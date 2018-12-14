global with sharing class ADM_FeatureFreezeUtils extends ADM_DevelopmentCycleUtils implements ADM_DevelopmentCycleInterface { 
    
    
    
    public static void updateFeatureFreezeStatus(ADM_Work__c[] newWork, ADM_Work__c[] oldWork, Boolean isUpdate) {
        Set<Id> buildIDs = new Set<Id>();
        Set<Id> teamIDs = new Set<Id>();
        
        for(Integer i = 0; i < newWork.size(); i++) {
            
            //If the team has been added, removed or unchanged any feature freeze status records still need to be updated
            if(newWork[i].Scheduled_Build__c != null) buildIDs.add(newWork[i].Scheduled_Build__c);
            if(newWork[i].Found_In_Build__c != null) buildIDs.add(newWork[i].Found_In_Build__c);
            if(newWork[i].Scrum_Team__c != null) teamIDs.add(newWork[i].Scrum_Team__c);
            
            if(isUpdate) {
                if(oldWork[i].Scheduled_Build__c != null) buildIDs.add(oldWork[i].Scheduled_Build__c);
                if(oldWork[i].Found_In_Build__c != null) buildIDs.add(oldWork[i].Found_In_Build__c);
                if(oldWork[i].Scrum_Team__c != null) teamIDs.add(oldWork[i].Scrum_Team__c);
            }
        }
        
        updateFeatureFreezeStatusAsync(teamIDs, buildIDs);
        
    } 
    
    @future
    private static void updateFeatureFreezeStatusAsync(Set<Id> teamIDs, Set<Id> buildIDs) {
        try {
            List<ADM_Feature_Freeze_Status__c>  ffrecords = [select id, Build__c, Scrum_Team__c, Team_Release__r.Build__c, Team_Release__r.Scrum_Team__c 
                                                            from ADM_Feature_Freeze_Status__c where Team_Release__r.Build__c in:buildIDs 
                                                            or Team_Release__r.Scrum_Team__c in :teamIDs];
            ADM_FeatureFreezeUtils ffu = new ADM_FeatureFreezeUtils();
            ffu.processDevelopmentCycleStatus(ffrecords);
        } catch (Exception e) {
            System.debug('Unexpected exception building teams and builds:' + e + ' Line:' + e.getLineNumber());
        }       
        
    }
    
    Webservice static void updateSingleDevelopmentCycleStatus(Id ffrecord) {
        try {
            List<ADM_Feature_Freeze_Status__c> ffrecords = [select id, Build__c, Scrum_Team__c, Team_Release__r.Build__c, Team_Release__r.Scrum_Team__c from ADM_Feature_Freeze_Status__c where id =:ffrecord];
            ADM_FeatureFreezeUtils ffu = new ADM_FeatureFreezeUtils();
            ffu.processDevelopmentCycleStatus(ffrecords);
            
        } catch (Exception e) {
            System.debug('Unexpected exception totaling ff counts:' + e + ' Line:' + e.getLineNumber());
        }
    }
    
    public static void updateFeatureFreezeStatus(List<ADM_Feature_Freeze_Status__c> ffrecords) {
        try {
            ffrecords = [select id, Build__c, Scrum_Team__c, Team_Release__r.Build__c, Team_Release__r.Scrum_Team__c from ADM_Feature_Freeze_Status__c where id in:ffrecords];
            ADM_FeatureFreezeUtils ffu = new ADM_FeatureFreezeUtils();
            ffu.processDevelopmentCycleStatus(ffrecords);
            
        } catch (Exception e) {
            System.debug('Unexpected exception totaling ff counts:' + e + ' Line:' + e.getLineNumber());
        }
    }
    
    public void processDevelopmentCycleStatus(List<ADM_Feature_Freeze_Status__c> ffrecords) {
        
        
        try {   
            String scheduledBuilds = addSingleQuotesAndWildCardToStringSet(getDistinctStrings(ffrecords, 'Build__c'), 'Scheduled_Build__r.Name');
            String foundBuilds = addSingleQuotesAndWildCardToStringSet(getDistinctStrings(ffrecords, 'Build__c'), 'Found_In_Build__r.Name');
            
            Set<String> teamNames = getDistinctStrings(ffrecords, 'Scrum_Team__c');
            String teams = addSingleQuotesToStringSet(teamNames); 
            AggregateResult[] memberRoleCountByScrumTeam = getMemberRoleCountsGroupedByScrumTeam(teamNames);
            Map<Id, ADM_Scrum_Team__c> scrumTeamIDs = new Map<Id, ADM_Scrum_Team__c>( [select id, name from ADM_Scrum_Team__c where name in :teamNames]); 
            
        
            //wrap each stat in its own try catch so that if one calc fails the others still fire
            try {
                //count open stories. field label: 'Number of Open User Stories '
                ffrecords = countOpenUserStoriesByTeamAndBuild(ffrecords, scheduledBuilds, teams);
            } catch (Exception e) {
                System.debug('Unexpected exception counting open stories:' + e + ' Line:' + e.getLineNumber());
            }   
            
            try {
                //count blocking bugs. Field label: 'Number of P0/Blocking Bugs'
                ffrecords = countBlockingBugsByTeamAndBuild(ffrecords, scheduledBuilds, foundBuilds, teams);
            } catch (Exception e) {
                System.debug('Unexpected exception counting blocking bugs:' + e + ' Line:' + e.getLineNumber());
            }   
            
            try {
                //field label 'Number of Bugs to Fix (max 1/Dev)'
                ffrecords = countOpenBugsByTeamAndBuild(ffrecords, scheduledBuilds, foundBuilds, teams, memberRoleCountByScrumTeam, scrumTeamIDs);
            } catch (Exception e) {
                System.debug('Unexpected exception counting open bugs:' + e + ' Line:' + e.getLineNumber());
            }   
            
            try {   
                //count untested bugs field label 'Number of Bugs to Verify'
                ffrecords = countUntestedBugsByTeamAndBuild(ffrecords, scheduledBuilds, foundBuilds, teams, memberRoleCountByScrumTeam, scrumTeamIDs);
            } catch (Exception e) {
                System.debug('Unexpected exception counting untested bugs:' + e + ' Line:' + e.getLineNumber());
            }
            
            try {   
                //count test failures older then 7 days. Field label 'Number of TF to Fix >1week'
                ffrecords = countOpenTestFailures(ffrecords, 7, foundBuilds, teams);
            } catch (Exception e) {
                System.debug('Unexpected exception counting test failures:' + e + ' Line:' + e.getLineNumber());
            }
            
            try {   
                //count # test failures per dev. Field label: 'Number of TF to Fix (max 1/Dev)'
                ffrecords = countOpenTestFailuresByAllocation(ffrecords, foundBuilds, teams, memberRoleCountByScrumTeam, scrumTeamIDs);
            } catch (Exception e) {
                System.debug('Unexpected exception counting test failures by allocation:' + e + ' Line:' + e.getLineNumber());
            } 
            
            
            Database.update(ffrecords);
            
            
        } catch (Exception e) {
            System.debug('Unexpected exception processing ff counts:' + e + ' Line:' + e.getLineNumber());
        }
        
        
    }
    
    private  List<ADM_Feature_Freeze_Status__c> countOpenUserStoriesByTeamAndBuild(List<ADM_Feature_Freeze_Status__c> ffrecords, String scheduledBuilds, String teams)   {
        String q = SELECT_CLAUSE + ' where Closed__c = 0 and Theme__c NOT IN (select id from ADM_Theme__c where Name LIKE \'%Release Sprint%\') and (' + scheduledBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and RecordType.Name = \'User Story\'';
        return countWorkRecordsMatchingCriteria(ffrecords, q, 'Number_Of_Open_User_Stories_0__c');      
    }
    
    private  List<ADM_Feature_Freeze_Status__c> countBlockingBugsByTeamAndBuild(List<ADM_Feature_Freeze_Status__c> ffrecords, String scheduledBuilds, String foundBuilds, String teams)  {
        String q = SELECT_CLAUSE + ' where Closed__c = 0 and (' + scheduledBuilds + ' ) and ( ' + foundBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and RecordType.Name = \'Bug\' and Type__c IN(\'Bug\', \'Help\') and (Priority__c = \'P0\' or (Subject__c LIKE \'BLOCKED%\' or Subject__c LIKE \'BLOCKING%\' or Subject__c LIKE \'BLOCKER%\' or Subject__c LIKE \'FEATURE BLOCKING%\' or Subject__c LIKE \'FEATURE BLOCKER%\' or Subject__c LIKE \'RELEASE BLOCKING%\' or Subject__c LIKE \'RELEASE BLOCKER%\')) and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ') and Customer__c NOT IN(' + IGNORED_CUSTOMERS_PARTIAL + ')';
        return countWorkRecordsMatchingCriteria(ffrecords, q, 'Number_of_Blocking_Bugs__c');
    }
    
    private  List<ADM_Feature_Freeze_Status__c> countOpenBugsByTeamAndBuild(List<ADM_Feature_Freeze_Status__c> ffrecords, String scheduledBuilds, String foundBuilds, String teams, AggregateResult[] memberRoleCountByScrumTeam, Map<Id, ADM_Scrum_Team__c> scrumTeamIDs)   {
        String q = SELECT_CLAUSE + ' where (' + scheduledBuilds + ' ) and ( ' + foundBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and Type__c = \'Bug\' and Resolved__c = 0 and Customer__c NOT IN(' + IGNORED_CUSTOMERS_COMPLETE + ') and RecordType.Name = \'Bug\'';
        return countWorkRecordsMatchingCriteriaDividedByRole(ffrecords, q, 'Number_of_Bugs_to_Fix_max_1_Dev__c', memberRoleCountByScrumTeam, 'Developer', scrumTeamIDs);
    }
    
     private  List<ADM_Feature_Freeze_Status__c> countUntestedBugsByTeamAndBuild(List<ADM_Feature_Freeze_Status__c> ffrecords, String scheduledBuilds, String foundBuilds, String teams, AggregateResult[] memberRoleCountByScrumTeam, Map<Id, ADM_Scrum_Team__c> scrumTeamIDs)  {
        String q = SELECT_CLAUSE + ' where (' + scheduledBuilds + ' ) and ( ' + foundBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and Type__c = \'Bug\' and Resolved__c = 1 and Closed__c = 0 and Customer__c NOT IN(' + IGNORED_CUSTOMERS_COMPLETE + ') and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ')  and RecordType.Name = \'Bug\'';
        return countWorkRecordsMatchingCriteriaDividedByRole(ffrecords, q, 'Number_of_Bugs_to_Verify_max_1_QE__c', memberRoleCountByScrumTeam, 'QA Engineer', scrumTeamIDs);
    }
    
    private  List<ADM_Feature_Freeze_Status__c> countOpenTestFailures(List<ADM_Feature_Freeze_Status__c> ffrecords, Integer age, String foundBuilds, String teams)   {
        String q = SELECT_CLAUSE + ' where ( ' + foundBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and Type__c in (\'Test Failure\', \'Test Change\') and Resolved__c = 0 and Age_With_Scrum_Team__c > ' + age + ' and Customer__c NOT IN(' + IGNORED_CUSTOMERS_COMPLETE + ') and of_Test_Failures__c > 0 and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ') and RecordType.Name = \'Bug\'';
        return countWorkRecordsMatchingCriteria(ffrecords, q, 'Number_of_TF_to_Fix_1week_0__c');
    }
    
    private  List<ADM_Feature_Freeze_Status__c> countOpenTestFailuresByAllocation(List<ADM_Feature_Freeze_Status__c> ffrecords, String foundBuilds, String teams, AggregateResult[] memberRoleCountByScrumTeam, Map<Id, ADM_Scrum_Team__c> scrumTeamIDs) {
        String q = SELECT_CLAUSE + ' where ( ' + foundBuilds + ' ) and Scrum_Team__r.Name in (' + teams + ') and Type__c in (\'Test Failure\', \'Test Change\') and Resolved__c = 0 and Customer__c NOT IN(' + IGNORED_CUSTOMERS_COMPLETE + ') and of_Test_Failures__c > 0 and Scheduled_Build__r.Name NOT IN(' + IGNORED_BUILDS + ') and RecordType.Name = \'Bug\'';
        return countWorkRecordsMatchingCriteriaDividedByRole(ffrecords, q, 'Number_of_TF_to_Fix_max_1_Dev__c', memberRoleCountByScrumTeam, 'Developer', scrumTeamIDs);
    }   

}