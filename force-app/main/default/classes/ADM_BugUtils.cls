public with sharing class ADM_BugUtils {
	private static final String OPTION_NONE_LABEL = '--None--';
	public static List<SelectOption> getImpactsForBug(){
		List<SelectOption> impactOptions = new List<SelectOption>();
        impactOptions.add(new SelectOption('', OPTION_NONE_LABEL));
        //new Work page has deprecated the Type picklist so always pull impacts for 'Bug'
        List<ADM_Impact__c> impactList = ADM_Impact.getAllByType('Bug');
        for( ADM_Impact__c i : impactList) {
            impactOptions.add(new SelectOption(i.id, i.Name));
        }
        return impactOptions;
	}
	
	public static List<SelectOption> getFrequencyOptions(){
		List<SelectOption> frequencyOptions = new List<SelectOption>();
		frequencyOptions.add(new SelectOption('', OPTION_NONE_LABEL));
        List<ADM_Frequency__c> frequencyList = ADM_Frequency.getAll();
        for( ADM_Frequency__c f : frequencyList) {
            frequencyOptions.add(new SelectOption(f.id, f.Name));
        }
        return frequencyOptions;
	}
}