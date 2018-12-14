trigger ADM_Tag_AssignmentTrigger on ADM_Tag_Assignment__c (before insert, before update, after insert, after update, after delete) {
    
    
    
    if(Trigger.isInsert && Trigger.isBefore) {
        //create unique key based on team, tag and record type enforce uniqueness 
        for(ADM_Tag_Assignment__c ta : Trigger.new) {
            ta.Tag_Record_Type_Key__c = ta.Product_Tag__c + '@' + ta.Assignment_Rule__c + '@' + ta.Record_Type__c;
        }
    }    


    if(Trigger.isInsert && Trigger.isAfter) {
        //IN AFTER INSERT insert's check Product Tag is active and activate it if not
        
        //build list of Product Tags
        List<Id> tagIDs = new List<Id>();
        for(ADM_Tag_Assignment__c ta : Trigger.new) {
            tagIDs.add(ta.Product_Tag__c);
        }
        
        //bulk lookup
        List<ADM_Product_Tag__c> tags = [select Id, Active__c from ADM_Product_Tag__c where Active__c != true and id in:tagIDs];
        
        //activate each one
        for(ADM_Product_Tag__c tag : tags) {
            tag.Active__c = true;                       
        }
        
        //bulk update
        update tags;
    
    }
    
    
    if(Trigger.isDelete && Trigger.isAfter) {
        //IN AFTER DELETE - for deletes if no more assignments exist for that tag then de-activate the tag
        
        //build list of Product Tags
        List<Id> tagIDs = new List<Id>(); 
        for(ADM_Tag_Assignment__c ta : Trigger.old) {
            tagIDs.add(ta.Product_Tag__c);
        }
        
        
        
        //bulk lookup
        List<ADM_Product_Tag__c> tags = [select Id, (Select id from Tag_Assignments__r), Active__c from ADM_Product_Tag__c where id in:tagIDs];
        
        
        
                            
        //for each tag assignment list with zero size deactivate the tag
        for(ADM_Product_Tag__c tag: tags) {
            List<ADM_Tag_Assignment__c> ta = tag.Tag_Assignments__r;
            if(ta == null || ta.size() == 0) {
                
                //no more assignments remain for this tag so de-activate it
                tag.Active__c = false;
            } 
        }
        
        
        
        update tags;
            
    }
    

}