/*
 *	Extension used with Visualforce button to set eRelease Requests' status to Released.
 *    @userstory W-3661313 https://gus.my.salesforce.com/a07B0000002raZMIAY 
 *    @author: snahm
 */
public with sharing class ADM_SetERRToReleasedExtension {

    private static ApexPages.StandardSetController thisSetController;
	private static List<eRelease_Request__c> selectedErrs;
    private static Id releaseId;
    
    public PageReference setErrsToReleased() {
        if (selectedErrs != null && selectedErrs.size() > 0) {
            for (eRelease_Request__c err : selectedErrs) {
                /* DEBUG OFF   System.debug('ADM_SetERRToReleasedExtension: Setting err to RELEASED - err=' + err); /* DEBUG */ 
                err.eRelease_Status__c = ADM_eReleaseRequest.ERR_RELEASED;
            }
            try {
                Database.update(selectedErrs);
            } catch (Exception e) {
            	System.debug('ADM_SetERRToReleasedExtension: Error: Could not update selected eRelease Requests to ' + 
                    ADM_eReleaseRequest.ERR_RELEASED + '. Error message: ' + e);
        		return thisSetController.cancel();
            }
        } else {
            return null;
        }
        return thisSetController.cancel();
    }
    
    public ADM_SetERRToReleasedExtension(ApexPages.StandardSetController setController) {

        /* DEBUG OFF   System.debug('ADM_SetERRToReleasedExtension: Prototype record is: ' + setController.getRecord()); /* DEBUG */
        thisSetController = setController;
        selectedErrs = setController.getSelected();
        /* DEBUG OFF   System.debug('ADM_SetERRToReleasedExtension: Selected records are: ' + selectedErrs); /* DEBUG */
        if (selectedErrs != null && selectedErrs.size() > 0) {
            releaseId = selectedErrs[0].Released_In__c;
            Set<Id> eReleaseRequestIDs = new Set<Id>();
            for (eRelease_Request__c err : selectedErrs) {
                eReleaseRequestIDs.add(err.Id);
            }
            try {
                /* DEBUG OFF   System.debug('ADM_SetERRToReleasedExtension: Querying eRelease Request Set: ' + eReleaseRequestIDs); /* DEBUG */
                selectedErrs = [SELECT eRelease_Status__c,Released_In__c  FROM eRelease_Request__c WHERE Id =: eReleaseRequestIDs];
            } catch (Exception e) {
            	System.debug('ADM_SetReleaseEventStatusExtension: Error: Could not access eRelease Request selected for setting eRelease Request Status' + 
               		'. Error message: ' + e);                
            }
        } else {
            /* DEBUG OFF   System.debug('ADM_SetERRToReleasedExtension.contructor: No records selected.'); /* DEBUG */
	        ApexPages.Message noERRsSelected = new ApexPages.Message(ApexPages.Severity.ERROR, 
	        	'No eRelease Requests were selected. Select records or click "View All" to select records.');
			ApexPages.addMessage(noERRsSelected);
        }
    }
}