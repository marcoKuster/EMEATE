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
private class QA_PendingExecutionsControllerTests {

  
    private static QA_Test_Case__c getTestCase() {
        
                QA_Test_Case__c testCase = new QA_Test_Case__c();
                testCase.Brief_Description__c = 'TestTC1';
                testCase.Hierarchy__c = 'API.TCMassEdit.Test';
                testCase.Priority__c = 'Medium';
                testCase.Execution_Type__c = 'Manual';
                testCase.Steps_To_Reproduce__c = 'I like testing :)';
                testCase.Expected_Results__c = 'The test is expected to pass';
                insert(testCase);
            

            return testCase;
       
    }

    private static List<QA_Test_Execution__c> getTestExecs(Id workID, Id testCaseId) {
        
            
        QA_Test_Execution__c testTE = new QA_Test_Execution__c();
        testTE.Test_Case__c = testCaseId;
        testTE.Status__c = 'Blocked';
        testTE.Type__c = 'Manual';
        testTE.User_Story__c = workID;
        testTE.Assignee__c = UserInfo.getUserID();
        testTE.Number_Of_Executions__c = 1;

        QA_Test_Execution__c testTE2 = new QA_Test_Execution__c();
        testTE2.Test_Case__c = testCaseId;
        testTE2.Status__c = 'Failed';
        testTE2.Date_of_Last_Execution__c = System.now();
        testTE2.Type__c = 'Ftest';
        testTE2.User_Story__c = workID;
        testTE2.Assignee__c = UserInfo.getUserID();
        testTE2.Number_Of_Executions__c = 1;

        List<QA_Test_Execution__c> testExecs = new List<QA_Test_Execution__c>{testTE, testTE2};
        insert testExecs;
  
        return testExecs;

    }

   

 /**
 * @testcaseID a0B20000009evZzEAI
 * @userStory a07B0000000DfNy
 * @hierarchy GUS.QaforceToGUS.Pending Test Executions.Inline Edit Cancel
 * @expectedResults User is able to cancel out of a inline edit test execution
 */

    private static testMethod void verifyCancelling(){
        

        //create a pendingexecsv2 object
        QA_PendingExecutionsController testPE = new QA_PendingExecutionsController();
        testPE.init = false;

        //test the cancelAllUpdatedTEs and setisUpdating method
        testPE.setIsUpdating(true);
        System.assertEquals(null, testPE.cancelAllUpdatedTEs());
        System.assertEquals(false,testPE.getIsUpdating());
    }

/**
 * @testcaseID  a0B20000009evZyEAI
 * @userStory a07B0000000DfNy
 * @hierarchy GUS.QaforceToGUS.Pending Test Executions.Inline Edit Save
 * @expectedResults User is able to inline edit one or a few test executions at the same time
 */
    private static testMethod void verifyDestState(){
       

        //create a pendingexecsv2 object
        QA_PendingExecutionsController testPE = new QA_PendingExecutionsController();
        testPE.init = false;

        //test the get and set destState methods
        testPE.setDestState('asda');
        System.assertEquals('asda', testPE.getDestState());
    }

/**
 * @testcaseID a0B20000009evZsEAI
 * @userStory a07B0000000DfNy
 * @hierarchy GUS.QaforceToGUS.Pending Test Executions.Select All
 * @expectedResults User is able to check all of the test executions
 */

 
/**
 * @testcaseID a0B20000009evZtEAI
 * @userStory a07B0000000DfNy
 * @hierarchy GUS.QaforceToGUS.Pending Test Executions.Select None
 * @expectedResults User is able to un-check all of the test executions
 */
    
