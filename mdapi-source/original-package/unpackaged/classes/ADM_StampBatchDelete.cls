public with sharing class ADM_StampBatchDelete implements Database.Batchable<Sobject>{
  String releaseFrom;
  String query;

  public ADM_StampBatchDelete(String releaseFrom, String query) {
    this.releaseFrom = releaseFrom;
    this.query = query;
  }

  public Database.Querylocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Sobject> scope) {
    delete scope;
  }

  public void finish(Database.BatchableContext BC) {
      Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        User user = ADM_WorkUser.get(Userinfo.getUserId());
        mail.setToAddresses(new String[] {user.Email});
        mail.setReplyTo(user.Email);
        mail.setSenderDisplayName('Release Stamp Batch');
        mail.setSubject('Completed removing release stamps from release, ' + [select Name from ADM_Release__c where Id = : releaseFrom].Name  + '.');
        mail.setPlainTextBody(mail.getSubject());
        Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
  }
}