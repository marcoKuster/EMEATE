trigger ADM_TeamDependency on ADM_Team_Dependency__c(after insert, after update, before delete) {
    ADM_TextUtils textUtils = new ADM_TextUtils();
    Map<String, ADM_FieldWrapper> teamDependencyFields = ADM_TeamDependencyUtils.TEAM_DEPENDENCY_MAP;
    
    private Messaging.SingleEmailMessage getEmailHeader(String replyTo) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setReplyTo(replyTo);
        mail.setSenderDisplayName('GUS');
        return mail; 
    }
    

    List<ADM_Team_Dependency__c> teamDependencies;
    if(Trigger.isInsert || Trigger.isUpdate) {
        teamDependencies = [select id,Dependency_Status__c,CreatedBy.Name, LastModifiedBy.Name, Deliverable__c,
                                                            Provider_Team__c,Provider_Team__r.name,Provider_User_Story__c,Provider_User_Story__r.Scrum_Team__c, 
                                                            Dependent_Team__c,Dependent_Team__r.name,Dependent_User_Story__r.Scrum_Team__c 
                                                     from ADM_Team_Dependency__c 
                                                     where id in :Trigger.newMap.keySet()];
    } else {
        teamDependencies = [select id,Dependency_Status__c,LastModifiedBy.Name, Deliverable__c,Provider_Team__c,Provider_Team__r.name,Dependent_Team__c,Dependent_Team__r.name
                                                     from ADM_Team_Dependency__c 
                                                     where id in :Trigger.oldMap.keySet()];         
    }


    Set<ID> dependentTeams = new Set<ID>();
    Set<ID> provider_Teams = new Set<ID>();
    for(ADM_Team_Dependency__c aDependency : teamDependencies) {
        dependentTeams.add(aDependency.Dependent_Team__c);
        provider_Teams.add(aDependency.Provider_Team__c);    
    }
 
    // Run various validation checks. Need to do these in Apex since there is a limit of 5 cross-object references.
    if(Trigger.isInsert || Trigger.isUpdate) {
        ADM_Validate_Team_Dependency.validateTeamDependencies(teamDependencies, Trigger.newMap);    
    }
    
    Messaging.SingleEmailMessage[] emailsToSend = new Messaging.SingleEmailMessage[]{};

    // Get the POs and SMs who need to be notified via email of changes to the dependency 
    List <ADM_Scrum_Team_Member__c> teamMembers = [select Scrum_Team__c, member_name__r.email from ADM_Scrum_Team_Member__c 
                                                    where((Scrum_Team__c in :dependentTeams or
                                                    Scrum_Team__c in :provider_Teams) 
                                                    and role__c in('Product Owner', 'Scrum Master', 'Program Manager'))];
    
    

    User currentUser = [Select Email,Name from User where id = :UserInfo.getUserId() limit 1];
    
    Map<ID,Set<String>> teamSendToList = new Map<ID,Set<String>>{};
    for(ADM_Scrum_Team_Member__c aTeamMember : teamMembers) {
        
        
            Set<String> sendToList = teamSendToList.get(aTeamMember.Scrum_Team__c);
            if(sendToList == null) {
                sendToList = new Set<String>();
                teamSendToList.put(aTeamMember.Scrum_Team__c,sendToList); 
            }
            
            sendToList.add(aTeamMember.member_name__r.email);
        
    }


    if(Trigger.isInsert) {     

        for(ADM_Team_Dependency__c aDependency : teamDependencies) {
        
            Set<String> needingWorkEmailList = teamSendToList.get(aDependency.Dependent_Team__c);            
            if(needingWorkEmailList != null) {
                Messaging.SingleEmailMessage mail = getEmailHeader(currentUser.Email);
                mail.setToAddresses(new List<String>(needingWorkEmailList));
                mail.setSubject('New Dependency For Your Team');
                String msg = aDependency.CreatedBy.Name.escapeHtml4() + ' has created a new <a href=' + ADM_WorkUtils.GUS_URL + '/'+aDependency.Id+'> dependency</a> for your team in GUS:<p>';
                msg += textUtils.escapeHTML('The ' + aDependency.Dependent_Team__r.name.escapeHtml4() + ' team needs the ' + aDependency.Provider_Team__r.name.escapeHtml4() + ' team to deliver "' + aDependency.Deliverable__C.escapeHtml4()) + '".<p>';
                 
                if(aDependency.Provider_User_Story__c == null) {
                    msg += 'This dependency is not yet linked to a user story for the work that is needed. ';
                    msg += 'Ask the product owner of the ' +  textUtils.escapeHTML(aDependency.Provider_Team__r.name.escapeHtml4()) + ' team to add a story onto their team\'s backlog and then link to it from the "User Story For Deliverable" field of the dependency record.<p>';
                }
                mail.setHtmlBody(msg);
                emailsToSend.add(mail);
                
            }

            Set<String> doingWorkEmailList = teamSendToList.get(aDependency.Provider_Team__c);            
            if(doingWorkEmailList != null) {
                Messaging.SingleEmailMessage mail = getEmailHeader(currentUser.Email);
                mail.setToAddresses(new List<String>(doingWorkEmailList));
                mail.setSubject('New Dependency On Your Team');
                String msg = aDependency.CreatedBy.Name.escapeHtml4() + ' has created a new <a href=' + ADM_WorkUtils.GUS_URL + '/'+aDependency.Id+'> dependency</a> on your team in GUS:<p>';
                msg += textUtils.escapeHTML('The ' + aDependency.Dependent_Team__r.name.escapeHtml4() + ' team needs the ' + aDependency.Provider_Team__r.name.escapeHtml4() + ' team to deliver "' + aDependency.Deliverable__C.escapeHtml4()) + '".<p>';
                
                if(aDependency.Provider_User_Story__c == null) {
                    msg += 'This dependency is not yet linked to a user story for the work that is needed. ';
                    msg += 'Once this dependency is validated, add a story onto your team\'s backlog for the work to be done and link to it from the "User Story For Deliverable" field of the dependency record. <p>';
                }
                mail.setHtmlBody(msg);  
                emailsToSend.add(mail);
                
            }     
        } 
        
    } else if(Trigger.isUpdate) {
        for(ADM_Team_Dependency__c aDependency : teamDependencies) {
            Set<String> emailList = teamSendToList.get(aDependency.Dependent_Team__c);
            if(emailList == null)           
                emailList = teamSendToList.get(aDependency.Provider_Team__c);   
            else 
                if(teamSendToList.get(aDependency.Provider_Team__c) != null) {
                    emailList.addAll(teamSendToList.get(aDependency.Provider_Team__c));
                }   
            
            if(emailList != null) {
                String msg = aDependency.LastModifiedBy.Name + ' has updated <a href=' + ADM_WorkUtils.GUS_URL + '/'+aDependency.Id+'> the dependency</a>';
                if(aDependency.Dependent_Team__r.name != null) msg += ' of the ' + textUtils.escapeHTML(aDependency.Dependent_Team__r.name) + ' team'; 
                if(aDependency.Provider_Team__r.name != null) msg += ' on the ' + textUtils.escapeHTML(aDependency.Provider_Team__r.name) + ' team';
                if(aDependency.Deliverable__c != null) msg += ' to deliver "' + textUtils.escapeHTML(aDependency.Deliverable__c) + '".';
                
                ADM_Team_Dependency__c oldDep = Trigger.oldMap.get(aDependency.Id);
                ADM_Team_Dependency__c newDep = Trigger.newMap.get(aDependency.Id);
                List<String> changes = new List<String>();
                
                
                for(String fieldName : teamDependencyFields.keySet()) {
                    Sobject elOld, elNew = null;
                    if(oldDep != null) elOld = oldDep;
                    if(newDep != null) elNew = newDep;
                    
                    changes = ADM_TeamDependencyUtils.getSObjectChange(elOld, elNew, fieldName, teamDependencyFields.get(fieldName).fieldLabel, changes);
                }
                
                if(!changes.isEmpty()) {
                    msg += '<p>Changes: <p><ul>';
                    
                    for(String change : changes) {
                        msg += '<li>' + change + '</li>';          
                    }
                    
                    msg+= '<ul/>';
                    
                    Messaging.SingleEmailMessage mail = getEmailHeader(currentUser.Email);
                    mail.setToAddresses(new List<String>(emailList));
                    mail.setSubject('Dependency Updated');
                    mail.setHtmlBody(msg);  
                    emailsToSend.add(mail);
                }
            }
        }  
    } else if(Trigger.isDelete) {
        for(ADM_Team_Dependency__c aDependency : teamDependencies) {
            Set<String> emailList = teamSendToList.get(aDependency.Dependent_Team__c);
            if(emailList == null)           
                emailList = teamSendToList.get(aDependency.Provider_Team__c);   
            else {
                if(teamSendToList.get(aDependency.Provider_Team__c) != null) {
                    emailList.addAll(teamSendToList.get(aDependency.Provider_Team__c));
                }   
            }
            
            if(emailList != null) {
                Messaging.SingleEmailMessage mail = getEmailHeader(currentUser.Email);
                mail.setToAddresses(new List<String>(emailList));
                mail.setSubject('Dependency Deleted');
                String msg = textUtils.escapeHTML(currentUser.Name + ' has deleted the dependency of the ' + aDependency.Dependent_Team__r.name + ' team on the ' + aDependency.Provider_Team__r.name + ' team to deliver "' + aDependency.Deliverable__C) + '".<p>';
                
                mail.setHtmlBody(msg);  
                emailsToSend.add(mail);
            }               
        }
    }
    if(!emailsToSend.isEmpty()) {
        try {
            List<Messaging.SendEmailResult> ser = Messaging.sendEmail(emailsToSend);                
        } catch(EmailException e) {
        }
    }
}