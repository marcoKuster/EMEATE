/**
 *    @userstory W-1224650: eRelease Request process takes up too many workflows
 *    @author snahm
 */

 public with sharing class ADM_ApplicationApproverTests {

    static final Set<String> mayContext = new Set<String> {
    		ADM_ApplicationApprover.CONTEXT_MAY
    	};
    static final Set<String> mustContext = new Set<String> {
    		ADM_ApplicationApprover.CONTEXT_MUST
    	};    	

	/**
 	* Select all type, role and context.
 	* Given an Application with a list of multiple Application Approver records, 
 	* ensure that all records are returned when all filters are set to NULL.
 	* testcaseID a1DB00000002tB6
 	* @userStory W-1224650
 	* @hierarchy GUS.Application Approver.approverUsers
 	* @priority Medium
 	* @expectedResults A set of users that matches all users on the provided 
 	* Application's Application Approver list.
 	* @author snahm
 	*/
	static testMethod void testApproverUsersNullFilter() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);
        /* DEBUG ON */ System.debug('testApproverUsersNullFilter: userMap=' + userMap); /* DEBUG */
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_ERELEASES));
        /* DEBUG OFF System.debug('aaList[0]=' + aaList[0]);  /* DEBUG */
        /* aaList[0] = [select Application__c, Approver__c, Approver_Email__c, Approval_Context__c, Approval_Type__c, Approver_Role__c
            from ADM_Application_Approver__c where id = :aaList[0].id limit 1][0];
        /* DEBUG OFF System.debug('After insert of aaList[0], aaList[0]=' + aaList[0]);  /* DEBUG */
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_RELEASES));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_ERELEASES));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES));

		Set<User> filteredAAUsers = ADM_ApplicationApprover.approverUsers(aaList, userMap,  null, null, null);

		System.assert(filteredAAUsers.size() == userMap.size(), 'testApproverUsersNullFilter: Size of returned filtered Users Set is wrong. Should be ' + 
            userMap.size() + ' but instead is ' + filteredAAUsers.size());
            
        System.assert(filteredAAUsers.containsAll(userMap.values()), 
        	'testApproverUsersNullFilter: The Set of returned filtered Users does not match the list of Users expected. Users should be ' +  
            userMap.values() + ' but instead is ' + filteredAAUsers);
	}


	/**
	 * Select eRelease type only.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers, ensure that only the records 
	 * that are eRelease records are returned.
	 * testcaseID a1DB00000002tBB
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverUsers
	 * @priority Medium
	 * @expectedResults A list of users that matches the users on the provided 
	 * Application's Application Approver list with type eRelease.
	 */
 	static testMethod void testApproverUsersTypeERR() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<User> expectedUsers = new List<User>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));
        expectedUsers.add(testUser[0]);	// First match        
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedUsers.add(testUser[2]);	// Second match        
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_DEV));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_RM));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'test@salesforce.com', ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
                
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedUsers=' + expectedUsers);  /* DEBUG */

		Set<User> filteredAAUsers = ADM_ApplicationApprover.approverUsers(aaList, userMap, ADM_ApplicationApprover.TYPE_ERELEASES, null, null);
        /* DEBUG ON */ System.debug('filteredAAUsers=' + filteredAAUsers);  /* DEBUG */

		System.assert(filteredAAUsers.size() == expectedUsers.size(), 
			'testApproverUsersTypeERR: Size of returned filtered Emails Set is wrong. Should be ' + expectedUsers.size() + ' but instead is ' + filteredAAUsers.size());
			
        System.assert(filteredAAUsers.containsAll(expectedUsers), 
        	'testApproverUsersTypeERR: The Set of returned filtered Emails does not match the list of expected Users. Expected Users should be ' +  
            expectedUsers + ' but instead is ' + filteredAAUsers);  
	}
	 /**
	 * Select Release type and QE role.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers and a mix of QE and non-QE role 
	 * approvers, ensure that only the records that are type Release with a Role QE 
	 * are returned.
	 * testcaseID  a1DB00000002tBG
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverUsers
	 * @priority Medium
	 * @expectedResults A list of users that matches the users on the provided 
	 * Application's Application Approver list with type Release and role QE.
	 */
 
  	static testMethod void testApproverUsersTypeRole() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<User> expectedUsers = new List<User>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_QE));
        expectedUsers.add(testUser[0]);	// First match        
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_RM));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV)); 
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_QE));	// Matches filter below, but not a User
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'test@salesforce.com', ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
                
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedUsers=' + expectedUsers);  /* DEBUG */

		Set<User> filteredAAUsers = ADM_ApplicationApprover.approverUsers(aaList, userMap, ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_QE, null);
        /* DEBUG ON */ System.debug('filteredAAUsers=' + filteredAAUsers);  /* DEBUG */

		System.assert(filteredAAUsers.size() == expectedUsers.size(), 
			'testApproverUsersTypeRole: Size of returned filtered Emails Set is wrong. Should be ' + expectedUsers.size() + ' but instead is ' + filteredAAUsers.size());
			
        System.assert(filteredAAUsers.containsAll(expectedUsers), 
        	'testApproverUsersTypeRole: The Set of returned filtered Emails does not match the list of expected Users. Expected Users should be ' +  
            expectedUsers + ' but instead is ' + filteredAAUsers);  
	}
 
	 /**
	 * Select eRelease type, DevMgr role and Must Approve context.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers and a mix of QE and non-QE role 
	 * approvers and a mix of different context approvers, ensure that only the 
	 * records that are type eRelease with a Role DevMgr and context Must Approve are 
	 * returned.
	 * testcaseID a1DB00000002tBL
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverUsers
	 * @priority Medium
	 * @expectedResults A list of users that matches the users on the provided 
	 * Application's Application Approver list with type eRelease, role DevMgr, and 
	 * context "Must Approve".
	 */
 	static testMethod void testApproverUsersTypeRoleContext() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<User> expectedUsers = new List<User>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedUsers.add(testUser[1]);	// First match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_DEV));
        expectedUsers.add(testUser[2]);	// Second match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_RM));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'test@salesforce.com', ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedUsers=' + expectedUsers);  /* DEBUG */

		Set<User> filteredAAUsers = ADM_ApplicationApprover.approverUsers(aaList, userMap, ADM_ApplicationApprover.TYPE_RELEASES, 
			ADM_ApplicationApprover.ROLE_DEV, mustContext);
        /* DEBUG ON */ System.debug('filteredAAUsers=' + filteredAAUsers);  /* DEBUG */

		System.assert(filteredAAUsers.size() == expectedUsers.size(), 
			'testApproverUsersTypeRoleContext: Size of returned filtered Emails Set is wrong. Should be ' + expectedUsers.size() + ' but instead is ' + filteredAAUsers.size());
			
        System.assert(filteredAAUsers.containsAll(expectedUsers), 
        	'testApproverUsersTypeRoleContext: The Set of returned filtered Emails does not match the list of expected Emails. Expected Emails should be ' +  
            expectedUsers + ' but instead is ' + filteredAAUsers);
 	}
 	
	 /**
	 * Select filters that return no users.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers and a mix of QE and non-QE role 
	 * approvers and a mix of different context approvers, use a filter that does not 
	 * match any of the users in the list and ensure that an empty list is returned.
	 * testcaseID a1DB00000002tBQ
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverUsers
	 * @priority Low
	 * @expectedResults An empty list of users.
	 */

	static testMethod void testApproverUsersNoMatch() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);
        /* DEBUG ON */ System.debug('testApproverUsersNullFilter: userMap=' + userMap); /* DEBUG */
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_RM));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_RM));
        	
		Set<User> filteredAAUsers = ADM_ApplicationApprover.approverUsers(aaList, userMap,  ADM_ApplicationApprover.TYPE_RELEASES, 
			ADM_ApplicationApprover.ROLE_RM, mayContext);

		System.assert(filteredAAUsers.size() == 0, 'testApproverUsersNoMatch: Size of returned filtered Users Set is wrong. Should be ' + 
             'zero but instead is ' + filteredAAUsers.size());
	}
	/**
	 * Select ADM_ApplicationApprover.TYPE_BOTH.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers, ensure that only the records 
	 * that are eRelease records are returned.
	 * testcaseID a1DB00000002tBM
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverUsers
	 * @priority Medium
	 * @expectedResults A list of users that matches the users on the provided 
	 * Application's Application Approver list with type eRelease.
	 */
 	static testMethod void testApproverUsersTypeBoth() {

        Set<Id>userSet = new Set<Id>();
		List<User> expectedUsers = new List<User>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */

		ADM_ApplicationApprover.createTestApplicationApprovers(appl1);

        List<ADM_Application_Approver__c> aaList = [select Application__c, Approver__c, Approver_Email__c, Approval_Context__c, Approval_Type__c, Approver_Role__c
            from ADM_Application_Approver__c where id = :appl1.id];
            
        for (ADM_Application_Approver__c aa : aaList) {
        	if (aa.Approver__c != null) {
        		userSet.add(aa.Approver__c);  
        	}
        }
        Map<Id, User>userMap = new Map<Id, User>([select Id,Name,Email from User where id =: userSet ]);

        /* DEBUG ON */ System.debug('testApproverUsersTypeBoth: Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('testApproverUsersTypeBoth: expectedUsers=' + expectedUsers);  /* DEBUG */
    	
		Set<User> filteredAAUsers = ADM_ApplicationApprover.approverUsers(aaList, userMap, ADM_ApplicationApprover.TYPE_BOTH, null, mayContext);
        /* DEBUG ON */ System.debug('testApproverUsersTypeBoth: filteredAAUsers=' + filteredAAUsers);  /* DEBUG */

		System.assert(filteredAAUsers.size() == userSet.size(), 
			'testApproverUsersTypeBoth: Size of returned filtered Emails Set is wrong. Should be ' + userSet.size() + ' but instead is ' + filteredAAUsers.size());
			
        System.assert(filteredAAUsers.containsAll(userMap.values()), 
        	'testApproverUsersTypeBoth: The Set of returned filtered Emails does not match the list of expected Users. Expected Users should be ' +  
            userMap.values() + ' but instead is ' + filteredAAUsers);  
	}
	/**
	 * Select all type, role and context.
	 * Given an Application with a list of multiple Application Approver records, 
	 * ensure that all records are returned when all filters are set to NULL.
	 * testcaseID a1DB00000002tBV
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverEmails
	 * @priority Medium
	 * @expectedResults A set of emails that matches all users on the provided 
	 * Application's Application Approver list.
	 */
	static testMethod void testApproverEmailsNullFilter() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<String> expectedEmails = new List<String>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));
        expectedEmails.add(aaList[0].Approver_Email__c);	// First match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[1].Approver_Email__c);	// Second match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[2].Approver_Email__c);	// Third match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[3].Approver_Email__c);	// Fourth match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'test@salesforce.com', ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[4].Approver_Email__c);	// Fifth match
                
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedEmail=' + expectedEmails);  /* DEBUG */

		Set<String> filteredAAEmails = ADM_ApplicationApprover.approverEmails(aaList, userMap, NULL, NULL, NULL);
        /* DEBUG ON */ System.debug('filteredAAEmails=' + filteredAAEmails);  /* DEBUG */

		System.assert(filteredAAEmails.size() == expectedEmails.size(), 
			'testApproverEmailsNullFilter: Size of returned filtered Emails Set is wrong. Should be ' + expectedEmails.size() + ' but instead is ' + filteredAAEmails.size());
			
        System.assert(filteredAAEmails.containsAll(expectedEmails), 
        	'testApproverEmailsNullFilter: The Set of returned filtered Emails does not match the list of expected Emails. Expected Emails should be ' +  
            expectedEmails + ' but instead is ' + filteredAAEmails);    
	}		 
	 

	/**
	 * Select eRelease type only.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers, ensure that only the email 
	 * records that are for eRelease type are returned.
	 * testcaseID a1DB00000002tBa
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverEmails
	 * @priority Medium
	 * @expectedResults A set of emails that matches the approvers on the provided 
	 * Application's Application Approver list with type eRelease.
	 */
	static testMethod void testApproverEmailsTypeERR() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<String> expectedEmails = new List<String>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));
        expectedEmails.add(aaList[0].Approver_Email__c);	// First match        
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[2].Approver_Email__c);	// Second match        
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[3].Approver_Email__c);	// Third match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_RM));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'test@salesforce.com', ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[5].Approver_Email__c);	// Fourth match
                
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedEmail=' + expectedEmails);  /* DEBUG */

		Set<String> filteredAAEmails = ADM_ApplicationApprover.approverEmails(aaList, userMap, ADM_ApplicationApprover.TYPE_ERELEASES, null, null);
        /* DEBUG ON */ System.debug('filteredAAEmails=' + filteredAAEmails);  /* DEBUG */

		System.assert(filteredAAEmails.size() == expectedEmails.size(), 
			'testApproverEmailsTypeERR: Size of returned filtered Emails Set is wrong. Should be ' + expectedEmails.size() + ' but instead is ' + filteredAAEmails.size());
			
        System.assert(filteredAAEmails.containsAll(expectedEmails), 
        	'testApproverEmailsTypeERR: The Set of returned filtered Emails does not match the list of expected Emails. Expected Emails should be ' +  
            expectedEmails + ' but instead is ' + filteredAAEmails);  
	}		 

	/**
	 * Select Release type and QE role.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers and a mix of QE and non-QE role 
	 * approvers, ensure that only the emails for records that are type Release with a 
	 * Role QE are returned.
	 * testcaseID a1DB00000002tBf
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverEmails
	 * @priority Medium
	 * @expectedResults A set of emails that matches the users on the provided 
	 * Application's Application Approver list with type Release and role QE.
	 */
	static testMethod void testApproverEmailsTypeRole() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<String> expectedEmails = new List<String>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_QE));
        expectedEmails.add(aaList[1].Approver_Email__c);	// First match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_QE));
        expectedEmails.add(aaList[2].Approver_Email__c);	// Second match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_RM));
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedEmail=' + expectedEmails);  /* DEBUG */

		Set<String> filteredAAEmails = ADM_ApplicationApprover.approverEmails(aaList, userMap, ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_QE, null);

		System.assert(filteredAAEmails.size() == expectedEmails.size(), 
			'testApproverEmailsTypeRole: Size of returned filtered Emails Set is wrong. Should be ' + expectedEmails.size() + ' but instead is ' + filteredAAEmails.size());
			
        System.assert(filteredAAEmails.containsAll(expectedEmails), 
        	'testApproverEmailsTypeRole: The Set of returned filtered Emails does not match the list of expected Emails. Expected Emails should be ' +  
            expectedEmails + ' but instead is ' + filteredAAEmails);
            
	}		 

	/**
	 * Select eRelease type, DevMgr role and Must Approve context.
	 * Given an Application with a list of multiple Application Approver records which 
	 *  is a mix of eRelease and Release type approvers and a mix of QE and non-QE 
	 * role approvers and a mix of different context approvers, ensure that only the 
	 * emails for records that are type eRelease with a Role DevMgr and context Must 
	 * Approve are returned.
	 * testcaseID a1DB00000002tBk
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverEmails
	 * @priority Medium
	 * @expectedResults A set of emails that matches the approvers on the provided 
	 * Application's Application Approver list with type eRelease, role DevMgr, and 
	 * context "Must Approve".
	 */
	static testMethod void testApproverEmailsTypeRoleContext() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<String> expectedEmails = new List<String>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[1].Approver_Email__c);	// First match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[3].Approver_Email__c);	// Second match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_RM));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'test@salesforce.com', ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedEmail=' + expectedEmails);  /* DEBUG */

		Set<String> filteredAAEmails = ADM_ApplicationApprover.approverEmails(aaList, userMap, ADM_ApplicationApprover.TYPE_RELEASES, 
			ADM_ApplicationApprover.ROLE_DEV, mustContext);
        /* DEBUG ON */ System.debug('filteredAAEmails=' + filteredAAEmails);  /* DEBUG */

		System.assert(filteredAAEmails.size() == expectedEmails.size(), 
			'testApproverEmailsTypeRoleContext: Size of returned filtered Emails Set is wrong. Should be ' + expectedEmails.size() + ' but instead is ' + filteredAAEmails.size());
			
        System.assert(filteredAAEmails.containsAll(expectedEmails), 
        	'testApproverEmailsTypeRoleContext: The Set of returned filtered Emails does not match the list of expected Emails. Expected Emails should be ' +  
            expectedEmails + ' but instead is ' + filteredAAEmails);
            
	}		 

	/**
	 * Select filters that return no users.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers and a mix of QE and non-QE role 
	 * approvers and a mix of different context approvers, use a filter that does not 
	 * match any of the approvers in the list and ensure that an empty set is returned.
	 * testcaseID a1DB00000002tBp
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverEmails
	 * @priority Low
	 * @expectedResults An empty set of emails.
	 */
	
	static testMethod void testApproverEmailsNullResults() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_ERELEASES));
        /* DEBUG OFF System.debug('aaList[0]=' + aaList[0]);  /* DEBUG */
        /* aaList[0] = [select Application__c, Approver__c, Approver_Email__c, Approval_Context__c, Approval_Type__c, Approver_Role__c
            from ADM_Application_Approver__c where id = :aaList[0].id limit 1][0];
        /* DEBUG OFF System.debug('After insert of aaList[0], aaList[0]=' + aaList[0]);  /* DEBUG */
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MAY,
        	ADM_ApplicationApprover.TYPE_RELEASES));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_ERELEASES));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES));

		Set<String> filteredAAEmails = ADM_ApplicationApprover.approverEmails(aaList, userMap,  ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_RM, 
			mayContext);

		System.assert(filteredAAEmails.size() == 0, 
			'testApproverEmailsNullResults: Size of returned filtered Emails Set is wrong. Should be zero but instead is ' + filteredAAEmails.size());			
            
	}
	
	/**
	 * Select ADM_ApplicationApprover.TYPE_BOTH.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of eRelease and Release type approvers, request that ADM_ApplicationApprover.TYPE_BOTH is returned.
	 * testcaseID a1DB00000002tBu
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverEmails
	 * @priority Medium
	 * @expectedResults A set of emails that matches the approvers on the provided 
	 * Application's Application Approver list with both eRelease and Release type.
	 */
	static testMethod void testApproverEmailsTypeBoth() {

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<String> expectedEmails = new List<String>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));
        expectedEmails.add(aaList[0].Approver_Email__c);	// First match        
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[1].Approver_Email__c);	// Second match        
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[3].Approver_Email__c);	// Third match
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_RM));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'test@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_TECHOPS));
        expectedEmails.add(aaList[5].Approver_Email__c);	// Fourth match
                
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedEmail=' + expectedEmails);  /* DEBUG */

		Set<String> filteredAAEmails = ADM_ApplicationApprover.approverEmails(aaList, userMap, ADM_ApplicationApprover.TYPE_BOTH, null, mustContext);
        /* DEBUG ON */ System.debug('filteredAAEmails=' + filteredAAEmails);  /* DEBUG */

		System.assert(filteredAAEmails.size() == expectedEmails.size(), 
			'testApproverEmailsTypeBoth: Size of returned filtered Emails Set is wrong. Should be ' + expectedEmails.size() + ' but instead is ' + filteredAAEmails.size());
			
        System.assert(filteredAAEmails.containsAll(expectedEmails), 
        	'testApproverEmailsTypeBoth: The Set of returned filtered Emails does not match the list of expected Emails. Expected Emails should be ' +  
            expectedEmails + ' but instead is ' + filteredAAEmails);  
	}
	
	/**
	 * Select exactly two Context types.
	 * Given an Application with a list of multiple Application Approver records which 
	 * is a mix of Context types, request that CONTEXT_MAY and CONTEXT_INFORM only is returned.
	 * testcaseID a1DB00000002tBz
	 * @userStory W-1224650
	 * @hierarchy GUS.Application Approver.approverEmails
	 * @priority Medium
	 * @expectedResults A set of emails that matches the approvers on the provided 
	 * Application's Application Approver list with CONTEXT_MAY and CONTEXT_INFORM context only.
	 */
	static testMethod void testApproverEmailsContextTwo() {

    	Set<String> selectedContext = new Set<String> {
    		ADM_ApplicationApprover.CONTEXT_MAY,
    		ADM_ApplicationApprover.CONTEXT_INFORM
    	};    	

        User[] testUser = ADM_ApplicationApprover.createTestUsers();
        Map<Id, User>userMap = new Map<Id, User>();
        userMap.putAll(testUser);

		List<String> expectedEmails = new List<String>();
        
        ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrif Office', 'Justice Department');
        /* DEBUG ON */ System.debug('After creation, appl1=' + appl1);  /* DEBUG */
        
        List<ADM_Application_Approver__c> aaList = new List<ADM_Application_Approver__c>();

        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[0], testUser[0].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_QE));      
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[1], testUser[1].email, ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_DEV));     
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, testUser[2], testUser[2].email, ADM_ApplicationApprover.CONTEXT_MAY, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_DEV));
        expectedEmails.add(aaList[2].Approver_Email__c);	// First match          	
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'devnull@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_BOTH, ADM_ApplicationApprover.ROLE_DEV));
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'example@example.com', ADM_ApplicationApprover.CONTEXT_INFORM, 
        	ADM_ApplicationApprover.TYPE_RELEASES, ADM_ApplicationApprover.ROLE_RM));
        expectedEmails.add(aaList[4].Approver_Email__c);	// Second match           	
        aaList.add(ADM_ApplicationApprover.createTestApplicationApprover(appl1, null, 'test@salesforce.com', ADM_ApplicationApprover.CONTEXT_MUST, 
        	ADM_ApplicationApprover.TYPE_ERELEASES, ADM_ApplicationApprover.ROLE_TECHOPS));
                
        /* DEBUG ON */ System.debug('Approvers List, aaList=' + aaList);  /* DEBUG */
        /* DEBUG ON */ System.debug('expectedEmail=' + expectedEmails);  /* DEBUG */

		Set<String> filteredAAEmails = ADM_ApplicationApprover.approverEmails(aaList, userMap, ADM_ApplicationApprover.TYPE_BOTH, null, selectedContext);
        /* DEBUG ON */ System.debug('filteredAAEmails=' + filteredAAEmails);  /* DEBUG */

		System.assert(filteredAAEmails.size() == expectedEmails.size(), 
			'testApproverEmailsTypeBoth: Size of returned filtered Emails Set is wrong. Should be ' + expectedEmails.size() + ' but instead is ' + filteredAAEmails.size());
			
        System.assert(filteredAAEmails.containsAll(expectedEmails), 
        	'testApproverEmailsTypeBoth: The Set of returned filtered Emails does not match the list of expected Emails. Expected Emails should be ' +  
            expectedEmails + ' but instead is ' + filteredAAEmails);  
	}	
}