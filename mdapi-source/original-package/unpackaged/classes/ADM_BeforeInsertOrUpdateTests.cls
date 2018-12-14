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
private class ADM_BeforeInsertOrUpdateTests {
  public static ADM_errorUtils errorUtils{
    get {
      if(errorUtils == null) {
        errorUtils = new ADM_errorUtils();
      }
      return errorUtils;
    }
    set;
  } 
  
  public static ADM_Build__c build {
    get {
      if(build == null) {
        build = ADM_Build.createTestBuild(String.valueOf(Math.random()));       
      }
      return build;
    }
    set;
  }
  
  public static User user {
    get {
      if(user == null) {
        user = ADM_WorkUser.createTestUser();
      }
      return user;
    }
    set;
  }
  
  public static final String p4error = 'Enter a valid scheduled build when setting the Source Control Status to Open or Open Once.';
  
  /** 
      @testcaseID:  a0B20000008yKbuEAE    
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults: Changing a user story SB will cause the Source Control Status to clear after save (using any profile) 
    */ 

      /** 
      @testcaseID: a0B20000008yKbvEAE      
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults: Changing a bug SB will cause the Source Control Status to clear after save (using any profile) 
    */ 
      /** 
      @testcaseID: a0B20000008yKbwEAE 
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing a user story SB will cause the Source Control Status to clear after save (using any profile)
    */ 

      /** 
      @testcaseID: a0B20000008yKbxEAE      
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults: Changing a bug SB will cause the Source Control Status to clear after save (using any profile) 
    */ 

  static testMethod void setPerforceStatusWithoutScheduledBuild() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P1');   
        String currentBuild = work.Scheduled_Build__c;
        
