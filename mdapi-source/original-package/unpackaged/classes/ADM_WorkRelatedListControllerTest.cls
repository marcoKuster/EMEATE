@isTest
public class ADM_WorkRelatedListControllerTest {

    /*

      @testcaseID a0B20000003yOApEAM

      @hierarchy GUS.BugforceToGUS.Change Lists page.Add new change list in GUS

      @userstory a0A20000001uzqH

      @expectedResults: The change list should get submitted and the change list link and description shows on the Work Item under "Change Lists" section. This section shows the Perforce link, check in user name, check in date and Comments

    */
    @isTest
    static void testChangeListLimit() {
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController();
        wrl.enableChangeListLimit();
        System.assertEquals(true, wrl.getChangeListLimit());
        wrl.disableChangeListLimit();
        System.assertEquals(false, wrl.getChangeListLimit());
    }

    /*

      @testcaseID a0B20000005GDvBEAW

      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-626310

      @userstory a0A20000001uzqH

      @expectedResults: The list of production cases show in descending order by case ID

    */
    @isTest
    static void test62OrgLimit() {
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController();
        wrl.enable62OrgCaseLimit();
        System.assertEquals(true, wrl.getSixtyTwoOrgCaseLimit());
        wrl.disable62OrgCaseLimit();
        System.assertEquals(false, wrl.getSixtyTwoOrgCaseLimit());
    }

    /*

      @testcaseID a0B20000005IJ1dEAG

      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-621041

      @userstory a0A20000001uzqH

      @expectedResults: The release stamps list shows without returning any errors

    */
    @isTest
    static void testReleaseLimit() {
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController();
        wrl.enableReleaseLimit();
        System.assertEquals(true, wrl.getReleaseLimit());
        wrl.disableReleaseLimit();
        System.assertEquals(false, wrl.getReleaseLimit());
    }


    @isTest
    static void testListSizes() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController(work);

        wrl.getRelatedChangeListSize();
        System.assert(wrl.relatedChangeListSize != null);

        wrl.getRelatedReleaseListSize();
        System.assert(wrl.relatedReleaseListSize != null);

