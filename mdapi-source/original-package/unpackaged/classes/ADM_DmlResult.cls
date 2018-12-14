global with sharing class ADM_DmlResult {
	public String id { get; set; }
	public Boolean success { get; set; }
	public String error { get; set; }
	public ADM_Work__c work { get; set; }
	public List<ADM_Work__c> backlog { get; set; }
	public List<ADM_Work__c> backburner { get; set; }
	public Boolean hasMore { get; set; } 
	
	public ADM_DmlResult(String id, Boolean success) {
		this.id = id;
		this.success = success;
	}
	
	public static ADM_DmlResult createFromSaveResult(Database.SaveResult saveResult) {
		ADM_DmlResult result = new ADM_DmlResult(saveResult.getId(), saveResult.isSuccess());
            
        if(!saveResult.isSuccess()) {
            String errors = '';
            
            for(Database.Error error : saveResult.getErrors()) {
                errors += error.getMessage().trim() + ',';  
            }
            
            errors = ADM_TextUtils.removeTrailingComma(errors);
            result.error = errors;
        }
        
        return result;
	}
}