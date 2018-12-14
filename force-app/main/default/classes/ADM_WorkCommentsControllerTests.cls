@isTest
private class ADM_WorkCommentsControllerTests{

	static testMethod void testGetComments() {
        ADM_WorkCommentsController controller = new ADM_WorkCommentsController();
        ADM_Work__c work = ADM_Work.createTestBug();
        controller.work = work;
        work.Description__c = 'test';
        work.Preserve_Formatting__c = true;
        Test.startTest();
        update work;
        Test.stopTest();
        ADM_Comment__c[] comments = controller.getComments();
        ADM_Comment__c comment = comments[0];
        System.assertEquals(1, comments.size());
        System.assert(comment.Body__c.contains('test'));
        
	}

}