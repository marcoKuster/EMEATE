public with sharing class ADM_EmailWorkQuickViewController {
	private static String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
	@AuraEnabled
    public static ADM_Work__c findWork(String workName) {
        //all fields must be readable by the current user to proceed otherwise an exception is thrown
        if (!(Schema.sObjectType.ADM_Work__c.fields.Name.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Subject__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Due_Date__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Status__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Assignee__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.QA_Engineer__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Sprint__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Sprint_Name__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Scheduled_Build_Name__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Scrum_Team_Name__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Scrum_Team__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Type__c.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Product_Tag__c.isAccessible() &&
              Schema.sObjectType.User.fields.Id.isAccessible() &&
              Schema.sObjectType.User.fields.Name.isAccessible() &&
              Schema.sObjectType.ADM_Build__c.fields.Id.isAccessible() &&
              Schema.sObjectType.ADM_Sprint__c.fields.Id.isAccessible() &&
              Schema.sObjectType.ADM_Work__c.fields.Id.isAccessible()
             )){
                 throw new AuraHandledException('User cannot change that field');
             }
        return 
       	[SELECT Name, Subject__c, Due_Date__c, Status__c, Assignee__r.Name, Assignee__r.Id, QA_Engineer__r.Name, QA_Engineer__r.Id, Sprint__c, Sprint_Name__c, Sprint__r.Id,
         Scheduled_Build__r.Id,Scheduled_Build_Name__c, Scrum_Team_Name__c, Scrum_Team__c, Type__c, Product_Tag__r.Team__c, Product_Owner__r.Name,
         Id FROM ADM_Work__c Where Name=:workName LIMIT 1];     
    }
    
    @AuraEnabled
    public static List<String> getSourceControlStatuses(String workId){ 
        if(!isSourceControlStatusUpdateable()) {
			throw new AuraHandledException('Insufficient Access Permission: WorkQuickViewController.getSourceControlStatuses');
        }

        ADM_Work__c work = [SELECT Perforce_Status__c FROM ADM_Work__c WHERE Id=:workId LIMIT 1];
        Schema.sObjectType objType = work.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        List<String> toReturn = new List<String>();
        // Get the list of picklist values for this field.
        for(Schema.PicklistEntry i : fieldMap.get(nameSpacePrefix + 'Perforce_Status__c').getDescribe().getPickListValues()) {
            toReturn.add(i.getValue());
        }
        return toReturn;
    }
    
    /*
     * Get the current source control status of the work item
     */
    @AuraEnabled
    public static String getSourceControlStatus(String workId) {
        if(!isSourceControlStatusUpdateable()) {
            throw new AuraHandledException('Insufficient Access Permission: WorkQuickViewController.getSourceControlStatus');
        }
        ADM_Work__c work = [SELECT Perforce_Status__c FROM ADM_Work__c WHERE Id=:workId LIMIT 1];
        return work.Perforce_Status__c;
    }
    
    /**
     * Get Team members of the work item's team based on the product tag 
     * for assigning the assignee and qa engineer
     */
    @AuraEnabled
    public static ADM_Scrum_Team_Member__c[] getTeamMembers(String teamId){
        if (!Schema.sObjectType.User.fields.Id.isAccessible() ||
            !Schema.sObjectType.User.fields.Name.isAccessible()){
                
        	throw new AuraHandledException('Insufficient Access Permissions: WorkQuickViewController.getTeamMembers');
        }
        return [SELECT Member_Name__r.Name, Member_Name__r.Id FROM ADM_Scrum_Team_Member__c WHERE Scrum_Team__c=:teamId];
    }
    
    /*
     * Gets the current sprint and any sprint that started last month
     */
    @AuraEnabled
    public static ADM_Sprint__c[] getSprints(String scrumTeamId) {
        if (!Schema.sObjectType.ADM_Sprint__c.fields.Name.isAccessible()){
            return new ADM_Sprint__c[]{};
        }
        Date lastMonth = Date.today().addMonths(-1);
        return [SELECT Name, Id FROM ADM_Sprint__c WHERE Scrum_Team__c = :scrumTeamId AND Start_Date__c > :lastMonth];
    }

    /*
     * Get all possible statuses based on the work type which is a comma separated list
     */
	@AuraEnabled
    public static ADM_Work_Status__c[] getWorkStatusList(String workType) {
        if (!Schema.sObjectType.ADM_Work_Status__c.fields.Name.isAccessible() || !Schema.sObjectType.ADM_Work_Status__c.fields.Type__c.isAccessible()){
            return new ADM_Work_Status__c[]{};
        }
        return [SELECT Name FROM ADM_Work_Status__c WHERE Type__c includes (:workType)];
    }
 
    /*
     * Get all builds from 208 and 210. If the user needs more options they should edit the bug in GUS
     */
    @AuraEnabled
    public static ADM_Build__c[] getBuilds() {
        if (!Schema.sObjectType.ADM_Build__c.fields.Name.isAccessible()){
            return new ADM_Build__c[]{};
        }
        return [SELECT Name, Id FROM ADM_Build__c WHERE Name LIKE '208%' OR Name = '210'];
    }
    
    /**************************************
     * 
     *           SETTER METHODS
     * 
     **************************************/
    
    @AuraEnabled
    public static void setStatus(String status, String name){
        if (!Schema.sObjectType.ADM_Work__c.fields.Status__c.isUpdateable()){
            throw new AuraHandledException('User cannot change the status field.');
        }
        try {
            ADM_Work__c work = [SELECT Status__c FROM ADM_Work__c Where Name=:name LIMIT 1];
            work.Status__c = status;
            update work;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void setAssignee(String assigneeId, String workName) {
        try {
            if (!Schema.sObjectType.ADM_Work__c.fields.Assignee__c.isUpdateable()){
            	return;
        	}
            ADM_Work__c work = [SELECT Assignee__c FROM ADM_Work__c WHERE Name=:workName LIMIT 1];
            work.Assignee__c = assigneeId;
            update work;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void setQAEngineer(String qaId, String workName) {
        try {
            if (!Schema.sObjectType.ADM_Work__c.fields.QA_Engineer__c.isUpdateable()){
            	return;
        	}
            ADM_Work__c work = [SELECT QA_Engineer__c FROM ADM_Work__c WHERE Name=:workName LIMIT 1];
            work.QA_Engineer__c = qaId;
            update work;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void setSprint(String sprintId, String workName) {
        try {
            if (!Schema.sObjectType.ADM_Work__c.fields.Sprint__c.isUpdateable()){
            	throw new AuraHandledException('Sprint is not updateable');
        	}
            ADM_Work__c work = [SELECT Sprint__c FROM ADM_Work__c WHERE Name=:workName LIMIT 1];
            work.Sprint__c = sprintId;
            update work;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void setBuild(String buildId, String workName) {
        try {
            if (!Schema.sObjectType.ADM_Work__c.fields.Scheduled_Build__c.isUpdateable()){
            	return;
        	}
            ADM_Work__c work = [SELECT Scheduled_Build__c FROM ADM_Work__c WHERE Name=:workName LIMIT 1];
            work.Scheduled_build__c = buildId;
            update work;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void setSourceControl(String sourceControlStatus, String workName) {     
        try{
            if (!isSourceControlStatusUpdateable()){
            	throw new AuraHandledException('User cannot change ADM_Work__c.Perfoce_Status__c');
        	}
            ADM_Work__c work = [SELECT Perforce_Status__c FROM ADM_Work__c WHERE Name=:workName LIMIT 1];
            work.Perforce_Status__c = sourceControlStatus;
            update work;
        } catch(Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**************************************
     * 
     *           MISC. METHODS
     * 
     **************************************/
    
    public static boolean isSourceControlStatusUpdateable() {
    	return Schema.sObjectType.ADM_Work__c.fields.Perforce_Status__c.isUpdateable();
    }
    
}