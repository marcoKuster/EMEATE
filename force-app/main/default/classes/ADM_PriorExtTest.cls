@isTest
private class ADM_PriorExtTest {

    @IsTest
    private static ADM_PriorExt setupPrioritizer() {
        List<ADM_Work__c> recs = new List<ADM_Work__c>();
        List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        ADM_Sprint__c sprint;
        insert work;
        work = [select id, Subject__c, Status__c, Use_Prioritizer__c, Found_In_Build__c, Scheduled_Build__c, Type__c, Impact__c, Frequency__c, Scrum_Team__c, Sprint__c, Product_Tag__c from ADM_Work__c where id=:work.id];
          
        System.assert(work.Scrum_Team__c != null);
        
        for(Integer i = 0; i < 50; i++) {
            ADM_Work__c w = work.clone(false, false);
            recs.add(w);
        }
        
        //repeat but add a priority rank
        for(Integer j = 1; j < 20; j++) {
            ADM_Work__c w = work.clone(false, false);
            w.Priority_Rank__c = j;
            recs.add(w);
        }
        
        insert recs;
        
        
        String sprintName = '';
        List<String> alpha = new List<String>{'a','b','c','d','e','f','g','h','i','j','k'};
        
        for(Integer i = 0; i < 7; i++) {
            sprint = new ADM_Sprint__c();
            
            if(i == 6) {
                sprint.Start_Date__c = Date.today().addDays(-1);
                sprint.End_Date__c = Date.today();
            } else {
                sprint.Start_Date__c = Date.today().addDays(-100 - i - 1);
                sprint.End_Date__c = Date.today().addDays(-100 - i);
                sprint.Completed_Story_Points__c = i;   
            }
            
            sprintName = String.valueOf(sprint.Start_Date__c.month());
            
            if(sprintName.length() == 1) {
                sprintName = '0' + sprintName;
            }
            
            sprintName = sprint.Start_Date__c.year() + '.' + sprintName;
            
            if(i == 6) {
                sprintName += alpha.get(0);
            } else {
                sprintName += alpha.get(i);
            }
            
            sprintName += '-AnotherTestSprint';
            sprint.Name = sprintName;
            sprint.Scrum_Team__c = work.Scrum_Team__c;
            
            sprints.add(sprint);                
        }
        
        insert sprints;
        
        System.debug('-->' + work.Scrum_Team__c);
        
        System.currentPageReference().getParameters().put('scrumteamId', work.Scrum_Team__c);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(work);
        ADM_PriorExt ext = new ADM_PriorExt(ctrl);
        
        System.assertEquals(work.Scrum_Team__c, ext.teamId);
        
        return ext;     
    }
    
    /*
    @testcaseID a1DB000000013B8
    @userstoryID a07B0000000FA3rIAG
    @Expected results AutoComplete should list all present and future Sprints available for that Scrum team, including Sprints where the end date is today
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Sprint AutoComplete
    Author: Alexis Williams
    */
    static testMethod void verifySprints() {
        ADM_PriorExt ext = setupPrioritizer();
        Boolean foundToday = false;
        
        for(String sprint : ext.sprints.split(',')) {
            if(sprint.contains('a-')) foundToday = true;
        }
        
        System.assertEquals(true, foundToday);
    }

    /*
    @testcaseID a1DB000000013A2
    @userstoryID a07B0000000FA3rIAG
    @Expected results All newly created work items should show in ascending ID order on the Backburner tile in Prioritizer page. Only the Record Type icon, Subject and Story Point number should show up per line. Also, a user can only add up to 400 items to the Backburner, if there are no other items already prioritized in the Backlog. Up to 400 items are allowed to be listed in the Prioritizer.
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Add records to Backburner
    Author: Alexis Williams
    */
    static testMethod void testWithOnlyBackBurnerRecords() {
        
        List<ADM_Work__c> recs = new List<ADM_Work__c>();
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        work = [select id, Subject__c, Status__c, Use_Prioritizer__c, Found_In_Build__c, Scheduled_Build__c, Type__c, Impact__c, Frequency__c, Scrum_Team__c, Sprint__c, Product_Tag__c from ADM_Work__C where id=:work.id];
        System.assert(work.Scrum_Team__c != null);
        for(Integer i = 0; i < 101; i++) {
            ADM_Work__c w = work.clone(false, false);
            recs.add(w);
        }
        
        insert recs;
        
        System.debug('-->' + work.Scrum_Team__c);
        System.currentPageReference().getParameters().put('scrumteamId', work.Scrum_Team__c);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(work);
        ADM_PriorExt ext = new ADM_PriorExt(ctrl);
        
        System.assertEquals(work.Scrum_Team__c, ext.teamId);
        System.assertNotEquals(null, ext.team);
        System.assertNotEquals(0, ext.backburnerRecs.size());
    }
    
