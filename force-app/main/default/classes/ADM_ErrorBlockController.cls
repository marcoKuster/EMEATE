public with sharing class ADM_ErrorBlockController {
	private transient List<String> errorMessages;
	
    public List<String> getErrorMessages() {
    	if(errorMessages == null) {
    		errorMessages = new List<String>();
    		for(ApexPages.Message message : ApexPages.getMessages()) {
    			errorMessages.add(message.getSummary());
    		}
    	}
    	return errorMessages;
    }
    
    public String getErrorMessagesAsJSON() {
    	return JSON.serialize(getErrorMessages());
    }
    
}