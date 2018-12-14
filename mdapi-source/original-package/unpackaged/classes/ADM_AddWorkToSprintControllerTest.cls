@isTest
public class ADM_AddWorkToSprintControllerTest {

    
    /* 
	  @testcaseID a0B20000006aebaEAA
	  @hierarchy GUS.ScrumforceToGUS.Sprint.Detail page.Sprint Backlog
	  @userstory a0A20000007rUNO
	  @expectedResults: Ensure work items that are closed do not show on Add work to Sprint page
	*/    
   @isTest
   static void testSuiteAddWorkToSprint() {
        ADM_Work__c story = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_Product_Tag__c tag = [select id, Team__c from ADM_Product_Tag__c where id =:story.Product_Tag__c];
        tag.Team__c = sprint.Scrum_Team__c;
        update tag; 
        
        System.currentPageReference().getParameters().put('sprintID', sprint.id);
        story.Priority__c = 'P1';
        Test.startTest();
            insert story; 
        
            List<ADM_Work__c> works = new List<ADM_Work__c>();
    
            works.add(story);
    	
            ADM_AddWorkToSprintController controller = new ADM_AddWorkToSprintController();
            System.assert(controller != null);
            List<ADM_WorkWrapper> work = controller.getWork();
        	
        	//on page loads the default work list is displayed
        	System.assert(work != null);
        
        	//should be 1 works records in our original list.  Limited to testing with small size due to test method gov limits
        	System.assertEquals(1, work.size());
        	//verify on load that none of the works items are selected - the checked boolean meta data shows this
        	for(ADM_WorkWrapper ww : work) {
        		System.assertEquals(false, ww.checked);
        		System.assert(ww.work != null);
        		System.assert(ww.work.Subject__c != null);
        		System.assert(ww.work.Closed__c == 0);
        		System.assert(ww.work.Sprint__c != sprint.id);
        		System.assert(ww.work.Use_Prioritizer__c == true);
        		System.assert(ww.work.RecordType.Name != ADM_Work.TEMPLATE_RECORD_TYPE_NAME);
        		//check the box to select the work item for subsequent test
        		if(ww.work.id == story.id) ww.checked = true;
        	} 
        	//verify the sprint ID is in scope
        	System.assertEquals(sprint.id, controller.getSprintID());
        	
        	//select a work record to add to the sprint
        	controller.addToSprint();
        Test.stopTest();

    	//verify success message is returned
    	System.assert(ApexPages.getMessages() != null);
    	System.assertEquals('Work item(s) have been successfuly added to the sprint.', ApexPages.getMessages().get(0).getDetail());

    	//verify story was updated with sprint
    	System.assertEquals(sprint.id, [select Sprint__c from ADM_Work__c where id =:story.id].Sprint__c);
        	
    	//repeat but deliberately forget to select a work record and assert a nice error message is returned
    	for(ADM_WorkWrapper ww : controller.workList) {
    		 ww.checked = false;
    	} 

    	//attempt to add "nothing" to the sprint
    	controller.addToSprint();
    	//verify nice error message is returned
    	System.assert(ApexPages.getMessages() != null);
    	System.assertEquals('No Work item(s) have been selected.', ApexPages.getMessages().get(1).getDetail());
    } 
      
}