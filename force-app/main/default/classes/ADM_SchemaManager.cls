public with sharing class ADM_SchemaManager {
    static Map<String,SchemaObjectChecker> objectSchemaCheckerMap = new Map<String,SchemaObjectChecker>();
	private static Map<String, Schema.SObjectType> sobjectSchemaMap;


	//Retrieve the specific Schema.SobjectType for a object so we can inspect it
    private static Schema.SObjectType getObjectSchema(String objectAPIName)
    {
        if(sobjectSchemaMap == null)
        {
            sobjectSchemaMap = Schema.getGlobalDescribe();
        }
        Schema.SObjectType aSObjectType = sobjectSchemaMap.get(objectAPIName);
        if(aSObjectType == null) {
            aSObjectType = sobjectSchemaMap.get('' + objectAPIName);
        }
        return aSObjectType;
    }

    private static Schema.DescribeSObjectResult getObjectDescribe(String objectAPIName)
    {
        return getObjectSchema(objectAPIName).getDescribe();
    }

    /*

		As per documentation
		The map has the following characteristics:
		It is dynamic, that is, it is generated at runtime on the fields for that sObject.
		All field names are case insensitive.
		The keys use namespaces as required.
		The keys reflect whether the field is a custom object.

    */
    public static boolean areFieldsAccessible(String objectAPIName, Set<String>fields){
    	SchemaObjectChecker objectSchemaChecker = getObjectSchemaChecker(objectAPIName);
    	return objectSchemaChecker.checkAccess(fields);
    }

    public static boolean areFieldsUpdateable(String objectAPIName, Set<String>fields){
    	SchemaObjectChecker objectSchemaChecker = getObjectSchemaChecker(objectAPIName);
    	return objectSchemaChecker.checkUpdateable(fields);
    }

    public static boolean areFieldsCreateable(String objectAPIName, Set<String>fields){
    	SchemaObjectChecker objectSchemaChecker = getObjectSchemaChecker(objectAPIName);
    	return objectSchemaChecker.checkCreatable(fields);
    }

    public static boolean isObjectDeletable(String objectAPIName){
    	Schema.DescribeSObjectResult describeResult= getObjectDescribe(objectAPIName);
    	return describeResult.isDeletable();
    }

    public static boolean isObjectUpdateable(String objectAPIName){
    	Schema.DescribeSObjectResult describeResult= getObjectDescribe(objectAPIName);
    	return describeResult.isUpdateable();
    }

    public static boolean isObjectQueryable(String objectAPIName){
    	Schema.DescribeSObjectResult describeResult= getObjectDescribe(objectAPIName);
    	return describeResult.isQueryable();
    }

    public static Map<String, Schema.sObjectField> isObjectUpdateableReturnFieldsSchema(String objectAPIName){
    	if(isObjectUpdateable(objectAPIName)){
    		SchemaObjectChecker objectSchemaChecker = getObjectSchemaChecker(objectAPIName);
    		return objectSchemaChecker.getFieldsSchema();
    	}
    	else{
    		return null;
    	}
    }

    public static boolean isObjectCreateable(String objectAPIName){
    	Schema.DescribeSObjectResult describeResult= getObjectDescribe(objectAPIName);
    	return describeResult.isCreateable();
    }

    public static Map<String, Schema.sObjectField> isObjectCreateableReturnFieldsSchema(String objectAPIName){
    	if(isObjectCreateable(objectAPIName)){
    		SchemaObjectChecker objectSchemaChecker = getObjectSchemaChecker(objectAPIName);
    		return objectSchemaChecker.getFieldsSchema();
    	}
    	else{
    		return null;
    	}
    	
    }

    public static boolean isObjectUpsertable(String objectAPIName){
    	Schema.DescribeSObjectResult describeResult= getObjectDescribe(objectAPIName);
    	return describeResult.isCreateable() && describeResult.isUpdateable();
    }


   

    private static SchemaObjectChecker getObjectSchemaChecker(String objectAPIName){
    	SchemaObjectChecker objectSchemaChecker;
    	if(!objectSchemaCheckerMap.containsKey(objectAPIName.toLowerCase())){
    		if(objectAPIName.containsIgnoreCase('ADM_Work__c')){
    			objectSchemaChecker = new ADM_WorkSchemaChecker();
	    	}
    		else if(objectAPIName.containsIgnoreCase('ADM_Build__c')){
    			objectSchemaChecker = new ADM_BuildSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Theme__c')){
	    		objectSchemaChecker = new ADM_ThemeSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Release__c')){
	    		objectSchemaChecker = new ADM_ReleaseSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Sprint__c')){
	    		objectSchemaChecker = new ADM_SprintSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('User')){
	    		objectSchemaChecker = new UserSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Scrum_Team__c')){
	    		objectSchemaChecker = new ADM_ScrumTeamSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('Headcount__c')){
	    		objectSchemaChecker = new HeadCountSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Product_Tag__c')){
	    		objectSchemaChecker = new ADM_ProductTagSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Assignment_Rule__c')){
	    		objectSchemaChecker = new ADM_AssignmentRuleSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Bookmark__c')){
	    		objectSchemaChecker = new ADM_BookmarkSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_GUS_Exception__c')){
	    		objectSchemaChecker = new ADM_GUSExceptionSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Parent_Work__c')){
	    		objectSchemaChecker = new ADM_ParentWorkSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Priority_Override__c')){
	    		objectSchemaChecker = new ADM_PriorityOverrideSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Release_Burndown_Item__c')){
	    		objectSchemaChecker = new ADM_ReleaseBurndownItemSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Release_Event_Template__c')){
	    		objectSchemaChecker = new ADM_ReleaseEventTemplateSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Release_Event__c')){
	    		objectSchemaChecker = new ADM_ReleaseEventSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Released_In__c')){
	    		objectSchemaChecker = new ADM_ReleasedInChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Scrum_Team_Member__c')){
	    		objectSchemaChecker = new ADM_ScrumTeamMemberSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Tag_Assignment__c')){
	    		objectSchemaChecker = new ADM_TagAssignmentSchemaChecker();
	    	}
			else if(objectAPIName.containsIgnoreCase('ADM_Theme_Assignment__c')){
	    		objectSchemaChecker = new ADM_ThemAssignmentSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Work_Subscriber__c')){
	    		objectSchemaChecker = new ADM_WorkSubscriberSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_Answer__c')){
	    		objectSchemaChecker = new QAAnswerSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_Comment__c')){
	    		objectSchemaChecker = new QACommentSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_Default_Test_Case__c')){
	    		objectSchemaChecker = new QADefaultTestCaseSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_ExecutionBug__c')){
	    		objectSchemaChecker = new QAExecutionBugSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_FTest__c')){
	    		objectSchemaChecker = new QAFTestSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_Hierarchy__c')){
	    		objectSchemaChecker = new QAHierarchySchemaChecker();
	    	}
			else if(objectAPIName.containsIgnoreCase('QA_Question__c')){
	    		objectSchemaChecker = new QAQuestionSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_Test_Case__c')){
	    		objectSchemaChecker = new QATestCaseSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_Test_Execution__c')){
	    		objectSchemaChecker = new QATestExecutionSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('QA_Test_Plan__c')){
	    		objectSchemaChecker = new QATestPlanSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('eRelease_Request__c')){
	    		objectSchemaChecker = new eReleaseRequestSchemaChecker();
	    	}
	    	else if(objectAPIName.containsIgnoreCase('ADM_Task__c')){
	    		objectSchemaChecker = new ADM_TaskSchemaChecker();
	    	}

	    	if(null == objectSchemaChecker){
	    		throw new ADM_ApplicationException('Cannot instantiate SchemaObjectChecker');
	    	}
	    	objectSchemaCheckerMap.put(objectAPIName.toLowerCase(), objectSchemaChecker);
    	}
    	

    	return objectSchemaCheckerMap.get(objectAPIName.toLowerCase());

    }


    abstract class SchemaObjectChecker {
    	boolean hasPermission = true;
	    Map<String, Schema.sObjectField> fieldsSchemaMap;
    	public SchemaObjectChecker(){
    		fieldsSchemaMap = getFieldsSchema();
    	}
		
        boolean checkAccess(Set<String>fields){
			for(String field:fields){
    		    //field = ADM_TextUtils.makeQualifiedName(field);
			    Schema.DescribeFieldResult dr = fieldsSchemaMap.get(field).getDescribe();
			    if(dr.isPermissionable() && !dr.isCalculated() && !dr.isAccessible()){
			        System.debug('User has no access permission for field '+ field);
			    	hasPermission = false;
			    	break;
			    }
    		}
    		return hasPermission;
		}

		boolean checkUpdateable(Set<String>fields){
			for(String field:fields){
				
    		    //field = ADM_TextUtils.makeQualifiedName(field);
			    Schema.DescribeFieldResult dr = fieldsSchemaMap.get(field).getDescribe();
			    if(dr.isPermissionable() && !dr.isCalculated() && !dr.isUpdateable()){
			        System.debug('User has no update permission for field '+ field);
			    	hasPermission = false;
			    	break;
			    }
    		}
    		return hasPermission;
		}

		boolean checkCreatable(Set<String>fields){
			for(String field:fields){
    		    //field = ADM_TextUtils.makeQualifiedName(field);
			    Schema.DescribeFieldResult dr = fieldsSchemaMap.get(field).getDescribe();
			    if(dr.isPermissionable() && !dr.isCalculated() && !dr.isCreateable()){
			    	System.debug('User has no create permission for field '+ field);
			    	hasPermission = false;
			    	break;
			    }
    		}
    		return hasPermission;
		}

    	abstract Map<String, Schema.sObjectField> getFieldsSchema();
	}

	private class ADM_BuildSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Build__c.fields.getMap();
		}
	}

	private class ADM_ThemeSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Theme__c.fields.getMap();
		}
	}

	private class ADM_ReleaseSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Release__c.fields.getMap();
		}
	}

	private class ADM_SprintSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Sprint__c.fields.getMap();
		}
	}

	private class UserSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.User.fields.getMap();
		}
	}

	private class ADM_ScrumTeamSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Scrum_Team__c.fields.getMap();
		}
	}

	private class HeadCountSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.Headcount__c.fields.getMap();
		}
	}

	private class ADM_ProductTagSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Product_Tag__c.fields.getMap();
		}
	}

	private class ADM_WorkSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Work__c.fields.getMap();
		}
	}

	private class ADM_AssignmentRuleSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Assignment_Rule__c.fields.getMap();
		}
	}

	private class ADM_BookmarkSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Bookmark__c.fields.getMap();
		}
	}

	private class ADM_GUSExceptionSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_GUS_Exception__c.fields.getMap();
		}
	}

	private class ADM_ParentWorkSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Parent_Work__c.fields.getMap();
		}
	}

	private class ADM_PriorityOverrideSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Priority_Override__c.fields.getMap();
		}
	}

	private class ADM_ReleaseBurndownItemSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Release_Burndown_Item__c.fields.getMap();
		}
	}

	private class ADM_ReleaseEventTemplateSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Release_Event_Template__c.fields.getMap();
		}
	}

	private class ADM_ReleaseEventSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Release_Event__c.fields.getMap();
		}
	}

	private class ADM_ReleasedInChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Released_In__c.fields.getMap();
		}
	}

	private class ADM_ScrumTeamMemberSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Scrum_Team_Member__c.fields.getMap();
		}
	}

	private class ADM_TagAssignmentSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Tag_Assignment__c.fields.getMap();
		}
	}

	private class ADM_TaskSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Task__c.fields.getMap();
		}
	}

	private class ADM_ThemAssignmentSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Theme_Assignment__c.fields.getMap();
		}
	}

	private class ADM_WorkSubscriberSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.ADM_Work_Subscriber__c.fields.getMap();
		}
	}

	private class QAAnswerSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_Answer__c.fields.getMap();
		}
	}

	private class QACommentSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_Comment__c.fields.getMap();
		}
	}

	private class QADefaultTestCaseSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_Default_Test_Case__c.fields.getMap();
		}
	}

	private class QAExecutionBugSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_ExecutionBug__c.fields.getMap();
		}
	}

	private class QAFTestSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_FTest__c.fields.getMap();
		}
	}

	private class QAHierarchySchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_Hierarchy__c.fields.getMap();
		}
	}

	private class QATestCaseSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_Test_Case__c.fields.getMap();
		}
	}

	private class QAQuestionSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_Question__c.fields.getMap();
		}
	}

	private class QATestExecutionSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_Test_Execution__c.fields.getMap();
		}
	}

	private class QATestPlanSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.QA_Test_Plan__c.fields.getMap();
		}
	}

	private class eReleaseRequestSchemaChecker extends SchemaObjectChecker{
		override Map<String, Schema.sObjectField> getFieldsSchema(){
			return Schema.sObjectType.eRelease_Request__c.fields.getMap();
		}
	}
}