trigger QA_insertTC on QA_Test_Case__c (after insert, after undelete, after update) {
    // Create a new Hierarchy record per every new level in the hierarchy 
    // EXAMPLE:
    // Assume we are inserting 1 test case with hierarchy: "a.b.c" and 
    // the existing hiearchies are (name=a,count=2,path=a),(name=b,count=1,patch=a.b),(name=d,count=1,patch=a.d)
    //
    // The result should be  (name=a,count=3,path=a),(name=b,count=2,patch=a.b),(name=d,count=1,patch=a.d)
    // ,(name=c,count=1,patch=a.b.c)    

    // 1. Create a map of all the hierarchies that are needed, update the count accordingly
    Map<String, QA_Hierarchy__c> mapH = new Map<String, QA_Hierarchy__c>();
    for(QA_Test_Case__c curTC : Trigger.new){
        String[] curHierArr = curTC.Hierarchy__c.split('[.]');      
        String curHierStr = '';
        for(Integer i = 0; i < curHierArr.size(); i++){
            if(i==0)
                curHierStr = curHierArr[i];
            else
                curHierStr += '.' + curHierArr[i];
            if(mapH.containsKey(curHierStr.toLowerCase())) {
                QA_Hierarchy__c curHier = mapH.get(curHierStr.toLowerCase());
                curHier.Count__c ++;
                mapH.remove(curHierStr.toLowerCase());
                mapH.put(curHierStr.toLowerCase(), curHier);
            } else {
                QA_Hierarchy__c newHier = new QA_Hierarchy__c();
                newHier.Name = curHierArr[i];
                newHier.Depth__c = i;
                newHier.Full_Path__c = curHierStr;
                newHier.Count__c = 1;
                mapH.put(curHierStr.toLowerCase(), newHier);
            }
        }
    }
    
    // 2. Query for all the hierarchies and update the count
    for (QA_Hierarchy__c existingHierarchy : [SELECT Name, Count__c, Full_Path__c, Id FROM QA_Hierarchy__c WHERE Full_Path__c in :mapH.keySet()]){
        if(existingHierarchy != null) {
            QA_Hierarchy__c newHierarchy = mapH.get(existingHierarchy.Full_Path__c.toLowerCase());
            newHierarchy.Count__c = newHierarchy.Count__c + existingHierarchy.Count__c;
            newHierarchy.Name = existingHierarchy.Name;
            mapH.put(existingHierarchy.Full_Path__c.toLowerCase(), newHierarchy);
        }
    }
    
    // 3. upsert
    upsert mapH.values() Full_Path__c ;
}