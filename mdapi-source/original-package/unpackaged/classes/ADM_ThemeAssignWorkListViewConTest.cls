@isTest
public class ADM_ThemeAssignWorkListViewConTest{

    private static final String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
	@isTest
    public static void testGetWorkItemsReturnsThemeWorkWithNoSOSL() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme('Test');
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');
        insert works;
        
        assignTheme(works.get(0).Id, theme.Id);
        
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aTheme = theme;
        con.aPageSize = 10;
        
        List<ADM_ThemeAssignWorkListViewController.WorkWrapper> wws = con.getWorkItems();
        System.assert(!con.getHasMoreThanOnePage());
        System.assertEquals(1, wws.size());
        System.assertEquals(works.get(0).Id, wws.get(0).work.Id);
    }
    
    @isTest
    public static void testForResetWorkWithSetTheme() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme('Test');
        ADM_Theme__c theme2 = ADM_ThemeUtils.createTestTheme('Test2');
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');
        insert works;
        
        assignTheme(works.get(0).Id, theme.Id);
        assignTheme(works.get(1).Id, theme2.Id);
        
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aTheme = theme;
        con.aPageSize = 10;
        
        List<ADM_ThemeAssignWorkListViewController.WorkWrapper> wws = con.getWorkItems();
        System.assertEquals(1, wws.size());
        System.assertEquals(works.get(0).Id, wws.get(0).work.Id);
        
        con.aTheme = theme2;
        
		wws = con.getWorkItems();
        System.assertEquals(1, wws.size());
        System.assertEquals(works.get(1).Id, wws.get(0).work.Id);        
    }
    
    @isTest
    public static void testGetWorkItemsReturnsThemeWorkWithSOSL() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme('Test');
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');
        works.get(1).Subject__c = 'My SuperTest';
        insert works;
        
        assignTheme(works.get(1).Id, theme.Id);
        
        Test.setFixedSearchResults(new Id[]{works.get(1).Id});
        
        test.startTest();
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aTheme = theme;
        con.aQuery = 'FIND {SuperTest} IN ALL FIELDS RETURNING '+ nameSpacePrefix + 'ADM_Work__c(' + ADM_ThemeAssignWorkListViewController.fields + ')';
        con.aPageSize = 10;
        
        List<ADM_ThemeAssignWorkListViewController.WorkWrapper> wws = con.getWorkItems();
        
        test.stopTest();
        
        System.assert(!con.getHasMoreThanOnePage());
        System.assertEquals(1, wws.size());
        System.assertEquals(works.get(1).Id, wws.get(0).work.Id);
    }
    
    @isTest
    public static void testGetWortWithSOSLNoResults() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme('Test');
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');
        insert works;
        
        assignTheme(works.get(1).Id, theme.Id);
        
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aTheme = theme;
        con.aQuery = 'FIND {SuperTest} IN ALL FIELDS RETURNING '+ nameSpacePrefix + 'ADM_Work__c(' + ADM_ThemeAssignWorkListViewController.fields + ')';
        con.aPageSize = 10;
        
        List<ADM_ThemeAssignWorkListViewController.WorkWrapper> wws = con.getWorkItems();
        
        ApexPages.Message m = ApexPages.getMessages().get(0);
        System.assertEquals(ApexPages.Severity.INFO, m.getSeverity());
		System.assertEquals('No matching work records', m.getSummary());
        System.assertEquals(0, wws.size());
    }
    
    @isTest
    public static void testGetWorkItemsExceptionWithBadSOSL() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme('Test');
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');
        insert works;
        
        assignTheme(works.get(1).Id, theme.Id);
        
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aTheme = theme;
        con.aQuery = 'FIND BAD IN ALL FIELDS RETURNING';
        con.aPageSize = 10;
        ApexPages.StandardSetController setCon = con.workList;
            
        ApexPages.Message m = ApexPages.getMessages().get(0);
        System.assertEquals(ApexPages.Severity.FATAL, m.getSeverity());
        System.assert(setCon == null);
    }
    
    @isTest
    public static void testPaging() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme('Test');
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');
        insert works;
        
        assignTheme(works.get(0).Id, theme.Id);
        assignTheme(works.get(1).Id, theme.Id);
        
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aTheme = theme;
        con.aPageSize = 1;
        
        List<ADM_ThemeAssignWorkListViewController.WorkWrapper> wws = con.getWorkItems();
        System.assert(con.getHasMoreThanOnePage());
        System.assertEquals(1, wws.size());
        System.assertEquals(works.get(0).Id, wws.get(0).work.Id);
        
        con.workList.next();
        
        wws = con.getWorkItems();
        System.assertEquals(1, wws.size());
        System.assertEquals(works.get(1).Id, wws.get(0).work.Id);
    }
    
    @isTest
    public static void testUpdateAll() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme('Test');
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');
        insert works;
        
        assignTheme(works.get(1).Id, theme.Id);
        
        Test.setFixedSearchResults(new Id[]{works.get(0).Id,works.get(1).Id});
        
        test.startTest();
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aTheme = theme;
        con.aQuery = 'FIND {SuperTest} IN ALL FIELDS RETURNING '+ nameSpacePrefix + 'ADM_Work__c(' + ADM_ThemeAssignWorkListViewController.fields + ')';
        con.aPageSize = 10;
        //We need to initialixe the currently displayed before we can update all
        List<ADM_ThemeAssignWorkListViewController.WorkWrapper> wws = con.getWorkItems();
        System.assertEquals(1, [SELECT Id FROM ADM_Theme_Assignment__c].size());
        con.changeAll();
        System.assertEquals(0, [SELECT Id FROM ADM_Theme_Assignment__c].size());
        con.selectedAll = true;
        con.changeAll();
        System.assertEquals(2, [SELECT Id FROM ADM_Theme_Assignment__c].size());
        test.stopTest();
    }
    
    @isTest
    public static void testUpdateSingle() {
        ADM_Theme__c theme = ADM_ThemeUtils.createTestTheme('Test');
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(1, 'User Story');
        insert works;
        
        Test.setFixedSearchResults(new Id[]{works.get(0).Id});
        
        test.startTest();
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aTheme = theme;
        con.aQuery = 'FIND {SuperTest} IN ALL FIELDS RETURNING '+ nameSpacePrefix + 'ADM_Work__c(' + ADM_ThemeAssignWorkListViewController.fields + ')';
        con.aPageSize = 10;
        
        List<ADM_ThemeAssignWorkListViewController.WorkWrapper> wws = con.getWorkItems();
        System.assertEquals(0, [SELECT Id FROM ADM_Theme_Assignment__c].size());
        wws.get(0).hasTheme = true;
        con.updateAssignedThemes();
        System.assertEquals(1, [SELECT Id FROM ADM_Theme_Assignment__c].size());
        wws.get(0).hasTheme = false;
        con.updateAssignedThemes();
        System.assertEquals(0, [SELECT Id FROM ADM_Theme_Assignment__c].size());
        
        test.stopTest();
    }
    
    @isTest
    public static void testSetBackgroundColorConvertsToCSS() {
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
        con.aBackgroundColor = '#fff';
		System.assertEquals('background:#fff;', con.aBackgroundColor);
    }
    
    @isTest
    public static void testLabel() {
        ADM_ThemeAssignWorkListViewController con = new ADM_ThemeAssignWorkListViewController();
		System.assert(!con.getHasLabel());
        con.aLabel = 'test';
        System.assert(con.getHasLabel());
    }
    
    private static void assignTheme(Id workId, Id themeId) {
        ADM_Theme_Assignment__c tm = new ADM_Theme_Assignment__c();
        tm.Work__c = workId;
        tm.Theme__c = themeId;
        insert tm;
    }
    
}