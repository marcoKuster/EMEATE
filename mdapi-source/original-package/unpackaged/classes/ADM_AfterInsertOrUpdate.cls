public class ADM_AfterInsertOrUpdate {

    @future
    public static void updateStatusHistoryTableIfNeeded(Id[] workIds) { 

        List<ADM_Work__c> works = [SELECT Id, Perforce_Status__c, Scrum_Team__c, Scheduled_Build__c, Assignee__c FROM ADM_Work__c WHERE Id IN :workIds ];
        Long startTimer = System.currentTimeMillis();

        ADM_Scrum_Team__c scrumTeam = null;
        
        if ( works.size() < 1 ){
            System.debug('The work item wasnt available. Exiting in : ' +(System.currentTimeMillis()-startTimer ) + ' : milliseconds');
            return;
        }

        Id scrumTeamId = works.get(0).Scrum_Team__c;
 
        if ( scrumTeamId == null ){
            System.debug('The work item didn\'t have a corresponding scrum team exit in : ' +(System.currentTimeMillis()-startTimer ) + ' : milliseconds');
            return;
        }

        List<ADM_Scrum_Team__c> scrum_list = [SELECT Id, Status_Change_Notify__c,Name FROM ADM_Scrum_Team__c WHERE Id=:scrumTeamId];           
        if (  scrum_list.size() > 0 ){
            scrumTeam = scrum_list.get(0);
        } else {
            System.debug('No matching scrum team was found, so exiting in : ' +(System.currentTimeMillis()-startTimer ) + ' : milliseconds');
            return;
        }

        // List set for Status History
        List<ADM_Status_History__c> status_history_list = new List<ADM_Status_History__c>();
        for(Integer i = 0; i < works.size(); i++) {
            
                ADM_Work__c newWork = works[i];
                         
                if ( scrumTeam.Status_Change_Notify__c == true ){        
                    
                    ADM_Status_History__c status_history = new ADM_Status_History__c();
                    status_history.Processed__c = false;
                    status_history.Status__c = 'Source control status changed to :' + newWork.Perforce_Status__c;
                    status_history.Work_ID__c = newWork.Id;
                    status_history.Scheduled_Build__c = newWork.Scheduled_Build__c;
                    status_history.Assignee__c = newWork.Assignee__c;
                    status_history_list.add(status_history);
                    
                } // If status change
            
        } // End for loop

        // Saving entry outside of loop
        if ( status_history_list.size() > 0 ){
            insert status_history_list;
        }

        System.debug('ADM_Status_History_c total insertion time in milliseconds : ' +(System.currentTimeMillis()-startTimer ) + ' :' );
    }
}