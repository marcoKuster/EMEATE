@isTest
public class ADM_ErrorBlockControllerTest {

    @isTest   
    static void testGetErrorMessages() {
        ADM_Work__c work = new ADM_Work__c();
        work.addError('test');
        
        ADM_ErrorBlockController controller = new ADM_ErrorBlockController();
        
        System.assertEquals(1, controller.getErrorMessages().size(), 'Expected there to be 1 error message since only one error message was added');
        System.assertEquals('test', controller.getErrorMessages()[0], 'Expected the error message to be the error message entered.');
    }

    @isTest    
    static void testGetErrorMessagesAsJSON() {
        ADM_Work__c work = new ADM_Work__c();
        work.addError('test');
        
        ADM_ErrorBlockController controller = new ADM_ErrorBlockController();
        
        System.assertEquals(1, controller.getErrorMessages().size(), 'Expected there to be 1 error message since only one error message was added');
        System.assertEquals('["test"]', controller.getErrorMessagesAsJSON(), 'Expected the error message to be the error message entered.');
    }

}