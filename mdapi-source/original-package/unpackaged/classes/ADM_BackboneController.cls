global with sharing class ADM_BackboneController {
	private Map<String, List<String>> workStatusValues;
	private List<String> priorities;
	private List<String> perforceStatusValues;
	
    /**
     * Gets the map of work status values grouped by the record type name
     */
	public Map<String, List<String>> getWorkStatusValues() {
		if(workStatusValues == null) {
			workStatusValues = ADM_Work.getStatusValues();
		}
		return workStatusValues;
	}
	
	/**
	 * Gets the map of work status values grouped by record type name as a JSON string
	 */
	public String getWorkStatusValuesAsJson() {
		return JSON.serialize(getWorkStatusValues());
	}
    
    /**
     * Gets the list of priorities  
     */
    public List<String> getPriorities() {
        if(this.priorities == null) {
            this.priorities = new List<String>();
            
            Schema.DescribeFieldResult fieldResult = ADM_Work__c.Priority__c.getDescribe();
            List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
            for(Schema.Picklistentry ple : ples) {
                this.priorities.add(ple.getLabel());
            }
        }
        return this.priorities;
    }
    
    /**
     * Gets the list of priorities as a JSON string
     */
    public String getPrioritiesAsJson() {
        return JSON.serialize(getPriorities());
    }
    
    /**
     * Gets the list of Perforce status values
     */
    public List<String> getPerforceStatusValues() {
        if(this.perforceStatusValues == null) {
            this.perforceStatusValues = new List<String>();
            
            Schema.DescribeFieldResult fieldResult = ADM_Work__c.Perforce_Status__c.getDescribe();
            List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
            for(Schema.Picklistentry ple : ples) {
                this.perforceStatusValues.add(ple.getLabel());
            }
        }
        return this.perforceStatusValues;
    }
    
    /**
     * Gets the list of Perforce status values as a JSON string
     */
    public String getPerforceStatusValuesAsJson() {
        return JSON.serialize(getPerforceStatusValues());
    }

}