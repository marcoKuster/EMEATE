public with sharing class ADM_SprintBacklogControllerExtension {
    private String sprintId { get; set; }
    private List<ADM_Sprint__c> sprints { get; set; }
    Integer hasBeenLoaded { get; set; }
    transient String message { get; set; }
    public ADM_Sprint__c sprint { get; set; }
    public ADM_SprintBacklogControllerExtension(ApexPages.StandardController controller) {}
    
    public Apexpages.Standardsetcontroller setController {
        get {
            if(setController == null) {
                sprintId = System.currentPageReference().getParameters().get('id');
                sprint = [select Name from ADM_Sprint__c where Id = : sprintId];
                setController = new Apexpages.Standardsetcontroller(Database.getQueryLocator([
                    select Name, Theme__c, Subject__c, Priority_Rank__c, Priority__c, Story_Points__c, Status__c, Scheduled_Build__c, Closed_On__c
                    from ADM_Work__c
                    where Sprint__c = : sprintId
                ]));
                setController.setPageSize(20);
            }
            if(setController.getResultSize() == 0) {
            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No records were found.'));
            }
            return setController;
        }
        set;
    }
    
    public List<ADM_Work__c> works {
        get {
            if(works == null) works = new List<ADM_Work__c>();
            
            for(ADM_Work__c work : (List<ADM_Work__c>) setController.getRecords()) {
                works.add(work);
            }
            return works;
        }
        set;
    }   
   
     // indicates whether there are more records after the current page set.  
     public Boolean hasNext {  
         get {  
             return setController.getHasNext();  
         }  
         set;  
     }  
   
     // indicates whether there are more records before the current page set.  
     public Boolean hasPrevious {  
         get {  
             return setController.getHasPrevious();  
         }  
         set;  
     }  
   
     // returns the page number of the current page set  
     public Integer pageNumber {  
         get {  
             return setController.getPageNumber();  
         }  
         set;  
     }  
   
     // returns the page size of the current page set  
     public Integer pageSize {  
         get {  
             return setController.getPageSize();  
         }  
         set;  
     }
     
     public Integer resultSize {
        get {
            return setController.getResultSize();
        }
        set;
     } 
   
     // returns the first page of records  
     public void first() {  
         setController.first();  
     }  
   
     // returns the last page of records  
     public void last() {  
         setController.last();  
     }  
   
     // returns the previous page of records  
     public void previous() {  
         setController.previous();  
     }  
   
     // returns the next page of records  
     public void next() {  
         setController.next();  
     }  
   
     // returns the PageReference of the original page, if known, or the home page.  
     public void cancel() {  
         setController.cancel();  
     }
     
     public Integer rowStart {
        get {
            if(!hasPrevious) {
                return 1;
            } else if(hasNext){
                return (works.size() * (pageNumber - 1)) + 1;
            } else {
                return resultSize - works.size() + 1;
            }
        }
        set;
     }
     
     public Integer rowEnd {
        get {
            if(!hasNext) {
                return resultSize;
            } else {
                return works.size() * pageNumber;
            }
        }
        set;
    }
}