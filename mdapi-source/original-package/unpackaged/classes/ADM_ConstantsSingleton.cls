/* 
* Copyright, 2008, SALESFORCE.com
* All Rights Reserved
* Company Confidential
*
* Provides a central location for values which have to be looked up at run time (typically org dependent) but after intial lookup remain constant
*
* @author James Hatton
* @created 11/04/2008
*/

public class ADM_ConstantsSingleton {
    
    private static ADM_ConstantsSingleton uniqueInstance;
    private String EMAIL_2_GUS_ADDRESS; 
    private final String EMAIL_FUNCTION_NAME = 'email2gus';    
    
    //This is deliberately data typed as String so that later null check can be done. Eventhough Boolean variable can also be set null, not want to take the chance of null being treated as False later.
    private String isFederationFieldAvailable = null; 
    private String nameSpace = '';
    private boolean userLightningExperiencePreferred = false;

   
    //private constructor only the getInstance method can instantiate this class
    private ADM_ConstantsSingleton() {
            if(Test.isRunningTest()){
               this.EMAIL_2_GUS_ADDRESS = 'donot_send_email@test.com';
            } else {
                List<EmailServicesFunction> functions = [select Id, FunctionName from EmailServicesFunction where FunctionName in ('email2gus', 'email2agile') limit 1];
                if(functions.size() == 0) {
                    //throw new ADM_ApplicationException(DOCUMENTATION + ' We are missing a required EmailService that can created by going to Setup -> Develop -> Email Services as described in our guide. ' + REASON);
                } else {
                    Id emailFunctionID = functions.get(0).id;
                    String emailFunctionName = functions.get(0).FunctionName;
                    List<EmailServicesAddress> addresses = [select EmailDomainName from EmailServicesAddress where FunctionId = :emailFunctionID limit 1];
                    if(addresses.size() == 0) {
                        //throw new ADM_ApplicationException(DOCUMENTATION + ' We are missing a required Email Address with the name \'' + EMAIL_FUNCTION_NAME + '\' that can be created by going to Setup -> Develop -> Email Services -> Selecting "' + EMAIL_FUNCTION_NAME + '" and clicking the "New Email Address" button as described in our guide. ' + REASON);
                    } else {
                        String emailDomainName = addresses.get(0).EmailDomainName;
                        this.EMAIL_2_GUS_ADDRESS = emailFunctionName + '@' + emailDomainName;    
                    } 
                }
            }

            if(null == this.getIsFederationFieldAvailable()){//This check will make sure the Describe call only happens once during a transaction
                Map<String, Schema.sObjectField> Fields = User.sObjectType.getDescribe().fields.getMap();
                if(Fields.keySet().contains('FederationIdentifier'.toLowerCase()) || Fields.keySet().contains('FederationIdentifier'.toUpperCase())|| Fields.keySet().contains('FederationIdentifier')){
                    this.setIsFederationFieldAvailable('true');
                } else{
                    this.setIsFederationFieldAvailable('false');
                }
            }
            
            List<ApexClass> apexClasses = [Select NamespacePrefix from ApexClass where name = 'ADM_ConstantsSingleton'];
            if(apexClasses.size() >0){
                if(apexClasses[0].NamespacePrefix != null && apexClasses[0].NamespacePrefix.length() > 0){
                    this.setNameSpace(apexClasses[0].NamespacePrefix+'__');
                }
            }
            /*SFX page carries this parameter on each page and we can use this to determine we are rendering page on SFX view or not
            if isdtp == 'p1' it is SFX*/
            boolean userLightningExperiencePreferred = false;
            if(System.currentPageReference() != null && System.currentPageReference().getParameters() != null){
                String isdtp = System.currentPageReference().getParameters().get('isdtp');
                if(isdtp != null && isdtp.equalsIgnoreCase('p1')){
                    userLightningExperiencePreferred = true;
                }
                else{
                    userLightningExperiencePreferred = false;
                }
            }
            else{
                List<User> users = [SELECT UserPreferencesLightningExperiencePreferred FROM User Where Id =:UserInfo.getUserId() limit 1];
                if(users.size() >0 ){
                     userLightningExperiencePreferred = users[0].UserPreferencesLightningExperiencePreferred;
                }
            }
            
            this.setUserLightningExperiencePreferred(userLightningExperiencePreferred);
        
    }
    
    public void setUserLightningExperiencePreferred(boolean userLightningExperiencePreferred){
        this.userLightningExperiencePreferred = userLightningExperiencePreferred;
    }
    
    public  boolean getUserLightningExperiencePreferred(){
       return this.userLightningExperiencePreferred;
    }
    
    //don't need to worry about the Singleton thread safe gotcha as Apex ensures this is synchronized
    public static ADM_ConstantsSingleton getInstance() {
        if  (uniqueInstance == null) {
            uniqueInstance = new ADM_ConstantsSingleton();  
        }
        
        return uniqueInstance;  
    }
    
    public String getEmail2GusAddress() {
        return EMAIL_2_GUS_ADDRESS; 
    }

    public void setIsFederationFieldAvailable(String value){
        isFederationFieldAvailable = value;
    }
    
    public String getIsFederationFieldAvailable(){
        return isFederationFieldAvailable;
    }
    
    public void setNameSpace(String value){
        nameSpace = value;
    }
    
    public String getNameSpace(){
        return nameSpace;
    }

    public Boolean isPackagedOrg(){       
        if(null != getNameSpace() && !''.equals(getNameSpace())){
            return true;
       }
       return false;
    }

    testMethod static void testSingleton() {
            ADM_ConstantsSingleton acs = ADM_ConstantsSingleton.getInstance();
            String expectedEmailSender = 'donot_send_email';
            System.assert(acs != null);
            //assert the email address has the correct sender
            System.assert(acs.getEmail2GusAddress().contains(expectedEmailSender));
            //assert the organization-unique domain name has been added
            System.assert((acs.getEmail2GusAddress().length()) > expectedEmailSender.length());
    }           

}