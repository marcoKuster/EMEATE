trigger ADM_ScrumTeam on ADM_Scrum_Team__c (before insert, before update, after delete, after insert, after update) {
	ADM_ScrumTeamUtils stu = new ADM_ScrumTeamUtils();
	String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
	List<ADM_Scrum_Team__c> teamsActivatingKanban = new List<ADM_Scrum_Team__c>();
	Set<String> nameSet = new Set<String>();
	if(Trigger.isBefore) {
		stu.validateStoryPoints(Trigger.new);
	}

	//Check for DOD and DOR fields to update checkbox based on null/not null
	if(Trigger.isBefore){

		for(Integer i = 0; i < Trigger.new.size(); i++) {
			if(!ADM_TextUtils.isBlank(Trigger.new.get(i).Definition_of_Done__c)){
				Trigger.new.get(i).Definition_of_Done_Check__c = true;
			}
			else{ 
				Trigger.new.get(i).Definition_of_Done_Check__c = false;
			}



			if(!ADM_TextUtils.isBlank(Trigger.new.get(i).Definition_of_Ready__c)){
				Trigger.new.get(i).Definition_of_Ready_Check__c = true;
			}
			else{ 
				Trigger.new.get(i).Definition_of_Ready_Check__c = false;
			}

		}
	}

	if(Trigger.isBefore && Trigger.isUpdate) {
		//collect team IDs being deactivated
		List<Id> deactivatedTeams = new List<Id>();
		for(Integer i = 0; i < Trigger.new.size(); i++) {
            if(Trigger.new.get(i).Name.containsIgnoreCase('inactive')||Trigger.new.get(i).Name.containsIgnoreCase('Do not use')||Trigger.new.get(i).Name.containsIgnoreCase('Donotuse')||Trigger.new.get(i).Name.containsIgnoreCase('in active')||Trigger.new.get(i).Name.containsIgnoreCase('in-active')){
                Trigger.new.get(i).addError('If you are trying to inactivate the team please uncheck the active checkbox. This will prevent new work being assigned to this team.');
            }
			if(Trigger.New.get(i).Active__c == false && Trigger.Old.get(i).Active__c == true) {
				//store id
				deactivatedTeams.add(Trigger.New.get(i).Id);
			}
			if(Trigger.New.get(i).Kanban__c == true &&  Trigger.Old.get(i).Kanban__c == false) {
				teamsActivatingKanban.add(Trigger.New.get(i));
			}

			if(Trigger.New.get(i).Name !=  Trigger.Old.get(i).Name) { // Only if team name changed
				String newName = Trigger.New.get(i).Name;
				if(nameSet.contains(newName)){
					Trigger.New.get(i).addError('Team name duplicated in the list, please avoid duplicate names');
				}
				else{
					nameSet.add(newName);
				}
			}

		}
		
		Map<String, String> usedTeamNamesIdMap = ADM_ScrumTeam.findUsedTeamNames(nameSet);
        
		Map<String, String> teamOldNameIdMap = new Map<String, String>();
		String teamNameBeforeChange;
		
			for(ADM_Scrum_Team__c team : Trigger.New){
				teamNameBeforeChange = Trigger.oldMap.get(team.Id).Name;
				boolean recordTeamNameHistory = team.Name !=  Trigger.oldMap.get(team.Id).Name; //Record team name change
				System.debug(' team name change ' + team.Name+','+Trigger.oldMap.get(team.Id).Name);
				if(usedTeamNamesIdMap != null && usedTeamNamesIdMap.size() >0){
					if(usedTeamNamesIdMap.containsKey(team.Name.toLowerCase())){
						String usedByTeamName = usedTeamNamesIdMap.get(team.Name.toLowerCase());// Team name will be unique so can be used as a key.
						if(!usedByTeamName.equalsIgnoreCase(teamNameBeforeChange)){
							recordTeamNameHistory = false; //Team name change not allowed, no need to record this name in history.
							team.addError(' Team name "'+ team.Name + '" was used by ' + usedByTeamName + ' Team in the past, please select a different Name');
						}
						
					}
				}
				if(recordTeamNameHistory){
					teamOldNameIdMap.put(teamNameBeforeChange, team.Id);
				}
			}
		
		

		if(teamOldNameIdMap != null && teamOldNameIdMap.size() > 0){
			ADM_ScrumTeam.recordTeamNameChange(teamOldNameIdMap);
		}

		//check if teams have open work - group into one query
		AggregateResult[] workRecordsByTeam = [select Scrum_Team__c, COUNT(Name)
											from ADM_Work__c where Closed__c = 0 and Scrum_Team__c in :deactivatedTeams
											group by Scrum_Team__c];

		for(AggregateResult ar : workRecordsByTeam) {
			//add error for any open work found assigned to team being deactivated
			Id teamID = (Id)ar.get(nameSpacePrefix + 'Scrum_Team__c');
			Trigger.newMap.get(teamID).addError('There are ' + ar.get('expr0') + ' open records assigned to this team.  Please close or re-assign these records before de-activating the team.');
		}
	}

	/* 

	   Have to repeat some of the code used for Update logic for insert also because trying to merge insert and update logic
	   is more complicated and risky as update section does more than Team name validation.

	*/
	if(Trigger.isBefore && Trigger.isInsert) {
		for(ADM_Scrum_Team__c team : Trigger.New){
			nameSet.add(team.Name);
		}
		Map<String, String> usedTeamNamesIdMap = ADM_ScrumTeam.findUsedTeamNames(nameSet);
		for(ADM_Scrum_Team__c team : Trigger.New){
			if(usedTeamNamesIdMap.containsKey(team.Name.toLowerCase())){
				String usedByTeamName = usedTeamNamesIdMap.get(team.Name.toLowerCase());
				team.addError(' Team name "'+ team.Name + '" was used by ' + usedByTeamName + ' Team in the past, please select a different Name');
			}
		}

	}

	if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			//don't create public groups for Agile Accelerator package
			if(!ADM_ConstantsSingleton.getInstance().isPackagedOrg() || Test.isRunningTest()) {
				ADM_ScrumTeamUtils.createPublicGroupsForTeams(Trigger.new);
			}

			for(Integer i = 0; i < Trigger.new.size(); i++) {
				if(Trigger.New.get(i).Kanban__c == true){
					teamsActivatingKanban.add(Trigger.New.get(i));
				}
			}
		} else if(Trigger.isDelete) {
            ADM_ScrumTeamUtils.deletePublicGroupsForTeams(Trigger.old);
		}
			}

	if(teamsActivatingKanban.size() > 0){
		ADM_ColumnUtility.createDefaultColumns(teamsActivatingKanban); //Setting initial columns for Kanban Board Controller.
		ADM_Color.createDefaultColors(teamsActivatingKanban);
	}

	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		stu.setExternalId(Trigger.New);
	}

	// After the update check to see if 
	// the Capex flag went from true to fase
	if(Trigger.isAfter && Trigger.isUpdate) {        
	    
        ADM_Scrum_Team__c[] updatedTeamArray = Trigger.New;
	    ADM_Scrum_Team__c[] oldTeamArray = Trigger.Old;

        
	    // Build a map of the old values
	    Map<Id,ADM_Scrum_Team__c> oldTeamMap = new Map<Id,ADM_Scrum_Team__c>();  
        for ( ADM_Scrum_Team__c teamOld : oldTeamArray ){
			oldTeamMap.put( teamOld.Id, teamOld );
	    }

	    List<Id> teamIdList = new List<Id>();
            
	    for ( ADM_Scrum_Team__c updatedTeam : updatedTeamArray ){	
            ADM_Scrum_Team__c oldTeam = oldTeamMap.get(updatedTeam.Id);
				if ( oldTeam.Capex_Enabled__c == true && updatedTeam.Capex_Enabled__c == false ){
                    teamIdList.add(updatedTeam.Id); 
				}
	    }

	    // If the ID list isn't empty send it to the capex utiltity
	    if ( teamIdList.size() > 0)
		    ADM_CapexUtility.removeAllCapexFlagsForOpenItems(teamIdList);
	}

}