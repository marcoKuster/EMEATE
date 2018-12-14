/*
 * This focus of this test is the eReleaseRequest_SubscriberUsers trigger, which adds related users
 * when ERRs are created or set to a Pending state, and unsubscribes them when the ERR is set to 
 * Rejected, Approved or Withdrawn.
 *
 */
 
 
@isTest
private class ADM_eReleaseRequest_SubscriberTest {
        
    /**
     * ERR and Work Related Users are Swarmed.
     * Tests these operations:
     * 1. Insert
     * 2. Change to Need More Information 
     * 3. Change to Rejected
     * 4. Change to Need More Information 
     * 4a. Manuall remove one of the related subscribers
     * 5. Change to Pending 
     * 6. Change to Approved
     * 7. Change to Released
     * 8. Test two concurrent ERR updates: One to Rejected, the other to Approved.
     * 
     * @userStory W-1271898
     * @hierarchy GUS.eRelease Request.Chatter Swarm
     * @priority High
     * @expectedResults 1. Related users are subscribed
     * 2. Users are still subscribed
     * 3. Users are unsubscribed
     * 4. Users are subscribed
     * 4a. The selected user is unsubscribed
     * 5. Users (including the unsubscribed User) are all subscribed
     * 6. Users are still subscribed
     * 7. Users are unsubscribed
     * 8. Users are unsubscribed from the Rejected ERR and still subscribed to the 
     * Approved ERR.
     */ 

    static testMethod void testErrBugSwarmed() {

        // The Email template requires a $CurrentPage reference
        PageReference pageRef = new PageReference('https://gus.salesforce.com');
        Test.setCurrentPage(pageRef);

        List<User> nu = ADM_ApplicationApprover.createTestUsers();
        
        // nu[0] user is on both ERR and related Work
        // nu[1] user is *only* on ERR
        // nu[2] user is *only* on related Work item

        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        work.Assignee__c=nu[2].id;
        work.QA_Engineer__c=nu[0].id;
        work.Product_Owner__c=nu[0].id;
        work.Tech_Writer__c=nu[1].id;      
        insert(work);
        /* DEBUG OFF     System.debug('ID of Work: ' + work.id); /* DEBUG */
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', nu[0], nu[1]);
        /* DEBUG OFF     System.debug('ID of App: ' + app.id);  /* DEBUG */  
        Test.startTest();

        eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, nu[0], nu[1], null); 
            // This will invoke the eReleaseRequest_SubscribeUsers trigger -- Test 1

        // All of nu[] should be subscribed to the ERR now
        List <EntitySubscription> esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        Set<ID> subscribers = new Set<ID>();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        System.assert(subscribers.contains(nu[0].id));     // All users added?
        System.assert(subscribers.contains(nu[1].id));
        System.assert(subscribers.contains(nu[2].id));
        
        // Test 2: change the status to Need More Info
        err = [select Explanation_of_eRelease__c, eRelease_Status__c,Request_Type__c, Customer_Impact__c, Requested_Deployment_Date__c,
            Target_Instances__c,Bug_ID__c,Application__c, Checkin_Location__c,  
            Who_is_gack_watching__c, Who_is_verifying_fix_in_prod__c, Who_is_working_with_ProductOps__c
            from eRelease_Request__c where Id =: err.id];
        err.eRelease_Status__c = 'Need More Information';
        update(err);
        //
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        System.assert(subscribers.contains(nu[0].id));     // All users still subscribed?
        System.assert(subscribers.contains(nu[1].id));
        System.assert(subscribers.contains(nu[2].id));        
        
