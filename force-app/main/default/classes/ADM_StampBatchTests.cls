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
private class ADM_StampBatchTests {
    private static ADM_Release__c release {
        get {
          if(release == null) {
              release = ADM_Release.createTestRelease();
          }
          return release;
        }
        set;
    }

    private static ADM_Release__c release2 {
        get {
            if(release2 == null) {
                release2 = release.clone(false, true);
                release2.Name = release.Id;
                insert release2;
            }
            return release2;
        }
        set;
    }

    static testMethod void testDelete() {
        ADM_Released_In__c stamp = ADM_Release.createTestReleasedIn(release);
        ADM_SetStandardControllerHelper helper = new ADM_SetStandardControllerHelper(release.Id, new List<String>{}, new List<String>{}, new List<String>{}, new List<String>{});
        ADM_StampBatchDelete el = new ADM_StampBatchDelete(release.Id, helper.query);
        Test.startTest();
            Id elId = Database.executeBatch(el);
        Test.stopTest();
        System.assertEquals(0, ADM_ReleasedIn.getAllForRelease(release.Id).size());
    }

    static testMethod void testCopy() {
        ADM_Released_In__c stamp = ADM_Release.createTestReleasedIn(release);
        ADM_SetStandardControllerHelper helper = new ADM_SetStandardControllerHelper(release.Id, new List<String>{}, new List<String>{}, new List<String>{}, new List<String>{});
        ADM_StampBatch el = new ADM_StampBatch(release.Id, release2.Id, helper.query);
        Test.startTest();
            Id elId = Database.executeBatch(el);
        Test.stopTest();
        System.assertEquals(ADM_ReleasedIn.getAllForRelease(release2.Id).size(), ADM_ReleasedIn.getAllForRelease(release.Id).size());
    }
}