@isTest
public with sharing class ADM_KanbanBoardControllerTests {

/*static testMethod void testSaveWorks() {
        // create team
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('GUS Test Suite Team');

        // create 1 column: NEW
        ADM_Column__c column1 = ADM_ColumnUtility.createTestColumn('New', null, 0, 0, team.Id);
        insert column1;
        
        // create column 2: IN PROGRESSS
        ADM_Column__c column2 = ADM_ColumnUtility.createTestColumn('In Progress', null, 0, 0, team.Id);
        insert column2;
        
        // create work record: 1 POSITION
        List<ADM_Work__c> newStories = ADM_Work.createListOfWork(3, ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        
        ADM_Work__c story1 = newStories[0];
        story1.Subject__c = 'Subject A';
        story1.Column_Rank__c = 1;
        story1.Column__c = column1.Id;
        insert story1;
            
        // create work record: 2 POSITION
        ADM_Work__c story2 = newStories[1];
        story2.Subject__c = 'Subject B';
        story2.Column_Rank__c = 2;
        story2.Column__c = column1.Id;
        insert story2;

        // create work record: 3 POSITION
        ADM_Work__c story3 = newStories[2];
        story3.Subject__c = 'Subject C';
        story3.Column_Rank__c = 3;
        story3.Column__c = column1.Id;
        insert story3;

        // reindex work records
        
        List<ADM_Work__c> stories = new List<ADM_Work__c>();
        stories.add(story3);
        stories.add(story2);
        stories.add(story1);
        
        ADM_KanbanBoardController.saveWorks(column2.Id , stories);

        // observe their sort orders changed
        List<ADM_Work__c> updatedStories = [select Id, Subject__c, Column__c, Column_Rank__c from ADM_Work__c WHERE Id IN :stories ORDER BY Column_Rank__c];
        System.assertEquals(story3.Id, updatedStories.get(0).Id, 'Expected the third story to now be the first');

    }*/
    
    static testMethod void testStatusIsUpdatedWhenTheColumnIDChanges() {
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        //verify the story begins with the new status
        System.assertEquals('New', story.Status__c);
        //turn on kanban for this team
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c(id=story.Scrum_Team__c);
        team.Kanban__c = true;
        update team;
       
        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name from ADM_Column__c where Team__c =:team.id];
        System.assert(columns != null && columns.size() >= 3, 'Expected at least two Kanban columns to be initialized for team:' + team.id);
        ADM_Column__c column1 = columns[0];
        //Now In Progress is the third element in the list
        ADM_Column__c column2 = columns[2];
        //move work into column 1
        story.Column__c = column1.id;
        update story;
        //move from column 1 to column 2 and call the same controller method used when dragging and dropping {moving from New to In Progress}
        story.Column__c = column2.id;
        List<ADM_Work__c> workBeingDragged = new List<ADM_Work__c>();
        workBeingDragged.add(story);
        ADM_KanbanBoardController.saveWorks(workBeingDragged, false);
        //verify the status changed - don't assert on the status name since they can change from org to org
        ADM_Work__c updatedStory= [select id, Status__c, Column__c, Origin__c from ADM_Work__c where id = :story.id];
        System.assertNotEquals(story.Status__c, updatedStory.Status__c ,' Expected In Progress status for updated story , but got ' + story.Status__c);
        //verify the origin was not saved to the database as this would cause subsequent edits to be validated incorrectly
        System.assertEquals(null, updatedStory.Origin__c);
    }  
