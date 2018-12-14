public class ADM_Case{
    private static final String FIELD_NAMES = 'a.Work__c, a.SystemModstamp, a.OwnerId, a.Name, a.LastModifiedDate, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedById, a.Cases_Link__c, a.Case_Number__c, a.Case_ID__c, a.Case_ID_Set__c, a.Account_Stage__c';
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_FROM = 'from ADM_Case__c a';
	private static User user {
        get {
            if(user == null) {
                user = ADM_WorkUser.createTest62Orguser();
            }
            return user;
		}
		set;
	}

    //Just adding this in here for now to allow for this class to serve a double duty as the controller to get the information regarding the number of cases for a work record on a page layout.
    public ADM_Case(ApexPages.StandardController stdController){}

    public static Integer getRecordCount(String work){
        List<ADM_Case__c> org62Cases = getRecords(work);
        return org62Cases.size();
    }

    public static List<ADM_Case__c> getRecords(String workId){
        String soql = SQL_SELECT + SQL_FROM + ' where Work__c = \'' + workId + '\'';
        List<ADM_Case__c> org62Cases = Database.query(soql);
        return org62Cases;
    }

    public static void save( ADM_Case__c admCase){
        Database.insert( admCase );
    }


    private static testMethod void testGetRecordCount() {
        ADM_Case__c tcase = createTestCase();
        Integer recCount = getRecordCount(tcase.Work__c);
        System.assertEquals(1, recCount);
    }

    private static testMethod void testSave() {
        System.runAs(user) {
            ADM_Case__c tcase = new ADM_Case__c();
            tcase.Case_Number__c = 'New-Test-Number-123456';
            //create work to relate to this case
            ADM_Work__c  work = ADM_Work.createTestWork();
            tcase.Work__c = work.id;
            save(tcase);
            System.assertEquals(1, [ Select count() From ADM_Case__c Where id = :tcase.id]);
       }
    }

    public static ADM_Case__c createTestCase() {
        ADM_Case__c newCase = new ADM_Case__c();
        System.runAs(user) {
            newCase.Case_Number__c = '123456';
            //create work to relate to this case
            ADM_Work__c  work = ADM_Work.createTestWork();
            newCase.Work__c = work.id;
            Database.insert(newCase);
        }
        return newCase;
    }

    public static ADM_Case__c createTestCaseWithAccountStage(String accountStage) {
        ADM_Case__c newCase = new ADM_Case__c();
        System.runAs(user) {
            newCase.Case_Number__c = '123456';
            //create work to relate to this case
            ADM_Work__c  work = ADM_Work.createTestWork();
            newCase.Account_Stage__c = accountStage;
            newCase.Work__c = work.id;
            Database.insert(newCase);
        }
        return newCase;
    }

    public static List<ADM_Case__c> createTestCases(Integer amount) {
        List<ADM_Case__c> cases = new List<ADM_Case__c>();
        for(Integer i =0; i < amount; i++) {
            cases.add(createTestCase());
        }
        
        return cases;

    }
    
    public static String createCaseSummary(ADM_Case__c newCase) {
    	String parentAccountName = (ADM_TextUtils.isNull(newCase.Parent_Account_Name__c)) ? '' : '(' + newCase.Parent_Account_Name__c + ')';
    	String accountName = (ADM_TextUtils.isNull(newCase.Account_Name__c)) ? '' :  newCase.Account_Name__c;
    	String summary = 'Added related 62 Org Case:\n\n' + 
    					 'Case Subject:' + newCase.Case_Subject__c	+ '\n' +
    					 'Account:' + accountName + ' ' + parentAccountName + '\n' +
    					 'Case:' + newCase.Case_Number__c + ' ' + '(https://org62.my.salesforce.com/' + newCase.Case_ID__c + ')\n\n';
    					 
    	return summary;				 
    	
    }
}