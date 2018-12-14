trigger ADM_ThemeTrigger on ADM_Theme__c (before delete, before insert, before update) {
    
    //remove the team for all new themes to make them global
    if(Trigger.isBefore && Trigger.isInsert) {
        for(ADM_Theme__c theme : Trigger.new) {
            theme.Scrum_Team__c = null;
        }
    } 
    
    //make sure that no team themes are modified
    if(Trigger.isBefore && Trigger.isUpdate) {
        Profile userProfile = [select Name from Profile where Id = :UserInfo.getProfileId()];
        if(userProfile.Name != 'System Administrator') {
            for(ADM_Theme__c newTheme : Trigger.new) {
                ADM_Theme__c oldTheme = Trigger.oldMap.get(newTheme.Id);
            
                if(oldTheme.Scrum_Team__c != null || newTheme.Scrum_Team__c != null) {
                   newTheme.addError('Themes owned by a team are deprecated and cannot be created or changed.');
                }
            }
        }
    }
    
    //check to make sure the name is unique
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        
        Map<String, List<ADM_Theme__c>> names = new Map<String, List<ADM_Theme__c>>();
        for(ADM_Theme__c theme : Trigger.new) {
            // Trim any whitespace from the Theme name
            theme.Name = theme.Name.trim();
            // cast all names to lowercase to make search case-insensitive
            String thisKey = theme.Name.toLowerCase();
            //check if the collection contains more than one with the same name
            if(names.containsKey(thisKey)) {
            
                List<ADM_Theme__c> sameThemes = ADM_ThemeUtils.getSameThemes(names.get(thisKey), theme);
                if(!sameThemes.isEmpty()) {
                    
                    String themeLink = 'theme';
                    if(sameThemes.get(0).Id != null) {
                        themeLink = '<a href="/' + sameThemes.get(0).Id + '">theme</a>';
                    }
                    
                    theme.addError('A ' + themeLink + ' with this name already exists. Please specify a different name.');
                    break;
                }
                names.get(thisKey).add(theme);
                
            } else {
                names.put(thisKey, new List<ADM_Theme__c>{theme});
                
            }
        }
        
        //check the database for matching records
        //this search does not account for spacing differences
        // also note that the SOQL 'IN' clause is case-insensitive
        for(ADM_Theme__c matchingTheme : [select Name, Scrum_Team__c, Active__c from ADM_Theme__c where Name in :names.keySet()]) {
            String trimmedMatchingThemeName = matchingTheme.Name.trim().toLowerCase(); 
            if(names.containsKey(trimmedMatchingThemeName)) {
                for(ADM_Theme__c sameTheme : ADM_ThemeUtils.getSameThemes(names.get(trimmedMatchingThemeName), matchingTheme)) {
                    if(matchingTheme.Id == sameTheme.Id) {
                       continue;
                    }
                    sameTheme.addError('A <a href="/' + matchingTheme.Id + '">theme</a> with this name already exists. Please specify a different name.');
                }
            }
        }
    }
    
    //check to see if the theme is associated to any work items
    if(Trigger.isBefore && Trigger.isDelete) {
        String themeOnThemeAssignment = ADM_ConstantsSingleton.getInstance().getNameSpace() + 'Theme__c';
        List<AggregateResult> countResults = [select Theme__c, count(Id) assignmentCount from ADM_Theme_Assignment__c where Theme__c in :Trigger.oldMap.keySet() group by Theme__c limit 1000];
        for(AggregateResult result : countResults) {
            Id themeId = (Id)result.get(themeOnThemeAssignment);
            Integer assignmentCount = (Integer)result.get('assignmentCount');
            if(assignmentCount > 0) {
                Trigger.oldMap.get(themeId).addError('This Theme can\'t be deleted because it is associated to ' + ((assignmentCount >= 1000) ? 'over ' : '') + ((assignmentCount == 1) ? 'a Work record': assignmentCount + ' Work records') + '. The theme will have to be removed from the associated work records, including closed records, for this to be deleted.');
            }
        }
    }
}