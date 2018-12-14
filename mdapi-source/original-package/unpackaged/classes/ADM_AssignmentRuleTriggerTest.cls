@isTest
public class ADM_AssignmentRuleTriggerTest {
        
    static testMethod void testSaveRule() {
        User user1 = ADM_WorkUser.createTestUser();
         
        //create the product tag
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
         
        //create rule
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = user1.id;
        rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam().id;
        rule.Product_Owner__c = UserInfo.getUserId();
        insert rule;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(rule);
        ADM_AssignmentRuleController arc = new ADM_AssignmentRuleController(stdController);
        
        arc.saveRule();
        
        System.assert(ApexPages.getMessages().isEmpty(), 'Expected no errors to occur when the assignment rule is saved.');
    }
    
    static testMethod void testCloneRule() {
        User user1 = ADM_WorkUser.createTestUser();
         
        //create the product tag
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
         
        //create rule
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = user1.id;
        rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam().id;
        rule.Product_Owner__c = UserInfo.getUserId();
        insert rule;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(rule);
        ADM_AssignmentRuleController arc = new ADM_AssignmentRuleController(stdController);
        
        PageReference page = arc.cloneRule();
        
        System.assert(page != null, 'Expected cloneRule to return a page');
    }
    
	
     /* 

      @testcaseID a0B20000007mIWSEA2

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: Ensure users can Create new active assignment rule using new design for a bug
      
      @author jhatton

    */
    
     /* 

      @testcaseID a0B20000007mIqeEAE

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: Ensure users can Create new active assignment rule using new design for a bug with a product child
      
      @author jhatton

    */
    
    /* 

      @testcaseID a0B20000007mIbnEAE

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: Ensure major Func Area, Additional Emails, Inactive checkbox, product owner, tech writer, UE engineer, Assignee, QA engineer and Performance engineer are optional fields
      
      @author jhatton

    */ 
     
    static testMethod void testAssignmentRuleForBug() {
        
         User user1 = ADM_WorkUser.createTestUser();
         User user2 = ADM_WorkUser.createTestUser();
         
		//create the product tag
		ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
		
         //create rule
         ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
         rule.Assignee_Assignment__c = user1.id;
         rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam().Id;
         rule.Product_Owner__c = UserInfo.getUserId();
         insert rule;
         
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
         
         //verify assignee is auto-assigned
         ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
         work.Product_Tag__c = productTag.Id;
         work.Assignee__c = null;
         Test.startTest();
         //now insert
         insert work;
         Test.stopTest();
         
         work = ADM_Work.get('id', work.id, 'id', 'desc');
         //verify Assignee was auto-assigned
         System.assertEquals(user1.id, work.Assignee__c);
        
    } 
    
    
    
     /* 

      @testcaseID a0B20000007mIWREA2

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: Ensure users can Create new active assignment rule using new design for a User Story
      
      @author jhatton

    */
    
    /* 

      @testcaseID a0B20000007mIqdEAE

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: Ensure users can Create new active assignment rule using new design for a user story with a product child
      
      @author jhatton

    */
    
     static testMethod void testAssignmentRuleForUserStory() { 
        
                 
         User user1 = ADM_WorkUser.createTestUser();
         
		 //create the product tag
		 ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
         
         //create rule
         ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
         rule.Assignee_Assignment__c = user1.id;
         rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam().id;
         rule.Product_Owner__c = UserInfo.getUserId();
         insert rule;
         
         //create the tag assignment
         ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
         tagAssignment.Assignment_Rule__c = rule.Id;
         tagAssignment.Product_Tag__c = productTag.Id;
         tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_USERSTORY;
         insert tagAssignment;
		 
         //verify assignee is auto-assigned
         ADM_Work__c work = ADM_Work.setupTestWork('User Story');
         work.Product_Tag__c = productTag.Id;
         work.Assignee__c = null;
         work.Priority__c = 'P1';
         Test.startTest();
         //now insert
         insert work;
         Test.stopTest();
         
         work = ADM_Work.get('id', work.id, 'id', 'desc');
         //verify Assignee was auto-assigned
         System.assertEquals(user1.id, work.Assignee__c);
    } 
    
