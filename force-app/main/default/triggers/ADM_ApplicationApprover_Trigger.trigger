/*
 * This trigger sets the Approver_Email__c field if it is blank. 
 *
 *    @userstory a07B0000000MUaj
 *    @author snahm
 */
 

 trigger ADM_ApplicationApprover_Trigger on ADM_Application_Approver__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        /*
         * Fix the email field if it was not set by user
         */
         
        Set</*User*/ Id> approverUsers = new Set<Id>();

        for(ADM_Application_Approver__c appr : Trigger.new) {
            if (appr.Approver_Email__c == null || appr.Approver_Email__c.trim().length() == 0) {
                if (appr.Approver__c != null) {
                    approverUsers.add(appr.Approver__c);
                }
            }
        }
        Map<Id, User> approversMap = new Map<Id, User>([select Email from User where id in :approverUsers]);
        for(ADM_Application_Approver__c appr : Trigger.new) {
            if (appr.Approver_Email__c == null || appr.Approver_Email__c.length() == 0) {
                if (appr.Approver__c != null) {
                    User u = approversMap.get(appr.Approver__c);
                    if (u != null && u.Email != null) {
                        appr.Approver_Email__c = u.Email;
                    }
                }
            }
        }   
        return;
    }
}