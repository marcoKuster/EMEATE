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
private class ADM_WorkTest {

    static String gusNameSpace = ADM_ConstantsSingleton.getInstance().getNameSpace();

    static ADM_Work__c work {
        get {
            if(work == null) {
                work = ADM_Work.createTestWork();
            }
            return work;
        }
        set;
    }

    static ADM_Work__c work2 {
        get {
            if(work2 == null) {
                work2 = ADM_Work.createTestWork();
             }
            return work2;
        }
        set;
    }

    static ADM_Work__c[] works {
        get {
            if(works == null) {
                works = new ADM_Work__c[]{};
                works.add(work);
                works.add(work2);
            }
            return works;
        }
        set;
    }

    static String columnName {
        get { return 'Id'; }
        set;
    }

    static String columnValue {
        get { return work.Id; }
        set;
    }

    static String[] columnValuesString {
        get {
            if(columnValuesString == null) {
                columnValuesString = new String[]{};
                for(ADM_Work__c w : works) {
                    columnValuesString.add(w.Id);
                }
            }
            return columnValuesString;
        }
        set;
    }

    static String[] columnValues {
        get { return columnValuesString; }
        set;
    }

    static Integer rowStart {
        get { return 0; }
        set;
    }

    static Integer rowEnd {
        get { return 1000; }
        set;
    }

    static String sortBy {
        get { return columnName; }
        set;
    }

    static String sortOrder {
        get { return 'asc'; }
        set;
    }

    static testMethod void getAllByAsMap() {
        Map<Id,ADM_Work__c> workMap = ADM_Work.getAllByAsMap(columnName, columnValuesString, rowStart, rowEnd, sortBy, sortOrder);
        System.assert(workMap != null);
    }

    static testMethod void getOneBy() {
        System.assert(ADM_Work.getOneBy(columnName, columnValue).Id == work.Id);
    }

    static testMethod void getAll() {
        String id = work.Id;
        System.assert(ADM_Work.getAll(Id).size() == 1);
    }

    static testMethod void getLookupFieldsMap() {
        System.assert(ADM_Work.getLookupFieldsMap() != null);
    }

    static testMethod void getStatusValues() {
        System.assert(ADM_Work.getStatusValues() != null);
    }

    static testMethod void testWorkTrigger() {
        System.assertEquals(1, [select count() from ADM_Work__c where id = :work.id]);

    }

    testMethod static void test_toChangeListMessage_onUpdateAndInsert(){
        ADM_Work__c testWork = ADM_Work.createTestWork();
        ADM_Work__c clone = testWork.clone(false,true);
        User user_1 = ADM_WorkUser.createTestUser();
        ADM_Build__c build_1 = ADM_Build.createTestBuild();
        upsert clone;
        clone = ADM_Work.getAllBy('Id', new List<String>{clone.Id}, 0, 1, 'Id', 'ASC').get(0);
        clone.Priority__c = 'P0';
        
        testWork.Assignee__c = user_1.Id;
        testWork.Product_Owner__c = user_1.Id;
        testWork.System_Test_Engineer__c = user_1.Id;
        testWork.Tech_Writer__c = user_1.Id;
        testWork.QA_Engineer__c = user_1.Id;
        testWork.UE_Engineer__c = user_1.Id;
        testWork.Scheduled_Build__c = build_1.Id;
        upsert testWork;
        testWork = ADM_Work.getAllBy('Id', new List<String>{testWork.Id}, 0, 1, 'Id', 'ASC').get(0);
        testWork.Status__c = 'Closed';
        testWork.Perforce_Status__c = 'Open';
        testWork.Priority__c = 'P1';
        
        Boolean isInsert = false;
        Database.delete([select Id from ADM_Work_Cache__c where Work__c = : testWork.Id]);
        
        Test.startTest();
        ADM_WorkUtils.processNotifications(new List<ADM_Work__c>{testWork}, new List<ADM_Work__c>{clone}, isInsert, !isInsert, ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN);
        Test.stopTest();
        
        ADM_Work_Cache__c[] workCaches = [Select a.Change_List_Description__c, a.Field_Names_With_Changes__c From ADM_Work_Cache__c a where Work__c = : testWork.Id];
        Set<String> notificationFields = new Set<String>{'Priority__c', 'Assignee__c', 'QA_Engineer__c', 'Product_Owner__c', 'Tech_Writer__c', 'System_Test_Engineer__c', 'UE_Engineer__c', 'Perforce_Status__c', 'Scheduled_Build__c','Status__c'};
        String delimiter = ADM_WorkUtils.DELIMITER;

        for(ADM_Work_Cache__c workCache : workCaches) {
            if(workCache.Field_Names_With_Changes__c == null) {
                System.assert(workCache.Change_List_Description__c == null,'this should be null because it was the insert work cache object!');
            } else {
                for(String field : workCache.Field_Names_With_Changes__c.split(delimiter)) {
                    notificationFields.remove(field);
                }
            }
        }

        System.assert(notificationFields.isEmpty(), 'was expecting to have all notification fields accounted for. looks like there is something that was missed--->' + notificationFields);
        System.assert(workCaches.size() == 1,'was expecting to have 1 record for the update--->' + workCaches.size());
    }

