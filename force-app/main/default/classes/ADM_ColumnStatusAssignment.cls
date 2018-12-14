public with sharing class ADM_ColumnStatusAssignment {
	
	Static final String SELECT_CLAUSE = 'select Column__c, Work_Status__c, Work_Status__r.Name ';
	Static final String FROM_CLAUSE = ' from ADM_Column_Status_Assignment__c';
	Static final String COLUMN_WHERE_CLAUSE = ' Column__c ';
	Static final String TEAM_WHERE_CLAUSE = ' Column__r.Team__c ';

	public static List<ADM_Column_Status_Assignment__c> getAssignmentsByColumns(List<String> columnIds){
		String soql = '';
		soql += SELECT_CLAUSE;
		soql += FROM_CLAUSE;
		String inClause = COM_SoqlUtils.createInClause(COLUMN_WHERE_CLAUSE, columnIds);
		soql += ' where ' + inClause + ' order by Work_Status__r.Order__c ';
		List<ADM_Column_Status_Assignment__c> columnStatusMappings = Database.query(soql);
   		return columnStatusMappings;
	}

	public static List<ADM_Column_Status_Assignment__c> getAssignmentsByColumn(String columnId){
		List<String> columnIds = new List<String>{columnId};
		List<ADM_Column_Status_Assignment__c> columnStatusMappings = getAssignmentsByColumns(columnIds);
   		return columnStatusMappings;
	}

	public static List<ADM_Column_Status_Assignment__c> getAssignmentsFromColumnStatusMapping(Set<String> workStatusIds, Set<String> currentTeamIds){
		List<ADM_Column_Status_Assignment__c> columnStatusMapping = [select Column__c, Work_Status__c, Work_Status__r.Name from ADM_Column_Status_Assignment__c where Work_Status__c in :workStatusIds 
		                                                                                      and Column__r.Team__c in :currentTeamIds order by column__r.Parent_Column__c Nulls First, column__r.level__c, column__r.position__c];
		return columnStatusMapping;
	}

	public static List<ADM_Column_Status_Assignment__c> getAssignmentsByColumns(Set<String> columnIds){
		List<ADM_Column_Status_Assignment__c> columnStatusMapping = getAssignmentsByColumns(new List<String>(columnIds));
		return columnStatusMapping;
	}


	public static List<ADM_Column_Status_Assignment__c> getAssignmentsByTeams(Set<String> teamIds){
		String soql = '';
		soql += SELECT_CLAUSE;
		soql += FROM_CLAUSE;
		String inClause = COM_SoqlUtils.createInClause(TEAM_WHERE_CLAUSE, teamIds);
		soql += ' where ' + inClause + ' order by column__r.Parent_Column__c Nulls First, column__r.level__c, column__r.position__c ';
		List<ADM_Column_Status_Assignment__c> columnStatusMappings = Database.query(soql);
   		return columnStatusMappings;
	}

}