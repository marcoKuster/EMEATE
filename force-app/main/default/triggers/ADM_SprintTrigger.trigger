trigger ADM_SprintTrigger on ADM_Sprint__c bulk(before insert, after insert, before delete, before update, after update) {
    static final Date dateCutoff = Date.newInstance(1950, 1, 1);
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        
        for(ADM_Sprint__c s : Trigger.New) {
            //This field is used to enforce a unique name as the standard Name field does not offer the option to enforce uniqueness.
            s.NameValidator__c = s.Name;
            
            //make sure the start date of the sprints is after 1950, we don't need to 
            //check the end date because end date is always greater than start date
            if(s.Start_Date__c < dateCutoff) {
                s.Start_Date__c.addError('Start date must be after 1950');
            }
        }
    }
    
    if(Trigger.isDelete) {
        
        Date dateToday = System.today();
        for (ADM_Sprint__c sprint:[select id, Start_Date__c, (select id from Work__r) from ADM_Sprint__c where Id in :Trigger.old]) {
            if ( sprint.Work__r.size() > 0 ) 
                Trigger.oldMap.get(sprint.Id).addError('You can not delete a Sprint that has stories assigned.');
        }
        
    } 

    if((Trigger.isBefore)&&(Trigger.isInsert || Trigger.isUpdate)) {
        Set<Id> teamIds = new Set<Id>();
        for(ADM_Sprint__c sprint : Trigger.new) {
            if(sprint.Scrum_Team__c == null) {
                sprint.scrum_team__c.addError('A sprint must have a reference to a Scrum Team.');   
            } else {
                teamIds.add(sprint.Scrum_Team__c);
            }
        } 
            
        ADM_SprintBurnDownUtils.daysBetweenMinusWeekendsAndCompanyHolidays(Trigger.new);
       
        
    }
    
    // Build out the burn down items if the dates of the sprint change
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<ADM_Sprint__c> rebuildBurnDown = new List<ADM_Sprint__c>();
        
        for(ADM_Sprint__c newSprint : Trigger.new) {
            ADM_Sprint__c oldSprint = (Trigger.isUpdate)? Trigger.oldMap.get(newSprint.Id) : null;
            
            Boolean startDateChanged = Trigger.isInsert || newSprint.Start_Date__c != oldSprint.Start_Date__c;
            Boolean endDateChanged = Trigger.isInsert || newSprint.End_Date__c != oldSprint.End_Date__c;
            if(startDateChanged || endDateChanged) {
            
                //makes sure you can't change the start or end date after the sprint has started
                if(Trigger.isUpdate && System.today() >= oldSprint.Start_Date__c) {
                    if(startDateChanged) {
                        newSprint.Start_Date__c.addError('You can not change the start date after the sprint has started.');
                    }
                    
                    if(endDateChanged) {
                        newSprint.End_Date__c.addError('You can not change the end date after the sprint has started.');
                    }
                } else {
                    rebuildBurnDown.add(newSprint);
                }
            }
        }
        
        if(!rebuildBurnDown.isEmpty()) {
            (new ADM_SprintBurnDownUtils()).rebuildBurndownItems(rebuildBurnDown);
        }
    }
    
    // Updates the data used to generate release burnup & burndown charts.
       if(Trigger.isUpdate && Trigger.isAfter) {
        
        Set<Id> calcReleaseBurndownSprints = new Set<Id>();
        for(ADM_Sprint__c newSprint:Trigger.new) {
            ADM_Sprint__c oldSprint = Trigger.oldMap.get(newSprint.Id);
            
            if(oldSprint.Release_Burndown_Calc__c == false && newSprint.Release_Burndown_Calc__c == true) {
                calcReleaseBurndownSprints.add( newSprint.Id );
            }
        }
        
        if(!calcReleaseBurndownSprints.isEmpty()) {             
            ADM_ReleaseBurndownUtils.updateReleaseBurndownsBulk(calcReleaseBurndownSprints);
        }
    } 
}