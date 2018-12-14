/**
 * Adapts a PermissionSet to provide additional functionality.
 */
public with sharing virtual class COM_PermissionSetAdapter {
	private PermissionSet permset;
    
    /**
     * Used by classes that extend this adapter
     */
    protected COM_PermissionSetAdapter() {
    	
    }
    
    /**
     * Creates a new PermSetAdapter with the given PermissionSet.
     */
	public COM_PermissionSetAdapter(PermissionSet permset) {
		if (permset == null) {
			throw new ADM_UnexpectedValueException('permset cannot be null');
		}
		this.permset = permset;
	}
	
	/**
     * Determines if the user is assigned the specified permission set.
     * @param user The user to check; may not be null
	 */
	public virtual Boolean isAssignedToUser(User user) {
    	Integer count = [
          select count()
          from PermissionSetAssignment 
          where
            AssigneeId = :user.Id and 
            PermissionSetId = :permset.Id];
        return count > 0;
	}
	
    /**
     * Returns a comma delimited list of users that are active and are assigned to the specified perm set.
     */
	public virtual String getUserFullNameList() {
		return getUserFullNameList(',');
	}
	
	/**
 	 * Returns a delimited list of users that are active and are assigned to the specified perm set.
	 */
	public virtual String getUserFullNameList(String delimiter) {
		COM_UserFullNameListBuilder listBuilder = new COM_UserFullNameListBuilder(delimiter);
        for(User u : [select id, Name from User where isActive =:true and id in (select assigneeId from PermissionSetAssignment where PermissionSetId =:permset.id)]) {
        	listBuilder.addUser(u);
        }
        return listBuilder.buildString();
	}
	
	/**
	 * Gets the name of the permission set.
	 */
	public virtual String getName() {
		return permset.Name;
	}
	
	/**
	 * Gets the ID of the permission set.
	 */
	public virtual String getId() {
		return permset.Id;
	}
	
	/**
	 * Gets the permission set to which the adapter is wrapping
	 */
	public virtual PermissionSet toPermissionSet() {
		return permset;
	}
	
	/**
	 * Gets the permission set assignment for the specified assignee ID. If
	 * no permission is assigned then a null is returned.
	 */
	public virtual PermissionSetAssignment getAssignmentFor(String assigneeId) {
		try {
			PermissionSet permSet = this.toPermissionSet();
			return [select id, AssigneeId, PermissionSetId from PermissionSetAssignment where AssigneeId=:assigneeId and PermissionSetId =:permSet.Id];
		} catch (Exception e) {
			return null;    
		}
	}
}