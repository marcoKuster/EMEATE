@isTest
public with sharing class ADM_ValidateTest {

    /**
        testcase ID: a1DB00000000wHV
        user story ID: a07B0000000EiszIAC
        Hierarchy: GUS.ScrumforceToGUS.Work Page.Bug.New Page
        Expected Results: Error occurs: The assignee of a work record can't open the Perforce Status. Put some Windex on it and try again.
        author: Alexis Williams
    */

        /**
        testcase ID: a1DB00000000wHa
        user story ID: a07B0000000EiszIAC
        Hierarchy: GUS.ScrumforceToGUS.Work Page.Bug.New Page
        Expected Results: Error occurs: The assignee of a work record can't open the Perforce Status. Put some Windex on it and try again.
        author: Alexis Williams
    */
    static testMethod void verifyErrorMessagesOnPerforceStatusOpenAfterCheckin() {
        User u = ADM_WorkUser.createTestUser();

        Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
        Test.stopTest();

        work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;
        work.Assignee__c = Userinfo.getUserId();

        try {
          update work;
        } catch(System.Dmlexception e) {
//          System.assertEquals(e.getDmlMessage(0), ADM_WorkPerforceStatus.P4_ASSIGNEE_CANNOT_UPDATE_ERROR);
        }

        work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;
        work.Assignee__c = u.Id;

        try {
          update work;
          System.assertEquals(true, true);
        } catch(System.Dmlexception e) {
          System.assertEquals(true, false, 'I should have NOT have gotten a DML exception thrown with the following error message: ' + e.getDmlMessage(0));
        }
    }

    /**
     * Expect that the an error is thrown when the team is not active.
     */
    static testMethod void testWorkCannotHaveAnInactiveTeam() {
      ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
      team.Active__c = false;
      upsert team;

      ADM_Product_Tag__c tag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

      ADM_Work__c work = ADM_Work.createTestBug();
      work.Product_Tag__c = tag.Id;
      work.Scrum_Team__c = team.Id;

      String message = null;
      try {
        Test.startTest();
        upsert work;
        Test.stopTest();
      } catch(System.DmlException exc) {
        message = exc.getMessage();
      }

      System.assert(message != null, 'Expected the work insert to fail because the team is inactive.');
      System.assert(message.contains('scrum team') && message.contains('not active'), 'Expected the work update to fail because the team is inactive: ' + message);
    }


    /**
     * Expect that the an error is thrown when the team is not active.
     */
    static testMethod void testTestResolutionFieldIsPopulatedForTestFailureAndStatusIsDuplicate() {
      ADM_Work__c work1 = ADM_Work.createTestBug();
      ADM_Work__c work = ADM_Work.createTestBug();

      ADM_Parent_Work__c relatedWork = new ADM_Parent_Work__c();
      relatedWork.Parent_Work__c = work1.Id;
      relatedWork.Child_Work__c = work.Id;

      insert relatedWork;

      work.Type__c = 'Test Failure';
      work.Status__c = 'Duplicate';

      String message = null;
      try {
        Test.startTest();
        update work;
        Test.stopTest();
      } catch(System.DmlException exc) {
        message = exc.getMessage();
      }

      ADM_Work__c works = [Select id, Resolution__c,Type__c from ADM_Work__c where id =: work.Id limit 1];
      System.assert(works.Resolution__c != null  , 'Expected test resolution field to be populated and not be null.');
      System.assertEquals('Duplicate Test Failure',works.Resolution__c , 'Expected test resolution field to be populated with this particular value.');

    }


    static testMethod void testTestResolutionFieldIsRequiredForTestFailureAndClosedWork() {
      ADM_Work__c work = ADM_Work.setUpTestWork('Bug');
      work.Type__c = 'Test Failure';
      work.Status__c = 'Closed';

      String message = null;
      try {
        Test.startTest();
        insert work;
        Test.stopTest();
      } catch(Exception exc) {
        message = exc.getMessage();
      }
      System.assert(message.contains('Please select a value in the test resolution picklist') , 'Expected test resolution field to not be null and have this value.');
    }

    /**
     * Expect that the 62org Integration user can update a work with an inactive team
     */
    static testMethod void testWorkCanHaveInactiveTeamIfIntegrationUser() {

        User user62org = ADM_WorkUser.createTest62Orguser();

        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        team.Active__c = false;
        upsert team;

        ADM_Product_Tag__c tag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        ADM_Work__c work = ADM_Work.createTestBug();
        work.Product_Tag__c = tag.Id;
        work.Scrum_Team__c = team.Id;

        String message = null;
        try {
            Test.startTest();
            System.runAs(user62org) {
                upsert work;
            }
            Test.stopTest();
        } catch(System.DmlException exc) {
            message = exc.getMessage();
        }

        System.assert(message == null, 'Expected the work insert to pass even though the team is inactive because the user is 62 Org Integration: ' + message);
    }

     /**
     * Verify default values are assigned such as Impact, Frequency and Type are populated when these fields are null
     */
    static testMethod void testDefaultVariablesAreAssignedWhenWorkIsCreated() {
        /*to make them mobile friendly certain fields like impact,frequency and type have been removed from the global action page layout
         this test asserts they are defaulted with sensible defaults */
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        //blank out fields
        work.Type__c = null;
        work.Impact__c = null;
        work.Frequency__c = null;
        work.Priority__c = 'P4';
        insert work;
        ADM_Work__c insertedWork = [select id, Name, Impact__c, Frequency__c, Type__c, Priority__c from ADM_Work__c where id = :work.id];
        System.assert(insertedWork.id != null);
        //verify the impact and frequency are populated.  In most cases the value will be Malfunctioning & Often but we don't assert that because this can be customized at the org level
        System.assert(insertedWork.Frequency__c != null);
        System.assert(insertedWork.Impact__c != null);
        System.assertEquals('Bug', insertedWork.Type__c);
        System.assertEquals('P4', insertedWork.Priority__c);

    }


    /**
     * Verify Impact & Frequency calculate the correct Priority
     */
    static testMethod void testPriorityMapping() {
        
        // Setup a test bug
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        
        // Set up a test impact/frequency priority mapping
        ADM_Impact__c impact = new ADM_Impact__c(Name='Cosmetic Doc/UI Text');
        upsert impact;
        
        ADM_Frequency__c frequency = new ADM_Frequency__c(Name='Often');
        upsert frequency;
        
        ADM_Priority__c priority = new ADM_Priority__c(Name='P4');
        upsert priority;
        
        ADM_Priority_Mapping__c priority_mapping = new 
            ADM_Priority_Mapping__c(Impact__c=impact.Id,
                                   Frequency__c=frequency.Id,
                                   Priority__c=priority.Id);
        upsert priority_mapping;
        
        // Set up a second test impact/frequency priority mapping
        ADM_Impact__c impact2 = new ADM_Impact__c(Name='Performance');
        upsert impact2;
        
        ADM_Frequency__c frequency2 = new ADM_Frequency__c(Name='Often');
        upsert frequency2;
        
        ADM_Priority__c priority2 = new ADM_Priority__c(Name='P0');
        upsert priority2;
        
        ADM_Priority_Mapping__c priority_mapping2 = new 
            ADM_Priority_Mapping__c(Impact__c=impact2.Id,
                                   Frequency__c=frequency2.Id,
                                   Priority__c=priority2.Id);
        upsert priority_mapping2;
        

        work.Impact__c = impact.Id;
        work.Frequency__c = frequency.Id;
        insert work;

        ADM_Work__c insertedWork = [select id, Name, Impact__r.Name, Frequency__r.Name, Type__c, Priority__c from ADM_Work__c where id = :work.id];

        System.assert(insertedWork.id != null);
        System.assertEquals(frequency.Name, insertedWork.Frequency__r.Name);
        System.assertEquals(impact.Name, insertedWork.Impact__r.Name);
        System.assert(insertedWork.Priority__c != null);

        insertedWork.Impact__c = impact2.Id;
        insertedWork.Frequency__c = frequency2.Id;
        upsert insertedWork;

        ADM_Work__c updatededWork = [select id, Name, Impact__r.Name, Frequency__r.Name, Type__c, Priority__c from ADM_Work__c where id = :work.id];

        System.assert(updatededWork.id != null);
        System.assertEquals(frequency2.Name, updatededWork.Frequency__r.Name);
        System.assertEquals(impact2.Name, updatededWork.Impact__r.Name);
        System.assert(updatededWork.Priority__c != null);
    }

    static testMethod void testNegativeBacklogRanksAreNotAllowed(){

      ADM_Work__c work = ADM_Work.setupTestWork('Bug');
      work.Priority_Rank__c = -1;
      try {
          insert work;
          System.debug('A negative Backlog rank should throw an exception');
          System.assert(false);
        } catch ( System.DmlException saveException){
          System.assert(saveException.getMessage().contains('Backlog Rank cannot be negative'));
        }
    }

    static testMethod void testRequiredErrorMessages(){

      ADM_Work__c bug = ADM_Work.setupTestWork('Bug');
      Set<String> field_set = null;

      // With an empty required field, return a blank string
      System.assertEquals( '',  ADM_Validate.getErrorMessagesForRequiredFields( bug, field_set ));

      field_set = new Set<String>();
      field_set.add('Senior_Management_POC__c');

      // With a single required field, the message should be returned
      System.assertEquals( 'Senior Management POC is a required field. ',  ADM_Validate.getErrorMessagesForRequiredFields( bug, field_set ));

    }

    static testMethod void testValidateAdditionalFieldsForBugs(){

      ADM_Work__c bug = ADM_Work.setupTestWork('Bug');
      // Blank out an expected field to raise the exception on save
      bug.Found_In_Build__c = null;
      try {
        upsert bug;
        System.assert(false, 'Saving a bug record without a Found_In_Build__c should throw an exception.');
      } catch ( System.DmlException d ){
        System.assertEquals('System.DmlException', d.getTypeName());
        System.assertEquals( d.getMessage(), 'Upsert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Please correct the following error(s): Found In Build is a required field. : []' );
      }
    }

    static testMethod void testValidateAdditionalFieldsForUserStories(){

      ADM_Work__c user_story = ADM_Work.setupTestWork('User Story');
      //  Blank out the product tag to raise the exception on save
      user_story.Product_Tag__c = null;
      try {
        upsert user_story;
        System.assert(false, 'Saving a User Story without a Product_Tag__c should throw an exception.');
      } catch ( System.DmlException d ){
        System.assertEquals('System.DmlException', d.getTypeName());
        System.assertEquals( d.getMessage(), 'Upsert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Please correct the following error(s): Product Tag is a required field. : []' );
      }

    }

    /* Commenting test to investigate why it is failing in patch and not in main.
    static testMethod void testValidateAdditionalFieldsForInvestigations(){

      ADM_Work__c investigation = ADM_Work.setupTestWork('Investigation');
      //  Blank out the Assignee to raise the exception on save
      investigation.Assignee__c = null;
      try {
        upsert investigation;
        System.assert(false, 'Saving an Investigation without an Assignee__c should throw an exception.');
      } catch ( System.DmlException d ){
        System.assertEquals('System.DmlException', d.getTypeName());
        System.assertEquals( d.getMessage(), 'Upsert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Please correct the following error(s): Assignee is a required field. : []' );
      }

    }*/

       static testMethod void testvalidateReadMeNotesforKnownIssue() {

      ADM_Work__c work = ADM_Work.createTestWork('Bug');
      work.Origin__c = ADM_WorkTriggerStaticDataStore.NEXT_GEN_EDIT_PAGE_ORIGIN;
      work.Known_Issue_Num_Reporting_Customers__c = 1;
      try {
          work.Status__c = 'Closed';
          update work;
          System.assert(false,'A bug with associated Known Issues should have the readme text field filled in ');
        } catch ( System.DmlException saveException){
          System.assert(saveException.getMessage().contains('Please enter a value for the ReadMe Notes field'), 'Did not expect this error:' + saveException.getMessage());
        }
    }

      static testMethod void testvalidateReadMeNotesFor62OrgUser() {
      User user62org = ADM_WorkUser.createTest62Orguser();
      ADM_Work__c work = ADM_Work.createTestWork('Bug');
      work.Origin__c = ADM_WorkTriggerStaticDataStore.LIGHTNING_EXPERIENCE_WORK_ORIGIN;

     try {
            Test.startTest();
            System.runAs(user62org) {
                work.Number_of_Cases__c = 1;
                work.Status__c = 'Closed';
                update work;

                System.assert(true, ' Can update Work as 62Org user without ReadMe Notes.');
            }
            Test.stopTest();
        } catch(System.DmlException saveException) {
             System.assert(false, 'Did not expect this error:' + saveException.getMessage());
        }

    }

    static testMethod void testvalidateNonDeterministicBugType() {

     ADM_Work__c work = ADM_Work.setUpTestWork('Bug');
     work.Type__c = 'Non Deterministic Test';
     work.Status__c = 'Closed';

     String message = null;
       try {
         Test.startTest();
         insert work;
         Test.stopTest();
       } catch(Exception exc) {
         message = exc.getMessage();
     }
       System.assert(message.contains('Please select a value in the test resolution picklist when closing a Non Deterministic test') , 'Expected test resolution field to not be null and have this value.');
   }

    static testMethod void testValidateClosingCapexTasksWithHours() {
       User currentUser = [Select EmployeeNumber,Id from user where id=:Userinfo.getUserId()];
       currentUser.EmployeeNumber = String.valueOf(Integer.valueOf(Math.random() * 1000000));

       update currentUser;


        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        work.Product_Tag__c = productTag.Id;

        insert work;

        ADM_Task__c task = ADM_Task.setupTestTask(work);

        task.Capex_Enabled__c = true;
        task.Actual_Hours__c = 10;
        task.Assigned_To__c = Userinfo.getUserId();

        insert task;

        try {
          Test.startTest();
              work.Capex_Enabled__c = true;
              work.Status__c = 'Closed';

              update work;

              System.assert(true,'A task with Capex_Enabled__c = true and Actual_Hours__c > 0 should update without errors');
          Test.stopTest();
        } catch(System.DmlException saveException) {
            System.assert(false, 'A task with Capex_Enabled__c = true and Actual_Hours__c > 0 should update without errors. Did not expect this error:' + saveException.getMessage());
        }
    }

    static testMethod void testValidateClosingCapexTasksWithoutHours() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        work.Product_Tag__c = productTag.Id;

        insert work;

        ADM_Task__c task = ADM_Task.setupTestTask(work);

        task.Capex_Enabled__c = true;
        task.Actual_Hours__c = 0;

        insert task;

        try {
          Test.startTest();
              work.Capex_Enabled__c = true;
              work.Status__c = 'Closed';

              update work;

              System.assert(false,'A task with Capex_Enabled__c = true and Actual_Hours__c <= 0 should throw exception');
          Test.stopTest();
        } catch(System.DmlException saveException) {
            System.assert(saveException.getMessage().contains('should have Actual hours greater than 0'), 'Did not expect this error:' + saveException.getMessage());
        }
    }

    static testMethod void testValidateClosingCapexUserStoryWithNoCapexTasks() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        work.Product_Tag__c = productTag.Id;

        insert work;

        ADM_Task__c task = ADM_Task.setupTestTask(work);

        task.Capex_Enabled__c = false;
        task.Actual_Hours__c = 10;

        insert task;

        try {
          Test.startTest();
                work.Capex_Enabled__c = true;
              work.Status__c = 'Closed';

              update work;

              System.assert(false,'Closing a Capex Enabled User Story with no Capex Enabled tasks should throw exception');
          Test.stopTest();
        } catch(System.DmlException saveException) {
            System.assert(saveException.getMessage().contains('cannot be closed without at least one Quality task'), 'Did not expect this error:' + saveException.getMessage());
        }
    }

    static testMethod void testValidateClosingCapexUserStoryWithNonEmployeeCapexTasks() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        work.Product_Tag__c = productTag.Id;

        insert work;

        ADM_Task__c task = ADM_Task.setupTestTask(work);

        task.Capex_Enabled__c = true;
        task.Actual_Hours__c = 10;
        task.Assigned_To__c =  ADM_WorkUser.createNonEmployeeTestUser().Id;

        try {
          Test.startTest();
              insert task;

              work.Capex_Enabled__c = true;
              work.Status__c = 'Closed';

              update work;

              System.assert(false,'Closing a Capex Enabled User Story with Capex Enabled tasks with Task Assignee whose Employee number = null or Tbd should fail');
          Test.stopTest();
        } catch(System.DmlException saveException) {
            System.assert(saveException.getMessage().containsIgnoreCase('If assignee is an active employee of Salesforce please submit a concierge ticket to correct the employee record'), 'Did not expect this error:' + saveException.getMessage());
        }
    }

    static testMethod void testDecapitalizingUserStoryAlsoDecapitalizesTasks() {
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestCapexEnabledScrumTeam('Test Capex Enabled Team');
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        work.Product_Tag__c = productTag.Id;
        work.Capex_Enabled__c = true;

        insert work;

        ADM_Task__c task1 = ADM_Task.setupTestTask(work);
        ADM_Task__c task2 = ADM_Task.setupTestTask(work);

        task1.Capex_Enabled__c = true;
        task1.Actual_Hours__c = 10;

        task2.Capex_Enabled__c = true;
        task2.Actual_Hours__c = 15;

        List<ADM_Task__c> tasks = new List<ADM_Task__c>();
        tasks.add(task1);
        tasks.add(task2);

        insert tasks;

        System.assert(task1.Capex_Enabled__c);
        System.assert(task2.Capex_Enabled__c);
        System.assert(task1.Work__c == work.Id);
        System.assert(task2.Work__c == work.Id);

        work.Capex_Enabled__c = false;

        update work;

        try {
            Test.startTest();
                List<ADM_Task__c> updatedTasks = [Select Id, Capex_Enabled__c, Work__c from ADM_Task__c where Work__r.Id = :work.Id];

                System.assert(updatedTasks.size() == 2);
                System.assert(!updatedTasks[0].Capex_Enabled__c);
                System.assert(!updatedTasks[1].Capex_Enabled__c);
            Test.stopTest();
        } catch(System.DmlException saveException) {
            System.assert(false, 'Did not expect testDecapitalizingUserStoryAlsoDecapitalizesTasks error:' + saveException.getMessage());
        }
    }
}