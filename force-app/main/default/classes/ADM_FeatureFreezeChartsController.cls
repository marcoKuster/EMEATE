public with sharing class ADM_FeatureFreezeChartsController {
	
	ADM_Feature_Freeze_Status__c featureFreezeRecord { get; set; }
		
	public ADM_FeatureFreezeChartsController(ApexPages.StandardController stdController) {
		featureFreezeRecord = (ADM_Feature_Freeze_Status__c) stdController.getRecord();
		//flesh out ff record as the one passed by standard controller is not fully populated
		featureFreezeRecord = [select Id, Scrum_Team__c, Build__c from ADM_Feature_Freeze_Status__c where id =: + featureFreezeRecord.id];
	} 
	
	
	
	public String getBlockingBugsReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Number Of Blocking Bugs');
	}
	
	public String getBlockingBugsReportParams() {
		return 'pv0=' + featureFreezeRecord.Scrum_Team__c + '&pv1=' + featureFreezeRecord.Build__c + '&pv2=' + featureFreezeRecord.Build__c;
	}
	
	public String getBugsToVerifyReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Number Of Bugs To Verify');
	}
	
	public String getBugsToVerifyReportParams() {
		return 'pv0=' + featureFreezeRecord.Scrum_Team__c + '&pv1=' + featureFreezeRecord.Build__c + '&pv2=' + featureFreezeRecord.Build__c;
	}
	
	public String getOpenBugsReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Number Of Open Bugs');
	}
	
	public String getOpenBugsReportParams() {
		return 'pv0=' + featureFreezeRecord.Scrum_Team__c + '&pv1=' + featureFreezeRecord.Build__c + '&pv2=' + featureFreezeRecord.Build__c;
	}
	
	public String getOpenUserStoriesReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Number Of Open User Stories');
	}
	
	public String getOpenUserStoriesReportParams() {
		return 'pv0=' + featureFreezeRecord.Scrum_Team__c + '&pv1=' + featureFreezeRecord.Build__c;
	}
	
	public String getOpenTestFailuresReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Number Of Open Test Failures');
	}
	
	public String getOpenTestFailuresReportParams() {
		return 'pv0=' + featureFreezeRecord.Scrum_Team__c + '&pv1=' + featureFreezeRecord.Build__c;
	}
	
	public String getOpenTestFailuresByDevReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Number Of Test Failures Per Dev');
	}
	 
	public String getOpenTestFailuresByDevReportParams() {
		return 'pv0=' + featureFreezeRecord.Scrum_Team__c + '&pv1=' + featureFreezeRecord.Build__c;
	}
	
	
	
	

}