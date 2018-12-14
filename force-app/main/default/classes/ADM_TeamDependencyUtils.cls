public with sharing class ADM_TeamDependencyUtils {
    public static final Map<String, ADM_FieldWrapper> TEAM_DEPENDENCY_MAP = new Map<String, ADM_FieldWrapper>{'Provider_User_Story__c' => new ADM_FieldWrapper('Provider User Story'), 'Deliver_By__c' => new ADM_FieldWrapper('Needed By Date'), 'Dependency_Status__c' => new ADM_FieldWrapper('Dependency Status'),'Target_Build__c' => new ADM_FieldWrapper('Target Build')};    
    
    public static List<String> getSObjectChange(SObject elOld, SObject elNew, String elFieldName, String elFieldLabel, List<String> changes) {
        String fieldValueOld;
        String fieldValueNew;
        Map<String,String> changeTypes = new Map<String,String>();
        String messageAdded;
        String messageRemoved;
        String messageChanged;
        
        if(elOld != null && elNew != null) {
            fieldValueOld = String.valueOf(elOld.get(elFieldName));
            fieldValueNew = String.valueOf(elNew.get(elFieldName));
            
            
            try{
                Id idOld = fieldValueOld;
                Id idNew = fieldValueNew;
                changeTypes.put('messageAdded', elFieldLabel + ' has been added');
                changeTypes.put('messageRemoved', elFieldLabel + ' has been removed');
                changeTypes.put('messageChanged', elFieldLabel + ' has been changed');
            } catch(System.Exception e) {
                try{
                    fieldValueOld = date.valueOf(fieldValueOld).format();
                } catch(System.Exception ex) {
                    System.debug(ex);
                }
                
                try{
                    fieldValueNew = date.valueOf(fieldValueNew).format();
                } catch(System.Exception ex) {
                    System.debug(ex);
                }   
                
                changeTypes.put('messageAdded',elFieldLabel + ', ' + fieldValueNew + ', added');
                changeTypes.put('messageRemoved',elFieldLabel + ', ' + fieldValueOld + ', removed');
                changeTypes.put('messageChanged',elFieldLabel + ' changed from ' + fieldValueOld + ' to ' + fieldValueNew); 
            }
                
            if(fieldValueNew != fieldValueOld) {
                if(fieldValueNew == null && fieldValueOld != null) {
                    changes.add(changeTypes.get('messageRemoved'));
                } else if(fieldValueNew != null && fieldValueOld == null) {
                    changes.add(changeTypes.get('messageAdded'));
                } else {
                    changes.add(changeTypes.get('messageChanged'));
                }
            }
        }
        return changes;
    }
    public static void asyncSendUserStoryUpdateMessage(Set<Id> workUpdatedSprintOrBuild) {
        List<Set<String>> listOfEmailAddySets = new List<Set<String>>();
        List<String> listOfPlainMessages = new List<String>();
        List<String> listOfHtmlMessages = new List<String>();
        ADM_TextUtils textUtils = new ADM_TextUtils();
        User currentUser = [Select Email,Name from User where id = :UserInfo.getUserId() limit 1];
        
        if(!workUpdatedSprintOrBuild.isEmpty()) {
            ADM_Team_Dependency__c[] effectedTeamDependencies = [
                select id, provider_user_story__c, dependent_team__r.name,dependent_team__r.id, provider_team__r.name,provider_team__r.id, deliverable__c 
                from ADM_Team_Dependency__c 
                where provider_user_story__c in :workUpdatedSprintOrBuild and dependency_status__c not in ('Completed','Deferred','Never')];
            Set<Id> scrumTeamIds = new Set<Id>();
            for(ADM_Team_Dependency__c td:effectedTeamDependencies) {
                scrumTeamIds.add(td.dependent_team__r.id);
                scrumTeamIds.add(td.provider_team__r.id); 
            }
            
            ADM_Scrum_Team_Member__c[] peopleToEmail = [
                select member_name__r.email, scrum_team__c 
                from ADM_Scrum_Team_Member__c 
                where scrum_team__c in :scrumTeamIds and role__c in ('Product Owner', 'Scrum Master', 'Program Manager')];
            
            for (ADM_Team_Dependency__c td : effectedTeamDependencies) {
                Set<String> emailAddySet = new Set<String>();
                for(ADM_Scrum_Team_Member__c stm:peopleToEmail) {
                    if (stm.Scrum_Team__c == td.dependent_team__r.id || stm.scrum_team__c == td.provider_team__r.id)
                        emailAddySet.add(stm.member_name__r.email); 
                }
                listOfEmailAddySets.add(emailAddySet);
                
                String htmlMessage = 'The scheduled sprint or release has changed for the <a href=' + ADM_WorkUtils.GUS_URL + '/'+
                    td.provider_user_story__c+'> user story </a> to satisfy the <a href=' + ADM_WorkUtils.GUS_URL + '/'+
                    td.Id+'> the dependency</a> of the ' + 
                    textUtils.escapeHTML(td.dependent_team__r.name + ' team on the ' + td.provider_team__r.name + ' team to deliver "' + td.deliverable__c) + '".<p>';
                listOfHtmlMessages.add(htmlMessage);
                
                String plainMessage = 'The scheduled sprint or release has changed for this user story (' + ADM_WorkUtils.GUS_URL + '/'+
                    td.provider_user_story__c+') to satisfy this dependency (' + ADM_WorkUtils.GUS_URL + '/'+
                    td.Id+') of the '+td.dependent_team__r.name+' team on the '+ td.provider_team__r.name + 
                    ' team to deliver '+ td.deliverable__c + '.';
                listOfPlainMessages.add(plainMessage);
            }
            
            
            
            
            
            
            
            ADM_WorkEmail.sendSimpleBulkEmailForTeamDependency(currentUser.Email, 'Dependency User Story modified', currentUser.Name,listOfEmailAddySets,listOfPlainMessages,listOfHtmlMessages);
        }
    }

    public static void updateTeamDependenciesBasedOnWorkStatus(Map<String,ADM_Work__c> workIdToObjectMap){
        try {
            List<ADM_Team_Dependency__c> teamDependenciesToUpdate = new List<ADM_Team_Dependency__c>();
            if(workIdToObjectMap != null && !workIdToObjectMap.isEmpty()){
                ADM_Team_Dependency__c[] deps = [select id, dependency_status__c, Provider_User_Story__c from ADM_Team_Dependency__c where provider_user_story__c in :workIdToObjectMap.keySet()];
                System.debug(' found '+deps);
                for(ADM_Team_Dependency__c tdIter: deps){
                    ADM_Work__c workFromMap = workIdToObjectMap.get(tdIter.Provider_User_Story__c);
                    if(workFromMap.Status__c == 'Never'){
                        tdIter.Dependency_Status__c = 'Never';
                    }
                    else if(workFromMap.Closed__c == 1){
                        tdIter.Dependency_Status__c = 'Completed';
                    }
                    else if(workFromMap.Closed__c == 0){
                        tdIter.Dependency_Status__c = 'New';
                    }
                    teamDependenciesToUpdate.add(tdIter);
                }

                if(teamDependenciesToUpdate.size() > 0){
                    update teamDependenciesToUpdate;
                }
            }
        }
        catch(Exception e) {
            System.debug(e);    
        }


    }
    
   public static void closeTeamDependencies(Set<Id> closedUserStories) {
        try {
            if(!closedUserStories.isEmpty()) {
                ADM_Team_Dependency__c[] deps = [select id, dependency_status__c from ADM_Team_Dependency__c where provider_user_story__c in :closedUserStories];
                for(ADM_Team_Dependency__c d:deps) {
                    d.dependency_status__c = 'Completed';   
                }
                update deps;
            }
        } catch(Exception e) {
            System.debug(e);    
        }
    }

    public static void openTeamDependencies(Set<Id> openedUserStories) {
        try {
            if(!openedUserStories.isEmpty()) {
                ADM_Team_Dependency__c[] deps = [select id, dependency_status__c from ADM_Team_Dependency__c where provider_user_story__c in :openedUserStories];
                for(ADM_Team_Dependency__c d:deps) {
                    d.dependency_status__c = 'New'; 
                }
                update deps;
            }
        } catch(Exception e) {
            System.debug(e);    
        }           
    }

}