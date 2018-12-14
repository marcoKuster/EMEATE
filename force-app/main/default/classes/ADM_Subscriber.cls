/**

* Copyright, 2008, SALESFORCE.com

* All Rights Reserved

* Company Confidential

*

* Provides a wrapper around CRUD functionality for ADM_Subscriber records, grouping them in a central location

 

*/



public class ADM_Subscriber {    

    public static final String orgName = '@' + ADM_Organization.getOrganizationName().toLowerCase() + '.com';
    public static final String salesforceDomain = '@' + ADM_WorkUtils.getSalesforceDomain();  
    public static final Pattern emailPattern = Pattern.compile('@');

    
    public static final String USERNAMES_KEY = 'userNames';
    public static final String ALIASES_KEY = 'aliases';
    public static final String EMAIL_ADDRESSES_KEY = 'emailAddresses';
    public static final String SFDC_ADDRESSES_KEY = 'sfdcAddresses';

    private static final Pattern WHITESPACE_PATTERN = Pattern.compile('\\s');
    private static final Pattern EMAIL_ID_DELIMITER_PATTERN = Pattern.compile(';|,');
    

    

    
    //TODO: Breakdown this method to remove unconventional Map<Id, ADM_Work__c> arg used to allow other objects to use work as a transport while using their own id as the key.  See Assignment Rule Trigger.

    public static Map<Id, List<String>> getAllFromWork(Map<Id, ADM_Work__c> workMap) {

        

        Map<Id, List<String>> notFoundMap = new Map<Id, List<String>>();

        
        List<ADM_Work__c> works = new List<ADM_Work__c>();

        for(String key : workMap.keySet()) {

        	works.add(workMap.get(key));
        }

        

		//combine the to field of all work records to allow users to be looked up with 1 query       

        Set<String> userIdentifications = getSetOfCombinedSubscribers(works);

        Set<String> userIdentificationsWithOrgName = appendUserIDWithOrgName(userIdentifications);        

        //bulk lookup users

        List<User> users = ADM_WorkUser.getByAnyUserIdentification(userIdentificationsWithOrgName); 

        //to help match users in an efficient manor - convert to Map.  User is keyed by username, alias, email etc.

        Map<String, User> userMap = ADM_WorkUser.convertUserListToUserIdentifierMap(users);           

        //sort the useridentifications by work to allow personal error message

        Map<Id, Set<String>> userIdentifcationByWorkID = ADM_Subscriber.getSubscribersSimple(workMap);

        

        User user = null;

        //for each work records user identifications see if a match is found.  If not add the invalid value to the notFoundValues map
      
        for(String key : workMap.keySet()) {       	

        	List<String> notFoundValues = new List<String>();        	

	        if(userIdentifcationByWorkID != null && userIdentifcationByWorkID.containsKey(key)) {        	          

	            for(String userIdentifier : userIdentifcationByWorkID.get(key)) {

	            	if(userIdentifier != null & userIdentifier.trim().length() > 0) {

		            	user = userMap.get(userIdentifier); 

		                if(user == null) {                    

		                    notFoundValues.add(userIdentifier);  

		                }

		                //reset user for next time

		                user = null;

	            	}                       

	            }                   

	        }

	        if(notFoundValues != null && notFoundValues.size() > 0) notFoundMap.put(key, notFoundValues);

	        

        }

                               

         
        return notFoundMap;      

    }

    

    public static Map<String, Set<String>> getSubscribers(ADM_Work__c work) {

    	return ADM_Subscriber.getSubscribers(new List<ADM_Work__c>{work});

    }

    

