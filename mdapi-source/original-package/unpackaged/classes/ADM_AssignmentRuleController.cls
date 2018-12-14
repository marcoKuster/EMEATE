public with sharing class ADM_AssignmentRuleController {
    
    public static final Boolean CLONE_OPTION_PRESERVE_ID = false;
    public static final Boolean CLONE_OPTION_IS_DEEP_CLONE = true;
    
    public ADM_Assignment_Rule__c rule { 
        get;
        set;
    }
    
    public String returnURL { 
        get;
        set;
    }

    public Boolean isNewRule {
    	get;
    	set;
    }
    
    public ApexPages.StandardController stdController {
    	get;
    	set;
    }

    List<ADM_Product_Tag__c> tags;
    
    public ADM_AssignmentRuleController(ApexPages.StandardController stdController) {
        try {
           this.stdController = stdController;
           this.rule = (ADM_Assignment_Rule__c)stdController.getRecord();
           populateRule();
           returnURL = System.currentPageReference().getParameters().get('retURL');           
        } catch(System.Exception e) {
            System.debug('Exception During Assignment Rule Init:' + e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to initialize Assignment Rule'));
            
        }    
    }
    
    private void setValuesFromUrl() {
        List<String> fieldsFromUrl = new List<String>{'Assignee__c','Product_Owner__c','QA_Engineer__c','Scrum_Team__c','Senior_Manager__c','Systest_Engineer__c','Tech_Writer__c','UE_Engineer__c','Suggestion_ID'};
        Map<String, String> fieldValuesFromUrl = new Map<String, String>();
        String fieldName = '';

        for(String fieldFromUrl : fieldsFromUrl) {
            String fieldValueFromUrl = System.currentPageReference().getParameters().get(fieldFromUrl);

            if( fieldValueFromUrl != null) {
                fieldValuesFromUrl.put(fieldFromUrl, EncodingUtil.urlEncode(fieldValueFromUrl, 'UTF-8'));
            }
        }
        
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('Assignee__c'))) rule.Assignee_Assignment__c = fieldValuesFromUrl.get('Assignee__c');
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('Product_Owner__c'))) rule.Product_Owner__c = fieldValuesFromUrl.get('Product_Owner__c');
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('QA_Engineer__c'))) rule.QA_Assignment__c = fieldValuesFromUrl.get('QA_Engineer__c');
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('Scrum_Team__c'))) rule.Scrum_Team_Assignment__c = fieldValuesFromUrl.get('Scrum_Team__c');
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('Senior_Manager__c'))) rule.Senior_Management_POC_Assignment__c = fieldValuesFromUrl.get('Senior_Manager__c');
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('Systest_Engineer__c'))) rule.Systest_Assignment__c = fieldValuesFromUrl.get('Systest_Engineer__c');
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('Tech_Writer__c'))) rule.Tech_Writer_Assignment__c = fieldValuesFromUrl.get('Tech_Writer__c');
        if(!ADM_TextUtils.isBlank(fieldValuesFromUrl.get('UE_Engineer__c'))) rule.UE_Engineer__c = fieldValuesFromUrl.get('UE_Engineer__c'); 
    }
    
    private void populateRule() {
        
       
        if(this.rule.id != null) {
            //flesh out the object - version passed by std controller only holds the id
            this.rule = [select Exception_Request_POC__c, id, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, Additional_Emails__c, Inactive__c, Senior_Management_POC_Assignment__c, Scrum_Team_Assignment__c, Product_Owner__c, Assignee_Assignment__c, Tech_Writer_Assignment__c, QA_Assignment__c, Systest_Assignment__c, UE_Engineer__c, Sev_1_Assignee__c, Sev_2_Assignee__c, Sev_3_Assignee__c, Sev_4_Assignee__c from ADM_Assignment_Rule__c where id=:rule.id];
            this.isNewRule = false;
        } else {
        	this.isNewRule = true;
        }   
        
        setValuesFromUrl();
               
        //check if item is being cloned
        String clonePageVar = System.currentPageReference().getParameters().get('clone');
        if(clonePageVar != null && clonePageVar.equalsIgnoreCase('1')) {
            ADM_Assignment_Rule__c ruleClone;   
            ruleClone = rule.clone(CLONE_OPTION_PRESERVE_ID, CLONE_OPTION_IS_DEEP_CLONE);
            ruleClone.Name = '';
            this.rule = ruleClone;
        }    
        
        
    }
    
    public PageReference saveRule() {
    	String duplicateAssignmentRuleId = ADM_AssignmentRule.checkForDuplicateAssignmentRule(rule);
    	if (duplicateAssignmentRuleId == null) {
    		try {
	    		// The assignment rule we are working with is not a duplicate.  Continue with save logic.
	            upsert rule;
	            
				if(returnURL != null && returnURL.contains(ADM_WorkUtils.GUS_URL)) {
	                return new PageReference(this.returnURL);
	            } else {
	                return new PageReference('/' + rule.id);
	            }
    		} catch(System.Exception e) {
    			System.debug('Exception during assignment rule save: ' + e);
    			return null;
    		}
    	} else {
    		// We have a duplicate assignment rule. Format an error with the duplicate rule included.     
            String errorMessage = 'An Assignment rule already exists with the criteria you have specified.';
            errorMessage = errorMessage + '<a href="/' + duplicateAssignmentRuleId + '">View Duplicate</a> ';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));        
            return null;
        }       
    }
    
    public PageReference cloneRule() {
        return new PageReference('/' + rule.id + '/e?clone=1');
    }
    
}