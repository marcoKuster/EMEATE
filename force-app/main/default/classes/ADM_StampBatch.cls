public class ADM_StampBatch  implements Database.Batchable<Sobject>{
    String releaseFrom;
    String releaseTo;
    String query;
    ADM_Release__c relFrom = new ADM_Release__c();
    ADM_Release__c relTo = new ADM_Release__c();

    public ADM_StampBatch(String releaseFrom, String releaseTo, String query) {
      this.releaseFrom = releaseFrom;
      this.releaseTo = releaseTo;
      this.query = query;
      List<ADM_Release__c> releases = ADM_Release.getAllBy('Id', new Set<String>{releaseFrom, releaseTo});
      for(ADM_Release__c release : releases) {
        if(release.Id == releaseFrom) {
            relFrom = release;
        } else if(release.Id == releaseTo) {
            relTo = release;
        }
      }
    }

    public Database.Querylocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Sobject> scope) {
      List<ADM_Released_In__c> stamps = new List<ADM_Released_In__c>();
      List<ADM_Released_In__c> stamps2 = new List<ADM_Released_In__c>();
      stamps2 = [select Work__c from ADM_Released_In__c where Release__c = : releaseTo];
      Map<String,ADM_Released_In__c> stamps2map = new Map<String,ADM_Released_In__c>();
      for(ADM_Released_In__c stamp2 : stamps2) {
        stamps2map.put(stamp2.Work__c, stamp2);
      }

      for(Sobject s : scope) {
         ADM_Released_In__c stamp = new ADM_Released_In__c();
         String workId = String.valueOf(s.get('Work__c'));
         if(!stamps2map.containsKey(workId)) {
           stamp.Work__c = workId;
           stamp.Release__c = releaseTo;
           stamp.Reverted__c = Boolean.valueOf(s.get('Reverted__c'));
           stamps.add(stamp);
         }
      }
      if(stamps.isEmpty()) {
      } else {
        Database.insert(stamps,false);
      }
    }

    public void finish(Database.BatchableContext BC) {
        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        User user = ADM_WorkUser.get(Userinfo.getUserId());
        mail.setToAddresses(new String[] {user.Email});
        mail.setReplyTo(user.Email);
        mail.setSenderDisplayName('Release Stamp Batch');
        mail.setSubject('Completed copying release stamps from release, ' + relFrom.Name  + ', to release, ' + relTo.Name + '.');
        mail.setPlainTextBody(mail.getSubject());
        Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
    }
}