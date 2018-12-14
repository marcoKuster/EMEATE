@isTest
private class ADM_WorkControllerExtensionTest {
    private static String recordTypeId_UserStory = ADM_RecordType.getId(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
    private static String recordTypeId_Bug = ADM_RecordType.getId(ADM_Work.BUG_RECORD_TYPE_NAME);
    private static String recordTypeId_Todo = ADM_RecordType.getId(ADM_Work.RECORD_TYPE_NAME_TODO);

  /**
    *@testcaseID a1DB00000000gk4
    *@hierarchy GUS.BugforceToGUS.DefectPrioritizationProcess.URL population.Get Record Type
    *@userstory a0790000000D26O
    *@expectedResults  Once the user presses enter on the URL, a soft error occurs warning the user that the record type used is invalid
*/
    static testMethod void testGetRecordTypeIdFromUrlWithJunkData() { 
        ADM_Work__c testWork = ADM_Work.createTestWork();
        System.currentPageReference().getParameters().put('recordTypeLogicalName', 'junk1234567890');
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        System.assert(work.RecordTypeId == recordTypeId_Bug,'The record type id, ' + work.RecordTypeId + ', was not == ' + recordTypeId_Bug);
    }
  /**
    *@testcaseID a1DB00000000gk9
    *@hierarchy GUS.BugforceToGUS.DefectPrioritizationProcess.URL population.Get Record Type
    *@userstory a0790000000D26O
    *@expectedResults  Once the user presses enter on the URL, the user should see the edit page of a user story filled in with all fields indicated in the URL
*/
    static testMethod void testGetRecordTypeIdFromUrlWithGoodDataUserStory() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        ADM_Work__c testWork = ADM_Work.createTestWork();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        System.assert(work.RecordTypeId == recordTypeId_UserStory,'The record type id, ' + work.RecordTypeId + ', was not == ' + recordTypeId_UserStory);
    }
  /**
    *@testcaseID a1DB00000000gki
    *@hierarchy GUS.BugforceToGUS.DefectPrioritizationProcess.URL population.Get Record Type
    *@userstory a0790000000D26O
    *@expectedResults  Once the user presses enter on the URL, the user should see the edit page of a bug filled in with all fields indicated in the URL
*/
    static testMethod void testGetRecordTypeIdFromUrlWithGoodDataBug() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
        ADM_Work__c testWork = ADM_Work.createTestWork();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        System.assert(work.RecordTypeId == recordTypeId_Bug,'The record type id, ' + work.RecordTypeId + ', was not == ' + recordTypeId_Bug);
    }
  /**
    *@testcaseID a1DB00000000gkn
    *@hierarchy GUS.BugforceToGUS.DefectPrioritizationProcess.URL population.Get Record Type
    *@userstory a0790000000D26O
    *@expectedResults  Once the user presses enter on the URL, the user should see the edit page of a todo filled in with all fields indicated in the URL
*/
    static testMethod void testGetRecordTypeIdFromUrlWithGoodDataTodo() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_TODO);
        ADM_Work__c testWork = ADM_Work.createTestWork();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        System.assert(work.RecordTypeId == recordTypeId_Todo,'The record type id, ' + work.RecordTypeId + ', was not == ' + recordTypeId_Todo);
    }

  /**
    *@testcaseID a1DB00000000Pb4
    *@hierarchy GUS.BugforceToGUS.DefectPrioritizationProcess.Work Page.New Page
    *@userstory a0790000000DB87
    *@expectedResults Ensure that user is able to select from Impact and Frequency when creating a new bug. The Impact field lists the following choices: Crash, Data Loss and Corruption/ Performance/ Security/ Embarassing/ 			Malfunctioning/ Poor Usability/ Incorrect Doc- UI Test/ Has Workaround/ Fit and Finish UI/ Cosmetic Doc-UI Test and the Frequency field lists the following choices:Always, Often, Sometimes, Rarely
*/
    static testMethod void testSetImpactAndFrequencyNoErrors() {
        ADM_Work__c testWork = ADM_Work.createTestWork();
        
        ADM_Type__c testType = new ADM_Type__c();
        testType.Name = 'Bug';
        insert testType;

        ADM_Impact__c testImpact = new ADM_Impact__c();
        testImpact.Name = 'Eternal';
        insert testImpact;

        ADM_Frequency__c testFrequency = new ADM_Frequency__c();
        testFrequency.Name = 'There can be only one';
        insert testFrequency;

        ADM_Impact_Type__c testImpactType = new ADM_Impact_Type__c();
        testImpactType.Type__c = testType.Id;
        testImpactType.Impact__c = testImpact.Id;
        insert testImpactType;
        System.currentPageReference().getParameters().put('Type__c','Bug');
        System.currentPageReference().getParameters().put('Impact__c','Eternal');
        System.currentPageReference().getParameters().put('Frequency__c',testFrequency.Name);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        System.assert(work.Impact__c == testImpact.Id,'work impact->'+work.Impact__c + ' test impact object->' + testImpact.Id + ' work type->' + work.Type__c);
        System.assert(work.Frequency__c == testFrequency.Id,'work frequency->' + work.Frequency__c + ' test frequency object->' + testFrequency.Id);
    }
  

  /**
    *@testcaseID a1DB00000002NTz
    *@hierarchy GUS.BugforceToGUS.DefectPrioritizationProcess.Work Page.New Page
    *@userstory a0790000000DB87
    *@expectedResults An error occurs that a reason for override needs to be entered
*/
    static testMethod void testSetImpactFrequencyWithErrors() {
        String junk = 'junk that should never be in there';
        Map<String,String> messages = new Map<String,String>{'Impact'=>'An impact value was not found for the value entered over the URL','Frequency'=>'A frequency value was not found for the value entered over the URL'};
        Set<String> keysToRemove = new Set<String>();
        System.currentPageReference().getParameters().put('Type__c','Bug');
        System.currentPageReference().getParameters().put('Impact__c', junk);
        System.currentPageReference().getParameters().put('Frequency__c', junk);
        ADM_Work__c testWork = ADM_Work.createTestWork();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        Boolean foundFrequencyError = false;
        Boolean foundImpactError = false;

        System.assertNotEquals(junk,String.valueOf(work.Impact__c));
        System.assertNotEquals(junk,String.valueOf(work.Frequency__c));

        for(String key : messages.keySet()) {
            
            String message = messages.get(key);
			key = key.toLowerCase();
            if(key.contains('frequency')) {
                foundFrequencyError = true;
            }

            if(key.contains('frequency')) {
                foundImpactError = true;
            }

            if(message != null) {
                if(message.contains('frequency')) {
                    foundFrequencyError = true;
                } else if(message.contains('impact')) {
                    foundImpactError = true;
                }
            }

            for(String errorMessage : getErrorMessagesFromPage()) {
                if(errorMessage.contains(message)) {
                    keysToRemove.add(key);
                }
            }
        }

        if(!keysToRemove.isEmpty()) {
            for(String keyToRemove :keysToRemove) {
                messages.remove(keyToRemove);
            }
        }

        System.assertEquals(false,messages.isEmpty());
        System.assertEquals(true,foundFrequencyError);
        System.assertEquals(true, foundImpactError);
    }
