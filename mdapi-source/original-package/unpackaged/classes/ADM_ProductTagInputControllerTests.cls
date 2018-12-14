@IsTest
public with sharing class ADM_ProductTagInputControllerTests {
    
    /*
    @testcaseID a1DB00000001Sm5
    @userstory a07B0000000FeoR
    @Expected Results A user is able to create a bug using an existing product tag
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
    */
    /**
     * Given a valid record type, the controller should return all available
     * product tags. 
     * @author jared.pearson@
     */
    public static testMethod void testGetTags() {
        RecordType recordType = [select id,Name from RecordType where Name =:ADM_Work.BUG_RECORD_TYPE_NAME];
        
        //create at least one product tag to test with
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = recordType.Name;
        insert tagAssignment;
        
        //get the list of all active product tags
        List<ADM_Product_Tag__c> productTags = [select Id, Name, Team__r.Name from ADM_Product_Tag__c where Active__c = true and Team__r.Active__c = true and Id in (select Product_Tag__c from ADM_Tag_Assignment__c where Record_Type__c = :recordType.Name)];
        Map<String, ADM_Product_Tag__c> tagsById = mapProductTagsById(productTags);
        
        //execute the controller code
        List<ADM_Product_Tag__c> actualProductTags = ADM_ProductTagInputController.getTags(recordType.Name, null);
        
        //verify that the tagModels contains the same amount
        System.assertEquals(productTags.size(), actualProductTags.size(), 'tagModels should return all active product tags');
        
        //verify that the model is returning values correctly
        for(ADM_Product_Tag__c tag : actualProductTags) {
            System.assert(tagsById.containsKey(tag.Id));
            ADM_Product_Tag__c expectedTag = tagsById.get(tag.Id);
            System.assertEquals(expectedTag.Id, tag.id);
            System.assertEquals(expectedTag.Name, tag.Name);
            System.assertEquals(expectedTag.Team__r.Name, tag.Team__r.Name);
        }
        
    }
    
    /*
    @testcaseID a1DB00000001Sm5
    @userstory a07B0000000FeoR
    @Expected Results A user is able to create a bug using an existing product tag
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
    */  
    /**
     * Given a valid record type, the controller should return all available
     * product tags. 
     * @author jared.pearson@
     */
    public static testMethod void testGetTagsWithId() {
        RecordType recordType = [select id,Name from RecordType where Name =:ADM_Work.BUG_RECORD_TYPE_NAME];
        
        //create one product tag with an assignment rule
        ADM_Product_Tag__c productTag1 = ADM_ProductTag.createAndInsertProductTag();
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag1.Id;
        tagAssignment.Record_Type__c = recordType.Name;
        insert tagAssignment;
        
        //create a product tag that is not active and no assignment rules
        ADM_Product_Tag__c productTag2 = new ADM_Product_Tag__c();
        productTag2.Name = 'inactiveTag' + Math.random();
        productTag2.Active__c = false;
        productTag2.Team__c = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName().Id; 
        insert productTag2;
        productTag2 = [select Id, Name, Team__r.Name from ADM_Product_Tag__c where Id = :productTag2.Id];
        
        //get the map of all active product tags
        List<ADM_Product_Tag__c> productTags = [select Id, Name, Team__r.Name from ADM_Product_Tag__c where Active__c = true and Id in (select Product_Tag__c from ADM_Tag_Assignment__c where Record_Type__c = :recordType.Name)];
        Map<String, ADM_Product_Tag__c> tagsById = mapProductTagsById(productTags);
        
        //add the single product tag to the map
        tagsById.put(productTag2.Id, productTag2);
        
        //execute the controller code
        Test.startTest();
        List<ADM_Product_Tag__c> actualProductTags = ADM_ProductTagInputController.getTags(recordType.Name, productTag2.Id);
        Test.stopTest();
        
        //verify that the model is returning values correctly
        for(ADM_Product_Tag__c tag : actualProductTags) {
            System.assert(tagsById.containsKey(tag.Id));
            ADM_Product_Tag__c expectedTag = tagsById.get(tag.Id);
            System.assertEquals(expectedTag.Id, tag.id);
            System.assertEquals(expectedTag.Name, tag.Name);
            System.assertEquals(expectedTag.Team__r.Name, tag.Team__r.Name);
        }
        
        //verify that the list from getTags() contains the one with the ID
        System.assert(ADM_ProductTag.contains(actualProductTags, productTag2.Id), 'getTags() should return the tag with the specified ID');
    }
    
	/*
	@testcaseID a1DB00000002In1
	@userstory a07B0000000MRkLIAW
	@Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
	@Expected results Product tag is not available for use because it belongs to an inactive team
	*/
    /**
     * Product Tags belonging to an inactive team should Not be displayed
     * @author jhatton@
     */
    public static testMethod void testTagsBelongingToInactiveTeamsAreNotDisplayed() {
        RecordType recordType = [select id,Name from RecordType where Name =:ADM_Work.BUG_RECORD_TYPE_NAME];
        
        //create one product tag with an assignment rule
        ADM_Product_Tag__c productTag1 = ADM_ProductTag.createAndInsertProductTag();
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag1.Id;
        tagAssignment.Record_Type__c = recordType.Name;
        insert tagAssignment;
        
        ADM_Scrum_Team__c inactiveTeam = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        inactiveTeam.Active__c = false;
        update inactiveTeam;
        
        //create a product tag that is assigned to inactive team
        ADM_Product_Tag__c productTag2 = new ADM_Product_Tag__c();
        productTag2.Name = 'inactiveTag' + Math.random();
        productTag2.Active__c = true;
        productTag2.Team__c = inactiveTeam.Id;
        insert productTag2;
        productTag2 = [select Id, Name, Team__r.Name from ADM_Product_Tag__c where Id = :productTag2.Id];
        ADM_Tag_Assignment__c tagAssignment2 = new ADM_Tag_Assignment__c();
        tagAssignment2.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment2.Product_Tag__c = productTag2.Id;
        tagAssignment2.Record_Type__c = recordType.Name;
        insert tagAssignment2;
        
       
        
        //execute the controller code
        Test.startTest();
        List<ADM_Product_Tag__c> actualProductTags = ADM_ProductTagInputController.getTags(recordType.Name, null);
        Test.stopTest();
        
        //verify that the model returned the tag belonging to the active team and did not return the one belonging to the inactive team
        Boolean foundTagBelongingToActiveTeam = false;
        Boolean foundTagBelongingToInActiveTeam = false;
        
        for(ADM_Product_Tag__c tag : actualProductTags) {
            if(tag.Id == productTag1.Id) {
            	foundTagBelongingToActiveTeam = true;
            }
            
            if(tag.Id == productTag2.Id) {
            	foundTagBelongingToInActiveTeam = true;
            }
        }
        
        System.assertEquals(true, foundTagBelongingToActiveTeam, 'Did not find the active Product Tag belonging to the Active Team with a valid Tag Assignment');
        System.assertEquals(false, foundTagBelongingToInActiveTeam, 'Product Tag belonging to INACTIVE Team was returned');
    }
    
    /*
    @testcaseID a1DB00000001SpD
    @userstory a07B0000000FeoR
    @Expected Results Product tags are visible from the Bug product tags for a specific team
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Product Tags.Work Page
    */
    
    /**
     * Given a template record type, the controller should return all available
     * product tags for the bug record type.
     * @author jared.pearson@
     */
    public static testMethod void testGetBugTagsForTemplate() {
        RecordType templateRecordType = [select id,Name from RecordType where Name =:ADM_Work.TEMPLATE_RECORD_TYPE_NAME];
        RecordType bugRecordType = [select id,Name from RecordType where Name =:ADM_Work.BUG_RECORD_TYPE_NAME];
        
        //create at least one product tag to test with
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = bugRecordType.Name;
        insert tagAssignment;
        
        //get the list of all active product tags
        List<ADM_Product_Tag__c> productTags = [select Id, Name, Team__r.Name from ADM_Product_Tag__c where Active__c = true and Team__r.Active__c = true and Id in (select Product_Tag__c from ADM_Tag_Assignment__c where Record_Type__c = :bugRecordType.Name)];
        Map<String, ADM_Product_Tag__c> tagsById = mapProductTagsById(productTags);
        
        //execute the controller code
        List<ADM_Product_Tag__c> actualProductTags = ADM_ProductTagInputController.getTags(templateRecordType.Name, null);
        
        //verify that the tagModels contains the same amount
        System.assertEquals(productTags.size(), actualProductTags.size(), 'tagModels should return all active product tags');
        
        //verify that the model is returning values correctly
        for(ADM_Product_Tag__c tag : actualProductTags) {
            System.assert(tagsById.containsKey(tag.Id));
            ADM_Product_Tag__c expectedTag = tagsById.get(tag.Id);
            System.assertEquals(expectedTag.Id, tag.id);
            System.assertEquals(expectedTag.Name, tag.Name);
            System.assertEquals(expectedTag.Team__r.Name, tag.Team__r.Name);
        }
        
    }
    
    /**
     * Given a user with a configured preference to show the guided tour, the showGuidedTour
     * property should match.
     * @author jared.pearson
     * @testcaseID a1DB00000002IPVMA2
     * @hierarchy GUS.ScrumforceToGUS.Product Tags.Guided Tour
     * @userstory a07B0000000MKesIAG
     * @expectedResults The guided tour should be displayed.
     */



    static testMethod void testShowGuidedTourWithTruePreference() {
        User user1 = createTestUser();
        System.runAs(user1){ 
            
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowProductTagGuidedTour__c = true;
            upsert preferences;
            
            ADM_ProductTagInputController controller = new ADM_ProductTagInputController();
            
            System.assertEquals(true, controller.getShowGuidedTour(), 'Expected the showGuidedTour property to match that of the User Preference');
        }
    }  


    
    /**
     * Given a user with a configured preference to hide the guided tour, the showGuidedTour
     * property should match.
     * @author jared.pearson
     */
   

 static testMethod void testShowGuidedTourWithFalsePreference() {
        User user1 = createTestUser();
        System.runAs(user1){
            
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowProductTagGuidedTour__c = false;
            upsert preferences;
            
            ADM_ProductTagInputController controller = new ADM_ProductTagInputController();
            
            System.assertEquals(false, controller.getShowGuidedTour(), 'Expected the showGuidedTour property to match that of the User Preference');
        }
    }

    
    /**
     * When the never show guided tour method is invoked, the getShowGuidedTour should return false.
     * @author jared.pearson
     * @testcaseID a1DB00000002IPWMA2
     * @hierarchy GUS.ScrumforceToGUS.Product Tags.Guided Tour
     * @userstory a07B0000000MKesIAG
     * @expectedResults After closing the guided tour, the guided tour should not display again.
     */
    



    static testMethod void testNeverShowGuidedTour() {
        User user1 = createTestUser();
        System.runAs(user1){
            
            //create a user preference to show the tour
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowProductTagGuidedTour__c = true;
            upsert preferences;
            
            //call the method to never show the preference
            ADM_ProductTagInputController.neverShowGuidedTour();
            
            //check to make sure the value is false
            ADM_ProductTagInputController controller = new ADM_ProductTagInputController();
            System.assertEquals(false, controller.getShowGuidedTour(), 'Expected the neverShowGuidedTour to change the showGuidedTour property to false');
            
            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowProductTagGuidedTour__c, 'Expected neverShowGuidedTour to change the User Preference');
        }
    } 
        
    /**
     * Given a list of product tags, create a map of product tags keyed with ID.
     */
    private static Map<String, ADM_Product_Tag__c> mapProductTagsById(List<ADM_Product_Tag__c> productTags) {
        Map<String, ADM_Product_Tag__c> tagsById = new Map<String, ADM_Product_Tag__c>();
        for(ADM_Product_Tag__c tag : productTags) {
            tagsById.put(tag.Id, tag);
        }
        return tagsById;
    }
    
    private static User createTestUser() {
        User u = ADM_WorkUser.createTestUserWithRandomName();
        u = [select Id, Name, Email from User where Id=:u.Id limit 1];
        return u;
    } 
}