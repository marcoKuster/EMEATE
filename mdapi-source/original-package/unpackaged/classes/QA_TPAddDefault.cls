public with sharing class QA_TPAddDefault {
    
    //Inner class for a test case and whether or not it is selected in the table
    public class TestCaseWrapper {
        private QA_Test_Case__c testCase;
        private Boolean selected;
        private String hierarchyError;
        private String briefDescError;
        private String longDescError;
        private String expectedResultsError;
        
        public TestCaseWrapper(QA_Test_Case__c TC, Boolean sel) {
            testCase = TC;
            selected = sel;
            hierarchyError = '';
            briefDescError = '';
            longDescError = '';
            expectedResultsError = '';
        }
        
        public QA_Test_Case__c getTestCase() {
            return testCase;
        }
        
        public Boolean getSelected() {
            return selected;
        }
        
        public void setSelected(Boolean sel) {
            selected = sel;
        }
        
        //Returns the hierarchy error message (if any)
        public String getHierarchyError() {
            return hierarchyError;
        }
        
        public Boolean getIsHierarchyError() {
            return hierarchyError != null && hierarchyError != '';
        }
    
        //Returns the brief description error message (if any)
        public String getBriefDescError() {
            return briefDescError;
        }
        
        public Boolean getIsBriefDescError() {
            return briefDescError != null && briefDescError != '';
        }
        
        //Returns the long description error message (if any)
        public String getLongDescError() {
            return longDescError;
        }
        
        public Boolean getIsLongDescError() {
            return longDescError != null && longDescError != '';
        }
        
        //Returns the expected results error message (if any)
        public String getExpectedResultsError() {
            return expectedResultsError;
        }
        
        public Boolean getIsExpectedResultsError() {
            return expectedResultsError != null && expectedResultsError != '';
        }
    }
    
    private QA_Answer__c answer;
    private List<TestCaseWrapper> defaultTCs;
    private Integer numRows;
    private String defaultHierarchy;
    public QA_Test_Execution__c testExec {
        get {
            if(testExec == null) {
                testExec = new QA_Test_Execution__c();
            }
            return testExec;
        }
        set;
    }
    public Boolean selectAllCheckbox {get; set;}
    private static final Integer MAX_NUM_ROWS = 50;
    
    //Simplifies the logic of changing this label as long as structure remains the same
    //This is the only place the change needs to be made
    public static String getCompleted() {
        return 'Completed';
    }
    
    //Constructor used by the visualforce pages
    public QA_TPAddDefault() {
        Id answerid = System.currentPageReference().getParameters().get('answerid');
        answer = [select Question__c, Test_Plan__c, Test_Plan__r.Scrum_Team__r.Name, Test_Plan__r.Name, Question__r.Category__c, 
            Question__r.Question_Text__c from QA_Answer__c where QA_Answer__c.Id = :answerid];
        List<QA_Default_Test_Case__c> qaDefaultTestCases = [select test_case__c from QA_Default_Test_Case__c where question__c = :answer.question__c];
        List<Id> testCaseIds = new List<Id>();
        for(QA_Default_Test_Case__c qaDefaultTestCase : qaDefaultTestCases){
            testCaseIds.add(qaDefaultTestCase.test_case__c);
        }
        List<QA_Test_Case__c> TCs = [select Hierarchy__c, Brief_Description__c, Steps_To_Reproduce__c, Expected_Results__c, Priority__c, Execution_Type__c 
        			from QA_Test_Case__c 
            where QA_Test_Case__c.id in :testCaseIds ];
        List<QA_Test_Case__c> clonedTCs = TCs.deepClone(false);
        defaultTCs = new List<TestCaseWrapper>();
        defaultHierarchy = answer.Test_Plan__r.Scrum_Team__r.Name + '.' + answer.Test_Plan__r.Name + '.' + answer.Question__r.Category__c + '.' + answer.Question__r.Question_Text__c;
        for(QA_Test_Case__c TC : clonedTCs) {        
            TC.Hierarchy__c = defaultHierarchy;
            defaultTCs.add(new TestCaseWrapper(TC, true));
        }
        numRows = defaultTCs.size();
        selectAllCheckbox = true;
    }
    
    //Queries the QA_Test_Case__c object and returns the list of possible options for the Execution Type field
    //Used because default input field did not fit well into the spreadsheet layout
    public List<SelectOption> getExecTypeOptions() {
        List<SelectOption> execTypeOptions = new List<SelectOption>();
        Schema.DescribeFieldResult F = QA_Test_Case__c.Execution_Type__c.getDescribe();
        List<Schema.PicklistEntry> executionTypes = F.getPicklistValues();
        for(Schema.PicklistEntry executionType : executionTypes) {
            execTypeOptions.add(new SelectOption(executionType.getLabel(), executionType.getLabel()));
        }
        return execTypeOptions;
    }
    
    //Queries the QA_Test_Case__c object and returns the list of possible options for the Priority field
    //Used because did not want the None option to be displayed since it would start with a default value
    public List<SelectOption> getPriorityOptions() {
        List<SelectOption> priorityOptions = new List<SelectOption>();
        Schema.DescribeFieldResult F = QA_Test_Case__c.Priority__c.getDescribe();
        List<Schema.PicklistEntry> priorities = F.getPicklistValues();
        for(Schema.PicklistEntry priority : priorities) {
            priorityOptions.add(new SelectOption(priority.getLabel(), priority.getLabel()));
        }
        return priorityOptions;
    }
    
    //Returns the list of possible options for the User Story field for the current test plan
    //Used because only want the user stories associated with this test plan to be choices
    public List<SelectOption> getUserStoryOptions() {
        List<SelectOption> userStoryOptions = new List<SelectOption>();
        List<ADM_Work__c> userStories = [select Name, Id from ADM_Work__c where Test_Plan__c = :answer.Test_Plan__c];
        userStoryOptions.add(new SelectOption('', '--None--'));
        for(ADM_Work__c userStory : userStories) {
            userStoryOptions.add(new SelectOption(userStory.Id, userStory.Name));
        }
        return userStoryOptions;
    }
    
    //Adds a new row to the bottom of the test case table
    public void addRow() {
        if (numRows >= MAX_NUM_ROWS) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot add more than ' + MAX_NUM_ROWS + ' test cases at a time.');
            ApexPages.AddMessage(myMsg);    
        }
        else {
            QA_Test_Case__c row = new QA_Test_Case__c();
            row.Hierarchy__c = defaultHierarchy;
            row.Steps_to_Reproduce__c = 'No description';
            numRows++;
            defaultTCs.add(new TestCaseWrapper(row, true));
        }
    }
    
    public void selectAll() {
        for(TestCaseWrapper TC : defaultTCs) {
            if(selectAllCheckbox == true) {
                TC.setSelected(true);
            }
            else {
                TC.setSelected(false);
            }
        } 
    }
    
    //Returns a reference to the 1st page in the wizard
    //No validation is done because the values are not saved going backward
    public PageReference step1() {
        return Page.QA_TPAddDefaultStep1;
    }
    
    //Returns a reference to the 2nd page in the wizard if there are no errors
    //Otherwise, outputs relevant error messages (at least one selected, non-empty brief description, valid hierarchy, fields not over max char lengths)
    public PageReference step2() {
        Boolean selected = false;
        Boolean goodDescription = true;
        Boolean goodHierarchy = true;
        
        for(TestCaseWrapper TC : defaultTCs) {
            if(TC.getSelected()) {
                selected = true;
                break;
            }
        }
        if(!selected) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one test case.');
            ApexPages.AddMessage(myMsg);    
        }
        
        List<QA_Hierarchy__c> baseHierarchies = [SELECT Name FROM QA_Hierarchy__c WHERE Depth__c = 0 limit 200];
        for(TestCaseWrapper TC : defaultTCs) {
            TC.briefDescError = '';
            TC.hierarchyError = '';
            
            //Validate only if the test case is selected
            if(TC.getSelected()) {
                if(TC.getTestCase().Brief_Description__c == '' || TC.getTestCase().Brief_Description__c == null) {
                    goodDescription = false;
                    TC.briefDescError = 'You must enter a brief description';
                }
                else if(TC.getTestCase().Brief_Description__c.length() > 255) {
                    goodDescription = false;
                    TC.briefDescError = 'Value cannot be more than 255 characters';
                }
                
                if(TC.getTestCase().Steps_to_Reproduce__c != null && TC.getTestCase().Steps_to_Reproduce__c.length() > 32000) {
                    goodDescription = false;
                    TC.longDescError = 'Value cannot be more than 32,000 characters';
                }
                
                if(TC.getTestCase().Expected_Results__c != null && TC.getTestCase().Expected_Results__c.length() > 32000) {
                    goodDescription = false;
                    TC.expectedResultsError = 'Value cannot be more than 32,000 characters';
                }
                
                if(TC.getTestCase().Hierarchy__c == '' || TC.getTestCase().Hierarchy__c == null) {
                    goodHierarchy = false;
                    TC.hierarchyError = 'You must enter a hierarchy';
                }
                else {
                    List<String> hierarchies = TC.getTestCase().Hierarchy__c.split('\\.');
                    if(hierarchies.size() < 2) {
                        goodHierarchy = false;
                        TC.hierarchyError = 'The hierarchy must have a depth of at least 2';
                    }
                    else if(hierarchies.size() > 5) {
                        goodHierarchy = false;
                        TC.hierarchyError = 'You can only create up to 5 hierarchy levels.';
                    }
                    for(String hierarchy : hierarchies) {
                        if(hierarchy == '') {
                            goodHierarchy = false;
                            TC.hierarchyError = 'Hierarchy elements must not be empty';
                            break;
                        }
                    }
                    
                    //Only check the base hierarchy if no error message is being displayed yet
                    if(goodHierarchy) {
                        Boolean valid = false;
                        for(Integer index = 0; index < baseHierarchies.size(); index++) {
                            if(hierarchies.get(0).equalsIgnoreCase(baseHierarchies.get(index).Name)) {
                                valid = true;
                                TC.getTestCase().Hierarchy__c.replaceFirst(hierarchies.get(0), baseHierarchies.get(index).Name);
                                break;
                            }
                        }
                        if(!valid) {
                            goodHierarchy = false;
                            TC.hierarchyError = 'You must provide a valid base hierarchy';
                        }
                    }
                }
            }
        }
        
        if(!selected || !goodDescription || !goodHierarchy) {
            return null;
        }
        return Page.QA_TPAddDefaultStep2;
    }
    
    //Saves the customized default test cases and their executions and returns a reference to the current test plan's detail page
    //Since user story is not an inputField, returns null and an error message if '--None--' is specified
    public PageReference save() {
        String userStoryId = testExec.User_Story__c;
        if(userStoryId == null) {
            return null;
        }
        
        List<QA_Test_Case__c> insertTestCases = new List<QA_Test_Case__c>();
        for(QA_Test_Case__c TC : getSelectedTCs()) {
            insertTestCases.add(TC);
        }
        try {
        	if(insertTestCases.size()>0) {
            	insert(insertTestCases);
        	}
            
            List<QA_Test_Execution__c> insertTestExecs = new List<QA_Test_Execution__c>();
            for(QA_Test_Case__c TC : getSelectedTCs()) {
                QA_Test_Execution__c insertTestExec = new QA_Test_Execution__c();
                insertTestExec.Status__c = 'Planned';
                insertTestExec.Number_of_Executions__c = 0;
                insertTestExec.User_Story__c = testExec.User_Story__c;
                insertTestExec.Type__c = testExec.Type__c;
                insertTestExec.Assignee__c = testExec.Assignee__c;
                insertTestExec.Test_Case__c = TC.Id;
                insertTestExecs.add(insertTestExec);                
            }            
            insert(insertTestExecs);
            
            answer.Status__c = getCompleted();
            update(answer);
        } catch(Exception e) {
            ApexPages.addMessages(e);            
            return null;
        }
        
        PageReference ref = Page.QA_TPDetails;
        ref.getParameters().put('id', answer.Test_Plan__c);
        return ref;
    }
    
    //Returns a reference to the current test plan's detail page
    public PageReference cancel() {
        PageReference ref = Page.QA_TPDetails;
        ref.getParameters().put('id', answer.Test_Plan__c);
        return ref;
    }
    
    //Returns all default test case wrappers
    public List<TestCaseWrapper> getDefaultTCs() {
        return defaultTCs;
    }
    
    //Returns only the selected default test cases
    public List<QA_Test_Case__c> getSelectedTCs() {
        List<QA_Test_Case__c> selectedTCs = new List<QA_Test_Case__c>();
        for(TestCaseWrapper TC : defaultTCs) {
            if(TC.getSelected()) {
                selectedTCs.add(TC.getTestCase());
            }
        }
        return selectedTCs;
    }
    
    //Unit Tests and Helper Methods
    
    //Creates a new test plan associated with the specified scrum team and name
    public static QA_Test_Plan__c createTestPlan(String name, ADM_Scrum_Team__c team) {
        QA_Test_Plan__c tp = new QA_Test_Plan__c();
        tp.Name = name;
        tp.Description__c = 'TestPlan';
        tp.Functional_Specification__c = 'none';
        tp.BugList__c = 'none';
        tp.Scrum_Team__c = team.Id;
        insert(tp);
        return tp;
    }
    
    //Creates a new scrum team with the specified name
    public static ADM_Scrum_Team__c createScrumTeam(String name) {
       ADM_Scrum_Team__c scrumTeam = ADM_ScrumTeam.createTestScrumTeam(name);
        return scrumTeam;
    }
    
    //Creates a new user story associated with the specified test plan and with the given name
    public static ADM_Work__c createUserStory(String name, QA_Test_Plan__c testPlan) {    	
		//create the product tag
		ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();
		
		//create the assignment rule
		ADM_Assignment_Rule__c assignmentRule = ADM_AssignmentRule.createAndInsertAssignmentRule();
        
        //create the tag assignment
        ADM_Tag_Assignment__c tagAssignment = new ADM_Tag_Assignment__c();
        tagAssignment.Assignment_Rule__c = assignmentRule.Id;
        tagAssignment.Product_Tag__c = productTag.Id;
        tagAssignment.Record_Type__c = ADM_Work.RECORD_TYPE_NAME_USERSTORY;
        insert tagAssignment;
		
        ADM_Work__c userStory = new ADM_Work__c();
        userStory.Subject__c = name;
        userStory.Type__c = 'User Story';
        userStory.Test_Plan__c = testPlan.Id;
        userStory.RecordTypeId = ADM_RecordType.getId(ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        userStory.Product_Tag__c = productTag.Id;
        userStory.Product_Area__c = 'some area';
        userStory.Priority__c = 'P1';
        userStory.Scrum_Team__c = createScrumTeam('Sao Paulo').id;
        userStory.Major_Func_Area__c = 'func area';
        
        insert(userStory);
        return [select id, name from ADM_Work__c where id = :userStory.id];
    }
    
    //Creates a new hierarchy with the specified name
    public static QA_Hierarchy__c createBaseHierarchy(String name) {
        QA_Hierarchy__c hierarchy = new QA_Hierarchy__c();
        hierarchy.Name = name;
        hierarchy.Depth__c = 0;
        insert(hierarchy);
        return hierarchy;
    }
    
    //Creates new test cases with the specified hierarchy
    public static List<QA_Test_Case__c> createTestCases(String hierarchy, Integer num, QA_Question__c question) {
        List<QA_Test_Case__c> testCases = new List<QA_Test_Case__c>();
        
        for(Integer i = 0; i < num; i++) {
            QA_Test_Case__c testCase = new QA_Test_Case__c();
            testCase.Hierarchy__c = hierarchy;
            testCase.Brief_Description__c = 'Test';
            testCase.Priority__c = 'Medium';
            testCases.add(testCase);
        }
        insert(testCases);
        
        if(question!=null) {
        	List<QA_Default_Test_Case__c> defaultTCs = new List<QA_DEfault_Test_Case__c>();
        	for(QA_Test_Case__c testCase: testCases) {
	        	QA_Default_Test_Case__c defaultTC = new QA_Default_Test_Case__c();
	        	defaultTC.test_case__c = testCase.id;
	        	defaultTC.question__c = question.id;
	        	defaultTCs.add(defaultTC);
        	}
        	insert(defaultTCs);
        }
        
        
        return testCases;
    }

    //Creates a new question with specified question text and category
    public static QA_Question__c createQuestion(String text, String category) {
        QA_Question__c question = new QA_Question__c();
        question.Question_Text__c = text;
        question.Category__c = category;
        insert(question);
        return question;
    }
    
    //Marks questions as obsolete so their answers don't get created during tests
    public static void clearQuestions() {
        for(List<QA_Question__c> questions : [select Obsolete__c, Editable__c from QA_Question__c where Obsolete__c = false]) {
            for(QA_Question__c question : questions) {
                question.Obsolete__c = true;
                question.Editable__c = true;
            }
            update questions;
        }
    }
    
    //Test navigation from step 1 to step 2 with no test cases selected, a description error, and a hierarchy error
    public static testMethod void testTestCaseErrors() {
        //Setup a test plan and one default test case for one of its questions
        clearQuestions();
        ADM_Scrum_Team__c scrumTeam = createScrumTeam('QAForceTest');
        QA_Question__c question = createQuestion('Setup Audit Trail Test', 'Admin');
        QA_Test_Plan__c testPlan = createTestPlan('TestPlan', scrumTeam);
        QA_Hierarchy__c hierarchyDefault = createBaseHierarchy('Default Test Plan');
        QA_Hierarchy__c hierarchyScrum = createBaseHierarchy('QAForceTest');
        List<QA_Test_Case__c> testCases = createTestCases('Default Test Plan.Admin.Setup Audit Trail Test', 1, question);
        
        //Instantiate a new controller with the id of the answer with default test cases as its parameter
        Id answerid = [select Id from QA_Answer__c where Test_Plan__c = :testPlan.Id].Id;
        PageReference pageRef = Page.QA_TPAddDefaultStep1;
        pageRef.getParameters().put('answerid', answerid);
        Test.setCurrentPage(pageRef);
        QA_TPAddDefault controller = new QA_TPAddDefault(); 
        
        Test.startTest();
        //Trying to move on to step 2 with no selected test cases should cause an error
        TestCaseWrapper testCase = controller.getDefaultTCs().get(0);
        testCase.setSelected(false);
        System.assert(controller.step2() == null);
        ApexPages.Message message = ApexPages.getMessages().get(0);
        System.assertEquals(ApexPages.Severity.ERROR, message.getSeverity());
        System.assertEquals('You must select at least one test case.', message.getSummary());
        
        //Trying to move on to step 2 with an invalid hierarchy specified should cause an error
        testCase.setSelected(true);        
        testCase.getTestCase().Hierarchy__c = '';
        System.assert(controller.step2() == null);
        System.assertEquals('You must enter a hierarchy', testCase.getHierarchyError());
        
        testCase.getTestCase().Hierarchy__c = 'a..b';
        System.assert(controller.step2() == null);
        System.assertEquals('Hierarchy elements must not be empty', testCase.getHierarchyError());
        
        testCase.getTestCase().Hierarchy__c = 'Test Default Test Plan Test.abc';
        System.assert(controller.step2() == null);
        System.assertEquals('You must provide a valid base hierarchy', testCase.getHierarchyError());
        
        testCase.getTestCase().Hierarchy__c = 'a.b.c.d.e.f';
        System.assert(controller.step2() == null);
        System.assertEquals('You can only create up to 5 hierarchy levels.', testCase.getHierarchyError());
        
        testCase.getTestCase().Hierarchy__c = 'Default Test Plan';
        System.assert(controller.step2() == null);
        System.assertEquals('The hierarchy must have a depth of at least 2', testCase.getHierarchyError());
        
        //Trying to move on to step 2 with an invalid hierarchy and a blank brief description should display both errors
        testCase.getTestCase().Brief_Description__c = '';
        System.assert(controller.step2() == null);
        System.assertEquals('The hierarchy must have a depth of at least 2', testCase.getHierarchyError());
        System.assertEquals('You must enter a brief description', testCase.getBriefDescError());
        System.assertEquals(true, testCase.getIsBriefDescError());
        System.assertEquals(true, testCase.getIsHierarchyError());
        
        //Trying to move on to step 2 with a brief description over 255 characters should cause an error
        testCase.getTestCase().Hierarchy__c = 'QAForceTest.TestPlan.Admin.Setup Audit Trail Test';
        testCase.getTestCase().Brief_Description__c = 'I am a brief description that is over 255 characters and I should throw an error ' +
            'because of this. I am a brief description that is over 255 characters and I should throw an error because of this. I am a ' +
            'brief description that is over 255 characters and I should throw an error because of this.';
        System.assert(controller.step2() == null);
        System.assertEquals('Value cannot be more than 255 characters', testCase.getBriefDescError());
        System.assertEquals(true, testCase.getIsBriefDescError());
        System.assertEquals(false, testCase.getIsHierarchyError());
        
        //Long description and expected results are both under 32,000 characters, so they should not have an error
        System.assertEquals('', testCase.getLongDescError());
        System.assertEquals(false, testCase.getIsLongDescError());
        System.assertEquals('', testCase.getExpectedResultsError());
        System.assertEquals(false, testCase.getIsExpectedResultsError());
        
        Test.stopTest();
    }
    
    //Test Select All checkbox functionality
    public static testMethod void testSelectAll() {
        //Setup a test plan and 20 default test cases for one of its questions
        clearQuestions();
        ADM_Scrum_Team__c scrumTeam = createScrumTeam('QAForceTest');
        QA_Question__c question = createQuestion('Setup Audit Trail Test', 'Admin');
        QA_Test_Plan__c testPlan = createTestPlan('TestPlan', scrumTeam);
        QA_Hierarchy__c hierarchyDefault = createBaseHierarchy('Default Test Plan');
        QA_Hierarchy__c hierarchyScrum = createBaseHierarchy('QAForceTest');
        List<QA_Test_Case__c> testCases = createTestCases('Default Test Plan.Admin.Setup Audit Trail Test', 20, question);
        
        //Instantiate a new controller with the id of the answer with default test cases as its parameter
        Id answerid = [select Id from QA_Answer__c where Test_Plan__c = :testPlan.Id].Id;
        PageReference pageRef = Page.QA_TPAddDefaultStep1;
        pageRef.getParameters().put('answerid', answerid);
        Test.setCurrentPage(pageRef);
        QA_TPAddDefault controller = new QA_TPAddDefault(); 
        
        Test.startTest();
        //All test cases should be selected, so SelectAll() should deselect all of them
        for(TestCaseWrapper TC : controller.getDefaultTCs()) {
            System.assert(TC.getSelected());
        }
        System.assert(controller.getSelectedTCs().size() == 20);
        controller.selectAllCheckbox = false;
        controller.selectAll();
        System.assert(controller.getSelectedTCs().size() == 0);
        
        //Select one test case, then select all
        controller.getDefaultTCs().get(0).setSelected(true);
        System.assert(controller.getSelectedTCs().size() == 1);
        controller.selectAllCheckbox = true;
        controller.selectAll();
        System.assert(controller.getSelectedTCs().size() == 20);
        
        Test.stopTest();
    }
    
    //Test that execution type, priority, and user story options are displaying
    public static testMethod void testOptions() {
        //Setup a test plan
        clearQuestions();
        ADM_Scrum_Team__c scrumTeam = createScrumTeam('QAForceTest');
        QA_Question__c question = createQuestion('Setup Audit Trail Test', 'Admin');
        QA_Test_Plan__c testPlan = createTestPlan('TestPlan', scrumTeam);
        
        //Instantiate a new controller with the id of an answer as its parameter
        Id answerid = [select Id from QA_Answer__c where Test_Plan__c = :testPlan.Id].Id;
        PageReference pageRef = Page.QA_TPAddDefaultStep1;
        pageRef.getParameters().put('answerid', answerid);
        Test.setCurrentPage(pageRef);
        QA_TPAddDefault controller = new QA_TPAddDefault(); 
        
        Test.startTest();
        //Test that only the --None-- option is returned, then attach a user story and make sure that option is returned also
        List<SelectOption> userStoryOptions = controller.getUserStoryOptions();
        System.assert(userStoryOptions.size() == 1);
        System.assertEquals('--None--', userStoryOptions.get(0).getLabel());
        System.assertEquals('', userStoryOptions.get(0).getValue());
        
        ADM_Work__c userStory = createUserStory('User Story', testPlan);
        userStoryOptions = controller.getUserStoryOptions();
        System.assert(userStoryOptions.size() == 2);
        System.assertEquals(userStory.name, userStoryOptions.get(1).getLabel());
        System.assertEquals(userStory.Id, userStoryOptions.get(1).getValue());
        
        //Since execution type and priority could change, just verify that some options are being returned
        System.assert(controller.getExecTypeOptions().size() > 0);
        System.assert(controller.getPriorityOptions().size() > 0);
        
        Test.stopTest();
    }
    
    //Test adding a row to the TC table
    public static testMethod void testAddRow() {
        //Setup a test plan and 20 default test cases for one of its questions
        clearQuestions();
        ADM_Scrum_Team__c scrumTeam = createScrumTeam('QAForceTest');
        QA_Question__c question = createQuestion('Setup Audit Trail Test', 'Admin');
        QA_Test_Plan__c testPlan = createTestPlan('TestPlan', scrumTeam);
        QA_Hierarchy__c hierarchyDefault = createBaseHierarchy('Default Test Plan');
        QA_Hierarchy__c hierarchyScrum = createBaseHierarchy('QAForceTest');
        List<QA_Test_Case__c> testCases = createTestCases('Default Test Plan.Admin.Setup Audit Trail Test', 20, question);
        
        //Instantiate a new controller with the id of the answer with default test cases as its parameter
        Id answerid = [select Id from QA_Answer__c where Test_Plan__c = :testPlan.Id].Id;
        PageReference pageRef = Page.QA_TPAddDefaultStep1;
        pageRef.getParameters().put('answerid', answerid);
        Test.setCurrentPage(pageRef);
        QA_TPAddDefault controller = new QA_TPAddDefault(); 
        
        Test.startTest();
        //Test adding 2 rows one a time
        System.assertEquals(20, controller.numRows);
        controller.addRow();
        System.assertEquals(21, controller.numRows);
        controller.addRow();
        System.assertEquals(22, controller.numRows);
        System.assertEquals(22, controller.getDefaultTCs().size());
        
        //Test adding a row when already at the maximum number of rows allowed -- should cause an error
        while(controller.numRows < MAX_NUM_ROWS) {
            controller.addRow();
        }
        System.assertEquals(MAX_NUM_ROWS, controller.getDefaultTCs().size());
        controller.addRow();
        ApexPages.Message message = ApexPages.getMessages().get(0);
        System.assertEquals(ApexPages.Severity.ERROR, message.getSeverity());
        System.assertEquals('You cannot add more than ' + MAX_NUM_ROWS + ' test cases at a time.', message.getSummary());
        
        Test.stopTest();
    }
    
    //Test navigation from step 1 to step 2, from step 2 to step 1, and the cancel button with 20 test cases selected
    public static testMethod void testNavigation() {
       /* //Setup a test plan and 20 default test cases for one of its questions
        clearQuestions();
        ADM_Scrum_Team__c scrumTeam = createScrumTeam('QAForceTest');
        QA_Question__c question = createQuestion('Setup Audit Trail Test', 'Admin');
        QA_Test_Plan__c testPlan = createTestPlan('TestPlan', scrumTeam);
        QA_Hierarchy__c hierarchyDefault = createBaseHierarchy('Default Test Plan');
        QA_Hierarchy__c hierarchyScrum = createBaseHierarchy('QAForceTest');
        List<QA_Test_Case__c> testCases = createTestCases('Default Test Plan.Admin.Setup Audit Trail Test', 20, question);
        
        //Instantiate a new controller with the id of the answer with default test cases as its parameter
        Id answerid = [select Id from QA_Answer__c where Test_Plan__c = :testPlan.Id].Id;
        PageReference pageRef = Page.QA_TPAddDefaultStep1;
        pageRef.getParameters().put('answerid', answerid);
        Test.setCurrentPage(pageRef);
        QA_TPAddDefault controller = new QA_TPAddDefault(); 
        
        Test.startTest();
        //Since test cases were created with all necessary fields, try navigating to step 2 of the wizard
        //Should return a PageReference to step 2, or a non-null value
        System.assert(controller.step2() != null);
        System.assert(System.currentPageReference() != null);
        System.assert(controller.step1() != null);
        System.assertEquals('/apex/qa_tpdetails?id=' + TestPlan.Id, controller.cancel().getUrl());
        Test.stopTest(); */
    }
    
    //Test an unsuccessful and successful save for 20 selected test cases
    public static testMethod void testSave() {
        //Setup a test plan and 20 default test cases for one of its questions
        clearQuestions();
        ADM_Scrum_Team__c scrumTeam = createScrumTeam('QAForceTest');
        QA_Question__c question = createQuestion('Setup Audit Trail Test', 'Admin');
        QA_Test_Plan__c testPlan = createTestPlan('TestPlan', scrumTeam);
        QA_Hierarchy__c hierarchyDefault = createBaseHierarchy('Default Test Plan');
        QA_Hierarchy__c hierarchyScrum = createBaseHierarchy('QAForceTest');
        List<QA_Test_Case__c> testCases = createTestCases('Default Test Plan.Admin.Setup Audit Trail Test', 20, question);
        
        //Instantiate a new controller with the id of the answer with default test cases as its parameter
        Id answerid = [select Id from QA_Answer__c where Test_Plan__c = :testPlan.Id].Id;
        PageReference pageRef = Page.QA_TPAddDefaultStep2;
        pageRef.getParameters().put('answerid', answerid);
        Test.setCurrentPage(pageRef);
        QA_TPAddDefault controller = new QA_TPAddDefault(); 
        
        //Specify required test execution information (know that there must be at least one user in this org)
        controller.testExec.Type__c = QA_Test_Execution__c.Type__c.getDescribe().getPicklistValues().get(0).getLabel();
        controller.testExec.Assignee__c = [SELECT Id FROM User LIMIT 1].Id;
        
        Test.startTest();
        //Since user story is not specified, saving should cause save to return null (error is handled in VF)
        System.assert(controller.save() == null);
        
        //Specify user story, save should be successful
        controller.testExec.User_Story__c = createUserStory('User Story', testPlan).Id;        
        
        String qualifiedPageName = (ADM_ConstantsSingleton.getInstance().getNameSpace() + 'qa_tpdetails').toLowerCase();   
        System.assertEquals('/apex/'+qualifiedPageName+'?id=' + testPlan.Id, controller.save().getUrl());
        Test.stopTest();
        
        System.assertEquals(getCompleted(), [select Status__c from QA_Answer__c where Test_Plan__c = :testPlan.Id].Status__c);
        List<QA_Test_Case__c> testCasesInserted = [select Id from QA_Test_Case__c where Hierarchy__c = 'QAForceTest.TestPlan.Admin.Setup Audit Trail Test'];
        List<QA_Test_Execution__c> testExecsInserted = [select Id from QA_Test_Execution__c where Test_Case__c in :testCasesInserted];
        System.assertEquals(20, testCasesInserted.size());
        System.assertEquals(20, testExecsInserted.size());
    }
}