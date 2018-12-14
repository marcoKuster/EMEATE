@isTest
private class ADM_ColumnTest {
	
	@isTest static void ADM_ColumnSortingTest() {
		
		String testScrumTeamId = ADM_ScrumTeam.createTestScrumTeam().Id;

		ADM_Column__c testADMColumn_Level0_Position0 = ADM_ColumnUtility.createColumn('Column00', null, 0, 0, testScrumTeamId);

		ADM_Column__c testADMColumn_Level0_Position1 = ADM_ColumnUtility.createColumn('Column01', null, 0, 1, testScrumTeamId);

		ADM_Column__c testADMColumn_Level1_Position0 = ADM_ColumnUtility.createColumn('Column10', null, 1, 0, testScrumTeamId);

		ADM_Column__c testADMColumn_Level1_Position1 = ADM_ColumnUtility.createColumn('Column11', null, 1, 1, testScrumTeamId);

		List<ADM_Column__c> admTestColumnSObjects = new List<ADM_Column__c>();

		//Adding to a list in different order - before sorting
		admTestColumnSObjects.add(testADMColumn_Level1_Position0);
		admTestColumnSObjects.add(testADMColumn_Level0_Position0);
		admTestColumnSObjects.add(testADMColumn_Level1_Position1);
		admTestColumnSObjects.add(testADMColumn_Level0_Position1);

		List<ADM_Column> admColumns = ADM_ColumnUtility.makeADM_ColumnListFromColumnSObjectList(admTestColumnSObjects);

		System.assertEquals('Column10',admColumns[0].getColumnName(),'Expected Column10 was added at index 0 toList admColumns');
		System.assertEquals('Column00',admColumns[1].getColumnName(),'Expected Column00 was added at index 1 toList admColumns');
		System.assertEquals('Column11',admColumns[2].getColumnName(),'Expected Column11 was added at index 2 toList admColumns');
		System.assertEquals('Column01',admColumns[3].getColumnName(),'Expected Column01 was added at index 3 toList admColumns');

		//Now sort list by calling sort method
		admColumns.sort();

		System.assertEquals('Column00',admColumns[0].getColumnName(),'Expected Column10 after sorting List admColumns');
		System.assertEquals('Column01',admColumns[1].getColumnName(),'Expected Column01 after sorting List admColumns');
		System.assertEquals('Column10',admColumns[2].getColumnName(),'Expected Column10 after sorting List admColumns');
		System.assertEquals('Column11',admColumns[3].getColumnName(),'Expected Column11 after sorting List admColumns');


	}


	@isTest static void ADM_ColumnSortingThrowsExceptionForNonEqualParents() {
		
		String testScrumTeamId = ADM_ScrumTeam.createTestScrumTeam().Id;

		ADM_Column__c columnNew = ADM_ColumnUtility.createColumn('New', null, 0, 0, testScrumTeamId);
		ADM_Column__c columnInProgress = ADM_ColumnUtility.createColumn('In Progress', null, 0, 1, testScrumTeamId);
		

		List<ADM_Column__c> admParentColumns = new List<ADM_Column__c>();
		admParentColumns.add(columnNew);
		admParentColumns.add(columnInProgress);

		insert admParentColumns;

		ADM_Column__c columnTriaged = ADM_ColumnUtility.createColumn('Triaged', admParentColumns[0].Id, 0, 1, testScrumTeamId);

		ADM_Column__c columnUIProgress = ADM_ColumnUtility.createColumn('UI In Progress', admParentColumns[1].Id, 0, 0, testScrumTeamId);

		ADM_Column__c columnCodeInProgress = ADM_ColumnUtility.createColumn('Code In Progress', admParentColumns[1].Id, 0, 1, testScrumTeamId);

		List<ADM_Column__c> admChildColumns = new List<ADM_Column__c>();
		
		admChildColumns.add(columnUIProgress);
		admChildColumns.add(columnCodeInProgress);
		insert admChildColumns;

		List<ADM_Column> admColumns = ADM_ColumnUtility.makeADM_ColumnListFromColumnSObjectList(admChildColumns);

		Boolean expThrown = false;
		try{
			admColumns.sort();
			expThrown = false;
		}
		catch(ADM_ObjectNotComparableException exp){
			expThrown = true;
		}

		System.assertEquals(false,expThrown,'No exception excepted as only sorting children of same parent ');

		insert columnTriaged;
		ADM_Column admColumn_Triaged = new ADM_Column(columnTriaged);
        //Now add a child of different parent and call sort mehtod
		admColumns.add(admColumn_Triaged);

		try{
			admColumns.sort();
			expThrown = false;
		}
		catch(ADM_ObjectNotComparableException exp){
			expThrown = true;
            // Confirm mesage is as expected 'Cannot compare Columns of different parents'
            System.assert(exp.message.contains('Cannot compare Columns of different parents'))  ;
		}

		System.assertEquals(true,expThrown,'Expected sort method on admChildren list to throw ADM_ObjectNotComparableException exception ');

	}
    
}