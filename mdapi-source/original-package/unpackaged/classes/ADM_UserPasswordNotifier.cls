public class ADM_UserPasswordNotifier implements Schedulable {
   Integer pwdExpiryDays = 90;
   List<String> profileNames = new List<String>();
   private static final String PASSWORD_CHANGE_PROFILES_KEY = 'Password_change_profiles';
   private static final String PASSWORD_MUST_CHANGE_IN_DAYS_KEY = 'password_must_change_in_days';
   private static final String PASSWORD_EXPIRY_IN_10_DAYS_KEY = 'passwd_expiry_in_10_days';
   private static final String PASSWORD_EXPIRY_IN_5_DAYS_KEY = 'passwd_expiry_in_5_days';
   private static final String PASSWORD_EXPIRY_IN_1_DAY_KEY = 'passwd_expiry_in_1_day';
   private static final String PASSWORD_EXPIRY_IN_10_DAYS_TEMPLATE_KEY = 'password_expiry_in_10_days';
   private static final String PASSWORD_EXPIRY_IN_5_DAYS_TEMPLATE_KEY = 'password_expiry_in_5_days';
   private static final String PASSWORD_EXPIRY_IN_1_DAY_TEMPLATE_KEY = 'password_expiry_in_1_day';
   private static final String GUS_ADMIN_STRING = 'GUS Admin';
   
   public void execute(SchedulableContext SC) {
      List<ADM_Key_Value_Properties__c> keyValues = [Select Name, value__c from ADM_Key_Value_Properties__c where name in ('Password_change_profiles', 'password_must_change_in_days')];
      
      for(ADM_Key_Value_Properties__c keyValue: keyValues){
           if(PASSWORD_CHANGE_PROFILES_KEY .equals(keyValue.Name)){
               profileNames = keyValue.value__c.split(',');
           }
           else{
               pwdExpiryDays = Integer.valueOf(keyValue.value__c);
               
           } 
      }
      
      
      List<EmailTemplate> passwExpiryTemplates = [SELECT id, name FROM EmailTemplate WHERE Name like 'password_expiry_in%'];
      List<User> usersPasswdExpiryIn10days = null;
      List<User> usersPasswdExpiryIn5days = null;
      List<User> usersPasswdExpiryIn1day = null;
      
      usersPasswdExpiryIn10days = Database.query(getSOQLForUserWhoRequiresPasswordChangeIn10Days(profileNames, pwdExpiryDays));
      usersPasswdExpiryIn5days = Database.query(getSOQLForUserWhoRequiresPasswordChangeIn5Days(profileNames, pwdExpiryDays));
      usersPasswdExpiryIn1day = Database.query(getSOQLForUserWhoRequiresPasswordChangeIn1Day(profileNames, pwdExpiryDays));
      Map<String,List<User>> passwdexpiryDay2UsersMap = new Map<String, List<User>>();
      passwdexpiryDay2UsersMap.put(PASSWORD_EXPIRY_IN_10_DAYS_KEY , usersPasswdExpiryIn10days);
      passwdexpiryDay2UsersMap.put(PASSWORD_EXPIRY_IN_5_DAYS_KEY , usersPasswdExpiryIn5days);
      passwdexpiryDay2UsersMap.put(PASSWORD_EXPIRY_IN_1_DAY_KEY , usersPasswdExpiryIn1day);
      List<Messaging.Singleemailmessage> mailMessagesToNotifyUsers = this.getMailMessages(passwExpiryTemplates, passwdexpiryDay2UsersMap);
      Messaging.sendEmail(mailMessagesToNotifyUsers);
   }
   
   @TestVisible
   private String getSOQLForUserWhoRequiresPasswordChangeIn10Days(List<String> profileNames, Integer pwdExpiryDays){
       String soql = getSOQLForUserWhoRequiresPasswordChange(profileNames, pwdExpiryDays-10);
       return soql;
   }
   
   @TestVisible
   private String getSOQLForUserWhoRequiresPasswordChangeIn5Days(List<String> profileNames, Integer pwdExpiryDays){
       String soql = getSOQLForUserWhoRequiresPasswordChange(profileNames, pwdExpiryDays-5);
       return soql;
   }
   
   @TestVisible
   private String getSOQLForUserWhoRequiresPasswordChangeIn1Day(List<String> profileNames, Integer pwdExpiryDays){
       String soql = getSOQLForUserWhoRequiresPasswordChange(profileNames, pwdExpiryDays-1);
       return soql;
   } 
   
   private String getSOQLForUserWhoRequiresPasswordChange(List<String> profileNames, Integer pwdExpiryDays){
       String soql = '';
       String selectUser = 'Select id from User ';
       String whereClause = ' where ';
       Integer pwdExpiryDaysMinusOne = pwdExpiryDays-1;
       String whereCondition =' lastPasswordChangeDate = last_n_days:'+ pwdExpiryDays +' and lastPasswordChangeDate != last_n_days:' + pwdExpiryDaysMinusOne;
       whereCondition += ' and ' + COM_SoqlUtils.createInClause('Profile.Name', profileNames);
       soql = selectUser + whereClause + whereCondition;
       
       return soql;
   }    
   
   @TestVisible
   private List<Messaging.Singleemailmessage> getMailMessages(List<EmailTemplate> passwExpiryTemplates, Map<String,List<User>> passwdexpiryDay2UsersMap){
      EmailTemplate passwd_expiry_in_10_days = null;
      EmailTemplate passwd_expiry_in_5_days = null;
      EmailTemplate passwd_expiry_in_1_day = null;
      for(EmailTemplate expiryTemplate:passwExpiryTemplates){
          if(expiryTemplate.Name.contains(PASSWORD_EXPIRY_IN_10_DAYS_TEMPLATE_KEY)){
              if(getPasswordExpiryEmailTemplateName(PASSWORD_EXPIRY_IN_10_DAYS_TEMPLATE_KEY).equalsIgnoreCase(expiryTemplate.Name)){
                  passwd_expiry_in_10_days = expiryTemplate;
              }
          }
          else if(expiryTemplate.Name.contains(PASSWORD_EXPIRY_IN_5_DAYS_TEMPLATE_KEY)){
              if(getPasswordExpiryEmailTemplateName(PASSWORD_EXPIRY_IN_5_DAYS_TEMPLATE_KEY).equalsIgnoreCase(expiryTemplate.Name)){
                  passwd_expiry_in_5_days = expiryTemplate;
              }
          }
          else if(expiryTemplate.Name.contains(PASSWORD_EXPIRY_IN_1_DAY_TEMPLATE_KEY)){
              if(getPasswordExpiryEmailTemplateName(PASSWORD_EXPIRY_IN_1_DAY_TEMPLATE_KEY).equalsIgnoreCase(expiryTemplate.Name)){
                  passwd_expiry_in_1_day = expiryTemplate;
              }
          }
      }
      List<Messaging.Singleemailmessage> combinedListOfMailMessages = new List<Messaging.Singleemailmessage> ();
      List<Messaging.Singleemailmessage> message_10_days_expiry_mails = this.getMailMessageFor10DaysExpiry(passwd_expiry_in_10_days,passwdexpiryDay2UsersMap);
      List<Messaging.Singleemailmessage> message_5_days_expiry_mails = this.getMailMessageFor5DaysExpiry(passwd_expiry_in_5_days,passwdexpiryDay2UsersMap);
      List<Messaging.Singleemailmessage> message_1_day_expiry_mails = this.getMailMessageFor1DayExpiry(passwd_expiry_in_1_day,passwdexpiryDay2UsersMap);
      
      if(null != message_10_days_expiry_mails){
          combinedListOfMailMessages.addAll(message_10_days_expiry_mails);
      }
      if(null != message_5_days_expiry_mails){
          combinedListOfMailMessages.addAll(message_5_days_expiry_mails);
      }
      if(null != message_1_day_expiry_mails){
          combinedListOfMailMessages.addAll(message_1_day_expiry_mails);
      }
      return combinedListOfMailMessages;
  }
  
  private List<Messaging.Singleemailmessage> getMailMessageFor10DaysExpiry(EmailTemplate expiryTemplate, Map<String,List<User>> passwdexpiryDay2UsersMap){
      List<User> users10DayExpiry = passwdexpiryDay2UsersMap.get(PASSWORD_EXPIRY_IN_10_DAYS_KEY);
      List<Messaging.Singleemailmessage> message_10_days_expiry_mails = new List<Messaging.Singleemailmessage>();
      if(null != users10DayExpiry && users10DayExpiry.size()>0){
         message_10_days_expiry_mails = getMailMessageForUsers(expiryTemplate, users10DayExpiry);
      }
      return message_10_days_expiry_mails;
  }
  
  private List<Messaging.Singleemailmessage> getMailMessageFor5DaysExpiry(EmailTemplate expiryTemplate, Map<String,List<User>> passwdexpiryDay2UsersMap){
      List<User> users5DaysExpiry = passwdexpiryDay2UsersMap.get(PASSWORD_EXPIRY_IN_5_DAYS_KEY);
      List<Messaging.Singleemailmessage> message_5_days_expiry_mails = new List<Messaging.Singleemailmessage>();
      if(null != users5DaysExpiry && users5DaysExpiry.size()>0){
         message_5_days_expiry_mails = getMailMessageForUsers(expiryTemplate, users5DaysExpiry);
      }
      return message_5_days_expiry_mails;
  }
  
  private List<Messaging.Singleemailmessage> getMailMessageFor1DayExpiry(EmailTemplate expiryTemplate, Map<String,List<User>> passwdexpiryDay2UsersMap){
      List<User> users1DayExpiry = passwdexpiryDay2UsersMap.get(PASSWORD_EXPIRY_IN_1_DAY_KEY);
      List<Messaging.Singleemailmessage> message_1_day_expiry_mails = new List<Messaging.Singleemailmessage>();
      if(null != users1DayExpiry && users1DayExpiry.size()>0){
         message_1_day_expiry_mails = getMailMessageForUsers(expiryTemplate, users1DayExpiry);
      }
      return message_1_day_expiry_mails;
  }
  
  private List<Messaging.Singleemailmessage> getMailMessageForUsers(EmailTemplate emailTemplate, List<User> usersListToNotify){
       List<Messaging.Singleemailmessage> mailMessageList = new List<Messaging.Singleemailmessage>();
       for(User user: usersListToNotify){
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
               mail.setSenderDisplayName(GUS_ADMIN_STRING);
               mail.setTargetObjectId(user.id); 
               mail.setTemplateId(emailTemplate.id);  
               mail.setSaveAsActivity(false);
               mailMessageList.add(mail);
       }
       return mailMessageList;
  }
  
  private String getPasswordExpiryEmailTemplateName(String templateName){
      if(Test.isRunningTest()){
          return 'test_' + templateName;
      }
      else{
          return templateName;
      }
  }
   
}