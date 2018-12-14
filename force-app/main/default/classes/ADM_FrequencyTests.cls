@isTest
private class ADM_FrequencyTests {

    static testMethod void testFrequencyGetAll() {
        List<ADM_Frequency__c> freqs = new List<ADM_Frequency__c>{new ADM_Frequency__c(Name='Always', Order__c=1), new ADM_Frequency__c(Name='Often', Order__c=2), new ADM_Frequency__c(Name='Sometimes', Order__c=3), new ADM_Frequency__c(Name='Never', Order__c=4)};
        insert freqs;
        //running with late api version so we can assume test is in sandbox mode and will only find data we have created
        List<ADM_Frequency__c> retrievedFreqs = ADM_Frequency.getAll();
        //verify all frequencies were found sorted by Order__c
        System.assertEquals(4, retrievedFreqs.size());
        System.assertEquals('Always', retrievedFreqs.get(0).Name);
        System.assertEquals('Often', retrievedFreqs.get(1).Name);
        System.assertEquals('Sometimes', retrievedFreqs.get(2).Name);
        System.assertEquals('Never', retrievedFreqs.get(3).Name);
        
    }
    
    static testMethod void testFrequencyGetAllAsIDObjectMap() {
       List<ADM_Frequency__c> freqs = new List<ADM_Frequency__c>{new ADM_Frequency__c(Name='Always', Order__c=1), new ADM_Frequency__c(Name='Often', Order__c=2), new ADM_Frequency__c(Name='Sometimes', Order__c=3), new ADM_Frequency__c(Name='Never', Order__c=4)};
       insert freqs;
       //running with late api version so we can assume test is in sandbox mode and will only find data we have created
       Map<Id, ADM_Frequency__c> retrievedFreqsMap = ADM_Frequency.getAllAsIDObjectMap();
       System.assertEquals(4, retrievedFreqsMap.size());
        
    	
    	
    }
    
}