    public static Map<String, Set<String>> getSubscribers(List<ADM_Work__c> works) {

    	ADM_TextUtils textUtils = new ADM_TextUtils();

    	Map<String, Set<String>> subscribers = new Map<String, Set<String>>();

        Set<String> aliases = new Set<String>();

        Set<String> userNames = new Set<String>();

        Set<String> emailAddresses = new Set<String>();

        Set<String> sfdcAddresses = new Set<String>();        

        List<String> ArrEmailSubscriptionId = new List<String>();

        Pattern p = Pattern.compile(';|,');

        Pattern nonWhiteSpacePattern = Pattern.compile('\\S');

        Pattern whiteSpacePattern = Pattern.compile('\\s');

        String StrEmailSubscriptionId;

     	

     	for(ADM_Work__c work : works) {

	     	

	     	if(work.Email_Subscription_ID__c != null) {    

		        // get rid of all , and ; put into new var        

		        StrEmailSubscriptionId = textUtils.escapeGtAndLt(work.Email_Subscription_ID__c);

		        StrEmailSubscriptionId = p.matcher(StrEmailSubscriptionId).replaceAll(' ');	        

		        // split the new var into array based upon whitespace

		        String[] subscriptionIds = whiteSpacePattern.split(StrEmailSubscriptionId);

			        

		        for(String subscriptionId : subscriptionIds) {

		        	ArrEmailSubscriptionId.add(subscriptionId);	

		        }

			    

			    for(String s : ArrEmailSubscriptionId) {

			        // loop over the user alias to evaluate if they are not an empty string

			        if(s != '') {                        

			            Matcher emailMatcher = emailPattern.matcher(s);

			            // we are allowing ppl to send out to email addresses that end in salesforce.com therefore, i don't want to add this 

			            // to the list of things i will check against                                        

			            if(emailMatcher.find()) {

			            	if(s.toLowerCase().contains('salesforce.com')) {                    

			                	sfdcAddresses.add(s);

			            	} else {

			            		userNames.add(s);

			            	}

			            } else if(s.toLowerCase().contains(orgName)) {

			                userNames.add(s + orgName);                         

			            } else {

			            	aliases.add(s);                   

			                emailAddresses.add(s + salesforceDomain);

			            }

			        }

			    }

	     	}    

     	}    

	    

	    subscribers.put(USERNAMES_KEY, userNames);

	    subscribers.put(ALIASES_KEY, aliases);

	    subscribers.put(EMAIL_ADDRESSES_KEY, emailAddresses);

	    subscribers.put(SFDC_ADDRESSES_KEY, sfdcAddresses);

	    

	   

	    

	    return subscribers;

    }

    

    public static Map<Id,Set<String>> getSubscribersSimple(Map<Id, ADM_Work__c> works) {

		ADM_TextUtils textUtils = new ADM_TextUtils(); //this guy could be static

		Set<String> userIdentifications = new Set<String>();

		Map<Id,Set<String>> userIDByWork = new Map<id,Set<String>>();

		List<String> ArrEmailSubscriptionId = new List<String>();

        Pattern p = Pattern.compile(';|,');

        Pattern nonWhiteSpacePattern = Pattern.compile('\\S');

        Pattern whiteSpacePattern = Pattern.compile('\\s');

        String StrEmailSubscriptionId;

		
		for(String key : works.keySet()) {

	     	ADM_Work__c work = works.get(key);

	     	if(work.Email_Subscription_ID__c != null) {    

		        // get rid of all , and ; put into new var        

		        StrEmailSubscriptionId = textUtils.escapeGtAndLt(work.Email_Subscription_ID__c);

		        StrEmailSubscriptionId = p.matcher(StrEmailSubscriptionId).replaceAll(' ');	        

		        // split the new var into array based upon whitespace

		        String[] subscriptionIds = whiteSpacePattern.split(StrEmailSubscriptionId);

		        for(String subscriptionId : subscriptionIds) {

		        	 if(subscriptionId != null || subscriptionId != '') {

		        	 	userIdentifications.add(subscriptionId);

		        	 }

		        }

		        userIDByWork.put(key, userIdentifications);

	     	}    

     	}

     	
     	return userIDByWork;  

    }

    /**
     * Gets a set of subscribers from the Email_Subscription_ID__c property of 
     * the given work objects.
     */
    public static Set<String> getSetOfCombinedSubscribers(List<ADM_Work__c> works) {
		Set<String> userIdentifications = new Set<String>();

		for(ADM_Work__c work : works) {
            if(work.Email_Subscription_ID__c != null) {
                userIdentifications.add(work.Email_Subscription_ID__c);
            }
        }

        return getSetOfCombinedSubscribers(userIdentifications);
    }

