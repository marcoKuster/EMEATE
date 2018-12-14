public class ADM_ChangeListMessage {
    public Map<String, String> coreValues;
    public List<String> toAddresses;
    public List<String> ccAddresses;
    public List<String> bccAddresses;
    public String subjectLine;
    public ADM_Comment__c[] comments;
    public User user;
    public List<String> fieldNamesWithChanges = new List<String>();
    private List<ADM_ChangeListMessage.Recipient> recipients = null;
    public String mailOrigin {get;set;}
    public List<FeedItem> posts {get;set;}
    public static final String CHATTER_POST = 'Chatter Post';
    public static final String COMMENT_ON_WORK = 'Comment';
    public ADM_ChangeListMessage(Map<String, String> coreValues, List<ADM_ChangeListMessage.Recipient> recipients, String subjectLine, ADM_Comment__c[] comments, User user) {
        this.coreValues = coreValues;
        this.subjectLine = subjectLine;
        this.recipients = recipients;
        this.setAddresses(recipients);
        this.subjectLine = subjectLine;
        
        if(comments == null) {
            this.comments = new List<ADM_Comment__c>();
        } else {
            this.comments = comments;
        }
        
        this.user = user;
        this.mailOrigin = COMMENT_ON_WORK;
    }
    
    public ADM_ChangeListMessage(Map<String, String> coreValues, List<ADM_ChangeListMessage.Recipient> recipients, String subjectLine, List<FeedItem> posts, User user){
        this.coreValues = coreValues;
        this.subjectLine = subjectLine;
        this.recipients = recipients;
        this.setAddresses(recipients);
        this.subjectLine = subjectLine;
        this.comments = null;
        this.user = user;
        this.mailOrigin = CHATTER_POST;
        this.posts = posts;
    }
    public Messaging.SingleEmailMessage toEmailMessage() {
        Messaging.SingleEmailMessage wMail = null;
        
        Boolean hasToAddresses = toAddresses != null && !toAddresses.isEmpty();
        Boolean hasCcAddresses = ccAddresses != null && !ccAddresses.isEmpty();
        Boolean hasBccAddresses = bccAddresses != null && !bccAddresses.isEmpty();
        
        if(hasToAddresses || hasCcAddresses || hasBccAddresses) {
            Map<String, String> mailBody = renderBody();
            
            wMail = new Messaging.SingleEmailMessage();
            
            if(hasToAddresses) {
                wMail.setToAddresses(toAddresses);
            }
            
            if(hasCcAddresses) {
                wMail.setCCAddresses(ccAddresses);
            }
            
            if(hasBccAddresses) {
                wMail.setBccAddresses(bccAddresses);
            }
            
            wMail.setBccSender( false );
            wMail.setSaveAsActivity( false );
            wMail.setUseSignature( true );
            wMail.setSubject( subjectLine );
            wMail.setHtmlBody( mailBody.get('html') );
            wMail.setPlainTextBody( mailBody.get('text') );
            wMail.setSenderDisplayName(user.Name);
            
            // Specify the address used when the recipients reply to the email - either current user or email2gus functionality built off of email2apex.
            String email2ApexReplyAddress = ADM_ConstantsSingleton.getInstance().getEmail2GusAddress();
            if(ADM_TextUtils.isBlank(email2ApexReplyAddress)) {
                wMail.setReplyTo(user.Email); 
            } else {
                wMail.setReplyTo(email2ApexReplyAddress);    
            }
            
        }
        
        return wMail;
    }
    
    private void setAddresses(List<ADM_ChangeListMessage.Recipient> recipients) {
        Set<String> addresses = getUniqueEmailAddresses(recipients);
        
        //reset the addresses
        this.toAddresses = new List<String>();
        this.ccAddresses = new List<String>();
        this.bccAddresses = new List<String>();
        
        Integer toLimit = ADM_WorkEmail.EMAIL_SIZE_LIMIT_TO_FIELD;
        Integer ccLimit = ADM_WorkEmail.EMAIL_SIZE_LIMIT_CC_FIELD;
        Integer totalSizeLimit = toLimit + ccLimit;
        
        //the platform limits the number of people that email can be sent to
        if(addresses.size() > totalSizeLimit) {
            throw new AddressLimitException('This work record will generate an email with ' + addresses.size() +' receipients. This amount exceeds our limit of ' + totalSizeLimit + ' recipients. Please consider either removing some of the subscribers, or changing the email addresses to distribution lists.');
        }

        //put every address in the TO line
        toAddresses.addAll(addresses);
        
        //move any addresses that are over the TO limit to the CC field.
        if(toAddresses.size() > toLimit) {
            for(Integer i = toAddresses.size() - 1; toAddresses.size() > toLimit; i--) {
                ccAddresses.add(toAddresses.remove(i));
            }
        }
    }
    
    private Map<String, String> renderBody() {
        Map<String, String> mailBody = new Map<String, String>();
        String html = '';
        String text = '';
        
        if(!coreValues.isEmpty()){
            html += renderCoreValues(new HtmlCoreValueWriter());
            text += renderCoreValues(new TextCoreValueWriter());
        }
        
        try {               
            if(mailOrigin.equals(COMMENT_ON_WORK)){              
            if(!comments.isEmpty()) {
                Map<String, String> commentsFormatted = formatComments();
                html += commentsFormatted.get('html');
                text += commentsFormatted.get('text');
            }
            }
            else if(mailOrigin.equals(CHATTER_POST)){
                Map<String, String> postFormatted = formatPost();
                text += postFormatted.get('text');
                html += postFormatted.get('html');  

            }
        } catch(NullPointerException npe) {
            System.debug( npe.getMessage() );
        }
        
        mailBody.put( 'html', html );
        mailBody.put( 'text', text );
        
        return mailBody;
    }
    
    private Map<String, String> formatComments() {
        Map<String, String> mapReturn = new Map<String, String>();
        String strReturnText = '';
        String strReturnHTML = '';
        
        for ( ADM_Comment__c comment : comments ) {         
            DateTime dt = comment.CreatedDate;
            User createdBy = comment.Comment_Created_By__r;
            
            strReturnHTML += '<br /><br /><table cellpadding="3" cellspacing="3">';
            
            // sometimes we're going to get a comment without any date or author because it is a psuedo comment
            // that i added for a copy log because cuz i don't want to add another method to format and send emails
            if( dt != null && createdBy != null){
                comment.LocaleCreatedDate__c = comment.Comment_Created_Date__c.formatLong();
                String header = ((createdBy == null)? '' : createdBy.Name) + ' ' + comment.LocaleCreatedDate__c;
                
                strReturnText += '\n\n' + header + '\n';
                strReturnHTML += '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;">' + header + '</td></tr>';
            }
            
            if(comment.Body__c != null){
                strReturnText += comment.Body__c + '\n\n';
                
                strReturnHTML += '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;">';
                if(comment.Preserve_Formatting__c) {
                    strReturnHTML += comment.Body__c;
                } else {
                    strReturnHTML += ADM_TextUtils.toHTML(comment.Body__c.escapeHtml4());
                }
                strReturnHTML += '</td></tr>';
            }
            
            strReturnHTML += '</table>';
        }
        
        mapReturn.put('text', strReturnText);
        mapReturn.put('html', strReturnHTML);

        return mapReturn;
    }
    
    //Let's keept formatComment and formatPost separate. Eventhough these methods have common code each is dealing with different entities.
    private Map<String, String> formatPost() {
        String gusNameSpace = ADM_ConstantsSingleton.getInstance().getNameSpace();
        Map<String, String> mapReturn = new Map<String, String>();
        String strReturnText = '';
        String strReturnHTML = '';
        Map<String, ADM_FieldWrapper> ALL_FIELDS_MAP = ADM_Work.getMapOfFieldNameLabelPairs();
        for(FeedItem post: posts){
            DateTime dt = post.CreatedDate;
            String createdByName = '';
            try{
                if(null == post.createdBy){
                    createdByName = user.Name;
                }
                else{
                 createdByName = post.createdBy.Name;
                }
            }
            catch(Exception exp){
                System.debug('Exception occured in ADM_ChangeListMessage ' + exp.getMessage());
            }
            
           strReturnHTML += '<br /><br /><table cellpadding="3" cellspacing="3">';
            
            // sometimes we're going to get a comment without any date or author because it is a psuedo comment
            // that i added for a copy log because cuz i don't want to add another method to format and send emails
            if( dt != null){
                String header = createdByName + ' ' + post.CreatedDate.formatLong();
                
                strReturnText += '\n\n' + header + '\n';
                strReturnHTML += '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;">' + header + '</td></tr>';
            }
            String body = post.Body;
            if(body != null && body.length() >0) {
                strReturnText += post.Body + '\n\n';

                strReturnHTML += '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;">';
                //For security reasons we escape the post, we then replace the new line character with the <br> tag so that HTML email clients process new lines correctly.
                String postBody  = ADM_TextUtils.replaceBR(post.Body);
                postBody = post.Body;
                if(post.isRichText == false){
                    postBody = postBody.escapeHTML4();
                }
                //Apex escapeHTML() method is adding a phantom <br/> tag. TODO: Log bug with Apex Team.
                postBody = ADM_TextUtils.unescapeBR(postBody);
                String postBody1 = (new ADM_TextUtils()).replaceEOL(postBody);
                strReturnHTML += postBody1;
                strReturnHTML += '</td></tr>';          
            }
            else if(post.Type == 'ContentPost' || post.Type == 'LinkPost'){
                strReturnHTML += '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;">';
                strReturnHTML += ADM_WorkUtils.getFeedItemPostBodyBasedOnType(post);
                strReturnHTML += '<br/>';
                strReturnHTML += '</td></tr>';
            }
            else if(post.feedTrackedChanges.size()> 0){
                /*
                    If post.Body is null and not Content/Link Post check Feed Track change ...
                */
                
                for(FeedTrackedChange trackedChange :post.feedTrackedChanges) {
                    String fieldName = trackedChange.fieldName;
                    
                    
                    String oldValue = '';
                    String newValue = '';

                    if(null == trackedChange.OldValue){
                        oldValue = 'a blank value';
                    }
                    else{
                        oldValue = String.valueOf(trackedChange.OldValue);
                    }

                    if(null == trackedChange.NewValue){
                        newValue = 'a blank value';
                    }
                    else{
                        newValue = String.valueOf(trackedChange.NewValue);
                    }
                    //If a FK field is in tracked changes then it is repeated on FeedTrackedChange one with ID value and the one with Name (Ignoring ID value by below condition
                    if(ADM_Work.getNamesOfFKFields().contains(fieldName.remove(gusNameSpace + 'ADM_Work__c.' + gusNameSpace)) && (ADM_TextUtils.validateId(oldValue) || ADM_TextUtils.validateId(newValue))){
                        continue;
                    }

                    strReturnHTML += '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;">';
                                        
                    
                    ADM_FieldWrapper changedFieldWrapper = ALL_FIELDS_MAP.get(trackedChange.fieldName.remove(gusNameSpace + 'ADM_Work__c.' + gusNameSpace) );
                    if(null != changedFieldWrapper){
                        fieldName = changedFieldWrapper.fieldLabel;
                    }

                    strReturnText += fieldName + ' changed from ' + oldValue + ' to ' + newValue;
                    strReturnHTML += fieldName + ' changed from ' + oldValue + ' to ' + newValue;
                    
                    strReturnHTML += '<br/>';
                }
                strReturnText += '\n\n';
                strReturnHTML += '</td></tr>';
            }
            else{
                strReturnHTML += '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;">';
                strReturnHTML += coreValues.get('Type') + ' created';
                strReturnHTML += '</td></tr>';
                
            }
            
            strReturnHTML += '</table>';
        }
        mapReturn.put('text', strReturnText);
        mapReturn.put('html', strReturnHTML);
        
        return mapReturn;
    }
    
    private String renderCoreValues(CoreValueWriter writer) {
        for(String fieldName : ADM_CoreValues.keys()){
            if(ADM_TextUtils.isBlank(fieldName)) {
                continue;
            }
            
            String value = coreValues.get(fieldName);
            if(ADM_TextUtils.isBlank(value)) {
                continue;
            }
            
            //escape everything except for "link" and "steps to repro" fields
            Boolean escape = true;
            if(fieldName.toLowerCase().contains('link') || fieldName.toLowerCase().replaceAll('_',' ').contains('details and steps to reproduce')) {
                escape = false;
            }
            
	
            // For Assignee and QA engineer, confirm the ID is valid, otherwise ingnore and proceed		
            if ( fieldName == 'Assignee' || fieldName == 'QA Engineer' ){
		    // If any field is still just an ID, append INACTIVE to it
		    String strId = '';
		    try {
			strId = Id.valueOf(value);
			if ( strId == value ) { value = value + '-INACTIVE';}
		    } catch ( System.StringException se ){
			// No-Op
		    }
            }
	
            writer.writeKeyValuePair(fieldName, value, escape);
        }
        
        return writer.toString();
    }
    
    private static Set<String> getUniqueEmailAddresses(List<ADM_ChangeListMessage.Recipient> recipients) {
        Set<String> addresses = new Set<String>();
        for(ADM_ChangeListMessage.Recipient recipient : recipients) {
            if(recipient.getEmail() != null) {
                addresses.add(recipient.getEmail());
            }
        }
        return addresses;
    }
    

    
    abstract class CoreValueWriter {
        private String buffer = '';
        
        void writeKeyValuePair(String key, String value, Boolean escape) {
            if(value == null) {
                value = '';
            }
            
            //truncate the value if it is over 3200 characters
            if(value.length() > 3200) {
                value = value.trim().substring(0, 3200) + '... \n\nSee the rest of ' + key + ' on the work record.';
            }
            
            buffer += createLine(key, value, escape);
        }
        
        /**
         * Gets the text that is to be used before the core values 
         */
        protected virtual String getHeader() {
            return '';
        }
        
        /**
         * Gets the text that is to be used after the core values
         */
        protected virtual String getFooter() {
            return '';
        }
        
        abstract String createLine(String key, String value, Boolean escape);
        
        public virtual override String toString() {
            return getHeader() + buffer + getFooter();
        }
    }
    
    private class TextCoreValueWriter extends ADM_ChangeListMessage.CoreValueWriter {
        public override String createLine(String key, String value, Boolean escape) {
            return key + ':\t ' + value + '\n';
        }
    }
    
    private class HtmlCoreValueWriter extends ADM_ChangeListMessage.CoreValueWriter {
        
        public override String createLine(String key, String value, Boolean escape) {
            String outputValue = null;
            String keyAndValue = '';
            //escape the value
            if(escape) {
                outputValue = (new ADM_TextUtils()).escapeHTML(value);
            } else {
                outputValue = value;
            }
            String keyStr = '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;vertical-align:top;white-space:nowrap;">' + key + ':</td>';
            String valueStr = '';
            if(key.containsIgnoreCase('details and steps to reproduce') || key.containsIgnoreCase('description') ){//In a new line if details and stops to reproduce or description
                keyStr += '</tr>';
                valueStr = '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;vertical-align:top;" colspan="3">' + ADM_TextUtils.toHTML(outputValue) + '</td></tr>';
            }
            else{
                valueStr = '<td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;vertical-align:top;width:100%">' + outputValue + '</td></tr>';
            }
            keyAndValue = keyStr + valueStr;
            return keyAndValue;
        }
        
        protected override String getHeader() {
            return '<table cellpadding="3" cellspacing="3">';
        }
        
        protected override String getFooter() {
            return '</table>';
        }
    }
    
    public class AddressLimitException extends Exception {}
    
    public virtual class Recipient {
        private String name;
        private String email;
        
        public Recipient(String name, String email) {
            this.name = name;
            this.email = email;
        }
        
        public String getName() {
            return this.name;
        }
        
        public String getEmail() {
            return this.email;
        }
    }
    
    public class UserRecipient extends Recipient {
        private User user;
        
        public UserRecipient(User user) {
            super(user.Name, user.Email);
            this.user = user;
        } 
        
        public User getUser() {
            return this.user;
        }
    }
}