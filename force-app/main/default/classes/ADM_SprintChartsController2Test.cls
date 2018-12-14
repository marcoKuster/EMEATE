@isTest
private class ADM_SprintChartsController2Test {
  /*
 @testcaseID  a1DB00000000HbF
 @userstoryID a07B0000000KsFc
 @Hierarchy GUS.Social Sprint.Sprint Details.Create new Sprint
 @ExpectedResults Sprint Available Hours Metrics section contains the Total Workdays field. This field gets calculated by the app after the user has closed the sprint manually or the sprint has been closed by the system after reaching the last day
 */

    static testMethod void testAvailableHoursChartHeight1TeamMember() {
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
        System.assert(sc.getHoursByAssigneeChartDataHeight() == sc.getDefaultChartHeight());
    }
  /*
 @testcaseID  a1DB00000002h0O
 @userstoryID a0790000000DCHa
 @Hierarchy GUS.Social Sprint.Charts and Tasks.Detail page
 @ExpectedResults Available Hours Chart Height fits 15 Team Members
 */

    static testMethod void testAvailableHoursChartHeight15TeamMembers() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);


        List<User> users = new List<User>();
        for (Integer x = 0; x < 15; x++) {
             User user = new User(Username = ADM_WorkUser.TEST_USERNAME + Math.random(), //username has to be unique across all tests
                                FirstName = ADM_WorkUser.TEST_FIRST_NAME,
                                LastName = ADM_WorkUser.TEST_LAST_NAME,
                                Email = ADM_WorkUser.TEST_EMAIL,
                                Alias = 'test',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                EmailEncodingKey = 'ISO-8859-1',
                                ProfileId = [select id from Profile where Name = 'System Administrator'].id, //only safe to assume the Sys Admin profile exists
                                LanguageLocaleKey = 'en_US');
            users.add(user);
        }
        Database.insert(users);

        List<ADM_Scrum_Team_Member__c> members = new List<ADM_Scrum_Team_Member__c>();
        for (User user : users) {
            ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = user.id, Allocation__c = 100);
            members.add(member);
        }
        insert members;

        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);

        // Make sure chart height has been increased over the default
        System.assert(sc.getHoursByAssigneeChartDataHeight() > sc.getDefaultChartHeight());
    }
  /*
 @testcaseID  a1DB00000000QO6
 @userstoryID a0790000000DCHa
 @Hierarchy GUS.Social Sprint.Charts and Tasks.Detail page
 @ExpectedResults The Charts and Tasks section shows the Member Name, Hours Assigned and Hours Available
 */

    static testMethod void testAvailableHoursData() {
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
        sc.calculateAvailableHoursData();
        System.assert(sc.m_idHoursAvailableMap.size() > 0);
        System.assert(sc.m_idHoursAssignedMap.size() > 0);
        //repeat with the view set to role
        sc.setViewChartByOption(ADM_SprintChartsController2.VIEW_BY_ROLE);
        sc.calculateAvailableHoursData();
        System.assert(sc.m_idHoursAvailableMap.size() > 0);
        System.assert(sc.m_idHoursAssignedMap.size() > 0);
    }


  /*
 @testcaseID  a1DB00000000QTx
 @userstoryID a0790000000DCHa
 @Hierarchy GUS.Social Sprint.Charts and Tasks.Detail page
 @ExpectedResults The sprint burndown calculates the total amount of hours (blue line) and compares it to the ideal amount of hours that should have been burned during the sprint (red line)
 */
    static testMethod void testBurndownChartURL() {
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
        System.assert(sc.getBurndownChartURL() != null);
    }
  /*
 @testcaseID  a1DB00000000QTy
 @userstoryID a0790000000DCHa
 @Hierarchy GUS.Social Sprint.Charts and Tasks.Detail page
 @ExpectedResults The Hours Remaining chart shows in the form of a graph the amount of hours assigned vs the amount of hours available. The green part is the the amount of hours available and the red part is the amount of hours assigned.
 */

    static testMethod void testHoursByAssigneeChartData() {
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
        System.assert(sc.getHoursByAssigneeChartData() != null);
    }

    /*
    @testcaseID a1DB00000000zJz
    @userStoryID a07B0000000ELLTIA4
    @Hierarchy GUS.ScrumforceToGUS.Sprint.Charts and Tasks.Team Velocity
    @Expected Results:
     Velocity Chart called "Team Velocity" is located on Charts & Task tab
     Y axis is the number of points (zero points)
     X axis is the sprint in chronological order (1 sprint)
     Average velocity is one flat line (no velocity yet)
     Actual velocity is one flat line (no velocity yet)
     Legend Average Velocity and Actual Velocity shows on right hand side
    @Author: Alexis Williams
    */

    static testMethod void testWithNewTeam() {
        ADM_SprintChartsController2 controller = new ADM_SprintChartsController2();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        controller.setScrumTeamId(team.Id);
        System.assertEquals(0, controller.sprints.size());
    }

    /*
    @testcaseID a1DB00000000zKD
    @userStoryID a07B0000000ELLTIA4
    @Hierarchy GUS.ScrumforceToGUS.Sprint.Charts and Tasks.Team Velocity
    @Expected Results
     Velocity Chart called "Team Velocity" is located on Charts & Task tab
     Y axis is the number of points (zero)
     X axis is the sprint in chronological order (10 sprints)
     Average velocity is a flat line
     Actual velocity is a flat line
     Legend Average Velocity and Actual Velocity shows on right hand side
    @Author: Alexis Williams
    */
    static testMethod void testWithTeamMoreThanTwoSprints() {
        List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        List<Selectoption> options;
        ADM_Sprint__c sprint;
        ADM_Work__c work;
        ADM_SprintChartsController2 controller = new ADM_SprintChartsController2();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        controller.setScrumTeamId(team.Id);
        String sprintName = '';
        List<String> alpha = new List<String>{'a','b','c','d','e','f','g','h','i','j','k'};

        for(Integer i = 6; 0 <= i; i--) {

            sprint = new ADM_Sprint__c();

            if(i == 6) {
                sprint.Start_Date__c = Date.today().addDays(-10);
                sprint.End_Date__c = Date.today();
            } else {
                sprint.Start_Date__c = Date.today().addDays( - 300 + ( i * 15 ) -10);
                sprint.End_Date__c = Date.today().addDays( - 300 + ( i * 15 ) );
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

            sprintName += '-' + team.Name;
            sprint.Name = sprintName;
            sprint.Scrum_Team__c = team.Id;

            sprints.add(sprint);
        }

        insert sprints;

        sprint = [select Id from ADM_Sprint__c where Scrum_Team__c = :team.Id order by Start_Date__c desc limit 1];

        Test.startTest();
            work = ADM_Work.createTestBug();
            work.Story_Points__c = 5.0;
            work.Sprint__c = sprint.Id;
            work.Scrum_Team__c = team.Id;
            update work;
        Test.stopTest();

        System.assertEquals(6, controller.sprints.size());
        System.assertEquals(6, ADM_SprintChartsController2.getCurrSprints(team.Id, 6).size());
        System.assertEquals(6, ADM_SprintChartsController2.getTotalSprints(team.Id));
    }

  /*
 @testcaseID  a1DB00000002h09
 @userstoryID a07B0000000KsD5
 @Hierarchy GUS.Social Sprint.Virtual Wall.Detail page
 @ExpectedResults Test list view when team has over 100 sprints
 */
    static testMethod void testWithTeamMoreThanTwentyFiveSprints() {
        List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        List<Selectoption> options;
        ADM_Sprint__c sprint;
        ADM_Work__c work;
        ADM_SprintChartsController2 controller = new ADM_SprintChartsController2();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        controller.setScrumTeamId(team.Id);
        String sprintName = '';
        List<String> alpha = new List<String>{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
        Integer j = 0;
        Integer days = 100;

        for(Integer i = 25; 0 <= i; i-- ) {

            sprint = new ADM_Sprint__c();

            if(i > 0 && Math.mod(i,6) == 0) {

                sprint.Start_Date__c = Date.today().addDays( -5000  + ( i * 15 ) - 10);
                sprint.End_Date__c = Date.today().addDays( -5000  + ( i * 15 ));
                sprint.Completed_Story_Points__c = i;

                sprintName = String.valueOf(sprint.Start_Date__c.month());

                if(sprintName.length() == 1) {
                    sprintName = '0' + sprintName;
                }

                sprintName = sprint.Start_Date__c.year() + '.' + sprintName;
                sprintName += alpha.get(0) + i;
                j = 0;
            } else {

                sprint.Start_Date__c = Date.today().addDays( -5000  + ( i * 15 ) - 10);
                sprint.End_Date__c = Date.today().addDays( -5000  + ( i * 15 ));
                sprint.Completed_Story_Points__c = i;

                sprintName = String.valueOf(sprint.Start_Date__c.month());

                if(sprintName.length() == 1) {
                    sprintName = '0' + sprintName;
                }

                sprintName = sprint.Start_Date__c.year() + '.' + sprintName;
                sprintName += alpha.get(0) + i;
                sprintName += alpha.get(j);
                j++;
            }

            sprintName += '-' + team.Name;
            sprint.Name = sprintName;
            sprint.Scrum_Team__c = team.Id;

            sprints.add(sprint);
        }

        insert sprints;

        System.assertEquals(6, controller.sprints.size());
        System.assertEquals(6, ADM_SprintChartsController2.getCurrSprints(team.Id, 6).size());
        System.assertEquals(10, ADM_SprintChartsController2.getTotalSprints(team.Id));
    }

    static testMethod void testupdateHoursAvailableChart() {
         List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        List<Selectoption> options;
        ADM_Sprint__c sprint;
        ADM_Work__c work;
        ADM_SprintChartsController2 controller = new ADM_SprintChartsController2();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        controller.setScrumTeamId(team.Id);
        ADM_SprintChartsController2.HoursByAssigneeChart chart   = ADM_SprintChartsController2.updateHoursAvailableChart(team.Id,2);
        System.assert(chart!=null,'chart should not be null for sprint');


    }

    static testMethod void testgetViewByOptions() {
         List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        List<Selectoption> options;
        ADM_Sprint__c sprint;
        ADM_Work__c work;
        ADM_SprintChartsController2 controller = new ADM_SprintChartsController2();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        controller.setScrumTeamId(team.Id);
         List<SelectOption> options1=controller.getViewByOptions();
        System.assert(options1!=null ,'option values should not be null');
    }
}