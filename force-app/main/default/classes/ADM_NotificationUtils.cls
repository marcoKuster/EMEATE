public with sharing class ADM_NotificationUtils {
    
    public static final String HIDDEN_RECIPIENT_DELIMITER = '::';
    public static final String HIDDEN_RECIPIENT_TYPE_DELIMITER = '==';
    
    public static final String AUTO_ASSIGNED_PREFIX = 'A';
    public static final String MANUALLY_ASSIGNED_PREFIX = 'M';
    
     
    public static void processSubscribers(List<ADM_Work__c> workList) {
       try {
            
            //must validate subscribers before removnig and deleting.  Validation errors will be thrown as exceptions
	        ADM_NotificationUtils.parseRecipientList(workList);  //group work to prevent user lookup matchUserInputToUsers() occuring once per user
	        //no exceptions thrown safe to remove and replace subscribers
	        ADM_NotificationUtils.removeSubscribers(workList);
	        ADM_NotificationUtils.saveSubscribers(workList);
       	} catch (DMLException dmle) {
            for (Integer i = 0; i < dmle.getNumDml(); i++) {
            	if (dmle.getDmlType(i) == System.Statuscode.INVALID_EMAIL_ADDRESS) {
            		throw dmle;
            	}
            }
        	
       	} catch (System.Exception e) {
			System.debug('exception thrown ' + e);
		}   
    }

    public static void removeSubscribers(List<ADM_Work__c> workIDs) {
        try {
            List<ADM_Work_Subscriber__c> subscribers = [select id from ADM_Work_Subscriber__c where WorkId__c = : workIDs];
            delete subscribers;
        } catch(System.Exception e) {
            
        }   
    }

    
    public static void removeAutoAssignedSubscribers(List<ADM_Work__c> workIDs) {
        try {
            List<ADM_Work_Subscriber__c> subscribers = [select id from ADM_Work_Subscriber__c where WorkId__c = : workIDs and Assignment_Type__c != 'Manually Assigned'];
            delete subscribers;
        } catch(System.Exception e) {
            
        }   
    }
    
    public static void saveSubscribers(List<ADM_Work__c> work) {
        try {
            
            List<ADM_Work_Subscriber__c> subscribers = parseRecipientList(work);
            insert subscribers;
            
            
        } catch (System.DmlException dmle) {
            for (Integer i = 0; i < dmle.getNumDml(); i++) {
            	if (dmle.getDmlType(i) == System.Statuscode.INVALID_EMAIL_ADDRESS) {
            		throw dmle;
            	}
            }
        	
        } catch(System.Exception e) {
            
        } 
    }
    
    
    public static String encodeEmailToLine(ADM_Work__c work) {
        return ADM_NotificationUtils.encodeRecipientList(ADM_NotificationUtils.convertEmailToLineToWorkSubscriberObjects(work));
    }
    
    /** 
     * Given a collection of email addresses, user aliases or user names, an encoded
     * list of subscribers is returned.
     */
    public static String encodeEmailToLine(String emailTo) {
        return ADM_NotificationUtils.encodeRecipientList(ADM_NotificationUtils.convertEmailToLineToWorkSubscriberObjects(emailTo));
    }
    
    /** 
     * Given a collection of email addresses, user aliases or user names, a list
     * of subscribers is returned.  Each of the returned subscribers will be 
     * 'Auto Assigned'.
     */
    public static List<ADM_Work_Subscriber__c> convertEmailToLineToWorkSubscriberObjects(String emailTo) {
    	List<ADM_Work_Subscriber__c> subscribers = new List<ADM_Work_Subscriber__c>();
        
        Set<String> userIdentifications = new Set<String>();
        for(String s : ADM_Subscriber.getCombinedSubscribers(emailTo)) {
            //only add if email is internal
            if(s.contains('salesforce.com')) {
                ADM_Work_Subscriber__c ws = new ADM_Work_Subscriber__c();
                ws.Assignment_Type__c = 'Auto Assigned';
                ws.Distribution_List__c = s;
                subscribers.add(ws);
            } else {
                //verify if the string matches a user in the system
                userIdentifications.add(s);
            }
        }
        
        //for those which aren't valid internal email addresses attempt to match to a user
        if(!userIdentifications.isEmpty()) {
	        Set<String> userIdentificationsWithOrgName = ADM_Subscriber.appendUserIDWithOrgName(userIdentifications);
	        
	        //add these users
	        List<User> users = ADM_WorkUser.getByAnyUserIdentification(userIdentificationsWithOrgName);
	        for(User u: users) {
	            
	            ADM_Work_Subscriber__c ws = new ADM_Work_Subscriber__c();
	            ws.Assignment_Type__c = 'Auto Assigned';
	            ws.Distribution_List__c = u.email;
	            subscribers.add(ws);
	        } 
        }
        
        return subscribers;
    }
    
    public static List<ADM_Work_Subscriber__c> convertEmailToLineToWorkSubscriberObjects(ADM_Work__c work) {
    	return convertEmailToLineToWorkSubscriberObjects(work.Email_Subscription_ID__c);
    }
    
    public static List<ADM_Work_Subscriber__c> buildWorkSubscribersFromWorkList(List<ADM_Work__c> works) {
    	 Map<Id, Set<String>> workUserEmailMap = ADM_Subscriber.getEmailsFromWork(works);
    	 
    	 List<ADM_Work_Subscriber__c> subscribers = new List<ADM_Work_Subscriber__c>();
         ADM_Work_Subscriber__c ws = null;
    	 //iterate map and create subscribers
    	 for(Id wid : workUserEmailMap.keySet()) {
    	 	for(String email: workUserEmailMap.get(wid)) {
    	 		ws = new ADM_Work_Subscriber__c();
	            ws.WorkId__c = wid;
	            ws.Assignment_Type__c = 'Auto Assigned';
	            ws.Distribution_List__c = email;
	            subscribers.add(ws);	
    	 	}	
    	 }
		return subscribers;
    }
    
    public static List<ADM_Work__c> removeAutoAssignedRecipients(List<ADM_Work__c> works) {
    	for(ADM_Work__c w: works) {
    		w.Encoded_Recipients_Txt_Area__c = removeAutoAssignedRecipients(w.Encoded_Recipients_Txt_Area__c);
    	}
    	return works;
    }
    
    /** 
     * Given a list of encoded recipients, the auto-assigned recipients are removed.
     *
     * If given the specified value 'M==jaredp::A=rickdeckard@salesforce.com', the
     * following value will be returned 'M==jaredp'
     */
    public static String removeAutoAssignedRecipients(String encodedReps) {
        
        String updatedEncodedReps = ''; 
            
        for(String s:encodedReps.split(ADM_NotificationUtils.HIDDEN_RECIPIENT_DELIMITER)) {
        
            List<String> els = s.split(ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER);
            
            if(els != null & els.size() == 2) {
                if(els[0].equalsIgnoreCase(ADM_NotificationUtils.AUTO_ASSIGNED_PREFIX)) {
                    //don't add to new list
                } else if(els[0].equalsIgnoreCase(ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX)) {
                    if(updatedEncodedReps.equals('')) {
                        updatedEncodedReps = s;
                    } else {
                        updatedEncodedReps = updatedEncodedReps + ADM_NotificationUtils.HIDDEN_RECIPIENT_DELIMITER + s;
                    }
                }   
            }
        }
        
        return updatedEncodedReps;
    } 
    
    /**
     * Given a list of subscribers, an encoded recipient string is returned.
     *
     * The format of the string is as follows
     * [recipient_tuple](::[recipient_tuple])*
     *
     * where [recipient_tuple] is
     * [prefix]==[identifier]
     *
     * where [prefix] is
     *  * A - for auto assignment type or
     *  * M - for manual assignment type
     *
     * where [identifier] is
     *  * User.Name or
     *  * ADM_Work_Subscriber__c.Distribution_List__c
     */
    public static String encodeRecipientList(List<ADM_Work_Subscriber__c> subscribers) {
        String encodedReps = '';
        for(ADM_Work_Subscriber__c ws: subscribers) {
            if(encodedReps != '') {
                encodedReps = encodedReps + ADM_NotificationUtils.HIDDEN_RECIPIENT_DELIMITER;
            }
            
            if(ws.Assignment_Type__c != null && ws.Assignment_Type__c.equalsIgnoreCase('Auto Assigned')) {
                encodedReps += ADM_NotificationUtils.AUTO_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER;
            } else {
                //deliberately default to Manual if anything other
                encodedReps += ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER;
            }
            
            if(ws.UserId__r.Name != null) {
                encodedReps = encodedReps + ws.UserId__r.Name;
            } else {
                encodedReps = encodedReps + ws.Distribution_List__c;
            }
        }
        
        return encodedReps;
    }
    
    
    public static List<ADM_Work_Subscriber__c> parseRecipientList(List<ADM_Work__c> workList) {
        
        List<ADM_Work_Subscriber__c> subscribers = new List<ADM_Work_Subscriber__c>();
        ADM_Work_Subscriber__c ws = null;
        List<String> userInputs = new List<String>();
        
        String encodedReps = '';

    	ADM_TextUtils textUtil = new ADM_TextUtils();
        
        //combine all recipients in work list so that they can share a query
        for(ADM_Work__c w: workList) {	
        	encodedReps = w.Encoded_Recipients_Txt_Area__c;
        	if(encodedReps != null && encodedReps != '') {
	        	encodedReps = textUtil.unEscapeHTML(encodedReps);
	            //build list of all users to prevent querying 1 at once
	            for(String rep:encodedReps.split(ADM_NotificationUtils.HIDDEN_RECIPIENT_DELIMITER)) {
	                List<String> reps = rep.split(ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER);
	                if(reps != null & reps.size() == 2) {
	                    userInputs.add(reps[1]);
	                }   
	            }
        	}
    	}	       
            
        //match input against the user object - anything which doesn't match is a distribution list
        Map<String, User> usersByName = matchUserInputToUsers(userInputs);
        
        //build list of work subscribers
	    for(ADM_Work__c w2: workList) {
	    	encodedReps =  w2.Encoded_Recipients_Txt_Area__c;   
	        if(encodedReps != null && encodedReps != '') {
		    	encodedReps =  textUtil.unEscapeHTML(encodedReps);   
		        for(String s:encodedReps.split(ADM_NotificationUtils.HIDDEN_RECIPIENT_DELIMITER)) {
		            List<String> els = s.split(ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER);
		            ws = new ADM_Work_Subscriber__c();
		            if(els != null & els.size() == 2) {
		                if(els[0].equalsIgnoreCase(ADM_NotificationUtils.AUTO_ASSIGNED_PREFIX)) {
		                    ws.Assignment_Type__c = 'Auto Assigned';
		                } else if(els[0].equalsIgnoreCase(ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX)) {
		                    ws.Assignment_Type__c = 'Manually Assigned';
		                }   
		                ws = ADM_NotificationUtils.populateSubscriber(ws, els[1], w2.id, usersByName);
		                if (ws != null) subscribers.add(ws);
		            }
		        }
	        }    
	    }     
    
        
    	return subscribers;
    }
     
   
    
    private static Map<String, User> matchUserInputToUsers(List<String> userInputs) {
        //match against the actual name's of users
        List<User> users = [select id, IsActive, Name from user where name in :userInputs order by LastLoginDate ASC];
        Map<String, User> usersByName = new Map<String, User>();
        for(User u : users) {
            //if a user has mulitple accounts their last login will be applied last
            usersByName.put((u.Name).toLowerCase(), u);
        }
        return usersByName;
    }
    
    public static ADM_Work_Subscriber__c populateSubscriber(ADM_Work_Subscriber__c ws, String input, String workID, Map<String, User> usersByName)  {
        ws.WorkId__c = workID;
        //create Work Subscriber with the correct field populated depending if the input matches a gus user or a distribution list (must end in salesforce.com)
        User u = usersByName.get(input.toLowerCase());
            
        if(u != null && u.IsActive) {
            ws.UserId__c = u.id;
        } else if(u != null && !u.IsActive) {
            //don't throw an error but ignore inactive user.  
            return null;
        } else if(input.contains('salesforce.com')) {
            ws.Distribution_List__c = input;
        } else {
            ADM_UnexpectedValueException ue = new ADM_UnexpectedValueException();
            ue.unexpectedValue = input;
            throw ue;
        }
        
        return ws;
    }
    
    
    
    public static void validateEncodedRecipients(String encodedReps) {
        //no need for work ID for validation - any errors will be thrown as ADM_UnexceptedValueException
        ADM_Work__c w = new ADM_Work__c();
        w.Encoded_Recipients_Txt_Area__c = encodedReps;
        ADM_NotificationUtils.parseRecipientList(new List<ADM_Work__c>{w});
    }
    
}