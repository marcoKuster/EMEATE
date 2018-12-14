Global class ADM_WorkUtils {
    public static final String DELIMITER = ':::'; 
    public static final String GUS_URL = URL.getSalesforceBaseUrl().toExternalForm();
    public static final String CHATTER_POST = 'Chatter Post';
    public static final String COMMENT_ON_WORK = 'Comment';
    public static final Integer ASYNC_BATCH_SIZE = 1;
    public static final Boolean IMPORTED_BUGFORCE_BUGS_ARE_EDITABLE = true;
    
    private static final String salesforceDomain = 'salesforce.com';
    private static Map<String, String> domains = new Map<String, String>{  'GUS' => 'gus.com', 'GUS test' => 'gustest.com', 'GUS Pilot (new)' => 'guspilot.com' };
    public static final Set<String> WORK_ENTITY_SUBSCRIBERS = new Set<String>{'Assignee__c', 'QA_Engineer__c', 'Product_Owner__c', 'Tech_Writer__c', 'System_Test_Engineer__c', 'UE_Engineer__c','Senior_Management_POC__c','CS_Contact__c'};
    
    public static Map<String, String> getDomains(){ 
        return domains; 
    }
    
    /**
     * @deprecated Use ADM_TextUtils.removeTrailingComma instead.
     */
    public static String removeTrailingComma(String s) {
        return ADM_TextUtils.removeTrailingComma(s);
    }
    
    public static String getSalesforceDomain(){ 
        return salesforceDomain; 
    }
    
    public static Boolean isId(String sObjectId, String keyPrefix) {
        if(sObjectId.startsWith(keyPrefix) && (sObjectId.length() >= 15 && sObjectId.length() <= 18)) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @deprecated Use ADM_TextUtils.isNoneSelected or ADM_TextUtils.isBlank. 
     * TODO W-1273189 
     */
    public static Boolean isNull(String s) {
        return ADM_TextUtils.isNoneSelected(s);
    }
    
    public static Boolean isValidIdFormat(String Id) {
        if(Id.length() >=15 && Id.length() <=18) {
            return true;
        } else {
            return false;
        }
    }

    public static Boolean isValidId(String Id) {
        try {
            Id testId = Id;
            return true;
        } catch(System.Exception e) {
            return false;
        }
    }
    
    public static List<String> getSortedListFromSet(Set<String> els) {
        List<String> sorted = new List<String>();
        if(els != null && els.size() > 0) {
            sorted.addAll(els);
            sorted.sort();
        }
        return sorted;
    }

    public static String arrayToStringForQuery(List<String> columnValues) {
        Integer inValuesCounter = 0;
        String inValues = '';

        for(String columnValue : columnValues){
            inValuesCounter++;
            inValues = inValues + '\'' + columnValue.trim() + '\'';
            if(inValuesCounter != columnValues.size()){
                inValues = inValues + ',';
            }
        }

        return inValues;
    }
    
    /**
     * Adds the IDs from the assignee fields within the specified work items to the set of user IDs.
     */
    private static void addUserIDsFromWork(Set<Id> userIds, List<ADM_Work__c> works) {
        if(works == null) {
            return;
        }
        
        for(ADM_Work__c w: works) {
            if(w.Assignee__c != null) userIds.add( w.Assignee__c );
            if(w.OwnerId != null) userIds.add( w.OwnerId );
            if(w.QA_Engineer__c != null) userIds.add( w.QA_Engineer__c );
            if(w.Product_Owner__c != null) userIds.add( w.Product_Owner__c );
            if(w.Tech_Writer__c != null) userIds.add( w.Tech_Writer__c );
            if(w.System_Test_Engineer__c != null) userIds.add( w.System_Test_Engineer__c );
            if(w.UE_Engineer__c != null) userIds.add( w.UE_Engineer__c);
            if(w.CS_Contact__c != null) userIds.add(w.CS_Contact__c);
            if(w.Senior_Management_POC__c != null) userIds.add(w.Senior_Management_POC__c);
        }
    }

    /**
     * Gets the values of specified properties from the specified sObjects.
     */
    public static List<String> extractElsFromSobjects(List<Sobject> els, Set<String> names) {
        List<String> returnVars = new List<String>();
        for(Sobject el : els) {
            for(String name : names) {
                try {
                    String value = String.valueOf(el.get(name));
                    if(!ADM_TextUtils.isNoneSelected(value)) {
                        returnVars.add(value);
                    }
                } catch(System.NullPointerException e) {}
            }
        }
        return returnVars;
    }

    /**
     * Extracts value of the specified property from the specified sObjects.
     */
    public static List<String> extractElsFromSobjects(List<Sobject> els,String name) {
        return ADM_WorkUtils.extractElsFromSobjects(els,new Set<String>{name});
    }

    /**
     * Given work objects, retrieve the list of ID values for the specified fields
     */
    public static List<Id> extractIdsFromWork(List<ADM_Work__c> works, Set<String> names) {
        List<Id> ids = new List<Id>();
        for(Sobject s : works) {
            for(String name : names) {
                try {
                    Id id = String.valueOf(s.get(name));
                    ids.add(id);
                } catch(Exception exc) {
                    System.debug('Exception while trying to retrieve \'' + name + '\' from work ' + s.Id);
                }
                
            }
        }
        return ids;
    }

    /**
     * Given work objects, retrieve the list of ID values for the specified field
     */
    public static List<Id> extractIdsFromWork(List<ADM_Work__c> works,String name) {
        return ADM_WorkUtils.extractIdsFromWork(works,new Set<String>{name});
    }
    
    /**
     * Creates a new work cache object from the given work instance.
     * @param nw The work object after the changes
     * @param ow The work object before the changes. If this is an update, this will be null.
     * @param uMap The map of users
     * @param isWorkInsert True if the value is inserted; false otherwise
     */
    private static ADM_Work_Cache__c createWorkCache(ADM_Work__c nw, ADM_Work__c ow, Map<Id, User> uMap, Boolean isWorkInsert) {
        // create the changeList to get the list of things that were changed
        List<Change> changes = null;
        if ( !isWorkInsert ) {
            changes = getChanges(nw, ow, uMap);
        }else {
            changes = getChanges(nw, nw, uMap); //nw is passed twice to compare it to itself as it is an insert
        }
        
        //create work cache object
        ADM_Work_Cache__c wc = new ADM_Work_Cache__c();
        wc.Work__c = nw.id;
		wc.Name = nw.Name;
        wc.User__c = UserInfo.getUserId();
        wc.Has_Been_Opened__c = (isWorkInsert) ? nw.Closed__c == 0 : (ow.Closed__c == 1 && nw.Closed__c == 0);
        wc.Has_Been_Closed__c = (isWorkInsert) ? nw.Closed__c == 1 : (ow.Closed__c == 0 && nw.Closed__c == 1);
        
        ADM_WorkCacheWrapper wrapper = new ADM_WorkCacheWrapper(wc);
        for(Change change : changes) {
            wrapper.addFieldNameWithChange(change.fieldName);
        }
        
        //add any user comments to the changelist
        if( ADM_Comment.wasCommentInserted(nw) ){
            
            //the description within the cache object has a limit on the number of characters it can hold, which is  
            //conveniently the same size as the Comment_Copy__c field. To make all of the changes fit in the cache's 
            //description, we are going to truncate the comment. We truncate it smaller than the max so that it can
            //fit the extra characters used for meta information (like delimiters)
            String newComment = nw.Comment_Copy__c;
            if(newComment.length() > 29000) {
                newComment = newComment.substring(0, 29000);
            }
            
            wrapper.addChangeListDescription(newComment);
            wrapper.addFieldNameWithChange('Comment_Copy__c');
            changes.add(createAddChange('Comment_Copy__c', newComment));
        }
        
        wrapper.setChanges(changes);
        
        return wc;
    }

    public static void processNotifications(List<ADM_Work__c> newWorks, List<ADM_Work__c> oldWorks, Boolean isWorkInsert, Boolean isUpdate, String origin) {
        
        //grab all user ids from user related fields for new work objects, old
        //work objects and the current user
        Set<Id> userIds = new Set<Id>();
        userIds.add(UserInfo.getUserId());
        addUserIDsFromWork(userIds, newWorks);
        addUserIDsFromWork(userIds, oldWorks);
        Map<Id, User> uMap = new Map<Id, User>(ADM_WorkUser.getUsers('id', new List<Id>(userIds)));
        
        //create changelists and cache for async processing
        List<ADM_Work_Cache__c> cachedChangeList = new List<ADM_Work_Cache__c>();
        for(Integer index = 0; index < newWorks.size(); index++) {
            ADM_Work__c newWork = newWorks[index];
            
            ADM_Work__c oldWork = null;
            if(isUpdate) {
                oldWork = oldWorks[index]; 
            }
            
            ADM_Work_Cache__c wc = createWorkCache(newWork, oldWork, uMap, isWorkInsert);
            cachedChangeList.add(wc);
        }
        
        //save the new changelists
        Database.SaveResult[] results = Database.insert(cachedChangeList, false);
        
        //process the save results
        List<ADM_GUS_Exception__c> exceptionNotifications = new List<ADM_GUS_Exception__c>();
        List<String> workCacheIDs = new List<String>();
        Map<Id, ADM_WorkCacheWrapper> workCacheMap = new Map<Id, ADM_WorkCacheWrapper>();
        for(Integer index = 0; index < results.size(); index++) {
            Database.SaveResult sr = results[index];
            if(sr.isSuccess()) {
                workCacheIDs.add(sr.getId());
                workCacheMap.put(cachedChangeList.get(index).Work__c, new ADM_WorkCacheWrapper(cachedChangeList.get(index)));
            } else {
                cachedChangeList.remove(index);
                
                //create a new exception for logging
                exceptionNotifications.add(createSaveResultException(sr, 'email_' + String.valueOf(System.now() + Math.random()), 'An error occurred while trying to save the ADM_Work_Cache__c'));
            }
        }
        
        //store any errors that occurred
        if(!exceptionNotifications.isEmpty()) {
            Database.insert(exceptionNotifications, false); 
        }
        
        //continue processing if a small batch, otherwise use async
        if(newWorks.size() > ASYNC_BATCH_SIZE) {
            System.debug('Processing as async');
            processChangeListAsync(workCacheIDs, isWorkInsert, UserInfo.getUserId(), origin);   
        } else {
            System.debug('Processing as sync');
            processChangeList(workCacheMap, newWorks, isWorkInsert, uMap.get(UserInfo.getUserId()), origin);
        }

    }
    
    @Future
    private static void processChangeListAsync(List<String> workCacheIDs, Boolean isWorkInsert, String userID, String origin) {
        
        //we need to reload all of the work cache information
        Map<Id, ADM_WorkCacheWrapper> workCacheMap = new Map<Id, ADM_WorkCacheWrapper>();
        List<String> workIDs = new List<String>();
        for(ADM_Work_Cache__c wc : [select Has_Been_Opened__c, Has_Been_Closed__c, Work__c, User__c, Field_Names_With_Changes__c, Change_List_Description__c, Changes__c from ADM_Work_Cache__c where Id in:workCacheIDs]) {
            workIDs.add(wc.Work__c);
            workCacheMap.put(wc.Work__c, new ADM_WorkCacheWrapper(wc));
        }
        
        //reload the associated work items
        List<ADM_Work__c> newWorks = ADM_Work.getAllById(workIDs);
        User u = ADM_WorkUser.get(userID);
        
        processChangeList(workCacheMap, newWorks, isWorkInsert, u, origin);
    }
    
    private static void processChangeList(Map<Id, ADM_WorkCacheWrapper> workCacheMap, List<ADM_Work__c> newWorks, Boolean isWorkInsert, User u, String origin) {
        
        List<ADM_ChangeListMessage> messages = createChangeListMessages(workCacheMap, newWorks, isWorkInsert, u);
        if(null != messages){
        //final step email the notifications
        ADM_WorkEmail.sendNotification(messages);
    }
    }
    
    /**
     * Given a list of work objects, create change list messages
     */
    private static List<ADM_ChangeListMessage> createChangeListMessages(Map<Id, ADM_WorkCacheWrapper> workCacheMap, List<ADM_Work__c> newWorks, Boolean isWorkInsert, User u) {
 
        List<EntitySubscription> currentEntitySubscribers = null;

        Set<Id> workIdsFromNewWorks = new Set<Id>();
        for(ADM_Work__c workIter : newWorks){
            workIdsFromNewWorks.add(workIter.Id);
        }
        currentEntitySubscribers = getExistingEntitySubscribersForWorks(workIdsFromNewWorks,new Set<Id>());
        
        
        // No point to proceed further if there is no EntitySubscribers for this work - "Fail Fast"
        if(null != currentEntitySubscribers && currentEntitySubscribers.size() > 0){
        
            Map<Id, Set<String>> workIdToSubscribersMap = ADM_EntitySubscriptionUtils.getWorkIdToSubscriberMapFromEntitySubscribers(currentEntitySubscribers);

            // Map have List of users and below method combine it to single Set to create userCache
            Set<String> entitySubscribersIds = ADM_TextUtils.joinListValues(workIdToSubscribersMap.values());

 
        Boolean notificationFieldChanged = false;
        //Get the record types
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        
        Map<Id, List<ADM_Work_Subscriber__c>> subscribersByWorkID = new Map<Id, List<ADM_Work_Subscriber__c>>();
        try {
            subscribersByWorkID = ADM_Subscriber.getWorkSubscribers(newWorks); // 1 SOQL for entire List
        } catch (System.Exception e) {
            System.debug(LoggingLevel.WARN, 'Unable to retrieve subscribers for the list of work. ' + e);
        }
        
        //lookup all of the users from the work items, including the current user
        //and the subscribers
        Set<Id> userIds = new Set<Id>();
            userIds.addAll(ADM_TextUtils.convertSetOfStringToIds(entitySubscribersIds));
        addUserIDsFromWork(userIds, newWorks);
        userIds.add(u.Id);
        for(List<ADM_Work_Subscriber__c> subscribers : subscribersByWorkID.values()) {
            userIds.addAll(ADM_Subscriber.getUserIds(subscribers));
        }
        ADM_UserCache userCache = new ADM_UserCache(ADM_WorkUser.getUsers('id', new List<Id>(userIds)));
        u = userCache.getById(u.Id);
        
        List<ADM_GUS_Exception__c> exs = new List<ADM_GUS_Exception__c>();
        Map<Id, ADM_ChangeListMessage> messagesByWorkID = new Map<Id, ADM_ChangeListMessage>();
        List<ADM_Work__c> workWithUserGeneratedComments = new List<ADM_Work__c>();
        for(ADM_Work__c nw : newWorks) {
            if(ADM_CreateCommentAction.wasCommentInserted(nw)) {
                workWithUserGeneratedComments.add(nw);
            }
            
            Boolean sendNotification = false;
            ADM_WorkCacheWrapper workCacheWrapper = workCacheMap.get(nw.id);
            String recordTypeName = workRecordTypesById.get(nw.RecordTypeId).Name;
            WorkWrapper workWrapper = new WorkWrapper(nw, subscribersByWorkID.get(nw.Id));
            
            if(workCacheWrapper == null) {
                ADM_GUS_Exception__c ex = new ADM_GUS_Exception__c();
                ex.Name = nw.Id + ' email_' + String.valueOf(System.now() + Math.random());
                ex.Description__c = 'Unexpected error: no Cache Wrapper found for work ' + nw.Id;
                exs.add(ex);
                continue;
            }
            
            if(workCacheWrapper.hasChanges() || isWorkInsert) {
                
                
                //if the work item has been modified, we only send a notification 
                //message if at least one notification fields was modified
                //if the work item is new, we always send a notification message 
                try {
                    if(isWorkInsert) {
                        sendNotification = true;
                    
                    } else {
                    
                        //if any of the notification fields have been changed,
                        //then we need to send the notification
                        for(String fieldName : ADM_Work.getNotificationFields(recordTypeName)) {
                            if(workCacheWrapper.isFieldModified(fieldName)) {
                                sendNotification = true;
                                notificationFieldChanged = true;
                                break;
                            }
                        }
                        
                        /*
                            We should not send double emails in case there was a comment inserted along with other Notification field change, Bug (W-1990842 - https://gus.my.salesforce.com/a07B0000000cQNiIAM)
                            Scenarios are as below
                            1) Change of notification field on a work record (Bug , User story or Investigation), will send email through processNotification method on Work Utils
                            2) Comment inserted with / without change of notification field email send out through Chatter email

                            For the second scenario to happen sendNotification is turned false below 
                        */
                        if(ADM_CreateCommentAction.wasCommentInserted(nw)) {
                            sendNotification = false;
                        }
                    }
                } catch (System.Exception e) {
                    System.debug(LoggingLevel.WARN, 'An error occurred while determining if a notification should be sent. Sending the notification to all addresses. ' + e);
                    sendNotification = true;
                }
                
                //if we've determined that we are sending the notification, then determine who needs to be notified
                List<ADM_ChangeListMessage.Recipient> recipients = new List<ADM_ChangeListMessage.Recipient>();
                if(sendNotification) {
                        recipients.addAll(getToBeNotified(workWrapper, workCacheWrapper, isWorkInsert, userCache, u,notificationFieldChanged, workIdToSubscribersMap));
                }
                
                if(sendNotification && !recipients.isEmpty()) {
                    
                    try {
                        //log the notification
                        exs.add(createNotificationException(nw, recipients));
                    } catch (System.Exception e) {
                        System.debug(LoggingLevel.WARN, 'WARNING:' + e);
                    }
                    
                    //get the a map of field values from the work object
                    Map<String, String> coreValues = ADM_CoreValues.getCoreValues(isWorkInsert, nw, userCache, workRecordTypesById);
                    
                    //create the subject
                    String subjectLine = createSubject(nw, recordTypeName);
                    
                    try {
                    
                        //store variables as a change list message obj for bulk processing outside of the loop
                        messagesByWorkID.put(nw.id, new ADM_ChangeListMessage(coreValues, recipients, subjectLine, new List<FeedItem>(), u));
                    
                    } catch (ADM_ChangeListMessage.AddressLimitException e) {
                        nw.addError(e.getMessage());
                    }
                }
            }
        }
        
        //store comments for bulk insert
        List<ADM_CommentWrapper> commentWrappers = new List<ADM_CommentWrapper>();
        for(ADM_Work__c work : newWorks) {
            ADM_WorkCacheWrapper workCacheWrapper = workCacheMap.get(work.id);
            
            //a cache could be missing if there was an error persisting it
            if(workCacheWrapper == null) {
                continue;
            }
            
            //add the change list description as a comment ready for bulk storage outside of the for loop
            if(workCacheWrapper.hasChanges() || workCacheWrapper.hasChangeListDescriptions()) {
                commentWrappers.add(new ADM_CommentWrapper(work, workCacheWrapper.getChanges(), workCacheWrapper.getChangeListDescriptions(), u));
            }
        }
        List<ADM_Comment__c> combinedComments = ADM_WorkUtils.processComments(commentWrappers);
        
        //if an actual comment was inserted create a chatter post visible on the next generation page
        postCommentsToChatter(workWithUserGeneratedComments, combinedComments); 

        //process team dependencies
        processTeamDependencies(newWorks, workCacheMap, isWorkInsert, !isWorkInsert);
        
        List<FeedItem> getRecentFeedItems = ADM_FeedItemUtil.getRecentFeedItemsByParentId(new List<Id>(messagesByWorkID.keySet()));

        addCurrentChangesAsFeedItem(messagesByWorkID, workCacheMap);

        //tie last 5 feed items with appropriate change list
        matchCommentWithChangeList(messagesByWorkID, getRecentFeedItems);
        
        //insert all of the exceptions that were captured
        insert exs;
        
        return messagesByWorkID.values();
    }
        else{
            return null;
        } 
    }
  
    private static void postCommentsToChatter(List<ADM_Work__c> workList, List<ADM_Comment__c> combinedComments) {  
        //loop work list and only create a chatter post if a user actually entered a comment (vs audit comment) and create a link to the comment id when the post is too long
        try {
            //create a map of comments by work ID for easy retrieval if the comment is too long for the chatter post
            Map<Id, List<ADM_Comment__c>> workMap = ADM_Comment.getCommentListMappedByWorkID(combinedComments);
            List<FeedItem> feeds = new List<FeedItem>();
            // chatter feed suffix in case comment is having more than 1000 characters
            String chatter_feed_suffix = '...  To read more ' + URL.getSalesforceBaseUrl().toExternalForm() + '/';
            for(ADM_Work__c work : workList) {
                if(!ADM_TextUtils.isBlank(work.Comment_Copy__c)){
                    List<ADM_Comment__c> commentList = workMap.get(work.id);
                    Id commentId = null;
                    Id commentAuthor = null;
                    //list of all comments for work record sorted in reverse chronological order so get the first one
                    if(commentList != null && commentList.size() > 0) {
                        commentId = commentList.get(0).Id;
                        commentAuthor = commentList.get(0).Comment_Created_By__c;
                        FeedItem post = new FeedItem();
                        post.ParentId = work.Id;
                        //record the user sending the email not the Email2GUS user -Comment_Created_By__c
                        post.CreatedById = commentAuthor;
                        if(work.Comment_Copy__c.length() > 4500){
                            //trim the max allowed plus allow some breathing room for our link and unexpected ascii or white space characters 
                            post.Body = work.Comment_Copy__c.subString(0,4400) + chatter_feed_suffix + commentId;
                        } else{
                            post.Body = work.Comment_Copy__c;
                        }
                        feeds.add(post);
                    } else {
                        System.debug('WARNING: postCommentsToChatter() unexpected commentList');
                    }
                }
            }
            //insert chatter feeds in bulk
            insert feeds;
        } catch(System.Exception e) {
            ADM_ExceptionHandler.saveException(e, 'Error posting comments to Chatter:' + e + ' Line:' + e.getLineNumber() + ' Comment Data:' + combinedComments + ' Work List:' + workList);
        }
    }
    
    
    
    /**
     * Creates the subject line for the e-mail for the given work object (and recordType name)
     */
    private static String createSubject(ADM_Work__c work, String recordTypeName) {
        String subjectLine = '#' + work.Name + ' - ';
        
        if(recordTypeName.equals(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) && work.Request_RD_Mgr_Review__c) {
            subjectLine += 'Escalated ';
        }
        
        subjectLine += recordTypeName;
        
        if(recordTypeName.equals(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
            subjectLine += ' - Sev ' + work.Severity_Level__c;
        } else if(recordTypeName.equals(ADM_Work.RECORD_TYPE_NAME_BUG)) {
            subjectLine += ' - ' + work.Priority__c;
        }
        
        subjectLine += ' - ' + work.Subject__c;
        
        return subjectLine;
    }
    
    /**
     * Creates a new exception about the specified work item.
     */
    private static ADM_GUS_Exception__c createNotificationException(ADM_Work__c nw, List<ADM_ChangeListMessage.Recipient> recipients){
        
        ADM_GUS_Exception__c ex = new ADM_GUS_Exception__c();
        ex.Name = nw.Id + ' email_' + String.valueOf(System.now() + Math.random());
        
        String exInfo = 'toAddresses: ';
        for(Integer index = 0; index < recipients.size(); index++) {
            ADM_ChangeListMessage.Recipient recipient = recipients.get(index);
            exInfo += recipient.getEmail();
            if(index < recipients.size() - 1){
                exInfo += ', ';
            }
        }
        
        ex.Description__c = exInfo;
        return ex;
    }
    
    /**
     * Creates a new exception about the specified save result.
     */
    private static ADM_GUS_Exception__c createSaveResultException(Database.SaveResult sr, String name, String message) {
        ADM_GUS_Exception__c ex = new ADM_GUS_Exception__c();
        ex.Name = name;
        ex.Description__c = message + ': \n\n';
        for(Database.Error error : sr.getErrors()) {
            ex.Description__c += '[' + error.getStatusCode() + '] ' + error.getMessage() + '\n\n';
        }
        return ex;
    }
    
    testMethod static void testRemovalOfRestrictedAddresses() {
        List<ADM_ChangeListMessage.Recipient> recipients;
        
        ADM_Work__c work = ADM_Work.createTestBug();
        User user = ADM_WorkUser.createTestUser();
        user.Notification_Level__c = 'The Whole Enchilada';
        update user;
        //add the assignee as a subscriber
        ADM_Work_Subscriber__c subscriber = new ADM_Work_Subscriber__c();
        subscriber.WorkId__c = work.Id; 
        subscriber.UserId__c = user.Id;
        insert subscriber;
        user = ADM_WorkUser.get(user.Id);
        work.Email2GUS_Addresses__c = user.Email; //add the subscriber to restricted address
        update work;
        List<ADM_Work_Subscriber__c> subscribers = ADM_Subscriber.getAllBy('workid__c', new List<String>{work.id});
        WorkWrapper workWrapper = new WorkWrapper(work, subscribers);
        ADM_UserCache userCache = new ADM_UserCache(new User[]{user});
        Boolean isInsert = false;
        Boolean notificationFieldChanged = false;
        ADM_Work_Cache__c workCache = createWorkCache(work, work, new Map<Id, User>{user.Id => user}, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper = new ADM_WorkCacheWrapper(workCache);
        
        //test that items are NOT removed when the user is not 'email2gus'
        User u = ADM_WorkUser.createTestUser();
        u = ADM_WorkUser.get(u.Id);
        List<EntitySubscription> currentEntitySubscribers = getExistingEntitySubscribersForWorks(new Set<Id> {work.id},new Set<Id>());
        Map<Id, Set<String>> workIdToSubscribersMap = ADM_EntitySubscriptionUtils.getWorkIdToSubscriberMapFromEntitySubscribers(currentEntitySubscribers);
        System.runAs(u) {
            notificationFieldChanged = true;
            recipients = getToBeNotified(workWrapper, workCacheWrapper, isInsert, userCache, u,notificationFieldChanged,workIdToSubscribersMap);
            Boolean found = false;
            for(ADM_ChangeListMessage.Recipient recipient : recipients) {
                if(recipient.getEmail() == user.Email) {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Expected the method to return the subscriber because the current user is not email2gus');
        }
        
        //change the user so that the last name contains 'email2gus'
        u.LastName = 'email2gus';
        update u;
        u = ADM_WorkUser.get(u.Id);
        System.runAs(u) {
            recipients = getToBeNotified(workWrapper, workCacheWrapper, isInsert, userCache, u, notificationFieldChanged,workIdToSubscribersMap);
            Boolean found = false;
            for(ADM_ChangeListMessage.Recipient recipient : recipients) {
                if(recipient.getEmail() == user.Email) {
                    found = true;
                    break;
                }
            }
            System.assert(!found, 'Expected the method not to return the subscriber because the current user is email2gus and the subscriber was restricted');
        }       
    }
    
    testMethod static void testAssigneesShouldReceiveEmailsOnNotificationFieldChanges() {
        List<ADM_ChangeListMessage.Recipient> recipients;
        Set<String> recipientEmails = new Set<String>();
        
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        User assignee = ADM_WorkUser.createTestUser();
        User qa = ADM_WorkUser.createTestUser();
        User productOwner = ADM_WorkUser.createTestUser();
        User techWriter = ADM_WorkUser.createTestUser();
        User seniorManagerPOC = ADM_WorkUser.createTestUser();
        User csContact = ADM_WorkUser.createTestUser();
        User systemTestEngineer = ADM_WorkUser.createTestUser();
        User ueEngineer = ADM_WorkUser.createTestUser();
        work.Assignee__c = assignee.Id;
        work.QA_Engineer__c = qa.Id;
        work.Product_Owner__c = productOwner.Id;
        work.Tech_Writer__c = techWriter.Id;
        work.Senior_Management_POC__c = seniorManagerPOC.Id;
        work.CS_Contact__c = csContact.Id;
        work.System_Test_Engineer__c = systemTestEngineer.Id;
        work.UE_Engineer__c = ueEngineer.Id;
        
        insert work;
        
        WorkWrapper workWrapper = new WorkWrapper(work, null);
        ADM_UserCache userCache = new ADM_UserCache(new User[]{assignee});
        Boolean isInsert = false;
        Boolean notificationFieldChanged = true;
        ADM_Work_Cache__c workCache = createWorkCache(work, work, new Map<Id, User>{assignee.Id => assignee}, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper = new ADM_WorkCacheWrapper(workCache);
        
        //test that items are NOT removed when the user is not 'email2gus'
        User u = ADM_WorkUser.createTestUser();
        u = ADM_WorkUser.get(u.Id);
        List<EntitySubscription> currentEntitySubscribers = getExistingEntitySubscribersForWorks(new Set<Id> {work.id},new Set<Id>());
        Map<Id, Set<String>> workIdToSubscribersMap = ADM_EntitySubscriptionUtils.getWorkIdToSubscriberMapFromEntitySubscribers(currentEntitySubscribers);
        System.runAs(u) {
            recipients = getToBeNotified(workWrapper, workCacheWrapper, isInsert, userCache, u, notificationFieldChanged, workIdToSubscribersMap);
            for(ADM_ChangeListMessage.Recipient recipient : recipients) {
                    recipientEmails.add(recipient.getEmail());
                }
            }
            
        System.assert(recipientEmails.contains(assignee.Email), 'Expected the method to return the assignee because Assignee will be notified by Chatter email');
        System.assert(recipientEmails.contains(qa.Email), 'Expected the method to return the qa email because qa will be notified by Chatter email');
        System.assert(recipientEmails.contains(productOwner.Email), 'Expected the method to return the productOwner email because productOwner will be notified by Chatter email');
        System.assert(recipientEmails.contains(techWriter.Email), 'Expected the method to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(recipientEmails.contains(seniorManagerPOC.Email), 'Expected the method to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(recipientEmails.contains(csContact.Email), 'Expected the method to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(recipientEmails.contains(systemTestEngineer.Email), 'Expected the method to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(recipientEmails.contains(ueEngineer.Email), 'Expected the method to return the techWriter email because techWriter will be notified by Chatter email');
        
            
    }
    //No email for assignees on comment as comment becomes -> chatter -> sends email from there
    testMethod static void testAssigneesShouldNotReceiveEmailOnComment() {
        List<ADM_ChangeListMessage.Recipient> recipients;
        Set<String> recipientEmails = new Set<String>();
        
        ADM_Work__c work = ADM_Work.createTestBug();
        User assignee = ADM_WorkUser.createTestUser();
        User qa = ADM_WorkUser.createTestUser();
        User productOwner = ADM_WorkUser.createTestUser();
        User techWriter = ADM_WorkUser.createTestUser();
        User seniorManagerPOC = ADM_WorkUser.createTestUser();
        User csContact = ADM_WorkUser.createTestUser();
        User systemTestEngineer = ADM_WorkUser.createTestUser();
        User ueEngineer = ADM_WorkUser.createTestUser();
        work.Assignee__c = assignee.Id;
        work.QA_Engineer__c = qa.Id;
        work.Product_Owner__c = productOwner.Id;
        work.Tech_Writer__c = techWriter.Id;
        work.Senior_Management_POC__c = seniorManagerPOC.Id;
        work.CS_Contact__c = csContact.Id;
        work.System_Test_Engineer__c = systemTestEngineer.Id;
        work.UE_Engineer__c = ueEngineer.Id;
        update work;
        
        //Adding comment (2nd updation on work item)
        work.Comment_copy__c = 'Test comment for this work';
        update work;
        
        WorkWrapper workWrapper = new WorkWrapper(work, null);
        ADM_UserCache userCache = new ADM_UserCache(new User[]{assignee});
        Boolean isInsert = false;
        Boolean notificationFieldChanged = false;
        ADM_Work_Cache__c workCache = createWorkCache(work, work, new Map<Id, User>{assignee.Id => assignee}, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper = new ADM_WorkCacheWrapper(workCache);
        
        //test that items are NOT removed when the user is not 'email2gus'
        User u = ADM_WorkUser.createTestUser();
        u = ADM_WorkUser.get(u.Id);
        List<EntitySubscription> currentEntitySubscribers = getExistingEntitySubscribersForWorks(new Set<Id> {work.id},new Set<Id>());
        Map<Id, Set<String>> workIdToSubscribersMap = ADM_EntitySubscriptionUtils.getWorkIdToSubscriberMapFromEntitySubscribers(currentEntitySubscribers);
        System.runAs(u) {
            recipients = getToBeNotified(workWrapper, workCacheWrapper, isInsert, userCache, u, notificationFieldChanged, workIdToSubscribersMap);
            for(ADM_ChangeListMessage.Recipient recipient : recipients) {
                    recipientEmails.add(recipient.getEmail());
                }
            }
            
        System.assert(!recipientEmails.contains(assignee.Email), 'Expected the method not to return the assignee because Assignee will be notified by Chatter email');
        System.assert(!recipientEmails.contains(qa.Email), 'Expected the method not to return the qa email because qa will be notified by Chatter email');
        System.assert(!recipientEmails.contains(productOwner.Email), 'Expected the method not to return the productOwner email because productOwner will be notified by Chatter email');
        System.assert(!recipientEmails.contains(techWriter.Email), 'Expected the method not to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(!recipientEmails.contains(seniorManagerPOC.Email), 'Expected the method not to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(!recipientEmails.contains(csContact.Email), 'Expected the method not to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(!recipientEmails.contains(systemTestEngineer.Email), 'Expected the method not to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(!recipientEmails.contains(ueEngineer.Email), 'Expected the method not to return the techWriter email because techWriter will be notified by Chatter email');
        
            
    }
    
    testMethod static void testAssigneesShouldReceiveEmailOnChatterPost() {
        List<ADM_ChangeListMessage.Recipient> recipients;
        Set<String> recipientEmails = new Set<String>();
        
        ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P1');
        User assignee = ADM_WorkUser.setupTestUser();
        User qa = ADM_WorkUser.setupTestUser();
        User productOwner = ADM_WorkUser.setupTestUser();
        User techWriter = ADM_WorkUser.setupTestUser();
        User seniorManagerPOC = ADM_WorkUser.setupTestUser();
        User systemTestEngineer = ADM_WorkUser.setupTestUser();
        User ueEngineer = ADM_WorkUser.setupTestUser();
        User subscriber1 = ADM_WorkUser.setupTestUser();
        User subscriber2 = ADM_WorkUser.setupTestUser();
        

        subscriber1.Email = 'subscriber1@test.com';
        subscriber2.Email = 'subscriber2@test.com';

        assignee.Email = 'test1@test.com';
        qa.Email = 'test2@test.com';
        productOwner.Email = 'test3@test.com';
        techWriter.Email = 'test4@test.com';
        seniorManagerPOC.Email = 'test5@test.com';
        systemTestEngineer.Email = 'test7@test.com';
        ueEngineer.Email = 'test8@test.com';



        insert new User[]{assignee,qa,productOwner,techWriter,seniorManagerPOC,systemTestEngineer,ueEngineer,subscriber1,subscriber2};



        work.Assignee__c = assignee.Id;
        work.QA_Engineer__c = qa.Id;
        work.Product_Owner__c = productOwner.Id;
        work.Tech_Writer__c = techWriter.Id;
        work.Senior_Management_POC__c = seniorManagerPOC.Id;
        work.System_Test_Engineer__c = systemTestEngineer.Id;
        work.UE_Engineer__c = ueEngineer.Id;
        
        insert work;


        
        ADM_UserCache userCache = new ADM_UserCache(new User[]{assignee,qa,productOwner,techWriter,seniorManagerPOC,systemTestEngineer,ueEngineer,subscriber1,subscriber2});
        
       
        
        User u = ADM_WorkUser.createTestUser();
        u = ADM_WorkUser.get(u.Id);

        Set<String> subscribers = new Set<String> ();
        subscribers.add(assignee.id);
        subscribers.add(qa.id);
        subscribers.add(productOwner.id);
        subscribers.add(techWriter.id);
        subscribers.add(seniorManagerPOC.id);
        subscribers.add(systemTestEngineer.id);
        subscribers.add(ueEngineer.id);

        subscribers.add(subscriber1.id);
        subscribers.add(subscriber2.id);

        Map<Id, Set<String>> workIdToSubscribersMap = new Map<Id, Set<String>> ();
        workIdToSubscribersMap.put(work.id, subscribers);

        System.runAs(u) {
            recipients = getToBeNotified(work, userCache, u, workIdToSubscribersMap,CHATTER_POST);
            for(ADM_ChangeListMessage.Recipient recipient : recipients) {
                    recipientEmails.add(recipient.getEmail());
        }       
    }

        System.assert(recipientEmails.contains(assignee.Email), 'Expected the method to return the assignee because Assignee will be notified by Chatter email');
        System.assert(recipientEmails.contains(qa.Email), 'Expected the method to return the qa email because qa will be notified by Chatter email');
        System.assert(recipientEmails.contains(productOwner.Email), 'Expected the method to return the productOwner email because productOwner will be notified by Chatter email');
        System.assert(recipientEmails.contains(techWriter.Email), 'Expected the method to return the techWriter email because techWriter will be notified by Chatter email');
        System.assert(recipientEmails.contains(seniorManagerPOC.Email), 'Expected the method to return the Senior Manager POC email because Senior Manager POC will be notified by Chatter email');
        System.assert(recipientEmails.contains(systemTestEngineer.Email), 'Expected the method to return the System Test Engineer email because System Test Engineer will be notified by Chatter email');
        System.assert(recipientEmails.contains(ueEngineer.Email), 'Expected the method to return the UE Engineer email because UE Engineer will be notified by Chatter email');
        System.assert(recipientEmails.contains(subscriber1.Email), 'Expected the method to return the Subscriber1 email because all entity subscribers will be notified by Chatter email');
        System.assert(recipientEmails.contains(subscriber2.Email), 'Expected the method to return the Subscriber2 email because all entity subscribers will be notified by Chatter email');
        
            
    }

    private static List<ADM_Comment__c> processComments(List<ADM_CommentWrapper> commentWrappers) {
        //bulk insert
        ADM_CreateCommentAction.save(commentWrappers);
        
        //reload all of the comments that were saved
        List<Id> workIDs = new List<Id>();
        List<ADM_Comment__c> comments = new List<ADM_Comment__c>();
        for(ADM_CommentWrapper cw : commentWrappers) {
            workIDs.add(cw.work.Id);
        }
        if(!workIDs.isEmpty()) {
            comments = ADM_Comment.getAllCommentsForWork(workIDs);
        }
        return comments; 
    }
 
    private static void addCurrentChangesAsFeedItem(Map<Id, ADM_ChangeListMessage> messagesByWorkID, Map<Id, ADM_WorkCacheWrapper> workCacheMap) {
        User currentUser = ADM_WorkUser.get(UserInfo.getUserId());
        Map<String, ADM_FieldWrapper> ALL_FIELDS_MAP = ADM_Work.getMapOfFieldNameLabelPairs();
        for(Id workId: workCacheMap.keySet()) {
             
            if(messagesByWorkID.containsKey(workId)) {
                FeedItem newFeedItem = new FeedItem();
                newFeedItem.parentId = workId;
                newFeedItem.CreatedDate = System.now();
                
                for(Change change: workCacheMap.get(workId).getChanges()){
                    String fieldLabel = change.fieldName;
                    //Ignore if comment_copy__c field
                    if(fieldLabel.containsIgnoreCase('Comment_Copy__c')){
                        //No need to send comment in email 
                        continue;
                    }
                    
                    String oldValue = '';
                    String newValue ='';
                    if(ADM_TextUtils.isBlank(change.oldValue)){
                        oldValue = 'a blank value';
                    } 
                    else{
                        oldValue = change.oldValue;
                    }

                    if(ADM_TextUtils.isBlank(change.newValue)){
                        newValue = 'a blank value';
                    } 
                    else{
                        newValue = change.newValue;
                    }
                    
                    if(null !=  ALL_FIELDS_MAP.get(change.fieldName)){
                        fieldLabel = ALL_FIELDS_MAP.get(change.fieldName).fieldLabel;
                    }
                    if(newFeedItem.Body == null){
                        newFeedItem.Body = '';
                    }
                    newFeedItem.Body +=   fieldLabel + ' changed  from ' + oldValue + ' to '+ newValue + ' <br/>';
               }
                ADM_ChangeListMessage message = messagesByWorkID.get(workId);
                message.posts.add(newFeedItem);
            }
        }
    }
 
    private static void matchCommentWithChangeList(Map<Id, ADM_ChangeListMessage> messagesByWorkID, List<FeedItem> feedItems) {

        for(FeedItem feedItem : feedItems) {
            if(messagesByWorkID.containsKey(feedItem.parentId)) {
                ADM_ChangeListMessage message = messagesByWorkID.get(feedItem.parentId);
                message.posts.add(feedItem);
            }
        }
    }
    
    testMethod static void testToChangeListMessageWhenQAEngineerChanged() {
        ADM_Work__c newWork = ADM_Work.createTestWork();
        ADM_Work__c oldWork = ADM_Work.createTestWork();
        
        Boolean isWorkInsert = false;

        processNotifications(new List<ADM_Work__c>{newWork}, new List<ADM_Work__c>{oldWork}, isWorkInsert, !isWorkInsert, ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN);
    }
    
     /* We track a last modified date when certain fields change.  Typically this time stamp is
        used by formula fields i.e. number of days between today and the date the scrum team was
        last modified.  Can't query Field History from Formula field so this is necessary
    */
    public static void trackFieldChanges(List<ADM_Work__c> worksNew, List<ADM_Work__c> worksOld) {
        if( Trigger.isInsert ) {
            for(Integer i = 0; i < worksNew.size(); i++) {
                if ( worksNew.get(i).Scrum_Team__c != null )
                    worksNew.get(i).Scrum_Team_Last_Modified__c = System.now();
            }
        }
        else if(Trigger.isUpdate) {
            for(Integer i = 0; i < worksNew.size(); i++) {
                if(worksNew.get(i).Scrum_Team__c != worksOld.get(i).Scrum_Team__c) {
                    worksNew.get(i).Scrum_Team_Last_Modified__c = System.now();
                }
            }
        }
    }

   /*
      @testcaseID TO BE ADDED
      @hierarchy TO BE ADDED
      @userstory TO BE ADDED
      @expectedResults: Scrum Team Last Modified field is updated
      @author jhatton
    */
    static testMethod void testScrumTeamLastModifiedIsUpdatedWhenScrumTeamChanges() {
        Test.startTest();
        ADM_Work__c work = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        Test.stopTest();
        work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
        System.assert(work.Scrum_Team_Last_Modified__c != null); // since we now add on insert as well
         ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('New Team Name Test');
       
        work.Scrum_Team__c = team.id;
        update work;
        work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
        System.assert(work.Scrum_Team_Last_Modified__c != null);
        System.assertEquals(0, work.Age_With_Scrum_Team__c);

    }

    /*
      @testcaseID TO BE ADDED
      @hierarchy TO BE ADDED
      @userstory TO BE ADDED
      @expectedResults: Scrum Team Last Modified field is not updated when scrum team remains constant
      @author jhatton
    */
     
    static testMethod void testScrumTeamLastModifiedIsNotUpdatedIfScrumTeamRemainsTheSame() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('New Team Name Test');
        work.Scrum_Team__c = team.id;
        update work;
        work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
        Datetime lastMod = work.Scrum_Team_Last_Modified__c;
        work.Subject__c = '123';
        update work;
        work = [select id, Scrum_Team_Last_Modified__c, Age_With_Scrum_Team__c from ADM_Work__c where id = :work.id];
        System.assert(work.Scrum_Team_Last_Modified__c != null);
        System.assertEquals(0, work.Age_With_Scrum_Team__c);
        //verfiy original time stamp remains as the last edit did not effect the scrum team
        System.assertEquals(lastMod, work.Scrum_Team_Last_Modified__c);
    }
    /**
     *
     * @param elOld The previous sObject
     * @param elNew The new sObject
     * @param elFieldName The field within the sObject to use in the display
     */
    private static Change getSObjectChange(SObject elOld, SObject elNew, String elFieldName){

        Change change = null;
        
        if(elOld == null && elNew == null) {
            //objects are same so they haven't changed
        } else if( (elNew == null || elNew.Id == null) && (elOld != null && elOld.Id != null) ){
            change = createRemoveChange(elFieldName, toString(elOld.get(elFieldName)));
            
        } else if( (elOld == null || elOld.Id == null) && (elNew != null && elNew.Id != null) ){
            change = createAddChange(elFieldName, toString(elNew.get(elFieldName)));
            
        } else if( (elOld != null && elOld.Id != null) && (elNew != null && elNew.Id != null) && (elOld.id != elNew.Id)){
            
            String newValue = toString(elNew.get(elFieldName));
            String oldValue = toString(elOld.get(elFieldName));
            change = createModifyChange(elFieldName, oldValue, newValue);
            
        }

        return change;
    }
    
    testMethod static void testGetSObjectChange(){
        ADM_Work__c oldWork = ADM_Work.createTestWork();
        oldWork = ADM_Work.getById(oldWork.Id);
        
        ADM_Work__c newWork = oldWork.clone(false,true);
        newWork.Status__c = 'Closed';
        newWork.Assignee__c = null;
        newWork.Priority__c = null;
        upsert newWork;
        
        Change change1 = getSObjectChange(oldWork, newWork, 'Status__c');
        System.assert(change1 != null, 'Expected the change to status to be detected');
        System.assertEquals('Status__c', change1.fieldName, 'Expected fieldName to be the value specified from getSObjectChange');
        System.assertEquals('M', change1.typeCode, 'Expected the changeType to be MODIFY because the status was changed to Closed');
        
        Change change2 = getSObjectChange(newWork, newWork, 'Status__c');
        System.assert(change2 == null, 'Expected no change to be returned because the values are the same.');
    }

    private static String cleanupFKName(String fieldName) {
        if(ADM_Work.FK_VALUES_MAP.containsKey(fieldName)) {
            return fieldName.replace('_Name__c','__c');
        } else {
            return fieldName;
        }
    }
    
    /**
     * Returns back a list of changes between the given work objects.
     */
    private static List<Change> getChanges(ADM_Work__c nw, ADM_Work__c ow, Map<Id, User> uMap) {
        
        List<Change> changes = new List<Change>();
        SObject sOld = ow;
        SObject sNew = nw;
        
        //compare the user lookup fields and add a string description of any changes to the changelist
        Set<String> userFields = ADM_Work.USER_FIELDS_MAP.keySet();
        for(String fieldName: userFields) {
            try {
                if((sOld.get(fieldName) == null && sNew.get(fieldName) == null) || sOld.get(fieldName) == sNew.get(fieldName)) {
                    continue;
                }
                
                //weird syntax issue apex won't allow you to treat object id as string and vice versa when using dynamic get() syntax
                User uOld, uNew = null;
                if(sOld.get(fieldName) != null) {
                    uOld = uMap.get(toString(sOld.get(fieldName)).trim());
                }
                if(sNew.get(fieldName) != null) {
                    uNew = uMap.get(toString(sNew.get(fieldName)).trim());
                }
                
                //try to detect a change to the name property of the sObject
                Change change = getSObjectChange(uOld, uNew, 'Name');
                if(change != null) {
                    //override the name of the property with parent property
                    change.fieldName = fieldName;
                    changes.add(change);
                }
                
            } catch(System.Exception e ){
                try {
                    System.debug('ADM_WorkUtils.getChanges()  Exception while comparing USER fields. Line:' + e.getLineNumber() + ' e:' + e);
                    ADM_ExceptionHandler.saveException(e, 'ADM_WorkUtils.getChanges()  Exception while comparing USER fields. Line:' + e.getLineNumber() + ' e:' + e + '  Current Field:' + fieldName + ' field map:' + userFields + ' UserInfo.getUserID():' +   UserInfo.getUserId() + ' Name:' + UserInfo.getName() + ' Comments nw.Comment_Copy__c:' + nw.Comment_Copy__c);
                } catch(System.Exception e2 ){
                    //log the error
                    System.debug('Failed to save exception:' + e2 + ' UserInfo.getUserID():' + UserInfo.getUserId());
                }
            }
        }
        
        //compare the simple (not a lookup to another object) fields and add a string description of any changes to the changelist
        Map<String, ADM_FieldWrapper> textFieldsMap = new Map<String, ADM_FieldWrapper>();
        textFieldsMap.putAll(ADM_Work.TEXT_FIELDS_MAP);
        textFieldsMap.putAll(ADM_Work.FK_VALUES_MAP);
        for(String fieldName: textFieldsMap.keySet()) {
            try {
                //same so no changes
                if((sNew.get(fieldName) == null && sOld.get(fieldName) == null) || toString(sNew.get(fieldName)) == toString(sOld.get(fieldName))) {
                    continue;
                }
                
                String cleanFieldName = cleanupFKName(fieldName);
                
                if(sNew.get(fieldName) == null){
                    
                    changes.add(createRemoveChange(cleanFieldName, sOld.get(fieldName)));
                    
                } else if(sOld.get(fieldName) == null){
                    
                    changes.add(createAddChange(cleanFieldName, sNew.get(fieldName)));
                    
                } else {
                    
                    changes.add(createModifyChange(cleanFieldName, sOld.get(fieldName), sNew.get(fieldName)));
                    
                }
            } catch(System.Exception e ){
                try {
                    System.debug('ADM_WorkUtils.getChanges()  Exception while comparing fields. Line:' + e.getLineNumber() + ' e:' + e);
                    ADM_ExceptionHandler.saveException(e, 'ADM_WorkUtils.getChanges()  Exception while comparing fields. Line:' + e.getLineNumber() + ' e:' + e + '  Current Field:' + fieldName + ' field map:' + textFieldsMap + ' Comments nw.Comment_Copy__c:' + nw.Comment_Copy__c);
                } catch(System.Exception e2 ){
                    System.debug('Failed to save exception:' + e2);
                }
            }
        }
        return changes;
    }
    
    /**
     * Creates a new change for when a field is removed
     */
    private static Change createRemoveChange(String fieldName, Object oldValue) {
        String oldValueAsString = toString(oldValue);
        
        Change change = new Change();
        change.typeCode = 'R';
        change.fieldName = fieldName;
        change.oldValue = oldValueAsString;
        change.newValue = null;
        return change;
    }
    
    /**
     * Creates a new change for when a field is added
     */
    private static Change createAddChange(String fieldName, Object newValue) {
        String newValueAsString = toString(newValue);
        
        Change change = new Change();
        change.typeCode = 'A';
        change.fieldName = fieldName;
        change.oldValue = null;
        change.newValue = newValueAsString;
        return change;
    }
    
    /**
     * Creates a new change for when a field is modified
     */
    private static Change createModifyChange(String fieldName, Object oldValue, Object newValue) {
        String oldValueAsString = toString(oldValue);
        String newValueAsString = toString(newValue);
        
        Change change = new Change();
        change.typeCode = 'M';
        change.fieldName = fieldName;
        change.oldValue = oldValueAsString;
        change.newValue = newValueAsString;
        return change;
    }
    
    /**
     * Converts the given value into a String for display. If the value is a null
     * reference, a null reference is returned. 
     *
     * FIXME Isn't this the same as String.valueOf()?
     */
    private static String toString(Object value) {
        if(value == null) {
            return null;
        }
        return String.valueOf(value);
    }
    
    testMethod static void testGetChanges(){
        ADM_Work__c oldWork = ADM_Work.createTestBug();
        upsert oldWork;
        oldWork = ADM_Work.getById(oldWork.Id);
        
        //create a copy of the work object
        ADM_Work__c newWork = oldWork.clone(false,true);
        
        User user_1 = ADM_WorkUser.createTestUser();
        Map<Id, User> userMap = new Map<Id, User>{user_1.Id => user_1};
        
        ADM_Build__c build_1 = ADM_Build.createTestBuild();

        newWork.Priority__c = null;
        newWork.Status__c = 'In Progress';
        newWork.Perforce_Status__c = 'Open';
        newWork.Assignee__c = user_1.Id;
        newWork.Product_Owner__c = user_1.Id;
        newWork.System_Test_Engineer__c = user_1.Id;
        newWork.Tech_Writer__c = user_1.Id;
        newWork.QA_Engineer__c = user_1.Id;
        newWork.UE_Engineer__c = user_1.Id;
        newWork.Scheduled_Build__c = build_1.Id;
        upsert newWork;
        newWork = ADM_Work.getAllBy('Id', new List<String>{newWork.Id}, 0, 10000, 'Id', 'ASC')[0];
        
        //Changes to priority have to occur after the update/insert because 
        //it will fail due to validation errors
        oldWork.Priority__c = 'P0';
        newWork.Priority__c = 'P1';
        
        Set<String> changedFields = new Set<String>{
            'Status__c', 
            'Perforce_Status__c', 
            'Assignee__c', 
            'Product_Owner__c', 
            'System_Test_Engineer__c', 
            'Tech_Writer__c', 
            'QA_Engineer__c', 
            'UE_Engineer__c', 
            'Scheduled_Build__c',
            'Priority__c'};
        
        List<Change> changes = ADM_WorkUtils.getChanges(newWork, oldWork, userMap);
        
        //check to see if all of the expected fields are found
        List<String> notFoundChanges = new List<String>();
        for(String changedField : changedFields) {
            Boolean found = false;
            for(Change c : changes) {
                if(changedField.equalsIgnoreCase(c.fieldName)) {
                    found = true;
                    break;
                }
            }
            
            if(!found) {
                notFoundChanges.add(changedField);
            }
        }
        System.assert(notFoundChanges.isEmpty(), 'Expected to find the following changes: ' + notFoundChanges);
        
        //check to see if there are unexpected fields found
        List<String> unexpectedChanges = new List<String>();
        for(Change c : changes) {
            Boolean found = false;
            for(String changedField : changedFields) {
                if(changedField.equalsIgnoreCase(c.fieldName)) {
                    found = true;
                    break;
                }
            }
            
            if(!found) {
                unexpectedChanges.add(c.fieldName);
            }
        }
        System.assert(unexpectedChanges.isEmpty(), 'Did not expect to find the following changes: ' + unexpectedChanges);
    }
    
    /**
     * Given the work object, all of the users who receive notifications associate to the work object
     * are returned. The user is only returned if found in the map. 
     */
    private static List<User> getUsersWhoReceiveNotificationsFromWork(ADM_Work__c w, ADM_UserCache userCache, String mailOrigin) {
        mailOrigin = (null == mailOrigin)? COMMENT_ON_WORK: mailOrigin;
        List<User> users = new List<User>();
        SObject sObj = w;
        
        for(String field : ADM_Work.USERS_WHO_RECEIVE_NOTIFICATION_FOR_WORK) {
            try {
                if(sObj.get(field) != null) {
                    //weird syntax issue apex won't allow you to treat object id as string and vice versa when using dynamic get() syntax
                    String id = String.valueOf(sObj.get(field)).trim();
                    User u = userCache.getById(id);
                    if(u == null) {
                        System.debug(LoggingLevel.WARN, 'User in work object not found in user map: ' + id);
                    }
                    else if(u.Email != null) {
                        if(validateUserForChatterPostEmail(u, mailOrigin)){
                            //Not current user if current user
                        users.add(u);
                    }
                }
                }
            } catch(System.Exception e) {
                System.debug('WARNING: Exception:' + e);
            }
        }
        return users;
    }
    
    
    /**
     * Determines if the specified user was added as an assignee to the work cache
     */
    private static Boolean wasUserAddedAsAssignee(ADM_WorkCacheWrapper workCacheWrapper, User user) {
        Set<String> assigneeFields = ADM_Work.USER_FIELDS_MAP.keySet();
        for(String field : assigneeFields) {
            Change change = workCacheWrapper.getChangeByFieldName(field);
            if(change != null) {
                if(change.newValue == user.Name) {
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
     * Determines if the user wants to recieve notifications about the given
     * work changes.
     */
    private static Boolean doesUserWantNotification(User user, WorkWrapper workWrapper, ADM_WorkCacheWrapper workCacheWrapper, Boolean isInsert) {
        
        //Standard Notification Levels
        //   'Bread & Butter' - No notifications except when added as an assignee or subscriber
        //   'Meat & Potatoes' - User comments and status changes (when I'm an assignee or subscriber) and when added as an assignee or subscriber
        //   'The Whole Enchilada' - All notifications including when I'm removed as an assignee
        
        String settingName = user.Notification_Level__c;
        //if the user has not selected one, then default to always use 'The Whole Enchilada' 
        if(ADM_TextUtils.isNoneSelected(settingName)) {
            settingName = 'The Whole Enchilada';
        }
        
        //if the user wants to receive notification on any field change
        if(settingName == 'Bread & Butter') {
            //check to see if a comment was added
            Boolean commentAdded = workCacheWrapper.isFieldModified('Comment_Copy__c');
            
            Boolean addedAsAssignee = wasUserAddedAsAssignee(workCacheWrapper, user);
            return addedAsAssignee || isInsert || commentAdded;
            
        } else if(settingname == 'Meat & Potatoes') {
            //check to see if a comment was added
            Boolean commentAdded = workCacheWrapper.isFieldModified('Comment_Copy__c');
            
            //check to see if the status was changed
            Boolean statusChanged = wasStatusChanged(workCacheWrapper);
            Boolean isSubscriber = workWrapper.isAssignee(user) || workWrapper.isSubscriber(user);
            Boolean addedAsAssignee = wasUserAddedAsAssignee(workCacheWrapper, user);
            
            return addedAsAssignee ||  isInsert || commentAdded || statusChanged;
            
        } else if(settingName == 'The Whole Enchilada') {
            return true;
        }
        
        System.debug(LoggingLevel.WARN, 'Users notification preference could not be determined. Allowing all notifications');
        return true;
    }
    
    private static void processTeamDependencies(List<ADM_Work__c> newWorks, Map<Id, ADM_WorkCacheWrapper> workCacheMap, Boolean isInsert, Boolean isUpdate) {
        try{
            if(isUpdate) {
                //Set<Id> workClosed = new Set<Id>();
               // Set<Id> workOpened = new Set<Id>();
                Map<String,ADM_Work__c> workId2ObjectMap = new Map<String,ADM_Work__c>();
                Set<Id> workUpdatedSprintOrBuild = new Set<Id>();
                
                for(ADM_Work__c nw : newWorks) {
                    ADM_WorkCacheWrapper workCacheWrapper = workCacheMap.get(nw.id);
                    ADM_Work_Cache__c wc = workCacheWrapper.getWorkCache();

                    Change statusFieldChange = workCacheWrapper.getChangeByFieldName('Status__c');

                    if(statusFieldChange != null){
                         if( statusFieldChange.oldValue != null && statusFieldChange.oldValue.equalsIgnoreCase('Never') && 
                             ADM_Work.CLOSED_LIKE_STATUSES.contains(statusFieldChange.newValue.toLowerCase())){
                             workId2ObjectMap.put(nw.Id, nw);
                        }
                        else if( statusFieldChange.newValue != null && statusFieldChange.newValue.equalsIgnoreCase('Never')){
                             workId2ObjectMap.put(nw.Id, nw);
                        }
                    }
                    if(workId2ObjectMap.get(nw.Id) == null){
                        if(wc.Has_Been_Opened__c) {
                            System.debug(' Code path A0-WorkUtils');
                           // workOpened.add(nw.Id);
                            workId2ObjectMap.put(nw.Id, nw);
                        }
                        if(wc.Has_Been_Closed__c) {
                            System.debug(' Code path A1-WorkUtils');
                           // workClosed.add(nw.Id);
                            workId2ObjectMap.put(nw.Id, nw);
                        }  
                    }  
                    
                    
                    
                    //if the sprint or scheduled build was changed, then we
                    //need to send a UserStory update message
                    for(String fieldName: workCacheWrapper.getFieldNamesWithChanges()) {
                        if(fieldName.toLowerCase().contains('sprint') || fieldName.toLowerCase().contains('scheduled_build')) {
                            workUpdatedSprintOrBuild.add(nw.Id);
                            break;
                        }
                    }
                }
                ADM_TeamDependencyUtils.updateTeamDependenciesBasedOnWorkStatus(workId2ObjectMap);
               // ADM_TeamDependencyUtils.closeTeamDependencies(workClosed);
               // ADM_TeamDependencyUtils.openTeamDependencies(workOpened);
                ADM_TeamDependencyUtils.asyncSendUserStoryUpdateMessage(workUpdatedSprintOrBuild);
            }
        }
        catch(Exception e){
            ADM_ExceptionHandler.saveException(e, 'Exception in ProcessTeamDependencies method');
        }
    }
    
    /**
     * Gets the email addresses of the Users and distribution lists to be notified for the specified work item.
     getToBeNotified - used by field updates
     */
    private static List<ADM_ChangeListMessage.Recipient> getToBeNotified(WorkWrapper work, ADM_WorkCacheWrapper workCacheWrapper, Boolean isInsert, ADM_UserCache userCache, User currentUser,Boolean notificationFieldChanged, Map<Id, Set<String>> workIdToSubscribersMap) {
        Set<Id> recipientUserIds = new Set<Id>();
        Set<String> recipientEmails = new Set<String>();
        Set<ADM_ChangeListMessage.Recipient> recipients = new Set<ADM_ChangeListMessage.Recipient>();
        Set<ADM_ChangeListMessage.Recipient> recipientsOnWork = getRecipientsForWork(work.work, userCache, currentUser, workIdToSubscribersMap, 'New Work',recipientUserIds);
        
        if(isInsert ||  notificationFieldChanged){
            recipients = recipientsOnWork;
        }
        
        //if it was an insert, then add the user who initiated the notification
        if(isInsert && currentUser.Email != null && !recipientUserIds.contains(currentUser.Id) && canAddUserToRecipientList(work.work,null,currentUser)) {
            recipientUserIds.add(currentUser.Id);
            recipientEmails.add(currentUser.Email.toLowerCase());
            recipients.add(new ADM_ChangeListMessage.UserRecipient(currentUser));
        }
        
                   
        
        //check the user settings to see if the user wants to receive the notification
        for(ADM_ChangeListMessage.Recipient recipient : recipients) {
            if(!(recipient instanceof ADM_ChangeListMessage.UserRecipient)) {
                continue;
            }
            User user = ((ADM_ChangeListMessage.UserRecipient)recipient).getUser();
            
            if(user != null && !ADM_WorkUtils.doesUserWantNotification(user, work, workCacheWrapper, isInsert)) {
                System.debug('Removing  user from the recipients because they do not want to be notified');
                recipients.remove(recipient);
            }
        }
        
        return new List<ADM_ChangeListMessage.Recipient>(recipients);
                        }
    /*
    
        getToBeNotified - used by chatter post
    */
    private static List<ADM_ChangeListMessage.Recipient> getToBeNotified(ADM_Work__c work, ADM_UserCache userCache, User currentUser, Map<Id, Set<String>> workIdToSubscribersMap, String mailOrigin) {
        Set<Id> recipientUserIds = new Set<Id>();
        Set<ADM_ChangeListMessage.Recipient> recipients = getRecipientsForWork(work, userCache, currentUser, workIdToSubscribersMap, mailOrigin, recipientUserIds);
        return new List<ADM_ChangeListMessage.Recipient>(recipients);
    }
    
    private static Set<ADM_ChangeListMessage.Recipient> getRecipientsForWork(ADM_Work__c work, ADM_UserCache userCache, User currentUser, String mailOrigin,Set<Id> recipientUserIds) {
        Set<ADM_ChangeListMessage.Recipient> recipients = new Set<ADM_ChangeListMessage.Recipient>();
        //by default everyone associated to the work should be notified
        List<User> users = ADM_WorkUtils.getUsersWhoReceiveNotificationsFromWork(work, userCache,mailOrigin);
        for(User user : users) {
                if(user.Email != null && !recipientUserIds.contains(user.Id) && canAddUserToRecipientList(work,user,currentUser)) {
                        recipientUserIds.add(user.Id);
                        recipients.add(new ADM_ChangeListMessage.UserRecipient(user));
            }
        }
        return recipients;
    }
    
    private static Set<ADM_ChangeListMessage.Recipient> getRecipientsForWork(ADM_Work__c work, ADM_UserCache userCache, User currentUser,  Map<Id, Set<String>> workIdToSubscribersMap, String mailOrigin, Set<Id> recipientUserIds) {
        Set<ADM_ChangeListMessage.Recipient> recipients = new Set<ADM_ChangeListMessage.Recipient>();
        //by default everyone associated to the work should be notified
        Set<String> userIds = workIdToSubscribersMap.get(work.Id);
        for(String userId : userIds) {
                User user = userCache.getById(userId);

                if(null == user || !validateUserForChatterPostEmail(user,mailOrigin)){//Ignore user if null OR not valid for chatter post email
                    //For chatter post no need to send email to the current user
                    continue;
                }
                if(user.Email != null && !recipientUserIds.contains(user.Id) && canAddUserToRecipientList(work,user,currentUser)) {
                        recipientUserIds.add(user.Id);
                        recipients.add(new ADM_ChangeListMessage.UserRecipient(user));
            }
        }
        return recipients;
    }
    
    
    public static ADM_Work__c removeFieldsNotApplicableForClone(ADM_Work__c workClone) {
            //since tmeplates are created via clone we wan't its name and description to be cloned 
            workClone.Template_Name__c = null;
            workClone.Template_Description__c = null;
            //remove other fields not applicable for clone
            workClone.Encoded_Recipients_Txt_Area__c = null;
            workClone.Bug_Number__c = null;
            workClone.External_ID__c = null;
            workClone.Scrumforce_ID__c = null;
            workClone.Resolved_On__c = null;
            workClone.Closed_On__c = null;
            workClone.Closed_By__c = null;
            workClone.Priority__c = null; 
            workClone.Frequency__c = null; 
            workClone.Impact__c = null; 
            workClone.Resolved_By__c = null;
            workClone.Perforce_Status__c = null;
            workClone.Scrum_Team_Last_Modified__c = null;
            workClone.Attributes__c = null;
            workClone.of_Test_Failures__c = null;
            workClone.Root_Cause_Analysis_2__c = null;
            workClone.Product_Area__c = null;
            workClone.Major_Func_Area__c = null;
            workClone.Known_Issue_ID__c = null;
            workClone.Known_Issue_Num_Reporting_Customers__c  = null;
            
            return workClone;
    }
    
    public static ADM_Work__c setImpactFrequencyPriorityForClone(ADM_Work__c original, ADM_Work__c clone) {

        clone.Frequency__c = original.Frequency__c;
        clone.Impact__c = original.Impact__c;
        if(original.Type__c != 'Bug') {
            clone.Priority__c = original.Priority__c;
        }
            
        return clone;
    }
    public static ADM_Work__c initializeFieldsForClone(ADM_Work__c workClone) {
        
            workClone.Number_Of_Cases__c = 0;
            workClone.Number_of_Change_Lists__c = 0;
            workClone.Last_Modified_By__c = UserInfo.getUserId();
            workClone.Created_By_import__c = UserInfo.getUserId();
            workClone.Status__c = 'New';
            return workClone;
    }

    private static List<Change> changeListFromJSON(String value) {
        return (List<Change>)JSON.deserialize(value, List<Change>.class);
    }
    
    private static String changeListToJSON(List<Change> changeList) {
        return JSON.serialize(changeList);
    }
    
    testMethod static void testIsValidIdFormat() {
        String shortId = '1234';
        String longId = '1234567890123456';
        System.assert(isValidIdFormat(shortId) == false,'short id is ' + shortId.length() + ' characters short and the is valid is format is ' + isValidIdFormat(shortId));
        System.assert(isValidIdFormat(longId) == true,'long id is ' + longId.length() + ' characters long and the is valid is format is ' + isValidIdFormat(longId));
    }
    
    testMethod static void testIsId() {
        String keyPrefixBuild = Schema.SObjectType.ADM_Build__c.getKeyPrefix();
        ADM_Build__c build = ADM_Build.createTestBuild();
        String buildId = keyPrefixBuild + '00000';

        System.assert(ADM_WorkUtils.isId(build.Id, keyPrefixBuild));
        System.assert(!ADM_WorkUtils.isId(buildId,keyPrefixBuild));
    }

    testMethod static void testProcessNotificationsForInsert() {
        ADM_Work__c newWork = ADM_Work.createTestWork();
        //verify notifications for an insert
        Test.startTest();
        ADM_WorkUtils.processNotifications(new List<ADM_Work__c>{newWork}, null, true, false, ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN);
        Test.stopTest();
        //2 cache object will exist as creating a the test obj newWork also triggers the processNotifications method and creates a cache object
        System.assertEquals(2, [select count() from ADM_Work_Cache__c where Work__c = :newWork.id]);

    }

    testMethod static void testProcessNotificationsForUpdates() {
        User user1 = [Select Id, FirstName, LastName, Name from User where isActive = true limit 1 ];
        ADM_Work__c newWork = ADM_Work.createTestWork();
        ADM_Work__c oldWork = ADM_Work.createTestWork();
        newWork.Assignee__c = user1.id;
        update newWork;
        //verify notification for an update
        Test.startTest();
        ADM_WorkUtils.processNotifications(new List<ADM_Work__c>{newWork}, new List<ADM_Work__c>{oldWork}, false, true, ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN);
        Test.stopTest();
        //3 cache object will exist as creating the 2 test obj's  also triggers the processNotifications method indirectly
        System.assertEquals(3, [select count() from ADM_Work_Cache__c where Work__c = :newWork.id]);
    }
    
    /*
    testcaseID a1DB00000002J5Y
    Hierarchy GUS.ScrumforceToGUS.Work Page.Email Settings.Bread and Butter
    Expected Results No emails from GUS except when user is added as an Assignee or Subscriber
    userstory a07B0000000Emmz
    Author: Jared Pearson
    */
    /**
     * This test is inside this class because doesUserWantNotification is private
     */
     
    private testMethod static void testBreadAndButterSettingWithWatchedChange() {
        User user1 = ADM_WorkUser.createTestUser();
        user1.FirstName = 'User1';
        user1.Notification_Level__c = 'Bread & Butter';
        Database.upsert(user1);
        
        User user2 = ADM_WorkUser.createTestUser();
        user2.FirstName = 'User2';
        user2.Notification_Level__c = 'Bread & Butter';
        Database.upsert(user2);
        
        User user3 = ADM_WorkUser.createTestUser();
        user3.FirstName = 'User3';
        user3.Notification_Level__c = 'Bread & Butter';
        Database.upsert(user3);
        
        //refresh each of the user accounts
        Map<Id, User> userMap = new Map<Id, User>(ADM_WorkUser.getUsers('Id', new Set<String>{user1.Id, user2.Id, user3.Id}));
        user1 = userMap.get(user1.Id);
        user2 = userMap.get(user2.Id);
        user3 = userMap.get(user3.Id);
        
        ADM_Work__c oldWork = ADM_Work.createTestBug();
        oldWork.Product_Owner__c = user3.Id;
        Database.upsert(oldWork);
        oldWork = ADM_Work.getById(oldWork.Id);
        
        ADM_Work__c newWork = oldWork.clone(true, false);
        
        //change one of the Bread and Butter fields
        newWork.Assignee__c = user2.Id;
        
        Boolean isInsert = false;
        ADM_Work_Cache__c workCache = createWorkCache(newWork, oldWork, userMap, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper = new ADM_WorkCacheWrapper(workCache);
        WorkWrapper workWrapper = new WorkWrapper(newWork, null);
        
        Test.startTest();
        System.assertEquals(false, doesUserWantNotification(user1, workWrapper, workCacheWrapper, isInsert), 'User 1 should not receive a notification because they were not added as the assignee.');
        System.assertEquals(true,  doesUserWantNotification(user2, workWrapper, workCacheWrapper, isInsert), 'User 2 should receive a notification because they were added as the assignee.');
        System.assertEquals(false, doesUserWantNotification(user3, workWrapper, workCacheWrapper, isInsert), 'User 3 should receive a notification because they were added as the assignee.');
        Test.stopTest();
    }
    
    /*
    testcaseID a1DB00000002J5Y
    Hierarchy GUS.ScrumforceToGUS.Work Page.Email Settings.Bread and Butter
    Expected Results No emails from GUS except when user is added as an Assignee or Subscriber
    userstory a07B0000000Emmz
    Author: Jared Pearson
    */
    /**
     * This test is inside this class because doesUserWantNotification is private
     */
    private testMethod static void testBreadAndButterSettingWithTodoWithUnwatchedChange() {
        User user1 = ADM_WorkUser.createTestUser();
        user1.FirstName = 'User1';
        user1.Notification_Level__c = 'Bread & Butter';
        Database.upsert(user1);
        
        //refresh each of the user accounts
        Map<Id, User> userMap = new Map<Id, User>(ADM_WorkUser.getUsers('Id', new Set<String>{user1.Id}));
        user1 = userMap.get(user1.Id);
        
        ADM_Work__c oldWork = ADM_Work.createTestTodo();
        oldWork.Assignee__c = user1.Id;
        Database.upsert(oldWork);
        oldWork = ADM_Work.getById(oldWork.Id);
        
        ADM_Work__c newWork = oldWork.clone(true, false);
        
        //change a field not watched by Bread and Butter
        newWork.Subject__c = 'New Subject';
        
        Boolean isInsert = false;
        ADM_Work_Cache__c workCache = createWorkCache(newWork, oldWork, userMap, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper = new ADM_WorkCacheWrapper(workCache);
        WorkWrapper workWrapper = new WorkWrapper(newWork, null);
        
        Test.startTest();
        System.assertEquals(false, doesUserWantNotification(user1, workWrapper, workCacheWrapper, isInsert), 'User 1 should not receive a notification because they are Bread & Butter.');
        Test.stopTest();
    }
    
    /*
    testcaseID a1DB00000002J59
    Hierarchy GUS.ScrumforceToGUS.Work Page.Email Settings.Meat and Potatoes
    Expected Results Just User Comments and Status Changes (when user is Assignee or Subscriber), and when user is added as an Assignee or Subscriber
    userstory a07B0000000Emmz
    Author: Jared Pearson
    */
    /**
     * This test is inside this class because doesUserWantNotification is private
     */
    private testMethod static void testMeatAndPotatoesSettingWithWatchedChange() {
        User user1 = ADM_WorkUser.createTestUser();
        user1.FirstName = 'User1';
        user1.Notification_Level__c = 'Meat & Potatoes';
        Database.upsert(user1);
        
        User user2 = ADM_WorkUser.createTestUser();
        user2.FirstName = 'User2';
        user2.Notification_Level__c = 'Meat & Potatoes';
        Database.upsert(user2);
        
        User user3 = ADM_WorkUser.createTestUser();
        user3.FirstName = 'User3';
        user3.Notification_Level__c = 'Meat & Potatoes';
        Database.upsert(user3);
        
        User user4 = ADM_WorkUser.createTestUser();
        user4.FirstName = 'User4';
        user4.Notification_Level__c = 'Bread & Butter';
        Database.upsert(user4);
        
        Map<Id, User> userMap = new Map<Id, User>(ADM_WorkUser.getUsers('Id', new Set<String>{user1.Id, user2.Id, user3.Id, user4.Id}));
        user1 = userMap.get(user1.Id);
        user2 = userMap.get(user2.Id);
        user3 = userMap.get(user3.Id);
        user4 = userMap.get(user4.Id);
        
        ADM_Work__c oldWork1 = ADM_Work.createTestBug();
        oldWork1.Product_Owner__c = user3.Id; //make sure user 3 is an assignee
        oldWork1.UE_Engineer__c = user4.Id; //make sure user 4 is an assignee
        Database.upsert(oldWork1);
        oldWork1 = ADM_Work.getById(oldWork1.Id);
        
        ADM_Work__c newWork1 = oldWork1.clone(true, false);
        newWork1.Comment_Copy__c = 'New comment'; //adding a comment, which is watched
        newWork1.Assignee__c = user2.Id; //adding user2 as an assignee
        
        Boolean isInsert = false;
        ADM_Work_Cache__c workCache1 = createWorkCache(newWork1, oldWork1, userMap, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper1 = new ADM_WorkCacheWrapper(workCache1);
        WorkWrapper workWrapper1 = new WorkWrapper(newWork1, null);
        
        ADM_Work__c newWork2 = oldWork1.clone(true, false);
        newWork2.Status__c = 'Closed'; //changing the status, which is watched
        newWork2.Assignee__c = user2.Id; //adding user2 as an assignee
        
        ADM_Work_Cache__c workCache2 = createWorkCache(newWork2, oldWork1, userMap, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper2 = new ADM_WorkCacheWrapper(workCache2);
        WorkWrapper workWrapper2 = new WorkWrapper(newWork2, null);
        
        Test.startTest();
        
        //newWork1
        /*
              https://gus.my.salesforce.com/a07B0000000eBQ6IAM - commenting out the below assertion as the method is not looking for isAssignee or Subscriber now because it is irrelavant
        as all the users assoiated to a work item will be an entity subscriber now
        */
        //System.assertEquals(false, doesUserWantNotification(user1, workWrapper1, workCacheWrapper1, isInsert), 'User 1 should not receive a notification because they were not added as the assignee.');
        System.assertEquals(true,  doesUserWantNotification(user2, workWrapper1, workCacheWrapper1, isInsert), 'User 2 should receive a notification because they were added as the assignee.');
        System.assertEquals(true,  doesUserWantNotification(user3, workWrapper1, workCacheWrapper1, isInsert), 'User 3 should receive a notification because they are an assignee.');
        System.assertEquals(true,  doesUserWantNotification(user4, workWrapper1, workCacheWrapper1, isInsert), 'User 4 should receive a notification because they are "Bread & Butter" which wantches changes to Comments.');
        
        //newWork2
        /*
              https://gus.my.salesforce.com/a07B0000000eBQ6IAM - commenting out the below assertion as the method is not looking for isAssignee or Subscriber now because it is irrelavant
        as all the users assoiated to a work item will be an entity subscriber now
        */
        //System.assertEquals(false, doesUserWantNotification(user1, workWrapper2, workCacheWrapper2, isInsert), 'User 1 should not receive a notification because they were not added as the assignee.');
        System.assertEquals(true,  doesUserWantNotification(user2, workWrapper2, workCacheWrapper2, isInsert), 'User 2 should receive a notification because they were added as the assignee.');
        System.assertEquals(true,  doesUserWantNotification(user3, workWrapper2, workCacheWrapper2, isInsert), 'User 3 should receive a notification because they are an assignee.');
        System.assertEquals(false, doesUserWantNotification(user4, workWrapper2, workCacheWrapper2, isInsert), 'User 4 should not receive a notification because they are "Bread & Butter" which does not watch changes to Status.');
        
        Test.stopTest();
    }
    
    /*
    testcaseID a1DB00000002J5T
    Hierarchy GUS.ScrumforceToGUS.Work Page.Email Settings.Meat and Potatoes
    Expected Results Just User Comments and Status Changes (when user is an Assignee or Subscriber), and when user is added as an Assignee or Subscriber
    userstory a07B0000000Emmz
    Author: Jared Pearson
    */
    /**
     * This test is inside this class because doesUserWantNotification is private
     */
    private testMethod static void testMeatAndPotatoesSettingWithUnwatchedChanged() {
        User user1 = ADM_WorkUser.createTestUser();
        user1.FirstName = 'User1';
        user1.Notification_Level__c = 'Meat & Potatoes';
        Database.upsert(user1);
        
        User user2 = ADM_WorkUser.createTestUser();
        user2.FirstName = 'User2';
        user2.Notification_Level__c = 'Meat & Potatoes';
        Database.upsert(user2);
        
        User user3 = ADM_WorkUser.createTestUser();
        user3.FirstName = 'User3';
        user3.Notification_Level__c = 'Bread & Butter';
        Database.upsert(user3);
        
        Map<Id, User> userMap = new Map<Id, User>(ADM_WorkUser.getUsers('Id', new Set<String>{user1.Id, user2.Id, user3.Id}));
        user1 = userMap.get(user1.Id);
        user2 = userMap.get(user2.Id);
        user3 = userMap.get(user3.Id);
        
        //--------------------------------------------------------------
        //set up the work records
        // oldWork2/newWork2: Adds a field that is NOT being watched by 'Meat & Potatoes'
        //                      which should NOT send notifications to 'Meat & Potatoes' users
        //--------------------------------------------------------------
        ADM_Work__c oldWork2 = ADM_Work.createTestBug();
        oldWork2.Product_Owner__c = user2.Id; //make sure user 2 is an assignee
        Database.upsert(oldWork2);
        oldWork2 = ADM_Work.getById(oldWork2.Id);
        
        ADM_Work__c newWork2 = oldWork2.clone(true, false);
        newWork2.Priority__c = 'P1'; //changing a field not being watched
        
        Boolean isInsert = false;
        ADM_Work_Cache__c workCache2 = createWorkCache(newWork2, oldWork2, userMap, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper2 = new ADM_WorkCacheWrapper(workCache2);
        WorkWrapper workWrapper = new WorkWrapper(newWork2, null);
        
        Test.startTest();
        System.assertEquals(false, doesUserWantNotification(user1, workWrapper, workCacheWrapper2, isInsert), 'User 1 should not receive a notification because they were not added as the assignee.');
        System.assertEquals(false, doesUserWantNotification(user2, workWrapper, workCacheWrapper2, isInsert), 'User 2 should not receive a notification because Priority__c is not a watched field.');
        System.assertEquals(false, doesUserWantNotification(user3, workWrapper, workCacheWrapper2, isInsert), 'User 3 should not receive a notification because Priority__c is not a watched field by "Bread & Butter".');
        Test.stopTest();
    }
    
    /*
    testcaseID a1DB00000002J5E
    Hierarchy GUS.ScrumforceToGUS.Work Page.Email Settings.Whole Enchilada
    Expected Results 'The Whole Enchilada' is the same as it is today, user gets emailed with every change
    userstory a07B0000000Emmz
    Author: Jared Pearson
    */
    /**
     * This test is inside this class because doesUserWantNotification is private
     */
    private testMethod static void testWholeEnchiladaSettingWithAssigneeRemoval() {
        User user1 = ADM_WorkUser.createTestUser();
        user1.FirstName = 'User1';
        user1.Notification_Level__c = 'The Whole Enchilada';
        Database.upsert(user1);
        
        User user2 = ADM_WorkUser.createTestUser();
        user2.FirstName = 'User2';
        user2.Notification_Level__c = 'The Whole Enchilada';
        Database.upsert(user2);
        
        Map<Id, User> userMap = new Map<Id, User>(ADM_WorkUser.getUsers('Id', new Set<String>{user1.Id, user2.Id}));
        user1 = userMap.get(user1.Id);
        user2 = userMap.get(user2.Id);
        
        ADM_Work__c oldWork = ADM_Work.createTestBug();
        oldWork.Product_Owner__c = user1.Id; //make sure user 1 is an assignee
        Database.upsert(oldWork);
        oldWork = ADM_Work.getById(oldWork.Id);
        
        ADM_Work__c newWork = oldWork.clone(true, false);
        newWork.Product_Owner__c = user2.Id; //change the assignee to user 2 
        
        Boolean isInsert = false;
        ADM_Work_Cache__c workCache = createWorkCache(newWork, oldWork, userMap, isInsert);
        ADM_WorkCacheWrapper workCacheWrapper = new ADM_WorkCacheWrapper(workCache);
        WorkWrapper workWrapper = new WorkWrapper(newWork, null);
        
        Test.startTest();
        System.assertEquals(true, doesUserWantNotification(user1, workWrapper, workCacheWrapper, isInsert), 'User 1 should receive a notification because they were removed.');
        System.assertEquals(true, doesUserWantNotification(user2, workWrapper, workCacheWrapper, isInsert), 'User 2 should not receive a notification because they were added.');
        Test.stopTest();
    }
    
    testMethod static void testProcessChangeListAsync(){
       ADM_Work__c work = ADM_Work.createTestWork();

       User user = ADM_WorkUser.createTestUser();


       //create work cache object
      ADM_Work_Cache__C  wc = new ADM_Work_Cache__c(
                Work__c = work.id,
                User__c = user.id,
                Field_Names_With_Changes__c = 'Assignee__c:::Subject__c',
                Change_List_Description__c = 'Assignee description:::Subject description'

            );
       insert wc;
       Test.startTest();
            ADM_WorkUtils.processChangeListAsync(new List<String>{wc.id},true,user.id, '');
       Test.stopTest();
       //verify a comment was created
       Integer count = [select count() from ADM_Comment__c where Work__c = :work.id];
       System.assertEquals(1, count);


    }

    testMethod static void test_toChangeListMessage_onUpdateAndInsert(){
        
        ADM_Work__c oldWork = ADM_Work.createTestBug();
        upsert oldWork;
        oldWork = ADM_Work.getById(oldWork.Id);
        
        ADM_Build__c build_1 = ADM_Build.createTestBuild();
        User user_1 = ADM_WorkUser.createTestUser();
        
        ADM_Work__c newWork = oldWork.clone(false,true);
        newWork.Status__c = 'Integrate';
        newWork.Perforce_Status__c = 'Open';
        newWork.Assignee__c = user_1.Id;
        newWork.Product_Owner__c = user_1.Id;
        newWork.System_Test_Engineer__c = user_1.Id;
        newWork.Tech_Writer__c = user_1.Id;
        newWork.QA_Engineer__c = user_1.Id;
        newWork.UE_Engineer__c = user_1.Id;
        newWork.Scheduled_Build__c = build_1.Id;
        newWork.Priority__c = null; //set priority to null so it passes validation
        upsert newWork;
        newWork = ADM_Work.getById(newWork.Id);
        
        //changing the priority after insert/update because the priority field 
        //cannot normall be changed. it is a calculated field
        oldWork.Priority__c = 'P0';
        newWork.Priority__c = 'P1';
        
        Boolean isWorkUpdate = false;

        ADM_WorkUtils.processNotifications(new List<ADM_Work__c>{newWork}, new List<ADM_Work__c>{oldWork}, isWorkUpdate, !isWorkUpdate, ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN);
        ADM_Work_Cache__c[] workCaches = [Select a.Change_List_Description__c, a.Field_Names_With_Changes__c From ADM_Work_Cache__c a where Work__c = : newWork.Id];
        Set<String> notificationFields = new Set<String>{'Priority__c', 'Assignee__c', 'QA_Engineer__c', 'Product_Owner__c', 'Tech_Writer__c', 'System_Test_Engineer__c', 'UE_Engineer__c', 'Perforce_Status__c', 'Scheduled_Build__c','Status__c'};

        for(ADM_Work_Cache__c workCache : workCaches) {
            if(workCache.Field_Names_With_Changes__c == null) {
                System.assert(workCache.Change_List_Description__c == null,'this should be null because it was the insert work cache object!');
            } else {
                for(String field : workCache.Field_Names_With_Changes__c.split(DELIMITER)) {
                    notificationFields.remove(field);
                }
            }
        }

        System.assert(notificationFields.isEmpty(), 'was expecting to have all notification fields accounted for. looks like there is something that was missed--->' + notificationFields);
        System.assert(workCaches.size() == 2,'was expecting to have 2 records returned... one for the insert of the work object and one for the update--->' + workCaches.size());
    }
    
    static testMethod void testWorkCacheWrapperAddFieldNameWithChange() {
        ADM_Work_Cache__c workCache = new ADM_Work_Cache__c();
        ADM_WorkCacheWrapper wrapper = new ADM_WorkCacheWrapper(workCache);
        System.assertEquals(workCache, wrapper.getWorkCache(), 'Expected getWorkCache to return the same work cache instance');
        
        //add the first field
        wrapper.addFieldNameWithChange('Assignee__c');
        
        System.assertEquals(1, wrapper.getFieldNamesWithChanges().size(), 'Expected getFieldNamesWithChanges to return 1');
        System.assertEquals(true, wrapper.isFieldModified('Assignee__c'), 'Expected isFieldModified to return true because the field has been added');
        System.assertEquals('Assignee__c', workCache.Field_Names_With_Changes__c, 'Expected the Field_Names_With_Changes__c property to be set when the field was added');
        
        //add another field
        wrapper.addFieldNameWithChange('Subject__c');
        
        System.assertEquals(2, wrapper.getFieldNamesWithChanges().size(), 'Expected getFieldNamesWithChanges to return 2');
        System.assertEquals(true, wrapper.isFieldModified('Assignee__c'), 'Expected isFieldModified to return true because the field has been added');
        System.assertEquals(true, wrapper.isFieldModified('Subject__c'), 'Expected isFieldModified to return true because the field has been added');
        System.assertEquals('Assignee__c:::Subject__c', workCache.Field_Names_With_Changes__c, 'Expected the Field_Names_With_Changes__c property to be set when the field was added');
    }
    
    static testMethod void testWorkCacheWrapperWithLoad() {
        ADM_Work_Cache__c workCache = new ADM_Work_Cache__c();
        workCache.Field_Names_With_Changes__c = 'Assignee__c:::Subject__c';
        workCache.Change_List_Description__c = 'Assignee description:::Subject description';
        workCache.Changes__c = '[{"typeCode":"A","fieldName":"Assignee__c","newValue":"Assignee description"},{"typeCode":"A","fieldName":"Subject__c","newValue":"Subject description"}]';
        
        ADM_WorkCacheWrapper wrapper = new ADM_WorkCacheWrapper(workCache);
        System.assertEquals(workCache, wrapper.getWorkCache(), 'Expected getWorkCache to return the same work cache instance');
        System.assertEquals(2, wrapper.getFieldNamesWithChanges().size(), 'Expected getFieldNamesWithChanges to return 2');
        System.assertEquals(true, wrapper.isFieldModified('Assignee__c'), 'Expected isFieldModified to return true because the field has been added');
        System.assertEquals(true, wrapper.isFieldModified('Subject__c'), 'Expected isFieldModified to return true because the field has been added');
        System.assertEquals('Assignee__c:::Subject__c', workCache.Field_Names_With_Changes__c, 'Expected the Field_Names_With_Changes__c property to be set when the field was added');
        System.assert(wrapper.getChangeByFieldName('Assignee__c') != null, 'Expected the assignee change to be found using getChangeByFieldName');
        
        //add the another field
        wrapper.addFieldNameWithChange('Priority__c');
        
        System.assertEquals(3, wrapper.getFieldNamesWithChanges().size(), 'Expected getFieldNamesWithChanges to return 3');
        System.assertEquals(true, wrapper.isFieldModified('Priority__c'), 'Expected isFieldModified to return true because the field has been added');
        System.assertEquals('Assignee__c:::Subject__c:::Priority__c', workCache.Field_Names_With_Changes__c, 'Expected the Field_Names_With_Changes__c property to be set when the field was added');
    }
    
   
    static testMethod void testCreateChangeListMessagesWithBugInsert() {
        
        User assignee = ADM_WorkUser.createTestUser();
        assignee.FirstName = 'Second';
        assignee.LastName = 'Test User';
        assignee.Email = 'user22222@gus.com';
        assignee.Notification_Level__c = 'The Whole Enchilada';
        Database.upsert(assignee);
        assignee = [select Name, Email from User where Id = :assignee.Id];
        
        User qaEngineer = ADM_WorkUser.createTestUser();
        qaEngineer.FirstName = 'First';
        qaEngineer.LastName = 'Test User';
        qaEngineer.Email = 'user11111@gus.com';
        qaEngineer.Notification_Level__c = 'The Whole Enchilada';
        Database.upsert(qaEngineer);
        qaEngineer = [select Name, Email from User where Id = :qaEngineer.Id];
        
        ADM_Build__c build1 = new ADM_Build__c();
        build1.Name = 'Build1';
        Database.insert(build1);
        build1 = [select Name from ADM_Build__c where Id = :build1.Id];
        
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Subject__c = 'Test Work Subject';
        work.QA_Engineer__c = qaEngineer.Id;
        work.Assignee__c = assignee.Id;
        work.Scheduled_Build__c = build1.Id;
        insert work;
        work = ADM_Work.getById(work.Id);
        
        ADM_Work_Cache__c workCache = new ADM_Work_Cache__c();
        insert workCache;
        workCache = [select Id, Field_Names_With_Changes__c, Change_List_Description__c, Changes__c from ADM_Work_Cache__c where Id = :workCache.Id];
        
        Map<Id, ADM_WorkCacheWrapper> workCacheMap = new Map<Id, ADM_WorkCacheWrapper>{work.Id => new ADM_WorkCacheWrapper(workCache)};
        List<ADM_Work__c> newWorks = new List<ADM_Work__c>{work};
        Boolean isInsert = true;
        User currentUser = ADM_WorkUser.createTestUser();
        currentUser.Notification_Level__c = 'The Whole Enchilada';
        update currentUser;

        Test.startTest();
        List<ADM_ChangeListMessage> changeListMessages = null;
        System.runAs(currentUser) {
            changeListMessages = createChangeListMessages(workCacheMap, newWorks, isInsert, currentUser);
        }
        Test.stopTest();
        
        System.assertEquals(1, changeListMessages.size(), 'Expected to create one change list message because the work item is inserted');
        
        ADM_ChangeListMessage message = changeListMessages.get(0);
        
        System.assert(message.toAddresses != null, 'ChangeListMessage.toAddress should never be null');
        System.assert(message.ccAddresses != null, 'ChangeListMessage.ccAddress should never be null');
        System.assert(message.bccAddresses != null, 'ChangeListMessage.bccAddress should never be null');
        //3 emails in to Address (Creator, QA_Engineer__c, Assignee) 
        System.assertEquals(3, message.toAddresses.size(), 'Expected email address of the user that created the bug. Actual: ' + message.toAddresses);
        System.assertEquals(0, message.ccAddresses.size(), 'Expected no email addresses to be in the CC field. Actual: ' + message.ccAddresses);
        System.assertEquals(0, message.bccAddresses.size(), 'Expected no email addresses to be in the BCC. Actual: ' + message.bccAddresses);
        boolean assigneeFound = false;
        boolean qaFound = false;
        boolean currentUserFound = false;
        for(String address : message.toAddresses) {
           if(address.equals(currentUser.Email)) {
                currentUserFound = true;
                continue;
            }
        }
        System.assert(currentUserFound, 'Expected to find the Current User\'s email address in the To');
        
        System.assert(message.coreValues != null, 'ChangeListMessage.coreValues should never be null');
        
        //test to make sure that the coreValues contains all of the proper keys
        for(String expectedKey : ADM_CoreValues.getKeys('Bug', isInsert)) {
            System.assert(message.coreValues.containsKey(expectedKey), 'Expected coreValues to contain the key ' + expectedKey);
        }
        
        //check the values of the keys to make sure they are correct
        System.assertEquals('Bug', message.coreValues.get('Type'), 'Expected the value of type to be Bug');
        System.assertEquals(qaEngineer.Name, message.coreValues.get('QA Engineer'), 'Expected the QA Engineer value to be the same as the user');
        System.assertEquals(assignee.Name, message.coreValues.get('Assignee'), 'Expected the Assignee value to be the same as the user');
        System.assertEquals(work.Subject__c, message.coreValues.get('Subject'), 'Expected the Subject value to be ' + work.Subject__c);
        System.assertEquals(build1.Name, message.coreValues.get('Scheduled Build'), 'Expected the Scheduled Build value to be the name of the build.');
        System.assert(message.coreValues.containsKey('Link') && message.coreValues.get('Link') != null, 'Expected core values to always contain the link');
        
    }

    /*
    testcaseID a1DB00000002Jha
    Hierarchy GUS.ScrumforceToGUS.Work Page.Email Settings.Bread and Butter
    Expected Results User still gets emailed since the user is in the notifications section
    userstory a07B0000000Emmz
    Author: Jared Pearson
    */
    
    /**
     * Given a user that has the most restrictive notification level,
     * if the user's e-mail is a subscriber, 
     * then the user should receive email when their notification level allows.
     */
    static testMethod void testSubscriberFollowsNotificationLevel() {
        
        //delete all of the assignment rules that are currently in the database
        //because assignment rules are automatically applied. we want to make
        //sure the external data does not adversely affect this test by adding 
        //users to the work record.
        delete [select Id from ADM_Assignment_Rule__c];
        
        //create a user with the most restrictive notification level
        User user = ADM_WorkUser.createTestUser();
        user.FirstName = 'Assignee';
        user.LastName = 'Test User';
        user.Email = 'user22222@gus.com'; 
        user.Notification_Level__c = 'Bread & Butter';
        Database.upsert(user);
        user = [select Name, Email, Username from User where Id = :user.Id];
        
        //make a work object that changes a value not watched by the notification 
        //level (in this case, the Subject)
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Subject__c = 'Subject description new';
        Database.insert(work);
        work = ADM_Work.getById(work.Id);
        
        //make sure the assignee user is Bread & Butter
        User assignee = [select Notification_Level__c from User where Id = :work.Assignee__c];
        assignee.Notification_Level__c = 'Bread & Butter';
        Database.update(assignee);
        
        //add the assignee as a subscriber
        ADM_Work_Subscriber__c subscriber1 = new ADM_Work_Subscriber__c();
        subscriber1.WorkId__c = work.Id; 
        subscriber1.UserId__c = user.Id;
        Database.insert(subscriber1);
        
        //make a work cache object that changes a value not watched by the notification 
        //level (in this case, the Subject)
        ADM_Work_Cache__c workCache = new ADM_Work_Cache__c();
        workCache.Work__r = work;
        workCache.User__c = UserInfo.getUserId();
        workCache.Field_Names_With_Changes__c = 'Subject__c';
        workCache.Change_List_Description__c = 'Subject description';
        workCache.Changes__c = '[{"typeCode":"M","fieldName":"Subject__c","oldValue":"Subject description old", "newValue":"' + work.Subject__c + '"}]';
        Database.insert(workCache);
        workCache = [select Id, Has_Been_Opened__c, Has_Been_Closed__c, Field_Names_With_Changes__c, Change_List_Description__c, Changes__c from ADM_Work_Cache__c where Id = :workCache.Id];
        
        Map<Id, ADM_WorkCacheWrapper> workCacheMap = new Map<Id, ADM_WorkCacheWrapper>{work.Id => new ADM_WorkCacheWrapper(workCache)};
        List<ADM_Work__c> newWorks = new List<ADM_Work__c>{work};
        Boolean isInsert = false;
        User currentUser = [select Id, Name, Username from User where Id = :UserInfo.getUserId()];
        
        Test.startTest();
        List<ADM_ChangeListMessage> changeListMessages = createChangeListMessages(workCacheMap, newWorks, isInsert, currentUser);
        Test.stopTest();
        
        System.assertEquals(0, changeListMessages.size(), 'Expected no change list message because the subscriber is Bread & Butter');
    }
    
    /*
    testcaseID a1DB00000002bgM
    Hierarchy GUS.ScrumforceToGUS.Work Page.Email Settings.Bread and Butter
    Expected Results An email is generated from a manually entered comment in todo but no message is received
    userstory a07B0000000NXYdIAO
    Author: Chris Copek 
    */
    /**
     */
    static testMethod void testBreadAndButterUserDoesNotReceiveNotificationWithTodoWithUnwatched() {
        
        //create a user with 'Bread and Butter' notification level
        User assignee = ADM_WorkUser.createTestUser();
        assignee.FirstName = 'Assignee';
        assignee.LastName = 'Test User';
        assignee.Email = 'user22222@gus.com'; 
        assignee.Notification_Level__c = 'Bread & Butter';
        Database.upsert(assignee);
        assignee = [select Name, Email, Username from User where Id = :assignee.Id];
        
        //make a work object that changes a value not watched by the notification 
        //level (in this case, the Subject)
        ADM_Work__c work = ADM_Work.setupTestWork('ToDo');
        work.Priority__c = 'P4';
        work.Subject__c = 'Subject description new';
        work.Assignee__c = assignee.Id;
        insert work;
        work = ADM_Work.getById(work.Id);
        
        //make a work cache object that changes a value not watched by the notification 
        //level (in this case, the Subject)
        ADM_Work_Cache__c workCache = new ADM_Work_Cache__c();
        workCache.Work__r = work;
        workCache.User__c = UserInfo.getUserId();
        workCache.Field_Names_With_Changes__c = 'Subject__c';
        workCache.Change_List_Description__c = 'Subject description';
        workCache.Changes__c = '[{"typeCode":"M","fieldName":"Subject__c","oldValue":"Subject description old", "newValue":"' + work.Subject__c + '"}]';
        insert workCache;
        workCache = [select Id, Has_Been_Opened__c, Has_Been_Closed__c, Field_Names_With_Changes__c, Change_List_Description__c, Changes__c from ADM_Work_Cache__c where Id = :workCache.Id];
        
        Map<Id, ADM_WorkCacheWrapper> workCacheMap = new Map<Id, ADM_WorkCacheWrapper>{work.Id => new ADM_WorkCacheWrapper(workCache)};
        List<ADM_Work__c> newWorks = new List<ADM_Work__c>{work};
        Boolean isInsert = false;
        User currentUser = [select Id, Name, Username from User where Id = :UserInfo.getUserId()];
        
        Test.startTest();
        List<ADM_ChangeListMessage> changeListMessages = createChangeListMessages(workCacheMap, newWorks, isInsert, currentUser);
        Test.stopTest();
        
        System.assertEquals(0, changeListMessages.size(), 'Expected to create no change list messages because the user is Bread and Butter and only the subject has changed');
    }

    /*
    testcaseID a1DB00000002bgW
    Hierarchy GUS.ScrumforceToGUS.Work Page.Email Settings.Bread and Butter
    Expected Results An email is generated from a manually entered comment
    userstory a07B0000000NXYdIAO
    Author: Chris Copek 
    */
    
    /**
     * Given a subscriber with a notification level of Meat and Potatoes,
     * an e-mail should be generated when a watched field is changed.
     */
    static testMethod void testSubscriberOfMeatAndPotatoesReceivesAMessageOnWatchedChange() {
        User assignee = ADM_WorkUser.createTestUser();
        assignee.FirstName = 'Second';
        assignee.LastName = 'Test User';
        assignee.Email = 'user22222@gus.com';
        Database.upsert(assignee);
        assignee = [select Name, Email from User where Id = :assignee.Id];
        
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        work.Status__c = 'In Progress';
        work.Subject__c = 'Test Work Subject';
        work.Assignee__c = null;
        work.QA_Engineer__c = null;
        work.Assignee__c = assignee.Id;
        insert work;
        work = ADM_Work.getById(work.Id);
        
        //create a change for a field that is being watched by Meat and Potatoes
        ADM_Work_Cache__c workCache = new ADM_Work_Cache__c();
        workCache.Work__r = work;
        workCache.User__c = UserInfo.getUserId();
        workCache.Field_Names_With_Changes__c = 'Status__c';
        workCache.Change_List_Description__c = 'Status description';
        workCache.Changes__c = '[{"typeCode":"M","fieldName":"Status__c","oldValue":"New", "newValue":"' + work.Status__c + '"}]';
        insert workCache;
        workCache = [select Id, Field_Names_With_Changes__c, Change_List_Description__c, Changes__c from ADM_Work_Cache__c where Id = :workCache.Id];
        
        //create a user that is 'meat & potatoes' 
        User subscriberUser = ADM_WorkUser.createTestUser();
        subscriberUser.FirstName = 'First';
        subscriberUser.LastName = 'Test User';
        subscriberUser.Email = 'user11111@gus.com';
        subscriberUser.Notification_Level__c = 'Meat & Potatoes';
        Database.upsert(subscriberUser);
        subscriberUser = [select Name, Email from User where Id = :subscriberUser.Id];
        
        //add the subscriber
        ADM_Work_Subscriber__c subscriber1 = new ADM_Work_Subscriber__c();
        subscriber1.WorkId__c = work.Id; 
        subscriber1.UserId__c = subscriberUser.Id;
        Database.insert(subscriber1);
        
        Map<Id, ADM_WorkCacheWrapper> workCacheMap = new Map<Id, ADM_WorkCacheWrapper>{work.Id => new ADM_WorkCacheWrapper(workCache)};
        List<ADM_Work__c> newWorks = new List<ADM_Work__c>{work};
        Boolean isInsert = true;
        User currentUser = [select Id, Name, Username from User where Id = :UserInfo.getUserId()];
        
        Test.startTest();
        List<ADM_ChangeListMessage> changeListMessages = createChangeListMessages(workCacheMap, newWorks, isInsert, currentUser);
        Test.stopTest();
        
        System.assertEquals(1, changeListMessages.size(), 'Expected there to be at least one message to be generated.');
        
        Boolean foundSubscriber = false;
        for(ADM_ChangeListMessage changeListMessage : changeListMessages) {
            for(String bccAddress : changeListMessage.bccAddresses) {
                if(bccAddress == subscriberUser.Email) {
                    foundSubscriber = true;
                    break;
                }
            }
            
            for(String ccAddress : changeListMessage.ccAddresses) {
                if(ccAddress == subscriberUser.Email) {
                    foundSubscriber = true;
                    break;
                }
            }
            
            for(String toAddress : changeListMessage.toAddresses) {
                if(toAddress == subscriberUser.Email) {
                    foundSubscriber = true;
                    break;
                }
            }
        }
        System.assert(foundSubscriber, 'Expected the subscriber to be one of the recipients on the message.');
    }
    
    testMethod static void testGetDomains() {
        System.assert(ADM_WorkUtils.getDomains() != null);
    }
    
    class ADM_WorkCacheWrapper {
        private ADM_Work_Cache__c workCache = null;
        private List<Change> changes = null;
        private String[] fieldNames = null;
        private String[] changeListDescriptions = null;
        
        public ADM_WorkCacheWrapper(ADM_Work_Cache__c workCache) {
            this.workCache = workCache;
            
            //initialize the field name property
            if(workCache.Field_Names_With_Changes__c != null) {
                this.fieldNames = workCache.Field_Names_With_Changes__c.split(ADM_WorkUtils.DELIMITER);
            } else {
                this.fieldNames = new String[0];
            }
            
            //initialize the change list property
            if(workCache.Change_List_Description__c != null) {
                this.changeListDescriptions = workCache.Change_List_Description__c.split(ADM_WorkUtils.DELIMITER);
            } else {
                this.changeListDescriptions = new String[0];
            }
            
            //initialize the changes property
            if(workCache.Changes__c != null) {
                this.changes = changeListFromJSON(workCache.Changes__c);
            } else {
                this.changes = new List<Change>();
            }
        }
        
        public ADM_Work_Cache__c getWorkCache() {
            return this.workCache;
        }
        
        public String[] getFieldNamesWithChanges() {
            return this.fieldNames;
        }
        
        /**
         * Gets the list of change descriptions associated to this change. If no
         * changes have been made, this will return an empty array.
         */
        public String[] getChangeListDescriptions() {
            return this.changeListDescriptions;
        }
        
        public Boolean hasChangeListDescriptions() {
            return !this.changeListDescriptions.isEmpty();
        }
        
        public Boolean isFieldModified(String fieldName) {
            //FIXME change this to check the changes objects
            //currently there is an issue where a field can be added without 
            //being added to the changes list and vice versa
            for(String changedFieldName : this.fieldNames) {
                if(changedFieldName.equalsIgnoreCase(fieldName)) {
                    return true;
                }
            }
            return false;
        }
        
        /**
         * Adds a changed field to the current WorkCache instance
         */
        public void addFieldNameWithChange(String fieldName) {
            if(fieldName != null) {
                this.fieldNames.add(fieldName);
                
                //update the work cache record
                if(this.fieldNames.size() != 1) {
                    workCache.Field_Names_With_Changes__c += ADM_WorkUtils.DELIMITER + fieldName;
                } else {
                    workCache.Field_Names_With_Changes__c = fieldName;  
                }
            }
        }
        
        /**
         * Adds a list of changed fields to the current WorkCache instance
         */
        public void addFieldNamesWithChange(List<String> fieldNames) {
            for(String fieldName : fieldNames) {
                this.addFieldNameWithChange(fieldName);
            }
        }
        
        public void addChangeListDescription(String description) {
            if(description != null) {
                this.changeListDescriptions.add(description);
                
                //update the work cache record
                if(this.changeListDescriptions.size() != 1) {
                    workCache.Change_List_Description__c += ADM_WorkUtils.DELIMITER + description;
                } else {
                    workCache.Change_List_Description__c = description;  
                }
            }
        }
        
        public void addChangeListDescriptions(List<String> descriptions) {
            for(String description : descriptions) {
                this.addChangeListDescription(description);
            }
        }
        
        /**
         * Gets the first change corresponding to the specified field name. If
         * the field was not changed, then a null reference is returned.
         */
        public Change getChangeByFieldName(String fieldName) {
            for(Change change : changes) {
                if(change.fieldName.equalsIgnoreCase(fieldName)) {
                    return change;
                }
            }
            return null;
        }
        
        public void setChanges(List<Change> changes) {
            this.changes = new List<Change>(changes);
            workCache.Changes__c = changeListToJSON(changes);
        }
        
        public List<Change> getChanges() {
            if(this.changes == null) {
                return new List<Change>();
            }
            return new List<Change>(this.changes);
        }
        
        public Boolean hasChanges() {
            return this.changes != null && !this.changes.isEmpty();
        }
    }
    
    
    /**
     * Represents an addition, removal, or modification of a field on.
     *
     * An additionition ("add") is when a field goes from null to a value.
     * A removal ("remove") is when a field goes from a value to null.
     * A modification ("modify") is when a field changes value.
     */
    public class Change {
        /**
         * Determines what type of change was made. Can be any of the following 
         * values:
         * 
         * * A - add
         * * R - remove
         * * M - modify
         *
         * A string is used (and not a Enum) because this object is serialized
         * using the System.JSON.serialize() method which does not support
         * Enum types.
         */
        public String typeCode;
        public String fieldName;
        public String oldValue;
        public String newValue;
        
        public boolean isAdd() {
            return this.typeCode == 'A';
        }
        public boolean isRemove() {
            return this.typeCode == 'R';
        }
        public boolean isModify() {
            return this.typeCode == 'M';
        }
    }
    
    /**
     * Wraps a work instance to provide convenience methods.
     */
    private class WorkWrapper {
        public Id Id {
            get {
                return this.work.Id;
            }
        }
        public ADM_Work__c work;
        public List<ADM_Work_Subscriber__c> subscribers;
        
        public WorkWrapper(ADM_Work__c work, List<ADM_Work_Subscriber__c> subscribers) {
            this.work = work;
            this.subscribers = (subscribers != null) ? subscribers : new List<ADM_Work_Subscriber__c>();
        }
        
        public Boolean isAssignee(User user) {
            sObject sWork = (sObject)work;
            Set<String> assigneeFields = ADM_Work.USER_FIELDS_MAP.keySet();
            for(String field : assigneeFields) {
                try {
                    if(sWork.get(field) == null) {
                        continue;
                    }
                
                    String value = String.valueOf(sWork.get(field));
                    if(String.valueOf(user.Id) == value) {
                        return true;
                    }
                
                } catch(Exception exc) {
                    System.debug(LoggingLevel.WARN, 'Error determining if the user is an assignee. ' + exc.getMessage());
                }
            }
            return false;
        }
        
        /**
         * Determines if the user is a subscriber, which normally corresponds
         * to the "Other Recipients" property.
         *
         * This method will always return false if constructed with a null subscriber list.
         */
        public Boolean isSubscriber(User user) {
            for(ADM_Work_Subscriber__c subscriber : subscribers) {
                try {
                    if(subscriber.UserId__c == user.Id) {
                        return true;
                    }
                } catch(Exception exc) {
                    System.debug(LoggingLevel.WARN, 'Error determining if the user is a subscriber. ' + exc.getMessage());
                }
            }
            return false;
        }
    }
    
    public static void sendEmailToAssigneesOnFeedPost(List<Id> workIdsFromPost){
        //Property to distinguish the origin of mail message
        List<ADM_ChangeListMessage> messageToAssigneesList = getMessagesToAssignees(workIdsFromPost,CHATTER_POST);
        if(messageToAssigneesList.size()>0){
            ADM_WorkEmail.sendNotification(messageToAssigneesList);
        }
        
    }
    
    public static List<ADM_ChangeListMessage> getMessagesToAssignees(List<Id> workIdsFromPost, String mailOrigin){

        List<ADM_ChangeListMessage> messageToAssigneesList = new List<ADM_ChangeListMessage>();
        User currentUser = ADM_WorkUser.get(UserInfo.getUserId());
        //Get the record types
        Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
        //ADM_Work__c records associated with Chatter post which initiated email
        List<ADM_Work__c> newWorks = ADM_Work.getAllById(workIdsFromPost);
        //Converting List<Id>  to Set<Id>
        Set<Id> workIdSet = new Set<Id>(workIdsFromPost);
        
        List<EntitySubscription> currentEntitySubscribers = getExistingEntitySubscribersForWorks(workIdSet,new Set<Id>());

        // No point to proceed further if there is no EntitySubscribers for this work - "Fail Fast"
        if(null != currentEntitySubscribers && currentEntitySubscribers.size() > 0){
        
            Map<Id, Set<String>> workIdToSubscribersMap = ADM_EntitySubscriptionUtils.getWorkIdToSubscriberMapFromEntitySubscribers(currentEntitySubscribers);

            // Map have List of users and below method combine it to singe Set create userCache
            Set<String> workSubscriberIds = ADM_TextUtils.joinListValues(workIdToSubscribersMap.values());

            ADM_UserCache userCache = new ADM_UserCache(ADM_WorkUser.getUsers('id', workSubscriberIds));

            List<ADM_ChangeListMessage.Recipient> recipients = new List<ADM_ChangeListMessage.Recipient>();
            
            List<FeedItem> posts = ADM_FeedItemUtil.getRecentFeedItemsByParentId(workIdsFromPost);
            Map<Id,List<FeedItem>> postsOnWork = new Map<Id,List<FeedItem>>();
            for(FeedItem postOnWorkItem: posts){
                if(null != postsOnWork.get(postOnWorkItem.parentId)){
                    postsOnWork.get(postOnWorkItem.parentId).add(postOnWorkItem);
                }
                else{
                    List<FeedItem> workItemPosts = new List<FeedItem>();
                    workItemPosts.add(postOnWorkItem);
                    postsOnWork.put(postOnWorkItem.parentId,workItemPosts);
                }
            }
            
            for(ADM_Work__c nw : newWorks){
                // Bug Fix https://gus.my.salesforce.com/a07B0000000cXIUIA2
                recipients.clear();

                //get the a map of field values from the work object
                Map<String, String> coreValues = ADM_CoreValues.getCoreValues(false, nw, userCache, workRecordTypesById);

                //create the subject
                String subjectLine = createSubject(nw, workRecordTypesById.get(nw.RecordTypeId).Name);
                List<ADM_ChangeListMessage.Recipient> recs = getToBeNotified(nw,userCache,currentUser,workIdToSubscribersMap,mailOrigin);            
                recipients.addAll(recs);
                ADM_ChangeListMessage message = new ADM_ChangeListMessage(coreValues, recipients, subjectLine, postsOnWork.get(nw.id),  currentUser);
                messageToAssigneesList.add(message);
            }
        }
        
        return messageToAssigneesList;
    }
    
     
    
    private static Boolean validateUserForChatterPostEmail(User u, String mailOrigin){
        // Not using doesUserWantNotification as Chatter post generated email has very simple validations to be done before sending email
        // Current user who creates post will not receive email on chater post
        
        if(CHATTER_POST == mailOrigin && u.Id == UserInfo.getUserId()){
            return false;
        }
        else {
            return true;
        }
    }   
    
    
    private static Boolean wasStatusChanged(ADM_WorkCacheWrapper wChacheWrapper){
        //check to see if the status was changed
            return wChacheWrapper.isFieldModified('Status__c');
    }  
    
    private static Boolean canAddUserToRecipientList(ADM_Work__c work, User u,User currentUser){
        //make sure we don't have any restricted recipients in the list
        //The Email2GUS_Addresses__c will contain restricted email addresses but only check when the user is Email2GUS
        try {
            //If user to be checked is passed null then assign current user
            u = (null == u)?currentUser:u;
            if(ADM_WorkUser.isEmail2GusUser(currentUser) && work.Email2GUS_Addresses__c != null) {
                Set<String> restrictedAddresses = new Set<String>(work.Email2GUS_Addresses__c.toLowerCase().split(','));
                
                if(restrictedAddresses.contains(u.Email)){
                    return false;
                }
                
            }
        } catch (System.Exception e) {
            System.debug(LoggingLevel.WARN, 'WARNING:' + e);
        }
        return true;
    } 

    /* 
        W-1927936. 
        https://gus.my.salesforce.com/a07B0000000bhupIAA
        Next generation work page will be showing other recipients are followers of Work-Item.
    */
    public static void addEntitySubscribersForWork(Map<Id, ADM_Work__c> newWorksMap, Boolean isInsert){
        
        Map<String, Set<String>> workId2AssigneesMap = new Map<String, Set<String>>();
        Map<String, Set<String>> workIdsAndAssigneesIds = getAssigneessAndWorkIdsFromWorks(newWorksMap.values(), workId2AssigneesMap);
        
        /*
            Below method will combine all the ids and email addresses into one set to make one soql call 
            to get the list of users
        */

        Map<Id, User> uMap = new Map<Id, User>(ADM_WorkUser.getUsers('Id',workIdsAndAssigneesIds.get('assigneeIds'),10000));

        List<EntitySubscription> existingEntitySubscribers = new List<EntitySubscription>() ;
        Map<Id, Set<String>> workIdToSubscribersMap = new Map<Id, Set<String>> ();
        

        /*
            W-2071992 - removing isInsert check { Before adding assignees existing entity subscribers check need to be done}
            
            
            
            Find existing entity subscribers for the Work-Items passing in the Work-Ids and the user Ids we found who are
            candidates for AutoSubscribing to Work Item
        */



        existingEntitySubscribers = getExistingEntitySubscribersForWorks(newWorksMap.keySet(), uMap.keySet()); //1 SOQL



        workIdToSubscribersMap = ADM_EntitySubscriptionUtils.getWorkIdToSubscriberMapFromEntitySubscribers(existingEntitySubscribers);

       
       
        List<EntitySubscription> followers = new List<EntitySubscription>();
        
        for(User workUser: uMap.values()){
           for(Id workId: newWorksMap.keySet()){
                /*
                         The set.contains will save us from using more SOQL queries. 
                            What happens if ID length is going to be changed from/to 15/18 characters?
                                ID length or case sensitivity will not matter because of two reasons 
                                   1) we are only dealing with System returned ID so the change will be reflected for all ID fields across all objects
                                   2) The worse case here is we won't be able to determine Entity Subscription exists for workId + subscriber id here and proceed with creating a new
                                      EntitySubscription which will cause DML excpetion, but we are using Database.insert({entities}, false) - so dml will continue with successful records
                */
                Set<String> subscribersAlreadyWithThisWork = null;
                if(null != workIdToSubscribersMap){
                     subscribersAlreadyWithThisWork = workIdToSubscribersMap.get(workId);
                }
                else{
                    workIdToSubscribersMap = new Map<Id, Set<String>> ();
                }

                if(subscribersAlreadyWithThisWork != null && subscribersAlreadyWithThisWork.contains(workUser.Id)){//If this is true then this user is already a subscriber of this Work-Item, so continuing to next iteration
                    continue;
                }
                else{
                     /*
                            Ok, At this point WorkId + workUser.Id is eligible for EntitySubscription, but wait....
                                Doing a final check to make sure the Work user is one of the subscriber on the work record. Better to be paranoid than a mixing up of EntitySubscribers on a bulk Work Updates
                     */
                     Set<String> workAssignees = workId2AssigneesMap.get(workId);
                     if(null != workAssignees && workAssignees.contains(workUser.Id)){ //Getting the set of Subscribers on the work record...If this is null don't worry about creating Entity Subscription
                            System.debug('Adding follower');
                            EntitySubscription workFolllower  = new EntitySubscription(parentId=workId, subscriberId=workUser.Id);
                            followers.add(workFolllower);

                            //Once added to the list of followers to be inserted adding it to the list of workIdToSubscribersMap to avoid duplicated id found error

                            if(null == subscribersAlreadyWithThisWork){
                                subscribersAlreadyWithThisWork = new Set<String>();
                            }
                            subscribersAlreadyWithThisWork.add(workUser.Id);
                            workIdToSubscribersMap.put(workId,subscribersAlreadyWithThisWork);
                     }
                }
            }
        }

        ADM_EntitySubscriptionUtils.insertEntitySubscriptions(followers);
  
    }

    /*
        This method returns the assingess,other recipients of a work which are populated by assignment rule from a product tag
        based on the record type.
        Return type is a List of strings containing Id/email address to query User object to get User record
    */
    private static Map<String, Set<String>> getAssigneessAndWorkIdsFromWorks(List<ADM_Work__c> works, Map<String, Set<String>> workId2AssigneesMap){
        
        Map<String,Set<String>> workIdsAndAssigneesIds = new Map<String,Set<String>>();
        Set<String> assigneeIds = new Set<String>();
        Set<String> workIds = new Set<String>(); 

        Set<String> workAssigneesSet;
        
       
        for(ADM_Work__c work : works){
            workAssigneesSet = new Set<String>();
            SObject workSObject = (SObject)work;
            for(String fieldName:WORK_ENTITY_SUBSCRIBERS){//Explicitly NOT checking whether a change happened or not; All time there is a work update assingees will be chcked for EntitySubscription
                String fieldValue = (String)workSObject.get(fieldName);  
                assigneeIds.add(fieldValue);  
                workAssigneesSet.add(fieldValue);
            }
            
            //now remove null from the set before adding to map
            assigneeIds.remove(null);
            workAssigneesSet.remove(null);
            workIds.add(work.Id);

            workId2AssigneesMap.put(work.Id, workAssigneesSet);
        }

        workIdsAndAssigneesIds.put('workIds', workIds);
        if(assigneeIds.size() > 0){
            workIdsAndAssigneesIds.put('assigneeIds', assigneeIds);
        }

        
        return workIdsAndAssigneesIds;
    }

    private static List<EntitySubscription> getExistingEntitySubscribersForWorks(Set<Id> workIds, Set<Id> userIds){
        return ADM_EntitySubscriptionUtils.getAllBy(workIds, userIds);
    }

    //Return true if originating from classic/next gen edit page
    public static boolean isOriginatingFromEditPage(String origin){

        if(origin == ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN || origin ==  ADM_WorkTriggerStaticDataStore.NEXT_GEN_EDIT_PAGE_ORIGIN){
            return true;
        }

        return false;
    }

    private static void buildWorkSubscribersFromWorkList(List<ADM_Work__c> newWorks){
        List<ADM_Work_Subscriber__c> newWorkSubs = ADM_NotificationUtils.buildWorkSubscribersFromWorkList(newWorks);
        Database.insert(newWorkSubs);
    }

    public static void processWorkSubscribers(List<ADM_Work__c> newWorks, Boolean isWorkInsert, String origin){
        try {

            if(origin != null && origin.equalsIgnoreCase(ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN)) {
                //edits orginating from the edit page have subscribers encoding to allow fast client side interaction
                ADM_NotificationUtils.processSubscribers(newWorks);
            } else if(origin != null && origin.equalsIgnoreCase(ADM_WorkTriggerStaticDataStore.NEXT_GEN_EDIT_PAGE_ORIGIN)) {
                //removing and adding subscribers on edit
                ADM_NotificationUtils.removeAutoAssignedSubscribers(newWorks);
                buildWorkSubscribersFromWorkList(newWorks);
            } else if(isWorkInsert) {
                //for records originating outside of the edit page (API, List View) we can create subscribers from assignment rules directly
                //only process on insert since ADM_AutoAssignWorkAction.applyAutoAssignmentRules() only populates Email_Subscription_ID__c 1 time.
                buildWorkSubscribersFromWorkList(newWorks);
            }

            
            
        } catch (DMLException dmle) {
            for (Integer i = 0; i < dmle.getNumDml(); i++) {
                if (dmle.getDmlType(i) == System.Statuscode.INVALID_EMAIL_ADDRESS) {
                    throw dmle;
                }
            }
            System.debug('processChangeList() unexpected error:' + dmle + ' line number:' + dmle.getLineNumber());
        } catch (System.Exception e) {
            System.debug('processChangeList() Unexpected error processing subscribers:' + e);
        }
    }

    public static void removeChangedUsersFromWorkEntitySubscription(List<ADM_Work__c> newWorks, Map<Id,ADM_Work__c> oldWorksMap){
        SObject newSObjectWork;
        SObject oldSObjectWork;
        Map<Id,Set<Id>> workId2SubscribersMap = new Map<Id,Set<Id>>();
        Set<Id> subscriberIdsToBeRemoved;
        for(Integer counter=0; counter<newWorks.size(); counter++){
            newSObjectWork = (SObject) newWorks[counter];

            oldSObjectWork = (SObject) oldWorksMap.get(newSObjectWork.Id);
            subscriberIdsToBeRemoved = new Set<Id>();
            
            for(String fieldName:WORK_ENTITY_SUBSCRIBERS){
                
                if(oldSObjectWork.get(fieldName) != null && (oldSObjectWork.get(fieldName) != newSObjectWork.get(fieldName))){
                    subscriberIdsToBeRemoved.add((Id)oldSObjectWork.get(fieldName));
                }
            }
            if(subscriberIdsToBeRemoved.size()>0 ){
                workId2SubscribersMap.put(oldSObjectWork.Id, subscriberIdsToBeRemoved);
            }
        }


        
        EntitySubscription[] entitySubscriptions = ADM_EntitySubscriptionUtils.getAllBy(workId2SubscribersMap.keySet(), ADM_TextUtils.joinListValues(workId2SubscribersMap.values()));
        
        List<EntitySubscription> toBeDeletedES = new List<EntitySubscription>();

        for(EntitySubscription entitySubscription : entitySubscriptions){
            if(workId2SubscribersMap.get(entitySubscription.parentId).contains(entitySubscription.subscriberId)){
                toBeDeletedES.add(entitySubscription);
            }
        }
        
        ADM_EntitySubscriptionUtils.deleteEntitySubscriptions(toBeDeletedES);

    }

    public static String getFeedItemPostBodyBasedOnType(FeedItem post){
        String body = post.body;
        String message = '';
        if(null == body || 0 == body.length()){
            
            if(post.Type == 'ContentPost'){
                message += 'Attached a file named ' + new ADM_TextUtils().escapeHTML(post.ContentFileName);
            }
            else if(post.Type == 'LinkPost'){
                 message += 'Posted a link ' + new ADM_TextUtils().escapeHTML(post.LinkUrl);
            }
        }
        return message;
    }

}