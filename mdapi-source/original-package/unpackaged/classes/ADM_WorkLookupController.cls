public with sharing class ADM_WorkLookupController {
	
	private List<ADM_WorkWrapper> matchingWork = new List<ADM_WorkWrapper>();
	
	public List<ADM_WorkWrapper> getMatchingWork() { 
		return matchingWork;
	}
	
	public void setMatchingWork(List<ADM_WorkWrapper> ww) {
		this.matchingWork = ww;
	}
		
	public String query {get; set; }
	
	public ADM_WorkLookupController() {
		
	}
	
	public void searchWork() {
		try {
			matchingWork = new List<ADM_WorkWrapper>();
			
			for(ADM_Work__c w : [select id, Name, Subject__c, Priority__c, Assignee__r.Name, Scrum_Team__r.Name from ADM_Work__c where Subject__c LIKE :'%' + query + '%' and Closed__c = 0 order by Subject__c limit 50]) {
				ADM_WorkWrapper ww = new ADM_WorkWrapper(w);
				matchingWork.add(ww);
			}		
		} catch (System.Exception e) {
			System.debug('Unexpected exception searching for work.');
			matchingWork = new List<ADM_WorkWrapper>();
		}
	}

}