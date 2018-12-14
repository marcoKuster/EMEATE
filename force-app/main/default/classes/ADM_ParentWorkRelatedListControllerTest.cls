@IsTest
public with sharing class ADM_ParentWorkRelatedListControllerTest {
	
    /*
      @testcaseID a0B20000005wJq0EAE
      @hierarchy GUS.BugforceToGUS.DefectPrioritizationProcess.Work Page.New Page
      @userstory a0A20000001uzqH
      @expectedResults: The user should be taken to the create new work page with the new fields
    */
    static testMethod void testRedirectToNewParentWorkRecord() {
        ADM_Work__c work = ADM_Work.createTestWork();
        
        ADM_ParentWorkRelatedListController controller = new ADM_ParentWorkRelatedListController();
        controller.setWorkId(work.Id);
        
        PageReference pageRef = controller.redirectToNewParentWorkRecord();
        
        System.assert(pageRef != null);
        System.assert(pageRef.getParameters() != null);
        
        //assert priority no longer copied
        System.assert(pageRef.getParameters().get('Priority__c') == null);
    }
    
    
    /*
      @testcaseID a0B20000001pXStEAM
      @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Detail page
      @userstory a0A20000001uzqH
      @expectedResults: The Work ID gets saved as a parent work record
    */
    static testMethod void testGetRelatedParentWorkList() {
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        List<ADM_Parent_Work__c> plist = new List<ADM_Parent_Work__c>();
        
        for(Integer i = 1; i < works.size(); i++) {
            ADM_Parent_Work__c rel = new ADM_Parent_Work__c();
            rel.Parent_Work__c = works.get(i).id;
            
            //make the 1st record child of the rest
            rel.Child_Work__c = works.get(0).id;
            
            plist.add(rel);
        }
        
        insert plist;
        
        ADM_ParentWorkRelatedListController controller = new ADM_ParentWorkRelatedListController();
        controller.setWorkId(works.get(0).id);
        controller.enableParentWorkLimit();
        
        List<ADM_Parent_Work__c> parents = controller.getRelatedParentWorkList();
        System.assertEquals(5, parents.size());
        
        //rerun with the limit diasabled
        controller.disableParentWorkLimit();
        controller.clearParentsCache();
        
        List<ADM_Parent_Work__c> noLimitParents = controller.getRelatedParentWorkList();
        System.assertEquals([select count() from ADM_Parent_Work__c where Child_Work__c = : controller.getWorkID()], noLimitParents.size());

    }
    
    static testMethod void testCreateNewParentWork() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        insert works;
        works = [select Id, Name from ADM_Work__c where Id in :works];
        
        ADM_Work__c work1 = works.get(0);
        ADM_Work__c work2 = works.get(1);
        
        Test.startTest();
        ADM_ParentWorkRelatedListController controller = new ADM_ParentWorkRelatedListController();
        controller.setWorkId(work1.Id);
        controller.newParentWorkName = work2.Name;
        controller.createNewParentWork();
        Test.stopTest();
        
        System.assert(controller.getErrorMessages().isEmpty(), 'Unexpected errors occurred during createNewParentWork: ' + (controller.getErrorMessages().isEmpty()? '' : controller.getErrorMessages().get(0)));
        List<ADM_Parent_Work__c> relationships = [select Id, Duplicate__c from ADM_Parent_Work__c where Parent_Work__c = :work2.Id and Child_Work__c = :work1.Id];
        System.assertEquals(1, relationships.size(), 'Expected a new parent relationship to be created');
        System.assertEquals(false, relationships.get(0).Duplicate__c, 'Expected Duplicate to be false since the relationship type should not be original');
    }
    
    static testMethod void testCreateNewParentWorkWhenDuplicate() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        insert works;
        works = [select Id, Name from ADM_Work__c where Id in :works];
        
        ADM_Work__c work1 = works.get(0);
        ADM_Work__c work2 = works.get(1);
        
        Test.startTest();
        ADM_ParentWorkRelatedListController controller = new ADM_ParentWorkRelatedListController();
        controller.setWorkId(work1.Id);
        controller.newParentWorkName = work2.Name;
        controller.relationshipType = 'original'; //set the relationship type
        controller.createNewParentWork();
        Test.stopTest();
        
        System.assert(controller.getErrorMessages().isEmpty(), 'Unexpected errors occurred during createNewParentWork: ' + (controller.getErrorMessages().isEmpty()? '' : controller.getErrorMessages().get(0)));
        
        List<ADM_Parent_Work__c> relationships = [select Id, Duplicate__c, Child_Work__r.Status__c from ADM_Parent_Work__c where Parent_Work__c = :work2.Id and Child_Work__c = :work1.Id];
        System.assertEquals(1, relationships.size(), 'Expected a new parent relationship to be created');
        System.assertEquals('Duplicate', relationships.get(0).Child_Work__r.Status__c, 'Expected the status of the original record to be set to Duplicate');
        System.assertEquals(true, relationships.get(0).Duplicate__c, 'Expected the duplicate checkbox to be checked when creating a duplicate');
    }
    
    static testMethod void testDeleteParentWork() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        insert works;
        works = [select Id, Name from ADM_Work__c where Id in :works];
        
        ADM_Work__c work1 = works.get(0);
        ADM_Work__c work2 = works.get(1);
        
        ADM_Parent_Work__c relationship = new ADM_Parent_Work__c();
        relationship.Parent_Work__c = work2.Id;
        relationship.Child_Work__c = work1.Id;
        insert relationship;
        
        Test.startTest();
        ADM_ParentWorkRelatedListController controller = new ADM_ParentWorkRelatedListController();
        controller.setWorkId(work1.Id);
        controller.setIDOfParentWorkBeingModified(relationship.Id);
        controller.deleteParentWork();
        Test.stopTest();
        
        System.assert(controller.getErrorMessages().isEmpty(), 'Unexpected errors occurred during createDeleteParentWork: ' + (controller.getErrorMessages().isEmpty()? '' : controller.getErrorMessages().get(0)));
        System.assertEquals(0, [select count() from ADM_Parent_Work__c where Parent_Work__c = :work2.Id and Child_Work__c = :work1.Id], 'Expected the parent relationship to be deleted');
    }
    
    static testMethod void testRelatedParentWorkListSize() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_ParentWorkRelatedListController controller = new ADM_ParentWorkRelatedListController();
        controller.setWorkId(work.Id);
        
        System.assert(controller.getRelatedParentWorkListSize() != null);
    }
}