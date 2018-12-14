@isTest
private class ADM_ReleaseRelatedListControllerTest {
    private static ADM_Release__c release {
        get {
          if(release == null) {
              release = ADM_Release.createTestRelease();
          }
          return release;
        }
        set;
    }

    private static final String successComplete = 'Your request has been successfully completed';
    /*
    @testcaseID a1DB00000000x3j
    userstory a07B0000000UO64
    Expected results  Copy all stamps
    Hierarchy GUS.Releases page.Automated Release Stamping
    */
    static testMethod void copyAll() {
        System.assert(release.id != null);
        ADM_Release__c release2 = release.clone(false,true);
        release2.Name = release.Id;
        insert release2;
        ADM_Released_In__c stamp = ADM_Release.createTestReleasedIn(release);
        ADM_Released_In__c stamp2 = stamp.clone(false,true);
        stamp2.Release__c = release2.Id;
        stamp2.External_ID__c = null;

        ADM_StampsWrapper sw = new ADM_StampsWrapper();
        sw.checked = true;
        sw.stamp = stamp;
        List<ADM_StampsWrapper> sws = new list<ADM_StampsWrapper>();
        sws.add(sw);
        System.currentPageReference().getParameters().put('id', release.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);


        Test.startTest();
        ctrl.allStampsFrom = null;
        System.assert(ctrl.setCon != null);
        ctrl.autoCompleteRelease = release2;
        System.assert(ctrl.resultSize != null,'Result size was equal to null');
        System.assert(ctrl.pageSize != null,'Page size was equal to null');
        System.assert(ctrl.hasNext != null,'hasNext was equal to null');
        System.assert(ctrl.hasPrevious != null,'hasPrevious was equal to null');
        System.assert(ctrl.pageNumber != null,'pageNumber was equal to null');
        System.assert(ctrl.rowStart != null,'rowStart was equal to null');
        System.assert(ctrl.rowEnd != null,'rowEnd was equal to null');
        System.assert(ctrl.autoCompleteRelease != null);
        //System.assert(ctrl.release != null);

        ctrl.enableReleaseAssignment();
        ctrl.disableReleaseAssignment();
        List<ADM_StampsWrapper> stamps = ctrl.getStamps();
        Pagereference pr = ctrl.CopyAll();
        System.assertEquals(successComplete, pr.getParameters().get('message'));
        ctrl.Copy();
        ctrl.Transfer();
        ctrl.TransferAll();
        ctrl.stampId = stamp.Id;
        ctrl.deleteStamp();
        ctrl.first();
        ctrl.last();
        ctrl.previous();
        ctrl.next();
        ctrl.cancel();
        ctrl.autoCompleteRelease = null;
        System.assertNotEquals(null, ctrl.autoCompleteRelease);
        ctrl.Copy();
        Test.stopTest();
    }

    static testMethod void releaseWithNoStamps() {
        ADM_Release__c release2 = release.clone(false,true);
        release2.Name = release.Id;
        insert release2;

        System.currentPageReference().getParameters().put('id', release2.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release2);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);

