public with sharing class ADM_StampsWrapper {
    public Boolean checked { get; set; }
    public ADM_Released_In__c stamp { get; set; }
    
    public ADM_StampsWrapper() {
    	stamp = new ADM_Released_In__c();
    	checked = false;
    }
    
    public ADM_StampsWrapper(ADM_Released_In__c s) {
        stamp = s;
        checked = false;	
    }
    
    static testMethod void testStampsWrapper() {
    	//test no arg constructor
    	ADM_StampsWrapper sw = new ADM_StampsWrapper();
    	System.assert(sw != null);
    	System.assert(sw.checked == false);
    	
    	ADM_Release__c release = ADM_Release.createTestRelease();
        ADM_Released_In__c stamp = ADM_Release.createTestReleasedIn(release);
    	
    	//test other constructor
    	ADM_StampsWrapper sw1 = new ADM_StampsWrapper(stamp);
    	System.assert(sw1 != null);
    	System.assert(sw1.stamp.id == stamp.id);
    	System.assert(sw1.checked == false);
    }
}