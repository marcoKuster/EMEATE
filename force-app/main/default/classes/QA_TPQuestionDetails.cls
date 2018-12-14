public with sharing class QA_TPQuestionDetails {
   //Contains information for each row in the answer table
    public class AnswerRow {
        public QA_Answer__c answer {get; set;}
        public boolean editable {get; set;}
        private String oldStatus;
        public List<QA_Comment__c> comments {get; set;}
        public String newComment {get; set;}
        private boolean hasDefaultTestCase;

        public AnswerRow(QA_Answer__c answer, boolean hasDefaultTestCase) {
            this.answer = answer;
            editable = false;
            comments = new List<QA_Comment__c>();
            newComment = '';
            this.hasDefaultTestCase = hasDefaultTestCase;
        }

        //The current row is being edited
        public void setEditable() {
            editable = true;
            //Save the old status so changes can be undone
            oldStatus = answer.Status__c;
        }

        //Revert (undo) the status to what it was
        public void revertStatus() {
            editable = false;
            answer.Status__c = oldStatus;
            newComment = '';
        }

        public Integer getNumberOfComments() {
            return comments.size();
        }

        public void saveComment() {
        //Check for comment text in an edited row
            if (commentHasText()) {
                QA_Comment__c comment = new QA_Comment__c();

                comment.Comment_Text__c = Pattern.compile('\n').matcher(newComment).replaceAll('<BR />');

                comment.Answer__c = answer.id;
                insert comment;

                comments.add([select Comment_Text__c, Answer__c, Owner.Name, CreatedDate from QA_Comment__c where Id = :comment.id]);
                newComment='';
            }
        }

        public void cancelComment() {
            newComment='';
        }

        public List<QA_Comment__c> getCommentsInDesc() {
            List<QA_Comment__c> tempList = new List<QA_Comment__c>();
            for (Integer i = comments.size()-1; i >= 0; i--) {
                tempList.add(comments.get(i));
            }
            return tempList;
        }

        public boolean commentHasText() {
            return newComment != null && newComment != '' && !Pattern.matches('\\s*', newComment);
        }
        
        //Returns true if the current question has any default test cases associated with it and the question is not completed
        public Boolean getHasDefaultTestCases(){
        	return hasDefaultTestCase && answer.Status__c != getCompletedLabel();
        }        
    }

    //Contains answers for each category group in the answer table. Also keeps track of
    //category completeness
    public class CategoryWrapper {
        public String category {get; set;}
        public List<AnswerRow> answers {get; set;}

        //Compute percent complete for the section everytime the property is retrieved to
        //reflect changes
        public Long percentComplete {
            get {
                return computePercent(answersProgress(answers), answersProgressSize(answers));
            }
            set;
        }

        public CategoryWrapper (String category, List<AnswerRow> answers) {
            this.category = category;
            this.answers = answers;
        }

        //Returns if the category is in progress
        public boolean getInProgress() {
            //Store so the percentComplete is not computed twice if both conditions are executed
            Long perComp = percentComplete;

            return perComp > 0.0 && perComp < 100.0;
        }

        //Get the background color of the category based on the percent complete
        public String getColor() {
            if (percentComplete < 100.0 && percentComplete >= 0) {
                return 'background-color:#edaf9d;';
            }
            else {
                return '';
            }
        }
    }

    private Id testPlanId;

    private List<CategoryWrapper> answerLists;

    private List<SelectOption> options;
    private List<String> optionLabels;
    private List<String> categories;
    public String error {get; set;}
    public String popupMessage {get; set;}

    public List<CategoryWrapper> getAnswerLists() {
        return answerLists;
    }

    //The following 4 functions simplify the logic of changing a label as long as structure remains the same
	//This is the only place that the change needs to be made
    public static String getNALabel() {
    	return 'Does Not Apply';
    }
    
    public static String getNotStartedLabel() {
    	return 'Not Started';
    }
    
    public static String getInProgressLabel() {
    	return 'Reviewing';
    }
    
    public static String getCompletedLabel() {
    	return 'Completed';
    }
    
    //Constructor used by the visualforce page
    public QA_TPQuestionDetails (ApexPages.StandardController stdController) {
        testPlanId = stdController.getId();

        List<AnswerRow> answers;
        List<QA_Answer__c> answerList;
        Map<Id, AnswerRow> answerMap;

        answerLists = new List<CategoryWrapper>();
        answerMap = new Map<Id, AnswerRow>();

        //Construct the answer list
        for (String cata : getCategories()) {
            answerList = [Select a.Status__c, a.Question__r.Category__c, a.Question__r.Name, 
            					a.Question__r.More_Info__c, a.Question__r.URL__c, a.Question__c, 
            					a.Question__r.Question_Text__c 
            			From QA_Answer__c a 
            			where a.Test_Plan__c = :testPlanId 
            				and a.Question__r.Category__c = :cata];
            				
			Map<ID, QA_Question__c> default_test_cases = new Map<ID, QA_Question__c>([select id, (select id from Default_Test_Cases__r) 
				from QA_Question__c where category__c = :cata ]);
				
            answers = new List<AnswerRow>();
            for (QA_Answer__c answer : answerList) {
            	boolean hasDefaultTestCase = default_test_cases.get(answer.Question__c).default_test_cases__r.size() > 0;
                AnswerRow temp = new AnswerRow(answer, hasDefaultTestCAse);
                answers.add(temp);
                answerMap.put(answer.id, temp);
            }
            if (!answers.isEmpty())
                answerLists.add(new CategoryWrapper(cata, answers));
        }

        //Get all the comments for this test plan and add them to the correct answer
        for (QA_Comment__c comment : [select Comment_Text__c, Answer__c, Owner.Name, CreatedDate From QA_Comment__c where Answer__r.Test_Plan__c = :testPlanId]) {
            if (answerMap.containsKey(comment.Answer__c)) {
                answerMap.get(comment.Answer__c).comments.add(comment);
            }
        }
    }

    public boolean getHasQuestions() {
        return answerLists.size() > 0;
    }

    //Get the categoriy ids for the javascript to expand or collapse all
    //sections. This only returns categories that are displayed in the test plan
    public String getDelimitedCategories() {
        String cats = '';

        for(CategoryWrapper cw : getAnswerLists()) {
            cats += cw.category + '.section' + ';';
        }

        if (cats.length() > 1)
            cats = cats.substring(0, cats.length()-1);

        return cats;
    }

    //Overall completeness
    public Long getCategoryCompleteness() {
        Double completeCount = 0;
        Integer size = 0;

        for(CategoryWrapper cw : getAnswerLists()) {
            completeCount += answersProgress(cw.answers);
            size += answersProgressSize(cw.answers);
        }

        return computePercent(completeCount, size);
    }

    //Select options for the Status__c of an Answer__c. The labels are blank since the
    //labels are only displayed on the top of the table
    public List<SelectOption> getStatusOptions() {
        if (options == null) {
            options = new List<SelectOption>();
            Schema.DescribeFieldResult F = QA_Answer__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> status = F.getPicklistValues();

            for (Schema.PicklistEntry s : status) {
                options.add(new SelectOption(s.getLabel(),''));
            }
        }
        return options;
    }

    //Labels for the Status__c of an Answer__c to be displayed on the top of the page
    public List<String> getStatusLabels() {
        if (optionLabels == null) {
            optionLabels = new List<String>();
            Schema.DescribeFieldResult F = QA_Answer__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> status = F.getPicklistValues();

            for (Schema.PicklistEntry s : status) {
                optionLabels.add(s.getLabel());
            }
        }
        return optionLabels;
    }

    //Get all the Category__c values of Question__c
    public List<String> getCategories() {
        if (categories == null) {
            categories= new List<String>();
            Schema.DescribeFieldResult F = QA_Question__c.Category__c.getDescribe();
            List<Schema.PicklistEntry> status = F.getPicklistValues();

            for (Schema.PicklistEntry s : status) {
                categories.add(s.getLabel());
            }
        }
        return categories;
    }

    //Is there an editable row on the page?
    public boolean getIsEditable() {
        for (CategoryWrapper cw : answerLists) {
            for (AnswerRow wrapper : cw.answers) {
                if (wrapper.editable)
                    return true;
            }
        }
        return false;
    }

    //Save all rows that are editable.
    public void saveRows() {
        List<QA_Answer__c> updateList = new List<QA_Answer__c>();
        List<AnswerRow> answerRows = new List<AnswerRow>();
        Map<Id, QA_Comment__c> commentsToAdd = new Map<Id, QA_Comment__c>();

        for (CategoryWrapper cw : answerLists) {
            for (AnswerRow wrapper : cw.answers) {
                if (wrapper.editable) {
                    updateList.add(wrapper.answer);
                    answerRows.add(wrapper);

                    if (wrapper.commentHasText()) {
                        QA_Comment__c comment = new QA_Comment__c();
                        comment.Comment_Text__c = Pattern.compile('\n').matcher(wrapper.newComment).replaceAll('<BR />');
                        comment.Answer__c = wrapper.answer.id;

                        commentsToAdd.put(wrapper.answer.Id, comment);
                    }
                }
            }
        }
        try {
            update updateList;
            insert commentsToAdd.values();

            for (QA_Comment__c comment : [select Comment_Text__c, Answer__c, Owner.Name, CreatedDate from QA_Comment__c where Id in :commentsToAdd.values()]) {
                commentsToAdd.put(comment.Answer__c, comment);
            }
            for (AnswerRow wrapper : answerRows) {
                wrapper.editable = false;

                if (commentsToAdd.containsKey(wrapper.answer.id)) {
                    wrapper.comments.add(commentsToAdd.get(wrapper.answer.id));
                    wrapper.newComment = '';
                }

            }
        }
        catch (Exception e) {
            error = e.getMessage();
        }
    }

    public boolean getIsError() {
        return !(error == null || error == '');
    }

    //Revert all rows that are editable. (Cancel)
    public void revertRows() {
        for (CategoryWrapper cw : answerLists) {
            for (AnswerRow wrapper : cw.answers) {
                if (wrapper.editable) {
                    wrapper.revertStatus();
                }
            }
        }
        error = '';
    }

    //Make all rows editable
    public void editAll() {
        for (CategoryWrapper cw : answerLists) {
            for (AnswerRow wrapper : cw.answers) {
                wrapper.setEditable();
            }
        }
    }

    public static Double answersProgress(List<AnswerRow> answerList) {
        Double completeCount = 0;

        for(AnswerRow ar : answerList) {
            if (ar.answer.Status__c.equals(getCompletedLabel()))
                completeCount += 1;
        }

        return completeCount;
    }

    public static Integer answersProgressSize(List<AnswerRow> answerList) {
        Integer size = answerList.size();

        for(AnswerRow ar : answerList) {
            if (ar.answer.Status__c.equals(getNALabel()))
                size--;
        }
        return size;
    }

    public static Long computePercent(Double total, Integer size) {
        return size > 0 ? ((total/size) * 100).round() : -1;
    }

    public void doNothing() {}

    //Generate the page reference to add default test cases if at least one user story is associated with this test plan
    //and the question is not marked as completed, otherwise display a popup error
    public PageReference addDefaultTestCases(){
    	Id answerid = System.currentPageReference().getParameters().get('answerid');
    	QA_Answer__c answer = [select QA_Answer__c.Status__c from QA_Answer__c where id = :answerid];
        if([select Id from ADM_Work__c where ADM_Work__c.Test_Plan__c = :testPlanId].size() == 0) {
            popupMessage = 'You can only add default test cases when at least one user story has been associated with this test plan.';
            return null;
        }
        else if(answer.Status__c == getCompletedLabel()) {
            popupMessage = 'You have already added default test cases for this question.  If you wish to add more, you must first change the status of the question.';
            return null;
        }
        PageReference ref = Page.QA_TPAddDefaultStep1;
        ref.getParameters().put('answerid', answerid);
        return ref;
    }
    
    //Popup is displayed only if there is an error message to display
    public Boolean getDisplayPopup(){
    	return popupMessage != null && popupMessage != '';
    }
    
    //Clear the error message so that the popup closes
    public void closePopup(){
    	popupMessage = '';
    }
    
    //Apex Test helper methods
    //Create a new test plan
    public static QA_Test_Plan__c createTestPlan(String name) {
        QA_Test_Plan__c tp = new QA_Test_Plan__c();
        tp.Name = name;
        tp.Description__c = 'TestPlan';
        tp.Functional_Specification__c = 'TestPlanSpecs.com';
        tp.BugList__c = 'TestPlanBugs.com';
        insert(tp);
        return tp;
    }

    //Create a new question
    public static QA_Question__c createQuestion(String name, String category) {
        QA_Question__c question = new QA_Question__c();
        question.Question_Text__c = name;
        question.Category__c = category;
        insert(question);
        return question;
    }

    //Mark questions as obsolete so they answers don't get created durning test
    public static void clearQuestions() {
        List<QA_Question__c> questions = [select Obsolete__c, Category__c from QA_Question__c where Obsolete__c = false];
        List<QA_Question__c> updateQuestions = new List<QA_Question__c>();
        for (QA_Question__c question : questions) {
            question.Obsolete__c = true;
            question.Editable__c = true;
            updateQuestions.add(question);
            if (updateQuestions.size() == 20) {
                update updateQuestions;
                updateQuestions.clear();
            }
        }
        update updateQuestions;
    }

    //Apex Test

    //Test a test plan with no questions or answers associated with it
  
    /**
    * @testcaseID a0B20000009gnkPEAQ
    * @userstory a07B0000000DfNr
    * @hierarchy GUS.QaforceToGUS.Test Plan.Test Plan Completeness
    * @expectedResults testTPWithNoQuestions
    */

    public static testMethod void testTPWithNoQuestions() {
        clearQuestions();
        Test.startTest();
        //Create new test plan
        QA_Test_Plan__c tp = createTestPlan('TPQuestionDetail.testTPWithNoQuestions');
        ApexPages.standardController stdController = new ApexPages.standardController(tp);

        //Instantiate a new controller with all parameters in the page
        QA_TPQuestionDetails controller = new QA_TPQuestionDetails(stdController);

        System.assertEquals(false, controller.getHasQuestions());
        System.assertEquals('', controller.getDelimitedCategories());
        System.assertEquals(-1, controller.getCategoryCompleteness());
    }

    //Ensure that categories, options, and labels are being returns.

    /**
    * @testcaseID a0B20000009gnlVEAQ
    * @userstory  a07B0000000DfNr
    * @hierarchy GUS.QaforceToGUS.Test Plan.Test Plan Completeness
    * @expectedResults testTPOptionsAndLabels
    */
    public static testMethod void testTPOptionsAndLabels() {
        //Create new test plan
        QA_Test_Plan__c tp = createTestPlan('TPQuestionDetail.testTPWithNoQuestions');
        ApexPages.standardController stdController = new ApexPages.standardController(tp);

        //Instantiate a new controller with all parameters in the page
        QA_TPQuestionDetails controller = new QA_TPQuestionDetails(stdController);

        List<String> labels = controller.getStatusLabels();
        List<SelectOption> options = controller.getStatusOptions();

        //Options and labels must have the same size since they are comming from the same picklist
        System.assertEquals(options.size(), labels.size());

        //The labels and the values should be the same since they are comming from the same picklist
        for (Integer i = 0; i < options.size(); i++) {
            System.assertEquals('', options[i].getLabel());
            System.assertEquals(options[i].getValue(), labels[i]);
        }

        //Some categories should always be returned
        System.assertEquals(true, controller.getCategories().size() > 0);
    }

    //Test editing the questionnarie

 /**
    * @testcaseID a0B20000009fP7GEAU
    * @userstory a07B0000000DfNr
    * @hierarchy GUS.QaforceToGUS.Test Plan.Test Plan Completeness
    * @expectedResults All rows or sections of the test plan completeness should be edited
    */

    public static testMethod void testTPEditQuestions() {
        clearQuestions();
        Test.startTest();
        //Create new Questions
        QA_Question__c question1 = createQuestion('TPQuestionDetail.testTPEditQuestions.question1', 'Admin');
        QA_Question__c question2 = createQuestion('TPQuestionDetail.testTPEditQuestions.question2', 'Admin');
        QA_Question__c question3 = createQuestion('TPQuestionDetail.testTPEditQuestions.question3', 'Functionality');

        //Create new test plan
        QA_Test_Plan__c tp = createTestPlan('TPQuestionDetail.testTPWithNoQuestions');
        ApexPages.standardController stdController = new ApexPages.standardController(tp);

        //Instantiate a new controller with all parameters in the page
        QA_TPQuestionDetails controller = new QA_TPQuestionDetails(stdController);

        //There are questions in this test plan
        System.assertEquals(true, controller.getHasQuestions());
        System.assertEquals(0, controller.getCategoryCompleteness());
        System.assertEquals(false, controller.getIsEditable());

        //All questions are diaplayed and in default state
        List<CategoryWrapper> cw = controller.getAnswerLists();
        System.assertEquals(2, cw.size());
        System.assertEquals('Admin', cw.get(0).category);
        System.assertEquals('Functionality', cw.get(1).category);
        System.assertEquals(2, cw[0].answers.size());
        System.assertEquals(1, cw[1].answers.size());
        System.assertEquals('Admin.section;Functionality.section', controller.getDelimitedCategories());
        System.assertEquals(0, cw[0].percentComplete);

        AnswerRow adminRow1 = cw[0].answers[0];
        AnswerRow adminRow2 = cw[0].answers[1];
        AnswerRow functionalityRow1 = cw[1].answers[0];

        //Edit some row
        adminRow1.setEditable();
        System.assertEquals(true, controller.getIsEditable());
        adminRow2.setEditable();
        functionalityRow1.setEditable();
        System.assertEquals(true, controller.getIsEditable());

        //Change status of the editable rows
        String status = adminRow1.answer.Status__c;
        adminRow1.answer.Status__c = getInProgressLabel();
        System.assertEquals(0, cw[0].percentComplete);
        adminRow2.answer.Status__c = getCompletedLabel();
        System.assertEquals(50, cw[0].percentComplete);

        adminRow1.revertStatus();
        System.assertEquals(getNotStartedLabel(), adminRow1.answer.Status__c);
        System.assertEquals(50, cw[0].percentComplete);

        functionalityRow1.answer.Status__c = getNALabel();
        System.assertEquals(-1, cw[1].percentComplete);        
        System.assertEquals(50, controller.getCategoryCompleteness());        

        controller.revertRows();
        System.assertEquals(false, controller.getIsEditable());

        for (CategoryWrapper tempCw : cw) {
            for (AnswerRow row : tempCw.answers) {
                System.assertEquals(getNotStartedLabel(), row.answer.Status__c);
            }
        }

        System.assertEquals('background-color:#edaf9d;', cw[1].getColor());
        controller.editAll();
        System.assertEquals(true, controller.getIsEditable());
        functionalityRow1.answer.Status__c = getCompletedLabel();
        controller.SaveRows();
        System.assertEquals(false, controller.getIsEditable());
        System.assertEquals(100, cw[1].percentComplete);
        System.assertEquals('', cw[1].getColor());
        System.assertEquals(false, cw[1].getInProgress());
        System.assertEquals(33, controller.getCategoryCompleteness());
    }

    /**
    * @testcaseID a0B20000009gnlaEAA
    * @userstory a07B0000000DfNr
    * @hierarchy GUS.QaforceToGUS.Test Plan.Test Plan Completeness
    * @expectedResults testTPCompletenessPercentage
    */

    public static testMethod void testTPCompletenessPercentage() {
        //Ignore all other questions that exist
        clearQuestions();
        Test.startTest();

        //Create new Questions
        QA_Question__c question1 = createQuestion('TPQuestionDetail.testTPCompletenessPercentages.question1', 'Admin');
        QA_Question__c question2 = createQuestion('TPQuestionDetail.testTPCompletenessPercentages.question2', 'Functionality');
        QA_Question__c question3 = createQuestion('TPQuestionDetail.testTPCompletenessPercentages.question3', 'Upgrade Script');
        QA_Question__c question4 = createQuestion('TPQuestionDetail.testTPCompletenessPercentages.question4', 'Regression Testing');
        QA_Question__c question5 = createQuestion('TPQuestionDetail.testTPCompletenessPercentages.question5', 'Functionality');
        QA_Question__c question6 = createQuestion('TPQuestionDetail.testTPCompletenessPercentages.question6', 'Security');
        QA_Question__c question7 = createQuestion('TPQuestionDetail.testTPCompletenessPercentages.question7', 'Performance and System Testing');
        QA_Question__c question8 = createQuestion('TPQuestionDetail.testTPCompletenessPercentages.question8', 'Globalization');
        //Create new test plan
        QA_Test_Plan__c tp = createTestPlan('TPQuestionDetail.testTPCompletenessPercentages');
        ApexPages.standardController stdController = new ApexPages.standardController(tp);

        //Instantiate a new controller with all parameters in the page
        QA_TPQuestionDetails controller = new QA_TPQuestionDetails(stdController);

        System.assertEquals(0, controller.getCategoryCompleteness(),'->' + controller.getAnswerLists());

        for (CategoryWrapper cw : controller.getAnswerLists()) {
            for (AnswerRow ar : cw.answers) {
                ar.answer.Status__c = getNALabel();
            }
        }
        System.assertEquals(-1, controller.getCategoryCompleteness());
        //[ALEXIS] test failing wrong # System.assertEquals(-1, controller.getCategoryCompleteness());
        for (CategoryWrapper cw : controller.getAnswerLists()) {
            for (AnswerRow ar : cw.answers) {
                ar.answer.Status__c = getInProgressLabel();
            }
        }
        System.assertEquals(0, controller.getCategoryCompleteness());
        for (CategoryWrapper cw : controller.getAnswerLists()) {
            for (AnswerRow ar : cw.answers) {
                ar.answer.Status__c = getCompletedLabel();
            }
        }
        System.assertEquals(100, controller.getCategoryCompleteness());

        Integer i = 0;
        for (CategoryWrapper cw : controller.getAnswerLists()) {
            for (AnswerRow ar : cw.answers) {
                if (i < 2) {
                    ar.answer.Status__c = getInProgressLabel();
                    i++;
                }
                else if (i < 4) {
                    ar.answer.Status__c = getNALabel();
                    i++;
                }
                else break;
            }
        }
        System.assertEquals(Math.round(4*100/6.0), controller.getCategoryCompleteness());        
    }

    /**
    * @testcaseID a0B20000009fVaLEAU
    * @userstory a07B0000000DfNr
    * @hierarchy GUS.QaforceToGUS.Test Plan.Test Plan Completeness
    * @expectedResults User is able to add a comment to the Data Management section of the test plan completeness. The comment shows underneath the question/criteria for that section
    */

    public static testMethod void testTPQuestionComments() {
        clearQuestions();
        Test.startTest();
        //Create new Questions
        QA_Question__c question1 = createQuestion('TPQuestionDetail.testTPEditQuestions.question1', 'Admin');
        QA_Question__c question2 = createQuestion('TPQuestionDetail.testTPEditQuestions.question2', 'Admin');
        QA_Question__c question3 = createQuestion('TPQuestionDetail.testTPEditQuestions.question3', 'Functionality');

        //Create new test plan
        QA_Test_Plan__c tp = createTestPlan('TPQuestionDetail.testTPWithNoQuestions');
        ApexPages.standardController stdController = new ApexPages.standardController(tp);

        //Instantiate a new controller with all parameters in the page
        QA_TPQuestionDetails controller = new QA_TPQuestionDetails(stdController);

        List<CategoryWrapper> cw = controller.getAnswerLists();
        AnswerRow row = cw[0].answers[0];
        AnswerRow row1 = cw[0].answers[1];

        //Test all questions have no comments
        for (CategoryWrapper tempCw : cw) {
            for (AnswerRow tempRow : tempCw.answers) {
                System.assertEquals(0, tempRow.comments.size());
                System.assertEquals('', tempRow.newComment);
            }
        }

        //Create a comment
        row.setEditable();
        row.newComment = 'Some new comment in testTPQuestionComments() in QA_TPQuestionDetails';
        controller.SaveRows();

        //Ensure the comment is displayed right away
        System.assertEquals(1, row.comments.size());
        System.assertEquals('Some new comment in testTPQuestionComments() in QA_TPQuestionDetails', row.comments[0].Comment_Text__c);
        System.assertEquals(row.answer.id, row.comments[0].Answer__c);

        //Create a new comment
        row.setEditable();
        row.newComment = 'Some newer comment in testTPQuestionComments() in QA_TPQuestionDetails';
        controller.SaveRows();

        //Ensure the comments are displayed in the right order
        System.assertEquals(2, row.comments.size());
        System.assertEquals('Some new comment in testTPQuestionComments() in QA_TPQuestionDetails', row.comments[0].Comment_Text__c);
        System.assertEquals('Some newer comment in testTPQuestionComments() in QA_TPQuestionDetails', row.comments[1].Comment_Text__c);
        System.assertEquals('Some new comment in testTPQuestionComments() in QA_TPQuestionDetails', row.getCommentsInDesc()[1].Comment_Text__c);
        System.assertEquals('Some newer comment in testTPQuestionComments() in QA_TPQuestionDetails', row.getCommentsInDesc()[0].Comment_Text__c);

        //Cancel a row with a new comment
        row1.setEditable();
        row1.newComment = 'Some newerer comment for this specific test in testTPQuestionComments() in QA_TPQuestionDetails';
        controller.revertRows();

        //Ensure the comment was not created
        System.assertEquals(0, row1.comments.size());
        System.assertEquals('', row1.newComment);
        System.assertEquals(true, [select Comment_Text__c from QA_Comment__c where Answer__c = :row1.answer.id].isEmpty());

        //Create multiple comments at once
        controller.editAll();
        row.newComment = 'Comment at the same time in testTPQuestionComments() in QA_TPQuestionDetails';
        row1.newComment = 'Comment at the same time in testTPQuestionComments() in QA_TPQuestionDetails';
        controller.SaveRows();

        //Ensure both comments are created
        System.assertEquals(3, row.comments.size());
        System.assertEquals(1, row1.comments.size());

        //Create a comment without editing the row
        row.newComment = 'Create comment without editing tow in testTPQuestionComments() in QA_TPQuestionDetails';
        row.saveComment();

        //Ensure the comment was created
        System.assertEquals(4, row.comments.size());
        System.assertEquals(1, row1.comments.size());

        //Create a comment without editing the row
        row.newComment = 'cancel comment without editing tow in testTPQuestionComments() in QA_TPQuestionDetails';
        row.cancelComment();

        //Ensure the comment was created
        System.assertEquals(4, row.comments.size());
        System.assertEquals('', row.newComment);
        System.assertEquals(1, row1.comments.size());

        //Save rows with a comment being added on a row not being edited
        String commentText = 'This is the comment being added in testTPQuestionComments() in QA_TPQuestionDetails';
        row.newComment = commentText;
        row1.setEditable();
        controller.saveRows();

        //Ensure the comment was not created
        System.assertEquals(4, row.comments.size());
        System.assertEquals(commentText, row.newComment);
        System.assertEquals(1, row1.comments.size());
    }

    /**
    * @testcaseID a0B20000009fVaKEAU
    * @userstory a07B0000000DfNr 
    * @hierarchy GUS.QaforceToGUS.Test Plan.Test Plan Completeness
    * @expectedResults The following Data Management questions/criterion show with comments:                                                   
    * Most features will be required to work for org migration, sandbox copy, weekly export, and maybe imports. If your feature will be implemented for these data management 
    * tools there will be required testing.                     
    * Does the feature allow mass actions such as transfer, insert, mass mail etc?                                                                                                                                                                                                     
    * The radio buttons show with the following selections: Does not apply, Not Started, Under Consideration, Considered
    */

    public static testMethod void testTPDetailPageWithComments() {
        clearQuestions();
        Test.startTest();
        //Create new Questions
        QA_Question__c question3 = createQuestion('TPQuestionDetail.testTPEditQuestions.question3', 'Functionality');

        //Create new test plan
        QA_Test_Plan__c tp = createTestPlan('TPQuestionDetail.testTPWithNoQuestions');

        QA_Answer__c ans = [Select Id, Test_Plan__c, Question__r.Category__c from QA_Answer__c where Test_Plan__c = :tp.id and Question__r.Category__c = 'Functionality'][0];
        QA_Comment__c comment = new QA_Comment__c();
        comment.Comment_Text__c = 'A comment to see if existing comments show up';
        comment.Answer__c = ans.id;
        insert comment;

        ApexPages.standardController stdController = new ApexPages.standardController(tp);

        //Instantiate a new controller with all parameters in the page
        QA_TPQuestionDetails controller = new QA_TPQuestionDetails(stdController);

        System.assertEquals('A comment to see if existing comments show up', controller.getAnswerLists()[0].answers[0].comments[0].Comment_Text__c);
    }
    
    public static testMethod void testDefaultTestCases() {
    	//Setup a test plan and 1 default test case for one of its questions
    	clearQuestions();
    	QA_Question__c question = createQuestion('Setup Audit Trail Test', 'Admin');
        QA_Test_Plan__c testPlan = createTestPlan('TestPlan');
        QA_Hierarchy__c hierarchy = new QA_Hierarchy__c();
        hierarchy.Name = 'Default Test Plan';
        hierarchy.Depth__c = 0;
        insert(hierarchy);
        QA_Test_Case__c testCase = new QA_Test_Case__c();
        testCase.Hierarchy__c = 'Default Test Plan.Admin.Setup Audit Trail Test';
        testCase.Brief_Description__c = 'Test';
        testCase.Priority__c = 'Medium';
        insert(testCase);
        QA_Default_Test_Case__c defaultTC = new QA_Default_Test_Case__c();
        defaultTC.Question__c = question.id;
        defaultTC.Test_Case__c = testCase.id;
        insert(defaultTC);
        
        //Instantiate a new controller with parameters
        Id answerid = [select Id from QA_Answer__c where Test_Plan__c = :testPlan.Id].Id;
        PageReference pageRef = Page.QA_TPQuestionDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.standardController stdController = new ApexPages.standardController(testPlan);
        QA_TPQuestionDetails controller = new QA_TPQuestionDetails(stdController); 
        
        Test.startTest();
        //Try adding default test cases with user story error to test popup message
        AnswerRow defaultAnswer = controller.answerLists.get(0).answers.get(0);
        System.assertEquals(true, defaultAnswer.getHasDefaultTestCases());
        System.assertEquals(false, controller.getDisplayPopup());
        pageRef.getParameters().put('answerid', answerid);
        System.assert(controller.addDefaultTestCases() == null);
        System.assertEquals(true, controller.getDisplayPopup());
        controller.closePopup();
        System.assertEquals(false, controller.getDisplayPopup());
        
        //Try adding default test cases with completed status error to test popup message
        ADM_Work__c userStory = QA_TPAddDefault.createUserStory('new story', testPlan);
        defaultAnswer.answer.Status__c = getCompletedLabel();
        update(defaultAnswer.answer);
        System.assert(controller.addDefaultTestCases() == null);
        System.assertEquals(true, controller.getDisplayPopup());
        controller.closePopup();
        System.assertEquals(false, controller.getDisplayPopup());
        
        //Try adding default test cases successfully
        defaultAnswer.answer.Status__c = getNotStartedLabel();
        update(defaultAnswer.answer);
        
        String qualifiedPageName = (ADM_ConstantsSingleton.getInstance().getNameSpace() + 'qa_tpadddefaultstep1').toLowerCase();   
        System.assertEquals('/apex/'+qualifiedPageName+'?answerid=' + answerid, controller.addDefaultTestCases().getUrl());
        System.assertEquals(false, controller.getDisplayPopup());
        Test.stopTest();
    }    
}