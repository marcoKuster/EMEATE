@isTest
private class ADM_FeatureFreezeUtilsTest {

    @isTest
    public static ADM_Team_Release__c setupTeamRelease() {
    	
        Test.startTest();
		ADM_Sprint__c sprint = ADM_ReleaseBurndownUtils.createTestClosedSprint();
		List<ADM_Work__c> works = [select id, Scheduled_Build__c, Product_Tag__c, Scrum_Team__c from ADM_Work__c where Sprint__c =:sprint.id];
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
		
		return tRelease;
    	
    	
    }
        /*
	@testcaseID a1DB00000001IJE
	@userstoryID a07B0000000G2EMIA0
	@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Release Support Information.New Feature Freeze Team Status
	@expected results Dashboards for #of P0 blocking bugs, # of bugs to verify per QE, # of bugs to fix per Dev, Open User Stories, # of open test failures > 1 week and # of TF per Dev appear under the "FF criteria status dashboard" section
	@author: jhatton
	*/

    static testMethod void testFeatureFreezeMetricsDashboard() {
    	   	ADM_Team_Release__c tr = setupTeamRelease();
			        
	        //file for feature freeze
	        ADM_Feature_Freeze_Status__c ffs = new ADM_Feature_Freeze_Status__c();
			ffs.Team_Release__c = tr.id;
            ffs.Team_Signoff_Status__c = 'Yes / meets criteria';
			insert ffs;
			ApexPages.StandardController stdC = new ApexPages.StandardController(ffs);
			ADM_FeatureFreezeChartsController ffc = new ADM_FeatureFreezeChartsController(stdC);
			//TODO how to assert correct behavior of code which relies on custom setting that will not
			//be populated when this code first deploys and will therefore cause tests to fail and block deployment
			try {
				ffc.getBlockingBugsReportID();
				ffc.getBlockingBugsReportParams();
				ffc.getBugsToVerifyReportID();
				ffc.getBugsToVerifyReportParams();
				ffc.getOpenBugsReportID();
				ffc.getOpenBugsReportParams();
				ffc.getOpenUserStoriesReportID();
				ffc.getOpenUserStoriesReportParams();
				ffc.getOpenTestFailuresReportID();
				ffc.getOpenTestFailuresByDevReportParams();
				ffc.getOpenTestFailuresByDevReportID();
				ffc.getOpenTestFailuresByDevReportParams();
			} catch(Exception e) {
				System.debug('exception in testFeatureFreezeMetricsDashboard:' + e);
			}	
			
    	
    }
    
    	/*
	@testcaseID a1DB00000000ryC
	@userstoryID a07B0000000ECUTIA4
	@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Release Support Information.New Feature Freeze Team Status
	@expected results The Number of Open User Stories (0) on Feature Freeze Team Status page shows the following formulated number: # of open user stories for that team and build
	@author: jhatton
	*/
	
    
    static testMethod void testCountOpenUserStoriesByTeamAndBuild() {
        ADM_Team_Release__c tr = setupTeamRelease();
		//open a story
		ADM_Work__c work = ADM_Work.setupTestWork('User Story');
		//update the team of the Product Tag autocreated in setupTestWork() to match the team used on the team release record.  
		ADM_Product_Tag__c tag = [select id, Name from ADM_Product_Tag__c where id =:work.Product_Tag__c];
		tag.Team__c = tr.Scrum_Team__c;
		update tag;
		work.Scheduled_Build__c = tr.Build__c;
		work.Scrum_Team__c = tr.Scrum_Team__c; 
        work.Priority__c = 'P1';
        insert work;
        
        //file for feature freeze
        ADM_Feature_Freeze_Status__c ffs = new ADM_Feature_Freeze_Status__c();
		ffs.Team_Release__c = tr.id;
        ffs.Team_Signoff_Status__c = 'Yes / meets criteria';
		insert ffs;
		
		//expect 2 - one story with the initial team release and one we just created
		System.assertEquals(2, [select Number_Of_Open_User_Stories_0__c from ADM_Feature_Freeze_Status__c where id =:ffs.id].Number_Of_Open_User_Stories_0__c);
    }
    
