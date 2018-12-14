@IsTest
private class ADM_UserStoryAndTaskWrapperTest {

	/*
	@testcaseID a1DB00000000VWO
	@userStory a07B0000000MmZ3IAK
	@expected results When clicking on Show Completed the completed tasks will show on virtual wall
	@hierarchy GUS.ScrumforceToGUS.Sprint.Virtual Wall.Detail page
	*/

    static testMethod void testCompleted() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        
        ADM_Work__c story = ADM_Work.setupTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Priority__c = 'P1';
        upsert story;
        
        //ensure the story does not have any tasks
        delete [select Id from ADM_Task__c where Work__c = :story.Id];
        
        ADM_Task__c task1 = new ADM_Task__c();
        task1.Subject__c = 'Task1';
        task1.Assigned_To__c = UserInfo.getUserId();
        task1.Hours_Remaining__c = 10;
        task1.Starting_Hours__c = 10;
        task1.Work__c = story.id;
        task1.Status__c = 'Completed';
        upsert task1;
        
        story = [select Id, (select Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Subject__c, Status__c, Work__c, Order__c from Tasks__r order by Order__c, CreatedDate) from ADM_Work__c where id = :story.Id];
        
        Test.startTest();
        ADM_UserStoryAndTaskWrapper wrapper = new ADM_UserStoryAndTaskWrapper(story);
        Test.stopTest();
        
