public with sharing class ADM_ProductTagTriggerTest {
    
    @IsTest
    public static ADM_Product_Tag__c setupProductTag() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Team__c = team.id;
        tag.Name = 'Test Name 123987675';
        return tag;
    }
    
    @IsTest
    public static ADM_Product_Tag__c setupRandomProductTag() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Team__c = team.id;
        tag.Name = 'Test Tag' + Math.random();
        return tag;
    }
    /*
    @testcasaID a1DB00000002fEu
    @usercaseID a07B0000000NoyiIAC
    @Hierarchy GUS.Product Tags.Detail Product tag
    @Expected Results Tag assignments can be removed when there is no associated to work
    @Author: James Hatton
    */
    
    static testMethod void testProductTagCanBeRemoved() {
    	ADM_Product_Tag__c p1 = setupRandomProductTag();
    	ADM_Product_Tag__c p2 = setupRandomProductTag();
    	List<ADM_Product_Tag__c> tagList = new List<ADM_Product_Tag__c>{p1, p2};
    	insert tagList;
    	Id idToBeRemoved = tagList.get(0).Id;
    	Set<ADM_Product_Tag__c> tagSet = new Set<ADM_Product_Tag__c>{p1, p2};
    	Set<ADM_Product_Tag__c> newTagSet = ADM_ProductTag.removeTagById(tagSet, idToBeRemoved);
    	System.assert(idToBeRemoved != null);
    	System.assertEquals(1, newTagSet.size());
    	for(ADM_Product_Tag__c p : newTagSet) {
    		System.assertNotEquals(idToBeRemoved, p.id);
    	}
    }
    
    /*
    @testcasaID a1DB00000001IPv
    @usercaseID a07B0000000FeoHIAS
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
    @Expected Results Create a new product tag and add Name, Team, Asgnmt Rule, and click on Use for Automated Tools checkbox
    @Author: James Hatton
    */

    static testMethod void testProductTagCanBeCreated() {
        ADM_Product_Tag__c tag = setupProductTag();     
        Database.insert(tag);
        System.assert(tag.id != null);
    }
    /*
    @testcasaID a1DB00000001ITE
    @usercaseID a07B0000000FeoHIAS
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
    @Expected Results Team is a mandatory field
    @Author: James Hatton
    */
    
    static testMethod void testProductTagTeamRequired() {
        ADM_Product_Tag__c tag = setupProductTag();     
        try {
            tag.Team__c = null;
            Database.insert(tag);
            System.assert(false, 'Test should have thrown a DML exception before it reached here');
        } catch (Exception e) { 
            System.assert(e.getMessage().contains('exception on row 0'), e.getMessage());
        }
    }
    
     /*
    @testcasaID a1DB00000002dNl
    @usercaseID a07B0000000OAMc
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Detail Product tag
    @Expected Results Each team can only have 1 tag with the Use For Automated Tools checkbox checked
    @Author: James Hatton
    */
    
    static testMethod void testEachTeamCanOnlyHaveOneTagUseAutomatedTools() {
        List<ADM_Product_Tag__c> tags = new List<ADM_Product_Tag__c>();
        ADM_Product_Tag__c tag = setupRandomProductTag();     
        tags.add(tag);
        
        ADM_Product_Tag__c tag2 = setupRandomProductTag(); 
        //make the default
        tag2.Use_for_Automated_Tools__c = true;    
        tag2.Team__c = tag.Team__c;
        tags.add(tag2);
        
        insert tags;
        
        //make a new default
        ADM_Product_Tag__c tag3 = setupRandomProductTag(); 
        tag3.Team__c = tag.Team__c;
        //make tag3 the new default
        tag3.Use_for_Automated_Tools__c = true;    
        insert tag3;
        
        //verfiy tag 2 has been deselected
        tag2 = [select id, Use_For_Automated_Tools__c from ADM_Product_Tag__c where id =:tag2.id];
        System.assertEquals(false, tag2.Use_For_Automated_Tools__c);
    }
    
     /*
    @testcasaID a1DB00000001IYR
    @usercaseID a07B0000000FeoHIAS
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.New Product tag
    @Expected Results Different teams can use the same tag name but the tag names must be unique within a single team.
    @Author: James Hatton
    */
    
    static testMethod void testProductTagKeyIsPopulated() {
        ADM_Product_Tag__c tag = setupProductTag();     
        Database.insert(tag);
        //retreive key
        tag = [select id, Name, Team__c, Team_Tag_Key__c from ADM_Product_Tag__c where id = :tag.id];
        System.assert(tag.id != null);
        System.assert(tag.Team_Tag_Key__c != null);
        String expectedKeyFormat = tag.Team__c + '@' + tag.Name;
        System.assertEquals(expectedKeyFormat, tag.Team_Tag_Key__c);
    }
    
     /*
    @testcasaID a1DB00000002dNq
    @usercaseID a07B0000000OAMc
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Detail Product tag
    @Expected Results A product tag cannot be deleted when it is associated to an assignment rule. An error is generated: "Product Tag cannot be deleted because it is used by Assignment Rules. Make sure the 		product tag is not assigned to any Assignment Rules before deleting."
    @Author: James Hatton
    */
    static testMethod void testProductTagCannotBeDeletedWhenAssociatedToAnAssignmentRule() {
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = ADM_WorkUser.createTestUser().Id;
        rule.Product_Owner__c = ADM_WorkUser.createTestUser().id;
        rule.Scrum_Team_Assignment__c = team.Id;
        insert rule;
        
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'tag' + Math.random();
        tag.Active__c = true;
        tag.Team__c = team.Id;
        insert tag;
        
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Product_Tag__c = tag.Id;
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
        
        try {
            delete tag;
            System.assert(false, 'Product Tag should not have been deleted because it is used by an assignment rule.');
        } catch(System.DMLException e) {
            System.assert(e.getMessage().contains('cannot') && e.getMessage().contains('deleted'), 'Product Tag should not have been deleted because it used by an assignment rule: ' + e.getMessage());
        }
    }
    
     /*
    @testcasaID a1DB00000002dNv
    @usercaseID a07B0000000OAMc
    @Hierarchy GUS.ScrumforceToGUS.Product Tags.Detail Product tag
    @Expected Results Tag assignments are removed when a product tag is deleted
    @Author: James Hatton
    */
    static testMethod void testFormerTagAssignmentsAreRemovedWhenProductTagMovesToANewTeam() {
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        ADM_Scrum_Team__c team2 = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = ADM_WorkUser.createTestUser().Id;
        rule.Product_Owner__c = ADM_WorkUser.createTestUser().id;
        rule.Scrum_Team_Assignment__c = team.Id;
        insert rule;
        
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'tag' + Math.random();
        tag.Active__c = true;
        tag.Team__c = team.Id;
        insert tag;
        
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Product_Tag__c = tag.Id;
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Record_Type__c = ADM_Work.BUG_RECORD_TYPE_NAME;
        insert tagAssignment;
        Id formerTagAssignmentID = tagAssignment.id;
        System.assert(formerTagAssignmentID != null);
        
        Test.startTest();
        //now move the tag to a new team and verfiy tag Assignment is deleted
        tag.Team__c = team2.id;
        update tag;
        //tag assignments are removed async so we need to call stop test to ensure the method has completed
        Test.stopTest();
        List<ADM_Tag_Assignment__c> productTagAssignments = [select id from ADM_Tag_Assignment__c where Product_Tag__c =: tag.id];
        //list should be empty
        System.assert(productTagAssignments == null || productTagAssignments.size() == 0, ' Did not expect to find any tag assignments but found:' + productTagAssignments);
        //verify the tag assignments were really deleted (and did not just have the Product Tag field set to null) by explicity checking for a former id
        productTagAssignments =  [select id, Product_Tag__c from ADM_Tag_Assignment__c where id =: formerTagAssignmentID];
        System.assert(productTagAssignments == null || productTagAssignments.size() == 0, ' Did not expect to find any tag assignments but found:' + productTagAssignments);
        
    }
    
    /*
    @testcasaID a1DB00000002fEu
    @usercaseID a07B0000000NoyiIAC
    @Hierarchy GUS.Product Tags.Detail Product tag
    @Expected Results Tag assignments cannot be removed when associated to work
    @Author: James Hatton
    */
    static testMethod void testProductTagCannotBeDeletedWhenAssociatedToWork() {
    	ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'tag' + Math.random();
        tag.Active__c = true;
        tag.Team__c = team.Id;
        insert tag;
        
        ADM_Work__c work = ADM_Work.createTestBug();
        work.Product_Tag__c = tag.Id;
        upsert work;
        
        try {
            delete tag;
            System.assert(false, 'Product Tag should not have been deleted because it is used by a work record.');
        } catch(System.DMLException e) {
//            System.assert(e.getMessage().contains('Delete failed') && e.getMessage().contains('can\'t be deleted'), 'Product Tag should not have been deleted because it used by a work rule: ' + e.getMessage());
        }
    }

    @isTest
    static void testDeletingAProductTagWithAnAssigmentRule() {

        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        Id userStoryId = ADM_RecordType.getId('User Story');
        RecordType userStoryRecordType = ADM_RecordType.getById( userStoryId );

        Id bugId = ADM_RecordType.getId('Bug');
        RecordType bugRecordType = ADM_RecordType.getById( bugId );

        ADM_Product_Tag__c tag = new ADM_Product_Tag__c();
        tag.Name = 'tag' + Math.random();
        tag.Active__c = true;
        tag.Team__c = team.Id;
        insert tag;

        ADM_Tag_Assignment__c assignment1 = ADM_TagAssignment.createAndInsertTagAssignment( tag , userStoryRecordType );
        ADM_Tag_Assignment__c assignment2 = ADM_TagAssignment.createAndInsertTagAssignment( tag , bugRecordType );

        try {
           delete tag;
           System.assert(false, 'Deleting a product tag with an assignment association is not allowed');
        } catch ( Exception e ){
            System.assert( e.getMessage().contains('Product Tag cannot be deleted because it is used by Assignment Rules'));
        }

    }

    @IsTest
    public static void testDeletingProductTagDeletedAssociatedAdditionalFields() {
        ADM_Product_Tag__c p1 = setupRandomProductTag();
        insert p1;
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        af.Name = 'Environment';
        af.Field_API_Name__c = 'Environment__c';
        af.Product_Tag__c = p1.id;
        af.Bug_Setting__c = 'Visible';
        insert af; 
        Test.startTest();
        delete p1;
        Test.stopTest();
        List<ADM_Additional_Field__c> additionalFieldList = [select id from ADM_Additional_Field__c where Product_Tag__c =: p1.id];
        System.assertEquals(additionalFieldList.size(),0);
        List<ADM_Additional_Field__c> additionalFields = [select id from ADM_Additional_Field__c where id =: af.id];
        System.assertEquals(additionalFields.size(),0);
        
    }



}