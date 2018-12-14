@isTest
private class ADM_WorkDirectorExtensionTest {

    /*
    testcaseID a1DB00000002sI8
    userstory a07B0000000VcKdIAK
    Expected Results:  The correct version of the detail page is shown when viewing a Bug with the classic interface ui choice
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    /**
    * Test the correct version of the detail page is shown when viewing a Bug with the classic interface ui choice
    */
    static testMethod void testViewingClassicBugDetailInterface() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        //create user and make sure they have the classic user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_CLASSIC;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectDetailPage();
            String qualifiedPageName = '';
            if(ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred()){
                qualifiedPageName = getQualifiedApexPageName('adm_bugdetailsds');
            }
            else{
                qualifiedPageName = getQualifiedApexPageName('adm_workdetail');
            }
            

            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }
    /*
    testcaseID a1DB00000002sID
    userstory a07B0000000VcKdIAK
    Expected Results: The correct version of the detail page is shown when viewing a User Story with the classic interface ui choice
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    
    /**
    * Test the correct version of the detail page is shown when viewing a User Story with the classic interface ui choice
    */
    static testMethod void testViewingClassicUserStoryDetailInterface() {
        ADM_Work__c work = ADM_Work.createTestWork('User Story');
        //create user and make sure they have the classic user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_CLASSIC;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectDetailPage();
            String qualifiedPageName = '';
            if(ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred()){
                qualifiedPageName = getQualifiedApexPageName('adm_userstorydetailsds');
            }
            else{
                qualifiedPageName = getQualifiedApexPageName('adm_workdetail');
            }
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }
    
        /*
    testcaseID a1DB00000002sII
    userstory a07B0000000VcKdIAK
    Expected Results: the correct version of the detail page is shown when viewing a Bug with next gen setting 
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
   
    
   /**
    * Test the correct version of the detail page is shown when viewing a Bug with next gen setting
    */
   
    static testMethod void testViewingNextGenBugDetailInterface() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        //create user and make sure they have the next generation user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_NEXT_GENERATION;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectDetailPage();
            String qualifiedPageName = '';
            if(ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred()){
                qualifiedPageName = getQualifiedApexPageName('adm_bugdetailsds');
            }
            else{
                qualifiedPageName = getQualifiedApexPageName('adm_bugdetail');
            }
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }
    /*
    testcaseID a1DB00000002sIN
    userstory a07B0000000VcKdIAK
    Expected Results: the correct version of the create/edit page is shown when viewing a Bug with next gen setting 
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    
    /**
    * Test the correct version of the create/edit page is shown when viewing a Bug with next gen setting
    */
   
    static testMethod void testViewingNextGenBugCreateEditInterface() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        //create user and make sure they have the next generation user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_NEXT_GENERATION;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectCreateOrEditPage();
            String qualifiedPageName = '';
            if(ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred()){
                qualifiedPageName = getQualifiedApexPageName('adm_bugeditsds');
            }
            else{
                qualifiedPageName = getQualifiedApexPageName('adm_bugedit');
            }
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }
    /*
    testcaseID a1DB00000002sIS
    userstory a07B0000000VcKdIAK
    Expected Results: the correct version of the detail page is shown when viewing a User Story with next gen setting 
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    
    /**
    * Test the correct version of the detail page is shown when viewing a User Story with next gen setting
    */
    static testMethod void testViewingNextGenUserStoryDetailInterface() {
        ADM_Work__c work = ADM_Work.createTestWork('User Story');
        //create user and make sure they have the next generation user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_NEXT_GENERATION;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectCreateOrEditPage();
            String qualifiedPageName = '';
            if(ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred()){
                qualifiedPageName = getQualifiedApexPageName('adm_userstoryeditsds');
            }
            else{
                qualifiedPageName = getQualifiedApexPageName('adm_userstoryedit');
            }
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }

    /*
    testcaseID a1DB00000002sIX
    userstory a07B0000000VcKdIAK
    Expected Results: the correct version of the create/edit page is shown when viewing a User Story with next gen setting 
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    
    /**
    * Test the correct version of the create/edit page is shown when viewing a User Story with next gen setting
    */
   
    static testMethod void testViewingNextGenUserStoryCreateEditInterface() {
        ADM_Work__c work = ADM_Work.createTestWork('User Story');
        //create user and make sure they have the next generation user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_NEXT_GENERATION;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectCreateOrEditPage();
            String qualifiedPageName = '';
            if(ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred()){
                qualifiedPageName = getQualifiedApexPageName('adm_userstoryeditsds');
            }
            else{
                qualifiedPageName = getQualifiedApexPageName('adm_userstoryedit');
            }
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }

    /*
    testcaseID a1DB00000002sIc
    userstory a07B0000000VcKdIAK
    Expected Results: the correct version of the detail page is shown when viewing a ToDo.  Only Bugs and Stories have a next gen page but we need to make sure ToDo's are still visible regardless of what     value is chosen for Work User Interface.
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    
     /**
    * Test the correct version of the detail page is shown when viewing a ToDo.  Only Bugs and Stories have a next gen page but we need to make 
    * sure ToDo's are still visible regardless of what value is chosen for Work User Interface.
    */
    static testMethod void testViewingToDoDetail() {
        ADM_Work__c work = ADM_Work.createTestWork('ToDo');
        //create user and make sure they have the classic user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_CLASSIC;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectDetailPage();
            String qualifiedPageName = getQualifiedApexPageName('adm_workdetail');
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }

    /*
    testcaseID a1DB00000002sIh
    userstory a07B0000000VcKdIAK
    Expected Results: the correct version of the create/edit page is shown when viewing a ToDo.  Only Bugs and Stories have a next gen page but we need to make sure ToDo's are still visible regardless of what        value is chosen for Work User Interface.
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    
    /**
    * Test the correct version of the create/edit page is shown when viewing a ToDo.  Only Bugs and Stories have a next gen page but we need to make 
    * sure ToDo's are still visible regardless of what value is chosen for Work User Interface.
    */
    static testMethod void testViewingToDoCreateEdit() {
        ADM_Work__c work = ADM_Work.createTestWork('ToDo');
        //create user and make sure they have the classic user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_CLASSIC;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectCreateOrEditPage();
            String qualifiedPageName = getQualifiedApexPageName('adm_workedittodo');
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }

    /*
    testcaseID a1DB00000002sIr
    userstory a07B0000000VcKdIAK
    Expected Results: The correct version of the detail page is shown when viewing an Investigation.  Only Bugs and Stories have a next gen page but we need to make sure Investigation's are still visible     regardless of what value is chosen for Work User Interface.
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    
   /**
    * Test the correct version of the detail page is shown when viewing an Investigation.  Only Bugs and Stories have a next gen page but we need to make 
    * sure Investigation's are still visible regardless of what value is chosen for Work User Interface.
    */
    static testMethod void testViewingInvestigationDetail() {
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        //create user and make sure they have the classic user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_CLASSIC;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectDetailPage();
            String qualifiedPageName = '';
            if(ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred()){
                qualifiedPageName = getQualifiedApexPageName('adm_investigationdetailsds');
            }
            else{
                qualifiedPageName = getQualifiedApexPageName('adm_workdetail');
            }
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }

    /*
    testcaseID a1DB00000002sIm
    userstory a07B0000000VcKdIAK
    Expected Results: the correct version of the create/edit page is shown when viewing a Investigation.  Only Bugs and Stories have a next gen page but we need to make sure Investigation's are still visible         regardless of what value is chosen for Work User Interface.
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */
    
    /**
    * Test the correct version of the create/edit page is shown when viewing a Investigation.  Only Bugs and Stories have a next gen page but we need to make 
    * sure Investigation's are still visible regardless of what value is chosen for Work User Interface.
    */
    static testMethod void testViewingInvestigationCreateEdit() {
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        //create user and make sure they have the classic user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_CLASSIC;
        insert u;
        
        Test.startTest();
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(stdController);
            PageReference page = ext.redirectCreateOrEditPage();
            String qualifiedPageName = getQualifiedApexPageName('adm_workeditinvestigation');
            System.assertEquals('/apex/'+qualifiedPageName, page.getUrl());
        }
        Test.stopTest();
        
    }
    /*
    testcaseID a1DB00000002tP5
    userstory a07B0000000VcKdIAK
    Expected Results: User is able to change record type and select all fields that are accessible on the user story layout
    hierarchy GUS.NextGenWorkPage.Re-direction mechanism
    */  
     /**
    * Test the correct version of the create/edit page is shown when viewing a User Story with next gen setting
    */
   
    static testMethod void testRedirectionWhenRecordTypeChanges() {
        //create user and make sure they have the next generation user interface
        User u = ADM_WorkUser.setupTestUser();
        u.work_user_interface__c = ADM_Work.UI_TYPE_NEXT_GENERATION;
        insert u;
        
        System.runAs(u) {
            //create a user story
            ADM_Work__c work = ADM_Work.createTestWork('User Story');
            RecordType bugRecordType = ADM_RecordType.getByName('Bug', 'ADM_Work__c');
             //simulate changing the record type to a Bug by adding URL params and initializing the Work Director Extension
            System.currentPageReference().getParameters().put('id', work.id);
            System.currentPageReference().getParameters().put('RecordType', bugRecordType.id);
            ADM_WorkDirectorExtension ext = new ADM_WorkDirectorExtension(new ApexPages.StandardController(work));
            
            //verify the correct page was chosen
            PageReference page = ext.redirectCreateOrEditPage();
            String qualifiedPageName = getQualifiedApexPageName('adm_bugedit');
            System.assert(page.getUrl().contains('/apex/'+qualifiedPageName), 'Expected the WorkDirector to direct us to the bug edit page but instead we were directed to url:' + page.getUrl());
        }
    }
    
    static String getQualifiedApexPageName(String pageName){
        
        String qualifiedPageName = (ADM_ConstantsSingleton.getInstance().getNameSpace() +  pageName).toLowerCase();  
        return qualifiedPageName; 
       
    }
}