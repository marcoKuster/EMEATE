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
private class ADM_RecordTypeTests {
    private static List<RecordType> recordTypes {
    	get {
    		if(recordTypes == null) {
                recordTypes = [select SystemModstamp, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, Id, Description, CreatedDate, CreatedById, BusinessProcessId from RecordType limit 1000];
    		}
    		return recordTypes;
    	}
    	set;
    }

    testMethod static void verifyGetId() {
    	RecordType rec = recordTypes[0];
    	String recId = ADM_RecordType.getId(rec.Name);
        System.assertEquals(rec.Id, recId);
    }

    testMethod static void verifyGetAll() {
    	System.assertNotEquals(null, ADM_RecordType.getAll());
    }

    testMethod static void verifyGet() {
    	RecordType rec = recordTypes.get(0);
    	System.assertEquals(rec.Id, ADM_RecordType.get(rec.Id).Id);
    }
    
    testMethod static void verifyGetById() {
    	RecordType recordType = recordTypes.get(0);
    	RecordType actual = ADM_RecordType.getById(recordType.Id);
    	System.assertEquals(recordType.Id, actual.Id);
    }
    
    testMethod static void verifyGetByName() {
        RecordType recordType = recordTypes.get(0);
        RecordType actual = ADM_RecordType.getByName(recordType.Name, recordType.SobjectType);
        System.assertEquals(recordType.Id, actual.Id);
    }
    
    testMethod static void verifyFirst() {
        RecordType actual = ADM_RecordType.first(recordTypes);
        System.assertEquals(recordTypes.get(0), actual, 'Expected the first value the first value of the list');
    }
    
    testMethod static void verifyFirstWhenEmpty() {
    	RecordType actual = ADM_RecordType.first(new List<RecordType>());    
    	System.assert(actual == null, 'Expected the first value to be null since the list is empty');
    }

    testMethod static void verifyEnsureByName() {
        RecordType recordType = recordTypes.get(0);
        RecordType actual = ADM_RecordType.ensureByName(recordType.Name, recordType.SobjectType);
        System.assertEquals(recordType.Id, actual.Id);
    }

    testMethod static void verifyEnsureByNameException() {
    	try {
            RecordType actual = ADM_RecordType.ensureByName('Unknown', 'ADM_Work__c');
            System.assert(false, 'Expected an exception to be thrown when the RecordType is not valid');
    	} catch(Exception exc) {
    		System.assert(exc.getMessage().contains('No RecordType found'), 'Expected exception to be about the invalid RecordType name: ' + exc.getMessage());
    	}
    }
    
    testMethod static void verifyMapRecordTypeListById() {
    	Map<Id, RecordType> recs = ADM_RecordType.mapRecordTypeListByID(recordTypes);
    	System.assertEquals(recordTypes.size(), recs.size());
    }

    testMethod static void verifyCatchWithInvalidId() {
    	String recId = String.valueOf(recordTypes.get(0).Id).substring(0,10);
    	System.assertEquals(null, ADM_RecordType.get(recId));
    }
    
    testMethod static void testGetRecordTypeFromUrl() {
    	RecordType expected = ADM_RecordType.getByName('Bug', 'ADM_Work__c');
    	
    	Map<String, String> parameters = System.currentPageReference().getParameters();
    	parameters.put('RecordTypeLogicalName', expected.Name);
    	
    	Test.startTest();
    	RecordType actual = ADM_RecordType.getRecordTypeFromUrl('ADM_Work__c');
    	Test.stopTest();
    	
    	System.assertEquals(expected.Name, actual.Name);
    }


}