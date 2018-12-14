global with sharing class ADM_ThemeAggregatorController {
    public ADM_StringHolder soslHolder {get; set;}
    
    public ADM_ThemeAggregatorController() {
        soslHolder = new ADM_StringHolder();
        soslHolder.theString = '.';
    }
    
    public ADM_Theme__c getTheme() {
        Map<string,string> URLParameters = ApexPages.currentPage().getParameters();
		if(URLParameters.containsKey('id')) {
	        List<ADM_Theme__c> theme = [Select id, name from ADM_Theme__c Where id = :URLParameters.get('id')];
            if (theme.size() > 0) {
                return theme.get(0);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Theme Id'));
            }
        } else { 
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Theme Id not provided'));
        }
        return null;
    }
}