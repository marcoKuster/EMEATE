@IsTest
public class ADM_TaskTriggerTest {


    private static List<ADM_Task__c> queryTasks(List<Id> ids){
        return [select Id, Subject__c, Status__c, Starting_Hours__c, Order__c, Hours_Remaining__c, External_ID__c, Due_By__c, Assigned_To__c, Actual_Hours__c, LastModifiedDate from ADM_Task__c where
                     id in :ids];
    }

/*
@testcaseID  a1DB00000002NeW
@userstory  a07B0000000NM9B
@Expected Results Tasks cannot be added to templates
@Hierarchy GUS.ScrumforceToGUS.Social Sprint.Task
*/

    testMethod static void testTasksShouldNotBeAssignedToTemplates() {

        ADM_Work__c template = ADM_Work.createTestTemplate();
        ADM_Work__c bug = ADM_Work.createTestBug();
        User u = ADM_WorkUser.createTestUser();
        ADM_Task__c t = new ADM_Task__c(Work__c = template.id, Assigned_To__c = u.id, Subject__c = 'Test Task');
        try {
            insert t;
            System.assert(false, 'The task insert should have failed because it is assigned to a template');
        } catch (System.Exception e) {
            System.assert(e.getMessage().contains('Error:Tasks cannot be assigned to work templates.'), e.getMessage());
        }
        //repeat but this time assign to a bug this should pass
        t.Work__c = bug.id;
        try {
            insert t;
            System.assert(true, 'The task insert should have passed because it is assigned to a bug');
        } catch (System.Exception e) {
            System.assert(false, 'Not expecting this error:' + e.getMessage());
        }
    }

/*
@testcaseID  a1DB00000002ciG
@userstory  a07B0000000NM9B
@Expected Results Changelists cannot be deleted from tasks
@Hierarchy GUS.ScrumforceToGUS.Social Sprint.Task
*/

    testMethod static void testChangelistOnTaskDeletionError() {
        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_Task__c t = new ADM_Task__c(Work__c = bug.id, Assigned_To__c = bug.Assignee__c, Subject__c = 'Test Task');

        insert t;

        String describe = '';
        describe = describe + '        Testing new ARS';
        describe = describe + '        https://tapp0.salesforce.com/' + bug.Id;
        describe = describe + '        @rev jhatton@';
        describe = describe + '        @revert@';

        ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
        String changeNumber = '999999';
        pc.Describe__c = 'Change: '+ changeNumber + '\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
        pc.Changelist__c = changeNumber;
        pc.Release__c = 'ATHF_MasterShake';
        pc.Work__c = bug.Id;
        pc.Task__c = t.Id;

        insert pc;

        try {
            delete t;
            System.assert(false, 'The delete should have failed because the task has a change list associated with it.');
        } catch (System.Exception e) {
            System.assert(e.getMessage().contains('Error: Tasks that have change list(s) associated with them cannot be deleted.'), e.getMessage());
        }

        ADM_Change_List__c cl = [Select Id from ADM_Change_List__c Where Task__c = :t.Id limit 1];
        delete cl;

        try {
            delete t;
            System.assert(true, 'The delete should have worked because the task has 0 change lists associated with it.');
        } catch (System.Exception e) {
            System.assertEquals(e.getMessage(), '', e.getMessage());
        }
    }

/*
@testcaseID  a1DB00000002ciG
@userstory  a07B0000000NM9B
@Expected Results Task.Starting_Hours should be populated to equal Hours Remaining the first time that value is populated
@Hierarchy GUS.ScrumforceToGUS.Social Sprint.Task
*/
    testMethod static void testStartingHoursIsPopulatedWhenHoursRemainingIsNotZeroOrNull() {
        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_Task__c t = new ADM_Task__c(Work__c = bug.id, Assigned_To__c = bug.Assignee__c, Subject__c = 'Test Task', hours_remaining__c = 0.0);

        insert t;

        ADM_Task__c updatedTask = [select ID, starting_hours__c from ADM_Task__c where ID = :t.Id];
        System.assertEquals(0.0, updatedTask.starting_hours__c);



        updatedTask.hours_remaining__c = 5;
        update updatedTask;
        updatedTask = [select ID, starting_hours__c from ADM_Task__c where ID = :t.Id];
        System.assertEquals(5, updatedTask.starting_hours__c);



        updatedTask.hours_remaining__c = 7;
        update updatedTask;
        updatedTask = [select ID, starting_hours__c from ADM_Task__c where ID = :t.Id];
        System.assertEquals(5, updatedTask.starting_hours__c, 'Starting hours should remain the same as its initial value.');


/*
@testcaseID a1DB000000030d0
@userstory a07B0000000dBwSIAU
@Expected Results The hours remaining transfer to actual hours
@Hierarchy GUS.Social Sprint.Task
*/


    }

