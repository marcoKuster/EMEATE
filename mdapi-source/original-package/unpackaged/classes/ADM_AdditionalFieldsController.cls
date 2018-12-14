public with sharing class ADM_AdditionalFieldsController {

    public String productTagName {get;set;}
    public ADM_Product_Tag__c productTag;
    public List<ADM_Additional_Field__c> additionalFields{get;set;}
    public List<ADM_Additional_Field__c> additionalFieldsForMap;
    Map<String,String> mapFieldApiNameWithBugSetting;
    Map<String,String> mapFieldApiNameWithUserStorySetting;
    Map<String,String> mapFieldApiNameWithInvestigationSetting;
    Map<String,ADM_Additional_Field__c> mapFieldApiNameWithId;
    
    public ADM_AdditionalFieldsController(ApexPages.StandardController stdController) {
        try{
            mapFieldApiNameWithBugSetting = new Map<String,String>();
            mapFieldApiNameWithUserStorySetting = new Map<String,String>();
            mapFieldApiNameWithInvestigationSetting = new Map<String,String>();
            mapFieldApiNameWithId = new Map<String,ADM_Additional_Field__c>();
            additionalFields = new List<ADM_Additional_Field__c>();            
            String productTagId = ApexPages.currentPage().getParameters().get('Id');            
            productTag = [Select id, Name from ADM_Product_Tag__c where id =: productTagId limit 1];            
            productTagName = productTag.Name;
            additionalFieldsForMap = [Select id, Field_API_Name__c,Product_Tag__c, Type__c, Bug_Setting__c, User_Story_Setting__c, Investigation_Setting__c from ADM_Additional_Field__c where Product_Tag__c =: productTagId];
            addMapValuesForAdditionalFields();     
        }
        catch(Exception e){
            System.debug('Exception while retrieving additional fields : '+e);
        }
    }
    
    public void addMapValuesForAdditionalFields(){
        try{
            for(ADM_Additional_Field__c af : additionalFieldsForMap){
                mapFieldApiNameWithBugSetting.put(af.Field_API_Name__c,af.Bug_Setting__c);
                mapFieldApiNameWithUserStorySetting.put(af.Field_API_Name__c,af.User_Story_Setting__c);
                mapFieldApiNameWithInvestigationSetting.put(af.Field_API_Name__c,af.Investigation_Setting__c);
                mapFieldApiNameWithId.put(af.Field_API_Name__c,af);                
            } 
        }
        catch(Exception e){
            System.debug('Exception while while creating Map values for additional fields : '+e);
        }
    }
    
    public List<ADM_Additional_Field__c> getFieldList() { 
        try{     
            additionalFields = new List<ADM_Additional_Field__c>();

            String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
            List<Schema.FieldSetMember> additionalFieldSetMembers = SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
 

            //Query all items from the field set and create an object to hold a relation to the VF page's each row. No actual instance is created.
            for(Schema.FieldSetMember f : additionalFieldSetMembers){
                ADM_Additional_Field__c af = new ADM_Additional_Field__c();
                af.Field_API_Name__c = f.getFieldPath();
                af.Type__c = String.valueOf(f.Type);
                af.Name = f.Label;
                af.Product_Tag__c = productTag.Id;
                af.Bug_Setting__c = mapFieldApiNameWithBugSetting.get(f.getFieldPath());
                af.User_Story_Setting__c = mapFieldApiNameWithUserStorySetting.get(f.getFieldPath());
                af.Investigation_Setting__c = mapFieldApiNameWithInvestigationSetting.get(f.getFieldPath());
                if(af.Field_API_Name__c == 'Platform__c')
                    af.Order__c = 1;
                else if(af.Field_API_Name__c == 'Page_Type__c')
                    af.Order__c = 2;
                else if(af.Field_API_Name__c == 'Object__c')
                    af.Order__c = 3;
                additionalFields.add(af);
                
            }
        return additionalFields; //List of objects created on the fly. 
        }
        catch(Exception e){
            System.debug('Exception while retrieving additional fields : '+e);
            return null;
        }
    }
    
    public PageReference save(){
        try{
        /*
           Here since we are querying fields from a field set and creating an object (no actual instance created) and using that for the VF page, while saving we insert everytime.
           We cannot update because there is no id. 
           Also we query the existing additional fields and mark required/visible based on this using the 2 maps. 
           Now while saving the old additional fields are already present, so if we insert we keep making duplicate values. 
           So to avoid this, we delete every single time what was already present and insert fresh based on the users current changes.
           So delete old changes first and insert all new changes. 

        */
        List<ADM_Additional_Field__c> insertList = new List<ADM_Additional_Field__c>();
        List<ADM_Additional_Field__c> deleteList = new List<ADM_Additional_Field__c>();
        for(ADM_Additional_Field__c af : additionalFields){
            if(mapFieldApiNameWithId.get(af.Field_API_Name__c) != null){
                deleteList.add(mapFieldApiNameWithId.get(af.Field_API_Name__c));
            }
            if(af.Bug_Setting__c != 'hidden' || af.User_Story_Setting__c != 'hidden' || af.Investigation_Setting__c != 'hidden'){
                insertList.add(af);
            }
        }
        delete deleteList;
        insert insertList;
        return new PageReference('/'+productTag.id);
        }
        catch(Exception e){
            System.debug('Exception while saving additionalFields : '+e);
            return null;
        }
    }

}