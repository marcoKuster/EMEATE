@isTest
private class ADM_ChatterFollowersControllerTest {
	
	private static void verifySubscriptionExists(List<ADM_ChatterFollowersComponentController.EntitySubscriptionWrapper> subs,
		EntitySubscription subToLookFor) {
		// Loop over the returned list of subscribers (which should include the generated test user)
		// until we find the generated test EntitySubscription and make sure the ParentId and
		// SubscriberId match
		for (ADM_ChatterFollowersComponentController.EntitySubscriptionWrapper wrapper : subs) {
			if (wrapper.es.Id == subToLookFor.Id) {
				System.assertEquals(wrapper.es.ParentId, subToLookFor.ParentId, 'Expected ParentId(s) to match');
				System.assertEquals(wrapper.es.SubscriberId, subToLookFor.SubscriberId, 'Expected SubscriberId(s) to match');
			}
		}
	}

	static testmethod void testGetFollowers() {
		// Create test EntitySubscriptions using the utility
		// method, which will also create associated users and
		// work objects
		EntitySubscription[] testSubs = ADM_EntitySubscriptionUtils.createTestEntitySubscriptions(1);
		ADM_ChatterFollowersComponentController controller = new ADM_ChatterFollowersComponentController();
		System.assert(testSubs.size() == 1, 'Expected test EntitySubscription(s) array to be one');

		controller.parentId = testSubs[0].ParentId;
		List<ADM_ChatterFollowersComponentController.EntitySubscriptionWrapper> subs = controller.getFollowers();
		System.assert(subs.size() > 0, 'Expected results of getFollowers() to be a non-zero length list of EntitySubscriptionWrapper(s)');
		verifySubscriptionExists(subs, testSubs[0]);
	}

	static testmethod void testAddAndRemoveFollower() {
		// Create a test Work item
		ADM_Work__c workItem = ADM_Work.createListOfWork(1,'Bug').get(0);
		insert workItem;
		System.assert(workItem.Id != null, 'Expected test work item to be created');

		// Create a test user to add as a follower
		User user = ADM_WorkUser.setupTestUser();
		insert user;
		System.assert(user.Id != null, 'Expected test user to be created');

		// Add the test user as a follower
		ADM_ChatterFollowersComponentController.addFollower(user.FirstName + ' ' + user.LastName, workItem.Id);

		// Retieve the newly created subscription
		EntitySubscription newSubscription = [select Id, ParentId, SubscriberId from EntitySubscription where ParentId = :workItem.Id].get(0);
		System.assert(newSubscription != null, 'Expected to find the a new EntitySubscription');

		// Retrieve the list of followers for this work item
		ADM_ChatterFollowersComponentController controller = new ADM_ChatterFollowersComponentController();
		controller.parentId = workItem.Id;
		List<ADM_ChatterFollowersComponentController.EntitySubscriptionWrapper> subs = controller.getFollowers();
		System.assert(subs.size() > 0, 'Expected results of getFollowers() to be a non-zero length list of EntitySubscriptionWrapper(s)');

		// Make sure the test user exists as a subscriber
		verifySubscriptionExists(subs, newSubscription);

		// Now we remove the newly created EntitySubscription
		ADM_ChatterFollowersComponentController.removeFollower(newSubscription.Id);

		// Verify the subscription no longer exists
		List<EntitySubscription> returnedList = [select Id from EntitySubscription where Id = :newSubscription.Id];
		System.assert(returnedList.size() == 0, 'Expected removed subscription to not exist in the database');
	}
}