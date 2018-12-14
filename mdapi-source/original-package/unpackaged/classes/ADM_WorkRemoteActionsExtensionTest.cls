@isTest
private class ADM_WorkRemoteActionsExtensionTest {
	static testMethod void getTeamCapexEligibilityDefaultDisabledTest(){		
        System.assertEquals(false, new ADM_WorkRemoteActionsExtension().getTeamCapexEligibility());
    }
    
    static testMethod void getAdditionalFieldsForUserStoryProdTagNullTest(){		
	    ADM_Work__c user_story = ADM_Work.setupTestWork('User Story');
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension();
        ext.myProdTag = null;
        System.assertEquals(new List<ADM_Additional_Field__c>(), ext.getAdditionalFieldsForUserStory());
    }
    
    static testMethod void getAdditionalFieldsForUserStoryTest(){
        List<Schema.FieldSetMember> listOfExpectedAdditionalFields =  new List<Schema.FieldSetMember>();
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        listOfExpectedAdditionalFields = Schema.SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        Schema.FieldSetMember f = listOfExpectedAdditionalFields.get(0);
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        af.Field_API_Name__c = f.getFieldPath();
        af.Type__c = String.valueOf(f.Type);
        af.Name =  f.Label;
        af.Product_Tag__c = proTag.id;
        af.Bug_Setting__c = 'Hidden';
        af.User_Story_Setting__c = 'Required' ;
        af.Investigation_Setting__c = 'Hidden';
        insert(af);

        ADM_Work__c work = ADM_Work.setupTestWork('User Story');
        work.Product_Tag__c = proTag.id;
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension(stdController);
        
        List<ADM_Additional_Field__c> afs = new List<ADM_Additional_Field__c>();
        afs.add(af);
        System.assertEquals(afs.get(0).Id, ext.getAdditionalFieldsForUserStory().get(0).Id);
    }
    
    static testMethod void getAdditionalFieldsForBugProdTagNullTest(){		
	    ADM_Work__c user_story = ADM_Work.setupTestWork('Bug');
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension();
        ext.myProdTag = null;
        System.assertEquals(new List<ADM_Additional_Field__c>(), ext.getAdditionalFieldsForBug());
    }
        
    static testMethod void getAdditionalFieldsForBugTest(){
        List<Schema.FieldSetMember> listOfExpectedAdditionalFields =  new List<Schema.FieldSetMember>();
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        listOfExpectedAdditionalFields = Schema.SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        Schema.FieldSetMember f = listOfExpectedAdditionalFields.get(0);
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        af.Field_API_Name__c = f.getFieldPath();
        af.Type__c = String.valueOf(f.Type);
        af.Name =  f.Label;
        af.Product_Tag__c = proTag.id;
        af.Bug_Setting__c = 'Visible';
        af.User_Story_Setting__c = 'Hidden' ;
        af.Investigation_Setting__c = 'Hidden';
        insert(af);

        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Product_Tag__c = proTag.id;
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension(stdController);
        
        List<ADM_Additional_Field__c> afs = new List<ADM_Additional_Field__c>();
        afs.add(af);
        System.assertEquals(afs.get(0).Id, ext.getAdditionalFieldsForBug().get(0).Id);
    }
    
    static testMethod void getAdditionalFieldsForInvestigationProdTagNullTest(){		
	    ADM_Work__c user_story = ADM_Work.setupTestWork('Investigation');
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension();
        ext.myProdTag = null;
        System.assertEquals(new List<ADM_Additional_Field__c>(), ext.getAdditionalFieldsForInvestigation());
    }
        
    static testMethod void getAdditionalFieldsForInvestigationTest(){
        List<Schema.FieldSetMember> listOfExpectedAdditionalFields =  new List<Schema.FieldSetMember>();
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        listOfExpectedAdditionalFields = Schema.SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        Schema.FieldSetMember f = listOfExpectedAdditionalFields.get(0);
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        af.Field_API_Name__c = f.getFieldPath();
        af.Type__c = String.valueOf(f.Type);
        af.Name =  f.Label;
        af.Product_Tag__c = proTag.id;
        af.Bug_Setting__c = 'Hidden';
        af.User_Story_Setting__c = 'Hidden' ;
        af.Investigation_Setting__c = 'Visible';
        insert(af);

        ADM_Work__c work = ADM_Work.setupTestWork('Investigation');
        work.Product_Tag__c = proTag.id;
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension(stdController);
        
        List<ADM_Additional_Field__c> afs = new List<ADM_Additional_Field__c>();
        afs.add(af);
        System.assertEquals(afs.get(0).Id, ext.getAdditionalFieldsForInvestigation().get(0).Id);
    }
    
