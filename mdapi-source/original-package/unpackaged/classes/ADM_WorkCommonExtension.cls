global virtual with sharing class ADM_WorkCommonExtension {
    private final ApexPages.StandardController standardController; 
    private final ADM_Work__c selectedWork;
    private final RecordType recordType = null;
    private final ADM_Work.WorkType workType;
    private final Boolean isClone;
    
    private boolean showEditDialog;
    private transient List<SelectOption> statusOptions;
    ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance();

    public ADM_WorkCommonExtension(ApexPages.StandardController stdController) {
        this.standardController = stdController;
        /* Populate custom fields that aren't automatically populated by the standard controller - Apex insists this is the first request in your constructor.  
         * However skip this section for apex tests due to catch 22 error:  System.SObjectException: You cannot call addFields when the data is being passed into the controller by the caller.
         */
        if(!Test.isRunningTest()) {
            List<Schema.FieldSetMember> fields = SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'custom_fields').getFields();
            List<String> customFieldNames = new List<String>();
            for (Schema.FieldSetMember field: fields) {
                 customFieldNames.add(field.getFieldPath());
            }
            standardController.addFields(new List<String>(customFieldNames));    
        }
         if(!Test.isRunningTest()) {
            List<Schema.FieldSetMember> fields = SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
            List<String> additionalFieldNames = new List<String>();
            for (Schema.FieldSetMember field: fields) {
                 additionalFieldNames.add(field.getFieldPath()); //change var name
            }
            standardController.addFields(new List<String>(additionalFieldNames));
        } 

        if(!Test.isRunningTest()) {
            List<String> formulaFieldList = new List<String>();
            formulaFieldList.add('visual_link_num_of_Test_Failures__c');
            standardController.addFields(formulaFieldList);
        }

        
        this.selectedWork = (ADM_Work__c)stdController.getRecord();
        //load the record type for the selected work
        this.recordType = this.loadRecordType(selectedWork);
        this.selectedWork.RecordType = this.recordType;
        this.selectedWork.RecordTypeId = this.recordType.Id;
        this.workType = ADM_Work.getWorkType(this.recordType);
          
        //determine if we are currently cloning a record
        this.isClone = '1'.equals(System.currentPageReference().getParameters().get('clone'));
        
        //If new, set the default values otherwise load the existing values
        if(getIsNew() || getIsClone()) {
            this.setDefaultValues(this.selectedWork);
        } 
            
        /* When editing a record or cloning a record (via 'clone' or 'create work from template' buttons) we need to load any fields that 
        aren't automatically loaded by Visualforce. VisualForce only loads fields that are directly in the edit page as inputField components so 
        fields that only indirectly use inputField (such as our custom ADM_Input component) need to be fetched from the database.  
        The loadFields() method does not overwite existing values so any default values previously set will be retained */
        if(!getIsNew() || getIsClone()) {   
            this.loadFields();
        }
        
        //load any fields from the URL
        ADM_Work.setWorkValuesFromUrl(this.selectedWork);
        
        //set the origin so that the trigger knows where the save originated
        if(lightningExperience) {
            this.selectedWork.Origin__c = ADM_WorkTriggerStaticDataStore.LIGHTNING_EXPERIENCE_WORK_ORIGIN;
        } else {
            this.selectedWork.Origin__c = ADM_WorkTriggerStaticDataStore.NEXT_GEN_EDIT_PAGE_ORIGIN;
        }
        
        
        //if we are cloning, then let's process the work record
        if(this.isClone) {
            
            //remove any fields that are not supposed to be copied
            workType.removeFieldsNotApplicableForClone(this.selectedWork);
            
            // initialize fields with values for clone - Eg: Some fields such as Status needs to be set with 'New'
            workType.initializeFieldsForClone(this.selectedWork);
             
            //get the original record
            String cloneId = System.currentPageReference().getParameters().get('id');
            if(cloneId == null) {
                throw new ADM_ApplicationException('Expected an ID to be specified on the URL when cloning');
            }
            ADM_Work__c originalWork = ADM_Work.getById(cloneId);
            
            //if the parent ID field is already populated (as is the case with create work from template) use that otherwise copy relationships
            if(originalWork.Parent_ID__c != null) {
                this.selectedWork.Parent_ID__c = originalWork.Parent_ID__c;
            } else {
                //populate Parent_ID__c with comma seperated list of Work Names - relationships are created in trigger if this hidden field is populated
                this.selectedWork.Parent_ID__c = ADM_TextUtils.joinList(ADM_WorkTreeUtils.getParentNames('' + originalWork.Id), ',');
            }
            
        }
        
        //pre-run assignment rules but only under certain circumstances as it is expensive perf wise 
        if(getIsNew() && this.selectedWork.Product_Tag__c != null) {
            /*
            Bug fix: W-1866981 https://gus.my.salesforce.com/a07B0000000WpMqIAK
            Product Tag Assignee fields should be populated for new work is product tag pre-populated (as is the case with the New work buton on the child work related list)
            */
            ADM_Product_Tag__c productTag = ADM_ProductTag.get(this.selectedWork.Product_Tag__c);
           
            ADM_WorkAssignment.AssignmentContext assignments = ADM_WorkAssignment.getAssignments(this.selectedWork.severity_level__c, productTag, this.recordType, this.selectedWork.Type__c,null);
            
            
            List<String> assignmentErrors = (assignments.errorMessages != null)? assignments.errorMessages : new List<String>();
            for(String errorMessage: assignmentErrors) {
                this.selectedWork.addError(errorMessage);
            }
            if(assignments.assignments != null) {
                assignments.assignments.apply(this.selectedWork);
            }    
        }
        
    }
    
    public Boolean getCurrentUserLightningDesktopPreference() {
    
        return ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
        
    }
    
    public static String getBaseUrl(){
        return System.Url.getSalesforceBaseUrl().toExternalForm();
    }

    public boolean getShowEditDialog(){
       String urlRequested = Apexpages.currentPage().getUrl();
       String namespace = ADM_ConstantsSingleton.getInstance().getNameSpace();
       if(urlRequested.containsIgnoreCase('/apex/'+namespace+'adm_userstoryedit') || urlRequested.containsIgnoreCase('/apex/'+namespace+'adm_bugedit') || urlRequested.containsIgnoreCase('/apex/'+namespace+'adm_investigationedit')){
           return true;
       }
       else{
           return false;
       }
       
    }
    
    public ADM_Work__c getSelectedWork() {
        return this.selectedWork;
    }
    
    public RecordType getRecordType() {
        return this.recordType; 
    }
    
    public String getTitle() {
        if(getIsNew() || getIsClone()) {
            return this.recordType.Name;
        } else {
            return 'Work: ' + this.selectedWork.Name;
        }   
    }
    
    public Boolean getIsNew() {
        return this.selectedWork.Id == null;
    }
    
    public Boolean getIsClone() {
        return this.isClone;
    }
    
    public List<SelectOption> getStatusOptions() {
        if(statusOptions == null) {
            statusOptions = new List<SelectOption>();
            List<String> statusValues = ADM_Work.getStatusValues(recordType.Name);
            
            for(String statusValue : statusValues) {
                statusOptions.add(new SelectOption(statusValue, statusValue));
            }
        }
        
        return statusOptions;
    }


    public List<ADM_ColumnUtility.LeafNodeDetails> getKanbanStates() {

        if(null != this.selectedWork.Scrum_Team__c){
            return ADM_ColumnUtility.getLeafNodesByTeamId(this.selectedWork.Scrum_Team__c);
        }

        return null;
        
    }

    public Map<String,String> getKanbanStateMapping() {

        if(null != this.selectedWork.Scrum_Team__c){
            return ADM_KanbanUtility.getWorkStatusToColumnMapping(this.selectedWork.Scrum_Team__c);
        }

        return null;
        
    }
    
    public PageReference doSaveAndNew(){
        if(standardController.save() != null) {
            PageReference pageReference = Page.ADM_SelectWorkRecordType;
            ADM_Work__c savedWork = (ADM_Work__c)standardController.getRecord();
            pageReference.getParameters().put('Epic__c', selectedWork.Epic__c);
            pageReference.setRedirect(true);
            return pageReference;
        }
        return null;
    }
    
    public Pagereference doSaveAndDetail(){
        String retUrl = '';
        String sprintId = '';
        if (standardController.save() != null) {
            retUrl = ApexPages.currentPage().getParameters().get('retURL');   
            sprintId = ApexPages.currentPage().getParameters().get('Sprint__c');         
            if(!ADM_TextUtils.isNull(retUrl) && !ADM_TextUtils.isBlank(retUrl)&& !ADM_TextUtils.isNull(sprintId)){
                return new PageReference(retUrl);
            }
            else{
            SObject so = standardController.getRecord();
            return new PageReference('/' + so.Id);
            }
        }
        return null;
    }
    
  private RecordType loadRecordType(ADM_Work__c selectedWork) {
        RecordType recordType = null;
        
        /* New record try to retrieve the record type. For maximum backwards compatibility 
        check each of these parameters: RecordType, RecordTypeName, RecordTypeLogicalName */
        if(recordType == null){
            recordType = ADM_RecordType.getRecordTypeFromUrl('ADM_Work__c');
        }
        
        //get the record type from the record if it wasn't passed as a param
        if(recordType == null && selectedWork.RecordTypeId != null) {
            recordType = ADM_RecordType.getById(selectedWork.RecordTypeId);
        }
        
        //get the default record type if one has been specified
        if(recordType == null) {
            recordType = getDefaultRecordType();
        }
        
        //check that a record type has been specified
        if(recordType == null) { 
            throw new ADM_ApplicationException('RecordType must be specified on the URL using RecordTypeLogicalName or RecordType');
        }
        
        //check we are using a supported record type
        if(recordType.Name != 'Bug' && recordType.Name != 'User Story' && recordType.Name != 'Investigation') {
            throw new ADM_ApplicationException('Unsupported record type specified: ' + this.recordType.Name);
        }
        
        return recordType;
    }
    
     /**
     * If loading an existing record into the page, this method loads extra field values that may not have been
     * loaded dynamically by Visualforce. 
     */
    private void loadFields() { 
        if(this.getIsNew()) {
            return;
        }
        
        //retrieve fields in Work that should be loaded since std controller version doesn't hold everything we need
        ADM_Work__c loadedWork = ADM_Work.getOneBy('id',getSelectedWork().Id);
        
         //copy over the properties from the loaded object to the copy in the standard controller
        for(String fieldName : ADM_Work.getUpdateableFieldSet()) { 
            fieldName = fieldName.trim();
            if(!ADM_TextUtils.isBlank(fieldName)) {
                 ((SObject)selectedWork).put(fieldName, ((SObject)loadedWork).get(fieldName));  
            }
        }

    }
    
    /**
     * Override this method to provide a default record type when one is not specified.
     */
    protected virtual RecordType getDefaultRecordType() {
        return null;
    }
    
    /**
     * Override this method to provide default values for a new work record.
     */
    protected virtual void setDefaultValues(ADM_Work__c work) {
        
        //change the status to the new value if the record is new
        work.Status__c = workType.getNewStatus();
        if(null != System.currentPageReference().getParameters().get('Epic__c')){
            work.Epic__c = System.currentPageReference().getParameters().get('Epic__c');
        }
    }  

    public Boolean packagedOrg{
        get{
          return signletonConstants.isPackagedOrg();
        }
        set;
       
    }

    public String nameSpace{
        get{
          return signletonConstants.getNameSpace();
        }
        set;
       
    }
    
    public Boolean lightningExperience{
        get{
            //optional we could also pull a param off the url to determine if the user is in lightning like this: System.currentPageReference().getParameters().get('SOME_SFX_PARAM');
            return signletonConstants.getUserLightningExperiencePreferred();
        }
        set;
    }
    
}