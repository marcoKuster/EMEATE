/**
 * REVIEWME: It is not certain whether we want to be restrictive on the values of each field 
 * i.e., (through auto-completion) or allow free text so that we can do a .*? search through SOSL 
 * 
 * TODO: It would be nice to disallow certain fields based on prior selections. For instance, if you
 * selected User Story for the type, then we should only display the status that are relevant to that type
 * 
 */
public with sharing class ADM_WorkSearchLayoutController {

    private static final String OPTION_NONE_LABEL = '';  
    
    public ADM_StringHolder queryHolder {get ; set;}
    public String queryFields {get; set;}
    
    // Just a placholder so we can use the productTagInput component for auto-completion
    private final RecordType recordType = null;
    
    // Just a placeholder so we can use some of the components that need a reference to an ADM_Work__c SObject
    // This value is only in memory and never inserted into the database
    private ADM_Work__c workPlaceholder;  
    
    // The different methods of retrieval (get,set vs explicit gets) is to account for some of the values
    // that we are getting out of our placeholder object.
     
    public String freeSearch { get; set; }
    
    public String getSubject() {
        return workPlaceholder.Subject__c;
    }
    
    public String selectedStatus { get; set; }
    
    public String getTeam() { 
        String scrumTeam = null;
        if (String.isNotBlank(workPlaceholder.Scrum_Team__c)) {
    		List<ADM_Scrum_Team__c> teams = [SELECT NAME FROM ADM_Scrum_Team__c WHERE id =: workPlaceholder.Scrum_Team__c LIMIT 1];
    		if (teams.size() == 1) {
    			scrumTeam = teams[0].name;
    		}
        }
        return scrumTeam;
    }
    
    public String selectedType { get; set; }
    
    public String getAssignedTo() { 
        String assigneeName = null;
        if (String.isNotBlank(workPlaceholder.Assignee__c)) {
            List<User> users = [SELECT NAME FROM user WHERE id =: workPlaceholder.Assignee__c LIMIT 1];
    		if (users.size() == 1) {
    			assigneeName = users[0].name;
    		}
    	}
        
        return assigneeName;
    }
    
    public String getScheduledBuild() {
        String scheduledBuild = null;
        if (String.isNotBlank(workPlaceholder.Scheduled_Build__c)) {
            List<ADM_Build__c> builds = [SELECT NAME FROM ADM_Build__c WHERE id =: workPlaceholder.Scheduled_Build__c LIMIT 1];
    		if (builds.size() == 1) {
    			scheduledBuild = builds[0].name;
    		}
    	}
        
        return scheduledBuild;
    }
    
    public String getProductTag() {
        String productTag = null;
        if (String.isNotBlank(workPlaceholder.Product_Tag__c)) {
    		List<ADM_Product_Tag__c> tags = [SELECT NAME FROM ADM_Product_Tag__c WHERE id =: workPlaceholder.Product_Tag__c LIMIT 1];
    		if (tags.size() == 1) {
    			productTag = tags[0].name;
    		}
        }

        return productTag;
    }
    
    public String selectedPriority { get; set; }
    
    public Date lastModified { get; set; }
    
    public String customerSearch { get; set; }

    private transient List<SelectOption> priorityOptions; 
    private transient List<SelectOption> statusOptions;
    private transient List<SelectOption> typeOptions;
    
    // TODO: Nate, since this part seems quite modular, maybe we can factor it to its own class?
    public void search() {
    	String lastModifiedString =  null;
    	if (lastModified != null) {
    		lastModifiedString = lastModified.year() + '-';
    		Integer num = lastModified.month();
    		lastModifiedString += (num < 10 ? '0' : '') + num + '-';
    		num = lastModified.day();
    		lastModifiedString += (num < 10 ? '0' : '') + num ;    		
    	}
    	
    	String assigneeName = getAssignedTo();
        String productTag = getProductTag();
        String scrumTeam = getTeam();
        String buildName = getScheduledBuild();

        
		String searchQueryString;
        
        if (freeSearch != null && freeSearch.length() > 0) {
            
	        searchQueryString = ADM_SearchWork.searchWork(freeSearch, queryFields, workPlaceholder.name, workPlaceholder.Subject__c, 
                                                selectedType, productTag, selectedStatus, 
                                                assigneeName, customerSearch, selectedPriority, scrumTeam, 
                                                buildName, lastModifiedString);
        } else if ((workPlaceholder.name + workPlaceholder.Subject__c + selectedType + productTag + 
                    selectedStatus + assigneeName + customerSearch + selectedPriority + scrumTeam + 
                    buildName + lastModifiedString).length() > 0) {
            searchQueryString = ADM_SearchWork.queryWork(freeSearch, queryFields, workPlaceholder.name, workPlaceholder.Subject__c, 
                                                selectedType, productTag, selectedStatus, 
                                                assigneeName, customerSearch, selectedPriority, scrumTeam, 
                                                buildName, lastModifiedString);
        }
		queryHolder.theString = searchQueryString;
    }
    
    public void cancel() {
        
    }
    
    public  RecordType getRecordType() {
        return recordType;
    }
    
    public ADM_Work__c getWorkPlaceholder() {
        return workPlaceholder;
    }
    
    public ADM_WorkSearchLayoutController() {
        recordType = ADM_RecordType.ensureByName('User Story', 'ADM_Work__c');
        workPlaceholder = new ADM_Work__c();
    }
    
    private List<Schema.PicklistEntry> getPriorityEntries() {
        return ADM_Work__c.Priority__c.getDescribe().getPicklistValues();
    }
    
    private List<Schema.PicklistEntry> getStatusEntries() {
        return ADM_Work__c.Status__c.getDescribe().getPicklistValues();
    }
    
    private List<Schema.PicklistEntry> getTypeEntries() {
        return ADM_Work__c.Type__c.getDescribe().getPicklistValues();
    }
    
    private void populateWithNoneOption(List<SelectOption> options) {
        options.add(new SelectOption('', OPTION_NONE_LABEL));
    }
    
    private List<SelectOption> createNewSelectOptions(List<Schema.PicklistEntry> pickListEntries) {
        List<SelectOption> options = new List<SelectOption>();
   
        populateWithNoneOption(options);
            
        for(Schema.Picklistentry pickListEntry : pickListEntries) {
                options.add(new SelectOption(pickListEntry.getLabel(), pickListEntry.getValue()));
        }
        
        return options;
    }
    
    public List<SelectOption> getPriorityOptions() {
        if(priorityOptions == null) {
            priorityOptions = createNewSelectOptions(getPriorityEntries());
        }
        return priorityOptions;
    }
    
    public List<SelectOption> getStatusOptions() {        
        if(statusOptions == null) {
            statusOptions = createNewSelectOptions(getStatusEntries());
        }
        
        return statusOptions;
    }

    public List<SelectOption> getTypeOptions() {
        if(typeOptions == null) {
            typeOptions = createNewSelectOptions(getTypeEntries());
        }
        return typeOptions;
    }
    
    public PageReference cancelBack() {
		PageReference pageRef = null;
        Map<string,string> URLParameters = ApexPages.currentPage().getParameters();
		if(URLParameters.containsKey('retURL')){
    		pageRef = new PageReference(URLParameters.get('retURL'));
    	}       
		return pageRef;
    }
}