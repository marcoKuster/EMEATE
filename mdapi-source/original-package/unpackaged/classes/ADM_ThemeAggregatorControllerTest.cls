@isTest
public class ADM_ThemeAggregatorControllerTest{
    @isTest
    public static void testGetThemeWithId() {
        ADM_Theme__c expected = ADM_ThemeUtils.createTestTheme('Test');
        
        System.PageReference page = ApexPages.currentPage();
        page.getParameters().put('id', expected.Id);
        
        ADM_ThemeAggregatorController conn = new ADM_ThemeAggregatorController();
        ADM_Theme__c actual = conn.getTheme();
        
        System.assertEquals(expected.Id, actual.Id);
    }
    
    @isTest
    public static void testGetThemeWithoutId() {
        ADM_ThemeAggregatorController conn = new ADM_ThemeAggregatorController();
        ADM_Theme__c actual = conn.getTheme();
        
        System.assertEquals(null, actual);
        System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages().get(0).getSeverity());
    }
    
    @isTest
    public static void testGetThemeWithoutBadId() {
        ADM_Theme__c expected = ADM_ThemeUtils.createTestTheme('Test');
        
        System.PageReference page = ApexPages.currentPage();
        page.getParameters().put('id', expected.Id + 'd');
        
		ADM_ThemeAggregatorController conn = new ADM_ThemeAggregatorController();
        ADM_Theme__c actual = conn.getTheme();
        
        System.assertEquals(null, actual);
        System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages().get(0).getSeverity());
    }
}