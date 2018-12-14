public with sharing class ADM_TeamReleaseExtension {
   
    public String reportResultsDebug { get; set; }
        
    // Controller extension used to help generate the release burndown charts on the team release detail page.
    @TestVisible
    private final ADM_Team_Release__c teamRelease;
    Release_Reports__c releaseReportsCustomSetting;
    
    public ADM_TeamReleaseExtension(ApexPages.StandardController stdController) {
        releaseReportsCustomSetting = Release_Reports__c.getInstance(UserInfo.getProfileId());
        this.teamRelease = [select id, Build__c, Build__r.name, Scrum_Team__r.name from ADM_Team_Release__c where id=:stdController.getRecord().ID limit 1];
        //Uncomment for debugging
        /* Reports.ReportDescribeResult descRes = Reports.ReportManager.describeReport('00Oo0000001wtxL');
        reportResultsDebug = JSON.serializePretty(descRes.getReportMetaData().getDetailColumns());
        //Reports.ReportResults results = Reports.ReportManager.runReport('00Oo0000001wtxJ');
        //reportResultsDebug = JSON.serializePretty(results); */
    }
    
    public String getPackageNameSpace() {
       ADM_ConstantsSingleton constants = ADM_ConstantsSingleton.getInstance();
       String namespace = constants.getNameSpace();
        if(namespace != null && namespace != '') {
            return namespace;
        } else {
            return '';
        }
         
    }
   
    public String getTeamReleaseId15() {
        String idString = teamRelease.ID;
        return ADM_TextUtils.oldSchoolSalesforceID(idString);
    }

    public String getBuildID15() {
        String idString = teamRelease.Build__c;
       return ADM_TextUtils.oldSchoolSalesforceID(idString);
    }
     
    public String getScrumTeamName() {
        return teamRelease.Scrum_Team__r.name;
    }
    
    public String getBuildName() {
        return teamRelease.Build__r.name;
    }
   
}