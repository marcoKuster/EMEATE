public with sharing class ADM_ProductTagController {

    public ADM_Product_Tag__c tag { 
        get;
        set;
    }
    
    public String returnURL { 
        get;
        set;
    }
    
    public Boolean isNewTag {
        get;
        set;
    }
    
    private Integer workRecordsWithProductTagCount = null;

    public ADM_ProductTagController(ApexPages.StandardController stdController) {
        try {
           this.tag = (ADM_Product_Tag__c)stdController.getRecord();
           populateTag();
           returnURL = System.currentPageReference().getParameters().get('retURL');           
        } catch(System.Exception e) {
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to initialize Product Tag'));
        }    
    }

    private void populateTag() {
        if(this.tag.id != null) {
            //flesh out the object - version passed by std controller only holds the id
            this.tag = [select Name, Team__c, Team__r.Name, Description__c, Use_for_Automated_Tools__c, Active__c from ADM_Product_Tag__c where id=:tag.id];
            this.isNewTag = false;
        } else {
            this.isNewTag = true;
        }
        
        setValuesFromUrl();
    }
    
    private void setValuesFromUrl() {
        List<String> fieldsFromUrl = new List<String>{'Team__c'};
        Map<String, String> fieldValuesFromUrl = new Map<String, String>();
        String fieldName = '';

        for(String fieldFromUrl : fieldsFromUrl) {
            String fieldValueFromUrl = System.currentPageReference().getParameters().get(fieldFromUrl);

            if( fieldValueFromUrl != null) {
                
                fieldValuesFromUrl.put(fieldFromUrl, EncodingUtil.urlEncode(fieldValueFromUrl, 'UTF-8'));
            }
        }
        
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('Team__c'))) tag.Team__c = fieldValuesFromUrl.get('Team__c');
    }
   
    public PageReference saveTag() {
        try {
            //verify the team is active and the current user belongs to that team.  We want to allow this via the API but not the U.I which is why 
            //this validation is not in the Trigger
            ADM_Scrum_Team__c team = [select id, Name, Active__c from ADM_Scrum_Team__c where Id =:tag.Team__c];
            
            if(team == null || team.Active__c == false) {
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot create or edit a Product Tag for an inactive team'));
                return null;
            } else {
                List<ADM_Scrum_Team_Member__c> members = [select id from ADM_Scrum_Team_Member__c 
                                                        where Scrum_Team__c =:team.Id and Member_Name__c = :UserInfo.getUserId()];
                if(members == null || members.size() < 1) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot create or edit a Product Tag for a team you don\'t belong to.'));
                    return null;        
                } else {                                         
                    //tag is valid
                    upsert tag;
                    if(returnURL != null && returnURL.contains(ADM_WorkUtils.GUS_URL)) {
                        return new PageReference(this.returnURL);
                    } else {
                        return new PageReference('/' + tag.id);
                    }
                }   
            }    
        } catch(System.Exception e) {
            
            String errorMessage = e.getMessage();
            String duplicateErrorMessage = 'duplicates value on record with id: ';
            if (errorMessage.contains(duplicateErrorMessage)) {
                Integer duplicateTagIdIndex = errorMessage.IndexOf(duplicateErrorMessage) + duplicateErrorMessage.length(); 
                String duplicateTagId = errorMessage.substring(duplicateTagIdIndex, (duplicateTagIdIndex + 15 <= errorMessage.length()) ? duplicateTagIdIndex+15 : errorMessage.length());
                List<ADM_Product_Tag__c> duplicateTags = [Select Name from ADM_Product_Tag__c where id=:duplicateTagId];
                if(duplicateTags.size() > 0) {
                    ADM_Product_Tag__c duplicateTag = duplicateTags.get(0);
                    String returnErrorMessage = 'Duplicate value on record: <a href="/' + duplicateTagId + '">' + duplicateTag.Name.escapeHtml4() + '</a>';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,returnErrorMessage));
                } else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Duplicate value'));
                }
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
            return null;
        }
    }
    
    public Integer getNumberWorkRecordsWithProductTag() {
        if (workRecordsWithProductTagCount == null) {
            if (tag.id != null) {
                workRecordsWithProductTagCount = [select count() from ADM_Work__c where Product_Tag__c =: tag.id limit 101];
            } else {
                workRecordsWithProductTagCount = 0;
            }
        }
        return workRecordsWithProductTagCount;
    }
}