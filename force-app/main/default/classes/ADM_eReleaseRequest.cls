/**
 *    @userstory W-1268579: Track application information and lifecycle with Application object
 *    @author snahm
 */

public with sharing class ADM_eReleaseRequest {

    // eRelease_Request__c.eRelease_Status__c picklist
    public static final String ERR_PENDING = 'Pending';
    public static final String ERR_APPROVED = 'Approved';
    public static final String ERR_REJECTED = 'Rejected';
    public static final String ERR_NMI = 'Need More Information';
    public static final String ERR_WITHDRAWN = 'Request Withdrawn';
    public static final String ERR_RELEASED = 'Released';
    public boolean associatedToRedAccount = false;
    private final eRelease_Request__c eReleaseRecord;
    private final String RED_ACCOUNT = 'Open';
    
    public ADM_eReleaseRequest(ApexPages.StandardController  stdController){
       this.eReleaseRecord = (eRelease_Request__c)stdController.getRecord();
       /* DEBUG OFF  System.debug('ADM_eReleaseRequest: eReleaseRecord=' + this.eReleaseRecord);  /* DEBUG */
       if(null != this.eReleaseRecord){
        setValuesFromEReleaseRecord();
       }
    }
    public static eRelease_Request__c setupTestEReleaseRequest(ADM_Work__c work, ADM_Application__c app, User gackWatcher, User verifier, User productOps) {

        eRelease_Request__c err = new eRelease_Request__c(Explanation_of_eRelease__c='Test ERR', eRelease_Status__c=null,
            Request_Type__c='Emergency Release', Customer_Impact__c='minimal', Requested_Deployment_Date__c=Date.today(),
            Target_Instances__c='none', Checkin_Location__c='/dev/null', Deploy_to_all_Instances__c='Yes',
            Use_Default_Verification_Instance__c='Yes');
        if (work != null) {
            err.Bug_ID__c=work.id;
        }
        if (app != null) {
            err.Application__c=app.id;
        }
        if (gackWatcher != null) {
            err.Who_is_gack_watching__c=gackWatcher.id;
        }
        if (verifier != null) {
            err.Who_is_verifying_fix_in_prod__c=verifier.id;
        }
        if (productOps != null) {
            err.Who_is_working_with_ProductOps__c=productOps.id;
        }
        return err;
    }


    public static eRelease_Request__c createTestEReleaseRequest(ADM_Work__c work, ADM_Application__c app, User gackWatcher, User verifier, User productOps) {

        eRelease_Request__c err = setupTestEReleaseRequest(work, app, gackWatcher, verifier, productOps);
        /* DEBUG OFF  System.debug('createTestEReleaseRequest: err=' + err); /* DEBUG */
        Database.insert(err);
        return err;
    }

    /*
     *  Takes an eRelease Request record and a Map of User records, returns a set of email addresses of 
     *  the related Users on an eRelease Request that are found in the Map.
     */
    public static Set<String> eReleaseRequestEmails(eRelease_Request__c request, Map<Id, User> users) {
        Set<String> errEmails = new Set<String>();
        User u;
        if ((u = users.get(request.Who_is_verifying_fix_in_prod__c)) != null)   
            errEmails.add(u.Email);
        if ((u = users.get(request.Who_is_gack_watching__c)) != null)
            errEmails.add(u.Email);
        if ((u = users.get(request.Who_is_working_with_ProductOps__c)) != null)
            errEmails.add(u.Email);
        if ((u = users.get(request.OwnerId)) != null)
            errEmails.add(u.Email);
        if ((u = users.get(request.CreatedByID)) != null)
            errEmails.add(u.Email);
        return errEmails;       
    }

    /*
     * Sets up "count" test users.  For tests.
     */
    public static List<User> createTestUsers(Integer count, String key) {
        List <User> testUsers = new List<User>();   

        Profile p = null;
        try {
            p = [select id from profile where name='System Administrator'];
        } catch (System.Exception e) {
            System.debug('createTestUsers: did not find System Administrator profile.');
            return null;
        }
        /* DEBUG OFF   System.debug('ID of profile being used: ' + p.id);   /* DEBUG */

        for (Integer i=0; i < count; i++) {
            User testuser = new User(alias = 'test' + i, email='test' + i + '@test.test', firstname='test' + i, lastname='user_' + i,
                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles',
                    profileid = p.Id, username= key + i + '@example.com');
            /* DEBUG OFF  System.debug('createTestUsers: testUsers[ ' + i + ' ] = ' + testUser);    /* DEBUG */
            Database.insert(testuser);
            testUsers.add(testuser);   
        }
        /* DEBUG OFF  
        for (Integer i=0; i < count; i++) {
            System.debug('createTestUsers: testUsers[ ' + i + ' ] = ' + testUsers[i]); 
        }
        /* DEBUG */
        return testUsers;
    }    

    private void setValuesFromEReleaseRecord(){
        String workId = this.eReleaseRecord.Bug_ID__c;
        /* DEBUG OFF System.debug('ADM_eReleaseRequest.setValuesFromEReleaseRecord: workId=' + workId); /* DEBUG */
        if (workID != null) {
        List<ADM_Case__c> org62Cases = ADM_Case.getRecords(workId);
        for(ADM_Case__c caseIter : org62Cases){
            String accountStage = caseIter.Account_Stage__c;
            setRedAccountStatus(accountStage);
            if(true == associatedToRedAccount){//If associatedToRedAccount set to true (Atleast one of the case associated to this work record has Red Account in org62)
                break;
            }
        }
        }
    }

    private void setRedAccountStatus(String accountStage){
        if(RED_ACCOUNT.equalsIgnoreCase(accountStage)){
            setAssociatedToRedAccount(true);
        }
    }

    public Boolean getAssociatedToRedAccount(){
        return associatedToRedAccount;
    }

    public void setAssociatedToRedAccount(Boolean value){
        this.associatedToRedAccount = value;
    }

  }