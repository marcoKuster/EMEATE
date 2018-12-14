@isTest
public class ADM_CertificationTriggerTest {
    @isTest
    public static void testBeforeTriggerEnablesCertifiedField(){
        ADM_Certification__c certification = new ADM_Certification__c();
        certification.Type__c = 'Scrum Master';
        certification.User__c = (ADM_WorkUser.createTestUser()).Id;
        insert certification;
        
        ADM_Certification__c certificationQueried = [Select id, Certified__c, Certified_On__c from ADM_Certification__c
                                                      where id =:certification.id];
        System.assertEquals(true, certificationQueried.Certified__c, 'Expected True as before Trigger should set True on this field');
        System.assertEquals(System.today(), certificationQueried.Certified_On__c, 'Expected today\'s date as before Trigger should set date if none passed in by user');
        
    }
    
    @isTest
    public static void testCertificationTypeIsRequired(){
        ADM_Certification__c certification = new ADM_Certification__c();
        try{
            certification.User__c = (ADM_WorkUser.createTestUser()).Id;
            insert certification;
            System.assert(false, ' Expected insert above to cause exception, since Typ__c is a required field');
        }
        catch(DMLException exp){
            System.assert(exp.getMessage().contains('REQUIRED_FIELD_MISSING'));
            System.assert(exp.getMessage().contains('Type__c'));
        }
    }
    
