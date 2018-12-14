@IsTest
public with sharing class ADM_LocatorTests {
	
	/**
	 * @testcaseID: a1DB00000002KI6
	 * @userstory: a07B0000000Mdhn
	 * @hierarchy: GUS.ScrumforceToGUS.Sprint.Sprint Information.Detail page
	 * @expectedResults: Should navigate through all the sprints in date order. On the sprint page 
	 *		with the earliest start date, there should be no "Previous Sprint" arrow available. 
	 *      When on the detail page of the sprint with the latest start date, there should be
	 *      no "Next Sprint" arrow displayed.  
	 * @author: jhatton 
	 **/
	static testMethod void testSprintNavigation() {
    	 ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
    	
    	//create some test sprint to navigate between
    	List<ADM_Sprint__c> testSprints = new List<ADM_Sprint__c>();
    	final Integer SPRINT_LENGTH = 31;
    	
    	Integer i = 5;
    	Date startDate = null;
    	Date endDate = null; 
    	while(i > 0) {
    		//if this is the first sprint pick a new date else calculate it
    		if(startDate == null && endDate == null) {
    			 startDate = Date.today().addDays(1);
    			 endDate = Date.today().addDays(SPRINT_LENGTH);
    		} else {
    			 startDate = endDate.addDays(1);  	
    			 endDate = startDate.addDays(SPRINT_LENGTH);  			
    		}
    		
    		testSprints.add(createTestSprint(startDate, endDate, team));
    		i--;
    	}
    	
    	insert testSprints;
    	
    	//pick sprint in the middle so that it has a next sprint and prior sprint
        System.debug('inside testCurrentSprintIsFound');
        ADM_SprintNavigationController nav = new ADM_SprintNavigationController();
        nav.currentSprint = testSprints.get(2);
        System.assert(nav.getThePreviousSprint() != null, ' Did not find any previous sprint.  Sprints created:' + testSprints);
        System.assert(nav.getTheNextSprint() != null, ' Did not find any previous sprint.  Sprints created:' + testSprints);
        
        System.assertEquals(nav.getThePreviousSprint(), testSprints.get(1).Id);
        System.assertEquals(nav.getTheNextSprint(), testSprints.get(3).Id);
        Schema.DescribeSObjectResult sprintDescribe = Schema.SObjectType.ADM_Sprint__c;
        String objectPrefix = '/' + sprintDescribe.getKeyPrefix();
        System.assertEquals(objectPrefix, nav.getListViewLink()); 
        
    }
    
	/**
	 * @testcaseID: a1DB00000002KIF
	 * @userstory: a07B0000000Mdhn
	 * @hierarchy: GUS.ScrumforceToGUS.Team.Team Information.Detail page	
	 * @expectedResults: The Team Detail page of the team the user is a member of is displayed.
	 * @author: jhatton 
	 **/
   static testMethod void testTeamLocatorFindsTeamWhenASingleMembershipRecordIsPresent() {
  		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        User u = ADM_WorkUser.createTestUserWithRandomName();
        
        ADM_Scrum_Team_Member__c mem = new ADM_Scrum_Team_Member__c();
        mem.Member_Name__c = u.id;
        mem.Scrum_Team__c = team.id;
        mem.Allocation__c = 10;
        insert mem;
        
        System.runAs(u) {
        	ADM_TeamLocatorController con = new ADM_TeamLocatorController();
        	PageReference pr = con.goToCurrentTeam();
        	System.assert(pr.getUrl().contains(team.id));
        	//System.assertEquals();
        }
   }
   
	/**
	 * @testcaseID: a1DB00000002KIK
	 * @userstory: a07B0000000Mdhn
	 * @hierarchy: GUS.ScrumforceToGUS.Team.Team Information.Detail page	
	 * @expectedResults: The Team Selector is shown
	 * @author: jhatton 
	 **/
   static testMethod void testTeamLocatorFindsListViewWhenMultipleMembershipRecordsArePresent() {
  		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        User u = ADM_WorkUser.createTestUserWithRandomName();
        
        ADM_Scrum_Team_Member__c mem = new ADM_Scrum_Team_Member__c();
        mem.Member_Name__c = u.id;
        mem.Scrum_Team__c = team.id;
        mem.Allocation__c = 10;
        insert mem;
        
        ADM_Scrum_Team__c team2 = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM + '2');
       
        ADM_Scrum_Team_Member__c mem2 = new ADM_Scrum_Team_Member__c();
        mem2.Member_Name__c = u.id;
        mem2.Scrum_Team__c = team2.id;
        mem2.Allocation__c = 5;
        insert mem2;
        
        System.runAs(u) {
        	ADM_TeamLocatorController con = new ADM_TeamLocatorController();
        	PageReference pr = con.goToCurrentTeam();
        	System.assertEquals(null, pr); // expect result to be null, meaning they are shown team selector on current page
        }
   }

	/**
	 * @userstory: a07B0000000yiqiIAA
	 * @expectedResults: Send the user to the list view because they have no team membership
	 * @author: tyler.clark
	 **/
   static testMethod void testTeamLocatorFindsListViewWhenNoMembershipRecordsArePresent() {
  		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        User u = ADM_WorkUser.createTestUserWithRandomName();
        
        Schema.DescribeSObjectResult teamDescribe = Schema.SObjectType.ADM_Scrum_Team__c;
        String objectPrefix = teamDescribe.getKeyPrefix();
        
        PageReference expectedPR = new PageReference('/' + objectPrefix);
        
        System.runAs(u) {
        	ADM_TeamLocatorController con = new ADM_TeamLocatorController();
        	PageReference pr = con.goToCurrentTeam();
        	System.assertEquals(expectedPR.getUrl(), pr.getUrl(), 'Expected the system to redirect to the teams list view page');
        }
   }

    /*
     * @expectedResults: The Sprint Detail page of the sprint is displayed.
     * @author: jared.pearson
     */ 
    static testMethod void testSprintLocatorWithEqualToStartDate(){
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        User u = ADM_WorkUser.createTestUserWithRandomName();
        
        ADM_Scrum_Team_Member__c mem = new ADM_Scrum_Team_Member__c();
        mem.Member_Name__c = u.id;
        mem.Scrum_Team__c = team.id;
        mem.Allocation__c = 10;
        insert mem;
        
        List<ADM_Sprint__c> testSprints = new List<ADM_Sprint__c>();
        testSprints.add(createTestSprint(Date.newInstance(2012, 1, 1), Date.newInstance(2012, 1, 31), team));
        testSprints.add(createTestSprint(Date.newInstance(2012, 2, 1), Date.newInstance(2012, 2, 28), team));
        insert testSprints;
        
        System.runAs(u) {
            ADM_SprintLocatorController controller = new ADM_SprintLocatorController();
            PageReference pr = controller.goToSprint(Date.newInstance(2012, 2, 1));
            
            System.assert(pr.getParameters().containsKey('id'), 'expected the Sprint ID to be set on the page reference');
            System.assertEquals(testSprints.get(1).Id, pr.getParameters().get('id'), 'Expected the Sprint ID to be the second sprint because the date should be today\'s date');
        }
    }
    
    /*
     * @expectedResults: If a user access the sprint locator when in between sprints, the previous sprint should be 
     *                   selected.
     * @author: jared.pearson
     */ 
    static testMethod void testSprintLocatorSelectsPreviousSprintWhenInBetweenSprints(){
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        User u = ADM_WorkUser.createTestUserWithRandomName();
        
        ADM_Scrum_Team_Member__c mem = new ADM_Scrum_Team_Member__c();
        mem.Member_Name__c = u.id;
        mem.Scrum_Team__c = team.id;
        mem.Allocation__c = 10;
        insert mem;
        
        List<ADM_Sprint__c> testSprints = new List<ADM_Sprint__c>();
        //create a sprint that ends a few days before the month
        testSprints.add(createTestSprint(Date.newInstance(2012, 1, 1), Date.newInstance(2012, 1, 30), team));
        testSprints.add(createTestSprint(Date.newInstance(2012, 2, 1), Date.newInstance(2012, 2, 28), team));
        insert testSprints;
        
        System.runAs(u) {
            ADM_SprintLocatorController controller = new ADM_SprintLocatorController();
            
            //try to find the sprint that is between the end of the previous sprint and before the next sprint
            PageReference pr = controller.goToSprint(Date.newInstance(2012, 1, 31));
            
            System.assert(pr.getParameters().containsKey('id'), 'expected the Sprint ID to be set on the page reference');
            System.assertEquals(testSprints.get(0).Id, pr.getParameters().get('id'), 'Expected the Sprint ID to be the second sprint because the date should be today\'s date');
        }
    }
    
    /*
     * @expectedResults: If a user access the sprint locator when no sprint within the last 14 days, then show the list
     * @author: jared.pearson
     */ 
    static testMethod void testSprintLocatorDoesNotSelectOldSprint(){
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        User u = ADM_WorkUser.createTestUserWithRandomName();
        
        ADM_Scrum_Team_Member__c mem = new ADM_Scrum_Team_Member__c();
        mem.Member_Name__c = u.id;
        mem.Scrum_Team__c = team.id;
        mem.Allocation__c = 10;
        insert mem;
        
        List<ADM_Sprint__c> testSprints = new List<ADM_Sprint__c>();
        testSprints.add(createTestSprint(Date.newInstance(2012, 1, 1), Date.newInstance(2012, 1, 30), team));
        insert testSprints;
        
        Schema.DescribeSObjectResult teamDescribe = Schema.SObjectType.ADM_Sprint__c;
        String objectPrefix = teamDescribe.getKeyPrefix();
        PageReference expectedPR = new PageReference('/' + objectPrefix);
        
        System.runAs(u) {
            ADM_SprintLocatorController controller = new ADM_SprintLocatorController();
            
            //enter a date that is greater than 14 days of the sprint
            PageReference pr = controller.goToSprint(Date.newInstance(2012, 3, 1));
            
            System.assertEquals(expectedPR.getUrl(), pr.getURL(), 'Expected to be sent to the list view because there is no sprint within 14 days');
        }
    }
   
    private static ADM_Sprint__c createTestSprint(Date startDate, Date endDate, ADM_Scrum_Team__c team) {
        
        String sprintMonth = startDate.month().format();
        if(sprintMonth.length() == 1) {
            sprintMonth = '0' + sprintMonth;
        }
        String sprintName = startDate.year() + '.' + sprintMonth + 'a';
        ADM_Sprint__c sprint = new ADM_Sprint__c(Name = sprintName, Scrum_Team__c = team.id, Start_Date__c = startDate, End_Date__c = endDate);
        
        return sprint;
    }
	

}