    /**
     * Given a list of e-mail address, split then by the following delimiters
     * <ul>
     * <li>semicolon - ;
     * <li>pipe - |
     * <li>comma - ,
     * </ul>
     *
     * If the value specified is null, an empty list is returned.
     */
    public static Set<String> getCombinedSubscribers(String emailAddresses) {
    	if(emailAddresses == null) {
    		return new Set<String>();
    	}

        //encode all of the less than and greater than symbols
        //TODO: escapeGtAndLt should be static
        String StrEmailSubscriptionId = (new ADM_TextUtils()).escapeGtAndLt(emailAddresses);

        // replace delimiter characters with a space
        StrEmailSubscriptionId = EMAIL_ID_DELIMITER_PATTERN.matcher(StrEmailSubscriptionId).replaceAll(' ');         

        // split the new var into array based upon whitespace
        Pattern whiteSpacePattern = Pattern.compile('\\s');
        String[] subscriptionIds = WHITESPACE_PATTERN.split(StrEmailSubscriptionId);

        //convert the array into a set
        Set<String> userIdentifications = new Set<String>();
        for(String subscriptionId : subscriptionIds) {
            if(subscriptionId != null || subscriptionId != '') {
                userIdentifications.add(subscriptionId);
            }
        }
        return userIdentifications;
    }

    /**
     * Gets the list of subscribers from the given list of values. See 
     */
    public static Set<String> getSetOfCombinedSubscribers(Set<String> values) {
        Set<String> userIdentifications = new Set<String>();
        for(String value : values) {
            if(value != null) {
                userIdentifications.addAll(getCombinedSubscribers(value));
            }    
        }
        return userIdentifications;  
    }

    testMethod static void testGetSetOfCombinedSubscribers() {
    	ADM_Work__c work = ADM_Work.createTestWork();
    	work.Email_Subscription_ID__c = 'jhatton awilliams rkimble';
    	Set<String> subscriberIDs = ADM_Subscriber.getSetOfCombinedSubscribers(new List<ADM_Work__c>{work});
    	System.assert(subscriberIDs != null);
    	System.assertEquals(3, subscriberIDs.size(), 'Received:' + subscriberIDs);
    }

    testMethod static void testGetCombinedSubscribers() {
        String subscribers = 'jhatton awilliams rkimble';
        Set<String> subscriberIDs = ADM_Subscriber.getCombinedSubscribers(subscribers);
    	System.assert(subscriberIDs != null);
    	System.assertEquals(3, subscriberIDs.size(), 'Received:' + subscriberIDs);
    }

    testMethod static void testGetCombinedSubscribersWithSingle() {
    	String subscribers = 'gusteam@salesforce.com';
        Set<String> subscriberIDs = ADM_Subscriber.getCombinedSubscribers(subscribers);
        System.assert(subscriberIDs != null);
        System.assertEquals(1, subscriberIDs.size(), 'Received:' + subscriberIDs);
    }

    testMethod static void testGetAllFromWork() {

    	ADM_Work__c work = ADM_Work.createTestWork();

    	User user = [select username from User limit 1];

    	String username = user.username;

    	work.Email_Subscription_ID__c = username;

    	//System.assert(ADM_Subscriber.getAllFromWork(work) != null);

    	// fixme

    }

    /**
     * Returns a new set of user identifications which contains all of the original
     * user IDs plus a new '@' organization name.  The domain for the organization
     * will be taken from the current UserName (from UserInfo.getUserName());
     */
    public static Set<String> appendUserIDWithOrgName(Set<String> useridentifications) {
    	Set<String> extendedUserIDs = new Set<String>();
    	for(String userid : useridentifications) {
    		extendedUserIDs.add(userid);

    		if(!userid.contains('@')) {
    			extendedUserIDs.add(userid + UserInfo.getUserName().substring(UserInfo.getUserName().indexOf('@')) );
    		} 
    	}

    	return extendedUserIDs;
    }

