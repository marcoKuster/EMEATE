@IsTest
public class ADM_BugControllerGlobalActionTest {
	public testMethod static void testBugControllerGlobalAction() {
        ADM_BugControllerGlobalAction controller = new ADM_BugControllerGlobalAction();
        
        System.assertEquals('Bug', controller.getRecordType().Name, 'Record type should be of type Bug');
        System.assertEquals('Bug', controller.work.Type__c, 'Record type should be of type Bug');
    }
}