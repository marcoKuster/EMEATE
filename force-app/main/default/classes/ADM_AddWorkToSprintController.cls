public with sharing class ADM_AddWorkToSprintController  {
   
    public List<ADM_WorkWrapper> workList;
    public List<ADM_WorkWrapper> selectedWorkList;
    
    public ADM_AddWorkToSprintController() {
    	
    }
    
    public ADM_AddWorkToSprintController(ApexPages.StandardSetController c) {
        
    }
   
   
   /* 
	  @testcaseID a0B20000006aebXEAQ
	  @hierarchy GUS.ScrumforceToGUS.Sprint.Detail page.Sprint Backlog
	  @userstory a0A20000007rUNO
	  @expectedResults: Work items match the following criteria:
	
		1) Include in Prioritize View flag is set to true 
		2) Closed is set to False 
		3) work item belongs to the Scrum team of the current sprint
		
	*/ 
	
	/* 
	  @testcaseID a0B20000006bojZEAQ
	  @hierarchy GUS.ScrumforceToGUS.Sprint.Detail page.Sprint Backlog
	  @userstory a0A20000007rUNO
	  @expectedResults: Ensure work items that have an Include in Prioritize View flag set to false do not show on the Add Work to Sprint page
	*/
	
	/* 
	  @testcaseID a0B20000006aRdVEAU
	  @hierarchy GUS.ScrumforceToGUS.Sprint.Detail page.Sprint Backlog
	  @userstory a0A20000007rUNO
	  @expectedResults: Ensure templates do not show listed on the Sprint Backlog section
	*/
	
	/* 
	  @testcaseID a0B20000006aebZEAQ
	  @hierarchy GUS.ScrumforceToGUS.Sprint.Detail page.Sprint Backlog
	  @userstory a0A20000007rUNO
	  @expectedResults: Ensure Work items that are already in the Sprint do not show on the Add work to Sprint pop up window
	*/ 
	
	/* 
	  @testcaseID a0B20000006aebaEAA
	  @hierarchy GUS.ScrumforceToGUS.Sprint.Detail page.Sprint Backlog
	  @userstory a0A20000007rUNO
	  @expectedResults: Ensure work items that are closed do not show on Add work to Sprint page
	*/     
      
    public Id getSprintID() {
    	return  System.currentPageReference().getParameters().get('sprintID');
    }  
      
         
    public List<ADM_WorkWrapper> getWork() { 
      workList = new List<ADM_WorkWrapper>();
      try {
     	
      	
	      String sprintID = System.currentPageReference().getParameters().get('sprintID');
	      ADM_Sprint__c sprint = [select id, Name, Scrum_Team__c from ADM_Sprint__c where id =:sprintID];
	      
	      List<ADM_Work__c> popWorks = [select id, Name, Subject__c, Status__c, Priority__c, Theme__r.Name, Scheduled_Build__r.Name, Sprint__r.Name, Sprint__c, Closed__c, Use_Prioritizer__c, RecordType.name from ADM_Work__c where Scrum_Team__c = :sprint.Scrum_Team__c and Sprint__c != :sprintID and Closed__c = 0 and Use_Prioritizer__c = true and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME order by Priority_Rank__c, Id  nulls first limit 1000];
          
          
	      //store populated work records in a wrapper class which maintains run time meta data
	      
	      for(ADM_Work__c work : popWorks) {
	    		workList.add(new ADM_WorkWrapper(work));
	      }
	      
	  } catch(System.Exception e) {
	    	
	    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to initialize list view.'));
	    	
	  }        
      return workList;
    }
    
    
    
    public PageReference addToSprint() {
    	filterSelectedWork();
    	String sprintID = System.currentPageReference().getParameters().get('sprintID');
    	try {
	    	List<ADM_Work__c> updateList = new List<ADM_Work__c>();
	    	if(selectedWorkList != null) {
		    	for(ADM_WorkWrapper w : selectedWorkList) {
		    		w.work.Sprint__c = sprintID;
		    		updateList.add(w.work);
		    	}	    	
		    	update updateList;
		    	if(updateList != null & updateList.size() > 0) {
		    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Work item(s) have been successfuly added to the sprint.'));
		    	} else {
		    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'No Work item(s) have been selected.'));
		    	}	
	    	}
    	} catch(System.Exception e) {
	    	
	    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Work item(s) have failed to be added to the sprint.'));
	    	
	    }		
    	return null;
    }
    
    public void filterSelectedWork() {
    	selectedWorkList = new List<ADM_WorkWrapper>();
    	if(workList != null) {
	    	for(ADM_WorkWrapper w : workList) {
	    		if(w.checked) selectedWorkList.add(w);
	    	}
    	}	
    }
    
   

}