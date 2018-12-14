@isTest
private class ADM_ColumnUtilityTest {
	
	@isTest static void arrangeColumnsInHierarchyTest() {
		String testScrumTeamId = ADM_ScrumTeam.createTestScrumTeam().Id;
		createTestColumnHierarchy(testScrumTeamId);
		List<ADM_Column__c> columnSObjects = ADM_ColumnQueryUtils.getColumnsByTeam(testScrumTeamId);
		ADM_ColumnUtility.ColumnUtilityDataHolder columnUtilityDataHolder = ADM_ColumnUtility.arrangeColumnsInHierarchy(columnSObjects);
		List<ADM_Column> parentColumns = columnUtilityDataHolder.parent2ChildrenColumn.get(null);
		System.assertEquals(6, parentColumns.size(), 'Expected 6 parent columns, but got only ' + parentColumns.size());

		System.assert('New'.equalsIgnoreCase(parentColumns[0].getColumnName()),'Expected New to be the first child of Root Parent');
		System.assert('In Progress'.equalsIgnoreCase(parentColumns[1].getColumnName()),'Expected In Progress to be the second child of Root Parent');
		System.assert('Fixed'.equalsIgnoreCase(parentColumns[2].getColumnName()),'Expected Fixed to be the third child of Root Parent');
		System.assert('QA in Progress'.equalsIgnoreCase(parentColumns[3].getColumnName()),'Expected QA In Progress to be the fourth child of Root Parent');
		System.assert('Closed'.equalsIgnoreCase(parentColumns[4].getColumnName()),'Expected Closed to be the fifth child of Root Parent');
		System.assert('Housekeeping'.equalsIgnoreCase(parentColumns[5].getColumnName()),'Expected Housekeeping to be the sixth child of Root Parent');

		for(ADM_Column column:parentColumns){
			System.debug(column.getColumnName());
			if(column.getColumnName().equalsIgnoreCase('In Progress')){
				System.assertEquals(3, column.getChildren().size(), 'Expected 3 children for In Progress, but got ' + column.getChildren().size());
				System.assert('UI In Progress'.equalsIgnoreCase(column.getChildren()[0].getColumnName()),'Expected UI In Progress to be the first child of In Progress');
				System.assert('UI Done'.equalsIgnoreCase(column.getChildren()[1].getColumnName()),'Expected UI Done to be the second child of In Progress');
				System.assert('Code In Progress'.equalsIgnoreCase(column.getChildren()[2].getColumnName()),'Expected Code In Progress to be the third child of In Progress');
			}

			if(column.getColumnName().equalsIgnoreCase('QA in Progress')){
				System.assertEquals(2, column.getChildren().size(), 'Expected 2 children for QA in Progress, but got ' + column.getChildren().size());
				System.assert('Expediate'.equalsIgnoreCase(column.getChildren()[0].getColumnName()),'Expected Expediate to be the first child of QA in Progress');
				System.assert('Active Projects'.equalsIgnoreCase(column.getChildren()[1].getColumnName()),'Expected Active Projects to be the second child of QA in Progress');
				List<ADM_Column> activateColumnChildren = column.getChildren()[1].getChildren();
				
				System.assert('Doing'.equalsIgnoreCase(activateColumnChildren[0].getColumnName()),'Expected Doing to be the first child of Active Projects');
				System.assert('Done'.equalsIgnoreCase(activateColumnChildren[1].getColumnName()),'Expected Done to be the second child of Active Projects');
			}

			if(column.getColumnName().equals('Housekeeping')){
				System.assertEquals(3, column.getChildren().size(), 'Expected 3 children for Housekeeping, but got ' + column.getChildren().size());
				System.assert('New'.equalsIgnoreCase(column.getChildren()[0].getColumnName()),'Expected New to be the first child of Housekeeping');
				System.assert('Doing'.equalsIgnoreCase(column.getChildren()[1].getColumnName()),'Expected Doing to be the second child of Housekeeping');
				System.assert('Done'.equalsIgnoreCase(column.getChildren()[2].getColumnName()),'Expected Doneto be the third child of Housekeeping');
			}
		}	
	}


