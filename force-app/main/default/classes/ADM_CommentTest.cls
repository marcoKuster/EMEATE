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
private class ADM_CommentTest {

    static testMethod void getAll() {
        ADM_Work__c work = ADM_Work.createTestBug();
        work.Description__c = 'test';
        Test.startTest();
        update work;
        Test.stopTest();
        ADM_Comment__c[] comments = ADM_Comment.getAll(work.Id);
        System.assertEquals(1, comments.size());
    }

    static testMethod void getAllUnprocessed() {
        ADM_Work__c work = ADM_Work.createTestBug();
        work.Description__c = 'test';
        work.Preserve_Formatting__c = true;
        Test.startTest();
        update work;
        Test.stopTest();
        ADM_Comment__c[] comments = ADM_Comment.getAllUnprocessed(work.Id);
        ADM_Comment__c comment = comments[0];
        System.assertEquals(false, comment.Body__c.contains('<pre class="pre">'));
        System.assertEquals(1, comments.size());
    }
    
    static testMethod void getAllWithPriorityOverride() {
        ADM_Work__c work = ADM_Work.createTestBug();
        work.Description__c = 'test';
        work.Priority_Override_Explanation__c = 'test';
        Test.startTest();
        update work;
        Test.stopTest();
        ADM_Comment__c[] comments = ADM_Comment.getAll(work.Id);
        System.assertEquals(1, comments.size());
    }
    
    static testMethod void get() {
        ADM_Work__c work = ADM_Work.createTestBug();
        work.Description__c = 'test';
        Test.startTest();
        update work;
        Test.stopTest();
        ADM_Comment__c[] comments = ADM_Comment.getAll(work.Id);
        ADM_Comment__c comment = ADM_Comment.get('Id', comments[0].Id);
        System.assertEquals('test', comment.Body__c);        
    }
    
    static testMethod void save() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	String body = 'test';
    	ADM_Comment.save(work, body);    	
        ADM_Comment__c[] comments = ADM_Comment.getAll(work.Id);
        ADM_Comment__c comment = ADM_Comment.get('Id', comments[0].Id);
        System.assertEquals('test', comment.Body__c);
    }
    
    static testMethod void addPreTags() {
    	ADM_Work__c work = ADM_Work.createTestBug();
    	String body = 'test';
    	ADM_Comment.save(work, body);    	
        ADM_Comment__c comment = ADM_Comment.getAll(work.Id)[0];
        comment.Preserve_Formatting__c = true;
        List<ADM_Comment__c> comments = new List<ADM_Comment__c>{comment};
        comments = ADM_Comment.addPreTags(comments);
        System.assertEquals(true, comments[0].Body__c.contains('<pre class="pre">'));
    }
    
    /*
    @testcaseID a1DB00000000jjo
    @userstoryID a07B0000000EAFaIAO
    @expected results All assignees and other recipients show on detail page, even when their names contain special characters
    @hierarchy GUS.BugforcetoGUS.Work Page.Notifications.Detail Page
    @author: Alexis Williams
    */

    static testMethod void testNoCommentCreatedBy() {
    	Test.startTest();
    	ADM_Work__c work = ADM_Work.createTestBug();
    	work.Description__c = 'test';
        work.Priority_Override_Explanation__c = 'test';
        update work;
    	Test.stopTest();
    	ADM_Comment__c[] comments = ADM_Comment.getAllUnprocessed(work.Id);
        ADM_Comment__c comment = comments[0];
        System.assertEquals(Encodingutil.urlEncode(Userinfo.getName(), 'UTF-8'), comment.Created_By__c);
        comment.Comment_Created_By__c = null;
        update comment;
        comments = ADM_Comment.getAllUnprocessed(work.Id);
        comment = comments[0];
        System.assertEquals(Encodingutil.urlEncode(Userinfo.getName(), 'UTF-8'), comment.Created_By__c);
    }
    /*
    @testcaseID a1DB00000002tZ0
    @userstoryID a07B0000000VfgsIAC
    @expected results Created by fields are populated when comments are created
    @hierarchy GUS.NextGenWorkPage.Comments
    */
    
    static testMethod void testCustomCommentCreatedByFieldsArePopulated() {
    	ADM_Work__c w = ADM_Work.createTestWork('Bug');
    	ADM_Comment__c c = new ADM_Comment__c();
    	c.Body__c = 'test';
    	c.Work__c = w.id;
    	insert c;
    	ADM_Comment__c insertedComment = [select Comment_Created_By__c, Comment_Created_Date__c from ADM_Comment__c where id =:c.id];
    	System.assertEquals(UserInfo.getUserId(), insertedComment.Comment_Created_By__c);
    	//don't want to introduce a flappy test by comparing time stamps so just assert that it was populated
    	System.assert(insertedComment.Comment_Created_Date__c != null);
    	
    }
    /*
    @testcaseID a1DB00000002tZ0
    @userstoryID a07B0000000VfgsIAC
    @expected results Comments are added in both Chatter feed and comments section
    @hierarchy GUS.NextGenWorkPage.Comments
    */
    static testMethod void testCommentsAreTurnedIntoChatterFeedItems() {
    	User u = ADM_WorkUser.createTestUserWithRandomName();
    	List<FeedItem> feedsCreatedFromComment = new List<FeedItem>();
    	System.runAs(u) {
	    	ADM_Work__c w = ADM_Work.createTestWork('Bug');
	    	w.Description__c = 'unit_test_description';
	    	update w;
	    	feedsCreatedFromComment = [select id, body, CreatedById from FeedItem where Parentid =:w.id];
    	}	
    	System.assert(feedsCreatedFromComment.size()>0);
    	System.assert(feedsCreatedFromComment[0].body.contains('unit_test_description'));
    	//verify the creator
    	System.assertEquals(u.id, feedsCreatedFromComment[0].CreatedById);
    }
    /*
    @testcaseID a1DB00000002tZA
    @userstoryID a07B0000000VfgsIAC
    @expected results The comment should also show in chatter feed without any issues.
    @hierarchy GUS.NextGenWorkPage.Comments
    */    
    static testMethod void testChatterFeedWillContainURLToCommentRecordIfCommentLengthGreaterThan4500() {
    	ADM_Work__c w = ADM_Work.createTestWork('Bug');
    	
    	//Creating a string with more than 1000 characters
    	String longString = 'longString'.repeat(501);
    	w.Description__c = longString; 
    	update w;
    	//Getting Comment id to do assertion
    	ADM_Comment__c comment = ADM_Comment.getAll(w.Id)[0];
    	List<FeedItem> feedsCreatedFromComment = [select id, body from FeedItem where Parentid =:w.id];
    	
    	System.assert(feedsCreatedFromComment.size()>0);
    	System.assert(feedsCreatedFromComment[0].body.contains (URL.getSalesforceBaseUrl().toExternalForm() + '/' + comment.id));
    	
    }
    /*
    @testcaseID a1DB00000002tZF
    @userstoryID a07B0000000VfgsIAC
    @expected results Comments added in Chatter feed but not in the comments section
    @hierarchy GUS.NextGenWorkPage.Comments
    */	
    static testMethod void testPostedToChatterIsSetIfCommentExists() {
        ADM_Work__c w = ADM_Work.createTestWork('Bug');
        w.Description__c = 'test comment to check the boooean field is set'; 
        update w;
        //Getting Comment id to do assertion
        ADM_Comment__c comment = ADM_Comment.getAll(w.Id)[0];
        System.assert(null != comment);
        System.assert(comment.Posted_to_Chatter__c);
    }
}