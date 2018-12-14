trigger QA_GenerateQuestionsAndAnswers on QA_Test_Plan__c (after insert) {
    //This trigger will only let 100 questions per test plan before it hits a governor limt. 
    //Need to fix this when we start getting more questions added.
    List<QA_Test_Plan__c> testPlans = Trigger.new;
    List<QA_Question__c> questions = [SELECT ID FROM QA_Question__c q WHERE q.Obsolete__c = FALSE];
    QA_Answer__c answer;
    List<QA_Answer__c> answers= new List<QA_Answer__c>();
    if (!questions.isEmpty()) {
        for(QA_Test_Plan__c i : Trigger.new){
            for (QA_Question__c question : questions) {
                answer = new QA_Answer__c();
                answer.Question__c = question.Id;
                answer.Test_Plan__c = i.Id;
                answers.add(answer);
            }
        }
        insert answers;
    }
}