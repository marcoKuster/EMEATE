public class ADM_CommentWrapper {
    
    public ADM_CommentWrapper(ADM_Work__c work, List<ADM_WorkUtils.Change> changes, List<String> descriptions, User author) {
        this.work = work;
        this.changeList = new List<String>();
        this.body = renderCommentBody(changes, descriptions);
        this.author = author;
    }
    
    public ADM_CommentWrapper(ADM_Work__c newWork, List<String> newChangeList, User author) {
        this(newWork, newChangeList, '', author);
    }
    
    public ADM_CommentWrapper(ADM_Work__c newWork, List<String> newChangeList, String newBody, User author) {
        this.work = newWork;
        this.changeList = newChangeList;
        this.body = renderCommentBody(changeList, newBody);
        this.author = author; 
    }
    
    public ADM_Work__c work {get; set;}
    public List<String> changeList {get; set;}
    public String body {get; set;}
    public User author {get; set;}
    
    public ADM_Comment__c toComment() {
        if(ADM_TextUtils.isBlank(this.body)) {
            return null;
        }
        
        ADM_Comment__c comment = new ADM_Comment__c();
        comment.Body__c = body;
        comment.Work__c = work.Id;
        comment.Comment_Created_Date__c = System.now();
        comment.Preserve_Formatting__c = work.Preserve_Formatting_Copy__c;     
        
        //attempt to store the real comment author for comments submitted via email2apex
        if(author.username.toLowerCase().contains('email2') && work.Last_Modified_By_Copy__c != null) {
            System.debug('Using Last Mod as author of the comment');
            comment.Comment_Created_By__c = work.Last_Modified_By_Copy__c; 
        } else {
            System.debug('Using the current user as the author of the comment');
            comment.Comment_Created_By__c = author.id;
        }
        
        return comment;
    }
    
    private String renderCommentBody(List<ADM_WorkUtils.Change> changes, List<String> descriptions) {
        List<String> changeDescriptionParts = new List<String>();
        Boolean hasChanges = changes != null && changes.size() > 0;
        
        if(hasChanges) {
            for(ADM_WorkUtils.Change change : changes) {
                //skip the Comment_Copy__c change
                if(change.fieldName.equals('Comment_Copy__c')) {
                    continue;
                }
                
                //add a human readable message of the changes
                String fieldLabel = ADM_Work.getFieldLabel(change.fieldName);
                String message = null;
                if(change.isAdd()) {
                    message = fieldLabel + ', ' + change.newValue + ', has been added.';
                } else if(change.isRemove()) {
                    message = fieldLabel + ', ' + change.oldValue + ', has been deleted.';
                } else {
                    message = fieldLabel + ' changed from ' + change.oldValue + ' to ' + change.newValue;
                }
                changeDescriptionParts.add(message);
            }
        }
        
        //add the comment
        if(descriptions != null) {
            for(Integer index = 0; index < descriptions.size(); index++) {
                String description = descriptions.get(index);
                
                //add an empty line before each description
                if(index > 0 || (index == 0 && hasChanges)) {
                    changeDescriptionParts.add('');
                }
                
                changeDescriptionParts.add(description);
            }
        }
        
        return renderCommentBody(changeDescriptionParts, null);
    }
    
    private String renderCommentBody(List<String> changeList, String body) {
        String fullBody = '';
        
        //add the body text
        if(!ADM_TextUtils.isBlank(body)) {
            fullBody += body;
            
            if(!changeList.isEmpty()) {
                fullBody += '\n';
            }
        }
        
        //add the change list messages
        for(String messageBody : changeList) {
            fullBody += messageBody + '\n';
        }
        
        return fullBody;
    }
}