    testMethod static void testAppendUserIDWithOrgName() {
    	Set<String> users = new Set<String>{'jblogs', 'jblow@org.com'};
    	Set<String> usersWithOrgName = ADM_Subscriber.appendUserIDWithOrgName(users);

    	//we expect 3 - the two originals and one extra: jblogs@[org name]
    	System.assertEquals(3, usersWithOrgName.size());
    	String orgPostfix = UserInfo.getUserName().substring(UserInfo.getUserName().indexOf('@'));
    	System.assert(usersWithOrgName.contains('jblogs' + orgPostfix));
    }

    public static Set<String> getEmailsFromWork(ADM_Work__c work) {

     	 Map<Id, Set<String>> emailsByWorkID = ADM_Subscriber.getEmailsFromWork(new List<ADM_Work__c>{work});

     	 if(emailsByWorkID != null && emailsByWorkID.containsKey(work.id)) {

     	 	return emailsByWorkID.get(work.id);

     	 } else {

     	 	return null;

     	 }

    }

    

    public static  Map<Id, Set<String>> getEmailsFromWork(List<ADM_Work__c> works) { //2 SOQL calls

        //combine user info of entire work list so that if can be looked up in a batch and then seperated out by work id

        Set<String> userIdentifications = getSetOfCombinedSubscribers(works);

        Set<String> userIdentificationsWithOrgName = appendUserIDWithOrgName(userIdentifications);

        List<User> users = ADM_WorkUser.getByAnyUserIdentification(userIdentificationsWithOrgName); //1 SOQL query

        ADM_Scrum_Team__c[] scrumTeams = ADM_ScrumTeam.get('Name', userIdentifications); //1 SOQL

        return ADM_Subscriber.seperateUsersByWorkID(users, works, scrumTeams);

    }   

	

	testMethod static void testGetEmailsFromWorkByUserName() {

    	ADM_Work__c work = ADM_Work.createTestWork();

    	User user = [select username from User limit 1];

    	String username = user.username;

    	work.Email_Subscription_ID__c = username;

    	Map<Id, Set<String>> emailsByWorkID = ADM_Subscriber.getEmailsFromWork(new List<ADM_Work__c>{work});

    	System.assert(emailsByWorkID != null);

    	System.assertEquals(1, emailsByWorkID.size(), 'Data:' + emailsByWorkID);

    }	

	

	testMethod static void testGetEmailsFromWorkByAlias() {

		ADM_Work__c work = ADM_Work.createTestWork();

		work.Email_Subscription_ID__c = 'jhatton';

		Map<Id, Set<String>> emailsByWorkID = ADM_Subscriber.getEmailsFromWork(new List<ADM_Work__c>{work});

		System.assert(emailsByWorkID != null);

		System.assertEquals(1, emailsByWorkID.size(), 'Data:' + emailsByWorkID);

	}

    /**
     * Gets a map of subscribers for the given work objects where the key of the
     * map is the work ID.
     *
     * This method should never return null.
     */
	public static Map<Id, List<ADM_Work_Subscriber__c>> getWorkSubscribers(List<ADM_Work__c> works) {
		
        Map<Id, Set<String>> subscriberEmailsByWorkID = new Map<Id, Set<String>>();
        
        //store ids in one list suitable for bulk lookup of subscribers
        List<Id> workIDs = new List<Id>();
        for(ADM_Work__c work: works) {
            workIDs.add(work.id);
        }

        //bulk lookup of subscribers
        List<ADM_Work_Subscriber__c> subscribers = ADM_Work_Subscriber.getByList(workIDs);

        Set<String> emailAddresses = null;

        Map<Id, List<ADM_Work_Subscriber__c>> subscriberMap = new Map<Id, List<ADM_Work_Subscriber__c>>();
        for(ADM_Work_Subscriber__c subscriber : subscribers) {
        	
        	//if we already have a list of subscribers in the map, add the new
        	//subscriber to it. otherwise create a list and add it to the map
        	List<ADM_Work_Subscriber__c> workSubscribers = null; 
        	if(subscriberMap.containsKey(subscriber.WorkId__c)) {
        		workSubscribers = subscriberMap.get(subscriber.WorkId__c);
        	} else {
        		workSubscribers = new List<ADM_Work_Subscriber__c>();
        		subscriberMap.put(subscriber.WorkId__c, workSubscribers);
        	}
        	
        	workSubscribers.add(subscriber);
        }
        return subscriberMap;
	}

