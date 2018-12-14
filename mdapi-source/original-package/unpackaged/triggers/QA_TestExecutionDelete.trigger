trigger QA_TestExecutionDelete on QA_Test_Execution__c (after undelete, before delete) {

     if(Trigger.isDelete){
        QA_Test_Execution__c[] testExec = Trigger.old;
        
        List<QA_ExecutionBug__c> execBugList = [select id from QA_ExecutionBug__c where Execution__c in: testExec LIMIT 1000];
           if(!execBugList.isEmpty()){
              system.debug('------delete.execBugLis.size(): ' + execBugList.size());
              
                if(execBugList.size() < 201){
                    Database.DeleteResult[] DR_Dels = Database.delete(execBugList);
                }else{
                    System.debug('deleteTE trigger GREATER THAN 200');
                    List<QA_ExecutionBug__c> tempExecBugList = new List<QA_ExecutionBug__c>();
                        for(QA_ExecutionBug__c exec: execBugList){
                            tempExecBugList.add(exec);
                            if(tempExecBugList.size() == 200){
                                Database.DeleteResult[] DR_Dels = Database.delete(tempExecBugList);
                                tempExecBugList.clear();
                            }
                        }
                        if(!execBugList.isEmpty())
                            Database.DeleteResult[] DR_Dels = Database.delete(tempExecBugList);
                 }
            }
     }
     if(Trigger.isUndelete){
        QA_Test_Execution__c[] testExec = Trigger.new;
        List<QA_ExecutionBug__c> execBugList = [select id from QA_ExecutionBug__c where Execution__c in: testExec LIMIT 1000 ALL ROWS];
           if(!execBugList.isEmpty()){
                system.debug('------undelete.execBugLis.size(): ' + execBugList.size());
                
                if(execBugList.size() < 201){
                    Database.UnDeleteResult[] DR_UDels = Database.undelete(execBugList);
                }else{
                    List<QA_ExecutionBug__c> tempExecBugList = new List<QA_ExecutionBug__c>();
                        for(QA_ExecutionBug__c exec: execBugList){
                            tempExecBugList.add(exec);
                            if(tempExecBugList.size() == 200){
                                Database.UnDeleteResult[] DR_UDels = Database.undelete(tempExecBugList);
                                tempExecBugList.clear();
                            }
                        }
                        if(!execBugList.isEmpty())
                            Database.UnDeleteResult[] DR_UDels = Database.undelete(tempExecBugList);
                 }
            }

     }
}