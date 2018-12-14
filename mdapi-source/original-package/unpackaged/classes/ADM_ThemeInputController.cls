public with sharing class ADM_ThemeInputController {
    
    public class AddThemeResponse {
        public Boolean success;
        public String[] messages;
        public ADM_Theme__c theme;
    }
    
    private transient List<ADM_Theme__c> themes;
    
    public Id selectedWorkId {
    	get;
    	set;
    }
    
    public List<ADM_Theme__c> getThemes() {
    	if(themes == null) {
    		themes = [select Id, Name, Active__c from ADM_Theme__c where Id in (select Theme__c from ADM_Theme_Assignment__c where Work__c = :selectedWorkId) order by Name limit 1000];
    	}
    	return themes;
    }
    
    public String getThemesAsJson() {
    	return JSON.serialize(getThemes());
    }
    
    @RemoteAction
    public static List<ADM_Theme__c> queryThemes(String term) {
    	String cleanTerm = term.replace('%', '\\%');
    	String cleanTermWildcard = '%' + cleanTerm + '%';
        //first look for exact match.  As a defensive precaution we limit 1 but validaiton rules should have already guarded against duplicates
        List<ADM_Theme__c> results = new List<ADM_Theme__c>();
        results = [select Id, Name, Active__c from ADM_Theme__c where Name =:cleanTerm and Scrum_Team__c = null and Active__c = true limit 1];
        //now add partial matches to results
        results.addAll([select Id, Name, Active__c from ADM_Theme__c where (Name like :cleanTermWildcard and Name != :cleanTerm) and Scrum_Team__c = null and Active__c = true order by Name, Scrum_Team__r.Name limit 50]);
    	return results;
    }

    @RemoteAction
    public static ADM_ThemeInputController.AddThemeResponse addThemeToWork(Id workId, String themeName) {
    	ADM_ThemeInputController.AddThemeResponse response;
    	System.debug('This is the theme name' + themeName);
    	if(!ADM_TextUtils.isBlank(themeName)){
	    	//create a savepoint so that all inserts are rolled back if there is a problem
	    	Savepoint sp = Database.setSavepoint();
	    	
	    	ADM_Theme__c theme = getThemeWithName(themeName);
	    	if(theme == null) {
	    		System.debug(String.format('No theme found for name {0}. Creating one.', new String[]{themeName}));
	    		theme = new ADM_Theme__c();
	    		theme.Name = themeName;
	    		theme.Active__c = true;
	    		insert theme;
	    	}
	    	
	    	if(!theme.Active__c) {
	    		Database.rollback(sp);
	    		return createFailedResponse(String.format('Theme {0} is currently inactive and cannot be selected', new String[]{themeName}));
	    	}
	    	
	    	//check to see if the theme assignment already exists
	    	ADM_Theme_Assignment__c existingThemeAssignment = getThemeAssignment(workId, theme.Id);
	    	if(existingThemeAssignment != null) {
	            response = new ADM_ThemeInputController.AddThemeResponse();
	            response.success = true;
	            response.theme = theme;
	            return response;
	    	}
	    	
	    	//create the theme assignment for the work
	    	ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
	    	themeAssignment.Work__c = workId;
	    	themeAssignment.Theme__c = theme.Id;
	    	insert themeAssignment;
	    	
	    	response = new ADM_ThemeInputController.AddThemeResponse();
	    	response.success = true;
	    	response.theme = theme;
    	}
    	return response;
    }
    
    @RemoteAction
    public static void removeThemeFromWork(Id workId, Id themeId) {
        ADM_Theme_Assignment__c existingThemeAssignment = getThemeAssignment(workId, themeId);
        if(existingThemeAssignment == null) {
        	return;
        }
        
        delete existingThemeAssignment;
    }
    
    /**
     * Gets the public theme with exactly the same name
     */
    private static ADM_Theme__c getThemeWithName(String name) {
        List<ADM_Theme__c> themes = [select Id, Name, Scrum_Team__c, Active__c from ADM_Theme__c where Name = :name and Scrum_Team__c = null limit 1];
        if(themes.isEmpty()) {
        	return null;
        } else {
        	return themes.get(0);
        }
    }
    
    private static ADM_Theme_Assignment__c getThemeAssignment(Id workId, Id themeId) {
        List<ADM_Theme_Assignment__c> existingThemeAssignments = [select Work__c, Theme__c, Theme__r.Id, Theme__r.Name from ADM_Theme_Assignment__c where Work__c = :workId and Theme__c = :themeId];
        if(!existingThemeAssignments.isEmpty()) {
            return existingThemeAssignments.get(0);
        }
        return null;
    }
    
    private static ADM_ThemeInputController.AddThemeResponse createFailedResponse(String message) {
        ADM_ThemeInputController.AddThemeResponse response = new ADM_ThemeInputController.AddThemeResponse();
        response.success = false;
        response.messages = new String[]{message}; 
        return response;
    }
}