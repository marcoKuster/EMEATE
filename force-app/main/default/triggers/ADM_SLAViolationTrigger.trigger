/**
 * This trigger automatically populates Closed_Date and Team fields when the SLA Violation record is closed,
 * and sets the count of SLA Violations on the parent Work record.
 */
trigger ADM_SLAViolationTrigger on SLA_Violation__c (before insert, before update) {

    try{
        Set<Id> workIds = new Set<Id>();
        
        for (SLA_Violation__c violation : Trigger.new) {
            // Set Closed_Date__c
            if (violation.Status__c == ADM_WorkSLAViolationHelper.VIOLATIONSTATUS_CLOSED && violation.Closed_Date__c == null) {
                violation.Closed_Date__c = System.now();
                
            } else if (violation.Status__c != ADM_WorkSLAViolationHelper.VIOLATIONSTATUS_CLOSED && violation.Closed_Date__c != null) {
                violation.Closed_Date__c = null;
            }
            
            // get the work.Id where Team__c is empty -- should generally only happen on insert
            if (violation.Team__c == null && violation.Work__c != null) {
                workIds.add(violation.Work__c);
            }
        }
        
        // set Team__c from the parent Work
        if (!workIds.isEmpty()) {
            Map<Id,ADM_Work__c> works = new Map<Id,ADM_Work__c>([SELECT Id,Scrum_Team__c FROM ADM_Work__c WHERE Id in :workIds]);
            
            for (SLA_Violation__c violationAddTeam : Trigger.new) {
                if (violationAddTeam.Team__c == null && violationAddTeam.Work__c != null) {
                    ADM_Work__c work = works.get(violationAddTeam.Work__c);
                    if (work != null && work.Scrum_Team__c !=null) {
                        violationAddTeam.Team__c = work.Scrum_Team__c;
                    }
                }
            }
        } 
    } catch (Exception e) {
        // log the error
        ADM_ExceptionHandler.saveException(e,'iSLA Exception happened in ADM_SLAViolationTrigger, exception is: ' + e);
    }
    
}