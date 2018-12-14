@isTest
private class AgileManager_PostInstallScriptsTest {

    static testMethod void testonInstall() {    
        AgileManager_PostInstallScripts postinstall = new AgileManager_PostInstallScripts();
        
        List<ADM_Impact__c> impacts = [Select id from ADM_Impact__c]; 
        List<ADM_Frequency__c> frequencies = [Select id from ADM_Frequency__c];
        List<ADM_Priority__c> priorities = [Select id from ADM_Priority__c];
        List<ADM_Priority_Mapping__c> pMappings = [Select id from ADM_Priority_Mapping__c];
        List<ADM_Type__c> types = [select id from ADM_Type__c];
        List<ADM_Impact_Type__c> impactTypes = [Select id from ADM_Impact_Type__c];
        List<ADM_Scrum_Team__c> teams = [select id from ADM_Scrum_Team__c];
        List<ADM_Scrum_Team_Member__c> teamMembers = [select id from ADM_Scrum_Team_Member__c];
        List<ADM_Sprint__c> sprints = [Select id from ADM_Sprint__c];
        List<ADM_Build__c> builds = [Select id from ADM_Build__c];
        List<ADM_Product_Tag__c> pTags = [Select id from ADM_Product_Tag__c];
        List<ADM_Assignment_Rule__c> rules = [Select id from ADM_Assignment_Rule__c];
        List<ADM_Tag_Assignment__c> tagAssignments = [Select id from ADM_Tag_Assignment__c];
        List<ADM_Epic__c> epics = [Select id from ADM_Epic__c];
        List<ADM_Work__c> works = [Select id from ADM_Work__c];
        
        System.assertEquals(0, impacts.size());
        System.assertEquals(0, frequencies.size());
        System.assertEquals(0, priorities.size());
        System.assertEquals(0, pMappings.size());
        System.assertEquals(0, impactTypes.size());
        System.assertEquals(0, teams.size());
        System.assertEquals(0, teamMembers.size());
        System.assertEquals(0, sprints.size());
        System.assertEquals(0, builds.size());
        System.assertEquals(0, pTags.size());
        System.assertEquals(0, rules.size());
        System.assertEquals(0, tagAssignments.size());
        System.assertEquals(0, epics.size());
        //System.assertEquals(0, works.size());

        Test.testInstall(postinstall, null);
        impacts = [Select id from ADM_Impact__c];
        frequencies = [Select id from ADM_Frequency__c];
        priorities = [Select id from ADM_Priority__c];
        pMappings = [Select id from ADM_Priority_Mapping__c];
        types = [select id from ADM_Type__c];
        impactTypes = [Select id from ADM_Impact_Type__c];
        teams = [select id from ADM_Scrum_Team__c];
        teamMembers = [select id from ADM_Scrum_Team_Member__c];
        sprints = [Select id from ADM_Sprint__c];
        builds = [Select id from ADM_Build__c];
        pTags = [Select id from ADM_Product_Tag__c];
        rules = [Select id from ADM_Assignment_Rule__c];
        tagAssignments = [Select id from ADM_Tag_Assignment__c];
        epics = [Select id from ADM_Epic__c];
        works = [Select id from ADM_Work__c];
            
        System.assertEquals(true, impacts.size()>0,'Expected impacts to be created by post install scripts');
        System.assertEquals(true, frequencies.size()>0,'Expected frequencies to be created by post install scripts');
        System.assertEquals(true, priorities.size()>0,'Expected priorities to be created by post install scripts');
        System.assertEquals(true, pMappings.size()>0,'Expected pMappings to be created by post install scripts');
        System.assertEquals(true, impactTypes.size()>0,'Expected impactTypes to be created by post install scripts');
        System.assertEquals(true, teams.size()>0,'Expected teams to be created by post install scripts');
        System.assertEquals(true, teamMembers.size()>0,'Expected teamMembers to be created by post install scripts');
        System.assertEquals(true, sprints.size()>0,'Expected sprints to be created by post install scripts');
        System.assertEquals(true, builds.size()>0,'Expected builds to be created by post install scripts');
        System.assertEquals(true, pTags.size()>0,'Expected pTags to be created by post install scripts');
        System.assertEquals(true, rules.size()>0,'Expected rules to be created by post install scripts');
        System.assertEquals(true, tagAssignments.size()>0,'Expected tagAssignments to be created by post install scripts');
        System.assertEquals(true, epics.size()>0,'Expected epic to be created by post install scripts');
        System.assertEquals(true, works.size()>0,'Expected works to be created by post install scripts');

    }



}