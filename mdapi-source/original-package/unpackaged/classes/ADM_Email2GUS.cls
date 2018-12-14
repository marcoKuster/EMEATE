public class ADM_Email2GUS implements Messaging.InboundEmailHandler { 
    
    public static final String Email_2_GUS_User_Prefix = 'email2gus'; 
    private String emailAdds { 
        get {
            if(emailAdds == null) emailAdds = '';
            return emailAdds;
        } 
        set; 
    }
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        // Create a new inboundEmailResult object - for returning the result of the Apex code
        String commentHeader = 'Comments submitted via email2apex:\n\n';
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        Integer startChar = -1;
        Integer endChar = -1;
    
        result.success = false;
        // Look for the bug number
        // It should be preceeded by #
        // we expect the subject to look like: "Re: #W-943641 - User Story - New - P1 - P4 upgrade testing"
        startChar = email.subject.indexOf('#W-');
        endChar = email.subject.indexOf('-', startChar + 3);
        if ( (startChar < 0 || endChar < 0 || endChar <= startChar) ){ 
            result.message = 'Error: Work ID not found in Subject';
        }
        else{
            String myBugNumber = '';
            myBugNumber = email.subject.substring(startChar + 1, endChar).trim();
    
            //select the work record using the bug number that was found in the subject line
            ADM_Work__c vWork;
            User u;
            try {
                
                initEmailAdds(email);
            
                //What if bug number not found
                vWork = [Select Id, Name, Subject__c
                      From ADM_Work__c
                      Where name = :myBugNumber
                      Limit 1];
                if (vWork == null){ 
                    result.message = 'Error: Work ID not found in Database';
                }
                else{
                    //What if user not found
                     u = [select id from user where IsActive = true and email = :email.fromaddress limit 1];
                    if (u == null){
                        result.message = 'Error: Sending email address is not associated with a GUS user';
                    }
                    
                }
            }
            catch (System.QueryException e) {
                
                result.message = 'Error: (Likely bad Work Id, or User) ' + e;
            }
            if ( (vWork != null) && (u != null)){
                
                //Pull out the comment - only take up until you get a blank line
                //do some error handling or dont process if no comment found.
               String theComment = '';
               String[] commentList = email.plainTextBody.split('\r|\n|\r\n');
               
               String previousLine = 'NewLine';
               integer  lineCnt = 0;
               Boolean removePreviousResponse = false;
               Boolean removeLastLine = false;
               for (String commentText : commentList){
                    //Outlook has From: preceeded by a blank line
                    if ( commentText.startsWith('From:') && previousLine.equals('') ){
                        break;
                    }
                    //Blackberry has From: preceded by some number of underscores
                    if ( commentText.startsWith('From:') && previousLine.trim().startsWith('______________' )) {
                        removeLastLine = True;
                        break;
                    }
                    //Saw the following on MAC and Thunderbird.  
                    if ( (commentText.startsWith('On')) && (commentText.endsWith('wrote:')) ){
                        break;
                    }
                    
                    //Handle Gmail
                    if (commentText.contains('> wrote:') ){
                        removeLastLine = True;
                        break;
                    }
                    //Now lets deal with clients like thunderbird that leave the previous response and add '>'
                    if  (commentText.startsWith('>')){
                        if (previousLine.endsWith('wrote:') ){
                            removePreviousResponse = true;
                            if (lineCnt <= 1){
                                //blank the comment if the first line ended in wrote: and the next line starts with >
                                theComment = '';
                            }
                        }
                    }
                    else{
                        removePreviousResponse = false;
                    }
    
                    if (!removePreviousResponse){
                       previousLine = commentText.trim();
                       theComment += commentText + '\n';
                       lineCnt++;
                    }
                }
                if (theComment.endsWith('wrote:\n')){
                    removeLastLine = True;
                }
    
                
                if (removeLastLine){
                    
                    //get rid of the last \n
                    theComment = theComment.trim();
                    
                    //locate the previous \n
                    Integer endPoint = theComment.lastIndexOf('\n');
                    //no get rid of everything after the \n
                    theComment = theComment.substring(0,endPoint);
                   
                    
                }
                
                //this curently only deals with plain text - should consider html
                //Only add a comment if one exists                
                if (!ADM_TextUtils.isBlank(theComment)){
                    vWork.Email2GUS_Addresses__c = emailAdds;                 
                    vWork.Description__c = commentHeader + theComment;
                    vWork.Last_Modified_By__c = u.Id;
                    vWork.Last_Modified_By_Copy__c = u.Id;
                    update(vWork);
                    
                }
            }
            result.success = true;
        }
        return result;
    }
    
    private void initEmailAdds(Messaging.InboundEmail email) {
        List<String> emailAddresses = new List<String>();
        Integer idxOfLt = 0;
        Integer idxOfGt = 0;
        
        if(email.ccAddresses != null) {
            emailAddresses.addAll(email.ccAddresses);
        }
        
        if(email.toAddresses != null) {
            emailAddresses.addAll(email.toAddresses);
        }    
          
        for(String emailAddress : emailAddresses) {
            idxOfLt = emailAddress.indexOf('<');
            idxOfGt = emailAddress.indexOf('>');
            if(idxOfLt > -1 && idxOfGt > 0) {
                emailAdds += emailAddress.substring(idxOfLt + 1, idxOfGt) + ','; 
            } else {
                emailAdds += emailAddress + ',';
            }
        }
        
        emailAdds = ADM_TextUtils.removeTrailingComma(emailAdds);
        
    }

}