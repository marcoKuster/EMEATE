@isTest
private class ADM_ProductTagControllerTests {
    
    /*
    @testcaseID a1DB00000001X2z
    @userstory a07B0000000Ln8NIAS
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Edit Product tag
    @Expected results An error occurs: "Whoa, this Product Tag is currently used on 776 Work records. Are you sure the new name, "test," is applicable to all of these records?"
    */
    /**
     * Tests that isUsedOnWorkRecords method making sure it returns false if the Product Tag is not used
     * on any work records, and returns true if it is used on 1 or more work records.
     * @author ccopek
     **/
    static testMethod void testIsUsedOnWorkRecordsIndicator() {
        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Team__c = rule.Scrum_Team_Assignment__c;
        tag.Name = 'Test Name 123987675';
        Database.insert(tag);
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Product_Tag__c = tag.Id;
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Record_Type__c = 'Bug';
        Database.insert(tagAssignment);
        
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(tag);
        ADM_ProductTagController controller = new ADM_ProductTagController(sc);
        System.assert(controller.getNumberWorkRecordsWithProductTag() == 0);
        
        // Now add a work record that uses the Product Tag and make sure the method returns true.
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        work.Product_Tag__c = tag.Id;
        Test.startTest();
        //now insert
        insert work;
        Test.stopTest();
        
        controller = new ADM_ProductTagController(sc);
        System.assert(controller.getNumberWorkRecordsWithProductTag() == 1);
    }
    /*
    @testcaseID a1DB00000001X30
    @userstory a07B0000000Ln8NIAS
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Edit Product tag
    @Expected results User gets error message that the value they are trying to save is a duplicate
    */
    /**
     * Verify the saveTag method is properly formatting the duplicate tag message
     * @author ccopek
     **/
    static testMethod void testDuplicateTagErrorMessage() {
        ADM_Assignment_Rule__c rule = ADM_AssignmentRuleTest.setupRule();
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Team__c = rule.Scrum_Team_Assignment__c;
        tag.Name = 'Test Name 123987675';
        Database.insert(tag);
        
        ADM_Product_Tag__c tag2 = new ADM_Product_Tag__c();
        tag2.Team__c = tag.Team__c;
        tag2.Name = tag.Name;
        
        //create team membership
        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c();
        member.Member_Name__c = UserInfo.getUserId();
        member.Allocation__c = 0;
        member.Scrum_Team__c = tag.Team__c;
        insert member;
        
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(tag2);
        ADM_ProductTagController controller = new ADM_ProductTagController(sc);
        // Try doing a save from the controller.  It will try to save another tag and should fail
        // since a save was already done on that same tag.
        PageReference pr = controller.saveTag();
        System.assert(pr == null);
        System.assert(ApexPages.getMessages().size() > 0);
        // Make sure message contains some of the formatted duplicate value message.
        System.assert(ApexPages.getMessages().get(0).getDetail().contains('Duplicate value'), 'Expected duplicate error instead recived:' + ApexPages.getMessages().get(0).getDetail());
    }
    
    /*
    @testcaseID a1DB00000002In2
    @userstory a07B0000000MRkLIAW
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
    @Expected results The following message appears: You cannot create a Product Tag for an inactive team
    */
    /**
     * Verify the Tags can't be created for inactive Teams
     * @author jhatton
     **/
    static testMethod void testTagsCannotBeCreatedForInactiveTeams() {
        ADM_Scrum_Team__c inactiveTeam = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        inactiveTeam.Active__c = false;
        update inactiveTeam;
        
        //create a product tag that is assigned to inactive team
        ADM_Product_Tag__c productTag2 = new ADM_Product_Tag__c();
        productTag2.Name = 'activeTag' + Math.random();
        productTag2.Active__c = true;
        productTag2.Team__c = inactiveTeam.Id;
        
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(productTag2);
        ADM_ProductTagController controller = new ADM_ProductTagController(sc);
        // Try doing a save from the controller.  
        PageReference pr = controller.saveTag();
        System.assert(pr == null);
        System.assert(ApexPages.getMessages().size() > 0);
        // Make sure message contains some of the formatted duplicate value message.
        System.assert(ApexPages.getMessages().get(0).getDetail().contains('You cannot create or edit a Product Tag for an inactive team'));
    }
    
    /*
    @testcaseID a1DB00000002In6
    @userstory a07B0000000MRkLIAW
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
    @Expected results Users that belong to the team can create tags for that team
    */
     /**
     * Verify the Tags can be created for active Teams
     * @author jhatton
     **/
    static testMethod void testTagsCanBeCreatedForActiveTeams() {
        ADM_Scrum_Team__c activeTeam = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        //create a product tag that is assigned to inactive team
        ADM_Product_Tag__c productTag2 = new ADM_Product_Tag__c();
        productTag2.Name = 'activeTag' + Math.random();
        productTag2.Active__c = true;
        productTag2.Team__c = activeTeam.Id;
        
        //create team membership
        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c();
        member.Member_Name__c = UserInfo.getUserId();
        member.Allocation__c = 0;
        member.Scrum_Team__c = productTag2.Team__c;
        insert member;
        
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(productTag2);
        ADM_ProductTagController controller = new ADM_ProductTagController(sc);
        // Try doing a save from the controller.  
        PageReference pr = controller.saveTag();
        System.assert(pr != null);
        System.assert(pr.getUrl().contains(productTag2.id));
        System.assert(ApexPages.getMessages().size() == 0);
        
    }

}