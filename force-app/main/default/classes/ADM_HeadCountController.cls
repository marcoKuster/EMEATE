public with sharing class ADM_HeadCountController {

    public ADM_HeadCountController() {
    
    }

    public ADM_HeadCountController(ApexPages.StandardController stdController) {
    
    }

    public List<HeadCount__c> getOpenHeadcountForCurrentUser() {
       try {
           return [select id, Name, Headcount_Name__c from Headcount__c where Hiring_Manager__c =:UserInfo.getUserId() and Status__c in ('Open - New', 'Open - Backfill')];
       } catch(Exception e) {
           System.debug('Error returning Headcount:' + e);
           return new List<Headcount__c>();
       }   
    }



}