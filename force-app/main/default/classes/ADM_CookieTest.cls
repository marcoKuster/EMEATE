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
private class ADM_CookieTest {
    private static String cookieName = 'loremipsumdolor';
    private static String defaultTabName = 'info';

    /*
    @testcaseID a1DB00000000szY
    @userstory a07B0000000E2QKIA0
    @hierarchy GUS.ScrumforceToGUS.Sprint.Sprint Information.Sticky Tab
    @expected results User should go back to the Sprint Information tab when clicking on a Sprint
    @author: Alexis Williams
    */
    
    static testMethod void testWithNoCookie() {
        ADM_Cookie cookie = new ADM_Cookie(cookieName, defaultTabName);
        System.assertEquals(cookieName, cookie.name);
        System.assertEquals(defaultTabName, cookie.activeTab);
        System.assertEquals(defaultTabName, cookie.defaultTabName);
    }
    
    /*
    @testcaseID a1DB00000000szO
    @userstory a07B0000000E2QKIA0
    @hierarchy GUS.ScrumforceToGUS.Sprint.Sprint Information.Sticky Tab
    @expected results User should go back to the Sprint Information tab where he/she left off
    @author: Alexis Williams
    */
    static testMethod void testWithCookieDifferentTabActive() {
    	Cookie acTab = new Cookie(cookieName, defaultTabName + '2', null, 1, false);
		Apexpages.currentPage().setCookies(new Cookie[]{acTab});
        ADM_Cookie cookie = new ADM_Cookie(cookieName, defaultTabName);
        System.assertEquals(cookieName, cookie.name);
        System.assertEquals(defaultTabName + '2', cookie.activeTab);
        System.assertEquals(defaultTabName, cookie.defaultTabName);
    }
    
    /*
    @testcaseID a1DB00000000szT
    @userstory a07B0000000E2QKIA0
    @hierarchy GUS.ScrumforceToGUS.Sprint.Sprint Information.Sticky Tab
    @expected results User should go back to the Sprint tab where he/she left off
    @author: Alexis Williams
    */
    static testMethod void testWithCookieSameTabActive() {
    	Cookie acTab = new Cookie(cookieName, defaultTabName, null, 1, false);
		Apexpages.currentPage().setCookies(new Cookie[]{acTab});
        ADM_Cookie cookie = new ADM_Cookie(cookieName, defaultTabName);
        System.assertEquals(cookieName, cookie.name);
        System.assertEquals(defaultTabName, cookie.activeTab);
        System.assertEquals(defaultTabName, cookie.defaultTabName);
    }
}