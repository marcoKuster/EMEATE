public with sharing class ADM_PriorityMatrixHelpController {
	
	public ADM_PriorityMatrixHelpController(ApexPages.StandardController controller) {}
	
	
	public List<ADM_Impact__c> getImpacts() {
		return [select id, Name, Description__c, Example__c from ADM_Impact__c where Name != NULL order by Order__c];
	}
		
	
}