    static testMethod void getAllLike() {
        ADM_Work__c[] w = ADM_Work.getAllLike('Scrumforce_ID__c', columnValues, rowStart, rowEnd, sortBy, sortOrder);
        System.assert(w.size() != null);
    }

    static testMethod void match() {
        ADM_Work__c w = ADM_Work.match(works, work.Id);
        System.assert(w.Id == work.Id);
    }

    static testMethod void get() {
        ADM_Work__c w = ADM_Work.get(columnName, columnValue, sortBy, sortOrder);
        System.assert(w.Id == work.Id);
    }

    static testMethod void createTestBug() {
        System.assert(ADM_Work.createTestBug() != null);
    }

    static testMethod void createTestTodo() {
        System.assert(ADM_Work.createTestTodo() != null);
    }

    static testMethod void createTestTemplate() {
        System.assert(ADM_Work.createTestTemplate() != null);
    }

    static testMethod void getWorkEditorDialogMetaDataTest(){
        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_Scrum_Team__c[] testTeams =  ADM_ScrumTeam.getAll(bug.Scrum_Team__c);
        List<ADM_Column__c> defaultColumnsCreated = ADM_ColumnUtility.createDefaultColumns(testTeams);
        ADM_Work.WorkEditorDialogMetaData metaData =  ADM_Work.getWorkEditorDialogMetaData(bug.id, bug.Scrum_Team__c);
        System.assertNotEquals(null, metaData, 'Expected not null value for WorkEditorDialogMetaData');
        System.assertEquals(metaData.workSObject.Id, bug.Id, 'Expected to get same work id object from metadata');
        System.assertNotEquals(null, metaData.bugStatuses, ' Expected to return bug statuses');
        System.assertNotEquals(null, metaData.userStoryStatuses, ' Expected to return user story statuses');
        //System.assertNotEquals(null,metaData.frequencies,' Expected to return frequencies');
        //System.assertNotEquals(null,metaData.impacts,' Expected to return impacts');
        //System.assertNotEquals(null,metaData.priorityMappings,' Expected to return priorityMappings');
        System.assertNotEquals(null,metaData.storyPoints,' Expected to return storyPoints');   
        System.assertNotEquals(null,metaData.leafNodeDetailsList,' Expected to return leafNodeDetailsList of KanbanBoard for the team this test work is assigned to');
    }

/**
* @testcaseID a0B20000009g6oOEAQ
* @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-801319
* @userstory a07B0000000DmEr
* @expected results Field label should read simply: "Production Incidents" and its help text should read: "The number of production incidents associated with this Work record. May include out-of-memory errors or gacks."
*/
    static testMethod void verifyNameOfNumberOfProductionIncidentsField() {
        Schema.Describefieldresult field = ADM_Work__c.Num_Of_Prod_Occ__c.getDescribe();
        System.assertEquals('Production Incidents', field.getLabel());
    }
    
 
    
