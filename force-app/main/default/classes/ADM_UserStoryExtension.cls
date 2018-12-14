global with sharing class ADM_UserStoryExtension extends ADM_WorkCommonExtension {
    private final ADM_Work__c selectedWork;
    private static final String OPTION_NONE_LABEL = '--None--';
    private transient List<SelectOption> impactOptions;
    private transient List<SelectOption> frequencyOptions;
    private transient List<SelectOption> priorityOptions;

    public ADM_UserStoryExtension(ApexPages.StandardController stdController) {
        super(stdController);
        this.selectedWork = (ADM_Work__c)stdController.getRecord();
        // If this is a new or cloned User Story, set the default values unique to User Stories
        if (getIsNew() || getIsClone()) {
            setDefaultValues();
        }
    }

    private void setDefaultValues() {
        this.selectedWork.Use_Prioritizer__c = true;
    }

    public PageReference doClone() {
        PageReference pr;
        boolean isSFXPagePreferred = ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
        if(isSFXPagePreferred){
            pr = Page.ADM_UserStoryEditSds;           
        }
        else{
             pr = Page.ADM_UserStoryEdit;
        }
        
        pr.setRedirect(true);
        pr.getParameters().put('id', getSelectedWork().Id);
        pr.getParameters().put('clone','1');
        pr.getParameters().put('retURL','/' + getSelectedWork().Id);
        return pr;
    }
    
    protected override RecordType getDefaultRecordType() {
        return ADM_RecordType.ensureByName('User Story', 'ADM_Work__c');
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
}