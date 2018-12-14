@isTest
private class QA_TreeLibraryTest {

	testMethod static void loadBranchWithTestCase() {
		QA_TreeLibrary tl = loadTreeLibrary(new QA_Test_Case__c(brief_description__c='this is a test', Is_Obsolete__c=false, order__c=1));
		System.assert(tl.tree.curBranch.size()==1);
	} 
	
	testMethod static void loadBranchWithTestCaseOrderNull() {
		QA_TreeLibrary tl = loadTreeLibrary(new QA_Test_Case__c(brief_description__c='this is a test', Is_Obsolete__c=false));
		System.assert(tl.tree.curBranch.size()==1);
	}
	
	static QA_TreeLibrary loadTreeLibrary(QA_Test_Case__c tc) {
		QA_TreeLibrary tl = new QA_TreeLIbrary();
		List<QA_Test_Case__c> tcs = new List<QA_Test_Case__c>();
		tcs.add(tc);
		tl.addTestCasesToBranch(tcs, 'All');
		return tl;		
	} 
}