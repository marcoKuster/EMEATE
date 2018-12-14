global with sharing class ADM_ChatterFollowersComponentController {
	public Id parentId {
		get;
		set;
	}

	public User user {
		get;
		set;
	}

	private transient List<EntitySubscriptionWrapper> followers = null;

	public ADM_ChatterFollowersComponentController() {
		user = new User();
	}

	public List<EntitySubscriptionWrapper> getFollowers() {
		if (followers == null) {
			List<EntitySubscriptionWrapper> followers = new List<EntitySubscriptionWrapper>();
			try {
				// We need to add a limit clause to this query because otherwise the system will throw an
				// implementation exception if the current user is not an admin 
				List<EntitySubscription> subscriptions = [select Id,ParentId,SubscriberId from EntitySubscription where ParentId = :parentId order by CreatedDate desc limit 999];
				
				//build list of user IDs
				List<Id> subscriberIds = new List<Id>();
				for (EntitySubscription subscription : subscriptions) {
					subscriberIds.add(subscription.SubscriberId);
				}

				//get all users for these subscriptions
				Map<Id,User> userMap = new Map<Id,User>([select Id,Name,SmallPhotoUrl from User where Id in :subscriberIds]);

				//loop subscriptions and create wrapper for each one and pull user object from map using user ID
				for (EntitySubscription subscription : subscriptions) {
					User user = userMap.get(subscription.SubscriberId);
					if (user != null)
						followers.add(new EntitySubscriptionWrapper(subscription, user));
				}

			}
			catch (System.Exception e) {
				System.debug('Exception in ADM_ChatterFollowersComponentController: ' + e);
				followers = new List<EntitySubscriptionWrapper>();
			}
			return followers;

		}
		else {
			return followers;
		}
	}

	@RemoteAction
	global static void addFollower(String fullName, String parentId) {
		System.debug('In addFollower with fullName = ' + fullName);

		// Validate the full name of the user
		List<User> foundUsers = [select Id from User where Name = :fullName and IsActive = true limit 1];
		if (foundUsers != null && foundUsers.size() == 1) {
			// Check to see if they're already a subscriber and alert if they are
			if (ADM_EntitySubscriptionUtils.isEntitySubscriber(parentId, foundUsers[0].Id)) {
				throw new ADM_ApplicationException('User is already subscribed');
			} else {
				// Create an EntitySubscription and insert it.  We won't return
				// anything as the caller is expected to refresh the follower list
				EntitySubscription es = new EntitySubscription();
				es.ParentId = parentId;
				es.SubscriberId = foundUsers[0].Id;
				ADM_EntitySubscriptionUtils.insertEntitySubscriptions(new List<EntitySubscription>{es});
			}
		}
		else {
			throw new ADM_ApplicationException('No active user found with full name "' + fullName + '"');
		}

	}

	@RemoteAction
	global static void removeFollower(String entitySubscriptionId) {
		System.debug('In removeFollower with entitySubscriptionId = ' + entitySubscriptionId);
		// Platform delete method requires a list of SObjects and Id is not-writable, so we need
		// to query the database
		// We need to add a limit clause to this query because otherwise the system will throw an
		// implementation exception if the current user is not an admin 
		
		List<EntitySubscription> esl = [select Id from EntitySubscription where Id = :entitySubscriptionId limit 1];
		if (esl.size() > 0) {
			ADM_EntitySubscriptionUtils.deleteEntitySubscriptions(esl);
		}
	}

	// Wrapper class needed because we cannot call SubscriberId__r.SmallPhotoUrl since Salesforce
	// doesn't support relationship names on EntitySubscription
	public class EntitySubscriptionWrapper {
		public EntitySubscription es { get; set; }
		public User user { get; set; }
		public EntitySubscriptionWrapper(EntitySubscription es, User user) {
			this.es = es;
			this.user = user;
		}
	}


}