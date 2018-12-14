@IsTest
public with sharing class ADM_UserStoryExtensionTest {
    private static String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
    public static testMethod void testDoClone() {
        ADM_Work__c work = ADM_Work.createTestWork('User Story');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_UserStoryExtension extension = new ADM_UserStoryExtension(controller);
        
        PageReference pageReference = extension.doClone();
        String qualifiedPageName = (nameSpacePrefix + 'ADM_UserStoryEdit').toLowerCase();   
        
        System.assert(pageReference.getUrl().containsIgnoreCase('/'+qualifiedPageName), 'Expected the page reference to go to the '+ qualifiedPageName+': ' + pageReference.getUrl());
        System.assert(pageReference.getRedirect(), 'Expected the page reference to be a redirect');
        System.assertEquals(work.Id, pageReference.getParameters().get('id'), 'Expected the ID to be specified on the page reference');
        System.assertEquals('1', pageReference.getParameters().get('clone'), 'Expected the clone parameter to be specified on the page reference');
        System.assertEquals('/' + work.Id, pageReference.getParameters().get('retURL'), 'Expected the retURL to be specified on the page reference');
    }
    
    public static testMethod void testGetRecordType() {
        RecordType recordType = ADM_RecordType.getByName('User Story', 'ADM_Work__c');
        
        ADM_Work__c work = new ADM_Work__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_UserStoryExtension extension = new ADM_UserStoryExtension(stdController);
        
        System.assertEquals(recordType, extension.getRecordType(), 'Expected the record type to the User Story record type');
    }
    
    public static testMethod void testIncludeInPrioritizerShouldBeTrueByDefault(){
        ADM_Work__c work = ADM_Work.createTestWork('User Story');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_UserStoryExtension extension = new ADM_UserStoryExtension(controller);
        
        System.assert(work.Use_Prioritizer__c,'Expected Use_Prioritizer__c to be true');
    }
    
    /**
     * Ensure impacts are loaded properly
     */
    public testMethod static void testGetImpactOptions() {
        String recordTypeId = ADM_RecordType.getId('Bug');
        
        //create the impact and associate it to bugs
        ADM_Impact__c impact = new ADM_Impact__c();
        impact.Name = 'Performance';
        insert impact;
        ADM_Type__c type = new ADM_Type__c();
        type.Name = 'Bug';
        insert type;
        ADM_Impact_Type__c impactType = new ADM_Impact_Type__c();
        impactType.Impact__c = impact.Id;
        impactType.Type__c = type.Id;
        insert impactType;
        
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_UserStoryExtension ext = new ADM_UserStoryExtension(stdController);
        
        Test.startTest();
        List<SelectOption> impactOptions = ext.getImpactOptions();
        Test.stopTest();
        
        System.assert(impactOptions != null, 'Expected getImpactOptions to not be null. Actual: null');
        System.assert(!impactOptions.isEmpty(), 'Expected getImpactOptions to return at least one option');
        assertContainsLabel(impactOptions, '--None--');
        assertContainsLabel(impactOptions, 'Performance');
    }
    
    /**
     * Ensure frequencies are loaded properly
     */
    public testMethod static void testGetFrequencyOptions() {
        ADM_Frequency__c frequency = new ADM_Frequency__c();
        frequency.Name = 'Always';
        insert frequency;
        
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_UserStoryExtension ext = new ADM_UserStoryExtension(stdController);
        
        Test.startTest();
        List<SelectOption> frequencyOptions = ext.getFrequencyOptions();
        Test.stopTest();
        
        System.assert(frequencyOptions != null, 'Expected getFrequencyOptions to not be null. Actual: null');
        System.assert(!frequencyOptions.isEmpty(), 'Expected getFrequencyOptions to return at least one option');
        assertContainsLabel(frequencyOptions, '--None--');
        assertContainsLabel(frequencyOptions, 'Always');
    }
    
    /**
     * Ensure priorities are loaded properly
     */
    public testMethod static void testGetPriorityOptions() {
        
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_UserStoryExtension ext = new ADM_UserStoryExtension(stdController);
        
        Test.startTest();
        List<SelectOption> priorityOptions = ext.getPriorityOptions();
        Test.stopTest();
        
        System.assert(priorityOptions != null, 'Expected getFrequencyOptions to not be null. Actual: null');
        System.assert(!priorityOptions.isEmpty(), 'Expected getFrequencyOptions to return at least one option');
        assertContainsLabel(priorityOptions, 'P0');
        assertContainsLabel(priorityOptions, 'P1');
        assertContainsLabel(priorityOptions, 'P2');
        assertContainsLabel(priorityOptions, 'P3');
        assertContainsLabel(priorityOptions, 'P4');
    }
    
    /**
     * Test that calculate priority returns the proper result
     */
    public testMethod static void testCalculatePriority() {
        ADM_Impact__c impact = new ADM_Impact__c();
        impact.Name = 'Performance';
        insert impact;
        
        ADM_Type__c type = new ADM_Type__c();
        type.Name = 'Bug';
        insert type;
        
        ADM_Impact_Type__c impactType = new ADM_Impact_Type__c();
        impactType.Impact__c = impact.Id;
        impactType.Type__c = type.Id;
        insert impactType;
        
        ADM_Frequency__c frequency = new ADM_Frequency__c();
        frequency.Name = 'Always';
        insert frequency;
        
        ADM_Priority__c priority = new ADM_Priority__c();
        priority.Name = 'P0';
        insert priority;
        
        ADM_Priority_Mapping__c priorityMapping = new ADM_Priority_Mapping__c();
        priorityMapping.Frequency__c = frequency.Id;
        priorityMapping.Impact__c = impact.Id;
        priorityMapping.Priority__c = priority.Id;
        insert priorityMapping;
        
        Test.startTest();
        String actualPriority = ADM_WorkRemoteActionsExtension.calculatePriority(frequency.Id, impact.Id);
        Test.stopTest();
        
        System.assertEquals('P0', actualPriority, 'Expected calculate priority to return P0 because that is what is setup in the priority mapping');
    }
    
    /**
     * Test that the calculatePriority instance property returns the proper result when displaying an existing record
     */
    public testMethod static void testInstanceCalculatePriority() {
        ADM_Impact__c impact = new ADM_Impact__c();
        impact.Name = 'Performance';
        insert impact;
        
        ADM_Type__c type = new ADM_Type__c();
        type.Name = 'Bug';
        insert type;
        
        ADM_Impact_Type__c impactType = new ADM_Impact_Type__c();
        impactType.Impact__c = impact.Id;
        impactType.Type__c = type.Id;
        insert impactType;
        
        ADM_Frequency__c frequency = new ADM_Frequency__c();
        frequency.Name = 'Always';
        insert frequency;
        
        ADM_Priority__c priority = new ADM_Priority__c();
        priority.Name = 'P0';
        insert priority;
        
        ADM_Priority_Mapping__c priorityMapping = new ADM_Priority_Mapping__c();
        priorityMapping.Frequency__c = frequency.Id;
        priorityMapping.Impact__c = impact.Id;
        priorityMapping.Priority__c = priority.Id;
        insert priorityMapping;
        
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Frequency__c = frequency.Id;
        work.Impact__c = impact.Id;
        work.Type__c = type.Name;
        insert work;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_UserStoryExtension ext = new ADM_UserStoryExtension(stdController);
        String actualPriority = ext.calculatedPriority;
        Test.stopTest();
        
        System.assertEquals('P0', actualPriority, 'Expected calculate priority to return P0 because that is what is setup in the priority mapping');
    }

    private static void assertContainsLabel(List<SelectOption> options, String label) {
        Boolean contains = false;
        for(SelectOption option : options) {
            if(option.getLabel() == label) {
                contains = true;
                break;
            }
        }
        
        System.assert(contains, 'Expected the options to contain the label: ' + label);
    }
}