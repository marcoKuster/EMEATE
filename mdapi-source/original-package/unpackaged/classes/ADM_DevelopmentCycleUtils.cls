public abstract with sharing class ADM_DevelopmentCycleUtils {
	
	public static final String SELECT_CLAUSE = 'select Id, Scheduled_Build__c, Scrum_Team__c, Scheduled_Build__r.Name, Scrum_Team__r.Name  from ADM_Work__c';
	public static final String IGNORED_BUILDS = '\'internal\',\'store\',\'eclipse\',\'prodtest\',\'l10n\',\'pollmatic\',\'lp\',\'RB\'';
	public static final String IGNORED_CUSTOMERS_COMPLETE = '\'behind perm\', \'patch approved\', \'translation\'';
	public static final String IGNORED_CUSTOMERS_PARTIAL = '\'behind perm\', \'patch approved\'';
    private String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
	
	protected  List<SObject> countWorkRecordsMatchingCriteria(List<SObject> records, String q, String fieldNameWithTotal)	{
														
		
		Map<String, List<ADM_Work__c>> openRecs = new Map<String, List<ADM_Work__c>>();
		
		for(ADM_Work__c w : Database.query(q)) {
			openRecs = addWorkToMap(w, openRecs);
		}												
		
		for(SObject so: records) {  
			String buildKey = parseParentBuild((String)so.get('Build__c'));
			List<ADM_Work__c> openWork = openRecs.get(buildKey + '-' + so.get('Scrum_Team__c'));
			
			if(openWork != null && openWork.size() > 0) {
				so.put(fieldNameWithTotal, openWork.size());
			} else {
				so.put(fieldNameWithTotal, 0);
			}
		}
		
		return records;		
		
	}
	
	protected  List<SObject> countWorkRecordsMatchingCriteriaDividedByRole(List<SObject> records, String q, String fieldNameWithTotal, AggregateResult[] memberRoleCountByScrumTeam, String roleName, Map<Id, ADM_Scrum_Team__c> scrumTeamIDs)	{
														
		
		Map<String, List<ADM_Work__c>> openRecs = new Map<String, List<ADM_Work__c>>();
		
		for(ADM_Work__c w : Database.query(q)) {
			openRecs = addWorkToMap(w, openRecs);
		}												
														
		for(SObject so: records) {  
			String buildKey = parseParentBuild((String)so.get('Build__c'));
			List<ADM_Work__c> openWork = openRecs.get(buildKey + '-' + so.get('Scrum_Team__c'));
			if(openWork != null && openWork.size() > 0) {
				//divide total by number of users of specified role type (dev, qa etc)
				Integer roleCount = countMembersMatchingRoleAndScrumTeam(memberRoleCountByScrumTeam, roleName, String.valueOf(so.get('Scrum_Team__c')), scrumTeamIDs );
				Double result = 0;
				if(roleCount != 0) {
					result = openWork.size() / roleCount;	
				} else {
					result = openWork.size();
				}
				
				so.put(fieldNameWithTotal, result);
			} else {
				so.put(fieldNameWithTotal, 0);
			}
		}
		
		return records;		
		
	}
	
	
	protected  Map<String, List<ADM_Work__c>> addWorkToMap(ADM_Work__c w, Map<String, List<ADM_Work__c>> wmap) {
		//stats for patch released should be grouped with parent build
		String buildPrefix = '';
		
			
		if(w.Scheduled_Build__r.Name != null && w.Scheduled_Build__r.Name.contains('.')) {
			//must work fine for 174.1 174.2 etc but also AXM.174.1 and AXM.174.2 mentioned in AC for story W-922997
			//buildPrefix = w.Scheduled_Build__r.Name.substring(0, w.Scheduled_Build__r.Name.indexOf('.'));
			buildPrefix = parseParentBuild(w.Scheduled_Build__r.Name);
		} else {
			buildPrefix = w.Scheduled_Build__r.Name;
		}
				
		
		
		
		String key = buildPrefix + '-' + w.Scrum_Team__r.Name;
		if(wmap.containsKey(key)) {
			wmap.get(key).add(w);
		} else {
			wmap.put(key, new List<ADM_Work__c>{w});
		}
		
		return wmap;			
	}
	
	public Set<String> getDistinctStrings(List<SObject> records, String idFieldName) {
		Set<String> ids = new Set<String>();
		for(SObject s: records) {
			
			ids.add(String.valueOf(s.get(idFieldName)));
		}
		return ids;
	}
	
	public String addSingleQuotesToStringSet(Set<String> els) {
		String s = '';
		for(String e : els) {
			s = s + '\'' + String.escapeSingleQuotes(e) + '\',';
		}
		//strip trailing comma
		s = s.substring(0, s.length()-1);
		return s;
	}
	
	public String addSingleQuotesAndWildCardToStringSet(Set<String> els, String fieldName) {
		String s = '';
		for(String e : els) {
			if(s != '') {
				s = s + ' OR ';
			}
			s = s + String.escapeSingleQuotes(fieldName) + ' LIKE \'' + String.escapeSingleQuotes(e) + '%\'';
		}
		return s;
	}
	
	protected  AggregateResult[] getMemberRoleCountsGroupedByScrumTeam(Set<String> teamNames) {
		
        String sobjectTypeName = nameSpacePrefix + 'ADM_Scrum_Team_Member__c';

        String roleFieldOnScrumTeamMember = nameSpacePrefix + 'Role__c';
        
        String teamFieldOnScrumTeamMember = nameSpacePrefix + 'Scrum_Team__c';
        
        String teamForeignFieldOnScrumTeamMember = teamFieldOnScrumTeamMember.replace('__c', '__r');
		
        String soql = 'select count(Name), '+ roleFieldOnScrumTeamMember + ', ' + teamFieldOnScrumTeamMember +', '+
                                                                ' GROUPING(' + teamFieldOnScrumTeamMember +') grpTeam, GROUPING('+ roleFieldOnScrumTeamMember +') grpRole from ' + sobjectTypeName +  
                                                                ' where '+ teamForeignFieldOnScrumTeamMember +'.Name in:teamNames '+ 
                                                                'group by ROLLUP('+teamFieldOnScrumTeamMember+ ', '+ roleFieldOnScrumTeamMember + ')';
        AggregateResult[] memberRoleCountByScrumTeam = Database.query(soql);
        /*AggregateResult[] memberRoleCountByScrumTeam = [select COUNT(Name), gus__Role__c, gus__Scrum_Team__c, 
                                                                GROUPING(gus__Scrum_Team__c) grpTeam, GROUPING(gus__Role__c) grpRole  
                                                                from gus__ADM_Scrum_Team_Member__c 
                                                                where gus__Scrum_Team__r.Name in:teamNames
                                                                group by ROLLUP(gus__Scrum_Team__c, gus__Role__c)];*/
														
		return memberRoleCountByScrumTeam;												
		
	}
	
	
	protected  Integer countMembersMatchingRoleAndScrumTeam(AggregateResult[] memberRoleCountByScrumTeam, String role, String teamName, Map<Id, ADM_Scrum_Team__c> scrumTeamIDs) {
        String roleFieldOnScrumTeamMember = nameSpacePrefix + 'Role__c';
        String teamFieldOnScrumTeamMember = nameSpacePrefix + 'Scrum_Team__c';
		
		for(AggregateResult ar : memberRoleCountByScrumTeam) {
            ADM_Scrum_Team__c foundTeam = scrumTeamIDs.get(String.valueOf(ar.get(teamFieldOnScrumTeamMember)));
            if((foundTeam != null && foundTeam.Name == teamName) && (ar.get(roleFieldOnScrumTeamMember) == role) ) {
				return (Integer)ar.get('expr0');
			}
		}
		//nothing found 
		return 0;
	}
	
	private String parseParentBuild(String build) {
		String buildPrefix = '';
		try {
			buildPrefix = build.substring(0, build.indexOf('.'));
		} catch (Exception e) {
			
			buildPrefix = build;
		}
		return buildPrefix;		
	} 
	
	public static String getCustomReportIDByName(String reportName) { 
		String reportIdName = '';
		Custom_Report__c [] customReports = [select Report_ID__c from Custom_Report__c where Name = :reportName limit 1];
		if(customReports != null){
			reportIdName = customReports[0].Report_ID__c;
	}
		return reportIdName;
    }
}