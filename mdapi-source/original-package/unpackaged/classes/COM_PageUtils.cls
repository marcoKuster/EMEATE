public with sharing class COM_PageUtils {
	
	public static void addErrorMessageToPage(Exception ex){
		addMessageToPage(ApexPages.Severity.Error, ex.getMessage());
	}
	
	
	public static void addMessageToPage(ApexPages.Severity level, String message){
		ApexPages.Message pageMessage = new ApexPages.Message(level, message);
        ApexPages.addMessage(pageMessage);
	}

}