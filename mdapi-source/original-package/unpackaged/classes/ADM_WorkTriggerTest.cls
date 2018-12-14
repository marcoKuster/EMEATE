@isTest
public class ADM_WorkTriggerTest {

   static testMethod void testTriggerOnInsert() {
    ADM_Work__c work = setUpStandAloneWork();
        insert(work);
        System.assert(work.id != null);
   }  

  /* @testcase ID: a1DB00000000Pcd
    @Brief Desc: Verify Bug Lists don't require Frequency and don't throw error on save
    @Expected Results: Successful save
    @user story ID:  a07B0000000Ea7f
   */
   static testMethod void testBugListTypeDoesNotRequireFrequency() {
    ADM_Work__c work = ADM_Work.setupTestWork('Bug');
    work.Type__c = 'Bug List';
    work.Priority__c = 'PA';
    work.Frequency__c = null;
        insert(work);
        System.assert(work.id != null);
   }

   static testMethod void testChangingBugToUserStoryRemovesUnnecessaryFields() {

    ADM_Work__c work = ADM_Work.createTestBug();

    ADM_Work__c createdWork = [Select id, Impact__c,Frequency__c,Priority__c from ADM_Work__c where id = : work.id limit 1];

    System.assertNotEquals(null,createdWork.Impact__c);
    System.assertNotEquals(null,createdWork.Frequency__c);
    System.assertNotEquals(null,createdWork.Priority__c);

    String recordTypeId = [select id from RecordType where Name =: ADM_Work.RECORD_TYPE_NAME_USERSTORY].id;
    work.RecordTypeId = recordTypeId;
    update work;

    ADM_Work__c updatedWork = [Select id, Impact__c,Frequency__c,Priority__c, RecordTypeId from ADM_Work__c where id = : work.id limit 1];

    System.assertEquals(null,updatedWork.Impact__c);
    System.assertEquals(null,updatedWork.Frequency__c);
    System.assertEquals(null,updatedWork.Priority__c);
        

   }


   static testMethod void testTriggerOnUpdate() {
    Test.startTest();
    ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Description__c= 'this text will be in ADM_Comment__c object as comment body__c';
        insert work;

        System.assert(work.id != null);
        //verfiy update
        work.Subject__c = 'New Subject';
        update work;
        ADM_Work__c modifiedWork = [select id, Subject__c from ADM_Work__c where id = :work.id];
        System.assert(modifiedWork.Subject__c != 'Test Work Subject');
        System.assert(modifiedWork.Subject__c == 'New Subject');
        Test.stopTest();
        //expect two comments - one for the initial work item creation (because Descrition__c is populated inside setUpStandAloneWork()) and one noting the change of subject
        System.assertEquals(2, [select count() from ADM_Comment__c where Work__c = :work.id], 'Unexpected number of comments created');
   }  


   static testMethod void testChangingTeamOfWorkItemNullsColumnAndColumnRank() {
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Product_Tag__c = productTag.Id;
        work.Scrum_Team__c = productTag.Team__c;
        work.Column_Rank__c = 4;
        ADM_Column__c columnNew = ADM_ColumnUtility.createColumn('New', null, 0, 0, productTag.Team__c);
        insert work;
        ADM_Product_Tag__c productTag1 = ADM_ProductTag.createAndInsertProductTag();
        work.Product_Tag__c = productTag1.Id;
        update work;
        ADM_Work__c work1 = [Select id,Column__c,Column_Rank__c from ADM_Work__c where id =: work.Id];
        System.assertEquals(null,work1.Column_Rank__c,'Column Rank becomes null when team changes');
        System.assertEquals(null,work1.Column__c,'Column becomes null when team changes');
    
    }

    /* Verify that changing teams nulls out Assigned colors on a kanban board */

     static testMethod void testChangingTeamOfWorkItemNullsColor() {
       ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        ADM_Scrum_Team__c team = [Select id from ADM_Scrum_Team__c where id = :productTag.Team__c];
        team.kanban__c = true;
        update team;
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Product_Tag__c = productTag.Id;
        work.Scrum_Team__c = productTag.Team__c;
        insert work;
        ADM_Color__c color = [Select id, name from ADM_Color__c where Team__c = :team.id limit 1];
        System.assert(color!=null, 'Team should have default colors in kanban');
        work.Color__c = color.Id;
        update work;
        System.assert(null != work.color__c);
        ADM_Product_Tag__c productTag1 = ADM_ProductTag.createAndInsertProductTag();
        work.Product_Tag__c = productTag1.Id;
        update work;
        ADM_Work__c work1 = [Select id,Color__c from ADM_Work__c where id =: work.Id];
        System.assertEquals(null,work1.Color__c,'Color should become null when team changes work is' + work1);

    }

    static testMethod void testChangingColumnCreatesAndUpdatesColumnHistoryTable() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        ADM_Column__c column1 = ADM_ColumnUtility.createColumn('New', null, 0, 0, work.Scrum_Team__c);

        Test.startTest();
        insert column1;
        work.Column__c = column1.Id;
        update work;
        List<ADM_Column_History__c> columnHistory = [Select id,Time_Entered__c,Time_Left__c,Work__c,Column__c from ADM_Column_History__c where work__c =: work.id];
       
        System.assertEquals(1,columnHistory.size(),'Column History List size should be 1 since this is the first record for this work item.');   
        System.assertEquals(column1.Id,columnHistory.get(0).column__c, 'Column History Record  should have updated column id.');
        System.assertEquals(null,columnHistory.get(0).Time_Left__c, 'Column History Record should have a null value for Time Left.');
        System.assertNotEquals(null,columnHistory.get(0).Time_Entered__c,'Column History Record should have a non null value for time Entered.');
        ADM_Column__c column2 = ADM_ColumnUtility.createColumn('In Progress', null, 0, 0, work.Scrum_Team__c);
        insert column2;
        work.Column__c = column2.Id;
        update work;
        List<ADM_Column_History__c> columnHistory1 = [Select id,Time_Entered__c,Time_Left__c,Work__c,Column__c from ADM_Column_History__c where Work__c =: work.Id order by Time_Entered__c];
        System.assertEquals(2,columnHistory1.size(),'Column History List size should be 2 since there are 2 records now, one for old and one for new.');   
        System.assertEquals(column2.Id,columnHistory1.get(1).column__c, 'Column History Record  should have updated column id for the new record.');
        System.assertNotEquals(null,columnHistory1.get(0).Time_Left__c, 'Column History Record should have a non null value for Time Left column for the first record.');
        System.assertNotEquals(null,columnHistory1.get(1).Time_Entered__c,'Column History Record should have a non null value for Time Entered column for the new record.');
        work.Column__c = column1.Id;
        update work;
        List<ADM_Column_History__c> columnHistory2 = [Select id,Time_Entered__c,Time_Left__c,Work__c,Column__c from ADM_Column_History__c where Work__c =: work.Id order by Time_Entered__c];
        Test.stopTest();

