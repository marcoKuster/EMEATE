/**
 * Utility class for working with the SLA_Violation__c custom object
 */
global class ADM_WorkSLAViolationHelper {

    public final static String VIOLATIONTYPE_ACKNOWLEDGMENT = 'Acknowledgment';
    public final static String VIOLATIONTYPE_UPDATE = 'Update';
    public final static String VIOLATIONTYPE_SUPPORT = 'Support';
    
    public final static String VIOLATIONSTATUS_OPEN = 'Open';
    public final static String VIOLATIONSTATUS_CLOSED = 'Closed';
    
    
    /**
     * Inserts a new SLA_Violation__c related to the specified Work record and returns the Id,
     * or null if no record was created
     */
    webService static Id createAndInsertSLAViolation(String workId) {
        List<ADM_Work__c> works = [SELECT Id, RecordTypeId, Assignee__c, CS_Contact__c, Scrum_Team__c, Status__c, Severity_Level__c
                            FROM ADM_Work__c WHERE Id = :workId];
        if (works==null || works.isEmpty()) {
            return null;
        }
        
        SLA_Violation__c violation = createAndInsertSLAViolations(works).get(0);
        if (violation==null) {
            return null;
        } else {
            return violation.Id;
        }
    }
    
    /**
     * Inserts a new SLA_Violation__c related to each specified Work record and returns a collection of the results,
     * in the same order as the input List. Entries are null if the Work was not an Investigation.
     */
    public static List<SLA_Violation__c> createAndInsertSLAViolations(List<ADM_Work__c> works) {
        List<SLA_Violation__c> results = new List<SLA_Violation__c>();
        List<SLA_Violation__c> toInsert = new List<SLA_Violation__c>();
        for (ADM_Work__c work : works) {
        	SLA_Violation__c violation = createSLAViolation(work);
        	results.add(violation); // may be null
            if (violation!=null) {
                toInsert.add(violation); // only add if not null
            }
        }
        if (!toInsert.isEmpty()) {
	  		insert toInsert;
        }
        return results;
    }
    
    /**
     * Generates a new SLA_Violation__c object related to the specified Work record
     * but does not commit it to the DB
     */
    public static SLA_Violation__c createSLAViolation(ADM_Work__c work) {
        if (work==null || work.RecordTypeId != ADM_WorkSLAMonitoringHelper.getRecordTypeFor(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION).Id) {
            return null;
        }
        
        String violationType = getViolationType(work.Status__c);
        if (violationType == null) {
            return null;
        }
        
        return new SLA_Violation__c(
            Work__c = work.Id,
            Assigned_To__c = (violationType==VIOLATIONTYPE_SUPPORT) ? work.CS_Contact__c : work.Assignee__c,
            Team__c = work.Scrum_Team__c,
            Severity_Level__c = work.Severity_Level__c,
            Type__c = violationType,
            Status__c = VIOLATIONSTATUS_OPEN
            );
    }
    
    /**
     * For a list of ADM_Work__c records, finds and closes all open related SLA_Violation__c records
     */
    public static void closeAndUpdateSLAViolations(List<ADM_Work__c> works) {
        if (works==null||works.isEmpty()) return;
        
        List<SLA_Violation__c> violationsToClose = getViolationsToClose(works);
        if (!violationsToClose.isEmpty()) {
            update violationsToClose;
        }        
    }
    
    /////////// INTERNAL HELPER METHODS ///////////
    
    /**
     * Retrieves any open SLA_Violation__c objects related to the supplied Work records, and sets their statuses to Closed
     * (but does not update them in the DB)
     */
    @testVisible
    private static List<SLA_Violation__c> getViolationsToClose(List<ADM_Work__c> works) {
        Set<Id> workIds = new Set<Id>();
        for (ADM_Work__c work : works) {
            workIds.add(work.Id);
        }
        
        List<SLA_Violation__c> violationsToClose = [SELECT Id FROM SLA_Violation__c WHERE Status__c = :VIOLATIONSTATUS_OPEN AND Work__c IN :workIds];
        for (SLA_Violation__c violation : violationsToClose) {
            violation.Status__c = VIOLATIONSTATUS_CLOSED;
        }
        return violationsToClose;
    }
    
    /**
     * Returns the value for SLA_Violation__c.Type__c based on the value of ADM_Work__c.Status__c
     */
    @testVisible
    private static String getViolationType(String workStatus) {
        String violationType = null;
        if (workStatus =='New') { 
        	violationType = VIOLATIONTYPE_ACKNOWLEDGMENT; 
        } else if (workStatus=='Investigating' || workStatus=='Acknowledged') { 
        	violationType = VIOLATIONTYPE_UPDATE; 
        } else if (workStatus=='More Info Reqd from Support') { 
        	violationType = VIOLATIONTYPE_SUPPORT; 
        } 
        return violationType;
    }
    
    
}