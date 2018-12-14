public with sharing class ADM_RichAutoCompleteControllerTest {
	 
    public testMethod static void testControllerInit() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	User assignee = [select Name, SmallPhotoUrl from User where Id = :work.Assignee__c];
    	
        ADM_RichAutoCompleteController controller = new ADM_RichAutoCompleteController();
        controller.currentField = 'Assignee__c';
        controller.currentSObject = work;
        
        System.assertEquals(assignee.SmallPhotoUrl, controller.profileImageUrl);
        System.assertEquals(assignee.Name, controller.name);
    }

    /*  
	  @testcaseID a1DB00000002gfnMAA

	  @hierarchy GUS.NextGenWorkPage.Bug Detail Page

	  @userstory a07B0000000VZ35IAG

	  @expectedResults: The list of items that should be present with autocomplete. 
	  
	  @author sgovindan

	*/
    public testMethod static void testUsersWithNameLike() {
        
        User user = ADM_WorkUser.createTestUserWithRandomName();
        user = [select Id, Name from User where Id = :user.Id];
        
        Map<String, Object> results = ADM_RichAutoCompleteController.getUsersWithNameLike(user.Name);
        
        System.assert(results.containsKey('results'), 'Expected results to contain the results key');
        
        List<User> users = (List<User>)results.get('results');
        System.assertEquals(1, users.size(), 'Expected results to contain the test user');
        
    }
    
}