@isTest
private class ADM_UserPasswordNotifierTest {
   
 /* 
      @testcaseID a1DB00000002zZOMAY
      @hierarchy GUS.Security
      @userstory a07B0000000cGDPIA2
      @expectedResults:  user gets an email telling him about his password expiry.
      @author saran govindan
    */
 
    static testMethod void getSOQLForUserWhoRequiresPasswordChangeIn10DaysTest() {
        String expectedString = 'Select id from User  where  lastPasswordChangeDate = last_n_days:80 and lastPasswordChangeDate != last_n_days:79 and Profile.Name in (\'TestProfile\')';
        List<String> profileNames = new List<String>{'TestProfile'};
        String actualString = new ADM_UserPasswordNotifier().getSOQLForUserWhoRequiresPasswordChangeIn10Days(profileNames,90);
        
        System.assertEquals(expectedString, actualString, 'Wrong soql query string returned');
    }
    

    static testMethod void getSOQLForUserWhoRequiresPasswordChangeIn5DaysTest() {
        String expectedString = 'Select id from User  where  lastPasswordChangeDate = last_n_days:85 and lastPasswordChangeDate != last_n_days:84 and Profile.Name in (\'TestProfile\')';
        List<String> profileNames = new List<String>{'TestProfile'};
        String actualString = new ADM_UserPasswordNotifier().getSOQLForUserWhoRequiresPasswordChangeIn5Days(profileNames,90);
        
        System.assertEquals(expectedString, actualString, 'Wrong soql query string returned');
    }

    
    static testMethod void getSOQLForUserWhoRequiresPasswordChangeIn1DayTest() {
        String expectedString = 'Select id from User  where  lastPasswordChangeDate = last_n_days:89 and lastPasswordChangeDate != last_n_days:88 and Profile.Name in (\'TestProfile\')';
        List<String> profileNames = new List<String>{'TestProfile'};
        String actualString = new ADM_UserPasswordNotifier(). getSOQLForUserWhoRequiresPasswordChangeIn1Day(profileNames,90);
        
        System.assertEquals(expectedString, actualString, 'Wrong soql query string returned');
    }
    
  /* 
      @testcaseID a1DB00000002zZOMAY
      @hierarchy GUS.Security
      @userstory a07B0000000cGDPIA2
      @expectedResults:  user gets an email telling him about his password expiry.
      @author saran govindan
    */

    static testMethod void getMailMessagesTest() {
        
        List<EmailTemplate> passwExpiryTemplates = new List<EmailTemplate>();
        EmailTemplate eTemplate1 = new EmailTemplate (developerName = 'testDeveloper1', FolderId = UserInfo.getOrganizationId(), TemplateType= 'text', Name = 'test_password_expiry_in_10_days'); 
        EmailTemplate eTemplate2 = new EmailTemplate (developerName = 'testDeveloper2', FolderId = UserInfo.getOrganizationId(), TemplateType= 'text', Name = 'test_password_expiry_in_5_days'); 
        EmailTemplate eTemplate3 = new EmailTemplate (developerName = 'testDeveloper3', FolderId = UserInfo.getOrganizationId(), TemplateType= 'text', Name = 'test_password_expiry_in_1_day'); 
        passwExpiryTemplates.add(etemplate1);
        passwExpiryTemplates.add(etemplate2);
        passwExpiryTemplates.add(etemplate3);
        
        insert passwExpiryTemplates;
        
        List<User> testUsers = new List<User>();
        List<String> userNamesToQuery = new List<String>();
        for(Integer count=0; count<5; count++){
            User testUser = ADM_WorkUser.setUpTestUser();
            testUsers.add(testUser);
            userNamesToQuery.add(testUser.Name);
        }
        
        insert testUsers;
        
        List<EmailTemplate> passwExpiryTemplatesQueried = [SELECT id, name FROM EmailTemplate WHERE Name like 'test_password_expiry_in%'];
        System.assert(passwExpiryTemplatesQueried.size()>0);
        List<User> testUsersQueried = [ Select id from User where name in :userNamesToQuery];
        Map<String,List<User>> passwdexpiryDay2UsersMap = new Map<String, List<User>>();
        passwdexpiryDay2UsersMap.put('passwd_expiry_in_10_days' , new List<User>{testUsers[0]});
        passwdexpiryDay2UsersMap.put('passwd_expiry_in_5_days' , new List<User>{testUsers[1],testUsers[2]});
        passwdexpiryDay2UsersMap.put('passwd_expiry_in_1_day' , new List<User>{testUsers[3], testUsers[4]});
        
        List<Messaging.Singleemailmessage> mailMessages = new ADM_UserPasswordNotifier().getMailMessages(passwExpiryTemplatesQueried, passwdexpiryDay2UsersMap);
        
        System.assertEquals(5, mailMessages.size(), 'Expected mailMessages');
    }
    
}