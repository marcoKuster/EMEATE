@isTest
private class ADM_KanbanSplashControllerTest {
    
    static testMethod void testPageLoadWithAValidTeamId() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(); 
        ApexPages.currentPage().getParameters().put('teamId', team.Id);       
        ADM_KanbanSplashController splash_controller = new ADM_KanbanSplashController();
        System.assertEquals( splash_controller.team.Name, team.Name);

    }    

    static testMethod void testPageLoadWithNoTeamId() {
        try { 
            new ADM_KanbanSplashController();
            String message  = 'Instantiating ADM_KanbanSplashController without a '
                            + 'team Id should throw an Exception';
            System.assert( false, message );
        } catch ( ADM_ApplicationException applicationException ){
            System.assertEquals( applicationException.getMessage(),
                 'Team must be specified on the URL using teamId' );
        }
    }   
    
    static testMethod void testPageLoadWithAnInValidTeamId() {

        String invalidTeamID = 'Bogus_Team_ID';
        ApexPages.currentPage().getParameters().put('teamId', invalidTeamID);       
        try {
            new ADM_KanbanSplashController();
            String message  = 'Instantiating ADM_KanbanSplashController with an '
                            + 'invalid Team ID should throw an StringException ';
            System.assert( false, message );
        } catch ( StringException stringException ){
            System.assert( stringException.getMessage().contains('Invalid id'));
        }
    }   
    
    static testMethod void testUserIsRedirectedtoKanbanBoardIfOneAlreadyExists() {

        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(); 
        //Enable Kanban for the team
        team.Kanban__c = true;
        update team;
        ApexPages.currentPage().getParameters().put('teamId', team.Id);
        PageReference page = new ADM_KanbanSplashController().goToCurrentKanbanBoard();
        System.assertNotEquals( null, page, 'The page reference should be non null' );
        System.assertEquals(team.Id, page.getParameters().get('teamId'));
        System.assert( page.getUrl().contains('kanban'));
    }  
    
    static testMethod void testUserRemainsOnSplashScreenIfNoKanbanBoardExists() {
    
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(); 
        // Even though the default team setting for Kanban is false, let's confirm
        team.Kanban__c = false;
        update team;
        ApexPages.currentPage().getParameters().put('teamId', team.Id);       
        PageReference page = new ADM_KanbanSplashController().goToCurrentKanbanBoard();
        System.assertEquals( null, page, 'The page reference should be null' );

    }   
}