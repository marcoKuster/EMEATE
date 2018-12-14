public without sharing class ADM_EntitySubscriptionUtils {

	private static final String FIELD_NAMES = 'Id,ParentId,SubscriberId,IsDeleted';
	private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
	private static final String SQL_FROM = 'from EntitySubscription';


    public static boolean isEntitySubscriber(Id parentId, Id subscriberId) {
        return getAllBy(new List<Id>{parentId}, new List<Id>{subscriberId}).size() > 0;
    }

    public static EntitySubscription[] getAllBy(Id parentId) {
        List<Id> parentIds = new List<Id>();
        parentIds.add(parentId);
        String soqlQuery = getSOQLQuery(parentIds, 'ParentId');

        return Database.query(soqlQuery);
    }

	public static EntitySubscription[] getAllBy(List<Id> parentIds, List<Id> subscriberIds){
        
        String parentIdInClause = '';
        String subscriberIdInClause = '';

        List<EntitySubscription> enitySubscriptions = new List<EntitySubscription>();

        if((null == parentIds && null == subscriberIds) || (0 == parentIds.size() && 0 == subscriberIds.size())){
             enitySubscriptions = new List<EntitySubscription>();
        }
        else{

        	if(null != parentIds && parentIds.size()>0){
        		parentIdInClause = COM_SoqlUtils.createInClause('ParentId', parentIds);
       		}

            if(null != subscriberIds && subscriberIds.size() >0){
        	   subscriberIdInClause = COM_SoqlUtils.createInClause('SubscriberId', subscriberIds);
            }
      
            String sql = getSOQLQuery(parentIdInClause, subscriberIdInClause);
               enitySubscriptions = Database.query(sql);
        }
	
	return enitySubscriptions;
		
	}

	public static EntitySubscription[] getAllBy(Set<Id> parentIdSet, Set<Id> subscriberIdSet){
        List<Id> parentIds = new List<Id>(parentIdSet);
        List<Id> subscriberIds = new List<Id>(subscriberIdSet);

        return getAllBy(parentIds,subscriberIds);

		
	}

    public static EntitySubscription[] getAllById(List<String> enitySubcscriptionIds){
        String sql = getSOQLQuery(enitySubcscriptionIds);
        EntitySubscription[] enitySubscriptions = Database.query(sql);
        return enitySubscriptions;

        
    }

	private static String getSOQLQuery(String parentIdInClause, String subscriberIdInClause){

		String sql = SQL_SELECT + SQL_FROM;

        if(ADM_TextUtils.isBlank(parentIdInClause)){
        	sql += ' where ' + subscriberIdInClause;
        }
        else if(ADM_TextUtils.isBlank(subscriberIdInClause)){
        	sql += ' where ' + parentIdInClause;
        }
        else{
        	// Both parentIdInClause and subscriberIdInClause have value
        	sql += ' where ' + parentIdInClause + ' and ' + subscriberIdInClause;
        }
      
      return sql;

	}

    private static String getSOQLQuery(List<String> values, String columnName){

        String sql = SQL_SELECT + SQL_FROM;
        String idClause = '';
        if(values.size() > 0){
            idClause = ' where '+ COM_SoqlUtils.createInClause(columnName, values);
        }
        
      sql += idClause;
      return sql;

    }

    private static String getSOQLQuery(List<String> ids){

        return getSOQLQuery(ids, 'Id');

    }

	public static Set<String> getParentIdSubscriberIdJoinedSetOfEntitySubscribers(List<EntitySubscription> existingEntitySubscribers){
        Set<String> parentIdSubscriberIdJoinedSet = new Set<String>();
        for(EntitySubscription es: existingEntitySubscribers){
            parentIdSubscriberIdJoinedSet.add(es.ParentId+''+es.SubscriberId);
        }
        return parentIdSubscriberIdJoinedSet;
    }
    /* Utility method to make it easy for the calle to get a map of ParentId+SubscriberId combined values to ParentId key*/
    public static Map<String,EntitySubscription> getParentIdSubscriberKeyToESMap(List<EntitySubscription> existingEntitySubscribers){
        Map<String,EntitySubscription> parentIdSubscriberIdJoinedKey2EntitySubscription = new Map<String,EntitySubscription>();
        for(EntitySubscription es: existingEntitySubscribers){
            parentIdSubscriberIdJoinedKey2EntitySubscription.put(es.ParentId+''+es.SubscriberId, es); //Need this '' in between or be ready to get compilation error that + is only for arithematic operations...
        }
        return parentIdSubscriberIdJoinedKey2EntitySubscription;
    }

   
    public static Set<String> getSubscribersFromEntitySubscribers(List<EntitySubscription> existingEntitySubscribers){
        Set<String> enitySubscriberIds = new Set<String>();
        for(EntitySubscription es: existingEntitySubscribers){
            enitySubscriberIds.add(es.SubscriberId);
        }
        return enitySubscriberIds;
    }

    public static Map<Id, Set<String>> getWorkIdToSubscriberMapFromEntitySubscribers(List<EntitySubscription> existingEntitySubscribers){
        Map<Id, Set<String>> workIdToSubscribersMap = new Map<Id, Set<String>>();

        for(EntitySubscription es: existingEntitySubscribers){
        	if(null != workIdToSubscribersMap.get(es.parentId)){
        		workIdToSubscribersMap.get(es.parentId).add(es.subscriberId);
        	}
        	else{
        		Set<String> subscriberIds = new Set<String>();
        		subscriberIds.add(es.subscriberId);
        		workIdToSubscribersMap.put(es.parentId, subscriberIds);
        	}
            
        }
        return workIdToSubscribersMap;
    }

    public static void deleteEntitySubscriptions(List<EntitySubscription> subscriptions){
        if(null != subscriptions && subscriptions.size() >0){
            try{
                Database.DeleteResult[] subscriptionsDeleteResult = Database.delete(subscriptions, false);
                ADM_ExceptionHandler.saveExceptions(subscriptionsDeleteResult,'ADM_EntitySubscriptionUtils', 'DML error while trying to delete EntitySubscription for WorkRecord', 'Expected number of deletion '+ subscriptions.size(), false);
            }
            catch(System.DmlException dmlE){
                ADM_ExceptionHandler.saveException(dmlE, 'EntitySubscription error happened' + dmlE + ' Line:' + dmlE.getLineNumber() + ' expected entity subscriptions to be removed ' + subscriptions);
            }
        }
    }

    public static void insertEntitySubscriptions(List<EntitySubscription> subscriptions){
       if(null != subscriptions && subscriptions.size() >0){
            try{
                String data = 'User '+UserInfo.getUserName()+ ' trying to insert ' + subscriptions.size() +' of EntitySubscription(s) ';
                Integer counter = 0;
                Database.SaveResult[] subscriptionsSaveResult = Database.insert(subscriptions, false);
                for(Database.SaveResult sr : subscriptionsSaveResult) {
                    if(!sr.isSuccess()) {
                        Set<String>  parentIdSubscriberIdJointSet = getParentIdSubscriberIdJoinedSetOfEntitySubscribers(subscriptions);
                        for(String parentSubscriber :parentIdSubscriberIdJointSet ){
                            counter++;
                            data += counter + '-> ' +  parentSubscriber + ' \n ';
                        }
                        break;//Only needed once to get the data of all the entity subscribers
                    }
                    
                }
                Set<String> parentIdSubscriberIdJointSet = getParentIdSubscriberIdJoinedSetOfEntitySubscribers(subscriptions);
                ADM_ExceptionHandler.saveExceptions(subscriptionsSaveResult,'ADM_EntitySubscriptionUtils', 'DML error while trying to add EntitySubscription ', data, false);
            }
            catch(System.DmlException dmlE){
                ADM_ExceptionHandler.saveException(dmlE, 'EntitySubscription error happened' + dmlE + ' Line:' + dmlE.getLineNumber() + ' expected entity subscribers ' + subscriptions);
            }
        }
    }

    public static EntitySubscription[] createTestEntitySubscriptions(Integer noOfEntitySubscriptions){
        ADM_Work__c[] testWorks = ADM_Work.createListOfWork(noOfEntitySubscriptions,'Bug');
        insert testWorks;
        List<User> users = new List<User>();
        for(Integer indx = 0; indx<noOfEntitySubscriptions; indx++){
            User user = ADM_WorkUser.setupTestUser();
            users.add(user);
        }
        
        insert users;

        EntitySubscription[] testESs = new EntitySubscription[noOfEntitySubscriptions];

        for(Integer indx = 0; indx<noOfEntitySubscriptions; indx++){
            EntitySubscription testES = new EntitySubscription(ParentId=testWorks[indx].Id, subscriberId=users[indx].Id);
            testESs[indx] = testES;
        }
        

        insert testESs;

        return testESs;

    }

    public static EntitySubscription[] createTestWorkEntitySubscriptions(Id workId, List<String> subscribers){
        
        EntitySubscription[] testESs = new EntitySubscription[subscribers.size()];

        for(Integer indx = 0; indx<subscribers.size(); indx++){
            EntitySubscription testES = new EntitySubscription(ParentId=workId, subscriberId=subscribers.get(indx));
            testESs[indx] = testES;
        }
        

        insert testESs;

        return testESs;

    }

	
}