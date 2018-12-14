public class ADM_CapexUtility {
    
    public static void removeAllCapexFlagsForOpenItems(List<Id> scrumTeamIds) {

        try {

            List<ADM_Work__c> workList = 
                [SELECT Id, Capex_Enabled__c,Scrum_Team__c FROM ADM_Work__c WHERE Scrum_Team__c in :scrumTeamIds AND Capex_Enabled__c = true AND Closed__c = 0 ];
            
            for ( ADM_Work__c  tempWork : workList ){
                tempWork.Capex_Enabled__c = false;
            }

            Database.update(workList);

        } catch ( Exception e ){

            String noreply_user = 'noreply@salesforce.com';
            String current_user = UserInfo.getUserEmail();
 
            List<String> emailList = new List<String>();
            emailList.add(noreply_user);
            emailList.add(current_user);

            String info = 'There was an exception with updating a work items CapEx flag : Please contact the GUS team\n';
            ADM_WorkEmail.sendSimpleSingleEmail( noreply_user, info, current_user, emailList, info+e.getMessage(), info+e.getMessage());
    
        }
    }
}