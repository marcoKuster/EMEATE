public with sharing class ADM_PlannerBacklogListController {

	private Id scrumTeamId = null;

	public ADM_PlannerBacklogListController() {
		this.scrumTeamId = ApexPages.currentPage().getParameters().get('teamid');
	}

	public void setScrumTeamId(Id teamId) {
		this.scrumTeamId = teamId;
	}

	private List<ADM_Work__c> backlogItems = null;

	public List<ADM_Work__c> getBacklogItems {
		get {
			try {
				if (this.backlogItems == null) {
					this.backlogItems = [select Id, Subject__c, RecordType.Name from ADM_Work__c
													where Closed__c = 0 and (RecordType.Name = 'User Story' or RecordType.Name = 'Bug'
														or RecordType.Name = 'ToDo') and Scrum_Team__c = :this.scrumTeamId and Use_Prioritizer__c = true
														and Priority_Rank__c != null order by Priority_Rank__c nulls last, CreatedDate, Id desc limit 200];
				}
			} catch (System.exception e) {
				System.debug('getBacklogItems(): Got an exception!');
				this.backlogItems = null;
			}

			return this.backlogItems;
		}
	}
}