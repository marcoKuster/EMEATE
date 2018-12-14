public with sharing class ADM_WorkSetController {
    public List<ADM_Work__c> selected { get; set; }
    public List<ADM_Work__c> selectedWorks { get; set; }
    public List<notecardWrapper> notecards { get; set; }
    public notecardWrapper notecard { get; set; }

    public ADM_WorkSetController(ApexPages.StandardSetController controller) {
        if(selected == null) {
            if(controller.getSelected().isEmpty()) {                
                selected = new List<ADM_Work__c>();                  
                String workIds = System.currentPageReference().getParameters().get('workIds');
                if(workIds != null) {
	                for(String workId : workIds.split(',')) {
	                    if(workId == '') continue;
	                    selected.add(new ADM_Work__c(Id = workId));
	                }                     
                }   
            } else {
               selected = (List<ADM_Work__c>) controller.getSelected();
            }
            
            notecards = new List<notecardWrapper>();
            
            if(!selected.isEmpty()) {
	            for(ADM_Work__c work : [select Id, Story_Points__c, Description__c, Subject__c, Name, User_Type__c, Priority_Rank__c, RecordType.Name from ADM_Work__c where Id in : selected]) {
	                notecard = new notecardWrapper(work);
	                notecards.add(notecard);        
	            }
            }
        }
        
        if(selected.isEmpty()) Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO,'No work records were selected.'));
    }
    
    public class notecardWrapper{
        public ADM_Work__c work { get; set; }
        public String text { get; set; }
        public notecardWrapper(ADM_Work__c w) {
            work = w;
            text = w.Subject__c;
        }
    } 
}