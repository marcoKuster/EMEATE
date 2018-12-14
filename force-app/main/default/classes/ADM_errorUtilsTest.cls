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
private class ADM_errorUtilsTest {

    static testMethod void getErrorMessage() {
        ADM_Task__c task = new ADM_Task__c();
        ADM_errorUtils err = new ADM_errorUtils();

        System.assertEquals(0, err.errorMessages.size());

        try {
            insert task;
        } catch(System.DmlException e) {
            System.assertNotEquals(0, err.getErrorMessage(e).length());
        }

    }

    static testMethod void getApexpagesMessage() {
        ADM_Task__c task = new ADM_Task__c();
        ADM_errorUtils err = new ADM_errorUtils();
        String message = 'test 123';

        try {
            insert task;
        } catch(System.DmlException e) {
        	System.assertEquals(true, err.getApexpagesMessage(message, e).getDetail().startsWith(message));
        }

        System.assertEquals(ApexPages.severity.ERROR, err.getApexpagesMessage(message).getSeverity());
        System.assertEquals(true, err.getApexpagesMessage(message).getDetail().startsWith(message));
    }
}