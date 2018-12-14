public with sharing class ADM_ScrumTeamWorkExtension {
    public transient LockingRecords lock;
    public transient String message;
    public transient String tabInfo;
    ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance();
    public Boolean editable{
    get{
         Schema.DescribeSObjectResult obj = Schema.SObjectType.ADM_Scrum_Team__c;
         return obj.isCreateable();
    }
    set;
    }
    public String getMessage() {
        return message;
    }

    public LockingRecords getLock() {
        return lock;
    }

    public ADM_Cookie cookie {
        get {
            if(cookie == null) {
                cookie = new ADM_Cookie(String.valueOf(scrumteamId), 'info');
            }
            return cookie;
        }
        set;
    }

    public Boolean packagedOrg{
        get{
          return signletonConstants.isPackagedOrg();
        }
        set;

    }

    public List<ADM_FieldWrapper> tabs {
        get {
            if(tabs == null) {
                tabs = new List<ADM_FieldWrapper>();
                ADM_FieldWrapper tab = new ADM_FieldWrapper('Team Information...');
                tab.fieldName = 'info';
                tabs.add(tab);

                tab = new ADM_FieldWrapper('Assignments');
                tab.fieldName = 'stories';
                tabs.add(tab);

                tab = new ADM_FieldWrapper('Sprints');
                tab.fieldName = 'sprints';
                tabs.add(tab);

                tab = new ADM_FieldWrapper('Dependencies');
                tab.fieldName = 'dependencies';
                tabs.add(tab);

                tab = new ADM_FieldWrapper('Release Support Information');
                tab.fieldName = 'releaseInfo';
                tabs.add(tab);
            }
            return tabs;
        }
        set;
    }

    public String getChatterGroups() {
        String chatterGroups = '';
        String gusUrl = ADM_WorkUtils.GUS_URL;
        ADM_Scrum_Team__c[] teams = [Select a.Chatter_Groups__c From ADM_Scrum_Team__c a Where Id =: scrumteamId];
        if(!teams.isEmpty()) {
            List<String> chGroupIds = new List<String>();
            List<String> invalidIds = new List<String>();
            String cGroupsValue = teams[0].Chatter_Groups__c;

            if(cGroupsValue != null) {
                for(String chGroupId : cGroupsValue.split('\\s*,\\s*',0)) {
                    if(ADM_TextUtils.isValidIdFormat(chGroupId)) {
                        chGroupIds.add(chGroupId);
                    } else {
                        invalidIds.add(chGroupId);
                    }
                }

                for(String chGroupId : chGroupIds) {
                    chatterGroups += '<a href="' + gusUrl +  '/_ui/core/chatter/groups/GroupProfilePage?g=' + chGroupId + '" target="_blank">' + chGroupId + '</a>, ';
                }

                if(chatterGroups == '' && cGroupsValue != '') return cGroupsValue;

                for(String invalidId : invalidIds) {
                    chatterGroups += invalidId + ', ';
                }

                chatterGroups = ADM_TextUtils.removeTrailingComma(chatterGroups);
            }

        }
        return chatterGroups;
    }

    private String scrumteamId {
        get {
            if(scrumteamId == null) scrumteamId = System.currentPageReference().getParameters().get('id');
            return scrumteamId;
        }
        set;
    }

    private ApexPages.StandardController controller;
    public ADM_ScrumTeamWorkExtension(ApexPages.StandardController controller) {
        lock = new LockingRecords(scrumteamId);
        lock.getLocks();
        this.controller = controller;
    }

    public Pagereference doSaveAndTeamDetail(){
        if (controller.save() != null) {
            ADM_Scrum_Team_Member__c teamMember = (ADM_Scrum_Team_Member__c) controller.getRecord();
            return new PageReference('/' + teamMember.Scrum_Team__c);
        }
        return null;
    }


    public Apexpages.Standardsetcontroller setController {
        get {
            try {
                if(setController == null) {
                    //limit 1 as we only care if they have more then 0 work records
                    Integer i = [select count() from ADM_Work__c where Scrum_Team__c = : scrumteamId limit 1];
                    if(i == 0) {
                        List<ADM_Work__c> works = new List<ADM_Work__c>();
                        setController = new Apexpages.Standardsetcontroller(works);
                    } else {
                        setController = new Apexpages.Standardsetcontroller(Database.getQueryLocator([
                            select Scrum_Team__c, RecordType.Name, Details__c , LastModifiedDate, Name, Subject__c, Priority_Rank__c, Priority__c, Story_Points__c, Status__c, Scheduled_Build__c, Closed_On__c
                            from ADM_Work__c
                            where Scrum_Team__c = : scrumteamId and RecordType.Name != : ADM_Work.TEMPLATE_RECORD_TYPE_NAME and Closed__c = 0
                            order by Id
                        ]));
                    }
                    setController.setPageSize(10);
                }
            } catch (System.Exception e) {
                List<ADM_Work__c> works = new List<ADM_Work__c>();
                setController = new Apexpages.Standardsetcontroller(works);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred loading the work records for this scrum team.' + e.getMessage()));
            }
            if(setController.getResultSize() == 0) {
                message = 'No records to display';
            }
            return setController;
        }
        set;
    }


    @RemoteAction
    public static void updateTeamDetails(ADM_Scrum_Team__c team){
        try{
/*
            Set<String> fields = new Set<String>();
            fields.add('Cloud_LU__c');
            fields.add('Business_Hours__c');

            if(!ADM_SchemaManager.areFieldsUpdateable('ADM_Scrum_Team__c',fields)){
                throw new DMLException('The ADM_Scrum_Team__c object has some fields that are not updateable. '+
                'Please check Cloud_LU__c and Business_Hours__c.');
            }
*/
             if(ADM_SchemaManager.isObjectUpdateable('ADM_Scrum_Team__c') && ADM_SchemaManager.areFieldsUpdateable('ADM_Scrum_Team__c', new Set<String>{'Cloud_LU__c', 'Capex_Lead__c', 'Business_Hours__c','Product_Owner__c','Scrum_Master__c' })){


            try {
             ADM_Cloud__c cloud = [select id, name from ADM_Cloud__c where name =:team.Cloud_LU__c or id =:team.Cloud_LU__c];
               if(cloud == null) {
                   throw new ADM_ApplicationException('Please enter a valid cloud');
               } else {

                   team.Cloud_LU__c = cloud.id;
               }
            } catch(Exception cloudException) {
                throw new ADM_ApplicationException('Please enter a valid cloud name');
            }

            try{

                List<User> capexLead = [select id, name from User where name =:team.Capex_Lead__c or id =:team.Capex_Lead__c];
                   if(capexLead.size() > 0) {
                       team.Capex_Lead__c = capexLead.get(0).id;
                   }
             }
            catch(Exception e) {
                throw new ADM_ApplicationException('Exception while saving Capex Lead : '+ e);
             }

            try{
                 if (Schema.sObjectType.ADM_Scrum_Team__c.fields.Product_Owner__c.isUpdateable()) {
                List<User> productOwner = [select id, name from User where name =:team.Product_Owner__c or id =:team.Product_Owner__c];
                   if(productOwner.size() > 0) {
                       team.Product_Owner__c = productOwner.get(0).id;
                   }
                 }
             }
            catch(Exception e) {
                throw new ADM_ApplicationException('Exception while saving Product Owner : '+ e);
             }

            try{
                if (Schema.sObjectType.ADM_Scrum_Team__c.fields.Scrum_Master__c.isUpdateable()) {
                List<User> scrumMaster = [select id, name from User where name =:team.Scrum_Master__c or id =:team.Scrum_Master__c];
                   if(scrumMaster.size() > 0) {
                       team.Scrum_Master__c = scrumMaster.get(0).id;
                   }
                }
             }
            catch(Exception e) {
                throw new ADM_ApplicationException('Exception while saving Scrum Master : '+ e);
             }

            if (team.Business_Hours__c!=null) {
               try {
                   BusinessHours bh = [select id, name from BusinessHours where name =:team.Business_Hours__c or id =:team.Business_Hours__c];
                   if(bh == null) {
                       throw new ADM_ApplicationException('Please enter a valid business hours name');
                   } else {
                       team.Business_Hours__c = bh.id;
                   }
                } catch(Exception cloudException) {
                    throw new ADM_ApplicationException('Please enter a valid business hours name');
                }
           }
            update team;
      }
        }
        catch(Exception e){
            System.debug('Exception while saving team from team Edit page : '+ e);
            throw new ADM_ApplicationException('Exception while saving team : '+ e);
        }
    }


    public List<ADM_WorkWrapper> workWrapper { get; set; }

    public List<ADM_WorkWrapper> getWorks() {
        workWrapper = new List<ADM_WorkWrapper>();
        for(ADM_Work__c work : (List<ADM_Work__c>) setController.getRecords()) {
            workWrapper.add(new ADM_WorkWrapper(work));
        }
        return workWrapper;
    }

    public Integer rowStart {
        get {
            if(!setController.getHasPrevious()) {
                if(setController.getResultSize() == 0) {
                    return 0;
                } else {
                    return 1;
                }
            } else {
                return setController.getPageSize() * (setController.getPageNumber() - 1) + 1;
            }
        }
        set;
    }

    public Integer rowEnd {
        get {
            if(!setController.getHasNext()) {
                return setController.getResultSize();
            } else {
                return setController.getPageSize() * setController.getPageNumber();
            }
        }
        set;
    }

    public Pagereference create() {
       Pagereference pr = Page.ADM_selectWorkRecordType;
       pr.setRedirect(true);
       return pr;
    }

    public Pagereference prioritize() {
        Pagereference pr = Page.ADM_WorkPrioritizer;
        pr.setRedirect(true);
        pr.getParameters().put('retUrl','/scrumteamId');
        pr.getParameters().put('scrumteamId',scrumteamId);
        return pr;
    }

    public Pagereference showNotecards() {
        String ids = '';
        for(ADM_WorkWrapper wrapper : workWrapper) {
            if(wrapper.checked) {
                String id = wrapper.work.Id;
                ids += ',' + id.substring(0, 15);
            }
        }

        ids = ids.replaceFirst(',', '');
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,ids));
        Pagereference pr = new Pagereference('/apex/ADM_ShowNoteCards?&workIds=' + ids);
        return pr;
    }

    public String getListViewLink() {
        Schema.DescribeSObjectResult teamDescribe = Schema.SObjectType.ADM_Scrum_Team__c;
        String objectPrefix = '/' + teamDescribe.getKeyPrefix();
        return objectPrefix;
    }

    public Boolean getCurrentUserLightningDesktopPreference() {

        return ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();

    }

}