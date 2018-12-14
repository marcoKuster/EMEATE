@IsTest
public class ADM_AdditionalFieldsControllerTest {
    
    @IsTest
    public static void testGetFieldList(){
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        List<Schema.FieldSetMember> listOfExpectedAdditionalFields =  new List<Schema.FieldSetMember>();
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace(); 
        listOfExpectedAdditionalFields = Schema.SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(af);
        ApexPages.currentPage().getParameters().put('id', proTag.id);
        ADM_AdditionalFieldsController ac = new ADM_AdditionalFieldsController(sc);
        List<ADM_Additional_Field__c> listOfActualAdditionalFields = new List<ADM_Additional_Field__c>();       
        listOfActualAdditionalFields = ac.getFieldList();
        System.assertEquals(listOfExpectedAdditionalFields.size(),listOfActualAdditionalFields.size(),'Expect the method to return the list of additional fields in the field set.');
    }
    
    @IsTest
    public static void testSaveForAdditionalFields(){
        List<Schema.FieldSetMember> listOfExpectedAdditionalFields =  new List<Schema.FieldSetMember>();
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        listOfExpectedAdditionalFields = Schema.SObjectType.ADM_Work__c.FieldSets.getMap().get(namespace + 'Additional_Fields').getFields();

        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        Schema.FieldSetMember f = listOfExpectedAdditionalFields.get(0);
        ADM_Additional_Field__c af = new ADM_Additional_Field__c();
        af.Field_API_Name__c = f.getFieldPath();
        af.Type__c = String.valueOf(f.Type);
        af.Name =  f.Label;
        af.Product_Tag__c = proTag.id;
        af.Bug_Setting__c = 'Visible';
        af.User_Story_Setting__c = 'Required' ;
        af.Investigation_Setting__c = 'Hidden';
        ApexPages.StandardController sc = new ApexPages.StandardController(af);
        ApexPages.currentPage().getParameters().put('id', proTag.id);
        ADM_AdditionalFieldsController ac = new ADM_AdditionalFieldsController(sc);
        ac.additionalFields.add(af);
        ac.save();

        List<ADM_Additional_Field__c> additionalFieldsQueried = [Select id, Field_API_Name__c,Product_Tag__c, Type__c, Bug_Setting__c, User_Story_Setting__c, Investigation_Setting__c from ADM_Additional_Field__c where Product_Tag__c =: proTag.id and Name = :f.Label];
        System.assertEquals(1,additionalFieldsQueried.size(),'Expected 1 record to be inserted');
        System.assertEquals(f.getFieldPath(),additionalFieldsQueried.get(0).Field_API_Name__c,'Expected 1 record to be inserted with the right field Api name');
        System.assertEquals('Required',additionalFieldsQueried.get(0).User_Story_Setting__c,'Expected 1 record to be inserted with the right User story setting');
        System.assertEquals('Visible',additionalFieldsQueried.get(0).Bug_Setting__c,'Expected 1 record to be inserted with the right bug setting');

    }
}