public class ADM_WorkPerforceStatus {
	public static String OPEN = 'Open';
	public static String OPEN_ONCE = 'Open Once';
	public static String REQUESTED = 'Requested';
	public static String P4_WORK_NOT_OPEN_ERROR = 'Please set the Status to one of the following values when opening the Source Control Status: ' + ADM_TextUtils.joinSet(ADM_Work.STATUS_VALUES_OPEN, ',') + '.';
	public static String P4_ASSIGNEE_CANNOT_UPDATE_ERROR = 'The assignee of a work record can\'t open the Source Control Status. Put some Windex on it and try again.';

	public static String getOpen() {
		return OPEN;
	}

	public static String getOpenOnce() {
		return OPEN_ONCE;
	}
	
	public static String getPerforceErrorWhenWorkOpened(ADM_Work__c newWork, ADM_Work__c oldWork) {
		if(newWork.Perforce_Status__c != oldWork.Perforce_Status__c) {
			if(!ADM_TextUtils.isBlank(newWork.Perforce_Status__c) && newWork.Perforce_Status__c.toLowerCase().contains('open')) {
	        	if(ADM_Work.STATUS_VALUES_OPEN.contains(newWork.Status__c)) {  
	        		if(newWork.Assignee__c == UserInfo.getUserId()) {
						return P4_ASSIGNEE_CANNOT_UPDATE_ERROR;        			
	        		}      		
	        	} else {
	        		return P4_WORK_NOT_OPEN_ERROR;
	        	}	        	
	        }
		}
        return '';	
	}

	// --------------------------------- isPerforceStatusUpdated Begin ------------------------------------------ \\

	public static Boolean isPerforceStatusUpdated( ADM_Work__c nw, ADM_Work__c ow ) {
		Boolean returnValue = false;
		if ( nw.Perforce_Status__c != ow.Perforce_Status__c && nw.Perforce_Status__c != null ) {							
			if ( nw.Perforce_Status__c.contains(ADM_WorkPerforceStatus.getOpen()) || nw.Perforce_Status__c.contains(ADM_WorkPerforceStatus.getOpenOnce()) ) {
				returnValue = true;
			}			
		}
		return returnValue;
	}

	static testMethod void testIsPerforceStatusUpdated (){
		ADM_Work__c w_1 = new ADM_Work__c();
		ADM_Work__c w_2 = new ADM_Work__c();
		Boolean checkValue = false;

		ADM_Work__c[] work = [
			Select a.Assignee__c, a.Bug_Number__c, a.Closed__c, a.Closed_By__c, a.Closed_On__c, a.Customer__c, a.Description__c, a.Email_Subscription_ID__c, a.External_ID__c, a.Major_Func_Area__c, a.Minor_Func_Area__c, a.Perforce_Status__c, a.Priority__c, a.Product_Area__c, a.Product_Child__c, a.Product_Owner__c, a.QA_Engineer__c, a.Regressed__c, a.Related_URL__c, a.Resolved__c, a.Resolved_By__c, a.Resolved_On__c, a.Scheduled_Build__c, a.Scheduled_On__c, a.Scrum_Team__c, a.Status__c, a.Subject__c, a.System_Test_Engineer__c, a.Tech_Writer__c, a.Type__c, a.CreatedById, a.CreatedDate, a.Id, a.LastModifiedById, a.LastModifiedDate, a.Name, a.OwnerId
			from ADM_Work__c a
			limit 2
		];

		if ( work.size() > 1 ) {
			w_1 = work[0];
			w_2 = work[1];
			if ( w_1.Perforce_Status__c != w_2.Perforce_Status__c ) {
				if ( w_1.Perforce_Status__c == ADM_WorkPerforceStatus.getOpen() || w_1.Perforce_Status__c == ADM_WorkPerforceStatus.getOpenOnce() ) {
					checkValue = true;
				}
			}
		}

		System.assertEquals( checkValue, isPerforceStatusUpdated( w_1, w_2 ) );

	}

// --------------------------------- isPerforceStatusUpdated End ------------------------------------------ \\

	//================================================RUN beginning TESTS==================================\\

	static testMethod void testGetOpen() {
		System.assertEquals( OPEN, getOpen() );
	}

	static testMethod void testGetOpenOnce() {
		System.assertEquals( OPEN_ONCE, getOpenOnce() );
	}

	//================================================RUN ending TESTS==================================\\

}