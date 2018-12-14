public with sharing class ADM_NotifierController {
    
    public ADM_Work__c work { 
        get;
        set;
    }
    
    public ADM_Work_Subscriber__c subscriber { 
        get;
        set;
    }
      
    public void setSObjectWork(SObject so) {
        this.work = (ADM_Work__c)so;
    }
    
    public SObject getSObjectWork() {
        return (SObject)this.work;
    }
    
    public ADM_NotifierController() {
        subscriber = new ADM_Work_Subscriber__c();
        
    }
    
    public String getStandardRecipients() {
    	return ADM_WorkDetails.getStandardRecipients(this.work);     
    }
    
   public List<ADM_Work_Subscriber__c> getSubscribers() {
        List<ADM_Work_Subscriber__c> subs = new List<ADM_Work_Subscriber__c>();
        try {
            subs = ADM_Subscriber.getSubscribersWithLimit(100, work.id);    
        } catch(System.Exception e) {
            System.debug('Unexpected exception fetching subscribers:' + e);
        }
        return subs;
    }
    
    
    

}