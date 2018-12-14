@isTest
private class COM_SoqlUtilsTest {
    static Map<String, String> expectedSOQLMap = new Map<String,String>();
	static{
		if((ADM_ConstantsSingleton.getInstance()).isPackagedOrg()){
			expectedSOQLMap.put('expectedSqlWithCustomFields','select Id, Subject__c, Status__c, Story_Points__c, Theme__c, Scheduled_Build__c, Assignee__c, Scrum_Team__c, Sprint__c, LastModifiedDate from ADM_Work__c' );
			expectedSOQLMap.put('expectedSqlWithNoCustomFields','select Id, Name, LastModifiedDate from User' );
			expectedSOQLMap.put('expectedSqlWithRelationship','select id, Name, Subject__c, Status__c, Priority__c, Theme__r.Name, Scheduled_Build__r.Name, Sprint__r.Name, Sprint__c, Closed__c, Use_Prioritizer__c, RecordType.name from ADM_Work__c where Scrum_Team__c = :sprint.Scrum_Team__c and Sprint__c != :sprintID and Closed__c = 0 and Use_Prioritizer__c = true and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME order by Priority_Rank__c, Id  nulls first limit 1000' );
			expectedSOQLMap.put('expecteSqlWithCustomFieldAndObjectNameContainingSameField', 'select Id, Name, Work__c, Task__c, LastModifiedDate from ADM_Deleted_Task__c');
		}
	}
	
	@isTest static void testMakeQualifiedQuery() {
		String sqlWithCustomFields = 'select Id, Subject__c, Status__c, Story_Points__c, Theme__c, Scheduled_Build__c, Assignee__c, Scrum_Team__c, Sprint__c, LastModifiedDate from ADM_Work__c';
		String actualSql = COM_SoqlUtils.makeQualifiedQuery(sqlWithCustomFields);
		String expectedSql = getExpectedSOQL('expectedSqlWithCustomFields');

		if(null == expectedSql){ // If this is null then this org is not a packaged or No NameSpace exist in this org
			expectedSql = sqlWithCustomFields;
		}

		System.assertEquals(expectedSql,actualSql,'Converted soql didn\'t match expected soql');

		String sqlWithNoCustomFields = 'select Id, Name, LastModifiedDate from User';
		actualSql = COM_SoqlUtils.makeQualifiedQuery(sqlWithNoCustomFields);
		expectedSql = getExpectedSOQL('expectedSqlWithNoCustomFields');

		if(null == expectedSql){ // If this is null then this org is not a packaged or No NameSpace exist in this org
			expectedSql = sqlWithNoCustomFields;
		}

		System.assertEquals(expectedSql,actualSql,'Converted soql didn\'t match expected soql');

		String sqlWithRelationship = 'select id, Name, Subject__c, Status__c, Priority__c, Theme__r.Name, Scheduled_Build__r.Name, Sprint__r.Name, Sprint__c, Closed__c, Use_Prioritizer__c, RecordType.name from ADM_Work__c where Scrum_Team__c = :sprint.Scrum_Team__c and Sprint__c != :sprintID and Closed__c = 0 and Use_Prioritizer__c = true and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME order by Priority_Rank__c, Id  nulls first limit 1000';
		actualSql = COM_SoqlUtils.makeQualifiedQuery(sqlWithRelationship);
		
		expectedSql = getExpectedSOQL('expectedSqlWithRelationship');

		if(null == expectedSql){ // If this is null then this org is not a packaged or No NameSpace exist in this org
			expectedSql = sqlWithRelationship;
		}

		System.assertEquals(expectedSql,actualSql,'Converted soql didn\'t match expected soql');

		String sqlWithCustomFieldAndObjectNameContainingSameField = 'select Id, Name, Work__c, Task__c, LastModifiedDate from ADM_Deleted_Task__c';
		actualSql = COM_SoqlUtils.makeQualifiedQuery(sqlWithCustomFieldAndObjectNameContainingSameField);
		
		expectedSql = getExpectedSOQL('expecteSqlWithCustomFieldAndObjectNameContainingSameField');

		if(null == expectedSql){ // If this is null then this org is not a packaged or No NameSpace exist in this org
			expectedSql = sqlWithCustomFieldAndObjectNameContainingSameField;
		}

		System.assertEquals(expectedSql,actualSql,'Converted soql didn\'t match expected soql');
	}

	private static String getExpectedSOQL(String expectedQueryName){
		return expectedSOQLMap.get(expectedQueryName);
	}
	
}