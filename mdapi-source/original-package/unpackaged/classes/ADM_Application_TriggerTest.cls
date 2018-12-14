/**
 *	Test that ADM_Application__c records cannot be created with duplicate names
 */
/*
 * Added tests in support of Release Event Templates
 *
 *    @testcaseID ADM_ReleaseTriggerTest
 *    @userstory W-2076536 https://gus.my.salesforce.com/a07B0000000dKy6 
 *    @author: snahm
 *
 */ 
@isTest
private class ADM_Application_TriggerTest {

	static final String TEST_APPLICATION_NAME = 'Test Application 123';
	static final String TEST_APPLICATION_TYPE = 'Testing Type';

/*
@testcaseID a1DB00000002xGB
@userstory a07B0000000cluE
@Hierarchy GUS.Application.Applications with duplicate names cannot be created
@Expected Results  An error that an Application with that same name has already been created is generated
 * @author snahm
 */
    static testMethod void createApplicationWithDuplicateNames() {

    	// Test 1: Create Application with identical name
        ADM_Application__c app1 = ADM_Application.createTestApplication(TEST_APPLICATION_NAME, TEST_APPLICATION_TYPE);
        //attempt to create a new app with the same name
        ADM_Application__c app2;
        try {
			app2 = ADM_Application.createTestApplication(TEST_APPLICATION_NAME, TEST_APPLICATION_TYPE);
            System.assert(false, 'createApplicationWithDuplicateNames: Test 1 should have thrown a DML exception before it reached here');
        } catch (System.Dmlexception e) {
            System.assertEquals(true, e.getMessage().contains('duplicates value on record with id:'), '->' + e.getMessage());
        }

        // Test 2: repeat with different case
        try {
            app2 = ADM_Application.createTestApplication(TEST_APPLICATION_NAME.toUpperCase(), TEST_APPLICATION_TYPE);
            System.assert(false, 'createApplicationWithDuplicateNames: Test 2 should have thrown a DML exception before it reached here');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().contains('duplicates value on record with id:'), e.getMessage());
        }

		final String TEST_APPLICATION_NOSPACE = 'MyTestApplicationName123';
		final String TEST_APPLICATION_SPACE   = 'My Test Application Name 123';
		
        // Test 3: repeat but set up two apps.  The original with no spaces and then attempt to insert a duplicate, identical except for white space
        ADM_Application__c appNoSpaces = ADM_Application.createTestApplication(TEST_APPLICATION_NOSPACE, TEST_APPLICATION_TYPE);
        try {
        	ADM_Application__c appWithSpaces = ADM_Application.createTestApplication(TEST_APPLICATION_SPACE, TEST_APPLICATION_TYPE);
            System.assert(false, 'createApplicationWithDuplicateNames: Test 3 should have thrown a DML exception before it reached here');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().contains('duplicates value on record with id:'), e.getMessage());
        }

        // Test 4: Test that updating an Application to an existing app name will not work
        try {
        	app1.Name = appNoSpaces.Name;
        	update(app1);
            System.assert(false, 'createApplicationWithDuplicateNames: Test 4 should have thrown a DML exception before it reached here');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().contains('duplicates value on record with id:'), e.getMessage());
        }
    }
    
