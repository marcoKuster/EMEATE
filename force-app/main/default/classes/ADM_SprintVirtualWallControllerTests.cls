@isTest
public with sharing class ADM_SprintVirtualWallControllerTests {

    static testMethod void testVirtualWall() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        story.Sprint__c = sprint.Id;
        update story;

        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task;

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        ADM_UserStoryAndTaskWrapper[] m_storiesAndTasks = vwc.getStories();
        System.assertEquals(1, vwc.getStories().size(), 'Expected the user story to be displayed');
        System.assertEquals(1, vwc.getStories()[0].getTasks().size(), 'Expected the user story to have a task');
    }

    /*
      @testcaseID a0B20000006aRdLEAU
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: Verify templates are not displayed on the virtual wall
      @author jhatton
    */

    static testMethod void testVirtualWallDoesNotDisplayTemplates() {

        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        ADM_UserStoryAndTaskWrapper[] m_storiesAndTasks = vwc.getStories();
        System.assertEquals(0, vwc.getStories().size(), 'Expected no stories to be returned for the empty sprint');

        //create a template and add it to the sprint
        ADM_Work__c template = ADM_Work.createTestWork('Template');
        template.sprint__c = sprint.Id;
        update template;

        //reinit and verify template is not included
        vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        System.assertEquals(0, vwc.getStories().size(), 'Expected the virtual wall to be empty because it should ignore the templates');
    }

    /*
      @testcaseID a0B20000007lXHmEAM
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: Verify no closed items are on the virtual wall
      @author jhatton
    */

    static testMethod void testVirtualWallDoesNotDisplayClosedItems() {
        //FIXME new virtual wall is going to show closed items
    }

    /*
      @testcaseID a0B20000007lXI1EAM
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: new tasks added from virtual wall appear on sprint backlog and release burndown
      @author jhatton
    */

    static testMethod void testTasksAddedFromVirtualWallAreDisplayedOnSprintBacklog() {
        //FIXME not sure what this test is for
    }

    /*
      @testcaseID a0B20000006aMEVEA2
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A2000000602fT
      @expectedResults: The Virtual Wall section shows all open tasks for user stories, bugs and todos where columns are Work, Record Type, Planned, In Progress and Completed
      @author jhatton
    */

    static testMethod void testVirtualWallIsCreated() {
        //create a sprint with one story containing one task
        ADM_Sprint__c sprint = createSprintWithOneStoryWithOneTask();

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        ADM_Task__c task1 = getFirstPlannedTask(vwc);
        System.assert(task1.id != null, 'Expected the task to have been saved.');

        //verfiy NO error messages have been added
        System.assert(ApexPages.hasMessages() == false, 'Unexpected error was thrown to the page');
    }


    static testMethod void testGetStatusTypes() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        Test.startTest();
        List<ADM_SprintVirtualWallController.StatusType> statusTypes = vwc.getStatusTypes();
        Test.stopTest();


        Map<String, List<String>> statusMapByRecordTypeName = ADM_Work.getStatusValues();
        for(String recordTypeName : statusMapByRecordTypeName.keySet()) {
            for(String statusValue : statusMapByRecordTypeName.get(recordTypeName)) {

                ADM_SprintVirtualWallController.StatusType selectedStatusType = null;
                for(ADM_SprintVirtualWallController.StatusType statusType : statusTypes) {
                    if(statusType.getValue().equalsIgnoreCase(statusValue)) {
                        selectedStatusType = statusType;
                        break;
                    }
                }

                System.assert(selectedStatusType != null, 'Expected the status types to contain status ' + statusValue);
                //System.assert(selectedStatusType.containsRecordType(recordTypeName), 'Expected status type, ' + statusValue + ', to contain the record type ' + recordTypeName);
            }
        }
    }

    static testMethod void testStatusType() {
        String statusValue = 'New';
        RecordType[] recordTypes = ADM_RecordType.getAll();

        List<String> recordTypeAliases = new List<String>();
        ADM_SprintVirtualWallController.StatusType statusType = new ADM_SprintVirtualWallController.StatusType(statusValue);
        for(RecordType recordType : recordTypes) {
            statusType.addRecordType(recordType);
            recordTypeAliases.add(ADM_RecordType.getRecordTypeAlias(recordType));
        }

        System.assertEquals(statusValue, statusType.getLabel(), 'Expected the label to be the value');
        System.assertEquals(statusValue, statusType.getValue(), 'Expected the value property to be the value');

        String statusTypeAsCsv = statusType.getRecordTypesAsAliasCsv();
        for(String recordTypeAlias : recordTypeAliases) {

            //verify the As CSV functionality
            System.assert(statusTypeAsCsv.contains(recordTypeAlias), 'Expected the CSV to contain the record type name ' + recordTypeAlias);
        }

        //verify contains when not contained
        System.assertEquals(false, statusType.containsRecordType('Intentionally Wrong Value'), 'Expected containsRecordType to be false when testing against a value not contained.');
    }

   /*
      @testcaseID ID:
      @hierarchy
      @userstory
      @expectedResults:
      @author jhatton
    */
    static testMethod void testDefaultAssigneeIsUser() {
        //create a sprint that contains a scrum master
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c(Name = 'GUS Test Suite Team');
        team.Cloud__c = 'Chatter';
        insert team;

        User user1 = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c membership1 = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = user1.id, Allocation__c = 100);
        insert membership1;

        User user2 = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c membership2 = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = user2.id, Allocation__c = 100);
        insert membership2;

        User scrumMaster = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c membership3 = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = scrumMaster.id, Allocation__c = 100, Role__c = 'Scrum Master');
        insert membership3;

        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);

        System.runAs(user2){
            ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
            vwc.setSprintId(sprint.Id);

            System.assertEquals(UserInfo.getUserId(), vwc.getDefaultAssigneeId(), 'Expected the current user to be assigned as the because they are on the team.');
        }
    }
   /*
      @testcaseID ID:
      @hierarchy
      @userstory
      @expectedResults:
      @author jhatton
    */

    static testMethod void testDefaultAssigneeIsScrumMaster() {
        //create a sprint that contains a scrum master
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c(Name = 'GUS Test Suite Team');
        team.Cloud__c = 'Chatter';
        insert team;

        User user = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c membership1 = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = user.id, Allocation__c = 100);
        insert membership1;

        User scrumMaster = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c membership2 = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = scrumMaster.id, Allocation__c = 100, Role__c = 'Scrum Master');
        insert membership2;

        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        System.assertEquals(scrumMaster.Id, vwc.getDefaultAssigneeId(), 'Expected the scrum master to be assigned as the default assignee.');
    }
       /*
      @testcaseID ID:
      @hierarchy
      @userstory
      @expectedResults:
      @author jhatton
    */
    static testMethod void testDefaultAssigneeIsOnTeam() {
        //create a sprint that has members but no scrum master
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c(Name = 'GUS Test Suite Team');
        team.Cloud__c = 'Chatter';
        insert team;

        User user1 = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c membership1 = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = user1.id, Allocation__c = 100);
        insert membership1;

        User user2 = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c membership2 = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = user2.id, Allocation__c = 100);
        insert membership2;

        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        Id defaultAssignee = vwc.getDefaultAssigneeId();

        Boolean onTeam = false;
        for(User user : new List<User>{user1, user2}) {
            if(user.Id == defaultAssignee) {
                onTeam = true;
                break;
            }
        }
        System.assert(onTeam, 'Expected one of the users on the team to be assigned as the default assignee.');
    }
    /*
      @testcaseID a1DB00000002PMp
      @hierarchy GUS.ScrumforceToGUS.Social Sprint.Task
      @userstory a07B0000000EnN9IAK
      @expectedResults: Assignee is the task creator by default
      @author jhatton
    */

    static testMethod void testDefaultAssigneeIsCurrentUserWhenNoTeamMembers() {
        //create a sprint that has no members
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c(Name = 'GUS Test Suite Team');
        team.Cloud__c = 'Chatter';
        insert team;

        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        User defaultAssignee = vwc.getDefaultAssignee();
        System.assert(defaultAssignee != null, 'Expected a user to be returned for the default assignee');
        System.assertEquals(UserInfo.getUserId(), defaultAssignee.Id, 'Expected the default assignee to be the current user when the team has no members');
    }

     /*
      @testcaseID a0B20000008xg9UEAQ
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Expect only stories to be displayed on the wall
      @author jhatton
    */

    static testMethod void testVirtualWallFilterByUserStory() {
        //FIXME - not needed since filtering is client side
    }

     /*
      @testcaseID a0B20000008xg8jEAA
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Expect only bugs to be displayed on the wall
      @author jhatton
    */

    static testMethod void testVirtualWallFilterByBug() {
        //FIXME - not needed since filtering is client side
    }

     /*
      @testcaseID a0B20000008xg9VEAQ
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Expect only TODOs to be displayed on the wall
      @author jhatton
    */

    static testMethod void testVirtualWallFilterByTODO() {
        //FIXME - not needed since filtering is client side
    }

    /*
      @testcaseID a0B20000008xg9YEAQ
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Expect only Bugs with certain theme to be displayed on the wall
      @author jhatton
    */

    static testMethod void testVirtualWallFilterByThemeAndBug() {
        //FIXME - not needed since filtering is client side
    }

    /*
      @testcaseID a0B20000008xg9XEAQ
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Expect only User Stories with certain theme to be displayed on the wall
      @author jhatton
    */

    static testMethod void testVirtualWallFilterByThemeAndUserStory() {
        //FIXME - not needed since filtering is client side
    }

    /*
      @testcaseID a0B20000008xg9WEAQ
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Expect only TODOs with certain theme to be displayed on the wall
      @author jhatton
    */

    static testMethod void testVirtualWallFilterByThemeAndTODO() {
        //FIXME - not needed since filtering is client side
    }

    /*
      @testcaseID a0B20000008xg8hEAA
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Expect only TODOs with certain theme to be displayed on the wall
      @author jhatton
    */

    static testMethod void testVirtualWallFilterByThemeOnly() {
        //FIXME - not needed since filtering is client side
    }

    /*
      @testcaseID a0B20000008xg9SEAQ
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a0A20000001wS5o
      @expectedResults: Expect only TODOs with certain theme to be displayed on the wall
      @author jhatton
    */

    static testMethod void testVirtualWallResetFilter() {
        //FIXME - not needed since filtering is client side
    }


    /*
      @testcaseID a1DB00000000nmz
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a07B0000000Dmx8
      @expectedResults:
      @author jhatton
    */

    static testMethod void testVirtualWallShowsUnrecognizedStatusTasksInPLannedColumn() {
        ADM_Sprint__c sprint = createSprintWithOneStoryWithOneTask();

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        //get the values before the update
        ADM_UserStoryAndTaskWrapper[] m_storiesAndTasks = vwc.getStories();
        ADM_Task__c[] tasks = m_storiesAndTasks[0].getPlannedTasks();

        //update a task to random status
        ADM_Task__c t = tasks[0];
        t.Status__c = 'Random!';
        update t;

        //refresh
        vwc.refresh();
        m_storiesAndTasks = vwc.getStories();
        System.assert(m_storiesAndTasks != null);
        ADM_Task__c[] refreshedTasks = m_storiesAndTasks[0].getPlannedTasks();

        //verfiy NO error messages have been added
        System.assert(ApexPages.hasMessages() == false);

        //verfiy planned tasks column contains the same number of tasks after status update
        System.assertEquals(tasks.size(), refreshedTasks.size());
    }

        /*
      @testcaseID a1DB00000000nn3
      @hierarchy GUS.ScrumforceToGUS.VirtualWall
      @userstory a07B0000000Dmx8
      @expectedResults:
      @author jhatton
    */

     static testMethod void testVirtualWallShowsCompletedStatusTasksInCompletedColumn() {
        ADM_Sprint__c sprint = createSprintWithOneStoryWithOneTask();

        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        ADM_UserStoryAndTaskWrapper[] m_storiesAndTasks = vwc.getStories();
        System.assert(m_storiesAndTasks.size() > 0);
        ADM_Task__c[] tasks = m_storiesAndTasks[0].getPlannedTasks();
        System.assert(tasks.size() > 0);

        //update a task to "waiting on somone" status
        ADM_Task__c t = tasks[0];
        t.Status__c = 'Waiting on someone else';
        update t;

        //refresh
        vwc.refresh();
        m_storiesAndTasks = vwc.getStories();
        System.assert(m_storiesAndTasks != null);
        ADM_Task__c[] refreshedTasks = m_storiesAndTasks[0].getPlannedTasks();

        //verfiy NO error messages have been added
        System.assert(ApexPages.hasMessages() == false);

        //verfiy planned tasks column contains the same number of tasks after status update
        System.assertEquals(tasks.size(), refreshedTasks.size());
    }

      /*
      @testcaseID ID:
      @hierarchy
      @userstory
      @expectedResults:
    */
    /*
      @expectedResults: The themes in use should include all of the themes in use
      @author jared.pearson
     */
    static testMethod void testGetThemesInUse() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'TestTheme1';
        ADM_Theme__c theme2 = new ADM_Theme__c();
        theme2.Name = 'TestTheme2';
        Database.upsert(new List<ADM_Theme__c>{theme1, theme2});

        //add a new user story
        ADM_Work__c story1 = ADM_Work.setupTestWork('User Story');
        story1.Status__c = 'New';
        story1.Sprint__c = sprint.id;
        story1.Priority__c = 'P0';
        story1.Theme__c = theme1.Id;

        //add a closed story to the sprint
        ADM_Work__c story2 = ADM_Work.setupTestWork('User Story');
        story2.Status__c = 'New';
        story2.Sprint__c = sprint.id;
        story2.Priority__c = 'P0';
        story2.Theme__c = theme2.Id;

        Database.upsert(new List<ADM_Work__c>{story1, story2});

        Test.startTest();
        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        List<ADM_Theme__c> themesInUse = vwc.getThemesInUse();
        Test.stopTest();

        Boolean found1 = false;
        Boolean found2 = false;
        for(ADM_Theme__c themeInUse : themesInUse) {
            if(themeInUse.Id == theme1.Id) {
                found1 = true;
            } else if(themeInUse.Id == theme2.Id) {
                found2 = true;
            } else {
                System.assert(false, 'Unknown theme found: ' + themeInUse.Name);
            }
        }
        System.assert(found1, 'Expected getThemesInUse to return theme 1');
        System.assert(found2, 'Expected getThemesInUse to return theme 2');
    }

      /*
      @testcaseID ID:
      @hierarchy
      @userstory
      @expectedResults:
    */
    /*
      @expectedResults: The record types in use should include all of the themes in use
      @author jared.pearson
     */
    static testMethod void testGetRecordTypesInUse() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        //add a new user story
        ADM_Work__c story1 = ADM_Work.setupTestWork('User Story');
        story1.Status__c = 'New';
        story1.Sprint__c = sprint.id;
        story1.Priority__c = 'P0';

        //add a closed story to the sprint
        ADM_Work__c story2 = ADM_Work.setupTestWork('Bug');
        story2.Status__c = 'New';
        story2.Sprint__c = sprint.id;

        Database.upsert(new List<ADM_Work__c>{story1, story2});

        Test.startTest();
        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        List<RecordType> recordTypesInUse = vwc.getRecordTypesInUse();
        Test.stopTest();

        RecordType userStoryRecordType = [select id from RecordType where Name = 'User Story'];
        RecordType bugRecordType = [select id from RecordType where Name = 'Bug'];
        Boolean found1 = false;
        Boolean found2 = false;
        for(RecordType recordTypeInUse : recordTypesInUse) {
            if(recordTypeInUse.Id == userStoryRecordType.Id) {
                found1 = true;
            } else if(recordTypeInUse.Id == bugRecordType.Id) {
                found2 = true;
            } else {
                System.assert(false, 'Unknown record type found: ' + recordTypeInUse.Name);
            }
        }
        System.assert(found1, 'Expected recordTypeInUse to return User Story of story 1');
        System.assert(found2, 'Expected recordTypeInUse to return Bug because of story 2');
    }


    static testMethod void testGetRecordTypesInUseForInvestigations() {
      ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_Work__c investigation = ADM_Work.setupTestWork('Investigation');
        investigation.Status__c = 'New';
        investigation.Sprint__c = sprint.id;
        investigation.Severity_Level__c = '1';

        insert investigation;


        Test.startTest();
        ADM_SprintVirtualWallController vwc = new ADM_SprintVirtualWallController();
        vwc.setSprintId(sprint.Id);

        List<RecordType> recordTypesInUse = vwc.getRecordTypesInUse();
        Test.stopTest();

        RecordType investigationRecordType = [select id from RecordType where Name = 'Investigation'];

        RecordType r = recordTypesInUse.get(0);


        System.assertEquals(recordTypesInUse.size(), 1, 'Expected recordTypeInUse\'s size to be 1');
        System.assertEquals(r.Id, investigationRecordType.Id, 'Expected recordTypeInUse to have Investigation as a record type');
    }


     static testMethod void testGetWorkByIdForInvestigations() {
      ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_Work__c investigation = ADM_Work.setupTestWork('Investigation');
        investigation.Status__c = 'New';
        investigation.Sprint__c = sprint.id;
        investigation.Severity_Level__c = '1';

        insert investigation;

      ADM_SprintVirtualWallController.ADM_VirtualWallWork vw = ADM_SprintVirtualWallController.getWorkById(investigation.Id);
      ADM_Work__c work = vw.work;
      System.assertEquals(work.id,investigation.Id,'Method return work of type investigations also.');
     }

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
    private static ADM_Task__c getFirstPlannedTask(ADM_SprintVirtualWallController controller) {
        ADM_UserStoryAndTaskWrapper[] stories = controller.getStories();
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
        ADM_SprintVirtualWallController.SaveResponse response = ADM_SprintVirtualWallController.saveTask(task, (DateTime)null);

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
      @expectedResults: Verify task can be deleted from the virtual wall
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
        ADM_SprintVirtualWallController.deleteTask(task.id);

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
        ADM_SprintVirtualWallController.changeTaskStatusToInProgress(task1.id);
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
        ADM_SprintVirtualWallController.changeTaskStatusToPlanned(task1.id);

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
            ADM_SprintVirtualWallController.changeTaskStatusToCompleted(task1.id);
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
        ADM_SprintVirtualWallController.saveTask(task1, task1.LastModifiedDate);

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
                ADM_SprintVirtualWallController.SaveResponse response = ADM_SprintVirtualWallController.saveTask(task, syncDateTime);
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
            ADM_SprintVirtualWallController.saveTask(task1, task1.LastModifiedDate);
            System.assert(false, 'Expected an exception to be thrown because of the missing subject');
        } catch(Exception exc) {
            System.assert(exc.getMessage().contains('Subject cannot be blank'), 'Expected the exception to be about the missing subject. ' + exc.getMessage());
        }
    }

    static testMethod void testSaveWork() {
        //create a sprint with one story
        Test.startTest();
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story.Sprint__c = sprint.id;
        update story;
        story = [select Id, Subject__c, LastModifiedDate from ADM_Work__c where Id = :story.Id limit 1];

        //update the work and save it with the controller
        story.Subject__c = 'New Subject!';
        Test.stopTest();
        ADM_SprintVirtualWallController.SaveResponse response = ADM_SprintVirtualWallController.saveWork(story, story.LastModifiedDate);
        System.assert(response != null, 'Expected the response to not be null');
        System.assert(response.Id != null, 'Expected the ID for the task to be returned after saving');

        //now verify the work has been updated
        List<ADM_Work__c> stories = [select Id, Subject__c, (select Id from Tasks__r) from ADM_Work__c where Id = :response.Id];
        System.assertEquals(1, stories.size(), 'Expected to show one story');
        System.assertEquals(story.Id, stories.get(0).Id, 'Expected the returned story Id to be the same');
        System.assertEquals(story.Subject__c, stories.get(0).Subject__c, 'Expected the returned story subject to be changed');
        System.assertEquals(0, stories.get(0).Tasks__r.size(), 'Expected the story to contain no tasks');
    }

  /*
      @testcaseID a1DB00000002zNc
      @hierarchy GUS.Social Sprint.Virtual Wall.Detail page.PlannedVelocity
      @userstory a07B0000000dYiqIAE
      @expectedResults: The Planned Velocity tag shows up and its value matches with the manual values calculated.
      @author saran govindan
    */


    static testMethod void testCalculatePlannedVelocity() {
        //create a sprint with one story
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        List<ADM_Work__c> stories = new List<ADM_Work__c>();
        ADM_Work__c story = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story.Sprint__c = sprint.id;
        story.Story_Points__c = 3;
        stories.add(story);
        ADM_Work__c story1 = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story1.Sprint__c = sprint.id;
        story1.Story_Points__c = 5;
        stories.add(story1);
        insert stories;
        Integer plannedVelocity = ADM_SprintVirtualWallController.calculatePlannedVelocity(sprint.id);
        System.assertEquals(Integer.valueOf((story.Story_Points__c+story1.Story_Points__c)),plannedVelocity);
    }

    /*
      @testcaseID a1DB00000002PMz
      @hierarchy GUS.ScrumforceToGUS.Social Sprint.Task
      @userstory a07B0000000EnN9
      @expectedResults: Expected the work save method to fail when the user updates an old work item.
      @author jhatton
    */

    static testMethod void testSaveWorkFailsWithConcurrentChanges() {
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        story = [select Id, Subject__c, LastModifiedDate from ADM_Work__c where Id = :story.Id limit 1];

        //save the date and time like a client doing a sync
        DateTime syncDateTime = DateTime.newInstance(story.LastModifiedDate.getTime()).addMinutes(-1);

        User user1 = ADM_WorkUser.createTestUser();

        //simulate a second client updating the work
        story.Subject__c = 'Client 2 Subject';
        update story;

        //simulate the first client changing subject
        story.Subject__c = 'Client 1 New Subject';

        System.RunAs(user1){
            try {
                ADM_SprintVirtualWallController.SaveResponse response = ADM_SprintVirtualWallController.saveWork(story, syncDateTime);
                System.assert(false, 'Expected the work save method to fail when the user updates an old work item.');
            } catch(Exception exc) {
                System.assert(exc.getMessage().contains('modified') && exc.getMessage().contains('work'), 'Expected the work save method to fail when the user updates an old work item. ' + exc.getMessage());
            }
        }
    }

    static testMethod void testReorderWork() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        List<ADM_Work__c> works = ADM_Work.createListOfWork(4, 'User Story');

        //create a work item that is first on the list (but will move to 2 after change)
        ADM_Work__c work1 = works.get(0);
        work1.Sprint__c = sprint.Id;
        work1.Sprint_Rank__c = 1;
        work1.Priority__c = 'P3';

        //create a work item that will be moved before work1
        ADM_Work__c work2 = works.get(1);
        work2.Sprint__c = sprint.Id;
        work2.Sprint_Rank__c = 2;
        work2.Priority__c = 'P3';

        //create a work item that has a rank but is not going to be sent to change
        ADM_Work__c work3 = works.get(2);
        work3.Sprint__c = sprint.Id;
        work3.Sprint_Rank__c = 3;
        work3.Priority__c = 'P3';

        //create a work item that does not contain a rank
        ADM_Work__c work4 = works.get(3);
        work4.Sprint__c = sprint.Id;
        work4.Sprint_Rank__c = null;
        work4.Priority__c = 'P3';

        Database.upsert(works);

        ADM_SprintVirtualWallController.WorkOrderChangeRequest request = new ADM_SprintVirtualWallController.WorkOrderChangeRequest();
        request.sprintId = sprint.Id;
        request.workIds =  new List<Id>{work2.Id, work1.Id, work4.Id};

        Test.startTest();
        ADM_SprintVirtualWallController.updateWorkOrder(request);
        Test.stopTest();

        Map<Id, ADM_Work__c> afterWorkMap = new Map<Id, ADM_Work__c>([select Id, Sprint_Rank__c from ADM_Work__c where Sprint__c = :sprint.Id]);

        System.assert(afterWorkMap.containsKey(work1.Id), 'Expected work1 to still be associated to the sprint');
        System.assertEquals(2, afterWorkMap.get(work1.Id).Sprint_Rank__c, 'Expected work1 to have a sprint rank of 2 since it is after work2');

        System.assert(afterWorkMap.containsKey(work2.Id), 'Expected work2 to still be associated to the sprint');
        System.assertEquals(1, afterWorkMap.get(work2.Id).Sprint_Rank__c, 'Expected work2 to have a sprint rank of 1 since it is before work1');

        System.assert(afterWorkMap.containsKey(work3.Id), 'Expected work3 to still be associated to the sprint');
        System.assert(afterWorkMap.get(work3.Id).Sprint_Rank__c == null, 'Expected work3 to have no sprint rank since it was not sent with change list');

        System.assert(afterWorkMap.containsKey(work4.Id), 'Expected work4 to still be associated to the sprint');
        System.assertEquals(3, afterWorkMap.get(work4.Id).Sprint_Rank__c, 'Expected work4 to have a sprint rank of 3 since it was third in the change list');
    }

    static testMethod void updateWorkOrderAura() {
       ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

       List<ADM_Work__c> works = ADM_Work.createListOfWork(4, 'User Story');

       //create a work item that is first on the list (but will move to 2 after change)
       ADM_Work__c work1 = works.get(0);
       work1.Sprint__c = sprint.Id;
       work1.Sprint_Rank__c = 1;
       work1.Priority__c = 'P3';

       //create a work item that will be moved before work1
       ADM_Work__c work2 = works.get(1);
       work2.Sprint__c = sprint.Id;
       work2.Sprint_Rank__c = 2;
       work2.Priority__c = 'P3';

       //create a work item that has a rank but is not going to be sent to change
       ADM_Work__c work3 = works.get(2);
       work3.Sprint__c = sprint.Id;
       work3.Sprint_Rank__c = 3;
       work3.Priority__c = 'P3';

       //create a work item that does not contain a rank
       ADM_Work__c work4 = works.get(3);
       work4.Sprint__c = sprint.Id;
       work4.Sprint_Rank__c = null;
       work4.Priority__c = 'P3';

       Database.upsert(works);

       String request = JSON.serialize(new Map<String,Object> {
           'sprintId' => sprint.Id,
           'workIds' => new List<Id>{work2.Id, work1.Id, work4.Id}
       });

       Test.startTest();
       ADM_SprintVirtualWallController.updateWorkOrderAura(request);
       Test.stopTest();

       Map<Id, ADM_Work__c> afterWorkMap = new Map<Id, ADM_Work__c>([select Id, Sprint_Rank__c from ADM_Work__c where Sprint__c = :sprint.Id]);

       System.assert(afterWorkMap.containsKey(work1.Id), 'Expected work1 to still be associated to the sprint');
       System.assertEquals(2, afterWorkMap.get(work1.Id).Sprint_Rank__c, 'Expected work1 to have a sprint rank of 2 since it is after work2');

       System.assert(afterWorkMap.containsKey(work2.Id), 'Expected work2 to still be associated to the sprint');
       System.assertEquals(1, afterWorkMap.get(work2.Id).Sprint_Rank__c, 'Expected work2 to have a sprint rank of 1 since it is before work1');

       System.assert(afterWorkMap.containsKey(work3.Id), 'Expected work3 to still be associated to the sprint');
       System.assert(afterWorkMap.get(work3.Id).Sprint_Rank__c == null, 'Expected work3 to have no sprint rank since it was not sent with change list');

       System.assert(afterWorkMap.containsKey(work4.Id), 'Expected work4 to still be associated to the sprint');
       System.assertEquals(3, afterWorkMap.get(work4.Id).Sprint_Rank__c, 'Expected work4 to have a sprint rank of 3 since it was third in the change list');
   }

    static testMethod void testResetWorkOrder() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');

        //create a work item with an order
        ADM_Work__c work1 = works.get(0);
        work1.Sprint__c = sprint.Id;
        work1.Sprint_Rank__c = 1;
        work1.Priority__c = 'P3';

        //create a work item without an order
        ADM_Work__c work2 = works.get(1);
        work2.Sprint__c = sprint.Id;
        work2.Sprint_Rank__c = null;
        work2.Priority__c = 'P3';

        Database.upsert(works);

        Test.startTest();
        ADM_SprintVirtualWallController.resetWorkOrder(sprint.Id);
        Test.stopTest();

        Map<Id, ADM_Work__c> afterWorkMap = new Map<Id, ADM_Work__c>([select Id, Sprint_Rank__c from ADM_Work__c where Sprint__c = :sprint.Id]);
        System.assert(afterWorkMap.containsKey(work1.Id), 'Expected work1 to still be associated to the sprint');
        System.assert(afterWorkMap.get(work1.Id).Sprint_Rank__c == null, 'Expected work1 to have no sprint rank');

        System.assert(afterWorkMap.containsKey(work2.Id), 'Expected work2 to still be associated to the sprint');
        System.assert(afterWorkMap.get(work2.Id).Sprint_Rank__c == null, 'Expected work2 to have no sprint rank');
    }

    static testMethod void testGetWorkOrder() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');

        //create a work item with an order
        ADM_Work__c work1 = works.get(0);
        work1.Sprint__c = sprint.Id;
        work1.Sprint_Rank__c = 1;
        work1.Priority__c = 'P3';

        //create a work item without an order
        ADM_Work__c work2 = works.get(1);
        work2.Sprint__c = sprint.Id;
        work2.Sprint_Rank__c = 2;
        work2.Priority__c = 'P3';

        Database.upsert(works);

        Test.startTest();
        List<Id> workOrder = ADM_SprintVirtualWallController.getWorkOrder(sprint.Id);
        Test.stopTest();

        System.assert(workOrder != null, 'getWorkOrder should never return null');
        System.assertEquals(work1.Id, workOrder.get(0), 'Expected work1 to be first in the ordering');
        System.assertEquals(work2.Id, workOrder.get(1), 'Expected work2 to be second in the ordering');
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

        ADM_SprintVirtualWallController.TaskOrderChangeRequest request = new ADM_SprintVirtualWallController.TaskOrderChangeRequest();
        request.workId = work.Id;
        request.plannedTasks = new List<Id>{task2.Id, task1.Id, task3.Id};
        request.inProgressTasks = new List<Id>{task4.Id};
        request.completedTasks = new List<Id>{task5.Id};


        ADM_SprintVirtualWallController.updateTaskOrder(request);


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



        ADM_SprintVirtualWallController.TaskOrderResponse response = ADM_SprintVirtualWallController.getTaskOrder(work.id);


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

    /*
      @testcaseID a1DB00000000VVY
      @hierarchy GUS.ScrumforceToGUS.Social Sprint.Virtual Wall.Detail page
      @userstory a07B0000000NMAMIA4
      @expectedResults: User is able to select new story points from picklist
      @author jhatton
    */
    public static testMethod void testGetValidStoryPointScale() {
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c();
        team.Name = 'Test Team ASDF';
        team.RecordTypeId = [select id from RecordType where name ='Scrum Team'].id;
        team.Story_Point_Scale__c = '0,1,2,3,5,8,13';
        team.Cloud__c = 'Chatter';
        insert team;

        User user = ADM_WorkUser.createTestUser();

        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c();
        member.Scrum_Team__c = team.id;
        member.Member_Name__c = user.id;
        member.Allocation__c = 100;
        insert member;

        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);

        Test.startTest();
        ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
        controller.setSprintId(sprint.Id);
        String[] pointScale = controller.getStoryPointScale();
        Test.stopTest();

        System.assert(pointScale != null, 'Expected a point scale to be returned, not null');
        System.assertEquals(7, pointScale.size(), 'Expected the point scale to contain all of the entries');
        System.assertEquals('0', pointScale[0], 'Expected the first point scale to be 0');
        System.assertEquals('1', pointScale[1], 'Expected the second point scale to be 1');
        System.assertEquals('2', pointScale[2], 'Expected the third point scale to be 2');
        System.assertEquals('3', pointScale[3], 'Expected the fourth point scale to be 3');
        System.assertEquals('5', pointScale[4], 'Expected the fifth point scale to be 5');
        System.assertEquals('8', pointScale[5], 'Expected the sixth point scale to be 8');
        System.assertEquals('13', pointScale[6], 'Expected the seventh point scale to be 13');
    }
    /*
      @testcaseID a1DB00000002PNE
      @hierarchy GUS.ScrumforceToGUS.Social Sprint.Virtual Wall.Detail page
      @userstory a07B0000000NMAMIA4
      @expectedResults: story points default to blank
      @author jhatton
    */

    public static testMethod void testGetDefaultStoryPointScaleWhenBlank() {
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c();
        team.Name = 'Test Team ASDF';
        team.RecordTypeId = [select id from RecordType where name ='Scrum Team'].id;
        team.Story_Point_Scale__c = ''; //intentionally blank
        team.Cloud__c = 'Chatter';
        insert team;

        User user = ADM_WorkUser.createTestUser();

        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c();
        member.Scrum_Team__c = team.id;
        member.Member_Name__c = user.id;
        member.Allocation__c = 100;
        insert member;

        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);

        Test.startTest();
        ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
        controller.setSprintId(sprint.Id);
        String[] pointScale = controller.getStoryPointScale();
        Test.stopTest();

        System.assert(pointScale != null, 'Expected the default point scale to be returned, not null');
        System.assertEquals(8, pointScale.size(), 'Expected the default point scale of [0, 1, 2, 3, 5, 8, 13, 21] because the team\'s point scale is blank');
        System.assertEquals('0', pointScale[0], 'Expected the first point scale to be 0');
        System.assertEquals('1', pointScale[1], 'Expected the second point scale to be 1');
        System.assertEquals('2', pointScale[2], 'Expected the third point scale to be 2');
        System.assertEquals('3', pointScale[3], 'Expected the fourth point scale to be 3');
        System.assertEquals('5', pointScale[4], 'Expected the fifth point scale to be 5');
        System.assertEquals('8', pointScale[5], 'Expected the sixth point scale to be 8');
        System.assertEquals('13', pointScale[6], 'Expected the seventh point scale to be 13');
        System.assertEquals('21', pointScale[7], 'Expected the eigth point scale to be 21');
    }

    /*
      @testcaseID a1DB00000002PO3
      @hierarchy GUS.ScrumforceToGUS.Social Sprint.Virtual Wall.Order Sprint
      @userstory a07B0000000KsGG
      @expectedResults: Order changes and stays put when users prioritize work items on social sprint
      @author jhatton
    */
    public static testMethod void testGetIsSprintOrderWhenOrdered() {

        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        List<ADM_Work__c> works = new List<ADM_Work__c>();

        ADM_Work__c work1 = ADM_Work.createTestWork('User Story');
        work1.Sprint__c = sprint.Id;
        work1.Sprint_Rank__c = 1;
        works.add(work1);

        ADM_Work__c work2 = ADM_Work.createTestWork('User Story');
        work2.Sprint__c = sprint.Id;
        work2.Sprint_Rank__c = null;
        works.add(work2);

        update works;


        Test.startTest();
        ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
        controller.setSprintId(sprint.Id);
        Boolean isSprintOrdered = controller.getIsSprintOrdered();
        Test.stopTest();

        System.assert(isSprintOrdered != null, 'Expected the isSprintOrdered to return true not null');
        System.assertEquals(true, isSprintOrdered, 'Expected the isSprintOrdered to return true because there is a rank set for at least one work item');
    }

    /*
      @testcaseID a1DB00000002PNj
      @hierarchy GUS.ScrumforceToGUS.Social Sprint.Virtual Wall.Order Sprint
      @userstory a07B0000000KsGG
      @expectedResults: Order stays intact from original prioritizer order
      @author jhatton
    */
    public static testMethod void testGetIsSprintOrderWhenNotOrdered() {

        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        List<ADM_Work__c> works = new List<ADM_Work__c>();

        ADM_Work__c work1 = ADM_Work.createTestWork('User Story');
        work1.Sprint__c = sprint.Id;
        work1.Sprint_Rank__c = null;
        works.add(work1);

        ADM_Work__c work2 = ADM_Work.createTestWork('User Story');
        work2.Sprint__c = sprint.Id;
        work2.Sprint_Rank__c = null;
        works.add(work2);

        update works;

        Test.startTest();
        ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
        controller.setSprintId(sprint.Id);
        Boolean isSprintOrdered = controller.getIsSprintOrdered();
        Test.stopTest();

        System.assert(isSprintOrdered != null, 'Expected the isSprintOrdered to return false not null');
        System.assertEquals(false, isSprintOrdered, 'Expected the isSprintOrdered to return false because no work item has a rank set');
    }

    /*
      @testcaseID a1DB00000002PO8
      @hierarchy GUS.ScrumforceToGUS.Social Sprint.Task
      @userstory a07B0000000Krjk
      @expectedResults: All tasks get zeroed out and automatically go to the Completed column
      @author jhatton
    */
     /* Disabling flapping test due to SOQL limit exception
    public static testMethod void testCloseWorkAndTasks() {

        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        Test.startTest();
        ADM_Work__c work = ADM_Work.createTestWork('User Story');


        work.Sprint__c = sprint.Id;
        update work;
        Test.stopTest();
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


            ADM_SprintVirtualWallController.closeWorkAndTasks(work.id);

            List<ADM_Work__c> updatedWorks = [select Status__c from ADM_Work__c where Id = :work.Id];


        System.assert(updatedWorks.size() > 0, 'Expected the work item to be found');
        System.assertEquals('Closed', updatedWorks.get(0).Status__c, 'Expected the status of the work item to be closed');

        Map<Id, ADM_Task__c> updatedTasks = new Map<Id, ADM_Task__c>([select Status__c from ADM_Task__c where Work__c = :work.id]);
        System.assertEquals(4, updatedTasks.values().size(), 'Expected all tasks to be returned since the work item should not have changed');

        System.assert(updatedTasks.containsKey(task1.Id), 'Expected task 1 to be returned');
        System.assertEquals('Completed', updatedTasks.get(task1.Id).Status__c, 'Expected task 1 status to be changed to Completed');

        System.assert(updatedTasks.containsKey(task2.Id), 'Expected task 2 to be returned');
        System.assertEquals('Completed', updatedTasks.get(task2.Id).Status__c, 'Expected task 2 status to be changed to Completed');

        System.assert(updatedTasks.containsKey(task3.Id), 'Expected task 3 to be returned');
        System.assertEquals('Completed', updatedTasks.get(task3.Id).Status__c, 'Expected task 3 status to be changed to Completed');

        System.assert(updatedTasks.containsKey(task4.Id), 'Expected task 4 to be returned');
        System.assertEquals('Completed', updatedTasks.get(task4.Id).Status__c, 'Expected task 4 status to be changed to Completed');
    }*/

    /*
      @testcaseID a1DB00000002PKU
      @hierarchy GUS.Social Sprint.Task
      @userstory   a07B0000000EVDM
      @expectedResults:     User is able to drop task in the Completed column and all hours remaining show as zero

    */
    /**
     * Given a TODO item, it should be 'Completed' and all associated tasks should be completed
     */
    /* Disabling flapping test due to SOQL limit

     public static testMethod void testCloseTodoAndTasks() {

        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        Test.startTest();
        ADM_Work__c work = ADM_Work.createTestWork('ToDo');


        work.Sprint__c = sprint.Id;
        update work;
        Test.stopTest();
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


          ADM_SprintVirtualWallController.closeWorkAndTasks(work.id);

          List<ADM_Work__c> updatedWorks = [select Status__c from ADM_Work__c where Id = :work.Id];
          System.assert(updatedWorks.size() > 0, 'Expected the work item to be found');
          System.assertEquals('Completed', updatedWorks.get(0).Status__c, 'Expected the status of the work item to be closed');

        Map<Id, ADM_Task__c> updatedTasks = new Map<Id, ADM_Task__c>([select Status__c from ADM_Task__c where Work__c = :work.id]);
        System.assertEquals(4, updatedTasks.values().size(), 'Expected all tasks to be returned since the work item should not have changed');

        System.assert(updatedTasks.containsKey(task1.Id), 'Expected task 1 to be returned');
        System.assertEquals('Completed', updatedTasks.get(task1.Id).Status__c, 'Expected task 1 status to be changed to Completed');

        System.assert(updatedTasks.containsKey(task2.Id), 'Expected task 2 to be returned');
        System.assertEquals('Completed', updatedTasks.get(task2.Id).Status__c, 'Expected task 2 status to be changed to Completed');

        System.assert(updatedTasks.containsKey(task3.Id), 'Expected task 3 to be returned');
        System.assertEquals('Completed', updatedTasks.get(task3.Id).Status__c, 'Expected task 3 status to be changed to Completed');

        System.assert(updatedTasks.containsKey(task4.Id), 'Expected task 4 to be returned');
        System.assertEquals('Completed', updatedTasks.get(task4.Id).Status__c, 'Expected task 4 status to be changed to Completed');

    }*/

    /*
      @testcaseID a1DB00000002IPV
      @hierarchy GUS.ScrumforceToGUS.Product Tags.Guided Tour
      @userstory    a07B0000000MRuk
      @expectedResults: The guided tour should be displayed.
      @author jhatton
    */

    /**
     * Given a user with a configured preference to show the guided tour, the showGuidedTour
     * property should match.
     * @author jared.pearson
     */
    static testMethod void testShowGuidedTourWithTruePreference() {
        User user1 = createTestUser();
        System.runAs(user1){

            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowVirtualWallGuidedTour__c = true;
            upsert preferences;

            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();

            System.assertEquals(true, controller.getShowGuidedTour(), 'Expected the showGuidedTour property to match that of the User Preference');
        }
    }
        /*
      @testcaseID a1DB00000002POI
      @hierarchy GUS.ScrumforceToGUS.Product Tags.Guided Tour
      @userstory    a07B0000000MRuk
      @expectedResults: Guided tour shows on social sprint upon arriving to the sprint page
      @author jhatton
    */
    /**
     * Given a user with a configured preference to hide the guided tour, the showGuidedTour
     * property should match.
     * @author jared.pearson
     */
    static testMethod void testShowGuidedTourWithFalsePreference() {
        User user1 = createTestUser();
        System.runAs(user1){

            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowVirtualWallGuidedTour__c = false;
            upsert preferences;

            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();

            System.assertEquals(false, controller.getShowGuidedTour(), 'Expected the showGuidedTour property to match that of the User Preference');
        }
    }
    /*
      @testcaseID a1DB00000002PON
      @hierarchy GUS.ScrumforceToGUS.Product Tags.Guided Tour
      @userstory    a07B0000000MRuk
      @expectedResults: Guided tour shouldn't come up unless user clicks on the "Guided tour" link
      @author jhatton
    */

    /**
     * When the never show guided tour method is invoked, the getShowGuidedTour should return false.
     * @author jared.pearson
     */
    static testMethod void testNeverShowGuidedTour() {
        User user1 = createTestUser();
        System.runAs(user1){

            //create a user preference to show the tour
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowVirtualWallGuidedTour__c = true;
            upsert preferences;

            //call the method to never show the preference
            ADM_SprintVirtualWallController.neverShowGuidedTour();

            //check to make sure the value is false
            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
            System.assertEquals(false, controller.getShowGuidedTour(), 'Expected the neverShowGuidedTour to change the showGuidedTour property to false');

            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowVirtualWallGuidedTour__c, 'Expected neverShowGuidedTour to change the User Preference');
        }
    }

    /*
      @testcaseID a1DB00000002gvf
      @hierarchy GUS.Social Sprint.Warnings
      @userstory a07B0000000NdhL
      @expectedResults: When clicking on Don't ask me again, none of the warning messages will be asked again

    */

    static testMethod void testNeverShowMoveUncompletedTasksDialog() {
        User user1 = createTestUser();
        System.runAs(user1){

            //create a user preference to show the dialog
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowMoveUncompletedTasksDialog__c = true;
            upsert preferences;

            //call the method to never show the dialog
            ADM_SprintVirtualWallController.neverShowMoveUncompletedTasksDialog();

            //check to make sure the value is false
            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
            System.assertEquals(false, controller.getShowMoveUncompletedTasksDialog(), 'Expected the neverShowMoveUncompletedTasksDialog to change the showMoveUncompletedTasksDialog property to false');

            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowMoveUncompletedTasksDialog__c, 'Expected neverShowMoveUncompletedTasksDialog to change the User Preference');
        }
    }
    /*
      @testcaseID a1DB00000002bws
      @hierarchyGUS.Social Sprint.Virtual Wall.Detail page
      @userstory a07B0000000cydg
      @expectedResults: When clicking on Don't ask me again, none of the warning messages will be asked again

    */

    static testMethod void testNeverShowRemoveWorkFromSprintDialog() {
        User user1 = createTestUser();
        System.runAs(user1){

            //create a user preference to show the dialog
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowRemoveWorkFromSprintDialog__c = true;
            upsert preferences;

            //call the method to never show the dialog
            ADM_SprintVirtualWallController.neverShowRemoveWorkFromSprintDialog();

            //check to make sure the value is false
            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
            System.assertEquals(false, controller.getShowRemoveWorkFromSprintDialog(), 'Expected the neverShowRemoveWorkFromSprintDialog to change the ShowRemoveWorkFromSprintDialog property to false');

            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowRemoveWorkFromSprintDialog__c, 'Expected neverShowRemoveWorkFromSprintDialog to change the User Preference');
        }
    }


    /*
      @testcaseID a1DB00000002y4LMAQ
      @hierarchy GUS.Social Sprint.Virtual Wall.Detail page
      @userstory a0A2000000602fT
      @expectedResults: When clicking on Don't ask me again, the move work to other sprint dialog will not be shown again.

    */

    static testMethod void testNeverShowMoveWorkToOtherSprintDialog() {
        User user1 = createTestUser();
        System.runAs(user1){

            //create a user preference to show the dialog
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowMoveWorkToOtherSprintDialog__c = true;
            upsert preferences;

            //call the method to never show the dialog
            ADM_SprintVirtualWallController.neverShowMoveWorkToOtherSprintDialog();

            //check to make sure the value is false
            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
            System.assertEquals(false, controller.getShowMoveWorkToOtherSprintDialog(), 'Expected the neverShowMoveWorkToOtherSprintDialog to change the ShowMoveWorkToOtherSprintDialog property to false');

            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowMoveWorkToOtherSprintDialog__c, 'Expected neverShowMoveWorkToOtherSprintDialog to change the User Preference');
        }
    }

    /*
      @testcaseID a1DB00000002bwn
      @hierarchy GUS.Social Sprint.Warnings
      @userstory a07B0000000NdhL
      @expectedResults: When clicking on Don't ask me again, none of the warning messages will be asked again

    */
    static testMethod void testNeverShowMoveTaskToCompletedDialog() {
        User user1 = createTestUser();
        System.runAs(user1){

            //create a user preference to show the dialog
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowMoveTaskToCompletedDialog__c = true;
            upsert preferences;

            //call the method to never show the dialog
            ADM_SprintVirtualWallController.neverShowMoveTaskToCompletedDialog();

            //check to make sure the value is false
            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
            System.assertEquals(false, controller.getShowMoveTaskToCompletedDialog(), 'Expected the neverShowMoveTaskToCompletedDialog to change the ShowMoveTaskToCompletedDialog property to false');

            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowMoveTaskToCompletedDialog__c, 'Expected neverShowMoveTaskToCompletedDialog to change the User Preference');
        }
    }

    /*
      @testcaseID a1DB00000002bwx
      @hierarchy GUS.Social Sprint.Warnings
      @userstory a07B0000000NdhL
      @expectedResults: When clicking on Don't ask me again, none of the warning messages will be asked again

    */
    static testMethod void testNeverShowMoveTaskToInProgressDialog() {
        User user1 = createTestUser();
        System.runAs(user1){

            //create a user preference to show the dialog
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowMoveTaskToInProgressDialog__c = true;
            upsert preferences;

            //call the method to never show the dialog
            ADM_SprintVirtualWallController.neverShowMoveTaskToInProgressDialog();

            //check to make sure the value is false
            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
            System.assertEquals(false, controller.getShowMoveTaskToInProgressDialog(), 'Expected the neverShowMoveTaskToInProgressDialog to change the ShowMoveTaskToInProgressDialog property to false');

            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowMoveTaskToInProgressDialog__c, 'Expected neverShowMoveTaskToInProgressDialog to change the User Preference');
        }
    }
    /*
      @testcaseID a1DB00000002bwi
      @hierarchy GUS.Social Sprint.Warnings
      @userstory a07B0000000NdhL
      @expectedResults: When clicking on Don't ask me again, none of the warning messages will be asked again

    */

    static testMethod void testNeverShowDeleteTaskDialog() {
        User user1 = createTestUser();
        System.runAs(user1){

            //create a user preference to show the dialog
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowDeleteTaskDialog__c = true;
            upsert preferences;

            //call the method to never show the dialog
            ADM_SprintVirtualWallController.neverShowDeleteTaskDialog();

            //check to make sure the value is false
            ADM_SprintVirtualWallController controller = new ADM_SprintVirtualWallController();
            System.assertEquals(false, controller.getShowDeleteTaskDialog(), 'Expected the neverShowDeleteTaskDialog to change the ShowDeleteTaskDialog property to false');

            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowDeleteTaskDialog__c, 'Expected neverShowDeleteTaskDialog to change the User Preference');
        }
    }

    static testMethod void testGetSprintChart() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);
        sprint.Start_Date__c = System.today();
        sprint.End_Date__c = System.today() + 15;
        sprint.Total_Workdays__c=12; 
        
        update sprint;
        
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Story_Points__c = 3;
        story.Closed_On__c = Date.today().addDays(6);
        update story;
        
        List<ADM_Sprint__c> sprint_list = new List<ADM_Sprint__c>();
        sprint_list.add(sprint);
            
        new ADM_SprintBurnDownUtils().createSprintBurnDownIdeal( sprint_list );
        Map<String, Object> chart = (Map<String, Object>) JSON.deserializeUntyped(ADM_SprintVirtualWallController.getSprintChartAura((String)sprint.Id, 'Story Points'));

        Map<String, Object> xAxis = (Map<String, Object>) chart.get('xAxis');
        Map<String, Object> yAxis = (Map<String, Object>) chart.get('yAxis');

        System.assertEquals('Day', xAxis.get('title'));
        System.assertEquals('Story Points', yAxis.get('title'));
        System.assertEquals('Burn Down', chart.get('title'));        
        
        List<Object> series_list = (List<Object>) chart.get('seriesList');
        System.assertEquals( 2 , series_list.size(), 'Expected only two series data points.');
       
        Boolean found_ideal = false;
        Boolean found_real = false;
        List<Object> ideal_objects = new List<Object>();
        List<Object> real_objects = new List<Object>();

        for (Integer i = 0; i < series_list.size(); i++) {
            Map<String, Object> series_item = (Map<String, Object>) series_list[i];

            if (series_item.get('name') == 'Real Burndown') {
                found_real = true;   
                real_objects = (List<Object>) series_item.get('data');
            }
            if (series_item.get('name') == 'Ideal Burndown') {
                found_ideal = true;
                ideal_objects = (List<Object>) series_item.get('data');
            }
        }
        
        System.assert(found_ideal, 'The ideal series data was not available');
        System.assert(found_real, 'The real series data was not available');
        
        System.assert( 0 < real_objects.size() , 'The real object series list had zero entries.');
        System.assert( 0 < ideal_objects.size() , 'The ideal object series list had zero entries.');
        
        Boolean ideal_had_a_positive = false;
        Boolean real_had_a_positive = false;
        
        for ( Object o : ideal_objects ){
            if ( o instanceof Double ){
                Double d = (Double) o;
                System.assert( 0.0 <= d , 'The ideal series data wasn\'t a positive number ' + d);
                if ( 0.0 < d ) ideal_had_a_positive = true;
            }
        }

        for ( Object o : real_objects ){
            if ( o instanceof Double ){
                Double d = (Double) o;
                System.assert( 0.0 <= d , 'The real series data wasn\'t a positive number ' + d);
                if ( 0.0 < d ) real_had_a_positive = true;
            }
        }

        System.assert( ideal_had_a_positive , 'The ideal series data did not have a single positive number');
        System.assert( real_had_a_positive , 'The real series data did not have a single positive number');
    }

    static testMethod void testGetTaskHoursSprintChart() {

        /**
         * The burn down charts do not render over the weekend, so 
         * if this test runs on a Saturday or Sunday, skip it.
         */
        DateTime todaysDate = DateTime.newInstance(System.currentTimeMillis());
        String todaysDateFormat = todaysDate.formatGMT('EEE');        
        if ( todaysDateFormat.contains('Sat') || todaysDateFormat.contains('Sun') ){
            System.debug('Skipping this test since its being executed on a Weekend');
            return;
        }

        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);
        sprint.Start_Date__c = System.today();
        sprint.End_Date__c = System.today() + 15;
        sprint.Total_Workdays__c=12; 
        
        update sprint;
        
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Story_Points__c = 3;
        story.Closed_On__c = Date.today().addDays(6);
        update story;
        
        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = UserInfo.getUserId(), Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
        insert task;

        List<ADM_Sprint__c> sprint_list = new List<ADM_Sprint__c>();
        sprint_list.add(sprint);
            
        new ADM_SprintBurnDownUtils().createSprintBurnDownIdeal( sprint_list );
        Map<String, Object> chart = (Map<String, Object>) JSON.deserializeUntyped(ADM_SprintVirtualWallController.getSprintChartAura((String)sprint.Id, 'Task Hours'));

        Map<String, Object> xAxis = (Map<String, Object>) chart.get('xAxis');
        Map<String, Object> yAxis = (Map<String, Object>) chart.get('yAxis');

        System.assertEquals('Day', xAxis.get('title'));
        System.assertEquals('Task Hours', yAxis.get('title'));
        System.assertEquals('Burn Down', chart.get('title'));        
        
        List<Object> series_list = (List<Object>) chart.get('seriesList');
        System.assertEquals( 2 , series_list.size(), 'Expected only two series data points.');
       
        Boolean found_ideal = false;
        Boolean found_real = false;
        List<Object> ideal_objects = new List<Object>();
        List<Object> real_objects = new List<Object>();

        for (Integer i = 0; i < series_list.size(); i++) {
            Map<String, Object> series_item = (Map<String, Object>) series_list[i];

            if (series_item.get('name') == 'Real Burndown') {
                found_real = true;   
                real_objects = (List<Object>) series_item.get('data');
            }
            if (series_item.get('name') == 'Ideal Burndown') {
                found_ideal = true;
                ideal_objects = (List<Object>) series_item.get('data');
            }
        }
        
        System.assert(found_ideal, 'The ideal series data was not available');
        System.assert(found_real, 'The real series data was not available');
        
        System.assert( 0 < real_objects.size() , 'The real object series list had zero entries. The current time zone is :'  +  UserInfo.getTimeZone().getDisplayName() + ' . The current time is :' +  System.now().format('EEEE, MMMM d, yyyy') + '. The current user is :' + UserInfo.getUserId()  + ' and their time zone is ' + UserInfo.getTimeZone());
        System.assert( 0 < ideal_objects.size() , 'The ideal object series list had zero entries.');
        
        Boolean ideal_had_a_positive = false;
        Boolean real_had_a_positive = false;
        
        for ( Object o : ideal_objects ){
            if ( o instanceof Double ){
                Double d = (Double) o;
                System.assert( 0.0 <= d , 'The ideal series data wasn\'t a positive number ' + d);
                if ( 0.0 < d ) ideal_had_a_positive = true;
            }
        }

        for ( Object o : real_objects ){
            if ( o instanceof Double ){
                Double d = (Double) o;
                System.assert( 0.0 <= d , 'The real series data wasn\'t a positive number ' + d);
                if ( 0.0 < d ) real_had_a_positive = true;
            }
        }

        System.assert( ideal_had_a_positive , 'The ideal series data did not have a single positive number');
        System.assert( real_had_a_positive , 'The real series data did not have a single positive number');
    }

    private static User createTestUser() {
        User u = ADM_WorkUser.createTestUserWithRandomName();
        u = [select Id, Name, Email from User where Id=:u.Id limit 1];
        return u;
    }
    
    static testMethod void testGetUserInfoAura() {
        ADM_SprintVirtualWallController.UserData userData = (ADM_SprintVirtualWallController.UserData) JSON.deserialize(ADM_SprintVirtualWallController.getUserInfoAura(), ADM_SprintVirtualWallController.UserData.class);

        Id userId = UserInfo.getUserId();
        User u = [select Id, Name, SmallPhotoUrl from User where Id = :userId limit 1];
        List<PermissionSetAssignment> uPermSet = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId];    

        System.assertEquals(userData.user.Id, UserInfo.getUserId());
        System.assertEquals(userData.user.Name, u.Name);
        System.assertEquals(userData.permSets[0].Id, uPermSet[0].Id);
    }
    
    static testMethod void testAuraCreateWork() {
        ADM_ConstantsSingleton.getInstance().setUserLightningExperiencePreferred(true);
        String bugUrl = ADM_SprintVirtualWallController.getWorkCreateEditPage(ADM_Work.RECORD_TYPE_NAME_BUG);
        String usUrl = ADM_SprintVirtualWallController.getWorkCreateEditPage(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        String investigationUrl = ADM_SprintVirtualWallController.getWorkCreateEditPage(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);

        String bugRTQS = '?RecordType=' + ADM_RecordType.getByName(ADM_Work.RECORD_TYPE_NAME_BUG, 'ADM_Work__c').Id;
        String usRTQS = '?RecordType=' + ADM_RecordType.getByName(ADM_Work.RECORD_TYPE_NAME_USERSTORY, 'ADM_Work__c').Id;
        String investigationRTQS = '?RecordType=' + ADM_RecordType.getByName(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, 'ADM_Work__c').Id;

        System.assertEquals(Page.ADM_BugEditSds.getUrl() + bugRTQS, bugUrl);
        System.assertEquals(Page.ADM_UserStoryEditSds.getUrl() + usRTQS, usUrl);
        System.assertEquals(Page.ADM_InvestigationEditSds.getUrl() + investigationRTQS, investigationUrl);
    }
}