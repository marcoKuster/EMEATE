@IsTest
public class ADM_AutoCompleteControllerTest {

    @IsTest
	static void testSearchSuggestionsBuilds() {
        System.currentPageReference().getParameters().put('objectname', 'build');
        ADM_Build__c el = ADM_Build.createTestBuild();
        System.currentPageReference().getParameters().put('aname', el.Name);   
        ADM_Work__c work = ADM_Work.createTestWork();    
        ADM_AutoCompleteController ac = new ADM_AutoCompleteController(new ApexPages.StandardController(work));
        ac.searchSuggestions();
        System.assert(ac.getResultsName() != null);
	} 
   
    @IsTest
	static void testSearchSuggestionsUsers() {
		System.currentPageReference().getParameters().put('objectname', 'User');
        User user = ADM_WorkUser.createTestUser();
        user.LastName = 'O\'Shea';
        update user;
        System.currentPageReference().getParameters().put('aname', user.FirstName);   
        ADM_Work__c work = ADM_Work.createTestWork();    
       	ADM_AutoCompleteController ac = new ADM_AutoCompleteController(new ApexPages.StandardController(work));
        ac.searchSuggestions();
        System.assert(ac.getResultsName() != null);
	} 
   
    @IsTest
    static void testSearchSuggestionsScrum() {
        System.currentPageReference().getParameters().put('objectname', 'Scrum');
        ADM_Scrum_Team__c el = ADM_ScrumTeam.createTestScrumTeam();        
        System.currentPageReference().getParameters().put('aname', el.Name);   
		ADM_Work__c work = ADM_Work.createTestWork();    
       	ADM_AutoCompleteController ac = new ADM_AutoCompleteController(new ApexPages.StandardController(work));
        ac.searchSuggestions();
        System.assert(ac.getResultsName() != null);
   	} 
   
   	@IsTest
	static void testSearchSuggestionsRelease() {
        System.currentPageReference().getParameters().put('objectname', 'release');
        ADM_Release__c el = new ADM_Release__c();
        el.Name = 'Loremipsumdolorsitamet' + String.valueOf(Math.random());
        insert el;
        System.currentPageReference().getParameters().put('aname', el.name);   
        ADM_Work__c work = ADM_Work.createTestWork();    
        ADM_AutoCompleteController ac = new ADM_AutoCompleteController(new ApexPages.StandardController(work));
        ac.searchSuggestions();
        System.assert(ac.getResultsName() != null);
	} 
   
	@IsTest
    static void testSearchSuggestionsTheme() {
        System.currentPageReference().getParameters().put('objectname', 'theme');
        ADM_Theme__c el = new ADM_Theme__c();
        el.Name = 'Loremipsumdolorsitamet' + String.valueOf(Math.random());
        insert el;
        System.currentPageReference().getParameters().put('aname', el.name);   
        ADM_Work__c work = ADM_Work.createTestWork();    
        ADM_AutoCompleteController ac = new ADM_AutoCompleteController(new ApexPages.StandardController(work));
        ac.searchSuggestions();
        System.assert(ac.getResultsName() != null);
	}
   
	@IsTest
    static void testSearchSuggestionsSolutionOveriew() {
        System.currentPageReference().getParameters().put('objectname', 'solution overview');
        ADM_Solution_Overview__c el = new ADM_Solution_Overview__c();
        el.Name = 'Loremipsumdolorsitamet' + String.valueOf(Math.random());
        insert el;
        System.currentPageReference().getParameters().put('aname', el.name);   
        ADM_Work__c work = ADM_Work.createTestWork();    
        ADM_AutoCompleteController ac = new ADM_AutoCompleteController(new ApexPages.StandardController(work));
        ac.searchSuggestions();
        System.assert(ac.getResultsName() != null);
	}
   
    @IsTest
	static void testSearchSuggestionsSprint() {
        System.currentPageReference().getParameters().put('objectname', 'sprint');
        Test.startTest();
            ADM_Sprint__c el = ADM_Sprint.createTestSprint();
        Test.stopTest();
        System.currentPageReference().getParameters().put('aname', el.name);   
        ADM_Work__c work = ADM_Work.createTestWork();    
        ADM_AutoCompleteController ac = new ADM_AutoCompleteController(new ApexPages.StandardController(work));
        
        ac.searchSuggestions();
        
        System.assert(ac.getResultsName() != null);
	}
	 
	@IsTest
    static void testAvoidRefresh() {   
        ADM_Work__c work = ADM_Work.createTestWork();    
        ADM_AutoCompleteController ac = new ADM_AutoCompleteController(new ApexPages.StandardController(work));
        ac.avoidRefresh();    	
    }
    
    @IsTest
    static void testADM_AutoCompleteController() {
        ADM_AutoCompleteController ac = new ADM_AutoCompleteController();
        System.assert(ac != null);
        ADM_Work__c work = ADM_Work.createTestWork();    
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_AutoCompleteController ac2 = new ADM_AutoCompleteController(stdController );
        System.assert(ac2 != null);
        System.assert(ac2.getHasparams() != null);
        System.assert(ac2.getHasnoresults() != null);    
    }   
      

    
    
    
}