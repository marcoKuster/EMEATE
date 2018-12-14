@IsTest
public class ADM_TeamReleaseExtensionTest {
    
    @IsTest
    static void testADM_TeamReleaseExtension() {

        Test.startTest();

        ADM_Sprint__c sprint = ADM_ReleaseBurndownUtils.createTestClosedSprint();
        List<ADM_Work__c> works = [select id, Product_Tag__c, Scheduled_Build__c, Scrum_Team__c from ADM_Work__c where Sprint__c =:sprint.id];
        String build = works[0].Scheduled_Build__c;
        ADM_Work__c work = works[0];
        
        //update the team of the Product Tag autocreated in setupTestWork() to match the team used on the team release record.  
        ADM_Product_Tag__c tag = [select id, Name from ADM_Product_Tag__c where id =:work.Product_Tag__c];
        tag.Team__c = sprint.Scrum_Team__c;
        update tag;
        //ensure scrum team is populated
        work.Scrum_Team__c = sprint.Scrum_Team__c;
        update work;
        
        //process release burn down
        ADM_ReleaseBurndownUtils.updateReleaseBurndownsBulk(new Set<Id>{sprint.id});
    
        Test.stopTest();
    
        //assert team release was created       
        List<ADM_Team_Release__c> teamReleases = [select id, Scrum_Team__c, Scrum_Team__r.Name, Build__c from ADM_Team_Release__c where Build__c = :build];
        
        System.assert(teamReleases != null);
        System.assertEquals(1, teamReleases.size(), 'Found unexpeted # of team releases for build:' + build);
        
        ADM_Team_Release__c tRelease = teamReleases[0];

        ApexPages.StandardController stdController = new ApexPages.StandardController(tRelease);
        ADM_TeamReleaseExtension controller = new ADM_TeamReleaseExtension(stdController);
        String releaseID = tRelease.id;
        String buildID = tRelease.Build__c;
        String scrumTeamID = tRelease.Scrum_Team__c;
        
        System.assert(controller != null);
        System.assertEquals(releaseID.substring(0, 15), controller.getTeamReleaseId15());
        System.assertEquals(buildID.substring(0, 15), controller.getBuildID15());
        System.assertEquals(tRelease.Scrum_Team__r.Name, controller.getScrumTeamName());

    }
   
}