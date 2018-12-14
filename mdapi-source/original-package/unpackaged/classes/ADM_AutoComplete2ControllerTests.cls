public with sharing class ADM_AutoComplete2ControllerTests {
    
    /*
    @testcaseID a1DB00000001Woe
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete should work for all assignees when selecting a product tag
        @author jared.pearson
     */
    testMethod static void testGetAllUsers() {
        User user1 = ADM_WorkUser.createTestUser();
        user1 = [select Name from User where Id = :user1.Id];
        
        Test.startTest();
        List<User> users = ADM_AutoComplete2Controller.getAllUsers();
        Test.stopTest();
        
        assertContains(users, user1, 'Expected list to contain the test user');
    }
    
    /*
    @testcaseID a1DB00000001Woo
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete for team fires when selecting a product tag
        @author jared.pearson
     */
    testMethod static void testGetAllTeams() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team = [select Name from ADM_Scrum_Team__c where Id = :team.Id];
        
        Test.startTest();
        List<ADM_Scrum_Team__c> teams = ADM_AutoComplete2Controller.getAllTeams();
        Test.stopTest();
        
        assertContains(teams, team, 'Expected list to contain the test team');
    }
    
    /*
    @testcaseID a1DB00000001Wot
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete for a schedule build fires when searching for a specific Schedule Build
        @author jared.pearson
     */
    testMethod static void testSearchSuggestionsBuilds() {
        ADM_Build__c build = ADM_Build.createTestBuild();
        build = [select Name from ADM_Build__c where id = :build.Id];
        //Added a % before the query string, because of change in code. It now removes the first % before quering.
        String text = '%' +build.Name + '%';
        String queryName = 'build';
        Map<String, String> params = new Map<String, String>();
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assert(response.containsResult(build.Name), 'Results should contain the test Build');
    }
   
      /*
    @testcaseID a1DB00000001Woy
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete should fire for all assignees starting with the typed letters when searching for a specific assignee using auto-complete
        @author jared.pearson
     */
    testMethod static void testSearchSuggestionsUsers() {
        User user = ADM_WorkUser.createTestUser();
        user.LastName = 'O\'Shea';
        update user;
        user = [select FirstName, Name from User where Id = :user.Id];
        
        String text = user.FirstName + '%';
        String queryName = 'User';
        Map<String, String> params = new Map<String, String>();
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assert(response.containsResult(user.Name), 'Results should contain the test User');
    }
   
    /*
    @testcaseID a1DB00000001Wp3
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete for a team fires when searching for a specific team
        @author jared.pearson
     */
    testMethod static void testSearchSuggestionsScrum() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team = [select Name from ADM_Scrum_Team__c where Id = :team.Id];
        
        String text = team.Name + '%';
        String queryName = 'Scrum';
        Map<String, String> params = new Map<String, String>();
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assert(response.containsResult(team.Name), 'Results should contain the test Scrum Team');
    }
   
    
   
    /*
    @testcaseID a1DB00000001WpD
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete for schedule build fires when selecting a product tag
        @author jared.pearson
     */
    testMethod static void testSearchSuggestionsRelease() {
        ADM_Release__c el = new ADM_Release__c();
        el.Name = 'Loremipsumdolorsitamet' + String.valueOf(Math.random());
        insert el;
        el = [select Name from ADM_Release__c where Id = :el.Id];
        
        String text = el.Name + '%';
        String queryName = 'release';
        Map<String, String> params = new Map<String, String>();
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assert(response.containsResult(el.Name), 'Results should contain the test Release');
    }
   
    /*
    @testcaseID a1DB00000001WpI
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete for theme fires when searching for a specific theme
        @author jared.pearson
     */
    testMethod static void testSearchSuggestionsTheme() {
        ADM_Theme__c el = new ADM_Theme__c();
        el.Name = 'Loremipsumdolorsitamet' + String.valueOf(Math.random());
        insert el;
        el = [select Name from ADM_Theme__c where Id = :el.Id];
        
        String text = el.Name + '%';
        String queryName = 'theme';
        Map<String, String> params = new Map<String, String>();
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assert(response.containsResult(el.Name), 'Results should contain the test Theme');
    }
   
    /*
    @testcaseID a1DB00000001WpN
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete for solution overview fires when searching for a specific solution overview
        @author jared.pearson
     */
    testMethod static void testSearchSuggestionsSolutionOveriew() {
        ADM_Solution_Overview__c el = new ADM_Solution_Overview__c();
        el.Name = 'Loremipsumdolorsitamet' + String.valueOf(Math.random());
        insert el;
        el = [select Name from ADM_Solution_Overview__c where Id = :el.Id];
        
        String text = el.Name + '%';
        String queryName = 'solution overview';
        Map<String, String> params = new Map<String, String>();
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assert(response.containsResult(el.Name), 'Results should contain the test Solution Overview');
    }
   
    /*
    @testcaseID a1DB00000001WpS
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete for sprint fires when searching for a specific sprint
        @author jared.pearson
     */
    testMethod static void testSearchSuggestionsSprint() {
        ADM_Sprint__c el = ADM_Sprint.createTestSprint();
        el = [select Name from ADM_Sprint__c where Id = :el.Id];
        
        String text = el.Name + '%';
        String queryName = 'sprint';
        Map<String, String> params = new Map<String, String>();
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assert(response.containsResult(el.Name), 'Results should contain the test Sprint');
    }
    
    /*
    @testcaseID a1DB00000001WpX
    @userstoryID a07B0000000Lbbm
    @hierarchy GUS.ScrumforceToGUS.Product Tags.AutoComplete
    @Expected Results Autocomplete for sprint fires when searching for a specific Sprint and starting by team
        @author jared.pearson
     */
    testMethod static void testSearchSuggestionsSprintWithScrumTeam() {
        ADM_Sprint__c el = ADM_Sprint.createTestSprint();
        el = [select Name, Scrum_Team__c from ADM_Sprint__c where Id = :el.Id];
        
        String text = el.Name + '%';
        String queryName = 'sprint';
        Map<String, String> params = new Map<String, String>();
        params.put('scrumteamId', el.Scrum_Team__c);
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assert(response.containsResult(el.Name), 'Results should contain the test Sprint');
    }
    
    /*
       @author jared.pearson
     */
    testMethod static void testADM_AutoComplete2Controller() {
        User user = ADM_WorkUser.createTestUser();
        user.LastName = 'O\'Shea';
        update user;
        user = [select FirstName, Name from User where Id = :user.Id];
        
        String text = user.FirstName + '%';
        String queryName = 'User';
        Map<String, String> params = new Map<String, String>();
        
        ADM_AutoComplete2Controller.SearchResponse response = ADM_AutoComplete2Controller.searchSuggestions(text, queryName, params);
        System.assert(response.getResults() != null, 'response#getResults() should never be null');
        System.assert(response.getResults().size() > 0, 'Results should contain at least one result');
        System.assertEquals(true, response.containsResult(user.Name), 'Results should contain the test User');
        System.assertEquals(false, response.containsResult('Not found'), '#containsResult() should return false for an unknown value');
        System.assertEquals(true, response.getHasResults(), '#getHasResults() should return true because the response contains at least one result');
        System.assert(response.getErrorMessages() != null, 'response#getErrorMessages() should never be null');
        System.assertEquals(0, response.getErrorMessages().size(), 'response#getErrorMessages() should not contain any error messages');
    }

    testMethod static void testUserCacheContainsAppropriateUsers() {

        if(ADM_OrgCacheManager.isCacheEnabled()){

            Long random_key = System.currentTimeMillis();
            String TEST_USER_CACHE_KEY = random_key + 'CachedUserList';
            String TEST_USER_CACHE_KEY_COUNT = random_key + 'CacheKeyCount';
            
            try {
                
                ADM_AutoComplete2Controller.USER_CACHE_KEY = TEST_USER_CACHE_KEY;
                ADM_AutoComplete2Controller.USER_CACHE_KEY_COUNT = TEST_USER_CACHE_KEY_COUNT;
                ADM_AutoComplete2Controller.users = new List<User>();
        
                User activeUser_user = ADM_WorkUser.setupTestUser();
                insert activeUser_user;
        
                User in_activeUser_user = ADM_WorkUser.setupTestInactiveUser();
                insert in_activeUser_user;
        
                Id activeUser_id = activeUser_user.Id;
                Id in_activeUser_id = in_activeUser_user.Id;
                
                Test.startTest();

                // Fill up the cache with the User list
                List<User> users = ADM_AutoComplete2Controller.getAllUsers();
                
                Boolean found_active_id = false;
                Boolean found_inactive_id = false;
                
                Integer cacheKeyCounter =(Integer) ADM_OrgCacheManager.get(TEST_USER_CACHE_KEY_COUNT);
                
                if ( cacheKeyCounter < 1000000000 ) {
                    System.debug('Org cache did not properly set user count. This is likely ' +
                        'due to configuration error. Exiting gracefully');
                    return;
                }

                List<String> userCacheKeysList = new List<String>();
                     
                for(Integer keyCount = 0; keyCount < cacheKeyCounter; keyCount++){
                    List<User> user_list = (List<User>) ADM_OrgCacheManager.get(TEST_USER_CACHE_KEY + keyCount);
                    System.assert( (user_list != null), 'The Org Cache returned no data for: ' + TEST_USER_CACHE_KEY_COUNT + keyCount );           
                    for( User temp_user : user_list ){
                        if ( activeUser_id == temp_user.Id ){
                            found_active_id = true;   
                        }
                        if ( in_activeUser_id == temp_user.Id ){                    
                            found_inactive_id = true;
                        }
                    }     
                }
                
                Test.stopTest();
                
                System.assert( found_active_id, 'An active User with the Id ' + found_active_id + ' was not available in the cache.');
                System.assert( !found_inactive_id, 'An inactive User with the Id ' + found_inactive_id + ' was available in the cache, but should have been missing.');
            
            }  finally {
          
                // Loop through cache and purge out the Key and Count
                Integer cacheKeyCounter =(Integer) ADM_OrgCacheManager.get(TEST_USER_CACHE_KEY_COUNT);
                List<String> userCacheKeysList = new List<String>();
             
                for(Integer keyCount = 0; keyCount < cacheKeyCounter; keyCount++){
                    userCacheKeysList.add(TEST_USER_CACHE_KEY + keyCount);
                    ADM_OrgCacheManager.remove(TEST_USER_CACHE_KEY + keyCount);
                } // for
                         
                ADM_OrgCacheManager.remove(TEST_USER_CACHE_KEY_COUNT);
          
            } // finally

            } else {
                System.debug('Skipping execution of testUserCacheContainsAppropriateUsers since the cache isn\'t available.');
            }

    }


    private static void assertContains(List<User> values, User expected, String message) {
        Boolean contains = false;
        for(User value : values) {
            if(value.Id == expected.Id) {
                contains = true;
                break;
            }
        }
        
        System.assert(contains, message);
    }
    
    private static void assertContains(List<ADM_Scrum_Team__c> values, ADM_Scrum_Team__c expected, String message) {
        Boolean contains = false;
        for(ADM_Scrum_Team__c value : values) {
            if(value.Id == expected.Id) {
                contains = true;
                break;
            }
        }
        
        System.assert(contains, message);
    }
}