@IsTest
public with sharing class ADM_ThemeInputControllerTest {
    
   /*  
	  @testcaseID a1DB00000002sHyMAI

	  @hierarchy GUS.NextGenWorkPage.MultiThemes

	  @userstory a07B0000000RWBS

	  @expectedResults: The themes should be added successfully to the page 
	  
	  @author sgovindan

	*/ 
    
    static testMethod void testGetThemes() {
        //Create the work
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        
        //Create the themes
        ADM_Theme__c theme1 = new ADM_Theme__c(Name = 'Test Theme 1', Active__c = true);
        ADM_Theme__c theme2 = new ADM_Theme__c(Name = 'Test Theme 2', Active__c = true);
        List<ADM_Theme__c> themes = new List<ADM_Theme__c>{theme1, theme2};
        insert themes;
        
        //Create the theme assignments
        List<ADM_Theme_Assignment__c> themeAssignments = new List<ADM_Theme_Assignment__c>();
        for(ADM_Theme__c theme : themes) {
            ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
            themeAssignment.Work__c = work.Id;
            themeAssignment.Theme__C = theme.Id;
            themeAssignments.add(themeAssignment);
        }
        insert themeAssignments;
        
        ADM_ThemeInputController controller = new ADM_ThemeInputController();
        controller.selectedWorkId = work.Id;
        
        Test.startTest();
        List<ADM_Theme__c> actualThemes = controller.getThemes();
        String themesAsJson = controller.getThemesAsJson();
        Test.stopTest();
        
        System.assertEquals(2, actualThemes.size(), 'Expected both themes associated to the work to be retrieved');
        System.assert(themesAsJson.contains('"Test Theme 1"'), 'Expected JSON version to contain Test Theme 1');
        System.assert(themesAsJson.contains('"Test Theme 2"'), 'Expected JSON version to contain Test Theme 2');
    }
    
    static testMethod void testQueryThemes() {
        //first test with a single theme
        ADM_Theme__c theme = new ADM_Theme__c(Name = 'Trust', Active__c = true);
        insert theme;
        Test.startTest();
        List<ADM_Theme__c> actualThemes = ADM_ThemeInputController.queryThemes('Trust');
        System.assertEquals(1, actualThemes.size(), 'Expected one theme to be found, actually found:' + actualThemes);
        //add a second theme with a similar name
         ADM_Theme__c theme2 = new ADM_Theme__c(Name = 'Apex Trust', Active__c = true);
        insert theme2;
        //first query for exact term. We expect 'Trust' should be sorted before 'Apex Trust' since it is an exact match
        actualThemes = ADM_ThemeInputController.queryThemes('Trust');
        System.assertEquals(2, actualThemes.size(), 'Expected two themes to be found, actually found:' + actualThemes);
        System.assert(actualThemes.get(0).Name == 'Trust');
        System.assert(actualThemes.get(1).Name == 'Apex Trust');
        //now repeat the test with a partial search term that has no exact match
        actualThemes = ADM_ThemeInputController.queryThemes('Tru');
        System.assertEquals(2, actualThemes.size(), 'Expected two themes to be found, actually found:' + actualThemes);
        //since no exact match has been found we expect the list to be sorted alphabetically with Apex Trust, before Trust.
        System.assert(actualThemes.get(0).Name == 'Apex Trust');
        System.assert(actualThemes.get(1).Name == 'Trust');
        Test.stopTest();
    }
    

/*  
	  @testcaseID a1DB00000002sI0MAI

	  @hierarchy GUS.NextGenWorkPage.MultiThemes

	  @userstory a07B0000000RWBS

	  @expectedResults: Scenario should work successfully.
	  
	  @author sgovindan

	*/ 

    static testMethod void testQueryThemesWithPercentCharacter() {
        ADM_Theme__c theme = new ADM_Theme__c(Name = 'Test%Theme 1', Active__c = true);
        insert theme;
        
        Test.startTest();
        List<ADM_Theme__c> actualThemes = ADM_ThemeInputController.queryThemes('Test%Theme 1');
        Test.stopTest();
        
        System.assertEquals(1, actualThemes.size(), 'Expected the theme to be found');
    }
    
	/*  
	  @testcaseID 
	  @hierarchy 
	  @userstory 
	  @expectedResults:
	*/ 

    static testMethod void testGetThemeWithName() {
        ADM_Theme__c theme = new ADM_Theme__c(Name = 'Test Theme 1', Active__c = true);
        insert theme;
        
        Test.startTest();
        List<ADM_Theme__c> actualThemes = ADM_ThemeInputController.queryThemes('Test Theme 1');
        Test.stopTest();
        
        System.assertEquals(1, actualThemes.size(), 'Expected the theme to be found');
    }
    
	/*  
	  @testcaseID 
	  @hierarchy 
	  @userstory 
	  @expectedResults:
	*/ 
    static testMethod void testAddThemeToWork() {
        //Create the work
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        
        //Create the theme
        ADM_Theme__c theme = new ADM_Theme__c(Name = 'Test Theme 1', Active__c = true);
        insert theme;
        
        Test.startTest();
        ADM_ThemeInputController.AddThemeResponse response = ADM_ThemeInputController.addThemeToWork(work.Id, 'Test Theme 1');
        Test.stopTest();
        
        System.assert(response != null, 'addThemeToWork should never return null');
        System.assert(response.success, 'Expected success to be true');
        System.assertEquals(theme.Id, response.theme.Id, 'Expected the theme to be the same');
        
        Integer themeCount = [select count() from ADM_Theme_Assignment__c where Work__c = :work.Id and Theme__c = :theme.Id];
        System.assertEquals(1, themeCount, 'Expected a theme assignment to be created');
    }
    
    /*  
	  @testcaseID a1DB00000002sHyMAI

	  @hierarchy GUS.NextGenWorkPage.MultiThemes

	  @userstory a07B0000000RWBS

	  @expectedResults: The themes should be added successfully to the page 
	  
	  @author sgovindan

	*/ 
    static testMethod void testAddThemeToWorkWithExistingThemeAssignment() {
        //Create the work
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        
        //Create the theme
        ADM_Theme__c theme = new ADM_Theme__c(Name = 'Test Theme 1', Active__c = true);
        insert theme;
        
        //Create the theme assignments
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__C = theme.Id;
        insert themeAssignment;
        
        Test.startTest();
        ADM_ThemeInputController.AddThemeResponse response = ADM_ThemeInputController.addThemeToWork(work.Id, 'Test Theme 1');
        Test.stopTest();
        
        System.assert(response != null, 'addThemeToWork should never return null');
        System.assert(response.success, 'Expected success to be true');
        System.assertEquals(theme.Id, response.theme.Id, 'Expected the theme to be the same');
        
        Integer themeCount = [select count() from ADM_Theme_Assignment__c where Work__c = :work.Id and Theme__c = :theme.Id];
        System.assertEquals(1, themeCount, 'Expected only one theme assignment to be in the database');
    }
    
	/*  
	  @testcaseID 
	  @hierarchy 
	  @userstory 
	  @expectedResults:
	*/ 
    static testMethod void testAddThemeToWorkWithNewTheme() {
    	String themeName = 'Test Theme 2';
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        
        Test.startTest();
        ADM_ThemeInputController.AddThemeResponse response = ADM_ThemeInputController.addThemeToWork(work.Id, themeName);
        Test.stopTest();
        
        System.assert(response != null, 'addThemeToWork should never return null');
        System.assert(response.success, 'Expected success to be true, since the theme should have been created');
        System.assert(response.theme != null, 'Expected the theme to be created');
        System.assert(response.messages == null, 'Expected no error messages to be present');
        
        Integer themeCount = [select count() from ADM_Theme__c where Name = :themeName];
        System.assertEquals(1, themeCount, 'Expected the theme to be created');
        
        Integer themeAssignmentCount = [select count() from ADM_Theme__c where Name = :themeName];
        System.assertEquals(1, themeAssignmentCount, 'Expected the theme assignment to be created');
    }

  /*  
	  @testcaseID a1DB00000002sI0MAI

	  @hierarchy GUS.NextGenWorkPage.MultiThemes

	  @userstory a07B0000000RWBS

	  @expectedResults: Scenario should not work successfully.
	  
	  @author sgovindan

	*/ 
    
    static testMethod void testAddThemeToWorkWithInactiveTheme() {
        //Create the work
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        
        //Create the inactive theme
        ADM_Theme__c theme = new ADM_Theme__c(Name = 'Test Theme 1', Active__c = false);
        insert theme;
        
        Test.startTest();
        ADM_ThemeInputController.AddThemeResponse response = ADM_ThemeInputController.addThemeToWork(work.Id, 'Test Theme 1');
        Test.stopTest();
        
        System.assert(response != null, 'addThemeToWork should never return null');
        System.assert(!response.success, 'Expected success to be false, since the theme is not active');
        System.assert(response.theme == null, 'Expected the theme to be null since the theme is in active');
        System.assert(!response.messages.isEmpty(), 'Expected an error message to be present');
        System.assert(response.messages[0].contains('inactive'), 'Expected an error message to be about the theme being inactive');
        
        Integer themeCount = [select count() from ADM_Theme_Assignment__c where Work__c = :work.Id and Theme__c = :theme.Id];
        System.assertEquals(0, themeCount, 'Expected the theme assignment to not be created');
    }
    

    /*  
	  @testcaseID a1DB00000002sHyMAI

	  @hierarchy GUS.NextGenWorkPage.MultiThemes

	  @userstory a07B0000000RWBS

	  @expectedResults: The themes should be added successfully to the page 
	  
	  @author sgovindan

	*/ 

    static testMethod void testRemoveThemeFromWork() {
        //Create the work
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        
        //Create the theme
        ADM_Theme__c theme = new ADM_Theme__c(Name = 'Test Theme 1', Active__c = true);
        insert theme;
        
        //Create the theme assignments
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = work.Id;
        themeAssignment.Theme__C = theme.Id;
        insert themeAssignment;
        
        Test.startTest();
        ADM_ThemeInputController.removeThemeFromWork(work.Id, theme.Id);
        Test.stopTest();
        
        Integer themeCount = [select count() from ADM_Theme_Assignment__c where Work__c = :work.Id and Theme__c = :theme.Id];
        System.assertEquals(0, themeCount, 'Expected the theme assignment to be removed');
    }
	/*  
	  @testcaseID a1DB00000002sHz
	  @hierarchy GUS.NextGenWorkPage.MultiThemes
	  @userstory a07B0000000RWBS
	  @expectedResults A "Create Theme" option should show up when you are typing the unique name and the user can create the Theme right from that suggestion.
	*/ 
    
    static testMethod void testRemoveThemeFromWorkWhenThemeAssignmentDoesntExist() {
        //Create the work
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        
        //Create the theme
        ADM_Theme__c theme = new ADM_Theme__c(Name = 'Test Theme 1', Active__c = true);
        insert theme;
        
        Test.startTest();
        ADM_ThemeInputController.removeThemeFromWork(work.Id, theme.Id);
        Test.stopTest();
        
        //since the theme doesn't exist already, we expect no exception and for it not to be present after the removal
        Integer themeCount = [select count() from ADM_Theme_Assignment__c where Work__c = :work.Id and Theme__c = :theme.Id];
        System.assertEquals(0, themeCount, 'Expected no theme assignments to exist');
    }
    
	/*  
	  @testcaseID a1DB00000002snT
	  @hierarchy GUS.NextGenWorkPage.MultiThemes
	  @userstory a07B0000000RWBS
	  @expectedResults:blank spaces cannot be added as themes
	*/ 
    /*
    	No Theme should be created if the theme name is blank
    */
    static testMethod void testThemesShouldNotBeCreatedIfThemeNameIsBlank() {
        //Create the work
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        
        Test.startTest();
        ADM_ThemeInputController.AddThemeResponse response = ADM_ThemeInputController.addThemeToWork(work.Id, '');
        Test.stopTest();
        
        System.assert(null == response, 'Expected AddThemResponse to be null when theme name passed is blank');
        
        //since the theme doesn't exist already, we expect no theme assignment witht he work id.
        Integer themeCount = [select count() from ADM_Theme_Assignment__c where Work__c = :work.Id ];
        System.assertEquals(0, themeCount, 'Expected no theme assignments to exist');
    }
}