        System.runAs(user) {
            insert work;
            work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;
            try {
                work.Scheduled_Build__c = null;
                update work;
            } catch(System.DmlException e) {
                System.assertEquals(p4error, errorUtils.getErrorMessage(e));
            }
        }
    }
    
   /** 
      @testcaseID: a0B20000008yKerEAE      
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing SB to blank when Source Control Status is open once generates an error
    */ 

      /** 
      @testcaseID:a0B20000008yKesEAE       
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults: Changing SB to blank when Source Control Status is open once generates an error 
    */ 

      /** 
      @testcaseID: a0B20000008yKetEAE      
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults: Changing SB to blank when Source Control Status is open generates an error 
    */ 

      /** 
      @testcaseID: a0B20000008yKeuEAE      
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing SB to blank when Source Control Status is open  generates an error
    */ 
    static testMethod void setPerforceStatusWithScheduledBuild() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P1');   
        String currentBuild = work.Scheduled_Build__c;
        
        System.runAs(user) {
            insert work;
            work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;
            try {
                update work;
                System.assertEquals(true, true);
            } catch(System.DmlException e) {
                System.assertEquals(true,false);
            }
        }
    }
    
  /** 
      @testcaseID:       
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing a user story SB and perforce from none to open once will not cause the Source Control Status to change back to none after save
    */  
      /** 
      @testcaseID:       
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:Changing a bug SB and perforce from none to open once will not cause the Source Control Status to change back to none after save  
    */ 

      /** 
      @testcaseID:       
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing a user story SB and perforce from none to open once will not cause the Source Control Status to change back to none after save
    */ 
      /** 
      @testcaseID:       
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing a bug SB and perforce from none to open once will not cause the Source Control Status to change back to none after save
    */ 
    static testMethod void verifyP4StatusRemovedAfterUpdatingScheduledBuild() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P1');
        String currentBuild = work.Scheduled_Build__c;
        
        System.runAs(user) {
            insert work;
            work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;
            try {
                update work;
                work.Scheduled_Build__c = build.Id;
                update work;
                work = [select Perforce_Status__c from ADM_Work__c where Id = : work.Id];
                System.assertEquals(null, work.Perforce_Status__c);
            } catch(System.DmlException e) {
                System.assertEquals(true,false);
            }
        }
    }
    
  /** 
      @testcaseID:a0B20000008yKeXEAU       
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing a user story SB and perforce from to open once will not cause the Source Control Status to change back to none after save
    */ 
    
      /** 
      @testcaseID:a0B20000008yKeYEAU       
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing a user story SB and perforce from to open once will not cause the Source Control Status to change back to none after save
    */ 

      /** 
      @testcaseID:  a0B20000008yKeZEAU     
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing a user story SB and perforce from to open once will not cause the Source Control Status to change back to none after save
    */ 

      /** 
      @testcaseID:a0B20000008yKeaEAE       
      @hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page      
      @userstory: a07B0000000DUlQ
      @expectedResults:  Changing a user story SB and perforce from to open once will not cause the Source Control Status to change back to none after save
    */ 
    static testMethod void verifyP4StatusNotRemovedAfterUpdatingScheduledBuildAndP4Status() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P1');
        String currentBuild = work.Scheduled_Build__c;
        
        System.runAs(user) {          
            work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;
            insert work;
            try {
              work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN_ONCE;             
                work.Scheduled_Build__c = build.Id;
                update work;
                work = [select Perforce_Status__c from ADM_Work__c where Id = : work.Id];
                System.assertEquals(ADM_WorkPerforceStatus.OPEN_ONCE, work.Perforce_Status__c);
            } catch(System.DmlException e) {
                System.assertEquals(true,false);
            }
        }
    }
    
     /** 
      @testcaseID:   a1DB00000000wI6    
      @hierarchy: GUS.ScrumforceToGUS.Work Page.Bug.New Page    
      @userstory: a07B0000000EiszIAC
      @expectedResults:  Source Control Status is cleared with every assignee
      @author: Alexis Williams
    */ 
         /** 
      @testcaseID:   a1DB00000000wIL    
      @hierarchy:    GUS.ScrumforceToGUS.Work Page.User Story.New page 
      @userstory: a07B0000000EiszIAC
      @expectedResults:  Source Control Status is cleared with every assignee
      @author: Alexis Williams
    */ 

    static testMethod void verifyP4StatusRemovedAfterUpdatingChangingAssignee() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P1');
        User u = ADM_WorkUser.createTestUser();
        work.Assignee__c = u.Id;      
        work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;
        insert work;
        work = [select Perforce_Status__c, Assignee__c from ADM_Work__c where Id = : work.Id];
        
        System.assertEquals(work.Perforce_Status__c, ADM_WorkPerforceStatus.OPEN);
        System.assertEquals(work.Assignee__c, u.Id);
        try {
          work.Assignee__c = Userinfo.getUserId();
          update work;
            
          work = [select Perforce_Status__c, Assignee__c from ADM_Work__c where Id = : work.Id];
            System.assertNotEquals(work.Perforce_Status__c, ADM_WorkPerforceStatus.OPEN);
            System.assertNotEquals(work.Assignee__c, u.Id);
        } catch(System.DmlException e) {
            System.assertEquals(true,false);
        }
    }
    
    /* Test to verify Bugs will have a default Bug Type specified */
    
    static testMethod void verifyBugsHaveADefaultBugType() {
        ADM_Work__c bug = ADM_Work.setupTestWork('Bug','P1');
        //make sure the Bug Type is null
        bug.Type__c = null;
        insert bug;
        //retreive the Bug Type from the database to verify it has been populated
        ADM_Work__c updatedBug = [select id, Type__c from ADM_Work__c where id =:bug.id];
        System.assertEquals('Bug', updatedBug.Type__c, 'Expected the Bug Type field to be populated with the default value of Bug');
        //repeat the test but this time populate the Bug Type to make sure the user value is never overwritten
        updatedBug.Type__c = 'Test Change';
        update updatedBug;
        //retrieve the record from the Database to make sure the user specified type persisted and wasn't modified by our trigger
        updatedBug = [select id, Type__c from ADM_Work__c where id =:bug.id];
        System.assertEquals('Test Change', updatedBug.Type__c, 'Expected the Bug Type field to be updated to Test Change');
   
        
    }
     
     
}