    /* 

      @testcaseID a0B20000007mIRGEA2

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: Ensure users can Create new active assignment rule using new design for a Investigation
      
      @author jhatton

    */
    
    /* 

      @testcaseID a0B20000007mIqcEAE

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: Ensure users can Create new active assignment rule using new design for a investigation with a product child
      
      @author jhatton

    */
    
    static testMethod void testAssignmentRuleForInvestigation() { 
        
                 
         User user1 = ADM_WorkUser.createTestUser();
        
		 //create the product tag
		 ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
         
         //create rule
         ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
         rule.Assignee_Assignment__c = user1.id;
         rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam().id;
         rule.Exception_Request_POC__c = user1.Id;
         rule.Product_Owner__c = user1.Id;
         insert rule;
         
         //create the tag assignment
         ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
         tagAssignment.Assignment_Rule__c = rule.Id;
         tagAssignment.Product_Tag__c = productTag.Id;
         tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
         insert tagAssignment;
		 
         //verify assignee is auto-assigned
         ADM_Work__c work = ADM_Work.setupTestWork('Investigation');
         //make sure its Sev 2 - Sev 1.3.4 have special user cases - see ADM_AutoAssignWorkAction
         work.Severity_Level__c = '2';
         work.Product_Tag__c = productTag.Id;
         work.Assignee__c = null;
         //work.d
          System.assert(work.Details_and_Steps_to_Reproduce__c != null, 'Did not expect:' + work.Details_and_Steps_to_Reproduce__c);
         Test.startTest();
         //now insert
         insert work;
         Test.stopTest();
         
         work = ADM_Work.get('id', work.id, 'id', 'desc');
         //verify Assignee was auto-assigned
         System.assertEquals(user1.id, work.Assignee__c);
    } 
    
    
    /* 
      @testcaseID a1DB00000000aq7
      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-772782
      @userstory a0A20000001hNa9
      @expectedResults: The Senior Management POC does not appear on the detail page next to the Senior Management POC field and does not get emailed
      
      @author jhatton
    */ 
    static testMethod void testSeniorMgrPOCIsNotAssignedWhenRequestReviewIsFalse() {
     		ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRuleInvestigation();
     		rule = [select Id from ADM_Assignment_Rule__c where Id = :rule.Id];
     		ADM_Work__c work = ADM_Work.setupTestWork('Investigation');
     		work.Severity_Level__c = '2';
     		
     		//remove the assignee to let it be auto-assigned
     		work.Senior_Management_POC__c = null;
     		work.Request_RD_Mgr_Review__c = false;
     		Test.startTest();
     		insert work;
     		Test.stopTest();
     		work = ADM_Work.get('id', work.id, 'id', 'DESC');
     		System.assertEquals(null, work.Senior_Management_POC__c);
     } 
     
     /* 
      @testcaseID a1DB00000000aq6
      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-772782
      @userstory a0A20000001hNa9
      @expectedResults: The Senior Management POC appears on the detail page next to the Senior Management POC field and gets emailed
      
      @author jhatton
    */ 
     static testMethod void testSeniorMgrPOCIsAssignedWhenRequestReviewIsTrue() {
			//create the product tag
			ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
     	
     		ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRuleInvestigation();
            rule = [select Id, Senior_Management_POC_Assignment__c from ADM_Assignment_Rule__c where Id = :rule.id];
     		
	        //create the tag assignment
	        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
	        tagAssignment.Assignment_Rule__c = rule.Id;
	        tagAssignment.Product_Tag__c = productTag.Id;
	        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
	        insert tagAssignment;
			
     		ADM_Work__c work = ADM_Work.setupTestWork('Investigation');
     		work.Severity_Level__c = '2';
     		work.Product_Tag__c = productTag.Id;
     		//remove the assignee to let it be auto-assigned
     		work.Senior_Management_POC__c = null;
     		work.Request_RD_Mgr_Review__c = true;
     		Test.startTest();
     		insert work;
     		Test.stopTest();
     		work = ADM_Work.get('id', work.id, 'id', 'DESC');
     		System.assertEquals(rule.Senior_Management_POC_Assignment__c, work.Senior_Management_POC__c);
     }   
    
  
    
         

     
     
