public with sharing virtual class ADM_PriorityMatrixController {
    public List<ADM_Priority_Mapping__c> mappings { get; set; }
    public List<ADM_Frequency__c> frequencies { get; set; }
    public List<ADM_Impact__c> impacts { get; set; }
    public List<String> impactIds { 
        get {
            if(impactIds == null) impactIds = new List<String>();
            return impactIds;
        } 
        set; 
    }
    public List<ADM_PriorityWrapper> priorityWrappers {
    	get {
    		if(priorityWrappers == null) priorityWrappers = new List<ADM_PriorityWrapper>();
    		return priorityWrappers;
    	}
    	set;
    }
    
    public ADM_PriorityWrapper priorityWrapper { get; set; }
          
    public ADM_PriorityMatrixController(ApexPages.StandardController stdController) {
        this.frequencies = ADM_Frequency.getAll();
        this.impacts = ADM_Impact.getAllByType(ADM_Work.BUG_RECORD_TYPE_NAME);
        for(ADM_Impact__c impact : this.impacts) {
            this.impactIds.add(impact.Id);
        }
        List<ADM_sortingWrapper> sortingWrappers = new List<ADM_sortingWrapper>();
        ADM_sortingWrapper sortingWrapperFrequency = new ADM_sortingWrapper();
        ADM_sortingWrapper sortingWrapperImpact = new ADM_sortingWrapper();
        
        sortingWrapperFrequency.sortBy = 'Frequency__r.Order__c';
        sortingWrapperFrequency.sortOrder = 'ASC';
        
        sortingWrapperImpact.sortBy = 'Impact__r.Order__c';
        sortingWrapperImpact.sortOrder = 'ASC';
        
        sortingWrappers.add(sortingWrapperImpact);
        sortingWrappers.add(sortingWrapperFrequency);
                
        this.mappings = ADM_PriorityMapping.getAllBy('Impact__c', this.impactIds, sortingWrappers);
        
        for(ADM_Priority_Mapping__c mapping : this.mappings) {
			if(mapping.Frequency__r.Name.equalsIgnoreCase('always')) {
				priorityWrapper = new ADM_PriorityWrapper();
				priorityWrapper.impact = mapping.Impact__r.Name;
				priorityWrapper.always = mapping.Priority__r.Name;
				priorityWrapper.frequency = mapping.Frequency__r.Name;
        	}
        	if(mapping.Frequency__r.Name.equalsIgnoreCase('often')) {
        		if(priorityWrapper == null) continue;
    			priorityWrapper.often = mapping.Priority__r.Name;
        	}
        	if(mapping.Frequency__r.Name.equalsIgnoreCase('sometimes')) {        		
        		if(priorityWrapper == null) continue;
    			priorityWrapper.sometimes = mapping.Priority__r.Name;
        	}
        	if(mapping.Frequency__r.Name.equalsIgnoreCase('rarely')) {
        		if(priorityWrapper == null) continue;
    			priorityWrapper.rarely = mapping.Priority__r.Name;
        		priorityWrappers.add(priorityWrapper);
        		
        	}
        }            
    }
}