/**
 * testBaseTemplateWhenNoneExist 
 * When an Application is created or updated, Base Release Event Templates will be 
 * created if no Base Release Event Templates already exist. 
 * 1) Create Application with no Base Release Events Templates 
 * 2) Check that a Base Release Event Template is created that covers all release 
 * types. 
 * 
 * @testcaseID a1DB0000000304g
 * @userStory W-2076536 
 * @hierarchy GUS.Releases page.Release Events 
 * @priority High 
 * @expectedResults Base Release Event Template is created when none already exists on 
 * Create or Update of an Application record. 
 * @author snahm
 */
    static testMethod void testBaseTemplateWhenNoneExist() {

        ADM_Application__c app1 = ADM_Application.createTestApplication(TEST_APPLICATION_NAME, TEST_APPLICATION_TYPE);

		// A Base Release Event Template should have been created
		List<ADM_Release_Event_Template__c> retList = [select Name, Base_Event__c, Notify_Customers__c, Day_Offset__c, Event_Duration__c,
			Event_Template_Name__c, Hour_Offset__c, Minute_Offset__c, Release_Type__c, Start_Time__c
			from ADM_Release_Event_Template__c where Application__c =: app1.Id];
		
		System.assert(retList.size() == 1, 
			'testBaseTemplateWhenNoneExist: Wrong number of Release Event Templates found after creation of Application. Expected 1 but got ' + retList.size());

		ADM_Release_Event_Template__c ret = retList[0];
		System.assert(ADM_ReleaseEventTemplate.isBaseEventTemplate(ret),
			'testBaseTemplateWhenNoneExist: Base offset values for Release Event Template created after creation of Application should all be zero but are not. Values are: Day_Offset__c=' + ret.Day_Offset__c + 
			' Event_Duration__c=' + ret.Event_Duration__c + ' Minute_Offset__c=' + ret.Minute_Offset__c + ' Hour_Offset__c=' + ret.Hour_Offset__c);

		Set<String> releaseTypeSet = new Set<String> {		// Check that the Base Event covers all release types
				ADM_ReleaseEventTemplate.RELEASE_TYPE_MAJOR,
				ADM_ReleaseEventTemplate.RELEASE_TYPE_PATCH,
				ADM_ReleaseEventTemplate.RELEASE_TYPE_ERELEASE,
				ADM_ReleaseEventTemplate.RELEASE_TYPE_OTHER 
		};
		for (String releaseType : releaseTypeSet) {
			if (ret.Release_Type__c != null && ret.Release_Type__c.contains(releaseType)) {
				releaseTypeSet.remove(releaseType);
			}
		}

		System.assert(releaseTypeSet.isEmpty(), 'testBaseTemplateWhenNoneExist: Created Base Event Template should cover all Release Types, but does not cover: '
			+ releaseTypeSet);

		// Delete the release event item and make sure it is recreated on update of the Application record
		
		Database.delete(ret);
		Database.update(app1);
		
		retList = [select Name, Base_Event__c, Notify_Customers__c, Day_Offset__c, Event_Duration__c,
			Event_Template_Name__c, Hour_Offset__c, Minute_Offset__c, Release_Type__c, Start_Time__c
			from ADM_Release_Event_Template__c where Application__c =: app1.Id];
		
		System.assert(retList.size() == 1, 
			'testBaseTemplateWhenNoneExist: Wrong number of Release Event Templates found after update of Application. Expected 1 but got ' + retList.size());

		ret = retList[0];
		System.assert(ADM_ReleaseEventTemplate.isBaseEventTemplate(ret),
			'testBaseTemplateWhenNoneExist: Base offset values for Release Event Template created after update of Application should all be zero but are not. Values are: Day_Offset__c=' + ret.Day_Offset__c + 
			' Event_Duration__c=' + ret.Event_Duration__c + ' Minute_Offset__c=' + ret.Minute_Offset__c + ' Hour_Offset__c=' + ret.Hour_Offset__c);
     
     
    }
    
 /**
  * testBaseTemplateForSomeReleaseTypes
  * If an Application has a Base Release Event Template for certain Release Types, but 
  * not for other Release Types, then a Base Release Event Template will be created for 
  * the other Release Types. 
  * 
  * @testcaseID a1DB0000000304h
  * @userStory W-2076536 
  * @hierarchy GUS.Releases page.Release Events 
  * @priority High 
  * @expectedResults A Base Release Event Template for the Release Types not already 
  * covered by an existing Release Event Template will be created for Application 
  * Create and Update.
  * @author snahm
  */
	static testMethod void testBaseTemplateForSomeReleaseTypes() {

        ADM_Application__c app1 = ADM_Application.createTestApplication(TEST_APPLICATION_NAME, TEST_APPLICATION_TYPE);
		ADM_Release_Event_Template__c retBase = [select Name, Base_Event__c, Notify_Customers__c, Day_Offset__c, Event_Duration__c,
			Event_Template_Name__c, Hour_Offset__c, Minute_Offset__c, Release_Type__c, Start_Time__c
			from ADM_Release_Event_Template__c where Application__c =: app1.Id];

		// Update the generated Base Release Event Template to cover just Patches
		retBase.Release_Type__c = ADM_ReleaseEventTemplate.RELEASE_TYPE_PATCH;
		Database.update(retBase);

		// Update Application to cause generation of Base Release Event Templates for the non-covered Release Types
		Database.update(app1);
		
		List<ADM_Release_Event_Template__c> retList = [select Name, Base_Event__c, Notify_Customers__c, Day_Offset__c, Event_Duration__c,
			Event_Template_Name__c, Hour_Offset__c, Minute_Offset__c, Release_Type__c, Start_Time__c
			from ADM_Release_Event_Template__c where Application__c =: app1.Id];

		// Should now have two Release Event Templates: one created when Application was created and now covering only Patch releases
		// and one created after recent update of Application, covering the other Release Types		
		System.assert(retList.size() == 2, 
			'testBaseTemplateForSomeReleaseTypes: Wrong number of Release Event Templates found after creation of Application. Expected 2 but got ' + retList.size());

		for (ADM_Release_Event_Template__c retB : retList) {
			// Both will be Base Release Event Templates
			System.assert(ADM_ReleaseEventTemplate.isBaseEventTemplate(retB),
				'testBaseTemplateForSomeReleaseTypes: Base offset values for Release Event Template created after creation of Application should ' +
				'all be zero but are not. Values are: Day_Offset__c=' + retB.Day_Offset__c + ' Event_Duration__c=' + retB.Event_Duration__c + 
				' Minute_Offset__c=' + retB.Minute_Offset__c + ' Hour_Offset__c=' + retB.Hour_Offset__c);
			if (!retB.Release_Type__c.contains(ADM_ReleaseEventTemplate.RELEASE_TYPE_PATCH)) {
				// Should cover all Release Types by Patch
				Set<String> releaseTypeSet = new Set<String> {
						ADM_ReleaseEventTemplate.RELEASE_TYPE_MAJOR,
						ADM_ReleaseEventTemplate.RELEASE_TYPE_ERELEASE,
						ADM_ReleaseEventTemplate.RELEASE_TYPE_OTHER 
				};
				for (String releaseType : releaseTypeSet) {
					if (retB.Release_Type__c != null && retB.Release_Type__c.contains(releaseType)) {
						releaseTypeSet.remove(releaseType);
					}
				}
		
				System.assert(releaseTypeSet.isEmpty(), 'testBaseTemplateForSomeReleaseTypes: Base Release Event Template should cover ' +
					'all Release Types except ' + ADM_ReleaseEventTemplate.RELEASE_TYPE_PATCH + ', but does not cover: ' + releaseTypeSet);
			}
		}
    }   
}