public with sharing class ADM_TagAssignment {
    
    /**
     * Gets a list of all Tag Assignments that are associated to the specified 
     * product tag IDs. 
     */
    public static List<ADM_Tag_Assignment__c> getAllWhereProductTagIdEquals(List<String> tagIds) {
        List<ADM_Tag_Assignment__c> assignments = [select Id, Name, Assignment_Rule__c, Product_Tag__c, Record_Type__c from ADM_Tag_Assignment__c where Product_Tag__c in :tagIds];
        return assignments;
    }
    
    public static ADM_Tag_Assignment__c createAndInsertTagAssignment(ADM_Product_Tag__c tag, RecordType rType){
        ADM_Tag_Assignment__c tagAsgnmt = new ADM_Tag_Assignment__c();
        tagAsgnmt.Product_Tag__c = tag.id;
        tagAsgnmt.Record_Type__c = rType.Name;
        
        insert tagAsgnmt;
        return tagAsgnmt;
    }
    
}