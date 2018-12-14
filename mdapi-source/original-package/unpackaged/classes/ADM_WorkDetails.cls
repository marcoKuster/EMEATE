public with sharing class ADM_WorkDetails {
    public ADM_Work__c work { get; set; }
    public Boolean isNew { get; set; }
    public String recordTypeName { get; set; }
    public Boolean isEdit { 
        get {
            if(isEdit == null) {
                isEdit = true;
            }
            return isEdit;
        } 
        set; 
    }
    
    public Boolean containsOriginalChatterContent { 
        get {
            Integer chatterItemCount = 0;
            Integer commentItemCount = 0;
            try {
                /*  compare number of chatter posts to the number of comments to determine if original chatter content has been added (not just comments we have turned into chatter feed posts)
                    if # chatter posts is > # comments where posted to chatter = true
                */
               
                commentItemCount = [select count() from ADM_Comment__c where Work__c=:work.id and Posted_To_Chatter__c = :true];
                //count number of chatter items 
                chatterItemCount = ADM_FeedItemUtil.getFeedItemsCountByParentID(work.id);
                if(chatterItemCount > commentItemCount) {
                    return true;
                } else {
                    return false;
                }   
            } catch (System.Exception e) {
                return false;
            }
        } 
        set; 
    }
    
    public String helpText {
        get {
            if(helpText == null) {
                Schema.DescribeFieldResult field = ADM_Work__c.Description__c.getDescribe();
                helpText = field.getInlineHelpText();
                if(isEdit) {
                    helpText = helpText.substring(0, helpText.indexOf('.') + 1);
                }
            }
            return helpText;
        }
        set;
    }
    
    public ADM_WorkDetails(ApexPages.StandardController stdController) {  }
    
    public ADM_WorkDetails() {  }
    
    public static Boolean getShowComments() {
        return [Select Show_All_Work_Comments__c From User Where Id =: UserInfo.getUserId()].Show_All_Work_Comments__c;
    }
    
    @RemoteAction 
    public static ADM_Comment__c[] getComments(String workId) {
        try {
            return ADM_Comment.getAllUnprocessed(workId);
        } catch(System.Exception e) {
            return new List<ADM_Comment__c>();
        }   
    }
    
    @RemoteAction    
    public static String getOtherRecipients(String workId) {
        List<ADM_Work_Subscriber__c> subs = new List<ADM_Work_Subscriber__c>();
        String setOfSubs = '';
        
        try {
            subs = ADM_Subscriber.getSubscribersWithLimit(100, workId);
            
            if(!subs.isEmpty()) {
                for(ADM_Work_Subscriber__c subscriber : subs) {
                    if(!ADM_TextUtils.isBlank(subscriber.UserId__r.Name)) {                     
                        setOfSubs += subscriber.UserId__r.Name + ', ';
                    } else if(!ADM_TextUtils.isBlank(subscriber.Distribution_List__c)) {
                        setOfSubs += subscriber.Distribution_List__c + ', ';                        
                    }               
                }
            }  
        } catch(System.Exception e) {
        }
        
        return ADM_TextUtils.removeTrailingComma(setOfSubs);
    }

    @RemoteAction
    public static String getStandardRecipients(String workId) { 
        ADM_Work__c work = ADM_Work.getOneBy('Id', workId);
        return getStandardRecipients(work);     
    }
        
    public static String getStandardRecipients(ADM_Work__c work) {     
        String setOfUsers = '';
        
        try {
            Map<String, ADM_FieldWrapper> userFields = ADM_Work.USER_FIELDS_MAP;
            Sobject nw = (SObject) work;
            List<String> userIds = new List<String>();
            List<User> usersFromWork = new List<User>();
    
            for(String fieldName: userFields.keySet()) {
                if(nw.get(fieldName) != null) {
                    if(fieldName.equalsIgnoreCase('Senior_Management_POC__c') && work.Request_RD_Mgr_Review__c) {
                        userIds.add(String.valueOf(nw.get(fieldName))); 
                    } else if(!fieldName.contains('Senior_Management_POC__c')) {
                        userIds.add(String.valueOf(nw.get(fieldName)));
                    }                   
                }
            }
            
            if(!userIds.isEmpty()) {
                usersFromWork = ADM_WorkUser.getAllBy('Id', userIds, 1, userIds.size(), 'Id', 'ASC');
                
                if(!usersFromWork.isEmpty()) {
                    for(User userFromWork : usersFromWork) {
                        setOfUsers += userFromWork.Name + ', ';
                    } 
                }
            }
        } catch(System.Exception e) {
          }
                
        return ADM_TextUtils.removeTrailingComma(setOfUsers);
    }
}