@isTest
public with sharing class ADM_ThemeTriggerTests {
    private static final String DUPLICATE_NAME_ERROR = 'name already exists. Please specify a different name.';
    private static final String ASSOCIATED_ERROR_FRAGMENT = 'can\'t be deleted because it is associated';
    public static final String TEST_THEME_NAME = 'Test Theme';
/*
@testcaseId a1DB00000002gp6
@userstory a07B0000000T7Dq
@hierarchy GUS.Theme.Create global theme
@expected results An error occurs that global themes cannot be duplicated
*/
    /**
     * Test that a global theme's name must be unique.
     */
    public testMethod static void testGlobalThemeNameMustBeUniqueOnInsert() {
        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'Test Theme';
        insert theme1;
        
        try {
            ADM_Theme__c theme2 = new ADM_Theme__c();
            theme2.Name = theme1.Name;
            insert theme2;
            
            System.assert(false, 'Expected an exception to be thrown since the theme names are the same');
        } catch(DmlException exc) {
            System.assert(exc.getMessage().contains(DUPLICATE_NAME_ERROR), 'Expected an exception to be thrown since the theme name is not unique:' + exc.getMessage());
        }
    }
    
/*
@testcaseId a1DB00000002gpB
@userstory a07B0000000T7Dq
@hierarchy GUS.Theme.Update global theme
@expected results An error occurs that global themes cannot be duplicated
*/
    /**
     * Test that a global theme's name must be unique.
     */
    public testMethod static void testGlobalThemeNameMustBeUniqueOnUpdate() {
        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'Test Theme';
        insert theme1;
        
        ADM_Theme__c theme2 = new ADM_Theme__c();
        theme2.Name = 'Test Theme 2';
        insert theme2;
        
        try {
            theme2.Name = theme1.Name;
            update theme2;
            
            System.assert(false, 'Expected an exception to be thrown since the theme names are the same');
        } catch(DmlException exc) {
            System.assert(exc.getMessage().contains(DUPLICATE_NAME_ERROR), 'Expected an exception to be thrown since the theme name is not unique:' + exc.getMessage());
        }
    }
/*
@testcaseId 
@userstory a07B0000000ce8Y
@hierarchy 
@expected results An error occurs that themes cannot be duplicated that only differ in case
*/
    /**
     * Test that a global theme's name must be unique.
     */
    public testMethod static void testGlobalThemeNameMustBeUniqueOnInsertForDifferentCase() {
        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'Test Theme';
        insert theme1;
        
        try {
            ADM_Theme__c theme2 = new ADM_Theme__c();
            // Use the same name, only differing in case
            theme2.Name = theme1.Name.toLowerCase();
            insert theme2;
            
            System.assert(false, 'Expected an exception to be thrown since the theme names are the same');
        } catch(DmlException exc) {
            System.assert(exc.getMessage().contains(DUPLICATE_NAME_ERROR), 'Expected an exception to be thrown since the theme name is not unique:' + exc.getMessage());
        }
    }
    
/*
@testcaseId 
@userstory a07B0000000ce8Y
@hierarchy 
@expected results An error occurs that themes cannot be duplicated that only differ in case
*/
    /**
     * Test that a global theme's name must be unique.
     */
    public testMethod static void testGlobalThemeNameMustBeUniqueOnUpdateForDifferentCase() {
        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'Test Theme';
        insert theme1;
        
        ADM_Theme__c theme2 = new ADM_Theme__c();
        theme2.Name = 'Test Theme 2';
        insert theme2;
        
        try {
            // Use the same name that only differs in case
            theme2.Name = theme1.Name.toUpperCase();
            update theme2;
            
            System.assert(false, 'Expected an exception to be thrown since the theme names are the same');
        } catch(DmlException exc) {
            System.assert(exc.getMessage().contains(DUPLICATE_NAME_ERROR), 'Expected an exception to be thrown since the theme name is not unique:' + exc.getMessage());
        }
    }
/*
@testcaseId a1DB00000002gpB
@userstory a07B0000000T7Dq
@hierarchy GUS.Theme.Create team theme
@expected results An error occurs that team themes cannot be duplicated
*/
    
    /**
     * Test that a team theme's name must be unique within the team.
     */
    public testMethod static void testTeamThemeNameMustBeUniqueOnInsert() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'Test Theme';
        theme1.Scrum_Team__c = team.Id;
        insert theme1;
        
        try {
            ADM_Theme__c theme2 = new ADM_Theme__c();
            theme2.Name = theme1.Name;
            theme2.Scrum_Team__c = team.Id;
            insert theme2;
            
            System.assert(false, 'Expected an exception to be thrown since the theme names are the same');
        } catch(DmlException exc) {
            System.assert(exc.getMessage().contains(DUPLICATE_NAME_ERROR), 'Expected an exception to be thrown since the theme name is not unique:' + exc.getMessage());
        }
    }
/*
@testcaseId a1DB00000002gpW
@userstory a07B0000000T7Dq
@hierarchy GUS.Theme.Update team theme
@expected results An error occurs that team themes cannot be duplicated
*/
    
    /**
     * Test that a team theme's name must be unique within the team.
     */
    public testMethod static void testTeamThemeNameMustBeUniqueOnUpdate() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'Test Theme';
        theme1.Scrum_Team__c = team.Id;
        insert theme1;
        
        ADM_Theme__c theme2 = new ADM_Theme__c();
        theme2.Name = 'Test Theme 2';
        theme2.Scrum_Team__c = team.Id;
        insert theme2;
        
        try {
            theme2.Name = theme1.Name;
            update theme2;
            
            System.assert(false, 'Expected an exception to be thrown since the theme names are the same');
        } catch(DmlException exc) {
            System.assert(exc.getMessage().contains(DUPLICATE_NAME_ERROR), 'Expected an exception to be thrown since the theme name is not unique:' + exc.getMessage());
        }
    }