        System.assertEquals(true, wrapper.getHaveCompletedTasks(), 'Expected #getHaveCompletedTasks to be true because there is one completed task');
        System.assert(wrapper.getCompletedTasks() != null, 'Expected #getCompletedTasks to never be null');
        System.assertEquals(1, wrapper.getCompletedTasks().size(), 'Expected there to be one completed task');
        System.assertEquals(task1.Id, wrapper.getCompletedTasks()[0].Id, 'Expected the completed task to be the one that was given to the wrapper');
    }
    
	/*
	@testcaseID a1DB00000002dOM
	@userStory a07B0000000O30r
	@expected results Notice that the closed items all show on the sprint by default. Also, the open and closed filter criteria is ON
	@hierarchy GUS.ScrumforceToGUS.Sprint.Virtual Wall.Detail page
	*/
    static testMethod void testClosedItemsNotVisible() {
    	// Expected start and end dates 2 months in advanced w/ 2 week span
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        update sprint;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Work__c story1 = works.get(0);
        story1.Status__c = 'Completed';
        story1.Sprint__c = sprint.Id;
        
        ADM_Work__c story2 = works.get(1);
        story2.Sprint__c = sprint.Id;
        insert works;
	        
        //refresh the story
        Map<Id, ADM_Work__c> stories = new Map<Id, ADM_Work__c>([SELECT Id, Closed__c, Name, Subject__c, Assignee__r.FirstName, Status__c, Sprint__c, Sprint__r.Start_Date__c,Sprint__r.End_Date__c, RecordType.Name, Theme__r.Name, Scheduled_Build__r.Name, Story_Points__c, (SELECT Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.FirstName, Hours_Remaining__c, Subject__c, Status__c, Work__c From Tasks__r ) FROM ADM_Work__c WHERE Id = :story1.Id or Id = :story2.Id ORDER BY Priority_Rank__c ASC]);
        
        ADM_UserStoryAndTaskWrapper wrapper1 = new ADM_UserStoryAndTaskWrapper(stories.get(story1.Id));
        ADM_UserStoryAndTaskWrapper wrapper2 = new ADM_UserStoryAndTaskWrapper(stories.get(story2.Id));
        
        System.assertEquals(true, wrapper1.getIsVisible(), 'Expected the wrapper to be visible because it is closed and not within the active sprint');
        System.assertEquals(true, wrapper2.getIsVisible(), 'Expected the wrapper to be visible because it is not closed');
    }


    
    static testMethod void testUpdatedTask() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        
        ADM_Work__c story = ADM_Work.setupTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Priority__c = 'P1';
        upsert story;
        
        //ensure the story does not have any tasks
        delete [select Id from ADM_Task__c where Work__c = :story.Id];
        
        List<ADM_Task__c> tasks = new List<ADM_Task__c>();
        ADM_Task__c task1 = new ADM_Task__c();
        task1.Subject__c = 'Task1';
        task1.Assigned_To__c = UserInfo.getUserId();
        task1.Hours_Remaining__c = 10;
        task1.Starting_Hours__c = 10;
        task1.Work__c = story.id;
        task1.Status__c = 'New';
        tasks.add(task1);
        
        ADM_Task__c task2 = new ADM_Task__c();
        task2.Subject__c = 'Task2';
        task2.Assigned_To__c = UserInfo.getUserId();
        task2.Hours_Remaining__c = 10;
        task2.Starting_Hours__c = 10;
        task2.Work__c = story.id;
        task2.Status__c = 'In Progress';
        tasks.add(task2);
        
        ADM_Task__c task3 = new ADM_Task__c();
        task3.Subject__c = 'Task3';
        task3.Assigned_To__c = UserInfo.getUserId();
        task3.Hours_Remaining__c = 10;
        task3.Starting_Hours__c = 10;
        task3.Work__c = story.id;
        task3.Status__c = 'Completed';
        tasks.add(task3);
        
        upsert tasks;
        
        story = [select Id, (select Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Subject__c, Status__c, Work__c, Order__c from Tasks__r order by Order__c, CreatedDate) from ADM_Work__c where id = :story.Id];
        
        Test.startTest();
        ADM_UserStoryAndTaskWrapper wrapper = new ADM_UserStoryAndTaskWrapper(story);
        
        task1.Status__c = 'In Progress';
        wrapper.updatedTask(task1);
        
        task2.Status__c = 'Completed';
        wrapper.updatedTask(task2);
        
        task3.Status__c = 'New';
        wrapper.updatedTask(task3);
        
        Test.stopTest();
        
        assertContains(wrapper.getPlannedTasks(), task3, 'Expected task3 to be moved to the planned list because it was moved to the New status');
        assertContains(wrapper.getInProgressTasks(), task1, 'Expected task3 to be moved to the in progress list because it was moved to the In Progress status');
        assertContains(wrapper.getCompletedTasks(), task2, 'Expected task2 to be moved to the completed list because it was moved to the Completed status');
    }
    

    static testMethod void testInsertedTask() {
    	
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        
        ADM_Work__c story = ADM_Work.setupTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Priority__c = 'P1';
        upsert story;
        
        //ensure the story does not have any tasks
        delete [select Id from ADM_Task__c where Work__c = :story.Id];
        
        ADM_Task__c task1 = new ADM_Task__c();
        task1.Subject__c = 'Task1';
        task1.Assigned_To__c = UserInfo.getUserId();
        task1.Hours_Remaining__c = 10;
        task1.Starting_Hours__c = 10;
        task1.Work__c = story.id;
        task1.Status__c = 'New';
        
        story = [select Id, (select Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Subject__c, Status__c, Work__c, Order__c from Tasks__r order by Order__c, CreatedDate) from ADM_Work__c where id = :story.Id];
        
        Test.startTest();
        ADM_UserStoryAndTaskWrapper wrapper = new ADM_UserStoryAndTaskWrapper(story);
        wrapper.insertedTask(task1);
        Test.stopTest();
        
        assertContains(wrapper.getPlannedTasks(), task1, 'Expected task1 to be moved into the planned list because it has a New status');
    }
	/*
	@testcaseID a1DB00000004lhz
	@userstoryID a07B0000000U5y7IAC
	@Expected results Multiple themes can be shown by hovering over the themes of every record
	@Hierarchy GUS.Multi Themes.Virtual Wall
	*/
    
    static testMethod void testThemeCsvProperties() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        
        ADM_Work__c story = ADM_Work.setupTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Priority__c = 'P1';
        upsert story;
        
        //add a theme
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'TestTheme-asdfqweoiu';
        insert theme;
        
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = story.Id;
        themeAssignment.Theme__c = theme.Id;
        insert themeAssignment;
        
        story = [select Id, (select Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Subject__c, Status__c, Work__c, Order__c from Tasks__r order by Order__c, CreatedDate), (select Id, Theme__r.Id, Theme__r.Name from Theme_Assignments__r order by Theme__r.Name) from ADM_Work__c where id = :story.Id];
        
        Test.startTest();
        ADM_UserStoryAndTaskWrapper wrapper = new ADM_UserStoryAndTaskWrapper(story);
        Test.stopTest();
        
        System.assertEquals('TestTheme-asdfqweoiu', wrapper.getThemeNameCsv(), 'Expected the theme names to be available using getThemeNameCsv');
    }
    
    private static void assertContains(List<ADM_Task__c> tasks, ADM_Task__c task, String message) {
    	Boolean found = false;
    	for(ADM_Task__c taskInList : tasks) {
    		if(taskInList.Id == task.Id) {
    			found = true;
    			break;
    		}
    	}
    	System.assert(found, message);
    }
}