    testMethod static void testTaskStatusOfCompletedWillCopyStartingHoursToActualHoursIfActualHoursIsNull(){

        ADM_Work__c story = ADM_Work.createTestWork('User Story');

        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id, Status__c = 'Completed');
        insert task;
        task = queryTasks(new List<Id>{task.id})[0];
        System.assertEquals(task.Starting_Hours__c, task.Actual_Hours__c, ' Expected task.Starting_Hours__c copied to task.Actual_Hours__c as status is completed');
    }

/*
@testcaseID a1DB000000030cv
@userstory a07B0000000dBwSIAU
@Expected Results The hours remaining transfer to actual hours
@Hierarchy GUS.Social Sprint.Task
*/

    testMethod static void testSettingTaskToCompletedCopyActualHoursFromStartingHoursIfActualHoursIsNull(){

        ADM_Work__c story = ADM_Work.createTestWork('User Story');

        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task;
        task = queryTasks(new List<Id>{task.id})[0];
        System.assertEquals(null, task.Actual_Hours__c, ' Expected null value for task.Actual_Hours__c');
        task.Status__c = 'Completed';

        update task;

        task = queryTasks(new List<Id>{task.id})[0];
        System.assertEquals(task.Starting_Hours__c, task.Actual_Hours__c, 'Expected task.Starting_Hours__c copied to task.Actual_Hours__c as status is updated to completed');

    }

/*
@testcaseID a1DB000000030d5
@userstory a07B0000000dBwSIAU
@Expected Results Ensure that actual hours stay unchanged
@Hierarchy GUS.Social Sprint.Task
*/

    testMethod static void testActualHoursStayUnchangedIfNotNull(){

        ADM_Work__c story = ADM_Work.createTestWork('User Story');

        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id, Actual_Hours__c = 12);
        insert task;
        task = queryTasks(new List<Id>{task.id})[0];
        System.assertEquals(12, task.Actual_Hours__c, ' Expected null value for task.Actual_Hours__c');
        task.Status__c = 'Completed';

        update task;

        task = queryTasks(new List<Id>{task.id})[0];
        System.assertEquals(12, task.Actual_Hours__c, ' Expected task.Actual_Hours__c to keep value 12 as Actual_Hours__c was non-null');

    }

