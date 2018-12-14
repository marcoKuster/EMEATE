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
private class QA_AddTEtoUSExtensionTests {
    //Tests

/**
 * testcaseID a0B20000009eawAEAQ
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Finish Test Execution page
 * @expectedResults User is taken back to the user story page and test executions are added in the test execution tree under Actions tab. Test executions are shown in the following order: status, assignee, hierarchy and test case
 */

 /**
 * testcaseID a0B20000009eawDEAQ
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Finish Test Execution page
 * @expectedResults Users are able to create test executions from closed user stories
 */

 /**
 * testcaseID a0B20000009eavzEAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults User is able to create a test execution with mandatory fields only (assignee, status and type)
 */

 /**
 * testcaseID a0B20000009eaw0EAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults Error occurs that assignee is a mandatory value
 */

 /**
 * testcaseID a0B20000009eaw1EAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults Error occurs that status is a mandatory value
 */

 /**
 * testcaseID a0B20000009eaw2EAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults Error occurs that type is a mandatory value
 */

 /**
 * testcaseID a0B20000009eaw5EAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults User is able to create a test execution with mandatory fields (assignee, status and type) and date of last execution
 */

 /**
 * testcaseID a0B20000009eaw6EAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults User is able to create a test execution with mandatory fields (assignee, status and type) and number of executions
 */

 /**
 * testcaseID a0B20000009eaw7EAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults User is able to create a test execution with mandatory fields (assignee, status and type) and time of completion
 */

 /**
 * testcaseID a0B20000009eaw8EAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults User is able to create a test execution with mandatory fields (assignee, status and type) and Build # of last execution
 */
 
 /**
 * testcaseID a0B20000009eaw9EAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults User is able to create a test execution with mandatory fields (assignee, status and type) and bugs
 */
 
 /**
 * testcaseID a0B20000009eawBEAQ
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults User is taken back to the user story page and test executions are added in the test execution tree under Actions tab.
 */
  
 /**
 * testcaseID a0B20000009eawEEAQ
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults Error occurs that the assignee is inactive
 */
  
 /**
 * testcaseID a0B20000009ebDtEAI
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Execution Create page
 * @expectedResults 
 */
    private static testMethod void testAddTEtoUS(){
        //set up objects needed
        ADM_Work__c newUs = QA_TreeTestUtils.createUS('AddTEtoUS');
        QA_Hierarchy__c baseHier = QA_TreeTestUtils.createBaseHiers('AddTEtoUS');
        List<QA_Test_Case__c> newTCs = QA_TreeTestUtils.createTCs('AddTEtoUS', 4, baseHier.Name + '.Branch 1');

        //initiliaze
        System.currentPageReference().getParameters().put('usid', newUs.Id);
        QA_TreeLibrary treeLib = new QA_TreeLibrary();
        QA_AddTEtoUSExtension newAddTEtoUS = new QA_AddTEtoUSExtension(treeLib);
        //should be at step 1
        System.assert(newAddTEtoUS.currentStep == 1);

        //try to move to step 2 without selecting any TCs
        newAddTEtoUS.toStep2();
        System.assert(newAddTEtoUS.treeLib.confirmationMessage.contains('Please select at least one Test Case.')); //should have error message
        //should still be at step 1
        System.assert(newAddTEtoUS.currentStep == 1);

        //select some TCs
        String allIds = null;
        String allPaths = null;
        for(QA_Test_Case__c curTC : newTCs){
            if(allIds == null){
                allIds = curTC.Id;
                allPaths = baseHier.Name + '.Branch 1';
            }else{
                allIds += ',' + curTC.Id;
                allPaths += '|~|' + baseHier.Name + '.Branch 1';
            }
        }
        newAddTEtoUS.treeLib.tree.selectedId = allIds;
        newAddTEtoUS.treeLib.tree.selectedPath = allPaths;
        newAddTEtoUS.treeLib.selectElems();

        //try to move to step 2
        newAddTEtoUS.toStep2();
        System.assertEquals(newAddTEtoUS.selectedTestCases.size(), 4); //should have 4 TCs selected
        //should be step 2 now
        System.assert(newAddTEtoUS.currentStep == 2);

        //fill in some details
        newAddTEtoUS.baseTE.Type__c = 'Manual';
        newAddTEtoUS.baseTE.Assignee__c = UserInfo.getUserId();

        //fill in status to Passed, should fail since date is required
        newAddTEtoUS.baseTE.Status__c = 'Passed';
        newAddTEtoUS.createTEs();
        System.assert(newAddTEtoUS.currentStep == 2); // should still be step 2
        System.assertEquals(true, newAddTEtoUS.getDateRequired());

        //test bug number validation, none of the following bug id strings should work
        newAddTEtoUS.baseTE.Status__c = 'Planned'; //set to planned so date not required
        newAddTEtoUS.baseTE.Bugs__c = '999';
        newAddTEtoUS.createTEs();
        System.assert(newAddTEtoUS.currentStep == 2); //should still be step 2
        System.assert(newAddTEtoUS.getBugValidationError() != '');
        newAddTEtoUS.baseTE.Bugs__c = '10000001';
        newAddTEtoUS.createTEs();
        System.assert(newAddTEtoUS.currentStep == 2); //should still be step 2
        System.assert(newAddTEtoUS.getBugValidationError() != '');
        newAddTEtoUS.baseTE.Bugs__c = 'W-10';
        newAddTEtoUS.createTEs();
        System.assert(newAddTEtoUS.currentStep == 2); //should still be step 2
        System.assert(newAddTEtoUS.getBugValidationError() != '');

        //try to create TEs successfully
        newAddTEtoUS.baseTE.Status__c = null; //don't set the status, should default to Planned
        newAddTEtoUS.baseTE.Bugs__c = '9999, W-000001';
        newAddTEtoUS.createTEs();
        System.assert(newAddTEtoUS.getBugValidationError() == ''); //bugs validated
        System.assertEquals(3, newAddTEtoUS.currentStep); //should still step 3

        //all the TEs should be created
        List<String> teIds = new List<String>();
        for(QA_AddTEtoUSExtension.TEResult curTEResult : newAddTEtoUS.createdTEResults){
            System.assert(curTEResult.id != '' && curTEResult.id != null); //should have ids if created
            teIds.add(curTEResult.id);
        }

        System.assertEquals(4, [SELECT count() FROM QA_Test_Execution__c WHERE Id IN :teIds]); //should return all 4 created TEs
    }

/**
 * testcaseID a0B20000009ebFAEAY
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Finish Test Execution page
 * @expectedResults Creation Result (green check), Test case, Test Execution Status, Test Execution Type and Test Execution ID are shown in this page
 */