        /*
    @testcaseID a1DB000000013AJ
    @userstoryID a07B0000000FA3rIAG
    @Expected results All items display on the Backlog after dragging and dropping. Also, these same items no longer appear on the Backburner. The items also save automatically with a backlog rank number that corresponds to the position they are being dropped in the tile. The other items in the Backlog get re-prioritized to the correct backlog rank number. Prioritized work is highlighted after being dropped into backlog once progress save modal has closed. Users can have up to 100 items in Backlog
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Add records to Backlog
    Author: Alexis Williams
    */
    static testMethod void testMovingItemFromBackburnerToBacklog() {
         ADM_PriorExt ext = setupPrioritizer();
         System.assert(ext.backburnerRecs.size() >= 1);
         //test moving item from back burner to the 3rd spot of the backlog
         ADM_Work__c movedItem = ext.backburnerRecs.get(0);      
         ADM_Work__c[] updatedWork = ADM_PriorExt.updateBacklogRank(movedItem.Id + '=3');
         for(ADM_Work__c w: updatedWork) {
            if(w.id == movedItem.id) {
                //verify it has been given priority rank of 3
                System.assertEquals(3, w.Priority_Rank__c);
            }   
         }
    }
    
        /*
    @testcaseID a1DB000000013A3
    @userstoryID a07B0000000FA3rIAG
    @Expected results The backlog rank field goes back to blank. The item that's being dragged and dropped back in the Backburner tile will stay in order of created date.
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Add records to Backburner
    Author: Alexis Williams
    */
    static testMethod void testMovingItemFromBacklogToBackburner() {
         ADM_PriorExt ext = setupPrioritizer();
         System.assert(ext.backburnerRecs.size() >= 1);
         ADM_Work__c movedItem = ext.backlogRecs.get(0);                 
         ADM_Work__c[] updatedWork = ADM_PriorExt.updateBacklogRank(movedItem.Id + '=-1');
         for(ADM_Work__c w: updatedWork) {
            if(w.id == movedItem.id) {
                //verify it has had its priority rank removed
                System.assertEquals(null, w.Priority_Rank__c);
            }   
         }
    }
    
        /*
    @testcaseID a1DB000000013Rj
    @userstoryID a07B0000000FA3rIAG
    @Expected results All items get re-prioritized in the Backlog according to where the user moves and drops the item(s) in the Backlog
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Add records to Backlog
    Author: Alexis Williams
    */
    static testMethod void testMovingItemDownInPriority() {
         ADM_PriorExt ext = setupPrioritizer();
         System.assert(ext.backlogRecs.size() >= 1);
         ADM_Work__c movedItem = ext.backlogRecs.get(0);         
         ADM_Work__c[] updatedWork = ADM_PriorExt.updateBacklogRank(movedItem.Id + '=3');
         for(ADM_Work__c w: updatedWork) {
            if(w.id == movedItem.id) {
                //verify it has had its priority rank updated
                System.assertEquals(3, w.Priority_Rank__c);
            }   
         }
    }
    
        /*
    @testcaseID a1DB000000013Ro
    @userstoryID a07B0000000FA3rIAG
    @Expected results All items get re-prioritized in the Backlog according to where the user moves and drops the item(s) in the Backlog
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Add records to Backlog
    Author: Alexis Williams
    */
    static testMethod void testMovingItemUpInPriority() {
         ADM_PriorExt ext = setupPrioritizer();
         System.assert(ext.backlogRecs.size() >= 1);
         ADM_Work__c movedItem = ext.backlogRecs.get(ext.backlogRecs.size() -1);         
         ADM_Work__c[] updatedWork = ADM_PriorExt.updateBacklogRank(movedItem.Id + '=1');
         for(ADM_Work__c w: updatedWork) {
            if(w.id == movedItem.id) {
                //verify it has had its priority rank updated
                System.assertEquals(1, w.Priority_Rank__c);
            }   
         }
    }
    
