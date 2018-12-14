@isTest
public with sharing class ADM_Planner_ReleaseVisualizerTests {

	static ADM_Sprint__c pastSprintA = null;
	static ADM_Sprint__c pastSprintB = null;
	static ADM_Sprint__c futureSprintA = null;
	static ADM_Sprint__c futureSprintB = null;

	public ADM_Planner_ReleaseVisualizerTests() {
	}
			
	static testMethod void testGetTeamName() {
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('teamId', team.Id);
		ADM_Planner_ReleaseVisualizerController controller = new ADM_Planner_ReleaseVisualizerController();
		String retrievedName = controller.getTeamName();
		Test.stopTest();

		System.assert(retrievedName == team.Name, 'Expected getTeamName to return test team name');
	}


	static testMethod void testGetAverageVelocity() {
		// Create a list of four work items
		Set<String> additionalFields = new Set<String>();
        additionalFields.add('Scrum_Team__c');
		List<ADM_Work__c> workItems = ADM_Work.createListOfWork(4, ADM_Work.RECORD_TYPE_NAME_USERSTORY, additionalFields);
		// All the items are assigned the same scrum team
		Id teamId = workItems[0].Scrum_Team__c;
		System.assert(teamId != null, 'Expected teamId to be non-null');

		ApexPages.currentPage().getParameters().put('teamid', teamId);
		ADM_Planner_ReleaseVisualizerController controller = new ADM_Planner_ReleaseVisualizerController();

		Test.startTest();

		createPastSprints(teamId);
		createFutureSprints(teamId); // Note: these sprints shouldn't matter or cause any exceptions

		// Assign the first two work items to past sprint 'a' and the other two to past sprint 'b'
		workItems[0].Sprint__c = pastSprintA.Id;
		workItems[0].Story_Points__c = 3;
		workItems[1].Sprint__c = pastSprintA.Id;
		workItems[1].Story_Points__c = 5;
		workItems[2].Sprint__c = pastSprintB.Id;
		workItems[2].Story_Points__c = 8;
		workItems[3].Sprint__c = pastSprintB.Id;
		workItems[3].Story_Points__c = 13;

		// Insert the work items
		insert workItems;

		// Make sure they were inserted and set the status to 'Closed'
		for (ADM_Work__c workItem : workItems) {
			System.assert(workItem.Id != null, 'Expected work Id to be non-null');
			workItem.Status__c = 'Closed';
		}

		// Update the items - this should update the sprint velocity
		update workItems;


		Test.stopTest();

		Integer avgVelocity = controller.getAverageVelocity();
		// Our expected velocity for each sprint is sprint A = 8, sprint B = 21
		// So the average velocity should be (8 + 21)/2 ~= 14
		System.assert(avgVelocity == 14, 'Expected average velocity to be 14');

	}

	static testMethod void testGetPlanningSprints() {
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
		ApexPages.currentPage().getParameters().put('teamid', team.Id);
		ADM_Planner_ReleaseVisualizerController controller = new ADM_Planner_ReleaseVisualizerController();

		Test.startTest();

		createPastSprints(team.Id); // Note: these sprints should not be returned
		createFutureSprints(team.Id);

		List<ADM_Sprint__c> planningSprints = controller.getPlanningSprints();

		Test.stopTest();

		System.assert(planningSprints.size() == 2, 'Expected two planning sprints');
		System.assert(planningSprints[0].Id == futureSprintA.Id, 'Expected first planning sprint to be sprint A');
		System.assert(planningSprints[1].Id == futureSprintB.Id, 'Expected second planning sprint to be sprint B');

	}

	static testMethod void testGetSprintsToBeDisplayed() {
		// Create a list of four work items
		Set<String> additionalFields = new Set<String>();
        additionalFields.add('Scrum_Team__c');
		List<ADM_Work__c> workItems = ADM_Work.createListOfWork(6, ADM_Work.RECORD_TYPE_NAME_USERSTORY, additionalFields);
		// All the items are assigned the same scrum team
		Id teamId = workItems[0].Scrum_Team__c;
		System.assert(teamId != null, 'Expected teamId to be non-null');

		ApexPages.currentPage().getParameters().put('teamid', teamId);
		ADM_Planner_ReleaseVisualizerController controller = new ADM_Planner_ReleaseVisualizerController();

		Test.startTest();

		createPastSprints(teamId);
		createFutureSprints(teamId);

		// Assign the first two work items to past sprint 'a' and the next two to past sprint 'b'
		workItems[0].Sprint__c = pastSprintA.Id;
		workItems[0].Story_Points__c = 3;
		workItems[1].Sprint__c = pastSprintA.Id;
		workItems[1].Story_Points__c = 5;
		workItems[2].Sprint__c = pastSprintB.Id;
		workItems[2].Story_Points__c = 8;
		workItems[3].Sprint__c = pastSprintB.Id;
		workItems[3].Story_Points__c = 13;

		// Assign the last two work items to future sprint 'a' and future sprint 'b', respectively
		workItems[4].Sprint__c = futureSprintA.Id;
		workItems[4].Story_Points__c = 5;
		workItems[5].Sprint__c = futureSprintB.Id;
		workItems[5].Story_Points__c = 8;


		// Insert the work items
		insert workItems;

		// Make sure they were inserted and set the status to 'Closed' for past sprints
		for (ADM_Work__c workItem : workItems) {
			System.assert(workItem.Id != null, 'Expected work Id to be non-null');
			if (workItem.Sprint__c == pastSprintA.Id || workItem.Sprint__c == pastSprintB.Id) {
				workItem.Status__c = 'Closed';
			}
		}

		// Update the items - this should update the sprint velocity
		update workItems;

		Test.stopTest();

		// Generate the custom VF component based on the data set up above
		Component.Apex.OutputPanel panel = controller.getSprintsToBeDisplayed();
		System.assert(panel != null, 'Expected the custom output panel to be non-null');

		// Unfortunately, this simple sanity check (!= null) is about the only realistic test that can
		// be done at this level for this method.  See:
		// http://salesforce.stackexchange.com/questions/16080/how-do-i-unit-test-an-apex-controller-method-for-dynamic-components
		// for a discussion of the troubles testing dynamic components.  Selenium should be able to cover the generated
		// HTML later.
	}

	private static void createPastSprints(Id teamId) {
		// Create two sprints in the past: Go back one month from the current month and set up the 'a' and 'b' sprints
		Date sprintAStart = Date.today().toStartOfMonth().addMonths(-1);
		Date sprintAEnd = Date.newInstance(sprintAStart.year(), sprintAStart.month(), sprintAStart.day()).addDays(14);
		Date sprintBStart = Date.newInstance(sprintAEnd.year(), sprintAEnd.month(), sprintAEnd.day()).addDays(1);
		Date sprintBEnd = Date.today().toStartOfMonth().addDays(-1);

		pastSprintA = createAndInsertTestSprint(sprintAStart, sprintAEnd, teamId, 'a');
		pastSprintB = createAndInsertTestSprint(sprintBStart, sprintBEnd, teamId, 'b');

		System.assert(pastSprintA.Id != null, 'Expected sprint A ID to be non-null');
		System.assert(pastSprintB.Id != null, 'Expected sprint B ID to be non-null');

	}

	private static void createFutureSprints(Id teamId) {
		// Create two sprints in the future: Go forward one month from the current month and set up the 'a' and 'b' sprints
		Date sprintAStart = Date.today().toStartOfMonth().addMonths(1);
		Date sprintAEnd = Date.newInstance(sprintAStart.year(), sprintAStart.month(), sprintAStart.day()).addDays(14);
		Date sprintBStart = Date.newInstance(sprintAEnd.year(), sprintAEnd.month(), sprintAEnd.day()).addDays(1);
		Date sprintBEnd = Date.today().toStartOfMonth().addMonths(2).addDays(-1);

		futureSprintA = createAndInsertTestSprint(sprintAStart, sprintAEnd, teamId, 'a');
		futureSprintB = createAndInsertTestSprint(sprintBStart, sprintBEnd, teamId, 'b');

		System.assert(futureSprintA.Id != null, 'Expected sprint A ID to be non-null');
		System.assert(futureSprintB.Id != null, 'Expected sprint B ID to be non-null');

	}

  private static ADM_Sprint__c createAndInsertTestSprint(Date startDate, Date endDate, Id teamId, String sprintSuffix) {    
    String sprintMonth = startDate.month().format();
    if(sprintMonth.length() == 1) {
        sprintMonth = '0' + sprintMonth;
    }
    String sprintName = startDate.year() + '.' + sprintMonth + sprintSuffix;
    ADM_Sprint__c sprint = new ADM_Sprint__c();
    sprint.Name = sprintName;
    sprint.Scrum_Team__c = teamId;
    sprint.Start_Date__c = startDate;
    sprint.End_Date__c = endDate;
    insert sprint;
    
    return sprint;
  }

}