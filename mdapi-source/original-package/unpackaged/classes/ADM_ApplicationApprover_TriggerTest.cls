/**
	@testcaseiD a1DB00000002naz
	@Expected results Appplications show on release page
	@Hierarchy GUS.Releases page.Automated Release Stamping
 *    @userstory W-1268579: Track application information and lifecycle with Application object
 *    @author snahm
 */
@isTest
private class ADM_ApplicationApprover_TriggerTest {

    static testMethod void testApplicationApproverTrigger() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        
        Profile p = null;
        try {
            p = [select id from profile where name='GUS Release Manager'];
        } catch (System.Exception e) {
            System.Debug('ApplicationApprover_TriggerTest: did not find GUS Release Manager profile. Will use System Administrator profile.');
        }
        if (p == null)                    // GUS RM profile doesn't exist in this org
            p = [select id from profile where name='System Administrator'];
        System.Debug('ID of GUS Rel Mgr profile: ' + p.id);

        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG OFF System.Debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        /*
         * Test 1: Create first Approver
         */
        ADM_Application_Approver__c aa1 = ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, 
        	ADM_ApplicationApprover.CONTEXT_INFORM, ADM_ApplicationApprover.TYPE_ERELEASES);
        /* DEBUG OFF System.Debug('aa1=' + aa1);  /* DEBUG */
        aa1 = [select Application__c, Approver__c, Approver_Email__c, Approval_Context__c, Approval_Type__c, Approver_Role__c
            from ADM_Application_Approver__c where id = :aa1.id limit 1][0];
        /* DEBUG OFF System.Debug('After creation of aa1, aa1=' + aa1);  /* DEBUG */
        
        System.Assert(aa1.Application__c == appl1.id, 'testApplicationApproverTrigger: Test 1 Approver\'s Application is wrong. Should be ' + 
            appl1.id + ' but instead is ' + aa1.Application__c);
        System.Assert(aa1.Approver__c == testUser[0].id, 'testApplicationApproverTrigger: Test 1 Approver\'s User is wrong. Should be ' + 
            testUser[0].id + ' but instead is ' + aa1.Approver__c);
        System.Assert(aa1.Approver_Email__c == testUser[0].email, 'testApplicationApproverTrigger: Test 1 Approver\'s User Email is wrong. Should be ' + 
            testUser[0].email + ' but instead is ' + aa1.Approver_Email__c);
        System.Assert(aa1.Approval_Context__c.equals('Inform Only'), 'testApplicationApproverTrigger: Test 1 Approver\'s Approval Context wrong. Should be ' + 
            'Inform Only' + ' but instead is ' + aa1.Approval_Context__c);
        System.Assert(aa1.Approval_Type__c.equals('eReleases'), 'testApplicationApproverTrigger: Test 1 Approver\'s Approval Context wrong. Should be ' + 
            'eReleases' + ' but instead is ' + aa1.Approval_Type__c);
            
        /*
         * Test 2: Insert second user, email is null to test auto-update of that field by trigger 
         */
        ADM_Application_Approver__c aa2 = ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], null,  
        	ADM_ApplicationApprover.CONTEXT_MUST, ADM_ApplicationApprover.TYPE_RELEASES);
        /* DEBUG OFF System.Debug('aa2=' + aa2);  /* DEBUG */

        aa2 = [select Approver_Email__c from ADM_Application_Approver__c
            where Id = :aa2.id limit 1][0];
        System.Assert(testUser[1].email.compareTo(aa2.Approver_Email__c) == 0, 'testApplicationApproverTrigger: Test 2 Approver email not set correctly. Expected: "'
            + testUser[1].email + '" but got: "' + aa2.Approver_Email__c + '"');                                           
    }
    
}