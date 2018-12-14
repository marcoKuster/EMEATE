@isTest
public with sharing class ADM_TasksControllerTests {

    private static ADM_Sprint__c createSprintWithOneStoryWithOneTask() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        story.Sprint__c = sprint.Id;
        update story;

        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task;

        return sprint;
    }

    /**
     * Utility method to retrieve the first task of the first story.
     *
     * Assertions are thrown if there are no stories or tasks.
     */
    private static ADM_Task__c getFirstPlannedTask(ADM_TasksController controller) {
        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        ADM_UserStoryAndTaskWrapper[] stories = vwc.getStories();
        System.assert(stories != null, 'Expected getStories to never return null');
        System.assert(stories.size() > 0, 'Expected at least one user story to be returned');

        ADM_Task__c[] tasks = stories[0].getPlannedTasks();
        System.assert(tasks != null, 'Expected getPlannedTasks to never return null');
        System.assert(tasks.size() > 0, 'Expected at least one task to be returned');

        ADM_Task__c task = tasks[0];
        System.assert(task != null, 'Task should not be null');
        return task;
    }

    /*
      @testcaseID a0B20000006aN9jEAE
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: A new screen appears under Planned where the user can enter the task name, assignee and amount of hours assigned. It saves automatically
      @author jhatton
    */
    static testMethod void testVirtualWallTaskCreation() {
        //create a sprint with one story
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story.Sprint__c = sprint.id;
        update story;

        //create a new task and save it with the controller
        ADM_Task__c task = new ADM_Task__c(Subject__c = 'task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        ADM_TasksController.SaveResponse response = ADM_TasksController.saveTask(task, (DateTime)null);

        System.assert(response != null, 'Expected the response to not be null');
        System.assert(response.Id != null, 'Expected the ID for the task to be returned after saving');

        //now verfiy task is visible
        List<ADM_Work__c> stories = [select Id, (select Id from Tasks__r) from ADM_Work__c where Id = :story.Id];
        System.assertEquals(1, stories.size(), 'Expected to show one story');
        System.assertEquals(1, stories[0].Tasks__r.size(), 'Expected the story to contain one task');
    }

    /*
      @testcaseID a0B20000006aN9kEAE
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: Verify task can be deleted from the component
      @author jhatton
    */
    static testMethod void testVirtualWallTaskDeletion() {
        //create a sprint with one story
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story.Sprint__c = sprint.id;
        update story;

        ADM_Task__c task = new ADM_Task__c(Subject__c = 'task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task;

        //delete the task
        ADM_TasksController.deleteTask(task.id);

        //refresh the controller and verify it was removed
        List<ADM_Work__c> stories = [select Id, (select Id from Tasks__r) from ADM_Work__c where Id = :story.Id];
        System.assertEquals(0, stories[0].Tasks__r.size(), 'Expected the number of tasks on the story to be 0 because the task should have been deleted.');
    }

     /*
      @testcaseID a0B20000006aN9mEAE
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: Verify task can be marked in progress
      @author jhatton
    */

    static testMethod void testVirtualWallMarkTaskInProgress() {
        //create a sprint with one story
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story.Sprint__c = sprint.id;
        update story;

        ADM_Task__c task1 = new ADM_Task__c(Subject__c = 'task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task1;

        //change the task status
        ADM_TasksController.changeTaskStatusToInProgress(task1.id);
        System.assertEquals('In Progress', [select Status__c from ADM_Task__c where id = :task1.Id].Status__c);
    }

     /*
      @testcaseID a0B20000007lZBREA2
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: Verify task status can be saved as planned
      @author jhatton
    */

    static testMethod void testVirtualWallMarkTaskPlanned() {

        //create a sprint with one story
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story.Sprint__c = sprint.id;
        update story;

        ADM_Task__c task1 = new ADM_Task__c(Subject__c = 'task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task1;

        //change the task status
        ADM_TasksController.changeTaskStatusToPlanned(task1.id);

        System.assertEquals('Not Started', [select Status__c from ADM_Task__c where id = :task1.Id].Status__c);
    }

     /*
      @testcaseID a0B20000007lZBSEA2
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: Verify task status can be saved as completed
      @author jhatton
    */

    static testMethod void testVirtualWallMarkTaskCompleted() {
        //create a sprint with one story
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story.Sprint__c = sprint.id;
        update story;

        ADM_Task__c task1 = new ADM_Task__c(Subject__c = 'task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task1;

        Test.startTest();
            //change the task status
            ADM_TasksController.changeTaskStatusToCompleted(task1.id);
        Test.stopTest();

        System.assertEquals('Completed', [select Status__c from ADM_Task__c where id = :task1.Id].Status__c);
    }


    /*
      @testcaseID a0B20000007lFMPEA2
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Pass if all fields are populated with valid data.
      @author jhatton
    */

    static testMethod void testUpdateTaskWithValidTask() {
        //create a sprint containing 1 task and get the first task
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();

        List<ADM_Task__c> tasks = [select Id, Subject__c, LastModifiedDate from ADM_Task__c where Work__r.Sprint__c = :sprint.Id];
        ADM_Task__c task1 = tasks.get(0);

        //change the task
        task1.Subject__c = 'My Test Subject';

        //attempt to update
        ADM_TasksController.saveTask(task1, task1.LastModifiedDate);

        //verify the change
        System.assertEquals('My Test Subject', [select Subject__c from ADM_Task__c where id = :task1.Id].Subject__c);

        //verfiy NO error messages have been added
        System.assert(ApexPages.hasMessages() == false);
    }

    /*
      @testcaseID a1DB00000002PMu
      @hierarchy GUS.ScrumforceToGUS.Social Sprint.Task
      @userstory a07B0000000EnN9IAK
      @expectedResults: Expected the task save method to fail when the user updates an old task item
      @author jhatton
    */
    static testMethod void testSaveTaskFailsWithConcurrentChanges() {
        //create a sprint containing 1 task and get the first task
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();

        List<ADM_Task__c> tasks = [select Id, Subject__c, LastModifiedDate from ADM_Task__c where Work__r.Sprint__c = :sprint.Id];
        ADM_Task__c task = tasks.get(0);

        //save the date and time like a client doing a sync
        DateTime syncDateTime = DateTime.newInstance(task.LastModifiedDate.getTime()).addMinutes(-1);

        User user1 = ADM_WorkUser.createTestUser();

        //simulate a second client updating the task
        task.Subject__c = 'Client 2 Subject';
        update task;

        //simulate the first client changing subject
        task.Subject__c = 'Client 1 New Subject';

        System.RunAs(user1) {
            try {
                ADM_TasksController.SaveResponse response = ADM_TasksController.saveTask(task, syncDateTime);
                System.assert(false, 'Expected the task save method to fail when the user updates an old task item.');
            } catch(Exception exc) {
                System.assert(exc.getMessage().contains('modified') && exc.getMessage().contains('task'), 'Expected the task save method to fail when the user updates an old task item. ' + exc.getMessage());
            }
        }
    }

    /*
      @testcaseID a0B20000007lFMPEA2
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Show error message if subject is missing.  Error should be graceful and use built in PageMessages component
      @author jhatton
    */

    static testMethod void testUpdateTaskWithSubjectMissing() {
        //create a sprint containing 1 task and get the first task
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();

        List<ADM_Task__c> tasks = [select Id, Subject__c, LastModifiedDate from ADM_Task__c where Work__r.Sprint__c = :sprint.Id];
        ADM_Task__c task1 = tasks.get(0);

        //remove the subject
        task1.Subject__c = '';

        try {
            ADM_TasksController.saveTask(task1, task1.LastModifiedDate);
            System.assert(false, 'Expected an exception to be thrown because of the missing subject');
        } catch(Exception exc) {
            System.assert(exc.getMessage().contains('Subject cannot be blank'), 'Expected the exception to be about the missing subject. ' + exc.getMessage());
        }
    }

    static testMethod void testReorderTaskOrder() {
        Test.startTest();
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_Work__c work = ADM_Work.createTestWork('User Story');
         Test.stopTest();
        work.Sprint__c = sprint.Id;
        update work;

        //task 1 will be behind task 2
        ADM_Task__c task1 = new ADM_Task__c();
        task1.Subject__c = 'Task1';
        task1.Assigned_To__c = UserInfo.getUserId();
        task1.Hours_Remaining__c = 10;
        task1.Starting_Hours__c = 10;
        task1.Work__c = work.id;
        task1.Order__c = 1;
        task1.Status__c = 'Not Started';
        insert task1;

        //task 2 will move ahead of task 1
        ADM_Task__c task2 = new ADM_Task__c();
        task2.Subject__c = 'Task2';
        task2.Assigned_To__c = UserInfo.getUserId();
        task2.Hours_Remaining__c = 10;
        task2.Starting_Hours__c = 10;
        task2.Work__c = work.id;
        task2.Order__c = 2;
        task2.Status__c = 'Not Started';
        insert task2;

        //task 3 will move to the planned column from in progress
        ADM_Task__c task3 = new ADM_Task__c();
        task3.Subject__c = 'Task3';
        task3.Assigned_To__c = UserInfo.getUserId();
        task3.Hours_Remaining__c = 10;
        task3.Starting_Hours__c = 10;
        task3.Work__c = work.id;
        task3.Order__c = 1;
        task3.Status__c = 'In Progress';
        insert task3;

        //task 4 will stay in the planned column
        ADM_Task__c task4 = new ADM_Task__c();
        task4.Subject__c = 'Task4';
        task4.Assigned_To__c = UserInfo.getUserId();
        task4.Hours_Remaining__c = 10;
        task4.Starting_Hours__c = 10;
        task4.Work__c = work.id;
        task4.Order__c = 2;
        task4.Status__c = 'In Progress';
        insert task4;

        //task 5 will move to the completed column from in progress
        ADM_Task__c task5 = new ADM_Task__c();
        task5.Subject__c = 'Task5';
        task5.Assigned_To__c = UserInfo.getUserId();
        task5.Hours_Remaining__c = 10;
        task5.Starting_Hours__c = 10;
        task5.Work__c = work.id;
        task5.Order__c = 3;
        task5.Status__c = 'In Progress';
        insert task5;

        ADM_TasksController.TaskOrderChangeRequest request = new ADM_TasksController.TaskOrderChangeRequest();
        request.workId = work.Id;
        request.plannedTasks = new List<Id>{task2.Id, task1.Id, task3.Id};
        request.inProgressTasks = new List<Id>{task4.Id};
        request.completedTasks = new List<Id>{task5.Id};
      

        ADM_TasksController.updateTaskOrder(request);


        List<ADM_Task__c> resultTasks = [select Status__c, Order__c from ADM_Task__c where Work__c = :work.Id order by Status__c, Order__c];
        Map<String, List<ADM_Task__c>> resultTaskMap = new Map<String, List<ADM_Task__c>>();
        resultTaskMap.put('Not Started', new List<ADM_Task__c>());
        resultTaskMap.put('In Progress', new List<ADM_Task__c>());
        resultTaskMap.put('Completed', new List<ADM_Task__c>());
        for(ADM_Task__c task : resultTasks) {
            if(task.Status__c == 'Completed') {
                resultTaskMap.get('Completed').add(task);
            } else if(task.Status__c == 'In Progress') {
                resultTaskMap.get('In Progress').add(task);
            } else {
                resultTaskMap.get('Not Started').add(task);
            }
        }

        //not started tasks
        List<ADM_Task__c> notStartedTasks = resultTaskMap.get('Not Started');
        System.assert(!notStartedTasks.isEmpty(), 'Expected to find the tasks to remain associated to the work instance');
        System.assertEquals(3, notStartedTasks.size(), 'Expected three tasks to be in the \'Not Started\' column');

        System.assertEquals(task2.Id, notStartedTasks.get(0).Id, 'Expected task 2 to be ahead of task 1');
        System.assertEquals(1, notStartedTasks.get(0).Order__c,  'Expected task 2 to be at order index of 1');
        System.assertEquals('Not Started', notStartedTasks.get(0).Status__c,  'Expected task 2 to have the same status since it didn\'t change');

        System.assertEquals(task1.Id, notStartedTasks.get(1).Id, 'Expected task 1 to be after task 2');
        System.assertEquals(2, notStartedTasks.get(1).Order__c, ' Expected task 1 to be at order index of 2');
        System.assertEquals('Not Started', notStartedTasks.get(1).Status__c,  'Expected task 1 to have the same status since it didn\'t change');

        System.assertEquals(task3.Id, notStartedTasks.get(2).Id, 'Expected task 3 to be after task 1');
        System.assertEquals(3, notStartedTasks.get(2).Order__c, ' Expected task 3 to be at order index of 3');
        System.assertEquals('Not Started', notStartedTasks.get(2).Status__c,  'Expected task 3 status to be \'Not Started\' since it moved the planned column');


        //in progress tasks
        List<ADM_Task__c> inProgressTasks = resultTaskMap.get('In Progress');
        System.assert(!inProgressTasks.isEmpty(), 'Expected to find the tasks to remain associated to the work instance');
        System.assertEquals(1, inProgressTasks.size(), 'Expected one task to be in the \'In Progress\' column');

        System.assertEquals(task4.Id, inProgressTasks.get(0).Id, 'Expected task 4 to be the first in the \'In Progress\' column');
        System.assertEquals(1, inProgressTasks.get(0).Order__c, ' Expected task 4 to be at order index of 1');
        System.assertEquals('In Progress', inProgressTasks.get(0).Status__c,  'Expected task 4 status to be \'In Progress\' since it didn\'t change');


        //completed tasks
        List<ADM_Task__c> completedTasks = resultTaskMap.get('Completed');
        System.assert(!completedTasks.isEmpty(), 'Expected to find the tasks to remain associated to the work instance');
        System.assertEquals(1, completedTasks.size(), 'Expected one task to be in the \'Completed\' column');

        System.assertEquals(task5.Id, completedTasks.get(0).Id, 'Expected task 5 to be the first in the \'Completed\' column');
        System.assertEquals(1, completedTasks.get(0).Order__c, ' Expected task 5 to be at order index of 1');
        System.assertEquals('Completed', completedTasks.get(0).Status__c,  'Expected task 5 status to be \'Completed\' since it moved the completed column');
    }

    static testMethod void testGetTaskOrder() {

        Test.startTest();
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_Work__c work = ADM_Work.createTestWork('User Story');
         Test.stopTest();
        work.Sprint__c = sprint.Id;
        update work;

        List<ADM_Task__c> tasks = new List<ADM_Task__c>();
        ADM_Task__c task1 = new ADM_Task__c();
        task1.Subject__c = 'Task1';
        task1.Assigned_To__c = UserInfo.getUserId();
        task1.Hours_Remaining__c = 10;
        task1.Starting_Hours__c = 10;
        task1.Work__c = work.id;
        task1.Order__c = 1;
        task1.Status__c = 'Not Started';
        tasks.add(task1);

        ADM_Task__c task2 = new ADM_Task__c();
        task2.Subject__c = 'Task2';
        task2.Assigned_To__c = UserInfo.getUserId();
        task2.Hours_Remaining__c = 10;
        task2.Starting_Hours__c = 10;
        task2.Work__c = work.id;
        task2.Order__c = 2;
        task2.Status__c = 'Not Started';
        tasks.add(task2);

        ADM_Task__c task3 = new ADM_Task__c();
        task3.Subject__c = 'Task3';
        task3.Assigned_To__c = UserInfo.getUserId();
        task3.Hours_Remaining__c = 10;
        task3.Starting_Hours__c = 10;
        task3.Work__c = work.id;
        task3.Order__c = 1;
        task3.Status__c = 'In Progress';
        tasks.add(task3);

        ADM_Task__c task4 = new ADM_Task__c();
        task4.Subject__c = 'Task4';
        task4.Assigned_To__c = UserInfo.getUserId();
        task4.Hours_Remaining__c = 10;
        task4.Starting_Hours__c = 10;
        task4.Work__c = work.id;
        task4.Order__c = 1;
        task4.Status__c = 'Completed';
        tasks.add(task4);
        insert tasks;


        ADM_TasksController.TaskOrderResponse response = ADM_TasksController.getTaskOrder(work.id);


        System.assertEquals(response.workId, work.Id, 'Work ID in response should match that of the work object');
        System.assert(response.notStartedTasks != null, 'Not Started list in response should not be null');
        System.assertEquals(2, response.notStartedTasks.size(), 'Not Started list should contain 2 IDs');
        System.assertEquals(task1.Id, response.notStartedTasks.get(0), 'Expected task 1 to be the first ID in the Not Started list');
        System.assertEquals(task2.Id, response.notStartedTasks.get(1), 'Expected task 1 to be the second ID in the Not Started list');

        System.assert(response.inProgressTasks != null, 'In Progress list in response should not be null');
        System.assertEquals(1, response.inProgressTasks.size(), 'In Progress list should contain 1 ID');
        System.assertEquals(task3.Id, response.inProgressTasks.get(0), 'Expected task 3 to be the first ID in the In Progress list');

        System.assert(response.completedTasks != null, 'Completed list in response should not be null');
        System.assertEquals(1, response.completedTasks.size(), 'Completed list should contain 1 ID');
        System.assertEquals(task4.Id, response.completedTasks.get(0), 'Expected task 4 to be the first ID in the Completed list');
    }

    private static User createTestUser() {
        User u = ADM_WorkUser.createTestUserWithRandomName();
        u = [select Id, Name, Email from User where Id=:u.Id limit 1];
        return u;
    }
}