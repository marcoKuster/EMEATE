public class ADM_ManageProductTagFieldsController {
    
        
    /*Build a list of all possible additional product tag fields.  Lookup which ones have already been turned
     * on for each record record if any */
    @AuraEnabled
    public static List<ADM_Additional_Field__c> getFieldList(String productTagId) { 
        Map<String,String> mapFieldApiNameWithBugSetting = new Map<String,String>();
        Map<String,String> mapFieldApiNameWithUserStorySetting = new Map<String,String>();
        Map<String,String> mapFieldApiNameWithInvestigationSetting = new Map<String,String>();
        Map<String,ADM_Additional_Field__c> mapFieldApiNameWithId = new Map<String,ADM_Additional_Field__c>();
        
        List<ADM_Additional_Field__c> possibleAdditionalFields = new List<ADM_Additional_Field__c>();
        List<ADM_Additional_Field__c> existingAdditionalFields = [Select id, Field_API_Name__c,Product_Tag__c, Type__c, Bug_Setting__c, User_Story_Setting__c, Investigation_Setting__c from ADM_Additional_Field__c where Product_Tag__c =: productTagId];
        
        for(ADM_Additional_Field__c af : existingAdditionalFields){
                mapFieldApiNameWithBugSetting.put(af.Field_API_Name__c,af.Bug_Setting__c);
                mapFieldApiNameWithUserStorySetting.put(af.Field_API_Name__c,af.User_Story_Setting__c);
                mapFieldApiNameWithInvestigationSetting.put(af.Field_API_Name__c,af.Investigation_Setting__c);
                mapFieldApiNameWithId.put(af.Field_API_Name__c,af);                
        } 
        
             
          
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        List<Schema.FieldSetMember> additionalFieldSetMembers = SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        
        
        for(Schema.FieldSetMember f : additionalFieldSetMembers){
            ADM_Additional_Field__c af = new ADM_Additional_Field__c();
            af.Field_API_Name__c = f.getFieldPath();
            af.Type__c = String.valueOf(f.Type);
            af.Name = f.Label;
            af.Product_Tag__c = productTagId;
            //default to Hidden and overide if a prior settings exists in the map
            if(mapFieldApiNameWithBugSetting.get(f.getFieldPath()) != null) {
                af.Bug_Setting__c = mapFieldApiNameWithBugSetting.get(f.getFieldPath());
            } else {
                af.Bug_Setting__c = 'Hidden';
            }
            
            if(mapFieldApiNameWithUserStorySetting.get(f.getFieldPath()) != null) {
                af.User_Story_Setting__c = mapFieldApiNameWithUserStorySetting.get(f.getFieldPath());
            } else {
                af.User_Story_Setting__c = 'Hidden';
            }
            
            if(mapFieldApiNameWithInvestigationSetting.get(f.getFieldPath()) != null) {
                af.Investigation_Setting__c = mapFieldApiNameWithInvestigationSetting.get(f.getFieldPath());
            } else {
                af.Investigation_Setting__c = 'Hidden';
            }
            
            if(af.Field_API_Name__c == 'Platform__c')
                af.Order__c = 1;
            else if(af.Field_API_Name__c == 'Page_Type__c')
                af.Order__c = 2;
            else if(af.Field_API_Name__c == 'Object__c')
                af.Order__c = 3;
            
            possibleAdditionalFields.add(af);
        }
		//Lightning does not like returning a list of SObjects that have no ID because they have not been inserted.  The return
		//works fine but any subsequent operations on the list will fail.  Therefore delete the existing additional fields and
		//insert the new ones.   This way any new entries added to the list of available fields after the product tag was created
		//are still included
		delete existingAdditionalFields;
		insert possibleAdditionalFields;
        return possibleAdditionalFields; 
      
        
    }
    
    
    @AuraEnabled
    public static void saveAdditionalFields(ADM_Additional_Field__c[] newAdditionalFields, String productTagId){
        System.debug('inside saveAdditionalFields() newAdditionalFields' + newAdditionalFields + ' productTagId:' + productTagId);
        update newAdditionalFields;
    }

}