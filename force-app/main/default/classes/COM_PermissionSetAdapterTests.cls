@isTest
public with sharing class COM_PermissionSetAdapterTests {
	
	/*
	Since version 24 of Apex API does not allow Apex to create PermissionSet instances,
	we are unable to test the following methods. When the feature becomes enabled
	in a future version, the following code can be uncommented.
	*/
	
	/**
	 * Given a valid permission then the simple delegated properties should return
	 * the proper values.
	 */
	public static testMethod void testSimpleProperties() {
		PermissionSet permSet = getTestPermissionSet();
		
		COM_PermissionSetAdapter adapter = new COM_PermissionSetAdapter(permSet);
		
		System.assertEquals(permSet.Name, adapter.getName());
		System.assertEquals(permSet.Id, adapter.getId());
		System.assertEquals(permSet, adapter.toPermissionSet());
	}
	
	/**
	 * Given a valid permission and a user in that permission set
	 * the #isAssignedToUser method should return true.
	 */
	public static testMethod void testIsAssignedToUser() {
		PermissionSet permSet = getTestPermissionSet();
		
		User user = ADM_WorkUser.createTestUser();
		
        PermissionSetAssignment assignment = new PermissionSetAssignment();
        assignment.AssigneeId = user.Id;
        assignment.PermissionSetId = permSet.Id;
        insert assignment;
		
		COM_PermissionSetAdapter adapter = new COM_PermissionSetAdapter(permSet);
		
		List<User> users = [select Id, Name from User where Id in (select AssigneeId from PermissionSetAssignment where PermissionSetId = :permset.Id) limit 1];
		System.assertEquals(1, users.size());
		System.assert(adapter.isAssignedToUser(user), 'User should be assigned to the permission set');
	}
	
	/**
	 * Given a valid permission then the #getUserFullNameList should contain all
	 * the names of the active users.
	 */
	public static testMethod void testGetUserFullNameList() {
		PermissionSet permSet = getTestPermissionSet();
        
        User newUser = ADM_WorkUser.createTestUser();
        
        PermissionSetAssignment assignment = new PermissionSetAssignment();
        assignment.AssigneeId = newUser.Id;
        assignment.PermissionSetId = permSet.Id;
        insert assignment;
		
		COM_PermissionSetAdapter adapter = new COM_PermissionSetAdapter(permSet);
		String fullNameList = adapter.getUserFullNameList();
		
		//verify that the list contains all of the users
		List<User> users = [select Id, Name from User where isActive = :true and Id in (select AssigneeId from PermissionSetAssignment where PermissionSetId = :permset.Id)];
		System.assertEquals(1, users.size());
		for(User user : users) {
			System.assert(fullNameList.contains(user.Name), 'List does not contain user ' + user.Name);
		}
	}
	
	/**
	 * Given a permisison set and a user assigned to the permission set, the 
	 * method #getAssignmentFor should return an assignment for the specified user
	 */
	public static testMethod void testGetAssignmentForAssigneeId() {
		PermissionSet permSet = getTestPermissionSet();
		
        User user = ADM_WorkUser.createTestUser();
        
        PermissionSetAssignment newAssignment = new PermissionSetAssignment();
        newAssignment.AssigneeId = user.Id;
        newAssignment.PermissionSetId = permSet.Id;
        insert newAssignment;
        
		COM_PermissionSetAdapter adapter = new COM_PermissionSetAdapter(permSet);
		
		PermissionSetAssignment assignment = adapter.getAssignmentFor(user.Id);
		System.assert(assignment != null);
		System.assertEquals(user.Id, assignment.AssigneeId);
	}
	
	@IsTest
	private static PermissionSet getTestPermissionSet() {
		PermissionSet permissionSet = new PermissionSet();
		permissionSet.Name = 'TestPermission';
		permissionSet.Label = 'TestPermission';
		insert permissionSet;
		return permissionSet;
	}
}