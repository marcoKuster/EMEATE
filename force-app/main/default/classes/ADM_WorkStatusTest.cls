@isTest
public with sharing class ADM_WorkStatusTest {
	@isTest
	public static void testCreateOrUpdateAllWorkStatusrecords(){
		List<ADM_Work_Status__c> workStatusItems = [Select id from ADM_Work_Status__c ];
		delete workStatusItems;
		workStatusItems = [Select id from ADM_Work_Status__c ];
		System.assertEquals(0,workStatusItems.size(),'Initiall all work statuses are deleted.');
		Set<String> allStatuses = new Set<String>();
		allStatuses.addAll(ADM_Work.STATUS_VALUES_INVESTIGATION);
		allStatuses.addAll(ADM_Work.STATUS_VALUES_BUG);
		allStatuses.addAll(ADM_Work.STATUS_VALUES_USERSTORY);
		Integer totalRecordsExpected = allStatuses.size();
		ADM_WorkStatus.createOrUpdateAllWorkStatusRecords();
		workStatusItems = [Select id, Name, Type__c, Order__c from ADM_Work_Status__c order by Order__c];
		System.assertEquals(totalRecordsExpected,workStatusItems.size(),'Expected the total number to be equal to sum of statuses for the 3 work record types');
		ADM_Work_Status__c newStatus = [Select id, Name, Type__c, Order__c from ADM_Work_Status__c where Name = 'New' limit 1];
		System.assert(newStatus.Type__c.contains('Bug'));
		System.assert(newStatus.Type__c.contains('User Story'));
		System.assert(newStatus.Type__c.contains('Investigation'));
	}
}