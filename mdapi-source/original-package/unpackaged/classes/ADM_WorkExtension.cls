public with sharing class ADM_WorkExtension {
    
    private String selectedWorkId = null;
    private transient ADM_Work__c selectedWork = null;
    
    private String selectedRecordTypeId = null;
    private transient RecordType recordType = null;
    
    private String sprintId = null;
    private transient ADM_Sprint__c sprint = null;
    
    private String currentProductTagId = null;
    private transient ADM_Product_Tag__c currentProductTag = null;
    
    private transient List<ADM_Product_Tag__c> productTags = null;
    private transient List<ADM_Impact__c> impacts = null; 
    private transient List<ADM_Frequency__c> frequencies = null;
    private transient List<User> users = null;
    private transient List<ADM_Comment__c> comments = null;
    private transient List<String> priorities = null;
    private transient List<String> perforceStatusValues = null;
    private transient List<ADM_Scrum_Team__c> teams = null;
    
    /** 
     *   Constructor used by standard CRUD actions an object overides for Create, Clone and Edit 
     */
    public ADM_WorkExtension(ApexPages.StandardController stdController) {
        if(stdController.getId() != null) {
            
            this.selectedWorkId = stdController.getId();
            this.selectedRecordTypeId = getSelectedWork().RecordTypeId;
            this.sprintId = getSelectedWork().Sprint__c;
            this.currentProductTagId = getSelectedWork().Product_Tag__c;
        } else {
            
            this.selectedWork = (ADM_Work__c)stdController.getRecord();
            
            //attempt to retrieve the record type
            this.selectedRecordTypeId = System.currentPageReference().getParameters().get('RecordType');  
            if(!ADM_TextUtils.isBlank(this.selectedRecordTypeId)) {
                this.recordType = ensureRecordTypeById(this.selectedRecordTypeId);
            }
            
            //try to retrieve the record type using the logical name
            if(this.recordType == null) {
                String recordTypeName = System.currentPageReference().getParameters().get('RecordTypeLogicalName');
                if(ADM_TextUtils.isBlank(recordTypeName)) {
                    recordTypeName = System.currentPageReference().getParameters().get('RecordTypeName');
                }
                if(ADM_TextUtils.isBlank(recordTypeName)) {
                    throw new ADM_ApplicationException('RecordType must be specified on the URL using RecordTypeLogicalName or RecordType');
                }
                this.recordType = ensureRecordTypeByName(recordTypeName);
                this.selectedRecordTypeId = recordType.Id;
            }
            this.selectedWork.RecordTypeId = this.selectedRecordTypeId;
            
            //set the default status
            this.selectedWork.Status__c = 'New';
            this.selectedWork.Type__c = 'Bug';
        }
        this.selectedWork.Origin__c = ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN;
    } 
    
    /**
     * Constructor Used for callers without a standard controller such as MDP Global Actions 
     */
    public ADM_WorkExtension() {
        this.selectedWork = new ADM_Work__c();
        //set the default status
        this.selectedWork.Status__c = 'New';
        this.selectedWork.Origin__c = ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN;
    } 
    
   /**
    *    Helper method to initialize record type for MDP actions since we don't have a 
    *    standard controller and cannot pass parameters via the URL 
    */
    public void initBugRecordType() {
        this.recordType = ensureRecordTypeByName('Bug');
        if(this.recordType == null) {
            throw new ADM_ApplicationException('Bug record type not found');
        } else {
            this.selectedRecordTypeId = recordType.Id;
            this.selectedWork.RecordTypeId = this.selectedRecordTypeId;
            this.selectedWork.Type__c = 'Bug';
        }
    }
    
    public void initUserStoryRecordType() {
        this.recordType = ensureRecordTypeByName('User Story');
        if(this.recordType == null) {
            throw new ADM_ApplicationException('User Story record type not found');
        } else {
            this.selectedRecordTypeId = recordType.Id;
            this.selectedWork.RecordTypeId = this.selectedRecordTypeId;
            this.selectedWork.Type__c = 'User Story';
        }
    }
    
    /**
     * Gets a list of all the users
     */
    public List<User> getUsers() {
        if(this.users == null) {
            this.users = [select Id, Name, SmallPhotoUrl from User where Name != NULL];
        }
        return this.users;
    }
    
    /**
     * Gets a list of all users as JSON
     */
    public String getUsersAsJson() {
        return JSON.serialize(getUsers());
    }
    
    /**
     * Gets the selected work
     */
    public ADM_Work__c getSelectedWork() {
        if(this.selectedWork == null) {
            List<ADM_Work__c> works = [select Id, Name, RecordTypeId, Subject__c, Description__c, Details__c, Status__c, Product_Tag__c, Assignee__c, Product_Owner__c, QA_Engineer__c, Sprint__c, Story_Points__c, Encoded_Recipients_Txt_Area__c, Type__c, Impact__c, Frequency__c, Found_in_Build__c, Scheduled_Build__c, Details_and_Steps_to_Reproduce__c, Priority__c, Priority_Override_Explanation__c, ftest__c, Root_Cause_Analysis_2__c, Perforce_Status__c from ADM_Work__c where Id = :selectedWorkId limit 1];
            if(works.size() > 0) {
                this.selectedWork = works.get(0);
            }
        }
        return this.selectedWork;
    }
    
    /**
     * Gets the selected work as JSON 
     */
    public String getSelectedWorkAsJson() {
        return JSON.serialize(getSelectedWork());
    }
    
    public ADM_Product_Tag__c getCurrentProductTag() {
        if(this.currentProductTag == null && currentProductTagId != null) {
            List<ADM_Product_Tag__c> productTags = [select Id, Name, Team__c, Team__r.Name from ADM_Product_Tag__c where Id = :currentProductTagId limit 1];
            if(productTags.size() > 0) {
                this.currentProductTag = productTags.get(0); 
            }
        }
        return this.currentProductTag;
    }
    
    public List<ADM_Product_Tag__c> getProductTags() {
        if(this.productTags == null) {
            
            //preload all of the tags associated to the record type
            this.productTags = getProductTagsForRecordType(getRecordType().Name);
            
            //add the current product tag if it isn't already in the list
            ADM_Product_Tag__c currentProductTag = getCurrentProductTag();
            if(currentProductTag != null) {
                Boolean found = false;
                for(ADM_Product_Tag__c productTag : this.productTags) {
                    if(productTag.Id == currentProductTag.Id) {
                        found = true;
                        break;
                    }
                }
                if(!found) {
                    this.productTags.add(currentProductTag);
                }
            }
        }
        return this.productTags;
    }
    
    /**
     * Gets the product tags to cache in the page as a JSON string
     */
    public String getProductTagsAsJson() {
        return JSON.serialize(getProductTags());
    }
    
    public RecordType getRecordType() {
        if(this.recordType == null && selectedRecordTypeId != null) {
            List<RecordType> recordTypes = [select Id, Name from RecordType where Id = :selectedRecordTypeId];
            if(recordTypes.size() > 0) {
                this.recordType = recordTypes.get(0);
            }
        }
        return this.recordType;
    }
    
    public String getRecordTypesAsJson() {
        return JSON.serialize(new List<RecordType>{getRecordType()});
    }
    
    /**
     * Gets the sprint related to the work object
     */
    public ADM_Sprint__c getSprint() {
        if(this.sprint == null && sprintId != null) {
            List<ADM_Sprint__c> sprints = [select Id, Name from ADM_Sprint__c where Id = :sprintId];
            if(sprints.size() > 0) {
                this.sprint = sprints.get(0);
            }
        }
        return this.sprint;
    }
    
    /**
     * Gets the sprints to cache in the page as a JSON string
     */
    public String getSprintsAsJson() {
        return JSON.serialize(new List<ADM_Sprint__c>{getSprint()});
    }
    
    /**
     * Gets the list of comments related to the work object
     */
    public List<ADM_Comment__c> getComments() {
        if(this.comments == null && selectedWorkId != null) {
            //this.comments = ADM_Comment.getAllUnprocessed(this.selectedWorkId);
            this.comments = [select Id, Work__c, Comment_Created_By__c, Comment_Created_Date__c, Body__c from ADM_Comment__c where Work__c = :selectedWorkId];
        }
        return this.comments;
    }
    
    /**
     * Gets the list of comments related to the work object as a JSON string
     */
    public String getCommentsAsJson() {
        return JSON.serialize(this.getComments());
    }
    
    public List<ADM_Impact__c> getImpacts() {
        if(this.impacts == null && this.getSelectedWork() != null && this.getSelectedWork().Type__c != null) {
            this.impacts = getImpactsForBugType(getSelectedWork().Type__c);
        }
        return impacts;
    }
    
    public String getImpactsAsJson() {
        return JSON.serialize(getImpacts());
    }
    
    public List<ADM_Frequency__c> getFrequencies() {
        if(this.frequencies == null) {
            this.frequencies = ADM_Frequency.getAll();
        }
        return this.frequencies;
    }
    
    public String getFrequenciesAsJson() {
        return JSON.serialize(this.getFrequencies());
    }
    
    public List<ADM_Scrum_Team__c> getTeams() {
        if(this.teams == null) {
            this.teams = [select Id, Name from ADM_Scrum_Team__c where Name != NULL];
        }
        return this.teams;
    }
    
    public String getTeamsAsJson() {
        return JSON.serialize(this.getTeams());
    }
    
    @RemoteAction
    public static List<ADM_Impact__c> getImpactsForBugType(String bugType) {
        return ADM_Impact.getAllByType(bugType);
    }
    
    @RemoteAction
    public static String calculatePriority(ID frequencyID, ID impactID) {
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
            
            return null;
        }
    }
    
    @RemoteAction
    public static ADM_WorkAssignment.AssignmentContext getAssignments(String severityLevel, ADM_Product_Tag__c productTag, RecordType recordType, String workType, String recipients) {
        return ADM_WorkAssignment.getAssignments(severityLevel, productTag, recordType, workType, recipients);
    }
    
    @RemoteAction 
    public static List<ADM_Product_Tag__c> getProductTagsForRecordType(String recordTypeName) {
        return [select Id, Name, Team__c from ADM_Product_Tag__c where Id in (select Product_Tag__c from  ADM_Tag_Assignment__c where Record_Type__c = :recordTypeName)];
    }
    
    private static RecordType ensureRecordTypeById(String id) {
        List<RecordType> recordTypes = [select Id, Name from RecordType where Id = :id];
        if(recordTypes.isEmpty()) {
            throw new ADM_ApplicationException('No RecordType found with the ID of ' + id);
        }
        return recordTypes.get(0);
    }
    
    private static RecordType ensureRecordTypeByName(String name) {
        List<RecordType> recordTypes = [select Id, Name from RecordType where Name = :name];
        if(recordTypes.isEmpty()) {
            throw new ADM_ApplicationException('No RecordType found with the name ' + name);
        } else if(recordTypes.size() > 1) {
            
        }
        return recordTypes.get(0);
    }
}