        /*
    @testcaseID a1DB00000001675
    @userstoryID a07B0000000FJKuIAO
    @Expected results Picklist shows fibonacci numbers if there are no points added to the story point scale field in Team
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Story Point Picklist
    Author: Alexis Williams
    */
    static testMethod void testGettingPtScale() {
        ADM_PriorExt ext = setupPrioritizer();
        System.assertEquals('1,2,3,5,8,13,21', ext.ptScale);
    }
    
    // Commenting out because of Too many SOQL error in Jenkins.
    
    
        /*
    @testcaseID a1DB000000018sL
    @userstoryID a07B0000000Eq0Q
    @hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Average Velocity Picklist
    @Expected results If the team has less then 2 sprints their velocity is zero
    Author: James Hatton
    */
 /*   static testMethod void testVelocityDefaultsToZeroWhenThereAreNotEnoughSprints() {
        ADM_Work__c work = ADM_Work.setupTestWork('User Story'); 
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        work.Scrum_Team__c = team.id;
        work.Priority__c = 'P0';
        insert work;
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(work);
        ADM_PriorExt ext = new ADM_PriorExt(ctrl);
        System.assertEquals(0, ext.getCalculatedVelocity());
        
    } */
    
    /* 
        @testcaseID a1DB00000001BhP
    @userstoryID a07B0000000Eq0Q
    @hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Average Velocity Picklist
    @Expected results Default story point sequence is Fibonnacci and includes 0
    Author: James Hatton
    */
    static testMethod void testDefaultStoryPointScale() {
        ADM_Work__c work = ADM_Work.setupTestWork('User Story'); 
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        team.Story_Point_Scale__c = null;
        update team;
        work.Scrum_Team__c = team.id;
        work.Priority__c = 'P0'; 
        insert work;
        System.currentPageReference().getParameters().put('scrumteamId', team.Id);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(work);
        ADM_PriorExt ext = new ADM_PriorExt(ctrl);
        System.assertEquals('0,1,2,3,5,8,13,21', ext.ptScale);
        
    }
    
    /* 
        @testcaseID a1DB00000001BhU
    @userstoryID a07B0000000Eq0Q
    @hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Average Velocity Picklist
    @Expected results Prioritizer reads Cookie for initial number of sprints
    Author: James Hatton
    */
    static testMethod void testCookieValueForNumberOfSprints() {
        ADM_Work__c work = ADM_Work.setupTestWork('User Story'); 
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        work.Scrum_Team__c = team.id;
        work.Priority__c = 'P0'; 
        insert work;
        System.currentPageReference().getParameters().put('scrumteamId', team.Id);
        Cookie cookie = new Cookie('velocityControl_' + team.id, '5',null,-1,false);
        Apexpages.currentPage().getCookies().put('velocityControl_' + team.id, cookie);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(work);
        ADM_PriorExt ext = new ADM_PriorExt(ctrl);
        System.assertEquals(5, ADM_PriorExt.numberOfSprints);  
    }
        /*
    @testcaseID a1DB00000001BrI
    @userstoryID a07B0000000FSyiIAG
    @Expected results Bucket only shows 50 items on initial load and no "Show More" link shows on that bucket
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Cap Prioritizer
    Author: James Hatton
    */
    
