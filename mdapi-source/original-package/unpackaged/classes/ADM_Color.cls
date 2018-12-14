public with sharing class ADM_Color {
	private static final String SELECT_CLAUSE = 'Select Name, Color__c, Order__c, Team__c ';
	private static final String FROM_CLAUSE = ' from ADM_Color__c ';
	private static final String WHERE_CLAUSE = ' where Active__c = true and ';
	private static final String ORDER_CLAUSE = ' order by Order__c  ';

	public static List<ADM_Color__c> getTeamColors(String teamId){
		return getTeamColors(new List<String>{teamId});
	}

	public static List<ADM_Color__c> getTeamColors(Set<String> teamIds){
		return getTeamColors(new List<String>(teamIds));
	}

	public static List<ADM_Color__c> getTeamColors(List<String> teamIds){
		String soql = SELECT_CLAUSE + FROM_CLAUSE;
		String inClause = '';
		if(teamIds != null && teamIds.size() > 0){
			inClause = COM_SoqlUtils.createInClause('Team__c' , teamIds);
		}

		if(inClause != null && inClause != ''){
			soql += WHERE_CLAUSE + inClause;
		}

		soql += ORDER_CLAUSE;

		return Database.query(soql);


	}

	public static List<ADM_Color__c> getColorsById(List<String> colorIds){
		String soql = SELECT_CLAUSE + FROM_CLAUSE;
		String inClause = '';
		if(colorIds != null && colorIds.size() > 0){
			inClause = COM_SoqlUtils.createInClause('Id' , colorIds);
		}
		else{
			return null;
		}

		if(inClause != null && inClause != ''){
			soql += WHERE_CLAUSE + inClause;
		}

		soql += ORDER_CLAUSE;

		return Database.query(soql);


	}


	public static ADM_Color__c createColor(String name, String colorHex, String teamId, Decimal order){
		ADM_Color__c color = new ADM_Color__c();
		color.Name = name;
		color.Color__c= colorHex;
		color.Team__c = teamId;
		color.Order__c = order;

		return color;
	}


	public static List<ADM_Color__c> createDefaultColors(List<ADM_Scrum_Team__c> teams){
		List<ADM_Color__c> colors = new List<ADM_Color__c>();
		for(ADM_Scrum_Team__c team: teams){
			ADM_Color__c blue = createColor('Blue', '#0079BF', team.Id, 1);
			ADM_Color__c purple = createColor('Purple', '#C377E0', team.Id, 2);
			ADM_Color__c red = createColor('Red', '#EB5A46', team.Id, 3);
			ADM_Color__c orange = createColor('Orange', '#FF9F1A', team.Id, 4);
			ADM_Color__c yellow = createColor('Yellow', '#F2D600', team.Id, 5);
			ADM_Color__c green = createColor('Green', '#70B500', team.Id, 6);

			colors.add(blue);
			colors.add(purple);
			colors.add(red);
			colors.add(orange);
			colors.add(yellow);
			colors.add(green);
		}
		insert colors;

		return colors;
	}

	public static List<ADM_Color__c> createDefaultColorsFromTeamIds(List<String> teamIds){
		List<ADM_Color__c> colors = new List<ADM_Color__c>();
		for(String teamId: teamIds){
			ADM_Color__c blue = createColor('Blue', '#0079BF', teamId, 1);
			ADM_Color__c purple = createColor('Purple', '#C377E0', teamId, 2);
			ADM_Color__c red = createColor('Red', '#EB5A46', teamId, 3);
			ADM_Color__c orange = createColor('Orange', '#FF9F1A', teamId, 4);
			ADM_Color__c yellow = createColor('Yellow', '#F2D600', teamId, 5);
			ADM_Color__c green = createColor('Green', '#70B500', teamId, 6);

			colors.add(blue);
			colors.add(purple);
			colors.add(red);
			colors.add(orange);
			colors.add(yellow);
			colors.add(green);
		}
		insert colors;

		return colors;
	}

	public static List<ADM_Color__c> createDefaultColorsFromTeamIds(Set<String> teamIds){
		return createDefaultColorsFromTeamIds(new List<String>(teamIds));
	}


	
}