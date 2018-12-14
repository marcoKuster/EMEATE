public with sharing class ADM_ColumnUtility {
	
	private static final String ROOT_COLUMN_PARENT = null;

	public static List<ADM_Column> getRootParentColumns(List<ADM_Column__c> columns){
		ColumnUtilityDataHolder columnUtilityDataHolder = arrangeColumnsInHierarchy(columns);
     	return columnUtilityDataHolder.parent2ChildrenColumn.get(ROOT_COLUMN_PARENT);
	}


	public static ColumnUtilityDataHolder arrangeColumnsInHierarchy(List<ADM_Column__c> columns){
		Map<String,List<ADM_Column>> parent2ChildrenColumn = new Map<String,List<ADM_Column>>();
		Map<String,ADM_Column> id2ColumnMap = new Map<String,ADM_Column>();
		
		/*

			The loop below is working on a list of ADM_Column__c SObjects which are ordered by Parent_Column_ Postion, Level - So the columns
			will be already ordered. 


		*/

		for(ADM_Column__c column:columns){
			String parentColumnId = column.Parent_Column__c;
			String columnId = column.Id;

			ADM_Column columnObj = new ADM_Column(column);
			//Creating a map of ColumnId to ADM_Column Object
			id2ColumnMap.put(columnId, columnObj);
			if(!parent2ChildrenColumn.containsKey(parentColumnId)){//Root columns will have null as parent and map will have <null,List<ADM_Column__c>> - this is expected.
					parent2ChildrenColumn.put(parentColumnId, new List<ADM_Column>());
			}
			
			parent2ChildrenColumn.get(parentColumnId).add(columnObj); //Add column to the list attached to Parent
	
		}
		//Sorting root parents - Don't need it as the query is already doing order by, but not making that assumption in case someone changes the query later.
		parent2ChildrenColumn.get(ROOT_COLUMN_PARENT).sort();
		//Once the column Hierarchy is added to the map let's traverse again through the map to add Children to each ADM_Column if any for easy traversal later

		for(String key: parent2ChildrenColumn.keySet()){
			if(id2ColumnMap.get(key) != null){
				List<ADM_Column> childColumns = parent2ChildrenColumn.get(key);
				childColumns.sort();//Sort Children before setting it to parent ADM_Colum
				id2ColumnMap.get(key).setChildren(childColumns);
			}
		}

		ColumnUtilityDataHolder columnUtilityDataHolder = new ColumnUtilityDataHolder();
		columnUtilityDataHolder.id2ColumnMap = id2ColumnMap;
		columnUtilityDataHolder.parent2ChildrenColumn = parent2ChildrenColumn;

		return columnUtilityDataHolder;

	}


	public static ADM_Column__c createColumn(String name, String parentId, Integer level, Integer position, String scrumTeamId){
		ADM_Column__c admColumn = new ADM_Column__c();
		admColumn.Name = name;
		admColumn.Parent_Column__c = parentId;
		admColumn.Level__c = level;
		admColumn.Position__c = position;
		admColumn.Team__c = scrumTeamId;
		return admColumn;
	}

	public static List<ADM_Column> makeADM_ColumnListFromColumnSObjectList(List<ADM_Column__c> sObjects){
		List<ADM_Column> admColumns = new List<ADM_Column>();
		for(ADM_Column__c columnSObject: sObjects){
			admColumns.add(new ADM_Column(columnSObject));
		}

		return admColumns;
	}

	public static List<ADM_Column__c> createDefaultColumns(List<ADM_Scrum_Team__c> selectedTeams){		
		List<ADM_Column__c> defaultColumnsCreated = new List<ADM_Column__c>();
		try{
				List<ADM_Column__c> existingColumns = [Select id,team__r.Name from ADM_Column__c where team__c in: selectedTeams AND Active__c = true];
				if(existingColumns != null && existingColumns.size() > 0){ //Chcecking of columns already exist for a team for the first time
					Set<String> teamsWithExistingColumns = new Set<String>();
					for(ADM_Column__c existingColumn : existingColumns){
						teamsWithExistingColumns.add(existingColumn.Team__r.Name);
				}
					throw new ADM_ApplicationException('Columns already exist for these teams : ' + teamsWithExistingColumns);
				}

				List<ADM_Work_Status__c> existingWorkStatuses = ADM_WorkStatus.getAllWorkStatusesByTypes(new List<String>{'Bug', 'User Story'});
				if(!(existingWorkStatuses != null && existingWorkStatuses.size() > 0)){
					ADM_WorkStatus.createAllWorkStatuses();
				}

				//Creating Parent Columns
				List<ADM_Column__c> defaultParentColumns =  new List<ADM_Column__c>();
				for(ADM_Scrum_Team__c selectedTeam : selectedTeams){
			        ADM_Column__c readyColumn = ADM_ColumnUtility.createColumn('Ready', null, 0, 0, selectedTeam.Id); 
			        defaultParentColumns.add(readyColumn);
			        ADM_Column__c inProgressColumn = ADM_ColumnUtility.createColumn('In Progress', null, 0, 1, selectedTeam.Id); 
			        defaultParentColumns.add(inProgressColumn);
			        ADM_Column__c waitingColumn = ADM_ColumnUtility.createColumn('Waiting', null, 0, 2, selectedTeam.Id); 
			        defaultParentColumns.add(waitingColumn);
			        ADM_Column__c fixedColumn = ADM_ColumnUtility.createColumn('Fixed', null, 0, 3, selectedTeam.Id); 
			        defaultParentColumns.add(fixedColumn);
			        ADM_Column__c qaInProgressColumn = ADM_ColumnUtility.createColumn('QA In Progress', null, 0, 4, selectedTeam.Id); 
			        defaultParentColumns.add(qaInProgressColumn);
			        ADM_Column__c closedColumn = ADM_ColumnUtility.createColumn('Closed', null, 0, 5, selectedTeam.Id); 
			        defaultParentColumns.add(closedColumn);
		       }
		       insert defaultParentColumns;
		       defaultColumnsCreated.addAll(defaultParentColumns);


		        //Creating a Map of TeamId+Column Name as the Key and the Column Object as the value. 
		        //This is done because the Parent columns are necessary to create child columns and we cannot match the child with parent team wise without a mapping.
		        Map<String,ADM_Column__c> columnByTeamIdAndColumnName = new  Map<String,ADM_Column__c> ();
		        for(ADM_Column__c column : defaultParentColumns){
		        	columnByTeamIdAndColumnName.put(column.Team__c+'-'+column.Name,column);
		        }
		        
		        //Creating Child Columns
		        List<ADM_Column__c> defaultChildColumns =  new List<ADM_Column__c>();
		        for(ADM_Scrum_Team__c selectedTeam : selectedTeams){
			        ADM_Column__c codeInProgressColumn = ADM_ColumnUtility.createColumn('Code In Progress', columnByTeamIdAndColumnName.get(selectedTeam.Id+'-In Progress').Id, 0, 0, selectedTeam.Id); 
			        defaultChildColumns.add(codeInProgressColumn);
                    ADM_Column__c uiInProgressColumn = ADM_ColumnUtility.createColumn('UI In Progress', columnByTeamIdAndColumnName.get(selectedTeam.Id+'-In Progress').Id, 0, 1, selectedTeam.Id); 
			        defaultChildColumns.add(uiInProgressColumn);
			        ADM_Column__c uiCompleteColumn = ADM_ColumnUtility.createColumn('UI Complete', columnByTeamIdAndColumnName.get(selectedTeam.Id+'-In Progress').Id, 0, 2, selectedTeam.Id); 
			        defaultChildColumns.add(uiCompleteColumn);
			        ADM_Column__c readyForReviewColumn = ADM_ColumnUtility.createColumn('Ready for Review', columnByTeamIdAndColumnName.get(selectedTeam.Id+'-In Progress').Id, 0, 3, selectedTeam.Id); 
			        defaultChildColumns.add(readyForReviewColumn);
			        
		        }
		        insert defaultChildColumns;
		        defaultColumnsCreated.addAll(defaultChildColumns);

		        //Map of status name vs Work_Status object
		        Map<String,Id> workStatusMapByName = new Map<String,Id>();
		        for(ADM_Work_Status__c workStatus : [Select id,Name from ADM_Work_Status__c where Type__c includes ('Bug' , 'User Story') order by Order__c]){
		            workStatusMapByName.put(workStatus.Name,workStatus.Id);
		        }

		        //Creating Column Status Assignment for Parent Columns
		        List<ADM_Column_Status_Assignment__c> defaultColumnsStatuses =  new List<ADM_Column_Status_Assignment__c>();
		        for(ADM_Column__c column : defaultParentColumns){ //Looping through parent columns
		        	 if(column.Name.equalsIgnoreCase('Ready')){
		        	 	continue;
		        	 }
		        	 else{
		             	defaultColumnsStatuses.add(ADM_ColumnUtility.setUpColumnStatusAssignment(column.Name,column,workStatusMapByName));
		             }

		        }
		        //Creating Column Status Assignment for Child Columns
		        for(ADM_Column__c column : defaultChildColumns){ //Looping through child columns
		        	if(column.Name.equalsIgnoreCase('Ready for Review')){
		        		defaultColumnsStatuses.add(ADM_ColumnUtility.setUpColumnStatusAssignment('Ready for Review',column,workStatusMapByName));
		        	}
		        	else{
		             defaultColumnsStatuses.add(ADM_ColumnUtility.setUpColumnStatusAssignment('In Progress',column,workStatusMapByName));
					}
		        }  

			    /*https://gus.my.salesforce.com/apex/adm_bugdetail?id=a07B0000001DLrgIAG&sfdc.override=1
					Removed mapping duplicate and never to closed column by default.
			    */
		        insert defaultColumnsStatuses;
     	}
     	catch(Exception e){
     		System.debug('Exception while creating and setting Columns and Column status Assignments : '+e);
     	}
     	return defaultColumnsCreated;
	}



	public static ADM_Column_Status_Assignment__c setUpColumnStatusAssignment(String statusName, ADM_Column__c column,Map<String,Id> workStatusMap){
		try{
			Id workStatusId = workStatusMap.get(statusName);
			ADM_Column_Status_Assignment__c columnStatusAssignment = new ADM_Column_Status_Assignment__c();
			columnStatusAssignment.Column__c = column.id;
			columnStatusAssignment.Work_Status__c = workStatusId;
			return columnStatusAssignment;
		}
		catch(Exception e){
			System.debug('Exception while creating ADM_Column_Status_Assignment__c object : '+ e);
			return null;
		}
	}

	public static void validateColumnsBeforeDML(List<ADM_Column__c> columnsToValidate, boolean isInsert, boolean isUpdate, Map<Id, ADM_Column__c> columnsOldMap ){
		List<String> teamIds = new List<String>();
		Set<Id> columnIdsToDeactive = new Set<Id>();
		for(ADM_Column__c column: columnsToValidate){
            if(ADM_TextUtils.isBlank(column.Name)){
                column.addError('Column name cannot be blank');
            }
            else{
			if(isUpdate && column.Active__c == false){
				columnIdsToDeactive.add(column.Id);
			}
			else {
				teamIds.add(column.Team__c);
			}
		}

		}

		if(columnIdsToDeactive.size() >0){
			Set<Id> columnsIdsHavingWorks = getColumnsAttachedToWorks(columnIdsToDeactive);
			Set<Id> parentIdColumns = getColumnsHavingChildren(columnIdsToDeactive);

			if(null != parentIdColumns || null != columnsIdsHavingWorks){
				for(ADM_Column__c column: columnsToValidate){
					if(null != parentIdColumns && parentIdColumns.contains(column.Id)){
						column.addError('Cannot delete parent Column ' + column.Id);
					}
					else if(null != columnsIdsHavingWorks && columnsIdsHavingWorks.contains(column.Id)){
						column.addError('Cannot delete column with work item(s) ' + column.Id);
					}
				}
			}
			
		}

		if(teamIds.size() > 0){
			List<ADM_Column__c> existingColumnsForTeams = ADM_ColumnQueryUtils.getColumnsByTeams(teamIds);
			if(null != existingColumnsForTeams && existingColumnsForTeams.size() > 0){
				List<ADM_Column> existingADMColumnObjects = makeADM_ColumnListFromColumnSObjectList(existingColumnsForTeams);
				Map<String,ADM_Column> idToADMColumnMap = new Map<String,ADM_Column>();
			
				ADM_KanbanUtility.getIdToColumnMap(existingADMColumnObjects, idToADMColumnMap);

				Map<String, Map<String,String>> teamToColumnCoordinateMap = getMapOfTeamColumnCoordinates(existingColumnsForTeams);
				Set<String> columnNameParentSet = getSetOfColumnNameParent(existingColumnsForTeams);

				for(ADM_Column__c columnToValidate: columnsToValidate){
					String columnNameBeforeUpdate;
					Decimal levelBeforeUpdate;
					Decimal positionBeforeUpdate;
					if(isUpdate){
						columnNameBeforeUpdate = columnsOldMap.get(columnToValidate.Id).Name;
						levelBeforeUpdate = columnsOldMap.get(columnToValidate.Id).Level__c;
						positionBeforeUpdate = columnsOldMap.get(columnToValidate.Id).Position__c;
					}
					if(true == isColumnValidationNeeded(isInsert, columnToValidate, columnNameBeforeUpdate, levelBeforeUpdate, positionBeforeUpdate)){
                        if(validateColumnName(isInsert, columnToValidate, columnNameParentSet, columnNameBeforeUpdate)){
                        	columnToValidate.addError('Column Name must be unique per generation');
                        	continue;
                        }

                        //If name validation for same generation succeeds make sure no Column Name was not already used in current hierarchy of the new column

                        Set<String> columnNamesInHierarchy = new Set<String>();
                        ADM_KanbanUtility.findAllColumnNamesInColumnHierarchy(idToADMColumnMap.get(columnToValidate.Parent_Column__c), idToADMColumnMap, columnNamesInHierarchy);
                        if(columnNamesInHierarchy.contains(columnToValidate.Name)){
                        	columnToValidate.addError('Column name must be unique in its hierarchy');
                        	continue;
                        }
                        /* Disabling this validation because this story https://gus.my.salesforce.com/apex/adm_bugdetail?id=a07B00000012l7eIAA&sfdc.override=1 (W-2429801) cannot be completed
                           with this validation on. So created https://gus.my.salesforce.com/apex/adm_userstorydetail?id=a07B00000012ohT&sfdc.override=1 to work on validation 
						boolean columnExistWithSameLevelAndPosition = validateColumnUpdateForLevelAndPosition(isInsert, columnToValidate, teamToColumnCoordinateMap, columnNameParentSet, columnNameBeforeUpdate);
						if(columnExistWithSameLevelAndPosition){
							columnToValidate.addError('Column Level__c, Position__c combination should be unique per generation');
						}*/
					}
				}
			}
		}
		

	}

   	public static List<LeafNodeDetails> getLeafNodesByTeamId(String teamId){
		List<ADM_Column__c> columnSObjects = ADM_ColumnQueryUtils.getColumnsByTeam(teamId);
		List<ADM_Column> admColumns = null;
		if(null != columnSObjects && columnSObjects.size() > 0){
		    admColumns = ADM_ColumnUtility.getRootParentColumns(columnSObjects);
		}
		Set<String> closedColumnIds = getKanbanClosedColumns(teamId);
		return ADM_KanbanUtility.getLeafColumnsWithPathInfo(admColumns, closedColumnIds);
	}

	

	private static boolean isColumnValidationNeeded(boolean isInsert, ADM_Column__c columnToBeValidated, String columnNameBeforeUpdate, Decimal levelBeforeUpdate, Decimal positionBeforeUpdate){
		boolean validationRequired = false;
		if(isInsert){
			validationRequired = true;
		}
		else if(columnToBeValidated.Name != columnNameBeforeUpdate || columnToBeValidated.Level__c != levelBeforeUpdate || columnToBeValidated.Position__c != positionBeforeUpdate){
			validationRequired = true;
		}
		return validationRequired;
	}

	private static boolean validateColumnName(boolean isInsert, ADM_Column__c columnToValidate, Set<String> columnNameParentSet, String columnNameBeforeUpdate){
		boolean columnNameExists = false;
		String parentColumn = '';
		if(null != columnToValidate.Parent_Column__c){
			parentColumn = columnToValidate.Parent_Column__c;
		}
		if(isInsert || (columnToValidate.Name != columnNameBeforeUpdate)){//If it is a column insert or column name update check column name uniqueness in its generation
			if(columnNameParentSet.contains(columnToValidate.Name.toLowerCase()+parentColumn)){// The columnName + parentid combination exists in the set.ie, this parent has a child with this column name
				columnNameExists = true;
			}
		}
		return columnNameExists;
	}

	private static boolean validateColumnUpdateForLevelAndPosition(boolean isInsert, ADM_Column__c columnToValidate, Map<String, Map<String,String>> teamToColumnCoordinateMap, Set<String> columnNameParentSet, String columnNameBeforeUpdate){
		Map<String,String> columnCoordinateToNameMap = teamToColumnCoordinateMap.get(columnToValidate.Team__c);

		boolean columnExistWithSameLevelAndPosition = false;
		if(null !=  columnCoordinateToNameMap){
			/*
				Check whether the columnToValidate Level and Position key combination returns a name from the map then that means
                there is column with this level and position 
			*/
			String parentColumn = '';
			if(null != columnToValidate.Parent_Column__c){
				parentColumn = columnToValidate.Parent_Column__c;
			}

			
			String nameFromMap = columnCoordinateToNameMap.get(parentColumn + String.valueOf(columnToValidate.Level__c)+ String.valueOf(columnToValidate.Position__c));
			if(null != nameFromMap){
				if(nameFromMap.equalsIgnoreCase(columnNameBeforeUpdate)){//The column with the same level and position is same as the column getting updated so name change can proceed.
					columnExistWithSameLevelAndPosition = false;
				}
				else{
					columnExistWithSameLevelAndPosition = true;
				}
			}
		}

		return columnExistWithSameLevelAndPosition;
	}

	private static Set<Id> getColumnsAttachedToWorks(Set<Id> columnIdsToDeactive){
		Set<Id> columnIdsHavingWork = new Set<Id>();
		ADM_Work__c[] worksWithColumns = ADM_Work.getWorksByColumnIds(columnIdsToDeactive);
		for(ADM_Work__c workWithColumn:worksWithColumns){
			columnIdsHavingWork.add(workWithColumn.Column__c);
		}
		return columnIdsHavingWork;
	}

	private static Set<Id> getColumnsHavingChildren(Set<Id> columnIdsToDeactive){
		Set<Id> parentColumnIds = new Set<Id>();
		/*Querying to know these columns are parent columns...Don't be confused why not using column.Parent_Column__c 
		  because we are here to know the current column is a parent column or not
		*/
		ADM_Column__c[] columnsByParents = ADM_ColumnQueryUtils.getColumnsByParents(columnIdsToDeactive);
		for(ADM_Column__c column:columnsByParents){
			parentColumnIds.add(column.Parent_Column__c);
		}
		return parentColumnIds;
	}

	private static Map<String, Map<String,String>> getMapOfTeamColumnCoordinates(List<ADM_Column__c> existingColumnsForTeams){
		Map<String, Map<String,String>> teamToColumnCoordinateMap = new Map<String, Map<String,String>>();
		for(ADM_Column__c existingColumn :existingColumnsForTeams){
			if(!teamToColumnCoordinateMap.containsKey(existingColumn.Team__c)){
				teamToColumnCoordinateMap.put(existingColumn.Team__c, new Map<String,String>());
			}
			Map<String,String> columnCoordinateToNameMap = teamToColumnCoordinateMap.get(existingColumn.Team__c);
			String parentColumn = '';
			if(null != existingColumn.Parent_Column__c){
				parentColumn = existingColumn.Parent_Column__c;
			}
			columnCoordinateToNameMap.put(parentColumn + String.valueof(existingColumn.Level__c)+String.valueOf(existingColumn.Position__c), existingColumn.Name);
		}
		return teamToColumnCoordinateMap;
	}

	private static Set<String> getSetOfColumnNameParent(List<ADM_Column__c> existingColumns){
		Set<String> columnNameParentSet = new Set<String>();
		for(ADM_Column__c existingColumn :existingColumns){
			String parentColumnId = '';
			if(existingColumn.Parent_Column__c != null){
				parentColumnId = existingColumn.Parent_Column__c;
			}
			columnNameParentSet.add(existingColumn.Name.toLowerCase()+parentColumnId);
		}
		return columnNameParentSet;
	}

	public static Set<String> getKanbanColumnsEligibleToAddWork(String teamId){
		List<ADM_Column__c> eligbileKanbanColumns = [Select Id from ADM_Column__c where team__c = :teamId AND Active__c = true];
		Set<String> eligibleColumnIdsToAddWork = new Set<String>();
		for(ADM_Column__c eligbileKanbanColumn: eligbileKanbanColumns){
			eligibleColumnIdsToAddWork.add(eligbileKanbanColumn.Id);
		}

		return eligibleColumnIdsToAddWork;
	}

	public static Set<String> getKanbanClosedColumns(String teamId){
		List<Adm_Column_Status_Assignment__c> kanbanClosedColumnAssignments = [Select Column__c from Adm_Column_Status_Assignment__c where Work_Status__r.Name = 'Closed' and Column__r.Active__c = true and Column__r.Team__c = :teamId];
		Set<String> closedColumnIds = new Set<String>();
		for(Adm_Column_Status_Assignment__c kanbanClosedColumnAssignment: kanbanClosedColumnAssignments){
			closedColumnIds.add(kanbanClosedColumnAssignment.Column__c);
		}

		return closedColumnIds;
	}

	/*
		Light weight dataholder object to carry ids To ADM_column map and parent To Children Column map - This will help avoid using SOQL query
	*/
	@TestVisible
	private class ColumnUtilityDataHolder {
		@TestVisible
		Map<String,ADM_Column> id2ColumnMap;
		@TestVisible
		Map<String,List<ADM_Column>> parent2ChildrenColumn;
	}

	/*
		Light weight dataholder object to carry ids To ADM_column map and parent To Children Column map - This will help avoid using SOQL query
	*/
	@TestVisible
	public class LeafNodeDetails {
		public boolean isClosedColumn;
		public String path;
		public String columnId;
	}

	

}