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
private class QA_TestExecutionTriggersTest {

    private static ADM_Scrum_Team__c team {
        get {
            if(team == null) {
              team = ADM_ScrumTeam.get('Id', sprint.Scrum_Team__c, 'Name', 'asc');
            }
            return team;
        }
        set;
    }

    private static ADM_Sprint__c sprint {
        get {
            if(sprint == null) {
              sprint = ADM_Sprint.createTestSprint();
            }
            return sprint;
        }
        set;
    }

    private static ADM_Work__c[] works{
        get {
            if(works == null) {
                works = ADM_Work.getAllBy('Sprint__c', new List<String>{String.valueOf(sprint.Id)}, 0, 5, 'Id', 'asc');
                if(works.size() < 5) {
                    List<ADM_Work__c> works2insert = new List<ADM_Work__c>();
                    for(Integer i = 0; i < 5; i++) {
                        ADM_Work__c w = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
                        w.Scrum_Team__c = team.Id;
                        w.Sprint__c = sprint.Id;
                        w.Subject__c += i;
                        works2insert.add(w);
                    }
                    insert works2insert;
                    works = ADM_Work.getAllBy('Sprint__c', new List<String>{String.valueOf(sprint.Id)}, 0, 5, 'Id', 'asc');
                }
            }
            return works;
        }
        set;
    }

    private static ADM_Work__c work {
        get {
            if(work == null) {
                for(ADM_Work__c w : works) {
                    if(w.RecordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME)) {
                        work = w;
                    }
                }
            }
            return work;
        }
        set;
    }

    private static ADM_Work__c userStory {
        get {
            if(userStory == null) {
                for(ADM_Work__c w : works) {
                    if(w.RecordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
                        userStory = w;
                    }
                }
            }
            return userStory;
        }
        set;
    }

    private static Id assignee {
        get {
            if(assignee == null) {
                assignee = work.Assignee__c;
            }
            return assignee;
        }
        set;
    }

    private static QA_Test_Case__c testCase {
        get {
            if(testCase == null) {
                QA_Hierarchy__c hierarchy = new QA_Hierarchy__c();
                hierarchy.Name = 'API';
                hierarchy.Depth__c = 0;
                insert hierarchy;
        
                testCase = new QA_Test_Case__c();
                testCase.Brief_Description__c = 'TestTC1';
                testCase.Hierarchy__c = 'API.TCMassEdit.Test';
                testCase.Priority__c = 'Medium';
                testCase.Execution_Type__c = 'Manual';
                testCase.Steps_To_Reproduce__c = 'I like testing :)';
                testCase.Expected_Results__c = 'The test is expected to pass';
                insert(testCase);
            }

            return testCase;
        }
        set;
    }

    private static List<QA_Test_Execution__c> testExecs {
        get {
            if(testExecs == null) {
                QA_Test_Execution__c testTE = new QA_Test_Execution__c();
                testTE.Test_Case__c = testCase.Id;
                testTE.Status__c = 'Blocked';
                testTE.Type__c = 'Manual';
                testTE.User_Story__c = userStory.Id;
                testTE.Assignee__c = assignee;
                testTE.Number_Of_Executions__c = 1;

                QA_Test_Execution__c testTE2 = new QA_Test_Execution__c();
                testTE2.Test_Case__c = testCase.Id;
                testTE2.Status__c = 'Failed';
                testTE2.Date_of_Last_Execution__c = System.now();
                testTE2.Type__c = 'Ftest';
                testTE2.User_Story__c = userStory.Id;
                testTE2.Assignee__c = assignee;
                testTE2.Number_Of_Executions__c = 1;

                testExecs = new List<QA_Test_Execution__c>{testTE, testTE2};
                insert testExecs;
            }
            return testExecs;
        }
        set;
    }

    private static QA_Test_Execution__c testTE {
        get {
            if(testTE == null) {
                testTE = testExecs.get(0);
            }
            return testTE;
        }
        set;
    }

    private static QA_Test_Execution__c testTE2 {
        get {
            if(testTE2 == null) {
                testTE2 = testExecs.get(1);
            }
            return testTE2;
        }
        set;
    }


/**
 * @testcaseID a0B20000009euqlEAA
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Delete Selected
 * @expectedResults A message displays: "Please select at least one object to delete."
 */
 /**
 * @testcaseID a0B20000009euumEAA
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Delete Selected
 * @expectedResults A message displays: "Deleted X object(s)."
 */

