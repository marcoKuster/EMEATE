public class ADM_Frequency {
    
    public static ADM_Frequency__c[] getAll( ){
        ADM_Frequency__c[] freqs = null;
        try {
            freqs = [select Id, Name, Order__c from ADM_Frequency__c  where Name != NULL order by Order__c];
        } catch (System.exception e) {
            System.debug(e);
            freqs = new ADM_Frequency__c[0];
        }
        return freqs;   
    }
    
    public static Map<Id, ADM_Frequency__c> getAllAsIDObjectMap(){
        Map<Id, ADM_Frequency__c> frequencyMap = null;
        try {
            frequencyMap = new Map<Id, ADM_Frequency__c>([select Id, Name, Order__c from ADM_Frequency__c  where Name != NULL order by Order__c]);
        } catch (System.exception e) {
            System.debug(e);
            frequencyMap = new Map<Id, ADM_Frequency__c>();
        }
        return frequencyMap;   
    }
    
    public static ADM_Frequency__c[] getByNameOrId(String param){
        ADM_Frequency__c[] freqs = null;
        try {
            freqs = [select Id, Name, Order__c from ADM_Frequency__c where Id = :param OR Name = :param];
        } catch (System.exception e) {
            System.debug(e);
            freqs = new ADM_Frequency__c[0];
        }
        return freqs; 
    }
    
     public static ADM_Frequency__c getDefaultFrequency() {
        ADM_Frequency__c defaultFrequency; 
        ADM_Frequency__c[] frequencies = ADM_Frequency.getByNameOrId('Often'); 
        if(frequencies == null || frequencies.size() < 1) {
            //if Often is not found default to the 1st impact based on the order field
            defaultFrequency = [select Id, Name, Order__c from ADM_Frequency__c order by Order__c limit 1];
        } else {
            defaultFrequency = frequencies.get(0); 
        }
        return defaultFrequency;
    }
}