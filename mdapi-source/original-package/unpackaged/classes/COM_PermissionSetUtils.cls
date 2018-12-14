public with sharing class COM_PermissionSetUtils {
    /**
     * Determine if the user ID is found within the given assignments
     */
    public static Boolean isAssigned(List<PermissionSetAssignment> assignments, Id userId) {
        for(PermissionSetAssignment assignment : assignments) {
            if(assignment.AssigneeId == userId) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Creates new assignments for the given users to the specified permission set. If an error occurs, they are
     * written to the console and logged as
     */
    @future
    public static void futureCreatePermissionAssignments(Id permissionSetId, Set<Id> assigneeIds) {
    	List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
        for(Id assigneeId : assigneeIds) {
            PermissionSetAssignment newAssignment = new PermissionSetAssignment();
            newAssignment.PermissionSetId = permissionSetId;
            newAssignment.AssigneeId = assigneeId;
            newAssignments.add(newAssignment);
        }
        
        Database.SaveResult[] saveResults = Database.insert(newAssignments, false);
        
        //process the results for insert errors
        List<ADM_GUS_Exception__c> thrownExceptions = new List<ADM_GUS_Exception__c>();
        for(Database.SaveResult saveResult : saveResults) {
            if(!saveResult.isSuccess()) {
                for(Database.Error databaseError : saveResult.getErrors()) {
                    System.debug(Logginglevel.ERROR, databaseError.getMessage());
                    thrownExceptions.add(new ADM_GUS_Exception__c(Name = 'Database.Error', Description__c = databaseError.getMessage()));
                }
            }
        }
        
        //save the exceptions
        try {
            if(!thrownExceptions.isEmpty()) {
        	   Database.insert(thrownExceptions, false);
            }
        } catch(Exception e) {
        	System.debug(LoggingLevel.ERROR, 'Unable to save exceptions. [' + e.getLineNumber() + '] ' + e.getMessage());
        }
    }
}