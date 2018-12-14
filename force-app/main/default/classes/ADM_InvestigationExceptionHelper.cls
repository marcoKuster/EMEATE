public class ADM_InvestigationExceptionHelper {

	private static final String PARENT_INVESTIGATION_RESOLVED = 'Parent Investigation Resolved';
	private static final String UNDER_REVIEW = 'Under Review';
	private static final String DECISION_EXPLANATION = 'This Exception Request was neither Accepted nor Rejected - its parent Investigation was closed.';

	/*
		This method is called from within the WorkTrigger after an update to an
		Investigation work item is detected and the Investigation is closed.
		In this case, we want to automatically close all related Exception Requests
		so the user doesn't have to.  We cannot schedule this in the @future because
		Org62 integration may process Investigations in batch, and you can't call
		a @future method in a batch environment.
	*/
	public static void closeAssociatedExceptionRequests(List<ADM_Work__c> workItems) {

		// If a passed-in work item isn't already closed, then alert to the log and return
		for (ADM_Work__c workItem : workItems) {
			if (workItem.Closed__c != 1) {
				System.debug('closedAssociatedExceptionRequests() -- received non-closed work item');
				return;
			}
		}

		List<ADM_Investigation_Exception__c> updateList = new List<ADM_Investigation_Exception__c>();

		for (ADM_Investigation_Exception__c ie : [ select Id, Status__c, Decision_Explanation__c
												       from ADM_Investigation_Exception__c
												       where Investigation__c in :workItems]) {
			// Only auto-close an IER if it is "Under Review"
			if (ie.Status__c.equalsIgnoreCase(UNDER_REVIEW)) {
				ie.Status__c = PARENT_INVESTIGATION_RESOLVED;
				ie.Decision_Explanation__c = DECISION_EXPLANATION;
				updateList.add(ie);
			}
		}

		// Bulk update the Exception Requests
		if (updateList.size() > 0)
			update updateList;
	}
}