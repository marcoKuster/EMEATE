public with sharing class RetrospectiveTests {
    private static User manager;
    private static User testUser;
    private static ADM_Release__c reviewPeriod;
    private static Retrospective__c testRetrospective;
    
    private static void initTestData() {
       Profile p = [select id from profile where name='Standard User'];
       manager = new User(alias = 'tmanager', email='test.manager@testorg.com',
            emailencodingkey='UTF-8', firstname='Test', lastname='Manager', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='test.manager@testorg.com');
       insert manager;
       testUser = new User(alias = 'tuser', email='test.user@testorg.com',
            emailencodingkey='UTF-8', firstname='Test', lastname='User', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='test.user@testorg.com', managerId = manager.Id);
       insert testUser;    
        
       reviewPeriod = new ADM_Release__c(Name='Summer 2012');
       insert reviewPeriod;
       
        System.runAs (testUser) {
           testRetrospective = new Retrospective__c(Name='Test Retrospective', Status__c = RetrospectiveControllerExtension.STATUS_NEW, Review_Period__c=reviewPeriod.id, User__c=testUser.id, Manager__c=manager.id);
           insert testRetrospective; 
        }
    }
    
    public static testMethod void testProperties() {
        
        initTestData();
        ApexPages.StandardController standardController = new ApexPages.StandardController(testRetrospective);
        RetrospectiveControllerExtension controllerToTest = new RetrospectiveControllerExtension(standardController);

        // Assert the labels are returned as expected.
        System.assert(controllerToTest.whatWentWellLabel.length() > 0);
        System.assert(controllerToTest.whatDidNotGoWellLabel.length() > 0);
        System.assert(controllerToTest.whatToDoBetterLabel.length() > 0);
        System.assert(controllerToTest.overallRatingLabel.length() > 0);
       
        System.runAs (testUser) {
            System.assert(controllerToTest.isEmployee);
            System.assert(!controllerToTest.isManager);
            System.assert(controllerToTest.canEdit);
            System.assert(controllerToTest.canSubmit);
            System.assert(!controllerToTest.canShare);
        }
       
        System.runAs (manager) {
            System.assert(!controllerToTest.isEmployee);
            System.assert(controllerToTest.isManager);
            System.assert(!controllerToTest.canEdit);
            System.assert(!controllerToTest.canSubmit);
            System.assert(!controllerToTest.canShare);
        }
       
    }
    
    /**
    public static testMethod void testDefaultValuesForNewRetrospective() {
        initTestData();
        Retrospective__c newRetrospective = new Retrospective__c(Name='New test Retrospective', Review_Period__c=reviewPeriod.id, User__c=testUser.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(newRetrospective);
        RetrospectiveControllerExtension controllerToTest = new RetrospectiveControllerExtension(stdController);
        
        System.runAs (testUser) {
            //Retrospective__c retrospectiveToTest = (Retrospective__c) stdController.getRecord();
            System.assertEquals(RetrospectiveControllerExtension.STATUS_NEW, newRetrospective.Status__c);
            System.assertEquals(manager.Id, newRetrospective.Manager__c);
        }
    }
    */

    public static testMethod void testCancel() {
       initTestData();
       navigateToTestRetrospectiveViewPage();
       
       ApexPages.StandardController standardController = new ApexPages.StandardController(testRetrospective);
       RetrospectiveControllerExtension controllerToTest = new RetrospectiveControllerExtension(standardController);
       
       System.runAs(testUser) {
           PageReference newPageRef = controllerToTest.cancel();
           String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
           
           String qualifiedPageName = (nameSpacePrefix + 'Feedback').toLowerCase();   
          
           System.assertEquals('/apex/'+qualifiedPageName, newPageRef.getUrl().toLowerCase());
           
        }
       
        
    }
    
    public static testMethod void testSave() {
       initTestData();
       navigateToTestRetrospectiveViewPage();
       
       ApexPages.StandardController standardController = new ApexPages.StandardController(testRetrospective);
       RetrospectiveControllerExtension controllerToTest = new RetrospectiveControllerExtension(standardController);
        
       System.runAs(testUser) {
           controllerToTest.retrospective.What_Went_Well_employee__c = 'test1';
           controllerToTest.retrospective.What_Didn_t_Go_Well_employee__c = 'test2';
           controllerToTest.retrospective.What_To_Do_Better_Next_Time_employee__c = constructTestString(35000);

           PageReference resultPageRef = controllerToTest.save();
           // TODO: uncomment this assert, throws a compilation error right now - fix it later.
           //System.assertEquals(RetrospectiveControllerExtension.ERROR_COMMENTS_MAX_LENGTH_EXCEEDED, controllerToTest,customErrorMessage);
           System.assertEquals(null, resultPageRef);
       }
    }
    
    private static String constructTestString(Integer length) {
        String sample = '';
        final Integer MAX_LENGTH = 100000;
        
        if (length <= 0) return '';
        if (length > MAX_LENGTH) return null;
        
        for (Integer cutoff = 10; cutoff <= MAX_LENGTH; cutoff = cutoff * 10) {
            if (sample == '') {
                sample = 'abcde12345';
            }
            else {
                String newSample = '';
                for (Integer i = 0; i < 10; i ++) {
                    newSample += sample;
                }
                sample = newSample;
            }

            if (length <= cutoff) {
                return sample.substring(0, length);
            }
        }
        
        return null;
    }
    
    
    public static testMethod void testSubmitAndShare() {
       initTestData();
       navigateToTestRetrospectiveViewPage();
       
       ADM_Release__c existingRelease = reviewPeriod;
       ADM_Release__c newRelease = new ADM_Release__c(Name='Winter 2012');
       insert newRelease;
       Retrospective__c newRetrospective = new Retrospective__c(Name='New Retrospective', Review_Period__c = newRelease.id, User__c = testUser.id, Manager__c = manager.Id);
       
       ApexPages.StandardController standardController = new ApexPages.StandardController(newRetrospective);
       RetrospectiveControllerExtension controllerToTest = new RetrospectiveControllerExtension(standardController);
       String longString = constructTestString(35000);
       
       System.runAs(testUser) {
           // Initialize properties so empty values in the new retrospective get populated.
           controllerToTest.initializeProperties(newRetrospective);
           controllerToTest.retrospective.What_Went_Well_employee__c = 'test1';
           controllerToTest.retrospective.What_Didn_t_Go_Well_employee__c = 'test2';
           controllerToTest.retrospective.What_To_Do_Better_Next_Time_employee__c = longString;

           PageReference resultPageRef = controllerToTest.save();
           // TODO: uncomment this assert, throws a compilation error right now - fix it later.
           //System.assertEquals(RetrospectiveControllerExtension.ERROR_COMMENTS_MAX_LENGTH_EXCEEDED, controllerToTest,customErrorMessage);
           System.assert(resultPageRef == null);
           
           controllerToTest.retrospective.What_To_Do_Better_Next_Time_employee__c = '';
           controllerToTest.retrospective.Review_Period__c = existingRelease.Id;  // Set to existing review period
           resultPageRef = controllerToTest.save();
           System.assert(resultPageRef == null);
           
           controllerToTest.retrospective.Review_Period__c = newRelease.Id;  // Set to new review period
           resultPageRef = controllerToTest.save();
           System.assert(resultPageRef != null);

           // TODO - Add assertions
           resultPageRef = controllerToTest.submitToManager();
           System.assert(resultPageRef == null);

           controllerToTest.retrospective.What_To_Do_Better_Next_Time_employee__c = 'test3';
           resultPageRef = controllerToTest.submitToManager();
           System.assert(resultPageRef != null);
       }

       System.runAs(manager) {
           controllerToTest.retrospective.What_Went_Well_manager__c = 'test1';
           controllerToTest.retrospective.What_Didn_t_Go_Well_manager__c = 'test2';
           controllerToTest.retrospective.What_To_Do_Better_Next_Time_manager__c = longString;

           PageReference resultPageRef = controllerToTest.save();
           // TODO: uncomment this assert, throws a compilation error right now - fix it later.
           //System.assertEquals(RetrospectiveControllerExtension.ERROR_COMMENTS_MAX_LENGTH_EXCEEDED, controllerToTest,customErrorMessage);
           System.assertEquals(null, resultPageRef);
           
           controllerToTest.retrospective.What_To_Do_Better_Next_Time_manager__c = '';
           resultPageRef = controllerToTest.save();
           System.assert(resultPageRef != null);
           
           // TODO - Add assertions
           resultPageRef = controllerToTest.shareWithEmployee();
           System.assert(resultPageRef == null);

           controllerToTest.retrospective.What_To_Do_Better_Next_Time_manager__c = 'test3';
           resultPageRef = controllerToTest.shareWithEmployee();
           System.assert(resultPageRef != null);
       }
    }
    
    private static void navigateToTestRetrospectiveViewPage() {
       PageReference pageRef = Page.RetrospectiveView;
       Test.setCurrentPage(pageRef);
       pageRef.getParameters().put('id',testRetrospective.id);
    }
    
    public static testMethod void testDelete() {
        initTestData();
        
        System.runAs(testUser) {
            Retrospective__c retroToDelete = new Retrospective__c(Name='Test Retrospective', Status__c = RetrospectiveControllerExtension.STATUS_SHARED_WITH_MANAGER, Review_Period__c=reviewPeriod.id, User__c=testUser.id, Manager__c=manager.id);
            insert retroToDelete;
            try {
                delete retroToDelete;
                System.assert(false);
            }
            catch(DMLException e) {
            }  
        }
        
    }
    
    public static testMethod void testRetrospectiveMini() {
        initTestData();
         
        System.runAs(testUser) {
            RetrospectiveMiniController controller = new RetrospectiveMiniController();
            controller.userId = testUser.Id;
            System.assertEquals(1, controller.retros.size());
        }
        
    }
    
}