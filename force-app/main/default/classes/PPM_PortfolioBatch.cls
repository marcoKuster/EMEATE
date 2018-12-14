public class PPM_PortfolioBatch implements Database.Batchable<sObject>{
    
    private final String query;
   

   public PPM_PortfolioBatch(String q){
        query = q;
      
   }
    
    
    public Database.querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        //grab all epics whose related work has been modified within the last 90 days, Call these "activeEpics"
       List<Id> activeEpicIds = new List<Id>();
        for(SObject so: scope) {
           ADM_Work__c activeWork = (ADM_Work__c)so;
           activeEpicIds.add(activeWork.Epic__c);    
       }
       System.debug('PPM_PortfolioScheduledJob() activeEpicIds size:' + activeEpicIds.size());
        
        
        //create portfolio burn down items
        List<ADM_Epic_Burndown_Item__c> items = new List<ADM_Epic_Burndown_Item__c>();
        System.debug('PPM_PortfolioBatch() scope size:' + scope.size()); 
        //get work related to active epics 
        //get work related to active epics 
        for(ADM_Work__c work: [select id, Epic__c, Story_Points__c, Status__c, Closed__c, LastModifiedDate from ADM_Work__c where Epic__c in:activeEpicIds]) {
        
            ADM_Epic_Burndown_Item__c item = new ADM_Epic_Burndown_Item__c();
            item.Closed__c = work.Closed__c;
            if(item.Closed__c == 0) {
                item.Status__c = 'Open';
            } else {
                item.Status__c = 'Closed';            
            }
            item.Metric__c = work.Story_Points__c;
            item.Epic__c = work.Epic__c;
            
            //for testing sometime useful to put a dummy date vs waiting for calendar day.  For prod we replace last Modified Date with System.today so that each time this runs its the current date
            /*DateTime dT = work.LastModifiedDate;
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            item.Date__c = myDate;*/
            item.Date__c = System.today();
            item.Compound_Key__c = System.today().format() + '_' + work.id;
            items.add(item);
        }
        System.debug('PPM_PortfolioBatch() epic burndown items size:' + items.size()); 
        Database.insert(items, false);
    }
        
    

    public void finish(Database.BatchableContext BC) {
    
    }
    
}