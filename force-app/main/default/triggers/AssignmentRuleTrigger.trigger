trigger AssignmentRuleTrigger on ADM_Assignment_Rule__c bulk (before insert, before update) {

    if(UserInfo.getUserName().contains('p4') || UserInfo.getUserName().contains('Perforce') || UserInfo.getUserName().contains('integration')){
        return;
    }


    ADM_Assignment_Rule__c[] rules = Trigger.new;

    //this map is used as a wrapper to allow existing subscrition validation to be leveraged
    Map<Id, ADM_Work__c> emailOrUsersPendingValidation = new Map<Id, ADM_Work__c>();

    for( ADM_Assignment_Rule__c rule : rules ){
		try {
			if(Trigger.isInsert) {
				//attempt to auto-populate Product Owner field based on Scrum Team

		    	if(rule.Product_Owner__c == null && rule.Scrum_Team_Assignment__c != null) {

		    		List<ADM_Scrum_Team_Member__c> members = ADM_ScrumTeam.getUsersByRoleOrderedByAllocation(rule.Scrum_Team_Assignment__c, 'Product Owner');

		    		//users are ordered by allocation to the first match is used to popualte the Product Owner field
		    		if(members.size() >= 1) {
		    			rule.Product_Owner__c = members.get(0).Member_Name__c;
		    		} else {
                //product owner wasn't populated and no team members have that role so default to the current user
                rule.Product_Owner__c = UserInfo.getUserId();
            }


		    		//any subsequent matches go in the additional emails
		    		if(members.size() > 1) {
		    			for(Integer i = 1; i < members.size(); i++) {
		    				if(rule.Additional_Emails__c == null || rule.Additional_Emails__c == '') {
		    					rule.Additional_Emails__c = members.get(i).Member_Name__r.Email;
		    				} else {
		    					if(!rule.Additional_Emails__c.toLowerCase().contains(members.get(i).Member_Name__r.Email)) {
		    						rule.Additional_Emails__c = rule.Additional_Emails__c + ', ' + members.get(i).Member_Name__r.Email;
		    					}
		    				}

		    			}
		    		}
		    	}
			}
		} catch (System.Exception e) {

	    }

        //if additonal emails field is populated validate that each entry matches an alias, username or email
        if( rule.Additional_Emails__c != null) {
             emailOrUsersPendingValidation.put(rule.id, new ADM_Work__c(Email_Subscription_ID__c = rule.Additional_Emails__c));
        }


    }
    //validate the email/user contacts
    Map<Id, List<String>> invalidUsersOrEmails = ADM_Subscriber.getAllFromWork(emailOrUsersPendingValidation);
    //attach error message
    for( ADM_Assignment_Rule__c r : rules ){
        if(invalidUsersOrEmails.containsKey(r.id)) {
            r.Additional_Emails__c.addError('This item ' + invalidUsersOrEmails.get(r.id) + ', could not be matched to a username, email address or alias in the system.');
        }
    }



}