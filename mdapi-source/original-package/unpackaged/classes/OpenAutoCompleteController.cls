public with sharing class OpenAutoCompleteController {     
    public OpenAutoCompleteController() {}
    public OpenAutoCompleteController(ApexPages.StandardController controller) {}
    
    private List<String> resultsname = new List<String>();
    public Boolean currentlySearching = false;
    private Boolean hasnoresults = false;
    private Boolean searchedAgain = false;
    
    /**
     * Check if the auto complete is searching for results. Call this method before trying to 
     * get results, otherwise old or incomplete results may be returned.
     */
    public Boolean getCurrentlySearching() {
        return currentlySearching;     
    }
  
    public void clearValues() {  
        currentlySearching = false;  
    }
    
    /**
     * Check if there are any matches. Note: there may be elements in the results list 
     * even if no matches were found.
     */
    public Boolean getHasNoResults() {
        return hasnoresults;    
    }
    
    /**
     * Check if the user as started to search again. i.e. searchSuggestions was called again.
     */
    public Boolean getHasSearchedAgain() {
        if (searchedAgain) {
            searchedAgain = false;
            return true;
        }
        return searchedAgain;    
    }
 
    public PageReference searchSuggestions() {
        //Initalize variables, hasparams just indicates that a search has started
        resultsname.clear();   
        currentlySearching = true;
        hasnoresults = false;
        searchedAgain = true;
        
        //Obtain current parameters
        String sobjectname = System.currentPageReference().getParameters().get('objectname');
        String stext = System.currentPageReference().getParameters().get('aname')+'%';
        //String scrumteamId = System.currentPageReference().getParameters().get('scrumteamId');
        
        //Limit Suggestions to 10 Results
        Integer iLimit = 10;
        
        //Special condition for when the auto complete is for users
        String userCondition = sobjectname.equals('User') ? 'and IsActive = true ' : '';
        
        //Validate theres an input and get results, new objects will require more else if statments
        //Could possibly replace with dynamic table name but that might lead to injection attacks
        if(stext.length() > 2) {
            try {
                for(SObject x: Database.query('select name from '+ String.escapeSingleQuotes(sobjectname)+' where name like \''+String.escapeSingleQuotes(stext)+'\' '+userCondition+'limit '+iLimit)){
                    resultsname.add((String)x.get('name'));
                }
            }catch(Exception e) {
                resultsname.add('Unexpected Error while attempting autocomplete.'+e); 
            }    
        }
        return null;
    } 
    
    /**
     * Returns the results formatted as a javascript array. 
     * Note: This functionality is incomplete in the component.
     */
    public String getResultsJSString() {
        if (!hasnoresults) {
            String ret = '[';
            for (String r : resultsname) {
                ret+= '\'' + r + '\',';
            }
            ret += ret.subString(0, ret.length()-1);
            
            return ret.length() > 0 ? ret + ']' : '[]';
        }
        return '[]';    
    }
    
    /**
     * Returns the results as a list. The list may contain the string 'No Results' if no matching 
     * elements are found. Use getHasNoResults instead of getResultsname().isEmpty().
     */
    public List<String> getResultsname() {
        //Make sure to clear past values
        //clearValues();
        currentlySearching = false;
        if(resultsname.isEmpty()) {
            hasnoresults = true;
            resultsname.add('No Results');
        }
        
        return resultsname;
    }
}