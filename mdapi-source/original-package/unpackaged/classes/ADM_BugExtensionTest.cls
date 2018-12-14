@IsTest
public with sharing class ADM_BugExtensionTest {
    private static String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
    public testMethod static void testNewProperties() {
        
        RecordType recordType = ADM_RecordType.getByName('Bug', 'ADM_Work__c');
        
        ADM_Work__c work = new ADM_Work__c();
        work.RecordTypeId = recordType.Id;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_BugExtension ext = new ADM_BugExtension(stdController);
        String actualTitle = ext.getTitle();
        Boolean isNew = ext.getIsNew();
        Test.stopTest();
        
        System.assertEquals(recordType.Name, actualTitle, 'Expected the title to be record type name');
        System.assert(isNew, 'Expected isNew to return true when the record is new');
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
        ADM_BugExtension ext = new ADM_BugExtension(stdController);
        
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
        ADM_BugExtension ext = new ADM_BugExtension(stdController);
        
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
        ADM_BugExtension ext = new ADM_BugExtension(stdController);
        
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
     * Ensure status options are loaded properly
     */
    public testMethod static void testGetStatusOptions() {
        
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_BugExtension ext = new ADM_BugExtension(stdController);
        
        Test.startTest();
        ADM_WorkStatus.createOrUpdateAllWorkStatusRecords();
        List<SelectOption> statusOptions = ext.getStatusOptions();
        Test.stopTest();
        
        System.assert(statusOptions != null, 'Expected getStatusOptions to not be null. Actual: null');
        System.assert(!statusOptions.isEmpty(), 'Expected getStatusOptions to return at least one option');
        assertContainsLabel(statusOptions, 'Closed');
        assertContainsLabel(statusOptions, 'New');
        assertContainsLabel(statusOptions, 'In Progress');
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
        ADM_BugExtension ext = new ADM_BugExtension(stdController);
        String actualPriority = ext.calculatedPriority;
        Test.stopTest();
        
        System.assertEquals('P0', actualPriority, 'Expected calculate priority to return P0 because that is what is setup in the priority mapping');
    }
    
    /**
     * Ensure that the default record type method is returning the correct value.
     */
    public testMethod static void testDefaultRecordType() {
        RecordType recordType = ADM_RecordType.getByName('Bug', 'ADM_Work__c');
        
        ADM_Work__c work = new ADM_Work__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_BugExtension ext = new ADM_BugExtension(stdController);
        
        System.assertEquals(recordType, ext.getRecordType());
    }
    

    /*  
      @testcaseID a1DB00000002r2mMAA

      @hierarchy GUS.NextGenWorkPage

      @userstory a07B0000000VZ35IAG

      @expectedResults: The clone button should clone the user story.
      
      @author sgovindan

    */

    /**
     * Ensure that the doClone method returns the correct page
     */
    public static testMethod void testDoClone() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_BugExtension extension = new ADM_BugExtension(controller);
        
        PageReference pageReference = extension.doClone();
        
        String qualifiedPageName = (nameSpacePrefix + 'ADM_BugEdit').toLowerCase();  
        System.assert(pageReference.getUrl().containsIgnoreCase('/'+qualifiedPageName), 'Expected the page reference to go to the ADM_BugEdit page: ' + pageReference.getUrl());
        System.assert(pageReference.getRedirect(), 'Expected the page reference to be a redirect');
        System.assertEquals(work.Id, pageReference.getParameters().get('id'), 'Expected the ID to be specified on the page reference');
        System.assertEquals('1', pageReference.getParameters().get('clone'), 'Expected the clone parameter to be specified on the page reference');
        System.assertEquals('/' + work.Id, pageReference.getParameters().get('retURL'), 'Expected the retURL to be specified on the page reference');
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
    
    public static testMethod void testDetailsAndStepsToReproduceContainsHTML() {
        ADM_Work__c bug = ADM_Work.setupTestWork('Bug');
        bug.Details_And_Steps_To_Reproduce__c = 'test';
        insert bug;
        ApexPages.StandardController controller = new ApexPages.StandardController(bug);
        ADM_BugExtension extension = new ADM_BugExtension(controller);
        System.assertEquals(false, extension.getDetailsAndStepsToReproduceContainsHTML(), 'Expected no html to be found since we provided:' + bug.Details_And_Steps_To_Reproduce__c);
        //now lets add some html
        bug.Details_And_Steps_To_Reproduce__c = 'test<ul><li>one</li><li>two</li></ul>';
        update bug;
        System.assertEquals(true, extension.getDetailsAndStepsToReproduceContainsHTML(), 'Expected html to be found since we provided:' + bug.Details_And_Steps_To_Reproduce__c);
    }

    public testMethod static void testDoSaveBugAndNew() {
        ADM_Work__c bug = ADM_Work.setupTestWork('Bug', 'P1');
        insert bug;
        ApexPages.StandardController standardController = new Apexpages.StandardController(bug);
        ADM_BugExtension extension = new ADM_BugExtension(standardController);
        PageReference pageReference = extension.doSaveBugAndNew();
        System.assert(pageReference != null, 'Expected doSaveAndNew to never return null');
        
        String qualifiedPageName = (nameSpacePrefix + 'ADM_SelectWorkRecordType').toLowerCase(); 
        System.assert(pageReference.getUrl().containsIgnoreCase('/'+qualifiedPageName), 'Expected the page reference to go to the ADM_SelectWorkRecordType page: ' + pageReference.getUrl());
        System.assertEquals(bug.Priority_Default__c, 'P1', 'Expected the default priority to be equal to the calculated priority');
    }

    public testMethod static void testDoSaveBugAndDetail() {
        ADM_Work__c bug = ADM_Work.setupTestWork('Bug', 'P1');
        insert bug;
        String expectedURL = '/' + bug.Id;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(bug);
        ADM_BugExtension extension = new ADM_BugExtension(standardController);
        Pagereference pageref = extension.doSaveBugAndDetail();
        
        System.assert(pageref != null, 'Expected doSaveBugAndDetail to never return null');
        System.assertEquals(expectedURL, pageref.getUrl(), 'Expected the page to go to the detail page');
        System.assertEquals(bug.Priority_Default__c, 'P1', 'Expected the default priority to be equal to the calculated priority');
    }

}