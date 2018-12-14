public with sharing class ADM_StoryCostExtension {
    private Map<Id, ADM_WorkWrapper> m_mapOfSelectedStories;
    private Id scrumteamId { get; set; }
    
    public ADM_WorkWrapper[] storiesToCost { get; set; }
    public Integer[] storyPointList { get; set; }
    public String changeList { get; set; }
    public String storyPoints { get; set; }
        
    public ADM_StoryCostExtension(ApexPages.StandardSetController controller) {
        scrumteamId = System.currentPageReference().getParameters().get('scrumteamId');
        String workList = System.currentPageReference().getParameters().get('workIds');
        String[] workIds = new String[] {};
        
        if(workList != null) {
        	for(String id : workList.split(',')) {
	            if(id != null && ADM_TextUtils.isValidId(id)) {
	                workIds.add(id.substring(0,15));
	            }
            }
        }
        
    	if(!controller.getSelected().isEmpty()) {
    		workIds = new String[] {};
            for(ADM_Work__c w : (List<ADM_Work__c>) controller.getSelected()) {
            	workIds.add(w.Id);
            }
        }
        
        if(!workIds.isEmpty()) {
	        loadStories(workIds);
	        loadStoryPoints();
        } else {
        	userError('No records were selected to story point');
        }
    }
        
    public PageReference save() {    
        return saveAndReturn('/apex/ADM_WorkPrioritizer?scrumteamId=' + scrumteamId);
    }
    
    public PageReference quickSave() {
        return saveAndReturn(null);       
    }
    
    public PageReference cancel() {
        return new PageReference('/apex/ADM_WorkPrioritizer?scrumteamId=' + scrumteamId);
    }
    
    public PageReference empty() {
        return null; 
    }    
    
    private void addStoryPointToList(Double d) {
        if (storyPointList == null)
            storyPointList = new List<Integer>();
        Integer intValue = Math.round(d);
        if (intValue < 0)
            intValue = 0;
        for(Integer i: storyPointList)
            if (i == intValue) return;
        storyPointList.add(intValue);
    }
    
    private void loadStories(String[] ids) {
        ADM_Work__c[] works = ADM_Work.getAllBy('Id', ids, 0, ids.size(), 'Priority_Rank__c', 'asc');
        storiesToCost = new List<ADM_WorkWrapper>();
        
        m_mapOfSelectedStories = new Map<Id,ADM_WorkWrapper>();
        for (ADM_Work__c w:works) {
        	if(scrumteamId == null) {
        		scrumteamId = w.Scrum_Team__c;
        	} else if(scrumteamId != w.Scrum_Team__c){
        		
        	}
            ADM_WorkWrapper sw = new ADM_WorkWrapper(w);
            storiesToCost.add(sw);
            m_mapOfSelectedStories.put(w.id, sw);
        }
    }
    
    private void loadStoryPoints() {
        if(scrumteamId != null) {
            ADM_Scrum_Team__c scrumTeamObj = [select Story_Point_Scale__c from ADM_Scrum_Team__c where id = :scrumteamId];
            
            if (scrumTeamObj.Story_Point_Scale__c != null && scrumTeamObj.Story_Point_Scale__c.trim().length() > 0)
                setStoryPointValues(scrumTeamObj.Story_Point_Scale__c);
            else
                setStoryPointValues('1,2,3,5,8,13,21');
        } else {
            setStoryPointValues('1,2,3,5,8,13,21');            
        }
    }   
    
    private PageReference saveAndReturn(String url) {
        ADM_Work__c[] toUpdate = new List<ADM_Work__c>();
        
        // Look at the list of works and order recevied and reshuffle storiesToCost to that order
        String[] workIds = changeList.split(' ');
        for(String idSet:workIds) {
            String[] sidAndPoints = idSet.split(':');
            if(sidAndPoints[0] != null && ADM_TextUtils.isValidId(sidAndPoints[0])) {
            	
            	ADM_WorkWrapper sw = m_mapOfSelectedStories.get(sidAndPoints[0]);
            	if(sidAndPoints[1] != null) {
	                try {
	                	Integer points = Integer.valueOf(sidAndPoints[1]);
	                    sw.work.Story_Points__c = points;
	                    sw.stayInBucket = true;
	                    toUpdate.add(sw.work);
	                } catch(System.Exception e) {
	                   userError('There is something wrong with the story point values you entered. Please correct and try again');	
	                }
            	}
            }  
        }
        
        changeList = '';
        
        if (toUpdate.size() > 0)
            try {
            	update toUpdate;
            } catch (System.Exception e) {
            	return null;
            }
        if (url == null) {
            return null;    
        } else {
            return new PageReference(url);
        }
    }
    
    private void setStoryPointValues(String s) {
        
        if (storyPointList == null) 
            storyPointList = new List<Integer>();
        
        s = s.trim();
        String[] storyPointsArr = s.split(',');
        if (storyPointsArr.size() > 0) {
            storyPointList.clear();
            for (String sp:storyPointsArr) {
                Integer intValue = 0;
                try {
                    intValue = Integer.valueOf(sp);
                } catch (Exception e) {
                    userError('There is something wrong with the story point values you entered. Please correct and try again');
                    return; 
                }
                if (intValue < 0) continue;
                addStoryPointToList(intValue*1.0);
            }
            storyPointList.sort();
        }
    }
    
    private void userError(String s) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));   
    }
}