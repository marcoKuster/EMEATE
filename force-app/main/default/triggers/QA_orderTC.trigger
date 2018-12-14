trigger QA_orderTC on QA_Test_Case__c (before insert) {
    List<QA_Test_Case__c> tc = new List<QA_Test_Case__c>();
    List<String> tcHiers = new List<String>();      
    Map<String, Double> hierCountsMap = new Map<String, Double>();
    Double count;   
    
    for(QA_Test_Case__c curTC : Trigger.new){
        if (curTC.Hierarchy__c == null) {
            curTC.addError('Please provide a valid base hierarchy!');
            continue;   
        }
        String curHierarchy = curTC.Hierarchy__c;
        tcHiers.add(curHierarchy);
        tc.add(curTC);              
    }

    QA_Hierarchy__c[] hiers = [SELECT Count__c, Full_Path__c, Id FROM QA_Hierarchy__c WHERE Full_Path__c IN : tcHiers];

    for(QA_Hierarchy__c curHier : hiers){                  
        hierCountsMap.put(curHier.Full_Path__c, curHier.Count__c);
    }
    
    for(QA_Test_Case__c curTC : tc) {
        if(hierCountsMap != null && !hierCountsMap.isEmpty()){
            Set<String> hierarchySet = hierCountsMap.keySet();
            for(String hierarchyStr : hierarchySet){
                if(hierarchyStr.equalsIgnoreCase(curTC.Hierarchy__c)){
                    curTC.Hierarchy__c = hierarchyStr;
                    break;
                }
            }
        }
        String curHierarchy = curTC.Hierarchy__c;
        if(hierCountsMap.containsKey(curHierarchy)){
                count = hierCountsMap.get(curHierarchy);
                curTC.Order__c = count;
                hierCountsMap.put(curHierarchy, count+1); 
        }           
        else {
                curTC.Order__c = 0;
                hierCountsMap.put(curHierarchy, 1);
        }
    }
}