        //System.assertEquals(true, Apexpages.hasMessages());
    }
    /*
    @testcaseID a1DB00000000x3o
    userstory a07B0000000UO64
    Expected results transfer all stamps from one release to another
    Hierarchy GUS.Releases page.Automated Release Stamping
    */

    static testMethod void transferAll() {
        //setup two releases so that we can transfer stamps between them
        System.assert(release.id != null);
        ADM_Release__c release2 = release.clone(false,true);
        release2.Name = String.valueOf(Math.random());
        insert release2;
        ADM_Released_In__c stamp = ADM_Release.createTestReleasedIn(release);
        //flesh out stamp as some fields are popualted by the trigger
        stamp = [select id, Work__c, Release__c, Stamped_On__c from ADM_Released_In__c where id=:stamp.id];
        //log original time stamp for assertions later
        Datetime originalStampedOn = stamp.Stamped_On__c;
        
        //create second stamp in the second release
        ADM_Released_In__c stamp2 = stamp.clone(false,true);
        stamp2.Release__c = release2.Id;
        stamp2.External_ID__c = null;

        //view the release related list
        ADM_StampsWrapper sw = new ADM_StampsWrapper();
        sw.checked = true;
        sw.stamp = stamp;
        List<ADM_StampsWrapper> sws = new list<ADM_StampsWrapper>();
        sws.add(sw);
        System.currentPageReference().getParameters().put('id', release.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);

        //mimic the user populating the release text box and transfer the stamps from release1 to release2
        Test.startTest();
        ctrl.allStampsFrom = null;
        System.assert(ctrl.setCon != null);
        ctrl.autoCompleteRelease = release2;

        ctrl.enableReleaseAssignment();
        ctrl.disableReleaseAssignment();
        List<ADM_StampsWrapper> stamps = ctrl.getStamps();
        Pagereference pr = ctrl.TransferAll();
        System.assertEquals(successComplete, pr.getParameters().get('message'));
        Test.stopTest();
        
        //post stop test so any async processes are complete
        ADM_Released_In__c stampPostTransferAll = [select id, Stamped_On__c from ADM_Released_In__c where release__c =:release2.Id and Work__c =:stamp.Work__c];
        System.assertEquals(originalStampedOn, stampPostTransferAll.Stamped_On__c);
    }

    static testMethod void verifyRefresh() {
        System.currentPageReference().getParameters().put('id', release.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);
        Pagereference pr = ctrl.refresh();
        System.assertEquals(release.Id, pr.getParameters().get('id'),'->' + pr);
    }

    static testMethod void verifyNothing() {
        System.currentPageReference().getParameters().put('id', release.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);
        Pagereference pr = ctrl.nothing();
        System.assertEquals(null, pr);
    }
    /*
    @testcaseID a1DB00000000x3t
    userstory a07B0000000UO64
    Expected results delete all stamps
    Hierarchy GUS.Releases page.Automated Release Stamping
    */
    static testMethod void deleteAll() {
        System.currentPageReference().getParameters().put('id', release.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);
        Pagereference pr = ctrl.DeleteAll();
    }

    static testMethod void flushStamps() {
        System.currentPageReference().getParameters().put('id', release.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);
        ctrl.flushAddStamps();
        ctrl.flushDeleteStamps();
    }

    static testMethod void transferAllToSameRelease() {
        System.assert(release.id != null);
        ADM_Release__c release2 = release.clone(false,true);
        release2.Name = String.valueOf(Math.random());
        insert release2;
        ADM_Released_In__c stamp = ADM_Release.createTestReleasedIn(release);
        ADM_Released_In__c stamp2 = stamp.clone(false,true);
        stamp2.Release__c = release2.Id;
        stamp2.External_ID__c = null;

        ADM_StampsWrapper sw = new ADM_StampsWrapper();
        sw.checked = true;
        sw.stamp = stamp;
        List<ADM_StampsWrapper> sws = new list<ADM_StampsWrapper>();
        sws.add(sw);
        System.currentPageReference().getParameters().put('id', release.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);


        Test.startTest();
        ctrl.allStampsFrom = null;
        System.assert(ctrl.setCon != null);
        ctrl.autoCompleteRelease = release;

        ctrl.enableReleaseAssignment();
        ctrl.disableReleaseAssignment();
        List<ADM_StampsWrapper> stamps = ctrl.getStamps();
        Pagereference pr = ctrl.TransferAll();
        System.assertEquals(true, Apexpages.hasMessages());
        Test.stopTest();
    }

    static testMethod void testGetUrl() {
        System.currentPageReference().getParameters().put('id', release.id);
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
        ADM_ReleaseRelatedListController ctrl = new ADM_ReleaseRelatedListController(sc);
        
        System.assertEquals(ADM_WorkUtils.GUS_URL, ctrl.GUS_URL);
    }
        /*
    @testcaseID a1DB00000002n8n
    userstory a07B0000000UO64
    Expected results Message shows that release contains over 1000 stamps
    Hierarchy GUS.Releases page.Automated Release Stamping
    */
    static testMethod void testOverMaxNumberOfStamps() {
        ADM_Release__c release1 = ADM_Release.createTestRelease();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        List<ADM_Released_In__c> stamps = new List<ADM_Released_In__c>();
        for(ADM_Work__c work : works) {
            ADM_Released_In__c stamp = new ADM_Released_In__c();
            stamp.Work__c = work.Id;
            stamp.Release__c = release1.Id;
            stamp.External_ID__c = work.Id + '-' + release1.Id;
            stamps.add(stamp);
        }
        insert stamps;
        
        System.currentPageReference().getParameters().put('id', release1.id);
        Apexpages.Standardcontroller standardController = new Apexpages.Standardcontroller(release1);
        ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(standardController);
        controller.maxNumberOfStamps = 5;
        controller.MAP_SIZE_MAX = 3;
        
        ApexPages.StandardSetController setController = controller.setCon;
        
        System.assert(setController != null);
        System.assert(!ApexPages.getMessages().isEmpty(), 'Expected a message to be added because there are more stamps than the max transfer and max display amounts');
        
        Boolean found = false;
        for(ApexPages.Message message : ApexPages.getMessages()) {
            if(message.getDetail().containsIgnoreCase('total')) {
                found = true;
            }
        }
        System.assert(found, 'Expected the page to have the transfer max limit message and the max display limit message.' + ApexPages.getMessages());
    }

    static testMethod void testGetStamps() {
        ADM_Release__c release1 = ADM_Release.createTestRelease();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        List<ADM_Released_In__c> stamps = new List<ADM_Released_In__c>();
        for(ADM_Work__c work : works) {
            ADM_Released_In__c stamp = new ADM_Released_In__c();
            stamp.Work__c = work.Id;
            stamp.Release__c = release1.Id;
            stamp.External_ID__c = work.Id + '-' + release1.Id;
            stamps.add(stamp);
        }
        insert stamps;
        
        System.currentPageReference().getParameters().put('id', release1.id);
        Apexpages.Standardcontroller standardController = new Apexpages.Standardcontroller(release1);
        ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(standardController);
        
        //populate the stamps wrapper collection and check one of the stamps
        List<ADM_StampsWrapper> stampWrappers = controller.getStamps();
        Id selectedStamp = stampWrappers.get(0).stamp.Id;
        stampWrappers.get(0).checked = true;
        
        stampWrappers = controller.getStamps();
        
        Boolean checked = false;
        for(ADM_StampsWrapper stamp : stampWrappers) {
            if(stamp.stamp.Id == selectedStamp) {
                checked = stamp.checked;
                break;
            }
        }
        System.assert(checked, 'Expected the second call to getStamps would keep the checked property the same.');
    }
    
    static testMethod void testDeleteAllWhenOverTransferAmount() {
        ADM_Release__c release1 = ADM_Release.createTestRelease();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        List<ADM_Released_In__c> stamps = new List<ADM_Released_In__c>();
        for(ADM_Work__c work : works) {
            ADM_Released_In__c stamp = new ADM_Released_In__c();
            stamp.Work__c = work.Id;
            stamp.Release__c = release1.Id;
            stamp.External_ID__c = work.Id + '-' + release1.Id;
            stamps.add(stamp);
        }
        insert stamps;
        
        System.currentPageReference().getParameters().put('id', release1.id);
        Apexpages.Standardcontroller standardController = new Apexpages.Standardcontroller(release1);
        ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(standardController);
        controller.MAP_SIZE_MAX = 3;
        
        Test.startTest();
        controller.DeleteAll();
        Test.stopTest();
        
        System.assertEquals(0, [select count() from ADM_Released_In__c where Release__c = :release1.Id], 'Expected all stamps to be deleted');
    }
    
    static testMethod void testshowAssignReleaseControlsAndHideAssignReleaseButton(){   
        ADM_Release__c release1 = ADM_Release.createTestRelease(); 
        Apexpages.Standardcontroller standardController = new Apexpages.Standardcontroller(release1);
        ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(standardController);
        ApexPages.StandardSetController setCon = controller.setCon;
        System.assertEquals('display:block',controller.assignReleaseDivStyle,'Asserting the initial value of the variable before method call');
        System.assertEquals('display:none',controller.buttonsDivStyle,'Asserting the initial value of the variable before method call');
        controller.showAssignReleaseControlsAndHideAssignReleaseButton();
        System.assertEquals('display:none',controller.assignReleaseDivStyle,'Asserting the value of the variable after the method call');
        System.assertEquals('display:block',controller.buttonsDivStyle,'Asserting the initial value of the variable after the method call');
    
    }
    
    static testMethod void testhideAssignReleaseControlsAndShowAssignReleaseButton(){   
        ADM_Release__c release1 = ADM_Release.createTestRelease(); 
        Apexpages.Standardcontroller standardController = new Apexpages.Standardcontroller(release1);
        ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(standardController);
        ApexPages.StandardSetController setCon = controller.setCon;
        controller.showAssignReleaseControlsAndHideAssignReleaseButton();
        System.assertEquals('display:none',controller.assignReleaseDivStyle,'Asserting the initial value of the variable before the method call');
        System.assertEquals('display:block',controller.buttonsDivStyle,'Asserting the initial value of the variable before the method call');
        controller.hideAssignReleaseControlsAndShowAssignReleaseButton();
        System.assertEquals('display:block',controller.assignReleaseDivStyle,'Asserting the value of the variable after the method call');
        System.assertEquals('display:none',controller.buttonsDivStyle,'Asserting the value of the variable after the method call');
    
    }
    
    static testMethod void doCancelTest() {
       Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
       ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(sc);
       Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Release__c;
       String expectedUrl = '/' + result.getKeyPrefix() + '/o';
       PageReference returnPage = controller.doCancel();
       System.assertEquals(expectedUrl,returnPage.getUrl(),'Asserting if it returns back to the Release list view page on click of cancel button');
    }
    
    static testMethod void getListViewLinkTest() {
       Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(release);
       ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(sc);
       Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Release__c;
       String expectedUrl = '/' + result.getKeyPrefix() + '/o';
       String returnUrl = controller.getListViewLink();
       System.assertEquals(expectedUrl,returnUrl,'Asserting if it returns the link to the Release list view page');
    }
    
    
    static testMethod void doSaveAndNewTest() {
       Integer beforeCount = [Select count() from ADM_Release__c];
       ADM_Release__c releaseObj = ADM_Release.createTestRelease();
       Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(releaseObj);
       ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(sc);
       Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Release__c;
       String expectedUrl = '/' + result.getKeyPrefix() + '/e';
       PageReference returnPage = controller.doSaveAndNew();
       Integer afterCount = [Select count() from ADM_Release__c];
       System.assertEquals(expectedUrl,returnPage.getUrl(),'Asserting if it opens a new Release page on click of Save&New button');
       System.assertEquals(beforeCount+1,afterCount,'A new record is saved and the new Page opens on click of Save&New'); 
    }
    
    
    static testMethod void testTransferAllWhenOverTransferAmount() {
        ADM_Release__c release1 = ADM_Release.createTestRelease();
        
        ADM_Release__c release2 = new ADM_Release__c(Name = 'NewRelease-asdf9876');
        insert release2;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        List<ADM_Released_In__c> stamps = new List<ADM_Released_In__c>();
        for(ADM_Work__c work : works) {
            ADM_Released_In__c stamp = new ADM_Released_In__c();
            stamp.Work__c = work.Id;
            stamp.Release__c = release1.Id;
            stamp.External_ID__c = work.Id + '-' + release1.Id;
            stamps.add(stamp);
        }
        insert stamps;
        
        System.currentPageReference().getParameters().put('id', release1.id);
        Apexpages.Standardcontroller standardController = new Apexpages.Standardcontroller(release1);
        ADM_ReleaseRelatedListController controller = new ADM_ReleaseRelatedListController(standardController);
        ApexPages.StandardSetController setCon = controller.setCon; //FIXME: Why does setCon initialize the selected release's information?
        controller.autoCompleteRelease = release2;
        controller.MAP_SIZE_MAX = 3;
        
        Test.startTest();
        controller.TransferAll();
        Test.stopTest();
        
        System.assertEquals(0, [select count() from ADM_Released_In__c where Release__c = :release1.Id], 'Expected all stamps to be deleted');
    }
}