     /* 

      @testcaseID a0B20000007mIWOEA2

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.Clone

      @userstory a0A20000001hNa9

      @expectedResults: User cannot save an exact clone of an active assignment rule
      
      @author jhatton

    */ 
    
    /* 

      @testcaseID a0B20000007mIWOEA2

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.Clone

      @userstory a0A20000001hNa9

      @expectedResults: User cannot save an exact clone of an active assignment rule
      
      @author jhatton

    */ 

    static testMethod void testCannotSaveDuplicateFromClonedAssignmentRule() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        //now attempt to clone.  
        System.currentPageReference().getParameters().put('clone', '1');
        System.currentPageReference().getParameters().put('id', rule.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(rule);
        ADM_AssignmentRuleController arc = new ADM_AssignmentRuleController(stdController);
        
        ADM_Assignment_Rule__c clonedRule = arc.rule;
        
        //assert its identical
        System.assertEquals(rule.Assignee_Assignment__c, clonedRule.Assignee_Assignment__c);
        
        //verify it can't be saved as it is a duplicate
        System.assert(clonedRule.id == null);     
        PageReference pr = arc.saveRule();
        System.assert(pr == null, 'User should not receive a page reference as we expect an error to be displayed');
        System.assert(ApexPages.hasMessages());
        String error = ApexPages.getMessages().get(0).getSummary();
        System.assert(error.contains('Assignment rule already exists'));
        
        
     }
     
     /* 

      @testcaseID a0B20000007mIu0EAE

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.Clone

      @userstory a0A20000001hNa9

      @expectedResults: Clone functionality clones every field on assignment rule. 
      
      @author jhatton

    */ 

   static testMethod void testCloneFunctionClonesEveryField() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        //now attempt to clone.  
        System.currentPageReference().getParameters().put('clone', '1');
        System.currentPageReference().getParameters().put('id', rule.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(rule);
        ADM_AssignmentRuleController arc = new ADM_AssignmentRuleController(stdController);
        
        ADM_Assignment_Rule__c clonedRule = arc.rule;
        
        //assert its identical
        System.assertEquals(rule.Assignee_Assignment__c, clonedRule.Assignee_Assignment__c);
        System.assertEquals(rule.Product_Owner__c, clonedRule.Product_Owner__c);
        System.assertEquals(rule.Scrum_Team_Assignment__c, clonedRule.Scrum_Team_Assignment__c);
        System.assertEquals(rule.QA_Assignment__c, clonedRule.QA_Assignment__c);
        System.assertEquals(rule.Tech_Writer_Assignment__c, clonedRule.Tech_Writer_Assignment__c);
        System.assertEquals(rule.UE_Engineer__c, clonedRule.UE_Engineer__c);
        System.assertEquals(rule.Systest_Assignment__c, clonedRule.Systest_Assignment__c);
        System.assertEquals(rule.Senior_Management_POC_Assignment__c, clonedRule.Senior_Management_POC_Assignment__c);
        
     }
     
     /* 
      @testcaseID a0B20000007mIsKEAU
      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.Clone
      @userstory a0A20000001hNa9
      @expectedResults: User can save an exact clone of an inactive assignment rule
      
      @author jhatton
    */ 
    static testMethod void testCloneFunctionClonesEveryFieldForInactiveRule() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        rule.Inactive__c = true;
        update rule;
        
