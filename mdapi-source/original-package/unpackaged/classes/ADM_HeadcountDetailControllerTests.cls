@isTest
public class ADM_HeadcountDetailControllerTests {

/*
@testcaseiD a1DB00000001PdZ
@userstory a07B0000000LIiF
@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
@Expected Results Recruiter is able to make offer using a position that's in a current fiscal quarter
@Author: Jared Pearson
*/

    /**
     * Given a head count with
     *  - effective date = current quarter and
     *  - status = 'Open - New'
     * then getRecruitActionsCssClass should return 'recruitActionsOpen'
     */
    public static testMethod void testGetRecruitActionsCssClassOpenNew() {
        //create the new headcount instance
        User hiringManager = ADM_WorkUser.createTestUserWithRandomName();
        Headcount__c hc = new Headcount__c();
        hc.Hiring_Manager__c = hiringManager.Id;
        hc.Status__c = 'Open - New';
        hc.Effective_Date__c = 'FY12-Q1';
        insert hc;

        //the context date must be within the quarter
        Date contextDate = Date.newInstance(2011, 02, 01);

        ApexPages.StandardController stdController = new ApexPages.StandardController(hc);
        ADM_HeadcountDetailController controller = new ADM_HeadcountDetailController(stdController, contextDate);
        String actual = controller.getRecruitActionsCssClass();

        System.assertEquals('recruitActionsOpen', actual);
    }

/*
@testcaseiD a1DB00000001Pdo
@userstory a07B0000000LIiF
@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
@Expected Results Recruiter is able to make offer using a position that's in a current fiscal quarter
@Author: Jared Pearson
*/
    /**
     * Given a head count with
     *  - effective date = current quarter and
     *  - status = 'Open - Backfill'
     * then getRecruitActionsCssClass should return 'recruitActionsOpen'
     */
    public static testMethod void testGetRecruitActionsCssClassOpenBackfill() {
        //create the headcount instance open for backfill
        Headcount__c hc = new Headcount__c();
        User hiringManager = ADM_WorkUser.createTestUserWithRandomName();
        hc.Hiring_Manager__c = hiringManager.Id;
        hc.Status__c = 'Open - Backfill';
        hc.Effective_Date__c = 'FY12-Q1';
        hc.Backfill_Date__c = (System.today() + 1);
        hc.Backfill_Name__c = 'Test Name';
        insert hc;

        //the context date must be within the quarter
        Date contextDate = Date.newInstance(2011, 02, 01);

        ApexPages.StandardController stdController = new ApexPages.StandardController(hc);
        ADM_HeadcountDetailController controller = new ADM_HeadcountDetailController(stdController, contextDate);
        String actual = controller.getRecruitActionsCssClass();

        System.assertEquals('recruitActionsOpen', actual);
    }

/*
@testcaseiD a1DB00000001O3b
@userstory a07B0000000LIiF
@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
@Expected Results The Make Offer button is not available for Positions with status "Offer in Progress"
@Author: Jared Pearson
*/
    /**
     * Given a head count with
     *  - effective date = current quarter and
     *  - status = 'Offer In Progress'
     * then getRecruitActionsCssClass should return 'recruitActionsInProgress'
     */
    public static testMethod void testGetRecruitActionsCssClassOfferInProgress() {
        //create the headcount instance
        User hiringManager = ADM_WorkUser.createTestUserWithRandomName();
        Headcount__c hc = new Headcount__c();
        hc.Hiring_Manager__c = hiringManager.Id;
        hc.Status__c = 'Offer In Progress';
        hc.Effective_Date__c = 'FY12-Q1';
        hc.Target_Start_Date__c = Date.newInstance(2011, 02, 01);
        hc.Talentforce_Offer__c = 'JO-1234-ABCD';
        hc.Backfill_Name__c = 'test';
        hc.Candidate_Name__c = 'Test Name';
        insert hc;

        //the context date must be within the quarter
        Date contextDate = Date.newInstance(2011, 02, 01);

        ApexPages.StandardController stdController = new ApexPages.StandardController(hc);
        ADM_HeadcountDetailController controller = new ADM_HeadcountDetailController(stdController, contextDate);
        String actual = controller.getRecruitActionsCssClass();

        System.assertEquals('recruitActionsInProgress', actual);
    }

/*
@testcaseiD a1DB00000001QfE
@userstory a07B0000000LIiF
@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
@Expected Results The Make Offer button is not available for Positions with status "offer accepted"
@Author: Jared Pearson
*/
    /**
     * Given a head count with
     *  - effective date = current quarter and
     *  - status = 'Offer Accepted'
     * then getRecruitActionsCssClass should return 'recruitActionsInProgress'
     */
    public static testMethod void testGetRecruitActionsCssClassOfferAccepted() {
        //create the headcount instance
        User hiringManager = ADM_WorkUser.createTestUserWithRandomName();
        Headcount__c hc = new Headcount__c();
        hc.Hiring_Manager__c = hiringManager.Id;
        hc.Status__c = 'Offer Accepted';
        hc.Effective_Date__c = 'FY12-Q1';
        hc.Target_Start_Date__c = Date.newInstance(2011, 02, 01);
        hc.Talentforce_Offer__c = 'JO-1234-ABCD';
        hc.Backfill_Name__c = 'test';
        hc.Candidate_Name__c = 'Test Name';
        insert hc;

        //the context date must be within the quarter
        Date contextDate = Date.newInstance(2011, 02, 01);

        ApexPages.StandardController stdController = new ApexPages.StandardController(hc);
        ADM_HeadcountDetailController controller = new ADM_HeadcountDetailController(stdController, contextDate);
        String actual = controller.getRecruitActionsCssClass();

        System.assertEquals('recruitActionsInProgress', actual);
    }

/*
@testcaseiD a1DB00000001O3h
@userstory a07B0000000LIiF
@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
@Expected Results  The Make Offer button is not available for Positions with status "filled"
@Author: Jared Pearson
*/
    /**
     * Given a head count with
     *  - effective date = current quarter and
     *  - status = 'Filled'
     * then getRecruitActionsCssClass should return 'recruitActionsFilled'
     */
    public static testMethod void testGetRecruitActionsCssClassFilled() {
        //create the headcount instance
        Headcount__c hc = new Headcount__c();
        User hiringManager = ADM_WorkUser.createTestUserWithRandomName();
        hc.Hiring_Manager__c = hiringManager.Id;
        hc.Status__c = 'Filled';
        User user = ADM_WorkUser.createTestUserWithRandomName();
        hc.Headcount_Name__c = user.Id;
        hc.Effective_Date__c = 'FY12-Q1';
        insert hc;

        //the context date must be within the quarter
        Date contextDate = Date.newInstance(2011, 02, 01);

        ApexPages.StandardController stdController = new ApexPages.StandardController(hc);
        ADM_HeadcountDetailController controller = new ADM_HeadcountDetailController(stdController, contextDate);
        String actual = controller.getRecruitActionsCssClass();

        System.assertEquals('recruitActionsFilled', actual);
    }

/*
@testcaseiD a1DB00000001Ou7
@userstory a07B0000000N8mEIAS
@Hierarchy GUS.ScrumforceToGUS.Position.Hiring Manager Actions - Edit
@Expected Results An error should not occur and the position should be viewable and editable
@Author: Jared Pearson
*/
    public static testMethod void testHeadcountWithoutHiringManager() {
        //create the new headcount instance without a hiring manager
        Headcount__c hc = new Headcount__c();
        hc.Hiring_Manager__c = null;
        hc.Status__c = 'Open - New';
        hc.Effective_Date__c = 'FY12-Q1';
        insert hc;

        //the context date must be within the quarter
        Date contextDate = Date.newInstance(2011, 02, 01);

        ApexPages.StandardController stdController = new ApexPages.StandardController(hc);
        ADM_HeadcountDetailController controller = new ADM_HeadcountDetailController(stdController, contextDate);
        controller.getShowRequestOfferButton();
        System.assert(!ApexPages.hasMessages(), 'Expected no errors to occur when displaying a position without a hiring manager');
    }


