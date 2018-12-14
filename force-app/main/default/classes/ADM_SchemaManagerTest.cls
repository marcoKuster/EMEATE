@IsTest
public class ADM_SchemaManagerTest {
    static Set<String> fieldsToCheck = new Set<String>{'Subject__c', 'Product_Tag__c', 'Found_in_Build__c', 'Priority__c', 'Details_and_steps_to_Reproduce__c', 'Details__c' };
    static Set<String> genericFields = new Set<String>{'Id', 'CreatedById'};
    static Set<String> deleteableObjects = new Set<String>{'ADM_Work__c', 'ADM_Build__c', 'ADM_Theme__c', 'ADM_Release__c', 'ADM_Sprint__c', 'ADM_Scrum_Team__c', 'Headcount__c', 'ADM_Product_Tag__c', 'ADM_Assignment_Rule__c', 'ADM_Bookmark__c', 'ADM_GUS_Exception__c', 'ADM_Parent_Work__c', 'ADM_Priority_Override__c', 'ADM_Release_Burndown_Item__c', 'ADM_Release_Event_Template__c', 'ADM_Release_Event__c', 'ADM_Released_In__c', 'ADM_Scrum_Team_Member__c', 'ADM_Tag_Assignment__c', 'ADM_Theme_Assignment__c', 'ADM_Work_Subscriber__c', 'QA_Answer__c', 'QA_Comment__c', 'QA_Default_Test_Case__c', 'QA_ExecutionBug__c', 'QA_FTest__c', 'QA_Hierarchy__c', 'QA_Question__c', 'QA_Test_Case__c', 'QA_Test_Execution__c', 'QA_Test_Plan__c', 'eRelease_Request__c', 'ADM_Task__c'};
	static Set<String> nonDeleteableObjects = new Set<String>{'User'};
        