/**
    
    *@testcaseID a1DB00000000gks
    *@hierarchy GUS.ScrumforceToGUS.Work.Bug.New page
    *@userstory a01T00000035RnwIAE
    *@expectedResults Once the user presses enter on the URL, the user should see the edit page of a bug or user story filled in with all fields indicated in the URL
  */
    //we are going to test the following values '','','Scrum_Team__c','Sprint__c'
    static testMethod void testValuesOverTheUrlNoErrorExpected() {
        ADM_Sprint__c testSprint = ADM_Sprint.createTestSprint();
        System.currentPageReference().getParameters().put('Priority_Rank__c', '1');
        System.currentPageReference().getParameters().put('Story_Points__c', '1');
        System.currentPageReference().getParameters().put('Scrum_Team__c',testSprint.Scrum_Team__r.Name);
        System.currentPageReference().getParameters().put('Sprint__c',testSprint.Name);
        ADM_Work__c testWork = [select id, Name, RecordTypeId from ADM_Work__c where Sprint__c =:testSprint.id limit 1];
        
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        System.assert(work.Priority_Rank__c == 1,'Did not find a priority ranking matching 1 ->' + work.Priority_Rank__c);
        System.assert(work.Story_Points__c == 1,'Did not find a story point matching 1 ->' + work.Story_Points__c);
        System.assert(work.Scrum_Team__c == testSprint.Scrum_Team__r.Name,'Did not match up the scrum team properly with ->' + testSprint.Scrum_Team__r.Name + ' work->' + work.Scrum_Team__c);
        System.assert(work.Sprint__c == testSprint.Id,'Did not find matching sprint for URL specified value ->' + testSprint.Id + ' work->' + work.Sprint__c);
    }
