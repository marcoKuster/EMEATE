public with sharing class ADM_errorUtils {
	public String requiredFieldMessage = ' is a required field.';
    public List<String> errorMessages { 
        get {
            if(errorMessages == null) errorMessages = new List<String>();
            return errorMessages;
        }
        set;
    }    
    
    public String getErrorMessage(System.DmlException e) {
        String errorMessage = '';
        for (Integer i = 0; i < e.getNumDml(); i++) {
            errorMessage += e.getDmlMessage(i);                                                           
        }
        return errorMessage;
    }
    
    public Apexpages.Message getApexpagesMessage(String message, System.Dmlexception e) {
    	return new ApexPages.message(ApexPages.severity.ERROR, message + ': ' + getErrorMessage(e));
    }
    
    public Apexpages.Message getApexpagesMessage(String message) {
        return new ApexPages.message(ApexPages.severity.ERROR, message);
    }
}