    /**
        testcase ID: a1DB00000000axU
        user story ID: a07B0000000EMlMIAW
        Hierarchy: GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page
        Expected Results: Changing a bug where Source Control Status = open or open once to a status that is not valid for the perforce checkin will generate the following error message: "Please set the Status to one of the following values when opening the Source Control Status: Integrate, Triaged, In Progress, New, Ready for Review." 
        author: Alexis Williams  
    */
    static testMethod void verifyErrorMessagesOnPerforceStatus() {      
        ADM_Work__c w = ADM_Work.createTestBug();
        ADM_Build__c b = ADM_Build.createTestBuild();
        ADM_ErrorUtils errorutils = new ADM_ErrorUtils();
        List<String> messages;
        String message;
        String errorMessage = 'Please set the Status to one of the following values when opening the Source Control Status: ';
        //Test #1 Make sure we get an error when set to a not open status with p4 status open
        w.Status__c = 'Fixed';
        w.Perforce_Status__c = 'Open';
        w.QA_Engineer__c = Userinfo.getUserId();
        w.Scheduled_Build__c = b.Id;
        
        try {        
            update w;
            System.assertEquals(true, false);
        } catch(System.DmlException e) {
            message = errorutils.getErrorMessage(e);
            System.assertEquals(true, message.contains(errorMessage));
            message = message.replace(errorMessage, '');
            System.assertEquals(message.split(',').size(), ADM_Work.STATUS_VALUES_OPEN.size());                     
        }
        
        //Test #2 Make sure we get an error when set to a not open status with p4 status open once
        w.Perforce_Status__c = 'Open Once';
        
        try {        
            update w;
            System.assertEquals(true, false);
        } catch(System.DmlException e) {
            message = errorutils.getErrorMessage(e);
            System.assertEquals(true, message.contains(errorMessage));
            message = message.replace(errorMessage, '');
            System.assertEquals(message.split(',').size(), ADM_Work.STATUS_VALUES_OPEN.size());                     
        }
        
        //Test #3 Make sure we get an error when set to a not open status with p4 status open
        w.Status__c = 'New';
        try {        
            update w;
            System.assertEquals(true, true);
        } catch(System.DmlException e) {
            message = errorutils.getErrorMessage(e);
            System.assertNotEquals(true, message.contains(ADM_WorkPerforceStatus.P4_WORK_NOT_OPEN_ERROR));                      
        }        
    }
     
 /*  
      @testcase a1DB00000000adl
      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-734511
      @userstory a0790000000DHdC
      @expectedResults When a bug or user story with Source Control Status = open, open once changes to fixed or qa in progress, the Source Control Status automatically changes to none
      @author Alexis Williams
*/
    
    static testMethod void removeP4StatusBySettingStatusFixed(){   
        Test.startTest();          
        ADM_Work__c w = ADM_Work.createTestBug();
        ADM_Build__c b = ADM_Build.createTestBuild();
        ADM_ErrorUtils errorutils = new ADM_ErrorUtils();
        w.Perforce_Status__c = 'Open';
        w.QA_Engineer__c = Userinfo.getUserId();
        w.Scheduled_Build__c = b.Id;
        update w;
        w.Status__c = 'Fixed';
        update w;
        Test.stopTest();
        w = ADM_Work.get('id', w.id, 'id', 'DESC');
        System.assertEquals(null,w.Perforce_Status__c);
    }

/*    
      @testcase a1DB00000000adm
      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-734511
      @userstory a0790000000DHdC
      @expectedResults When a bug or user story with Source Control Status = open, open once changes to closed, the Source Control Status automatically changes to none
      @author Alexis Williams
*/   

    static testMethod void removeP4StatusBySettingStatusClosed(){
        //Get the record types
        Test.startTest();
        ADM_Build__c build = ADM_Build.createTestBuild();
        ADM_Work__c w = ADM_Work.createTestWork();
        w.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN_ONCE;
        w.QA_Engineer__c = Userinfo.getUserId();
        w.Scheduled_Build__c = build.Id;
        update w;        
        w.Status__c = 'Closed';
        update w;
        Test.stopTest();
        w = ADM_Work.get('id', w.id, 'id', 'DESC');
        System.assertEquals(null,w.Perforce_Status__c);
    }
    