	public static Map<Id, Set<String>> getEmailsForWorkSubscribers(List<ADM_Work__c> works) {

		Map<Id, Set<String>> subscriberEmailsByWorkID = new Map<Id, Set<String>>();

		//store ids in one list suitable for bulk lookup of subscribers

		List<Id> workIDs = new List<Id>();

		for(ADM_Work__c work: works) {

			workIDs.add(work.id);

		}

		//bulk lookup of subscribers		

		List< ADM_Work_Subscriber__c > subscribers = ADM_Work_Subscriber.getByList(workIDs);

		
		Set<String> emailAddresses = null;

		for(ADM_Work__c w : works) {

			emailAddresses = matchSubscriberEmailWithWorkID(subscribers, w.id);

			
			if(emailAddresses != null && emailAddresses.size() > 0) {

				subscriberEmailsByWorkID.put(w.id, emailAddresses);

			}

		}

		return subscriberEmailsByWorkID;

	}

	

	testMethod static void testGetEmailsForWorkSubscribers() {

		ADM_Work__c work = ADM_Work.createTestWork();

		User user = [select id, email, username from user limit 1];

		ADM_Work_Subscriber__c ws = new ADM_Work_Subscriber__c(WorkId__c = work.id, UserId__c = user.id);

		Database.insert(ws);

		Map<Id, Set<String>> emailsByWorkID = ADM_Subscriber.getEmailsForWorkSubscribers(new List<ADM_Work__c>{work});

		System.assert(emailsByWorkID != null);

		//TODO test fails as ADM_Work_Subscriber.email is not populated - should the code really be using user.email?

		System.assertEquals(1, emailsByWorkID.size(), 'Data:' + emailsByWorkID);

	}

    /**
     * Given a list of subscribers, all of the user IDs are returned
     */
    public static Set<Id> getUserIds(List<ADM_Work_Subscriber__c> subscribers) {
    	Set<Id> userIds = new Set<Id>();
        for(ADM_Work_Subscriber__c subscriber : subscribers) {
        	if(subscriber.UserId__c != null && !userIds.contains(subscriber.UserId__c)) {
        		userIds.add(subscriber.UserId__c);
        	}
        }
        return userIds;
    }
    
    public static String getEmailAddress(ADM_Work_Subscriber__c subscriber) {
    	String emailAddress = null;
    	
    	if(subscriber.UserId__r.Email != null) {
            emailAddress = subscriber.UserId__r.Email;
        } else if(subscriber.Distribution_List__c != null) {
            emailAddress = subscriber.Distribution_List__c;
        }
        
        return emailAddress;
    } 

	private static Set<String> matchSubscriberEmailWithWorkID(List<ADM_Work_Subscriber__c> subscribers, Id workID) {

		Set<String> emailAddresses = new Set<String>();

		for(ADM_Work_Subscriber__c s : subscribers) {

			if(s.WorkId__r.Id == workID) {
				String emailAddress = getEmailAddress(s);
				if(emailAddress != null) {
					emailAddresses.add(emailAddress);
				}
			}

		}

		return emailAddresses;

	}

	

	

	

	

	

	private static Map<Id, Set<String>> seperateUsersByWorkID(List<User> users, List<ADM_Work__c> works, List<ADM_Scrum_Team__c> scrumTeams) {

		Map<Id, Set<String>> emailAddressesByWorkID = new Map<Id, Set<String>>();

		Set<String> emailAddresses;

		//evaluate each work reocrd to see if it references a user in the list.  

		for(ADM_Work__c work : works) {

			emailAddresses = new Set<String>();

        	Set<String> userIdentifications = ADM_Subscriber.getSetOfCombinedSubscribers(new List<ADM_Work__c>{work});

	        for(String s: userIdentifications) {

                User user = matchUser(s, users, scrumTeams);

                if(user != null && user.Email != null) {                    

                    emailAddresses.add(user.Email);    

                } else if (s.toLowerCase().contains('salesforce.com')) {                    

		            emailAddresses.add(s);

		        }   

	        }

			//store the email addresses relevant for the this work item

			emailAddressesByWorkID.put(work.id, emailAddresses);

		}	

		return emailAddressesByWorkID;

	}

	

