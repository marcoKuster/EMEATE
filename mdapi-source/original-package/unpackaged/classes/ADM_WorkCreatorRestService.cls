@RestResource(urlMapping='/CreateWork/*')
global with sharing class ADM_WorkCreatorRestService{

    static Set<String> fieldsToCheck = new Set<String>{'Subject__c', 'Product_Tag__c', 'Found_in_Build__c', 'Priority__c', 'Details_and_steps_to_Reproduce__c',
                                            'Details__c' };
    static boolean arefieldsAccessibleOnWorkObject = true;
    static boolean arefieldsCreatableOnWorkObject = true;
    static boolean isPtagObjectQueryable = true;
    static boolean isBuildObjectQueryable = true;

    @HttpPost  
    global static ADM_WorkCreatorRestService.Result createWork(String subject, String ptag, String team,String type, String finBuild, String priority, String description, String details, String image) {
        Result result = new Result();
        if(validateUserPerm()){
            ADM_Work__c work = new ADM_Work__c();
            work.Subject__c = subject;
            RecordType rType = ADM_RecordType.getByName(type, 'ADM_Work__c');
            if(rType != null){
               work.RecordTypeId = rType.Id;
               String soqlPTag= 'select id, name from adm_product_tag__c where name=:ptag and team__c in (select id from ADM_Scrum_Team__c where name = :team) limit 1' ;
               List<ADM_Product_Tag__c> ptags =  Database.query(soqlPTag );
               if(ptags != null && ptags.size() >0){
                work.Product_Tag__c = ptags[0].Id;
               }
               else{
                 result.getErrorMessages().add('Cannot find a Product tag with name "' + ptag.escapeHTML4() + '" which belongs to team "'+ team.escapeHTML4() +'"') ;
               }
               if(rType.Name.equalsIgnoreCase('bug')){
                    String fBuildsoql= 'select id, name from adm_Build__c where name=:finBuild limit 1' ;
                    List<ADM_Build__c> builds = Database.query(fBuildsoql);
                    
                    if (builds.size() > 0){
                    work.Found_in_Build__c = builds[0].Id;
                    }
                    else{
                            result.getErrorMessages().add( 'Cannot find build with name "' + finBuild.escapeHTML4() + '"');
                    }
                    work.Priority__c = priority;
                    work.Details_and_steps_to_Reproduce__c = details;
                    
                }
                else{
                    work.Details__c = description;
                    work.RecordTypeId = [Select id from RecordType where name = 'User Story'].Id;
                }
                
                if(result.getErrorMessages().size() == 0){
                    insert work;
                    result.setId(work.id);
                }
 
                if ( ( work.Id != null ) && (image != null ) &&  ( image.length() > 0 )){
                    Attachment attachment = new Attachment();
                    attachment.ContentType = 'image/jpg';
                    attachment.Name = 'screen-capture.jpg';
                    attachment.ParentId = work.Id;                   
                    attachment.Body = EncodingUtil.base64Decode(image);
                    insert attachment;
                } 
            }
        }
        else{
            result.getErrorMessages().add('User has insufficient access');
        }
        
        
        return (result);  
    }

    private static boolean validateUserPerm(){
        arefieldsAccessibleOnWorkObject = ADM_SchemaManager.areFieldsAccessible('ADM_Work__c', fieldsToCheck);
        arefieldsCreatableOnWorkObject = ADM_SchemaManager.areFieldsCreateable('ADM_Work__c', fieldsToCheck);
        isPtagObjectQueryable = ADM_SchemaManager.isObjectQueryable('ADM_Product_Tag__c');
        isBuildObjectQueryable = ADM_SchemaManager.isObjectQueryable('ADM_Build__c');

        return (arefieldsAccessibleOnWorkObject && arefieldsCreatableOnWorkObject && isPtagObjectQueryable && isBuildObjectQueryable);

    }
    
    
    global class Result{
        String id;
        List<String> errorMessages = new List<String>();
        global void setId(String id){
            this.id = id;
        }

        global List<String> getErrorMessages(){
            return this.errorMessages;
        }
    }

}