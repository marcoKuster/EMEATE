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
private class ADM_ScrumTeamWorkExtensionTest {
	private static Apexpages.Pagereference create = Page.ADM_selectWorkRecordType;

/*
 @testcaseID  a1DB00000000kT4
 @userstoryID a07B0000000DlSE
 @Hierarchy GUS.ScrumforcetoGUS.ScrumTeams.New Chatter Group
 @ExpectedResults The same characters saved on create team page should show on the team page without breaking the page
 @Author = Alexis Williams
 */

    static testMethod void testGetChatterGroupsWithJunk() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        work.Scrum_Team__c = team.Id;
        story.Scrum_Team__c = team.Id;
        
        String gusUrl = ADM_WorkUtils.GUS_URL;
        
        List<ADM_Work__c> works = new List<ADM_Work__c>();
        works.add(work);
        works.add(story);
                        
        update works;
        
        team.Chatter_Groups__c = 'Junk!';
        update team;
        
        System.currentPageReference().getParameters().put('id', team.id);        
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(team);        
        ADM_ScrumTeamWorkExtension extension = new ADM_ScrumTeamWorkExtension(controller);
        
        System.assertEquals('Junk!', extension.getChatterGroups());
    }
    
    /*
 @testcaseID  a1DB00000000kT5
 @userstoryID a07B0000000DlSE
 @Hierarchy GUS.ScrumforcetoGUS.ScrumTeams.New Chatter Group
 @ExpectedResults User should be able to see the link to the public, private groups and the junk should show as it was written in edit Team page
 @Author = Alexis Williams
 */

    static testMethod void testGetChatterGroupsWithPuplicAndPrivateAndJunk() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        work.Scrum_Team__c = team.Id;
        story.Scrum_Team__c = team.Id;
        
        String gusUrl = ADM_WorkUtils.GUS_URL;
        
        List<ADM_Work__c> works = new List<ADM_Work__c>();
        works.add(work);
        works.add(story);
                        
        update works;
        
        System.currentPageReference().getParameters().put('id', team.id);        
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(team);        
        ADM_ScrumTeamWorkExtension extension = new ADM_ScrumTeamWorkExtension(controller);
        
        System.assertEquals('', extension.getChatterGroups());
        
        CollaborationGroup group1 = new CollaborationGroup();
        group1.Name = String.valueOf(Math.random());
        group1.CollaborationType = 'Public';
        
        CollaborationGroup group2 = new CollaborationGroup();
        group2.Name = String.valueOf(Math.random());
        group2.CollaborationType = 'Private';
        
        List<CollaborationGroup> groups = new List<CollaborationGroup>{group1, group2};
        insert groups;
        
        team.Chatter_Groups__c = String.valueOf(group1.Id);
        update team;
        
        String group1Url = '<a href="' + gusUrl +  '/_ui/core/chatter/groups/GroupProfilePage?g=' + group1.Id + '" target="_blank">' + group1.Id + '</a>';
        String group2Url = '<a href="' + gusUrl +  '/_ui/core/chatter/groups/GroupProfilePage?g=' + group2.Id + '" target="_blank">' + group2.Id + '</a>'; 
        
        System.assertEquals(group1Url, extension.getChatterGroups());
        
        team.Chatter_Groups__c += ', ' + String.valueOf(group2.Id);
        update team;
        
        System.assertEquals(group1Url + ', ' + group2Url, extension.getChatterGroups());
        
        team.Chatter_Groups__c += ', Junk!';
        update team;
                
        System.assertEquals(group1Url + ', ' + group2Url + ', Junk!', extension.getChatterGroups());
	}

