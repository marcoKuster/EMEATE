@isTest
public class ADM_PriorityMatrixHelpControllerTest {

    @isTest
    static void priorityMatrixTest() {        
       
        // Create a controller with a standard work item, not a bug, so there's no impact
        ApexPages.StandardController stdController = new ApexPages.StandardController(new ADM_Work__c());
		ADM_PriorityMatrixHelpController priorityController = new ADM_PriorityMatrixHelpController(stdController);
        System.assertEquals( 0 , priorityController.getImpacts().size());
        
        // Create a controller with a standard bug so there's an one impact
        ApexPages.StandardController stdControllerBug = new ApexPages.StandardController(ADM_Work.createTestBug());
		ADM_PriorityMatrixHelpController priorityControllerBug = new ADM_PriorityMatrixHelpController(stdController);        
		System.assertEquals( 1 , priorityControllerBug.getImpacts().size());
        
    }
}