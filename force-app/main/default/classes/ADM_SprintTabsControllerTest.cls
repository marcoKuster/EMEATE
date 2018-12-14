@IsTest
public class ADM_SprintTabsControllerTest {

	@IsTest
	static void testGetChatterViewPreference() {
        User user = ADM_WorkUser.createTestUser();
        System.runAs(user){ 
            
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowChatterOnVirtualWall__c = true;
            upsert preferences;
            
            ADM_SprintTabsController controller = new ADM_SprintTabsController();
            
            System.assertEquals(true, controller.getChatterViewPreference(), 'Expected the ShowChatterOnVirtualWall property to match that of the User Preference');
        }
    }
    
    @IsTest
    static void testSetChatterPreference() {
        User user1 = ADM_WorkUser.createTestUser();
        System.runAs(user1){
            
            //create a user preference
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowChatterOnVirtualWall__c = true;
            upsert preferences;
            
            //set the preference to false
            ADM_SprintTabsController.setChatterPreference(false);
            
            //verify that the setting was persisted
            System.assertEquals(false, ADM_User_Preferences__c.getInstance(UserInfo.getUserId()).ShowChatterOnVirtualWall__c, 'Expected setChatterPreference to change the User Preference');
        }
    }

    @isTest
    public static void getPlannedVelocityTest(){
        String newName = '2012.10a-Test asdf9876';
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        sprint.Name = newName;
        ADM_SprintDetailController.saveSprint(sprint);
        Test.startTest();
         ApexPages.currentPage().getParameters().put('Id',sprint.id);
        Integer velocity = new ADM_SprintTabsController().getPlannedVelocity();
        System.debug(velocity);
        Test.stopTest();
        System.assertEquals(0,velocity);
    }
   
    @isTest
    public static void getCurrentUserLightningDesktopPreferenceTest(){
       ADM_SprintTabsController controller = new ADM_SprintTabsController();
       Boolean bool = controller.getCurrentUserLightningDesktopPreference();
      System.assertEquals(false,bool);
    }
    
    @isTest
    public static void getFullscreenCookieValueTest(){
       ADM_SprintTabsController controller = new ADM_SprintTabsController();
       Boolean bool = controller.getFullscreenCookieValue();
      System.assertEquals(false,bool);
    }
   
}