testMethod static void testActualHoursStayUnchangedIfCapexEnabled(){
        ADM_Work__c story = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        User workUser = ADM_WorkUser.createTestUser();

        story.Product_Tag__c = productTag.Id;
        story.Capex_Enabled__c = true;

        upsert story;

        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = workUser.Id, Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id, Actual_Hours__c = 0.0, Capex_Enabled__c = true);
        insert task;
        task = queryTasks(new List<Id>{task.id})[0];
        System.assertEquals(0, task.Actual_Hours__c, ' Expected 0.0 for task.Actual_Hours__c');
        task.Status__c = 'Completed';
        task.Actual_Hours__c = 10;

        update task;

        task = queryTasks(new List<Id>{task.id})[0];
        System.assertEquals(10, task.Actual_Hours__c, ' Expected task.Actual_Hours__c to keep value 10 as Capex_Enabled__c == true');
    }

    testMethod static void testCapexTasksShouldNotBeAssignedToNonCapexUserStories() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        insert work;

        ADM_Task__c task = ADM_Task.setupTestTask(work);

        task.Capex_Enabled__c = true;
        task.Actual_Hours__c = 10;

        try {
            work.Product_Tag__c = productTag.Id;
            work.Capex_Enabled__c = false;

            update work;
        insert task;

            System.assert(false, 'The task insert should have failed because a capex task cannot be assigned to a non-capex user story');
        } catch (System.Exception e) {
            System.assert(e.getMessage().contains('A user story that is not a New Customer Facing Feature cannot contain Quality tasks.'), e.getMessage());
        }
        //set capex on task to false to verify that insert is successful
        task.Capex_Enabled__c = false;

        try {
            insert task;
            System.assert(true, 'The task insert should have passed because both neither work or task are capex enabled');
        } catch (System.Exception e) {
            System.assert(false, 'Not expecting this error:' + e.getMessage());
        }

        //set capex on task to true to verify that update fails
        task.Capex_Enabled__c = true;

        try {
            update task;
            System.assert(false, 'The task update should have failed because a capex task cannot be assigned to a non-capex user story');
        } catch (System.Exception e) {
            System.assert(e.getMessage().contains('A user story that is not a New Customer Facing Feature cannot contain Quality tasks.'), e.getMessage());
        }
        //set capex on user story to true to verify that update is successful
        work.Capex_Enabled__c = true;
        update work;

        try {
            update task;
            System.assert(true, 'The task update should have passed because both work and task are capex enabled');
        } catch (System.Exception e) {
            System.assert(false, 'Not expecting this error:' + e.getMessage());
        }
    }

    testMethod static void testCapexTasksCanBeCreatedOnClosedStories() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        work.Product_Tag__c = productTag.Id;
        work.Capex_Enabled__c = true;
        work.Status__c = 'Closed';

        insert work;

        ADM_Task__c task = ADM_Task.setupTestTask(work);

        task.Capex_Enabled__c = true;
        task.Status__c = 'Completed';
        task.Actual_Hours__c = null;

        try {
            insert task;
            System.assert(task.Id != null, 'The task insert should not fail because capex task can be added to a closed user story');
        } catch (System.Exception e) {
          System.assert(false, 'The task insert should not fail because capex task can be added to a closed user story');

        }
    }

    testMethod static void testValidateAssigningCapexTasksToInactiveUser() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        work.Product_Tag__c = productTag.Id;

        insert work;

        ADM_Task__c task = ADM_Task.setupTestTask(work);

        task.Capex_Enabled__c = true;
        task.Actual_Hours__c = 10;
        task.Assigned_To__c =  ADM_WorkUser.createInactiveTestUser().Id;

        try {
          Test.startTest();
              insert task;

              System.assert(false,'Assigning a Capex Enabled task to an inactive Assignee should fail');
          Test.stopTest();
        } catch(System.DmlException saveException) {
            System.assert(saveException.getMessage().containsIgnoreCase('If assignee is an active employee of Salesforce please submit a concierge ticket to correct the employee record'), 'Did not expect this error:' + saveException.getMessage());
        }
    }

    testMethod static void testTaskCompletedPopulatesCompletedDateButNullsItOnOtherStatuses() {
        
        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_Task__c t = new ADM_Task__c(Work__c = bug.id, Assigned_To__c = bug.Assignee__c, Subject__c = 'Test Task' + System.currentTimeMillis());
        insert t;
        
        System.assertEquals(null, t.Completed_On__c);

        t.Status__c = 'Completed';
        upsert t;

        ADM_Task__c t_after = [SELECT Id,Completed_On__c FROM ADM_Task__c WHERE Id =: t.Id ];
        
        System.assertNotEquals(null, t_after.Completed_On__c);

    }

}