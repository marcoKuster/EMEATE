public class PPM_PortfolioScheduledJob implements Schedulable{

    public void execute(SchedulableContext sc) {

        //grab all epics whose related work has been modified within the last 90 days, Call these "activeEpics"
       List<Id> activeEpicIds = new List<Id>();
       String inClause = '';
       for(ADM_Work__c activeWork : [select id, Epic__c from ADM_Work__c where LastModifiedDate >=LAST_N_DAYS:7 and Epic__c != null]) {
           activeEpicIds.add(activeWork.Epic__c);
           inClause = inClause + '\'' + activeWork.Epic__c + '\',';
       }
       inClause = ADM_TextUtils.removeTrailingComma(inClause); 
       System.debug('PPM_PortfolioScheduledJob() activeEpicIds size:' + activeEpicIds.size());
      
      
      String query = 'select id, Epic__c, Story_Points__c, Status__c, Closed__c, LastModifiedDate from ADM_Work__c where Epic__c in (' + inClause + ')';
      System.debug('query:' + query);
      PPM_PortfolioBatch batch = new PPM_PortfolioBatch(query); 
      Database.executebatch(batch); 
        
          
    }
}