/*
    static testMethod void testSaveColumnsThrowExceptionIfOneColumnSendWithoutStatusMapping() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;
       
        
        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Parent_Column__c, Active__c from ADM_Column__c where Team__c =:team.id];

        ADM_Column testColumn = new ADM_Column(columns[0]);
        boolean expThrown = false;
        try{
            ADM_KanbanBoardController.saveColumns(new List<ADM_Column>{testColumn});
        }
        catch(ADM_ApplicationException exp){
            expThrown = true;
            System.assert(exp.getMessage().contains('Column Status Assignment is required for Column'));
        }

        System.assertEquals(true, expThrown,'Expected to throw ADM_ApplicationException with message :- Column Status Assignment is required for Column');

    }  
*/
    static testMethod void testSaveColumnsWithNewStatus() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;
       
        List<ADM_Work_Status__c> workStatuses = [Select Order__c from ADM_Work_Status__c where Type__c includes ('Bug' , 'User Story') order by Order__c desc];
        System.assert(workStatuses.size() >0 , 'Expected workStatuses to be created as part of column creation above as part of team.Kanban__c update');

        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Parent_Column__c, Parent_Column__r.Name, Active__c from ADM_Column__c where Team__c =:team.id];

        ADM_Column__c testColumnSObject = columns[0];
        ADM_Column testColumn = new ADM_Column(testColumnSObject);

        testColumnSObject.Name = 'NameChanged';
        
        ADM_Work_Status__c workStatus = new ADM_Work_Status__c();
        workStatus.Name = 'testStatus';
        workStatus.Order__c = workStatuses[0].Order__c + 1;
        insert workStatus;

        testColumn.getMappedWorkStatuses().put(workStatus.id, '');

        try{
            ADM_KanbanBoardController.saveColumns(new List<ADM_Column>{testColumn});
        }
        catch(ADM_ApplicationException exp){
            System.assert(exp.getMessage().contains('Column Status Assignment is required for Column'));
        }

        List<ADM_Column__c> columnsAfterUpdate = [select id, Name, Parent_Column__c, Active__c from ADM_Column__c where Id =:testColumnSObject.id];

        List<ADM_Column_Status_Assignment__c> columnAssignments = [select Column__c, Work_Status__c from ADM_Column_Status_Assignment__c where Column__c =:testColumnSObject.id];

        System.assertEquals('NameChanged', columnsAfterUpdate[0].Name, ' Expected column name to be updated');

        System.assert(columnAssignments.size() > 0, ' Expected column status assignment be created');

        System.assertEquals(workStatus.Id, columnAssignments[0].Work_Status__c, ' Expected work status to be the one inserted above '+ workStatus.Id);


    } 

   static testMethod void testColumnDeactivationWillDeleteStatusAssignment() {
         //pull the teams columns
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;
       
        
        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Parent_Column__c, Parent_Column__r.Name, Active__c, Position__c, Level__c, Team__c from ADM_Column__c where Team__c =:team.id];
        ADM_Column__c testColumnSObject = columns[0];
        ADM_Column testColumn = new ADM_Column(testColumnSObject);

        testColumnSObject.Active__c = false; 
        ADM_KanbanBoardController.SaveColumnsResult result = ADM_KanbanBoardController.saveColumns(new List<ADM_Column>{testColumn});
        List<ADM_Column__c> columnsAfterUpdate = [select id, Name, Parent_Column__c, Active__c from ADM_Column__c where Id =:testColumnSObject.id];

        List<ADM_Column_Status_Assignment__c> columnAssignments = [select Column__c, Work_Status__c from ADM_Column_Status_Assignment__c where Column__c =:testColumnSObject.id];

        System.assertEquals(false, columnsAfterUpdate[0].Active__c, ' Expected column to be deactivated');

        System.assert(columnAssignments.size() == 0, ' Expected column status assignment to be deleted');

        System.assertEquals('Delete', result.action, ' Expected delete operation');


    } 

    static testMethod void testSaveColumnsInsertNewColumn() {
         //pull the teams columns
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;

        List<ADM_Work_Status__c> workStatuses = [Select Order__c from ADM_Work_Status__c where Type__c includes ('Bug' , 'User Story') order by Order__c desc];
       
        System.assert(workStatuses.size() >0 , 'Expected workStatuses to be created as part of column creation above as part of team.Kanban__c update');
        /*
            New work status for testing
        */
        ADM_Work_Status__c workStatus = new ADM_Work_Status__c();
        workStatus.Name = 'testStatus';
        workStatus.Order__c = workStatuses[0].Order__c + 1;
        insert workStatus;
        
        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Parent_Column__c, Active__c, Position__c from ADM_Column__c where Team__c =:team.id and Parent_Column__c = null order by Position__c desc];

        //getting the highest position column
        ADM_Column__c testColumnSObject = columns[0];

        ADM_Column__c newColumnSObject = new ADM_Column__c();
        newColumnSObject.name = 'NewSColumnRandom';
        newColumnSObject.Level__c = 0;
        newColumnSObject.Position__c = testColumnSObject.Position__c + 1;
        newColumnSObject.Team__c = team.Id;
        
        ADM_Column testColumn = new ADM_Column(newColumnSObject);

        testColumn.getMappedWorkStatuses().put(workStatus.id, '');

        ADM_KanbanBoardController.SaveColumnsResult result = ADM_KanbanBoardController.saveColumns(new List<ADM_Column>{testColumn});

        System.assertEquals('Insert', result.action, ' Expected insert operation');
        System.assert(null != result.newColumnId, ' Expected new column Sobject id');
        List<ADM_Column__c> columnsAfterUpdate = [select id, Name, Parent_Column__c, Active__c from ADM_Column__c where Id =:result.newColumnId];

        List<ADM_Column_Status_Assignment__c> columnAssignments = [select Column__c, Work_Status__c from ADM_Column_Status_Assignment__c where Column__c =:result.newColumnId];

        System.assert(columnAssignments.size() > 0, ' Expected column status assignment to be deleted');

        System.assertEquals(result.newColumnId, columnAssignments[0].Column__c, ' Expected column status assignment to have the new column id');

        System.assertEquals(workStatus.Id, columnAssignments[0].Work_Status__c, ' Expected column status assignment to have the new column id');

       


    }

    static testMethod void testSaveColumnsUpdateMultipleColumn() {
         //pull the teams columns
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;

        List<ADM_Work_Status__c> workStatuses = [Select Order__c from ADM_Work_Status__c where Type__c includes ('Bug' , 'User Story') order by Order__c desc];
        System.assert(workStatuses.size() >0 , 'Expected workStatuses to be created as part of column creation above as part of team.Kanban__c update');
       
        /*
            New work status for testing
        */
        ADM_Work_Status__c workStatus = new ADM_Work_Status__c();
        workStatus.Name = 'testStatus';
        workStatus.Order__c = workStatuses[0].Order__c + 1;
        insert workStatus;
        
        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Parent_Column__c, Active__c, Position__c from ADM_Column__c where Team__c =:team.id and Parent_Column__c = null order by Position__c desc];

        List<ADM_Column> columnForSaveColumnTest = new List<ADM_Column>();
        for(ADM_Column__c column: columns){
            column.Name = column.Name + '_random';
            columnForSaveColumnTest.add(new ADM_Column(column));
        }

        ADM_KanbanBoardController.SaveColumnsResult result = ADM_KanbanBoardController.saveColumns(columnForSaveColumnTest);

        
        List<ADM_Column__c> columnsAfterUpdate = [select id, Name, Parent_Column__c, Active__c from ADM_Column__c where Id =:result.newColumnId];

        System.assertEquals('Update', result.action, ' Expected update operation');
        for(ADM_Column__c columnAfterUpdate: columns){
            System.assert(columnAfterUpdate.Name.contains('_random'), ' Expected column name to be changed');
        }
       


    }

    static testMethod void getColumnsAndWorksMethodThrowsADM_ApplicationExceptionForKanbanNotConfiguredTeams() {
         //pull the teams columns
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        boolean expThrown = false;
        try{
            String resultJson = ADM_KanbanBoardController.getColumnsAndWorksAsJSON(team.id);
        }
        catch(ADM_ApplicationException exp){
            expThrown = true;
            System.assert(exp.getMessage().contains('Error: This team is not configured to use Kanban.  Please check the Kanban checkbox on your team detail page.'), 'Expected exp message not found');
        }
        System.assert(expThrown, 'Expected ADM_ApplicationException to be thrown for team\'s kanban page request if no columns found');
       


    }   

    static testMethod void testColumnDeactivationWillDecrementPositionForSuccessiveColumns() {
         //pull the teams columns
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;
       
        Map<String,Decimal> id2Position = new Map<String,Decimal>();
        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Level__c, Parent_Column__c, Parent_Column__r.Name, Active__c, Team__c,Position__c from ADM_Column__c where Team__c =:team.id];

        ADM_Column__c testColumnSObject = columns[0];
        ADM_Column testColumn = new ADM_Column(testColumnSObject);

        for(ADM_Column__c columnIter: columns){
            System.debug(columnIter.Name + ' ' + columnIter.Id);
            if(columnIter.Name != testColumnSObject.Name && testColumnSObject.Level__c == columnIter.Level__c && columnIter.Parent_Column__c == testColumnSObject.Parent_Column__c ){
                id2Position.put(columnIter.Id, columnIter.Position__c);
            }
        }

        testColumnSObject.Active__c = false; 
        ADM_KanbanBoardController.SaveColumnsResult result = ADM_KanbanBoardController.saveColumns(new List<ADM_Column>{testColumn});
        
        System.assertEquals('Delete', result.action, ' Expected delete operation');

        List<ADM_Column__c> columnsAfterUpdate = [select id, Name, Parent_Column__c, Active__c, Position__c from ADM_Column__c where 
                                                     Parent_Column__c = :testColumnSObject.Parent_Column__c and Level__c = :testColumnSObject.Level__c  ];
                                                     System.debug(id2Position);
        for(ADM_Column__c columnIter: columnsAfterUpdate){
            if(columnIter.Name == testColumnSObject.Name ){
                System.assertEquals(false, columnIter.Active__c, ' Expected column to be deactivated');
            }
            else{
                System.debug(columnIter.Id);
                Decimal previousPosition = id2Position.get(columnIter.Id);
                Decimal expectedPosition = previousPosition -1;
                System.assert( expectedPosition == columnIter.Position__c, ' Since one column above was deleted expected position ' + expectedPosition + ' for column ' + columnIter.Name +' but got ' + columnIter.Position__c);
            }

        }
    }

    static testMethod void testStatusChangedForNewWorkOnKanbanColumnAssignment(){



        ADM_Work__c testWork = ADM_Work.setupTestWork('User Story', '');


        ADM_Scrum_Team__c team = [Select id, Kanban__c from ADM_Scrum_Team__c where id in (Select Team__c from ADM_Product_Tag__c where id = :testWork.Product_Tag__c)];

        team.Kanban__c = true;

        update team;

        List<ADM_Column__c> columns = [select id, Name, Level__c, Parent_Column__c, Active__c, Team__c,Position__c from ADM_Column__c where Team__c =:team.id];

        List<ADM_Column_Status_Assignment__c> columnAssignments = [select Column__c, Work_Status__c, Work_Status__r.Name from ADM_Column_Status_Assignment__c where Column__c in :columns];

        //Get first status whichis not 'New'
        String status = '';
        String columnIdToAssign = '';
        for(ADM_Column_Status_Assignment__c assignment : columnAssignments){
          if(assignment.Work_Status__r.Name != 'New'){
            status = assignment.Work_Status__r.Name;
            columnIdToAssign = assignment.Column__c;
          }
        }

        testWork.Column__c = columnIdToAssign;
        insert testWork;

        ADM_Work__c workAfterInsert = [Select id, Status__c from ADM_Work__c where id = :testWork.Id];

        System.assertEquals(status, workAfterInsert.Status__c, 'Expected status to be same as mapped column status ');

    }

    static testMethod void testColumnDeactivationWillDecrementLevelForHigherLevelSuccessiveColumns() {
         //pull the teams columns
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        List<ADM_Column__c> columns = new List<ADM_Column__c>();
        ADM_Column__c columnLevel0 = new ADM_Column__c();
        columnLevel0.Name = 'columnLevel0';
        columnLevel0.Team__c = team.Id;
        columnLevel0.Parent_Column__c = null;
        columnLevel0.Level__c = 0;
        columnLevel0.Position__c = 0;
        columns.add(columnLevel0);

        ADM_Column__c columnLevel1 = new ADM_Column__c();
        columnLevel1.Name='columnLevel1';
        columnLevel1.Team__c = team.Id;
        columnLevel1.Parent_Column__c = null;
        columnLevel1.Level__c = 1;
        columnLevel1.Position__c = 0;
        columns.add(columnLevel1);

        ADM_Column__c columnLevel2 = new ADM_Column__c();
        columnLevel2.Name='columnLevel2';
        columnLevel2.Team__c = team.Id;
        columnLevel2.Parent_Column__c = null;
        columnLevel2.Level__c = 1;
        columnLevel2.Position__c = 0;
        columns.add(columnLevel2);

        ADM_Column__c columnLevel3 = new ADM_Column__c();
        columnLevel3.Name='columnLevel3';
        columnLevel3.Team__c = team.Id;
        columnLevel3.Parent_Column__c = null;
        columnLevel3.Level__c = 1;
        columnLevel3.Position__c = 0;
        columns.add(columnLevel3);

        insert columns;

        // Mark the top column as for deletion and execute
        columnLevel0.Active__c = false;
        ADM_KanbanBoardController.SaveColumnsResult result_first_column = ADM_KanbanBoardController.saveColumns(new List<ADM_Column>{new ADM_Column(columnLevel0)});
        System.assertEquals('Delete', result_first_column.action, ' Expected delete operation');

        // Mark the third column as for deletion and execute
        columnLevel2.Active__c = false;
        ADM_KanbanBoardController.SaveColumnsResult result_third_column = ADM_KanbanBoardController.saveColumns(new List<ADM_Column>{new ADM_Column(columnLevel2)});
        System.assertEquals('Delete', result_third_column.action, ' Expected delete operation');

        // Query existing columns
        List<ADM_Column__c> columnsAfterUpdate = [select id, Name, Parent_Column__c, Active__c, Level__c from ADM_Column__c where Team__c = :team.Id and Active__c = true ];

        // Former second column shifts into the top spot        
        System.assertEquals('columnLevel1', columnsAfterUpdate[0].Name, 'Expected higher level column '+columnLevel1.Name );
        System.assertEquals(0, columnsAfterUpdate[0].Level__c, 'Expected higher level column '+columnLevel1.Name + ' level to be decremented to '+ columnLevel0.Level__c);

        // Former last column shifts into the second spot
        System.assertEquals('columnLevel3', columnsAfterUpdate[1].Name, 'Expected 2nd higher level column '+columnLevel3.Name );
        System.assertEquals(1, columnsAfterUpdate[1].Level__c, 'Expected higher level column '+columnLevel3.Name + ' level to be decremented to '+ (columnLevel0.Level__c + 1));

    }

    static testMethod void testGetNewAndBacklogWorks(){
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        
        upsert works;

        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];

        ApexPages.currentPage().getParameters().put('teamid', works[0].Scrum_Team__c);
        ADM_KanbanBoardController controller = new ADM_KanbanBoardController();

        ADM_KanbanBoardController.KanbanWorkFeeder workFeeder = ADM_KanbanBoardController.getNewAndBacklogWorks(works[0].Scrum_Team__c, '25', '50');
        
        // Makes sure new items are returned
        System.assertEquals(10, workFeeder.recentNewWorks.size(), 'Expected 10 new items ');

        //Set up kanban for the team
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c(Id=works[0].Scrum_Team__c);
        team.Kanban__c = true;
        update team;

        List<ADM_Column__c> columns = [select id, Name, Level__c, Parent_Column__c, Active__c, Team__c,Position__c from ADM_Column__c where Team__c =:team.id];

        //Assign column to one of the work item
        works[8].Column__c = columns[0].Id;

        update works[8];

        workFeeder = ADM_KanbanBoardController.getNewAndBacklogWorks(works[8].Scrum_Team__c, '25', '50');

        // Makes sure work items assigned to column are ignored
        System.assertEquals(9, workFeeder.backLogWorks.size(), 'Expected 9 items in the back log as the works[8] has Column__c != null');

    }   

    static testMethod void testKanbanControllerReturnsUserStory(){

        // Create a User Story 
        List<ADM_Work__c> user_stories = ADM_Work.createListOfWork(1, 'User Story');
        insert user_stories;

        // Look up the User Stories associated Team
        List<ADM_Work__c> user_story_lookup = [Select id,Scrum_Team__c from ADM_Work__c];

        // Use the associated team ID so we can enable Kanban
        ADM_Scrum_Team__c team = [Select id,Kanban__c from ADM_Scrum_Team__c where Id =:user_story_lookup[0].Scrum_Team__c];
        team.Kanban__c = true;
        update team;

        // Populate the team ID into the parameter list for the Kanban Controller has access to it
        ApexPages.currentPage().getParameters().put('teamId', team.Id);

        // Look up the Ready column ID and then update the User Story so it'll be associated with the Kanban Board
        List<ADM_Column__c> readyColumn = [Select id, Name from ADM_Column__c  where Name = 'Ready' and Team__c =:team.Id];
        for ( ADM_Work__c user_story : user_stories ){
            user_story.Column__c = readyColumn[0].Id;
        }
        update user_stories;

        // Load up the Kanban Board Controller
        ADM_KanbanBoardController local_KanbanBoardController = new ADM_KanbanBoardController();        
        List<ADM_Column> kanbanWorks = ADM_KanbanBoardController.getColumnsAndWorks();
  
        // Iterate the Columns and collect the Work Items from each
        Integer workCount = 0;
        for ( ADM_Column kanbanWork : kanbanWorks ){
            workCount = workCount + kanbanWork.getWorkItems().size();
        }

        System.assertEquals(1, workCount);
        
    }   

    static testMethod void testKanbanControllerNeverReturnsToDos(){

        // Create a ToDo
        ADM_Work__c todo = ADM_Work.createTestTodo();
        upsert todo;

        // Confirm that todo was inserted appropriately
        List<ADM_Work__c> todo_lookup = [Select id,Scrum_Team__c from ADM_Work__c where Record_Type__c = 'ToDo'];
        System.assert( todo_lookup.size() == 1 );

        // Use the associated team ID so we can enable Kanban
        ADM_Scrum_Team__c team = [Select id,Kanban__c from ADM_Scrum_Team__c where Id =:todo_lookup[0].Scrum_Team__c];
        team.Kanban__c = true;
        update team;

        // Populate the team ID into the parameter list for the Kanban Controller has access to it
        ApexPages.currentPage().getParameters().put('teamId', team.Id);

        List<ADM_Column__c> readyColumn = [Select id, Name from ADM_Column__c  where Name = 'Ready' and Team__c =:team.Id];

        todo.Column__c = readyColumn[0].Id;
        update todo;

        // Load up the Kanban Board Controller
        ADM_KanbanBoardController local_KanbanBoardController = new ADM_KanbanBoardController();        
        List<ADM_Column> kanbanWorks = ADM_KanbanBoardController.getColumnsAndWorks();
  
        // Iterate the Columns and collect the Work Items from each
        Integer workCount = 0;
        for ( ADM_Column kanbanWork : kanbanWorks ){
            workCount = workCount + kanbanWork.getWorkItems().size();
        }

        // ToDos should never be there!
        System.assertEquals(0, workCount);
        
    }   
    static testMethod void testKanbanControllerRemoveKanbanColors(){
        ADM_Work__c bug = ADM_Work.createTestBug();

        // Populate the team ID into the parameter list for the Kanban Controller has access to it
        ApexPages.currentPage().getParameters().put('teamId', bug.Scrum_Team__c);

        
        ADM_Color__c testColor = ADM_Color.createColor('Test', '#000000', bug.Scrum_Team__c, 1);

        insert testColor;

        System.assertNotEquals(null, testColor.Id, 'Expected testColor to be created');
        // Load up the Kanban Board Controller
        ADM_KanbanBoardController local_KanbanBoardController = new ADM_KanbanBoardController();        
        ADM_KanbanBoardController.removeKanbanColors(new List<String>{testColor.Id});
  
        ADM_Color__c [] testColorAfterDelete = [ Select id from ADM_Color__c where id = :testColor.Id ];

        
        System.assertEquals(0, testColorAfterDelete.size(), ' Expected testColorAfterDelete '+ testColorAfterDelete+ ' to be deleted');
        
    }  

    static testMethod void testKanbanColumnWillBeRetainedIfWorkChangesToANonMappedStatus(){

        // Create a User Story 
        List<ADM_Work__c> user_stories = ADM_Work.createListOfWork(1, 'User Story');
        insert user_stories; 
        
        
        
        ADM_Work__c userStoryQueried = [Select Scrum_Team__c from ADM_Work__c where id=:user_stories[0].Id];
        
        
        // Use the associated team ID so we can enable Kanban
        ADM_Scrum_Team__c team = [Select id,Kanban__c from ADM_Scrum_Team__c where Id =:userStoryQueried.Scrum_Team__c];
        team.Kanban__c = true;
        update team;
      
        
        List<ADM_Column_Status_Assignment__c> columnAssignments = [Select id, Column__c, Work_Status__c, Work_Status__r.Name from 
                                                                  ADM_Column_Status_Assignment__c where Work_Status__r.Name in ('In Progress', 'QA In Progress') and column__c in (Select id from ADM_Column__c where Team__c =:userStoryQueried.Scrum_Team__c)];
        
        System.assert(columnAssignments.size() > 0, 'Expected Column Status Assignment');
        ADM_Column_Status_Assignment__c toDelete = null;//This is going to be deleted
        ADM_Column_Status_Assignment__c toAssign = null;//Will use this to assign a column for work.
        for(ADM_Column_Status_Assignment__c ca: columnAssignments){
            if(ca.Work_Status__r.Name == 'In Progress'){
                toDelete = ca;
            }
            else{
                toAssign = ca;
            }
        }
        //Deleting column status assignments
        
        delete toDelete;
        
        Test.startTest();
        user_stories[0].Column__c = toAssign.Column__c;
        
        update  user_stories[0];
        ADM_Work__c workQueried = [Select id, Status__c, column__c from ADM_Work__c where id = :user_stories[0].Id];
        System.assertEquals(toAssign.Column__c,workQueried.Column__c, 'Expected column to be not null');
        
        user_stories[0].Status__c = 'In Progress';
                
         update  user_stories[0];
        workQueried = [Select id, Status__c, column__c from ADM_Work__c where id = :user_stories[0].Id];
        System.assertEquals('In Progress' ,workQueried.Status__c, ' Expected Work status to be In Progress');
        System.assertEquals(toAssign.Column__c,workQueried.Column__c, 'Expected column to be not null even if mapping not exist the previous column should be retained');
       Test.stopTest();
        
    }

}