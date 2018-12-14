@isTest
private class ADM_CommonControllerExtensionTests {

    static testMethod void testDoSaveAndNew() {
        User testUser = ADM_WorkUser.createTestUser();
        String keyPrefix = testUser.getSobjectType().getDescribe().getKeyPrefix();
        String expectedURL = '/' + keyPrefix + '/e';
        
        ApexPages.StandardController controllerObj = new ApexPages.StandardController(testUser);
        ADM_CommonControllerExtension extension = new ADM_CommonControllerExtension(controllerObj);
        Pagereference pageref = extension.doSaveAndNew();
        
        System.assert(pageref != null, 'Expected doSaveAndNew to never return null');
        System.assertEquals(expectedURL, pageref.getUrl(), 'Expected the page to go to the new page');
    }

    static testMethod void testDoSaveAndEdit() {
        User testUser = ADM_WorkUser.createTestUser();
        String expectedURL = '/' + testUser.Id + '/e';
        
        ApexPages.StandardController controllerObj = new ApexPages.StandardController(testUser);
        ADM_CommonControllerExtension extension = new ADM_CommonControllerExtension(controllerObj);
        Pagereference pageref = extension.doSaveAndEdit();
        
        System.assert(pageref != null, 'Expected doSaveAndEdit to never return null');
        System.assertEquals(expectedURL, pageref.getUrl(), 'Expected the page to go to the edit page');
    }
    static testMethod void testDoSaveAndDetail() {
        User testUser = ADM_WorkUser.createTestUser();
        String expectedURL = '/' + testUser.Id;
        
        ApexPages.StandardController controllerObj = new ApexPages.StandardController(testUser);
        ADM_CommonControllerExtension extension = new ADM_CommonControllerExtension(controllerObj);
        Pagereference pageref = extension.doSaveAndDetail();
        
        System.assert(pageref != null, 'Expected doSaveAndDetail to never return null');
        System.assertEquals(expectedURL, pageref.getUrl(), 'Expected the page to go to the detail page');
    }
    static testMethod void testDoSaveAndDetailfromVirtualWall() {
        User testUser = ADM_WorkUser.createTestUser();        
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        String expectedURL = sprint.Id;
        ApexPages.StandardController controllerObj = new ApexPages.StandardController(testUser);
        ADM_CommonControllerExtension extension = new ADM_CommonControllerExtension(controllerObj);
        ApexPages.currentPage().getParameters().put('retURL', sprint.Id); 
        ApexPages.currentPage().getParameters().put('Sprint__c', sprint.Id);        
        
        Pagereference pageref = extension.doSaveAndDetail();             
       
        System.assert(pageref != null, 'Expected doSaveAndDetail to never return null');
        System.assertEquals(expectedURL, pageref.getUrl(), 'Expected the page to go to the detail page');
    }
    static testMethod void testDoSaveAndListView() {
        User testUser = ADM_WorkUser.createTestUser();
        String keyPrefix = testUser.getSobjectType().getDescribe().getKeyPrefix();
        String expectedURL = '/' + keyPrefix;
        
        ApexPages.StandardController controllerObj = new ApexPages.StandardController(testUser);
        ADM_CommonControllerExtension extension = new ADM_CommonControllerExtension(controllerObj);
        Pagereference pageref = extension.doSaveAndListView();
        
        System.assert(pageref != null, 'Expected doSaveAndListView to never return null');
        System.assertEquals(expectedURL, pageref.getUrl(), 'Expected the page to go to the list view page');
    }
}