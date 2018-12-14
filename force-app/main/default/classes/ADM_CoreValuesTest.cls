@isTest
private class ADM_CoreValuesTest
{
	 /*
      @testcaseID a1DB00000000q8Q
      @hierarchy GUS.ScrumforcetoGUS.Work Page.User Story.Create Page
      @userstory a0790000000DRvq
      @expectedResults: The Emailed user story contains the following fields: Link, type, subject, Product Area, Major Func Area, Priority, Status, Assignee, QA Engineer, Scrum Team and comments
      @author jhatton
    */
    static testMethod void testGetCoreValuesForUserStory(){
        User u = ADM_WorkUser.createTestUser();
        
        ADM_Work__c w = ADM_Work.createTestWork('User Story');
        w.Assignee__c = u.id;
        w.QA_Engineer__c = u.id;
        w.Details__c = 'This is a test user story';
        update w;
        w = ADM_Work.getById(w.Id);
        
        //get the maps for use with the getCoreValues function
        Map<Id, RecordType> workRecordTypesById = new Map<Id, RecordType>(ADM_RecordType.getAll());
        Map<Id, User> users = new Map<Id, User>{u.Id => u};
        Test.startTest();
        
        Map<String, String> coreValues = ADM_CoreValues.getCoreValues(w, users, workRecordTypesById);
        Test.stopTest();
        
        //verify the core has all of the values
        for(String key : ADM_CoreValues.getKeys('User Story', false)) {
            System.assert(coreValues.containsKey(key), 'Expected core values to contain key ' + key);
        }
        
        //verify the field values in core
        System.assertEquals(workRecordTypesById.get(w.RecordTypeId).Name, coreValues.get( 'Type' ), 'Type in core values map should match the name of the Record Type associated to the work record');
        System.assertEquals(w.Subject__c, coreValues.get( 'Subject' ), 'Subject in core values map should match the subject of the work record');
        System.assertEquals(w.Status__c, coreValues.get( 'Status' ), 'Status in core values map should match the subject of the work record');
        System.assertEquals(u.Name, coreValues.get('Assignee'), 'Assignee in core values map should match the name of Assignee associated to the work record'); 
        System.assertEquals(u.Name, coreValues.get('QA Engineer'), 'QA Engineer in core values map should match the name of the QA Engineer associated to the work record');
        System.assertEquals(w.Details__c, coreValues.get('Description'), 'Description didn\'t match');//https://gus.my.salesforce.com/apex/adm_userstorydetail?id=a07B0000000dypR&sfdc.override=1
    }
    
    /*
      @testcaseID a1DB00000000q8F
      @hierarchy GUS.BugforceToGUS.Work Page.BugsCreatedInGus.Edit and New page
      @userstory a0790000000DRvq
      @expectedResults: User receives an email from the bug just created or edited with the following fields: Link, Type, Subject, Product Area, Major Func Area, Priority, Status, Assignee, QA Engineer and Scrum Team. Also Comments are added at the bottom of the email
      @author alexis.williams
    */
    static testMethod void testGetCoreValuesForBug(){
        User u = ADM_WorkUser.createTestUser();
        
        ADM_Work__c w = ADM_Work.createTestWork('Bug');
        w.Details_and_Steps_to_Reproduce__c = 'test details';
        w.Assignee__c = u.id;
        w.QA_Engineer__c = u.id;
        update w;
        w = ADM_Work.getById(w.Id);
        
        //get the maps for use with the getCoreValues function
        Map<Id, RecordType> workRecordTypesById = new Map<Id, RecordType>(ADM_RecordType.getAll());
        Map<Id, User> users = new Map<Id, User>{u.Id => u}; 

        Map< String, String > coreValues = ADM_CoreValues.getCoreValues(true, w, users, workRecordTypesById);
        
        //verify the core has all of the values
        for(String key : ADM_CoreValues.getKeys('Bug', true)) {
            System.assert(coreValues.containsKey(key), 'Expected core values to contain key ' + key);
        }
        
        //verify the field values in core
        System.assertEquals('Bug', coreValues.get('Type'), 'Type in core values map should match the name of the Record Type associated to the work record');
        System.assertEquals(w.Subject__c, coreValues.get('Subject'), 'Subject in core values map should match the subject of the work record');
        System.assertEquals(u.Name, coreValues.get('Assignee'), 'Assignee in core values map should match the name of Assignee associated to the work record'); 
        System.assertEquals(u.Name, coreValues.get('QA Engineer'), 'QA Engineer in core values map should match the name of the QA Engineer associated to the work record');
        System.assertEquals(w.Details_and_Steps_to_Reproduce__c, coreValues.get( 'Details and Steps to Reproduce' ) );
    }
    
