@IsTest
public with sharing class ADM_AgeOfWorkTests {



	/*  

	  @testcaseID a0B20000007m1cREAQ

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Scrum Team Last Modified field is updated 
	  
	  @author jhatton

	*/ 
	
	/* 

	  @testcaseID a0B20000007m1qFEAQ

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Verify that age of scrum team defaults to the last scrum team when changing  to different scrum teams for bugs
	  
	  @author jhatton

	*/ 
	
	/* 

	  @testcaseID a0B20000007m0ZzEAI

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Verify age with scrum team resets to zero when changing scrum teams on a bug from the UI
	  
	  @author jhatton

	*/ 
	
	static testMethod void testScrumTeamLastModifiedIsUpdatedWhenScrumTeamChanges() {
		ADM_Work__c work = ADM_Work.createTestWork();
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('New Team Name Test');
		work.Scrum_Team__c = team.id;
		update work;
		work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
		System.assert(work.Scrum_Team_Last_Modified__c != null);
		System.assertEquals(0, work.Age_With_Scrum_Team__c);
		
	}  
	
	/* 

	  @testcaseID a0B20000007m0a5EAA

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: age with scrum team resets to zero when deleting scrum teams on a bug
	  
	  @author jhatton

	*/ 
	
	static testMethod void testScrumTeamLastModifiedIsUpdatedWhenScrumTeamIsRemoved() {
		ADM_Work__c work = ADM_Work.createTestWork();
		work.Scrum_Team__c = null;
		update work;
		work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
		System.assert(work.Scrum_Team_Last_Modified__c != null);
		System.assertEquals(0, work.Age_With_Scrum_Team__c);
		
	} 
	
	/* 

	  @testcaseID a0B20000007m1qGEAQ

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Verify that age of scrum team defaults to the last scrum team when changing  to different scrum teams for user stories
	  
	  @author jhatton

	*/ 
	
	/* 

	  @testcaseID a0B20000007m0a4EAA

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Scrum Team Last Modified field is updated 
	  
	  @author jhatton

	*/ 
	
	/* 

	  @testcaseID a0B20000007m0aJEAQ

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Verify that changing the name of a scrum team doesn't affect the bug age 
	  
	  @author jhatton

	*/
	
	static testMethod void testScrumTeamLastModifiedIsUpdatedWhenScrumTeamChangesForUserStory() {
		ADM_Work__c work = ADM_Work.createTestWork('User Story');
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('New Team Name Test');
		work.Scrum_Team__c = team.id;
		update work;
		work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
		System.assert(work.Scrum_Team_Last_Modified__c != null);
		System.assertEquals(0, work.Age_With_Scrum_Team__c);
		
	} 
	
	/* 

	  @testcaseID a0B20000007m1hbEAA

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Verify new user stories in open status show an actual bug age
	  
	  @author jhatton

	*/ 
	
	/* 

	  @testcaseID a0B20000003xGsBEAU

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Verify new work in open status show an actual bug age
	  
	  @author jhatton

	*/ 
	
	static testMethod void testAgeForUserStory() {
		ADM_Work__c work = ADM_Work.createTestWork('User Story');
		
		work = [select id, Age__c from ADM_Work__c where id = :work.id];
		System.assert(work.Age__c != null);
		System.assertEquals(0, work.Age__c); //expect 0 as its less then 1 day old
		
	}
	
	/* 

	  @testcaseID a0B20000007m1f1EAA

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Verify age doesn't change when changing record types
	  
	  @author jhatton

	*/ 
	
	static testMethod void testAgeRemainsTheSameWhenChangingFromBugToUserStory() {
		ADM_Work__c work = ADM_Work.createTestWork('Bug');
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('New Team Name Test');
		work.Scrum_Team__c = team.id;
		update work;
		work = [select id, Age__c from ADM_Work__c where id = :work.id];
		System.assert(work.Age__c != null);
		System.assertEquals(0, work.Age__c); //expect 0 as its less then 1 day old
		work.RecordTypeId = [ Select Id from RecordType r Where Name = 'User Story'].Id;
		update work;
		work = [select id, Age__c from ADM_Work__c where id = :work.id];
		System.assert(work.Age__c != null);
		System.assertEquals(0, work.Age__c); //expect 0 as its less then 1 day old
		
	}  
	
	/* 

	  @testcaseID a0B20000007m20uEAA

	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age

	  @userstory TO BE ADDED

	  @expectedResults: Scrum Team Last Modified field is not updated when scrum team remains constant 
	  
	  @author jhatton

	*/ 
	
	static testMethod void testScrumTeamLastModifiedIsNotUpdatedIfScrumTeamRemainsTheSame() {
		ADM_Work__c work = ADM_Work.createTestWork();
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('New Team Name Test');
		work.Scrum_Team__c = team.id;
		update work;
		work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
		Datetime lastMod = work.Scrum_Team_Last_Modified__c;
		work.Subject__c = '123';
		update work;
		work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
		System.assert(work.Scrum_Team_Last_Modified__c != null);
		System.assertEquals(0, work.Age_With_Scrum_Team__c);
		//verfiy original time stamp remains as the last edit did not effect the scrum team
		System.assertEquals(lastMod, work.Scrum_Team_Last_Modified__c);
	} 
	
	/* 
	  @testcaseID a1DB00000000qm9
	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age
	  @userstory a07B0000000Dd2mIAC
	  @expectedResults:  Total age when closed is 0 when item is open
	  @author alexis williams
	*/ 

	/* 
	  @testcaseID a1DB00000000qmE
	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age
	  @userstory a07B0000000Dd2mIAC
	  @expectedResults:  Total age when closed is 0 when item is closed the same day
	  @author alexis williams
	*/ 

	/* 
	  @testcaseID a1DB00000000qmE
	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age
	  @userstory a07B0000000Dd2mIAC
	  @expectedResults: Total age when closed is 0 when item is closed the same day	 
	  @author alexis williams
	*/ 

	/* 
	  @testcaseID a1DB00000000qmF
	  @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Bug Age
	  @userstory a07B0000000Dd2mIAC
	  @expectedResults: Total age when closed is 0 when the created on import date is less than the closed date 
	  @author alexis williams
	*/ 
	static testMethod void testTotalAgeWhenClosed() {		
		ADM_Work__c work = ADM_Work.createTestWork();
		ADM_Build__c build = ADM_Build.createTestBuild();
		Test.startTest();
			//#1 Test to make sure the total age when closed is 0 becuase this is open
			work = [Select w.Total_Age_When_Closed__c From ADM_Work__c w Where w.Id =: work.Id];
			System.assertEquals(0, work.Total_Age_When_Closed__c);
			work.Status__c = 'Closed';
			work.Found_in_Build__c = build.Id;
			update work;
			//#2 Test to make sure the total age when closed is 0 becuase this was closed the same day
			work = [Select w.Total_Age_When_Closed__c From ADM_Work__c w Where w.Id =: work.Id];
			System.assertEquals(0, work.Total_Age_When_Closed__c);
			work.Created_On_import__c = System.now().addDays(-1);
			update work;		
			//#3 Test to make sure the total age when closed is 1 because it was "opened a day ago" according to the created on import date
			work = [Select w.Total_Age_When_Closed__c From ADM_Work__c w Where w.Id =: work.Id];
			System.assertEquals(1, work.Total_Age_When_Closed__c);
			work.Created_On_import__c = System.now().addDays(1);
			update work;		
			//#4 Test to make sure the total age when closed is 0 becuase the created on import date is less than the closed date which does not make sense
			work = [Select w.Total_Age_When_Closed__c From ADM_Work__c w Where w.Id =: work.Id];
		Test.stopTest();
		System.assertEquals(0, work.Total_Age_When_Closed__c);						
	}


}