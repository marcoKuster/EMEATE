//has to have global scope to be used inside an MDP page since salesforce wraps MDP actions in iframes
global with sharing class ADM_AutoComplete2Controller {
    @TestVisible
    private static String USER_CACHE_KEY = 'CachedUserList';
    @TestVisible
    private static String USER_CACHE_KEY_COUNT = 'CacheKeyCount';
    @TestVisible
    static List<User> users = new List<User>();
    public ADM_AutoComplete2Controller() {

  }

    public ADM_AutoComplete2Controller(ADM_WorkDialogController stdController) {

  }
    
    /**
     * Gets the names of all the users as a list.
     */
    @RemoteAction
    global static List<User> getAllUsers() {
      if(users != null && users.size() == 0){
        System.debug(' users list is not null');
        boolean expOccured = false;
        try{
          System.debug(' checking cache for key '+ USER_CACHE_KEY_COUNT);
          Integer cacheKeyCounter = (Integer) ADM_OrgCacheManager.get(USER_CACHE_KEY_COUNT);
          Integer keyCounter = 0;
          if(cacheKeyCounter == null){
            System.debug(' Since key  '+ USER_CACHE_KEY_COUNT + ' was not found proceeding to query user record');
            users = (new UserQuery()).setLimit(20000).execute();
            List<User> tempList = new List<User>();

            for(Integer count = 0; count < users.size(); count++){
              tempList.add(users.get(count));
              if(count >= 4000 && math.mod(count, 4000) == 0){
                System.debug(' seems like there are more than 4000 users so creating multiple keys with key prefix '+ USER_CACHE_KEY);
                ADM_OrgCacheManager.putList(USER_CACHE_KEY + keyCounter++, tempList);
                tempList = new List<User>();
              }
            }
            
            if(tempList.size() > 0){
              System.debug(' final user list has '+ tempList.size() + ' users');
              ADM_OrgCacheManager.putList(USER_CACHE_KEY + keyCounter++, tempList);
            }
            System.debug(' no of keys used to store user cache '+ keyCounter);
            //ADM_OrgCacheManager.put(USER_CACHE_KEY_COUNT, keyCounter);
            
            ADM_OrgCacheManager.put(USER_CACHE_KEY_COUNT, keyCounter); //incrementing keycounter as it is 0 index based count will be always +1
           } else {
                System.debug(' Users list exist in Org Cache getting it from there, cacheKeyCounter -> ' + cacheKeyCounter);
                List<String> userCacheKeysList = new List<String>();
                for(Integer keyCount = 0; keyCount <  cacheKeyCounter ; keyCount++){
                    System.debug(' Retrieving '+  USER_CACHE_KEY + keyCount);
                    userCacheKeysList.add(USER_CACHE_KEY + keyCount);
                    System.debug('users list building up size now is ' + users.size());
                    users.addAll((List<User>) ADM_OrgCacheManager.getList(USER_CACHE_KEY + keyCount));
                }
                //users.addAll((List<User>) ADM_OrgCacheManager.getList(userCacheKeysList));
              }  
              System.debug(' No: of users from Cache '+ users.size());
           }
          catch(Cache.CacheException ce){
            System.debug(' CacheException happened while retrieving users '+ ce.getMessage() + ' line number '+ ce.getLineNumber());
            System.debug(ce.getMessage());
            expOccured = true;
            ADM_ExceptionHandler.saveException(ce, 'CacheException happened while retrieving users:' + ce + ' Line:' + ce.getLineNumber());
          }
          catch(Exception exp){
            System.debug(' exception happened while retrieving users '+ exp.getMessage() + ' line number '+ exp.getLineNumber());
            System.debug('Attempting to retrieve users one more time');
            expOccured = true;
            ADM_ExceptionHandler.saveException(exp, 'Exception happened while retrieving users:' + exp + ' Line:' + exp.getLineNumber());
            users = (new UserQuery()).setLimit(20000).execute();
          }
          //We don't want work page to fail because of exception happening in Cache or due to any other failues..so if exception happened
          //check users list is empty and if yes requery to fill it.
          if(expOccured && users != null && users.size() == 0){
              users = (new UserQuery()).setLimit(20000).execute();
          }
      }
      
      return users;
      }
    
    /**
     * Gets the names of all the teams as a list.
     */
    @RemoteAction
    global static List<ADM_Scrum_Team__c> getAllTeams() {
        return (new TeamQuery()).setLimit(10000).execute();
    }
    
  
    @RemoteAction
  global static SearchResponse searchSuggestions(String text, String queryName, Map<String,String> params) {
      SearchResponse response = new SearchResponse();
      String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
    	system.debug(text);
      system.debug(queryName);
        //Limit Suggestions to 10 Results
        Integer iLimit = 10;
        
        if(text.length() > 2) {
            try {
                if(queryName.equalsIgnoreCase('build') || queryName.containsIgnoreCase('ADM_Build__c')) {
                    //Removing the first % to get more accurate results for Build after 200
                    String str = text.substringAfter('%');
                    for(ADM_Build__c build : [select Id, Name from ADM_Build__c where name like :str  limit :iLimit]) {
                        response.addResult(build.Id, build.name);
                    }
                } else if(queryName.equalsIgnoreCase('user')) {
                    for(User user : (new ADM_AutoComplete2Controller.UserQuery()).likeName(text).setLimit(iLimit).execute()) {
                        response.addResult(user.Id, user.name, user.smallPhotoUrl);
                    }
                } else if(queryName.equalsIgnoreCase('scrum') || queryName.containsIgnoreCase('ADM_Scrum_Team__c')) {
                    for(ADM_Scrum_Team__c team : (new TeamQuery()).likeName(text).setLimit(iLimit).execute()) {
                        response.addResult(team.Id, team.name);
                    }
                } else if(queryName.equalsIgnoreCase('epic') || queryName.containsIgnoreCase('ADM_Epic__c')) {
                    for(ADM_Epic__c epic : [select Id, Name from ADM_Epic__c where name like :text limit :iLimit]) {
                        response.addResult(epic.Id, epic.Name);
                    }
                } 
                else if(queryName.equalsIgnoreCase('account') || queryName.containsIgnoreCase('Account__c')) {
                    for(Account acc : [select Id, Name from Account where name like :text limit :iLimit]) {
                        response.addResult(acc.Id, acc.Name);
                    }
                } else if(queryName.equalsIgnoreCase('release') || queryName.containsIgnoreCase('ADM_Release__c')) {
                    for(ADM_Release__c release : [select Id, Name from ADM_Release__c where name like :text limit :iLimit]) {
                        response.addResult(release.Id, release.Name);
                    }
                }  else if(queryName.equalsIgnoreCase('producttag') || queryName.containsIgnoreCase('ADM_Product_Tag__c')) {
                    for(ADM_Product_Tag__c productTag : [select Id, Name, Team__r.Name, Team__r.Id, (select Id, Record_Type__c from Tag_Assignments__r) from ADM_Product_Tag__c where Active__c = true and (name like :text or Team__r.Name like :text) limit :iLimit]) {
                        //response.addProductTagResult(productTag.Id, productTag.Name, productTag.Team__r.Name, productTag.Team__r.Id, productTag.Tag_Assignments__r);
                        response.addProductTagResult(productTag.Id, productTag.Name, productTag.Team__r.Name, productTag.Team__r.Id, null);
                    }
                } else if(queryName.equalsIgnoreCase('theme') || queryName.containsIgnoreCase('ADM_Theme__c')) {
                    for(ADM_Theme__c theme : [select name, Scrum_Team__r.Name from ADM_Theme__c where name like :text limit :iLimit]) {
                      SearchResult searchResult = new SearchResult();
                      searchResult.Id = theme.Id;
                      searchResult.Name = theme.Name + ((theme.Scrum_Team__r != null)? '(' + theme.Scrum_Team__r.Name + ')' : '');
                        response.addResult(searchResult);
                    }
                } else if(queryName.equalsIgnoreCase('solution overview') || queryName.containsIgnoreCase('ADM_Solution_Overview__c')) {
                    for(ADM_Solution_Overview__c solution : [select Id, Name from ADM_Solution_Overview__c where name like :text limit :iLimit]) {
                        response.addResult(solution.Id, solution.Name);
                    }
                } else if(queryName.equalsIgnoreCase('sprint') || queryName.containsIgnoreCase('ADM_Sprint__c')) {
                  for(ADM_Sprint__c sprint : [select Id, Name, Start_Date__c, End_Date__c from ADM_Sprint__c where Name like :text and (End_Date__c >= :System.today() or (Start_Date__c <= :System.today() and End_Date__c >= :System.today())) order by Start_Date__c asc limit :iLimit]) {
                        response.addResult(sprint.Id, sprint.Name);
                    }
                }
            } catch(Exception e) {
                response.addErrorMessage('Unexpected Error while searching.'); 
                System.Debug('Unexpected Error while searching: ' + e);
            }
        }
        return response;
  }
  
  //TODO: Delete this class
    public class SprintComparable implements Comparable {
        public Integer compareTo(Object value) {
            return 0;
        }
    }
    
    /**
     * Represents a query for team instances
     */
    public class TeamQuery {
      private Integer limitValue = 1000;
      private String nameFilter;
      
      public TeamQuery setLimit(Integer value) {
        this.limitValue = value;
        return this;
      }
      
        /**
         * Specifies a filter for the Name property. Wildcard searching with percent (%) is supported.
         */
      public TeamQuery likeName(String nameFilter) {
        this.nameFilter = nameFilter;
        return this;
      }
      
        /**
         * Executes the query with the properties specified and returns the resulting
         * list of teams.
         */
      public List<ADM_Scrum_Team__c> execute() {
        if(ADM_SchemaManager.areFieldsAccessible('ADM_Scrum_Team__c', new Set<String>{'Name'})){
          if(nameFilter != null) {
           return [select name from ADM_Scrum_Team__c where name like :nameFilter and Active__c = true order by Name limit :limitValue];
          } else {
                 return [select name from ADM_Scrum_Team__c where Active__c = true order by Name limit :limitValue];
          }
        }
        else{
          throw new ADM_ApplicationException('User has insufficient access to ' + 'ADM_Scrum_Team__c Object fields');
        }
      }
    }
    
    /**
     * Represents a query for user instances
     */
    public class UserQuery {
      private Integer limitValue = 1000;
      private String nameFilter;
      
      public UserQuery setLimit(Integer value) {
        this.limitValue = value;
        return this;
      }
      
      /**
       * Specifies a filter for the Name property. Wildcard searching with percent (%) is supported.
       */
      public UserQuery likeName(String nameFilter) {
        this.nameFilter = nameFilter;
        return this;
      }
      
      /**
       * Executes the query with the properties specified and returns the resulting
       * list of users.
       */
      public List<User> execute() {
        if(ADM_SchemaManager.areFieldsAccessible('User', new Set<String>{'name','SmallPhotoUrl'})){
          if(nameFilter != null) {
                  return [select name, SmallPhotoUrl from User where name like :nameFilter and IsActive = true order by Name limit :limitValue];
          } else {
                  return [select name, SmallPhotoUrl from User where IsActive = true order by Name limit :limitValue];
          }
        }
        else{
          throw new ADM_ApplicationException('User has insufficient access to ' + 'User Object fields');
        }
      }
    }
    
    /**
     * Response for a search request. Contains the results of the search or
     * any issues that occurred during the search. 
     * @see ADM_AutoCompleteController.searchSuggestions(*)
     */
    global class SearchResponse {
        private List<String> errorMessages = new List<String>();
        private List<SearchResult> results = new List<SearchResult>();
        
        /**
         * Adds an error message
         */
        public void addErrorMessage(String message) {
            
        this.errorMessages.add(message);
      }
      
      /**
       * Gets all of the error messages
       */
      public List<String> getErrorMessages() {
        return this.errorMessages;
      }
      
      /**
       * Determines if the result has any results
       */
      public Boolean getHasResults() {
        return !this.results.isEmpty();
      }
      
      /**
       * Adds a result to the response 
       */
      public void addResult(Id id, String name, String smallPhotoUrl) {
        SearchResult result = new SearchResult();
        result.Id = id;
        result.Name = name;
        result.SmallPhotoUrl = smallPhotoUrl;
        this.addResult(result);
      }

      public void addProductTagResult(Id id, String name, String teamName, Id teamId, List<ADM_Tag_Assignment__c> tagAssignments) {
        SearchResult result = new SearchResult();
        result.Id = id;
        result.Name = name;
        result.TeamName = teamName;
        result.TeamId = teamId;
        result.TagAssignments = tagAssignments;
        this.addResult(result);
      }

      /**
       * Adds a result to the response 
       */
      public void addResult(Id id, String name) {
        SearchResult result = new SearchResult();
        result.Id = id;
        result.Name = name;
        this.addResult(result);
      }
      
      public void addResult(SearchResult result) {
        this.results.add(result);
      }
      
      /**
       * Gets the list of all of the results
       */
      public List<SearchResult> getResults() {
        return results;
      }
      
      /**
       * Determines if the response contains the specified result.
       */
      public Boolean containsResult(String value) {
            for(SearchResult result : results) {
                if(result.Name.equals(value)) {
                    return true;
                }
            }
            return false;
      }
    }
    
    public virtual class SearchResult {
      public Id Id;
      public String Name;
      public String SmallPhotoUrl;
      public String TeamName;
      public String TeamId;
      public List<ADM_Tag_Assignment__c> TagAssignments;
    }
}