@isTest
public class ADM_WorkPanelTests{
    public static testMethod void testGetWorkPanelViewPreference() {
    	User user = ADM_WorkUser.createTestUser();
        System.runAs(user){ 
            
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.WorkPanelViewPreference__c = true;
            upsert preferences;
            
            ADM_WorkRemoteActionsExtension controller = new ADM_WorkRemoteActionsExtension();
            
            System.assertEquals(true, controller.getWorkPanelViewPreference(), 'Expected the WorkPanelViewPreference__c property to match that of the User Preference');
        }
    }
    
    public static testMethod void testSetWorkPanelViewPreference() {
    	User user1 = ADM_WorkUser.createTestUser();
        System.runAs(user1){
            
            //create a user preference
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.WorkPanelViewPreference__c = true;
            upsert preferences;
            
            //set the preference to false
            ADM_WorkRemoteActionsExtension.setWorkPanelViewPreference(false);
            
            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).WorkPanelViewPreference__c, 'Expected setWorkPanelViewPreference to change the User Preference');
        }
    }
}