        /*
    @testcaseID a1DB00000001BrH
    @userstoryID a07B0000000FSyiIAG
    @Expected results Bucket only shows 50 items on initial load and no "Show More" link shows on that bucket
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Cap Prioritizer
    Author: James Hatton
    */
        /*
    @testcaseID a1DB00000001BrG
    @userstoryID a07B0000000FSyiIAG
    @Expected results Bucket only shows 50 items on initial load and no "Show More" link shows on that bucket
    @Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Cap Prioritizer
    Author: James Hatton
    */
    static testMethod void testShowMoreRecords() {
        ADM_PriorExt ext = setupPrioritizer();
        ADM_Work__c work = ext.backlogRecs.get(0);
        ADM_Work__c w;
        
        String lastBacklogId = ext.backlogRecs.get(ext.backlogRecs.size() -1).Id;
        String lastBackburnerId = ext.backburnerRecs.get(ext.backburnerRecs.size() -1).Id;
                
        ADM_DmlResult result = ADM_PriorExt.getMoreRecs(lastBacklogId,lastBackburnerId, '1');
        System.assertNotEquals(null, result);
        System.assert(result.backlog != null);
        System.assert(result.backlog.size() < 300);
    
    }
    
        /*
    @testcaseID a1DB00000001Bnu
    @userstoryID a07B0000000Eq0d
    @Expected results Only Backlog and Backburner tiles should be ON, and all items in these two buckets should show on the Prioritizer page (up to 100 for Backlog and up to 300 for Backburner). Filter tiles and buckets should          be off by default. Backlog and Backburner tiles show a dark blue font and light blue background. Filter tile shows an orange font and gray background
    @Hierarchy GUS.ScrumTeams.Prioritizer.Tile Filtering
    */
    static testMethod void testGetFiltered() {
        ADM_Build__c newBuild = new ADM_Build__c();
        newBuild.Name = 'NewTestBuild--asdf9876';
        insert newBuild;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        works.get(0).Use_Prioritizer__c = true;
        works.get(0).Priority_Rank__c = 1;
        works.get(0).Scheduled_Build__c = newBuild.Id;
        works.get(1).Use_Prioritizer__c = true;
        works.get(1).Priority_Rank__c = null;
        works.get(1).Scheduled_Build__c = newBuild.Id;
        upsert works;
        works = [select Id, Scrum_Team__c from ADM_Work__c where Id in :works];
        
        List<ADM_Work__c> actual = ADM_PriorExt.getFiltered(works.get(0).Scrum_Team__c, 'Scheduled_Build__r.Name', newBuild.Name);
        
        Boolean containsWork1 = false;
        Boolean containsWork2 = false;
        for(ADM_Work__c work : actual) {
            if(work.Id == works.get(0).Id) {
                containsWork1 = true;
            }
            if(work.Id == works.get(1).Id) {
                containsWork2 = true;
            }
        }
        System.assert(containsWork1, 'Expected the filtered list to contain the first work item');
        System.assert(containsWork2, 'Expected the filtered list to contain the second work item');
    }
    
        /*
    @testcaseID a1DB00000001Bo2
    @userstoryID a07B0000000Eq0d
    @Expected results All items show listed on the Filter bucket, once the user filters on all open items for a specific theme
    @Hierarchy GUS.ScrumTeams.Prioritizer.Tile Filtering
    */
    static testMethod void testGetFilteredTheme() {
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'NewTestTheme--asdf9876';
        insert theme;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        works.get(0).Use_Prioritizer__c = true;
        works.get(0).Priority_Rank__c = 1;
        works.get(1).Use_Prioritizer__c = true;
        works.get(1).Priority_Rank__c = null;
        upsert works;
        works = [select Id, Scrum_Team__c from ADM_Work__c where Id in :works];
        
        //add the theme assignments
        List<ADM_Theme_Assignment__c> themeAssignments = new List<ADM_Theme_Assignment__c>();
        for(Integer index = 0; index < works.size(); index++) {
            ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
            themeAssignment.Theme__c = theme.Id;
            themeAssignment.Work__c = works.get(index).Id;
            themeAssignments.add(themeAssignment);
        }
        insert themeAssignments;
        
        String searchValue = EncodingUtil.urlEncode(theme.Name, 'UTF-8');
        
        List<ADM_Work__c> actual = ADM_PriorExt.getFiltered(works.get(0).Scrum_Team__c, 'Theme', searchValue);
        
        System.assertEquals(2, actual.size(), 'Expected two work records to be returned');
        System.assertEquals(works.get(0).Id, actual.get(0).Id, 'Expected the first work record to be the value with the rank');
        System.assertEquals(works.get(1).Id, actual.get(1).Id, 'Expected the second work record to be the value without the rank');
    }
    
