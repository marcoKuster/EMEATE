public with sharing class ADM_WorkDeepCloneController {
    
    private ADM_Work__c work;
    private transient ADM_Work__c cloneOfWork;
    
    public Boolean cloneAcceptanceCriteria { get; set; }
    public Boolean cloneTasks { get; set; }
    public Boolean cloneThemeRelationships { get; set; }
    public Boolean cloneThemeAssignments { get; set; }
    public Boolean checkboxForParentPicklist { get; set; }
    public Boolean checkboxForChildPicklist { get; set; }
    public String parentValue { get; set; }
    public String childValue { get; set; }
    @AuraEnabled
    public ADM_Work__c getOriginal() {
        return work;
    }
    
    /**
     * This method is exposed for testing
     */
    public ADM_Work__c getCloneOfWork() {
        return cloneOfWork;
    }
    
    public ADM_WorkDeepCloneController(ApexPages.StandardController controller) {
        this.work = (ADM_Work__c) controller.getRecord();
        this.cloneAcceptanceCriteria = true;
        this.cloneTasks = true;
        this.cloneThemeAssignments = true;
        this.checkboxForParentPicklist = true;
        this.checkboxForChildPicklist = true;
    }
    
    @AuraEnabled
    public static DeepCloneWorkDetailResponse getWorkDetails(String workId){
        ADM_WorkDeepCloneController.DeepCloneWorkDetailResponse workDetails = new ADM_WorkDeepCloneController.DeepCloneWorkDetailResponse();
        try{
            ADM_Work__c workObject = [select id, Name, Subject__c, Status__c, Scrum_Team__c,Scrum_Team__r.Name, Scrum_Team__r.id, Theme__c  from ADM_Work__c where id=:workId];
            workDetails.workObj = workObject;
            List<ADM_Theme_Assignment__c> themes = [select Theme__r.Name from ADM_Theme_Assignment__c where Work__c =: workId];
            workDetails.themes = themes;
            List<ADM_Task__c> tasks = [select id, Name, Subject__c, Hours_Remaining__c from ADM_Task__c where Work__c =: workId ];
            workDetails.tasks = tasks;
            List<ADM_Acceptance_Criterion__c> ac = [select id, Name, Description__c from ADM_Acceptance_Criterion__c where Work__c=: workId];
            workDetails.ac = ac;
            
            
            List<String> workIds = new List<String>();
            List<ADM_Parent_Work__c> parentWorkIdsFromRelatedWork = [select Parent_Work__c from ADM_Parent_Work__c  where Child_Work__c  =:workId];
            for(ADM_Parent_Work__c pwId : parentWorkIdsFromRelatedWork){
                workIds.add(pwId.Parent_Work__c);
            }
            
            List<ADM_Work__c> parentAWork = [select Name, id, Assignee__r.Name, Status__c, Subject__c, Type__c, Priority__c, Scheduled_Build_Name__c ,Closed__c, Resolved__c  from ADM_Work__c  where id in : workIds];

            //List<ADM_Parent_Work__c> parentWork = [select Parent_Work__r.Name, Parent_Work__r.id,Parent_Work__r.Assignee__c,Parent_Work__r.Status__c, Parent_Work__r.Subject__c, Parent_Work__r.Type__c, Parent_Work__r.Priority__c,Parent_Work__r.Scheduled_Build_Name__c ,Parent_Work__r.Closed__c, Parent_Work__r.Resolved__c  from ADM_Parent_Work__c  where Child_Work__c  =:workId];
            
            List<ADM_Parent_Work__c> childWorkIdsFromRelatedWork = [select Child_Work__c from ADM_Parent_Work__c  where Parent_Work__c  =:workId];
            //List<ADM_Parent_Work__c> childWork = [select Child_Work__r.Name, Child_Work__r.id, Child_Work__r.Assignee__c, Child_Work__r.Status__c, Child_Work__r.Subject__c, Child_Work__r.Type__c, Child_Work__r.Priority__c, Child_Work__r.Scheduled_Build_Name__c , Child_Work__r.Closed__c, Child_Work__r.Resolved__c  from ADM_Parent_Work__c  where Parent_Work__c  =:workId];
               workIds = new List<String>();
            for(ADM_Parent_Work__c cwId : childWorkIdsFromRelatedWork){
                workIds.add(cwId.Child_Work__c);
            }
            
            List<ADM_Work__c> childAWork = [select Name, id, Assignee__r.Name, Status__c, Subject__c, Type__c, Priority__c, Scheduled_Build_Name__c ,Closed__c, Resolved__c  from ADM_Work__c  where id in : workIds];

            Map<String,String> userIdWithUserName = new Map<String,String>();
             
            workDetails.parentWork = parentAWork;
            workDetails.childWork = childAWork;
            workDetails.nameSpace = ADM_WorkDeepCloneController.getNameSpace();
            return workDetails;
        }
        catch(Exception e){
            System.debug('Exception : '+ e);
            workDetails.status = 'Exception';
            workDetails.errorMessage = e.getMessage();
            return workDetails;
        }
    }
    
    public PageReference cloneWork() {
        //we save a reference of the cloned work so that we can retrieve it during testing
        if(this.cloneOfWork == null) {
            ADM_WorkDeepCloner cloner = new ADM_WorkDeepCloner();
            cloner.cloneAcceptanceCriteria = this.cloneAcceptanceCriteria;
            cloner.cloneTasks = this.cloneTasks;
            cloner.cloneThemeAssignments = this.cloneThemeAssignments;
            if(this.checkboxForParentPicklist == true){
                cloner.parentValue = this.parentValue;
            }
            else{
                cloner.parentValue = 'None';
            }
            if(this.checkboxForChildPicklist == true){
                cloner.childValue = this.childValue;
            }
            else{
                cloner.childValue = 'None';
            }
            this.cloneOfWork = cloner.clone(this.work);
        }
        return new PageReference('/' + this.cloneOfWork.Id);
    }
    
    public static String getNameSpace(){
        return ADM_ConstantsSingleton.getInstance().getNameSpace();
    }
    
     @AuraEnabled
    public static String deepCloneWork(Map<String,Object> deepCloneOptions){
        try{
            
        ADM_WorkDeepCloner cloner = new ADM_WorkDeepCloner();
        cloner.cloneAcceptanceCriteria = (Boolean)deepCloneOptions.get('isAc');
        cloner.cloneTasks = (Boolean) deepCloneOptions.get('isTasks');
        cloner.cloneThemeAssignments = (Boolean) deepCloneOptions.get('isTheme');
        if((Boolean) deepCloneOptions.get('isParent')){
           cloner.parentValue = (String) deepCloneOptions.get('parentSelect');
        }
        else{
            cloner.parentValue = 'None';
        }
        if((Boolean) deepCloneOptions.get('isChild')){
            cloner.childValue = (String) deepCloneOptions.get('childSelect');
        }
        else{
            cloner.childValue = 'None';
        }
        String workId = (String) deepCloneOptions.get('workId');
        ADM_Work__c originalWork = [select id from ADM_Work__c where id=:workId];
        ADM_Work__c clonedWork = cloner.clone(originalWork);
        return clonedWork.id;
        }
        catch(Exception e){
            System.debug(e);
            System.debug(deepCloneOptions);
            return e.getMessage();
        }
    }
   
   public class DeepCloneWorkDetailResponse{
       @AuraEnabled
        public String nameSpace;
        @AuraEnabled
        public ADM_Work__c workObj;
        @AuraEnabled
        public List<ADM_Theme_Assignment__c> themes;
        @AuraEnabled
        public List<ADM_Acceptance_Criterion__c > ac;
        @AuraEnabled
        public List<ADM_Task__c> tasks;
        @AuraEnabled
        public List<ADM_Work__c> parentWork;
        @AuraEnabled
        public List<ADM_Work__c> childWork;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String status;
    }
    
    public class DeepCloneOptionsClass{
        @AuraEnabled
        public Boolean isTheme;
         @AuraEnabled
        public Boolean isAc;
         @AuraEnabled
        public Boolean isTasks;
         @AuraEnabled
        public Boolean isParent;
         @AuraEnabled
        public Boolean isChild;
         @AuraEnabled
        public String parentSelect;
         @AuraEnabled
        public String childSelect;
    }
    
}