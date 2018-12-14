@IsTest
public with sharing class ADM_SprintBurnDownUtilsTest {

    /*
    @testcaseID
    @userstory https://gus.salesforce.com/a07B0000000Syoo
    @Hierarchy
    @Expected Results Create sprint for 2012.12b and assert that Christmas day and weekends are not included, making only 10 working days.
    @author Tyler Clark
    */
    testMethod static void testDaysBetweenMinusWeekendsAndCompanyHolidays() {
        //make sure there are no other holidays
        List<ADM_Time_Off_Log__c> existingHolidays = [select Id from ADM_Time_Off_Log__c where RecordTypeId in (select Id from RecordType where Name='Company Holiday')];
        delete existingHolidays;

        ADM_Sprint__c sprint = new ADM_Sprint__c();
        Date startDate = Date.newInstance(2012, 12, 15);
        Date endDate = Date.newInstance(2012, 12, 31);
        sprint.Start_Date__c = startDate;
        sprint.End_Date__c = endDate;
        sprint.Name = '2012.12b-Test';
        sprint.Scrum_Team__c = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName().Id;
        insert sprint;

        ADM_Time_Off_Log__c holiday = new ADM_Time_Off_Log__c();
        Date holidayDate = Date.newInstance(2012, 12, 25); // Christmas
        holiday.Start_Date__c = holidayDate;
        holiday.End_Date__c = holidayDate;
        holiday.RecordTypeId = [select id from RecordType where Name = 'Company Holiday'].id;
        insert holiday;

        Test.startTest();
        Integer daysWithoutWeekends = ADM_SprintBurnDownUtils.daysBetweenMinusWeekends(startDate, endDate);
        List<ADM_Sprint__c> sprintList = new List<ADM_Sprint__c>{sprint};
        List<ADM_Sprint__c> sprintReturnList = ADM_SprintBurnDownUtils.daysBetweenMinusWeekendsAndCompanyHolidays(sprintList);
        System.assertEquals(10, sprintReturnList.get(0).Total_Workdays__c, 'Unexpected days without weekend and holiday for Sprint ' + sprintReturnList);
        Test.stopTest();
    }

    /*
    @testcaseID
    @userstory https://gus.salesforce.com/a07B0000000Syoo
    @Hierarchy
    @Expected Assert that weekends are not included
    @author Tyler Clark
    */
    testMethod static void testDaysBetweenMinusWeekends() {
        Date startDate = Date.newInstance(2012, 12, 15);
        Date endDate = Date.newInstance(2012, 12, 31);
        Test.startTest();
        Integer daysWithoutWeekends = ADM_SprintBurnDownUtils.daysBetweenMinusWeekends(startDate, endDate);
        System.assertEquals(11, daysWithoutWeekends, 'Unexpected days without weekend');
        Test.stopTest();
    }

    /**
     * When the date is older than 1901, an exception is thrown
     */
    testMethod static void testDaysBetweenMinusWeekendsWithOldDates() {
        Date startDate = Date.newInstance(1900, 12, 15);
        Date endDate = Date.newInstance(2012, 12, 31);
        try {
            Integer daysWithoutWeekends = ADM_SprintBurnDownUtils.daysBetweenMinusWeekends(startDate, endDate);
            System.assert(false, 'Expected an exception to be thrown because the date is older than 1900');
        } catch(Exception exc) {
        	System.assert(exc.getMessage().contains('Unable to compare dates older'), 'Expected the exception to be about the old dates: ' + exc.getMessage());
        }
    }

    /*
    @testcaseID a1DB00000000QOh
    @userstory a0790000000DAdb
    @Hierarchy GUS.ScrumforceToGUS.Sprint.Sprint Information.Create new Sprint
    @Expected Results Velocity is disabled when creating a new sprint. This is calculated by an algorithm
    */
    testMethod static void testCalculateVelocityForWorkItemUpdatedFromOpenToClosed() {
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_Work__c work = [select id, Closed__c, Story_Points__c, Sprint__c from ADM_Work__c where Sprint__c = :sprint.id limit 1];
        //verify sprint has ZERO completed points to begin with
        System.assertEquals(null, sprint.Completed_Story_Points__c);
        //verify work is open and has story points
        System.assert(work.Closed__c == 0);
        System.assert(work.Story_Points__c != null);
        System.assert(work.Story_Points__c > 0);
        System.assert(work.Sprint__c != null);
        work.Status__c = 'Closed';

        Test.startTest();
            ADM_ScopeChangeController.setSprintWorkCommitment(sprint.Id, true);
            update work;
        Test.stopTest();

        //verfiy sprints completed points equal the previously closed story - only one closed work record due to gov limits on test methods
        ADM_Sprint__c updatedSprint = [select id, Committed_Items_Completed__c, Committed_Story_Points_Completed__c, Completed_Story_Points__c from ADM_Sprint__c where id =:sprint.id];
        System.assertEquals(work.Story_Points__c, updatedSprint.Completed_Story_Points__c, 'Completed Story points should equal work records story points. Updated Sprint:' + updatedSprint + ' Work:' + work);
        System.assertEquals(work.Story_Points__c, updatedSprint.Committed_Story_Points_Completed__c, 'Committed Story Points Completed should equal work records story points. Updated Sprint:' + updatedSprint + ' Work:' + work);
        System.assertEquals(1, updatedSprint.Committed_Items_Completed__c, 'Committed Items Completed should equal # of committed work items completed. Updated Sprint:' + updatedSprint + ' Work:' + work);
    }

     static testMethod void testAverageVelocityOfSprintUpdatesOnClosingInvestigations() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c investigation = ADM_Work.setupTestWork('Investigation');
        investigation.Status__c = 'New';
        investigation.Sprint__c = sprint.id;
        investigation.Story_Points__c = 3;
        investigation.Severity_Level__c = '1';

        insert investigation;
        
        System.assertEquals(sprint.Completed_Story_Points__c,null,'Initial Actual Velocity is 0');
        Test.startTest();
            ADM_ScopeChangeController.setSprintWorkCommitment(sprint.Id, true);
            investigation.Status__c = 'closed - no fix - will not fix';
            update investigation;
        Test.stopTest();
        System.assertEquals('closed - no fix - will not fix',investigation.Status__c,'Status is updated to closed');
        ADM_Sprint__c sprintUpdated = [select id, Committed_Items_Completed__c, Committed_Story_Points_Completed__c, Completed_Story_Points__c from ADM_Sprint__c where id =: sprint.id ];
        System.assertEquals(investigation.Story_Points__c,sprintUpdated.Completed_Story_Points__c,'Actual Velocity is now updated to 3');
        System.assertEquals(investigation.Story_Points__c, sprintUpdated.Committed_Story_Points_Completed__c, 'Committed Story Points Completed should equal work records story points. Updated Sprint:' + sprintUpdated + ' Investigation:' + investigation);
        System.assertEquals(1, sprintUpdated.Committed_Items_Completed__c, 'Committed Items Completed should equal # of committed work items completed. Updated Sprint:' + sprintUpdated + ' Investigation:' + investigation);
     }

    /*
    @Expected Results No exception should be thrown when asyncCalculateVelocity is called with sprint with an inactive team.
    */
    testMethod static void testCalculateVelocityForInactivatedTeam() {
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_Work__c work = [select id, Closed__c, Story_Points__c, Sprint__c, Scrum_Team__c, Scrum_Team__r.Id, Scrum_Team__r.Active__c from ADM_Work__c where Sprint__c = :sprint.id limit 1];
        
        //inactivate the team associated to the sprint
        ADM_Scrum_Team__c team = [select Id, Active__c from ADM_Scrum_Team__c where Id = :sprint.Scrum_Team__c];
        team.Active__c = false;
        update team;
        
        Test.startTest();
        ADM_SprintBurnDownUtils.asyncCalculateVelocity(new Set<Id>{sprint.Id});
        Test.stopTest();
    }

    testMethod static void testVelocityIsUpdatedWhenStatusChangesFromNotReproducibleToClosed() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Status__c = 'Not Reproducible';
        work.Sprint__c = sprint.id;
        work.Story_Points__c = 2;
        insert work;
        
        Test.startTest();
            ADM_ScopeChangeController.setSprintWorkCommitment(sprint.Id, true);
            //now update the work to Closed and verify the sprint velocity increases by the correct amount
            work.Status__c = 'Closed';
            update work;
        Test.stopTest();
        //verfiy sprints completed points equal the previously closed story - only one closed work record due to gov limits on test methods
        ADM_Sprint__c updatedSprint = [select id, Committed_Items_Completed__c, Committed_Story_Points_Completed__c, Completed_Story_Points__c from ADM_Sprint__c where id =:sprint.id];
        System.assertEquals(work.Story_Points__c, updatedSprint.Completed_Story_Points__c, 'Completed Story points should equal work records story points. Updated Sprint:' + updatedSprint + ' Work:' + work);
        System.assertEquals(work.Story_Points__c, updatedSprint.Committed_Story_Points_Completed__c, 'Committed Story Points Completed should equal work records story points. Updated Sprint:' + updatedSprint + ' Work:' + work);
        System.assertEquals(1, updatedSprint.Committed_Items_Completed__c, 'Committed Items Completed should equal # of committed work items completed. Updated Sprint:' + updatedSprint + ' Work:' + work);
    }

     testMethod static void testCalculateVelocityForTODOUpdatedFromOpenToClosed() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c work = ADM_Work.createTestToDo();
        work.Sprint__c = sprint.id;
        work.Story_Points__c = 2;
        update work;
        
        Test.startTest();
            ADM_ScopeChangeController.setSprintWorkCommitment(sprint.Id, true);
            //verify sprint has ZERO completed points to begin with
            System.assertEquals(null, sprint.Completed_Story_Points__c);
            //verify work is open at the moment and then complete it
            System.assert(work.Status__c != 'Completed');
            work.Status__c = 'Completed';
            update work;
        Test.stopTest();
        //verfiy sprints completed points equal the previously closed story - only one closed work record due to gov limits on test methods
        ADM_Sprint__c updatedSprint = [select id, Committed_Items_Completed__c, Committed_Story_Points_Completed__c, Completed_Story_Points__c from ADM_Sprint__c where id =:sprint.id];
        System.assertEquals(work.Story_Points__c, updatedSprint.Completed_Story_Points__c, 'Completed Story points should equal TODO records story points. Updated Sprint:' + updatedSprint + ' Work TODO:' + work);
        System.assertEquals(work.Story_Points__c, updatedSprint.Committed_Story_Points_Completed__c, 'Committed Story Points Completed should equal work records story points. Updated Sprint:' + updatedSprint + ' Work:' + work);
        System.assertEquals(1, updatedSprint.Committed_Items_Completed__c, 'Committed Items Completed should equal # of committed work items completed. Updated Sprint:' + updatedSprint + ' Work:' + work);
    }

    @isTest
    public static void mapActualSprintBurndownChartTest(){
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c work = ADM_Work.createTestToDo();
        work.Sprint__c = sprint.id;
        work.Story_Points__c = 2;
        work.Status__c='Closed';
        update work;
        List<ADM_Work__c> works = new List<ADM_Work__c>();
        works.add(work);
        ADM_SprintBurnDownUtils utils = new ADM_SprintBurnDownUtils();
        ADM_SprintBurnDownUtils.ActualSprintData asd = utils.mapActualSprintBurndownChart(works,sprint);
        System.debug('ActualSprintData : '+ asd);
        ADM_SprintBurnDownUtils.ActualSprintData asd1 = utils.getSprintRealBurnDownItems(sprint, 'Story Points');
        Map<Date, Double> asd2 = utils.getSprintIdealBurnDownItems(sprint);
        ADM_SprintBurnDownUtils.findFutureSprints();
        ADM_SprintBurnDownUtils.forceSprintRecalc(sprint.id);
        ADM_SprintBurnDownUtils.patchBurndownItems(sprint.id);
        System.assertEquals(work.Story_Points__c, 2);
    }

    @isTest
    public static void mapActualSprintBurndownTaskHoursChartTest(){
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c work = ADM_Work.createTestToDo();
        work.Sprint__c = sprint.id;
        work.Closed_On__c = Date.today();
        update work;
        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = UserInfo.getUserId(), Actual_Hours__c = 10, Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = work.id, SprintId__c = sprint.id, Completed_On__c=Date.today());
        insert task;

        ADM_SprintBurnDownUtils utils = new ADM_SprintBurnDownUtils();
        ADM_SprintBurnDownUtils.ActualSprintData asd = utils.mapActualSprintTaskHoursBurndownChart(sprint);
        System.debug('ActualSprintData : '+ asd);
        ADM_SprintBurnDownUtils.ActualSprintData asd1 = utils.getSprintRealBurnDownItems(sprint, 'Task Hours');
        Map<Date, Double> asd2 = utils.getSprintIdealBurnDownItems(sprint);
        ADM_SprintBurnDownUtils.findFutureSprints();
        ADM_SprintBurnDownUtils.forceSprintRecalc(sprint.id);
        ADM_SprintBurnDownUtils.patchBurndownItems(sprint.id);
        System.assertEquals(task.Actual_Hours__c, 10);
    }
}