    public testMethod static void testSchemaManager() {
        Boolean arefieldsAccessibleOnWorkObject;
        Boolean arefieldsCreatableOnWorkObject;
        Boolean areFieldsUpdateableOnWorkObject;
        Boolean isObjectQueryable;
        Boolean isObjectDeletable;
        Boolean isObjectUpdateable;
        Boolean isObjectCreateable;
        Boolean isObjectUpsertable;
        
        User testUser = ADM_WorkUser.createTestUser();
        User org62User = ADM_WorkUser.createTest62Orguser();
        User nonEmpUser = ADM_WorkUser.createNonEmployeeTestUser();
        
        for (String str : deleteableObjects) {
            System.runAs(testUser) {
                isObjectQueryable = ADM_SchemaManager.isObjectQueryable(str);
                isObjectDeletable = ADM_SchemaManager.isObjectDeletable(str);
                isObjectUpdateable = ADM_SchemaManager.isObjectUpdateable(str);
                isObjectCreateable = ADM_SchemaManager.isObjectCreateable(str);
                isObjectUpsertable = ADM_SchemaManager.isObjectUpsertable(str);
                Map<String, Schema.sObjectField> updateFieldSchema = ADM_SchemaManager.isObjectUpdateableReturnFieldsSchema(str);
                Map<String, Schema.sObjectField> createFieldSchema = ADM_SchemaManager.isObjectCreateableReturnFieldsSchema(str);
                
                System.assert(isObjectQueryable, str + ' object should be queryable');
                System.assert(isObjectDeletable, str + ' object should be deleteable');
                System.assert(isObjectUpdateable, str + ' object should be updateable');
                System.assert(isObjectCreateable, str + ' object should be createable');
                System.assert(isObjectUpsertable, str + ' object should be upsertable');
                System.assert(updateFieldSchema != null, str + ' object update schema should not be null');
                System.assert(createFieldSchema != null, str + ' object create schema should not be null');
                System.assert(updateFieldSchema.containsKey('Id'), str + ' object should exist in update schema map');
                System.assert(createFieldSchema.containsKey('Id'), str + ' object should exist in create schema map');
                System.assert(updateFieldSchema.get('Id') != null, str + ' object should exist in update schema map');
                System.assert(createFieldSchema.get('Id') != null, str + ' object should exist in create schema map');
            }
            
            System.runAs(nonEmpUser) {
                isObjectQueryable = ADM_SchemaManager.isObjectQueryable(str);
                isObjectDeletable = ADM_SchemaManager.isObjectDeletable(str);
                isObjectUpdateable = ADM_SchemaManager.isObjectUpdateable(str);
                isObjectCreateable = ADM_SchemaManager.isObjectCreateable(str);
                isObjectUpsertable = ADM_SchemaManager.isObjectUpsertable(str);
                Map<String, Schema.sObjectField> updateFieldSchema = ADM_SchemaManager.isObjectUpdateableReturnFieldsSchema(str);
                Map<String, Schema.sObjectField> createFieldSchema = ADM_SchemaManager.isObjectCreateableReturnFieldsSchema(str);
                
                System.assert(isObjectQueryable, str + ' object should be queryable');
                System.assert(isObjectDeletable, str + ' object should be deleteable');
                System.assert(isObjectUpdateable, str + ' object should be updateable');
                System.assert(isObjectCreateable, str + ' object should be createable');
                System.assert(isObjectUpsertable, str + ' object should be upsertable');
                System.assert(updateFieldSchema != null, str + ' object update schema should not be null');
                System.assert(createFieldSchema != null, str + ' object create schema should not be null');
                System.assert(updateFieldSchema.containsKey('Id'), str + ' object should exist in update schema map');
                System.assert(createFieldSchema.containsKey('Id'), str + ' object should exist in create schema map');
                System.assert(updateFieldSchema.get('Id') != null, str + ' object should exist in update schema map');
                System.assert(createFieldSchema.get('Id') != null, str + ' object should exist in create schema map');
            }
        }
        
        for (String str : nonDeleteableObjects) {
            System.runAs(testUser) {
                isObjectDeletable = ADM_SchemaManager.isObjectDeletable(str);
                
                System.assert(!isObjectDeletable, str + ' object should not be deleteable');
            }
            
            System.runAs(nonEmpUser) {
                isObjectDeletable = ADM_SchemaManager.isObjectDeletable(str);
                
                System.assert(!isObjectDeletable, str + ' object should not be deleteable');
            }
        }
        
        for (String str : deleteableObjects) {
            System.runAs(testUser) {
                arefieldsAccessibleOnWorkObject = ADM_SchemaManager.areFieldsAccessible(str, genericFields);
                arefieldsCreatableOnWorkObject = ADM_SchemaManager.areFieldsCreateable(str, genericFields);
                areFieldsUpdateableOnWorkObject = ADM_SchemaManager.areFieldsUpdateable(str, genericFields);
                
                System.assert(arefieldsAccessibleOnWorkObject, str + ' fields should be accessible');
                System.assert(arefieldsCreatableOnWorkObject, str + ' fields should be creatable');
                System.assert(areFieldsUpdateableOnWorkObject, str + ' fields should be updatable');
            }
            
            System.runAs(nonEmpUser) {
                arefieldsAccessibleOnWorkObject = ADM_SchemaManager.areFieldsAccessible(str, genericFields);
                arefieldsCreatableOnWorkObject = ADM_SchemaManager.areFieldsCreateable(str, genericFields);
                areFieldsUpdateableOnWorkObject = ADM_SchemaManager.areFieldsUpdateable(str, genericFields);
                
                System.assert(arefieldsAccessibleOnWorkObject, str + ' fields should be accessible');
                System.assert(arefieldsCreatableOnWorkObject, str + ' fields should be creatable');
                System.assert(areFieldsUpdateableOnWorkObject, str + ' fields should be updatable');
            }
        }
        
        for (String str : nonDeleteableObjects) {
            System.runAs(testUser) {
                arefieldsAccessibleOnWorkObject = ADM_SchemaManager.areFieldsAccessible(str, genericFields);
                arefieldsCreatableOnWorkObject = ADM_SchemaManager.areFieldsCreateable(str, genericFields);
                areFieldsUpdateableOnWorkObject = ADM_SchemaManager.areFieldsUpdateable(str, genericFields);
                
                System.assert(arefieldsAccessibleOnWorkObject, str + ' fields should be accessible');
                System.assert(arefieldsCreatableOnWorkObject, str + ' fields should be creatable');
                System.assert(areFieldsUpdateableOnWorkObject, str + ' fields should be updatable');
            }
            
            System.runAs(nonEmpUser) {
                arefieldsAccessibleOnWorkObject = ADM_SchemaManager.areFieldsAccessible(str, genericFields);
                arefieldsCreatableOnWorkObject = ADM_SchemaManager.areFieldsCreateable(str, genericFields);
                areFieldsUpdateableOnWorkObject = ADM_SchemaManager.areFieldsUpdateable(str, genericFields);
                
                System.assert(arefieldsAccessibleOnWorkObject, str + ' fields should be accessible');
                System.assert(arefieldsCreatableOnWorkObject, str + ' fields should be creatable');
                System.assert(areFieldsUpdateableOnWorkObject, str + ' fields should be updatable');
            }
        }
    }
}