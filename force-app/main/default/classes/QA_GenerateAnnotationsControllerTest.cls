public class QA_GenerateAnnotationsControllerTest {

	public static testMethod void testWrappingTest(){
		QA_Hierarchy__c h = new QA_Hierarchy__c(Name = 'TestHierarchy', Count__c = 1, Depth__c = 0, Full_Path__c = 'TestHierarchy');
		QA_Test_Case__c tc = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Expected_Results__c = 'No Failure', Steps_to_Reproduce__c = 'My Description', Priority__c = 'Low', Brief_Description__c = 'Sample Test');
		ADM_Work__c u = ADM_Work.createTestWork('User Story');
		insert h;
		insert tc;
				
		QA_GenerateAnnotationsController.TestCaseAnnotation tca = getTestCaseAnnotation(tc);
		System.assert(tca.wrapForJavadoc('THIS IS A TEST STRING') != null, 'test that the text is not wrapped');
		String testLongString = '';
		for (integer i = 0; i < 100; i++){
			testLongString += 'This is a really long string. ';	
		}
		System.assert(testLongString.indexOf('\n') == -1, 'test that there are no linebreaks yet');
		System.assert(tca.wrapForJavadoc(testLongString).indexOf('\n') > 0, 'test that there was a linebreak');
	}

	private static QA_GenerateAnnotationsController.TestCaseAnnotation getTestCaseAnnotation(QA_Test_Case__c tc) {
		QA_GenerateAnnotationsController ga = new QA_GenerateAnnotationsController();
		ga.parseTestCases(tc.Id+';');
		return ga.testCaseAnnotations.get(0);		
	}
	
	public static testMethod void testNull(){
		QA_GenerateAnnotationsController ga = new QA_GenerateAnnotationsController();
		System.assert(ga.returnNull() == null, 'make sure return null actually returns null');
	}
	
/**
    *@testcaseID a0B20000009e7ivEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults An error message displays as follows: "Error: Value does not exist or is not a User Story"
*/
	public static testMethod void testInvalidTestCaseString(){
		System.currentPageReference().getParameters().put('cases', 'invalidId;null');
		QA_GenerateAnnotationsController ga = new QA_GenerateAnnotationsController();
		System.assert(ga.testCaseAnnotations.size() == 0);
	}
	
/**
    *@testcaseID a0B20000009e7jAEAQ
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults An error message displays as follows: "You must enter a value"
*/
	public static testMethod void testBlankQueryString(){
		System.currentPageReference().getParameters().put('cases', '');
		QA_GenerateAnnotationsController ga = new QA_GenerateAnnotationsController();
		System.assert(ApexPages.getMessages().size() == 1);
		
	}
	
/**
    *@testcaseID a0B20000009e7kmEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults Hierarchy is saved correctly in the annotation
*/
	public static testMethod void testTrailingPeriod(){
		QA_Hierarchy__c h = new QA_Hierarchy__c(Name = 'TestHierarchy', Count__c = 1, Depth__c = 0, Full_Path__c = 'TestHierarchy');
		QA_Test_Case__c tc = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Expected_Results__c = 'No Failure', Steps_to_Reproduce__c = 'My Description', Priority__c = 'Low', Brief_Description__c = 'Sample Test');
		ADM_Work__c u = ADM_Work.createTestWork('User Story');
		insert h;
		insert tc;
		
		QA_GenerateAnnotationsController.TestCaseAnnotation tca = getTestCaseAnnotation(tc);
		System.assert(tca.enforceTrailingPeriod('I need a period').equals('I need a period.'), 'test valid trailing period');
		System.assert(tca.enforceTrailingPeriod('I dont need a period.').equals('I dont need a period.'), 'test valid trailing period');
	}
	
/**
    *@testcaseID a0B20000009e7iwEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults An error message displays as follows: "Error: Value does not exist or is not a User Story"
*/
/**
    *@testcaseID a0B20000009e7ixEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults An error message displays as follows: "Error: Value does not exist or is not a User Story"
*/
/**
    *@testcaseID a0B20000009e7iyEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults An error message displays as follows: "Error: Value does not exist or is not a User Story"
*/

	public static testMethod void testNoUserStory(){
		QA_Hierarchy__c h = new QA_Hierarchy__c(Name = 'TestHierarchy', Count__c = 1, Depth__c = 0, Full_Path__c = 'TestHierarchy');
		QA_Test_Case__c tc = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Expected_Results__c = 'No Failure', Steps_to_Reproduce__c = 'My Description', Priority__c = 'Low', Brief_Description__c = 'Sample Test');
		insert h;
		insert tc;
		
		QA_GenerateAnnotationsController.TestCaseAnnotation tca = getTestCaseAnnotation(tc);
		System.assert(tca.getUserStoryName() == null, 'make sure there is no user story name');
		
	}
	
	/**
    *@testcaseID a0B20000009e7izEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults User is taken to the test case page
*/
	public static testMethod void testWithTestCases(){
		QA_Hierarchy__c h = new QA_Hierarchy__c(Name = 'TestHierarchy', Count__c = 1, Depth__c = 0, Full_Path__c = 'TestHierarchy');
		insert h;
		
		QA_Test_Case__c tc = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Brief_Description__c = 'Sample Test');
		insert tc;
		System.currentPageReference().getParameters().put('cases', tc.Id);
		
		QA_GenerateAnnotationsController ga = new QA_GenerateAnnotationsController();
		System.assert(ga.testCaseAnnotations != null);
		System.assert(ga.testCaseAnnotations.size() == 1);
		
	}
	