    static testMethod void testSetWorkValuesFromUrl() {
        ADM_Work__c testWork = new ADM_Work__c();
        
        //create the secondary reference objects
        ADM_Impact__c impact = new ADM_Impact__c(Name='End of Days');
        insert impact;
        
        ADM_Type__c bugType = new ADM_Type__c(Name='Bug');
        insert bugType;
        
        ADM_Impact_Type__c impactType = new ADM_Impact_Type__c(Impact__c=impact.Id, Type__c=bugType.Id);
        insert impactType;
        
        ADM_Frequency__c frequency = new ADM_Frequency__c(Name='Alwayss');
        insert frequency;
        
        ADM_Build__c build = ADM_Build.createTestBuild();
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();

        RecordType recordType = ADM_RecordType.getByName('Bug', 'ADM_Work__c');
        
        Map<String, String> parameters = System.currentPageReference().getParameters();
        parameters.put('Subject__c', 'Test Subject');
        parameters.put('Type__c', 'Bug');
        parameters.put('Priority__c', 'P0');
        parameters.put('Parent_ID__c', testWork.Id);
        parameters.put('Child_ID__c', testWork.Id);
        parameters.put('Impact__c', 'End of Days');
        parameters.put('Attributes__c', 'Test');
        parameters.put('Minor_Func_Area__c', 'MFA Test');
        parameters.put('Related_URL__c', 'http://www.salesforce.com');
        parameters.put('Description__c', 'test description');
        parameters.put('ftest__c', 'FTest.test');
        parameters.put('Regressed__c', 'true');
        parameters.put('Security__c', 'true');
        parameters.put('Customer__c', 'Customer');
        parameters.put('Status__c', 'In Progress');
        parameters.put('Priority_Rank__c', '10');
        parameters.put('Scheduled_Build__c', build.Name);
        parameters.put('Found_In_Build__c', build.Name);
        parameters.put('Story_Points__c', '8');
        parameters.put('Sprint__c', sprint.Id);
        parameters.put('Frequency__c', 'Alwayss');
        parameters.put('RecordTypeLogicalName', recordType.Name);
        
        Test.startTest();
        testWork = ADM_Work.setWorkValuesFromUrl(testWork);
        Test.stopTest();
        
        System.assertEquals('Test Subject', testWork.Subject__c, 'Expected the Subject__C field to be set by the URL parameter');
        System.assertEquals('Bug', testWork.Type__c, 'Expected the Type__c field to be set by the URL parameter');
        System.assertEquals('P0', testWork.Priority__c, 'Expected the Priority__c field to be set by the URL parameter');
        System.assertEquals(testWork.Id, testWork.Parent_ID__c, 'Expected the Parent_ID__c field to be set by the URL parameter');
        System.assertEquals(testWork.Id, testWork.Child_ID__c, 'Expected the Child_ID__c field to be set by the URL parameter');
        System.assertEquals(impact.Id, testWork.Impact__c, 'Expected the Impact__c field to be set by the URL parameter');
        System.assertEquals('Test', testWork.Attributes__c, 'Expected the Attributes__c field to be set by the URL parameter');
        System.assertEquals('MFA Test', testWork.Minor_Func_Area__c, 'Expected the Minor_Func_Area__c field to be set by the URL parameter');
        System.assertEquals('http://www.salesforce.com', testWork.Related_URL__c, 'Expected the Related_URL__c field to be set by the URL parameter');
        System.assertEquals('test description', testWork.Description__c, 'Expected the Description__c field to be set by the URL parameter');
        System.assertEquals('FTest.test', testWork.ftest__c, 'Expected the ftest__c field to be set by the URL parameter');
        System.assertEquals(true, testWork.Regressed__c, 'Expected the Regressed__c field to be set by the URL parameter');
        System.assertEquals(true, testWork.Security__c, 'Expected the Security__c field to be set by the URL parameter');
        System.assertEquals('Customer', testWork.Customer__c, 'Expected the Customer__c field to be set by the URL parameter');
        System.assertEquals('In Progress', testWork.Status__c, 'Expected the Status__c field to be set by the URL parameter');
        System.assertEquals(10, testWork.Priority_Rank__c, 'Expected the Priority_Rank__c field to be set by the URL parameter');
        System.assertEquals(build.Name, testWork.Scheduled_Build_Copy__c, 'Expected the Scheduled_Build_Copy__c field to be set by the URL parameter Scheduled_Build__c');
        System.assertEquals(build.Name, testWork.Found_In_Build_Copy__c, 'Expected the Found_In_Build_Copy__c field to be set by the URL parameter Found_In_Build__c');
        System.assertEquals(build.Id, testWork.Scheduled_Build__c, 'Expected the Scheduled_Build__c field to be set by the URL parameter Scheduled_Build__c');
        System.assertEquals(build.Id, testWork.Found_In_Build__c, 'Expected the Found_In_Build__c field to be set by the URL parameter Found_In_Build__c');
        System.assertEquals(8, testWork.Story_Points__c, 'Expected the Story_Points__c field to be set by the URL parameter');
        System.assertEquals(sprint.Id, testWork.Sprint__c, 'Expected the Sprint__c field to be set by the URL parameter');
        System.assertEquals(frequency.Id, testWork.Frequency__c, 'Expected the Frequency__c field to be set by the URL parameter');
        System.assertEquals(recordType.Id, testWork.RecordTypeId, 'Expected the RecordTypeId field to be set by the RecordTypeLogicalName URL parameter');
        
    } 
    
