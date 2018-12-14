public with sharing class ADM_ReleasedInTriggerTests {
	
	/**
	 * When a release stamp is inserted, the Stamped_On__c property should be updated
	 */
    static testMethod void testReleasedInStampedOnIsUpdatedWhenBlank() {
        
        ADM_Release__c release = ADM_Release.createTestRelease();
        ADM_Work__c work = ADM_Work.createTestBug();
        
        Test.startTest();
        ADM_Released_In__c newStamp = new ADM_Released_In__c();
        newStamp.Work__c = work.Id;
        newStamp.Release__c = release.Id;
        newStamp.Stamped_On__c = null;
        Database.insert(newStamp);
        Test.stopTest();
        
        //make sure the stamped on property has been populated
        List<ADM_Released_In__c> stamps = [select Id, Stamped_On__c from ADM_Released_In__c where Id = :newStamp.Id];
        System.assert(stamps.get(0).Stamped_On__c != null, 'Expected the stamped on property to be changed to the date it was inserted');
    }
    
    /**
     * After a stamp is cloned, the Stamped_On__c property should not change.
     */
    static testMethod void testReleasedInStampedOnIsCloned() {
        
        ADM_Release__c release = ADM_Release.createTestRelease();
        ADM_Work__c work = ADM_Work.createTestBug();
        
        //create a stamp to clone
        ADM_Released_In__c stamp1 = new ADM_Released_In__c();
        stamp1.Work__c = work.Id;
        stamp1.Release__c = release.Id;
        Database.insert(stamp1);
        stamp1 = [select Id, Work__c, Release__c, Stamped_On__c from ADM_Released_In__c where Id = :stamp1.Id];
        
        Test.startTest();
        //create the clone
        ADM_Released_In__c clonedStamp = stamp1.clone(false, true, true);
        Database.insert(clonedStamp);
        Test.stopTest();
        
        //make sure the stamped on value has not changed on the current objects
        System.assertEquals(stamp1.Stamped_On__c, clonedStamp.Stamped_On__c, 'Expected the stamped on property to not change the clone');
        
        //make sure the stamped on value in the database has not changed
        List<ADM_Released_In__c> stamps = [select Id, Stamped_On__c from ADM_Released_In__c where Id = :clonedStamp.Id];
        System.assertEquals(stamp1.Stamped_On__c, stamps.get(0).Stamped_On__c, 'Expected the stamped on property to not change on clone');
    } 
}