        //now attempt to clone.  
        System.currentPageReference().getParameters().put('clone', '1');
        System.currentPageReference().getParameters().put('id', rule.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(rule);
        ADM_AssignmentRuleController arc = new ADM_AssignmentRuleController(stdController);
        
        ADM_Assignment_Rule__c clonedRule = arc.rule;
        
        //assert its identical
        System.assertEquals(rule.Assignee_Assignment__c, clonedRule.Assignee_Assignment__c);
        System.assertEquals(rule.Product_Owner__c, clonedRule.Product_Owner__c);
        System.assertEquals(rule.Scrum_Team_Assignment__c, clonedRule.Scrum_Team_Assignment__c);
        System.assertEquals(rule.QA_Assignment__c, clonedRule.QA_Assignment__c);
        System.assertEquals(rule.Tech_Writer_Assignment__c, clonedRule.Tech_Writer_Assignment__c);
        System.assertEquals(rule.UE_Engineer__c, clonedRule.UE_Engineer__c);
        System.assertEquals(rule.Systest_Assignment__c, clonedRule.Systest_Assignment__c);
        System.assertEquals(rule.Senior_Management_POC_Assignment__c, clonedRule.Senior_Management_POC_Assignment__c);
        
     }
     
     /* 
      @testcaseID a0B20000007mIRGEA2
      @hierarchy GUS.ScrumforceToGUS.Assignment Rules page.RuleVerification.Inactive
      @userstory a0A20000001hNa9
      @expectedResults: Assignment rule does not fire when a user creates an investigation assignment rule that's inactive
      
      @author jhatton
    */ 
   static testMethod void testInactiveAssignmentRuleDoesNotApplyForInvestigationRecordType() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        rule.Inactive__c = true;
        update rule;
        //get related fields
        rule = [select id, Name, Assignee_Assignment__c, UE_Engineer__c, Product_Owner__c, Tech_Writer_Assignment__c, Systest_Assignment__c, Scrum_Team_Assignment__c, QA_Assignment__c, Additional_Emails__c, Senior_Management_POC_Assignment__c from ADM_Assignment_Rule__c
                                                where id= : rule.id];
        
        //create work object which would normally trigger the assignment rule
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        
        work.Senior_Management_POC__c = null;
        Test.startTest();
        update work;
        Test.stopTest();
        
