public with sharing class ADM_EmailChatterController {
    @AuraEnabled
    public static String findWork(String workName) {
        if (!Schema.sObjectType.ADM_Work__c.fields.Id.isAccessible()){
        	throw new AuraHandledException('Insufficient Access Permissions: Work.Id');
        }

        try {
            ADM_Work__c work = [SELECT Id FROM ADM_Work__c Where Name=:workName LIMIT 1];
        	return work.Id;
        } catch (QueryException e) {
            //return null;
            // setMessage allows testing of the exception
            Exception ex = new AuraHandledException('No work found');
            ex.setMessage('No work found');
            throw ex;
        }
    }
    
    @AuraEnabled
    public static String findChatterGroupId(String groupName){
        if (!Schema.sObjectType.CollaborationGroup.fields.Id.isAccessible()){
        	throw new AuraHandledException('Insufficient Access Permissions: EmailChatterController.findChatterGroupId');
        }

        try{
        CollaborationGroup work = [Select Id FROM CollaborationGroup WHERE Name = :groupName LIMIT 1];
        return work.Id;
        } catch (QueryException qex){
            // setMessage allows testing of the exception
            Exception ex = new AuraHandledException('No chatter group found');
            ex.setMessage('No chatter group found');
            throw ex;
        }
    }
    
    @AuraEnabled
    public static String findUserId(String email){
        if (!Schema.sObjectType.User.fields.Id.isAccessible() ||
            !Schema.sObjectType.User.fields.Email.isAccessible()){
        	throw new AuraHandledException('Insufficient Access Permissions: EmailChatterController.findUserId');
        }
        try{
            User u = [SELECT Id FROM User where Email = :email LIMIT 1];
        	return u.Id;
        }catch (QueryException e){
            // setMessage allows testing of the exception
            Exception ex = new AuraHandledException('No user found');
            ex.setMessage('No user found');
            throw ex;
        }
        
    }
}