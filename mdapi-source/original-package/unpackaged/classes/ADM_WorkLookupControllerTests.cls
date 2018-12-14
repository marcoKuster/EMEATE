@isTest
public with sharing class ADM_WorkLookupControllerTests {
	
	public static testMethod void testMethodTestWorkLookup() {
		
		Test.startTest();
		List<ADM_Work__c> workList = ADM_Work.createListOfWork(3, 'Bug');
		insert workList;
		Test.stopTest();
		
		try {
		
			ADM_WorkLookupController wl = new ADM_WorkLookupController();
			wl.query = 'Test Work Record';
			wl.searchWork();
			//check results
			System.assert(wl.getMatchingWork() != null);
			List<ADM_Work__c> workSearch = [select id, Name, Subject__c, Priority__c, Assignee__r.Name, Scrum_Team__r.Name from ADM_Work__c where Subject__c LIKE :'%Test Work Record%' and Closed__c = 0 order by Subject__c limit 50];
			System.assert(wl.getMatchingWork().size() > 0, ' Work Search should have found:' + workSearch.size() + ' query:' + workList.get(0).Subject__c);
			//should find at least every record we created plus others in the org with similar name since wildcard search is performed
			System.assert(wl.getMatchingWork().size() >= workList.size(), 'Found unxpected number:' + wl.getMatchingWork().size() + ' expected at least to find the:' + workList.size() + ' the test created.');
			
		} catch (System.Exception e) {
			System.debug('Unexpected exception:' + e);
		}	
		
		
	}
	

}