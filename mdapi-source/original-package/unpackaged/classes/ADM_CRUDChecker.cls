public with sharing class ADM_CRUDChecker {
	private final String objectAPIName;
	Set<String> fieldsToCheck = new Set<String>();
	private boolean isInsertTrigger = false;
	private boolean isUpdateTrigger = false;
	private boolean isDeleteTrigger = false;
	public ADM_CRUDChecker(String objectAPIName) {
		this.objectAPIName = objectAPIName;
	}

	public boolean checkPermsBeforeDML(boolean isInsert, boolean isUpdate, boolean isDelete, List<SObject> newSObjects, Map<Id, SObject> oldSObjectsMap){
		System.debug(' Check started for ' + objectAPIName);
		boolean permissionCheckResult = false;
		this.isInsertTrigger = isInsert;
		this.isUpdateTrigger = isUpdate;
		this.isDeleteTrigger = isDelete;
		permissionCheckResult = checkObjectPermissionAndFLS(newSObjects, oldSObjectsMap);
		return permissionCheckResult;
	}

	private boolean checkObjectPermissionAndFLS(List<SObject> newSObjects, Map<Id, SObject> oldSObjectsMap){
		boolean resultOnPermissionCheck = false;
		if(isDeleteTrigger){


			//Trigger is delete
				resultOnPermissionCheck = ADM_SchemaManager.isObjectDeletable(objectAPIName);
			
		}
		else {
			    //If Trigger is not delete it is insert or update
			 
			 	Map<String, Schema.sObjectField> fieldsSchemaMap = null;
			 	

				// Checking Object Create Permission for the user
				if(isInsertTrigger){
					//Insert trigger
				 	fieldsSchemaMap = ADM_SchemaManager.isObjectCreateableReturnFieldsSchema(objectAPIName);
				}
				else{
					    //Trigger is update
						fieldsSchemaMap = ADM_SchemaManager.isObjectUpdateableReturnFieldsSchema(objectAPIName);
				}
				if(null != fieldsSchemaMap){
					System.debug(' fieldSchemaMap is not null');
					resultOnPermissionCheck = checkFLS(fieldsSchemaMap, newSObjects, oldSObjectsMap);
				}

			
	    }
		

		
		return resultOnPermissionCheck;
	}

	private boolean checkFLS(Map<String, Schema.sObjectField> fieldsSchemaMap, List<SObject> newSObjects, Map<Id, SObject> oldSObjectsMap){

		/*
		      Checking FLS on fields 


		*/
		if( null != fieldsSchemaMap){
				for(SObject newSObject: newSObjects){
					for(String fieldName: fieldsSchemaMap.keySet()){
						if(isInsertTrigger){
							if(newSObject.get(fieldName) != null){
								fieldsToCheck.add(fieldName);
							}
						}
						else{
							SObject oldSObject = oldSObjectsMap.get(newSObject.Id);
							if(oldSObject.get(fieldName) != newSObject.get(fieldName)){
								fieldsToCheck.add(fieldName);
							}

						}
					}
				}
				
				
		}
		if(isInsertTrigger){
		    System.debug(' Checking field create permission for ' + objectAPIName);
			return ADM_SchemaManager.areFieldsCreateable(objectAPIName, fieldsToCheck);
		}
		else{
			System.debug(' Checking field update permission for ' + objectAPIName);
			return ADM_SchemaManager.areFieldsUpdateable(objectAPIName, fieldsToCheck);
		}
	}

}