trigger ADM_TaskTrigger on ADM_Task__c (after delete, after insert, after update, before delete, before insert, before update) {

	Map<Id, ADM_Task__c> oldMap;
	Map<Id, ADM_Task__c> newMap;
	Map<Id, ADM_Task__c> modedNewMap;
	ADM_Task__c[] insertTasks;
	ADM_SprintBurnDownUtils SBU = new ADM_SprintBurnDownUtils();

	/**
		Validate that tasks are not assigned to work template record type
	**/
	List<String> workIDs = new List<String>();
	List<Id> assigneeIds = new List<Id>();

	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
		for (ADM_Task__c t: Trigger.new ) {
			//store work IDs for bulk lookup so that we can validate none are templates
			workIDs.add(t.Work__c);
			//store Assigned_To__c Ids for bulk lookup because fields such as task.Assigned_To.* are not populated in this scope
			assigneeIds.add(t.Assigned_To__c);
		}
		//bulk lookup work
		Map<Id, ADM_Work__c> workMap = ADM_Work.getAllByAsMap('id', workIDs, 0, 1000, 'id', 'asc');
		//bulk lookup assignees
		Map<Id,User> assigneeById = new Map<Id,User>([SELECT Id, EmployeeNumber, IsActive FROM User WHERE Id IN :assigneeIds]);
		/*
		   Following loop do two things
		   	1) if work has been found loop tasks and evaluate t.Work__c record type
		   	2) if the Task record is set to status compeleted and actual_hours__c is null or 0.0, then copy starting_hours__c to actual_hours__c
		*/
		if(workMap != null) {
            for(Integer i=0; i < Trigger.New.size(); i++) {
            	ADM_Task__c t = Trigger.New[i];
				ADM_Work__c w = workMap.get(t.Work__c);
				User user = assigneeById.get(t.Assigned_To__c);

				if(w != null) {
					if(w.RecordType.Name == ADM_Work.TEMPLATE_RECORD_TYPE_NAME) {
						//add error at the field level
						t.Work__c.addError('Error:Tasks cannot be assigned to work templates.');
					}

					if (t.Capex_Enabled__c == true && w.Capex_Enabled__c == false) {
						t.addError('A user story that is not a New Customer Facing Feature cannot contain Quality tasks.');
					}

					if(t.Capex_Enabled__c == true && user != null && (user.EmployeeNumber == null || user.EmployeeNumber.equalsIgnoreCase('tbd') || !user.IsActive)) {
                        t.addError(ADM_Task.TASK_ERROR_NONEMPLOYEE.replace('<0>', t.Subject__c));
                    }

				}

                try{
	                if((w.Sprint__c != t.SprintId__c) && (w.Sprint__c != null)){
	                	t.sprintId__c = w.Sprint__c;
	                }
            	}
            	catch(Exception e){
            		ADM_ExceptionHandler.saveException(e, 'Task Trigger exception while saving sprintId from Work');
            	}

				if(t.status__c.equalsIgnoreCase('Completed') && (t.Actual_Hours__c == NULL || t.Actual_Hours__c == 0.0) && (t.Capex_Enabled__c != true)){//Only do this if Capex is not enabled on this Task
					t.Actual_Hours__c = t.Starting_Hours__c;
				}
			}

		}
	}

	if(Trigger.isInsert && Trigger.isBefore) {
        
	        for (ADM_Task__c t: Trigger.new ){
			t.Starting_Hours__c = t.Hours_Remaining__c;
		    
			// If a new task is marked completed, then mark completed on date
			if(t.Status__c == 'Completed' ){
				t.Completed_On__c = DateTime.now();
			}
		}

	} else if ( Trigger.isInsert && Trigger.isAfter ) {
		insertTasks = Trigger.new;


		ADM_Work__c[] stories = SBU.getStories(insertTasks);

		if(stories != null) {
			Set<Id> sprintsToUpdate = new Set<Id>();
			for (ADM_Work__c s:stories ) {
				if ( s.Sprint__c != null )
					sprintsToUpdate.add( s.Sprint__c );
			}
			if ( sprintsToUpdate.size() > 0 ) {
				ADM_Sprint__c[] sprints = ADM_SprintBurnDownUtils.getSprintsForIds( sprintsToUpdate );
				if (sprints != null )
					ADM_SprintBurnDownUtils.recalculateBurndown(sprints);
			}
		}
	} else if(Trigger.isUpdate && Trigger.isBefore ) {
		oldMap = Trigger.oldMap;
		newMap = Trigger.newMap;
		modedNewMap = new Map<Id, ADM_Task__c>();

		//go through the tasks and validate that Work__c didn't change on tasks that have non-null hours remaining.
		for(Id key:newMap.keySet()){
			ADM_Task__c newTask = newMap.get(key);
			ADM_Task__c oldTask = oldMap.get(key);

			// disallow changing of work associated with task: if old task hours remaining aren't null, and work id's don't match, pop error
			if(oldTask.hours_remaining__c != null && newTask.Work__c != oldTask.Work__c) newTask.Work__c.addError('You can not change the user story reference on a sprint task');

			// disallow nulling of new task: if old task hours remaining aren't null, and new hours are null, pop error
			else if(oldTask.hours_remaining__c != null && newTask.hours_remaining__c == null) newTask.hours_remaining__c.addError('You can not nullify the hours remaining, please use a valid number or cancel.');

			// if new task hours aren't null...
			if ( newTask.hours_remaining__c != null ) {
				if ( newTask.status__c == 'Completed' && oldTask.status__c!= 'Completed' && newTask.hours_remaining__c != 0.0 )
					newTask.hours_remaining__c = 0.0;
				else if ( newTask.hours_remaining__c != 0.0 && newTask.status__c == 'Completed' && oldTask.status__c == 'Completed' )
					newTask.status__c = 'In Progress';
				else if ( newTask.status__c == oldTask.status__c ) {
					// If status__c is not manually changed then check a few other conditions
					if ( newTask.hours_remaining__c == 0.0 && oldTask.hours_remaining__c > 0.0 && newTask.status__c != 'Completed' )
						newTask.status__c = 'Completed';
				}
			}


			// set starting hours to hours remaining...
			if (newTask.hours_remaining__c != 0.0) {
				if (newTask.starting_hours__c == NULL || newTask.starting_hours__c == 0.0) {
					newTask.starting_hours__c = newTask.hours_remaining__c;
				}
			}

			// Add completed timestamp if status is changed to Completed
			if ( oldTask.Status__c != newTask.Status__c ){
			        if(newTask.Status__c == 'Completed' ){
					newTask.Completed_On__c = DateTime.now();
				} else {
					newTask.Completed_On__c = null;
		                }
            		}        

		}

	} else if(Trigger.isUpdate && Trigger.isAfter) {
		oldMap = Trigger.oldMap;
		newMap = Trigger.newMap;
		ADM_Work__c[] stories = SBU.getStories(oldMap, newMap);

		if(stories != null) {
			Set<Id> sprintsToUpdate = new Set<Id>();
			for (ADM_Work__c s:stories ) {
				if ( s.Sprint__c != null )
					sprintsToUpdate.add( s.Sprint__c );
			}

			if ( sprintsToUpdate.size() > 0 ) {
				ADM_Sprint__C[] sprints = ADM_SprintBurnDownUtils.getSprintsForIds( sprintsToUpdate );

				if(sprints != null) {

					ADM_SprintBurnDownUtils.recalculateBurndown( sprints );
				}
			}
		}
	} else if(Trigger.isDelete && Trigger.isBefore) {
	    Set<String> ids = new Set<String>();

	    for(String id : Trigger.oldMap.keySet()) {
	        ids.add(id);
	    }

	    String taskOnChangeList = ADM_ConstantsSingleton.getInstance().getNameSpace() + 'Task__c';
	    List<AggregateResult> results = [select Task__c, count(Id) from ADM_Change_List__c where Task__c in : ids group by Task__c];

	    for(AggregateResult result : results) {
	        if(Integer.valueOf(result.get('expr0')) > 0) {
	            ADM_Task__c el = Trigger.oldMap.get(String.valueOf(result.get(taskOnChangeList)));
	            el.addError('Error: Tasks that have change list(s) associated with them cannot be deleted.');
	        }
	    }
	} else if (Trigger.isDelete && Trigger.isAfter ) {
		oldMap = Trigger.oldMap;


		ADM_Work__c[] stories = SBU.getStories(oldMap, null);
		if(stories != null) {
			Set<Id> sprintsToUpdate = new Set<Id>();
			for (ADM_Work__c s:stories ) {
				if ( s.Sprint__c != null )
					sprintsToUpdate.add( s.Sprint__c );
			}
			if ( sprintsToUpdate.size() > 0 ) {
				ADM_Sprint__C[] sprints = ADM_SprintBurnDownUtils.getSprintsForIds( sprintsToUpdate );

				if(sprints != null) {
					ADM_SprintBurnDownUtils.recalculateBurndown( sprints );
				}
			}
		}

	}


}