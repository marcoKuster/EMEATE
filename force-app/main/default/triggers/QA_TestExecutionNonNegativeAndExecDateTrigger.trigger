trigger QA_TestExecutionNonNegativeAndExecDateTrigger on QA_Test_Execution__c (before insert, before update) {

    //This trigger fires when you try to update or insert an test execution record. When the testExec status is marked
    //as Passed or Failed then the Number_of_Execution field should not be <1 and Date_of_Last_Execution should not be
    //null.
    for (Integer i = 0; i < Trigger.new.size(); i++)
    {
        QA_Test_Execution__c testExecObj = Trigger.new[i];
        //check the status of the testExec record
        if(testExecObj.Status__c == 'Passed' || testExecObj.Status__c == 'Failed'){

            if (Trigger.isUpdate){
                QA_Test_Execution__c testExecObj_Old = Trigger.old[i];
                // If the status of the test execution was updated to either 'Passed' or 'Failed' and the user did not update the
                // number of executions, then automatically increment the number of executions
                if(testExecObj.Status__c != testExecObj_Old.Status__c) {
                    if (testExecObj.Number_of_Executions__c == testExecObj_Old.Number_of_Executions__c) {
                    	if(testExecObj_Old.Number_of_Executions__c == null) {
                    		testExecObj.Number_of_Executions__c = 1;
                    	} else {
                    	   testExecObj.Number_of_Executions__c = testExecObj.Number_of_Executions__c + 1;
                    	}
                    }
                    if (testExecObj.Date_of_Last_Execution__c == testExecObj_Old.Date_of_Last_Execution__c) {
                        testExecObj.Date_of_Last_Execution__c = datetime.now();
                    }
                }
            }
            else{
                //when the testExec record is marked as Passed or Failed the Number_of_Execution field should be updated such that the
                //value in the field should be atleast 1
                if(testExecObj.Number_of_Executions__c == 0) {
                    testExecObj.Number_of_Executions__c = 1;
                }
            }
            //check for the Date_of_Last_Execution field and update it with the current date and time if the field is null.
            if(testExecObj.Date_of_Last_Execution__c == null) {
                testExecObj.Date_of_Last_Execution__c = datetime.now();
            }
        }
    }
}