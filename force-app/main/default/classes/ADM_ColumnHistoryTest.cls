@isTest
public with sharing class ADM_ColumnHistoryTest {

    static testMethod void testColumnHistoryIsNullAfterUpdatingProductTag() {

        // Create a test team and make sure kanban is enabled
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;

        // Create a test user story 
        ADM_Work__c story = ADM_Work.createTestWork('User Story');

        // Grab a Kanban column and update the story with a column
        List<ADM_Column__c> columns = [select id, Name from ADM_Column__c where Team__c =:team.id];
        ADM_Column__c column1 = columns[2];
        story.Column__c = column1.id;
        String column_id = column1.id;
        update story;

        // Kanban column should be non null
        System.assert( story.Column__c  != null );

        List<String> workIds = new List<String> { story.Id };
        List<ADM_Column_History__c> column_history = ADM_ColumnHistory.getColumnHistoryRecordsForListOfWorkIds( workIds );
        
        System.assert( column_history.size() == 1 , 'There are no column history entries');
        for ( ADM_Column_History__c history : column_history ){
            System.assert( history.Time_Entered__c != null, 'The time entered field for the history column was not populated.');
            System.assert( history.Time_Left__c == null , 'The time left field for the history column populated, but supposed to be null.');
            System.assert( history.Column__c != null , 'The column ID field for the history column was not populated.');            
        }

        // Now let's reassign to a different team, by updating the product tag
        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
        story.Product_Tag__c = productTag.Id;
        update story;

        List<ADM_Column_History__c> column_history_after_update = ADM_ColumnHistory.getColumnHistoryRecordsForListOfWorkIds( workIds );

        System.assert( column_history_after_update.size() == 1 , 'There are no column history entries');
        for ( ADM_Column_History__c history : column_history_after_update ){
            System.assert( history.Time_Left__c != null, 'The time left field for the history column was populated, but supposed to be null.');
        }

        // Retrive the the work item from the data 
        List<ADM_Work__c> story_list = [select id, Name,Column__c from ADM_Work__c where Id =:story.id];

        System.assertEquals( null, story_list[0].Column__c, ' The work items kanban column was not set '
                            + ' to null after changing the work item\'s product tag' );
                
    }

    static testMethod void testItemsCreatedOnKanbanBoardHaveAHistoryColumn() {
           
        // Create a test team and make sure kanban is enabled
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        team.Kanban__c = true;
        update team;
        
        // Grab the newly created columns
        List<ADM_Column__c> columns = [select id, Name from ADM_Column__c where Team__c =:team.id];
        System.assert( columns.size() > 0 );
        
        
        // Create a story object, but don't insert until we add a column to it
        ADM_Work__c story = ADM_Work.setupTestWork('User Story');        
        story.Column__c = columns.get(0).Id;
        insert story;
        List<Id> lists = new List<Id>();
        lists.add(story.Id);
        
        // Query and assert
        List<ADM_Column_History__c> columnHistoryRecords = ADM_ColumnHistory.getColumnHistoryRecordsForListOfWorkIds(lists);
        System.assertEquals( 1 , columnHistoryRecords.size() );
        
    }

}