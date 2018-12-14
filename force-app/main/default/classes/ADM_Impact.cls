public class ADM_Impact {
    
    private static final String FIELD_NAMES = 'Id, Name, Order__c';
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_FROM = 'from ADM_Impact__c i';  
    
    public static Map<Id, ADM_Impact__c> getAllAsIDObjectMap( ){
        Map<Id, ADM_Impact__c> impactMap = new Map<Id, ADM_Impact__c>();
        try {
            impactMap = new Map<Id, ADM_Impact__c>([select Id, Name, Order__c from ADM_Impact__c where Name != NULL order by Order__c]);
        } catch (System.exception e) {
            System.debug(e);
        }   
        return impactMap;   
    }
    
    public static ADM_Impact__c[] getAllByType(String workType) {
        return [select id, Name, Order__c from ADM_Impact__c where id in (select Impact__c from ADM_Impact_Type__c where Type__r.Name = :workType) order by Order__c];  
    }
    
    public static Map<String, Set<String>> getImpactsByTypeMap() {
        Map<String, Set<String>> impactMapByType = new Map<String, Set<String>>();
        List<ADM_Impact_Type__c> impactTypes = [select Impact__c, Name, Impact__r.Name, Type__c, Type__r.Name from ADM_Impact_Type__c where Name != NULL];
        for(ADM_Impact_Type__c i : impactTypes) {
            if(impactMapByType.containsKey(i.Type__r.Name)) {
                //add to list
                impactMapByType.get(i.Type__r.Name).add(i.Impact__c);
            } else {
                impactMapByType.put(i.Type__r.Name, new Set<String>{i.Impact__c});
            }
        }
        return impactMapByType;
    }
    
     public static ADM_Impact__c getByNameOrId(String param){
        ADM_Impact__c impact = null;
        try {
            impact = [select Id, Name, Order__c from ADM_Impact__c where Id = :param OR Name = :param];
        } catch (System.exception e) {
            System.debug(e);
            
        }
        return impact; 
    }
    
    public static ADM_Impact__c getDefaultImpact() {
         ADM_Impact__c defaultImpact = ADM_Impact.getByNameOrId('Malfunctioning'); 
        if(defaultImpact == null) {
            //if Malfunctioning is not found default to the 1st impact based on the order field
            defaultImpact = [select Id, Name, Order__c from ADM_Impact__c order by Order__c limit 1];
        }
        return defaultImpact;
    }
        
    
    
}