	@isTest static void testCreateDefaultColumnsWithSingleTeam() {
		ADM_Scrum_Team__c testScrumTeam = ADM_ScrumTeam.createTestScrumTeam();
		List<ADM_Column__c> testColumnsOld = [Select id from ADM_Column__c where team__c =: testScrumTeam.Id AND Active__c = true];
		if(testColumnsOld != null){
			delete testColumnsOld;		
		}
		System.assert(testColumnsOld.size() == 0);

		ADM_WorkStatus.createAllWorkStatuses();
		testScrumTeam.Kanban__c = true;
		update testScrumTeam;

		List<ADM_Column__c> createdColumns = [Select id from ADM_Column__c where team__c =: testScrumTeam.Id AND Active__c = true];
		System.assert(createdColumns != null);
        System.assertEquals(10, createdColumns.size(), ' Expected created Columns size 10 didnot match');
		List<ADM_Column_Status_Assignment__c> createdColumnStatusMappings = [Select id from ADM_Column_Status_Assignment__c];
		System.assertNotEquals(null, createdColumnStatusMappings);
        System.assertEquals(9, createdColumnStatusMappings.size(), 'Expected createdColumnStatus Mapping size 9');
	}

	@isTest static void testCreateDefaultColumnsCreatesDefaultColorsForTeam() {
		ADM_Scrum_Team__c testScrumTeam = ADM_ScrumTeam.createTestScrumTeam();
		List<ADM_Column__c> testColumnsOld = [Select id from ADM_Column__c where team__c =: testScrumTeam.Id AND Active__c = true];
		if(testColumnsOld != null){
			delete testColumnsOld;		
		}
		System.assert(testColumnsOld.size() == 0);

		ADM_WorkStatus.createAllWorkStatuses();
		testScrumTeam.Kanban__c = true;
		update testScrumTeam;

		List<ADM_Color__c> createdColors = [Select id from ADM_Color__c where team__c =: testScrumTeam.Id AND Active__c = true];
		System.assert(createdColors != null);
        System.assertEquals(6, createdColors.size(), ' Expected 6 default colors to be created');
	}


	@isTest static void testCreateDefaultColumnsWithMultipleTeams() {
		ADM_WorkStatus.createAllWorkStatuses();
		ADM_Scrum_Team__c testScrumTeam1 = ADM_ScrumTeam.setupTestScrumTeam('Team1');
		testScrumTeam1.Kanban__c = true;
		ADM_Scrum_Team__c testScrumTeam2 = ADM_ScrumTeam.setupTestScrumTeam('Team2');
		testScrumTeam2.Kanban__c = true;



		List<ADM_Scrum_Team__c> teamList = new List<ADM_Scrum_Team__c> ();
		teamList.add(testScrumTeam1);
		teamList.add(testScrumTeam2);

		insert teamList;

		List<ADM_Column__c> createdColumns = [Select id from ADM_Column__c where team__c in: teamList AND Active__c = true];
		System.assertNotEquals(null, createdColumns);
		System.assertEquals(20, createdColumns.size(), ' Expected created Columns size 20 didnot match');
		List<ADM_Column_Status_Assignment__c> createdColumnStatusMappings = [Select id,Column__c from ADM_Column_Status_Assignment__c where Column__c in (select id from ADM_Column__c where team__c in:teamList) AND Column__r.Active__c = true];
		System.assertNotEquals(null, createdColumnStatusMappings);
        System.assertEquals(18, createdColumnStatusMappings.size(),' Expected 18 column status mappings to be created');
	}

	@isTest static void testCreateDefaultColumnsWithExistingColumns() {
		try{	
			ADM_WorkStatus.createAllWorkStatuses();
			ADM_Scrum_Team__c testScrumTeam = ADM_ScrumTeam.createTestScrumTeam();
			ADM_Column__c newColumn = ADM_ColumnUtility.createColumn('New', null, 0, 0, testScrumTeam.Id); 
			insert newColumn;
			List<ADM_Scrum_Team__c> teams = new List<ADM_Scrum_Team__c>();
			testScrumTeam.kanban__c = true;
			teams.add(testScrumTeam);
			update teams;
			//TODO : Decide if we are going to throw exceptions and block creating teams if there is an issue when creating columns
			//System.assert(false, 'Test should never reach this point. We expected an exception to have been thrown on the previous update.');
		}
		catch(Exception e){
			System.assert(e.getMessage().contains('Exception while creating and setting Columns and Column status Assignments'));
		}
	} 

