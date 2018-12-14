@isTest
public class ADM_BuildTriggerTest {
    
//test    
    
    static testMethod void testTriggerOnDelete() {
       
        
        ADM_Build__c build = ADM_Build.createTestBuild();
        ADM_Work__c work = ADM_Work.createTestWork();
        work.Scheduled_Build__c = build.id;
        Database.update(work);
        
        // attempt to delete the build - it should fail because at least 1 work item has been related to it
        try {
            Database.delete(build);
            System.assert(false, 'Test should have thrown a DML exception before it reached here');
        } catch (DmlException e) { 
            System.assert(e.getMessage().contains('Error: You must re-assign all Work items scheduled for this build before it can be deleted.'), e.getMessage());
        }
        
        //now remove the work record and attempt to delete again
        work.Scheduled_Build__c = null;
        Database.update(work);
        try {
            Database.delete(build);
            System.assertEquals(0, [select count() from ADM_Build__c where id =:build.id]); 
        } catch (DmlException e) { 
            System.assert(false, 'No exception expected:' + e.getMessage());
        } 
    }
    
    static testMethod void testTriggerOnInsertOrUpdate() {
            ADM_Build__c build1 = ADM_Build.createTestBuild();
            //attempt to create a new build
            ADM_Build__c build2 = new ADM_Build__c();
            try {               
                build2.Name = build1.Name;
                Database.insert(build2);
                System.assert(false, 'Test should have thrown a DML exception before it reached here');
            } catch (DmlException e) { 
                System.assert(e.getMessage().contains('Another build with this name already exists.'), e.getMessage());
            }
            
            //repeat with different case
            try {               
                build2.Name = build1.Name.toUpperCase();
                Database.insert(build2);
                System.assert(false, 'Test should have thrown a DML exception before it reached here');
            } catch (DmlException e) { 
                System.assert(e.getMessage().contains('Another build with this name already exists.'), e.getMessage());
            }
            
            
            //repeat but set up two builds.  The original with no spaces and then attempt to insert a duplicate, identical except for white space
            ADM_Build__c buildNoSpaces = new ADM_Build__c();
            buildNoSpaces.Name = 'MyTestBuildName123';
            Database.insert(buildNoSpaces);
            ADM_Build__c buildWithSpaces = new ADM_Build__c();
            buildWithSpaces.Name = 'My Test Build Name 123';
            try {
                Database.insert(buildWithSpaces);
                System.assert(false, 'Test should have thrown a DML exception before it reached here');
            } catch (DmlException e) { 
                System.assert(e.getMessage().contains('Another build with this name already exists.'), e.getMessage());
            }
    } 

}