    	/*
	@testcaseID a1DB00000000ryH
	@userstoryID a07B0000000ECUTIA4
	@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Release Support Information.New Feature Freeze Team Status
	@expected results The Number of P0/Blocking Bugs (0) on Feature Freeze Team Status page shows the following formulated number: # of open P0 bugs for that team and build
	@author: jhatton
	*/
	
    static testMethod void testCountOpenBugsByTeamAndBuild() {
        ADM_Team_Release__c tr = setupTeamRelease();
		//open a story
		ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P1', 'Bug');
		//update the team of the Product Tag autocreated in setupTestWork() to match the team used on the team release record.  
		ADM_Product_Tag__c tag = [select id, Name from ADM_Product_Tag__c where id =:work.Product_Tag__c];
		tag.Team__c = tr.Scrum_Team__c;
		update tag;
		work.Scheduled_Build__c = tr.Build__c;
		work.Found_In_Build__c = tr.Build__c;
		work.Scrum_Team__c = tr.Scrum_Team__c;
		insert work;
        
        //file for feature freeze
        ADM_Feature_Freeze_Status__c ffs = new ADM_Feature_Freeze_Status__c();
		ffs.Team_Release__c = tr.id;
        ffs.Team_Signoff_Status__c = 'Yes / meets criteria';
		insert ffs;
		
		System.assertEquals(1, [select Number_of_Bugs_to_Fix_max_1_Dev__c from ADM_Feature_Freeze_Status__c where id =:ffs.id].Number_of_Bugs_to_Fix_max_1_Dev__c);
    }
    
    	/*
	@testcaseID a1DB00000000ryM
	@userstoryID a07B0000000ECUTIA4
	@hierarchy GUS.ScrumforceToGUS.ScrumTeams.Release Support Information.New Feature Freeze Team Status
	@expected results The Number of Bugs to Verify (max 1/QE) on Feature Freeze Team Status page shows the following formulated number: # of bugs in QA in progress for that team and build
	@author: jhatton
	*/
	
    static testMethod void testCountUntestedBugsByTeamAndBuild() {
        ADM_Team_Release__c tr = setupTeamRelease();
		//open a story
		ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P1', 'Bug');
		//update the team of the Product Tag autocreated in setupTestWork() to match the team used on the team release record.  
		ADM_Product_Tag__c tag = [select id, Name from ADM_Product_Tag__c where id =:work.Product_Tag__c];
		tag.Team__c = tr.Scrum_Team__c;
		update tag;
		work.Scheduled_Build__c = tr.Build__c;
		work.Found_In_Build__c = tr.Build__c;
		work.Scrum_Team__c = tr.Scrum_Team__c;
		work.Status__c = 'Fixed';
		work.QA_Engineer__c = UserInfo.getUserId();
		insert work;
        
        //file for feature freeze
        ADM_Feature_Freeze_Status__c ffs = new ADM_Feature_Freeze_Status__c();
		ffs.Team_Release__c = tr.id;
		ffs.Team_Signoff_Status__c = 'Yes / meets criteria';
		insert ffs;
		
		System.assertEquals(1, [select Number_of_Bugs_to_Verify_max_1_QE__c from ADM_Feature_Freeze_Status__c where id =:ffs.id].Number_of_Bugs_to_Verify_max_1_QE__c);
    }
    
