@isTest
public class ADM_WorkDeepCloneRedirectControllerTest {

    static testMethod void testWorkDeepCloneController() {
    
	String temp_id = String.valueOf(System.currentTimeMillis());
	System.currentPageReference().getParameters().put('id', temp_id);

	ADM_WorkDeepCloneRedirectController wdcrc = new ADM_WorkDeepCloneRedirectController();

	System.assertEquals( temp_id, wdcrc.recordId );        
        
        
   }
}