        System.assertEquals(3,columnHistory2.size(),'Column History List size should be 3 since there are 3 records now.');   
        System.assertNotEquals(null,columnHistory2.get(1).Time_Left__c, 'Column History Record should have a non null value for Time Left column for the second record.');
        System.assertEquals(columnHistory1.get(0).Time_Left__c,columnHistory2.get(0).Time_Left__c, 'Since both are the same records they should have the same value. Asserting to see previous records values are not touched');
    }

    

   
   /* @testcase ID: a0B20000007m1q9EAA 
    @Brief Desc: Verify cloning a bug does not clone age with scrum team on bug 
    @Expected Results: Cloning a bug does not clone age of scrum team 
    @user story ID: a0A20000009qR6u 
   */

   static testMethod void testTriggerOnCloneWithBug() {

    Test.startTest();
    ADM_Work__c work = ADM_Work.createTestWork('Bug');
    
    //now attempt to clone.  The private ADM_WorkControllerExtention.populateWork() method is called from the classes constructor and will clone if an ID is present AND a Clone Flag is set
    //to 1
    System.currentPageReference().getParameters().put('clone', '1');
    System.currentPageReference().getParameters().put('id', work.id);
    System.currentPageReference().getParameters().put('RecordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
    ApexPages.StandardController stdController = new ApexPages.StandardController(work);        
    ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
    ADM_Work__c clonedWork = wrl.getWork();
    //borrow impact and freq from original as these are intentionally not cloned
    clonedWork.Impact__c = work.Impact__c;
    clonedWork.Frequency__c = work.Frequency__c;
    insert clonedWork;
    Test.stopTest();
    ADM_Work__c modifiedClonedWork = ADM_Work.get('id',clonedWork.id, 'id', 'asc');
    //difficult to assert date based fields which can't be modified like CreatedDate whilst at the same time not relying on exsiting data
    System.assertEquals(0, modifiedClonedWork.Age__c);
               System.assertNotEquals(work.CreatedDate, modifiedClonedWork.Created_On_Import__c, 'Created On Import should be the actual creation date of the clone not the record it was cloned from');

   }
   
   /* @testcase ID: a0B20000007m1qAEAQ  
    @Brief Desc: Verify cloning a story does not clone age with scrum team on story 
    @Expected Results: Cloning a story does not clone age of scrum team 
    @user story ID: a0A20000009qR6u 
   */

   /*static testMethod void testTriggerOnCloneWithUserStory() {

    Test.startTest();
    ADM_Work__c work = ADM_Work.createTestWork('User Story');
    
    //now attempt to clone.  The private ADM_WorkControllerExtention.populateWork() method is called from the classes constructor and will clone if an ID is present AND a Clone Flag is set
    //to 1
    System.currentPageReference().getParameters().put('clone', '1');
    System.currentPageReference().getParameters().put('id', work.id);
    System.currentPageReference().getParameters().put('RecordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_USERSTORY);
    ApexPages.StandardController stdController = new ApexPages.StandardController(work);        
    ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
    ADM_Work__c clonedWork = wrl.getWork();
    //borrow impact and freq from original as these are intentionally not cloned
    clonedWork.Impact__c = work.Impact__c;
    clonedWork.Frequency__c = work.Frequency__c;
    clonedWork.Priority__c = 'P1';
    insert clonedWork;
    Test.stopTest();
    ADM_Work__c modifiedClonedWork = ADM_Work.get('id',clonedWork.id, 'id', 'asc');
    //difficult to thouroughly assert date based fields and (forumla fields which depend on dates) which can't be modified like CreatedDate whilst at the same time not relying on existing data
    System.assertEquals(0, modifiedClonedWork.Age__c);
        System.assertEquals(0, modifiedClonedWork.Age_With_Scrum_Team__c);
        System.assertNotEquals(work.CreatedDate, modifiedClonedWork.Created_On_Import__c, 'Created On Import should be the actual creation date of the clone not the record it was cloned from');

   }*/
   

   /* 

    @testcaseID a0B20000006c6N2EAI

    @hierarchy GUS.WorkEdit.Clone

    @userstory a0A2000000108a8

    @expectedResults: Ensure clones and parents play nice with each other.  Verifies expected operation of clone when it has a parent
    
    @author jhatton

  */ 

   

   static testMethod void testTriggerOnCloneWithParent() {

    Test.startTest();

    ADM_Work__c work = setupStandAloneWork();

    ADM_Work__c workParent = setupStandAloneWork();

    insert workParent;

    work.Parent_ID__c = workParent.Name;

    work.Email_Subscription_ID__c = 'gusteam@salesforce.com';

    insert work;

    //now attempt to clone.  The private ADM_WorkControllerExtention.populateWork() method is called from the classes constructor and will clone if an ID is present AND a Clone Flag is set

    //to 1

    System.currentPageReference().getParameters().put('clone', '1');

    System.currentPageReference().getParameters().put('id', work.id);

        System.currentPageReference().getParameters().put('RecordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);

    ApexPages.StandardController stdController = new ApexPages.StandardController(work);        

        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);

                

        //check the email on save flag

        ADM_Work__c clonedWork = wrl.getWork();

        clonedWork.Email_On_Save__c = true;

        //borrow impact and freq from original as these are intentionally not cloned

        clonedWork.Impact__c = work.Impact__c;

        clonedWork.Frequency__c = work.Frequency__c;

        

        insert clonedWork;

        Test.stopTest();

        //verify Email On Save Copy field which @Future method will rely on is true

        ADM_Work__c modifiedClonedWork = ADM_Work.get('id',clonedWork.id, 'id', 'asc');

        System.assertEquals(true, modifiedClonedWork.Email_On_Save_Copy__c);

    
    

   }

    /* 

      @testcaseID a0B20000007lKs1EAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change user story to bug

      @userstory a0A20000009qR6g

      @expectedResults: Converting from user story to bug is possible and the following fields from detail page stay the same BUT ARE NOT SHOWN on detail page: 
      user type, goal, reason, additional details, found in build. Fields that stay the same are: Work ID, product area, MFA, Help Status, Customer, Age, # of cases, 
      Status, Include in Prioritize view, priority rank, regressed, security, story points, Subject, Scheduled Build, Sprint, Theme, scrum team, assigned to, qa engineer, 
      ue engineer, product owner, tech writer, ST engineer, complete by, ftest, related URL, perforce status, root cause analysis#, notifications, comments
  @author jhatton
    */ 
        /* 

      @testcaseID a0B20000007lKtdEAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change user story to bug

      @userstory a0A20000009qR6g

      @expectedResults: All related lists stay the same when changing from user story to bug
      @author jhatton

    */
   /* 

      @testcaseID a0B20000007lKs1EAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change user story to bug

      @userstory a0A20000009qR6g

      @expectedResults: All 62 org cases stay the same when changing from user story to bug
      @author jhatton
    */
    /* 

      @testcaseID a0B20000007lKtfEAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change user story to bug

      @userstory a0A20000009qR6g

      @expectedResults: All change lists stay the same when changing from bug to user story
      @author jhatton
    */
    /* 

      @testcaseID a0B20000007lKtgEAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change user story to bug

      @userstory a0A20000009qR6g

      @expectedResults: All release stamps stay the same when changing from bug to user story
      @author jhatton
    */ 

   static testMethod void testStoryToBugRecordTypeConversion() {
    ADM_Work__c work = ADM_Work.createTestWork('User Story');
    System.assert(work.id != null);
    Id bugRecTypeID = ADM_RecordType.getId('Bug');
    work.RecordTypeId = bugRecTypeID;
    try {
      update work;
      System.assert(work.RecordTypeId != null);
      System.assertEquals(bugRecTypeID, work.RecordTypeId, 'Unexpected Record Type ID');
    } catch (System.Exception e) {
      System.assert(false, 'Unexpected exception:' + e);
    }
   }
   
   /* 

      @testcaseID a0B20000007lJdMEAU

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change bug to user story

      @userstory a0A20000009qR6g

      @expectedResults: Converting from bug to user story is possible and the following fields from detail page stay the same BUT ARE NOT SHOWN on detail page: 
      Impact, Frequency, type, found in build. Fields that stay the same are: Work ID, product area, MFA, Help Status, Customer, Age, # of cases, Status, 
      Include in Prioritize view, priority rank, regressed, security, story points, Subject, Scheduled Build, Sprint, Theme, scrum team, assigned to, 
      qa engineer, ue engineer, product owner, tech writer, ST engineer, complete by, ftest, related URL, perforce status, root cause analysis#, notifications, comments
      @author jhatton
    */ 
    /* 

      @testcaseID a0B20000007lKthEAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change bug to user story

      @userstory a0A20000009qR6g

      @expectedResults: All related lists stay the same when changing from bug to user story
      @author jhatton
    */ 
    /* 

      @testcaseID a0B20000007lKtiEAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change bug to user story

      @userstory a0A20000009qR6g

      @expectedResults: All 62 org cases stay the same when changing from bug to user story
      @author jhatton
    */ 
    /* 

      @testcaseID a0B20000007lKtjEAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change bug to user story

      @userstory a0A20000009qR6g

      @expectedResults: All change lists stay the same when changing from bug to user story
      @author jhatton
    */ 
        /* 

      @testcaseID a0B20000007lKtkEAE

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change bug to user story

      @userstory a0A20000009qR6g

      @expectedResults: All release stamps stay the same when changing from bug to user story
      @author jhatton
    */ 
   
   static testMethod void testBugToStoryRecordTypeConversion() {
    ADM_Work__c work = ADM_Work.createTestWork('Bug');
    System.assert(work.id != null);
    Id storyRecTypeID = ADM_RecordType.getId('User Story');
    work.RecordTypeId = storyRecTypeID;
    ADM_Scrum_Team__c scrum = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
      work.Scrum_Team__c = scrum.id;
    
    try {
      update work;
      System.assert(work.RecordTypeId != null);
      System.assertEquals(storyRecTypeID, work.RecordTypeId, 'Unexpected Record Type ID');
    } catch (System.Exception e) {
      System.assert(false, 'Unexpected exception:' + e);
    }
   }
   
      
     /* 

      @testcaseID a0B20000007lJdNEAU

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change bug to todo

      @userstory a0A20000009qR6g

      @expectedResults: User cannot convert bug to todo and error message is thrown
      @author jhatton
    */
   
   static testMethod void testInvalidBugToTODORecordTypeConversion() {
    ADM_Work__c work = ADM_Work.createTestWork('Bug');
    System.assert(work.id != null);
    Id todoRecTypeID = ADM_RecordType.getId('TODO');
    work.RecordTypeId = todoRecTypeID;
    try {
      update work;
      System.assert(false, 'Validation exception should have been thrown before the code reaches here.');
      
    } catch (System.Exception e) {
      System.assert(e.getMessage().contains('This type of record type conversion is not supported'), e.getMessage());
    }
   }
   
    /* 

    @testcaseID a0B20000007lKs0EAE

    @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change bug to Template

    @userstory a0A20000009qR6g

    @expectedResults: Invalid record type conversion -  exception should be thrown on update
          @author jhatton
  */ 
   
   static testMethod void testInvalidBugToTemplateRecordTypeConversion() {
    ADM_Work__c work = ADM_Work.createTestWork('Bug');
    System.assert(work.id != null);
    Id templateRecTypeID = ADM_RecordType.getId('Template');
    work.RecordTypeId = templateRecTypeID;
    work.Template_Name__c = 'Test Suite Template Name';
    work.Template_Description__c = 'Test Suite Template Description';
    try {
      update work;
      System.assert(false, 'Validation exception should have been thrown before the code reaches here.');
      
    } catch (System.Exception e) {
      System.assert(e.getMessage().contains('This type of record type conversion is not supported'), e.getMessage());
    }
   }
   
  /* 

      @testcaseID a0B20000007lKtZEAU

      @hierarchy GUS.ScrumforceToGUS.Convert Record Types.Change user story to ToDo

      @userstory a0A20000009qR6g

      @expectedResults: User cannot convert user story to todo and error is thrown
      @author jhatton
    */ 
   
   static testMethod void testInvalidStoryToTODORecordTypeConversion() {
    ADM_Work__c work = ADM_Work.createTestWork('User Story');
    System.assert(work.id != null);
    Id todoRecTypeID = ADM_RecordType.getId('TODO');
    work.RecordTypeId = todoRecTypeID;
    try {
      update work;
      System.assert(false, 'Validation exception should have been thrown before the code reaches here.');
      
    } catch (System.Exception e) {
      System.assert(e.getMessage().contains('This type of record type conversion is not supported'), e.getMessage());
    }
   }
   
    

   @IsTest

   private static ADM_Work__c setUpStandAloneWork() {

    ADM_Work__c work = new ADM_Work__c();
    
    ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
    
        
       ADM_Frequency__c f = new ADM_Frequency__c (Name='Never Ending');

        insert f;

        ADM_Impact__c i = new ADM_Impact__c(Name='End of Days');

        insert i;

        ADM_Type__c t = new ADM_Type__c(Name = 'Bug');

      insert t;

      ADM_Impact_Type__c it = new ADM_Impact_Type__c(Impact__c = i.id, Type__c = t.id);

      insert it;

      ADM_Priority__c p = new ADM_Priority__c(Name='P99');

      insert p;

      ADM_Priority_Mapping__c pm = new ADM_Priority_Mapping__c(Impact__c = i.id, Frequency__c = f.id, Priority__c = p.id);

      insert pm;

      

       

        work.Frequency__c = f.id;

        work.Impact__c = i.id;

        work.Type__c = 'Bug';
        
        work.Product_Tag__c = productTag.Id;

       
        work.Minor_Func_Area__c = 'Test';       

        work.Status__c = 'New';

        work.Subject__c = 'Test Work Subject';

        work.Description__c = 'Hello World';

        

        work.RecordTypeId = [select id from RecordType where Name =: ADM_Work.BUG_RECORD_TYPE_NAME].id;

        ADM_Build__c build = ADM_Build.createTestBuild('Build435' + String.valueOf(Math.random()));

        work.Found_in_Build__c = build.Id;

        

        return work;
   }  

  
  @IsTest
  private static Group setupTechDirectorGroup() {
    //set if group exists and if not create it
    Group g;
    if([select count() from Group where Name = :ADM_Validate.RESTRICTED_GROUP] == 0) {
      g = new Group(Name= ADM_Validate.RESTRICTED_GROUP);
      insert g;
    } else {
      g = [select id, Name from Group where Name = :ADM_Validate.RESTRICTED_GROUP];
    }
    
    
    
    return g;
    
  }
  
  /* 

      @testcaseID a0B20000007nbWKEAY

      @hierarchy GUS.ScrumforceToGUS.Work.Bug.Edit page

      @userstory  a0A2000000AmekV
                  
      @author jhatton
    */
   
   static testMethod void testTechDirectorGroupMemberCanAddSystemImpactOnCreateBug() {
    Group g = setupTechDirectorGroup();
    User u = ADM_WorkUser.createTestUser();
    GroupMember gm = new GroupMember(UserOrGroupId = u.id, GroupId = g.id);
    insert gm;
    //run as this user and attempt to create a bug with Technical Debt
    System.runAs(u) {
      ADM_Work__c work = ADM_Work.setupTestWork('Bug');
      work.Attributes__c = 'System Impact';
      try {
        insert work;
        System.assert(work.id != null);
      } catch (System.Exception e) {
        System.assert(false, 'Did not expect:' + e);
      }
    }
   }
   
   /* 

      @testcaseID a0B20000007nbWLEAY

      @hierarchy GUS.ScrumforceToGUS.Work.Bug.Edit page

      @userstory  a0A2000000AmekV
                  
      @author jhatton
    */
   static testMethod void testTechDirectorGroupMemberCanAddSystemImpactOnEditBug() {
    Group g = setupTechDirectorGroup();
    User u = ADM_WorkUser.createTestUser();
    GroupMember gm = new GroupMember(UserOrGroupId = u.id, GroupId = g.id);
    insert gm;
    //run as this user and attempt to create a bug with System Impact
    System.runAs(u) {
      ADM_Work__c work = ADM_Work.setupTestWork('Bug');
      
      try {
        insert work;
        //now attempt to edit
        work.Attributes__c = 'System Impact';
        Test.startTest();
        update work;
        Test.stopTest();
        work = [select id, Attributes__c from ADM_Work__c where id = : work.id];
        System.assert(work.id != null);
        System.assert(work.Attributes__c == 'System Impact');
      } catch (System.Exception e) {
        System.assert(false, 'Did not expect:' + e);
      }
    }
   }
   
   /* 

      @testcaseID a0B20000007nbWMEAY

      @hierarchy GUS.ScrumforceToGUS.Work.Bug.Edit page

      @userstory  a0A2000000AmekV
                  
      @author jhatton
    */
   
   static testMethod void testTechDirectorGroupMemberCanRemoveSystemImpactOnEdit() {
    Group g = setupTechDirectorGroup();
    User u = ADM_WorkUser.createTestUser();
    GroupMember gm = new GroupMember(UserOrGroupId = u.id, GroupId = g.id);
    insert gm;
    //run as this user and attempt to create a bug with System Impact
    System.runAs(u) {
      ADM_Work__c work = ADM_Work.setupTestWork('Bug');
      
      try {
        insert work;
        //now attempt to edit
        work.Attributes__c = '';
        Test.startTest();
        update work;
        Test.stopTest();
        work = [select id, Attributes__c from ADM_Work__c where id = : work.id];
        System.assert(work.id != null);
        
      } catch (System.Exception e) {
        System.assert(false, 'Did not expect:' + e);
      }
    } 
   }
   
   /* 

      @testcaseID a0B20000007nbWPEAY


      @hierarchy GUS.ScrumforceToGUS.Work.Bug.Edit page

      @userstory  a0A2000000AmekV
                  
      @author jhatton
    */

   
   static testMethod void testNonTechDirectorGroupMemberCantAddSystemImpactOnCreate() {
    Group g = setupTechDirectorGroup();
    User u = ADM_WorkUser.createTestUser();
    
    //run as this user who does not belong to group and attempt to create a bug with System Impact
    System.runAs(u) {
      ADM_Work__c work = ADM_Work.setupTestWork('Bug');
      work.Attributes__c = 'System Impact';
      try {
        insert work;
        System.assert(false, 'Excepted the trigger to throw an exception before it reached here');
      } catch (System.Exception e) {
//        System.assert(e.getMessage().contains('can only be selected by members of the R&DTechDirectors public group'), e.getMessage());
      }
    }
   }
   
   /* 

      @testcaseID a0B20000007nbWSEAY

      @hierarchy GUS.ScrumforceToGUS.Work.Bug.Edit page

      @userstory  a0A2000000AmekV
                  
      @author jhatton
    */
   
   static testMethod void testNonTechDirectorGroupMemberCanAddOtherAttributesWhenSystemImpactAlreadyChosen() {
    Group g = setupTechDirectorGroup();
    User u = ADM_WorkUser.createTestUser();
    User u2 = ADM_WorkUser.createTestUser();
    GroupMember gm = new GroupMember(UserOrGroupId = u.id, GroupId = g.id);
    insert gm;
    ADM_Work__c work;
    //run as this user who does not belong to group and attempt to create a bug with System Impact
    System.runAs(u) {
      work = ADM_Work.setupTestWork('Bug');
      work.Attributes__c = 'System Impact';
      insert work;
    }
    //now attempt to add other attribute as u2
    System.runAs(u2) {
      work = ADM_Work.get('id', work.id, 'id', 'DESC');
      work.Attributes__c = 'System Impact; Flapper';
      try {
        update work;
      } catch (System.Exception e) {
        System.assert(false, 'Did not expect:' + e);
      }
    }
   }
   
   /* 

      @testcaseID a0B20000007nbWMEAY

      @hierarchy GUS.ScrumforceToGUS.Work.Bug.Edit page

      @userstory  a0A2000000AmekV
                  
      @author jhatton
    */
   
   static testMethod void testNonTechDirectorGroupMemberCantAddSystemImpactOnEdit() {
    Group g = setupTechDirectorGroup();
    User u = ADM_WorkUser.createTestUser();
    
    //run as this user and attempt to edit a bug with System Impact
    System.runAs(u) {
      ADM_Work__c work = ADM_Work.setupTestWork('Bug');
      insert work;
      try {
        work.Attributes__c = 'System Impact';
        Test.startTest();
        update work;
        Test.stopTest();
        
        System.assert(false, 'Excepted the trigger to throw an exception before it reached here');
      } catch (System.Exception e) {
//        System.assert(e.getMessage().contains('can only be selected by members of the R&DTechDirectors public group'), e.getMessage());
      }
    } 
   }
   
   /* 

      @testcaseID a0B20000007nbWSEAY

      @hierarchy GUS.ScrumforceToGUS.Work.Bug.Edit page

      @userstory  a0A2000000AmekV
                  
      @author jhatton
    */
   
   static testMethod void testNonTechDirectorGroupMemberCantRemoveSystemImpactOnEdit() {
    Group g = setupTechDirectorGroup();
    User u = ADM_WorkUser.createTestUser();
    User u2 = ADM_WorkUser.createTestUser();
    GroupMember gm = new GroupMember(UserOrGroupId = u.id, GroupId = g.id);
    insert gm;
    ADM_Work__c work;
    
    System.runAs(u) {
      work = ADM_Work.setupTestWork('Bug');
      work.Attributes__c = 'System Impact';
      insert work;
    }
    
    System.runAs(u2) {
      
      try {
        //now attempt to remove
        work.Attributes__c = '';
        Test.startTest();
        update work;
        Test.stopTest();
        System.assert(false, 'Excepted the trigger to throw an exception before it reached here');
      } catch (System.Exception e) {
//        System.assert(e.getMessage().contains('can only be selected by members of the R&DTechDirectors public group'), e.getMessage());
      }
    }   
   }
   
  
   /* 
    @testcaseID a1DB00000000xKb
    @hierarchy GUS.ScrumforceToGUS.Work Page.ToDo.New page  
    @userstory a07B0000000EjeRIAS
    @expectedResults: Closed, Closed On, Closed By, Resolved, Resolved On and Resolved By fields are populated when creating a closed ToDo
    @author jhatton
  */ 

  static testMethod void testTODORecordsCreatedWithAClosedStatusHaveDependentFieldsPopulated() {
    Test.startTest();
    ADM_Work__c w = ADM_Work.setupTestWork('ToDo');
    w.Status__c = 'Completed';
    w.Priority__c = 'P1';
    insert w;
    Test.stopTest();
    //verfiy dependent fields were populated
    w = [select Closed_On__c, Closed__c, Closed_By__c from ADM_Work__c where id = :w.id];
    System.assert(w.Closed_On__c != null);
    //can't compare to actual system.now() as this will result in flappers so compare to the next best thing
    System.assert(w.Closed_On__c > System.today()); 
    System.assertEquals(UserInfo.getUserName(), w.Closed_By__c);
  }
  
    
   /* 
    @testcaseID a1DB00000000xKl
    @hierarchy GUS.ScrumforceToGUS.Work Page.Bug.New Page
    @userstory a07B0000000EjeRIAS
    @expectedResults: Closed, Closed On, Closed By, Resolved, Resolved On and Resolved By fields are populated when creating a closed Bug
    @author jhatton
  */ 

  static testMethod void testBUGRecordsCreatedWithAClosedStatusHaveDependentFieldsPopulated() {
    Test.startTest();
    ADM_Work__c bug = ADM_Work.setupTestWork('Bug');
    bug.Status__c = 'Closed';
    insert bug;
    Test.stopTest();
    //verfiy dependent fields were populated
    bug = [select Closed_On__c, Closed__c, Closed_By__c from ADM_Work__c where id = :bug.id];
    System.assert(bug.Closed_On__c != null);
    //can't compare to actual system.now() as this will result in flappers so compare to the next best thing
    System.assert(bug.Closed_On__c > System.today()); 
    System.assertEquals(UserInfo.getUserName(), bug.Closed_By__c);
  }
  
   /* 
    @testcaseID a1DB00000000xKq
    @hierarchy GUS.ScrumforceToGUS.Work Page.Bug.New Page
    @userstory a07B0000000EjeRIAS
    @expectedResults: Resolved, Resolved On and Resolved By fields are populated when creating a closed Bug
    @author jhatton
  */ 

  static testMethod void testBUGRecordsCreatedWithAResolvedStatusHaveDependentFieldsPopulated() {
    Test.startTest();
    ADM_Work__c w = ADM_Work.setupTestWork('Bug');
    w.Status__c = 'Fixed';
    w.QA_Engineer__c = UserInfo.getUserID();
    insert w;
    Test.stopTest();
    //verfiy dependent fields were populated
    w = [select Resolved_On__c, Resolved__c, Resolved_By__c from ADM_Work__c where id = :w.id];
    System.assert(w.Resolved_On__c != null);
    //can't compare to actual system.now() as this will result in flappers so compare to the next best thing
    System.assert(w.Resolved_On__c > System.today()); 
    System.assertEquals(UserInfo.getUserName(), w.Resolved_By__c);
  }

   /* 
    @testcaseID a1DB00000000xKg
    @hierarchy GUS.ScrumforceToGUS.Work Page.User Story.New page
    @userstory a07B0000000EjeRIAS
    @expectedResults: Closed, Closed On, Closed By, Resolved, Resolved On and Resolved By fields are populated when creating a closed User Story
    @author jhatton
  */ 


  static testMethod void testUserStoryRecordsCreatedWithAClosedStatusHaveDependentFieldsPopulated() {
    Test.startTest();
    ADM_Work__c w = ADM_Work.setupTestWork('User Story');
    w.Status__c = 'Closed';
    w.Priority__c = 'P1';
    insert w;
    Test.stopTest();
    //verfiy dependent fields were populated
    w = [select Closed_On__c, Closed__c, Closed_By__c from ADM_Work__c where id = :w.id];
    System.assert(w.Closed_On__c != null);
    //can't compare to actual system.now() as this will result in flappers so compare to the next best thing
    System.assert(w.Closed_On__c > System.today()); 
    System.assertEquals(UserInfo.getUserName(), w.Closed_By__c);
  }

   /* 
    @testcaseID a1DB00000000xKh
    @hierarchy GUS.ScrumforceToGUS.Work Page.User Story.New page
    @userstory a07B0000000EjeRIAS
    @expectedResults: Resolved, Resolved On and Resolved By fields are populated when creating a closed User Story
    @author jhatton
  */ 


  static testMethod void testUserStoryRecordsCreatedWithAResolvedStatusHaveDependentFieldsPopulated() {
    Test.startTest();
    ADM_Work__c w = ADM_Work.setupTestWork('User Story');
    w.Status__c = 'Fixed';
    w.Priority__c = 'P1';
    w.QA_Engineer__c = UserInfo.getUserID();
    insert w;
    Test.stopTest();
    //verfiy dependent fields were populated
    w = [select Resolved_On__c, Resolved__c, Resolved_By__c from ADM_Work__c where id = :w.id];
    System.assert(w.Resolved_On__c != null);
    //can't compare to actual system.now() as this will result in flappers so compare to the next best thing
    System.assert(w.Resolved_On__c > System.today()); 
    System.assertEquals(UserInfo.getUserName(), w.Resolved_By__c);
  }
   /* 
    @testcaseID a1DB00000000QgC
    @hierarchy GUS.Work.User Story.Clone page
    @userstory a0790000000D5T3
    @expectedResults:testWorkOriginatingFromEditPage
    @author jhatton
  */ 
  
  static testMethod void testWorkOriginatingFromEditPage() {
    ADM_Work__c w = ADM_Work.setupTestWork('User Story');
    w.Origin__c = ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN;
    w.Priority__c = 'P1';
    User u = ADM_WorkUser.createTestUserWithRandomName(); 
    Test.startTest();
    ApexPages.StandardController stdController = new ApexPages.StandardController(w);
        ADM_WorkControllerExtension wc = new ADM_WorkControllerExtension(stdController);
        //simulate encoding performed by UI
        String encoded = ADM_NotificationUtils.AUTO_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER + u.FirstName + ' ' + u.LastName;
        wc.HiddenReps = encoded;
        //save - subscriber should be inserted
        wc.saveAndView();
        Test.stopTest();
        //verfiy subscriber was created
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, UserId__c from ADM_Work_Subscriber__c where WorkId__c = :w.id];
        System.assert(subs != null);
        System.assertEquals(1, subs.size(), 'Encoded:' + encoded);
        System.assertEquals(u.id, subs.get(0).UserId__c);
    System.assert(w.id != null);
    
  }
   /* 
    @testcaseID a1DB00000000Pcc
    @hierarchy GUS.Work.DefectPrioritizationProcess.URL population
    @userstory a0790000000DB87
    @expectedResults:Bug gets created with the new fields
    @author jhatton
  */ 
  
  static testMethod void testWorkOriginatingFromAPI() {
    //create the product tag
    ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
    
    //create the assignment rule
    //make sure Additional_Emails__c is populated
    ADM_Assignment_Rule__c rule = ADM_AssignmentRule.createAssignmentRule();
        rule.Additional_Emails__c = 'gusteam@salesforce.com';
    insert rule;
    System.assert(rule.Additional_Emails__c != null, 'This test relies on the test rule populating Additional_Emails__c so it can be turned into Work Subscriber');
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_USERSTORY;
        insert tagAssignment;
    
    //ADM_Work__c.Origin__c explicity not set just like an API call 
    ADM_Work__c w = ADM_Work.setupTestWork('User Story');
    w.Priority__c = 'P1';
    w.Product_Tag__c = productTag.Id;
    
    //make sure email sub is empty prior to applying rule
    w.Email_Subscription_ID__c = null;
    
    Test.startTest();
    insert w;
      Test.stopTest();
      
      //verify the work object
    System.assert(w.id != null);
      
        //verify subscriber was created
        List<ADM_Work_Subscriber__c> subs = [select id, WorkId__c, UserId__c, Distribution_List__c from ADM_Work_Subscriber__c where WorkId__c = :w.id];
        System.assert(subs != null);
        System.assertEquals(1, subs.size(), 'Subscriber was not created');
        System.assert(subs.get(0).Distribution_List__c.contains(rule.Additional_Emails__c));
  }

    /*
     * If a work item is moved from one sprint to another, then the sprint
     * rank should be reset.
     */
   /* 
    @testcaseID a1DB00000000RBo
    @hierarchy GUS.Social Sprint.Sprint Backlog.Detail page
    @userstory a0790000000DAdb
    @expectedResults:display the work items in Backlog Rank where work item with null backlog rank shows last
    @author jhatton
  */ 
    static testMethod void testResetSprintRankOnSprintChange() {
        Date startDate = Date.newInstance(2012, 01, 01);
        Date endDate = Date.newInstance(2012, 01, 14);
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        ADM_Sprint__c sprint1 = new ADM_Sprint__c();
        sprint1.Name = '2012.01a';
        sprint1.Scrum_Team__c = team.Id;
        sprint1.Start_Date__c = Date.newInstance(2012, 01, 01);
        sprint1.End_Date__c = Date.newInstance(2012, 01, 14);
        insert sprint1;
        
        ADM_Sprint__c sprint2 = new ADM_Sprint__c();
        sprint2.Name = '2012.01b';
        sprint2.Scrum_Team__c = team.Id;
        sprint2.Start_Date__c = Date.newInstance(2012, 01, 15);
        sprint2.End_Date__c = Date.newInstance(2012, 01, 28);
        insert sprint2;
        
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_BUG);
        work.Sprint__c = sprint1.Id;
        work.Sprint_Rank__c = 10;
        insert work;
        
        Test.startTest();
        work.Sprint__c = sprint2.Id;
        update work;
        Test.stopTest();
        
        work = [select Sprint_Rank__c from ADM_Work__c where Id = :work.Id limit 1];
        System.assertEquals(null, work.Sprint_Rank__c, 'Expected the sprint rank to be reset to null when the sprint changed.');
    }

       /* 
    @testcaseID a1DB00000002iiN
    @hierarchy GUS.Unified Wall.Theme Backlog Rank
    @userstory a0790000000DAdb
    @expectedResults The theme rank gets reset so that a new re-ranking can take place
  */ 
    /*
     * If the theme on a work item is changed, then the theme
     * rank should be reset.
     */
    static testMethod void testResetThemeRankOnThemeChange() {
      ADM_Theme__c theme1 = new ADM_Theme__c();
      theme1.Name = 'Theme ' + Math.random();
      insert theme1;
      
        ADM_Theme__c theme2 = new ADM_Theme__c();
        theme2.Name = 'Theme ' + Math.random();
        insert theme2;
        
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_BUG);
        work.Theme__c = theme1.Id;
        work.Theme_Rank__c = 10;
        insert work;
        
        Test.startTest();
        work.Theme__c = theme2.Id;
        update work;
        Test.stopTest();
        
        work = [select Theme_Rank__c from ADM_Work__c where Id = :work.Id limit 1];
        System.assertEquals(null, work.Theme_Rank__c, 'Expected the theme rank to be reset to null when the theme changed.');
    }
         /* 
    @testcaseID a1DB00000002iiS
    @hierarchy GUS.Unified Wall.Build Backlog Rank
    @userstory a0790000000DAdb
    @expectedResults The build rank gets reset so that a new re-ranking can take place
  */ 
    /*
     * If the scheduled build on a work item is changed, then the scheduled build
     * rank should be reset.
     */
    static testMethod void testResetScheduledBuildRankOnThemeChange() {
        ADM_Build__c build1 = new ADM_Build__c();
        build1.Name = 'Build ' + Math.random();
        insert build1;
        
        ADM_Build__c build2 = new ADM_Build__c();
        build2.Name = 'Build ' + Math.random();
        insert build2;
        
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_BUG);
        work.Scheduled_Build__c = build1.Id;
        work.Scheduled_Build_Rank__c = 10;
        insert work;
        
        Test.startTest();
        work.Scheduled_Build__c = build2.Id;
        update work;
        Test.stopTest();
        
        work = [select Scheduled_Build_Rank__c from ADM_Work__c where Id = :work.Id limit 1];
        System.assertEquals(null, work.Scheduled_Build_Rank__c, 'Expected the build rank to be reset to null when the build changed.');
    }


   static testMethod void testCapexEnabledforWorkUpdateOnlyIfTeamIsCapexEligible() {
    ADM_Work__c work = ADM_Work.createTestWork('User Story');
    System.assert(work.id != null);

    ADM_Scrum_Team__c workTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id = :work.Scrum_Team__c];

    workTeam.Capex_Enabled__c = true;
    update workTeam;

    work.Capex_Enabled__c = true;

    update work;

    ADM_Work__c updatedWork = [Select id, Capex_Enabled__c from ADM_Work__c where id =:work.id];
    System.assertEquals(true, updatedWork.Capex_Enabled__c, 'Expected Capex to be enabled');

    //Trying to change work record type.
    Id bugRecTypeID = ADM_RecordType.getId('Investigation');

    work.RecordTypeId = bugRecTypeID;
    work.Details_and_Steps_to_Reproduce__c = 'details and steps to reproduce';
    work.Severity_Level__c = '2';

    try {
      update work;
      System.assert(false, 'Validation exception should have been thrown before the code reaches here.');

    } catch (System.Exception e) {
      System.assert(e.getMessage().contains('Cannot convert RecordType with New Customer Facing Feature enabled to anything other than a Bug or a User Story.'), e.getMessage());
    }
   }

    static testMethod void testCapexNotEnabledforWorkUpdateOnlyIfTeamIsNotCapexEligible() {
        try {
            ADM_Work__c work = ADM_Work.createTestWork('User Story');
            System.assert(work.id != null);

            ADM_Scrum_Team__c workTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id = :work.Scrum_Team__c];

            work.Capex_Enabled__c = true; //Even if Capex is set to true in update Trigger it will be set to false because Team is not Capex Enabled

            update work;

            System.assert(false, 'Validation exception should have been thrown on call to update work record.');
        } catch (System.Exception e) {
            System.assert(e.getMessage().contains('New Customer Facing Feature field should be set to false for Non-Capitalizable Team'), e.getMessage());
        }
    }

    static testMethod void testChangingWorkProductTagDeactivatesCapex() {
        ADM_Work__c work = ADM_Work.createTestCapexWork();

        System.assert(work.id != null);
        System.assert(work.Product_Tag__c != null);

        ADM_Product_Tag__c newProductTag = ADM_ProductTag.createAndInsertProductTag();

        work.Product_Tag__c = newProductTag.Id;
        work.Scrum_Team__c = newProductTag.Team__c;

        update work;

        ADM_Work__c workAfterUpdate = [Select id, Capex_Enabled__c from ADM_work__c where id = :work.id];

        System.assertEquals(false, workAfterUpdate.Capex_Enabled__c, 'Expected Capex to be set to false');
    }

   static testMethod void testCapexNotDefaultForWorkOriginatingFromEditPage() {
    ADM_Work__c w = ADM_Work.setupTestWork('User Story');
    w.Origin__c = ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN;


    ADM_Scrum_Team__c workTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id = :w.Scrum_Team__c];

    workTeam.Capex_Enabled__c = true;
    update workTeam;

    insert w;

    ADM_Work__c workAfterUpdate = [Select id, Capex_Enabled__c from ADM_work__c where id = :w.id];

    System.assertEquals(false, workAfterUpdate.Capex_Enabled__c , ' Capex Team  Work items  Capex_Enabled field is not enabled by default if originating from Work Edit Screen - User has the control to enable/disable it');

  }

  static testMethod void testCapexIsDefaultedForWorkOriginatingOutsideOfEditPage() {
    ADM_Work__c w = ADM_Work.setupTestWork('User Story');


    ADM_Scrum_Team__c workTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id = :w.Scrum_Team__c];

    workTeam.Capex_Enabled__c = true;
    update workTeam;

    insert w;

    ADM_Work__c workAfterUpdate = [Select id, Capex_Enabled__c from ADM_work__c where id = :w.id];

    System.assertEquals(true, workAfterUpdate.Capex_Enabled__c , ' Capex Team  Work items  Capex_Enabled field is enabled by default if originating outside of Work Edit Screen');

  }

  static testMethod void testCapexNotDefaultedForWorkOriginatingOutsideOfEditPage() {
    ADM_Work__c w = ADM_Work.setupTestWork('User Story');

    insert w;

    ADM_Work__c workAfterUpdate = [Select id, Capex_Enabled__c from ADM_work__c where id = :w.id];

    System.assertEquals(false, workAfterUpdate.Capex_Enabled__c , ' Work items  Capex_Enabled field  should be false for Non Capex Teams');

  }

  static testMethod void testCapexIsnotDefaultedForWorkUpdate() {
    ADM_Work__c w = ADM_Work.setupTestWork('User Story');

    insert w;

    ADM_Scrum_Team__c workTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id = :w.Scrum_Team__c];

    workTeam.Capex_Enabled__c = true;
    update workTeam;

    w.Subject__c = 'Work is updated';

    update w;


    ADM_Work__c workAfterUpdate = [Select id, Capex_Enabled__c from ADM_work__c where id = :w.id];

    System.assertEquals(false, workAfterUpdate.Capex_Enabled__c , ' Capex Team  Work items  Capex_Enabled field is enabled by default if originating outside of Work Edit Screen');

  }

  static testMethod void testCapexFieldDefaultedOnlyForUserStoryRecordType() {
    ADM_Work__c w = ADM_Work.setupTestWork('Bug');


    ADM_Scrum_Team__c workTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id = :w.Scrum_Team__c];

    workTeam.Capex_Enabled__c = true;
    update workTeam;

    insert w;

    ADM_Work__c workAfterUpdate = [Select id, Capex_Enabled__c from ADM_work__c where id = :w.id];

    System.assertEquals(false, workAfterUpdate.Capex_Enabled__c , ' Capex Team  Work items  Capex_Enabled field should only be enabled for User Story');

  }

  static testMethod void testCapexEnabledForWorkUpdateIfConditionsMet() {
   /* conditions
    1) User Record Type is User Story -
    2) Team has Capex_Enabled__c
    3) Team changed on Work [[ Product Tag change which will trigger team change]]
    4) Work is not originating from Edit page
    */


    ADM_Work__c work = ADM_Work.createTestWork('User Story');
      work.Origin__c = 'ApexTest';
    System.assert(work.id != null);

    ADM_Product_Tag__c pTag2 = ADM_ProductTag.createAndInsertProductTag();

    ADM_Scrum_Team__c newTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id in
                                     (Select Team__c from ADM_Product_Tag__c where id =:pTag2.ID)];

    newTeam.Capex_Enabled__c = true;

    update newTeam;

    work.Product_Tag__c = pTag2.Id;
    update work;

    ADM_Work__c updatedWork = [Select id, Capex_Enabled__c from ADM_Work__c where id =:work.id];
    System.assertEquals(true, updatedWork.Capex_Enabled__c, 'Expected Capex to be enabled');

   }

   static testMethod void testCapexEnabledForWorkUpdateIfConditionsNotMet() {
    /* conditions
    1) User Record Type is User Story -
    2) Team has Capex_Enabled__c
    3) Team changed on Work [[ Product Tag change which will trigger team change]]
    4) Work is not originating from Edit page
    */

    ADM_Work__c work = ADM_Work.createTestWork('Bug');
    work.Origin__c = 'ApexTest';
    System.assert(work.id != null);

    ADM_Product_Tag__c pTag2 = ADM_ProductTag.createAndInsertProductTag();

    ADM_Scrum_Team__c newTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id in
                                     (Select Team__c from ADM_Product_Tag__c where id =:pTag2.ID)];

    newTeam.Capex_Enabled__c = true;

    update newTeam;

    work.Product_Tag__c = pTag2.Id;
    update work;

    ADM_Work__c updatedWork = [Select id, Capex_Enabled__c from ADM_Work__c where id =:work.id];
    System.assertEquals(false, updatedWork.Capex_Enabled__c, 'Expected Capex Enabled to be false, because RecordType is not User Story ');

   }


   static testMethod void testCapexEnabledForWorkUpdateWhenCapexEnabledSetWithNoTeamChange() {
    /* conditions
    1) User Record Type is User Story -
    2) Team has Capex_Enabled__c
    3) Team changed on Work [[ Product Tag change which will trigger team change]]
    4) Work is not originating from Edit page
    */

    ADM_Work__c work = ADM_Work.createTestWork('User Story');
     work.Origin__c = 'ApexTest';
    System.assert(work.id != null);

    ADM_Scrum_Team__c workTeam = [Select id, Capex_Enabled__c from ADM_Scrum_Team__c where id = :work.Scrum_Team__c];

    workTeam.Capex_Enabled__c = true;
    update workTeam;

    work.Subject__c = 'new subject';
    update work;

    ADM_Work__c updatedWork = [Select id, Capex_Enabled__c from ADM_Work__c where id =:work.id];
    System.assertEquals(false, updatedWork.Capex_Enabled__c, 'Expected Capex Enabled to be false, because Team has not changed ');

   }

   static testMethod void testClosingWorkCompletesAllAssociatedTasks(){
        ADM_Work__c work = ADM_Work.createTestWork('User Story');

        List<ADM_Task__c> tasks = new List<ADM_Task__c>();

        ADM_Task__c task1 = new ADM_Task__c();
        task1.Subject__c = 'Task1';
        task1.Assigned_To__c = UserInfo.getUserId();
        task1.Hours_Remaining__c = 10;
        task1.Starting_Hours__c = 10;
        task1.Work__c = work.id;
        task1.Order__c = 1;
        task1.Status__c = 'Not Started';
        tasks.add(task1);

        ADM_Task__c task2 = new ADM_Task__c();
        task2.Subject__c = 'Task2';
        task2.Assigned_To__c = UserInfo.getUserId();
        task2.Hours_Remaining__c = 10;
        task2.Starting_Hours__c = 10;
        task2.Work__c = work.id;
        task2.Order__c = 2;
        task2.Status__c = 'Not Started';
        tasks.add(task2);

        ADM_Task__c task3 = new ADM_Task__c();
        task3.Subject__c = 'Task3';
        task3.Assigned_To__c = UserInfo.getUserId();
        task3.Hours_Remaining__c = 10;
        task3.Starting_Hours__c = 10;
        task3.Work__c = work.id;
        task3.Order__c = 1;
        task3.Status__c = 'In Progress';
        tasks.add(task3);

        ADM_Task__c task4 = new ADM_Task__c();
        task4.Subject__c = 'Task4';
        task4.Assigned_To__c = UserInfo.getUserId();
        task4.Hours_Remaining__c = 10;
        task4.Starting_Hours__c = 10;
        task4.Work__c = work.id;
        task4.Order__c = 1;
        task4.Status__c = 'Completed';
        tasks.add(task4);

        Test.startTest();
          insert tasks;

          work.Status__c = ADM_Work.WORK_STATUS_CLOSED;

          update work;
        Test.stopTest();

        tasks = [Select Id, Status__c from ADM_Task__c where Work__c = :work.Id];

        System.assert(tasks.size() == 4, 'Unexpected number of tasks for work item');

        for (ADM_Task__c task : tasks) {
            System.assert(task.Status__c == ADM_Task.TASK_STATUS_COMPLETED, 'When a work item is closed, all associated tasks should be set to completed');
        }
    }
}