    /*
@testcaseiD a1DB00000001PdF
@userstory a07B0000000N8mEIAS
@Hierarchy GUS.Position.Hiring Manager Request Offer
@Expected Results Email is sent to Recruiter.
            Email includes:
            Effective Date
            Region
            Role
            and the following text:

            Hello {Recruiter__c}, {Hiring_Manager__c} has requested that you begin the offer process for {Candidate_Name__c}.

            Please note, this open position on the GUS Roster is intended for hiring a new {Role__c}, effective as of {Effective_Date__c}, in
            {Region__c}. If the fiscal quarter or region information doesn't match your records for this Job ID, please ask the manager to correct the Position information with their Finance Business Partner.

            To proceed with making this offer, or to review details of the open Position, please visit ["the record" = link to the record using the autonumber ID}].
*/

    public static testMethod void testShowRequestOfferButtonWhenUserIsHiringManager() {
        User newUser = ADM_WorkUser.createTestUser();

        PermissionSet permissionSet = ensurePermissionSet('Headcount_Hiring_Manager');

        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = newUser.Id;
        permissionSetAssignment.PermissionSetId = permissionSet.Id;
        insert permissionSetAssignment;

        //create the new headcount instance
        Headcount__c hc = null;
        System.runAs(newUser) {
            hc = new Headcount__c();
            hc.Hiring_Manager__c = newUser.Id;
            hc.Status__c = 'Open - New';
            hc.Effective_Date__c = 'FY12-Q1';
            insert hc;
        }

        //the context date must be within the quarter
        Date contextDate = Date.newInstance(2011, 02, 01);

        Boolean showRequestOfferButton = null;
        System.runAs(newUser) {
            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(hc);
            ADM_HeadcountDetailController controller = new ADM_HeadcountDetailController(stdController, contextDate);
            showRequestOfferButton = controller.getShowRequestOfferButton();
            Test.stopTest();
        }

        System.assert(!ApexPages.hasMessages(), 'Expected no errors to occur when displaying a position without a hiring manager');
        System.assertEquals(true, showRequestOfferButton, 'Expected to show the request offer button because the user is a hiring manager.');
    }

    private static PermissionSet ensurePermissionSet(String name) {

        List<PermissionSet> permissionSets = [select Id from PermissionSet where Name = :name];
        PermissionSet permissionSet = null;
        if(permissionSets.size() > 0) {
            permissionSet = permissionSets.get(0);
        } else {
            permissionSet = new PermissionSet();
            permissionSet.Name = name;
            permissionSet.Label = name;
            insert permissionSet;
        }

        return permissionSet;
    }
}