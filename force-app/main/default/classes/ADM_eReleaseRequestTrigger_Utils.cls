/*
 *    @testcaseID eReleaseRequest_SubscriberTest
 *    @userstory W-1271898 https://gus.salesforce.com/a07B0000000MWWi
 *    @author snahm
 */

public with sharing class ADM_eReleaseRequestTrigger_Utils {

    /*
     * Mapping of ERR states to whether state is a 'resolved' state
     * These states need to be kept in sync with the eRelease Request object's eRelease_Status__c picklist
     */
    static final Map<String, Boolean> stateMap = new Map<String, Boolean> {
            ADM_eReleaseRequest.ERR_PENDING => false,     // NULL is same as Pending, an unresolved state
            ADM_eReleaseRequest.ERR_APPROVED => false,
            ADM_eReleaseRequest.ERR_REJECTED => true,
            ADM_eReleaseRequest.ERR_RELEASED => true,
            ADM_eReleaseRequest.ERR_NMI => false,
            ADM_eReleaseRequest.ERR_WITHDRAWN => true};
    /* 
     * Returns TRUE if the given state is a "resolved" state, otherwise returns FALSE
     */
     public static Boolean isResolvedState(String state) {  
        if (state == null)
            return false;
        Boolean resolved = stateMap.get(state);
        if (resolved == null) {
            System.debug('WARNING: eRelease Request state ' + state + ' was not recognized in isResolvedState function');
        } 
        return resolved;
     }

    /*
     * This function takes a List of eRelease_Request__c objects and adds their related bugs to a
     * passed in Map as indexes, and then calls the getERRUsers helper function to add a Set of the record's related
     * users to a passed in Map of users, with the record's ID as the Map index.
     */
    public static void addBugUsers (
        List <eRelease_Request__c> errs, 
        Map<ID, ADM_Work__c> bugs, 
        Map</* eRelease_Request__c */ ID, Set</*User*/ ID>> subscribers) {
            
        for (eRelease_Request__c request : errs) {

        if(request.Bug_ID__c != null)    // Used later to lookup Users on the related Work
                bugs.put(request.Bug_ID__c, null);

            subscribers.put(request.ID, getERRUsers(request));
        }      
    }

    /*
     * This function takes an eRelease_Request__c record and returns a Set of Users
     * related to the record.  It is called by addBugsUsers() during processing of the 
     * eReleaseRequest_SubscribeUsers trigger input records.
     *
     * NOTE: If other Users are added to the eRelease_Request__c object who should be added
     * as subscribers to the Chatter feed, this function needs to be updated to include the new
     * User fields.
     */
    public static Set</*User*/ ID> getERRUsers(eRelease_Request__c request) {
    
        Set<ID> errUsers = new Set</*User*/ ID>();        //Note: Sets do not allow duplicate entries

        if (request.Who_is_verifying_fix_in_prod__c != null)
            errUsers.add(request.Who_is_verifying_fix_in_prod__c);
        if (request.Who_is_gack_watching__c != null)
            errUsers.add(request.Who_is_gack_watching__c);
        if (request.Who_is_working_with_ProductOps__c != null)
            errUsers.add(request.Who_is_working_with_ProductOps__c);
        if (request.OwnerId != null)
            errUsers.add(request.OwnerID);
        errUsers.add(request.OwnerID);        // There's always a creator
            
        return(errUsers);
    }  

    /* 
     * This function takes a Work record which accessed by the eRelease_Request__c's related Bug field
     * and adds "interested" related Users from the record to the passed in Set of users to be subscribed
     * to that eRelease_Request__c's chatter feed.
     *
     * NOTE: If the Users on the Work object that are "interested" changes (either new User fields or a change in
     * existing User field's "interest", this function must be updated.
     */
    public static Set</*User*/ ID> getWorkUsers(ADM_Work__c work, Set<ID> errUsers) {
        if (work.Assignee__c != null)
            errUsers.add(work.Assignee__c);
        if (work.QA_Engineer__c != null)
            errUsers.add(work.QA_Engineer__c);
        if (work.Product_Owner__c != null)
            errUsers.add(work.Product_Owner__c);
            
        return errUsers;
    }
    
    public static Set</*User*/ ID> getApproverUsers(List<ADM_Application_Approver__c> approvers, Set<ID> errUsers) {
        if (approvers != null) {
          for (ADM_Application_Approver__c appr : approvers) {
            if (appr.Approval_Type__c != null && appr.Approval_Type__c.contains(ADM_ApplicationApprover.TYPE_ERELEASES)) {
                if (appr.Approver__c != null) {
                    errUsers.add(appr.Approver__c);
                }
            }
          }
        }        
        return errUsers;
    }

    /*
     * As its name indicates, this function adds the related Bug's Users which were retrieved from the Work
     * record to the subscribers Map, which will be used either to add or remove those users from the
     * eRelease_Request__c's chatter subscriber list.
     */
    public static void addUsersToSubscribe(List<eRelease_Request__c> errs, Map<ID, ADM_Work__c> bugs, 
        Map<Id, List<ADM_Application_Approver__c>> appApprovers, Map<ID, Set<ID>> subscribers) {
    
       // Go through the errs records and add the Bug related users to subscribers list
        for(eRelease_Request__c request : errs) {
            Set<ID> errUsers = subscribers.get(request.ID);
            ADM_Work__c work = bugs.get(request.Bug_ID__c);
            if (work != null) {
                           
              if (errUsers != null) {
                errUsers = getWorkUsers(work, errUsers);                    
                subscribers.put(request.ID, errUsers);    // Update the subscriber set for this ERR
              }
           }
           if (request.Application__c != null) {
                errUsers = getApproverUsers(appApprovers.get(request.Application__c), errUsers);
                subscribers.put(request.ID, errUsers);
           }
        }
    }


   /*
    * Convert map of ERR record subscriber sets into a list of EntitySubscriptions
    */   
    public static List<EntitySubscription> getSubscriberList(Map</* eRelease_Request__c */ ID, Set</*User*/ ID>> subscribers) {

      List <EntitySubscription> esList = new List<EntitySubscription>();
    
      for (ID err : subscribers.keySet()) {
        for (ID user : subscribers.get(err)) {
        
           esList.add(new EntitySubscription(parentid=err, subscriberId=user));
        }
      }
     
      return esList;    
    }
    
    /*
     * Retrieve and initialize the templates for the eRelease notification emails.
     * The Name strings need to be kept in sync with the corresponding eRelease template's Name 
     */ 
    static Map<String, Id> templateMap;
     
    public static Map<String, Id> initializeEmailTemplateIds() {

      if (templateMap == null) {
        templateMap = new Map<String, Id> ();
      }
    
      if (ADM_eReleaseRequestEmailTemplateIds.templatePendingId == null || 
        ADM_eReleaseRequestEmailTemplateIds.templateApprovedId == null || 
        ADM_eReleaseRequestEmailTemplateIds.templateRejectedID == null ||
        ADM_eReleaseRequestEmailTemplateIds.templateNMIId == null || 
        ADM_eReleaseRequestEmailTemplateIds.templateWithdrawnId == null) {
            
       
        List<EmailTemplate> templateList;
        try {
        	templateList = new List<EmailTemplate>([Select Id,Name from EmailTemplate Where Name LIKE 'ADM_eRelease%']);
        } catch (System.Exception e) {
            System.debug('ADM_eReleaseRequestTrigger_Utils.initializeEmailTemplateIds: Unexpected exception looking up email template IDs:' 
            	+ e + ' Line:' + e.getLineNumber());
            templateMap = null;
            return(templateMap);
        }
        /* 
         * The templateList loop is put inside the templateId tests because the common case will be that
         * the templateIds are set, and the loops are only encountered the first time the trigger is executed,
         * when they are not.
        */
        if (ADM_eReleaseRequestEmailTemplateIds.templatePendingId == null) {
          for (EmailTemplate template : templateList) {
              if (template.Name.compareTo('ADM eRelease Request Visualforce') == 0) {
                  ADM_eReleaseRequestEmailTemplateIds.templatePendingId = template.Id;
                  templateMap.put(ADM_eReleaseRequest.ERR_PENDING, ADM_eReleaseRequestEmailTemplateIds.templatePendingId);
              }
          }
        }
        if (ADM_eReleaseRequestEmailTemplateIds.templateApprovedId == null) {
          for (EmailTemplate template : templateList) {
              if (template.Name.compareTo('ADM eRelease Approved Visualforce') == 0) {
                  ADM_eReleaseRequestEmailTemplateIds.templateApprovedId = template.Id;
                  templateMap.put(ADM_eReleaseRequest.ERR_APPROVED, ADM_eReleaseRequestEmailTemplateIds.templateApprovedId);
              }
          }
        }      
        if (ADM_eReleaseRequestEmailTemplateIds.templateRejectedId == null) {
          for (EmailTemplate template : templateList) {
              if (template.Name.compareTo('ADM eRelease Not Approved Visualforce') == 0) {
                  ADM_eReleaseRequestEmailTemplateIds.templateRejectedId = template.Id;
                  templateMap.put(ADM_eReleaseRequest.ERR_REJECTED, ADM_eReleaseRequestEmailTemplateIds.templateRejectedID);
              }
          }
        }
        if (ADM_eReleaseRequestEmailTemplateIds.templateNMIId == null) {
          for (EmailTemplate template : templateList) {
              if (template.Name.compareTo('ADM eRelease More Info Required Visualforce') == 0) {
                  ADM_eReleaseRequestEmailTemplateIds.templateNMIId = template.Id;
                  templateMap.put(ADM_eReleaseRequest.ERR_NMI, ADM_eReleaseRequestEmailTemplateIds.templateNMIId);
              }
          }
        }
        if (ADM_eReleaseRequestEmailTemplateIds.templateWithdrawnId == null) {
          for (EmailTemplate template : templateList) {
              if (template.Name.compareTo('ADM eRelease Request Withdrawn Visualforce') == 0) {
                  ADM_eReleaseRequestEmailTemplateIds.templateWithdrawnId = template.Id;
                  templateMap.put(ADM_eReleaseRequest.ERR_WITHDRAWN, ADM_eReleaseRequestEmailTemplateIds.templateWithdrawnId);    
              }
          }
        }                 
      } else {
        /* DEBUG OFF  */ System.debug('initializeEmailTemplateIds: using cached email template Ids');  /* DEBUG */
      }

        return(templateMap);
    }    
    

    /* 
     * Creates a map of Application IDs to lists of their Application Approvers
     * Input is a map of Applications, and a User Id set (which is returned as a result of creating the result map)
     */

    public static Map</*ADM_Application__c*/ Id, List<ADM_Application_Approver__c>> getAppApproverMap(Map<Id, ADM_Application__c> appMap, Set</*User*/ID>apprUserIds) {

        Map</*ADM_Application__c*/ Id, List<ADM_Application_Approver__c>> appApproverMap = new Map<Id, List<ADM_Application_Approver__c>>();
            
        // applicationApprovers is a Map of Application Approvers Ids to their records
        Map<Id, ADM_Application_Approver__c> applicationApprovers;
        try {
        	applicationApprovers = new Map<Id, ADM_Application_Approver__c>(
            [select Application__c,Approver__c,Approver_Email__c,Approval_Context__c,Approval_Type__c,Approver_Role__c
            from ADM_Application_Approver__c where Application__c =:appMap.keySet()]);
        } catch (System.Exception e) {
    		System.debug('ADM_eReleaseRequestTrigger_Utils.getAppApproverMap: Unexpected exception looking up Application Approvers:' + e + ' Line:' + e.getLineNumber());
    		return(appApproverMap);
    	}
        for (ADM_Application_Approver__c appr : applicationApprovers.values()) {
          if (appr.Application__c != null) {
            ADM_Application__c app = appMap.get(appr.Application__c);
            if (app != null) {
                List<ADM_Application_Approver__c> thisApprList = appApproverMap.get(app.Id);
                if (thisApprList == null) {
                    thisApprList = new List<ADM_Application_Approver__c>();
                }
                thisApprList.add(appr);
                appApproverMap.put(app.Id, thisApprList);
            }
          }
          if (appr.Approver__c != null) {
            apprUserIds.add(appr.Approver__c);
          }
        }
        return(appApproverMap);
    }
    
    
}