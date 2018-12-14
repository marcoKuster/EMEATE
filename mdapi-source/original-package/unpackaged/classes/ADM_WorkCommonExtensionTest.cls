@IsTest
public with sharing class ADM_WorkCommonExtensionTest {

    private static String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
    
    public testMethod static void testNewProperties() {
        RecordType recordType = ADM_RecordType.getByName('Bug', 'ADM_Work__c');
        
        ADM_Work__c work = new ADM_Work__c();
        work.RecordTypeId = recordType.Id;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkCommonExtension ext = new ADM_WorkCommonExtension(stdController);
        String actualTitle = ext.getTitle();
        Boolean isNew = ext.getIsNew();
        Test.stopTest();
        
        System.assertEquals(recordType.Name, actualTitle, 'Expected the title to be record type name');
        System.assertEquals(true, isNew, 'Expected isNew to return true when the record is new');
    }

	/*
	@testcaseID 
	userstory 
	hierarchy 
	expected results 
	*/
    /**
     * When a RecordType name is given as a Parameter, the RecordType should be loaded and set on the work record and extension.
     */
    public testMethod static void testLoadRecordTypeFromRecordTypeLogicalNameParameter() {
    	ApexPages.currentPage().getParameters().put('RecordTypeLogicalName', 'Bug');
    	
    	ADM_Work__c work = new ADM_Work__c();
    	ApexPages.StandardController standardController = new Apexpages.StandardController(work);
    	ADM_WorkCommonExtension extension = new ADM_WorkCommonExtension(standardController);
    	
    	System.assert(extension.getRecordType() != null, 'Expected the RecordType property to be set on the extension');
    	System.assertEquals('Bug', extension.getRecordType().Name, 'Expected the RecordType property to be set to the type specified in the parameters');
        System.assert(extension.getSelectedWork().RecordType != null, 'Expected the RecordType to be set on the Work record');
        System.assertEquals('Bug', extension.getSelectedWork().RecordType.Name, 'Expected the RecordType property to be set to the type specified in the parameters');
    }

	/*
	@testcaseID 
	userstory 
	hierarchy 
	expected results 
	*/
    /**
     * When a RecordType name is given as a Parameter, the RecordType should be loaded and set on the work record and extension.
     */
    public testMethod static void testLoadRecordTypeFromRecordTypeNameParameter() {
        ApexPages.currentPage().getParameters().put('RecordTypeName', 'Bug');
        
        ADM_Work__c work = new ADM_Work__c();
        ApexPages.StandardController standardController = new Apexpages.StandardController(work);
        ADM_WorkCommonExtension extension = new ADM_WorkCommonExtension(standardController);
        
        System.assert(extension.getRecordType() != null, 'Expected the RecordType property to be set on the extension');
        System.assertEquals('Bug', extension.getRecordType().Name, 'Expected the RecordType property to be set to the type specified in the parameters');
        System.assert(extension.getSelectedWork().RecordType != null, 'Expected the RecordType to be set on the Work record');
        System.assertEquals('Bug', extension.getSelectedWork().RecordType.Name, 'Expected the RecordType property to be set to the type specified in the parameters');
    }

    /*
    @testcaseID 
    userstory 
    hierarchy 
    expected results 
   
     *   When editing a record or cloning a record (via 'clone' or 'create work from template' buttons) we need to load any fields 
     *   that  aren't automatically loaded by Visualforce. VisualForce only loads fields that are directly in the edit page as inputField 
     *   components so    fields that only indirectly use inputField (such as our custom ADM_Input component) need to be fetched from the 
     *   database.  The loadFields() method does not overwite existing values so any default values previously set will be retained 
     */

    public testMethod static void testCloneLoadFields() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        update work;
        
        ADM_Work__c original = [select id, RecordTypeId, Status__c, Found_In_Build__c, Scheduled_Build__c, Sprint__c, Product_Tag__c, Customer__c from ADM_Work__c where Id = :work.Id];
        
        
        //set the query parameters to 'clone'
        System.currentPageReference().getParameters().put('clone', '1');
        System.currentPageReference().getParameters().put('id', original.Id);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(original);
        ADM_WorkCommonExtension extension = new ADM_WorkCommonExtension(standardController);
        
        ADM_Work__c clonedWork = extension.getSelectedWork();
        System.assert(clonedWork.Status__c == 'New', 'Expected New status for cloned Work record'); 
        System.assertEquals(original.Found_In_Build__c, clonedWork.Found_in_Build__c);  
        System.assertEquals(original.Scheduled_Build__c, clonedWork.Scheduled_Build__c); 
        System.assertEquals(original.Sprint__c, clonedWork.Sprint__c); 
        System.assertEquals(original.Product_Tag__c, clonedWork.Product_Tag__c);
        System.assertEquals(original.Customer__c, clonedWork.Customer__c);

    }

	/*
	@testcaseID 
	userstory 
	hierarchy 
	expected results 
	*/    
    /**
     * When a RecordType is not specified, then an exception should be thrown
     */
    public testMethod static void testExceptionWhenRecordTypeIsNotSpecified() {
        ADM_Work__c work = new ADM_Work__c();
        ApexPages.StandardController standardController = new Apexpages.StandardController(work);
        
        try {
            ADM_WorkCommonExtension extension = new ADM_WorkCommonExtension(standardController);
            System.assert(false, 'Expected an exception to be thrown when the record type is not specified');
        } catch(Exception exc) {
        	System.assert(exc.getMessage().contains('RecordType must be specified'), 'Expected the exception to be about the record type not being specified: ' + exc.getMessage());
        }
    }

	/*
	@testcaseID 
	userstory 
	hierarchy 
	expected results 
	*/    
    /**
     * When cloning, the Parent_ID__c should be populated with the names of the parent work records
     */
    public testMethod static void testCloneParentChildRelationships() {
        //create work object and relate to serveral parents
        Id parentId = ADM_ParentWork.parentWorkTestSetupParents(2);
        ADM_Work__c original = [select id, RecordTypeId from ADM_Work__c where Id = :parentId];
        
        //set the query parameters to 'clone'
    	System.currentPageReference().getParameters().put('clone', '1');
    	System.currentPageReference().getParameters().put('id', original.Id);
    	
        ApexPages.StandardController standardController = new ApexPages.StandardController(original);
        ADM_WorkCommonExtension extension = new ADM_WorkCommonExtension(standardController);
        
        //verify that the hidden field Parent_ID__c is populated
        ADM_Work__c actualWork = extension.getSelectedWork();
        System.assert(actualWork.Parent_ID__c != null, 'Expected the Parent_ID__c field to be populated since we are cloning');
    }

	/*
	@testcaseID a1DB00000002r0J
	userstory a07B0000000VZ3Y
	hierarchy GUS.LightWorkPage.UserStory.SaveAndNew
	expected results Save and new button takes user to select record type
	*/
    /**
     * Test the doSaveAndNew method functionality
     */
    public testMethod static void testDoSaveAndNew() {
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController standardController = new Apexpages.StandardController(work);
        ADM_WorkCommonExtension extension = new ADM_WorkCommonExtension(standardController);
        PageReference pageReference = extension.doSaveAndNew();
        System.assert(pageReference != null, 'Expected doSaveAndNew to never return null');
        
        String qualifiedPageName = (nameSpacePrefix + 'ADM_SelectWorkRecordType').toLowerCase();   
        
        System.assert(pageReference.getUrl().containsIgnoreCase('/'+qualifiedPageName), 'Expected the page reference to go to the '+qualifiedPageName+' page: ' + pageReference.getUrl());
    
    }

    public testMethod static void testDoSaveAndDetail() {
        ADM_Work__c work = ADM_Work.createTestBug();
        String expectedURL = '/' + work.Id;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(work);
        ADM_WorkCommonExtension extension = new ADM_WorkCommonExtension(standardController);
        Pagereference pageref = extension.doSaveAndDetail();
        
        System.assert(pageref != null, 'Expected doSaveAndDetail to never return null');
        System.assertEquals(expectedURL, pageref.getUrl(), 'Expected the page to go to the detail page');
    }
    
    /**
     * Test clone will set Status to 'New'
     */
    public testMethod static void testCloneSetStatusFieldToNew() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        work.Status__c = 'In Progress';
        update work;
        
        ADM_Work__c original = [select id, RecordTypeId, Status__c from ADM_Work__c where Id = :work.Id];
        
        System.assert('In Progress' == original.Status__c, 'Expeced In Progress status for original work record');
        
        //set the query parameters to 'clone'
    	System.currentPageReference().getParameters().put('clone', '1');
    	System.currentPageReference().getParameters().put('id', original.Id);
    	
        ApexPages.StandardController standardController = new ApexPages.StandardController(original);
        ADM_WorkCommonExtension extension = new ADM_WorkCommonExtension(standardController);
        
        ADM_Work__c clonedWork = extension.getSelectedWork();
        System.assert(clonedWork.Status__c == 'New', 'Expected New status for cloned Work record');
    }
}