public class ADM_WorkUnsubscriber implements Schedulable {
   public void execute(SchedulableContext SC) {
      deleteEntitySubscriptionForWorks();
   }
   
     
  private void deleteEntitySubscriptionForWorks(){
    
    /*

      Querying records that are last modified between 180 - 90 days and those whose status is closed__c = 1

    */
    if(Test.isRunningTest()){
      //No last modified check for test methods...as data can be created only in tests and lastModified date check is irrelevant
      List<ADM_Work__c> testWorkRecords = [Select id from ADM_Work__c where closed__c = 1 order by lastModifiedDate   ];
      deleteEntitySubscriptionForWorks(testWorkRecords);
    }
    else{
      for( List<ADM_Work__c> oldWorkRecords: [Select id from ADM_Work__c where lastModifiedDate != LAST_N_DAYS:90 AND lastModifiedDate = LAST_N_DAYS:180 AND closed__c = 1 order by lastModifiedDate  ]){
          deleteEntitySubscriptionForWorks(oldWorkRecords);

          
         
           //1 queries expected for Entity Subscription
          if(Limits.getQueries() + 1 >= Limits.getLimitQueries()){
              break;
          }
    
          //If total queried rows are closer to allowed limit stopping the execution
          if(Limits.getQueryRows() + 200 >= Limits.getLimitQueryRows()){
              break;
          }
          
           //If total dml rows are closer to allowed limit stopping the execution
          if(Limits.getDmlRows() + 200 >= Limits.getLimitDmlRows()){
              break;
          }
          
           //If DML statements so far is closer to allowed dml statements stopping the execution
          if(Limits.getDmlStatements() + 1 >= Limits.getLimitDmlStatements()){
              break;
          }
          
           //If script statment inside the loop is closer to limit stopping the execution
          if(Limits.getScriptStatements() + 200 >= Limits.getLimitScriptStatements()){
              break;
          }
      }
    }
    
   }

   private void deleteEntitySubscriptionForWorks(ADM_Work__c [] works){
        Set<Id> workIds = new Set<Id>();
        for(ADM_Work__c work: works){
          workids.add(work.Id);
        }

        if(workIds.size() > 0){
          EntitySubscription[] entitySubsToBeDeleted = ADM_EntitySubscriptionUtils.getAllBy(workIds, new Set<Id>());
          ADM_EntitySubscriptionUtils.deleteEntitySubscriptions(entitySubsToBeDeleted); 
        }        
    }
   
   
}