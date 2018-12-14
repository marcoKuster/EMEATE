public with sharing class ADM_SearchWork {
	public static final String DEFAULT_FIELDS =
         'Id, '+
         'Name, ' +
         'Subject__c, ' +
         'Priority__c, ' +
         'Type__c, ' +
         'Product_Tag__c, ' +
         'Product_Tag_Name__c, ' +
         'Description__c,' +
         'Details__c, ' +
         'Details_and_Steps_to_Reproduce__c, ' +
         'Scheduled_Build__c, ' +
         'Scheduled_Build_Name__c, ' +
         'Customer__c, ' +
         'Assignee__c, ' +
         'Assignee__r.Name, ' +
         'Scrum_Team__c, ' +
         'Scrum_Team_Name__c, ' +
         'Status__c';
    
 	public static String searchWork(
	        String text,
        	String fields,
    	    String workId,
        	String subject, 
			String recordType,
			String tag,
			String status,
			String assignedTo, 
			String priority,
			String team,
			String scheduledBuild,
			String lastModified) {
                return ADM_SearchWork.searchWork(text, fields, workId, subject, recordType, tag, status, assignedTo, '', priority, team, scheduledBuild, lastModified);
            }

 	public static String searchWork(
	        String text,
        	String fields,
    	    String workId,
        	String subject, 
			String recordType,
			String tag,
			String status,
			String assignedTo, 
			String customer, 
			String priority,
			String team,
			String scheduledBuild,
			String lastModified) {

        if (String.isBlank(fields)) {
            fields = DEFAULT_FIELDS;
        }
		String clause = '';
		clause = addClause(clause, 'name', workId);
		clause = addClause(clause, 'subject__c', subject);
		clause = addClause(clause, 'type__c', recordType, false);
		clause = addClause(clause, 'Product_Tag_Name__c', tag);
		clause = addClause(clause, 'Status__c', status, false);
		clause = addClause(clause, 'Assignee__r.name', assignedTo);
		clause = addClause(clause, 'Customer__c', customer);
		clause = addClause(clause, 'Priority__c', priority, false);
		clause = addClause(clause, 'Scrum_Team__r.name', team);
		clause = addClause(clause, 'Scheduled_Build_Name__c', scheduledBuild);
		clause = addClause(clause, 'DAY_ONLY(LastModifiedDate)', lastModified, false, false);
		clause += ' LIMIT 200';
		text = String.escapeSingleQuotes(text);
		
        String s = 'FIND \'' + text + '\' IN ALL FIELDS RETURNING ADM_Work__c(' + fields + clause + ')';
		return s;
	}

	private static String addClause(String clause, String name, String value) {
		return addClause(clause, name, value, true);
	}
	
	private static String addClause(String clause, String name, String value, boolean likeClause) {
        return addClause(clause, name, value, likeClause, true);
    }
    
	private static String addClause(String clause, String name, String value, boolean likeClause, boolean quoteValue) {
		if (String.isNotBlank(value)) {
			String suffix = likeClause ? '%' : '';
			String operator = likeClause ? 'LIKE' : '=';
			String start = String.isNotBlank(clause) ? ' AND ' : ' WHERE ';
            String quote = quoteValue ? '\'' : '';
			return clause + start + name + ' ' + operator +  ' ' 
                + quote +  String.escapeSingleQuotes(value) + suffix  + quote;
		}
		return clause;
	}
    
 	public static String queryWork(
	        String text,
        	String fields,
    	    String workId,
        	String subject, 
			String recordType,
			String tag,
			String status,
			String assignedTo, 
			String customer, 
			String priority,
			String team,
			String scheduledBuild,
			String lastModified) 
    {
        
        if (String.isBlank(fields)) {
            fields = DEFAULT_FIELDS;
        }
		String clause = '';
		clause = addClause(clause, 'name', workId);
		clause = addClause(clause, 'subject__c', subject);
		clause = addClause(clause, 'type__c', recordType, false);
		clause = addClause(clause, 'Product_Tag_Name__c', tag);
		clause = addClause(clause, 'Status__c', status, false);
		clause = addClause(clause, 'Assignee__r.name', assignedTo);
		clause = addClause(clause, 'Customer__c', customer);
		clause = addClause(clause, 'Priority__c', priority, false);
		clause = addClause(clause, 'Scrum_Team__r.name', team);
		clause = addClause(clause, 'Scheduled_Build_Name__c', scheduledBuild);
		clause = addClause(clause, 'DAY_ONLY(LastModifiedDate)', lastModified, false, false);
		clause += ' LIMIT 200';
		text = String.escapeSingleQuotes(text);
		
        String q = 'Select ' + fields + ' FROM ADM_Work__c ' + clause;
        return q;
	}
}