    public static User matchUser(String alias, User[] users, ADM_Scrum_Team__c[] scrumTeams) {

        String sfdcMail = alias + salesforceDomain;        

        User newUser = new User();

               

        if(users != null && users.size()> 0) {        	        

            for(User user : users) {          



                if(user.Alias.equalsIgnoreCase(alias)) return user;

                if(user.Email.equalsIgnoreCase(alias)) return user;

                if(alias.toLowerCase().contains(orgName.toLowerCase())) {

                	if(user.UserName.equalsIgnoreCase(alias)) return user;

                } else {

                	if(user.UserName.equalsIgnoreCase(alias + orgName)) return user;

                }

                if(user.UserName.equalsIgnoreCase(alias)) return user;

                if(user.Email.equalsIgnoreCase(sfdcMail)) return user;

            }        

            for(ADM_Scrum_Team__c scrumTeam : scrumTeams) {        

            	if(scrumTeam.Name.equalsIgnoreCase(alias)) return newUser;

            }   

        }                                

        

        return null;   

    }

    

       

    

    public static ADM_Work_Subscriber__c[] getAllBy(String columnName, List<String> columnValues) {

        ADM_Work_Subscriber__c[] els = new ADM_Work_Subscriber__c[]{};

        

        try{

            

            if(columnName.equalsIgnoreCase('workid__c')) {                

                els = [ 

                    select a.Name, a.Id, a.WorkId__c, a.UserId__c, a.UserId__r.Username, a.UserId__r.Name, a.UserId__r.Email  

                    from ADM_Work_Subscriber__c a 

                    where WorkId__c in :columnValues 

                ];

            } else if(columnName.equalsIgnoreCase('name')) {                

                els = [ 

                    select a.Name, a.Id, a.WorkId__c, a.UserId__c, a.UserId__r.Email 

                    from ADM_Work_Subscriber__c a 

                    where Name in :columnValues 

                ];

            }  else if(columnName.equalsIgnoreCase('userid__c')) {                 

                els = [                  

                    select a.Name, a.Id, a.WorkId__c, a.UserId__c, a.UserId__r.Email 

                    from ADM_Work_Subscriber__c a 

                    where UserId__c in :columnValues 

                ];

            } else if(columnName.equalsIgnoreCase('id')) {                

                els = [ 

                    select a.Name, a.Id, a.WorkId__c, a.UserId__c, a.UserId__r.Email 

                    from ADM_Work_Subscriber__c a 

                    where Id in :columnValues 

                ];

            }

                            

            return els;

        }

        

        catch(System.Exception e) {

            return els;

        }

    }    

    

    testMethod static void testGetAllBy() {

    	ADM_Work__c work = ADM_Work.createTestWork();

    	ADM_Work_Subscriber__c subscriber = new ADM_Work_Subscriber__c();

    	User user = [select username from User limit 1];

    	subscriber.WorkId__c = work.id;

    	subscriber.UserId__c = user.id;    	

    	Database.insert(subscriber);

    	

    	List<String> columnValues = new List<String>();

    	columnValues.add(work.id);

    	System.assert(ADM_Subscriber.getAllBy('workid__c', columnValues) != null);

    	System.assert(ADM_Subscriber.getAllBy('workid__c', columnValues).size()> 0);

    	columnValues = new List<String>();

    	columnValues.add(subscriber.id);    	

    	System.assert(ADM_Subscriber.getAllBy('id', columnValues) != null);

    	columnValues = new List<String>();

    	columnValues.add(subscriber.userid__c);

    	System.assert(ADM_Subscriber.getAllBy('userid__c', columnValues) != null);

    	columnValues = new List<String>();

    	columnValues.add(subscriber.name);

    	System.assert(ADM_Subscriber.getAllBy('name', columnValues) != null);

    }	

    

