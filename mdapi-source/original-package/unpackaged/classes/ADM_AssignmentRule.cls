public class ADM_AssignmentRule {

    private static final string FIELD_NAMES = 'Exception_Request_POC__c, Id, Name, Additional_Emails__c, Inactive__c, Senior_Management_POC_Assignment__c, Scrum_Team_Assignment__c, Product_Owner__c, Assignee_Assignment__c, Tech_Writer_Assignment__c, QA_Assignment__c, Systest_Assignment__c, UE_Engineer__c, Sev_1_Assignee__c, Sev_2_Assignee__c, Sev_3_Assignee__c, Sev_4_Assignee__c';
    private static final string TABLE_NAME = 'ADM_Assignment_Rule__c';
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_FROM = 'from ' + TABLE_NAME;
    private static final String HELP_RULE = 'Help Rule';
    public static final Map<String,Set<String>> FIELDS_BY_RECORD_TYPE = new Map<String,Set<String>>{'Bug' => new Set<String>{'Scrum_Team_Assignment__c'}};
    
    public static ADM_Assignment_Rule__c[] getAll(String columnName, List<String> columnValues, Boolean getHelpRule) {
        return getAll(columnName, columnValues, 1, 1000, 'Name', 'ASC', getHelpRule);
    }    
    
    public static ADM_Assignment_Rule__c getById(String id) {
        String soql = SQL_SELECT + SQL_FROM + ' where Id = :id';
        List<ADM_Assignment_Rule__c> rules = Database.query(soql);
        if(rules.isEmpty()) {
        	return null;
        } else {
        	return rules.get(0);
        }
    }
    
    public static Map<Id, ADM_Assignment_Rule__c> convertAssignmentRuleListToMapById(List<ADM_Assignment_Rule__c> assignmentRules) {
		Map<Id, ADM_Assignment_Rule__c> assignmentRulesById = new Map<Id, ADM_Assignment_Rule__c>();
		for(ADM_Assignment_Rule__c rule : assignmentRules) {
			assignmentRulesById.put(rule.Id, rule);
		}
		return assignmentRulesById;
    }
    
    public static ADM_Assignment_Rule__c[] getAll(String columnName, List<String> columnValues, Integer rowStart, Integer rowEnd, String sortBy, String sortOrder, Boolean getHelpRule) {
        ADM_Assignment_Rule__c[] els = new ADM_Assignment_Rule__c[]{};
        String inValues = '';
        Integer inValuesCounter = 0;
        Integer i = 0;
        
        String inColumnValues = COM_SoqlUtils.createInClause(columnName, columnValues);
        
        String sql = SQL_SELECT + SQL_FROM + ' where (' + inColumnValues + ' ';
        
        if(getHelpRule) {
            sql = sql + ' or Name = ' + '\'' + HELP_RULE + '\'';
        }
        
        sql = sql + ') and Inactive__c = false ' + 'order by ' + COM_SoqlUtils.createOrder(sortBy, sortOrder);
        for(ADM_Assignment_Rule__c work : Database.query(sql)) {                             
            i++;
            if(i >= rowStart && i <= rowEnd) {
                els.add(work);
            }
        }
        
        return els;
    }   
    
    /**
     * From the list of rules, the 'Help' rule is returned. If no rules are the
     * 'Help' rule, then a null reference is returned.
     */
    public static ADM_Assignment_Rule__c getHelp( List<ADM_Assignment_Rule__c> rules ){     
        for( ADM_Assignment_Rule__c rule : rules ){
            if( isHelpRule(rule) ){
                return rule;
            }
        }
        
        return null;
    }
    
    /**
     * Determines if the specified rule is the 'Help' rule
     */
    public static Boolean isHelpRule(ADM_Assignment_Rule__c rule) {
        return rule.Name.equalsIgnoreCase(HELP_RULE);
    }
    
    /**
     * If the assignment rule passed in is active, look for one existing active assignment
     * rule with the same Scrum Team and Assignment Rules.  Returns the ID of the duplicate
     * assignment rule id.
     **/
	public static String checkForDuplicateAssignmentRule(ADM_Assignment_Rule__c rule) {
		String duplicateAssignmentRuleId = null;
    	if (!rule.Inactive__c) {
	    	// Check if there is another active assignment rule with the same scrum team and assignment values.  If there is, we can't allow a duplicate.
	        List<ADM_Assignment_Rule__c> ruleList = [select ID from ADM_Assignment_Rule__c where Scrum_Team_Assignment__c = :rule.Scrum_Team_Assignment__c and Assignee_Assignment__c =:rule.Assignee_Assignment__c 
	        		and Exception_Request_POC__c = :rule.Exception_Request_POC__c and Systest_Assignment__c = :rule.Systest_Assignment__c and Product_Owner__c = :rule.Product_Owner__c  
	        		and QA_Assignment__c = :rule.QA_Assignment__c and Senior_Management_POC_Assignment__c = :rule.Senior_Management_POC_Assignment__c and Tech_Writer_Assignment__c = :rule.Tech_Writer_Assignment__c
	        		and UE_Engineer__c = :rule.UE_Engineer__c and Sev_1_Assignee__c =:rule.Sev_1_Assignee__c and Sev_2_Assignee__c =:rule.Sev_2_Assignee__c and Sev_3_Assignee__c =:rule.Sev_3_Assignee__c and Sev_4_Assignee__c =:rule.Sev_4_Assignee__c  and  Additional_Emails__c = :rule.Additional_Emails__c and Inactive__c = false and id != :rule.id limit 1];
	        		
	        if (ruleList.size() > 0) {
	        	duplicateAssignmentRuleId = ruleList.get(0).ID;
	        }
    	}
		return duplicateAssignmentRuleId;		   
	}
	
	/**
	 * Creates an assignment rule with all of the assignments set to random
	 * users and to a random team.  
	 *
	 * The returned instance is not inserted into the database. Use #createAndInsertAssignmentRule()
	 * to insert the instance also.
	 */
	@IsTest
	public static ADM_Assignment_Rule__c createAssignmentRule() {
		ADM_Assignment_Rule__c assignmentRule = new ADM_Assignment_Rule__c();
		assignmentRule.Product_Owner__c = ADM_WorkUser.createTestUser().Id;
		assignmentRule.Tech_Writer_Assignment__c = ADM_WorkUser.createTestUser().Id;
        assignmentRule.Assignee_Assignment__c = ADM_WorkUser.createTestUser().Id;
        assignmentRule.QA_Assignment__c = ADM_WorkUser.createTestUser().Id;
        assignmentRule.UE_Engineer__c = ADM_WorkUser.createTestUser().Id;
        assignmentRule.Systest_Assignment__c = ADM_WorkUser.createTestUser().Id;
        assignmentRule.Senior_Management_POC_Assignment__c = ADM_WorkUser.createTestUser().Id;
        assignmentRule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName().Id;
        return assignmentRule;
	}
	
	/**
	 * Creates and inserts an assignment rule with all of the assignments set to 
	 * random users and to a random team.
	 */
	@IsTest
	public static ADM_Assignment_Rule__c createAndInsertAssignmentRule() {
		ADM_Assignment_Rule__c assignmentRule = createAssignmentRule();
        insert assignmentRule;
        return assignmentRule;
	}
	
	public static testMethod void testGetHelp() {
        ADM_Assignment_Rule__c assignmentRule = createAssignmentRule();
        assignmentRule.Name = HELP_RULE;
        insert assignmentRule;
        
        ADM_Assignment_Rule__c returned = ADM_AssignmentRule.getHelp(new List<ADM_Assignment_Rule__c>{assignmentRule});
        
        System.assertEquals(assignmentRule.Id, returned.Id);
	}

     public static Set<Id> buildUserIdsFromAssignmentRules(List<ADM_Assignment_Rule__c> rules) {
        Set<Id> userIds = new Set<Id>();
       
        for(ADM_Assignment_Rule__c rule : rules) {
            userIds.add(rule.Exception_Request_POC__c);
            userIds.add(rule.Senior_Management_POC_Assignment__c);
            userIds.add(rule.Product_Owner__c);
            userIds.add(rule.Assignee_Assignment__c);
            userIds.add(rule.Tech_Writer_Assignment__c);
            userIds.add(rule.QA_Assignment__c);
            userIds.add(rule.Systest_Assignment__c);
            userIds.add(rule.UE_Engineer__c);
            userIds.add(rule.Sev_1_Assignee__c);
            userIds.add(rule.Sev_2_Assignee__c);
            userIds.add(rule.Sev_3_Assignee__c);
            userIds.add(rule.Sev_4_Assignee__c);
        }
        
        return userIds;
    }
}