    static testMethod void testSpecialCharactersInParameters() {
        ADM_Work__c testWork = new ADM_Work__c();
        
                
        Map<String, String> parameters = System.currentPageReference().getParameters();
        parameters.put('Subject__c', 'Subject&Test#pound');
        parameters.put('Description__c', 'these_Values?&are>allowed</inthedescription;\'');
       
        
        Test.startTest();
        testWork = ADM_Work.setWorkValuesFromUrl(testWork);
        Test.stopTest();
        
        System.assertEquals('Subject&Test#pound', testWork.Subject__c, 'Expected the Subject__C field to be set by the URL parameter');
        System.assertEquals('these_Values?&are>allowed</inthedescription;\'', testWork.Description__c, 'Expected the Description__c field to be set by the URL parameter');
        
    }

    static testMethod void testDetailsAndStepsToReproduceIsCopiedToDetailsOnBugToStoryRecordTypeChange() {

        String test_text_with_tags = '<i>Test value for scrubbing</i><th style="width:16%;" class="bsChrome" title="Chrome"></th>';
        String test_text_without_tags = 'Test value for scrubbing';
        ADM_Work__c bug = ADM_Work.createTestBug();
        bug.Details_and_Steps_to_Reproduce__c = test_text_with_tags;
        upsert bug;
        
        PageReference pageReference = new PageReference( gusNameSpace + ADM_Work.USER_STORY_EDIT_PAGE );
        pageReference.getParameters().put('retURL', ADM_Work.BUG_DETAIL_PAGE);
        pageReference.getParameters().put('RecordType', ADM_RecordType.getByName('User Story' , 'ADM_Work__c').Id);
        pageReference.getParameters().put('RecordTypeLogicalName', 'User Story');
    
        Test.setCurrentPage(pageReference);
        Test.startTest();
        ADM_Work__c user_story = ADM_Work.setWorkValuesFromUrl(bug);
        Test.stopTest();
        
        System.assertEquals( test_text_without_tags, user_story.Details__c );
        // The original text is left in place also
        System.assertEquals( test_text_with_tags, user_story.Details_and_Steps_to_Reproduce__c );
        
    }

    static testMethod void testDetailsIsCopiedToDetailsAndStepsToReproduceOnUserStoryToBugRecordTypeChange() {

        String test_text = 'Test value for scrubbing';
        ADM_Work__c user_story = ADM_Work.createTestWork();
        user_story.Details__c = test_text;
        upsert user_story;
        
        PageReference pageReference = new PageReference( gusNameSpace + ADM_Work.BUG_EDIT_PAGE );
        pageReference.getParameters().put('retURL', ADM_Work.USER_STORY_DETAIL_PAGE);
        pageReference.getParameters().put('RecordType', ADM_RecordType.getByName('Bug' , 'ADM_Work__c').Id);
        pageReference.getParameters().put('RecordTypeLogicalName', 'Bug');
    
        Test.setCurrentPage(pageReference);
        Test.startTest();
        ADM_Work__c bug = ADM_Work.setWorkValuesFromUrl(user_story);
        Test.stopTest();
        
        System.assertEquals( test_text, bug.Details_and_Steps_to_Reproduce__c );
        // The original text is left in place also
        System.assertEquals( test_text, bug.Details__c );
        
    }