	private static void createTestColumnHierarchy(String testScrumTeamId){

		ADM_Column__c testNewSObject = ADM_ColumnUtility.createColumn('New', null, 0, 0, testScrumTeamId);

		ADM_Column__c testInProgressSObject = ADM_ColumnUtility.createColumn('In Progress', null, 0, 1, testScrumTeamId);

		ADM_Column__c testFixedSObject = ADM_ColumnUtility.createColumn('Fixed', null, 0, 2, testScrumTeamId);

		ADM_Column__c testQaInProgressSObject = ADM_ColumnUtility.createColumn('QA in Progress', null, 0, 3, testScrumTeamId);

		ADM_Column__c testClosedSObject = ADM_ColumnUtility.createColumn('Closed', null, 0, 4, testScrumTeamId);

		ADM_Column__c testHouseKeepingSObject = ADM_ColumnUtility.createColumn('Housekeeping', null, 0, 5, testScrumTeamId);

		List<ADM_Column__c> admTestColumnSObjects = new List<ADM_Column__c>();

		/* Adding columns to list in random order*/
        admTestColumnSObjects.add(testClosedSObject);
		admTestColumnSObjects.add(testNewSObject);
		admTestColumnSObjects.add(testHouseKeepingSObject);
		admTestColumnSObjects.add(testFixedSObject);
		admTestColumnSObjects.add(testQaInProgressSObject);
		admTestColumnSObjects.add(testInProgressSObject);

		insert admTestColumnSObjects;

		ADM_Column__c testUI_In_ProgressSObject = ADM_ColumnUtility.createColumn('UI In Progress', testInProgressSObject.Id, 0, 0, testScrumTeamId);

		ADM_Column__c testUI_DoneSObject = ADM_ColumnUtility.createColumn('UI Done', testInProgressSObject.Id, 0, 1, testScrumTeamId);

		ADM_Column__c testCode_In_ProgressSObject = ADM_ColumnUtility.createColumn('Code In Progress', testInProgressSObject.Id, 0, 2, testScrumTeamId);

		ADM_Column__c testExpediateSObject = ADM_ColumnUtility.createColumn('Expediate', testQaInProgressSObject.Id, 0, 0, testScrumTeamId);

		ADM_Column__c testActiveProjectSObject = ADM_ColumnUtility.createColumn('Active Projects', testQaInProgressSObject.Id, 1, 0, testScrumTeamId);

		ADM_Column__c testNewChildSObject = ADM_ColumnUtility.createColumn('New', testHouseKeepingSObject.Id, 0, 0, testScrumTeamId);

		ADM_Column__c testDoingSObject = ADM_ColumnUtility.createColumn('Doing', testHouseKeepingSObject.Id, 0, 1, testScrumTeamId);

		ADM_Column__c testDoneSObject = ADM_ColumnUtility.createColumn('Done', testHouseKeepingSObject.Id, 0, 2, testScrumTeamId);

		admTestColumnSObjects.clear();
		/* Adding columns to list in random order*/
		admTestColumnSObjects.add(testCode_In_ProgressSObject);
		admTestColumnSObjects.add(testUI_DoneSObject);
		admTestColumnSObjects.add(testDoneSObject);
		admTestColumnSObjects.add(testUI_In_ProgressSObject);
		
		admTestColumnSObjects.add(testActiveProjectSObject);
		admTestColumnSObjects.add(testExpediateSObject);
		admTestColumnSObjects.add(testNewChildSObject);
		admTestColumnSObjects.add(testDoingSObject);
		

		insert admTestColumnSObjects;

		ADM_Column__c testDoingChildSObject = ADM_ColumnUtility.createColumn('Doing', testActiveProjectSObject.Id, 0, 0, testScrumTeamId);

		ADM_Column__c testDoneChildSObject = ADM_ColumnUtility.createColumn('Done', testActiveProjectSObject.Id, 0, 1, testScrumTeamId);

		admTestColumnSObjects.clear();
		admTestColumnSObjects.add(testDoneChildSObject);
		admTestColumnSObjects.add(testDoingChildSObject);
		

		insert admTestColumnSObjects;

	}

