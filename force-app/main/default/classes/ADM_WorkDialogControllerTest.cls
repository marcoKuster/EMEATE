@isTest
public Class ADM_WorkDialogControllerTest{

    static testMethod void saveWorkByValidEpicId() {

        ADM_Epic__c test_epic = ADM_Epic.createTestEpic();
        ADM_Work__c test_bug = ADM_Work.createTestBug();

        // I have to cast the Work object as an SObject to bypass the ID validation of the Epic field
        SObject test_bug_SObject = (SObject)test_bug;
        test_bug_SObject.put('Epic__c',test_epic.Id);

        // Cast it back to an ADM_Work__c so it will update appropriately
        ADM_WorkDialogController.saveWork( (ADM_Work__c)test_bug_SObject , true , 'Bug' );

        // Now fetch the orignal record of ADM_Work__c type
        ADM_Work__c revised_test_bug = ADM_Work.getById( test_bug.Id );
        System.assert( revised_test_bug.Epic__c == test_epic.Id );
    }

    static testMethod void saveWorkByValidEpicName() {

        ADM_Epic__c test_epic = ADM_Epic.createTestEpic();
        ADM_Work__c test_bug = ADM_Work.createTestBug();

        // I have to cast the Work object as an SObject to bypass the ID validation of the Epic field
        SObject test_bug_SObject = (SObject)test_bug;
        test_bug_SObject.put('Epic__c',test_epic.Name);

        // Cast it back to an ADM_Work__c so it will update appropriately
        ADM_WorkDialogController.saveWork( (ADM_Work__c)test_bug_SObject , true , 'Bug' );

        // Now fetch the orignal record of ADM_Work__c type
        ADM_Work__c revised_test_bug = ADM_Work.getById( test_bug.Id );
        System.assert( revised_test_bug.Epic__c == test_epic.Id );


    }

    static testMethod void saveWorkWithBogusEpicThrowsError() {

        ADM_Epic__c test_epic = ADM_Epic.createTestEpic();
        ADM_Work__c test_bug = ADM_Work.createTestBug();

        SObject test_bug_SObject = (SObject)test_bug;
        test_bug_SObject.put('Epic__c', 'BOGUS-EPIC-NAME');

        try {
            ADM_WorkDialogController.saveWork( (ADM_Work__c)test_bug_SObject , true , 'Bug' );
            // This statement should never be reached
            System.assert(false,'Saving with a bogus name should throw an error');
        } catch ( Exception swe ){
            /**  No op on successufl catch */
        }
    }

    static testMethod void testGetBaseUrl() {
        System.assertNotEquals(null, ADM_WorkDialogController.getBaseUrl(), ' Expected getBaseUrl method to return Salesforce base url ');
    }

    static testMethod void testGetWorkEditorDialogMetaData() {
        ADM_Work__c testStory = ADM_Work.createTestWork('User Story');
        ADM_Scrum_Team__c testTeam = ADM_ScrumTeam.createTestScrumTeam('Yo Gabba Gabba');
        ADM_Work.WorkEditorDialogMetaData weMetaData = ADM_WorkDialogController.getWorkEditorDialogMetaData(testStory.Id, testTeam.Id);
        System.assertNotEquals(null, weMetaData.workSObject, ' Expected workSObject to be not null');
        System.assertEquals(testStory.Id, weMetaData.workSObject.Id, ' Expected workSObject id to match with test User story');
        System.assertNotEquals(null, weMetaData.storyPoints, ' Expected storyPoints list to be not null ');
    }

    static testMethod void testGetProductTagAutoAssignees() {
        //create the assignment rule
        ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();

        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        String pTagId = productTag.Id;
         //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
        insert tagAssignment;


        String severityLevel = '3';

        ADM_WorkAssignment.AssignmentContext context = ADM_WorkDialogController.getProductTagAutoAssignees(severityLevel, pTagId, 'Investigation');
        System.assertNotEquals(null, context.assignments, 'Expected assignments to be not null');

        System.assertNotEquals(null, context.assignments.Assignee, 'Expected Assignee to be not null');
        System.assertNotEquals(null, context.assignments.QA_Engineer, 'Expected QA_Engineer to be not null');

    }
}