        System.assert(work.Senior_Management_POC__c == null, 'Did not expect the Snr Mgt POC to be Auto-Assigned');
        
        
     }
     
     /* 
      @testcaseID a0B20000007mIYFEA2
      @hierarchy GUS.ScrumforceToGUS.Assignment Rules page.RuleVerification.Inactive
      @userstory a0A20000001hNa9
      @expectedResults: Assignment rule does not fire when a user creates a User Story assignment rule that's inactive
      
      @author jhatton
    */ 
    static testMethod void testInactiveAssignmentRuleDoesNotApplyForUserStoryRecordType() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        rule.Inactive__c = true;
        update rule;
        //get related fields
        rule = [select id, Name, Assignee_Assignment__c, UE_Engineer__c, Product_Owner__c, Tech_Writer_Assignment__c, Systest_Assignment__c, Scrum_Team_Assignment__c, QA_Assignment__c, Additional_Emails__c, Senior_Management_POC_Assignment__c from ADM_Assignment_Rule__c
                                                where id= : rule.id];
        
        //create work object which would normally trigger the assignment rule
        ADM_Work__c work = ADM_Work.createTestWork('User Story');
        work.Assignee__c = null;
        work.Senior_Management_POC__c = null;
        Test.startTest();
        update work;
        Test.stopTest();
        System.assert(work.Assignee__c == null, 'Did not expect the Assignee to be Auto-Assigned');
     }
     
     /* 
      @testcaseID a0B20000007mIYGEA2
      @hierarchy GUS.ScrumforceToGUS.Assignment Rules page.RuleVerification.Inactive
      @userstory a0A20000001hNa9
      @expectedResults: Assignment rule does not fire when a user creates a Bug assignment rule that's inactive
      
      @author jhatton
    */ 
    static testMethod void testInactiveAssignmentRuleDoesNotApplyForBugRecordType() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        rule.Inactive__c = true;
        update rule;
        //get related fields
        rule = [select id, Name, Assignee_Assignment__c, UE_Engineer__c, Product_Owner__c, Tech_Writer_Assignment__c, Systest_Assignment__c, Scrum_Team_Assignment__c, QA_Assignment__c, Additional_Emails__c, Senior_Management_POC_Assignment__c from ADM_Assignment_Rule__c
                                                where id= : rule.id];
        
        //create work object which would normally trigger the assignment rule
        ADM_Work__c work = ADM_Work.createTestWork('User Story');
        work.Assignee__c = null;
        Test.startTest();
        update work;
        Test.stopTest();
        System.assert(work.Assignee__c == null, 'Did not expect the Assignee to be Auto-Assigned');
     }
    
     /* 
      @testcaseID a0B20000007mIdxEAE
      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New
      @userstory a0A20000001hNa9
      @expectedResults: Ensure user can create duplicate assignment rules of an inactive assignment rule
      
      @author jhatton
    */ 
   static testMethod void testCanSaveDuplicateOfInActiveAssignmentRule() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        ADM_Assignment_Rule__c rule2 = rule.clone(false, true);
        //deactive the 1st rule and attempt to insert the 2nd one
        rule.Inactive__c = true;
        update rule;
        
        try {
            System.debug('Pre Insert');
            insert rule2;
            System.assert(rule2.id != null);
        } catch (System.Exception e) {
            System.assert(false, 'Should not receive:' + e.getMessage());
        }
        
     }
          
     /* 

      @testcaseID a0B20000007nQR2EAM

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: Ensure that when a user creates a new active AR for an investigation with a Senior Management POC, the field does not get automatically filled in when Request R&D Mgr Review is OFF 
      
      @author jhatton

    */ 

   static testMethod void testSnrMgrPOCIsNotAssignedIfRequestMgrReviewIsFalse() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        update rule;
        rule = [select Id, Senior_Management_POC_Assignment__c from ADM_Assignment_Rule__c where Id = :rule.Id];
        ADM_Work__c work = ADM_Work.setupTestWork('Investigation');
        work.Senior_Management_POC__c = null;
        work.Request_RD_Mgr_Review__c = false;
        //verfiy rule has snr mgr 
        System.assert(rule.Senior_Management_POC_Assignment__c != null);
        //even though snr mgr is populated in rule it should not auto-assign the work record on save as the request mgr review box is false
        Test.startTest();
        insert work;
        Test.stopTest();
        //see if it populated
        work = [select id, Senior_Management_POC__c from ADM_Work__c where id = :work.id];
        System.assertEquals(null, work.Senior_Management_POC__c);
        
     }
     
      /* 
      @testcaseID a0B20000007nQR3EAM 
      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New
      @userstory a0A20000001hNa9
      @expectedResults: Ensure that when a user creates a new active AR for an investigation with a Senior Management POC, the field gets automatically filled in when Request R&D Mgr Review is ON 
      
      @author jhatton
    */ 
   static testMethod void testSnrMgrPOCIsAssignedIfRequestMgrReviewIsTrue() {
		//create the product tag
		ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        update rule;
        rule = [select Id, Senior_Management_POC_Assignment__c from ADM_Assignment_Rule__c where id = :rule.id];
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
        insert tagAssignment;
		
        ADM_Work__c work = ADM_Work.setupTestWork('Investigation');
        work.Product_Tag__c = productTag.Id;
        work.Senior_Management_POC__c = null;
        work.Request_RD_Mgr_Review__c = true;
        //verfiy rule has snr mgr 
        System.assert(rule.Senior_Management_POC_Assignment__c != null);
        //even though snr mgr is populated in rule it should not auto-assign the work record on save as the request mgr review box is false
        Test.startTest();
        insert work;
        Test.stopTest();
        //see if it populated
        work = [select id, Senior_Management_POC__c from ADM_Work__c where id = :work.id];
        System.assertEquals(rule.Senior_Management_POC_Assignment__c, work.Senior_Management_POC__c, 'Rule:' + rule + ' Work:' + work);
        
     }
     
     /* 
      @testcaseID a0B20000007mImGEAU
      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New
      @userstory a0A20000001hNa9
      @expectedResults: Ensure Scrum Team is required
      
      @author jhatton
    */ 
   static testMethod void testScrumTeamIsARequiredField() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        
        try {   
            //now attempt to remove record type
            rule.Scrum_Team_Assignment__c = null;
            update rule;
            System.assert(false, 'Test should have thrown an error before it reached here');
            
        } catch (System.Exception e) {
            System.assert(e.getMessage().contains('Scrum Team is a required field'), e.getMessage());
        }
        
     }
     
     /* 
      @testcaseID a0B20000007mIqhEAE
      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New
      @userstory a0A20000001hNa9
      @expectedResults: Cannot add an inactive user to assignment rule
      
      @author jhatton
    */ 
   static testMethod void testCannotCreateRuleAssignedToInactiveUser() {

        
        //User u = ADM_WorkUser.createTestUser();
        //u.isActive = false;
        //update u;
        User u = new User(Username = 'ruleuser@gus.com' + String.valueOf(Math.random()), //username has to be unique across all tests 
                            FirstName = 'jack',
                            LastName = 'testuser', 
                            Email = '123@salesforce.com',
                            Alias = 'test839',
                            IsActive = false,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1',
                            ProfileId = [select id from Profile where Name = 'System Administrator'].id, //only safe to assume the Sys Admin profile exists
                            LanguageLocaleKey = 'en_US');
                
        //DML is allowed on the user object for later API versions
        Database.insert(u);
        
        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        try {   
            //now attempt to assign rule to inactive user
            rule.Assignee_Assignment__c= u.id;
            update rule;
            //TODO: Open platform bug as to why user is validated as active by the user lookup but not enforced via Apex
            //System.assert(false, 'Test should have thrown an error before it reached here');
            
        } catch (System.Exception e) {
            System.assert(e.getMessage().contains('User is not active'), e.getMessage());
        }
        
     }
     
     /* 

      @testcaseID a0B20000007mIy2EAE

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: When converting a user story to a bug, assignment rules are still correct for the record type
      
      @author jhatton

    */ 
     
   static testMethod void testRuleWithStoryToBugRecordTypeConversion() {
         //create the product tag
		 ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
		 
                 
         User user1 = ADM_WorkUser.createTestUser();
         
         //create rule which only applies to bugs
         ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
         rule.Assignee_Assignment__c = user1.id;
         rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam().id;
         rule.Product_Owner__c = UserInfo.getUserId();
         insert rule;
         
         //create the tag assignment
         ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
         tagAssignment.Assignment_Rule__c = rule.Id;
         tagAssignment.Product_Tag__c = productTag.Id;
         tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
         insert tagAssignment;
		 
         ADM_Work__c work = ADM_Work.createTestWork('User Story');
         //edit record type
         System.assert(work.id != null);
         Id bugRecTypeID = ADM_RecordType.getId('Bug');
         work.RecordTypeId = bugRecTypeID;
         //make sure Assignee is not populated so rule has a chance to fire
         work.Assignee__c = null;
         work.Product_Tag__c = productTag.Id;
         try {
            System.debug('Prior rec type conv');
            Test.startTest();
            update work;
            Test.stopTest();
            //requery
            work = [select Id, Assignee__c, RecordTypeId from ADM_Work__c where id = : work.id];
            System.assert(work.RecordTypeId != null);
            System.assertEquals(bugRecTypeID, work.RecordTypeId, 'Unexpected Record Type ID');
            System.assertEquals(user1.id, work.Assignee__c);
         } catch (System.Exception e) {
            System.assert(false, 'Unexpected exception:' + e);
         }
     }
     
      /* 

      @testcaseID a0B20000007mIy1EAE

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a0A20000001hNa9

      @expectedResults: When converting a bug to story, assignment rules are still correct for the record type
      
      @author jhatton

    */ 
     
    static testMethod void testRuleWithBugToStoryRecordTypeConversion() {
                         
         User user1 = ADM_WorkUser.createTestUser();
         //create the product tag
		 ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
		
         //create rule which only applies to bugs
         ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
         rule.Assignee_Assignment__c = user1.id;
         rule.Scrum_Team_Assignment__c = ADM_ScrumTeam.createTestScrumTeam().id;
         rule.Product_Owner__c = UserInfo.getUserId();
         insert rule;
        
         //create the tag assignment
         ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
         tagAssignment.Assignment_Rule__c = rule.Id;
         tagAssignment.Product_Tag__c = productTag.Id;
         tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_USERSTORY;
         insert tagAssignment;
		
         ADM_Work__c work = ADM_Work.createTestWork('Bug');
         //edit record type
         System.assert(work.id != null);
         Id storyRecTypeID = ADM_RecordType.getId('User Story');
         work.RecordTypeId = storyRecTypeID;
         //make sure Assignee is not populated so rule has a chance to fire
         work.Assignee__c = null;
         work.Product_Tag__c = productTag.Id;
         work.Scrum_Team__c = rule.Scrum_Team_Assignment__c;
         
         try {
            System.debug('Prior rec type conv');
            Test.startTest();
            update work;
            Test.stopTest();
            //requery
            work = [select Id, Assignee__c, RecordTypeId from ADM_Work__c where id = : work.id];
            System.assert(work.RecordTypeId != null);
            System.assertEquals(storyRecTypeID, work.RecordTypeId, 'Unexpected Record Type ID');
            System.assertEquals(user1.id, work.Assignee__c);
         } catch (System.Exception e) {
            System.assert(false, 'Unexpected exception:' + e);
         }
     }
     
    
     
     
     
     

   static testMethod void testInvestigationIsAssignedToApplicableSeverityAssigneeOnRule() {
   			
			//create the product tag
			ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
   	
     		ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRuleInvestigation();
            rule = [select Id, Assignee_Assignment__c, Product_Owner__c, Sev_3_Assignee__c from ADM_Assignment_Rule__c where id = :rule.id];
     		
	        //create the tag assignment
	        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
	        tagAssignment.Assignment_Rule__c = rule.Id;
	        tagAssignment.Product_Tag__c = productTag.Id;
	        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
	        insert tagAssignment;
			
     		ADM_Work__c work = ADM_Work.setupTestWork('Investigation');
     		work.Severity_Level__c = '3';
     		work.Product_Tag__c = productTag.Id;
     		//remove the assignee to let it be auto-assigned
     		work.Assignee__c = null;
     		Test.startTest();
     		insert work;
     		Test.stopTest();
     		work = ADM_Work.get('id', work.id, 'id', 'DESC');
     		System.assertEquals(rule.Sev_3_Assignee__c, work.Assignee__c);
     }  
     
     
     
     /* 

      @testcaseID a1DB00000000pzm

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a07B0000000E1r7

      @expectedResults:  When there are two Product Owners, the PO with highest allocation should be saved, taken from the team's Product Owner team members
      
      @author jhatton

    */ 
     static testMethod void testRuleProductOwnerIsPopulatedWithHighestAllocatedScrumTeamMemberWhenNull() {
		//setup rule and remove product owner
        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.populateRule();
        rule.Product_Owner__c = null;
        //create scrum team member who will be used to populate the product owner field as they have the product owner role
        User u = ADM_WorkUser.createTestUser();
        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c();
        member.Member_Name__c = u.id;
        member.Allocation__c = 100;
        member.Role__c = 'Product Owner';
        member.Scrum_Team__c = rule.Scrum_Team_Assignment__c;
        insert member;
        //now that the member is inserted update the rule
        insert rule;
        
        //verify the Product Owner was populated
        ADM_Assignment_Rule__c updatedRule = [select id, Product_Owner__c from ADM_Assignment_Rule__c where id =:rule.id].get(0);
        
        System.assert(updatedRule.Product_Owner__c != null);
        System.assertEquals(u.id, updatedRule.Product_Owner__c);        
     }
     

    /* 

      @testcaseID a1DB00000000pzr

      @hierarchy GUS.ScrumforcetoGUS.Assignment Rules page.RuleVerification.New

      @userstory a07B0000000E1r7

      @expectedResults:  When there are two Product Owners with the same allocation, one PO should be saved in PO field and the other PO in additional emails field, taken from the team's Product Owner team members
      
      @author jhatton

    */ 
     static testMethod void testRuleAdditionalEmailsIsPopulatedWhenTeamHasMultipleProductOwnersAndProductOwnerIsNull() {
		//setup rule and remove product owner
        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.populateRule();
        rule.Product_Owner__c = null;
        //create scrum team member who will be used to populate the product owner field as they have the product owner role
        User u = ADM_WorkUser.createTestUser();
        List<ADM_Scrum_Team_Member__c> members = new List<ADM_Scrum_Team_Member__c>(); 
        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c();
        member.Member_Name__c = u.id;
        member.Allocation__c = 100;
        member.Role__c = 'Product Owner';
        member.Scrum_Team__c = rule.Scrum_Team_Assignment__c;
        members.add(member);
        User u2 = ADM_WorkUser.createTestUser();
     
        ADM_Scrum_Team_Member__c member2 = new ADM_Scrum_Team_Member__c();
        member2.Member_Name__c = u2.id;
        member2.Allocation__c = 90;
        member2.Role__c = 'Product Owner';
        member2.Scrum_Team__c = rule.Scrum_Team_Assignment__c;
        members.add(member2);
        
        insert members;
        //now that the members are inserted update the rule
        insert rule;
        
        //verify the Product Owner was populated
        ADM_Assignment_Rule__c updatedRule = [select id, Additional_Emails__c, Product_Owner__c from ADM_Assignment_Rule__c where id =:rule.id].get(0);
        
        System.assert(updatedRule.Product_Owner__c != null);
        System.assertEquals(u.id, updatedRule.Product_Owner__c);
        //also verify the 2nd product owner was stored in additional emails
        System.assert(updatedRule.Additional_Emails__c.contains(u2.email));
                
     }
     
      /* 
      @testcaseID a1DB00000001Mhc
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Work from Product Tag
      @userstory a07B0000000Kd3A
      @expectedResults  The new product tag should not assign any bugs to the "Senior Mgr POC"
      @author jhatton
    */ 

     static testMethod void testClonedRulesDontSaveFieldsThatAreNotApplicableForItsRecordType() {

        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRuleInvestigation();
        //now attempt to clone.  
        System.currentPageReference().getParameters().put('clone', '1');
        System.currentPageReference().getParameters().put('id', rule.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(rule);
        ADM_AssignmentRuleController arc = new ADM_AssignmentRuleController(stdController);
        
        ADM_Assignment_Rule__c clonedRule = arc.rule;
        
        //assert its identical
        System.assertEquals(rule.Assignee_Assignment__c, clonedRule.Assignee_Assignment__c);
        
        //verify it can't be saved as it is a duplicate
        System.assert(clonedRule.id == null);   
        //change its record type but leave Investigation specific fields like Exception Request POC and Snr Mgr populated
        arc.rule = clonedRule;
        PageReference pr = arc.saveRule();
        // Null page reference should be returned because it's a duplicate assignment rule.
        System.assert(pr == null, 'PageReference should be null since this is the rule is a duplicate.');
     }
     
    static testMethod void testProductTagCannotBeDeletedWhenAssociatedToAnAssignmentRule() {
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = ADM_WorkUser.createTestUser().Id;
        rule.Product_Owner__c = ADM_WorkUser.createTestUser().id;
        rule.Scrum_Team_Assignment__c = team.Id;
        insert rule;
        
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'tag' + Math.random();
        tag.Active__c = true;
        tag.Team__c = team.Id;
        insert tag;
        
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Product_Tag__c = tag.Id;
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
        
        try {
            delete rule;
            System.assert(false, 'Assignment Rule should not have been deleted because it is used by a Product Tag.');
        } catch(System.DMLException e) {
            System.assert(e.getMessage().contains('cannot') && e.getMessage().contains('deleted'), 'Assignment Rule should not have been deleted because it used by an Product Tag: ' + e.getMessage());
        }
    }
}