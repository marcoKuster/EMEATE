global with sharing class ADM_BugExtension extends ADM_WorkCommonExtension {
    private static final String OPTION_NONE_LABEL = '--None--';
    private transient List<SelectOption> impactOptions;
    private transient List<SelectOption> frequencyOptions;
    private transient List<SelectOption> priorityOptions; 

    public ADM_BugExtension(ApexPages.StandardController stdController) {
        super(stdController);
    }
    
    public String currentPriority { 
        get;
        set;
    }

    public String calculatedPriority {
        get {
            if(calculatedPriority == null) {
                if(getSelectedWork().Frequency__c != null && getSelectedWork().Impact__c != null) {
                    calculatedPriority = ADM_WorkRemoteActionsExtension.calculatePriority(getSelectedWork().Frequency__c, getSelectedWork().Impact__c);
                }
            }
            return calculatedPriority;
        }
        set;
    } 
    
    public List<SelectOption> getImpactOptions() {
        if(impactOptions == null) {
            impactOptions = ADM_BugUtils.getImpactsForBug();
        }
        return impactOptions;
    }
    
    public List<SelectOption> getFrequencyOptions() {
        if(null == frequencyOptions){
            frequencyOptions = ADM_BugUtils.getFrequencyOptions();
        }
        return frequencyOptions;
    }

    public List<SelectOption> getPriorityOptions() {
        if(priorityOptions == null) {
            Schema.DescribeFieldResult fieldResult = ADM_Work__c.Priority__c.getDescribe();
            List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
            priorityOptions = new List<SelectOption>();

            for(Schema.Picklistentry pickListEntry : pickListEntries) {
                priorityOptions.add(new SelectOption(pickListEntry.getLabel(), pickListEntry.getValue()));
            }
        }
        return priorityOptions;
    }
    
    public PageReference doClone() {
        PageReference pr;
        boolean isSFXPagePreferred = ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred(); 
        if(isSFXPagePreferred){
            pr = Page.ADM_BugEditSds;           
        }
        else{
             pr = Page.ADM_BugEdit;
        }
        pr.setRedirect(true);
        pr.getParameters().put('id', getSelectedWork().Id);
        pr.getParameters().put('clone','1');
        pr.getParameters().put('retURL','/' + getSelectedWork().Id);
        return pr;
    }

     public Pagereference doSaveBugAndNew(){
        setPriorityDefault(getSelectedWork());
        return doSaveAndNew();
     }

    public Pagereference doSaveBugAndDetail(){
        setPriorityDefault(getSelectedWork());
        return doSaveAndDetail();
    }

     private void setPriorityDefault(ADM_Work__c work) {
        work.Priority_Default__c = ADM_WorkRemoteActionsExtension.calculatePriority(work.Frequency__c, work.Impact__c);
     }

    
    protected override RecordType getDefaultRecordType() {
        return ADM_RecordType.ensureByName('Bug', 'ADM_Work__c');
    }
    
    protected override void setDefaultValues(ADM_Work__c work) {
        super.setDefaultValues(work); 
        
        //set the default properties for a Bug
        getSelectedWork().Status__c = 'New';
        getSelectedWork().Type__c = 'Bug';
    }
    
    public Boolean getDetailsAndStepsToReproduceContainsHTML() {
        try {
            return ADM_TextUtils.containsHTML(getSelectedWork().Details_And_Steps_To_Reproduce__c);
        } catch (Exception e) {
            //if something goes wrong it's safer to assume it contains html and render the rich text editor then assume plain text and show raw html tags
            System.debug(LoggingLevel.ERROR, 'Exception checking for html:' + e);
            return true;    
        }   
    }
    
}