 /**
 * testcaseID a0B20000009ds7nEAA
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Test Case Detail page
 * @expectedResults The Add Test Executions to a User Story page appears and shows the link to the selected User Story. Also, a tree of all test cases section appears with Filter By and Search tabs
 */

 
    
     /**
 * testcaseID a0B20000009ebDtEAI
 * @userStory a07B0000000DfNF
 * @hierarchy GUS.QaforceToGUS.Add Test Executions to a User Story.Work Detail page
 * @expectedResults Error occurs that the date of last execution cannot be in the future
 */
    public static testmethod void verifyCatchingError() {
        //set up objects needed
        ADM_Work__c newUs = QA_TreeTestUtils.createUS('AddTEtoUS');
        QA_Hierarchy__c baseHier = QA_TreeTestUtils.createBaseHiers('AddTEtoUS');
        List<QA_Test_Case__c> newTCs = QA_TreeTestUtils.createTCs('AddTEtoUS', 4, baseHier.Name + '.Branch 1');

        //initiliaze
        System.currentPageReference().getParameters().put('usid', newUs.Id);
        QA_TreeLibrary treeLib = new QA_TreeLibrary();
        QA_AddTEtoUSExtension newAddTEtoUS = new QA_AddTEtoUSExtension(treeLib);
        //should be at step 1
        System.assert(newAddTEtoUS.currentStep == 1);

        //try to move to step 2 without selecting any TCs
        newAddTEtoUS.toStep2();
        System.assert(newAddTEtoUS.treeLib.confirmationMessage.contains('Please select at least one Test Case.')); //should have error message
        //should still be at step 1
        System.assert(newAddTEtoUS.currentStep == 1);

        //select some TCs
        String allIds = null;
        String allPaths = null;
        for(QA_Test_Case__c curTC : newTCs){
            if(allIds == null){
                allIds = curTC.Id;
                allPaths = baseHier.Name + '.Branch 1';
            }else{
                allIds += ',' + curTC.Id;
                allPaths += '|~|' + baseHier.Name + '.Branch 1';
            }
        }
        newAddTEtoUS.treeLib.tree.selectedId = allIds;
        newAddTEtoUS.treeLib.tree.selectedPath = allPaths;
        newAddTEtoUS.treeLib.selectElems();

        //try to move to step 2
        newAddTEtoUS.toStep2();
        System.assertEquals(newAddTEtoUS.selectedTestCases.size(), 4); //should have 4 TCs selected
        //should be step 2 now
        System.assert(newAddTEtoUS.currentStep == 2);

        //fill in some details
        newAddTEtoUS.baseTE.Type__c = 'Manual';
        newAddTEtoUS.baseTE.Assignee__c = UserInfo.getUserId();
        newAddTEtoUS.baseTE.Status__c = 'Planned';
        newAddTEtoUS.baseTE.Date_of_Last_Execution__c = System.now().addDays(100);
        String error = '';
        
        newAddTEtoUS.createTEs();
        
        for(Apexpages.Message message : Apexpages.getMessages()) {
            error += message.getSummary();    
        }
        
        System.assertEquals(true, error.contains('Date of Last Execution should be less than the current date'));
        System.assert(newAddTEtoUS.currentStep == 2);
    }
}