    @isTest
    public static void testCertificationUserIsRequired(){
        ADM_Certification__c certification = new ADM_Certification__c();
        try{
            certification.Type__c = 'Scrum Master';
            insert certification;
            System.assert(false, ' Expected insert above to cause exception, since User__c is a required field');
        }
        catch(DMLException exp){
            System.assert(exp.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), exp.getMessage());
            System.assert(exp.getMessage().contains('User__c'));
        }
    }
    
    @isTest
    public static void testAfterTriggerSetsCertifiedFieldOnUserRecord(){
        User certifiedUser = ADM_WorkUser.createTestUser();
        
        User beforeCertificationDataInsert = [Select id, Name, Certified_Scrum_Master__c, Certified_Product_Owner__c, Scrum_Master_Certified_Date__c, Product_Owner_Certified_Date__c
                             from User where id = :certifiedUser.id];
        
        System.assertEquals(false, beforeCertificationDataInsert.Certified_Scrum_Master__c, 'Expected Certified_Scrum_Master__c to be null before inserting Certification data');
        System.assertEquals(null, beforeCertificationDataInsert.Scrum_Master_Certified_Date__c, 'Expected Scrum_Master_Certified_Date__c to be null before inserting Certification data');
        System.assertEquals(false, beforeCertificationDataInsert.Certified_Product_Owner__c, 'Expected Certified_Product_Owner__c to be null before inserting Certification data');
        System.assertEquals(null, beforeCertificationDataInsert.Product_Owner_Certified_Date__c, 'Expected Product_Owner_Certified_Date__c to be null before inserting Certification data');
        
        ADM_Certification__c [] certifications = new List<ADM_Certification__c>();
        ADM_Certification__c scrumMaster = new ADM_Certification__c();
        scrumMaster.Type__c = 'Scrum Master';
        scrumMaster.User__c = certifiedUser.Id;
        
        certifications.add(scrumMaster);
        
        ADM_Certification__c po = new ADM_Certification__c();
        po.Type__c = 'Product Owner';
        po.User__c = certifiedUser.Id;
        
        certifications.add(po);
        
        insert certifications;
        
        User afterCertificationDataInsert = [Select id, Name, Certified_Scrum_Master__c, Certified_Product_Owner__c, Scrum_Master_Certified_Date__c, Product_Owner_Certified_Date__c
                             from User where id = :certifiedUser.id];
        
        System.assertEquals(true, afterCertificationDataInsert.Certified_Scrum_Master__c, 'Expected Certified_Scrum_Master__c to be null before inserting Certification data');
        System.assertEquals(System.today(), afterCertificationDataInsert.Scrum_Master_Certified_Date__c, 'Expected Scrum_Master_Certified_Date__c to be null before inserting Certification data');
        System.assertEquals(true, afterCertificationDataInsert.Certified_Product_Owner__c, 'Expected Certified_Product_Owner__c to be null before inserting Certification data');
        System.assertEquals(System.today(), afterCertificationDataInsert.Product_Owner_Certified_Date__c, 'Expected Product_Owner_Certified_Date__c to be null before inserting Certification data');
        
        
     }
    
    @isTest
    public static void testCertificationRemovedForScrumMaster(){
        
        User scrum_master = ADM_WorkUser.setupTestUser();
        scrum_master.Certified_Scrum_Master__c = true;
        Database.upsert(scrum_master);
        
        ADM_Certification__c certification = new ADM_Certification__c();
        certification.Type__c = 'Scrum Master';
        certification.User__c = (scrum_master).Id;
        insert certification;
        
        ADM_Certification__c certificationQueried = [Select id, Certified__c, Certified_On__c from ADM_Certification__c
                                                      where id =:certification.id];

        User u1 = [SELECT Id,Certified_Scrum_Master__c FROM User where Id = :scrum_master.Id];
        System.assertEquals(true, u1.Certified_Scrum_Master__c);

        Test.startTest();
        Database.delete(certificationQueried.Id);
        Test.stopTest();
        
        User u2 = [SELECT Id,Certified_Scrum_Master__c FROM User where Id = :scrum_master.Id];
        System.assertEquals(false, u2.Certified_Scrum_Master__c);
        
    }
    
    @isTest
    public static void testCertificationRemovedForProductOwner(){
        
        User product_owner = ADM_WorkUser.setupTestUser();
        product_owner.Certified_Product_Owner__c = true;
        Database.upsert(product_owner);
        
        ADM_Certification__c certification = new ADM_Certification__c();
        certification.Type__c = 'Product Owner';
        certification.User__c = (product_owner).Id;
        insert certification;
        
        ADM_Certification__c certificationQueried = [Select id, Certified__c, Certified_On__c from ADM_Certification__c
                                                      where id =:certification.id];

        User u1 = [SELECT Id,Certified_Product_Owner__c FROM User where Id = :product_owner.Id];
        System.assertEquals(true, u1.Certified_Product_Owner__c);

        Test.startTest();
        Database.delete(certificationQueried.Id);
        Test.stopTest();
        
        User u2 = [SELECT Id,Certified_Product_Owner__c FROM User where Id = :product_owner.Id];
        System.assertEquals(false, u2.Certified_Product_Owner__c);
        
    }

   @isTest
    public static void testSingleUserWithTwoCertsRemoved(){
        
        User product_owner = ADM_WorkUser.setupTestUser();
        product_owner.Certified_Product_Owner__c = true;
        Database.upsert(product_owner);
        
        ADM_Certification__c certification_po = new ADM_Certification__c();
        certification_po.Type__c = 'Product Owner';
        certification_po.User__c = (product_owner).Id;
        insert certification_po;
        
        ADM_Certification__c certification_sm = new ADM_Certification__c();
        certification_sm.Type__c = 'Scrum Master';
        certification_sm.User__c = (product_owner).Id;
        insert certification_sm;
        
        ADM_Certification__c certificationQueried_sm = [Select id, Certified__c, Certified_On__c from ADM_Certification__c
                                                      where id =:certification_sm.id];
        
        ADM_Certification__c certificationQueried_po = [Select id, Certified__c, Certified_On__c from ADM_Certification__c
                                                      where id =:certification_po.id];

        User u1 = [SELECT Id,Certified_Product_Owner__c, Certified_Scrum_Master__c FROM User where Id = :product_owner.Id];
        System.assertEquals(true, u1.Certified_Product_Owner__c);
        System.assertEquals(true, u1.Certified_Scrum_Master__c);
        
        Test.startTest();
        Database.delete(certificationQueried_sm.Id);
        Database.delete(certificationQueried_po.Id);
        Test.stopTest();
        
        User u2 = [SELECT Id,Certified_Product_Owner__c, Certified_Scrum_Master__c FROM User where Id = :product_owner.Id];
        System.assertEquals(false, u2.Certified_Product_Owner__c);
        System.assertEquals(false, u2.Certified_Scrum_Master__c);
        
    }
       
    
}