/**
    
    *@testcaseID a1DB00000000gkx
    *@hierarchy GUS.ScrumforceToGUS.Work.Bug.New page
    *@userstory a01T00000035RnwIAE
    *@expectedResults Once the user presses enter on the URL, the user should see a soft error generated indicating a field is not written correctly
  */
    
    static testMethod void testValuesOverTheUrlErrorExpected() {
        System.currentPageReference().getParameters().put('Priority_Rank__c', '1');
        System.currentPageReference().getParameters().put('Story_Points__c', '1');
        System.currentPageReference().getParameters().put('Scrum_Team__c','asfdasdf as df as df as');
        System.currentPageReference().getParameters().put('Sprint__c','asdf  asdf asdf asdfas');
        ADM_Work__c testWork = ADM_Work.createTestWork();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        System.assertEquals(work.Priority_Rank__c,Decimal.valueOf('1'));
        System.assertEquals(work.Story_Points__c,Decimal.valueOf('1'));
        System.assertEquals(1, getErrorMessagesFromPage().size());
    }
/**
    Create a new bug with type = feature request using the URL
    *@testcaseID a0B20000006cTJ8EAM
    *@hierarchy GUS.ScrumforceToGUS.Work.Bug.New page
    *@userstory a01T00000035RnwIAE
    *@expectedResults Type feature request is no longer an option (no error displayed)
  */
    static testMethod void testVerifyFeatureRequestOverTheUrlRemoved() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.BUG_RECORD_TYPE_NAME);
        System.currentPageReference().getParameters().put('Type__c', 'Feature Request');
        ADM_Work__c testWork = ADM_Work.createTestWork();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        // we loop over all select options because there should be no instance of feature request. this means that even though we may set the type to feature request because of what was passed over the URL
        // we will never see this as a selected option because it's not there in the back end!
        for(Selectoption option : ext.getWorkTypes()) {
            System.assert(!option.getLabel().equalsIgnoreCase(ext.getWorkType()),'found the feature request somewhere in your environment!');
        }
    }
