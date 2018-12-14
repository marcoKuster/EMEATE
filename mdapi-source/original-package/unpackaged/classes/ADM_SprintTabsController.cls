public with sharing class ADM_SprintTabsController {
    private transient Boolean chatterViewPreference = null;
    private transient Boolean fullscreenCookie = false;
    public Integer plannedVelocity;
    ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance();
    public ADM_SprintTabsController() {
    
        //Cookie fullscreen_cookie = new Cookie('fullscreen', 'true',null,-1,false);
        //ApexPages.currentPage().setCookies(new Cookie[]{fullscreen_cookie});
        Cookie cookie_result = ApexPages.currentPage().getCookies().get('fullscreen');
        if (cookie_result != null && cookie_result.getValue() == 'true') {
            fullscreenCookie = true;
        }
    }

    public Boolean getCurrentUserLightningDesktopPreference() {
        return ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
    }
    
    /**
     * Indicates whether or not to show the page in full screen
     */
    public Boolean getFullscreenCookieValue() {
        try {
            return fullscreenCookie;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving full screen cookie preference. Returning false. ' + exc.getMessage());
            return false;
        }
    }

    /**
     * Indicates whether or not to show the chatter view.
     */
    public Boolean getChatterViewPreference() {
        try {
            if(this.chatterViewPreference == null) {
                //retrieve the user preferences for the current user
                ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
                this.chatterViewPreference = preferences.ShowChatteronVirtualWall__c;
            }
            return this.chatterViewPreference;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving User Preferences. Returning false. ' + exc.getMessage());
            return false;
        }
    }
    
    @RemoteAction
    public static void setChatterPreference(Boolean chatterView) {
        ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
        preferences.ShowChatteronVirtualWall__c = chatterView;
        upsert preferences;
    }
    
    public static testMethod void testGetChatterViewPreference() {
        User user = ADM_WorkUser.createTestUser();
        System.runAs(user){ 
            
            ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            preferences.ShowChatterOnVirtualWall__c = true;
            upsert preferences;
            
            ADM_SprintTabsController controller = new ADM_SprintTabsController();
            
            System.assertEquals(true, controller.getChatterViewPreference(), 'Expected the ShowChatterOnVirtualWall property to match that of the User Preference');
        }
    }
    
    public static testMethod void testSetChatterPreference() {
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

    /**
     * Calculates the Planned Velocity
     */
    public Integer getPlannedVelocity() {
        String sprintId = ApexPages.currentPage().getParameters().get('Id');
        return ADM_SprintVirtualWallController.calculatePlannedVelocity(sprintId);
    }

    public Boolean packagedOrg{
        get{
          return signletonConstants.isPackagedOrg();
        }
        set;
       
    }
}