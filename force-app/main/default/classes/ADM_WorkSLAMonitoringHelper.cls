public class ADM_WorkSLAMonitoringHelper {

    // Current SLA settings https://sites.google.com/a/salesforce.com/support-technology-escalations/
    private static final Long MIN_IN_MILLISEC = 60 * 1000L;
    private static final Long HOUR_IN_MILLISEC = 60 * MIN_IN_MILLISEC;    
    
    private static final Long ACK_TIME_SEV1 = 7 * MIN_IN_MILLISEC;
    private static final Long ACK_TIME_SEV2 = 4 * HOUR_IN_MILLISEC;
    private static final Long ACK_TIME_SEV3 = 8 * HOUR_IN_MILLISEC;
    
    private static final Long UPDATE_TIME_SEV1 = 1 * HOUR_IN_MILLISEC;
    private static final Long UPDATE_TIME_SEV2 = 8 * HOUR_IN_MILLISEC;
    private static final Long UPDATE_TIME_SEV3 = 16 * HOUR_IN_MILLISEC;
    
    private static final String WORK_STATUS_NEW = 'New';
    private static final String WORK_STATUS_ACKNOWLEDGED = 'Acknowledged';
    private static final String WORK_STATUS_INVESTIGATING = 'Investigating';
    private static final String WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT = 'More Info Reqd from Support';
    
    private static final String SEV1 = '1';
    private static final String SEV2 = '2';
    private static final String SEV3 = '3';
    private static final String SEV4 = '4';
    
    private static final String USER_PROFILE_APIONLY = 'GUS API ONLY CRUD BY PERM SET';
    private static final String USER_PROFILE_SUPPORT = 'GUS Customer Support User';
    
    private static BusinessHours defaultBHs;
    @TestVisible
    private static Map<Id, Id> worksBusinessHoursMap;

    private static Map<String,RecordType> recordTypesMap;

    private static final ADM_WorkSLAResponseTimeDefinitions responseTimeDefinitions = new ADM_WorkSLAResponseTimeDefinitions();

    private static List<ADM_Work__c> worksOpenViolationList = new List<ADM_Work__c>();
    private static List<ADM_Work__c> worksCloseViolationList = new List<ADM_Work__c>();
    
    
    ///////////////// PUBLIC METHODS /////////////////
        
    /**
    * Examine Work objects and their previous state and determine if 
    *   SLA Due Time needs to be updated.
    *
    * @param worksNew List of Work we may want to set SLA due time
    * @param oldWorkMap The previous state of the work (i.e. from Trigger.old)
    */
    public static void applyInvestigationSLAs(List<ADM_Work__c> worksNew, Map<Id,ADM_Work__c> worksOldMap) {
        applyInvestigationSLAsWithDatetime(worksNew, worksOldMap, System.Now());
        
        // Moved this call out to the Work after update trigger
        // to avoid infinite loop from a RSF field from SLA Violation to Work
        //commitSLAViolationChanges();
    }
    
    /**
    * Examine Work objects and determine if SLA Due Time needs to be updated.
    * Intended to be used when inserting new Work records only. For updates
    * use the method: applyInvestigationSLAs(List,Map)
    *
    * @param worksNew List of Work we may want to set SLA due time
    */
    public static void applyInvestigationSLAs(List<ADM_Work__c> worksNew) {
        applyInvestigationSLAs(worksNew, null);
    }
    
    /**
    * Same method as the one below except it uses the default businesshours and system.now()
    *
    * @param workIdsFromPostOrComment ids for works, sent from triggers on FeedItems and FeedComments of ADM_Work__c
    */
    public static void resetInvestigationSLAsFromChatter(List<Id> workIdsFromPostOrComment){
        resetInvestigationSLAsFromChatter(workIdsFromPostOrComment, System.Now());
    }
    
    
    
    
    ///////////////// PRIVATE METHODS /////////////////
    
    /**
    * Assumes the user has just created a Chatter post or comment against each Work record in 'workIdsFromPostOrComment'.
    * Examine works and its status with current user profile and determine if its SLA Due Time needs to be updated
    *
    * @param workIdsFromPostOrComment ids for works, sent from triggers on FeedItems and FeedComments of ADM_Work__c
    * @param bhs The business hours when we calculate the dueTime
    * @param startDateTime The start time when we calculate the dueTime
    */
    @TestVisible
    private static void resetInvestigationSLAsFromChatter(List<Id> workIdsFromPostOrComment, DateTime startDateTime) {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        List<ADM_Work__c> invsWorks = new List<ADM_Work__c>();
        Id InvestigationRecordTypeId = getRecordTypeFor(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION).Id;
        if(profileName == USER_PROFILE_APIONLY) {
            return; // Integration user actions do not count toward SLAs
        }
        if(profileName == USER_PROFILE_SUPPORT){
            // Only reset support SLA if user is Support and the work.status is "more info required"
            invsWorks = [SELECT Id, RecordTypeId, Out_of_SLA__c, Status__c, Severity_Level__c, Due_Date__c,
                                Assignee__c, CS_Contact__c, Scrum_Team__c, Scrum_Team__r.Business_Hours__c
                         FROM ADM_Work__c
                         WHERE Id IN :workIdsFromPostOrComment
                           AND RecordTypeId = :InvestigationRecordTypeId
                           AND Status__c = :WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT];
        } else {
            // Only reset SLA on Chatter post if user is not support and work.status is "Acknowledged" Or "Investigating"
            invsWorks = [SELECT Id, RecordTypeId, Out_of_SLA__c, Status__c, Severity_Level__c, Due_Date__c,
                                Assignee__c, CS_Contact__c, Scrum_Team__c, Scrum_Team__r.Business_Hours__c
                         FROM ADM_Work__c
                         WHERE Id IN :workIdsFromPostOrComment
                           AND RecordTypeId = :InvestigationRecordTypeId
                           AND (Status__c = :WORK_STATUS_INVESTIGATING OR Status__c = :WORK_STATUS_ACKNOWLEDGED )];
        }
        
        if(invsWorks.size() >0){
            // get business hours or use default
            Map<Id,Id> userToBusinessHoursMap = getUserBusinessHours( getSLAUSerIdsFromWork(invsWorks) );
            Map<Id,Id> teamToBusinessHoursMap = new Map<Id,Id>(); // we've loaded the data above, no need to requery, we'll populate it below
        
            for (ADM_Work__c workBH : invsWorks) {
                teamToBusinessHoursMap.put(workBH.Scrum_Team__c,workBH.Scrum_Team__r.Business_Hours__c);
                Id businessHoursId = getWorkBusinessHoursId(workBH, userToBusinessHoursMap, teamToBusinessHoursMap);
                
                resetSLADueTime(businessHoursId, workBH, startDateTime);
            }
            update invsWorks;
        }
    }

   /**
    * Examine Work objects and their previous state and determine if
    * SLA Due Time needs to be updated.
    *
    * @param worksNew List of Work we may want to set SLA due time
    * @param oldWorkMap The previous state of the work (i.e. from Trigger.old)
    * @param startDateTime The start time when we calculate the dueTime
    */
    @TestVisible 
    private static void applyInvestigationSLAsWithDatetime(List<ADM_Work__c> worksNew, Map<Id,ADM_Work__c> worksOldMap, DateTime startDateTime){
        List<ADM_Work__c> investigationsNew = new List<ADM_Work__c>();
        for (ADM_Work__c work : worksNew) {
            if (work.RecordTypeId == getRecordTypeFor(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION).Id) {
                investigationsNew.add(work);
            }
        }
        if (!investigationsNew.isEmpty()) {        
            Map<Id, Id> userToBusinessHoursMap = getUserBusinessHours( getSLAUserIdsFromWork(worksNew) );
            Map<Id, Id> teamToBusinessHoursMap = getTeamBusinessHours( getTeamIdsFromWorks(worksNew) );
            for (ADM_Work__c work : investigationsNew) {
                ADM_Work__c oldWork = (worksOldMap!=null) ? worksOldMap.get(work.Id) : null;
                Id businessHoursId = getWorkBusinessHoursId(work, userToBusinessHoursMap, teamToBusinessHoursMap);
                addSLAViolationIfNecessary(work, oldwork);
                resetSLADueDateIfNecessary(work, oldWork, businessHoursId, startDateTime);
            }
        }
    }
    
    /**
     * If the ADM_Work__c.Out_of_SLA__c field just went from false to true (e.g. because of our Time-Based Workflow rule),
     * and if there is at least one customer case, then add a new SLA_Violation__c record.
     * 
     * These SLA_Violation__c records will be committed in bulk in the method commitSLAViolationChanges()
     */
    private static void addSLAViolationIfNecessary(ADM_Work__c work, ADM_Work__c oldWork){
        // Only create violation record when work just changed OutOfSLA field from false to true    
        if(work.Out_of_SLA__c==true && workCanAddSLAViolation(work) && (oldWork==null || oldWork.Out_of_SLA__c==false)){
            worksOpenViolationList.add(work);
        }
    }
    
    
    /**
     * Perform DML operations for SLA Violation changes
     */
    public static void commitSLAViolationChanges(){
        if(!worksOpenViolationList.isEmpty()){
            List<ADM_Work__c> worksToCreateViolation = new List<ADM_Work__c>();
            worksToCreateViolation.addAll(worksOpenViolationList); // copy to local collection to avoid recursive triggers
            worksOpenViolationList.clear();
            ADM_WorkSLAViolationHelper.createAndInsertSLAViolations(worksToCreateViolation); // pass local collection
            
        }
        if(!worksCloseViolationList.isEmpty()){
            List<ADM_Work__c> worksToCloseViolation = new List<ADM_Work__c>();
            worksToCloseViolation.addAll(worksCloseViolationList); // copy to local collection to avoid recursive triggers
            worksCloseViolationList.clear();
            ADM_WorkSLAViolationHelper.closeAndUpdateSLAViolations(worksToCloseViolation); // pass local collection
        }
    }

    
    /**
    * Examine a Work object and its previous state and determine if its
    *   SLA Due Time needs to be updated.
    *
    * @param work The work we may want to set SLA due time
    * @param oldWork The previous state of the work (i.e. from Trigger.old)
    * @param startDateTime The start time when we calculate the dueTime
    */
    @TestVisible 
    private static void resetSLADueDateIfNecessary(ADM_Work__c work, ADM_Work__c oldWork, String bhsId, Datetime startDateTime) {
        if (work.RecordTypeId == getRecordTypeFor(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION).Id) {
          //if (work.Type__c == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
        
            // Add logic to handle closing investigation W-2563277
            // If the work has a Status where SLA doesn't apply, make sure the SLA Due Time is null          
            if(work.Status__c != WORK_STATUS_NEW && work.Status__c != WORK_STATUS_ACKNOWLEDGED 
                    && work.Status__c != WORK_STATUS_INVESTIGATING && work.Status__c != WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT){
                if(work.Due_Date__c != null){
                    work.Due_Date__c = null;
                }
                // Fix W-2836077 SLA Violations are left Open after Investigations are closed
                if(work.Out_of_SLA__c == true){
                    work.Out_of_SLA__c = false;
                    worksCloseViolationList.add(work);
                }        
                return;
            }
        
            Boolean statusChanged = false;
            Boolean severityChanged = false;
            Boolean teamChanged = false;
            Boolean caseAddedAfterViolation = false;
            Boolean markAsCriticalFeatureAfterViolation = false;
            
            if (oldWork!=null) {
                //W-3303818: Acknowledged to Investigating is meaningful update, means I am looking into it, so we should reset clock.
                //          But Investigating to Acknowledged shouldn't reset SLA clock since we put work back to not-working status.
                statusChanged = (work.Status__c != oldWork.Status__c) && validUpdateSLA(oldWork.Status__c, work.Status__c);
                severityChanged = work.Severity_Level__c != oldWork.Severity_Level__c;
                teamChanged = work.Scrum_Team__c != oldWork.Scrum_Team__c;
                
                // W-2653562 - If a new case is created against an investigation that had 0 cases, and the investigation is in SLA Violation = true,
                //             then reset the SLA clock (i.e. rather than immediately creating a violation) 
                caseAddedAfterViolation = work.Out_of_SLA__c && work.Number_of_Cases__c>0 && (oldWork.Number_of_Cases__c==0 || oldWork.Number_of_Cases__c==null);
                
                // W-3808814 - If investigation marked as "Critical CRM Feature or Org Inaccessible", and the investigation is in SLA Violation = true,
                //             then reset the SLA clcok (i.e. rather than immediatly creating a violation)
                markAsCriticalFeatureAfterViolation = work.Out_Of_SLA__c && work.Critical_CRM_Feature__c == true && oldWork.Critical_CRM_Feature__c==false;
            }
            
            // Update the SLA Due time if the investigation is freshly created, or:
            //  * status changed (except between Acknowledged and Investigating)
            //  * team assignment changed
            //  * severity level changed
            if (oldWork==null || statusChanged || severityChanged || teamChanged || caseAddedAfterViolation || markAsCriticalFeatureAfterViolation) {
                if (oldWork!=null && severityChanged && !(statusChanged || teamChanged)) {
                    // status is same so do normal extend or reset
                    changeSeverityLevelUpdateSLADueTime(bhsId, work, oldWork.Severity_Level__c, startDateTime);
                } else {
                    resetSLADueTime(bhsId, work, startDateTime);
                }
            }         
        }
    }
    
    
    /** 
    * Re-set SLA(Ack/Update/Support) due time for current work depends on work.status
    *
    * @param bhs The business hours when we calculate the dueTime
    * @param work The work we want to update SLA due time
    * @param startDateTime The start time when we calculate the dueTime
    */
    @TestVisible 
    private static void resetSLADueTime(String bhsId, ADM_Work__c work, DateTime startDateTime){
 
        // re-meet criteria, clear the flag and add work to the list which close the violation records later.
        if(work.Out_of_SLA__c == true){
            work.Out_of_SLA__c = false;
            worksCloseViolationList.add(work);
        }
        
        ADM_WorkSLAResponseTimeDefinitions.SLAResponseTime responseTime = getSLAResponseTime(work.Status__c, work.Severity_Level__c);
        if (responseTime == null){
            work.Due_Date__c = null;
        } else if (responseTime.respectsBusinessHours) {
            validateAndSetDueTime(work, BusinessHours.add(bhsId, startDateTime, responseTime.responseTimeInMilliseconds), Test.isRunningTest());
        } else {
            // does not observe business hours -- do regular date math instead of BusinessHours.add()
            validateAndSetDueTime(work, Datetime.valueOf(startDateTime.getTime() + responseTime.responseTimeInMilliseconds), Test.isRunningTest());
        }
    }
    
    /**
    * Re-calculate the correct SLA due time for current work after change severity level.
    * - When Severity Level is lowered (e.g. 2->3), *extend* the SLA due time 
    * - When Severity Level is increased (e.g. 3->2), reset the SLA due time 
    *
    * @param bhs The business hours when we calculate the dueTime
    * @param work The work we want to update SLA due time
    * @param oldSevLevel The previous severity level of work before update
    * @param startDateTime The start time when we calculate the dueTime, only for reset SLA Due Time, extend SLA Due Time is based on the work.Due_Date__c
    */
    @TestVisible 
    private static void changeSeverityLevelUpdateSLADueTime(String bhsId, ADM_Work__c work, String oldSevLevel, DateTime startDateTime){
        if(compareTwoSevLevel(oldSevLevel, work.Severity_Level__c)){
            // old SevLevel is numerically greater (lower priority) than new SevLevel, e.g. 3 > 2
            resetSLADueTime(bhsId, work, startDateTime);
        } else {
            // old sev level is a smaller # (higher severity) than the new sev level, e.g. sev 2 -> sev 3
            extendSLADueTime(bhsId, work, oldSevLevel);
        }
    }
    
    /**
    * Extend SLA (Ack/Update/Support) due time for current work depends of work.status. 
    *
    * @param bhs The business hours when we calculate the dueTime
    * @param work The work we want to update SLA due time
    * @param oldSevLevel The previous severity level of work before update
    */
    @TestVisible 
    private static void extendSLADueTime(String bhsId, ADM_Work__c work, String oldSevLevel){
        String newSevLevel = work.Severity_Level__c;
        if(newSevLevel == oldSevLevel || newSevLevel == '1') {
            // Extension should only occur if newSevLevel is lower priority (numerically greater)
            // than old sev level. This should naturally exclude sev 1s, but just in case...
            return;
        }
        
        // re-meet criteria, clear the flag and add work to the list which close the violation records later.
        if(work.Out_of_SLA__c == true){
            work.Out_of_SLA__c = false;
            worksCloseViolationList.add(work);
        }
        
        ADM_WorkSLAResponseTimeDefinitions.SLAResponseTime newSLA = getSLAResponseTime(work.Status__c, newSevLevel);
        if (newSLA == null) {
            work.Due_Date__c = null;
        } else {
            ADM_WorkSLAResponseTimeDefinitions.SLAResponseTime oldSLA = getSLAResponseTime(work.Status__c, oldSevLevel);
            validateAndSetDueTime(work, BusinessHours.add(bhsId, work.Due_Date__c, newSLA.responseTimeInMilliseconds - oldSLA.responseTimeInMilliseconds), Test.isRunningTest());
        }
    }
    
    /** HELPER METHODS **/
    
    /**
    * Returns the default Business Hours 
    *
    * @return The org's default business hours id
    */
    @TestVisible 
    private static BusinessHours getDefaultBusinessHours() {
        if(defaultBHs == null) defaultBHs = [SELECT id FROM BusinessHours WHERE isDefault = true];
        return defaultBHs;
    }
    
    /**
     * Returns the Id of the BusinessHours to use for this work record
     */
    private static Id getWorkBusinessHoursId(ADM_Work__c work, Map<Id,Id> userToBusinessHoursMap, Map<Id,Id> teamToBusinessHoursMap) {
        Id bhId;
        if (useSupportSLA(work.Status__c)) {
            if (work.CS_Contact__c != null) {
                bhId = userToBusinessHoursMap.get(work.CS_Contact__c);
            }        
        } else {
            bhId = userToBusinessHoursMap.get(work.Assignee__c);
            if (bhId==null) {
                bhId = teamToBusinessHoursMap.get(work.Scrum_Team__c);
            }
        }
        if (bhId==null) {
            BusinessHours bh = getDefaultBusinessHours();
            if (bh!=null) {
                bhId = bh.Id;
            }
        }
        return bhId;
    }

    private static Set<Id> getTeamIdsFromWorks(List<ADM_Work__c> works){
        if (works == null) return null;
        Set<Id> teamIds = new Set<Id>();
        for(ADM_Work__c work : works){
            teamIds.add(work.Scrum_Team__c);
        }
        return teamIds;
    }
    
    @TestVisible
    private static Map<Id, Id> getTeamBusinessHours(Set<Id> teamIds){
        Map<Id, Id> teamToBusinessHoursMap = new Map<Id, Id>();
        List<ADM_Scrum_Team__c> teams = [SELECT Id, Business_Hours__c FROM ADM_Scrum_Team__c WHERE Id IN :teamIds];
        for(ADM_Scrum_Team__c team : teams){
            if(team.Business_Hours__c == null){
                teamToBusinessHoursMap.put(team.Id, getDefaultBusinessHours().Id);
            }else{
                teamToBusinessHoursMap.put(team.Id, team.Business_Hours__c);
            }
        }
        return teamToBusinessHoursMap;
    }
    
    @TestVisible
    private static Set<Id> getSLAUserIdsFromWork(List<ADM_Work__c> works) {
        Set<Id> userIds = new Set<Id>();
        for(ADM_Work__c work : works){
            if (useSupportSLA(work.Status__c)) {
                userIds.add(work.CS_Contact__c);
            } else {
                userIds.add(work.Assignee__c);
            }
        }
        return userIds;
    }
    
    @TestVisible
    private static Map<Id, Id> getUserBusinessHours(Set<Id> userIds){
        Map<Id, Id> userToBusinessHoursMap = new Map<Id, Id>();
        List<ADM_User_Business_Hours__c> userBizHoursList = [SELECT User__c,Business_Hours__c FROM ADM_User_Business_Hours__c WHERE User__c IN :userIds];
        for(ADM_User_Business_Hours__c userBizHours : userBizHoursList){
            userToBusinessHoursMap.put(userBizHours.User__c, userBizHours.Business_Hours__c);
        }
        return userToBusinessHoursMap;
    }
    
    /**
     * Returns the SLA for this Status + Severity Level combo, or null if no SLA is defined
     * 
     * workStatus - the value of ADM_Work__c.Status__c
     * sevLevel - the value of ADM_Work__c.Severity_Level__c
     */
    @TestVisible
    private static ADM_WorkSLAResponseTimeDefinitions.SLAResponseTime getSLAResponseTime(String workStatus, String sevLevel) {
        ADM_WorkSLAResponseTimeDefinitions.SLAResponseTime responseTime;
        if (useAcknowledgementSLA(workStatus)){
            responseTime = responseTimeDefinitions.getInvestigationAckSLA(sevLevel);
        } else if (useUpdateSLA(workStatus)) {
            responseTime = responseTimeDefinitions.getInvestigationUpdateSLA(sevLevel);
        } else if (useSupportSLA(workStatus)){
            responseTime = responseTimeDefinitions.getInvestigationSupportSLA(sevLevel);
        }
        return responseTime;
    }


    
    /**
    * Returns whether the Acknowledgement SLA applies to this work (based on status) 
    *
    * @return true if Acknowledgement SLA applies, otherwise false
    */
    @TestVisible 
    private static Boolean useAcknowledgementSLA(String workStatus) {
        return workStatus == WORK_STATUS_NEW;
    }
    
    /**
    * Returns whether the Update SLA applies to this work (based on status) 
    *
    * @return true if Update SLA applies, otherwise false
    */
    @TestVisible 
    private static Boolean useUpdateSLA(String workStatus) {
        return workStatus == WORK_STATUS_ACKNOWLEDGED || workStatus == WORK_STATUS_INVESTIGATING;
    }
    
    /**
     * Returns whether the Update SLA applies to this work based on previous status.
     * 
     * @return true if valid status change applies, SLA doesn't change from investigating to acknowledged.
     */
    @TestVisible
    private static Boolean validUpdateSLA(String oldWorkStatus, String workStatus){
        return !(oldWorkStatus == WORK_STATUS_INVESTIGATING && workStatus == WORK_STATUS_ACKNOWLEDGED);
    }
    
    /**
    * Returns whether the Support SLA applies to this work (based on status) 
    *
    * @return true if Support SLA applies, otherwise false
    */
    @TestVisible 
    private static Boolean useSupportSLA(String workStatus) {
        return workStatus == WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT;
    }
    
    /**
    * Compare two sevLevels, return whether first one is bigger or not.
    *
    * @param sevLevel1 The first severity level
    * @param sevLevel2 The second severity level
    * @return true if sevLevel1 is numerically greater than sevLevel2 (e.g. 4 > 3 = true), otherwise, return false(equal or smaller)
    */
    @TestVisible 
    private static Boolean compareTwoSevLevel(String sevLevel1, String sevLevel2){
        if(sevLevel1.compareTo(sevLevel2) > 0){
            return true;
        }else {
            return false;
        }
    }
    
    public static RecordType getRecordTypeFor(String recordTypeName) {
        if (recordTypesMap==null) {
            List<RecordType> rtList = ADM_RecordType.getAllAsList();
            recordTypesMap = ADM_RecordType.mapRecordTypeListByName(rtList);      
        }
        return recordTypesMap.get(recordTypeName);
    }
    
    /**
    * Work can add SLA Violation record if more than 0 cases associated or checked check box Critical_CRM_Feature__c.
    * W-3808814
    *
    * @param work Investigation
    * @return true if either has > 0 cases or Critical_CRM_Feature__c is checked, otherwise, return false.
    */
    @TestVisible
    private static boolean workCanAddSLAViolation(ADM_Work__c work){
        return work.Number_of_Cases__c > 0 || work.Critical_CRM_Feature__c == true;
    }
    
    /**
     * Production Code to prevent new SLA Due Time calculated is something in the past.
     * W-3917533
     * 
     * @param work current investigation.
     * @param newDueDate new calculated due date
     * @param isTest boolean variable to check if current transaction is test or not.
     * 			isTest == true: current method is calling from other tests.
     * 			isTest == false: current method is calling from real transaction 
     * 								OR 
     * 								testValidateAndSetDueTime test which test this single method.
     * @return if valid, return new SLA due time, otherwise, return null.
     */
    @TestVisible
    private static void validateAndSetDueTime(ADM_Work__c work, DateTime newDueDate, Boolean isTest){
        if(isTest){
            work.Due_Date__c = newDueDate;
        } else {
            if(newDueDate < System.now())
                return ;
            else
                work.Due_Date__c = newDueDate;
        }
    }
    
}