/*
@expected results An error occurs that themes cannot be duplicated even when one has no team
*/
    
    /**
     * Test that a team theme's name must be unique.
     */
   
   
    public testMethod static void testTeamThemeNameMustBeUnique() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'Test Theme';
        theme1.Scrum_Team__c = team.Id;
        insert theme1;
        
        theme1.active__c = false;
        update theme1;
        
        ADM_Theme__c theme2 = new ADM_Theme__c();
        theme2.Name = 'Test Theme';
        insert theme2;
         try {
            theme1.active__c = true;
            update theme1;
            System.assert(false, 'Expected an exception to be thrown since the theme names are the same');
        } catch(DmlException exc) {
            System.assert(exc.getMessage().contains(DUPLICATE_NAME_ERROR), 'Expected an exception to be thrown since the theme name is not unique:' + exc.getMessage());
        }
    }




/*
@testcaseId a1DB00000002gpb
@userstory a07B0000000T7Dq
@hierarchy GUS.Theme.Create team theme via a batch insert
@expected results A team theme's name must be unique even during a batch insert.
*/
    
    /**
     * Test that a team theme's name must be unique even during a batch insert.
     */
    public testMethod static void testGlobalThemeNameMustBeUniqueOnBatchInsert() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Theme__c theme1 = new ADM_Theme__c();
        theme1.Name = 'Test Theme';
        
        ADM_Theme__c theme2 = new ADM_Theme__c();
        theme2.Name = theme1.Name;
        
        try {
            insert new List<ADM_Theme__c>{theme1, theme2};
            
            System.assert(false, 'Expected an exception to be thrown since the theme names are the same');
        } catch(DmlException exc) {
            System.assert(exc.getMessage().contains(DUPLICATE_NAME_ERROR), 'Expected an exception to be thrown since the theme name is not unique:' + exc.getMessage());
        }
    }
    
/*
@testcaseId a1DB00000004gUU
@userstory a07B0000000T7Dq
@hierarchy GUS.Theme.Make changes to an existing theme
@expected results When making any changes to an existing theme
*/
    /**
     * Test that a property on a theme can be updated. This is needed so that the unique check doesn't 
     * think its not unique due to the same database entry.
     */
    public testMethod static void testAThemeCanBeUpdated() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Theme__c theme1 = ADM_ThemeUtils.createTestTheme(TEST_THEME_NAME);
        
        User testUser = ADM_WorkUser.createTestUser();
        
        theme1.OwnerId = testUser.Id;
        update theme1;
        
        theme1 = [select OwnerId from ADM_Theme__c where Id = :theme1.Id];
        System.assertEquals(testUser.Id, theme1.OwnerId, 'Expected to be able to change the owner of a theme.');
    }
    
  /*
@testcaseId a1DB00000004lrf
@userstory a07B0000000T7Dq
@hierarchy GUS.Multi Themes.Theme Assignment
@expected results A theme cannot be deleted with work records associated
**/
    public testMethod static void testAThemeCantBeDeleteIfAssigned() {
        
        ADM_Theme__c theme1 = ADM_ThemeUtils.createTestTheme(TEST_THEME_NAME); 
        
        ADM_Work__c work = ADM_Work.createTestBug();
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__c = theme1.Id;
        insert themeAssignment;
        
        try {
            delete theme1;
            System.assert(false, 'Expected the delete to fail because the theme is associated to a work item');
        } catch(Exception exc) {
            System.assert(exc.getMessage().contains(ASSOCIATED_ERROR_FRAGMENT), 'Expected the delete to fail because the theme is associated to a work item: ' + exc.getMessage());
        }
    }

    /**
     * Test that when a new theme is created, the scrum team is removed (to make it global). 
     */
    public testMethod static void testTeamIsRemovedOnThemeCreation() {
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'Test Theme';
        theme.Scrum_Team__c = team.Id;
        insert theme;
        
        theme = [select Scrum_Team__c from ADM_Theme__c where Id = :theme.Id];
        System.assert(theme.Scrum_Team__c == null, 'Expected the scrum team to be blank after creation'); 
    }
    
    /**
     * Test that a person cannot change a theme (unless they are an administrator)
     */
    public testMethod static void testTeamBasedThemeCannotBeModified() {
        User user = ADM_WorkUser.createTestGUSUser();
        if(user != null) {
            System.runAs(user) {
                ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
                
                ADM_Theme__c theme = new ADM_Theme__c();
                theme.Name = 'Test Theme';
                insert theme;
                
                try {
                    
                    theme.Scrum_Team__c = team.Id;
                    update theme;
                    
                    System.assert(false, 'Expected an exception to be thrown because the user should not be able to change team-based themes');
                } catch(Exception exc) {
                    System.assert(exc.getMessage().contains('cannot be created or changed'), 'Expected an exception to be thrown because the user should not be able to change team-based themes. Exception: ' + exc.getMessage());
                }
            }
        }
    }
}