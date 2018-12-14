@IsTest
private class ADM_ManageProductTagFieldsControllerTest {
    
    static testMethod void testGetFields() {
        ADM_Product_Tag__c tag = ADM_ProductTag.createAndInsertProductTag();
        List<ADM_Additional_Field__c> fieldsForTag = ADM_ManageProductTagFieldsController.getFieldList(tag.id);
        //now get the fields from the source for comparison
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        List<Schema.FieldSetMember> additionalFieldSetMembers = SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        //make sure we found the same number
        System.assertEquals(additionalFieldSetMembers.size(), fieldsForTag.size());
        
    }
    
    static testMethod void testSaveAdditionalFields() {
        ADM_Product_Tag__c tag = ADM_ProductTag.createAndInsertProductTag();
        List<ADM_Additional_Field__c> fieldsForTag = ADM_ManageProductTagFieldsController.getFieldList(tag.id);
        //now edit some of the fields and make everyone required for Bugs
        for(ADM_Additional_Field__c field : fieldsForTag) {
            field.Bug_Setting__c = 'Required';
        }
        //save the changes
        ADM_ManageProductTagFieldsController.saveAdditionalFields(fieldsForTag, tag.id);
        //now retrieve the changes using the same controller to verify the save happened
        List<ADM_Additional_Field__c> updatedFieldsForTag = ADM_ManageProductTagFieldsController.getFieldList(tag.id);
        
        for(ADM_Additional_Field__c field : updatedFieldsForTag) {
            System.assertEquals('Required', field.Bug_Setting__c);
        }
        
    }    

}