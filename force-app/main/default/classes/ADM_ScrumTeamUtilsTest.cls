/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ADM_ScrumTeamUtilsTest {
    static testMethod void test_createAndDeleteScrumteam() {
        Test.startTest();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('Yo Gabba Gabba');
        ADM_Scrum_Team__c teamFound;
        Test.stopTest();
        Group[] groups = [select Name, Type, Id from Group];
        Group groupFound;
        for(Group g : groups) {
            if(g.Type != null && g.Type == 'Regular') {
                if(g.Name != null && g.Name.contains(team.Name)) {
                    groupFound = g;
                    teamFound = [select Name, External_Name__c, Id, Team_Email_Group_Id__c from ADM_Scrum_Team__c where Team_Email_Group_Id__c = : groupFound.Id];
                    System.debug('here is groupFound ->' + groupFound + ' teamFound -> ' + teamFound);
                }
            }
        }
        
        System.assert(groupFound != null, 'did not find a matching group for this scrum team ' + team + ' here are all the groups ' + groups);
        System.assert(teamFound.External_Name__c.equalsIgnoreCase(teamFound.Name), 'the names did not match up! External_Name__c ->' + teamFound.External_Name__c + ' name ->' + teamFound.Name);
        
        delete team;
        
        System.assert([select count() from ADM_Scrum_Team_Cache__c where ScrumteamOrScrumteamMember__c = : team.Id and Deleted__c = true] == 1);
    }
    
    static testMethod void test_duplicateNameErrors() {
    	
        try { 
	        ADM_Scrum_Team__c team1 = ADM_ScrumTeam.createTestScrumTeam();
	        ADM_Scrum_Team__c team2 = ADM_ScrumTeam.createTestScrumTeam();
            System.assert(false, 'Test should have thrown a DML exception before it reached here');
        } catch (DmlException e) { 
            System.assert(e.getMessage().length() > 0, e.getMessage());
        }
    }
    
        /*
	@testcaseID a1DB00000001678
	@userstoryID a07B0000000FJKuIAO
	@Expected results Picklist shows values with special chars and user is able to select these numbers with special chars
	@Hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.Story Point Picklist
	Author: Alexis Williams
	*/

    static testMethod void testValidateStoryPoints() {
    	ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
    	team.Story_Point_Scale__c = 'a,b,c';
    	try {
    		update team;
    	} catch(DmlException e) {
    		System.assertEquals(true,e.getMessage().contains('Team story point scales can only contain digits and commas'));
    	}
    	team.Story_Point_Scale__c = '1,2,3';
    	update team;
    	team = [select Story_Point_Scale__c from ADM_Scrum_Team__c where Id =: team.Id];
    	System.assertEquals('1,2,3', team.Story_Point_Scale__c);
    }


    static testMethod void testGetStoryPointScaleByTeamIdReturnsDefault() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Story_Point_Scale__c = null;
        try {
            update team;
        } catch(DmlException e) {
            System.assertEquals(true,e.getMessage().contains('Team story point scales can only contain digits and commas'));
        }

        List<String> storyPointList = ADM_ScrumTeam.getStoryPointScaleByTeamId(team.Id);

        System.assertEquals(8, storyPointList.size(), 'Expected 8 story point values, found only ' + storyPointList.size());
    }
    
    static testMethod void testCapexEnabledTeam() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        System.assert(!team.Capex_Enabled__c, 'Capex_Enabled__c should default to false.');
        
        team.Capex_Enabled__c = true;
        
        update team;
        
        ADM_Scrum_Team__c capExTeam = ADM_ScrumTeam.get('Id', team.Id);
        
        System.assert(team.Capex_Enabled__c, 'Capex_Enabled__c flag should be set to true for this team.');
    }
}