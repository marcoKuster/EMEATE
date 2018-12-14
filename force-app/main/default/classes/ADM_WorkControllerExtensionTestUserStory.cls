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
private class ADM_WorkControllerExtensionTestUserStory {

	
	/*
	@testcaseID: a1DB00000000t3N
      	@hierarchy: GUS.ScrumforceToGUS.Work Page.User Story.Edit Page
      	@userstory: a07B0000000Eih7IAC
      	@expectedResults: Assignees should not be populated on User Story if the user doesn't select both PA and MFA first.
      	@author Alexis Williams
    */

    static testMethod void testAjaxAssignmentsErrors(){
        ADM_Work__c work = new ADM_Work__c();
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
		String name = String.valueOf(Math.random());
        String assignee;
        String qa;
        String ue;
        
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
				
		rule.Product_Owner__c = Userinfo.getUserId();
		rule.Assignee_Assignment__c = Userinfo.getUserId();
		rule.QA_Assignment__c = Userinfo.getUserId();
		rule.UE_Engineer__c = Userinfo.getUserId();
        
        ext.getAutoAssignedWork();
        
        assignee = ext.getAssignee();
        qa = ext.getQa();
        ue = ext.getUe();
        
        System.assertEquals('', assignee);
        System.assertEquals('', qa);
        System.assertEquals('', ue);
        
        ext.setProductArea(name);
        ext.setMajorFunctionalArea(name);
        
        ext.getAutoAssignedWork();
        
        assignee = ext.getAssignee();
        qa = ext.getQa();
        ue = ext.getUe();
        
        System.assertEquals(ext.getAssignee(), assignee);
        System.assertEquals(ext.getAssignee(), qa);
        System.assertEquals(ext.getAssignee(), ue);
    }
}