  /*  private static testMethod void testQA_PendingExecutionsControllerFilterTests(){
        
        List<QA_Test_Execution__c> execs = getTestExecs(ADM_Work.createTestWork('User Story').id, getTestCase().id);
        
        QA_Test_Execution__c testTE = execs.get(0);
        QA_Test_Execution__c testTE2 = execs.get(1);
        
        //create a pendingexecsv2 object
        QA_PendingExecutionsController testPE = new QA_PendingExecutionsController();
        testPE.init = false;

        //add testing for the getTestExecs method here
        testPE.setSortCol('Status');
        testPE.setAssignee(UserInfo.getUserID());
        testPE.filter();
        System.assertEquals(testTE2.Id,testPE.getTestExecs()[0].getTEID());
        testPE.resetTestExecs();
        testPE.setSortCol('Name');
        testPE.filter();
        
        //test the sortTE method
        //testPE.sortBy = 'Status';
        //testPE.sortTE();
        //System.assertEquals(testTE2.Id, testPE.getTestExecs()[0].getTEID());

        //test the getMarkOptions and getSortOptions method
        List<SelectOption> temp = testPE.getMarkOptions();
        System.assertEquals(temp.get(1).getValue(), 'In Progress');
        temp = testPE.getSortOptions();
        testPE.setSortCol('Test Case');
        testPE.filter();
        System.assertEquals(testTE.Id,testPE.getTestExecs()[0].getTEID());
        testPE.resetTestExecs();
        testPE.setSortCol('Hierarchy');
        testPE.filter();
        System.assertEquals(testTE.Id,testPE.getTestExecs()[0].getTEID());
        testPE.resetTestExecs();
        testPE.setSortCol('Brief Description');
        testPE.filter();
        System.assertEquals(testTE.Id,testPE.getTestExecs()[0].getTEID());
        testPE.resetTestExecs();
        testPE.setSortCol('User Story');
        testPE.filter();
        System.assertEquals(testTE.Id,testPE.getTestExecs()[0].getTEID());
        testPE.resetTestExecs();
        testPE.setSortCol('Sprint');
        testPE.filter();
        System.assertEquals(testTE.Id,testPE.getTestExecs()[0].getTEID());
        
        
        
    } */
    
   /* private static testMethod void testQA_PendingExecutionsControllerAddBugs(){
        
        //create a pendingexecsv2 object
        QA_PendingExecutionsController testPE = new QA_PendingExecutionsController();
        testPE.init = false;

        //add testing for the getTestExecs method here
        testPE.setSortCol('Status');
        testPE.setAssignee(UserInfo.getUserID());
        testPE.filter();
        System.assertEquals(testTE2.Id,testPE.getTestExecs()[0].getTEID());
        testPE.resetTestExecs();
        testPE.setSortCol('Name');
        testPE.filter();
        
        //test the sortTE method
        //testPE.sortBy = 'Status';
        //testPE.sortTE();
        //System.assertEquals(testTE2.Id, testPE.getTestExecs()[0].getTEID());

      
        
        //test the addBugs method
        testPE.setBugList('');
        System.assertEquals(null, testPE.addBugs());
        testPE.setBugList(work.Name);
        testPE.getTestExecs()[1].setCbox(true);
        testPE.addBugs();
        System.assertEquals(false, testPE.getTestExecs()[1].getCBox());
        System.assertEquals('', testPE.getBugList());
        System.assertEquals(work.Name, testPE.getTestExecs()[1].getTe().Bugs__c);
        testPE.getTestExecs()[0].getTe().Bugs__c = null;
        testPE.getTestExecs()[0].setCbox(true);
        testPE.setBugList('123456');
        testPE.addBugs();
        System.assertEquals('123456', testPE.getTestExecs()[0].getTe().Bugs__c);
        testPE.getTestExecs()[0].setCbox(true);
        testPE.setBugList('654654asd,6a5s4d65as4,5sa54d6a4s'); //this should cause an exception
        testPE.addBugs();
        System.assertEquals('123456', testPE.getTestExecs()[0].getTe().Bugs__c);

        //test the selectAll and selectNone methods
        testPE.selectAll();
        System.assertEquals(true, testPE.getTestExecs()[1].getCbox(), '->' + testPE.getTestExecs()[1]);
        testPE.selectNone();
        System.assertEquals(false, testPE.getTestExecs()[0].getCbox());

        //test the getTESizeOverFifty method
        System.assertEquals(false, testPE.getTESizeOverFifty());

        //test the lockOthers method
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.lockOthers();
        System.assertEquals(false,testPE.getTestExecs()[0].locked);
        System.assertEquals(true,testPE.getTestExecs()[1].locked);

        //test the unlockAll method
        testPE.unlockAll();
        System.assertEquals(false, testPE.getTestExecs()[1].locked);
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.getTestExecs()[0].editBriefDesc = true;
        testPE.getTestExecs()[0].editStatus = true;
        testPE.unlockAll();
        System.assertEquals(true, testPE.getTestExecs()[0].isUpdating);

        //test the getIsUpdating method
        testPE.getTestExecs()[0].isUpdating = true;
        System.assertEquals(true, testPE.getIsUpdating());
        testPE.getTestExecs()[0].isUpdating = false;
        System.assertEquals(false, testPE.getIsUpdating());

        //test the saveAllUpdatedTEs method
        testPE.getTestExecs()[0].TC.Brief_Description__c = 'This is my new brief desc';
        testPE.getTestExecs()[0].TE.Status__c = 'Planned';
        testPE.saveAllUpdatedTEs();

        //test the changeStatus method
        testPE.setDestState('MARKAS');
        System.assertEquals(null, testPE.changeStatus());
        testPE.setDestState('In Progress');
        testPE.getTestExecs()[0].setCbox(true);
        testPE.changeStatus();
        System.assertEquals(false, testPE.getTestExecs()[0].getCBox());
        System.assertEquals('In Progress', testPE.getTestExecs()[0].getTe().Status__c);

        //test the get and set SortBy methods
        testPE.setSortBy('Name');
        System.assertEquals('Name', testPE.getSortBy());

        //test the get and set BugList methods
        testPE.setBugList('134679');
        System.assertEquals('134679', testPE.getBugList()); 
        
        
        
    } */
    
