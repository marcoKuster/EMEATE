global with sharing class ADM_SprintChartsController {
	public ADM_SprintChartsController() {}
	private static Integer DEFAULT_SPRINTS = 6;
	private static Integer MAX_SPRINTS = 10; 
	private static Integer TOTAL_SPRINTS = 0;
	
	public String m_teamId { get; set; }
	public String m_sprintId { get; set; }
	
	public static transient String numSprints;
	
	public String getNumSprints() {
		return numSprints;
	}
	
	public void setNumSprints(String s) {
		numSprints = s;
	}
    
    public static ADM_Cookie cookie;
    
    public ADM_Cookie getCookie() {
    	return cookie;
    }
    
    public List<ADM_Sprint__c> sprints { 
        get {
        	if(sprints == null) {
	            sprints = new List<ADM_Sprint__c>();	                
	            if(m_teamId != null) {
					sprints = getMySprints(String.valueOf(m_teamId + ',' + 6));
	            }
        	}
            return sprints;
        } 
        set; 
    }
	
	private static List<AggregateResult> getAggregateResults(String sprintId) {
		List<AggregateResult> results = new List<AggregateResult>();				
		for(AggregateResult result : [select Sprint__c, SUM(Story_Points__c) summ from ADM_Work__c where Sprint__c = :sprintId group by Sprint__c]) {
			results.add(result);
		}
		return results;				
	}
	
	private static List<ADM_Sprint__c> getMySprints(String teamIdAndNumSprints) {
		String teamId;
		Integer num;
		Integer breakPt;
		Integer maxNum = 10;
		
		List<String> results = teamIdAndNumSprints.split(',');
        List<ADM_Sprint__c> sprintResults = new List<ADM_Sprint__c>();
        List<ADM_Sprint__c> sprints2Return = new List<ADM_Sprint__c>();
        
        if(results.size() == 2) {
        	teamId = results.get(0);
        	num = Integer.valueOf(results.get(1));
        	
        	sprintResults = [select a.Hours_in_a_work_day__c, a.Name, a.Start_Date__c, a.End_Date__c, a.Days_Remaining__c, a.Completed_Story_Points__c from ADM_Sprint__c a where a.Completed_Story_Points__c != null and a.Scrum_Team__c = :teamId and a.Days_Remaining__c like 'CLOSED%' order by a.End_Date__c desc limit 10];
        	
        	TOTAL_SPRINTS = sprintResults.size();
        	
        	if(num > TOTAL_SPRINTS || num < 2) {
        		breakPt = DEFAULT_SPRINTS;        		
        	} else {
        		breakPt = num;
        	}
        	
	        for(ADM_Sprint__c sprintResult : sprintResults) {
	            sprints2Return.add(sprintResult);
	            if(sprints2Return.size() == breakPt) break;
	        }
	        
	        numSprints = teamId + ',' + sprints2Return.size();
	        cookie = new ADM_Cookie('s2v' + teamId, teamId + ',' + sprints2Return.size());
        }     
           
        return sprints2Return;
	}
	
	@RemoteAction 
	global static Integer getTotalSprints(String teamId) {
		Integer counter = [select count() from ADM_Sprint__c a where a.Completed_Story_Points__c != null and a.Scrum_Team__c = :teamId and a.Days_Remaining__c like 'CLOSED%' limit 10];
		return counter;
	}
	
	@RemoteAction
	global static List<ADM_Sprint__c> getCurrSprints(String teamId) {
		List<ADM_Sprint__c> results = getMySprints(teamId);
		return results;	
	}
	
	@RemoteAction 
	global static String getCurrSprintPoints(String sprintId) {
		List<AggregateResult> results = getAggregateResults(sprintId);		
		String currSprintPoints = '0'; 
		
		for(AggregateResult result : results) {
			currSprintPoints = String.valueOf(result.get('summ'));
		}
		
		if(currSprintPoints == null) currSprintPoints = '0';
		
		return currSprintPoints;			
	}
	
	public List<Selectoption> getNumAvailSprints() {
        List<Selectoption> options = new List<Selectoption>();

        for(Integer i = 2; i <= TOTAL_SPRINTS; i++) {
            options.add(new SelectOption(String.valueOf(m_teamId + ',' + i), String.valueOf(i)));
            if(i == TOTAL_SPRINTS) break;
        }

        return options;
    }
}