        /*
    @testcaseID a1DB00000002jgc
    @userstoryID a07B0000000U5yHIAS
    @Expected results When filtering by theme = blank, work items with no theme should show on Filter tile  
    @Hierarchy GUS.Multi Themes.Prioritizer
    */
    /**
     * Whenever getFiltered is invoked with a blank search value, all work records without theme assignments should be returned
     */
    static testMethod void testGetFilteredThemeWithBlank() {
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'NewTestTheme--asdf9876';
        insert theme;
        
        //create two records
        // the first will have a theme assignment
        // the second will be the one expect in the assertions
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        works.get(0).Use_Prioritizer__c = true;
        works.get(0).Priority_Rank__c = 1;
        works.get(1).Use_Prioritizer__c = true;
        works.get(1).Priority_Rank__c = null;
        upsert works;
        works = [select Id, Scrum_Team__c from ADM_Work__c where Id in :works];
        
        //add a theme assignment to the first record
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Theme__c = theme.Id;
        themeAssignment.Work__c = works.get(0).Id;
        insert themeAssignment;
        
        //call getFiltered with a blank search value
        List<ADM_Work__c> actual = ADM_PriorExt.getFiltered(works.get(0).Scrum_Team__c, 'Theme', '');
        
        System.assertEquals(1, actual.size(), 'Expected one work records to be returned - the one without the team assignment');
        System.assertEquals(works.get(1).Id, actual.get(0).Id, 'Expected the second work record to be the value returned');
    }
            /*
    @testcaseID a1DB000000013AY
    @userstoryID a07B0000000FA3r
    @Expected results Backlog tile no longer displays on Prioritizer page
    @Hierarchy GUS.ScrumTeams.Prioritizer.Click on  Backlog Button
    */
    static testMethod void testGetBacklog() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        works.get(0).Use_Prioritizer__c = true;
        works.get(0).Priority_Rank__c = 1;
        works.get(1).Use_Prioritizer__c = true;
        works.get(1).Priority_Rank__c = 2;
        upsert works;
        works = [select Id, Scrum_Team__c from ADM_Work__c where Id in :works];
        
        List<ADM_Work__c> actual = ADM_PriorExt.getBacklog(works.get(0).Scrum_Team__c);
        