/**
 * @testcaseID a0B20000009euunEAA
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Delete Selected
 * @expectedResults A message displays: "Please select at least one object to delete."
 */
    
    
 
    
    static testMethod void verifyDeleteTrigger() {
        Test.startTest();
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        Test.stopTest();
        
        QA_Test_Execution__c testExecution = new QA_Test_Execution__c();
        testExecution.Test_Case__c = testCase.Id;
        testExecution.Status__c = 'Passed';
        testExecution.Type__c = 'Manual';
        testExecution.Number_of_Executions__c = 1;
        testExecution.Assignee__c = UserInfo.getUserId();
        testExecution.User_Story__c = story.id;
        insert testExecution;
		
		
        Database.Deleteresult[] results = Database.delete(new List<QA_Test_Execution__c>{testExecution}, false);
        for(Database.Deleteresult result : results) {
            System.assertEquals(true,result.isSuccess());
        }

        Database.Undeleteresult[] uResults = Database.undelete(new List<QA_Test_Execution__c>{testExecution}, false);
        for(Database.Undeleteresult result : uResults) {
            System.assertEquals(true,result.isSuccess());
        }
        
    }

     /**
 * @testcaseID a0B20000009euqrEAA
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Switch Assignee
 * @expectedResults The test executions are moved to another valid assignee
 */

  /**
 * @testcaseID a0B20000009ev6NEAQ
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Switch Assignee
 * @expectedResults An error message should occur
 */

  /**
 * @testcaseID a0B20000009ev6OEAQ
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Switch Assignee
 * @expectedResults An error message occurs: Please select at least one Test Exectuion to stwitch to a different Assignee.
 */
    static testMethod void verifyAssigneeCannotBeNull() {       
        Test.startTest();
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        Test.stopTest();
        Set<String> errorMessage = new Set<String>();
        QA_Test_Execution__c testExecution = new QA_Test_Execution__c();
        testExecution.Test_Case__c = testCase.Id;
        testExecution.Status__c = 'Passed';
        testExecution.Type__c = 'Manual';
        
        testExecution.User_Story__c = story.Id;
        testExecution.Date_of_Last_Execution__c = System.now();
        testExecution.Number_of_Executions__c = 10;
        
        Database.Saveresult result = Database.insert(testExecution, false);
        for(Database.Error e : result.getErrors()) {
            errorMessage.add(e.getMessage());
        }     
        System.assertEquals(true, errorMessage.contains('Test Execution Insert|Update Error: Assignee is mandatory to insert|update a test execution record.'), '->' + errorMessage);
        
    }
    
     /**
 * @testcaseID a0B20000009euqqEAA
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Move to a Different User Story
 * @expectedResults The test executions are moved to another valid user story
 */
  /**
 * @testcaseID a0B20000009ev5oEAA
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Move to a Different User Story
 * @expectedResults An error message should occur
 */
  /**
 * @testcaseID a0B20000009ev5pEAA
 * @userStory a07B0000000DfNyIAK
 * @hierarchy GUS.QaforceToGUS.Test Execution Related List.Move to a Different User Story
 * @expectedResults An error message occurs: Please select at least one Test Exectuion to move to a different User Story.
 */
    static testMethod void verifyUserStoryCannotBeNull() {       
        Set<String> errorMessage = new Set<String>();
        QA_Test_Execution__c testExecution = new QA_Test_Execution__c();
        testExecution.Test_Case__c = testCase.Id;
        testExecution.Status__c = 'Passed';
        testExecution.Type__c = 'Manual';
        testExecution.Date_of_Last_Execution__c = System.now();
        testExecution.Number_of_Executions__c = 10;
        testExecution.Assignee__c = UserInfo.getUserID();  
        
        
        Database.Saveresult result = Database.insert(testExecution, false);
        for(Database.Error e : result.getErrors()) {
            errorMessage.add(e.getMessage());
        }     
        System.assertEquals(true, errorMessage.contains('Test Execution Insert|Update Error: User Story is mandatory to insert|update a test execution record.'), '->' + errorMessage);
        
    }
    
    static testMethod void verifyDateCannotBeGreaterThanToday() {       
        Test.startTest();
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        Test.stopTest();
        Set<String> errorMessage = new Set<String>();
        QA_Test_Execution__c testExecution = new QA_Test_Execution__c();
        testExecution.Test_Case__c = testCase.Id;
        testExecution.Status__c = 'Passed';
        testExecution.Type__c = 'Manual'; 
        testExecution.User_Story__c = story.Id;
        testExecution.Date_of_Last_Execution__c = System.now().addDays(1);
        testExecution.Number_of_Executions__c = 10;
        testExecution.Assignee__c = UserInfo.getUserID();  
        
        Database.Saveresult result = Database.insert(testExecution, false);
        for(Database.Error e : result.getErrors()) {
            errorMessage.add(e.getMessage());
        }     
        System.assertEquals(true, errorMessage.contains('Date of Last Execution should be less than the current date!'), '->' + errorMessage);
        
    }
    
   /* static testMethod void verifyNumberOfExecutionsIncrements() {       
        Set<String> errorMessage = new Set<String>();
        QA_Test_Execution__c testExecution = new QA_Test_Execution__c();
        testExecution.Test_Case__c = testCase.Id;
        testExecution.Status__c = 'Passed';
        testExecution.Type__c = 'Manual';
        testExecution.User_Story__c = userStory.Id;
        testExecution.Date_of_Last_Execution__c = System.now();
        testExecution.Number_of_Executions__c = 0;
        testExecution.Assignee__c = assignee;
        
        Database.Saveresult result = Database.insert(testExecution, false);
        System.assertEquals(true, result.isSuccess());
        
        testExecution = [select Status__c, Number_of_Executions__c, Date_of_Last_Execution__c from QA_Test_Execution__c where Id = : result.getId()];
        System.assertNotEquals(null, testExecution.Date_of_Last_Execution__c);
        System.assertEquals(1, testExecution.Number_of_Executions__c);
        
    } 
    
    static testMethod void verifyUpdates() {       
        Set<String> errorMessage = new Set<String>();
        QA_Test_Execution__c testExecution = new QA_Test_Execution__c();
        testExecution.Test_Case__c = testCase.Id;
        testExecution.Status__c = 'Passed';
        testExecution.Type__c = 'Manual';
        testExecution.User_Story__c = userStory.Id;
        testExecution.Number_of_Executions__c = 1;
        testExecution.Assignee__c = assignee;
        
        Database.Saveresult result = Database.insert(testExecution, false);
        System.assertEquals(true, result.isSuccess());
        
        testExecution.Status__c = 'Failed';
        update testExecution;
        testExecution = [select Status__c, Number_of_Executions__c, Date_of_Last_Execution__c from QA_Test_Execution__c where Id = : result.getId()];
        System.assertNotEquals(null, testExecution.Date_of_Last_Execution__c);
        System.assertEquals(2, testExecution.Number_of_Executions__c);
    }

*/

