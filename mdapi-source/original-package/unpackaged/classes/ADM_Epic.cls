@isTest 
public with sharing class ADM_Epic {
    
    public static ADM_Epic__c createTestEpic() {
        ADM_Epic__c epic = new ADM_Epic__c(Name = 'Test Epic');
        insert epic;        
        return epic;
    }

}