        wrl.getRelated62OrgCaseListSize();
        System.assert(wrl.related62OrgCaseListSize != null);
    }

    /*

      @testcaseID a0B20000001pXSvEAM

      @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Detail page

      @userstory a0A20000001uzqH

      @expectedResults: A release link shows under the "Releases" section on work detail page

    */
    @isTest
    static void testGetRelatedReleasesList() {
        ADM_Work__c work = ADM_Work.createTestWork();
        
        List<ADM_Release__c> rels = new List<ADM_Release__c>();
        List<ADM_Released_In__c> stamps = new List<ADM_Released_In__c>();
        for(Integer i=0; i < 6; i++) {
            ADM_Release__c release = new ADM_Release__c(Name='ApexTestReleaseName-' + i);
            rels.add(release);
            
        } 
        insert rels;
        
        for(Integer i=0; i < 6; i++) {
            ADM_Release__c r = rels.get(i); 
            ADM_Released_In__c stamp = new ADM_Released_In__c();
            stamp.Work__c = work.id;
            stamp.Release__c = r.id;
            stamps.add(stamp);
        } 
        insert stamps;
        
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController(work);
        wrl.enableReleaseLimit();
        List<ADM_Released_In__c> releases = wrl.getRelatedReleasesList();
        System.assertEquals(5, releases.size());
        wrl.disableReleaseLimit();
        List<ADM_Released_In__c> releasesNoLimit = wrl.getRelatedReleasesList();
        System.assertEquals([select count() from ADM_Released_In__c where Work__c = : wrl.getWorkID()], releasesNoLimit.size());
    }

    /*

      @testcaseID a0B20000007nSodEAE

      @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Detail page

      @userstory a0A20000001uzqH

      @expectedResults: When there is an amount of more than 5 changes lists, a link to go to the list appears on the work detail page

    */
    @isTest
    static void testGetRelatedChangeListWithoutLimit() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController(work);
        ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
        ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
        ADM_Change_List__c cl;
        List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

        String describe = '';

        wrl.disableChangeListLimit();

        for(Integer i = 0; i > 1001; i++) {
            describe = describe + '        Testing new ARS';
            describe = describe + '        https://tapp0.salesforce.com/' + wrl.getWorkID();
            describe = describe + '        @rev jhatton@';
            describe = describe + '        @revert@';

            pc.Describe__c = 'Change: 9999' + i + '\n\nClient: alwilliams-wsr\n\nStatus: pending\n\nDescription:\n' + describe;
            pc.Changelist__c = '9999' + i;
            pc.Release__c = 'ATHF';

            cl = cld.getChangelist(pc.Describe__c, pc.Changelist__c, wrl.getWorkID(), pc.Release__c, pc.User__c, '');
            cls.add(cl);
        }

        Database.insert(cls);

        List<ADM_Change_List__c> relListNoLimit = wrl.getRelatedChangeLists();
        relListNoLimit = wrl.getRelatedChangeLists();

        System.assertEquals([select count() from ADM_Change_List__c where Work__c = : wrl.getWorkID()], relListNoLimit.size());

    }

    /*

      @testcaseID a0B20000001pXSsEAM

      @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Detail page

      @userstory a0A20000001uzqH

      @expectedResults: The new change lists show under the "Change Lists" section

    */
    @isTest
    static void testGetRelatedChangeList() {
        ADM_Work__c work = ADM_Work.createTestWork();
        List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();
        for(Integer i =0; i<6; i++ ) {
            ADM_Change_List__c cl = new ADM_Change_List__c();
            cl.External_ID__c = work.id + '-' + i;
            cl.Perforce_Changelist__c = 'Test:' + i;
            cl.Work__c = work.id;
            cls.add(cl);
        }
        
        insert cls;
        
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController(work);
        wrl.enableChangeListLimit();
        List<ADM_Change_List__c> relList = wrl.getRelatedChangeLists();
        System.assertEquals(5, relList.size());
        wrl.disableChangeListLimit();
        List<ADM_Change_List__c> relListNoLimit = wrl.getRelatedChangeLists();
        System.assertEquals([select count() from ADM_Change_List__c where Work__c = : wrl.getWorkID()], relListNoLimit.size());
    }

    /*

      @testcaseID a0B20000005IIyxEAG

      @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGus.Detail page

      @userstory a0A20000001uzqH

      @expectedResults: All 62 org cases are linked to the work item

    */
    @isTest
    static void testGetRelated62OrgList() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController(work);
        wrl.enable62OrgCaseLimit();
        List<ADM_Case__c> relList = wrl.getRelated62OrgCaseList();
        System.assertEquals([select count() from ADM_Case__c where Work__c = : wrl.getWorkID()], relList.size());
        wrl.disable62OrgCaseLimit();
        List<ADM_Case__c> relListNoLimit = wrl.getRelated62OrgCaseList();
        System.assertEquals([select count() from ADM_Case__c where Work__c = : wrl.getWorkID()], relListNoLimit.size());
    }

    @isTest
    static void testErrorMessages() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController(work);
        wrl.addDuplicateItemErrorMsg();
        wrl.addSelfReferenceErrorMsg();
        wrl.addInvalidItemErrorMsg('widget', '123abc');
        wrl.addReferenceExistsErrorMsg();
        wrl.addReferenceExistsErrorMsg('test item');
        wrl.addReferenceExistsErrorMsg('test id', 'child');
        System.assertEquals(6, wrl.getErrorMessages().size());
        wrl.clearErrorMessages();
        System.assertEquals(0, wrl.getErrorMessages().size());

    }

    @isTest
    public static void getRelatedParentWorkListSizeTest(){
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_WorkRelatedListController wrl = new ADM_WorkRelatedListController(work);
        Integer c = wrl.getRelatedParentWorkListSize();
        String s = wrl.getWorkID();
        System.assertEquals(c, 0);
        wrl.setWorkID(work.id);
        ADM_Work__c workR = wrl.getWork();
        System.assertEquals(workR.id, work.id);
        wrl.setWork(workR);
        List<String> msgs =  wrl.getFatalErrorMessages();
        System.assertEquals(msgs, null);
    }
}