        Boolean containsWork1 = false;
        Boolean containsWork2 = false;
        for(ADM_Work__c work : actual) {
            if(work.Id == works.get(0).Id) {
                containsWork1 = true;
            }
            if(work.Id == works.get(1).Id) {
                containsWork2 = true;
            }
        }
        System.assert(containsWork1, 'Expected the filtered list to contain the first work item');
        System.assert(containsWork2, 'Expected the filtered list to contain the second work item');
    }
            /*
    @testcaseID a1DB00000001BoQ
    @userstoryID a07B0000000Eq0d
    @Expected results All items highlighted should be saved with the new build
    @Hierarchy GUS.ScrumTeams.Prioritizer.Tile Filtering
    */
    static testMethod void testUpdateBuild() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        works.get(1).Scheduled_Build__c = null;
        upsert works;
        String workIds = getWorkIdsAsCSV(works);
        
        ADM_Build__c newBuild = new ADM_Build__c();
        newBuild.Name = 'NewTestBuild--asdf9876';
        insert newBuild;
        
        Test.startTest();
        List<ADM_PriorExt.UpdateAssignmentResult> results = ADM_PriorExt.updateAssignments(team.Id, workIds, newBuild.Name, '', '');
        Test.stopTest();
        
        works = [select Scheduled_Build__c from ADM_Work__c where ID in :works];
        
        System.assertEquals(2, results.size(), 'Expected 2 work records to change');
        System.assertEquals(newBuild.Id, works.get(0).Scheduled_Build__c);
        System.assertEquals(newBuild.Id, works.get(1).Scheduled_Build__c);
    }
        /*
    @testcaseID a1DB00000001BoT
    @userstoryID a07B0000000Eq0d
    @Expected results All items highlighted should be saved with the new sprint
    @Hierarchy GUS.ScrumTeams.Prioritizer.Tile Filtering
    */
    
    static testMethod void testUpdateBuildWithUnknownName() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        works.get(1).Scheduled_Build__c = null;
        upsert works;
        String workIds = getWorkIdsAsCSV(works);
        
        try {
            Test.startTest();
            List<ADM_PriorExt.UpdateAssignmentResult> results = ADM_PriorExt.updateAssignments(team.Id, workIds, 'Unknown Build', '', '');
            Test.stopTest();
            System.assert(false, 'Expected an exception to be thrown since the build name specified is not valid');
        } catch(ADM_ApplicationException exc) {
            System.assert(exc.getMessage().contains('Unable to find build'));
        }
        
        works = [select Scheduled_Build__c from ADM_Work__c where ID in :works];
        
        System.assertEquals(null, works.get(0).Scheduled_Build__c);
        System.assertEquals(null, works.get(1).Scheduled_Build__c);
    }
    
    static testMethod void testUpdateSprint() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        works.get(1).Sprint__c = null;
        upsert works;
        String workIds = getWorkIdsAsCSV(works);
        
        ADM_Sprint__c newSprint = ADM_Sprint.createEmptyTestSprint();
        newSprint = [select Name from ADM_Sprint__c where Id = :newSprint.Id];
        
        Test.startTest();
        List<ADM_PriorExt.UpdateAssignmentResult> results = ADM_PriorExt.updateAssignments(team.Id, workIds, '', newSprint.Name, '');
        Test.stopTest();
        
        works = [select Sprint__c from ADM_Work__c where ID in :works];
        
        System.assertEquals(2, results.size(), 'Expected 2 work records to change');
        System.assertEquals(newSprint.Id, works.get(0).Sprint__c);
        System.assertEquals(newSprint.Id, works.get(1).Sprint__c);
    }
    
    
    static testMethod void testUpdateSprintWithUnknownName() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        works.get(1).Sprint__c = null;
        upsert works;
        String workIds = getWorkIdsAsCSV(works);
        
        try {
            Test.startTest();
            List<ADM_PriorExt.UpdateAssignmentResult> results = ADM_PriorExt.updateAssignments(team.Id, workIds, '', 'Unknown Sprint', '');
            Test.stopTest();
            System.assert(false, 'Expected an exception to be thrown since the sprint name specified is not valid');
        } catch(ADM_ApplicationException exc) {
            System.assert(exc.getMessage().contains('Unable to find sprint'));
        }
        works = [select Sprint__c from ADM_Work__c where ID in :works];
        
        System.assertEquals(null, works.get(0).Sprint__c);
        System.assertEquals(null, works.get(1).Sprint__c);
    }
    
        /*
    @testcaseID a1DB00000001BoW
    @userstoryID a07B0000000Eq0d
    @Expected results All items highlighted should be saved with the new theme
    @Hierarchy GUS.ScrumTeams.Prioritizer.Tile Filtering
    */
    static testMethod void testUpdateTheme() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        upsert works;
        String workIds = getWorkIdsAsCSV(works);
        
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'Theme test--asdf9876';
        insert theme;
        
        Test.startTest();
        List<ADM_PriorExt.UpdateAssignmentResult> results = ADM_PriorExt.updateAssignments(team.Id, workIds, '', '', theme.Name);
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Expected 2 work records to change');
        
        //check to make sure the assignments are found for the work items
        List<ADM_Theme_Assignment__c> themeAssignments = [select Id, Work__c, Theme__c from ADM_Theme_Assignment__c where Work__c in :works];
        List<Boolean> foundWorks = new List<Boolean>{false, false};
        for(Integer index = 0; index < works.size(); index++) {
            ADM_Work__c work = works.get(index);
            for(ADM_Theme_Assignment__c themeAssignment : themeAssignments) {
                if(themeAssignment.Work__c == work.Id && themeAssignment.Theme__c == theme.Id) {
                    foundWorks.set(index, true);
                    break;
                }
            }
        } 
        System.assert(foundWorks.get(0), 'Expected a new theme assignment for the first work and the theme');
        System.assert(foundWorks.get(1), 'Expected a new theme assignment for the second work and the theme');
    }
    
    static testMethod void testUpdateThemeWithUnknownName() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        upsert works;
        String workIds = getWorkIdsAsCSV(works);
        
        try {
            Test.startTest();
            List<ADM_PriorExt.UpdateAssignmentResult> results = ADM_PriorExt.updateAssignments(team.Id, workIds, '', '', 'Unknown Theme');
            Test.stopTest();
            System.assert(false, 'Expected an exception to be thrown since the theme name specified is not valid');
        } catch(ADM_ApplicationException exc) {
            System.assert(exc.getMessage().contains('Unable to find theme'));
        }
        
        works = [select Theme__c from ADM_Work__c where ID in :works];
        
        System.assertEquals(null, works.get(0).Theme__c);
        System.assertEquals(null, works.get(1).Theme__c);
    }
    
        /*
    @testcaseID a1DB00000004loW
    @userstoryID a07B0000000U5yH
    @Expected results Display different, multiple themes on backlog
    @Hierarchy GUS.Multi Themes.Prioritizer
    */
    /**
     * Ensure that there is no error if a theme is added to a work item that is already assigned to the theme and that
     * no new theme assignments are created.
     */
    static testMethod void testAddingThemeDoesntAddSameTwice() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        ADM_Work__c work = ADM_Work.createTestBug();
        String workIds = work.Id;
        
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'Theme test--asdf9876';
        insert theme;
        
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__c = theme.Id;
        insert themeAssignment;
        
        Test.startTest();
        List<ADM_PriorExt.UpdateAssignmentResult> results = ADM_PriorExt.updateAssignments(team.Id, workIds, '', '', theme.Name);
        Test.stopTest();
        
        //check to make sure no new assignments are found for the work item
        List<ADM_Theme_Assignment__c> themeAssignments = [select Id, Work__c, Theme__c from ADM_Theme_Assignment__c where Work__c = :work.Id];
        System.assert(themeAssignments.size() == 1, 'Expected only one theme assignment to set on the work, since no new themes were added');
    }


            /*
    @testcaseID a1DB00000002jgn
    @userstoryID a07B0000000FA3rIAG
    @Expected results Divider should stay exactly where it matches the average velocity picklist
    @Hierarchy GUS.ScrumTeams.Prioritizer.Sprint Backlog Dividers
    */
    static testMethod void testRecalculateVelocity() {
        User user = ADM_WorkUser.createTestUser();
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        
        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c();
        member.Scrum_Team__c = team.Id;
        member.Member_Name__c = user.Id;
        member.Allocation__c = 100;
        insert member;
        
        ADM_Sprint__c sprint1 = new ADM_Sprint__c();
        sprint1.Name = '2010.01a-TestTeam asdf9876';
        sprint1.Scrum_Team__c = team.Id;
        sprint1.Start_Date__c = Date.newInstance(2010, 1, 1);
        sprint1.End_Date__c = Date.newInstance(2010, 1, 15);
        sprint1.Completed_Story_Points__c = 2;
        insert sprint1;
        
        ADM_Sprint__c sprint2 = new ADM_Sprint__c();
        sprint2.Name = '2010.01b-TestTeam asdf9876';
        sprint2.Scrum_Team__c = team.Id;
        sprint2.Start_Date__c = Date.newInstance(2010, 1, 15);
        sprint2.End_Date__c = Date.newInstance(2010, 1, 31);
        sprint2.Completed_Story_Points__c = 2;
        insert sprint2;
        
        ADM_Work__c work = ADM_Work.createTestBug();
        work.Sprint__c = sprint1.Id;
        upsert work;
        
        System.currentPageReference().getParameters().put('scrumteamId', team.Id);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_PriorExt extension = new ADM_PriorExt(controller);
        
        ADM_PriorExt.numberOfSprints = 2;
        Integer actual = extension.getCalculatedVelocity();
        System.assertEquals(2, actual);
    }
    
    private static String getWorkIdsAsCSV(List<ADM_Work__c> works) {
        String workIds = '';
        for(Integer index = 0; index < works.size(); index++) {
            workIds += works.get(index).Id;
            if(index < works.size() - 1) {
                workIds += ',';
            }
        }
        return workIds;
    }
}