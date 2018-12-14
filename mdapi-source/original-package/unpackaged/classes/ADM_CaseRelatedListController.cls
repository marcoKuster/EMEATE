public class ADM_CaseRelatedListController {
   
   private ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance(); 
    
   public Id workId {
        get; 
        set;
   }
    
   public String workName {
        get; 
        set;
   } 
   
   public Boolean packagedOrg{
        get{
          return signletonConstants.isPackagedOrg();
        }
        set;
   } 
    
   public List<Case> getCasesRelatedToWork() {
       List<Case> cases = new List<Case>();
       try {
          //The relationship between work and cases differs between GUS and Agile Accelerator
          
          if(packagedOrg) {
            System.debug('executing getCasesRelatedToWork() for packaged org...');
             cases = Database.query('select Id, CaseNumber, Subject, CreatedDate, LastModifiedDate, Owner.Name, Status from Case where ADM_Work__c=:workId order by CreatedDate');
          } else {
            System.debug('executing getCasesRelatedToWork() for non packaged org...');
            cases = Database.query('select Id, CaseNumber, Subject, CreatedDate, LastModifiedDate, Owner.Name, Status from Case where SM_Bug__c=:workName order by CreatedDate');
          
          }
           
           
       } catch(Exception e) {
           System.debug('Exception getting cases related to work e:' + e + ' work id:' + workId);
       } 
       
       return cases;
        
        
   } 
    
    public PageReference newCase() {
        return null;
    }

}