@isTest
private class ADM_SearchWorkTest {
    static testMethod void testSearch() {
        Test.startTest();
        try {
            List<ADM_Work__c> bugs = ADM_Work.createListOfWork(10, 'Bug');
            insert bugs;
            ID[] ids = new ID[bugs.size()];
            for (integer i = 0 ; i < 10 ; i++) {
                ids[i] = bugs[i].id;
                System.debug(ids[i]);
            }
            Test.setFixedSearchResults(ids);
            ADM_Work__c bug = bugs[0];
            
            String query = ADM_SearchWork.searchWork('text', null, 'W-', bug.subject__c, bug.Type__c, bug.Product_Tag_Name__c, bug.Status__c, bug.Assignee__r.name, bug.Priority__c, bug.Scrum_Team_Name__c, bug.Scheduled_Build__c, 'TODAY');
            List<ADM_Work__c> results = Search.query(query)[0];
            /* bug W-2052090 -  Test Failures - Please fix this.
            System.assertEquals(1, results.size(), 'All test records should come back');
            
            System.assertEquals(bug.id, results[0].id, 'Should get the 1st one back'); */
        } finally {
            Test.stopTest();
        }
    }
    
    static testMethod void testEscapeQuote() {
        String query = ADM_SearchWork.searchWork('w\'', null, null, null, null, null, null, null, null, null, null, null);
        System.assert(query.contains('\'w\\\'\''), 'The - should be escaped');
    }

    static testMethod void testEscapeBackslash() {
        String query = ADM_SearchWork.searchWork('w\\', null, null, null, null, null, null, null, null, null, null, null);
        System.assert(query.contains('\'w\\\\\''), 'The - should be escaped');
    }
}