        // Test 3: change the status to Rejected
        /* DEBUG ON */ System.debug('eReleaseRequest_SubscribeTest: Test 3: Prior=NMI; Set to Rejected');   /* DEBUG */
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_REJECTED;
        update(err);
        //
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
        /* DEBUG ON */ System.debug('eReleaseRequest_SubscribeTest: EntitySubscription p=' + es.parentId + ' s=' + es.subscriberId);            
            subscribers.add(es.subscriberId);
        }
        System.assert(!subscribers.contains(nu[0].id));     // All users NOT subscribed?
        System.assert(!subscribers.contains(nu[1].id));
        System.assert(!subscribers.contains(nu[2].id));        
        
        
        // Test 4: change the status to Need More Info
        /* DEBUG ON */ System.debug('eReleaseRequest_SubscribeTest: Test 4: Prior=Rejected; Set to NMI'); /* DEBUG */
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_NMI;
        update(err);
        //
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
        /* DEBUG ON */ System.debug('eReleaseRequest_SubscribeTest: EntitySubscription p=' + es.parentId + ' s=' + es.subscriberId);
            subscribers.add(es.subscriberId);
        }
        System.assert(subscribers.contains(nu[0].id));  // Setting to NMI means more review needed
        System.assert(subscribers.contains(nu[1].id));  // So this test sets all users to subscribed once again
        System.assert(subscribers.contains(nu[2].id));          
            
        // Test 4a: Unsubscribe one of the users; Test 5's setting to Pending will add that user back in
        EntitySubscription esUnsubscribe = new EntitySubscription();
        esUnsubscribe = esRecords[0];       // Take the first one
        delete esUnsubscribe;               // Remove it
        //
        Id unsubscriber = esUnsubscribe.subscriberId;   // Remember who we removed
        List<ID> stillSubscribed = new List<ID>();
        for (Integer i = 0; i<nu.size(); i++) {
            if (unsubscriber != nu[i].id)
                stillSubscribed.add(nu[i].id);
        }
        //
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
        /* DEBUG ON */ System.debug('eReleaseRequest_SubscribeTest: EntitySubscription p=' + es.parentId + ' s=' + es.subscriberId);    /* DEBUG */
            subscribers.add(es.subscriberId);
        }
        System.assert(!subscribers.contains(unsubscriber));     // Unsubscriber NOT subscribed?
        for (ID i : stillSubscribed) {
            System.assert(subscribers.contains(i));             // Subscribers still subscribed?
        }
        
        // Test 5: change the status to Pending; will Resubscribe the user unsubscribed in Test 4a
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_PENDING;
        update(err);
        //      
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        /* DEBUG ON */      System.debug('eReleaseRequest_SubscribeTest: esRecords - ' + esRecords + ' subscribers - ' + subscribers);   
        System.assert(subscribers.contains(nu[0].id));  // All users still subscribed?
        System.assert(subscribers.contains(nu[1].id));
        System.assert(subscribers.contains(nu[2].id));          
               
        // Test 6: change the status to Approved
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;
        err.Checkin_Location__c = '/test/checkin/..';
        /* DEBUG ON */ System.debug('eReleaseRequest_SubscribeTest: err prior to setting APPROVED:' + err);
        update(err);
        //
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        System.assert(subscribers.contains(nu[0].id));  // All users still subscribed?
        System.assert(subscribers.contains(nu[1].id));
        System.assert(subscribers.contains(nu[2].id));    
        
        // Test 7: change status to Released; make sure users are unsubscribed
        ADM_Release__c myRelease = ADM_Release.createTestRelease('Winchester.2020', app);
        //
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_RELEASED;
        err.Released_In__c = myRelease.Id;
        update(err);
        // Check that the subscribers are unsubscribed
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        System.assert(!subscribers.contains(nu[0].id)); // Check that all users are now NOT subscribed
        System.assert(!subscribers.contains(nu[1].id));
        System.assert(!subscribers.contains(nu[2].id));  
                        
        // Test 8: Test update to two records
        eRelease_Request__c err2 = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, nu[0], nu[1], nu[2]);   // Users on ERR2 are subscribed to it
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err2.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        System.assert(subscribers.contains(nu[0].id));  // All users subscribed?
        System.assert(subscribers.contains(nu[1].id));
        System.assert(subscribers.contains(nu[2].id));         
        
        //
        err2 = [select Explanation_of_eRelease__c, eRelease_Status__c,Request_Type__c, Customer_Impact__c, Requested_Deployment_Date__c,
            Target_Instances__c,Bug_ID__c,Application__c, Checkin_Location__c, Who_is_gack_watching__c, Who_is_verifying_fix_in_prod__c, 
            Who_is_working_with_ProductOps__c from eRelease_Request__c where Id =: err2.id];    
        err2.eRelease_Status__c = ADM_eReleaseRequest.ERR_REJECTED;
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_APPROVED;    // Change from Released to Approved will re-subscribe users
        err.Released_In__c = null;
        //
        eRelease_Request__c[] errList = new eRelease_Request__c[]{err, err2};
        /* DEBUG OFF 
        for (Integer i=0; i<errList.size(); i++) {
            System.debug('eReleaseRequest_SubscribeTest: errList[' + i + ']: ' + errList[i]);
        } /* DEBUG */
        List<Database.SaveResult> SR = database.update(errList, false);
        for (Database.Saveresult s : SR) {
            for(Database.Error error: s.getErrors())
            {
                System.debug('eReleaseRequest_SubscribeTest: Database.error ' + error + ' for ' + s);
            } 
        }
        // Users should be subscribed to ERR and unsubscribed from ERR2
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        System.assert(subscribers.contains(nu[0].id));  // All users subscribed?
        System.assert(subscribers.contains(nu[1].id));
        System.assert(subscribers.contains(nu[2].id));                
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err2.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        System.assert(!subscribers.contains(nu[0].id)); // All users unsubscribed?
        System.assert(!subscribers.contains(nu[1].id));
        System.assert(!subscribers.contains(nu[2].id));        
        
        Test.stopTest();                
    }

    /**
     * eRelease Application Approvers are Swarmed.
     * Create a set of Application Approvers for an Application for which we create an 
     * ERR. Then set the ERR to Rejected.
     * 
     * @userStory W-1617135
     * @hierarchy GUS.eRelease Request.Chatter Swarm
     * @priority High
     * @expectedResults When ERR is created, all Approvers with TYPE_ERELEASES are 
     * subscribed to the record and Approvers who are NOT of that type are not 
     * subscribed.
     * When ERR is set to Rejected, all Approvers that were subscribed are now 
     * unsubscribed.
     */
    static testMethod void testApproversSwarmed() {

        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        /* DEBUG OFF     System.debug('ID of Work: ' + work.id); /* DEBUG */
        
        ADM_Application__c app = ADM_Application.createTestApplication('Winchester', 'Colt 45', null, null);
        /* DEBUG OFF     System.debug('ID of App: ' + app.id);  /* DEBUG */  
                    
        ADM_ApplicationApprover.createTestApplicationApprovers(app);
        // Pull down the Users setup as eRelease Request Approvers
        List<ADM_Application_Approver__c> approvers = [select Approver__c,Approval_Type__c from ADM_Application_Approver__c where Application__c =: app.id];
        
        // Create the ERR
        eRelease_Request__c err = ADM_eReleaseRequest.createTestEReleaseRequest(work, app, null, null, null);   

        // Get the users subscribed to the ERR record
        List <EntitySubscription> esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        Set<ID> subscribers = new Set<ID>();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        
        Set<Id> approverUsers = new Set<Id>();
        
        // Check that the users who are NOT eRelease approvers were not added
        for (ADM_Application_Approver__c appr : approvers) {
            if (!appr.Approval_Type__c.contains(ADM_ApplicationApprover.TYPE_ERELEASES)) {
                if (appr.Approver__c != null) {
                    approverUsers.add(appr.Approver__c);
                }
            }
        }
        User u;
 		Map<Id, User> approverUsersMap;
    	try {
    		approverUsersMap = new Map<Id, User>([select Name,Email from User where Id =: approverUsers]);
   		} catch (System.Exception e) {
    		System.debug('testApproversSwarmed: Unexpected exception looking up Users:' + e + ' Line:' + e.getLineNumber());
    	}        
        /* DEBUG ON */ System.debug('testApproversSwarmed: Approvers who are NOT eRelease Approver Users=');
        for (Id uId : approverUsers) {
        	u = approverUsersMap.get(uId);
        	if (u == null) {
        		System.debug('testApproversSwarmed: Id=' + uId + ' (User record not in approverUsersMap)');
        	} else {
        		System.debug('testApproversSwarmed: Id=' + u.Id + ' Name=' + u.Name + ' email=' + u.email);
        	}
        }	/* DEBUG */
        
        for (Id uId : approverUsers) {
        	u = approverUsersMap.get(uId);
        	System.assert(u != null, 'testApproversSwarmed: [Not ERR Approvers] Could not find User Id=' + uId + ' in approverUsersMap');
            System.assert(!subscribers.contains(uId), 'testApproversSwarmed: User ID=' + u.Id + ' Name=' + u.Name + ' email=' + u.Email + ' should NOT have been subscribed to ERR, but was.');
        }       
        // Check that the users who were eRelease approvers were subscribed
        approverUsers.clear();
        for (ADM_Application_Approver__c appr : approvers) {
            if (appr.Approval_Type__c.contains(ADM_ApplicationApprover.TYPE_ERELEASES)) {
                if (appr.Approver__c != null) {
                    approverUsers.add(appr.Approver__c);
                }
            }
        }
    	try {
    		approverUsersMap = new Map<Id, User>([select Name,Email from User where Id =: approverUsers]);
   		} catch (System.Exception e) {
    		System.debug('testApproversSwarmed: Unexpected exception looking up Users:' + e + ' Line:' + e.getLineNumber());
    	}          
        /* DEBUG ON */ System.debug('testApproversSwarmed: Approvers who ARE eRelease Approver Users=');
        for (Id uId : approverUsers) {
        	u = approverUsersMap.get(uId);
        	if (u == null) {
        		System.debug('testApproversSwarmed: Id=' + uId + ' (User record not in approverUsersMap)');
        	} else {
        		System.debug('testApproversSwarmed: Id=' + u.Id + ' Name=' + u.Name + ' email=' + u.email);
        	}
        }	/* DEBUG */
        for (Id uId : approverUsers) {
        	u = approverUsersMap.get(uId);
        	System.assert(u != null, 'testApproversSwarmed: [ERR approvers] Could not find User Id=' + uId + ' in approverUsersMap');        	
            System.assert(subscribers.contains(uId), 'User ID=' + u.Id + ' Name=' + u.Name + ' email=' + u.Email + ' should have been subscribed to ERR, but was NOT.');
        } 
       
        // Set the ERR to an resolved state and verify that subscribed users were removed
        err.eRelease_Status__c = ADM_eReleaseRequest.ERR_REJECTED;
        update err;
        
        esRecords = [select parentId,subscriberId from EntitySubscription where parentId =: err.id];
        subscribers.clear();
        for (EntitySubscription es : esRecords) {
            subscribers.add(es.subscriberId);
        }
        /* DEBUG ON */ System.debug('testApproversSwarmed: ERR subscribers after ERR set to resolved state=' + subscribers); /* DEBUG */
        
        for (Id uId : approverUsers) {
        	u = approverUsersMap.get(uId);
        	System.assert(u != null, 'testApproversSwarmed: [removing ERR approvers] Could not find User Id=' + uId + ' in approverUsersMap');        	        	
            System.assert(!subscribers.contains(uId), 'User ID=' + u.Id + ' Name=' + u.Name + ' email=' + u.Email + ' should have been unsubscribed from ERR, but was NOT.');
        }         
        
    }
}