/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public with sharing class ADM_WorkUtilsTest {
    testmethod static void extractElsFromSobjects() { 
        ADM_Work__c[] els = new ADM_Work__c[]{};
        Set<String> ids = new Set<String>();
        Set<String> names = new Set<String>();
        
        for(Integer i = 0; i < 2; i++) {
            ADM_Work__c work = ADM_Work.createTestTodo();
            els.add(work);
            ids.add(String.valueOf(work.Id));
            names.add(String.valueOf(work.Name));
        }
        
        verifyElementsAreContained(ADM_WorkUtils.extractElsFromSobjects(els, 'Id'), ids);
        verifyElementsAreContained(ADM_WorkUtils.extractElsFromSobjects(els, 'Name'), names);
    }
    
    /*
 @testcaseID  a1DB00000000kSv
 @userstoryID a07B0000000DlSE
 @Hierarchy GUS.ScrumforcetoGUS.ScrumTeams.New Chatter Group
 @ExpectedResults User is able to click on these chatter groups
 @Author = Alexis Williams
 */

    testMethod static void testRemoveTrailingCommas() {
        String s;
        System.assertEquals(null, ADM_WorkUtils.removeTrailingComma(s));
        
        s = '';
        System.assertEquals(s, ADM_WorkUtils.removeTrailingComma(s));
        
        s = ', ';
        System.assertEquals('', ADM_WorkUtils.removeTrailingComma(s));
        
        s = 'test, test,';
        System.assertEquals('test, test', ADM_WorkUtils.removeTrailingComma(s));
    }
    
    testMethod static void testLargeComment() {
        ADM_Work__c newWork = ADM_Work.createTestWork();
        ADM_Work__c oldWork = ADM_Work.createTestWork();
        
        //delete the cache objects that were created during the createTestWork calls
        delete [select Id from ADM_Work_Cache__c where Work__c = :newWork.Id];
        
        Boolean isWorkInsert = false;
        
        newWork.Subject__c = 'a'.repeat(255);
        newWork.Customer__c = 'a'.repeat(255);
        newWork.Comment_Copy__c = 'a'.repeat(32000);
    
        Test.startTest();
        ADM_WorkUtils.processNotifications(new List<ADM_Work__c>{newWork}, new List<ADM_Work__c>{oldWork}, isWorkInsert, !isWorkInsert, ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN);
        Test.stopTest();
        
        System.assertEquals(1, [select Id from ADM_Work_Cache__c where Work__c = :newWork.Id].size(), 'Expected a work cache to be created for the work record');
    }
    
    private static void verifyElementsAreContained(List<String> els, Set<String> values) {      
        for(String el : els) {
            System.assertEquals(true, values.contains(el));
        }
    }
    
    testMethod static void testSendEmailToAssigneesOnFeedPost() {
        ADM_Work__c bug  = ADM_Work.createTestBug();
        FeedItem testFeed1 = new FeedItem();
        testFeed1.Body = 'Test feed1 for apex test';
        testFeed1.ParentId = bug.Id;
        insert testFeed1;
        
        ADM_Work__c userStory  = ADM_Work.createTestWork('User Story');
        FeedItem testFeed2 = new FeedItem();
        testFeed2.Body = 'Test feed1 for apex test';
        testFeed2.ParentId = userStory.Id;
        insert testFeed2;
        
        List<Id> workIds = new List<Id>();
        workIds.add(bug.id);
        workIds.add(userStory.id);
        List<ADM_ChangeListMessage> changeListMessages = ADM_WorkUtils.getMessagesToAssignees(workIds, 'Chatter Post');
        System.debug('asserting change list size');
        System.assert(changeListMessages.size()>0,'Expected ChangesListMessage to be populated');
        
        if(changeListMessages.size() > 0){System.debug('inside changelistMessages');
            for(ADM_ChangeListMessage clm : changeListMessages){
            Messaging.SingleEmailMessage singleEmailMessage = clm.toEmailMessage();
        
            System.assert(singleEmailMessage.getSubject().contains('Test Work Subject'), 'Email subject from chatter post triggered emails should have the work subject');
            System.debug('QA is ' + bug.QA_Engineer__r.Name);
            }
        }
        
        
    }
    
    /*
      Bug fix for email send to unknown recipients on work batch update
      Please refer Bug
      https://gus.my.salesforce.com/a07B0000000cXIUIA2
    */
    testMethod static void testRecipientsOnWorkBatch() {
        List<ADM_Work__c> bugs  = ADM_Work.createListOfWork(2,'Bug');
        ADM_Work__c bug1 = bugs.get(0);
        ADM_Work__c bug2  = bugs.get(1);
        
        User [] users = new User[2];
        User assigneeForBug1 = ADM_WorkUser.setupTestUser();
        assigneeForBug1.Email = 'firstuser@test.com';
        assigneeForBug1.Alias = '1t$%#a';
        assigneeForBug1.UserName = 'test@gus.com'+Math.random();
        assigneeForBug1.Notification_Level__c = 'The Whole Enchilada';
        users[0] = assigneeForBug1;
        User assigneeForBug2 = ADM_WorkUser.setupTestUser();
        assigneeForBug2.Email = 'seconduser@test.com';
        assigneeForBug1.Alias = '2t$%#a';
        assigneeForBug1.UserName = 'test@gus.com'+Math.random();
        assigneeForBug2.Notification_Level__c = 'The Whole Enchilada';
        users[1] = assigneeForBug2;
        
        insert users;
        
        bug1.Assignee__c = users[0].Id;
        bug1.QA_Engineer__c = users[0].Id;
        bug1.Product_Owner__c = users[0].Id;
        bug1.Tech_Writer__c = users[0].Id;
        bug1.Senior_Management_POC__c = users[0].Id;
        bug1.System_Test_Engineer__c = users[0].Id;
        bug1.UE_Engineer__c = users[0].Id;
        bug1.Subject__c = 'Bug1';
        bug1.Email_Subscription_ID__c = '';

        bug2.Assignee__c = users[1].Id;
        bug2.QA_Engineer__c = users[1].Id;
        bug2.Product_Owner__c = users[1].Id;
        bug2.Tech_Writer__c = users[1].Id;
        bug2.Senior_Management_POC__c = users[1].Id;
        bug2.System_Test_Engineer__c = users[1].Id;
        bug2.UE_Engineer__c = users[1].Id;
        bug2.Subject__c = 'Bug2';
        bug2.Email_Subscription_ID__c = '';


        ADM_Work__c [] bugsToInsert = new ADM_Work__c[2];
        bugsToInsert[0] = bug1;
        bugsToInsert[1] = bug2;
        
        insert bugsToInsert;
        
        List <id> workIds = new List<id>();
        
        workIds.add(bugsToInsert[0].Id);
        workIds.add(bugsToInsert[1].Id);
        List<ADM_ChangeListMessage> changeListMessages =  ADM_WorkUtils.getMessagesToAssignees(workIds, 'Chatter Post');
        
        for(ADM_ChangeListMessage changeListMessageIter : changeListMessages){
            Set<String> toEmailSet = new Set<String>();
            toEmailSet.addAll(changeListMessageIter.toAddresses);
            System.debug('toEmailSet ' + toEmailSet);
            if(changeListMessageIter.subjectLine.contains('Bug1')){
                System.assert(toEmailSet.contains('firstuser@test.com'),'User email address expected on the to list');
                System.assert(false==toEmailSet.contains('seconduser@test.com'),'Unexpected email address on to line');
            }
            else{
                System.assert(toEmailSet.contains('seconduser@test.com'),'User email address expected on the to list');
                System.assert(false==toEmailSet.contains('firstuser@test.com'),'Unexpected email address on to line');
            }
        }
    }

    /*
        With the W-1927936 change Entity Subscription will be created for users associated to Work items and all the values on Email_Subscription_ID__c field.
        Entity subscription will be created for assignee, qa, productOwner,techWriter,seniorManagerPOC,systemTestEngineer,ueEngineer + users corresponding to values on Email_Subscription_ID__c.
        Email_Subscription_ID__c can have username,email,alias
    */
    testMethod static void testAddEntitySubscribersForWork() {
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
        User csContact = ADM_WorkUser.setupTestUser();

        User subscriber1 = ADM_WorkUser.setupTestUser();
        User subscriber2 = ADM_WorkUser.setupTestUser();
        User subscriber3 = ADM_WorkUser.setupTestUser();
        

        subscriber1.userName = 'tuser@gus.com'+Math.random();

        String alias = 'a'+Math.random();
        subscriber3.alias = (alias.length() >=0)?alias.substring(0,8):alias;

        assignee.Email = 'test1@test.com';
        qa.Email = 'test2@test.com';
        productOwner.Email = 'test3@test.com';
        techWriter.Email = 'test4@test.com';
        seniorManagerPOC.Email = 'test5@test.com';
        systemTestEngineer.Email = 'test7@test.com';
        ueEngineer.Email = 'test8@test.com';
        csContact.Email = 'test9@test.com';

        subscriber1.Email = 'subscriber1@test.com';
        subscriber2.Email = 'subscriber2@test.com';
        subscriber3.Email = 'subscriber3@test.com';



        insert new User[]{assignee,qa,productOwner,techWriter,seniorManagerPOC,systemTestEngineer,ueEngineer,csContact,subscriber1,subscriber2,subscriber3};

        
        System.debug('users are '+ assignee.id + ' name '+ assignee.name );
        System.debug('users are '+ qa.id + ' name '+ qa.name );
        System.debug('users are '+ productOwner.id + ' name '+ productOwner.name );
        System.debug('users are '+ techWriter.id + ' name '+ techWriter.name );
        System.debug('users are '+ seniorManagerPOC.id + ' name '+ seniorManagerPOC.name );
        System.debug('users are '+ systemTestEngineer.id + ' name '+ systemTestEngineer.name );
        System.debug('users are '+ ueEngineer.id + ' name '+ ueEngineer.name );
        System.debug('users are '+ csContact.id + ' name '+ csContact.name );
        System.debug('users are '+ subscriber1.id + ' name '+ subscriber1.name );
        System.debug('users are '+ subscriber1.id + ' name '+ subscriber2.name );
        System.debug('users are '+ subscriber1.id + ' name '+ subscriber2.name );

        work.Assignee__c = assignee.Id;
        work.QA_Engineer__c = qa.Id;
        work.Product_Owner__c = productOwner.Id;
        work.Tech_Writer__c = techWriter.Id;
        work.Senior_Management_POC__c = seniorManagerPOC.Id;
        work.System_Test_Engineer__c = systemTestEngineer.Id;
        work.UE_Engineer__c = ueEngineer.Id;
        work.CS_Contact__c = csContact.Id;

        work.Email_Subscription_ID__c = subscriber1.userName + ',' + subscriber2.Email + ',' + subscriber3.alias;
        insert work;

        EntitySubscription[] entitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());
        
        for(EntitySubscription esIter: entitySubscribers){
            System.debug('subscriber id is ' + esIter.subscriberId);

        }
        System.debug('size is '+ entitySubscribers.size());
        System.assert(11 <= entitySubscribers.size(), 'At least 11 entity subscribers expected - 8 assigned users and 3 subscribers through Email_Subscription_ID__c field ');
    }


      /*
        Test to verify there won't be problems like duplicate id etc if same user is repeated on assignee fields or other receipients on Email_subscription_Id__c
    */
    testMethod static void testAddEntitySubscribersForWork_SameUserForAssigneesAndOtherRecipients() {
        List<ADM_ChangeListMessage.Recipient> recipients;
        Set<String> recipientEmails = new Set<String>();
        
        ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P1');
        User assignee = ADM_WorkUser.setupTestUser();
        

        assignee.userName = 'tuser@gus.com'+Math.random();

        String alias = 'a'+Math.random();
        assignee.alias = (alias.length() >=0)?alias.substring(0,8):alias;

        assignee.Email = 'test1@test.com';
        
       


        insert new User[]{assignee};


        //Same user for all assignees below
        work.Assignee__c = assignee.Id;
        work.QA_Engineer__c = assignee.Id;
        work.Product_Owner__c = assignee.Id;
        work.Tech_Writer__c = assignee.Id;
        work.Senior_Management_POC__c = assignee.Id;
        work.System_Test_Engineer__c = assignee.Id;
        work.UE_Engineer__c = assignee.Id;

        work.Email_Subscription_ID__c = assignee.userName + ',' + assignee.Email + ',' + assignee.alias;
        insert work;

        EntitySubscription[] entitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());

        System.assertEquals(1,entitySubscribers.size(), 'Expected only one Entity Subscription for Work record as it is the same user repeated for all Assignees as well as Other recipients ');
    }
    
    testmethod static void testGUSProcessesCommentsAsyncWhenBatchSizeExceedsLimitOnInsert() {
        try {
            Test.startTest();
            List<ADM_Work__c> workBatch = ADM_Work.createListOfWork(180, 'Bug');
            //insert batch and check for errors
            Database.SaveResult[] lsr = Database.insert(workBatch);
            for(Database.Saveresult sr : lsr) {
                System.assert(sr.getErrors() == null || sr.getErrors().size() == 0, 'Async Batch test threw the following error:' + sr.getErrors());
            }
            Test.stopTest();
            //now that async process is complete (post stopTest()) we can assert comments were created
            List<ADM_Comment__c> comments = [select id, Work__c from ADM_Comment__c where Work__c in:workBatch];
            System.assert(comments != null && comments.size() > 0);
            System.assert(comments.size() == workBatch.size(), 'Only:' + comments.size() + ' comments were inserted.  Excepted ' + workBatch.size() + ' one for each work record in the batch.');
            
            
        } catch (System.Exception e) {
            System.assert(false, 'Did not expect this exception:' + e);
        }
    }
    
    
    
    testmethod static void testGUSProcessesCommentsAsyncWhenBatchSizeExceedsLimitOnEdit() {
        try {
            Test.startTest();
            List<ADM_Work__c> workBatch = ADM_Work.createListOfWork(180, 'Bug');
            //insert batch and check for errors
            Database.SaveResult[] lsr = Database.insert(workBatch);
            for(Database.Saveresult sr : lsr) {
                System.assert(sr.getErrors() == null || sr.getErrors().size() == 0, 'Async Batch test threw the following error:' + sr.getErrors());
            }
            
            //now attempt to edit the batch and process
            for(ADM_Work__c w: workBatch) {
                w.Subject__c = '123 Test';
            }
            
            //update batch and check for errors
            Database.SaveResult[] editlsr = Database.update(workBatch);
            for(Database.Saveresult esr : editlsr) {
                System.assert(esr.getErrors() == null || esr.getErrors().size() == 0, 'Async Batch test ON EDIT threw the following error:' + esr.getErrors());
            }
            
            Test.stopTest();
            //now that async process is complete (post stopTest()) we can assert comments were created
            List<ADM_Comment__c> comments = [select id, Work__c from ADM_Comment__c where Work__c in:workBatch];
            System.assert(comments != null && comments.size() > 0);
            System.assert(comments.size() == (workBatch.size() * 2), 'Only:' + comments.size() + ' comments were inserted.  Excepted ' + workBatch.size() + ' two for each work record in the batch (1 for comment on insert and 1 for subject edit).');
            
            
            
        } catch (System.Exception e) {
            System.assert(false, 'Did not expect this exception:' + e);
        }
    } 

    testmethod static void testRemoveChangedUsersFromWorkEntitySubscription() {
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
        User csContact = ADM_WorkUser.setupTestUser();

        User subscriber1 = ADM_WorkUser.setupTestUser();
        User subscriber2 = ADM_WorkUser.setupTestUser();
        User subscriber3 = ADM_WorkUser.setupTestUser();
        

        subscriber1.userName = 'tuser@gus.com'+Math.random();

        String alias = 'a'+Math.random();
        subscriber3.alias = (alias.length() >=0)?alias.substring(0,8):alias;

        assignee.Email = 'test1@test.com';
        qa.Email = 'test2@test.com';
        productOwner.Email = 'test3@test.com';
        techWriter.Email = 'test4@test.com';
        seniorManagerPOC.Email = 'test5@test.com';
        systemTestEngineer.Email = 'test7@test.com';
        ueEngineer.Email = 'test8@test.com';
        csContact.Email =  'test9@test.com';

        subscriber1.Email = 'subscriber1@test.com';
        subscriber2.Email = 'subscriber2@test.com';
        subscriber3.Email = 'subscriber3@test.com';



        insert new User[]{assignee,qa,productOwner,techWriter,seniorManagerPOC,systemTestEngineer,ueEngineer,csContact,subscriber1,subscriber2,subscriber3};



        work.Assignee__c = assignee.Id;
        work.QA_Engineer__c = qa.Id;
        work.Product_Owner__c = productOwner.Id;
        work.Tech_Writer__c = techWriter.Id;
        work.Senior_Management_POC__c = seniorManagerPOC.Id;
        work.System_Test_Engineer__c = systemTestEngineer.Id;
        work.UE_Engineer__c = ueEngineer.Id;
        work.CS_Contact__c = csContact.Id;

        Set<String> assigneeIdsBeforeChange = new Set<String>{assignee.Id,qa.Id,productOwner.Id,techWriter.Id,seniorManagerPOC.Id,systemTestEngineer.Id,ueEngineer.Id};

        work.Email_Subscription_ID__c = subscriber1.userName + ',' + subscriber2.Email + ',' + subscriber3.alias;
        insert work;

        EntitySubscription[] entitySubscribers = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());

        System.assertEquals(11,entitySubscribers.size(), '11 entity subscribers expected - 8 assigned users and 3 subscribers through Email_Subscription_ID__c field ');


        //All good so far...Now change the assignees and make sure the change is reflected in EntitySubscription also.

        User assignee2Change = ADM_WorkUser.setupTestUser();
        User qa2Change = ADM_WorkUser.setupTestUser();
        User productOwner2Change = ADM_WorkUser.setupTestUser();
        User techWriter2Change = ADM_WorkUser.setupTestUser();
        User seniorManagerPOC2Change = ADM_WorkUser.setupTestUser();
        User systemTestEngineer2Change = ADM_WorkUser.setupTestUser();
        User ueEngineer2Change = ADM_WorkUser.setupTestUser();
        User csContact2Change = ADM_WorkUser.setupTestUser();

        insert new User[]{assignee2Change,qa2Change,productOwner2Change,techWriter2Change,seniorManagerPOC2Change,systemTestEngineer2Change,ueEngineer2Change,csContact2Change};

        work.Assignee__c = assignee2Change.Id;
        work.QA_Engineer__c = qa2Change.Id;
        work.Product_Owner__c = productOwner2Change.Id;
        work.Tech_Writer__c = techWriter2Change.Id;
        work.Senior_Management_POC__c = seniorManagerPOC2Change.Id;
        work.System_Test_Engineer__c = systemTestEngineer2Change.Id;
        work.UE_Engineer__c = ueEngineer2Change.Id;
        work.CS_Contact__c = csContact2Change.Id;

        update work;

        Set<String> assigneeIdsAfterChange = new Set<String>{assignee2Change.Id,qa2Change.Id,productOwner2Change.Id,techWriter2Change.Id,seniorManagerPOC2Change.Id,systemTestEngineer2Change.Id,ueEngineer2Change.Id,csContact2Change.Id};

        EntitySubscription[] entitySubscribersAfterChange = ADM_EntitySubscriptionUtils.getAllBy(new List<Id>{work.Id}, new List<Id>());

        System.assert(11 <= entitySubscribers.size(), 'At least 10 entity subscribers expected - 7 assigned users and 3 subscribers through Email_Subscription_ID__c field ');

        //Make sure the previous assignees doesn't have an entity subscriptions and new assingees are there in the subscriber ID fields
        Set<String> subscribersFromResult = new Set<String>();
        Boolean assigneeFound = false;
        for(String assigneeId:assigneeIdsAfterChange){
            for(EntitySubscription esIter: entitySubscribersAfterChange){
                if(esIter.subscriberId == assigneeId){
                    assigneeFound = true;
                    break;
                }
            }
            System.assert(assigneeFound,'Expected Assignee in the Entity Subscribers');
            assigneeFound = false;
        }

    } 
}