   /* private static testMethod void testQA_PendingExecutionsController(){
        
        List<QA_Test_Execution__c> execs = getTestExecs(ADM_Work.createTestWork('User Story').id, getTestCase().id);
        
        QA_Test_Execution__c testTE = execs.get(0);
        QA_Test_Execution__c testTE2 = execs.get(1);
        
        //create a pendingexecsv2 object
        QA_PendingExecutionsController testPE = new QA_PendingExecutionsController();
        testPE.init = false;

        //add testing for the getTestExecs method here
        testPE.setSortCol('Status');
        testPE.setAssignee(UserInfo.getUserId());
        testPE.filter();
        System.assertEquals(testTE2.Id,testPE.getTestExecs()[0].getTEID());
        testPE.resetTestExecs();
        testPE.setSortCol('Name');
        testPE.filter();
        
        //test the sortTE method
        //testPE.sortBy = 'Status';
        //testPE.sortTE();
        //System.assertEquals(testTE2.Id, testPE.getTestExecs()[0].getTEID());

        //test the getMarkOptions and getSortOptions method
        List<SelectOption> temp = testPE.getMarkOptions();
        System.assertEquals(temp.get(1).getValue(), 'In Progress');
        temp = testPE.getSortOptions();
        System.assertEquals(temp.get(1).getValue(), 'Test Case');

        


        //////////////////////////////////TESTS FOR THE WRAPPER CLASS///////////////////////////////////
        //test the getIndex method
        System.assertEquals(2, testPE.getTestExecs()[1].getIndex());

        //test the setallEdit method
        testPE.getTestExecs()[0].setAllEdit(true);
        System.assertEquals(true,testPE.getTestExecs()[0].editStatus);

        //test the getTE and getTC methods
        System.assertEquals('Failed',testPE.getTestExecs()[1].getTe().Status__c);
        System.assertEquals('API.TCMassEdit.Test',testPE.getTestExecs()[0].getTc().Hierarchy__c);


        //test the get and set cbox methods
        testPE.getTestExecs()[0].setCbox(true);
        System.assertEquals(true, testPE.getTestExecs()[0].getCbox());

        //test a few random get methods which help the pageBlockTable correctly display some data
        //System.assertEquals('This is my new brief desc', testPE.getTestExecs()[0].getBriefDesc());
        System.assertEquals('I like testing :)', testPE.getTestExecs()[0].getStepsReproduce());
        System.assertEquals('The test is expected to pass', testPE.getTestExecs()[0].getEResults());
        System.assertEquals('API.TCMassEdit.Test', testPE.getTestExecs()[0].getHier());

        //test get and set ShouldEditBriefDesc methods
        testPE.getTestExecs()[0].locked = true;
        testPE.getTestExecs()[0].isUpdating = false;
        testPE.getTestExecs()[0].setShouldEditBriefDesc(true);
        System.assertEquals(false,testPE.getTestExecs()[0].isUpdating);
        testPE.getTestExecs()[0].locked = false;
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.getTestExecs()[0].setShouldEditBriefDesc(true);
        System.assertEquals(true, testPE.getTestExecs()[0].getShouldEditBriefDesc());

        //test get and set ShouldEditLongDesc methods
        testPE.getTestExecs()[0].locked = true;
        testPE.getTestExecs()[0].isUpdating = false;
        testPE.getTestExecs()[0].setShouldEditLongDesc(true);
        System.assertEquals(false,testPE.getTestExecs()[0].isUpdating);
        testPE.getTestExecs()[0].locked = false;
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.getTestExecs()[0].setShouldEditLongDesc(true);
        System.assertEquals(true, testPE.getTestExecs()[0].getShouldEditLongDesc());

        //test get and set ShouldEditStatus methods
        testPE.getTestExecs()[0].locked = true;
        testPE.getTestExecs()[0].isUpdating = false;
        testPE.getTestExecs()[0].setShouldEditStatus(true);
        System.assertEquals(false,testPE.getTestExecs()[0].isUpdating);
        testPE.getTestExecs()[0].locked = false;
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.getTestExecs()[0].setShouldEditStatus(true);
        System.assertEquals(true, testPE.getTestExecs()[0].getShouldEditStatus());

        //test get and set ShouldEditEResults methods
        testPE.getTestExecs()[0].locked = true;
        testPE.getTestExecs()[0].isUpdating = false;
        testPE.getTestExecs()[0].setShouldEditEResults(true);
        System.assertEquals(false,testPE.getTestExecs()[0].isUpdating);
        testPE.getTestExecs()[0].locked = false;
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.getTestExecs()[0].setShouldEditEResults(true);
        System.assertEquals(true, testPE.getTestExecs()[0].getShouldEditEResults());

        //test get and set ShouldEditHier methods
        testPE.getTestExecs()[0].locked = true;
        testPE.getTestExecs()[0].isUpdating = false;
        testPE.getTestExecs()[0].setShouldEditHier(true);
        System.assertEquals(false,testPE.getTestExecs()[0].isUpdating);
        testPE.getTestExecs()[0].locked = false;
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.getTestExecs()[0].setShouldEditHier(true);
        System.assertEquals(true, testPE.getTestExecs()[0].getShouldEditHier());

        //test get and set ShouldEditType methods
        testPE.getTestExecs()[0].locked = true;
        testPE.getTestExecs()[0].isUpdating = false;
        testPE.getTestExecs()[0].setShouldEditType(true);
        System.assertEquals(false,testPE.getTestExecs()[0].isUpdating);
        testPE.getTestExecs()[0].locked = false;
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.getTestExecs()[0].setShouldEditType(true);
        System.assertEquals(true, testPE.getTestExecs()[0].getShouldEditType());

        //test get and set ShouldEditBugs methods
        testPE.getTestExecs()[0].locked = true;
        testPE.getTestExecs()[0].isUpdating = false;
        testPE.getTestExecs()[0].setShouldEditBugs(true);
        System.assertEquals(false,testPE.getTestExecs()[0].isUpdating);
        testPE.getTestExecs()[0].locked = false;
        testPE.getTestExecs()[0].isUpdating = true;
        testPE.getTestExecs()[0].setShouldEditBugs(true);
        System.assertEquals(true, testPE.getTestExecs()[0].getShouldEditBugs());

        //test the get and set Revert methods
        System.assertEquals(null, testPE.getTestExecs()[0].getRevertBriefDesc());
        System.assertEquals(null, testPE.getTestExecs()[0].getRevertLongDesc());
        System.assertEquals(null, testPE.getTestExecs()[0].getRevertStatus());
        System.assertEquals(null, testPE.getTestExecs()[0].getRevertEResults());
        System.assertEquals(null, testPE.getTestExecs()[0].getRevertHier());
        System.assertEquals(null, testPE.getTestExecs()[0].getRevertType());
        System.assertEquals(null, testPE.getTestExecs()[0].getRevertBugs());
        testPE.getTestExecs()[0].setRevertBriefDesc('test');
        testPE.getTestExecs()[0].setRevertLongDesc('test');
        testPE.getTestExecs()[0].setRevertStatus('test');
        testPE.getTestExecs()[0].setRevertEResults('test');
        testPE.getTestExecs()[0].setRevertHier('test');
        testPE.getTestExecs()[0].setRevertType('test');
        testPE.getTestExecs()[0].setRevertBugs('test');
        System.assertEquals(false, testPE.getTestExecs()[0].editBriefDesc);
        System.assertEquals(false, testPE.getTestExecs()[0].editLongDesc);
        System.assertEquals(false, testPE.getTestExecs()[0].editStatus);
        System.assertEquals(false, testPE.getTestExecs()[0].editEResults);
        System.assertEquals(false, testPE.getTestExecs()[0].editHier);
        System.assertEquals(false, testPE.getTestExecs()[0].editType);
        System.assertEquals(false, testPE.getTestExecs()[0].editBugs);

        ////////////////////////////////END TESTS FOR THE WRAPPER CLASS/////////////////////////////////
    } */

}