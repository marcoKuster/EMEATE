public with sharing class ADM_KanbanSplashController {

    public ADM_Scrum_Team__c team { get; set; }
    
    public ADM_KanbanSplashController() {
        //pull current team id off the URL
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        if(parameters.containsKey('teamId')) {
            Id selectedTeamId = (Id)parameters.get('teamId');
            List<ADM_Scrum_Team__c> teams = [select Id, Name, Kanban__c from ADM_Scrum_Team__c where Id = :selectedTeamId];
            if(null != teams && teams.size() > 0){
                this.team = teams[0];
            }
        } else {
            //Not 100% certain we can assume the logged in user is activating the board for a team they belong too.  So if the teamId is invalid or missing complain
            throw new ADM_ApplicationException('Team must be specified on the URL using teamId');
        }
        
    }
    
    public PageReference createKanbanBoard() {
        System.debug('inside create kanban board:' + team);
        team.Kanban__c = true;
        //turn on kanban - this will cause the team trigger to create default columns
        update team;
        //redirect to Kanban Board
		PageReference pr = Page.ADM_Kanban;        
        pr.getParameters().put('teamid', team.id);
        System.debug('returning page reference:' + pr);
        return pr;
        
    } 
    
    public PageReference goToCurrentKanbanBoard() {
        // go to the kanban board if it exists or the activation screen if it doesn't
        if(team.Kanban__c) {
            System.debug('current team already has a kanban board:' + team);
            PageReference pr = Page.ADM_Kanban;
            pr.getParameters().put('teamid', team.id);
            return pr;
        } else {
            System.debug('current team DOES NOT have a kanban board:' + team);
            /*PageReference pr = Page.ADM_KanbanSplash;
            pr.getParameters().put('teamid', team.id);
            return pr;*/
            return null;
        }        
                
    } 

    
    

}