	@isTest static void cannotDeactivateAColumnWithWorkItems(){

		ADM_Work__c story = ADM_Work.createTestWork('User Story');
        //turn on kanban for the team
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c(id=story.Scrum_Team__c);
        team.Kanban__c = true;
        update team;

        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name from ADM_Column__c where Team__c =:team.id];

        ADM_Column__c columnSObject = columns[0];

        //Assign first column in the above list to the work item
        story.Column__c = columnSObject.Id;

        update story;

        //Now try to deactivate the column

        columnSObject.Active__c = false;

        boolean dmlExceptionThrown = false;

        try{
        	update columnSObject;
        }
        catch(System.DmlException dmlE){
        	dmlExceptionThrown = true;
	    	System.assert(dmlE.getMessage().contains('Cannot delete column with work item(s)'), 'Expected DML Exception with column contains work items error.');
        }

        System.assert(dmlExceptionThrown, 'Expected to throw dml exception by the column update call above');

        ADM_Column__c columnAfterUpdateAttempt = [select id, Name,Active__c from ADM_Column__c where id =:columnSObject.id];

        System.assertEquals(true, columnAfterUpdateAttempt.Active__c, ' Expected true because previous attempt to update Active__c = false should fail');
	}

	@isTest static void cannotUpdateAColumnToHaveSameColumnNameAtSameLevel(){

		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;

        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Parent_Column__c, Active__c, Position__c from ADM_Column__c where Team__c =:team.id and Parent_Column__c = null ];

        //colulmns with null parent 
        ADM_Column__c columnFirstSObject = columns[0];

        ADM_Column__c columnSecondSObject = columns[1];

        //try to make the second Column name same as first Column name

        columnSecondSObject.Name = columnFirstSObject.Name;

        boolean dmlExceptionThrown = false;
        try{
        	update columnSecondSObject;
        }
        catch(System.DmlException dmlE){
        	dmlExceptionThrown = true;
	    	System.assert(dmlE.getMessage().contains('Column Name must be unique per generation'), 'Expected DML Exception with column name not unique error.');
        }
        System.assert(dmlExceptionThrown, 'Expected to throw dml exception by the column update call above');
        	
	}