/*
 @testcaseID  a1DB00000000kSy
 @userstoryID a07B0000000DlSE
 @Hierarchy GUS.ScrumforcetoGUS.ScrumTeams.New Chatter Group
 @ExpectedResults The chatter group field doesn't recognize the bogus ID
 @Author = Alexis Williams
 */

    static testMethod void testWithWork() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = [select id, Name from ADM_Scrum_Team__c where id =:work.Scrum_Team__c];
        //setting the product tag makes sure work and story belong to the same scrum team
        story.Product_Tag__c = work.Product_Tag__c;
        
        List<ADM_Work__c> works = new List<ADM_Work__c>();
        works.add(work);
        works.add(story);
                        
        update works;
        
        System.currentPageReference().getParameters().put('id', team.id);        
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(team);        
        ADM_ScrumTeamWorkExtension extension = new ADM_ScrumTeamWorkExtension(controller);
        System.assert(extension.getWorks().size() == 2);
        System.assert(extension.rowEnd == 2, 'Expected rowEnd to be 2 ->' + extension.rowEnd);
        System.assert(extension.rowStart == 1, 'Expected rowEnd to be 1 ->' + extension.rowStart);
        System.assert(extension.workWrapper.size() != 0, 'Did not exptect to see any work wrapper populated! ->' + extension.workWrapper);
        extension.setController.setPageSize(1);
        extension.setController.next();
        System.assert(extension.rowEnd == 2, 'Expected rowEnd to be 2 ->' + extension.rowEnd);
        System.assert(extension.rowStart == 2, 'Expected rowEnd to be 2 ->' + extension.rowStart);
        extension.setController.next();
        System.assert(extension.rowStart == 2, 'Expected rowEnd to be 2 ->' + extension.rowStart);
        System.assert(extension.showNotecards().getUrl() != null, 'Did not get URL I was looking for->' + extension.showNotecards().getUrl());
    }

    static testMethod void testUpdateTeamDetails() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeamAndCloud('testCloud');
        insert team;
        //Create a new cloud but don't save yet
				ADM_Parent_Cloud__c parentCloud = new ADM_Parent_Cloud__c(Name='TestTeamUpdateCloud');
        insert parentCloud;
        ADM_Cloud__c newCloud = new ADM_Cloud__c(Name='TestTeamUpdateCloud');
				newCloud.Parent_Cloud__c = parentCloud.id;
        insert newCloud;
        
        
        System.assertNotEquals(team.Name, 'TestTeamForUpdate','Asserting team name is not what we will use.');
        System.assertNotEquals(team.Cloud_LU__c,newCloud.Id, 'Asserting team cloud is not what we will use.');
        
        //Update team name
        team.Name = 'TestTeamForUpdate';
        //Update cloud
        team.Cloud_LU__c = newCloud.Id;

        //Update team details now
        ADM_ScrumTeamWorkExtension.updateTeamDetails(team);
        
        //Check if team updates are saved
        System.assertEquals(team.Name, 'TestTeamForUpdate', 'Team name is updated');
        System.assertEquals(team.Cloud_LU__c, newCloud.Id, 'Team cloud is updated');
    }

/*
 @testcaseID  a1DB00000000kTi
 @userstoryID a07B0000000DlSE
 @Hierarchy GUS.ScrumforcetoGUS.ScrumTeams.New Chatter Group
 @ExpectedResults The chatter group field doesn't display any ID
 @Author = Alexis Williams
 */

    static testMethod void testWithoutWork() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();        
        List<ADM_Work__c> works = new List<ADM_Work__c>();     
        
        System.currentPageReference().getParameters().put('id', team.id);        
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(team);        
        ADM_ScrumTeamWorkExtension extension = new ADM_ScrumTeamWorkExtension(controller);
        
        Pagereference pr = Page.ADM_WorkPrioritizer;
        
        System.assert(extension.getWorks().size() == 0, 'Did not expect to see any work records! ->' + extension.getWorks());
        System.assert(extension.getMessage() == 'No records to display', 'Expected to a message!');
        System.assert(extension.workWrapper.size() == 0, 'Did not exptect to see any work wrapper populated! ->' + extension.workWrapper);
        System.assert(extension.rowEnd == 0, 'Expected rowEnd to be 0 ->' + extension.rowEnd);
        System.assert(extension.rowStart == 0, 'Expected rowEnd to be 0 ->' + extension.rowStart);
        System.assert(extension.create().getUrl() == create.getUrl(), 'Got something I was not expecting->' + extension.create().getUrl());
        System.assert(extension.prioritize().getUrl().contains(pr.getUrl()), 'extension prioritize does not contain pr?->' + extension.prioritize().getUrl() + ' pr->' + pr.getUrl());
    }
    
