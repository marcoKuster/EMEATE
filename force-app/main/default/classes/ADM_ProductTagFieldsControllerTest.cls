@isTest
public class ADM_ProductTagFieldsControllerTest {
    
    @isTest
    public static void testGetWorkRecordNullThrowsException() {
    
        try {            
            ADM_ProductTagFieldsController.getWorkRecord(null);
            System.assert(false, 'This error should never be reached');
        } catch ( System.QueryException e ){
            // No-Op on pass
        }
        
    }

    @isTest    
    public static void testGetWorkRecordReturnsTheCorrectRecord() {
    
	ADM_Work__c test_story =  ADM_Work.setupTestWork('User Story');
        String subject = 'ControllerTest' + System.currentTimeMillis();
        test_story.Subject__c = subject;
        upsert test_story;
        
		List<ADM_Work__c> input_works = [SELECT Id,Subject__c FROM ADM_Work__c WHERE Subject__c =:subject];  
        ADM_Work__c work_input = (ADM_Work__c) input_works.get(0);
        
        String input_workId = (String) work_input.Id;
        
        ADM_Work__c return_work = ADM_ProductTagFieldsController.getWorkRecord(input_workId);
        
        System.assertEquals( work_input.Id, return_work.Id );
        
    }
    
    @isTest    
    public static void testProductTagFieldsUserStoryWithTwoAdditionalFields(){
    
	ADM_Work__c test_story =  ADM_Work.setupTestWork('User Story');
        String subject = 'ControllerTest' + System.currentTimeMillis();
        test_story.Subject__c = subject;
        upsert test_story;
    
    	List<ADM_Work__c> works = [SELECT Id,Subject__c,Product_Tag__c FROM ADM_Work__c WHERE Subject__c =:subject];  
        ADM_Work__c work = (ADM_Work__c) works.get(0);
        String workId = (String) work.Id;

        // First additional field
        Decimal d1 = 1.00;
		ADM_Additional_Field__c additionalField1 = new ADM_Additional_Field__c( 
					 Product_Tag__c=work.Product_Tag__c,
                                       	 Bug_Setting__c='visible',
                                         Investigation_Setting__c='visible',
					 User_Story_Setting__c='visible',
					 Order__c=d1,	
                                         Field_API_Name__c='Previous_Comments__c',
                                         Type__c='Text(100)'
                                       );         
        
        upsert additionalField1;

        // Second additional field
        Decimal d2 = 2.00;
		ADM_Additional_Field__c additionalField2 = new ADM_Additional_Field__c( 
					 Product_Tag__c=work.Product_Tag__c,
                                       	 Bug_Setting__c='visible',
                                         Investigation_Setting__c='visible',
					 User_Story_Setting__c='visible',
					 Order__c=d2,	
                                         Field_API_Name__c='UE_Engineer__c',
                                         Type__c='Text(100)'
                                       );         
        
        upsert additionalField2;

    	List<ADM_ProductTagFieldsController.ProductTagField> productTagFields = ADM_ProductTagFieldsController.getProductTagFields(workId);
		System.assertEquals(2, productTagFields.size());
    
    }
                
    @isTest    
    public static void testProductTagFieldsBugWithThreadAdditionalFields(){
    
	ADM_Work__c test_bug =  ADM_Work.setupTestWork('Bug');
        String subject = 'ControllerTest' + System.currentTimeMillis();
        test_bug.Subject__c = subject;
        upsert test_bug;
    
    	List<ADM_Work__c> works = [SELECT Id,Subject__c,Product_Tag__c FROM ADM_Work__c WHERE Subject__c =:subject];  
        ADM_Work__c work = (ADM_Work__c) works.get(0);
        String workId = (String) work.Id;

        // First additional field
        Decimal d1 = 1.00;
		ADM_Additional_Field__c additionalField1 = new ADM_Additional_Field__c( 
					Product_Tag__c=work.Product_Tag__c,
                                        Bug_Setting__c='visible',
                                        Investigation_Setting__c='visible',
					User_Story_Setting__c='visible',
					Order__c=d1,	
                                        Field_API_Name__c='Previous_Comments__c',
                                        Type__c='Text(100)'
                                       );         
        
        upsert additionalField1;

        // Second additional field
        Decimal d2 = 1.00;
		ADM_Additional_Field__c additionalField2 = new ADM_Additional_Field__c( 
            				Product_Tag__c=work.Product_Tag__c,
                                       	Bug_Setting__c='visible',
                                        Investigation_Setting__c='visible',
					User_Story_Setting__c='visible',
					Order__c=d2,	
                                        Field_API_Name__c='Resolution__c',
                                        Type__c='Text(100)'
                                       );         
        
        upsert additionalField2;
        
	// Third additional field
        Decimal d3 = 1.00;
		ADM_Additional_Field__c additionalField3 = new ADM_Additional_Field__c( 
					Product_Tag__c=work.Product_Tag__c,
                                       	Bug_Setting__c='visible',
                                        Investigation_Setting__c='visible',
					User_Story_Setting__c='visible',
					Order__c=d3,	
                                        Field_API_Name__c='CS_Contact__c',
                                        Type__c='Text(100)'
                                       );         
        
        upsert additionalField3;
        
    	List<ADM_ProductTagFieldsController.ProductTagField> productTagFields = ADM_ProductTagFieldsController.getProductTagFields(workId);
		System.assertEquals( 3, productTagFields.size());
    
    }
    
    
@isTest    
    public static void testProductTagFieldsInvestigationWithOneAdditionalField(){
    
	ADM_Work__c test_investigation =  ADM_Work.setupTestWork('Investigation');
        String subject = 'ControllerTest' + System.currentTimeMillis();
        test_investigation.Subject__c = subject;
        upsert test_investigation;
    
    	List<ADM_Work__c> works = [SELECT Id,Subject__c,Product_Tag__c FROM ADM_Work__c WHERE Subject__c =:subject];  
        ADM_Work__c work = (ADM_Work__c) works.get(0);
        String workId = (String) work.Id;

        // First additional field
        Decimal d1 = 1.00;
		ADM_Additional_Field__c additionalField = new ADM_Additional_Field__c( 
					Product_Tag__c=work.Product_Tag__c,
                                       	Bug_Setting__c='visible',
                                        Investigation_Setting__c='visible',
					User_Story_Setting__c='visible',
					Order__c=d1,	
                                        Field_API_Name__c='Previous_Comments__c',
                                        Type__c='Text(100)'
                                       );         
        
        upsert additionalField;

    	List<ADM_ProductTagFieldsController.ProductTagField> productTagFields = ADM_ProductTagFieldsController.getProductTagFields(workId);
		System.assertEquals(1 , productTagFields.size());
    
    }
    
}