    public static ADM_Work_Subscriber__c match(ADM_Work_Subscriber__c[] elements, String id) {

        List<ADM_Work_Subscriber__c> matches = new List<ADM_Work_Subscriber__c>();

        ADM_Work_Subscriber__c match = new ADM_Work_Subscriber__c();

        

        for(ADM_Work_Subscriber__c el : elements) {        

            if(el.UserId__c == id) {                

                matches.add(el);

            }   

        }

        

        if(matches.size()> 1) {

            //prolly need to throw an error here because it should not match more than 1 id

            //this is prolly an instance of me testing when i was getting the subscriber stuff setup for the visual force pages...

            //delete extras

        } else if(matches.isEmpty()) {

            //don't throw an error cuz it has not returned a match

        } else if(matches.size() == 1) {

            //good to go cuz we should only have 1 match for a unique id... i think

            match = matches.get(0);

        }

        

        return match;

    }

    

    testMethod static void testMatch() {

    	ADM_Work__c work = ADM_Work.createTestWork();

    	ADM_Work_Subscriber__c sub_control = new ADM_Work_Subscriber__c();

    	ADM_Work_Subscriber__c sub_variable = new ADM_Work_Subscriber__c();

    	List<ADM_Work_Subscriber__c> subscribers = new List<ADM_Work_Subscriber__c>();

    	

    	User control = [select username, id from User limit 1];

    	User variable = [select username, id from User where id !=: control.id limit 1];

    	 

    	sub_control.WorkId__c = work.id;

    	sub_control.UserId__c = control.id;    	

    	Database.insert(sub_control); 

    	

    	sub_variable.WorkId__c = work.id;

    	sub_variable.UserId__c = control.id;    	

    	Database.insert(sub_variable);

    	

    	subscribers.add(sub_control);

    	
    	System.assert(match(subscribers, control.id) == sub_control);    	

    	System.assert(match(subscribers, variable.id) != sub_control);

    }

    

    public static ADM_Work_Subscriber__c get(String userId, String workId) {

        ADM_Work_Subscriber__c el = new ADM_Work_Subscriber__c();

        ADM_Work_Subscriber__c[] els;

        List<String> columnValues = new List<String>();

        String columnName = 'workId__c';

        

        columnValues.add(workId);        

        els = getAllBy(columnName, columnValues);

        el = match(els, userId);

        

        return el;

    }



	testMethod static void testGet() {

    	ADM_Work__c work = ADM_Work.createTestWork();

    	ADM_Work_Subscriber__c subscriber = new ADM_Work_Subscriber__c();

    	User user = [select username from User limit 1];

    	subscriber.WorkId__c = work.id;

    	subscriber.UserId__c = user.id;    	

    	Database.insert(subscriber);

    	System.assert(ADM_Subscriber.get(subscriber.UserId__c, subscriber.WorkId__c) != null);

    }	



    public static String remove(ADM_Work_Subscriber__c subscriber) {

        String returnVar = '';      

        Database.DeleteResult dr = Database.delete(subscriber, false);

        

        if(dr.isSuccess()) {

            returnVar = 'Subscribe';

        } else {

            returnVar =  'Error';

        }

        

        return returnVar;

    }

    

    testMethod static void testRemove() {

        ADM_Work__c work = ADM_Work.createTestWork();

        ADM_Work_Subscriber__c subscriber = new ADM_Work_Subscriber__c();

        subscriber.WorkId__c = work.id;

        Database.insert(subscriber);

        String message = remove(subscriber);        

        System.assertEquals(0, getSubscriberCount(work.id), 'The subscriber should have been removed, subscribed to ADM_Work__c.id:' + work.id);

        System.assertEquals('Subscribe', message, 'The keyword Subscribe is expected to be returned (used for button label)');  

    } 

    

    public static ADM_Work_Subscriber__c make(String workId, String userId) {

    	ADM_Work_Subscriber__c subscriber = new ADM_Work_Subscriber__c(WorkId__c = workId, UserId__c = userId);

    	

    	return subscriber;

    }   

    

