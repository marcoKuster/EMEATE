@isTest
public class ADM_TagAssignmentComponentTests { 

    @IsTest
    private static ADM_Product_Tag__c setupTagMatrix() {
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'GUS Test Product Tag 123';
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        tag.Team__c = team.id;
        insert tag; 
        //setup up test rule and tag assignment
        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        rule.Scrum_Team_Assignment__c = team.id;
        update rule;
        //relate rule to tag
        ADM_Tag_Assignment__c ta = new ADM_Tag_Assignment__c();
        ta.Assignment_Rule__c = rule.id;
        ta.Product_Tag__c = tag.id;
        ta.Record_Type__c = 'Bug';
        insert ta;
        return tag;
    
    }

      /* 
      @testcaseID a1DB00000001MV3
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000Kd3A
      @expectedResults Assignment rules can be selected or de-selected on Product tag page 
      @author jhatton
    */ 
    static testMethod void testTagMatrixIsPopulated() {
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        
        //pull the raw data to compare to what the components apex controller builds later
        ADM_Tag_Assignment__c expectedAssignment = [select id, Assignment_Rule__c, Product_Tag__c, Record_Type__c, Tag_Record_Type_Key__c from ADM_Tag_Assignment__c where Product_Tag__c = :tag.id];
        
        //verify compound key has been populated correctly by Tag Assignment trigger
        String expectedKey = expectedAssignment.Product_Tag__c + '@' + expectedAssignment.Assignment_Rule__c + '@' + expectedAssignment.Record_Type__c;
        System.assertEquals(expectedKey,  expectedAssignment.Tag_Record_Type_Key__c);
        
        
        //load tag matrix by initializing VF page that references the tag matrix component
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        controller.tagID = tag.id;
        
        //build matrix 
        List<ADM_TagAssignmentComponentController.TeamRuleWrapper> wrappers = controller.getTeamRuleAssignments();
        ADM_TagAssignmentComponentController.TeamRuleWrapper wrappedAssignment = wrappers.get(0);
        
        //verify the correct rule is assigned to the correct tag for the correct record type
        System.assertEquals(expectedAssignment.Assignment_Rule__c, wrappedAssignment.rule.id);
        System.assertEquals(expectedAssignment.id, wrappedAssignment.BugAssignment.id);
        System.assertEquals(null, wrappedAssignment.storyAssignment);
        System.assertEquals(null, wrappedAssignment.investigationAssignment);
        System.assertEquals(true, wrappedAssignment.bugAssigned);
        System.assertEquals(false, wrappedAssignment.storyAssigned);
        System.assertEquals(false, wrappedAssignment.investigationAssigned);
        System.assertEquals(controller.readOnly, wrappedAssignment.readOnly, 'Expected the readOnly property of the rule to match that of the controller');
    }
    
    /**
     * Given multiple tags and multiple tag assignments, 
     * ensure that they do not interfere.
     *
     * More specifically, the assignments for one tag should not change the
     * results for another.
     * @author jared.pearson
     */
      /* 
      @testcaseID a1DB00000001XRC
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Detail Product tag
      @userstory a07B0000000M22Q
      @expectedResults  The Used By product tag matrix  shows all o f the available product tags that use that assignment rule
    */ 
    static testMethod void testTagMatrixMultiRuleMultiTag() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'GUS Test Product Tag 123';
        tag.Team__c = team.id;
        insert tag;
        
        ADM_Product_Tag__c tag2 = new ADM_Product_Tag__c();
        tag2.Name = 'GUS Test Product Tag 456';
        tag2.Team__c = team.id;
        insert tag2;
        
        //setup up test rule and tag assignment
        ADM_Assignment_Rule__c rule1 = ADM_AssignmentRuleTest.setupRule();
        rule1.Scrum_Team_Assignment__c = team.id;
        update rule1;
        
        ADM_Tag_Assignment__c expectedAssignment = new ADM_Tag_Assignment__c();
        expectedAssignment.Assignment_Rule__c = rule1.id;
        expectedAssignment.Product_Tag__c = tag.id;
        expectedAssignment.Record_Type__c = 'Bug';
        insert expectedAssignment;
        
        ADM_Assignment_Rule__c rule2 = ADM_AssignmentRuleTest.setupRule();
        rule2.Scrum_Team_Assignment__c = team.id;
        update rule2;
        
        ADM_Tag_Assignment__c rule2InvestigationAssignment = new ADM_Tag_Assignment__c();
        rule2InvestigationAssignment.Assignment_Rule__c = rule2.id;
        rule2InvestigationAssignment.Product_Tag__c = tag.id;
        rule2InvestigationAssignment.Record_Type__c = 'Investigation';
        insert rule2InvestigationAssignment;
        
        ADM_Tag_Assignment__c rule2UserStoryAssignment = new ADM_Tag_Assignment__c();
        rule2UserStoryAssignment.Assignment_Rule__c = rule2.id;
        rule2UserStoryAssignment.Product_Tag__c = tag.id;
        rule2UserStoryAssignment.Record_Type__c = 'User Story';
        insert rule2UserStoryAssignment;
        
