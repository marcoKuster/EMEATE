public with sharing class ADM_ReleaseFreezeChartsController {
	
	ADM_Release_Freeze_Status__c releaseFreezeRecord { get; set; }
		
	public ADM_ReleaseFreezeChartsController(ApexPages.StandardController stdController) {
		releaseFreezeRecord = (ADM_Release_Freeze_Status__c) stdController.getRecord();
		//flesh out ff record as the one passed by standard controller is not fully populated
		releaseFreezeRecord = [select Id, Scrum_Team__c, Build__c from ADM_Release_Freeze_Status__c where id =: + releaseFreezeRecord.id];
	} 
	
	
	
	public String getBlockingBugsReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Release Freeze Blocking Bugs');
	}
	
	public String getBlockingBugsReportParams() {
		return 'pv0=' + releaseFreezeRecord.Scrum_Team__c + '&pv1=' + releaseFreezeRecord.Build__c + '&pv2=' + releaseFreezeRecord.Build__c;
	}
	
	public String getOpenBugsReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Release Freeze Open Bugs Per Dev');
	}
	
	public String getOpenBugsReportParams() {
		return 'pv0=' + releaseFreezeRecord.Scrum_Team__c + '&pv1=' + releaseFreezeRecord.Build__c + '&pv2=' + releaseFreezeRecord.Build__c;
	}
	
	public String getOpenUserStoriesReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Release Freeze Open User Stories');
	}
	
	public String getOpenUserStoriesReportParams() {
		return 'pv0=' + releaseFreezeRecord.Scrum_Team__c + '&pv1=' + releaseFreezeRecord.Build__c;
	}
	
	public String getOpenTestFailuresByDevReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Release Freeze Test Failures Per Dev');
	}
	 
	public String getOpenTestFailuresByDevReportParams() {
		return 'pv0=' + releaseFreezeRecord.Scrum_Team__c + '&pv1=' + releaseFreezeRecord.Build__c;
	}
	
	public String getBugsToVerifyReportID() { 
		return ADM_DevelopmentCycleUtils.getCustomReportIDByName('Release Freeze Untested Bugs Per QE');
	}
	
	public String getBugsToVerifyReportParams() {
		return 'pv0=' + releaseFreezeRecord.Scrum_Team__c + '&pv1=' + releaseFreezeRecord.Build__c + '&pv2=' + releaseFreezeRecord.Build__c;
	}
	
	
	
	
	
	
	
	
	
	
	
	

}