public class ADM_WorkPrioritizerController {
    
    
    public ADM_WorkPrioritizerController() {}
    
    public PageReference goToNewVersion() {
    	return new PageReference('/apex/ADM_Prior3?scrumteamId=' + System.currentPageReference().getParameters().get('scrumteamId')); 
    }
    
    
}