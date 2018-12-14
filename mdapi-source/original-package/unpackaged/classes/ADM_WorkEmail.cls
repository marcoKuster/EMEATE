public class ADM_WorkEmail{    
    public static final Integer EMAIL_SIZE_LIMIT_TO_FIELD = 100;
    public static final Integer EMAIL_SIZE_LIMIT_CC_FIELD = 25;
    public static final Integer EMAIL_SIZE_LIMIT_BCC_FIELD = 25;
    public static final Integer EMAIL_SIZE_LIMIT_TOTAL = EMAIL_SIZE_LIMIT_TO_FIELD + EMAIL_SIZE_LIMIT_CC_FIELD;
    
    public static void sendSimpleBulkEmailForTeamDependency( String replyTo, String subject, String senderDisplayName, List<Set<String>> listOfEmailAddySets, List<String> plainMessageList, List<String> htmlMessageList ) {
        if(listOfEmailAddySets == null || plainMessageList == null || htmlMessageList == null) return;
    
	    Messaging.Email[] listOfEmails = new List<Messaging.Email>();
	    
	    for(Integer i = 0; i< listOfEmailAddySets.size(); i++) {
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        
	        if(replyTo != null)
	            mail.setReplyTo(replyTo);
	        else
	            mail.setReplyTo('noreply@salesforce.com');
	        if(subject != null) 
	            mail.setSubject(subject);
	        else 
	            mail.setSubject('No subject');
	        if(senderDisplayName != null)
	            mail.setSenderDisplayName(senderDisplayName);
	        else 
	            mail.setSenderDisplayName('No Reply');
	        
	        mail.setUseSignature(false);
	        mail.setSaveAsActivity(false);
	        
	        // because messages do not support sets
	        List<String> emailAddyList = new List<String>();
	        
	        for(String emailAddy:listOfEmailAddySets.get(i))
                emailAddyList.add(emailAddy);
	        
	        if(!emailAddyList.isEmpty()) {
		        mail.setToAddresses(emailAddyList);
		        mail.setPlainTextBody(plainMessageList.get(i));
		        mail.setHtmlBody(htmlMessageList.get(i));
	            
	            listOfEmails.add(mail);
	        }       
	    }
	    
        if(!listOfEmails.isEmpty()) Messaging.sendEmail(listOfEmails);
    }
    
    
    public static void sendSimpleSingleEmail( String replyTo, String subject, String senderDisplayName, List<String> listOfEmailAddresses, String plainMessage, String htmlMessage ) {
 
        if(listOfEmailAddresses == null || plainMessage == null || htmlMessage == null) return;
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           
        if(replyTo != null)
            mail.setReplyTo(replyTo);
        else
            mail.setReplyTo('noreply@salesforce.com');
        if(subject != null) 
            mail.setSubject(subject);
        else 
            mail.setSubject('No subject');
        if(senderDisplayName != null)
            mail.setSenderDisplayName(senderDisplayName);
        else 
            mail.setSenderDisplayName('No Reply');
        
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);

        mail.setToAddresses(listOfEmailAddresses);
        mail.setPlainTextBody(plainMessage);
        mail.setHtmlBody(htmlMessage);

        List<Messaging.SingleEmailMessage> email_list = new List<Messaging.SingleEmailMessage>();
        email_list.add(mail);    
        Messaging.sendEmail(email_list);
           
    }
    
    /**
     * This method is to be deleted and should not be used.
     * @deprecated
     */
    public static Boolean sendNotification(Map< String, String > coreValues, List< String > changeList, List< String > toAddresses, List< String > ccAddresses, String subjectLine, ADM_Comment__c[] comments, User u ) {
    	List<ADM_ChangeListMessage.Recipient> recipients = new List<ADM_ChangeListMessage.Recipient>();
    	for(String address : toAddresses) {
    		recipients.add(new ADM_ChangeListMessage.Recipient(address, address));
    	}
    	for(String address : ccAddresses) {
    		recipients.add(new ADM_ChangeListMessage.Recipient(address, address));
    	}
    	
        ADM_ChangeListMessage message = new ADM_ChangeListMessage(coreValues, recipients, subjectLine, comments, u);
        return sendNotification(message);
    }

	
	public static Boolean sendNotification( ADM_ChangeListMessage message ) {
		if( message == null ) {
			// allow null values to be passed in
			return false;
		} else {
			sendNotification(new List<ADM_ChangeListMessage>{message});
			return true;
		}
	}
	
	public static void sendNotification(List<ADM_ChangeListMessage> messages) {
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		
		for(ADM_ChangeListMessage message : messages) {
			Messaging.SingleEmailMessage wMail = message.toEmailMessage();
			if(wMail != null) {
                emails.add(wMail);
			}
		}	
		
		try {
			//List<Messaging.SendEmailResult> ser = Messaging.sendEmail(emails);
            List<Messaging.SendEmailResult> ser = null;
		} catch(EmailException e) {
			System.debug( e.getMessage() );
		}
	} 
   
}