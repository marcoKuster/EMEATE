public with sharing class ADM_EmailSenderInformationController {
    
	@AuraEnabled
    public static Map<String, Object> findSenderInfo(String senderEmail) {
        if (!(Schema.sObjectType.User.fields.Id.isAccessible() &&
              Schema.sObjectType.User.fields.SmallPhotoUrl.isAccessible() &&
              Schema.sObjectType.User.fields.ManagerId.isAccessible())){
        	throw new AuraHandledException('Insufficient Access Permissions: EmailSenderInformationController.findSenderInfo');
        }
        User user = [SELECT Id, SmallPhotoUrl, Manager.Name, Manager.Id, Manager.Manager.Name, Manager.Manager.Id, Title FROM User WHERE Email =: senderEmail LIMIT 1];

        Map<String, Object> response = new Map<String, Object>();
        response.put('user', user);
        response.put('host', URL.getSalesforceBaseUrl().getHost()); 
        
        return response;
    } 
   
	@AuraEnabled
    public static ADM_Scrum_Team_Member__c[] findAllScrumTeam(String user_email) {
        if (!ADM_Scrum_Team_Member__c.sObjectType.getDescribe().accessible){return new ADM_Scrum_Team_Member__c[]{};}
        if (!(Schema.sObjectType.ADM_Scrum_Team_Member__c.fields.Scrum_Team_Name__c.isAccessible() &&
              Schema.sObjectType.ADM_Scrum_Team__c.fields.Active__c.isAccessible() &&
              Schema.sObjectType.ADM_Scrum_Team_Member__c.fields.Scrum_Team__c.isAccessible())){
                  return new ADM_Scrum_Team_Member__c[]{};
              }
        
        return [SELECT Scrum_Team_Name__c, Scrum_Team__c FROM ADM_Scrum_Team_Member__c WHERE Scrum_Team__r.Active__c = TRUE AND Member_Name__c in 
            (SELECT Id FROM User WHERE Email=: user_email)];
    }	
}