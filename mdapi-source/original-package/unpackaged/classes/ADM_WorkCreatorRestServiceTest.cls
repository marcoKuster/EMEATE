@isTest
public class ADM_WorkCreatorRestServiceTest {

    @isTest
    public static void testUserStoryCreation(){
    
        String subject = 'Test-subject' + System.currentTimeMillis();
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('TestTeam');
    	ADM_Product_Tag__c productTagForTeam = ADM_ProductTag.createAndInsertProductTagForTeam(team);
    	String type = 'user story';
    
        ADM_WorkCreatorRestService.createWork(subject, productTagForTeam.Name, 
                                                     team.Name, type, null, null, null, null, null);
              
        List<ADM_Work__c> work_list = [ SELECT Id,Subject__c,Type__c from ADM_Work__c where Subject__c LIKE :subject ];
        System.assertEquals(1, work_list.size());
        System.assertEquals('User Story', work_list.get(0).Type__c);    
        
	}
    
    
    @isTest
    public static void testUserStoryCreationWithNullProductTag(){
    
        String subject = 'Test-subject' + System.currentTimeMillis();
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('TestTeam');
    	String type = 'user story';
    
        ADM_WorkCreatorRestService.Result result = ADM_WorkCreatorRestService.createWork(subject, 'bogus-product-tag', 
                                                     team.Name, type, null, null, null, null, null);
       	
        System.assertEquals( 1, result.getErrorMessages().size(), 'The error messages count was not one'); 
        System.assert( result.getErrorMessages().get(0).containsIgnoreCase('Cannot find a Product tag with name "bogus-product-tag"'), 
                      'The error message is not what was expected');
            
	}

    public static void testBugCreation(){
        
        String subject = 'Test-bug' + System.currentTimeMillis();
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('TestTeam');
    	ADM_Product_Tag__c productTagForTeam = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        String priority = 'p3';
        String type = 'bug';
    
        String test_build = 'ptest1.0' + System.currentTimeMillis();
        ADM_Build__c build = new ADM_Build__c();
        build.Name = test_build;
        build.External_ID__c = test_build;
        upsert build;
        
        ADM_WorkCreatorRestService.Result result = ADM_WorkCreatorRestService.createWork(subject, productTagForTeam.Name, 
                                                     team.Name, type, test_build, priority, null, null, null );
        
        RecordType bug_type = ADM_RecordType.getByName('Bug', 'ADM_Work__c');
        
		List<ADM_Work__c> work_list = [ SELECT Id,Subject__c,RecordTypeId from ADM_Work__c where Subject__c LIKE :subject ];
        System.assertEquals(1, work_list.size());
        System.assertEquals(bug_type.Id, work_list.get(0).RecordTypeId);    
        
	}
    
    @isTest
    public static void testBugCreationNoBuild(){
        
        String subject = 'Test-subject' + System.currentTimeMillis();
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('TestTeam');
    	ADM_Product_Tag__c productTagForTeam = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        String priority = 'p3';
        String type = 'bug';
		// Make a bogus found in build
        String found_in_build = 'bogus-data' +System.currentTimeMillis();
    
        ADM_WorkCreatorRestService.Result result = ADM_WorkCreatorRestService.createWork(subject, productTagForTeam.Name, 
                                                     team.Name, type, found_in_build, priority, null, null, null);
       	
        System.assertEquals( 1, result.getErrorMessages().size(), 'The error messages count was not one'); 
        System.assert( result.getErrorMessages().get(0).containsIgnoreCase('Cannot find build with name'), 
                      'The error message is not what was expected');
        
	}
}