/**
    Create a new bug and ensure type =Feature Request is no longer present in the layout
    *@testcaseID a0B20000003x0bTEAQ
    *@hierarchy GUS.ScrumforceToGUS.Work.Bug.New page
    *@userstory a01T00000035RnwIAE
    *@expectedResults When creating a new bug, the type = feature request is no longer an option.
 */
    static testMethod void verifyFeatureRequestTypeDeleted() {
        ADM_Work__c testWork = ADM_Work.createTestWork();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);

        for(Selectoption option : ext.getWorkTypes()) {
            System.assert(!option.getLabel().equalsIgnoreCase('feature request'),'found the feature request somewhere in your environment!');
        }
    }
    
      /**
    *@testcaseID a1DB00000002NU4
    *@hierarchy GUS.BugforceToGUS.DefectPrioritizationProcess.URL population.Create new bug
    *@userstory a0790000000DB87
    *@expectedResults An error occurs: 'An invalid record type was entered. The default record type of Bug is being used as an alternative.'
*/
    static testMethod void validateErrorsOnInvalidRecordTypeId() {
        System.currentPageReference().getParameters().put('RecordType', '012T00000004MU');
        ADM_Work__c empty = new ADM_Work__c();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(empty);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);

        List<String> messages = getErrorMessagesFromPage();
        String stringException = 'System.StringException: Invalid id: 012T00000004MU';
        String bugDefault = 'An invalid record type was entered. The default record type of Bug is being used as an alternative.';
        String recordTypeNotFound = 'No RecordType found with the name 012T00000004MU';
        Set<String> exceptions = new Set<String>{stringException, bugDefault, recordTypeNotFound};
        System.assertNotEquals(null, messages);
        System.assertEquals(3, messages.size());
        for(String message : messages) {
            System.assertEquals(true, exceptions.contains(message));
        }
    }
    
    /**
    *@testcaseID a1DB00000000hLA
    *@hierarchy GUS.BugforceToGUS.Bugs in GUS.W-840147
    *@userstory a07B0000000E6MM
    *@expectedResults Sticky PA should not override the PA saved in template
    *@author: James Hatton
  */
    static testMethod void testProductAreaIsNotStickyOnCloneOrApplyTemplate() {
        System.currentPageReference().getParameters().put('Clone__c', '1');
        ADM_Work__c testWork = ADM_Work.createTestWork();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        System.assertEquals(testWork.Product_Area__c, work.Product_Area__c);
        
    }

      /**
    *@testcaseID a1DB00000000shH
    *@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Edit Page
    *@userstory a07B0000000Efv8
    *@expectedResults Comment help reads: When you click the Save button, your comment will be added to the Work record and included in an email to the names listed in the Email Notifications section
    *@author: Alexis Williams
*/

      /**
    *@testcaseID a1DB00000000shH
    *@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Detail Page
    *@userstory a07B0000000Efv8
    *@expectedResults Comment help reads: To add a Comment, use inline editing, or click the Edit button. When you click the Save button, your comment will be added to the Work record and in included in an email to the names listed in the Email Notifications section.
    *@author: Alexis Williams
*/
    static testMethod void validateHelpCommentText() {
        ADM_Work__c testBug = ADM_Work.createTestBug();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testBug);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        String text = 'When you click the Save button, your comment will be added to the Work record and included in an email to the names listed in the Email Notifications section.';
        
        System.assertEquals(text, ext.commentHelpText);     
    }
    
    	/*
	@testcaseID a1DB00000002NU9 
	@userstory a07B0000000Lhdg
	@Hierarchy GUS.ScrumforceToGUS.Product Tags.Work Page
	@Expected Results Product tag should show and assignees should load when creating the child user story
	*/
    /*
     * When creating a child work item, the product tag should only be used if 
     * the tag is valid.
     */
    static testMethod void verifyProductTagIsOnChildWhenValidRecordType() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Assignee_Assignment__c = ADM_WorkUser.createTestUser().Id;
        rule.Product_Owner__c = ADM_WorkUser.createTestUser().id;
        rule.Scrum_Team_Assignment__c = team.Id;
        insert rule;
        
        ADM_Product_Tag__c productTag = new ADM_Product_Tag__c();
        productTag.Name = 'tag' + Math.random();
        productTag.Active__c = true;
        productTag.Team__c = team.Id;
        insert productTag;
        
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Assignment_Rule__c = rule.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_USERSTORY;
        insert tagAssignment;
        
        //create a work item that uses the product tag, which will be the parent 
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_BUG);
        work.Product_Tag__c = productTag.Id;
        insert work;
        work = [select Name, Product_Tag__r.Name, Product_Tag__r.Team__r.Name, RecordTypeId, Subject__c from ADM_Work__c where Id = :work.Id];
        
        //when you click the create child button, it uses the URL parameters to 
        //pass the values to the edit page.
        System.currentPageReference().getParameters().put('Parent_ID__c', work.Name);
        System.currentPageReference().getParameters().put('Product_Tag__c', work.Product_Tag__r.Name);
        System.currentPageReference().getParameters().put('RecordType', recordTypeId_UserStory);
        System.currentPageReference().getParameters().put('Scrum_Team__c', work.Product_Tag__r.Team__r.Name);
        System.currentPageReference().getParameters().put('Subject__c', work.Subject__c);
        System.currentPageReference().getParameters().put('Type__c', ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());        
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        
        ADM_Work__c childWork = ext.getWork();
        System.assertEquals(productTag.Id, childWork.Product_Tag__c, 'Expected the product tag on the child to be the one specified on the URL because it is valid.'); 
	   
	      
    }
    
	/*
	@testcaseID  a1DB00000002NUE
	@userstory a07B0000000Lhdg
	@Hierarchy GUS.ScrumforceToGUS.Product Tags.Work Page
	@Expected Results Product tag should not show and assignees should not load when creating the child user story
	*/
    /*
     * When creating a child work item, the product tag should only be used if 
     * the tag is valid.
     */
    static testMethod void verifyProductTagIsNotOnChildWhenInvalidRecordType() {
    	//create a product tag that is not active
        ADM_Product_Tag__c productTag = new ADM_Product_Tag__c();
        productTag.Name = 'tag' + Math.random();
        productTag.Active__c = true;
        productTag.Team__c = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName().Id; 
        insert productTag;
        
        //create a work item that uses the invalid product tag, which will be the parent 
        ADM_Work__c work = ADM_Work.setupTestWork(ADM_Work.BUG_RECORD_TYPE_NAME);
        work.Product_Tag__c = productTag.Id;
        insert work;
        work = [select Name, Product_Tag__r.Name, Product_Tag__r.Team__r.Name, RecordTypeId, Subject__c from ADM_Work__c where Id = :work.Id];
        
        //when you click the create child button, it uses the URL parameters to 
        //pass the values to the edit page.
        System.currentPageReference().getParameters().put('Parent_ID__c', work.Name);
        System.currentPageReference().getParameters().put('Product_Tag__c', work.Product_Tag__r.Name);
        System.currentPageReference().getParameters().put('RecordType', recordTypeId_UserStory);
        System.currentPageReference().getParameters().put('Scrum_Team__c', work.Product_Tag__r.Team__r.Name);
        System.currentPageReference().getParameters().put('Subject__c', work.Subject__c);
        System.currentPageReference().getParameters().put('Type__c', ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());        
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        
        ADM_Work__c childWork = ext.getWork();
        System.assertEquals(null, childWork.Product_Tag__c, 'Expected the product tag on the child to be null because it is not valid for the User Story record type.');         
    }
    
	/*
	@testcaseID  a1DB00000000REl
	@userstory a07B0000000OaR9IAK
	@Hierarchy GUS.Work Page.Template.New page
	@Expected Results Detail, Subject, Assignments, Other Information and Notification sections show the same on Work Template page. The following new fields show on the template new page: Theme, Sprint 
	*/
    static testMethod void testSaveTemplateWithErrors() {
    	List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Template');
    	ADM_Work__c parentWork = works.get(0);
        ADM_Work__c testWork = works.get(1);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);

        ADM_Work__c myWork = ext.getWork();
        myWork.Template_Name__c = null;
        myWork.Template_Description__c = null;
        
        Pagereference pr = ext.saveAndView();

        System.assertEquals(2, getErrorMessagesFromPage().size());
    }
	/*
	@testcaseID  a1DB00000000REo
	@userstory a07B0000000OaR9IAK
	@Hierarchy GUS.Work Page.Template.Edit page
	@Expected Results Detail, Subject, Assignments, Other Information and Notification sections show the same on Work Template page. The following new fields show on the template edit page: Theme, Sprint
	*/
    
    static testMethod void testSaveErrorTemplateWithInvalidParent() {
        ADM_Work__c testWork = ADM_Work.createTestTemplate();
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);

        ADM_Work__c myWork = ext.getWork();
        myWork.Parent_Id__c = 'Invalid';
        
        Pagereference pr = ext.saveAndView();

        List<String> messages = getErrorMessagesFromPage();
        System.assert(messages.size() > 0, 'Expected save to fail when the parent ID is not valid.');
        
        Boolean found = false;
        for(String message : messages) {
        	if(message.containsIgnoreCase('invalid') && message.containsIgnoreCase('parent work ID')) {
        		found = true;
        	}
        }
        System.assert(found, 'Expected save to fail when the parent ID is not valid.');
    }
	/*
	@testcaseID  a1DB00000002fEp
	@userstory a07B0000000OaR9IAK
	@Hierarchy GUS.Work Page.Notifications.New Template
	@Expected Results testSaveErrorTemplateWhenParentIsSame
	*/
    
    static testMethod void testSaveErrorTemplateWhenParentIsSame() {
        ADM_Work__c testWork = ADM_Work.createTestTemplate();
        testWork = [select Id, Name, RecordTypeId from ADM_Work__c where Id = :testWork.Id];
        
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);

        ADM_Work__c myWork = ext.getWork();
        myWork.Parent_Id__c = testWork.Name;
        
        Pagereference pr = ext.saveAndView();

        List<String> messages = getErrorMessagesFromPage();
        System.assert(messages.size() > 0, 'Expected save to fail when the parent ID is the same as the work ID.');
        Boolean found = false;
        for(String message : messages) {
            if(message.containsIgnoreCase('related to itself') && message.containsIgnoreCase('parent work ID')) {
                found = true;
            }
        }
        System.assert(found, 'Expected save to fail when the parent ID is the same as the work ID: ' + getErrorMessagesFromPage());
    }
	/*
	@testcaseID  a1DB00000001Xwp
	@userstory a07B0000000OaR9IAK
	@Hierarchy GUS.Product Tags.Work Page
	@Expected Results product tag and team change. A comment is created about the product tag and team changing
	*/
    
    static testMethod void testProductTagRequiredMessage() {
    	ADM_Work__c testWork = ADM_Work.createTestBug();
    	
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(testWork);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ext.getWork().Product_Tag__c = null;
        ext.getWork().Scrum_Team__c = null;
        ext.setIsNewWork(false);
        String instructions = ext.getRequiredInputProductTagInstructions();
        
        System.assert(instructions.length() > 0, 'Expected to show the required product tag message because it is blank');
    }
    
    private static List<String> getErrorMessagesFromPage() {
    	List<String> messages = new List<String>();
    	for(ApexPages.Message message : ApexPages.getMessages()) {
    		messages.add(message.getSummary());
    	}
    	return messages;
    }
     /**
     * Test clone will set Status to 'New'
	testcaseID a1DB00000002tdC
	userstory a07B0000000VcF9
	hierarchy GUS.Work.Deep clone page
	expected results status is new after cloning or deep cloning
     */
    public testMethod static void testCloneSetStatusFieldToNew() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        work.Status__c = 'In Progress';
        update work;
        
        ADM_Work__c original = [select id, RecordTypeId, Status__c from ADM_Work__c where Id = :work.Id];
        
        System.assert('In Progress' == original.Status__c, 'Expeced In Progress status for original work record');
        
        //set the query parameters to 'clone'
    	System.currentPageReference().getParameters().put('clone', '1');
    	System.currentPageReference().getParameters().put('id', original.Id);
    	
        ApexPages.StandardController standardController = new ApexPages.StandardController(original);
        ADM_WorkControllerExtension extension = new ADM_WorkControllerExtension(standardController);
        
        ADM_Work__c clonedWork = extension.getWork();
       
        System.assert(clonedWork.Status__c == 'New', 'Expected New status for cloned Work record');
    }
}