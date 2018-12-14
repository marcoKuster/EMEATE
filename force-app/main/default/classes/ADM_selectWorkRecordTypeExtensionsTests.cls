/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition. 
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */


    /*
      @testcaseID a1DB00000000qYg
      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-868788
      @userstory a07B0000000EMVj
      @expectedResults:User should never be able to create templates from parent child relationships
      Author: Alexis Williams
    */
@isTest
private class ADM_selectWorkRecordTypeExtensionsTests {

    static testMethod void test_templatesAreNotAvailableFromParentOrChild() {
    	ADM_Work__c bug = ADM_Work.createTestWork();
        System.currentPageReference().getParameters().put('Child_ID__c', bug.Id);
        System.currentPageReference().getParameters().put('Parent_ID__c', bug.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(bug);
    	ADM_selectWorkRecordTypeExtensions a = new ADM_selectWorkRecordTypeExtensions(stdController);
    	for(RecordType rec : a.getRecordTypes()) {
    		System.assertNotEquals(true, rec.Name.equalsIgnoreCase('template'));
    	}
        
    }
  /*
 @testcaseID  
 @userstoryID 
 @Hierarchy 
 @ExpectedResults 
 */
    
    static testMethod void testADM_selectWorkRecordTypeExtensions() {
    	ADM_Work__c work = ADM_Work.createTestWork();
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    	ADM_selectWorkRecordTypeExtensions a = new ADM_selectWorkRecordTypeExtensions(stdController);
    	System.assert(a != null);    	
    }
  /*
 @testcaseID  
 @userstoryID 
 @Hierarchy 
 @ExpectedResults 
 */
    
    static testMethod void testGetRecordTypes() {
    	ADM_Work__c work = ADM_Work.createTestWork();
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    	ADM_selectWorkRecordTypeExtensions a = new ADM_selectWorkRecordTypeExtensions(stdController);
    	System.assert(a != null);
    	System.assert(a.getRecordTypes() != null);    	
    }
    
    /*
      @testcaseID a0B20000008ykDzEAI
      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-772699
      @userstory a07B0000000DZ3I
      @expectedResults: User is able to create parent/child records from a bug that contains special chars on subject

    */
    static testMethod void testGoToWorkEdit() {
    	ADM_Work__c work = ADM_Work.createTestWork();
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    	ADM_selectWorkRecordTypeExtensions a = new ADM_selectWorkRecordTypeExtensions(stdController);
    	List<RecordType> recs = ADM_RecordType.getAllBy('Name', new List<String>{ADM_Work.BUG_RECORD_TYPE_NAME});
    	a.setRecordType(recs[0].Id);   
    	System.assert(a != null);
    	System.assert(a.gotoWorkEdit() != null);
    	String testSubject = 'Lorrem Ipsum -+=?.,|}{%%&**ab[c]|^tt_(9)-@#<>';
    	a.params.put('Subject__c', testSubject );
    	System.assert(a.gotoWorkEdit().getParameters().get('Subject__c').equals( EncodingUtil.urlEncode( testSubject, 'UTF-8' ) ) );
    } 
    
    /*
      @testcaseID 
      @hierarchy 
      @userstory 
      @expectedResults:
    */

    static testMethod void testGetRecordTypeOptions() {
    	ADM_Work__c work = ADM_Work.createTestWork();
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    	ADM_selectWorkRecordTypeExtensions a = new ADM_selectWorkRecordTypeExtensions(stdController);
    	System.assert(a != null);
    	System.assert(a.getRecordTypeOptions() != null);
    	a.setRecordType('test'); 
    	System.assert(a.getRecordType() != null);   	
    }
}