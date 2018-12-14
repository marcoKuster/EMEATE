public with sharing class ADM_Sprint {

	 /**
     * Creates the "TaskUpdates" PushTopic if it does not already exist otherwise,
     * a Debug message is logged.
     */
    public static void ensureSprintUpdatesPushTopic() {
    	String name = 'SprintUpdates';
    	String query = 'select Id, Name, Scrum_Team__c, Hours_in_a_work_day__c from ADM_Sprint__c';
    	query = COM_SoqlUtils.convertToQualifiedQuery(query);
    	ADM_PushTopic.ensurePushTopic(name, query, 25, 'All', 'All');
    }

		public static List<ADM_Sprint__c> getSprintsDetailsById(List<String> sprintIds){
			List<ADM_Sprint__c> sprintRecordList = [Select Id, Start_Date__c, End_Date__c, Total_Workdays__c, Scrum_Team__c from ADM_Sprint__c where Id in
			 :sprintIds];

			return sprintRecordList;
		}

	public static ADM_Sprint__c getCurrentSprintForTeam(Id teamId) {
		ADM_Sprint__c currentSprint = null;
		 List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
		 try {
				 sprints = [select id, Name, Start_Date__c, End_Date__c, Completed_Story_Points__c from ADM_Sprint__c where End_Date__c >=:System.today() and Start_Date__c <=today and Scrum_Team__c = :teamId order by Start_Date__c];
		 } catch(Exception e) {
				 System.debug(LoggingLevel.ERROR, 'Exception retrieving sprints e:' + e + ' teamId:' + teamId);
		 }
		 if(sprints != null && sprints.size() >0){
			 currentSprint = sprints[0];
		 }
		 return currentSprint;
 	}


	/**
	 * Creates a sprint with one user story containing one task
	 */
	@IsTest
	public static ADM_Sprint__c createTestSprint() {
		User user = ADM_WorkUser.createTestUser();
		ADM_Sprint__c sprint = createEmptyTestSprint(user);

		ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
		story.Sprint__c = sprint.id;
		update story;

		ADM_Task__c task = new ADM_Task__c(Subject__c = 'Just Do It', Assigned_To__c = user.id, Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id);
		insert task;

		return sprint;
	}

	/**
	 * Creates a sprint with no work items
	 */
    @IsTest
	public static ADM_Sprint__c createEmptyTestSprint() {
        User user = ADM_WorkUser.createTestUser();
        return createEmptyTestSprint(user);
	}

    private static ADM_Sprint__c createEmptyTestSprint(User user) {
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c(Name = ADM_ScrumTeam.TEST_SCRUM_TEAM);
        team.Cloud__c = 'Chatter';
        insert team;

        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c(Scrum_Team__c = team.id, Member_Name__c = user.id, Allocation__c = 100);
        insert member;

        ADM_Sprint__c sprint = createTestSprintForTeam(team);

        //create a pto record in the middle of the sprint
        Date ptoStart = Date.today().addDays(61);
        Date ptoEnd = Date.today().addDays(63);
        ADM_Time_Off_Log__c pto = new ADM_Time_Off_Log__c(Start_Date__c = ptoStart, End_Date__c = ptoEnd, User__c = user.id, Approved__c = true);
        insert pto;

        return sprint;
    }

    /**
     * Creates a sprint for the specified team
     */
    public static ADM_Sprint__c createTestSprintForTeam(ADM_Scrum_Team__c team) {
    	//create a two week sprint using today as the middle as many tests are date sensitive
        Date startDate = Date.today().addDays(60); //sprint is created two months in the future with a span of 2 weeks.
        Date endDate = Date.today().addDays(74);

        String sprintMonth = startDate.month().format();
        if(sprintMonth.length() == 1) {
            sprintMonth = '0' + sprintMonth;
        }
        String sprintName = startDate.year() + '.' + sprintMonth + 'a';

        ADM_Sprint__c sprint = new ADM_Sprint__c(Name = sprintName, Scrum_Team__c = team.id, Start_Date__c = startDate, End_Date__c = endDate);
        insert sprint;

        return sprint;
    }

	/*
	@testcaseID a1DB0000000101N
	@userstoryID a07B0000000EqK4IAK
	@ExpectedResults The following error message appears: Error: Invalid Data. Review all error messages below to correct your data. Duplicate value on record: XXXXXX
	@Hierarchy GUS.ScrumforceToGUS.Sprint.Sprint Information.Create new Sprint
	@Author: Alexis Williams
	*/

	testMethod static void testUniqueSprintNames() {
		try {
			ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
			//try to insert another sprint with the same name
			ADM_Sprint__c sprint2 = new ADM_Sprint__c(Name = sprint.Name, Scrum_Team__c = sprint.Scrum_Team__c, Start_Date__c = sprint.Start_Date__c, End_Date__c = sprint.End_Date__c);
		    // Push the second sprint date out so the names will collide instead
            sprint2.Start_Date__c = Date.today().addDays(10);
            sprint2.End_Date__c = Date.today().addDays(25);
            insert sprint2;
		 	System.assert(false, 'Test should have thrown a DML exception before it reached here');
		 	//insert the sprint but then try and edit it to have the same name
		 	try {
		 		sprint2.Name = '2009.01a-TEST';
		 		insert sprint2;
		 		System.assert(sprint2.id != null);
		 		try {
		 			sprint2.Name = sprint.Name;
		 			update sprint2;
		 			System.assert(false, 'Test should have thrown a DML exception before it reached here');
		 		} catch (DmlException e) {
		            System.assert(e.getMessage().contains('duplicates value on record'), e.getMessage());
		        }
		 	} catch (DmlException e) {
            	System.assert(false, 'sprint2 should have inserted successfully as it has a unique name');
        	}
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('duplicates value on record'), e.getMessage());
        }

	}

	/*
	@testcaseID a1DB0000000101D
	@userstoryID a07B0000000EqK4IAK
	@ExpectedResults When trying to save, the following error message appears:  "Error:Your sprint should follow the format: YYYY.MM(0-9 or a-f) - <Team Name> 4 digit year, 2 digit month, optional (0-9 or a-f) - <your team name>"
	@Hierarchy GUS.ScrumforceToGUS.Sprint.Sprint Information.Create new Sprint
	@Author: Alexis Williams
	*/
	testMethod static void testSprintNameError() {
		ADM_errorUtils err = new ADM_errorUtils();
		try {
			ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
			ADM_Sprint__c sprint = new ADM_Sprint__c();
			sprint.Name = 'test';
			sprint.Start_Date__c = Date.today();
			sprint.End_Date__c = Date.today().addDays(1);
			sprint.Scrum_Team__c = team.Id;

			insert sprint;
		} catch(DmlException e) {
			String error = err.getErrorMessage(e);
			System.assertEquals(true, error.contains('Your sprint should follow the format:'));
		}
	}

/*
Test to show that the sprint name now allows the additional character after month to allow a digit (0-9) or character (a-f)
*/

	testMethod static void testSprintNameWithOptionaCharacterToAllowNumbers() {
		ADM_errorUtils err = new ADM_errorUtils();
		ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
		ADM_Sprint__c sprint = new ADM_Sprint__c();
		sprint.Name = '2014.044-GUS';
		sprint.Start_Date__c = Date.today();
		sprint.End_Date__c = Date.today().addDays(1);
		sprint.Scrum_Team__c = team.Id;

		insert sprint;

		ADM_Sprint__c sprintCreated = [Select id from ADM_Sprint__c where id =: sprint.id limit 1];
		System.assertNotEquals(sprintCreated,null,'Sprint successfully created.');
	}



}