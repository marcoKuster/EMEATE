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
private class ADM_WorkControllerExtensionTestSaving {
    static ADM_Scrum_Team__c scrumteam {
    	get {
    		if(scrumteam == null) {
    			scrumteam = ADM_ScrumTeam.createTestScrumTeam('Lorem ipsum');
    		}
    		return scrumteam;
    	}
    	set;
    }
    
	/**
        testcase ID: a0B20000008eqIdEAI
        user story ID: a0A20000001wS5o
        Hierarchy: GUS.BugforceToGUS.Bugs in GUS.W-736638
        Expected Results: Expect no NPE
        author: Alexis Williams  
	*/  
    
    static testMethod void noNPESavingWithoutValidReturnUrl() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_TODO);
        System.currentPageReference().getParameters().put('retUrl', '');
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c el = ext.getWork();
        el.Priority__c = 'P1';
        el.Assignee__c = Userinfo.getUserId();
        el.Scrum_Team__c = scrumteam.Id;
        el.Subject__c = 'Lorem ipsum';
        Pagereference pr = ext.saveAndView();
        
        System.assert(!ApexPages.hasMessages(), 'Expected save to not have any messages: ' + getErrorMessagesFromPage());
        System.assertNotEquals(null,pr); 
        System.assertEquals('/' + ext.getWork().Id,pr.getUrl());
    }  
    
    /** 
		testcase ID: a0B20000008eqJ2EAI
		user story ID: a0A20000001wS5o
		Hierarchy: GUS.BugforceToGUS.Bugs in GUS.W-736638
		Expected Results: Expect no NPE
		Author: Alexis Williams  
    */
    
    static testMethod void verifyValueInUrlAfterSaveAndViewNewRecord() {
        System.currentPageReference().getParameters().put('recordTypeLogicalName', ADM_Work.RECORD_TYPE_NAME_TODO);
        System.currentPageReference().getParameters().put('retUrl', '/' + Userinfo.getUserId());
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c el = ext.getWork();
        el.Priority__c = 'P1';
        el.Assignee__c = Userinfo.getUserId();
        el.Scrum_Team__c = scrumteam.Id;
        el.Subject__c = 'Lorem ipsum';
        Pagereference pr = ext.saveAndView();
        
        
        System.assert(!ApexPages.hasMessages(), 'Expected save to not have any messages: ' + getErrorMessagesFromPage());
        System.assertNotEquals(null,pr);
        System.assertEquals('/' + ext.getWork().Id,pr.getUrl());
    }

	/**
		testcase ID: a0B20000008fmpbEAA
		user story ID: a0A20000001xRxj
		Hierarchy: GUS.BugforceToGUS.Bugs in GUS.W-763843
		Expected Results: When editing a work item in gus patch test, the page goes back to original screen 
	*/
    
    static testMethod void verifyValueInUrlAfterSaveAndViewEditRecord() {
        ADM_Work__c work = ADM_Work.createTestTodo();
        System.currentPageReference().getParameters().put('id', work.Id);
        System.currentPageReference().getParameters().put('retUrl', '/' + Userinfo.getUserId());
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c el = ext.getWork();
        el.Priority__c = 'P1';
        el.Assignee__c = Userinfo.getUserId();
        el.Scrum_Team__c = scrumteam.Id;
        el.Subject__c = 'Lorem ipsum';
        Pagereference pr = ext.saveAndView();
        
        System.assert(!ApexPages.hasMessages(), 'Expected save to not have any messages: ' + getErrorMessagesFromPage());
        System.assertNotEquals(null,pr);
        System.assertEquals('/' + Userinfo.getUserId(),pr.getUrl());
    }

	/**
		testcase ID: a0B20000008fmpvEAA
		user story ID: a0A20000001xRxj
		Hierarchy: GUS.BugforceToGUS.Bugs in GUS.W-763843
		Expected Results: After saving a cloned work item, ensure the user is taken back to the detail page of the cloned work
		Author: Alexis Williams
	*/
    
    static testMethod void verifyValueInUrlAfterSaveAndViewOfClone() {
    	ADM_Work__c work = ADM_Work.createTestTodo();
        System.currentPageReference().getParameters().put('id', work.Id);
        System.currentPageReference().getParameters().put('clone', '1');
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c el = ext.getWork();
        el.Priority__c = 'P1';
        el.Assignee__c = Userinfo.getUserId();
        el.Scrum_Team__c = scrumteam.Id;
        el.Subject__c = 'Lorem ipsum';
        Pagereference pr = ext.saveAndView();
        String Id = String.valueOf(ext.getWork().Id);
        
        System.assert(!ApexPages.hasMessages(), 'Expected save to not have any messages: ' + getErrorMessagesFromPage());
        System.assertNotEquals(null,pr);
        System.assertEquals('/' + Id,pr.getUrl());
    }

    
        
	/**
        testcase ID: a1DB00000000h08
        user story ID: a07B0000000E49r
        Hierarchy: GUS.ScrumforceToGUS.Work.User Story.New page
        Expected Results: User is able to save comments on Description which show on Edit and Detail screens
        author: Alexis Williams  
	*/  
    static testMethod void verifyDetailsAreSavedOnUserStory() {
        ADM_Work__c us = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        us.Priority__c = 'P1';
        us.Product_Area__c = String.valueOf(Math.random());
        us.Major_Func_Area__c = String.valueOf(Math.random());
        insert us;    
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(us);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        work.Details__c = 'test test';        
        ext.details.fieldLabel = 'test';
        ext.saveAndView();
        work = [select Details__c from ADM_Work__c where Id =: us.Id];
        System.assertEquals('test test', work.Details__c);
    }
    
    	/**
        testcase ID: a1DB00000000h0D
        user story ID: a07B0000000E49r
        Hierarchy: GUS.ScrumforceToGUS.Work.User Story.New page
        Expected Results: User is able to save user story and description does not show any text
        author: Alexis Williams  
	*/ 
    
    static testMethod void verifyDetailsAreNotSavedOnUserStory() {
        ADM_Work__c us = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        us.Priority__c = 'P1';
        us.Product_Area__c = String.valueOf(Math.random());
        us.Major_Func_Area__c = String.valueOf(Math.random());
        insert us;    
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(us);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        ADM_Work__c work = ext.getWork();
        work.Details__c = 'test test';        
        ext.details.fieldLabel = 'test test';
        ext.saveAndView();
        work = [select Details__c from ADM_Work__c where Id =: us.Id];
        System.assertEquals(null, work.Details__c);
    }
    
 	/**
        testcase ID: a1DB00000000h31
        user story ID: a0790000000D34iAAC
        Hierarchy: GUS.BugforceToGUS.Bugs in GUS.W-684991
        Expected Results: No URL should show on work detail page if no URLs have been added to the related URL field
        author: Alexis Williams  
	*/  
    
    static testMethod void validateUnpopulatedRelateUrl() {    
        ADM_Work__c us = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        us.Priority__c = 'P1';
        us.Product_Area__c = String.valueOf(Math.random());
        us.Major_Func_Area__c = String.valueOf(Math.random());
        insert us;    
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(us);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        String relatedUrl = ext.getRelatedUrl();
        System.assertEquals(0, relatedUrl.length());
    }
    
  /**
        testcase ID: a1DB00000000h2w
        user story ID: a0790000000D34iAAC
        Hierarchy: GUS.BugforceToGUS.Bugs in GUS.W-684991
        Expected Results: URL should show exactly how it's added in the related URL with the proper link
        author: Alexis Williams  
	*/  
    static testMethod void validatePopulateRelateUrl() {   
        ADM_Work__c us = ADM_Work.setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        us.Priority__c = 'P1';
        us.Product_Area__c = String.valueOf(Math.random());
        us.Major_Func_Area__c = String.valueOf(Math.random());
        us.Related_URL__c = 'https://www.salesforce.com'; 
        insert us;    
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(us);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);   
        String relatedUrl = ext.getRelatedUrl().trim(); 
        System.assertEquals('<a target="_blank" href="https://www.salesforce.com">https://www.salesforce.com</a>', relatedUrl);
    }
    
      /**
        testcase ID: a1DB00000000jIHMAY
        user story ID: a07B0000000DnIZIA0
        Hierarchy: GUS.Scrumforcetogus.Work.Bug.New Page
        Expected Results: URL renders correctly and all fields, including type get copied from URL to GUS fields
        author: Alexis Williams  
	*/  
    static testMethod void testProperlyEscapingSubject() {
        String testSubject = 'Lorrem Ipsum -+=?.,|}{%%&**ab[c]|^tt_(9)-@#<>';
        ApexPages.StandardController stdController = new ApexPages.StandardController(new ADM_Work__c());        
        System.currentPageReference().getParameters().put('Subject__c', testSubject);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(stdController);
        
        System.assertEquals(EncodingUtil.urlEncode(testSubject, 'UTF-8'),ext.getParams().get('Subject__c'));
    }    
    
    /**
	@testcaseID: a1DB00000000iZl 
	@userstoryID: a07B0000000E7wd 
	@Hierarchy:GUS.BugforceToGUS.Bugs in GUS.W-843486 
	@Expected Results: The characters should be properly escaped without causing any errors and properly copying and pasting the desired text in the Comments section
    */
    static testMethod void testProperlyEscapingURLValues() {
        String testSubject = 'Lorrem Ipsum -+=?.,|}{%%&**ab[c]|^tt_(9)-@#<>';
        String encoded = EncodingUtil.urlEncode(testSubject, 'UTF-8');
        ApexPages.StandardController stdController = new ApexPages.StandardController(new ADM_Work__c());        
        System.currentPageReference().getParameters().put('Subject__c', testSubject);        
        System.currentPageReference().getParameters().put('Description__c', testSubject);        
        System.currentPageReference().getParameters().put('Status__c', testSubject);        
        System.currentPageReference().getParameters().put('Type__c', testSubject);        
        System.currentPageReference().getParameters().put('Minor_Func_Area__c', testSubject);        
        System.currentPageReference().getParameters().put('Priority__c', testSubject);        
        System.currentPageReference().getParameters().put('Related_URL__c', testSubject);        
        System.currentPageReference().getParameters().put('ftest__c', testSubject);        
        System.currentPageReference().getParameters().put('Priority_Rank__c', '1'); 
        System.currentPageReference().getParameters().put('Sprint__c', testSubject); 
        System.currentPageReference().getParameters().put('Scrum_Team__c', testSubject); 
        System.currentPageReference().getParameters().put('Customer__c', testSubject);
        System.currentPageReference().getParameters().put('Parent_ID__c', testSubject);
        System.currentPageReference().getParameters().put('Scheduled_Build__c', testSubject);
        System.currentPageReference().getParameters().put('Found_In_Build__c', testSubject);
        
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(stdController);
        
        Map<String,String> params = ext.getParams();
        
        System.assertEquals(encoded,params.get('Subject__c'));
        System.assertEquals(encoded,params.get('Description__c'));
        System.assertEquals(encoded,params.get('Status__c'));
        System.assertEquals(encoded,params.get('Type__c'));
        System.assertEquals(encoded,params.get('Minor_Func_Area__c'));
        System.assertEquals(encoded,params.get('Priority__c'));
        System.assertEquals(encoded,params.get('Related_URL__c'));
        System.assertEquals(encoded,params.get('ftest__c'));
        System.assertEquals('1',params.get('Priority_Rank__c'));
        System.assertEquals(encoded,params.get('Sprint__c'));
        System.assertEquals(encoded,params.get('Scrum_Team__c'));
        System.assertEquals(encoded,params.get('Scrum_Team__c'));
        System.assertEquals(encoded,params.get('Customer__c'));
        System.assertEquals(encoded,params.get('Parent_ID__c'));
        System.assertEquals(encoded,params.get('Scheduled_Build__c'));
        System.assertEquals(encoded,params.get('Found_In_Build__c'));
    }
    
    /**
        testcase ID: a1DB00000000jI2MAI
        user story ID: a07B0000000DnIZIA0
        Hierarchy: GUS.Scrumforcetogus.Work.Bug.New Page
        Expected Results: Type bug is sticky for bugs
        author: Alexis Williams  
    */
    static testMethod void verifyStickyTypes() {      
        ADM_Work__c bug = ADM_Work.createTestBug();
        String typeOriginal = bug.Type__c;
        
        ADM_Work__c work;
        
        System.currentPageReference().getParameters().put('clone', '1');  
        System.currentPageReference().getParameters().put('id', bug.Id);  
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(new ADM_Work__c());
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        work = ext.getWork();
        
        System.assertEquals(typeOriginal, work.Type__c);
    } 
    
    /**
        testcase ID: a1DB00000000qMD
        user story ID: a07B0000000OaR9IAK
        Hierarchy: GUS.Work Page.User Story.New page
        Expected Results: User receives an error that Schedule Build is a mandatory field
    */
    static testMethod void verifyErrorMessagesOnPerforceStatus1() {      
        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_Work__c work;
        List<String> messages;
        String message;
        String errorMessage;
          
        System.currentPageReference().getParameters().put('id', bug.Id);  
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(bug);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        //Test #1 Make sure we get an error when set to a not open status with p4 status open
        work = ext.getWork();
        work.Status__c = 'Fixed';
        work.Perforce_Status__c = 'Open';
        
        ext.saveAndView(false);
        messages = getErrorMessagesFromPage();
        message = ADM_TextUtils.joinList(messages, ',');
        errorMessage = 'Please set the Status to one of the following values when opening the Source Control Status: ';
        System.assertEquals(true, message.contains(errorMessage));
        message = message.replace(errorMessage, '');
        System.assertEquals(message.split(',').size(), ADM_Work.STATUS_VALUES_OPEN.size());
    } 
    
    /**
        testcase ID: a1DB00000000Rvk
        user story ID: a07B0000000OaR9IAK
        Hierarchy: GUS.Work Page.User Story.New page
        Expected Results: error is generated
     */
    static testMethod void verifyErrorMessagesOnPerforceStatus2() {      
        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_Work__c work;
        List<String> messages;
        String message;
        String errorMessage;
          
        System.currentPageReference().getParameters().put('id', bug.Id);  
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(bug);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        
        //Test #2 Make sure we get an error when set to a not open status with p4 status open once
        work = ext.getWork();
        work.Status__c = 'Fixed';
        work.Perforce_Status__c = 'Open Once';
        
        ext.saveAndView(false);
        messages = getErrorMessagesFromPage();
        message = ADM_TextUtils.joinList(messages, ',');
        errorMessage = 'Please set the Status to one of the following values when opening the Source Control Status: ';
        System.assertEquals(true, message.contains(errorMessage));
        message = message.replace(errorMessage, '');
        System.assertEquals(message.split(',').size(), ADM_Work.STATUS_VALUES_OPEN.size());
    } 
    
    /**
        testcase ID: a1DB00000000Rvo
        user story ID: a07B0000000OaR9IAK
        Hierarchy: GUS.Work Page.User Story.New page
        Expected Results: error is generated
    */
    static testMethod void verifyErrorMessagesOnPerforceStatus3() {      
        ADM_Work__c bug = ADM_Work.createTestBug();
        ADM_Work__c work;
        List<String> messages;
        String message;
        String errorMessage;
          
        System.currentPageReference().getParameters().put('id', bug.Id);  
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(bug);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        
        //Test #3 Make sure we get an error when set to a not open status with p4 status open
        work = ext.getWork();
        work.Status__c = 'New';
        work.Perforce_Status__c = 'Open';
        
        ext.saveAndView(false);
        messages = getErrorMessagesFromPage();
        message = ADM_TextUtils.joinList(messages, ',');
        errorMessage = 'Please set the Status to one of the following values when opening the Source Control Status: ';
        System.assertEquals(false, message.contains(errorMessage));
    } 
        /**
        testcase ID: a1DB00000002fEH
        user story ID: a07B0000000OaR9IAK
        Hierarchy: GUS.Product Tags.New Product tag
        Expected Results: invalid tag name error occurs
    */
        static testMethod void verifyErrorIsDisplayForInvalidTagName() {      
        ADM_Work__c bug = ADM_Work.setupTestWork('Bug');
        ADM_Work__c work;
        List<String> messages;
        String message;
        String errorMessage;getErrorMessagesFromPage();
          
        System.currentPageReference().getParameters().put('id', bug.Id);  
        //remove the product tag
        bug.Product_Tag__c = null;
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(bug);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
        
        //Product_Tag__c is null yet the productTagInput param is not. 
        //This mimics the scenario when a user may have hit save before the Product Tag id could be populated.  
        System.currentPageReference().getParameters().put('productTagInput', 'Test Tag That Does Not Exist');
        System.debug('inside verifyErrorMessagesOnProductTags()');
        ext.saveAndView(false);
        messages = getErrorMessagesFromPage();
        message = ADM_TextUtils.joinList(messages, ',');
        System.assert(message.contains('is not a valid tag name for this record type.  Please enter a tag or team name to see the valid suggestions.'), 'Did not expect this error:' + messages);
        
    } 
        /**
        testcase ID: a1DB00000001MVI
        user story ID: a07B0000000OaR9IAK
        Hierarchy: GUS.Product Tags.New Product tag
        Expected Results: Product tag link to assignment rule saves real time
    */
    static testMethod void verifyErrorIsDisplayedWhenNonUniqueTagNameIsEnteredAndAutoCompleteIsNotUsed() {      
        ADM_Work__c bug = ADM_Work.setupTestWork('Bug');
        bug.Product_Tag__c = null;
        
        //setup two tags with same name but owned by different teams
        ADM_Product_Tag__c tag1 = ADM_ProductTagTriggerTest.setupRandomProductTag();
        ADM_Product_Tag__c tag2 = ADM_ProductTagTriggerTest.setupRandomProductTag();
        tag2.Name = tag1.Name;
        tag1.Active__c = true;
        tag2.Active__c = true;
        List<ADM_Product_Tag__c> tags = new List<ADM_Product_Tag__c>{tag1, tag2};
        insert tags;
        
        //setup two rules to go with the tags
        ADM_Assignment_Rule__c rule1 = ADM_AssignmentRuleTest.setupRule();
        rule1.Scrum_Team_Assignment__c = tag1.Team__c;
        ADM_Assignment_Rule__c rule2 = ADM_AssignmentRuleTest.setupRule();
        rule2.Scrum_Team_Assignment__c = tag2.Team__c;
        List<ADM_Assignment_Rule__c> rules = new List<ADM_Assignment_Rule__c>{rule1, rule2};
        update rules;
        
        //relate the rules to the tags
        ADM_Tag_Assignment__c ta1 = new ADM_Tag_Assignment__c();
        ta1.Product_Tag__c = tag1.id;
        ta1.Assignment_Rule__c = rule1.id;
        ta1.Record_Type__c = 'Bug';
        ADM_Tag_Assignment__c ta2 = new ADM_Tag_Assignment__c();
        ta2.Product_Tag__c = tag2.id;
        ta2.Assignment_Rule__c = rule2.id;
        ta2.Record_Type__c = 'Bug';
        List<ADM_Tag_Assignment__c> links = new List<ADM_Tag_Assignment__c>{ta1, ta2};
        insert links;
        
        //open work page
        System.currentPageReference().getParameters().put('id', bug.Id);  
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(bug);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
                
        //Product_Tag__c is null (since onSelect event of auto-complete did not fire) yet the productTagInput param is not. 
        //This mimics the scenario where the user types in a valid product tag name that is owned by more then one team and does not choose an auto-suggestion
        System.currentPageReference().getParameters().put('productTagInput', tag1.Name);
        System.debug('inside verifyErrorIsDisplayedWhenNonUniqueTagNameIsEnteredAndAutoCompleteIsNotUsed()');
        ext.saveAndView(false);
        List<String> messages = getErrorMessagesFromPage();
        String message = ADM_TextUtils.joinList(messages, ',');
        System.assert(message.contains('product tag is used by more then one team.  Please specifiy the version of the tag you intended by selecting one of the auto-suggestions.'), 'Did not expect this error:' + messages);
        
    }
    /**
        testcase ID: a1DB00000001Soo
        user story ID: a07B0000000OaR9IAK
        Hierarchy: GUS.Product Tags.Work Page
      	@author jhatton
    	@expected results: Bug was found where page would allow you to save without checking if the tag was active for that paticular record type
    */
    
    static testMethod void verifyErrorIsDisplayedWhenTagIsActiveForOnlySomeRecordTypes() {      
        ADM_Work__c bug = ADM_Work.setupTestWork('Bug');
        bug.Product_Tag__c = null;
        
        
        ADM_Product_Tag__c tag1 = ADM_ProductTagTriggerTest.setupRandomProductTag();
        List<ADM_Product_Tag__c> tags = new List<ADM_Product_Tag__c>{tag1};
        insert tags;
        
   
        ADM_Assignment_Rule__c rule1 = ADM_AssignmentRuleTest.setupRule();
        rule1.Scrum_Team_Assignment__c = tag1.Team__c;
        List<ADM_Assignment_Rule__c> rules = new List<ADM_Assignment_Rule__c>{rule1};
        update rules;
        
        //relate the rule to a tag for USER STORYS only!
        ADM_Tag_Assignment__c ta1 = new ADM_Tag_Assignment__c();
        ta1.Product_Tag__c = tag1.id;
        ta1.Assignment_Rule__c = rule1.id;
        ta1.Record_Type__c = 'User Story';
        List<ADM_Tag_Assignment__c> links = new List<ADM_Tag_Assignment__c>{ta1};
        insert links;
        
        //open work page for Bug (not tag is not valid for bugs only stories)
        System.currentPageReference().getParameters().put('id', bug.Id);  
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(bug);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
                
        System.currentPageReference().getParameters().put('productTagInput', tag1.Name);
        ext.saveAndView(false);
        List<String> messages = getErrorMessagesFromPage();
        String message = ADM_TextUtils.joinList(messages, ',');
        System.assert(message.contains('is not a valid tag name for this record type.'), 'Did not expect this error:' + messages);
        
    }
    /**
        testcase ID: a1DB00000001Xwk
        user story ID: a07B0000000OaR9IAK
        Hierarchy: GUS.Product Tags.Work Page
        Expected Results: product tag and team change. A comment is created about the product tag and team changing
       */
    
    static testMethod void verifyErrorIsNOTDisplayedWhenUniqueTagNameIsEnteredAndAutoCompleteIsNotUsed() {      
        ADM_Work__c bug = ADM_Work.setupTestWork('Bug');
        bug.Product_Tag__c = null;
        
        //setup 1 tag with a unique name 
        ADM_Product_Tag__c tag1 = ADM_ProductTagTriggerTest.setupRandomProductTag();
        tag1.Active__c = true;
        List<ADM_Product_Tag__c> tags = new List<ADM_Product_Tag__c>{tag1};
        insert tags;
        
        //open work page
        System.currentPageReference().getParameters().put('id', bug.Id);  
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(bug);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(ctrl);
                
        //Product_Tag__c is null (since onSelect event of auto-complete did not fire) yet the productTagInput param is not. 
        //This mimics the scenario where the user types in a valid product tag name, the name IS unique.  
        //Even though the user did not choose an auto-suggestion we can look up the tag for them
        System.currentPageReference().getParameters().put('productTagInput', tag1.Name);
        System.debug('inside verifyErrorIsNOTDisplayedWhenUniqueTagNameIsEnteredAndAutoCompleteIsNotUsed()');
        ext.saveAndView(false);
        List<String> messages = getErrorMessagesFromPage();
        String message = ADM_TextUtils.joinList(messages, ',');
        System.assert(!message.contains('product tag is used by more then one team.  Please specifiy the version of the tag you intended by selecting one of the auto-suggestions.'));
        System.assert(!message.contains('is not a valid tag name.  Please enter a tag or team name to see the valid suggestions.'));
        
    }  
    
    private static List<String> getErrorMessagesFromPage() {
        List<String> messages = new List<String>();
        for(ApexPages.Message message : ApexPages.getMessages()) {
            messages.add(message.getSummary());
        }
        return messages;
    }
}