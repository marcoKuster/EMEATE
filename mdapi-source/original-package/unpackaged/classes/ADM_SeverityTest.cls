/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ADM_SeverityTest {
	private static ADM_Severity__c severity {
		get {
			if(severity == null) {
				severity = new ADM_Severity__c();
                severity.Name = 'Name';
                insert severity;				
			}
			return severity;
		}
		set;
	}
	
	private static List<String> els { get; set; }

    static testMethod void testGet() {
        System.assertEquals('Name', ADM_Severity.get(severity.Name).Name);
        
    }
    
    static testMethod void testGetAllBy() {
    	List<ADM_Severity__c> severities = new List<ADM_Severity__c>();
    	els = new List<String>();
    	els.add(severity.OwnerId);
    	els.add(severity.LastModifiedById);
    	els.add(severity.Id);
    	els.add(severity.Name);
    	
        severities = ADM_Severity.getAllBy('name', els);
        System.assertEquals(severity.Id, severities.get(0).Id);
        
        severities = ADM_Severity.getAllBy('id', els);
        System.assertEquals(severity.Id, severities.get(0).Id);
    }
}