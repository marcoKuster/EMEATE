@isTest
public with sharing class ADM_ThemeAssignmentTriggerTest {

/*
@testcaseID a1DB00000002jLj
@userstory a07B0000000U7fP
@hierarchy GUS.Multi Themes.Theme Assignment
@Expected results Work and theme are required to create a new theme assignment
*/

    testMethod static void testWorkRequired() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme(ADM_ThemeTriggerTests.TEST_THEME_NAME); 
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = null;
        themeAssignment.Theme__c = theme.Id;
        
        try {
            insert themeAssignment;
            System.assert(false, 'Expected an exception to be thrown about the missing required field.');
        } catch(Exception exc) {
            System.assert(exc.getMessage().contains('Work is a required field.'), 'Expected an exception to be thrown about the missing required field. ' + exc.getMessage());
        }
    }


    testMethod static void testWhenAThemeIsAddedAChatterPostIsCreated() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme(ADM_ThemeTriggerTests.TEST_THEME_NAME); 
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__c = theme.Id;
        insert themeAssignment;
        FeedItem feedItem = [Select id, Body, ParentId from FeedItem where ParentId = : work.Id limit 1];
        String str = 'Theme '+theme.Name+' was added to the work record.';
        System.assert(feedItem != null);
        System.assert(feedItem.Body.containsIgnoreCase(str));     
        str = 'Theme '+theme.Name+' was deleted from the work record.';
        delete themeAssignment;
        List<FeedItem> feedItemList  = [Select id, Body, ParentId from FeedItem where ParentId = : work.Id order by CreatedDate desc];
        System.assertEquals(2, feedItemList.size(),'Expected two feed items to be returned');
        for(FeedItem feedItemRecord : feedItemList){
            if(feedItemRecord.id != feedItem.id ){
                System.assertEquals(str, feedItemRecord.Body, 'Expected the feed item to have the text in its body.');
            }
            
        }
        
    }

/*
@testcaseID a1DB00000004lY6
@userstory a07B0000000U7fP
@hierarchy GUS.Multi Themes.Theme Assignment
@Expected results Work and theme are required to create a new theme assignment
*/
    testMethod static void testThemeRequired() {
        ADM_Work__c work = ADM_Work.createTestWork();
        
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__c = null;
        
        try {
            insert themeAssignment;
            System.assert(false, 'Expected an exception to be thrown about the missing required field.');
        } catch(Exception exc) {
            System.assert(exc.getMessage().contains('Theme is a required field. Please provide a valid, active Theme.'), 'Expected an exception to be thrown about the missing required field. ' + exc.getMessage());
        }
    }
    
    
/*
@testcaseID a1DB00000004oJe
@userstory a07B0000000UFVz
@hierarchy GUS.Multi Themes.Theme Assignment
@Expected results An ACTIVE theme is required to create a new theme assignment
*/
    testMethod static void testActiveThemeRequired() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Theme__c theme = ADM_ThemeUtils.setupTestTheme(ADM_ThemeTriggerTests.TEST_THEME_NAME); 
        theme.active__c = false;
        insert theme;
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__c = null;
        
        try {
            insert themeAssignment;
            System.assert(false, 'Expected an exception to be thrown about the missing required field.');
        } catch(Exception exc) {
            System.assert(exc.getMessage().contains('Theme is a required field. Please provide a valid, active Theme.'), 'Expected an exception to be thrown about the missing required field. ' + exc.getMessage());
        }
    }    
    

/*
@testcaseID a1DB00000002jLo
@userstory a07B0000000U7fP
@hierarchy GUS.Multi Themes.Theme Assignment
@Expected results Work and theme are required to create a new theme assignment
*/
    
    testMethod static void testThemeWorkKey() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme(ADM_ThemeTriggerTests.TEST_THEME_NAME); 
        
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__c = theme.Id;
        insert themeAssignment;
        
        //reload the theme assignment to get the new changes
        themeAssignment = [select Id, Theme_Work_Key__c from ADM_Theme_Assignment__c where Id = :themeAssignment.Id];
        
        System.assertEquals(work.Id + '@' + theme.Id, themeAssignment.Theme_Work_Key__c, 'Expected the Theme Work Key to be a concatenation of work ID and theme ID');
    }
}