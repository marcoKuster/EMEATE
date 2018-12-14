@isTest
public with sharing class ADM_ScrumTeamTriggerTest { 
	
	/*
	@testcaseID a1DB00000000rsg
	@userstoryID  a0790000000DL4iAAG
	@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Team Information.Deactivate Scrum Team
	@expected results An error message occurs when deactivating scrum team: Review all error messages below to correct your data. There are X open records assigned to this team. Please close or re-assign these records before de-activating the team.
	@author: jhatton
	*/
	
	static testMethod void testScrumTeamCannotBeDeactivatedWithOpenWorkAssigned() {
		
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
		List <ADM_Work__c> works = ADM_Work.createListOfWork(3, 'Bug');
		//update the team of the Product Tag autocreated in setupTestWork() to match the team used on the team release record.  
		ADM_Product_Tag__c tag = [select id, Name from ADM_Product_Tag__c where id =:works.get(0).Product_Tag__c];
		tag.Team__c = team.id;
		update tag;
		//now make sure all of the work uses the same tag as tag and team are tightly coupled
		for(ADM_Work__c work : works) {
			work.Product_Tag__c = tag.id;
			work.Status__c = 'New';
		}
		
		insert works;
		//now try to deactivate the team
		try {
			team.Active__c = false;
			Database.update(team);
			System.assert(false, 'Test should have thrown a exception before it reached here');
		} catch (DmlException e) { 
            System.assert(e.getMessage().contains('There are ' + works.size() + ' open records assigned to this team.  Please close or re-assign these records before de-activating the team.'), e.getMessage());
        }
		
		
	}


	static testMethod void testScrumTeamDefinitionOfDoneCheckBox() {
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
		List<ADM_Scrum_Team__c> teams = [select id, Definition_of_Done__c,Definition_of_Done_Check__c from ADM_Scrum_Team__c where id =:team.id];
		System.assertEquals(ADM_TextUtils.isBlank(teams.get(0).Definition_of_Done__c),true);
		System.assertEquals(teams.get(0).Definition_of_Done_Check__c,false);
		team.Definition_of_Done__c = 'test text';
		update team;
		List<ADM_Scrum_Team__c> teams1 = [select id, Definition_of_Done__c,Definition_of_Done_Check__c from ADM_Scrum_Team__c where id =:team.id];
		System.assertEquals(teams1.get(0).Definition_of_Done_Check__c,true);
		ADM_Scrum_Team__c teamNew = teams1.get(0);
		teamNew.Definition_of_Done__c = '';
		update teamNew;
		List<ADM_Scrum_Team__c> teams2 = [select id, Definition_of_Done__c,Definition_of_Done_Check__c from ADM_Scrum_Team__c where id =:teamNew.id];
		System.assertEquals(teams2.get(0).Definition_of_Done_Check__c,false);

	}

	static testMethod void testScrumTeamDefinitionOfReadyCheckBox() {
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
		List<ADM_Scrum_Team__c> teams = [select id, Definition_of_Ready__c,Definition_of_Ready_Check__c from ADM_Scrum_Team__c where id =:team.id];
		System.assertEquals(ADM_TextUtils.isBlank(teams.get(0).Definition_of_Ready__c),true);
		System.assertEquals(teams.get(0).Definition_of_Ready_Check__c,false);
		team.Definition_of_Ready__c = 'test text';
		update team;
		List<ADM_Scrum_Team__c> teams1 = [select id, Definition_of_Ready__c,Definition_of_Ready_Check__c from ADM_Scrum_Team__c where id =:team.id];
		System.assertEquals(teams1.get(0).Definition_of_Ready_Check__c,true);

	}
	
	/*
	@testcaseID a1DB00000000rsj
	@userstoryID  a0790000000DL4iAAG
	@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Team Information.Deactivate Scrum Team
	@expected results User is able to deactivate scrum team without any warnings
	@author: jhatton
	*/
	
	static testMethod void testScrumTeamCanBeDeactivatedWithClosedWorkAssigned() {
		
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
		List <ADM_Work__c> works = ADM_Work.createListOfWork(3, 'Bug');
		//insert the work
		for(ADM_Work__c w : works) {
			w.Status__c = 'Closed';
			w.Scrum_Team__c = team.id;
		}
		insert works;
		//now try to deactivate the team
		try {
			team.Active__c = false;
			Database.update(team);
			System.assert(true, 'Test should have passed validation');
		} catch (DmlException e) { 
            System.assert(false, 'Did not expect this error as work assigned to team being deactivated is closed:' + e.getMessage());
        }
		
		
	}
	
	/* 
	@testcaseID a1DB00000001TE3
	@userstoryID  a07B0000000LIaaIAG
	@hierarchy GUS.ScrumforceToGUS.Position.Select Cloud
	@author James Hatton
	@exected results Applicable Headcount records have their Cloud updated when Scrum Team changes
	*/
	
	static testMethod void testHeadcountCloudIsUpdatedWhenScrumTeamCloudChanges() {
		//setup a test team
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
		
		//setup a test headcount record
        Headcount__c hc = new Headcount__c();
        User u1 = ADM_WorkUser.createTestUserWithRandomName();
        User u2 = ADM_WorkUser.createTestUserWithRandomName();
        hc.Hiring_Manager__c = u1.id;
        hc.Headcount_Name__c = u2.id;
        hc.Status__c = 'Filled';
        hc.Backfill_Date__c = System.today() +1;
        hc.Effective_Date__c = QuarterPeriod.getCurrentFiscalQuarterName();
        hc.Team__c = team.id;
        insert hc;	
		//now change the cloud on team
		team.Cloud__c = 'Data.com';
		update team;
		//verfiy Headcount was updated
		Headcount__c updatedHC = [select id, Cloud__c, Team__c from Headcount__c where id = : hc.id];
		System.assertEquals('Data.com', updatedHC.Cloud__c);
	}	

	/* Verify that New Kanban teams have default colors assigned to them */

	static testMethod void testDefaultColorCreatedForNewKanbanTeam() {
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
		 List <ADM_Color__c> color = [select id, Name from ADM_Color__c where Team__c =:team.id];
         System.assertEquals( 0,color.size(),'Non Kanban team should not have any colors assigned');
		 team.Kanban__c = true;
		 update team;
		 List <ADM_Color__c> defaultColor = [select id, Name from ADM_Color__c where Team__c =:team.id];
         System.assertEquals(6,defaultColor.size(), 'Kanban team should have default colors assigned');

	}

  /*
				If a different Team used the team name in the past then that attempt should be denied
  */
	static testMethod void testDenyTeamNameUpdateToNamePreviouslyUsedByADifferentTeam() {
		 ADM_Scrum_Team__c firstTeam = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
		 String teamNameBeforeChange = firstTeam.Name;
		 firstTeam.Name = 'StarWars!543@3';
		 update firstTeam;

		 ADM_Scrum_Team__c secondTeam = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
		 secondTeam.Name = teamNameBeforeChange;
		 try{
		 	update secondTeam;
            System.assert(false,' Expected DML Exception because secondTeam used team name used by firstTeam');

		 }
		 catch(DMLException exp){
            System.assert(exp.getMessage().containsIgnoreCase('Team Name "'+teamNameBeforeChange+'" was used by StarWars!543@3 Team in the past, please select a different Name'), exp.getMessage());
		 }

	}

	/*
				If a different Team used the team name in the past then that attempt should be denied - Team Name should not be allowed even with different Case.
	*/
	static testMethod void testTeamNameWithDifferentCaseIsDeniedIfUsedByDifferentTeam() {
		 ADM_Scrum_Team__c firstTeam = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
		 String teamNameBeforeChange = firstTeam.Name;
		 firstTeam.Name = 'StarWars!543@3';
		 update firstTeam;
		
		 ADM_Scrum_Team__c secondTeam = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
         String teamNameLowerCase = teamNameBeforeChange.toLowerCase();
         System.assertNotEquals(teamNameBeforeChange, teamNameLowerCase, 'Expected Previous Team names to be of different cases');
         secondTeam.Name = teamNameLowerCase;
		 try{
		 	update secondTeam;
            System.assert(false,' Expected DML Exception because secondTeam used team name used by firstTeam');
            
		 }
		 catch(DMLException exp){
            System.assert(exp.getMessage().containsIgnoreCase('Team Name "'+teamNameBeforeChange+'" was used by StarWars!543@3 Team in the past, please select a different Name'), exp.getMessage());
		 }

	}

	 static testMethod void testDenyNewTeamWithNamePreviouslyUsedByADifferentTeam() {
		 ADM_Scrum_Team__c firstTeam = ADM_ScrumTeam.createTestScrumTeam();
		 String teamNameBeforeChange = firstTeam.Name;
		 firstTeam.Name = 'StarWars!543@3';
		 update firstTeam;
		 
		 try{
		 ADM_Scrum_Team__c secondTeam = ADM_ScrumTeam.createTestScrumTeam();
		 
            System.assert(false,' Expected DML Exception because secondTeam used team name used by firstTeam');
            
		 }
		 catch(DMLException exp){
            System.assert(exp.getMessage().containsIgnoreCase('Team Name "'+teamNameBeforeChange+'" was used by StarWars!543@3 Team in the past, please select a different Name'), exp.getMessage());
		 }
		 

		

	}

	static testMethod void testAllowTeamToUsePastNames() {
		 ADM_Scrum_Team__c firstTeam = ADM_ScrumTeam.createTestScrumTeam();
		 String teamNameBeforeChange = firstTeam.Name;
		 firstTeam.Name = 'StarWars!543@3';
		 update firstTeam;
		 ADM_Scrum_Team__c teamQueried = [Select Name from ADM_Scrum_Team__c where id =:firstTeam.Id];
		 System.assertEquals('StarWars!543@3', teamQueried.Name, ' Expected team Name to be updated to StarWars!543@3');
		 firstTeam.Name = teamNameBeforeChange;
		 update firstTeam;
		 teamQueried = [Select Name from ADM_Scrum_Team__c where id =:firstTeam.Id];
		  System.assertEquals(teamNameBeforeChange, teamQueried.Name, ' Expected team Name to be updated to '+ teamNameBeforeChange);

		

	}


}