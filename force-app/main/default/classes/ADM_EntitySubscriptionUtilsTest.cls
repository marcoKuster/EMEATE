@isTest
public class ADM_EntitySubscriptionUtilsTest {

    testMethod static void testgetAllByList() {
        
        ADM_Work__c[] testWorks = ADM_Work.createListOfWork(1,'Bug');
        insert testWorks;
        List<User> users = new List<User>();
        User user = ADM_WorkUser.setupTestUser();
        users.add(user);
        
        insert users;

        EntitySubscription[] testESs = new EntitySubscription[1];
        EntitySubscription testES = new EntitySubscription(ParentId=testWorks[0].Id, subscriberId=users[0].Id);
        testESs[0] = testES;
        
        insert testESs;

        EntitySubscription[] results = ADM_EntitySubscriptionUtils.getAllBy(new List <Id> {testWorks[0].Id}, new List <Id> {users[0].Id});
        System.assert(results[0].ParentId!=null, 'The getAllBy method did not return any value');
        
    }


    testMethod  static void testgetWorkIdToSubscriberMapFromEntitySubscribers() {
        List <EntitySubscription>  listESS = new List <EntitySubscription>();
        EntitySubscription[] testESS = new EntitySubscription[1];
        testESS = ADM_EntitySubscriptionUtils.createTestEntitySubscriptions(1);
        listESS.add(testESS[0]);
        Map<Id, Set<String>> resultsMap = new Map<Id, Set<String>>();
        resultsMap = ADM_EntitySubscriptionUtils.getWorkIdToSubscriberMapFromEntitySubscribers(listESS);
        Set<String> temSubId = new Set<String>();
        temSubId = resultsMap.get(testESS[0].ParentId);
        System.assert(temSubId.contains(testESS[0].subscriberId));
    }


    testMethod static void testgetAllById() {
        EntitySubscription[] testESS = new EntitySubscription[1];
        testESS = ADM_EntitySubscriptionUtils.createTestEntitySubscriptions(1);
        List <String> enSubId = new List<String>();
        enSubId.add((String)testEss[0].Id);
        EntitySubscription[] results = ADM_EntitySubscriptionUtils.getAllById(enSubId);
        System.assert(results[0].ParentId!=null, 'The getAllById method did not return any value');   

    }  


    testMethod static void testBatchUpdate() {
        Integer noOfItems = 5;
        List <Id> workIds = new List <Id>();
        List <Id> userIds = new List <Id>();
        Map <Id,Id> workToUserMapping = new Map <Id,Id>() ;

        ADM_Work__c[] testWorks = ADM_Work.createListOfWork(noOfItems,'Bug');
        insert testWorks;
        List<User> users = new List<User>();
        User user = new User();
        for(Integer indx = 0; indx<noOfItems; indx++){
            user = ADM_WorkUser.createTestUser();
            users.add(user);
            workIds.add(testWorks[indx].Id);
            userIds.add(user.Id);
            workToUserMapping.put(testWorks[indx].Id,user.Id);
        }
        
        EntitySubscription[] testESS = new EntitySubscription[noOfItems];
        for (Integer i =0; i<noOfItems; i++) { 
            
            testESS.add(ADM_EntitySubscriptionUtils.createTestWorkEntitySubscriptions(testWorks[i].Id, new List <String> {users[i].Id}).get(0));

        }
        EntitySubscription[] results = ADM_EntitySubscriptionUtils.getAllBy(workIds,userIds);
        System.assert(results.size()==noOfItems);
        Boolean found = false;
        Integer counter =0;
        for(Id id : workToUserMapping.keyset()) {
            
            System.assertEquals(workToUserMapping.get((results[counter].ParentId)), results[counter].subscriberId);
            counter++;

        }
        

    }  

    testMethod static void testgetParentIdSubscriberIdJoinedSetOfEntitySubscribers() {
        List <EntitySubscription>  listESS = new List <EntitySubscription>();
        EntitySubscription[] testESS = new EntitySubscription[1];
        testESS = ADM_EntitySubscriptionUtils.createTestEntitySubscriptions(1);
        listESS.add(testEss[0]);
        Set<String> result = ADM_EntitySubscriptionUtils.getParentIdSubscriberIdJoinedSetOfEntitySubscribers(listESS);
        String joinresult = (String)testESS[0].ParentId + (String)testESS[0].subscriberId;
        System.assert(result.contains(joinresult), 'the join of subscriber id and work ids are not correct');
    }  
    
    testMethod static void testDataCaptureOnEntitySubscriptionsInsertionFailure(){
        
        EntitySubscription[] testESs = new EntitySubscription[1];

        
        EntitySubscription testES = new EntitySubscription(ParentId=UserInfo.getUserId(), subscriberId=UserInfo.getUserId());
        testESs[0] = testES;
        ADM_EntitySubscriptionUtils.insertEntitySubscriptions(testESs);
        
        List<ADM_GUS_Exception__c> gusExceptions = [Select Name, Description__c, Data_Capture__c from ADM_GUS_Exception__c];
        System.debug('size of exception is ' +gusExceptions.size());
        boolean textFound = false;
        
        for (ADM_GUS_Exception__c gE : gusExceptions){
            if(gE.Data_Capture__c.contains('User '+UserInfo.getUserName()+ ' trying to insert ' + testESs.size() +' of EntitySubscription(s) ')){
                textFound = true;
            }
        }
        
        System.assert(true == textFound);
    }
        
        
    
}