    static testMethod void testConvertBugToUserStoryToBug() {
        
        // 1. Create a standard bug        
        String test_text = 'Test text';
        String test_text_revised = 'Test text revised';
        ADM_Work__c bug = ADM_Work.createTestBug();
        bug.Details_and_Steps_to_Reproduce__c = test_text;
        upsert bug;

        // 2. Convert bug to a user story
        PageReference pageReference_user_story = new PageReference( gusNameSpace + ADM_Work.USER_STORY_EDIT_PAGE );
        pageReference_user_story.getParameters().put('retURL', ADM_Work.BUG_DETAIL_PAGE);
        pageReference_user_story.getParameters().put('RecordType', ADM_RecordType.getByName('User Story' , 'ADM_Work__c').Id);
        pageReference_user_story.getParameters().put('RecordTypeLogicalName', 'User Story');
    
        Test.setCurrentPage(pageReference_user_story);

        ADM_Work__c user_story = ADM_Work.setWorkValuesFromUrl(bug);

        System.assertEquals( test_text, user_story.Details__c );
        System.assertEquals( ADM_RecordType.getByName('User Story','ADM_Work__c').Id, user_story.RecordTypeId );
        System.assertEquals( 'User Story', user_story.Type__c );

        // 3. After conversion, update the details field
        user_story.Details__c = test_text_revised;
        upsert user_story;

        // 4. Convert back to a Bug
        PageReference pageReference_bug = new PageReference( gusNameSpace + ADM_Work.BUG_EDIT_PAGE );
        pageReference_bug.getParameters().put('retURL', ADM_Work.USER_STORY_DETAIL_PAGE);
        pageReference_bug.getParameters().put('RecordType', ADM_RecordType.getByName('Bug' , 'ADM_Work__c').Id);
        pageReference_bug.getParameters().put('RecordTypeLogicalName', 'Bug');

        Test.setCurrentPage(pageReference_bug);
    
        bug = ADM_Work.setWorkValuesFromUrl(user_story);

        // The Details should remain the same from step 4
        System.assertEquals( test_text_revised, bug.Details__c );
        // The Steps to Reproduce should be the original data from step 1
        System.assertEquals( test_text, bug.Details_and_Steps_to_Reproduce__c );
        System.assertEquals( ADM_RecordType.getByName('Bug','ADM_Work__c').Id, bug.RecordTypeId );
        System.assertEquals( 'Bug', bug.Type__c );

    }

    static testMethod void testAuraCreateWork() {
        ADM_ConstantsSingleton.getInstance().setUserLightningExperiencePreferred(true);
        String bugUrl = ADM_Work.getWorkCreateEditPage(ADM_Work.RECORD_TYPE_NAME_BUG);
        String usUrl = ADM_Work.getWorkCreateEditPage(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        String investigationUrl = ADM_Work.getWorkCreateEditPage(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);

        String bugRTQS = '?RecordType=' + ADM_RecordType.getByName(ADM_Work.RECORD_TYPE_NAME_BUG, 'ADM_Work__c').Id;
        String usRTQS = '?RecordType=' + ADM_RecordType.getByName(ADM_Work.RECORD_TYPE_NAME_USERSTORY, 'ADM_Work__c').Id;
        String investigationRTQS = '?RecordType=' + ADM_RecordType.getByName(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, 'ADM_Work__c').Id;

        System.assertEquals(Page.ADM_BugEditSds.getUrl() + bugRTQS, bugUrl);
        System.assertEquals(Page.ADM_UserStoryEditSds.getUrl() + usRTQS, usUrl);
        System.assertEquals(Page.ADM_InvestigationEditSds.getUrl() + investigationRTQS, investigationUrl);
    }
}