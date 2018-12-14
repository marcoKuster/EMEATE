public with sharing class ADM_TeamRulesController {
	private transient Boolean m_canCreateProductTag;

	public ADM_Scrum_Team__c team { 
        get;
        set;
    }
    
	public ADM_TeamRulesController() {
			
	}
	
	/**
	 * Determines if the user can create a new product tag for the team they
	 * are currently viewing.
	 */
	public Boolean getCanCreateProductTag() {
		if(m_canCreateProductTag == null) {
			try {
                //a user can create a product tag if they are on the team
                m_canCreateProductTag = isUserOnTeam(team.id, UserInfo.getUserId());
			} catch (System.Exception e) {
				System.debug(LoggingLevel.WARN, 'Issue while trying to determine if user can create product tags: ' + e);
				return false;
			}
		}
		return m_canCreateProductTag;
	}
	
	public List<ADM_Tag_Assignment__c> getTagAssignments() {
		List<ADM_Tag_Assignment__c> tagAssignments = new List<ADM_Tag_Assignment__c>();
		try {
			tagAssignments = [select Record_Type__c, Product_Tag__r.Id, Product_Tag__r.Name, Assignment_Rule__r.Product_Owner__r.Name, Assignment_Rule__r.Assignee_Assignment__r.Name, Assignment_Rule__r.QA_Assignment__r.Name from ADM_Tag_Assignment__c where Product_Tag__c in (Select Id from ADM_Product_Tag__c where Team__c = :team.id and Active__c=true) order by Record_Type__c, Product_Tag__r.Name];
		} catch (System.Exception e) {
			System.debug('Unexpected exception:' + e + ' For team:' + team);
		} 
		return tagAssignments;
	}

	public PageReference redirectToNewProductTag() {
        PageReference newTag = Page.ADM_ProductTagEdit;
        
        newTag.setRedirect(true); //want to change the URL as a result of navigation
        newTag.getParameters().put('Team__c', this.team.id);
        newTag.getParameters().put('retURL', '/' + this.team.id);
      
        return newTag;
    }
    
    /**
     * Determines if the user is on the specified team.
     * Consumes one SOQL
     */
    private static Boolean isUserOnTeam(String teamId, String userId) {
        Boolean hasMembership = [select count() from ADM_Scrum_Team_Member__c where Member_Name__c = :userId and Scrum_Team__c = :teamId] > 0;
        System.debug('Does user ' + userId + ' have a membership to team ' + teamId + '? ' + (hasMembership? 'yep':'nope'));
        return hasMembership;
    }
}