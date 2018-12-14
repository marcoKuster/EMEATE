global class ADM_ReleaseBurndownUtils {
  
  //these values are still considered Closed by the Closed__c formula field but aren't applicable when calculating release charts if they have points
  public static Set<String> NA_STATUS_VALUES = new Set<String>{'Duplicate', 'Never'}; 
    
  
  @Future
  public static void updateReleaseBurndownsBulk( Set<Id> closedSprintIds ) {
    ADM_Sprint__c[] closedSprints = [select Id, End_Date__c, Scrum_Team__c from ADM_Sprint__c where Id in :closedSprintIds ORDER BY End_Date__c];

    Set<ID> scrumTeamIdsOfClosedSprints = new Set<ID>();
    for ( ADM_Sprint__c sprint:closedSprints ) {
      scrumTeamIdsOfClosedSprints.add( sprint.Scrum_Team__c );
    }
      
    // Get all the team release records for the teams that have just completed a sprint, and store them in a Map.
    ADM_Team_Release__c[] existingTeamReleases = [select Scrum_Team__c, Build__c, Id from ADM_Team_Release__c where Scrum_Team__c in :scrumTeamIdsOfClosedSprints];
    Map<Object, Map<Object, ADM_Team_Release__c>> existingTeamReleasesMap = new Map<Object, Map<Object, ADM_Team_Release__c>>();
    for (ADM_Team_Release__c aTeamRelease:existingTeamReleases) {
      if (!existingTeamReleasesMap.containsKey(aTeamRelease.Scrum_Team__c)) {
        Map<Object,ADM_Team_Release__c> releaseMap = new Map<Object, ADM_Team_Release__c>{ aTeamRelease.Build__c => aTeamRelease };  
        existingTeamReleasesMap.put(aTeamRelease.Scrum_Team__c,releaseMap);
      } else {
        Map<Object,ADM_Team_Release__c> releaseMap = existingTeamReleasesMap.get(aTeamRelease.Scrum_Team__c);
        releaseMap.put(aTeamRelease.Build__c, aTeamRelease);
      }  
    }      
    
    // Go through all the stories in the closed sprint(s) to find which releases they were in.
    // Keep track of any new team release records we need to create.
    // Keep track of the TeamRelease records that will need to have release burndowns updated (usedTeamReleaseIDs)
    ADM_Team_Release__c[] newTeamReleases = new ADM_Team_Release__c[]{};
    Set<ID> usedTeamReleaseIDs = new Set<ID>();
    for ( ADM_Sprint__c sprint:closedSprints ) {
          ADM_Work__c[] sprintStories = [select Scrum_Team__c, Scheduled_Build__c from ADM_Work__c where Sprint__c = :sprint.Id and Scheduled_Build__c != null];
          for (ADM_Work__c story:sprintStories) {
                //if the scrum team of the story and the sprint owner don't match then ignore
                if(sprint.Scrum_Team__c == story.Scrum_Team__c) {
                    if (!existingTeamReleasesMap.containsKey(story.Scrum_Team__c)) {
                      ADM_Team_Release__c newTeamRelease = new ADM_Team_Release__c(Scrum_Team__c = story.Scrum_Team__c, Build__c = story.Scheduled_Build__c);
                      newTeamReleases.add(newTeamRelease);
                      Map<Object,ADM_Team_Release__c> releaseMap = new Map<Object, ADM_Team_Release__c>{ story.Scheduled_Build__c => newTeamRelease };  
                      existingTeamReleasesMap.put(story.Scrum_Team__c,releaseMap);
                    } else if (!(existingTeamReleasesMap.get(story.Scrum_Team__c)).containsKey(story.Scheduled_Build__c)) {
                      ADM_Team_Release__c newTeamRelease = new ADM_Team_Release__c(Scrum_Team__c = story.Scrum_Team__c, Build__c = story.Scheduled_Build__c);
                      newTeamReleases.add(newTeamRelease);
                      Map<Object,ADM_Team_Release__c> releaseMap = existingTeamReleasesMap.get(story.Scrum_Team__c);
                      releaseMap.put(story.Scheduled_Build__c, newTeamRelease);
                    } else {
                      usedTeamReleaseIDs.add(existingTeamReleasesMap.get(story.Scrum_Team__c).get(story.Scheduled_Build__c).Id);
                    }
                }    
          }
    }
    
    
    
    // Insert any missing team release records
    if ( newTeamReleases.size() > 0 ) {
      try {
        insert newTeamReleases;
      } catch (DmlException e) { 
        if(e.getMessage().contains('You must select a Scrum Team')) {
            
        } else if(e.getMessage().contains('The scrum team you selected is not active')) {
            
        } else {
            //re throw exception to trigger email notification to the gus team
            throw e;
        }
      } 
      // Add these new TeamRelease records to the set of TeamReleases that will need release burndowns updated
      for (ADM_Team_Release__c newTeamRelease:newTeamReleases) {
        usedTeamReleaseIDs.add(newTeamRelease.id);
      }
    }

    ADM_Team_Release__c[] usedTeamReleases = [select Scrum_Team__c, Build__c, Id from ADM_Team_Release__c where Id in :usedTeamReleaseIDs];
    
    ADM_ReleaseBurndownUtils.updateReleaseBurndownForTeamReleases(usedTeamReleases); //consumes 3 SOQL * number of team releases
        
  }
  
  /* 
      @testcaseID a1DB00000000lO6
      @hierarchy GUS.Scrumforcetogus.Team Release.New Team Release
      @userstory a07B0000000EG5E
      @expectedResults The team release for the scrum team is created and the story points from the closed user stories are credited to the sprint
      @author jhatton
    */
    
    testMethod static void testUpdateReleaseBurndownsBulk() {
        Test.startTest();
        ADM_Sprint__c sprint = createTestClosedSprint();
        List<ADM_Work__c> works = [select id, Product_Tag__c, Scheduled_Build__c, Scrum_Team__c from ADM_Work__c where Sprint__c =:sprint.id];
        String build = works[0].Scheduled_Build__c;
        ADM_Work__c work = works[0];
        ADM_Product_Tag__c tag = [select id, Team__c from ADM_Product_Tag__c where id =: work.Product_Tag__c];
        tag.Team__c = sprint.Scrum_Team__c;
        update tag;
        //ensure scrum team is populated
        work.Scrum_Team__c = sprint.Scrum_Team__c;
        update work;
        
        //process release burn down
        ADM_ReleaseBurndownUtils.updateReleaseBurndownsBulk(new Set<Id>{sprint.id});
        Test.stopTest();
        //assert team release was created       
        List<ADM_Team_Release__c> teamReleases = [select id from ADM_Team_Release__c where Build__c = :build];
        System.assert(teamReleases != null);
        System.assertEquals(1, teamReleases.size(), 'Found unexpeted # of team releases for build:' + build);
        
        //asert release burndown items were created
        List<ADM_Release_Burndown_Item__c> rbis = [select id from ADM_Release_Burndown_Item__c where Team_Release__c =:teamReleases[0].id];
        System.assert(rbis != null);
        System.assertEquals(2, rbis.size(), 'Found unexpected # of burn down items for team release:' + teamReleases[0].id);
        
        //process a 2nd time and assert the same team release is used
        ADM_ReleaseBurndownUtils.updateReleaseBurndownsBulk(new Set<Id>{sprint.id});
        System.assertEquals(1, [select count() from ADM_Team_Release__c where Build__c = :build], 'Found unexpeted # of team releases for build:' + build);
    }
    
    /* 
      @testcaseID a1DB00000000lkt
      @hierarchy GUS.Scrumforcetogus.Team Release.New Team Release
      @userstory a07B0000000EG5E
      @expectedResults The story points for that user story will not be accredited until the user story belongs to the sprint that corresponds to the correct team. Also, duplicate team releases will not be created	
      @author jhatton
    */
    
    testMethod static void testDuplicateTeamReleasesAreNotCreatedIfSprintClosesWithStoryBelongingToAnotherTeam() {
        
        //This test is disabled because it would require more future calls then the platform gov limits allow for test 
        //methods.  This is because all three triggers (work, scrum team, sprint) have asynchronous methods
        
       /* ADM_Sprint__c sprint = createTestClosedSprint();
        List<ADM_Work__c> works = [select id, Scheduled_Build__c, Scrum_Team__c from ADM_Work__c where Sprint__c =:sprint.id];
        String build = works[0].Scheduled_Build__c;
        ADM_Work__c work = works[0];
        ADM_Scrum_Team__c team2 = ADM_ScrumTeam.createTestScrumTeam('RandomTestTeam2');
        //ensure scrum team is populated with team2 even though the sprint belonged to team1
        work.Scrum_Team__c = team2.id;
        update work;
        Test.startTest();
        //process release burn down
        ADM_ReleaseBurndownUtils.updateReleaseBurndownsBulk(new Set<Id>{sprint.id});
        Test.stopTest();
        //assert team release was created       
        List<ADM_Team_Release__c> teamReleases = [select id from ADM_Team_Release__c where Build__c = :build];
        System.assert(teamReleases != null);
        System.assertEquals(1, teamReleases.size(), 'Found unexpeted # of team releases for build:' + build);
        
        //asert release burndown items were created
        List<ADM_Release_Burndown_Item__c> rbis = [select id from ADM_Release_Burndown_Item__c where Team_Release__c =:teamReleases[0].id];
        System.assert(rbis != null);
        System.assertEquals(2, rbis.size(), 'Found unexpected # of burn down items for team release:' + teamReleases[0].id);
        
        //process a 2nd time and assert the same team release is used
        ADM_ReleaseBurndownUtils.updateReleaseBurndownsBulk(new Set<Id>{sprint.id});
        System.assertEquals(1, [select count() from ADM_Team_Release__c where Build__c = :build], 'Found unexpeted # of team releases for build:' + build);
        */
    }
  
  
  @IsTest
    public static ADM_Sprint__c createTestClosedSprint() {
        //Temp comment out while work is being done on scrum team trigger
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        User user = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = user.id, Allocation__c = 100);
        insert member;      

        Date startDate = Date.today().addDays(-14);  
        Date endDate = Date.today().addDays(-7);
        
        String sprintMonth = startDate.month().format();
        if(sprintMonth.length() == 1) {
            sprintMonth = '0' + sprintMonth;
        }
        String sprintName = startDate.year() + '.' + sprintMonth + 'abc123';
        
        ADM_Sprint__c sprint = new ADM_Sprint__c(Name = sprintName, Scrum_Team__c = team.id, Start_Date__c = startDate, End_Date__c = endDate);
        insert sprint;
        
        //create a pto record in the middle of the sprint
        Date ptoStart = Date.today().addDays(61);
        Date ptoEnd = Date.today().addDays(63);
        ADM_Time_Off_Log__c pto = new ADM_Time_Off_Log__c(Start_Date__c = ptoStart, End_Date__c = ptoEnd, User__c = user.id, Approved__c = true);
        insert pto;
        
        ADM_Work__c story = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story.Sprint__c = sprint.id;
        upsert story;
        
        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Just Do It', Assigned_To__c = user.id, Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task;
        
        return sprint;
    }
  
  webService static void updateReleaseBurndownForTeamReleases( ADM_Team_Release__c[] teamReleaseList) {
    // Keep track of all the release burndown items to update/insert
    ADM_Release_Burndown_Item__c[] itemsToUpdate = new ADM_Release_Burndown_Item__c[]{};
    ADM_Release_Burndown_Item__c[] itemsToInsert = new ADM_Release_Burndown_Item__c[]{};

    // Now cycle through all the team releases that need release burndown records to be updated
    for (ADM_Team_Release__c teamRelease:teamReleaseList) {
      //
      Map<Date, Double> storyPointsClosed = new Map<Date, Double>();
      Double totalReleaseStoryPoints = 0.0;
      Double totalClosed = 0.0;

      Set<Date> sprintEndDates = new Set<Date>();   // keep track of the end dates for all sprints in which the team has stories
      
      //FIRST get all of the team's stories in the release that are parented to a sprint
      ADM_Work__c[] releaseStories = [select Closed__c, Story_Points__c, Sprint__r.End_Date__c from ADM_Work__c where Status__c not in:NA_STATUS_VALUES and Scheduled_Build__c = :teamRelease.Build__c and Scrum_Team__c = :teamRelease.Scrum_Team__c and Sprint__c != null order by Sprint__r.End_Date__c];
      for (ADM_Work__c story:releaseStories) {
        Double storyPoints = story.Story_Points__c == null ? 0 : story.Story_Points__c;
        // We don't want to calculate release burndown for sprints in the future
        if (story.Sprint__r.End_Date__c <= System.today() ) {
          sprintEndDates.add( story.Sprint__r.End_Date__c );
          if ( story.Closed__c == 1) {
            totalClosed += storyPoints;
            storyPointsClosed.put( story.Sprint__r.End_Date__c, totalClosed );
            //
          } //END IF story has closed date
        }//END IF story is assigned to a sprint and the sprint end is before or equal to today
        
        //No matter what we always add to the total story points scheduled for the release
        totalReleaseStoryPoints += storyPoints;
      } // end for each user story 
      
      
      //Second get all of the stories that are still open, belong to the scheduled release but are NOT parented to a sprint
      releaseStories = [select Story_Points__c from ADM_Work__c where Status__c not in:NA_STATUS_VALUES and Scheduled_Build__c = :teamRelease.Build__c and Scrum_Team__c = :teamRelease.Scrum_Team__c and Sprint__c = null and Closed__c=0];
      
      for (ADM_Work__c story:releaseStories) {
        Double storyPoints = story.Story_Points__c == null ? 0 : story.Story_Points__c;
        totalReleaseStoryPoints += storyPoints;
      }
      
      ADM_Release_Burndown_Item__c[] existingItems = 
        [ select id, Story_Points__c, Date__c, Type__c from ADM_Release_Burndown_Item__c where Team_Release__c = :teamRelease.Id ORDER BY Date__c];
      Map<Date, Map<String, ADM_Release_Burndown_Item__c>> existingItemsMap = new Map<Date, Map<String, ADM_Release_Burndown_Item__c>>();
      for (ADM_Release_Burndown_Item__c rbi:existingItems ) {
        if ( !existingItemsMap.containsKey( rbi.Date__c ) ) {
          Map<String, ADM_Release_Burndown_Item__c> typeToRbiMap = new Map<String, ADM_Release_Burndown_Item__c>{ rbi.Type__c => rbi };  
          existingItemsMap.put( rbi.Date__c, typeToRbiMap );
        } else {
          Map<String, ADM_Release_Burndown_Item__c> typeToRbiMap = existingItemsMap.get( rbi.Date__c );
          typeToRbiMap.put( rbi.Type__c, rbi );
        }
      }
      //END FOR RBI
      
      //Get the set of sprint end dates and sort them
      List<Date> sortedEndDates = new List<Date>();
      for ( Date endDate:sprintEndDates ) {
        sortedEndDates.add( endDate );
      }
      sortedEndDates.sort();
      
      //Now walk through the collected items and either update or create new RBIs
      Double lastPointsClosed = 0.0;
      for ( Date endDate:sortedEndDates ) {
        Double closedStoryPoints = ( storyPointsClosed.containsKey( endDate ) ? storyPointsClosed.get( endDate ) : lastPointsClosed );
        if ( !existingItemsMap.containsKey( endDate ) ) {
          itemsToInsert.add( new ADM_Release_Burndown_Item__c(Team_Release__c = teamRelease.Id, Date__c = endDate, Story_Points__c = closedStoryPoints, Type__c = 'Done') );
          Double notDonePoints = totalReleaseStoryPoints - closedStoryPoints;
          if ( notDonePoints < 0 ) {
            notDonePoints = 0.0;
          }
          itemsToInsert.add( new ADM_Release_Burndown_Item__c(Team_Release__c = teamRelease.Id, Date__c = endDate, Story_Points__c = notDonePoints, Type__c = 'Not Done') );          
        } else {
          Map<String, ADM_Release_Burndown_Item__c> typeToItemMap = existingItemsMap.get( endDate );
          ADM_Release_Burndown_Item__c doneRbi = typeToItemMap.get( 'Done' );
          ADM_Release_Burndown_Item__c notDoneRbi = typeToItemMap.get( 'Not Done' );
          
          // If the burndown is being recalculated within the last 7 days we allow for an adjustment 
          // to the total story points for the release, otherwise we keep the total fixed, but allow
          // for an adjustment only in the closed story points.
          if (endDate >= Date.today().addDays(-7)) {
            doneRbi.Story_Points__c = closedStoryPoints;
            Double notDonePoints = totalReleaseStoryPoints - closedStoryPoints;
            if ( notDonePoints < 0 ) {
              notDonePoints = 0.0;
            }
            notDoneRbi.Story_Points__c = notDonePoints;
            itemsToUpdate.add( doneRbi );
            itemsToUpdate.add( notDoneRbi );
          } else {
            Double notDoneAdjustmentAmount = 0.0;
            // If the number of story points done for the sprint is different from before
            // we'll update the done story points, and adjust the not done so that the total story
            // points is the same as before. We do this to preserve the total story points that existed
            // at that point in time.
            if ( doneRbi.Story_Points__c != closedStoryPoints ) {
              notDoneAdjustmentAmount = closedStoryPoints - doneRbi.Story_Points__c;
              doneRbi.Story_Points__c = closedStoryPoints;
              notDoneRbi.Story_Points__c -= notDoneAdjustmentAmount;
              if ( notDoneRbi.Story_Points__c < 0 )
                notDoneRbi.Story_Points__c = 0.0;
              itemsToUpdate.add( doneRbi );
              itemsToUpdate.add( notDoneRbi );
            }
          }
        }  
        lastPointsClosed = closedStoryPoints;
      } // end for each endDate
    } // end for each team release

    if ( itemsToInsert.size() > 0 )
      insert itemsToInsert;
      
    if ( itemsToUpdate.size() > 0 )
      update itemsToUpdate;    
  }


}