        ADM_Assignment_Rule__c rule3 = ADM_AssignmentRuleTest.setupRule();
        rule3.Scrum_Team_Assignment__c = team.id;
        update rule3;
        
        //create a tag assignment for tag2 => rule3
        //this is to check that when viewing tag1 there is no influence by 
        //another tag (in this case tag2)
        ADM_Tag_Assignment__c tag2Rule3Assignment = new ADM_Tag_Assignment__c();
        tag2Rule3Assignment.Assignment_Rule__c = rule3.id;
        tag2Rule3Assignment.Product_Tag__c = tag2.id;
        tag2Rule3Assignment.Record_Type__c = 'Bug';
        insert tag2Rule3Assignment;
        
        ADM_Assignment_Rule__c rule4 = ADM_AssignmentRuleTest.setupRule();
        rule4.Scrum_Team_Assignment__c = team.id;
        update rule4;
        
        Test.startTest();
        
        //load tag matrix by initializing VF page that references the tag matrix component
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        controller.tagID = tag.id;
        
        //build matrix 
        List<ADM_TagAssignmentComponentController.TeamRuleWrapper> wrappers = controller.getTeamRuleAssignments();
        
        Test.stopTest();
        
        System.assertEquals(4, wrappers.size(), 'Expected 4 wrappers to be returned which is the same amount as assignment rules for the team.');
        
        Boolean verifiedRule1 = false;
        Boolean verifiedRule2 = false;
        Boolean verifiedOtherRules = false;
        for(ADM_TagAssignmentComponentController.TeamRuleWrapper wrappedAssignment : wrappers) {
            
            if(wrappedAssignment.rule.Id == rule1.id) {
                if(verifiedRule1) {
                    System.assert(false, 'Multiple wrappers contain the rule');
                }
                verifiedRule1 = true;
                System.assert(wrappedAssignment.BugAssignment != null, 'Rule 1 should be associated to the bug assignment');
                System.assertEquals(expectedAssignment.id, wrappedAssignment.BugAssignment.id, 'Rule 1 should be associated to the bug assignment');
                System.assertEquals(true, wrappedAssignment.bugAssigned, 'Rule 1 should be assigned the bug');
                
                System.assertEquals(null, wrappedAssignment.storyAssignment, 'Rule 1 should not be assigned the user story');
                System.assertEquals(false, wrappedAssignment.storyAssigned, 'Rule 1 should not be assigned the story');
                
                System.assertEquals(null, wrappedAssignment.investigationAssignment, 'Rule 1 should not be assigned the investigation');
                System.assertEquals(false, wrappedAssignment.investigationAssigned, 'Rule 1 should not be assigned the investigation');
                
            } else if(wrappedAssignment.rule.Id == rule2.id) {
                if(verifiedRule2) {
                    System.assert(false, 'Multiple wrappers contain the rule');
                }
                verifiedRule2 = true;
                System.assertEquals(null, wrappedAssignment.bugAssignment, 'Rule 2 should be assigned the bug');
                System.assertEquals(false, wrappedAssignment.bugAssigned, 'Rule 2 should be assigned the bug');
                
                System.assert(wrappedAssignment.storyAssignment != null, 'Rule 2 should be associated to the user story assignment');
                System.assertEquals(rule2UserStoryAssignment.id, wrappedAssignment.storyAssignment.id, 'Rule 2 should be assigned the user story');
                System.assertEquals(true, wrappedAssignment.storyAssigned, 'Rule 2 should not be assigned the story');
                
                System.assert(wrappedAssignment.investigationAssignment != null, 'Rule 2 should be associated to the investigation assignment');
                System.assertEquals(rule2InvestigationAssignment.id, wrappedAssignment.investigationAssignment.id, 'Rule 2 should be assigned the investigation');
                System.assertEquals(true, wrappedAssignment.investigationAssigned, 'Rule 2 should not be assigned the investigation');
                
            } else {
                verifiedOtherRules = true;
                System.assertEquals(null, wrappedAssignment.bugAssignment, 'Rule should not be associated to the bug assignment');
                System.assertEquals(false, wrappedAssignment.bugAssigned, 'Rule should not be assigned the bug');
                
                System.assertEquals(null, wrappedAssignment.storyAssignment, 'Rule should be assigned the bug');
                System.assertEquals(false, wrappedAssignment.storyAssigned, 'Rule should not be assigned the story');
                
                System.assertEquals(null, wrappedAssignment.investigationAssignment, 'Rule should be assigned the bug');
                System.assertEquals(false, wrappedAssignment.investigationAssigned, 'Rule should not be assigned the investigation');
            }
        }
        