/**
    *@testcaseID a0B20000009e7knEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults An annotation gets generated per test case selected
*/
	public static testMethod void testWithMultipleTestCases(){
		QA_Hierarchy__c h = new QA_Hierarchy__c(Name = 'TestHierarchy', Count__c = 1, Depth__c = 0, Full_Path__c = 'TestHierarchy');
		insert h;
		
		QA_Test_Case__c tc = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Brief_Description__c = 'Sample Test');
		QA_Test_Case__c tc2 = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Brief_Description__c = 'Sample Test2');
		insert tc;
		insert tc2;
		System.currentPageReference().getParameters().put('cases', tc.Id+';'+tc2.Id);
		
		QA_GenerateAnnotationsController ga = new QA_GenerateAnnotationsController();
		System.assert(ga.testCaseAnnotations != null);
		System.assert(ga.testCaseAnnotations.size() == 2);

	}
		
/**
    *@testcaseID a0B20000009e7iuEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults An annotation gets generated. Example is as follows:                      * Brief description
												* 
												* @userStory W-065490
												* @hierarchy Hierarchy1.hierarchy2.hierarchy3
												* @priority High
												* @expectedResults My expected Results
												
*/
	public static testMethod void testAnnotationSingleTestCase(){
		QA_Hierarchy__c h = new QA_Hierarchy__c(Name = 'TestHierarchy', Count__c = 1, Depth__c = 0, Full_Path__c = 'TestHierarchy');
		QA_Test_Case__c tc = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Expected_Results__c = 'No Failure', Steps_to_Reproduce__c = 'My Description', Priority__c = 'Low', Brief_Description__c = 'Sample Test');
		ADM_Work__c u = ADM_Work.createTestWork('User Story');
		insert h;
		insert tc;
		
		QA_Test_Execution__c te = new QA_Test_Execution__c(User_Story__c = u.Id, Test_Case__c = tc.Id, Assignee__c = UserInfo.getUserId());
		insert te;
		
		QA_GenerateAnnotationsController.TestCaseAnnotation tca = getTestCaseAnnotation(tc);
		System.assert(tca.canRender(), 'annotation is valid, make sure we can render');
		System.assert(tca.getAnnotation() != null, 'Make sure that there is an annotation returned');
		
	}
/**
    *@testcaseID a0B20000009e7koEAA
    *@hierarchy GUS.QaforceToGUS.Generate Annotations.New Annotation
    *@userstory a07B0000000DfN4
    *@expectedResults An annotation gets generated as follows. Example is as follows:                   
													   * @userStory W-065490
													   * @hierarchy Hierarchy1.hierarchy2.hierarchy3
													
*/
	public static testMethod void testAnnotationWithPartialData(){
		QA_Hierarchy__c h = new QA_Hierarchy__c(Name = 'TestHierarchy', Count__c = 1, Depth__c = 0, Full_Path__c = 'TestHierarchy');
		QA_Test_Case__c tc = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Brief_Description__c = 'Sample Test');
		insert h;
		insert tc;

		QA_GenerateAnnotationsController.TestCaseAnnotation tca = getTestCaseAnnotation(tc);
		System.assert(tca.canRender() == false);
		System.assert(tca.getUserStoryName() == null);
		System.assert(tca.getAnnotation().equals(''), 'Make sure the annotation is blank');
	}
	
	public static testMethod void addManyTestCasesForGeneration(){
		QA_Hierarchy__c h = new QA_Hierarchy__c(Name = 'TestHierarchy', Count__c = 1, Depth__c = 0, Full_Path__c = 'TestHierarchy');
		insert h;
		
		QA_Test_Case__c tc = new QA_Test_Case__c(Hierarchy__c = h.Name + '.TestMeTest', Brief_Description__c = 'Sample Test');
		insert tc;
		
		QA_GenerateAnnotationsController ga = new QA_GenerateAnnotationsController();
		integer soqllimit = Limits.getLimitQueries();
		
		for(integer i=0;i<soqllimit;i++) {
			ga.addTestCase(tc);
		}
		System.assert(ga.testCaseAnnotations != null);
		System.assert(ga.testCaseAnnotations.size() == soqllimit);
		
	}	

}