    /* TODO:
    	Previous tests tally counts on creation of the Feature Freeeze Status record.  We also need tests to verify the record is kept up to date 
    	as work changes.
    	
    	However both the Team Release creation and the Feature Freeze Status updates are done asynchrnously.  Apex tests only allow one Test.start/stop
    	call per test.  
    		- Therefore if you use Test.start/stop on the creation of the team release record your Feature Freeze status asserts will always fail (as they haven't 
    		completed yet).
    		- Alternatively stubbing out a synthentic Team Release record reduces the realism and usefullness of the tests
    		-Sharing state (such as a team release record) between tests can lead to flappers and hard to debug failures due to one test leaving the
    		shared data in a format the next test wasn't expecting.  
    */		  
    
    static testMethod void testUpdateFeatureFreezeStatus() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P1', 'Bug');
        work.Status__c = 'Fixed';
        work.QA_Engineer__c = UserInfo.getUserId();
        insert work;
        
        ADM_Team_Release__c tr = new ADM_Team_Release__c();
        tr.Scrum_Team__c = work.Scrum_Team__c;
        tr.Build__c = work.Scheduled_Build__c;
        insert tr;
        
        //file for feature freeze
        ADM_Feature_Freeze_Status__c ffs = new ADM_Feature_Freeze_Status__c();
        ffs.Team_Release__c = tr.id;
        ffs.Team_Signoff_Status__c = 'Yes / meets criteria';
        insert ffs;
        
        ADM_Work__c work2 = ADM_Work.setupTestWork('Bug', 'P1', 'Bug');
        work2.Product_Tag__c = work.Product_Tag__c;
        work2.Scheduled_Build__c = work.Scheduled_Build__c;
        work2.Found_In_Build__c = work.Found_In_Build__c;
        work2.Scrum_Team__c = work.Scrum_Team__c;
        work2.Status__c = 'Fixed';
        work2.QA_Engineer__c = UserInfo.getUserId();
        insert work2;
        
        Test.startTest();
    	ADM_FeatureFreezeUtils.updateFeatureFreezeStatus(new List<ADM_Work__c>{work, work2}, new List<ADM_Work__c>{work, work2}, true);
    	Test.stopTest();
    	
    	ffs = [select Id, Number_of_Bugs_to_Verify_max_1_QE__c
                 from ADM_Feature_Freeze_Status__c 
                 where id = :ffs.Id];
        System.assertEquals(2, ffs.Number_of_Bugs_to_Verify_max_1_QE__c);
    }
    
    static testMethod void testUpdateSingleDevelopmentCycleStatus() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P1', 'Bug');
        work.Status__c = 'Fixed';
        work.QA_Engineer__c = UserInfo.getUserId();
        insert work;
        
        ADM_Team_Release__c tr = new ADM_Team_Release__c();
        tr.Scrum_Team__c = work.Scrum_Team__c;
        tr.Build__c = work.Scheduled_Build__c;
        insert tr;
        
        //file for feature freeze
        ADM_Feature_Freeze_Status__c ffs = new ADM_Feature_Freeze_Status__c();
        ffs.Team_Release__c = tr.id;
        ffs.Team_Signoff_Status__c = 'Yes / meets criteria';
        insert ffs;
        
        ADM_Work__c work2 = ADM_Work.setupTestWork('Bug', 'P1', 'Bug');
        work2.Product_Tag__c = work.Product_Tag__c;
        work2.Scheduled_Build__c = work.Scheduled_Build__c;
        work2.Found_In_Build__c = work.Found_In_Build__c;
        work2.Scrum_Team__c = work.Scrum_Team__c;
        work2.Status__c = 'Fixed';
        work2.QA_Engineer__c = UserInfo.getUserId();
        insert work2;
        
        Test.startTest();
        ADM_FeatureFreezeUtils.updateSingleDevelopmentCycleStatus(ffs.Id);
        Test.stopTest();
        
        ffs = [select Id, Number_of_Bugs_to_Verify_max_1_QE__c
                 from ADM_Feature_Freeze_Status__c 
                 where id = :ffs.Id];
        System.assertEquals(2, ffs.Number_of_Bugs_to_Verify_max_1_QE__c);
    }
}