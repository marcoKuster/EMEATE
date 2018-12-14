public class ADM_Organization {
    
    private static Boolean loaded = false;
    private static String name;
    
    /**
     * Gets the name of the organization. If the user doesn't have permission to access the organization name an empty 
     * String is returned.
     */
    public static String getOrganizationName() {
        if(!loaded) {
            loaded = true;
            
            //the Organization object is exposed to System Administrators but may not be available for other users
            try {
                ADM_Organization.name = (UserInfo.getOrganizationName() == null) ? '' : UserInfo.getOrganizationName();
            } catch(Exception exc) {
                ADM_Organization.name = '';
            }
        }
        return ADM_Organization.name;
    }
    
    static testMethod void testGetOrgName() {
        String expected = UserInfo.getOrganizationName();
        String actual = ADM_Organization.getOrganizationName();
        System.assertEquals(expected, actual, 'Expected getOrganizationName to return the organization name.');
    }
}