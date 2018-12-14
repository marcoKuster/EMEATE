public with sharing class ADM_WorkTabPanelExtension{
    private Boolean showComments = true;
    private transient Boolean tabPanelViewPreference = null;
    public Boolean hasGrandChildren {get;set;}
    ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance();

    
    Map<String, Integer> relatedListRecordCount {get;set;} 
    public ADM_WorkTabPanelExtension(ApexPages.StandardController controller) {
         
        //Don't proceed if work id is not present
            
        ID workid = controller.getId();
        String workKeyPrefix = ADM_Work__c.sObjectType.getDescribe().getKeyPrefix();
        if(workid == null || !((String) workid).startsWith(workKeyPrefix)) {
            throw new ADM_ApplicationException('Expected a valid Work Id in the URL');
        }
        try {
           
            relatedListRecordCount = new Map<String, Integer>();
            setRelatedListRecordCount(workid);
            if (!ADM_TextUtils.isBlank(workid)) {
                Integer commentCount = [select count() from ADM_Comment__c where Posted_to_Chatter__c != True and Work__c =:workid limit 1];
                    if (commentCount > 0) {
                        showComments = true;
                        return;
                    }
            }
            
        } catch(System.Exception e) {
             System.debug('Unexpected exception fetching old comments for tab panel:' + e + ', line ' + e.getLineNumber());
        }
        showComments = false;
    }

    public Boolean packagedOrg{
        get{
          return signletonConstants.isPackagedOrg();
        }
        set;
       
    }

    public void setRelatedListRecordCount(Id workid){    
        
        List<ADM_Parent_Work__c> relatedWorkList = new List<ADM_Parent_Work__c> ();
        hasGrandChildren = false;
        ADM_Work__c work = [SELECT id, name, (select id from ADM_Work__c.WorkChangeLists__r),(select id from ADM_Work__c.eRelease_Requests__r),
        (select id from ADM_Work__c.Theme_Assignments__r),(select id from ADM_Work__c.workReleasedIn__r),(select id from ADM_Work__c.Acceptance_Criteria__r),
        (select id from ADM_Work__c.Work62OrgCases__r),(select id from ADM_Work__c.Tasks__r),(select id from Attachments),
        (select id from Investigation_Exceptions__r),(select id from Notes), (select id from Team_Dependencies_On_Story__r),
        (select id from Team_Dependencies_For_Story__r),(select id from SLA_Violations__r)  from ADM_Work__c  where id =: workid];
        
        //Added the query seperately because there are some records without parent and child ids in production
        Integer relatedRecordsCount = [select count() from ADM_Parent_Work__c where Child_Work__c != '' and Parent_Work__c != '' and (Child_Work__c =: workid or Parent_Work__c =: workid)];
        //Query child work records to check for grandchildren
        relatedWorkList = [Select Child_Work__c from ADM_Parent_Work__c where Child_Work__c != '' and Parent_Work__c != '' and Parent_Work__c =: workid];
        
        //Get workids and add them to a list
        List<Id> parentWorkIds = new List<Id>();
        for(ADM_Parent_Work__c parentWork :relatedWorkList){
            parentWorkIds.add(parentWork.Child_Work__c);
        }
        //Check if these work records are parent work of other work items
        List<ADM_Parent_Work__c> grandChildren = [Select id from ADM_Parent_Work__c where Parent_Work__c in : parentWorkIds];
        //if size is greater than 0 then they have other child records.
        if(grandChildren.size() > 0)
            hasGrandChildren = true;
        Integer googleDocCount = 0;
        //we can't assume the org has Google Apps turned on
        try{
            String query = 'select count() from GoogleDoc where parentId =: workid';
            
            googleDocCount = Database.countQuery(query);
        } catch(Exception e){
            System.debug('Exception getting Google Docs, most likely Google Apps is not enabled e: ' + e + ', line '+ e.getLineNumber());
        }
        
        //seperately calculate case count because it differs based on the package
        Integer relatedCaseCount = 0;
        try {
          //The relationship between work and cases differs between GUS and Agile Accelerator
          List<Case> cases = new List<Case>();
          if(packagedOrg) {
             String workRecordID = work.id; 
             cases = Database.query('select Id from Case where ADM_Work__c=:workRecordID order by CreatedDate');
          } else {
            String workName = work.Name;
            System.debug('work from standard controller:' + work);  
            cases = Database.query('select Id from Case where SM_Bug__c=:workName');
          }
          relatedCaseCount = cases.size() + work.Work62OrgCases__r.size(); 
          System.debug('relatedCaseCount:' + relatedCaseCount); 
       } catch(Exception e) {
           System.debug('setRelatedListRecordCount() Exception calculating case count e:' + e);
       } 
        
        relatedListRecordCount.put('themes',work.Theme_Assignments__r.size());
        relatedListRecordCount.put('attachments',work.Attachments.size()+work.Notes.size()+googleDocCount);
        relatedListRecordCount.put('exceptionRequests',work.Investigation_Exceptions__r.size());
        relatedListRecordCount.put('tasks',work.Tasks__r.size());
        relatedListRecordCount.put('workChangeLists',work.WorkChangeLists__r.size());
        relatedListRecordCount.put('workReleasedIn',work.workReleasedIn__r.size());
        relatedListRecordCount.put('eRelease_Requests',work.eRelease_Requests__r.size());
        relatedListRecordCount.put('sla_Violations',work.SLA_Violations__r.size());
        relatedListRecordCount.put('acceptanceCriterion',work.Acceptance_Criteria__r.size()); 
        relatedListRecordCount.put('related',relatedRecordsCount);   
        relatedListRecordCount.put('teamDependencies',work.Team_Dependencies_On_Story__r.size()+work.Team_Dependencies_For_Story__r.size());
        relatedListRecordCount.put('workAllCases',relatedCaseCount); 
        System.debug('relatedListRecordCount:' + relatedListRecordCount);
       
    }

    public Map<String, Integer> getRelatedListRecordCount(){
        return relatedListRecordCount;
    }
    
    public Boolean getOldCommentsTab() {
        return showComments;
    }

    // Indicates how to show the tab panel
    public Boolean getTabPanelViewPreference() {
        try {
            if(this.tabPanelViewPreference == null) {
                ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
                this.tabPanelViewPreference = preferences.TabPanelViewPreference__c;
            }
            return this.tabPanelViewPreference;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving User Preferences. Returning false. ' + exc.getMessage());
            return false;
        }
    }

    @RemoteAction
    public static void setTabPanelViewPreference(Boolean toggleValue) {
        ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
        preferences.TabPanelViewPreference__c = toggleValue;
        upsert preferences;
    }
}