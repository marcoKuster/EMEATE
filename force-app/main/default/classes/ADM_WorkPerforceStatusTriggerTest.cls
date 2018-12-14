@isTest
public class ADM_WorkPerforceStatusTriggerTest {
	//================================================RUN beginning TESTS==================================\\

	static testMethod void testTrigger() {
		ADM_Work__c w = ADM_Work.createTestWork();
		
	
		w.Perforce_Status__c = 'Requested';
		Database.update(w);
	}

	static testMethod void testCommentsTrigger() {
		ADM_Work__c work = ADM_Work.createTestWork();
		ADM_Comment__c c = new ADM_Comment__c ( Body__c = 'just chillin out havin a bud', Work__c = work.id );

		insert c;
	}

	//================================================RUN ending TESTS==================================\\
}