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
private class ADM_SprintChartsControllerTest {

/*
@testcaseID a1DB00000000zJz
@userStoryID a07B0000000ELLTIA4
@Hierarchy GUS.ScrumforceToGUS.Sprint.Charts and Tasks.Team Velocity
@Expected Results: 
 Velocity Chart called "Team Velocity" is located on Charts & Task tab
 Y axis is the number of points (zero points)
 X axis is the sprint in chronological order (1 sprint)
 Average velocity is one flat line (no velocity yet)
 Actual velocity is one flat line (no velocity yet)
 Legend Average Velocity and Actual Velocity shows on right hand side
@Author: Alexis Williams
*/

    static testMethod void testWithNewTeam() {
        ADM_SprintChartsController controller = new ADM_SprintChartsController();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(); 
        controller.m_teamId = team.Id;
        System.assertEquals(0, controller.sprints.size());  
        System.assertEquals(team.Id + ',' + 0, controller.getNumSprints());             
    }
 
/*
@testcaseID a1DB00000000zKI
@userStoryID a07B0000000ELLTIA4
@Hierarchy GUS.ScrumforceToGUS.Sprint.Charts and Tasks.Team Velocity
@Expected Results Team Velocity chart should be the same as it was before the scrum team name change
@Author: Alexis Williams
*/
    static testMethod void testWithoutTeam() {
        ADM_SprintChartsController controller = new ADM_SprintChartsController();
        System.assertEquals(0, controller.sprints.size());  
        System.assertEquals(null, controller.getNumSprints());      
    }

 /*
@testcaseID a1DB00000000zKD
@userStoryID a07B0000000ELLTIA4
@Hierarchy GUS.ScrumforceToGUS.Sprint.Charts and Tasks.Team Velocity
@Expected Results 
 Velocity Chart called "Team Velocity" is located on Charts & Task tab
 Y axis is the number of points (zero)
 X axis is the sprint in chronological order (10 sprints)
 Average velocity is a flat line
 Actual velocity is a flat line
 Legend Average Velocity and Actual Velocity shows on right hand side
@Author: Alexis Williams
*/
    static testMethod void testWithTeamMoreThanTwoSprints() {
    	List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
    	List<Selectoption> options;
    	ADM_Sprint__c sprint;
    	ADM_Work__c work;
    	ADM_SprintChartsController controller = new ADM_SprintChartsController();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(); 
        controller.m_teamId = team.Id;
        String sprintName = '';
        List<String> alpha = new List<String>{'a','b','c','d','e','f','g','h','i','j','k'};
        
        for(Integer i = 0; i < 7; i++) {
        	sprint = new ADM_Sprint__c();
        	
        	if(i == 6) {
        		sprint.Start_Date__c = Date.today();
        		sprint.End_Date__c = Date.today().addDays(1);
        	} else {
	        	sprint.Start_Date__c = Date.today().addDays(-100 - i - 1);
	        	sprint.End_Date__c = Date.today().addDays(-100 - i);
	        	sprint.Completed_Story_Points__c = i;	
        	}
        	
        	sprintName = String.valueOf(sprint.Start_Date__c.month());
        	
        	if(sprintName.length() == 1) {
        		sprintName = '0' + sprintName;
        	}
        	
        	sprintName = sprint.Start_Date__c.year() + '.' + sprintName;
        	
        	if(i == 6) {
        		sprintName += alpha.get(0);
        	} else {
        		sprintName += alpha.get(i);
        	}
        	
        	sprintName += '-' + team.Name;
        	sprint.Name = sprintName;
        	sprint.Scrum_Team__c = team.Id;
        	
        	sprints.add(sprint);           		
        }
        
        insert sprints;
        
        sprint = [select Id from ADM_Sprint__c where Scrum_Team__c = :team.Id order by Start_Date__c desc limit 1];
        
        Test.startTest();
        	work = ADM_Work.createTestBug();
        	work.Story_Points__c = 5.0;
        	work.Sprint__c = sprint.Id;
        	work.Scrum_Team__c = team.Id;
        	update work;
        Test.stopTest();
        
        System.assertEquals(6, controller.sprints.size());  
        System.assertEquals(6, ADM_SprintChartsController.getCurrSprints(team.Id + ',' + 6).size());
        System.assertEquals('5.0', ADM_SprintChartsController.getCurrSprintPoints(sprint.Id));
        System.assertEquals(6, ADM_SprintChartsController.getTotalSprints(team.Id));
        
        ADM_Cookie cookie = controller.getCookie();
        System.assertEquals(team.Id + ',' + 6, cookie.activeTab);
        
        options = controller.getNumAvailSprints();
        System.assertEquals(5, options.size());
        
        for(Integer i = 2; i > 7; i++) {
        	Selectoption option = options[i];
        	System.assertEquals(String.valueOf(i), option.getLabel());
        	System.assertEquals(team.Id + ',' + i, option.getValue());        	
        }
        
        controller.setNumSprints(team.Id + ',' + 1);        
    }

