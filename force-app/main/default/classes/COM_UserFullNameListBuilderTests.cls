public with sharing class COM_UserFullNameListBuilderTests {
	
	/**
	 * Given a list of users, the builder should build a list of the user's names
	 */
	public static testMethod void testBuildStringValid() {
		//create the users
		List<Id> userIds = new List<Id>();
		User user1 = ADM_WorkUser.createTestUserWithRandomName();
		userIds.add(user1.Id);
		
		User user2 = ADM_WorkUser.createTestUserWithRandomName();
		userIds.add(user2.Id);
		
		User user3 = ADM_WorkUser.createTestUserWithRandomName();
		userIds.add(user3.Id);
		
		List<User> users = [select Name from User where id in :userIds];
		
		String delimiter = ',';
		COM_UserFullNameListBuilder builder = new COM_UserFullNameListBuilder(delimiter);
		for(User user : users) {
			builder.addUser(user);
		}
		String actual = builder.buildString();
		
		//verify the built string
		System.assert(actual != null);
		for(User user : users) {
			System.assert(user.Name != null);
			System.assertEquals(true, actual.contains(user.Name), 'String does not contain user ' + user.Name);
		}
		System.assertEquals(users.size(), actual.split(delimiter).size(), 'Expected the list to output all users');
	}
	
	/**
	 * Given a valid builder, if a null is passed into #addUser then an exception 
	 * should be thrown
	 */
	public static testMethod void testAddNullUser() {
		
		COM_UserFullNameListBuilder builder = new COM_UserFullNameListBuilder(',');
		try {
			builder.addUser(null);
			System.assert(false, 'Expected UnexpectedValueException to be thrown when adding a null user');
		} catch(ADM_UnexpectedValueException exc) {
			System.debug('caught the expected exception: ' + exc.getMessage());
		}
	}
}