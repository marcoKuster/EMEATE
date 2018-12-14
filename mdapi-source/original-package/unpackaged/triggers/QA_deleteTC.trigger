trigger QA_deleteTC on QA_Test_Case__c (after delete, after undelete, after update, 
before delete) {
    // Reduce the count of every hierarchy on every new level in the hierarchy 
    // EXAMPLE:
    // Assume we are changing 1 test case with hierarchy: "a.b" to "a.c"
    // The existing hiearchies are (name=a,count=2,path=a),(name=b,count=1,patch=a.b)
    //
    // The result should be  (name=a,count=2,path=a),(name=c,count=1,patch=a.c)
    // This trigger only cares about reducing the count in a and removing b
   //to delete Execution Bugs 
   if(Trigger.isDelete){ 
        QA_Test_Case__c[] testCase = Trigger.old;
        QA_Test_Execution__c[] testExec = [select Id from QA_Test_Execution__c where Test_Case__c in : testCase LIMIT 1000];
        QA_ExecutionBug__c[] execBug = [Select Id from QA_ExecutionBug__c  where Execution__c in : testExec LIMIT 1000];
        if(execBug != null){
            if(execBug.size() < 201){
                Database.DeleteResult[] DR_Dels = Database.delete(execBug);
            }
            else{
                List<QA_ExecutionBug__c> tempExecBugList = new List<QA_ExecutionBug__c>();
                for(QA_ExecutionBug__c exec: execBug){
                    tempExecBugList.add(exec);
                    if(tempExecBugList.size() == 200){
                        Database.DeleteResult[] DR_Dels = Database.delete(tempExecBugList);
                        tempExecBugList.clear();
                    }
                }
                if(!tempExecBugList.isEmpty())
                    Database.DeleteResult[] DR_Dels = Database.delete(tempExecBugList);
            }
        }
   }
   
   //to undelete Execution Bugs 
   if(Trigger.isUnDelete){ 
        QA_Test_Case__c[] testCase = Trigger.new;
        QA_Test_Execution__c[] testExec = [select Id from QA_Test_Execution__c where Test_Case__c in : testCase LIMIT 1000];
        QA_ExecutionBug__c[] execBug = [Select Id from QA_ExecutionBug__c  where Execution__c in : testExec LIMIT 1000 ALL ROWS];
        if(execBug != null){
            if(execBug.size() < 201){
                Database.UnDeleteResult[] DR_Dels = Database.undelete(execBug);
            }
            else{
                List<QA_ExecutionBug__c> tempExecBugList = new List<QA_ExecutionBug__c>();
                for(QA_ExecutionBug__c exec: execBug){
                    tempExecBugList.add(exec);
                    if(tempExecBugList.size() == 200){
                        Database.UnDeleteResult[] DR_Dels = Database.undelete(tempExecBugList);
                        tempExecBugList.clear();
                    }
                }
                if(!tempExecBugList.isEmpty())
                    Database.UnDeleteResult[] DR_Dels = Database.undelete(tempExecBugList);
            }
        }
   }  
   
    if(!Trigger.isUndelete && Trigger.isAfter){
        // 1. Create a map of all the hierarchies that are needed, update the count accordingly
        Map<String, QA_Hierarchy__c> mapH = new Map<String, QA_Hierarchy__c>();
        for(QA_Test_Case__c curTC : Trigger.old){
            String[] curHierArr = curTC.Hierarchy__c.split('[.]');     
            String curHierStr = '';
            for(Integer i = 0; i < curHierArr.size(); i++){
                if(i==0)
                    curHierStr = curHierArr[i];
                else
                    curHierStr += '.' + curHierArr[i];
                if(mapH.containsKey(curHierStr.toLowerCase())) {
                    QA_Hierarchy__c curHier = mapH.get(curHierStr.toLowerCase());
                    curHier.Count__c --;
                    mapH.put(curHierStr.toLowerCase(), curHier);
                } else {
                    QA_Hierarchy__c newHier = new QA_Hierarchy__c();
                    newHier.Count__c = -1;
                    mapH.put(curHierStr.toLowerCase(), newHier);
                }
            }
        }
    
        List<QA_Hierarchy__c> reduceCount = new List<QA_Hierarchy__c>();
        // 2. Query for all the hierarchies and update the count
        List<QA_Hierarchy__c> deleteHiers = new List<QA_Hierarchy__c>();
        for (QA_Hierarchy__c existingHierarchy : [SELECT Count__c, Full_Path__c, Id FROM QA_Hierarchy__c WHERE Full_Path__c in :mapH.keySet()]){
            if(existingHierarchy != null) {
                    existingHierarchy.Count__c = existingHierarchy.Count__c + mapH.remove(existingHierarchy.Full_Path__c.toLowerCase()).Count__c;
                    if (existingHierarchy.Count__c > 0) {
                        reduceCount.add(existingHierarchy);
                    } else {
                        deleteHiers.add(existingHierarchy);
                    }
            }
        }
        // 3. upsert
        update reduceCount;
        delete deleteHiers; 
    }
}