        System.assert(verifiedRule1, 'Rule 1 was not verified because it was not present in the collection returned by #getTeamRuleAssignments()');
        System.assert(verifiedRule2, 'Rule 2 was not verified because it was not present in the collection returned by #getTeamRuleAssignments()');
        System.assert(verifiedOtherRules, 'Other Rules were not verified because they were not present in the collection returned by #getTeamRuleAssignments()');
    }
    
    /*
      @author jared.pearson
    */ 
    static testMethod void testUsedByTags() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        //setup up tag assignment
        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        rule.Scrum_Team_Assignment__c = team.id;
        update rule;
        
        //create new product tags
        ADM_Product_Tag__c tag1 = new ADM_Product_Tag__c();
        tag1.Name = 'GUS Test Product Tag 123';
        tag1.Team__c = team.id;
        insert tag1;
        
        //relate rule to tag 1
        ADM_Tag_Assignment__c tagAssignment1 = new ADM_Tag_Assignment__c();
        tagAssignment1.Assignment_Rule__c = rule.id;
        tagAssignment1.Product_Tag__c = tag1.id;
        tagAssignment1.Record_Type__c = 'Bug';
        insert tagAssignment1;
        
        //create new product tag
        ADM_Product_Tag__c tag2 = new ADM_Product_Tag__c();
        tag2.Name = 'GUS Test Product Tag 456';
        tag2.Team__c = team.id;
        insert tag2; 
        
        //relate rule to tag 2
        ADM_Tag_Assignment__c tagAssignment2 = new ADM_Tag_Assignment__c();
        tagAssignment2.Assignment_Rule__c = rule.id;
        tagAssignment2.Product_Tag__c = tag2.id;
        tagAssignment2.Record_Type__c = 'Bug';
        insert tagAssignment2;
        
        //create new product tag
        ADM_Product_Tag__c tag3 = new ADM_Product_Tag__c();
        tag3.Name = 'GUS Test Product Tag 789';
        tag3.Team__c = team.id;
        insert tag3; 
        
        //relate rule to tag 2
        ADM_Tag_Assignment__c tagAssignment3 = new ADM_Tag_Assignment__c();
        tagAssignment3.Assignment_Rule__c = rule.id;
        tagAssignment3.Product_Tag__c = tag3.id;
        tagAssignment3.Record_Type__c = 'Bug';
        insert tagAssignment3;
        
        //load tag matrix by initializing VF page that references the tag matrix component
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        controller.tagID = tag1.id;
        
        //build matrix 
        List<ADM_TagAssignmentComponentController.TeamRuleWrapper> wrappers = controller.getTeamRuleAssignments();
        
        System.assertEquals(1, wrappers.size(), 'ADM_TagAssignmentComponentController#getTeamRuleAssignments() should only return one TeamRuleWrapper since there is only one tag assignment for the tag');
        ADM_TagAssignmentComponentController.TeamRuleWrapper wrappedAssignment = wrappers.get(0);
        System.assert(wrappedAssignment.usedBy != null, 'TeamRuleWrapper#usedBy should never be null');
        System.assert(wrappedAssignment.truncatedUsedBy != null, 'TeamRuleWrapper#truncatedUsedBy should never be null');
        System.assert(!wrappedAssignment.usedBy.contains(tag1.Name), 'Expected #usedBy to not contain the currently selected tag');
        System.assert(wrappedAssignment.usedBy.contains(tag2.Name), 'Expected #usedBy to contain the second tag');
        System.assert(wrappedAssignment.usedBy.contains(tag3.Name), 'Expected #usedBy to contain the third tag');
    }
    
     /* 
      @testcaseID a1DB00000001IYM
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Assignment Rule
      @userstory a07B0000000Kd3A
      @expectedResults  Users can add a new assignment rule from product tag using the following fields: Product Owner, Assignee, QA Engineer, Tech Writer, Perf Engineer, UE Engineer, Other Recipients
      @author jhatton
    */ 

     static testMethod void testNewRuleCanBeCreated() {
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        //create a test user
        User u = createTestUser();
        
        Test.startTest();
        //load tag matrix by initializing VF page that references the tag matrix component
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        controller.tagID = tag.id;
        
        //create rule and apply to ALL record types 
        System.debug('about to save rule');
        ADM_TagAssignmentComponentController.saveNewAssignmentRule(UserInfo.getName(), UserInfo.getName(), u.name, u.name, u.name, u.name, u.name, u.name, u.email, true, true, true, (String)tag.id, (String)tag.Team__c, u.name, u.name, u.name, u.name);
        Test.stopTest();
        
        //validate new data appears in matrix
        controller.reloadMatrix();
        List<ADM_TagAssignmentComponentController.TeamRuleWrapper> wrappers = controller.getTeamRuleAssignments();  
      
        ADM_TagAssignmentComponentController.TeamRuleWrapper wrappedAssignment = null;
        for(ADM_TagAssignmentComponentController.TeamRuleWrapper wrapper: wrappers) {
        	if(wrapper.rule != null && wrapper.bugAssigned == true && wrapper.storyAssigned == true && wrapper.investigationAssigned == true) {
        		wrappedAssignment = wrapper;
        		break;
        	}	
        }
        
        //debugging flapper
        if(wrappedAssignment != null) {
        	
	        List<ADM_Tag_Assignment__c> assignments = [
	            select 
	                Id, 
	                Record_Type__c, 
	                Product_Tag__r.Id,
	                Product_Tag__r.Name,
	                Assignment_Rule__c
	            from
	                ADM_Tag_Assignment__c 
	            where
	                Product_Tag__c = :tag.id];
	        
	        
	        System.assert(wrappedAssignment.BugAssignment != null, ' Did not find Bug Assignment.  Wrappers:' + wrappers + ' Assignments:' + assignments);
	        System.assertEquals(true, wrappedAssignment.bugAssigned);
	        System.assertEquals(true, wrappedAssignment.storyAssigned);
	        System.assertEquals(true, wrappedAssignment.investigationAssigned);
	        
	        //verify the correct fields were assigned to the rule.  
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Assignee_Assignment__c); 
	        System.assertEquals(u.id, wrappedAssignment.rule.Sev_1_Assignee__c); 
	        System.assertEquals(u.id, wrappedAssignment.rule.Sev_2_Assignee__c); 
	        System.assertEquals(u.id, wrappedAssignment.rule.Sev_3_Assignee__c); 
	        System.assertEquals(u.id, wrappedAssignment.rule.Sev_4_Assignee__c);  
        }
        
    
    }
    
     /* 
      @testcaseID a1DB00000001MRy
      @hierarchy GUS.Product Tags.New Assignment Rule from Product tag page
      @userstory a07B0000000Kd3A
      @expectedResults  Users can add a new assignment rule from product tag using the following fields: Product Owner, Assignee, QA Engineer, Tech Writer, Perf Engineer, UE Engineer, Other Recipients
      @author jhatton
    */
    static testMethod void testNewRuleCanBeCreatedForBugsOnly() {
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        //create a test user
        User u = createTestUser();
        
        Test.startTest();
        //load tag matrix by initializing VF page that references the tag matrix component
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        controller.tagID = tag.id;
        
        //create rule and apply to ALL record types 
        System.debug('about to save rule');
        ADM_TagAssignmentComponentController.saveNewAssignmentRule(UserInfo.getName(), UserInfo.getName(), null, null, null, null, null, null, null, true, false, false, (String)tag.id, (String)tag.Team__c, null, null, null, null);
        Test.stopTest();
        
        //validate new data appears in matrix
        controller.reloadMatrix();
        List<ADM_TagAssignmentComponentController.TeamRuleWrapper> wrappers = controller.getTeamRuleAssignments();  
      
        ADM_TagAssignmentComponentController.TeamRuleWrapper wrappedAssignment = null;
        for(ADM_TagAssignmentComponentController.TeamRuleWrapper wrapper: wrappers) {
        	if(wrapper.rule != null && wrapper.bugAssigned == true) {
        		wrappedAssignment = wrapper;
        		break;
        	}	
        }
        
        if(wrappedAssignment != null) {
        	
	        List<ADM_Tag_Assignment__c> assignments = [
	            select 
	                Id, 
	                Record_Type__c, 
	                Product_Tag__r.Id,
	                Product_Tag__r.Name,
	                Assignment_Rule__c
	            from
	                ADM_Tag_Assignment__c 
	            where
	                Product_Tag__c = :tag.id];
	        
	        
	        System.assert(wrappedAssignment.BugAssignment != null, ' Did not find Bug Assignment.  Wrappers:' + wrappers + ' Assignments:' + assignments);
	        System.assertEquals(true, wrappedAssignment.bugAssigned);
	        //verify the correct fields were assigned to the rule.  
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Assignee_Assignment__c); 
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Product_Owner__c); 
	    }
    }
       /* 
      @testcaseID a1DB00000001S2a
      @hierarchy GUS.Product Tags.New Assignment Rule from Product tag page
      @userstory a07B0000000Kd3A
      @expectedResults Users can add a new assignment rule from product tag using the following fields: Scrum Team, Product Owner, Assignee, QA Engineer, Tech Writer, Perf Engineer, UE Engineer, Other Recipients
      @author jhatton
    */  
    static testMethod void testNewRuleCanBeCreatedForStoriesOnly() {
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        //create a test user
        User u = createTestUser();
        
        Test.startTest();
        //load tag matrix by initializing VF page that references the tag matrix component
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        controller.tagID = tag.id;
        
        //create rule and apply to ALL record types 
        System.debug('about to save rule');
        ADM_TagAssignmentComponentController.saveNewAssignmentRule(UserInfo.getName(), UserInfo.getName(), null, null, null, null, null, null, null, false, true, false, (String)tag.id, (String)tag.Team__c, null, null, null, null);
        Test.stopTest();
        
        //validate new data appears in matrix
        controller.reloadMatrix();
        List<ADM_TagAssignmentComponentController.TeamRuleWrapper> wrappers = controller.getTeamRuleAssignments();  
      
        ADM_TagAssignmentComponentController.TeamRuleWrapper wrappedAssignment = null;
        for(ADM_TagAssignmentComponentController.TeamRuleWrapper wrapper: wrappers) {
        	if(wrapper.rule != null && wrapper.storyAssigned == true) {
        		wrappedAssignment = wrapper;
        		break;
        	}	
        }
        
        if(wrappedAssignment != null) {
        	
	        List<ADM_Tag_Assignment__c> assignments = [
	            select 
	                Id, 
	                Record_Type__c, 
	                Product_Tag__r.Id,
	                Product_Tag__r.Name,
	                Assignment_Rule__c
	            from
	                ADM_Tag_Assignment__c 
	            where
	                Product_Tag__c = :tag.id];
	        
	        
	        System.assert(wrappedAssignment.StoryAssignment != null, ' Did not find Story Assignment.  Wrappers:' + wrappers + ' Assignments:' + assignments);
	        System.assertEquals(true, wrappedAssignment.storyAssigned);
	        //verify the correct fields were assigned to the rule.  
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Assignee_Assignment__c); 
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Product_Owner__c); 
	    }
    }
        /* 
      @testcaseID a1DB00000001S2g
      @hierarchy GUS.Product Tags.New Assignment Rule from Product tag page
      @userstory a07B0000000Kd3A
      @expectedResults Users can add a new assignment rule using the following fields: Scrum team, Product Owner, Assignee1, Assignee2, Assignee3, Assignee 4, QA Engineer, Senior Mgr POC, Exception POC, Other Recipients
      @author jhatton
    */     
    static testMethod void testNewRuleCanBeCreatedForInvestigationsOnly() {
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        //create a test user
        User u = createTestUser();
        
        Test.startTest();
        //load tag matrix by initializing VF page that references the tag matrix component
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        controller.tagID = tag.id;
        
        //create rule and apply to ALL record types 
        System.debug('about to save rule');
        ADM_TagAssignmentComponentController.saveNewAssignmentRule(UserInfo.getName(), null, null, null, null, null, null, null, null, false, false, true, (String)tag.id, (String)tag.Team__c, UserInfo.getName(), UserInfo.getName(), UserInfo.getName(), UserInfo.getName());
        Test.stopTest();
        
        //validate new data appears in matrix
        controller.reloadMatrix();
        List<ADM_TagAssignmentComponentController.TeamRuleWrapper> wrappers = controller.getTeamRuleAssignments();  
      
        ADM_TagAssignmentComponentController.TeamRuleWrapper wrappedAssignment = null;
        for(ADM_TagAssignmentComponentController.TeamRuleWrapper wrapper: wrappers) {
        	if(wrapper.rule != null && wrapper.investigationAssigned == true) {
        		wrappedAssignment = wrapper;
        		break;
        	}	
        }
        
        if(wrappedAssignment != null) {
        	
	        List<ADM_Tag_Assignment__c> assignments = [
	            select 
	                Id, 
	                Record_Type__c, 
	                Product_Tag__r.Id,
	                Product_Tag__r.Name,
	                Assignment_Rule__c
	            from
	                ADM_Tag_Assignment__c 
	            where
	                Product_Tag__c = :tag.id];
	        
	        
	        System.assert(wrappedAssignment.InvestigationAssignment != null, ' Did not find Investigation Assignment.  Wrappers:' + wrappers + ' Assignments:' + assignments);
	        System.assertEquals(true, wrappedAssignment.investigationAssigned);
	        //verify the correct fields were assigned to the rule.  
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Product_Owner__c);
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Sev_1_Assignee__c); 
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Sev_2_Assignee__c); 
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Sev_3_Assignee__c); 
	        System.assertEquals(UserInfo.getUserId(), wrappedAssignment.rule.Sev_4_Assignee__c);  
	    }
    }
    
    /* 
      @testcaseID a1DB00000001Td0
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults Tag names must be unique within a single team.
    */ 
    /* 
     @author jared.pearson
    */
    static testMethod void testNewRuleFailWhenDuplicate() {
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        
        //create rule
        User u = createTestUser();
        
        //create rule
        ADM_TagAssignmentComponentController.saveNewAssignmentRule(UserInfo.getName(), UserInfo.getName(), u.name, u.name, u.name, u.name, u.name, u.name, u.email, true, true, true, (String)tag.id, (String)tag.Team__c, u.name, u.name, u.name, u.name);
        
        Test.startTest();
        try {
            //create a rule that is considered a duplicate
            ADM_TagAssignmentComponentController.saveNewAssignmentRule(UserInfo.getName(), UserInfo.getName(), u.name, u.name, u.name, u.name, u.name, u.name, u.email, true, true, true, (String)tag.id, (String)tag.Team__c, u.name, u.name, u.name, u.name);
            System.assert(false, 'Expected exception about the duplicate rule');
        } catch(ADM_UnexpectedValueException exc) {
            System.assert(exc.getMessage().contains('rule already exists'), 'Expected exception about the duplicate rule but received \'' + exc.getMessage() + '\'');
        }
        Test.stopTest();
    }
    
    static void testSaveNewRuleWithInactiveUser(
        String inactiveUserFieldLabel, 
        String productOwner,
        String assignee,
        String qe,
        String tw,
        String perfeng,
        String ue,
        String seniorMgmt,
        String excRequest, 
        String otherReps) {
        
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        
        //create rule and apply to ALL record types 
        Test.startTest();
        try {
            ADM_TagAssignmentComponentController.saveNewAssignmentRule(productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, otherReps, true, true, true, (String)tag.id, (String)tag.Team__c, assignee, assignee, assignee, assignee);
            System.assert(false, 'Expected exception to be thrown when ' + inactiveUserFieldLabel + ' is inactive');
        } catch(ADM_UnexpectedValueException exc) {
            System.assert(exc.getMessage().contains('is not an active user'), 'Expected exception to be thrown when ' + inactiveUserFieldLabel + ' is inactive but instead \'' + exc.getMessage() + '\'');
        }
        Test.stopTest();
    }
    
    static void testSaveNewRuleWithoutRequiredUser(
        String inactiveUserFieldLabel, 
        String productOwner,
        String assignee,
        String qe,
        String tw,
        String perfeng,
        String ue,
        String seniorMgmt,
        String excRequest, 
        String otherReps) {
        
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        
        //create rule and apply to ALL record types 
        Test.startTest();
        try {
            ADM_TagAssignmentComponentController.saveNewAssignmentRule(productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, otherReps, true, true, true, (String)tag.id, (String)tag.Team__c, null, null, null, null);
            System.assert(false, 'Expected exception to be thrown when ' + inactiveUserFieldLabel + ' is required');
        } catch(ADM_UnexpectedValueException exc) {
            System.assert(exc.getMessage().contains('required'), 'Expected exception to be thrown when ' + inactiveUserFieldLabel + ' is required but instead \'' + exc.getMessage() + '\'');
        }
        Test.stopTest();
    }

      /* 
      @testcaseID a1DB00000001ITF
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that the product owner cannot be found
    */ 
    
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithInvalidProductOwner() {
        User u = createTestUser();
        String productOwner = 'not valid' + Math.random();
        String assignee = UserInfo.getName();
        String qe = u.Name;
        String tw = u.Name;
        String perfeng = u.Name;
        String ue = u.Name;
        String seniorMgmt = u.Name;
        String excRequest = u.Name;
        
        testSaveNewRuleWithInactiveUser('Product Owner', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }

      /* 
      @testcaseID a1DB00000001TdA
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that a product owner is required
      @author jhatton
    */ 
    
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithoutProductOwner() {
        User u = createTestUser();
        String productOwner = null;
        String assignee = UserInfo.getName();
        String qe = u.Name;
        String tw = u.Name;
        String perfeng = u.Name;
        String ue = u.Name;
        String seniorMgmt = u.Name;
        String excRequest = u.Name;
        
        testSaveNewRuleWithoutRequiredUser('Product Owner', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
    
      /* 
      @testcaseID a1DB00000001Tdw
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that an assignee is invalid
    */ 
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithInvalidAssignee() {
        User u = createTestUser();
        String productOwner = UserInfo.getName();
        String assignee = 'not valid' + Math.random();
        String qe = u.Name;
        String tw = u.Name;
        String perfeng = u.Name;
        String ue = u.Name;
        String seniorMgmt = u.Name;
        String excRequest = u.Name;
        
        testSaveNewRuleWithInactiveUser('Assignee', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
    
      /* 
      @testcaseID a1DB00000001Tdm
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that an assignee is required
    */ 
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithoutAssignee() {
        User u = createTestUser();
        String productOwner = UserInfo.getName();
        String assignee = null;
        String qe = u.Name;
        String tw = u.Name;
        String perfeng = u.Name;
        String ue = u.Name;
        String seniorMgmt = u.Name;
        String excRequest = u.Name;
        
        testSaveNewRuleWithoutRequiredUser('Assignee', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
    
      /* 
      @testcaseID a1DB00000001Te1
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that an QE is invalid
    */ 
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithInvalidQe() {
        User u = createTestUser();
        String productOwner = UserInfo.getName();
        String assignee = UserInfo.getName();
        String qe = 'not valid' + Math.random();
        String tw = u.Name;
        String perfeng = u.Name;
        String ue = u.Name;
        String seniorMgmt = u.Name;
        String excRequest = u.Name;
        
        testSaveNewRuleWithInactiveUser('QE', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
      /* 
      @testcaseID a1DB00000001Te6
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that an Tech Writer is invalid
    */ 
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithInvalidTechWriter() {
        User u = createTestUser();
        String productOwner = UserInfo.getName();
        String assignee = UserInfo.getName();
        String qe = u.Name;
        String tw = 'not valid' + Math.random();
        String perfeng = u.Name;
        String ue = u.Name;
        String seniorMgmt = u.Name;
        String excRequest = u.Name;
        
        testSaveNewRuleWithInactiveUser('Tech Writer', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
    
      /* 
      @testcaseID a1DB00000001TeB
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that a Perf Engineer is invalid
    */ 
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithInvalidPerfEng() {
        //create rule
        User u = createTestUser();
        String productOwner = UserInfo.getName();
        String assignee = UserInfo.getName();
        String qe = u.Name;
        String tw = u.Name;
        String perfeng = 'not valid' + Math.random();
        String ue = u.Name;
        String seniorMgmt = u.Name;
        String excRequest = u.Name;
        
        testSaveNewRuleWithInactiveUser('Performance Engineer', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
      /* 
      @testcaseID a1DB00000001TeB
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that user is inactive
    */ 
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithInvalidUserExp() {
        User u = createTestUser();
        String productOwner = UserInfo.getName();
        String assignee = UserInfo.getName();
        String qe = u.Name;
        String tw = u.Name;
        String perfeng = u.Name;
        String ue = 'not valid' + Math.random();
        String seniorMgmt = u.Name;
        String excRequest = u.Name;
        
        testSaveNewRuleWithInactiveUser('User Exp', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
    
      /* 
      @testcaseID a1DB00000001Tep
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that Senior Manager is inactive
    */ 
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithInvalidSeniorMgmt() {
        User u = createTestUser();
        String productOwner = UserInfo.getName();
        String assignee = UserInfo.getName();
        String qe = u.Name;
        String tw = u.Name;
        String perfeng = u.Name;
        String ue = u.Name;
        String seniorMgmt = 'not valid' + Math.random();
        String excRequest = u.Name;
        
        testSaveNewRuleWithInactiveUser('Senior Mgmt', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
      /* 
      @testcaseID a1DB00000001Tez
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000LSoDIAW
      @expectedResults An error occurs that Exception POC is invalid
    */ 
    
    /* 
     @author jared.pearson
    */ 
    static testMethod void testSaveNewRuleFailureWithInvalidExceptionRequest() {
        User u = createTestUser();
        String productOwner = UserInfo.getName();
        String assignee = UserInfo.getName();
        String qe = u.Name;
        String tw = u.Name;
        String perfeng = u.Name;
        String ue = u.Name;
        String seniorMgmt = u.Name;
        String excRequest = 'not valid' + Math.random();
        
        testSaveNewRuleWithInactiveUser('Exception Request', productOwner, assignee, qe, tw, perfeng, ue, seniorMgmt, excRequest, u.Email);
    }
      
      /* 
      @testcaseID a1DB00000001Wz1
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Assignment Rule from Product tag page
      @userstory a07B0000000LgYCIA0
      @expectedResults User sees no bugs, user stories or investigations linked to any assignment rules
    */ 
    
    /*
      @author jared.pearson
    */ 
    static testMethod void testReadOnlyWhenNoProductTag() {
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        
        Test.startTest();
        System.assertEquals(true, controller.readOnly, 'Expected readOnly to return true because the product tag has not been set.');
        Test.stopTest();
    }
      /* 
      @testcaseID a1DB00000001Wz6
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Assignment Rule from Product tag page
      @userstory a07B0000000LgYCIA0
      @expectedResults The "Create new" button should not show on the product tag
    */
    
    /*
      @author jared.pearson
    */ 
    static testMethod void testReadOnlyWhenUserNotInScrumTeam() {
        //create new product tag
        ADM_Product_Tag__c tag = setupTagMatrix();
        
        ADM_TagAssignmentComponentController controller = new ADM_TagAssignmentComponentController();
        controller.tagID = tag.id;
        
        Test.startTest();
        System.assertEquals(true, controller.readOnly, 'Expected readOnly to return true because the user is not within the tag\'s scrum team.');
        System.assertEquals('visibility:hidden', controller.matrixInfoMessageWrapperStyle, 'Expected that wrapper style to include visibility hidden for the message since the user is not a member of the team.');
        Test.stopTest();
    }
      /* 
      @testcaseID a1DB00000001WzB
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Assignment Rule from Product tag page
      @userstory a07B0000000LgYCIA0
      @expectedResults The "Create new" button should show on the product tag
    */
    
    /*
      @author jared.pearson
    */ 
    static testMethod void testNotReadOnlyWhenUserInScrumTeam() {
        User user = createTestUser();
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'GUS Test Product Tag 123';
        tag.Team__c = team.id;
        insert tag;
        
        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        rule.Scrum_Team_Assignment__c = team.id;
        update rule;
        
        ADM_Tag_Assignment__c ta = new ADM_Tag_Assignment__c();
        ta.Assignment_Rule__c = rule.id;
        ta.Product_Tag__c = tag.id;
        ta.Record_Type__c = 'Bug';
        insert ta;
        
        ADM_Scrum_Team_Member__c teamMembership = new ADM_Scrum_Team_Member__c();
        teamMembership.Scrum_Team__c = team.Id;
        teamMembership.Member_Name_Text__c = user.Name;
        teamMembership.Member_Name__c = user.Id;
        teamMembership.Allocation__c = 100;
        teamMembership.Role__c = 'Product Owner';
        insert teamMembership;
        
        ADM_TagAssignmentComponentController controller = new TagAssignmentController(user.Name);
        controller.tagID = tag.id;
        
        Test.startTest();
        System.assertEquals(false, controller.readOnly, 'Expected readOnly to return false because the user is within the tag\'s scrum team.');
        System.assertEquals('visibility:hidden', controller.matrixInfoMessageWrapperStyle, 'Expected that wrapper style to include visibility hidden for the message since an assignemt rule exists for the tag.');
        Test.stopTest();
    }
    
    /*
      @author ccopek
    */ 
      /* 
      @testcaseID a1DB00000001MV8
      @hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
      @userstory a07B0000000M22Q
      @expectedResults When creating a new Product tag, the following information message appears on page: "Please select one of your team's assignment rules or create a new one to use with this tag" for the user's team
    */
    static testMethod void testInfoMessageVisibleWhenNoAssignmentForTag() {
        User user = createTestUser();
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'GUS Test Product Tag 123';
        tag.Team__c = team.id;
        insert tag;
        
        ADM_Scrum_Team_Member__c teamMembership = new ADM_Scrum_Team_Member__c();
        teamMembership.Scrum_Team__c = team.Id;
        teamMembership.Member_Name_Text__c = user.Name;
        teamMembership.Member_Name__c = user.Id;
        teamMembership.Allocation__c = 100;
        teamMembership.Role__c = 'Product Owner';
        insert teamMembership;
        
        ADM_TagAssignmentComponentController controller = new TagAssignmentController(user.Name);
        controller.tagID = tag.id;
        
        Test.startTest();
        System.assertEquals('', controller.matrixInfoMessageWrapperStyle, 'Expected that wrapper style to NOT include visibility hidden for the message since no assignemt rules exist for the tag.');
        Test.stopTest();
    }
    
    /**
     * Given a user with a configured preference to show the guided tour, the showGuidedTour
     * property should match.
     * @author jared.pearson
     * @testcaseID a1DB00000002IPXMA2
     * @hierarchy GUS.ScrumforceToGUS.Product Tags.Guided Tour
     * @userstory a07B0000000MKesIAG
     * @expectedResults The guided tour should be displayed.
     */
    static testMethod void testShowGuidedTourWithTruePreference() {
        User user1 = createTestUser();
        System.runAs(user1){
            
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowProductTagAssignmentGuidedTour__c = true;
            upsert preferences;
            
            ADM_TagAssignmentComponentController controller = new TagAssignmentController(user1.Name);
            
            System.assertEquals(true, controller.getShowGuidedTour(), 'Expected the showGuidedTour property to match that of the User Preference');
        }
    }
    
    /**
     * Given a user with a configured preference to hide the guided tour, the showGuidedTour
     * property should match.
     * @author jared.pearson
     */
    static testMethod void testShowGuidedTourWithFalsePreference() {
        User user1 = createTestUser();
        System.runAs(user1){
            
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowProductTagAssignmentGuidedTour__c = false;
            upsert preferences;
            
            ADM_TagAssignmentComponentController controller = new TagAssignmentController(user1.Name);
            
            System.assertEquals(false, controller.getShowGuidedTour(), 'Expected the showGuidedTour property to match that of the User Preference');
        }
    }
    
    /**
     * When the never show guided tour method is invoked, the getShowGuidedTour should return false.
     * @author jared.pearson
     * @testcaseID a1DB00000002IPYMA2
     * @hierarchy GUS.ScrumforceToGUS.Product Tags.Guided Tour
     * @userstory a07B0000000MKesIAG
     * @expectedResults The guided tour should not be displayed after the user clicks the "Don't show again".
     */
    static testMethod void testNeverShowGuidedTour() {
        User user1 = createTestUser();
        System.runAs(user1){
            
            //create a user preference to show the tour
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowProductTagAssignmentGuidedTour__c = true;
            upsert preferences;
            
            //call the method to never show the preference
            ADM_TagAssignmentComponentController.neverShowGuidedTour();
            
            //check to make sure the value is false
            ADM_TagAssignmentComponentController controller = new TagAssignmentController(user1.Name);
            System.assertEquals(false, controller.getShowGuidedTour(), 'Expected the neverShowGuidedTour to change the showGuidedTour property to false');
            
            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowProductTagAssignmentGuidedTour__c, 'Expected neverShowGuidedTour to change the User Preference');
        }
    }
        /**
     * @testcaseID a1DB00000002uVw
     * @hierarchy GUS.Product Tags.Delete Product tag
     * @userstory a07B0000000MKesIAG
     * @expectedResults Delete assignment rule
     */
    static testMethod void testDeleteAssignmentRule() {
    	
        User user = createTestUser();
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Scrum_Team_Assignment__c = team.id;
        rule.Assignee_Assignment__c = ADM_WorkUser.createTestUser().id;
        rule.Product_Owner__c = ADM_WorkUser.createTestUser().id;
        insert rule;
        
        Test.startTest();
        ADM_TagAssignmentComponentController.deleteAssignmentRule(rule.Id);
        Test.stopTest();
        
        List<ADM_Assignment_Rule__c> actualRules = [select Id from ADM_Assignment_Rule__c where Id = :rule.Id];
        System.assert(actualRules.isEmpty(), 'Expected the rule to be deleted.');
    }
    
    private static User createTestUser() {
        User u = ADM_WorkUser.createTestUserWithRandomName();
        u = [select Id, Name, Email from User where Id=:u.Id limit 1];
        return u;
    } 

    /**
     * Since we can't guarantee the current user on the testing servers, we 
     * extend the class to provide a way of retrieving the current user's name.
     */
    private class TagAssignmentController extends ADM_TagAssignmentComponentController {
        private String userName;
        
        public TagAssignmentController(String userName) {
            this.userName = userName;
        }
        
        public override String getCurrentUserName() {
            System.debug('overriding getCurrentUserName() to return ' + userName);
            return userName;
        }
    }
}