/*
 @testcaseID  a1DB00000000qMs
 @userstoryID a07B0000000EV6RIAW
 @Hierarchy GUS.BugforceToGUS.SystemIntegrations.Locking Record
 @ExpectedResults No error message should be displayed for the team
 @Author = Alexis Williams
 */
    static testMethod void testGetLock() {
   	 	ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();        
        System.currentPageReference().getParameters().put('id', team.id);        
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(team);        
        ADM_ScrumTeamWorkExtension ext = new ADM_ScrumTeamWorkExtension(controller);
        
        System.assertEquals('', ext.getLock().message);	
    }


/*
@testcaseID a1DB00000000x08
@userstory a07B00000008zabIAA
@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Team Information.Sticky Tab
@expected results User should be taken to the Team Information tab
@author: Alexis Williams
*/
    
    static testMethod void testActiveSprintTabWithNoCookies() {
    	ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();       
        System.currentPageReference().getParameters().put('id', team.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(team);
        ADM_ScrumTeamWorkExtension sc = new ADM_ScrumTeamWorkExtension(stdController);
        
        System.assertEquals('info', sc.cookie.activeTab);
        System.assertEquals('info', sc.cookie.defaultTabName);
    }
    
/*
@testcaseID a1DB00000000x0C
@userstory a07B00000008zabIAA
@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Team Information.Sticky Tab
@expected results User should go back to the Team tab where he/she left off
@author: Alexis Williams
*/

    static testMethod void testActiveSprintTabWithCookies() {
    	ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();       
        System.currentPageReference().getParameters().put('id', team.id);
    	Cookie acTab = new Cookie(team.Id, 'stories', null, -1, false);
    	Apexpages.currentPage().setCookies(new Cookie[]{acTab});
        ApexPages.StandardController stdController = new ApexPages.StandardController(team);
        ADM_ScrumTeamWorkExtension sc = new ADM_ScrumTeamWorkExtension(stdController);
        
        System.assertEquals('stories', sc.cookie.activeTab);
        System.assertEquals(team.Id, sc.cookie.name);
    }

/*
@testcaseID a1DB00000000wyZ
@userstory a07B00000008zabIAA
@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Team Information.Sticky Tab
@expected User should go back to the team tab where he/she left off and tabs names should be left intact
@author: Alexis Williams
*/

    static testMethod void testTabs() {
    	ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();       
        System.currentPageReference().getParameters().put('id', team.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(team);
        ADM_ScrumTeamWorkExtension sc = new ADM_ScrumTeamWorkExtension(stdController);
        Set<String> fieldLabels = new Set<String>{'Team Information...', 'Assignments', 'Sprints', 'Dependencies', 'Release Support Information'};
        Set<String> fieldNames = new Set<String>{'info', 'stories', 'sprints', 'dependencies', 'releaseInfo'};
        
        List<ADM_FieldWrapper> tabs = sc.tabs;
        Integer foundCounter = 0;
        
        for(ADM_FieldWrapper tab : tabs) {
        	if(fieldLabels.contains(tab.fieldLabel)) {
        		foundCounter++;
        	}
        	if(fieldNames.contains(tab.fieldName)) {
        		foundCounter++;
        	}
        }
        
        System.assertEquals(10, foundCounter);
    }   
/*
@testcaseID a1DB00000000HcL
@userstory a07B0000000VGMhIAO
@hierarchy GUS.ScrumTeams.Team Information.Edit Scrum Team page
@expected results the scrum team saves, the name changes on the scrum team page, and under the work items as well
*/

	static testMethod void testDoSaveAndTeamDetail() {
    	ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
		User testUser = ADM_WorkUser.createTestUser();
		ADM_Scrum_Team_Member__c teamMember = new ADM_Scrum_Team_Member__c();
		teamMember.Member_Name__c = testUser.Id;
		teamMember.Scrum_Team__c = team.Id;
		String expectedURL = '/' + team.Id;
		ApexPages.StandardController controllerObj = new ApexPages.StandardController(teamMember);
		ADM_ScrumTeamWorkExtension extension = new ADM_ScrumTeamWorkExtension(controllerObj);
		Pagereference pageref = extension.doSaveAndTeamDetail();
		
		System.assert(pageref != null, 'Expected doSaveAndDetail to never return null');
		System.assertEquals(expectedURL, pageref.getUrl(), 'Expected the page to go to the team detail page');
	}



}