      /*
 @testcaseID  a1DB00000002h09
 @userstoryID a07B0000000KsD5
 @Hierarchy GUS.Social Sprint.Virtual Wall.Detail page
 @ExpectedResults Test list view when team has over 100 sprints
 */
    static testMethod void testWithTeamMoreThanOneHundredSprints() {
    	List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
    	List<Selectoption> options;
    	ADM_Sprint__c sprint;
    	ADM_Work__c work;
    	ADM_SprintChartsController controller = new ADM_SprintChartsController();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(); 
        controller.m_teamId = team.Id;
        String sprintName = '';
        List<String> alpha = new List<String>{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
        Integer j = 0;
        Integer days = 100;
        
        for(Integer i = 0; i < 101; i++) {
        	sprint = new ADM_Sprint__c();
        	Integer days2div = i + 1;
        	
        	if(i > 0 && Math.mod(i,6) == 0) {
        		sprint.Start_Date__c = Date.today().addDays(-(Math.round(days/i)) - i - 1);
	        	sprint.End_Date__c = Date.today().addDays(-(Math.round(days/i)) - i);
	        	sprint.Completed_Story_Points__c = i;
	        	
	        	sprintName = String.valueOf(sprint.Start_Date__c.month());
	        	
	        	if(sprintName.length() == 1) {
	        		sprintName = '0' + sprintName;
	        	}
	        	
	        	sprintName = sprint.Start_Date__c.year() + '.' + sprintName;
        		sprintName += alpha.get(0) + i;
        		j = 0;
        	} else {        		
        		sprint.Start_Date__c = Date.today().addDays(-(Math.round(days/days2div)) - i - 1);
	        	sprint.End_Date__c = Date.today().addDays(-(Math.round(days/days2div)) - i);
	        	sprint.Completed_Story_Points__c = i;
	        	
	        	sprintName = String.valueOf(sprint.Start_Date__c.month());
	        	
	        	if(sprintName.length() == 1) {
	        		sprintName = '0' + sprintName;
	        	}
	        	
	        	sprintName = sprint.Start_Date__c.year() + '.' + sprintName;
        		sprintName += alpha.get(0) + i;
        		sprintName += alpha.get(j);
        		j++;
        	}
        	
        	sprintName += '-' + team.Name;
        	sprint.Name = sprintName;
        	sprint.Scrum_Team__c = team.Id;
        	        	
        	sprints.add(sprint);           		
        }
        
        insert sprints;
        
        System.assertEquals(6, controller.sprints.size());  
        System.assertEquals(6, ADM_SprintChartsController.getCurrSprints(team.Id + ',' + 6).size());
        System.assertEquals(10, ADM_SprintChartsController.getTotalSprints(team.Id));
        
        ADM_Cookie cookie = controller.getCookie();
        System.assertEquals(team.Id + ',' + 6, cookie.activeTab);
        
        options = controller.getNumAvailSprints();
        System.assertEquals(9, options.size());
        
        for(Integer i = 2; i > 10; i++) {
        	Selectoption option = options[i];
        	System.assertEquals(String.valueOf(i), option.getLabel());
        	System.assertEquals(team.Id + ',' + i, option.getValue());        	
        }
    }
}