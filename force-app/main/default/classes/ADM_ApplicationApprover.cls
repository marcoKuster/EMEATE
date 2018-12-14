/**
 *    @userstory W-1224650: eRelease Request process takes up too many workflows
 *    @author snahm
 */

/*
 * This class will include utility methods for accessing the Application Approver
 * objects related to an Application.  
 */


public with sharing class ADM_ApplicationApprover {
	
	/*
 	 * These strings need to be kept consistent with the corresponding picklists
 	 */
 
	// ADM_Application__c.Approval_Type__c picklist
	public static final String TYPE_RELEASES = 'Releases';
	public static final String TYPE_ERELEASES = 'eReleases';
	public static final String TYPE_BOTH = 'Releases; eReleases';


	// ADM_Application__c.Approval_Role__c picklist
	public static final String ROLE_DEV = 'Development Manager';
	public static final String ROLE_QE = 'QE Manager';
	public static final String ROLE_RE = 'Release Engineer';
	public static final String ROLE_RM = 'Release Manager';
	public static final String ROLE_TECHOPS = 'TechOps Manager';

	// ADM_Application__c.Approval_Context__c picklist
	public static final String CONTEXT_INFORM = 'Inform Only';
	public static final String CONTEXT_MAY = 'May Approve';
	public static final String CONTEXT_MUST = 'Must Approve';
	public static final String CONTEXT_NOTIFY = 'Notify When Approved';

	/*
	 * Takes a List of Application Approvers and a Map of Users from that list and returns a List of Users that 
	 * match the type, role and context criteria. "null" for any of these three filters means "all".
	 *
	 * Multiple context values can be specified; the contextSet param is Set of strings that match the Context picklist values.
	 */	
	public static Set<User> approverUsers(List<ADM_Application_Approver__c> approvers, Map<Id, User> users, 
			String type, String role, Set<String> contextSet) {
		Set<String> aaTypeSet = new Set<String>();
		if (type != null && type.equals(TYPE_BOTH)) {
			type = null;
		}
		Set<Id> selected = new Set<Id>();
		for (ADM_Application_Approver__c aa : approvers) {
			aaTypeSet.addAll(aa.Approval_Type__c.deleteWhitespace().split(';'));
			if ((type == null || aaTypeSet.contains(type)) &&
				(contextSet == null || contextSet.contains(aa.Approval_Context__c)) &&
				(role == null || role.equals(aa.Approver_Role__c))) {
					selected.add(aa.Approver__c);
			}
			aaTypeSet.clear();
		}
		Set<User> returnUsers = new Set<User>();
		for (Id uId : selected) {
			User u = users.get(uId);
			if (u != null) {
				returnUsers.add(u);
			}
		}
		return returnUsers;
	}
	/*
	 * Similar to above, but returns Emails instead.
	 */	
	public static Set<String> approverEmails(List<ADM_Application_Approver__c> approvers, Map<Id, User> users, 
			String type, String role, Set<String> contextSet) {
		Set<String> aaTypeSet = new Set<String>();
		if (type != null && type.equals(TYPE_BOTH)) {
			type = null;
		}
		Set<String> selected = new Set<String>();
		List<Id> selectedUser = new List<Id>();
		for (ADM_Application_Approver__c aa : approvers) {

			aaTypeSet.addAll(aa.Approval_Type__c.deleteWhitespace().split(';'));
			if ((type == null || aaTypeSet.contains(type)) &&
				(contextSet == null || contextSet.contains(aa.Approval_Context__c)) &&
				(role == null || role.equals(aa.Approver_Role__c))) {
				if (aa.Approver__c != null) {		// If Approver_Email__c is a dlist, Approver__c will be null
					User u = users.get(aa.Approver__c);
					if (u != null) {
						selected.add(u.Email);		// If Approver User is not null, need to return the Approver's email
					}
				} else {											
					selected.add(aa.Approver_Email__c);
				}
			}
			aaTypeSet.clear();							
		}

		return selected;
	}	
	
	public static ADM_Application_Approver__c createTestApplicationApprover(ADM_Application__c appl, User appU, String apprEmail,
        String context, String type) {
        
        return createTestApplicationApprover(appl, appU, apprEmail, context, type, ROLE_RM);
    }
    
    public static ADM_Application_Approver__c createTestApplicationApprover(ADM_Application__c appl, User appU, String apprEmail,
        String context, String type, String role) {
        
        ADM_Application_Approver__c aa = new ADM_Application_Approver__c(Application__c=null, Approver__c=null, Approver_Email__c=apprEmail,
            Approval_Context__c=context, Approval_Type__c=type, Approver_Role__c=role);
        if (appl != null) {
       		aa.Application__c=appl.id;
        }
        if (appU != null) {
        	aa.Approver__c=appU.id;
        }
        Database.insert(aa);
        return aa;      
    }
    
    /*
     * Sets up three test users.  For tests.
     */
    public static List<User> createTestUsers() {
		List <User> testUsers = new List<User>();  	

        Profile p = null;
        try {
            p = [select id from profile where name='GUS Release Manager'];
        } catch (System.Exception e) {
            System.debug('ApplicationApprover_TriggerTest: did not find GUS Release Manager profile. Will use System Administrator profile.');
        }
        if (p == null)                    // GUS RM profile doesn't exist in this org
            p = [select id from profile where name='System Administrator'];

        User aaU1 = new User(alias = 'mdillon', email='mdillon@test.test', firstname='Matt', lastname='Dillon',
                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles',
                    profileid = p.Id, username='mdillon@test.test');
        Database.insert(aaU1);
        testUsers.add(aaU1);
        User aaU2 = new User(alias = 'cgoode', email='cgoode@test.test', firstname='Chester', lastname='Goode', 
                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles',
                    profileid = p.Id, username='cgoode@test.test');
        Database.insert(aaU2);
        testUsers.add(aaU2);
        
        User aaU3 = new User(alias = 'gadams', email='gadams@test.test', firstname='Doc', lastname='Adams',
                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', 
                    profileid = p.Id, username='gadams@test.test');
        Database.insert(aaU3);
        testUsers.add(aaU3);
        return (testUsers);
    }
    
	/*
	 * Creates four test Application Approvers for the specified Application
	 */
	public static List <ADM_Application_Approver__c> createTestApplicationApprovers(ADM_Application__c app) {
	 	User[] testUser = createTestUsers();
	 	List <ADM_Application_Approver__c> aa = new List<ADM_Application_Approver__c>();
	 	aa.add(createTestApplicationApprover(app, 
	 		testUser[0], testUser[0].email, CONTEXT_MUST, TYPE_BOTH, ROLE_QE));
	 	aa.add(createTestApplicationApprover(app, 
	 		testUser[1], testUser[1].email, CONTEXT_MAY, TYPE_RELEASES, ROLE_DEV));
	 	aa.add(createTestApplicationApprover(app, 
	 		null, 'devnull@salesforce.com', CONTEXT_INFORM, TYPE_ERELEASES));
	 	aa.add(createTestApplicationApprover(app, 
	 		testUser[2], testUser[2].email, CONTEXT_MUST, TYPE_RELEASES));
	 	return(aa);
	}
	
}