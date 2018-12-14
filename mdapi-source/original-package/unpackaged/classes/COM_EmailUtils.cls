/*
 * Email Utility class from
 * http://developer.force.com/cookbook/recipe/email-utility-class
 * with updates from
 * http://boards.developerforce.com/t5/Apex-Code-Development/Behavior-testing-a-sendEmail-statement/m-p/284331/highlight/false#M49675
 */
 
public with sharing class COM_EmailUtils {

/* 
This utility originally found on the force.com Cookbook here:
http://developer.force.com/cookbook/recipe/email-utility-class
Thanks to Anup Jadhav!

Updated by Pete Richards, pete@pete-richards.com, May 2011
Added some features:
* Added static ".to" methods that construct and return an instance of a Email Util to 
  save you the trouble of instantiating an EmailUtil when sending email.
* Added variables needed for constructing emails using templates. (whatId, templateId, targetObjectId) 
* Updated build method to build using a template or plaintext/html. 
* Added bulk send functionality with the .stashForBulk() terminator and .sendBulkEmail() static method.
* Added static that stores the last send email result so you can verify emails sent during tests.   

    
*********** Sending a Single Message ***********
Here's how you could compose a single email and send it immediately:
    
List<String> toAddresses = new List<String> {'john.doe@acme.org'};
String replyToAddress = 'john.duh@acme.org';

emailUtil.to(toAddresses)
    .plainTextBody('Bilbo Bagginses has stolen our Preciousssss!!')
    .senderDisplayName('Gollum Gollum')
    .replyTo(replyToAddress)
    .sendEmail();
            
            
*********** Sending Bulk Mail in a Trigger ***********
Here's a pseudo-code example of the bulk send inside a trigger:
    
trigger onContact on Contact (after insert) {
    for (Contact c : Trigger.new) {
        if (meets_criteria_for_send_email(c)) {
            EmailUtil.to(new String[]{'test@spam.com'})
                .stashForBulk();
        }
    }
    EmailUtil.sendBulkEmail();
}

*/ 
     
    
   
    /*
     * These interface and classes facilitate testing by providing a mocked version
     * of the email service.  Hat tip to Jared Pearson.
     * @author snahm
     */

    public interface EmailService {
        Messaging.SendEmailResult[] sendEmail(Messaging.SingleEmailMessage[] messages);
    }
 
    public class MockEmailService implements EmailService {
        private List<Messaging.SingleEmailMessage> sentMessages = new List<Messaging.SingleEmailMessage>();

        public List<Messaging.SingleEmailMessage> getSentMessages() {
            return sentMessages;
        }
        
        public void resetSentMessages() {
            sentMessages.clear();
        }

        public Messaging.SendEmailResult[] sendEmail(Messaging.SingleEmailMessage[] messages) {
            this.sentMessages.addAll(messages);
            Messaging.SendEmailResult[] results = new List<Messaging.SendEmailResult>();
            return (results);
        }
    } 
    public class SalesforceEmailService implements EmailService {
        public Messaging.SendEmailResult[] sendEmail(Messaging.SingleEmailMessage[] messages) {
            return(Messaging.sendEmail(messages));
        }
    }   

    //default the email service to the Salesforce service
    private static EmailService emailService = new SalesforceEmailService();

    public static void setEmailService(EmailService eService) {
        emailService = eService;
    }
    /*
     *  End of mock structure
     */

     private Messaging.SingleEmailMessage singleEmailMessage;
     private final List<String> toAddresses;
        
     //optional parameters set to default       
     private String subject = '';
     private String htmlBody = '';
     private Boolean useSignature = false;
     private Boolean saveAsActivity = false;
     private List<Messaging.EmailFileAttachment> fileAttachments = null;
     //defaults to current user's first name + last name
     private String senderDisplayName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
     //get the current user in context
     // using a static to save this result across multiple email constructions.
     private static User currentUser {
         get {
             if (currentUser == null)
                 currentUser = [Select email from User where username = :UserInfo.getUserName() limit 1];
             return currentUser;
         } set;
     }
     //replyTo defaults to current user's email
     private String replyTo = currentUser.email;
     private String plainTextBody = '';
       
     // Template options
     private Id templateId;
     private Id whatId;
    
     // defaults for recipient types
     private final Id targetObjectId; // Contact, Lead, or User. 

     /* ===================================
        Chain Starters
     ======================================= */
     public static COM_EmailUtils to(List<String> addresses) {
         return new COM_EmailUtils(addresses);
     }
    
    public static COM_EmailUtils to(Id target) { 
        // warning: can't override this with a string handler, apex can't tell an Id from a String.
        return new COM_EmailUtils(target);
    }

    public static COM_EmailUtils to(Id target, List<String> addresses) {
        return new COM_EmailUtils(target, addresses);
    }
   
       
    /* ===================================
        Attribute Setters
    ======================================= */
    
    /*
    .saveAsActivity(Boolean val)
    .senderDisplayName(String val)
    .subject(String val)
    .htmlBody(String val)
    .useSignature(Boolean bool)
    .replyTo(String val)
    .plainTextBody(String val)
    .fileAttachments(List<Messaging.Emailfileattachment> val)
    
    for use in template:
    .templateId(Id an_id)
    .whatId(Id an_id)
    */

    public COM_EmailUtils saveAsActivity(Boolean val) {
        saveAsActivity = val;
        return this;
    }
            
    public COM_EmailUtils senderDisplayName(String val) {
           senderDisplayName = val;
           return this;
    }
            
    public COM_EmailUtils subject(String val) {
           subject = val;
           return this;
    }
        
    public COM_EmailUtils htmlBody(String val) {
           htmlBody = val;
           return this;
    }

    public COM_EmailUtils templateId(Id an_id) {
        templateId = an_id;
        return this;
    }
    
    public COM_EmailUtils whatId (Id an_id) {
        whatId = an_id;
        return this;
    }
            
    public COM_EmailUtils useSignature(Boolean bool) {
           useSignature = bool;
           return this;
    }
        
    public COM_EmailUtils replyTo(String val) {
           replyTo = val;
           return this;
    }
        
    public COM_EmailUtils plainTextBody(String val) {
           plainTextBody = val;
           return this;
    }
        
    public COM_EmailUtils fileAttachments(List<Messaging.Emailfileattachment> val) {
           fileAttachments = val;
           return this;
    }
        

    /* ===================================
        Chain Terminators: call to send now or stash for bulk send (eg, for triggers).
    ======================================= */
            
    public void sendEmail() {
        // build and send email.
        build();
        //last_sendEmail_result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage });
        last_sendEmail_result = emailService.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage });
    } 
    public void stashForBulk() {
        //build and stash email.
        build();
        bulk_stash.add(singleEmailMessage);
    }
    
    /* ===================================
        Other Bulk Actions
    ======================================= */
    
    public static void sendBulkEmail() {
        // send emails in bulk_stash, empty it.
        //last_sendEmail_result = Messaging.sendEmail(bulk_stash);
        last_sendEmail_result = emailService.sendEmail(bulk_stash);
        bulk_stash.clear();
    }
    
    public static Boolean hasEmailsToSend() {
        return bulk_stash.size() != 0 ? true : false;
    }
    
    // static method for holding email results, so I can test when triggers send emails
    public static Messaging.SendEmailResult[] last_sendEmail_result {get; private set;}
    
    /*
     * Normalizer for email text fields.
     * Takes text with email addresses seperated by comma, semicolon, or whitespace
     * and returns a comma separated string of email addresses.
     */
     public static String normalize(String emailtext) {
         return(emailtext.replaceAll('[;\\s]',',').replaceAll(',+',','));
     }
     
     /*
      * Takes a normalized string of email addresses and remove duplicates
      */
     public static String dedup(String emailtext) {
        String s = emailtext;
        Integer i;
        String rval = '';
        while ((i = s.indexOf(',')) != -1 ) {
            String addr = s.left(i);
            rval += addr;
            s = s.remove(',' + addr).remove(addr);  
            if (s.length() > 0) {
                rval += ',';
                s = s.substring(1);
            }
        }
        if (rval.length() == 0) {
            rval = emailtext;
        } else if (s.length() > 0) {
            rval += s;
        }
        return rval;
     }

    /* ===================================
        Helpers & private constructors
    ======================================= */

    // private constructors, force you to use the static chain methods.
    private COM_EmailUtils(List<String> addresses) {
        this.toAddresses = addresses;
    }
    
    private COM_EmailUtils(Id target) {
        this.targetObjectId = target; 
    }
    private COM_EmailUtils(Id target, List<String> addresses) {
        this.toAddresses = addresses;
        this.targetObjectId = target; 
    }
        
    // build method, constructs a single email message.
    // this method is private and is called from sendEmail() or stashForBulk()
    private COM_EmailUtils build() {
        singleEmailMessage = new Messaging.SingleEmailMessage();
        singleEmailMessage.setTargetObjectId(this.targetObjectId);
        singleEmailMessage.setWhatId(this.whatId);
        singleEmailMessage.setToAddresses(this.toAddresses);
        singleEmailMessage.setSenderDisplayName(this.senderDisplayName);
        singleEmailMessage.setUseSignature(this.useSignature);
        singleEmailMessage.setReplyTo(this.replyTo);
        singleEmailMessage.setFileAttachments(this.fileAttachments);
        singleEmailMessage.setSaveAsActivity(this.saveasactivity);
        // use template if one exists, else use html and plain text body
        if (this.templateId == null) {
            singleEmailMessage.setHtmlBody(this.htmlBody);
            singleEmailMessage.setPlainTextBody(this.plainTextBody);
            singleEmailMessage.setSubject(this.subject);
        } else {
            singleEmailMessage.setTemplateId(this.templateId);
        }
        return this;
    }
    
    private static Messaging.SingleEmailMessage[] bulk_stash {
        get {
            if (bulk_stash == null) 
                bulk_stash = new Messaging.SingleEmailMessage[]{};
            return bulk_stash;
        } private set;
    }

}