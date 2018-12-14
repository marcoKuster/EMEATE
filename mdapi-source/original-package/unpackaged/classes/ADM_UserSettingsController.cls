public with sharing class ADM_UserSettingsController {
    private ApexPages.Standardcontroller ctrl;
    public User user{get;set;}
    public ADM_User_Business_Hours__c userBusinessHours{get;set;}
    
    public ADM_UserSettingsController(){
        try{
            user = [Select Name,Notification_Level__c,Work_User_Interface__c from user where Id = :UserInfo.getUserId()];
        }
        catch(QueryException qE){
            System.debug('Exception while querying user record');
            user = new User();
        }
        loadUserBusinessHours();
        ctrl = new ApexPages.Standardcontroller(user);
    }
    
    public ADM_UserSettingsController(User user){
    	this.user = user;
        loadUserBusinessHours();
    	ctrl = new ApexPages.Standardcontroller(user);
    }
    
    public PageReference save(){
        saveUserBusinessHours();
        PageReference pageRef = ctrl.save();
        Map<String,String> parameters = pageRef.getParameters();
        parameters.put('tab','Gus_Settings');
        parameters.put('save','true');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
     * For Investigation SLAs, allows each user to specify business hours.
     * Salesforce doesn't allow Lookup fields directly from User to other objects,
     * so using a custom junction object instead.
     */
    
    /**
     * Loads the User Business Hours object for this user from the DB, if it exists
     */
    private void loadUserBusinessHours() {
        if (user!=null && user.Id!=null) {
            try{
                userBusinessHours = [SELECT Id,User__c,Business_Hours__c FROM ADM_User_Business_Hours__c WHERE User__c = :user.Id];
            }
            catch(QueryException qE){
                System.debug('Exception while querying User Business Hours record');
            }
        }
        if (userBusinessHours==null) {
            userBusinessHours = new ADM_User_Business_Hours__c(User__c=user.Id);
        }
    }
 
    /**
     * Loads the User Business Hours object for this user from the DB, if it exists
     */
    private void saveUserBusinessHours() {
        if (userBusinessHours.User__c!=null) {
            try {
                if (userBusinessHours.Id!=null) {
                    if (userBusinessHours.Business_Hours__c==null) {
                        delete userBusinessHours; // remove the junction object
                    } else {
	                    update userBusinessHours; // update the selection
                    }                
                } else if (userBusinessHours.Business_Hours__c!=null) {
                    insert userBusinessHours; // only create a new record if a Business_Hours__c was selected
                }
            }
            catch (DMLException de) {
                System.debug('Exception while saving User_Business_Hours__c');
            }
        }
    }
}