trigger ADM_ColorTrigger on ADM_Color__c (after delete) {
	Set<String> teamIdsOfDeletedColors = new Set<String>();
	for(ADM_Color__c oldColor: Trigger.old){
		teamIdsOfDeletedColors.add(oldColor.Team__c);
	}


    //Now check if all colors were deleted from Teams if so add back default colors.
	List<ADM_Color__c> teamColors = ADM_Color.getTeamColors(teamIdsOfDeletedColors);

    for(ADM_Color__c teamColor : teamColors){
    	teamIdsOfDeletedColors.remove(teamColor.Team__c);
    }

    if(teamIdsOfDeletedColors.size() > 0 ){
    	ADM_Color.createDefaultColorsFromTeamIds(teamIdsOfDeletedColors);
    }

}