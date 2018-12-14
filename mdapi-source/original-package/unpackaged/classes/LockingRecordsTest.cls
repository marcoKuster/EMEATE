/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LockingRecordsTest {

/*
 @testcaseID  a1DB00000000qMn
 @userstoryID a07B0000000EV6RIAW
 @Hierarchy GUS.BugforceToGUS.SystemIntegrations.Locking Record
 @ExpectedResults Error message displayed reads: "Team has been locked out of Perforce check in's by user_name. More information can be found at the following link: link_name
 @Author = Alexis Williams
 */
    static testMethod void testGettingLockingRecordsMessage() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        LockingRecords lock = new LockingRecords(team.Id); 
        String lockedByMessage = 'Team has been locked out of main branch by ' + Userinfo.getName() + '. ';
        
        System.assertEquals('', lock.message);
        System.assertEquals(true, lock.getLocks().isEmpty());
        
        Locking_Record__c lr = new Locking_Record__c();
        lr.Status__c = 'ToBe';
        lr.Team__c = team.Id;
        lr.Start_Time__c = System.now();
        insert lr;
        
        lock.getLocks();
        
        System.assertEquals('', lock.message);
        
        Locking_Record__c lr2 = lr.clone(false, true);
        lr2.Status__c = 'Locked';
        insert lr2;
        delete lr;
        
        List<Locking_Record__c> locks = lock.getLocks();
        
        System.assert(lock.message.contains(lockedByMessage), 'Expected locked by user message');  
        System.assert((lock.lockRecord.id == lr2.id),'Expected matching lock record id');      
    }
}