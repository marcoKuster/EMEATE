@isTest
public with sharing class ADM_CaseRelatedListControllerTests {
	

	@isTest
	public static void testGetCasesRelatedToWork(){
		ADM_CaseRelatedListController controller = new ADM_CaseRelatedListController();
		controller.workId = ADM_Work.createTestBug().id;
		controller.packagedOrg = true;
		Case case1 = new Case();
		case1.Subject = 'Case1';
        case1.ADM_Work__c = controller.workId;
		insert case1;
		List<Case> cases = controller.getCasesRelatedToWork();
		System.assertEquals(1, cases.size());
	}

	@isTest
	public static void testNewCase(){
		ADM_CaseRelatedListController controller = new ADM_CaseRelatedListController();
		PageReference pr = controller.newCase();
		System.assertEquals(pr,null,'Returns null as expected for method call');
	}
}