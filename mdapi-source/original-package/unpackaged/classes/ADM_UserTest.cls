@isTest
public class ADM_UserTest{

	@isTest
	public static void testLaneSettingsSave() {
		System.assert( !ADM_User.getUserLaneScrollingPreference());
		ADM_User.setUserLaneScrollingPreference(true);
		System.assert( ADM_User.getUserLaneScrollingPreference() );
	}

	@isTest
	public static void testKanbanCardPreferences() {

		ADM_KanbanPreferences preference1 = new ADM_KanbanPreferences();
		preference1.setUseColorCoding(true);
		preference1.setShowNumberOfDaysInColumn(true);
		preference1.setShowNumberOfTasks(true);
		preference1.setShowNumberOfPosts(true);
		preference1.setShowPriority(true);
		preference1.setShowScheduledBuild(true);
		preference1.setShowStoryPoints(true);
		preference1.setShowColoredSubjects(true);
		preference1.setShowWorkID(true);
		preference1.setShowColoredSubjects(true);
		preference1.setShowRecordTypeIcon(true);
		preference1.setShowQE(true);

		ADM_User.saveKanbanWorkCardPreferences(preference1);

		ADM_User_Preferences__c preference2 = ADM_User.getCurrentUserPreference();

		Boolean truth = true;
		System.assertEquals( truth, preference2.get( 'UseColorCoding__c') );
		System.assertEquals( truth, preference2.get( 'ShowNumberOfDaysInColumn__c'));
		System.assertEquals( truth, preference2.get( 'ShowNumberOfTasks__c'));
		System.assertEquals( truth, preference2.get( 'ShowNumberOfPosts__c'));
		System.assertEquals( truth, preference2.get( 'ShowPriority__c'));
		System.assertEquals( truth, preference2.get( 'ShowScheduledBuild__c'));
		System.assertEquals( truth, preference2.get( 'ShowStoryPoints__c'));
		System.assertEquals( truth, preference2.get( 'ShowColoredSubjects__c'));
		System.assertEquals( truth, preference2.get( 'ShowWorkID__c'));
		System.assertEquals( truth, preference2.get( 'ShowRecordTypeIcon__c'));
		System.assertEquals( truth, preference2.get( 'ShowQE__c'));

	}

}