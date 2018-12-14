global with sharing class ADM_ReleaseFreezeUtils  extends ADM_DevelopmentCycleUtils implements ADM_DevelopmentCycleInterface {
    
  
    
    Webservice static void updateSingleDevelopmentCycleStatus(Id rfrecord) {
        try {
            List<ADM_Release_Freeze_Status__c> rfrecords = [select id, Build__c, Scrum_Team__c, Team_Release__r.Build__c, Team_Release__r.Scrum_Team__c from ADM_Release_Freeze_Status__c where id =:rfrecord];
            ADM_ReleaseFreezeUtils rfu = new ADM_ReleaseFreezeUtils();
            rfu.processDevelopmentCycleStatus(rfrecords);
            
        } catch (Exception e) {
            
        }
    }
    
    public static void updateReleaseFreezeStatus(List<ADM_Release_Freeze_Status__c> rfrecords) {
        try {
            rfrecords = [select id, Build__c, Scrum_Team__c, Team_Release__r.Build__c, Team_Release__r.Scrum_Team__c from ADM_Release_Freeze_Status__c where id in:rfrecords];
            ADM_ReleaseFreezeUtils rfu = new ADM_ReleaseFreezeUtils();
            rfu.processDevelopmentCycleStatus(rfrecords);
            
        } catch (Exception e) {
            
        }
    }
    
    public void processDevelopmentCycleStatus(List<ADM_Release_Freeze_Status__c> rfrecords) {
        
        
        try {   
            String scheduledBuilds = addSingleQuotesAndWildCardToStringSet(getDistinctStrings(rfrecords, 'Build__c'), 'Scheduled_Build__r.Name');
            String foundBuilds = addSingleQuotesAndWildCardToStringSet(getDistinctStrings(rfrecords, 'Build__c'), 'Found_In_Build__r.Name');
            
            
            
            Set<String> teamNames = getDistinctStrings(rfrecords, 'Scrum_Team__c');
            String teams = addSingleQuotesToStringSet(teamNames); 
            AggregateResult[] memberRoleCountByScrumTeam = getMemberRoleCountsGroupedByScrumTeam(teamNames);
            Map<Id, ADM_Scrum_Team__c> scrumTeamIDs = new Map<Id, ADM_Scrum_Team__c>( [select id, name from ADM_Scrum_Team__c where name in :teamNames]); 
            
        
            //wrap each stat in its own try catch so that if one calc fails the others still fire
            try {
                //count open stories 'Number of Open User Stories'
                rfrecords = countOpenUserStoriesByTeamAndBuild(rfrecords, scheduledBuilds, teams);
            } catch (Exception e) {
                
            }   
            
            try {
                //count blocking bugs 'Number of P0/P1/Blocking Bugs'
                rfrecords = countBlockingBugsByTeamAndBuild(rfrecords, scheduledBuilds, foundBuilds, teams);
            } catch (Exception e) {
                
            }   
            
            try {
                //count unresolved bugs 'Total Number of Bugs to Fix'
                rfrecords = countOpenBugsByTeamAndBuild(rfrecords, scheduledBuilds, foundBuilds, teams, memberRoleCountByScrumTeam, scrumTeamIDs);
            } catch (Exception e) {
                
            }   
            
            try {   
                //count untested bugs 'Total Number of Fixed Bugs to Verify'
                rfrecords = countUntestedBugsByTeamAndBuild(rfrecords, scheduledBuilds, foundBuilds, teams, memberRoleCountByScrumTeam, scrumTeamIDs);
            } catch (Exception e) {
                
            }
            
            try {   
                //count # test failures per dev 'Total Number of TF to Fix'
                rfrecords = countOpenTestFailuresByAllocation(rfrecords, foundBuilds, teams, memberRoleCountByScrumTeam, scrumTeamIDs);
            } catch (Exception e) {
                
            } 
            
            
            Database.update(rfrecords);
            
            
        } catch (Exception e) {
            
        }
        
        
    }
    
    private  List<ADM_Release_Freeze_Status__c> countOpenUserStoriesByTeamAndBuild(List<ADM_Release_Freeze_Status__c> rfrecords, String scheduledBuilds, String teams)   {
        String q = SELECT_CLAUSE + ' where Closed__c = 0 and (' + scheduledBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ') and RecordType.Name = \'User Story\'';
        return countWorkRecordsMatchingCriteria(rfrecords, q, 'Number_Of_Open_User_Stories_0__c');      
    }
    
    private  List<ADM_Release_Freeze_Status__c> countBlockingBugsByTeamAndBuild(List<ADM_Release_Freeze_Status__c> rfrecords, String scheduledBuilds, String foundBuilds, String teams)  {
        String q = SELECT_CLAUSE + ' where Closed__c = 0 and (' + scheduledBuilds + ' ) and ( ' + foundBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and RecordType.Name = \'Bug\' and Type__c IN(\'Bug\', \'Help\') and (Priority__c In (\'P0\', \'P1\') or (Subject__c LIKE \'BLOCKED%\' or Subject__c LIKE \'BLOCKING%\' or Subject__c LIKE \'BLOCKER%\' or Subject__c LIKE \'FEATURE BLOCKING%\' or Subject__c LIKE \'FEATURE BLOCKER%\' or Subject__c LIKE \'RELEASE BLOCKING%\' or Subject__c LIKE \'RELEASE BLOCKER%\')) and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ') and Customer__c NOT IN(' + IGNORED_CUSTOMERS_PARTIAL + ')';
        return countWorkRecordsMatchingCriteria(rfrecords, q, 'Blocking_or_P0_Bugs__c');
    }
    
    private  List<ADM_Release_Freeze_Status__c> countOpenBugsByTeamAndBuild(List<ADM_Release_Freeze_Status__c> rfrecords, String scheduledBuilds, String foundBuilds, String teams, AggregateResult[] memberRoleCountByScrumTeam, Map<Id, ADM_Scrum_Team__c> scrumTeamIDs)   {
        String q = SELECT_CLAUSE + ' where  (' + scheduledBuilds + ' ) and ( ' + foundBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and Type__c = \'Bug\' and Resolved__c = 0 and Customer__c NOT IN(' + IGNORED_CUSTOMERS_COMPLETE + ') and RecordType.Name = \'Bug\' and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ')';
        return countWorkRecordsMatchingCriteriaDividedByRole(rfrecords, q, 'Total_Number_of_Bugs_to_Fix__c', memberRoleCountByScrumTeam, 'Developer', scrumTeamIDs);
    }
    
     private  List<ADM_Release_Freeze_Status__c> countUntestedBugsByTeamAndBuild(List<ADM_Release_Freeze_Status__c> rfrecords, String scheduledBuilds, String foundBuilds, String teams, AggregateResult[] memberRoleCountByScrumTeam, Map<Id, ADM_Scrum_Team__c> scrumTeamIDs)  {
        String q = SELECT_CLAUSE + ' where (' + scheduledBuilds + ' ) and ( ' + foundBuilds + ' )  and Scrum_Team__r.Name in (' + teams + ') and Type__c = \'Bug\' and Resolved__c = 1 and Closed__c = 0 and Customer__c NOT IN(' + IGNORED_CUSTOMERS_COMPLETE + ') and RecordType.Name = \'Bug\' and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ')';
        return countWorkRecordsMatchingCriteriaDividedByRole(rfrecords, q, 'Total_Number_of_Fixed_Bugs_to_Verify__c', memberRoleCountByScrumTeam, 'QA Engineer', scrumTeamIDs);
    }
    
    private  List<ADM_Release_Freeze_Status__c> countOpenTestFailuresByAllocation(List<ADM_Release_Freeze_Status__c> rfrecords, String foundBuilds, String teams, AggregateResult[] memberRoleCountByScrumTeam, Map<Id, ADM_Scrum_Team__c> scrumTeamIDs) {
        String q = SELECT_CLAUSE + ' where ( ' + foundBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and Type__c in (\'Test Failure\', \'Test Change\') and Resolved__c = 0 and Customer__c NOT IN(' + IGNORED_CUSTOMERS_COMPLETE + ') and of_Test_Failures__c > 0 and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ') and RecordType.Name = \'Bug\'';
        return countWorkRecordsMatchingCriteriaDividedByRole(rfrecords, q, 'Total_Number_of_TF_to_Fix__c', memberRoleCountByScrumTeam, 'Developer', scrumTeamIDs);
    }   

}