global virtual with sharing class ADM_WorkControllerGlobalAction {
    private transient List<SelectOption> impactOptions;
    private transient List<SelectOption> frequencyOptions;
    
    public String lastError;
    
    public ADM_Work__c work {
        get;
        set;
    }
    
    public String getLastError(){
        return lastError;
    }
    
    public RecordType getRecordType() {
        return ADM_RecordType.getById(work.RecordTypeId);
    }

    
    public List<SelectOption> getImpactOptions() {
        if(null == impactOptions) {
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
    
    public void saveAndView(){ 
         if(ADM_SchemaManager.isObjectCreateable('ADM_Work__c')) {
            //set the origin so that the trigger knows where the save originated
            work.Origin__c = ADM_WorkTriggerStaticDataStore.NEXT_GEN_EDIT_PAGE_ORIGIN;
            try{
                insert work;
                lastError = 'ok';
            }
            catch(Exception exp){
                lastError = 'DMLExcpetion';
            }
         }     

    }   

}