/*
	@isTest static void cannotUpdateAColumnToHaveSameLevelAndPositionAsOtherColumnWithSameParent(){

		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;

        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Parent_Column__c, Active__c, Position__c, Level__c from ADM_Column__c where Team__c =:team.id and Parent_Column__c = null ];

        //colulmns with null parent 
        ADM_Column__c columnFirstSObject = columns[0];

        ADM_Column__c columnSecondSObject = columns[1];

        //try to make the second Column name same level and position as the first Column 

        columnSecondSObject.Level__c = columnFirstSObject.Level__c;
        columnSecondSObject.Position__c = columnFirstSObject.Position__c;

        boolean dmlExceptionThrown = false;
        try{
        	update columnSecondSObject;
        }
        catch(System.DmlException dmlE){
        	dmlExceptionThrown = true;
	    	System.assert(dmlE.getMessage().contains('Column Level__c, Position__c combination should be unique per generation'), 'Expected DML Exception with column level and position combination not unique per generation error.');
        }
        System.assert(dmlExceptionThrown, 'Expected to throw dml exception by the column update call above');
     }

     @isTest static void cannotInsertAColumnToHaveSameLevelAndPositionAsOtherColumnWithSameParent(){

		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;

        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Team__c, Parent_Column__c, Active__c, Position__c, Level__c from ADM_Column__c where Team__c =:team.id and Parent_Column__c = null ];

        //colulmns with null parent 
        ADM_Column__c columnFirstSObject = columns[0];

        ADM_Column__c columnSObject = new ADM_Column__c();

        //try to make the new Column with same level and position as the existing column
        columnSObject.Name = 'Random_Newtest_random';
        columnSObject.Level__c = columnFirstSObject.Level__c;
        columnSObject.Position__c = columnFirstSObject.Position__c;
        columnSObject.Team__c = columnFirstSObject.Team__c;

        boolean dmlExceptionThrown = false;
        try{
        	insert columnSObject;
        }
        catch(System.DmlException dmlE){
        	dmlExceptionThrown = true;
	    	System.assert(dmlE.getMessage().contains('Column Level__c, Position__c combination should be unique per generation'), 'Expected DML Exception with column level and position combination not unique per generation error.');
        }
        System.assert(dmlExceptionThrown, 'Expected to throw dml exception by the column update call above');
     }
*/
     @isTest static void cannotInsertAColumnToHaveSameNameAsOtherColumnWithSameParent(){

		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;

        //pull the teams columns
        List<ADM_Column__c> columns = [select id, Name, Team__c, Parent_Column__c, Active__c, Position__c, Level__c from ADM_Column__c where Team__c =:team.id and Parent_Column__c = null order by Position__c desc];

        //colulmns with null parent and the highest position
        ADM_Column__c columnObject = columns[0];

        ADM_Column__c columnNewSObject = new ADM_Column__c();

        //try to make the new column sobject with same name as the existing column but +1 to the position
        columnNewSObject.Name = columnObject.Name;
        columnNewSObject.Level__c = columnObject.Level__c;
        columnNewSObject.Position__c = columnObject.Position__c+1;
        columnNewSObject.Team__c = columnObject.Team__c;

        boolean dmlExceptionThrown = false;
        try{
        	insert columnNewSObject;
        }
        catch(System.DmlException dmlE){
        	dmlExceptionThrown = true;
	    	System.assert(dmlE.getMessage().contains('Column Name must be unique per generation'), 'Expected DML Exception with column name not unique error.');
        }
        System.assert(dmlExceptionThrown, 'Expected to throw dml exception by the column update call above');
     }


	@isTest static void getKanbanClosedColumnsReturnsOnlyClosedColumns(){
		ADM_WorkStatus.createAllWorkStatuses();
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
     	String testScrumTeamId = team.Id;

		ADM_Column__c testClosedSObject = ADM_ColumnUtility.createColumn('Closed', null, 0, 4, testScrumTeamId);
		ADM_Column__c tesInProgressSObject = ADM_ColumnUtility.createColumn('In Progress', null, 0, 2, testScrumTeamId);

		List<ADM_Column__c> admTestColumnSObjects = new List<ADM_Column__c>();

		/* Adding columns to list in random order*/
        admTestColumnSObjects.add(testClosedSObject);
		admTestColumnSObjects.add(tesInProgressSObject);

		insert admTestColumnSObjects;

		List<ADM_Work_Status__c> workStatuses = [Select id, name from ADM_Work_Status__c where name in ('Closed', 'In Progress') and Type__c includes ('Bug') ]; //Getting closed and in progress status for type bug

		String closedWorkStatusId = '';
		String inProgressWorkStatusId = '';
		for(ADM_Work_Status__c workStatus: workStatuses){
			if(workStatus.Name == 'In Progress'){
				inProgressWorkStatusId = workStatus.Id;
			}
			if(workStatus.Name == 'Closed'){
				closedWorkStatusId = workStatus.Id;
			}
		}

		ADM_Column_Status_Assignment__c statusMappingForClose = new ADM_Column_Status_Assignment__c(Work_Status__c = closedWorkStatusId, column__c = testClosedSObject.Id);
		ADM_Column_Status_Assignment__c statusMappingForInProgress = new ADM_Column_Status_Assignment__c(Work_Status__c = inProgressWorkStatusId, column__c = tesInProgressSObject.Id);

		List<ADM_Column_Status_Assignment__c> columnStatusMappings = new List<ADM_Column_Status_Assignment__c>();
		columnStatusMappings.add(statusMappingForClose);
		columnStatusMappings.add(statusMappingForInProgress);

		insert columnStatusMappings;

		Set<String> closedColumnIds= ADM_ColumnUtility.getKanbanClosedColumns(testScrumTeamId);

		System.assertEquals(1, closedColumnIds.size(), 'Expected one closed column, but returned ' + closedColumnIds.size());
		List<String> closedColumnIdList = new List<String>(closedColumnIds);
		System.assertEquals(testClosedSObject.Id, closedColumnIdList[0], 'Expected one closed column, but returned ' + closedColumnIds.size());
		
		


	}
	
	

	
}