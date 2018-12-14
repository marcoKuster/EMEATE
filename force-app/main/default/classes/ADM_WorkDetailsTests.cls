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
private class ADM_WorkDetailsTests {

	/*
@testcaseID a1DB00000000v8L
@userstory a07B0000000EhafIAC
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Detail Page
@expected results Formatting is preserved on detail page when editing a bug	
@author: Alexis Williams
*/

    static testMethod void getShowComments() {
    	//Looking at current user running tests because that is what the method does
    	//Compare and make sure values are the same!
    	Boolean showComments = [Select Show_All_Work_Comments__c From User Where Id =: UserInfo.getUserId()].Show_All_Work_Comments__c;
        System.assertEquals(showComments,ADM_WorkDetails.getShowComments());        
    }
    
    /*
@testcaseID a1DB00000000v8h
@userstory a07B0000000EhafIAC
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.New Page
@expected results Formatting is preserved on detail page when creating a new bug	
@author: Alexis Williams
*/
    static testMethod void getComments() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	work.Description__c = 'Lorem ipsum dolor sit amet';
    	Test.startTest();
    	update work;
    	Test.stopTest();
    	//Test #1 make sure we have a comment
    	System.assertEquals(1, ADM_WorkDetails.getComments(work.Id).size());
    	//TEst #2 make sure we have no comments with invalid id    	
    	System.assertEquals(0, ADM_WorkDetails.getComments('123').size());
    	System.assertEquals(work.Description__c.replaceAll(' ','+'), ADM_WorkDetails.getComments(work.Id).get(0).Body__c);    	
    }
/*
@testcaseID a1DB00000000v96
@userstory a07B0000000EhafIAC
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Detail Page
@expected results Formatting is preserved on detail page when editing a bug and email address mail to link is created
@author: Alexis Williams
*/    
    static testMethod void getOtherRecipients() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	List<ADM_Work_Subscriber__c> subs = new List<ADM_Work_Subscriber__c>();    	
        ADM_Work_Subscriber__c ws = new ADM_Work_Subscriber__c();
        ws.WorkId__c = work.id;
        ws.UserId__c = UserInfo.getUserId();        
        ADM_Work_Subscriber__c ws1 = new ADM_Work_Subscriber__c();
        ws1.WorkId__c = work.id;
        ws1.Distribution_List__c = 'loremipsum@salesforce.com';
        subs.add(ws);
        subs.add(ws1);
        insert subs;        
        
    	System.assertEquals(UserInfo.getName() + ', ' + ws1.Distribution_List__c, ADM_WorkDetails.getOtherRecipients(work.Id));
    	System.assertNotEquals(UserInfo.getName(), ADM_WorkDetails.getOtherRecipients('123'));    	    	
    }
   
    static testMethod void getStandardRecipients() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	work.Assignee__c = UserInfo.getUserId();
    	work.Request_RD_Mgr_Review__c = true;
    	work.Senior_Management_POC__c = Userinfo.getUserId();
    	Test.startTest();
    	update work;
    	Test.stopTest();
    	System.assertEquals(true, ADM_WorkDetails.getStandardRecipients(work.Id).contains(UserInfo.getName()));
    	System.assertEquals(false, ADM_WorkDetails.getStandardRecipients('123').contains(UserInfo.getName()));
    }
 /*
@testcaseID a1DB00000000v8i
@userstory a07B0000000EhafIAC
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Edit Page
@expected results Formatting is preserved on edit page on existing comments
@author: Alexis Williams
*/   
    static testMethod void testClassConstructor() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
    	ADM_WorkDetails wd = new ADM_WorkDetails(controller);
    	System.assertEquals(true, wd.isEdit);
    	wd.isEdit = false;
    	System.assertNotEquals(true, wd.isEdit);
    	wd.isNew = true;
    	System.assertEquals(true, wd.isNew);
    	wd.isNew = false;
    	System.assertEquals(false, wd.isNew);
    	System.assertEquals(null, wd.recordTypeName);
    	wd.recordTypeName = 'Bug';
    	System.assertEquals('Bug', wd.recordTypeName);
    }
   /*
@testcaseID a1DB00000000sh8
@userstory a07B0000000EhafIAC
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Edit Page
@expected results Comment help reads: When you click the Save button, your comment will be added to the Work record and included in an email to the names listed in the Email Notifications section
@author: Alexis Williams
*/ 
    static testMethod void testHelpTextWhenEditing() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
    	ADM_WorkDetails wd = new ADM_WorkDetails(controller);
    	System.assertEquals('Comments will be added to the Work record and included in an email to the names listed in the Email Notifications section after saving.', wd.helpText);
    }
   /*
@testcaseID a1DB00000000shM
@userstory a07B0000000EhafIAC
@hierarchy GUS.ScrumforceToGUS.Work Page.User Story.Detail page
@expected results Comment help reads: To add a Comment, use inline editing, or click the Edit button. When you click the Save button, your comment will be added to the Work record and in included in an email to the names listed in the Email Notifications section.
@author: Alexis Williams
*/ 
    static testMethod void testHelpTextWhenNotEditing() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
    	ADM_WorkDetails wd = new ADM_WorkDetails(controller);
    	wd.isEdit = false;
    	System.assertEquals('Comments will be added to the Work record and included in an email to the names listed in the Email Notifications section after saving. Formatting will also be preserved when saving via in line edit.', wd.helpText);
    }
    
    static testMethod void testContainsOriginalChatterContentReturnsFalseWhenChatterContentDoesNotExist() {
    	//create a work record 
    	ADM_Work__c bug = ADM_Work.createTestWork('Bug');
    	ApexPages.StandardController controller = new ApexPages.StandardController(bug);
    	ADM_WorkDetails wd = new ADM_WorkDetails(controller);
    	//work set via component attribute vs std controller so for maximum realism we do the same here
    	wd.work = bug;
    	//verify the controller finds no chatter content
    	System.assertEquals(false, wd.containsOriginalChatterContent);
    } 
    
    static testMethod void testContainsOriginalChatterReturnsTrueContentWhenChatterContentDoesExist() {
    	//create a work record 
    	ADM_Work__c bug = ADM_Work.createTestWork('Bug');
    	ApexPages.StandardController controller = new ApexPages.StandardController(bug);
    	ADM_WorkDetails wd = new ADM_WorkDetails(controller);
    	//work set via component attribute vs std controller so for maximum realism we do the same here
    	wd.work = bug;
    	//now add chatter content
    	FeedItem post = new FeedItem();
		post.ParentId = bug.Id;
		post.Body = 'Test Chatter Post';
		insert post;
		//check that is was inserted 
		System.assert(post.id != null);
		Integer chatterItemCount = [select count() from FeedItem where ParentId =:bug.id and Type != 'TrackedChange'];
		//should be at least one chatter post that is not a tracked change
		System.assert(chatterItemCount >= 1);
		System.debug('about to check for chatter:');
		System.assertEquals(true, wd.containsOriginalChatterContent);
    } 
}