/*
        

    static testMethod void verifyNonNegativeTrigger() {
        Set<String> errorMessage = new Set<String>();
        QA_Test_Execution__c testExecution = new QA_Test_Execution__c();
        testExecution.Test_Case__c = testCase.Id;
        testExecution.Status__c = 'Passed';
        testExecution.Type__c = 'Manual';
        
        //no assignee
        testExecution.User_Story__c = userStory.Id;
        testExecution.Date_of_Last_Execution__c = System.now();
        
        Database.Saveresult result = Database.insert(testExecution, false);
        for(Database.Error e : result.getErrors()) {
            errorMessage.add(e.getMessage());
        }     
        System.assertEquals(1, errorMessage.size(), '->' + errorMessage);
        
        //no user story
        testExecution.Assignee__c = assignee;
        testExecution.User_Story__c = null;
        testExecution.Date_of_Last_Execution__c = System.now();
        
        result = Database.insert(testExecution, false);
        for(Database.Error e : result.getErrors()) {
            errorMessage.add(e.getMessage());
        }
        System.assertEquals(2, errorMessage.size(), '->' + errorMessage);
                
        //newer exec date
        testExecution.Assignee__c = assignee;
        testExecution.User_Story__c = userStory.Id;
        testExecution.Date_of_Last_Execution__c = System.now().addDays(1);
        result = Database.insert(testExecution, false);
        for(Database.Error e : result.getErrors()) {
            errorMessage.add(e.getMessage());
        }        
        System.assertEquals(3, errorMessage.size(), '->' + errorMessage);
        //System.assertEquals(true, errorMessage.contains('Test Execution Insert|Update Error: Assignee is mandatory to insert|update a test execution record.'), '->' + errorMessage);
        //System.assertEquals(true, errorMessage.contains('Test Execution Insert|Update Error: User Story is mandatory to insert|update a test execution record.'), '->' + errorMessage);
        
        //number of execs less than 1
        testExecution.Assignee__c = assignee;
        testExecution.User_Story__c = userStory.Id;
        testExecution.Date_of_Last_Execution__c = System.now().addDays(1);
        result = Database.insert(testExecution, false);
        for(Database.Error e : result.getErrors()) {
            errorMessage.add(e.getMessage());
        }  

        System.assertNotEquals(null, result.getId(), '->' + result);
        //System.assertEquals(true, errorMessage.contains('Number of Executions has to be >= 1 for Passed or Failed status and >= 0 for others.'));

        Database.Upsertresult uResult = Database.upsert(testExecution, false);
        
        for(Database.Error e : result.getErrors()) {
            errorMessage.add(e.getMessage());
        }
        
        System.assertEquals(3, errorMessage.size(), '->' + errorMessage);
        System.assertNotEquals(null, result.getId(), '->' + result);
        //System.assertEquals(2, errorMessage.size(), '->' + errorMessage);
        
        /*
        testExecution.Status__c = 'Failed';
        update testExecution;
        testExecution = [select Status__c, Number_of_Executions__c, Date_of_Last_Execution__c from QA_Test_Execution__c where Id = : result.getId()];
        System.assertEquals(2, testExecution.Number_of_Executions__c);*/
    //}
}