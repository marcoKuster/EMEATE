public with sharing class ADM_ProductTagFieldsController {
    
     @AuraEnabled
    public static ADM_Work__c getWorkRecord(String recordId) {
        return [select id, Name, Subject__c from ADM_Work__c where id=:recordId];
    }    
    
    
    @AuraEnabled
    public static List<ProductTagField>  getProductTagFields(String recordId) {
      //first determine the Product Tag and Record Type based on the record id
      ADM_Work__c work = [select id, Product_Tag__c, RecordType.Name from ADM_Work__c where id=:recordId];  
      if(work != null && work.Product_Tag__c != null && work.RecordType.Name != null) {
        
          List<ADM_Additional_Field__c> additionalFieldsForInvestigation = new List<ADM_Additional_Field__c>();
          List<ADM_Additional_Field__c> additionalFieldsForBug = new List<ADM_Additional_Field__c>();
          List<ADM_Additional_Field__c> additionalFieldsForUserStory = new List<ADM_Additional_Field__c>();
          List<ADM_Additional_Field__c> allAdditionalFieldsForProductTag = [select id, Name, Field_API_Name__c, Product_Tag__c, Type__c, Investigation_Setting__c, Bug_Setting__c, User_Story_Setting__c from ADM_Additional_Field__c where Product_Tag__c = : work.Product_Tag__c and (Investigation_Setting__c != 'hidden' or Bug_Setting__c != 'hidden' or User_Story_Setting__c != 'hidden') order by Order__c,Name];
    
          for(ADM_Additional_Field__c af : allAdditionalFieldsForProductTag){
              if(af.Bug_Setting__c != 'hidden'){
                additionalFieldsForBug.add(af);
              }
              if(af.User_Story_Setting__c != 'hidden'){
                additionalFieldsForUserStory.add(af);
              }
              if(af.Investigation_Setting__c != 'hidden'){
                additionalFieldsForInvestigation.add(af);
              }
          }
            
          if(work.RecordType.Name.equalsIgnoreCase('Bug')) {
            return populateProductTagFieldList(additionalFieldsForBug, work.id);  
          } else if(work.RecordType.Name.equalsIgnoreCase('User Story')) {
            return populateProductTagFieldList(additionalFieldsForUserStory, work.id);    
          } else if(work.RecordType.Name.equalsIgnoreCase('Investigation')) {
           return populateProductTagFieldList(additionalFieldsForInvestigation, work.id);    
          } else {
              return null; 
          }    
      } else {
          return null;
      }    
        
    }
    
    //converts additional fields to ProductTagField which includes the display friendly field label
    private static List<ProductTagField> populateProductTagFieldList(List<ADM_Additional_Field__c> addFields, Id workId) {
        
        //we need to pull just the fields we need from the Work object based on the field API names specified in the list of ADM_Additional_Field records
        List<ProductTagField> productTagFields = new List<ProductTagField>();
        //we need to pull just the fields we need from the Work object based on the field API names specified in the list of ADM_Additional_Field records
        String fieldListForQuery = '';
        if(addFields != null && addFields.size() >0 ){
        for(ADM_Additional_Field__c field : addFields) {
         	 fieldListForQuery = fieldListForQuery + field.Field_API_Name__c + ', ';
        }    
        fieldListForQuery = ADM_TextUtils.removeTrailingComma(fieldListForQuery);
        String query = 'select id, ' + fieldListForQuery + ' from ADM_Work__c where id=:workId';
        System.debug('inside populateProductTagFieldList() query:' + query);
        ADM_Work__c populatedWorkRecord = Database.query(query);
        SObject sobjectOfWork = populatedWorkRecord;
        

        System.debug('inside populateProductTagFieldList() about to iterate addFields:' + addFields);
        for(ADM_Additional_Field__c field : addFields) {
            System.debug('inside populateProductTagFieldList() processing field:' + field);
            ProductTagField pfield = new ProductTagField();
            pfield.fieldLabel = field.Name;
            pfield.fieldType = field.Type__c;
            pfield.fieldValue = String.valueOf(sobjectOfWork.get(field.Field_API_Name__c));
            productTagFields.add(pfield);
            
        }
        System.debug('productTagFields:' + productTagFields);
        }

        return productTagFields;
    }
    
    public class ProductTagField {
        @AuraEnabled
        public String fieldLabel{get;set;}
        @AuraEnabled
        public String fieldValue{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
        
    }
    

}