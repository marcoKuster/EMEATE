@isTest
public with sharing class COM_PermissionSetAdapterFactoryTest {

    public static testMethod void testCreateFromPermissionSet() {
        PermissionSet permSet = getTestPermissionSet();
        if(null != permSet){
            COM_PermissionSetAdapterFactory factory = new COM_PermissionSetAdapterFactory();
            COM_PermissionSetAdapter adapter = factory.createFromPermissionSet(permSet);
            System.assert(adapter != null, 'createFromPermissionSet should never return null');
            System.assertEquals(permSet.Name, adapter.getName());
        }
    }
    /* Disabling tests will enable after this investigation https://gus.my.salesforce.com/apex/adm_investigationdetail?id=a07B0000002ly9O
finds out what is wrong with the Tests after gs0 206 release.



    public static testMethod void testCreateFromName() {
        PermissionSet permSet = getTestPermissionSet();
        if(null != permSet){
            COM_PermissionSetAdapterFactory factory = new COM_PermissionSetAdapterFactory();
            COM_PermissionSetAdapter adapter = factory.createFromName(permSet.Name);
            System.assert(adapter != null, 'createFromName should never return null');
            System.assertEquals(permSet.Name, adapter.getName());
        }
    }

    */
    /* Disabling tests will enable after this investigation https://gus.my.salesforce.com/apex/adm_investigationdetail?id=a07B0000002ly9O
    finds out what is wrong with the Tests after gs0 206 release.


    public static testMethod void testCreateFromNameThrowsExceptionWhenInvalid() {
        COM_PermissionSetAdapterFactory factory = new COM_PermissionSetAdapterFactory();
        try {
            COM_PermissionSetAdapter adapter = factory.createFromName('Invalid_Name');
            System.assert(false, 'Expected exception to be thrown when ID is invalid');
        } catch(ADM_UnexpectedValueException exc) {
            System.debug('Caught an expected exception: ' + exc.getMessage());
        }
    }
    */

    /* Disabling tests will enable after this investigation https://gus.my.salesforce.com/apex/adm_investigationdetail?id=a07B0000002ly9O
    finds out what is wrong with the Tests after gs0 206 release.


    public static testMethod void testCreateFromId() {
        PermissionSet permSet = getTestPermissionSet();
        if(null != permSet){
            COM_PermissionSetAdapterFactory factory = new COM_PermissionSetAdapterFactory();
            COM_PermissionSetAdapter adapter = factory.createFromId(permSet.Id);
            System.assert(adapter != null, 'createFromId should never return null');
            System.assertEquals(permSet.Id, adapter.getId());
        }
    }

    */


    /* Disabling tests will enable after this investigation https://gus.my.salesforce.com/apex/adm_investigationdetail?id=a07B0000002ly9O
  finds out what is wrong with the Tests after gs0 206 release.


    public static testMethod void testCreateFromIdThrowsExceptionWhenInvalid() {
        PermissionSet permSet = getTestPermissionSet();
        COM_PermissionSetAdapterFactory factory = new COM_PermissionSetAdapterFactory();
        try {
            //try with a random ID
            COM_PermissionSetAdapter adapter = factory.createFromId('01pB00000008TxA');
            System.assert(false, 'Expected exception to be thrown when ID is invalid');
        } catch(ADM_UnexpectedValueException exc) {
            System.debug('Caught an expected exception: ' + exc.getMessage());
        }
    }
    */


    /**
     * Relies on external data!
     */
    @IsTest
    private static PermissionSet getTestPermissionSet() {
        String permSetName = 'Headcount_Hiring_Manager';
        List<PermissionSet> permSets = [select Id, Name from PermissionSet where Name = :permSetName];
        PermissionSet permSetToReturn = null;
        if(null != permSets && permSets.size() > 0)
        {
            permSetToReturn = permSets.get(0);
        }

        return permSetToReturn;
    }
}