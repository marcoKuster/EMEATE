public class AgileManager_InstallSchedulerException extends AgileManager_InstallException{
    public override void handle(InstallContext context){
        sendEmailToInstaller(context); 
    }

    private void sendEmailToInstaller(InstallContext context){
     User u = [Select Id, Email from User where Id =:context.installerID()];   
     Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
     String[] toAddresses = new String[] {u.Email};
     mail.setToAddresses(toAddresses);
     mail.setSenderDisplayName('Salesforce Agile Manager');
     String strReturnHTML = '<br /><br /><table cellpadding="3" cellspacing="3">';
     strReturnHTML += '<tr><td style="font-family:Verdana, Arial, sans-serif; font-size:10pt;">';
     strReturnHTML += 'An exception occured while trying to schedule the Agile Manager Work Unsubscriber job. Please schedule the job manually so that Work Chatter Follower limit is not reached over time. Refer to the install guide for more information.';
     strReturnHTML += '<br/>';
     strReturnHTML += ADM_TextUtils.toHTML(this.getMessage().escapeHtml4());
     strReturnHTML += '</td></tr>';
     mail.setSubject('Error on installing Salesforce Agile Manager (SAM) on Org : ' + UserInfo.getOrganizationName());
     mail.setPlainTextBody(this.getMessage());
     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
}