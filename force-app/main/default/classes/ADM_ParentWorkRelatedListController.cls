public with sharing class ADM_ParentWorkRelatedListController {
    private static final Integer RELATED_LIST_SIZE_ON_LOAD = 5;
    private static final String ERROR_ITEM_EXISTS = 'A prior {0} already exists';
    
	private String workId;
	private List<String> errorMessages;
	private Boolean parentsCache = false;
	private Boolean parentworkLimit = false; 
	private List<ADM_Parent_Work__c> parents = null;
	private Integer relatedParentWorkListSize = -1;
	
	private Id idOfParentWorkBeingModified = null;
    
    //remember if a create new record or edit record is in progress.  Effects display when re-renders
    private Boolean relatedParentWorkCreateFlag = false;
    private Boolean relatedParentWorkEditFlag = false;
	
    public ADM_ParentWorkRelatedListController() {
        
    }
    
    public String getWorkId() {
    	return workId;
    }
    
    public void setWorkId(String workId) {
    	this.workId = workId;
    }
    
    public List<String> getErrorMessages() {
    	return errorMessages;
    }
    
    /* 
     * All related lists filter the number of objects displayed if the list is too long.  These methods determine if the limit
     * is in place, enable the limit and disable the limit.
     */
    public Boolean getParentWorkLimit() {
        return parentWorkLimit;
    }

    public void enableParentWorkLimit() {
        parentWorkLimit = true;
        this.clearParentsCache();
    }

    public void disableParentWorkLimit() {
        parentWorkLimit = false;
        this.clearParentsCache();
    }
    
    public void clearParentsCache() {
    	this.parentsCache = false;
    	this.parents = null;
    	this.relatedParentWorkListSize = -1;
    }
    
    /*
     * The id of the object being modified is passed and used to populate an instance of the object ready for manipulation (edit or delete)
     */
    public void setIDOfParentWorkBeingModified(Id pid) {
        idOfParentWorkBeingModified = pid;
    }
    
    public String getIDOfParentWorkBeingModified() {
        return idOfParentWorkBeingModified;
    }
    
    public Boolean getRelatedParentWorkCreateFlag() {
    	return relatedParentWorkCreateFlag;
    }
    
    public Boolean getRelatedParentWorkEditFlag() {
    	return relatedParentWorkEditFlag;
    }
    
    public Integer getRelatedParentWorkListSize() {
    	return relatedParentWorkListSize;
    }
    
    public String newParentWorkName {
        get;
        set;
    }
    
    public String relationshipType {
    	get;
    	set;
    }
    
    public PageReference redirectToNewParentWorkRecord() {
        ADM_Work__c work = ADM_Work.getById(this.workId);
        
        PageReference newWork = Page.ADM_selectWorkRecordType;
        newWork.getParameters().put('Child_ID__c', work.Name);
        //only Bugs use the Type field and even that will be deprecated soon
        if(work.RecordType.Name == 'Bug')newWork.getParameters().put('Type__c', work.Type__c);
        newWork.getParameters().put('Product_Tag__c', work.Product_Tag__r.Name);
        newWork.getParameters().put('Minor_Func_Area__c', work.Minor_Func_Area__c);
        newWork.getParameters().put('Scrum_Team__c', work.Scrum_Team__r.Name);
        
        //want to change the URL as a result of navigation
        newWork.setRedirect(true);
        
        return newWork;
    }
    
    public PageReference deleteParentWork() {
        try {
        	//clear any left over error messages
            this.clearErrorMessages();
            
            //get the parent work record
            Id parentWorkId = getIDOfParentWorkBeingModified();
            if(parentWorkId == null) {
            	throw new ADM_ApplicationException();
            }
            ADM_Parent_Work__c parentWork = getParentWorkById(parentWorkId);
            
            //clear the list size to force it to be re-generated
            this.clearParentsCache();
            relatedParentWorkEditFlag = false;
            
            ADM_ParentWork.remove(parentWork);
            return null;
        } catch (Exception e) {
            this.errorMessages.add('An error has occurred while attempting to remove a parent work relationship.');
            return null;
        }
    }
    
    /*
     * Creates a new ADM_Parent_Work records using the current work item being viewed as the child and the user inputed Parent ID
     * as the parent
     */
    public PageReference createNewParentWork() {
        try {
            //clear any left over error messages
            this.clearErrorMessages();
            
            
            String[] arrParentWorkIds = ADM_ParentWork.splitWorkItems(this.newParentWorkName);
            List<ADM_Work__c> validatedWorkItems = ADM_ParentWork.validateWorkItems(ADM_ParentWork.trimWorkItems(arrParentWorkIds));
            //compare user input to validated list size
            if(arrParentWorkIds.size() > validatedWorkItems.size()) {
                
                errorMessages.add('Please enter a valid Work ID. ' + newParentWorkName + ' is invalid');
                return null;
            }
            
            //for each valid parent work ID entered check if a relationship already exists and if it doesn't create one
            Boolean successfulSave = false;
            for( ADM_Work__c validPWork : validatedWorkItems ){
                //if it doesn't exist then insert relationship
                if(validateWorkRelations(this.workId, validPWork.id)) {
                    
                    ADM_Parent_Work__c parent = new ADM_Parent_Work__c();
                    parent.Parent_Work__c = validPWork.Id;
                    parent.Child_Work__c = this.workId;
                    
                    if('original'.equalsIgnoreCase(this.relationshipType)) {
                        parent.Duplicate__c = true;
                    } else {
                        parent.Duplicate__c = false;
                    }
                    
                    Database.SaveResult sr = ADM_ParentWork.add(parent);
                    if(sr.isSuccess()) {
                        successfulSave = true;
                    }
                
                } else {
                    System.debug('createNewParentWork() error messages:' + this.errorMessages);
                }
            }
            
            if(successfulSave) {
                //if relating original then set the current work records status to Duplicate
                if('original'.equalsIgnoreCase(this.relationshipType)) {
                	
                    //need to determine record type due to different applicable statuses
                    Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
                    try {
                        ADM_Work__c original = [select id, RecordTypeId, status__c from ADM_Work__c where id=:this.workId];
                        if(workRecordTypesById.get(original.recordTypeId).Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
                            original.status__c = 'Closed - Duplicate';      
                        } else {
                            original.status__c = 'Duplicate';
                        }
                        
                        update original;
                    }  catch (Exception e) {
                        System.debug('createNewParentWork() caught exception e:' + e);
                        errorMessages.add('An error occurred while attempting to mark the current work records status to duplicate.');
                        return null;
                    }
                }
            }
            
            //reset the display
            this.relatedParentWorkCreateFlag = false;
            this.clearParentsCache();
            this.newParentWorkName = '';
            
            System.debug('Exiting createNewParentWork() Limits.getQueries():' + Limits.getQueries());
            return null;
        } catch (Exception e) {
            System.debug('createNewParentWork() caught exception ' + e.getMessage());
            errorMessages.add('An error has occurred while attempting to relate a new parent work record.');
            return null;
        }
    }
    
    
    /*
     * Return either the full list of related objects or the limited list depending on the related lists limit flag
     *
     */
    public List<ADM_Parent_Work__c> getRelatedParentWorkList() {
        if(parentsCache != null && !parentsCache){
            if (parentworkLimit) {
                parents = ADM_ParentWork.getParentWorkByChildWithLimit(RELATED_LIST_SIZE_ON_LOAD, getWorkId());
                //need to calculate the full size of the list for display
                relatedParentWorkListSize = ADM_ParentWork.getParentWorkCount(getWorkId());
            } else {
            	//-1 to signal no limit should be applied
                parents = ADM_ParentWork.getParentWorkByChildWithLimit(-1, getWorkId());
                relatedParentWorkListSize = parents.size();
            }
            parentsCache = true;
        }
        return parents;
    }
    
    private void clearErrorMessages() {
        this.errorMessages = new List<String>();
    }
    
    private Boolean validateWorkRelations(Id cwID, Id newID) {
        System.debug('Entering validateWorkRelations() Limits.getQueries():' + Limits.getQueries() + ' cwID:' + cwID + ' newID:' + newID);
        
        //work ID already exists as parent
        if(ADM_WorkTreeUtils.anchestorExists(cwID, newID)) {
            errorMessages.add(String.format(ERROR_ITEM_EXISTS, new List<String>{'ancestor'}));
            return false;
        }
        
        //work ID already exists as child
        if (ADM_WorkTreeUtils.childExists(cwID, newID)) {
            errorMessages.add(String.format(ERROR_ITEM_EXISTS, new List<String>{'descendent'}));
            return false;
        }
        
        String recordType = [select RecordType.Name from ADM_Work__c where Id =: newID].RecordType.Name;
        if(!ADM_WorkTreeUtils.isValidRecordTypeAssociation(recordType)) {
            errorMessages.add(ADM_WorkTreeUtils.getRecordTypeErrorMsg(recordType));
            return false;
        } 
        
        if (cwID == newID) {
            errorMessages.add('A work item cannot be related to itself');
            return false;
        }
        
        System.debug('Exiting validateWorkRelations() Limits.getQueries():' + Limits.getQueries() + ' cwID:' + cwID + ' newID:' + newID);
        return true;
    }
    
    private static ADM_Parent_Work__c getParentWorkById(Id id) {
    	List<ADM_Parent_Work__c> parentWorks = [select Id, Parent_Work__r.Name, Child_Work__c, External_ID__c from ADM_Parent_Work__c where id = :id];
    	if(parentWorks.isEmpty()) {
    		return null;
    	} else {
    		return parentWorks.get(0);
    	}
    }
}