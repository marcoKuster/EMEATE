public with sharing virtual class COM_PermissionSetAdapterFactory {
	
	/**
	 * Creates a new adapter from the given permission set.
	 * @param permset The permission set; may not be null
	 */
	public virtual COM_PermissionSetAdapter createFromPermissionSet(PermissionSet permset) {
		return new COM_PermissionSetAdapter(permset);
	}
	
	/**
	 * Creates a new PermissionSetAdapter from the PermissionSet with the given
	 * name. If no PermissionSet matches, then an ADM_UnexpectedValueException 
	 * is thrown.
	 */
	public virtual COM_PermissionSetAdapter createFromName(String name) {
		System.debug('querying for permset ');
		List<PermissionSet> permsets = [SELECT Id, Name, Description, Label FROM PermissionSet WHERE Name =:name];
		if(permsets.size() == 0) {
			throw new ADM_UnexpectedValueException('No permission set found with the name of "' + name + '"');
		}
		return new COM_PermissionSetAdapter(permsets.get(0));
	}
	
	/**
	 * Creates a new PermissionSetAdapter from the PermissionSet with the given
	 * ID. If no PermissionSet matches, then an ADM_UnexpectedValueException 
	 * is thrown.
	 */
	public virtual COM_PermissionSetAdapter createFromId(String id) {
		System.debug('querying for permset with ID of ' + id);
		List<PermissionSet> permsets = [SELECT Id, Name, Description, Label FROM PermissionSet WHERE Id =:id];
		if(permsets.size() == 0) {
			throw new ADM_UnexpectedValueException('No permission set found with ID of "' + id + '"');
		}
		return new COM_PermissionSetAdapter(permsets.get(0));
	}
}