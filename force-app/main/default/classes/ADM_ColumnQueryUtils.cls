public with sharing class ADM_ColumnQueryUtils {
	private static final String COLUMN_OBJECT = 'ADM_Column__c';
	private static final String COLUMN_SELECT = ' Select';
	private static final String COLUMN_FIELDS = ' c.Id, c.Name, c.Level__c, c.Max_Number_of_Records__c, c.Parent_Column__c, c.Parent_Column__r.Name, c.Position__c, c.Team__c';
	private static final String COLUMN_FROM = ' from ' + COLUMN_OBJECT + ' c' ;
	private static final String COLUMN_WHERE = ' where Active__c = true AND ' ;
	private static final String COLUMN_WHERE_TEAM_CLAUSE = ' c.Team__c ' ;
	private static final String COLUMN_ORDER_CLAUSE = ' c.Parent_Column__c Nulls First, c.level__c, c.position__c ' ;

	public static List<ADM_Column__c> getColumnsByTeam(String teamId){
		List<String> teamIds = new List<String>();
		teamIds.add(teamId);
		return getColumnsByTeams(teamIds);
	}

	public static List<ADM_Column__c> getColumnsByTeams(List<String> teamIds){
		List<ADM_Column__c> returnList = new List<ADM_Column__c>();
		String inClause = COM_SoqlUtils.createInClause(COLUMN_WHERE_TEAM_CLAUSE, teamIds);
		String columnSOQL = getColumnSOQL();
		columnSOQL += inClause;
		returnList = queryColumns(columnSOQL);
		
		
		return returnList;
	}

	public static List<ADM_Column__c> getColumnsByTeams(Set<String> teamIds){
		return getColumnsByTeams(new List<String>(teamIds));
	}

	public static List<ADM_Column__c> getColumnsFromThisPositionAndAbove(String teamId, String parentId, Decimal levelBeforeUpdate, Decimal positionBeforeUpdate){
		List<ADM_Column__c> returnList = new List<ADM_Column__c>();
		String columnSOQL = getColumnSOQL();
		if(null != parentId){
			columnSOQL += ' Parent_Column__c = ' + '\''+parentId + '\'';
		}
		else{
			columnSOQL += ' Parent_Column__c = null ';
		}

		columnSOQL += ' AND Level__c = ' + levelBeforeUpdate;
		columnSOQL += ' AND Position__c >= ' + positionBeforeUpdate; 
		columnSOQL += ' AND Team__c =' + '\''+teamId + '\'';
		columnSOQL += ' Order by Position__c asc ';
		returnList = queryColumns(columnSOQL);
		
		return returnList;

	}


	public static List<ADM_Column__c> getColumnsFromThisLevelAndAbove(String teamId, String parentId, Decimal levelBeforeUpdate){
		List<ADM_Column__c> returnList = new List<ADM_Column__c>();
		String columnSOQL = getColumnSOQL();
		if(null != parentId){
			columnSOQL += ' Parent_Column__c = ' + '\''+parentId + '\'';
		}
		else{
			columnSOQL += ' Parent_Column__c = null ';
		}

		columnSOQL += ' AND Level__c >= ' + levelBeforeUpdate;
		columnSOQL += ' AND Team__c =' + '\''+teamId + '\'';
		columnSOQL += ' Order by Level__c asc ';
		returnList = queryColumns(columnSOQL);
		
		return returnList;

	}

	public static List<ADM_Column__c> getColumnsByParents(Set<Id> parentIds){
		List<Id> parentIdList = new List<Id>(parentIds);
		List<ADM_Column__c> returnList = new List<ADM_Column__c>();
		String columnSOQL = getColumnSOQL();
		String inClause = COM_SoqlUtils.createInClause('Parent_Column__c', parentIdList);
		columnSOQL += inClause;
		returnList = queryColumns(columnSOQL);
		
		return returnList;

	}

	private static String getColumnSOQL(){
		//Check SObject Accessiblity before doing any work on SOQL query
		Boolean isObjectAccessible = COM_SoqlUtils.checkObjectAccessibility(COLUMN_OBJECT);
		if(isObjectAccessible){
			String column_soql = COLUMN_SELECT + COLUMN_FIELDS + COLUMN_FROM + COLUMN_WHERE;
			return column_soql;
		}
		else{
			throw new ADM_ApplicationException('Insufficient access to ' + COLUMN_OBJECT);
		}
	}

	private static List<ADM_Column__c> queryColumns(String columnSOQL){
		List<ADM_Column__c> columns = Database.query(columnSOQL);
		return columns;
	}

	
}