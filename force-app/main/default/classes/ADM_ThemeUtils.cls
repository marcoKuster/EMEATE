public with sharing class ADM_ThemeUtils {
    
    /**
     * Gets a list of themes from the given themes that are the "same" as the specified theme.
     * 
     * A theme is the same when one of the following conditions are met:
     *   - the non-null ID values are the same
     *   - the Names are the same
     */
    public static List<ADM_Theme__c> getSameThemes(List<ADM_Theme__c> themes, ADM_Theme__c theme) {
        List<ADM_Theme__c> sameThemes = new List<ADM_Theme__c>();
        
        for(ADM_Theme__c checkTheme : themes) {
            
            //check for same non-null ID values
            if(checkTheme.Id == theme.Id) {
                sameThemes.add(checkTheme);
                continue;
            }
            //check for same name (case-insensitive).
            Boolean sameName = checkTheme.Name.toLowerCase() == theme.Name.toLowerCase();
            Boolean bothActive = (checkTheme.Active__c) && (checkTheme.Active__c == theme.Active__c);
            if(sameName && bothActive) {
                sameThemes.add(checkTheme);
                continue;
            }
        }
        
        return sameThemes;
    }
    
    /**
     * Gets the first theme in the list with the specified team. If no themes match, then a null reference is returned.
     */
    public static ADM_Theme__c getFirstTeamTheme(List<ADM_Theme__c> themes, Id teamId) {
        if(teamId == null) {
            return null;
        }
        
        for(ADM_Theme__c theme : themes) {
            if(theme.Scrum_Team__c == teamId) {
                return theme;
            }
        }
        return null;
    }
    
    /**
     * Gets the first theme in the list that is global. If no themes are global, then a null reference is returned.
     */
    public static ADM_Theme__c getFirstGlobalTheme(List<ADM_Theme__c> themes) {
        for(ADM_Theme__c theme : themes) {
            if(theme.Scrum_Team__c == null) {
                return theme;
            }
        }
        return null;
    }
    
    public static ADM_Theme__c createTestTheme(String name) {
        ADM_Theme__c theme = setupTestTheme(name);
        insert theme;
        return theme;
    }
    
   
    public static ADM_Theme__c setupTestTheme(String name) {
        ADM_Theme__c theme = new ADM_Theme__c(Name=name);
        theme.active__c = true;
        return theme;
    }   

    public static Map<Id, List<ADM_Theme_Assignment__c>> getThemeAssignmentsByWork(List<Id> workIds){
        Map<Id, List<ADM_Theme_Assignment__c>> workIdToThemAssignments = new Map<Id,List<ADM_Theme_Assignment__c>>();
        List<ADM_Theme_Assignment__c> themeAssignments = [SELECT Id, Work__c, Theme__c, Theme__r.Name FROM ADM_Theme_Assignment__c WHERE work__c in :workIds];
        for(ADM_Theme_Assignment__c themeAssignment : themeAssignments){
            if(workIdToThemAssignments.get(themeAssignment.work__c) == null){
                workIdToThemAssignments.put(themeAssignment.work__c, new List<ADM_Theme_Assignment__c>());
            }
            workIdToThemAssignments.get(themeAssignment.work__c).add(themeAssignment);

        }
        return workIdToThemAssignments;
    }
}