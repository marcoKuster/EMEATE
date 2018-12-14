/**
 * Manages the permissions that are needed for the Headcount/Roster functionality.
 */
public with sharing virtual class ADM_HeadcountPermissionManager {
	private static final String RECRUITER_PERM_SET_NAME = 'Headcount_Recruiting';
    private static final String HIRING_MANAGER_PERM_SET_NAME = 'Headcount_Hiring_Manager';
	
	private COM_PermissionSetAdapterFactory factory = null;
	private transient COM_PermissionSetAdapter hiringManagerPermSet = null;
	private transient COM_PermissionSetAdapter recruiterPermSet = null;
	
	/**
	 * Creates a new permission manager with the default PermissionSetAdapterFactory.
	 */
	public ADM_HeadcountPermissionManager() {
		factory = new COM_PermissionSetAdapterFactory();
	}
	
	/**
	 * Creates a new permission manager with the specified factory.
	 * @param factory the factory instance to create the permission set adapters;
	 * may not be null
	 */
	public ADM_HeadcountPermissionManager(COM_PermissionSetAdapterFactory factory) {
		this.factory = factory;
	}
	
    /**
     * Gets the permission set that corresponds to the Recruiting. The value 
     * returned will never
     */
    public virtual COM_PermissionSetAdapter getRecruitingPermSet() {
    	if(recruiterPermSet == null) {
    		recruiterPermSet = factory.createFromName(RECRUITER_PERM_SET_NAME);
    	}
    	return recruiterPermSet;
    }
    
    /**
     * Gets the permission set that corresponds to the Hiring Manager.  The value
     * returned will never be null.
     */
    public virtual COM_PermissionSetAdapter getHiringManagerPermSet() {
    	if(hiringManagerPermSet == null) {
    		hiringManagerPermSet = factory.createFromName(HIRING_MANAGER_PERM_SET_NAME);
    	}
    	return hiringManagerPermSet;
    } 
}