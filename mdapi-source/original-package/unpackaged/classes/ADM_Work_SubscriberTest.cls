@isTest
private class ADM_Work_SubscriberTest {
	
	@isTest static void testInsertIntoWorkSubscriberWillAddEntitySubscription() {
		System.debug('my user is ' + UserInfo.getUserId());
		ADM_Work__c work = ADM_Work.createTestBug();
		User testUser = ADM_WorkUser.setupTestUser();
		User testUser2 = ADM_WorkUser.setupTestUser();
        User testUser3 = ADM_WorkUser.setupTestUser();
		testUser.Email = 'loremipsum@salesforce.com';
		testUser2.alias = 'alias$';
		testUser3.UserName = 'gusT3det3@gus.com';


		User[] testUsers = new List<User>{testUser,testUser2,testUser3};
		insert testUsers;
         System.debug('test users' + testusers);
    	List<ADM_Work_Subscriber__c> subs = new List<ADM_Work_Subscriber__c>();    	
        ADM_Work_Subscriber__c ws = new ADM_Work_Subscriber__c();
        ws.WorkId__c = work.id;
        ws.UserId__c = testUser2.Id;        
        ADM_Work_Subscriber__c ws1 = new ADM_Work_Subscriber__c();
        ws1.WorkId__c = work.id;
        ws1.Distribution_List__c = 'loremipsum@salesforce.com';

        ADM_Work_Subscriber__c ws2 = new ADM_Work_Subscriber__c();
        ws2.WorkId__c = work.id;
        ws2.Distribution_List__c = testUser3.UserName;

        subs.add(ws);
        subs.add(ws1);
        subs.add(ws2);
        insert subs;  

        EntitySubscription[] entitySubscribersAfterChange = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());

        System.debug('entities are ' + entitySubscribersAfterChange);

        Boolean userFound = false;
        for(User user:testUsers){
            for(EntitySubscription esIter: entitySubscribersAfterChange){
                if(esIter.subscriberId == user.Id){
                    userFound = true;
                    break;
                }
            }
            if(!userFound)
            	System.debug('User not found is ' + user);
            System.assert(userFound,'Expected User in the Entity Subscribers');
            userFound = false;
        }

	}


    @isTest static void testDeleteWorkSubscriberWillDeleteEntitySubscription() {
        System.debug('my user is ' + UserInfo.getUserId());
        ADM_Work__c work = ADM_Work.createTestBug();
        User testUser = ADM_WorkUser.setupTestUser();
        User testUser2 = ADM_WorkUser.setupTestUser();
        User testUser3 = ADM_WorkUser.setupTestUser();
        testUser.Email = 'loremipsum@salesforce.com';
        testUser2.alias = 'alias$';
        testUser3.UserName = 'gusT3det3@gus.com';


        User[] testUsers = new List<User>{testUser,testUser2,testUser3};
        insert testUsers;
         System.debug('test users' + testusers);
        List<ADM_Work_Subscriber__c> subs = new List<ADM_Work_Subscriber__c>();     
        ADM_Work_Subscriber__c ws = new ADM_Work_Subscriber__c();
        ws.WorkId__c = work.id;
        ws.UserId__c = testUser2.Id;        
        ADM_Work_Subscriber__c ws1 = new ADM_Work_Subscriber__c();
        ws1.WorkId__c = work.id;
        ws1.Distribution_List__c = 'loremipsum@salesforce.com';

        ADM_Work_Subscriber__c ws2 = new ADM_Work_Subscriber__c();
        ws2.WorkId__c = work.id;
        ws2.Distribution_List__c = testUser3.UserName;

        subs.add(ws);
        subs.add(ws1);
        subs.add(ws2);
        insert subs;  

        EntitySubscription[] entitySubscribersAfterChange = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());

        System.debug('entities are ' + entitySubscribersAfterChange);

        Boolean userFound = false;
        for(User user:testUsers){
            for(EntitySubscription esIter: entitySubscribersAfterChange){
                if(esIter.subscriberId == user.Id){
                    userFound = true;
                    break;
                }
            }
            if(!userFound)
                System.debug('User not found is ' + user);
            System.assert(userFound,'Expected User in the Entity Subscribers');
            userFound = false;
        }

        //Now deleting Work Subscribers to see the entity subscribers removed

        delete subs;

        entitySubscribersAfterChange = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>{ws.Id,ws1.id,ws2.id});

        system.debug('entitySubscribersAfterChange size ' + entitySubscribersAfterChange.size());

        System.assertEquals(0,entitySubscribersAfterChange.size(), 'Expected no Entity Subscribers for these users ' + testusers);
    }
	
}