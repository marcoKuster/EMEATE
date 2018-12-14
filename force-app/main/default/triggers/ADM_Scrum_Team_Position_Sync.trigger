trigger ADM_Scrum_Team_Position_Sync on ADM_Scrum_Team__c (after update) {

    List<Headcount__c> hcForUpdate = new List<Headcount__c>();
    
    //lookup position records that belong to teams in batch
    List<Headcount__c> headcount = [select id, Cloud__c, Team__c from Headcount__c where Team__c in : Trigger.new];
    
    for(Headcount__c hc: headcount) {
        if(hc.Team__c != null && Trigger.newMap.containsKey(hc.Team__c)) {
            ADM_Scrum_Team__c newTeam = Trigger.newMap.get(hc.Team__c);
            ADM_Scrum_Team__c oldTeam = Trigger.oldMap.get(hc.Team__c);
            //if cloud changed then change the cloud on the position record
            if(newTeam.Cloud__c != oldTeam.Cloud__c) {
                hc.Cloud__c = newTeam.Cloud__c;
                hcForUpdate.add(hc);
            }
           
        
        }
        
    }
    
    //bulk update positions
    try {
       Database.update(hcForUpdate); 
    } catch(Exception e) {
        System.debug('ADM_Scrum_Team_Position_Sync Trigger.  Exception updating cloud on Headcount:' + e );
    }

}