    testMethod static void testMake() {

    	String workId = 'a0LT0000000ZYywMAG';

    	String userId = '005T0000000f0iMIAQ';

    	

    	ADM_Work_Subscriber__c sub = make(workId, userId);

    	

    	System.assert(workId.equalsIgnoreCase(sub.WorkId__c), true);

    	System.assert(userId.equalsIgnoreCase(sub.UserId__c), true);

    }

    

    public static String add(ADM_Work_Subscriber__c subscriber){        

        String returnVar = '';

        Database.SaveResult dr = Database.insert(subscriber, false);

        

        if(dr.isSuccess()) {

            returnVar =  'Unsubscribe';

        } else {

            returnVar =  'Error';

        }

        

        return returnVar;

    }  

    

    testMethod static void testAdd() {

        ADM_Work__c work = ADM_Work.createTestWork();

        ADM_Work_Subscriber__c subscriber = new ADM_Work_Subscriber__c();

        subscriber.WorkId__c = work.id;

        String message = add(subscriber);       

        System.assertEquals(1, getSubscriberCount(work.id), '1 subscriber should have been created, subscribed to ADM_Work__c.id:' + work.id);

        System.assertEquals('Unsubscribe', message, 'The keyword Unsubscibe is expected to be returned (used for button label)');   

    }

    

    public static void modify(ADM_Work_Subscriber__c subscriber) {

        Database.update(subscriber);    

    }

    

    testMethod static void testModify() {

        //add a record to test with

        List<ADM_Work__c> validWork = new List<ADM_Work__c>(); 

        validWork.add([select id, Name from ADM_Work__c where id = : ADM_Work.createTestWork().id]);

        validWork.add([select id, Name from ADM_Work__c where id = : ADM_Work.createTestWork().id]);

        ADM_Work_Subscriber__c subscriber = new ADM_Work_Subscriber__c();

        subscriber.WorkId__c = validWork[0].id;

        Database.insert(subscriber);

        //change the record

        subscriber.WorkId__c = validWork[1].id;

        modify(subscriber);

        //assert the modification was made  

        ADM_Work_Subscriber__c modifiedSub = [select WorkId__c from ADM_Work_Subscriber__c where id = :subscriber.id];  

        System.assertEquals(subscriber.WorkId__c, modifiedSub.WorkId__c, 'ADM_Work_Subscriber__c (id:' + subscriber.id + ') should have been modified');

    }           

            

    public static List<ADM_Work_Subscriber__c> getSubscribersWithLimit(Integer subscriberLimit, Id workID) {

        return [select Id, UserId__c, UserId__r.Username, UserId__r.Name, Distribution_List__c from ADM_Work_Subscriber__c where WorkId__c = :workID LIMIT :subscriberLimit]; 

    }

    

    testMethod static void testGetSubscribersWithLimit() {

        Id workID = subscriberTestSetup(10);

        //retrieve subscribers and assert limit has been enforced       

        List<ADM_Work_Subscriber__c> subscribers = getSubscribersWithLimit(5, workID);

        System.assertEquals(5, subscribers.size(), 'Created 10 subscriptions and enforced limit of 5.');

        //check that all subscribers are returned if limit is higher then list contents

        subscribers = getSubscribersWithLimit(50, workID);

        System.assertEquals(10, subscribers.size(), 'Created 10 subscriptions and requested arbitary high limit of 50 so all 10 subscriptions should be returned');

    }   

    

    public static Integer getSubscriberCount(Id workID) {

        return [select count() from ADM_Work_Subscriber__c where WorkId__c = :workID];

    }

    

    testMethod static void testGetSubscriberCount() {

        Id workID = subscriberTestSetup(3);

        System.assertEquals(3, getSubscriberCount(workID), 'Created 3 subscriptions but count did not match');

    }

    

    //test case helper method to create a work object and relate it a number of subscriptions

    private static Id subscriberTestSetup(Integer subscriptions) {

        ADM_Work__c work = ADM_Work.createTestWork();

        ADM_Work_Subscriber__c subscriber;

        //insert subscribers

        Integer i = 0;

        while(i != subscriptions) {

            subscriber = new ADM_Work_Subscriber__c();

            subscriber.WorkId__c = work.id;

            Database.insert(subscriber); 

            i ++;       

        }

        return work.id;

    }                   

          

}