public with sharing class ADM_WorkExtensionTests {
	
	/**
	 * Ensure that loading an existing work item works properly
	 */
    public testMethod static void testLoadExisting() {
    	ADM_Work__c work = ADM_Work.createTestWork();
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    	ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
    	
    	Test.startTest();
    	ADM_Work__c actualWork = ext.getSelectedWork();
    	String actualWorkAsJson = ext.getSelectedWorkAsJson();
    	Test.stopTest();
    	
    	System.assert(actualWork != null, 'Expected a work object to be returned because the work item was specified in the controller. Actual: null');
    	System.assertEquals(work.Id, actualWork.Id, 'Expected the ID returned to be the same as the work item specified in the controller');
    	System.assert(actualWorkAsJson != null, 'Expected getSelectedWorkAsJson to return the work item specified. Actual: null');
    	System.assert(actualWorkAsJson.indexOf(work.Id) > -1, 'Expected getSelectedWorkAsJson to return the work item specified. Actual: ' + actualWorkAsJson);
    }
    
    /**
     * Ensure that loading a new work form works properly with the RecordTypeLogicalName parameter
     */
    public testMethod static void testNewWithRecordTypeLogicalName() {
    	String recordTypeId = ADM_RecordType.getId('Bug');
    	System.currentPageReference().getParameters().put('RecordTypeLogicalName', 'Bug');
    	
    	ApexPages.StandardController stdController = new ApexPages.StandardController(new ADM_Work__c());
    	ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
    	
    	Test.startTest();
    	ADM_Work__c actualWork = ext.getSelectedWork();
    	Test.stopTest();
    	
    	System.assert(actualWork != null, 'Expected work to not be null since we are creating a new work item with default values. Actual: ' + actualWork);
    	System.assertEquals(recordTypeId, actualWork.RecordTypeId, 'Expected the record type of the work item to be Bug since it was passed as a parameter. Actual: ' + actualWork);
    	System.assertEquals('New', actualWork.Status__c, 'Expected the status of the work item to be New');
    	System.assertEquals('Bug', actualWork.Type__c, 'Expected the type of the work item to be Bug');
    }
    
    /**
     * Ensure that loading a new work form works properly with the RecordTypeName parameter
     */
    public testMethod static void testNewWithRecordTypeName() {
        String recordTypeId = ADM_RecordType.getId('Bug');
        System.currentPageReference().getParameters().put('RecordTypeName', 'Bug');
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(new ADM_Work__c());
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        ADM_Work__c actualWork = ext.getSelectedWork();
        Test.stopTest();
        
        System.assert(actualWork != null, 'Expected work to not be null since we are creating a new work item with default values. Actual: ' + actualWork);
        System.assertEquals(recordTypeId, actualWork.RecordTypeId, 'Expected the record type of the work item to be Bug since it was passed as a parameter. Actual: ' + actualWork);
        System.assertEquals('New', actualWork.Status__c, 'Expected the status of the work item to be New');
        System.assertEquals('Bug', actualWork.Type__c, 'Expected the type of the work item to be Bug');
    }
    
    /**
     * Ensure that loading a new work form works properly with the RecordType parameter
     */
    public testMethod static void testNewWithRecordType() {
        String recordTypeId = ADM_RecordType.getId('Bug');
        System.currentPageReference().getParameters().put('RecordType', recordTypeId);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(new ADM_Work__c());
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        ADM_Work__c actualWork = ext.getSelectedWork();
        Test.stopTest();
        
        System.assert(actualWork != null, 'Expected work to not be null since we are creating a new work item with default values. Actual: ' + actualWork);
        System.assertEquals(recordTypeId, actualWork.RecordTypeId, 'Expected the record type of the work item to be Bug since it was passed as a parameter. Actual: ' + actualWork);
        System.assertEquals('New', actualWork.Status__c, 'Expected the status of the work item to be New');
        System.assertEquals('Bug', actualWork.Type__c, 'Expected the type of the work item to be Bug');
    }
    
    /**
     * Ensure that getUsers and getUsersAsJson returns a non-null value when loading an existing work item
     */
    public testMethod static void testGetUsersOnLoadExisting() {
    	User testUser = ADM_WorkUser.createTestUser();
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        List<User> actualUsers = ext.getUsers();
        String actualUsersAsJson = ext.getUsersAsJson();
        Test.stopTest();
        
        System.assert(actualUsers != null, 'Expected a list of users to be returned');
        Boolean containsUser = false;
        for(User user : actualUsers) {
        	if(user.Id == testUser.Id) {
        		containsUser = true;
        		break;
        	}
        }
        System.assert(containsUser, 'Expected the list of users to contain the test user. Actual: ' + actualUsers);
        System.assert(actualUsersAsJson != null, 'Expected getUsersAsJson to return a value. Actual: null');
        System.assert(actualUsersAsJson.startsWith('['), 'Expected getUsersAsJson to return an array. Actual: ' + actualUsersAsJson);
        System.assert(actualUsersAsJson.endsWith(']'), 'Expected getUsersAsJson to return an array. Actual: ' + actualUsersAsJson);
        System.assert(actualUsersAsJson.indexOf(testUser.Id) > -1, 'Expected getUsersAsJson to contain the test user. Actual: ' + actualUsersAsJson);
    }
    
    /**
     * Test that checks that getProductTag and getProductTags as JSON return non-null values when loading an existing work item
     */
    public testMethod static void testGetProductTagOnLoadExisting() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        ADM_Product_Tag__c actualProductTag = ext.getCurrentProductTag();
        String actualProductTagsAsJson = ext.getProductTagsAsJson();
        Test.stopTest();
        
        System.assert(actualProductTag != null, 'Expected a product tag to be returned. Actual: null');
        System.assertEquals(work.Product_Tag__c, actualProductTag.Id, 'Expected the returned product tag to match that of the work. Actual: ' + actualProductTag);
        System.assert(actualProductTagsAsJson != null, 'Expected getUsersAsJson to return a value. Actual: null');
        System.assert(actualProductTagsAsJson.startsWith('['), 'Expected getProductTagsAsJson to return an array. Actual: ' + actualProductTagsAsJson);
        System.assert(actualProductTagsAsJson.endsWith(']'), 'Expected getProductTagsAsJson to return an array. Actual: ' + actualProductTagsAsJson);
        System.assert(actualProductTagsAsJson.indexOf(work.Product_Tag__c) > -1, 'Expected getProductTagsAsJson to contain the product tag. Actual: ' + actualProductTagsAsJson);
    }
    
    /**
     * Ensure that the sprint is returned properly when loading an existing work item
     */
    public testMethod static void testGetSprintOnLoadExisting() {
    	ADM_Sprint__c testSprint = ADM_Sprint.createTestSprint();
        /*
         * Fixing bad test method...Work was already created as part of the testSprint creation 
         * So just query the work last created
         * As of version 24.0 no need to worry about organization data and tests run in isolation
         * https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_testing_data_access.htm
         * 
        */
        ADM_Work__c work = [Select id from ADM_Work__c order by createdDate desc limit 1];
        work.Sprint__c = testSprint.Id;

        Test.startTest();
            update work;
        Test.stopTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        ADM_Sprint__c sprint = ext.getSprint();
        String sprintsAsJson = ext.getSprintsAsJson();
        
        
        System.assert(sprint != null, 'Expected the sprint for the work item to be returned. Actual: null');
        System.assertEquals(testSprint.Id, sprint.Id, 'Expected the sprint from the work item to be the same as the test sprint.');
        System.assert(sprintsAsJson != null, 'Expected getSprintsAsJson to not be null. Actual: null');
        System.assert(sprintsAsJson.startsWith('['), 'Expected getSprintsAsJson to return an array. Actual: ' + sprintsAsJson);
        System.assert(sprintsAsJson.endsWith(']'), 'Expected getSprintsAsJson to return an array. Actual: ' + sprintsAsJson);
        System.assert(sprintsAsJson.indexOf(testSprint.Id) > -1, 'Expected getSprintsAsJson to contain the ID of the sprint. Actual:' + sprintsAsJson);
    }
    
    /**
     * Ensure that the comments are loaded properly when loading an existing work item.
     */
    public testMethod static void testGetCommentsOnLoadExisting() {
        ADM_Work__c work = ADM_Work.createTestWork();
        User testUser = ADM_WorkUser.createTestUser();
        ADM_Comment__c testComment = new ADM_Comment__c();
        testComment.Work__c = work.Id;
        testComment.Comment_Created_By__c = testUser.Id;
        testComment.Comment_Created_Date__c = Datetime.now();
        testComment.Body__c = 'test';
        insert testComment;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        List<ADM_Comment__c> comments = ext.getComments();
        String commentsAsJson = ext.getCommentsAsJson();
        Test.stopTest();
        
        System.assert(comments != null, 'Expected the comments for the work item to be returned. Actual: null');
        System.assert(!comments.isEmpty(), 'Expected the comments from the work item to be returned. Actual: ' + comments);
        Boolean containsComment = false;
        for(ADM_Comment__c comment : comments) {
        	if(comment.Id == testComment.Id) {
        		containsComment = true;
        		break;
        	}
        }
        System.assert(containsComment, 'Expected the list of comments to contain the test comment. Actual: ' + comments);
        
        System.assert(commentsAsJson != null, 'Expected getCommentsAsJson to not be null. Actual: null');
        System.assert(commentsAsJson.startsWith('['), 'Expected getCommentsAsJson to return an array. Actual: ' + commentsAsJson);
        System.assert(commentsAsJson.endsWith(']'), 'Expected getCommentsAsJson to return an array. Actual: ' + commentsAsJson);
        System.assert(commentsAsJson.indexOf(testComment.Id) > -1, 'Expected getCommentsAsJson to contain the ID of the test comment. Actual: ' + commentsAsJson);
    }
    
    /**
     * Ensure impacts are loaded properly when loading an existing work item.
     */
    public testMethod static void testGetImpacts() {
        String recordTypeId = ADM_RecordType.getId('Bug');
        
        //create the impact and associate it to bugs
    	ADM_Impact__c impact = new ADM_Impact__c();
    	impact.Name = 'Performance';
    	insert impact;
    	ADM_Type__c type = new ADM_Type__c();
    	type.Name = 'Bug';
    	insert type;
    	ADM_Impact_Type__c impactType = new ADM_Impact_Type__c();
    	impactType.Impact__c = impact.Id;
    	impactType.Type__c = type.Id;
    	insert impactType;
    	
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        String impactsAsJson = ext.getImpactsAsJson();
        Test.stopTest();
        
        System.assert(impactsAsJson != null, 'Expected getImpactsAsJson to not be null. Actual: null');
        System.assert(impactsAsJson.startsWith('['), 'Expected getImpactsAsJson to return an array. Actual: ' + impactsAsJson);
        System.assert(impactsAsJson.endsWith(']'), 'Expected getImpactsAsJson to return an array. Actual: ' + impactsAsJson);
        System.assert(impactsAsJson.indexOf(impact.Id) > -1, 'Expected getImpactsAsJson to contain the ID of the test impact. Actual: ' + impactsAsJson);
    }
    
    /**
     * Ensure frequencies are loaded properly when loading an existing work item.
     */
    public testMethod static void testGetFrequencies() {
        ADM_Frequency__c frequency = new ADM_Frequency__c();
        frequency.Name = 'Always';
        insert frequency;
        
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        String frequenciesAsJson = ext.getFrequenciesAsJson();
        Test.stopTest();
        
        System.assert(frequenciesAsJson != null, 'Expected getFrequenciesAsJson to not be null. Actual: null');
        System.assert(frequenciesAsJson.startsWith('['), 'Expected getFrequenciesAsJson to return an array. Actual: ' + frequenciesAsJson);
        System.assert(frequenciesAsJson.endsWith(']'), 'Expected getFrequenciesAsJson to return an array. Actual: ' + frequenciesAsJson);
        System.assert(frequenciesAsJson.indexOf(frequency.Id) > -1, 'Expected getFrequenciesAsJson to contain the ID of the test frequency. Actual: ' + frequenciesAsJson);
    }
    
    /**
     * Ensure teams are loaded properly
     */
    public testMethod static void testGetTeamsAsJson() {
    	ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
    	
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        String teamsAsJson = ext.getTeamsAsJson();
        Test.stopTest();
        
        System.assert(teamsAsJson != null, 'Expected getTeamsAsJson to not be null. Actual: null');
        System.assert(teamsAsJson.startsWith('['), 'Expected getTeamsAsJson to return an array. Actual: ' + teamsAsJson);
        System.assert(teamsAsJson.endsWith(']'), 'Expected getTeamsAsJson to return an array. Actual: ' + teamsAsJson);
        System.assert(teamsAsJson.indexOf(team.Id) > -1, 'Expected getTeamsAsJson to contain the test team. Actual: ' + teamsAsJson);
    }
    
    /**
     * Test that calculate priority returns the proper result
     */
    public testMethod static void testCalculatePriority() {
        ADM_Impact__c impact = new ADM_Impact__c();
        impact.Name = 'Performance';
        insert impact;
        
        ADM_Type__c type = new ADM_Type__c();
        type.Name = 'Bug';
        insert type;
        
        ADM_Impact_Type__c impactType = new ADM_Impact_Type__c();
        impactType.Impact__c = impact.Id;
        impactType.Type__c = type.Id;
        insert impactType;
    	
        ADM_Frequency__c frequency = new ADM_Frequency__c();
        frequency.Name = 'Always';
        insert frequency;
        
        ADM_Priority__c priority = new ADM_Priority__c();
        priority.Name = 'P0';
        insert priority;
    	
    	ADM_Priority_Mapping__c priorityMapping = new ADM_Priority_Mapping__c();
    	priorityMapping.Frequency__c = frequency.Id;
    	priorityMapping.Impact__c = impact.Id;
        priorityMapping.Priority__c = priority.Id;
        insert priorityMapping;
        
        ADM_Work__c work = ADM_Work.createTestBug();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkExtension ext = new ADM_WorkExtension(stdController);
        
        Test.startTest();
        String actualPriority = ADM_WorkExtension.calculatePriority(frequency.Id, impact.Id);
        Test.stopTest();
        
        System.assertEquals('P0', actualPriority, 'Expected calculate priority to return P0 because that is what is setup in the priority mapping');
    }
    
    /*
    	The WorkExtension has a seperate constructor to allow it to be consumed by pages that don't have a standard controller such as MDP Global Actions
    */
    public testMethod static void testNoArgConstructor() {
    	ADM_WorkExtension ext = new ADM_WorkExtension();
    	//verify a new work record has been created
    	System.assert(ext.getSelectedWork() != null);
    	//verify a sensible default has been used for the Status field
    	System.assertEquals('New', ext.getSelectedWork().Status__c);
    }
    /*
    	Test conveiniance method whose job it is to lookup the Bug record type id
    */
    public testMethod static void testInitRecordType() {
    	ADM_WorkExtension ext = new ADM_WorkExtension();
    	ext.initBugRecordType();
    	//retrieve bug record type ID for comparison to see if the controller grabbed the right value
    	RecordType bug = [ Select Id from RecordType Where Name =:'Bug' Limit 1 ]; 
    	System.assertEquals(bug.id, ext.getSelectedWork().RecordTypeId);
    	ext = new ADM_WorkExtension();
    	ext.initUserStoryRecordType();
    	//retrieve story record type ID for comparison to see if the controller grabbed the right value
    	RecordType story = [ Select Id from RecordType Where Name =:'User Story' Limit 1 ]; 
    	System.assertEquals(story.id, ext.getSelectedWork().RecordTypeId);
    }
    
    	
    
}