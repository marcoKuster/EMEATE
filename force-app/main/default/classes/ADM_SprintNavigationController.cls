public with sharing class ADM_SprintNavigationController {

    
    public transient Id nextSprintId { get; set; }
    
    public transient Id previousSprintId { get; set; }
    
    public ADM_Sprint__c currentSprint;
   
    public ADM_Sprint__c getCurrentSprint() {
        currentSprint = [select id, Scrum_Team__c, Start_Date__c, End_Date__c from ADM_Sprint__c where id =:currentSprint.id]; 
        return currentSprint;
     }
   
    public void setCurrentSprint(ADM_Sprint__c sprint) {
        currentSprint = sprint;
    }
   
    public ADM_SprintNavigationController() {
        
        
    }   
    
    
    //figure out the next chronological sprint (if there is one)
    public Id getTheNextSprint() {
        
        if(currentSprint != null) {
            return ADM_SprintNavigationController.findTheNextSprintId(getCurrentSprint());
        } else {
            return null;
        }
    }
    
    //figure out the previous chronological sprint (if there is one)
    public Id getThePreviousSprint() {
        
        if(currentSprint != null) {
           return ADM_SprintNavigationController.findThePreviousSprintId(getCurrentSprint());
        } else {
            return null;
        }
    }
    
    public static Id findTheNextSprintId(ADM_Sprint__c currentSprint) {
        
        /*find all sprints with a Start Date greater then the current sprints end date.  Sort them so the earliest sprint
        is returned first and then limit the result set to 1 since we only care about the next sprint */
        List<ADM_Sprint__c> futureSprints = [select id from ADM_Sprint__c 
                                            where Id !=:currentSprint.Id and Scrum_Team__c =:currentSprint.Scrum_Team__c 
                                            and Start_Date__c >=:currentSprint.End_Date__c 
                                            order by Start_Date__c limit 1];
        if(futureSprints != null && futureSprints.size() == 1) {
             
            return futureSprints.get(0).Id;
        } else {
            return null;
        }                                    
    
    }
    
    public static Id findThePreviousSprintId(ADM_Sprint__c currentSprint) {
       
        /*find all sprints with a End Date less than then the current sprints start date.  Sort them so the latest sprint
        is returned first and then limit the result set to 1 since we only care about the previous sprint */
        
        List<ADM_Sprint__c> pastSprints = [select id from ADM_Sprint__c 
                                            where Id !=:currentSprint.Id and Scrum_Team__c =:currentSprint.Scrum_Team__c 
                                            and End_Date__c <=:currentSprint.Start_Date__c 
                                            order by End_Date__c DESC limit 1];
        if(pastSprints != null && pastSprints.size() == 1) {
             
            return pastSprints.get(0).Id;
        } else {
            return null;
        }                                    
    
    }

    public String getListViewLink() {
        Schema.DescribeSObjectResult sprintDescribe = Schema.SObjectType.ADM_Sprint__c;
        String objectPrefix = '/' + sprintDescribe.getKeyPrefix();
        return objectPrefix;
    }

}