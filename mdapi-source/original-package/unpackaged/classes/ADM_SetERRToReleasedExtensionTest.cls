/**
* Tests ADM_SetERRToReleasedExtension.
**/
@isTest
public class ADM_SetERRToReleasedExtensionTest {
	/*
     * @testcaseID TBD
     * @userStory W-3661313 
     * @hierarchy GUS.Releases page
     * @priority Medium
     * @author snahm     
     */
    static testMethod void testSetErrsToReleased() {

  		final String TEST_CHECKIN_DETAILS = '//checkin/here/.. with build test.123';
  		final String TEST_ADDITIONAL_INSTRUCTIONS = 'Call Release Manager for details';
		List<eRelease_Request__c> errs = new List<eRelease_Request__c>();
        
        ADM_Release__c testRelease = ADM_Release.createTestRelease();
     	ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Application__c app = ADM_Application.createTestApplication('TEST APPLICATION', 'TEST APPLICATION TYPE', false);
		
        // Create two ERRs for this release
        eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, null, null, null);
		err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;
		err.Checkin_Location__c = TEST_CHECKIN_DETAILS;
		err.Release_Team_Comments__c = TEST_ADDITIONAL_INSTRUCTIONS;
		err.Released_In__c = testRelease.Id;
     	Database.update(err);
        errs.add(err);        

		err = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, null, null, null);
		errs.add(err);        
		err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;
		err.Checkin_Location__c = TEST_CHECKIN_DETAILS;
		err.Release_Team_Comments__c = TEST_ADDITIONAL_INSTRUCTIONS;
		err.Released_In__c = testRelease.Id;
     	Database.update(err);
		errs.add(err);        
            
        // Test 1 -- Select one ERR and set to Released
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(errs);
        List<eRelease_Request__c> selectedErr = new List<eRelease_Request__c>();
        selectedErr.add(errs.get(0));
        setController.setSelected(selectedErr);
		ADM_SetERRToReleasedExtension extension = new ADM_SetERRToReleasedExtension(setController);
        System.Debug('testSetErrsToReleased: extension=' + extension);
        System.assert(ApexPages.getMessages().isEmpty(), 
        	'testSetErrsToReleased: Expected no page messages when one eRelease Request is selected.  Message is: ' + Apexpages.getMessages());

		PageReference pr = extension.setErrsToReleased(); 

        errs = [SELECT eRelease_Status__c FROM eRelease_Request__c WHERE Released_In__c =: testRelease.Id];
        System.assert(errs.size() == 2, 'testSetErrsToReleased: Wrong number of eRelease Requests found. Expected 2, but found ' + errs.size());
        
        System.assert((!errs[0].eRelease_Status__c.equals(errs[1].eRelease_Status__c)) && 
            errs[0].eRelease_Status__c.equals(ADM_eReleaseRequest.ERR_RELEASED) || errs[1].eRelease_Status__c.equals(ADM_eReleaseRequest.ERR_RELEASED),
            'testSetErrsToReleased: One eRelease Request should be set to RELEASED. errs=' + errs);
        
        // Test 2 -- Check message when no ERRs are selected
		setController = new ApexPages.StandardSetController(errs);
        System.Debug('testSetErrsToReleased: setController=' + setController);
        System.assert(setController != null, 'testSetErrsToReleased: Set controller for eRelease Request is null.');            
    	extension = new ADM_SetERRToReleasedExtension(setController);
        System.Debug('testSetErrsToReleased: extension=' + extension);
        System.assert(!ApexPages.getMessages().isEmpty(), 
            'testSetErrsToReleased: Expected a message to be added to page because there are no eRelease Requests selected.');
        
        pr = extension.setErrsToReleased();
        System.assert(pr == null, 
            'testSetErrsToReleased: setErrsToReleased() should return NULL when no eRelease Requests were selected, but it returned: ' + pr);
    }
}