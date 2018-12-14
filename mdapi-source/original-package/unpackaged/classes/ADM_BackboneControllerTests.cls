@isTest
public with sharing class ADM_BackboneControllerTests {

    /**
     * Ensure that the status values are returned properly
     */
    public testMethod static void testGetStatuses() {
        ADM_BackboneController controller = new ADM_BackboneController();
        
        Test.startTest();
        Map<String, List<String>> statusValues = controller.getWorkStatusValues();
        String statusValuesAsJson = controller.getWorkStatusValuesAsJson();
        Test.stopTest();
        
        System.assert(statusValues != null, 'Expected the status values for the work item to be returned. Actual: null');
        System.assert(!statusValues.isEmpty(), 'Expected the status values from the work item to be returned. Actual: ' + statusValues);
        System.assert(statusValuesAsJson != null, 'Expected getWorkStatusValuesAsJson to not be null. Actual: null');
        System.assert(statusValuesAsJson.startsWith('{'), 'Expected getWorkStatusValuesAsJson to return a map. Actual: ' + statusValuesAsJson);
        System.assert(statusValuesAsJson.endsWith('}'), 'Expected getWorkStatusValuesAsJson to return a map. Actual: ' + statusValuesAsJson);
        System.assert(statusValuesAsJson.indexOf('Bug') > -1, 'Expected getWorkStatusValuesAsJson to contain Bug. Actual: ' + statusValuesAsJson);
        System.assert(statusValuesAsJson.indexOf('User Story') > -1, 'Expected getWorkStatusValuesAsJson to contain User Story. Actual: ' + statusValuesAsJson);
        System.assert(statusValuesAsJson.indexOf('ToDo') > -1, 'Expected getWorkStatusValuesAsJson to contain ToDo. Actual: ' + statusValuesAsJson);
        System.assert(statusValuesAsJson.indexOf('Investigation') > -1, 'Expected getWorkStatusValuesAsJson to contain Investigation. Actual: ' + statusValuesAsJson);
    }
    
    /**
     * Ensure priorities are loaded properly
     */
    public testMethod static void testGetPriorities() {
        ADM_BackboneController controller = new ADM_BackboneController();
        
        Test.startTest();
        String prioritiesAsJson = controller.getPrioritiesAsJson();
        Test.stopTest();
        
        System.assert(prioritiesAsJson != null, 'Expected getFrequenciesAsJson to not be null. Actual: null');
        System.assert(prioritiesAsJson.startsWith('['), 'Expected getFrequenciesAsJson to return an array. Actual: ' + prioritiesAsJson);
        System.assert(prioritiesAsJson.endsWith(']'), 'Expected getFrequenciesAsJson to return an array. Actual: ' + prioritiesAsJson);
        System.assert(prioritiesAsJson.indexOf('P0') > -1, 'Expected getFrequenciesAsJson to contain the P0 priority. Actual: ' + prioritiesAsJson);
    }
    
    /**
     * Ensure perforce status values are loaded properly
     */
    public testMethod static void testGetPerforceStatusValues() {
        ADM_BackboneController controller = new ADM_BackboneController();
        
        Test.startTest();
        String perforceStatusValuesAsJson = controller.getPerforceStatusValuesAsJson();
        Test.stopTest();
        
        System.assert(perforceStatusValuesAsJson != null, 'Expected getPerforceStatusValues to not be null. Actual: null');
        System.assert(perforceStatusValuesAsJson.startsWith('['), 'Expected getPerforceStatusValues to return an array. Actual: ' + perforceStatusValuesAsJson);
        System.assert(perforceStatusValuesAsJson.endsWith(']'), 'Expected getPerforceStatusValues to return an array. Actual: ' + perforceStatusValuesAsJson);
        System.assert(perforceStatusValuesAsJson.indexOf('Open') > -1, 'Expected getPerforceStatusValues to contain the P0 priority. Actual: ' + perforceStatusValuesAsJson);
    }
    
}