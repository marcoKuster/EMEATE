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
private class ADM_PriorityMatrixIndicatorTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        ADM_PriorityMatrixIndicator pmi = new ADM_PriorityMatrixIndicator();
        
        pmi.priority = null;
        System.assert(pmi.indicatorColor == 'white','color was not white ->' + pmi.indicatorColor);
        
        pmi.priority = 'p0';
        System.assert(pmi.indicatorColor == '#FF0000','color was not #FF0000 ->' + pmi.indicatorColor);
        
        pmi.priority = 'p1';
        System.assert(pmi.indicatorColor == '#FF9A00','color was not #FF9A00 ->' + pmi.indicatorColor);
        
        pmi.priority = 'p2';
        System.assert(pmi.indicatorColor == '#DCFF00','color was not #DCFF00 ->' + pmi.indicatorColor);
        
        pmi.priority = 'p3';
        System.assert(pmi.indicatorColor == '#90FF00','color was not #90FF00 ->' + pmi.indicatorColor);
        
        pmi.priority = 'p4';
        System.assert(pmi.indicatorColor == '#0F0','color was not #0F0 ->' + pmi.indicatorColor);
    }
}