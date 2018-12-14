trigger ADM_ThemeAssignmentTrigger on ADM_Theme_Assignment__c (before insert, after insert, before update, after update, before delete, after delete) {
    Map<Id, ADM_Theme__c> themeMap = new Map<Id, ADM_Theme__c> ();
    List<Id> themeIDs = new List<Id>();
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        //create unique key based on theme and work to enforce uniqueness 
        for(ADM_Theme_Assignment__c themeAssignment : Trigger.new) {
            themeAssignment.Theme_Work_Key__c = themeAssignment.Work__c + '@' + themeAssignment.Theme__c;
            themeIDs.add(themeAssignment.Theme__c);
        }
    }

    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        //pre-load data to help validate themes
        themeMap = new Map<Id, ADM_Theme__c>([select id, Name, Active__c from ADM_Theme__c where id in:themeIDs]);
        for(ADM_Theme_Assignment__c themeAssignment : Trigger.new) {
            
            //require that Work be specified
            if(themeAssignment.Work__c == null) {
                themeAssignment.Work__c.addError('Work is a required field.');
            }
            
            //require that an active Theme be specified - due to order of OR statement it won't attempt to read the Active flag when the theme is null preventing NPE
            if(themeAssignment.Theme__c == null || themeMap.get(themeAssignment.Theme__c).Active__c == false) {
                themeAssignment.Theme__c.addError('Theme is a required field. Please provide a valid, active Theme.');
            }

        }
    }

     if(Trigger.isAfter && (Trigger.isInsert || Trigger.isDelete)) {
        try{
            List<FeedItem> feedItems = new List<FeedItem>();
            Map<Id,ADM_Theme_Assignment__c> themeAssignmentMap = new Map<Id,ADM_Theme_Assignment__c>();
            String message = '';
            //We use oldMap and newMap instead of Trigger.old and Trigger.new directly because we use this both on insert and 
            //delete and it happens in the after trigger. Only the Maps are available on all conditions.
            if(Trigger.isDelete){
                message = ' was deleted from the work record.';
                themeAssignmentMap = Trigger.oldMap;
            }
            else if(Trigger.isInsert){
                message = ' was added to the work record.';
                themeAssignmentMap = Trigger.newMap;
            }

            //Get the theme assignment ids from the Map to loop thru.
            Set<Id> themeAssignmentIds = new Set<Id>();
            themeAssignmentIds = themeAssignmentMap.keySet();


            //Get the themes associated with the theme Asignment
            for(Id themeAssignmentId : themeAssignmentIds) {
                themeIDs.add(themeAssignmentMap.get(themeAssignmentId).Theme__c);
            }
            themeMap = new Map<Id, ADM_Theme__c>([select id, Name, Active__c from ADM_Theme__c where id in:themeIDs]);

            //Create feed items for the themeAssignments
            for(Id themeAssignmentId : themeAssignmentIds) {   
                ADM_Theme_Assignment__c themeAssignment = themeAssignmentMap.get(themeAssignmentId);
                FeedItem feedItem = new FeedItem();
                //If the theme is available then create the feed item.
                if(themeAssignment.Theme__c != null && themeMap.get(themeAssignment.Theme__c) != null){
                    String themeName = themeMap.get(themeAssignment.Theme__c).Name;                   
                    feedItem.Body = 'Theme '+themeName+message;
                    feedItem.ParentId = themeAssignment.Work__c;
                    feedItems.add(feedItem);
                }
            }
            if(feedItems.size() > 0){
                insert feedItems;
            }
        }
        catch(Exception e){
            System.debug('Exception while posting theme creation on Chatter : '+e);
        }
     }
     
}