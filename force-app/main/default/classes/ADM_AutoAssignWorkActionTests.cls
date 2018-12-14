@isTest
public with sharing class ADM_AutoAssignWorkActionTests {
	
	/**
	 * Given a tag with an assignment,
	 * if a bug is created with an empty assignment and linked to the 
	 * product tag
	 * then the action should set the work properties
	 * @author jared.pearson@
	 */
	/*
	@testcaseID a1DB00000001Wnq
	@hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
	@userstory a07B0000000Lbao
	@Expected results Given a tag with an assignment, if a bug is created with an empty assignment and linked to the product tag then the action should set the work properties
	*/
	public static testMethod void testActionWithBug() {
		//create the product tag
		ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
		
		//create the assignment rule
		ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
		
		//create the work
		ADM_Work__c work1 = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
		work1.Product_Tag__c = productTag.Id;
		work1.Assignee__c = null;
		work1.Tech_Writer__c = null;
		work1.QA_Engineer__c = null;
		work1.UE_Engineer__c = null;
		work1.Scrum_Team__c = null;
		work1.Product_Owner__c = null;
		work1.System_Test_Engineer__c = null;
		work1.Senior_Management_POC__c = null;
		insert work1;
		
		List<ADM_Work__c> works = new List<ADM_Work__c>{work1};
		
		ADM_AutoAssignWorkAction.applyAutoAssignmentRules(works);
		
		System.assertEquals(assignmentRule.Assignee_Assignment__c, work1.Assignee__c);
		System.assertEquals(assignmentRule.Product_Owner__c, work1.Product_Owner__c);
		System.assertEquals(assignmentRule.QA_Assignment__c, work1.QA_Engineer__c);
		System.assertEquals(assignmentRule.UE_Engineer__c, work1.UE_Engineer__c);
		System.assertEquals(assignmentRule.Systest_Assignment__c, work1.System_Test_Engineer__c);
		System.assertEquals(assignmentRule.Scrum_Team_Assignment__c, work1.Scrum_Team__c);
		System.assertEquals(null, work1.Senior_Management_POC__c, 'The senior management field should be null because request manager review is not checked');
	}
	
	/**
	 * Given a tag with an assignment,
	 * if a work record is created with an assignment and linked to the 
	 * product tag
	 * then the action should not replace the existing assignee
	 * @author jared.pearson@
	 */
	/*
	@testcaseID a1DB00000001Wnv
	@hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
	@userstory a07B0000000Lbao
	@Expected results Given a tag with an assignment, if a work record is created with an assignment and linked to the product tag then the action should not replace the existing assignee
	*/
	public static testMethod void testActionShouldNotReplaceExisting() {
		
		//create the product tag
		ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
		
		//create the assignment rule
		ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
		
		//create the work
		User assignee = ADM_WorkUser.createTestUser();
		ADM_Work__c work1 = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
		work1.Assignee__c = assignee.Id;
		work1.Product_Tag__c = productTag.Id;
		insert work1;
		
		List<ADM_Work__c> works = new List<ADM_Work__c>{work1};
		
		ADM_AutoAssignWorkAction.applyAutoAssignmentRules(works);
		
		System.assertEquals(assignee.Id, work1.Assignee__c, 'The assignee should not be replaced');
	}
	
	
	
	
	
	/**
	 * @author jared.pearson@
	 */
	/*
	@testcaseID a1DB00000001Wo1
	@hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
	@userstory a07B0000000Lbao
	@Expected results Tech writer from assignment rule is added to both assignee and tech writer fields on help bugs
	*/
	public static testMethod void testActionOnHelpAssignToTechWriter() {
		
		//create the product tag
		ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
		
		//create the assignment rule
		ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
		
		//create the work
		ADM_Work__c work1 = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
		work1.Assignee__c = null;
		work1.Product_Tag__c = productTag.Id;
		work1.Type__c = 'Help';
		
		List<ADM_Work__c> works = new List<ADM_Work__c>{work1};
		
		ADM_AutoAssignWorkAction.applyAutoAssignmentRules(works);
		
		System.assertEquals(assignmentRule.Tech_Writer_Assignment__c, work1.Assignee__c, 'The assignee should be the tech writer');
		System.assertEquals(assignmentRule.Tech_Writer_Assignment__c, work1.Tech_Writer__c, 'The tech writer should be the tech writer');
	}
	
	/**
	 * @author jared.pearson@
	 */
	/*
	@testcaseID a1DB00000001WoA
	@hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
	@userstory a07B0000000Lbao
	@Expected results When creating a user story, tech writer is automatically added to the user story on create
	*/
	public static testMethod void testActionOnUserStoryAssignToTechWriter() {
		
		//create the product tag
		ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
		
		//create the assignment rule
		ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_USERSTORY;
        insert tagAssignment;
		
		//create the work
		ADM_Work__c work1 = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
		work1.Tech_Writer__c = null;
		work1.Product_Tag__c = productTag.Id;
		
		List<ADM_Work__c> works = new List<ADM_Work__c>{work1};
		
		ADM_AutoAssignWorkAction.applyAutoAssignmentRules(works);
		
		System.assertEquals(assignmentRule.Tech_Writer_Assignment__c, work1.Tech_Writer__c, 'The tech writer in the assignment rule should be applied the tech writer');
	}
	
    /**
     * Given a tag with an assignment,
     * if a bug is created with an empty assignment and linked to the 
     * product tag
     * then the action should set the work properties
     * @author jared.pearson@
     */
	/*
	@testcaseID a1DB00000001WoF
	@hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
	@userstory a07B0000000Lbao
	@Expected results Given a tag with an assignment, if a bug is created with an empty assignment and linked to the  product tag then the action should set the work properties
	*/
    public static testMethod void testGetAssignmentsWithBug() {
        //create the product tag
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        
        //create the assignment rule
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
        
        //create the work
        ADM_Work__c work1 = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        work1.Product_Tag__c = productTag.Id;
        work1.Assignee__c = null;
        work1.Tech_Writer__c = null;
        work1.QA_Engineer__c = null;
        work1.UE_Engineer__c = null;
        work1.Scrum_Team__c = null;
        work1.Product_Owner__c = null;
        work1.System_Test_Engineer__c = null;
        work1.Senior_Management_POC__c = null;
        insert work1;
        
        boolean isInvestigation = false;
        boolean isHelpType = false;
        RecordType recordType = [select id, Name from RecordType where Name =:ADM_Work.BUG_RECORD_TYPE_NAME limit 1];
        
        Test.startTest();
        ADM_AutoAssignWorkAction action = ADM_AutoAssignWorkAction.createActionForTags(new List<ADM_Product_Tag__c>{productTag});
        ADM_AutoAssignWorkAction.Assignment assignment = action.getAssignments(productTag, isInvestigation, isHelpType, work1.Request_RD_Mgr_Review__c, recordType, work1.Severity_Level__c);
        Test.stopTest();
        
        System.assertEquals(assignmentRule.Assignee_Assignment__c, assignment.Assignee.Id, 'Expected Assignee to match assignment rule');
        System.assertEquals(assignmentRule.Product_Owner__c, assignment.Product_Owner.Id, 'Expected Product Owner to match assignment rule');
        System.assertEquals(assignmentRule.QA_Assignment__c, assignment.QA_Engineer.Id, 'Expected QA Engineer to match assignment rule');
        System.assertEquals(assignmentRule.UE_Engineer__c, assignment.UE_Engineer.Id, 'Expected UE Engineer to match assignment rule');
        System.assertEquals(assignmentRule.Systest_Assignment__c, assignment.System_Test_Engineer.Id, 'Expected System Test Engineer to match assignment rule');
        System.assertEquals(null, assignment.Senior_Management_POC, 'The senior management field should be null because request manager review is not checked');
    }
    
	@IsTest
	private static User createOscUser() {
		return ADM_WorkUser.createTestOSCUser();
	}
}