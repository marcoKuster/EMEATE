public with sharing class QA_TPUserStoryListExtension {

    public List<ADM_Work__c> works { get; set; }
    public Id testPlanId { get; set; }

    public QA_TPUserStoryListExtension (ApexPages.StandardController stdController) {
        testPlanId = stdController.getId();
        works = ADM_Work.getAllBy('Test_Plan__c', new List<String> {testPlanId}, 0, 100, 'Id', 'ASC');
    }

    public PageReference workWizard() {
        PageReference pageRef = Page.QA_addUStoTP;
        pageRef.getParameters().put('id', testPlanId);
        pageRef.getParameters().put('retURL', '/apex/QA_TPDetails?id='+testplanId);
        return pageRef;
    }
}