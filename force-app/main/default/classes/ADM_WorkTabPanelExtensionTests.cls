@IsTest
public with sharing class ADM_WorkTabPanelExtensionTests {
    
    /*
    testcaseID a1DB00000002tXL
    userstory a07B0000000VfhR
    Expected results Comments added to chatter are not posted as comments on the Comments section
    Hierarchy GUS.NextGenWorkPage.Comments
    */
    public testMethod static void testCommentsPostedToChatterAreNotDisplayed() {
        ADM_Work__c work = ADM_Work.createTestBug();
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_Comment__c comment = new ADM_Comment__c();
        comment.Work__c = work.id;
        comment.Body__c = 'This is a test comment. This is only a test.';
        comment.Posted_to_Chatter__c = true;
        Database.insert(comment);
        ADM_WorkTabPanelExtension ext = new ADM_WorkTabPanelExtension(stdController);
        Test.stopTest();
        ADM_Comment__c[] comments = ADM_Comment.getAllComments(work.Id);
        Boolean areThereOldComments = ext.getOldCommentsTab();

        System.assert(comments.size() > 0, 'Comment was never inserted');
        System.assertEquals(false, areThereOldComments, 'Comment exists, posted via Chatter. Didnt expect false from getOldCommentsTab().');
    }


    /*
    testcaseID a1DB00000002tXQ
    userstory a07B0000000VfhR
    Expected results Comments added to Comments section in classic view are displayed in both chatter feed and comments section
    Hierarchy GUS.NextGenWorkPage.Comments
    */
    public testMethod static void testCommentsNotPostedToChatterAreDisplayed() {
        ADM_Work__c work = ADM_Work.createTestBug();
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_Comment__c comment = new ADM_Comment__c();
        comment.Work__c = work.id;
        comment.Body__c = 'This is a test comment. This is only a test.';
        Database.insert(comment);
        //since comments default to post to chatter we need to go back and tweak the flag to false for this test scenario
        comment.Posted_to_Chatter__c = false;
        Database.update(comment);
        ADM_WorkTabPanelExtension ext = new ADM_WorkTabPanelExtension(stdController);
        Test.stopTest();
        ADM_Comment__c[] comments = ADM_Comment.getAllComments(work.Id);
        Boolean areThereOldComments = ext.getOldCommentsTab();

        System.assert(comments.size() > 0, 'Comment was never inserted');
        System.assertEquals(true, areThereOldComments, 'Comment exists that were not posted to Chatter. We expected getOldCommentsTab() to return true!');
    }


    /*
    testcaseID a1DB00000002y2j
    userstory a07B0000000cren
    Expected results A counter of how many items have been added or removed should show on the tab
    Hierarchy GUS.NextGenWorkPage.Tabs
    */

    public testMethod static void testSetRelatedListRecordCount() {
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTabPanelExtension customController = new ADM_WorkTabPanelExtension(stdController);
        ADM_Theme__c theme1 = new ADM_Theme__c(Name = 'Test Theme 1', Active__c = true);
        insert theme1;
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__C = theme1.Id;
        insert themeAssignment;
        customController.setRelatedListRecordCount(work.id);
        System.assertEquals(customController.getRelatedListRecordCount().get('themes'),1);
    }



    public static testMethod void testGetTabPanelViewPreference() {
    	User user = ADM_WorkUser.createTestUser();
        System.runAs(user){ 
            
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.TabPanelViewPreference__c = true;
            upsert preferences;
            
            ADM_Work__c work = ADM_Work.createTestBug();
			ApexPages.StandardController stdController = new ApexPages.StandardController(work);
			ADM_WorkTabPanelExtension ext = new ADM_WorkTabPanelExtension(stdController);
            
            System.assertEquals(true, ext.getTabPanelViewPreference(), 'Expected the TabPanelViewPreference__c property to match that of the User Preference');
        }
    }
    
    public static testMethod void testSetTabPanelViewPreference() {
    	User user1 = ADM_WorkUser.createTestUser();
        System.runAs(user1){
            
            //create a user preference
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.TabPanelViewPreference__c = true;
            upsert preferences;
            
            //set the preference to false
            ADM_WorkTabPanelExtension.setTabPanelViewPreference(false);
            
            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).TabPanelViewPreference__c, 'Expected setTabPanelViewPreference to change the User Preference');
        }
    }




}