    /*
      @testcaseID a1DB00000000q8P
      @hierarchy GUS.ScrumforceToGUS.Investigation Process.New Investigation page
      @userstory a0790000000DRvq
      @expectedResults: The following fields get emailed on investigation creation: Link, Type, Subject, Product Area, Major Func Area, Status, Assignee, QA Engineer, Scrum Team, Severity Level, Details and Steps to Reproduce and comments
      @author alexis.williams
    */
    static testMethod void testGetCoreValuesForInvestigation(){
        User u = ADM_WorkUser.createTestUser();
        ADM_Work__c w = ADM_Work.createTestWork('Investigation');
        w.Assignee__c = u.id;
        w.QA_Engineer__c = u.id;

        //get the maps for use with the getCoreValues function
        Map<Id, RecordType> workRecordTypesById = new Map<Id, RecordType>(ADM_RecordType.getAll());
        Map<Id, User> users = new Map<Id, User>{u.Id => u}; 

        Map< String, String > coreValues = ADM_CoreValues.getCoreValues(w, users, workRecordTypesById);
        
        //verify the core has all of the values
        for(String key : ADM_CoreValues.getKeys('Investigation', false)) {
            System.assert(coreValues.containsKey(key), 'Expected core values to contain key ' + key);
        }
        
        //verify the field values in core
        System.assertEquals('Investigation', coreValues.get('Type'), 'Type in core values map should match the name of the Record Type associated to the work record');
        System.assertEquals(w.Subject__c, coreValues.get('Subject'), 'Subject in core values map should match the subject of the work record');
        System.assertEquals(u.Name, coreValues.get('Assignee'), 'Assignee in core values map should match the name of Assignee associated to the work record'); 
        System.assertEquals(u.Name, coreValues.get('QA Engineer'), 'QA Engineer in core values map should match the name of the QA Engineer associated to the work record');
    }
    
    /*
      @testcaseID a1DB00000000q8Z
      @hierarchy GUS.ScrumforcetoGUS.Work Page.ToDo.Create Page
      @userstory a0790000000DRvq
      @expectedResults: The following fields get emailed: link, type, subject, scheduled build, priority, status, assignee, scrum team and comments
      @author alexis.williams
    */
    static testMethod void testGetCoreValuesForToDo (){
        User u = ADM_WorkUser.createTestUser();
        ADM_Work__c w = ADM_Work.createTestWork('ToDo');
        w.Assignee__c = u.id;
        w.QA_Engineer__c = u.id;
        
        //get the maps for use with the getCoreValues function
        Map<Id, RecordType> workRecordTypesById = new Map<Id, RecordType>(ADM_RecordType.getAll());
        Map<Id, User> users = new Map<Id, User>{u.Id => u};
        
        Map< String, String > coreValues = ADM_CoreValues.getCoreValues(w, users, workRecordTypesById);
        
        //verify the core has all of the values
        for(String key : ADM_CoreValues.getKeys('ToDo', false)) {
            System.assert(coreValues.containsKey(key), 'Expected core values to contain key ' + key);
        }
        
        //verify the field values in core
        System.assertEquals('ToDo', coreValues.get('Type'), 'Type in core values map should match the name of the Record Type associated to the work record');
        System.assertEquals(w.Subject__c, coreValues.get('Subject'), 'Subject in core values map should match the subject of the work record');
        System.assertEquals(u.Name, coreValues.get('Assignee'), 'Assignee in core values map should match the name of Assignee associated to the work record'); 
        
        //verify that fields are not in the list of core values
        System.assertEquals(false, coreValues.containsKey('QA Engineer'), 'Expected core values to not contain the QA Engineer');
    }
}