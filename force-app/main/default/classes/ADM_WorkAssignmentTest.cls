@isTest
public with sharing class ADM_WorkAssignmentTest {

	/*
	testcaseID a1DB00000002tce
	userstory a07B0000000VcF9
	expected results 
	hierarchy GUS.Work.Investigation Process.New Investigation page
	*/
    
    static testMethod void getAssignmentsReturnsEmptyContextForInvestigationWithBlankSeverityAndNullProductTag() { 
	 	RecordType investigationRType = ADM_RecordType.getByName('Investigation', 'ADM_Work__c');
	 	String severityLevel = '';
	    ADM_Product_Tag__c productTag = null;
        ADM_WorkAssignment.AssignmentContext context = ADM_WorkAssignment.getAssignments(severityLevel, productTag, investigationRType, 'Investigation', null);
        
        System.assertEquals(context.errorMessages.size(), 0);
        System.assert(null==context.assignments);
        System.assert(null==context.recipients);
        
    }
    	/*
	testcaseID a1DB00000002tcj
	userstory a07B0000000VcF9
	expected results An error occurs if user tries to save investigation without product tag
	hierarchy GUS.Work.Investigation Process.New Investigation page
	*/
    static testMethod void getAssignmentsReturnsErrorMessageForInvestigationWithNullProductTag() { 
	 	RecordType investigationRType = ADM_RecordType.getByName('Investigation', 'ADM_Work__c');
	 	String severityLevel = '3';
	    ADM_Product_Tag__c productTag = null;
        ADM_WorkAssignment.AssignmentContext context = ADM_WorkAssignment.getAssignments(severityLevel, productTag, investigationRType, 'Investigation', null);
        
        System.assertEquals(context.errorMessages.size(), 1);
        System.assert(context.errorMessages.get(0).contains('product tag'));
    }
    	/*
	testcaseID a1DB00000002td2
	userstory a07B0000000VcF9
	expected results An error occurs when user tries to save investigation without severity
	hierarchy GUS.Work.Investigation Process.New Investigation page
	*/
    static testMethod void getAssignmentsReturnsErrorMessageForInvestigationWithBlankSeverity() { 
	 	RecordType investigationRType = ADM_RecordType.getByName('Investigation', 'ADM_Work__c');
	 	String severityLevel = '';
	    ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        ADM_WorkAssignment.AssignmentContext context = ADM_WorkAssignment.getAssignments(severityLevel, productTag, investigationRType, 'Investigation', null);
        
        System.assertEquals(context.errorMessages.size(), 1);
        System.assert(context.errorMessages.get(0).contains('severity level'));
    }
    
    static testMethod void getAssignmentsTest() { 
    	
    	ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        
        //create the assignment rule
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
        
        
	 	RecordType bugRType = ADM_RecordType.getByName('Bug', 'ADM_Work__c');
	 	String severityLevel = null;
	 	Test.startTest();
        ADM_WorkAssignment.AssignmentContext context = ADM_WorkAssignment.getAssignments(severityLevel, productTag, bugRType, 'Bug', null);
        Test.stopTest();
        System.assert(null != context.assignments);
        System.assert(null != context.assignments.Assignee);
    }
    
}