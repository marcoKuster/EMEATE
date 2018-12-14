@isTest
public with sharing class ADM_PlannerBacklogListControllerTests {

	static testMethod void testGetBacklogItems() {

		Test.startTest();

		// Create a list of test work items
		List<ADM_Work__c> workItems = ADM_Work.createListOfWork(4, ADM_Work.RECORD_TYPE_NAME_USERSTORY);

		integer rank = 1;

		// Make sure the backlog rank is set and use prioritizer flag is on
		for (ADM_Work__c item : workItems) {
			item.Priority_Rank__c = rank++;
			item.Use_Prioritizer__c = true;
		}

		// Insert the test records
		Database.SaveResult[] dsr = Database.insert(workItems, true);

		for (Database.SaveResult sr : dsr) {
			System.assert(sr.isSuccess(), 'Unexpected error writing test work: ' + sr.getErrors());
		}

		// Pull the scrum team ID from the inserted records -- safe to use first one
		// as the createListOfWork() method sets them all to the same scrum team
		List<ADM_Work__c> firstItem = [select Scrum_Team__c from ADM_Work__c where Id = :workItems.get(0).Id limit 1];
		Id scrumTeamId = firstItem.get(0).Scrum_Team__c;

		ADM_PlannerBacklogListController controller = new ADM_PlannerBacklogListController();
		controller.setScrumTeamId(scrumTeamId);

		List<ADM_Work__c> backlogItems = controller.getBacklogItems;

		Test.stopTest();

		System.assert(backlogItems.size() > 0, 'Expected backlogItems size to be > 0');

		System.assert(backlogItems.size() == workItems.size(), 'Expected workItems and backlogItems to have the same number of items');

		Set<Id> expectedIds = new Set<Id>();
		Set<Id> actualIds = new Set<Id>();

		// Create sets of the expected IDs and the actual Ids, and make sure the actual
		// set contains the expected set
		for (ADM_Work__c item : workItems) {
			expectedIds.add(item.Id);
		}

		for (ADM_Work__c item : backlogItems) {
			actualIds.add(item.Id);
		}

		System.assert(actualIds.containsAll(expectedIds));

	}
}