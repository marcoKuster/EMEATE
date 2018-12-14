public with sharing class ADM_WorkWrapper {
    public Boolean checked { get; set; }
    public ADM_Work__c work { get; set; }
    public Integer order { get; set; }
    public Boolean stayInBucket { get; set; }
    public static final Integer DEFAULT_ORDER = 0;
    public static final Boolean DEFAULT_STAY_IN_BUCKET = false;
    
    public ADM_WorkWrapper() {
    	work = new ADM_Work__c();
    	checked = false;
    	order = DEFAULT_ORDER;
    	stayInBucket = DEFAULT_STAY_IN_BUCKET;
    }
    
    public ADM_WorkWrapper(ADM_Work__c w) {
        work = w;
        checked = false;
        order = DEFAULT_ORDER;
        stayInBucket = DEFAULT_STAY_IN_BUCKET;
    }
    
    public ADM_WorkWrapper(ADM_Work__c w, Boolean b) {
        work = w;
        checked = b;
        order = DEFAULT_ORDER;
    }
    
    public ADM_WorkWrapper(ADM_Work__c w, Boolean b, Boolean s) {
    	work = w;
    	checked = b;
    	stayInBucket = s;
    }
    
    public String getStoryLine() {
    	String text = '';
    	
        if(work.RecordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
            if(work.Details__c != null) {
                text = work.Details__c;
            }
        } else {
            text = work.Subject__c;
        }
        
        return text;
    } 
}