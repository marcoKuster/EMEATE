//has to have global scope to be used inside an MDP page since salesforce wraps MDP actions in iframes
global with sharing class ADM_WorkRemoteActionsExtension{
    private transient Boolean workPanelViewPreference = null;
    public String myProdTag{get;set;}
    public ADM_Work__c selectedWork{get;set;}
    public String retUrl{get;set;}
    public Boolean isReturnUrl{get;set;}
    public Boolean isTeamCapexEligible{get;set;}
    public  List<ADM_Additional_Field__c> additionalFieldsForUserStory{get;set;}
    public  List<ADM_Additional_Field__c> additionalFieldsForBug{get;set;}
    public  List<ADM_Additional_Field__c> additionalFieldsForInvestigation{get;set;}
    public List<ADM_Theme_Assignment__c> themeAssignments{get;set;}
    ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance();
    public String clonedRecord{get;set;}
    public ADM_WorkRemoteActionsExtension(ApexPages.StandardController stdController) {
       clonedRecord = '0';
       retUrl = null;
       isReturnUrl = false;
       isTeamCapexEligible = false;//defaulting to false
       this.selectedWork = (ADM_Work__c)stdController.getRecord();
       myProdTag = this.selectedWork.Product_Tag__c;
       getMyAdditionalFieldsForAll();
       themeAssignments = new List<ADM_Theme_Assignment__c> ();
       getThemesForWork();
       retUrl = ApexPages.currentPage().getParameters().get('retURL');
       clonedRecord = System.currentPageReference().getParameters().get('clone');
       if(clonedRecord == null){
          clonedRecord = '0';
       }
       if(!ADM_TextUtils.isNull(retUrl) && !ADM_TextUtils.isBlank(retUrl)) {
          isReturnUrl = true;
       }
    }
    public ADM_WorkRemoteActionsExtension(ADM_WorkControllerGlobalAction controller) { }
    public ADM_WorkRemoteActionsExtension() { }

    //This method will be called when product Tag changes.
    public PageReference setCapexEligibilityByTeam(){
      if(this.selectedWork != null && this.selectedWork.Id != null){ //Product Tag changed - Action is work update
        getTeamCapexEligibility();
        if(isTeamCapexEligible && this.selectedWork.RecordType != null && this.selectedWork.RecordType.Name == 'User Story'){
          this.selectedWork.Capex_Enabled__c = true;
        }
        else{
            this.selectedWork.Capex_Enabled__c = false;
        }
      }
      return null;
    }

    public boolean getTeamCapexEligibility(){
      isTeamCapexEligible = false;
      if(myProdTag != null){
        List<ADM_Product_Tag__c> pTags = [select Id, Team__r.Capex_Enabled__c from ADM_Product_Tag__c where Id = :myProdTag ];
        if(pTags != null && pTags.size() > 0){
          isTeamCapexEligible = pTags[0].Team__r.Capex_Enabled__c;
          if(this.selectedWork != null && this.selectedWork.Id == null && this.selectedWork.RecordType != null && this.selectedWork.RecordType.Name == 'User Story'){
            this.selectedWork.Capex_Enabled__c = isTeamCapexEligible;
          }
        }
      }
      return isTeamCapexEligible;
    }

    public List<ADM_Additional_Field__c> getAdditionalFieldsForUserStory(){
      if(myProdTag == null){
        return new List<ADM_Additional_Field__c>();
      }
       List<ADM_Additional_Field__c> fields = [select Field_API_Name__c, Product_Tag__c, Type__c, User_Story_Setting__c from ADM_Additional_Field__c where Product_Tag__c = : myProdTag and User_Story_Setting__c != 'hidden' order by Order__c,Name];
       return fields;
    }

    public List<ADM_Additional_Field__c> getAdditionalFieldsForBug(){
      if(myProdTag == null){
        return new List<ADM_Additional_Field__c>();
      }
       List<ADM_Additional_Field__c> fields = [select Field_API_Name__c, Product_Tag__c, Type__c, Bug_Setting__c from ADM_Additional_Field__c where Product_Tag__c = : myProdTag and Bug_Setting__c != 'hidden' order by Order__c,Name];
       return fields;
    }

    public List<ADM_Additional_Field__c> getAdditionalFieldsForInvestigation(){
      if(myProdTag == null){
        return new List<ADM_Additional_Field__c>();
      }
       List<ADM_Additional_Field__c> fields = [select Field_API_Name__c, Product_Tag__c, Type__c, Investigation_Setting__c from ADM_Additional_Field__c where Product_Tag__c = : myProdTag and Investigation_Setting__c != 'hidden' order by Order__c,Name];
       return fields;
    }

    public PageReference getMyAdditionalFieldsForUserStory(){
      additionalFieldsForUserStory = [select Field_API_Name__c, Product_Tag__c, Type__c,User_Story_Setting__c from ADM_Additional_Field__c where Product_Tag__c = : myProdTag and User_Story_Setting__c != 'hidden' order by Order__c,Name];
      return null;
    }

    public PageReference getMyAdditionalFieldsForBug(){
      additionalFieldsForBug = [select Field_API_Name__c, Product_Tag__c, Type__c, Bug_Setting__c from ADM_Additional_Field__c where Product_Tag__c = : myProdTag and Bug_Setting__c != 'hidden' order by Order__c,Name];
      return null;
    }

    public PageReference getMyAdditionalFieldsForInvestigation(){
      additionalFieldsForInvestigation =  [select Field_API_Name__c, Product_Tag__c, Type__c, Investigation_Setting__c from ADM_Additional_Field__c where Product_Tag__c = : myProdTag and Investigation_Setting__c != 'hidden' order by Order__c,Name];
      return null;
    }

    public PageReference getMyAdditionalFieldsForAll(){
      additionalFieldsForInvestigation = new List<ADM_Additional_Field__c>();
      additionalFieldsForBug = new List<ADM_Additional_Field__c>();
      additionalFieldsForUserStory = new List<ADM_Additional_Field__c>();
      List<ADM_Additional_Field__c> allAdditionalFieldsForProductTag = [select Field_API_Name__c, Product_Tag__c, Type__c, Investigation_Setting__c, Bug_Setting__c, User_Story_Setting__c from ADM_Additional_Field__c where Product_Tag__c = : myProdTag and (Investigation_Setting__c != 'hidden' or Bug_Setting__c != 'hidden' or User_Story_Setting__c != 'hidden') order by Order__c,Name];

      for(ADM_Additional_Field__c af : allAdditionalFieldsForProductTag){
          if(af.Bug_Setting__c != 'hidden'){
            additionalFieldsForBug.add(af);
          }
          if(af.User_Story_Setting__c != 'hidden'){
            additionalFieldsForUserStory.add(af);
          }
          if(af.Investigation_Setting__c != 'hidden'){
            additionalFieldsForInvestigation.add(af);
          }
      }
      return null;
    }

    public void getThemesForWork(){
       themeAssignments = [Select Theme__r.Name, Theme__r.id from ADM_Theme_Assignment__c where Work__c =: this.selectedWork.id ];
    }

    public PageReference getMyThemesForWork(){
       themeAssignments = [Select Theme__r.Name, Theme__r.id from ADM_Theme_Assignment__c where Work__c =: this.selectedWork.id ];
       return null;
    }



    public void setAdditionalfieldsForUserStory(List<ADM_Additional_Field__c> setFields){
        additionalFieldsForUserStory = setFields;
    }
    public void setAdditionalfieldsForBug(List<ADM_Additional_Field__c> setFields){
        additionalFieldsForBug = setFields;
    }

    public void setAdditionalfieldsForInvestigation(List<ADM_Additional_Field__c> setFields){
        additionalFieldsForInvestigation = setFields;
    }


    public Boolean getIsMobile() {
        try {
            String userAgent = System.currentPageReference().getHeaders().get('User-Agent').toLowerCase();
            if (userAgent.contains('mobile')) {
                return true;
            } else {
                return false;
            }

        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving User Agent. Returning false. ' + exc.getMessage());
            return false;
        }
    }

    public Boolean packagedOrg{
        get{
          return signletonConstants.isPackagedOrg();
        }
        set;

    }

    /**
     * Indicates whether or not to show the work panel
     */
    public Boolean getWorkPanelViewPreference() {
        try {
            if(this.workPanelViewPreference == null) {
                //retrieve the user preferences for the current user
                ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
                this.workPanelViewPreference = preferences.WorkPanelViewPreference__c;
            }
            return this.workPanelViewPreference;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving User Preferences. Returning false. ' + exc.getMessage());
            return false;
        }
    }

    @RemoteAction
    global static void setWorkPanelViewPreference(Boolean toggleValue) {
        ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
        preferences.WorkPanelViewPreference__c = toggleValue;
        upsert preferences;
    }

    @RemoteAction
    global static ADM_WorkAssignment.AssignmentContext getAssignments(String severityLevel, ADM_Product_Tag__c productTag, RecordType recordType, String workType, String recipients) {
        return ADM_WorkAssignment.getAssignments(severityLevel, productTag, recordType, workType, recipients);
    }

    @RemoteAction
    global static ADM_WorkAssignment.PriorityMetaData getPriorityMetaData(String Id){
        return ADM_WorkAssignment.getPriorityMetaData(Id);
    }

    @RemoteAction
    global static String calculatePriority(ID frequencyID, ID impactID) {
       try {
            List<ADM_Priority_Mapping__c> pms = ADM_PriorityMapping.getByFrequencyAndImpact(frequencyID, impactID);
            String calculatedPriority = null;

            if(pms == null || pms.isEmpty()) {

            } else if(pms.size() > 1) {

            } else {
                calculatedPriority = pms.get(0).Priority__r.Name;
            }
            return calculatedPriority;
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Exception:' + e);
            return null;
        }
    }

     public List<FieldSetMemberWrapper> getCustomFields() {
        List<FieldSetMemberWrapper> fields = new List<FieldSetMemberWrapper>();
        try {
           Map<String, Schema.SobjectField> fieldMap = Schema.SobjectType.ADM_Work__c.fields.getMap();
           FieldSetMemberWrapper wrapper;
           for(Schema.FieldSetMember fieldMember : SObjectType.ADM_Work__c.FieldSets.custom_fields.getFields()) {
                wrapper = new FieldSetMemberWrapper();
                wrapper.field = fieldMember;
                //the FieldSetMember class does not expose if the field is editable or not so must look this up via the describe API
                Schema.SObjectField field = fieldMap.get(fieldMember.getFieldPath());
                if(field.getDescribe().isUpdateable()) {
                    wrapper.locked = false;
                } else {
                    wrapper.locked = true;
                }
                fields.add(wrapper);
            }
        } catch (Exception e) {
            System.debug('Exception loading custom fields e:' + e);
        }

        return fields;
    }

    public class FieldSetMemberWrapper {
        public Schema.FieldSetMember field{ get; set; }
        public Boolean locked { get; set; }

    }


}