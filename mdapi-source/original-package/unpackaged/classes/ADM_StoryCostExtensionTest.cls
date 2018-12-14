@isTest
private class ADM_StoryCostExtensionTest {
    static ADM_Work__c work = ADM_Work.createTestWork();
    static List<ADM_Work__c> works = new List<ADM_Work__c>{work};
    static ADM_Scrum_Team__c scrumteam = ADM_ScrumTeam.createTestScrumTeam('ADM_StoryCostExtensionTest');
    private static String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();

    static testMethod void testWithURL() {
        System.currentPageReference().getParameters().put('workIds', work.Id);
        System.currentPageReference().getParameters().put('scrumteamId', scrumteam.Id);
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(works);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        
        System.assert(ext != null);
    }
    
    static testMethod void testWithoutURL() {
        System.currentPageReference().getParameters().put('scrumteamId', scrumteam.Id);
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(works);
        setController.setSelected(works);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        ext.changeList = work.Id;
        System.assert(ext.storiesToCost != null);
        System.assert(ext != null);
    }
    
    static testMethod void testWithoutWork() {
        List<ADM_Work__c> noWork = new List<ADM_Work__c>();
        System.currentPageReference().getParameters().put('scrumteamId', scrumteam.Id);
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(noWork);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        
        System.assert(Apexpages.hasMessages());
    }
    
    static testMethod void testWithoutWorkCancel() {
        List<ADM_Work__c> noWork = new List<ADM_Work__c>();
        
        System.currentPageReference().getParameters().put('scrumteamId', scrumteam.Id);
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(noWork);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        
        Apexpages.Pagereference pr = ext.cancel();
        
        System.assert(pr.getParameters().get('scrumteamId') == scrumteam.Id,'Scrum team Id did not match! pr->' + pr + ' scrumteamId->' + scrumteam.Id);
    }
    
    static testMethod void testWithoutWorkEmpty() {
        List<ADM_Work__c> noWork = new List<ADM_Work__c>();
        
        System.currentPageReference().getParameters().put('scrumteamId', scrumteam.Id);
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(noWork);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        
        System.assert(ext.empty() == null,'Thought that the empty should have returned null! ->' + ext.empty());
    }
    
    static testMethod void testWithoutURLSaveNoErrors() {
        System.currentPageReference().getParameters().put('scrumteamId', scrumteam.Id);
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(works);
        setController.setSelected(works);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        ext.changeList = work.Id + ':1';
        
        Pagereference pr = ext.save();
        
        ADM_Work__c retrieved = [select Story_Points__c from ADM_Work__c where Id = :work.Id];
        
        System.assert(pr != null);
        System.assert(retrieved.Story_Points__c == 1,'Story points did not match 1!->' + retrieved.Story_Points__c);
        System.assert(pr.getParameters().get('scrumteamId') == scrumteam.Id,'Scrum team Id did not match! pr->' + pr + ' scrumteamId->' + scrumteam.Id);
        
        
        String qualifiedPageName = (nameSpacePrefix +'ADM_WorkPrioritizer').toLowerCase(); 
        System.assert(pr.getUrl().toLowerCase().contains('/apex/'+ qualifiedPageName),'page reference URL did not contain /apex/'+qualifiedPageName+'->' + pr.getUrl());
    }
    
    static testMethod void testWithoutURLSaveNoErrorsNoScrumteamOverURL() {
        ADM_Product_Tag__c tag = [select id, Team__c from ADM_Product_Tag__c where id=:work.Product_Tag__c];
        tag.Team__c = scrumteam.Id;
        update tag;
        work.Product_Tag__c = tag.id;
        update work;
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(works);
        setController.setSelected(works);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        ext.changeList = work.Id + ':1';
        
        Pagereference pr = ext.save();
        
        ADM_Work__c retrieved = [select Story_Points__c from ADM_Work__c where Id = :work.Id];
        
        System.assert(pr != null);
        System.assert(retrieved.Story_Points__c == 1,'Story points did not match 1!->' + retrieved.Story_Points__c);
        System.assert(pr.getParameters().get('scrumteamId') == scrumteam.Id,'Scrum team Id did not match! pr->' + pr + ' scrumteamId->' + scrumteam.Id);
       
        String qualifiedPageName = (nameSpacePrefix + 'ADM_WorkPrioritizer').toLowerCase();   
        System.assert(pr.getUrl().toLowerCase().contains('/apex/'+qualifiedPageName),'page reference URL did not contain /apex/'+qualifiedPageName+'->' + pr.getUrl());
    }
    
    static testMethod void testWithoutURLSaveNoErrorsNoScrumteamOverURLInvalidPts() {
        work.Scrum_Team__c = scrumteam.Id;
        update work;
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(works);
        setController.setSelected(works);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        ext.changeList = work.Id + ':xxxx';
        
        Pagereference pr = ext.save();
        
        ADM_Work__c retrieved = [select Story_Points__c from ADM_Work__c where Id = :work.Id];
        
        System.assert(pr != null);
        List<Apexpages.Message> messages = Apexpages.getMessages();
        Apexpages.Message message = messages.get(0);
        
        System.assert(message.getDetail().contains('There is something wrong with the story point values you entered. Please correct and try again'));
    }
    
    static testMethod void testWithoutURLQuickSaveNoErrors() {
        System.currentPageReference().getParameters().put('scrumteamId', scrumteam.Id);
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(works);
        setController.setSelected(works);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        ext.changeList = work.Id + ':1';
        
        Pagereference pr = ext.quickSave();
        System.assert(pr == null);
        
        ADM_Work__c retrieved = [select Story_Points__c from ADM_Work__c where Id = :work.Id];
        System.assert(retrieved.Story_Points__c == 1,'Story points did not match 1!->' + retrieved.Story_Points__c);
    }
    
    static testMethod void testWithoutURLQuickSaveErrors() {
        System.currentPageReference().getParameters().put('scrumteamId', scrumteam.Id);
        Apexpages.Standardsetcontroller setController = new Apexpages.Standardsetcontroller(works);
        setController.setSelected(works);
        ADM_StoryCostExtension ext = new ADM_StoryCostExtension(setController);
        ext.changeList = work.Id + ':1';
        ext.quickSave();
    }
}