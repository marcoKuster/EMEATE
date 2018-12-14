trigger QA_TestExecutionPopulateTeam on QA_Test_Execution__c (after insert) {

    QA_Test_Execution__c te = Trigger.new[0];
    QA_Test_Case__c tc = [Select Id, Team__c from QA_Test_Case__c where Id =: te.Test_Case__c ];
    if (tc.Team__c == null) {
        ADM_Work__c us = [Select Id, Scrum_Team__c from ADM_Work__c where Id =: te.User_Story__c ]; 
        tc.Team__c = us.Scrum_Team__c;
        update(tc);
    }
}