    static testMethod void getMyAdditionalFieldsForUserStoryTest(){
        List<Schema.FieldSetMember> listOfExpectedAdditionalFields =  new List<Schema.FieldSetMember>();
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        listOfExpectedAdditionalFields = Schema.SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        Schema.FieldSetMember f = listOfExpectedAdditionalFields.get(0);
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        af.Field_API_Name__c = f.getFieldPath();
        af.Type__c = String.valueOf(f.Type);
        af.Name =  f.Label;
        af.Product_Tag__c = proTag.id;
        af.Bug_Setting__c = 'Hidden';
        af.User_Story_Setting__c = 'Visible';
        af.Investigation_Setting__c = 'Hidden';
        insert(af);

        ADM_Work__c work = ADM_Work.setupTestWork('User Story');
        work.Product_Tag__c = proTag.id;
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension(stdController);
        PageReference afPageReference = ext.getMyAdditionalFieldsForUserStory();
        
        List<ADM_Additional_Field__c> afs = new List<ADM_Additional_Field__c>();
        afs.add(af);

        System.assertEquals(null, afPageReference);
        System.assertEquals(ext.additionalFieldsForUserStory.get(0).Id, afs.get(0).Id);
    }
    
    static testMethod void getMyAdditionalFieldsForBugTest(){
        List<Schema.FieldSetMember> listOfExpectedAdditionalFields =  new List<Schema.FieldSetMember>();
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        listOfExpectedAdditionalFields = Schema.SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        Schema.FieldSetMember f = listOfExpectedAdditionalFields.get(0);
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        af.Field_API_Name__c = f.getFieldPath();
        af.Type__c = String.valueOf(f.Type);
        af.Name =  f.Label;
        af.Product_Tag__c = proTag.id;
        af.Bug_Setting__c = 'Visible';
        af.User_Story_Setting__c = 'Hidden';
        af.Investigation_Setting__c = 'Hidden';
        insert(af);

        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Product_Tag__c = proTag.id;
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension(stdController);
        PageReference afPageReference = ext.getMyAdditionalFieldsForBug();
        
        List<ADM_Additional_Field__c> afs = new List<ADM_Additional_Field__c>();
        afs.add(af);

        System.assertEquals(null, afPageReference);
        System.assertEquals(ext.additionalFieldsForBug.get(0).Id, afs.get(0).Id);
    }
    
    static testMethod void getMyAdditionalFieldsForInvestigationTest(){
        List<Schema.FieldSetMember> listOfExpectedAdditionalFields =  new List<Schema.FieldSetMember>();
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        listOfExpectedAdditionalFields = Schema.SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        Schema.FieldSetMember f = listOfExpectedAdditionalFields.get(0);
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        af.Field_API_Name__c = f.getFieldPath();
        af.Type__c = String.valueOf(f.Type);
        af.Name =  f.Label;
        af.Product_Tag__c = proTag.id;
        af.Bug_Setting__c = 'Hidden';
        af.User_Story_Setting__c = 'Hidden';
        af.Investigation_Setting__c = 'Visible';
        insert(af);

        ADM_Work__c work = ADM_Work.setupTestWork('Investigation');
        work.Product_Tag__c = proTag.id;
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkRemoteActionsExtension ext = new ADM_WorkRemoteActionsExtension(stdController);
        PageReference afPageReference = ext.getMyAdditionalFieldsForInvestigation();
        
        List<ADM_Additional_Field__c> afs = new List<ADM_Additional_Field__c>();
        afs.add(af);

        System.assertEquals(null, afPageReference);
        System.assertEquals(ext.additionalFieldsForInvestigation.get(0).Id, afs.get(0).Id);
    }
    
    static testMethod void getMyAdditionalFieldsForAllReturnsNullTest() {
    	PageReference pgRef = new ADM_WorkRemoteActionsExtension().getMyAdditionalFieldsForAll();
        System.assertEquals(null, pgRef);
    }
    
    static testMethod void getPriorityMetaDataTest(){
        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_WorkAssignment.PriorityMetaData metaData =  ADM_WorkRemoteActionsExtension.getPriorityMetaData(bug.id);

        System.assertNotEquals(null, metaData, 'Expected not null value for WorkEditorDialogMetaData');
        System.assertEquals(metaData.workSObject.Id, bug.Id, 'Expected to get same work id object from metadata');
        System.assertNotEquals(null,metaData.impacts,' Expected to return impacts');
        System.assertNotEquals(null,metaData.priorityMappings,' Expected to return priorityMappings');
    }
}