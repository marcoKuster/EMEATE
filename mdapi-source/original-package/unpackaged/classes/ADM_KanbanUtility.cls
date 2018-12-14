public with sharing class ADM_KanbanUtility {
	static Map<Id, ADM_Work__c> id2WorkMap = new Map<Id, ADM_Work__c>();
	private static Set<String> currentTeamIds = new Set<String>();
	private static List<ADM_Work_Status__c> workStatusSObjects = new List<ADM_Work_Status__c>();

	public void setTeamIds(Set<String> teamIds){
		currentTeamIds = teamIds;
	}

	public static List<ADM_Column> blendColumnWithWorks(List<ADM_Column> columns, List<ADM_Work__c> worksForKanbanBoard, List<FeedItem> feedItems, List<EntitySubscription> workSubscribedByUser, Map<String,List<ADM_ColumnHistory.AggregatedColumnHistory>> aggregatedColumnHistories,
		                                                 Map<Id, List<ADM_Theme_Assignment__c>> workIdToThemAssignments){
		
		

		//Get the list of valid column Ids for this team
		Map<String, ADM_Column> columnSObjectIdtoADMColumnMap = new Map<String, ADM_Column>();

		currentTeamIds.add(columns[0].getColumnSObject().Team__c);//All columns here belong to one Team so get the team from first column.

        getIdToColumnMap(columns, columnSObjectIdtoADMColumnMap);//Recursive call to get the full list of Map with id to ADM_Column for convenience in the below logic.

		Map<String, ADM_Work__c> workId2Work = new Map<String,ADM_Work__c>();
		//List<ADM_Work__c> worksWithNullColumn = new List<ADM_Work__c>();
		Set<String> workStatusesWithoutColumn = new Set<String>();
		for(ADM_Work__c work:worksForKanbanBoard){
			if(ADM_TextUtils.isNull(work.Column__c)){
				workId2Work.put(work.id, work);
				//worksWithNullColumn.add(work);
				workStatusesWithoutColumn.add(work.Status__c);
			}
		}
		//Get all Workstatuses
		workStatusSObjects =  ADM_WorkStatus.getAllWorkStatusesByTypes(new List<String>{'Bug', 'User Story'});

		if(workId2Work.values().size() > 0){
			attachColumnsToWork(workId2Work.values(), columnSObjectIdtoADMColumnMap);
		}

		Map<Id,List<FeedItem>> workId2FeedItem = getFeedCountOnWork(feedItems);

		Set<Id> userSubscribedWorkIds = getSubscribedWorksByCurrentUser(workSubscribedByUser);

		for(ADM_Work__c work : worksForKanbanBoard){
            ADM_Column columnToAddWork = columnSObjectIdtoADMColumnMap.get(work.Column__c);
			ADM_Column columnToAssignToWorkSatus;
			
			if(null != columnToAddWork && null != columnToAddWork.getChildren() && 
			                columnToAddWork.getChildren().size() > 0 ){// Check the column identified is a parent column -  if then assign the left most column of the leaf child
				columnToAssignToWorkSatus = findLeftmostLeafColumn(columnToAddWork);
			}
			else{
				columnToAssignToWorkSatus = columnToAddWork;
			}
			ADM_Column.ColumnWorkItem columnWorkItem = getColumnWork(work);

			List<ADM_Theme_Assignment__c> themAssignments = workIdToThemAssignments.get(work.Id);
			if(null != themAssignments && themAssignments.size() >0){
				columnWorkItem.themeIdToNameMap = new Map<String,String>();
				for(ADM_Theme_Assignment__c themeAssignment: themAssignments){
					columnWorkItem.themeIdToNameMap.put(themeAssignment.Theme__c, themeAssignment.Theme__r.Name);
				}
			}
			//Check if this work needs columnId save
			if(workId2Work.keySet().contains(work.id)){
				columnWorkItem.needsColumnUpdate = true;
			}
			List<FeedItem> feedsOnWork = workId2FeedItem.get(work.Id);
			if(null != feedsOnWork){
				columnWorkItem.numberOfPosts = feedsOnWork.size();
			}
			else{
				columnWorkItem.numberOfPosts = 0;
			}
			columnWorkItem.isUserSubscribed = userSubscribedWorkIds.contains(work.Id);
            if(columnToAssignToWorkSatus != null){
                columnToAssignToWorkSatus.getWorkItems().add(columnWorkItem);
            }
            if(null != aggregatedColumnHistories){
				List<ADM_ColumnHistory.AggregatedColumnHistory> workColumnHistoryList = aggregatedColumnHistories.get(work.Id);
				Map<String, Map<String, String>> columnIdToTimeSpent = new Map<String, Map<String, String>>();
				if(null != workColumnHistoryList && workColumnHistoryList.size() > 0){
					Map<String, String> historyMap;
					for(ADM_ColumnHistory.AggregatedColumnHistory workColumnHistory : workColumnHistoryList){
						historyMap = new Map<String, String>();
					    historyMap.put('totalWorkDays' , workColumnHistory.totalWorkDays.format());
					    historyMap.put('totalActualDays' , workColumnHistory.totalActualDays.format());
					    historyMap.put('totalActualDaysStr' , workColumnHistory.totalActualDaysStr);
					    columnIdToTimeSpent.put(workColumnHistory.columnId, historyMap);
					}
					
				}
				else{
						if(columnToAssignToWorkSatus != null){
							Map<String, String> historyMap = new Map<String, String>();
						    historyMap.put('totalWorkDays' , 'No_History');
						    historyMap.put('totalActualDays' , 'No_History');
						    historyMap.put('totalActualDaysStr' , 'No_History');
						    columnIdToTimeSpent.put(columnToAssignToWorkSatus.getColumnSObject().Id, historyMap);
						}
						
				}
				columnWorkItem.columnIdToTimeSpent = columnIdToTimeSpent;
			}
		}

		

		//Attaching columnStatusMapping to ADM_Column
		List<ADM_Column_Status_Assignment__c> columnAssignmentsByColumn = ADM_ColumnStatusAssignment.getAssignmentsByColumns(columnSObjectIdtoADMColumnMap.keySet());
		Map<String, List<String>> columnToWorkStatusIdMap = getColumn2WorkStatusIdsFromStatusAssigment(columnAssignmentsByColumn);
		
		Map<String, String> statusIdToNameMap = getIdToStatusNameMap(workStatusSObjects);
		
		for(String columnId: columnSObjectIdtoADMColumnMap.keySet()){
			ADM_Column columnToAddStatusAssigment = columnSObjectIdtoADMColumnMap.get(columnId);
			if(columnToWorkStatusIdMap.containsKey(columnId)){
				List<String> workStatusIds = columnToWorkStatusIdMap.get(columnId);
				for(String workStatusId: workStatusIds){
					if(!columnToAddStatusAssigment.getMappedWorkStatuses().containsKey(workStatusId)){
						if(statusIdToNameMap.containsKey(workStatusId)){
							/*If this column has already been found as "closed like" by one for the statuses before no need to check again, because it should be treated as "closed like" - if status order say never comes after closed and never is not treated as closed it will be set as closed like in first iteration and in the next iteration it will be reverted.
							  In-short column will remain treated as "closed like" if atleast one status is mapped to "closed like"
							*/
							if(false == columnToAddStatusAssigment.getClosedLike()){
								columnToAddStatusAssigment.setClosedLike(ADM_Work.CLOSED_LIKE_STATUSES.contains(statusIdToNameMap.get(workStatusId).toLowerCase()));
							}
							columnToAddStatusAssigment.getOrderedWorkStatusIds().add(workStatusId);
							columnToAddStatusAssigment.getMappedWorkStatuses().put(workStatusId, statusIdToNameMap.get(workStatusId));
						}
					}
				}
			}
		}
		
		return columns;
	}

	private static ADM_Column.ColumnWorkItem getColumnWork(ADM_Work__c workSObject){
		ADM_Column.ColumnWorkItem columnWork = new ADM_Column.ColumnWorkItem();
		columnWork.workId = workSObject.Id;
		columnWork.workTitle = workSObject.Name;
		columnWork.subject = workSObject.Subject__c;
		if(null != workSObject.Column_Rank__c){
			columnWork.columnRank = workSObject.Column_Rank__c.intValue();
		}
		else{
			columnWork.columnRank = 0;
		}
		columnWork.recordType = workSObject.RecordType.Name;
		columnWork.assigneeFirstName = workSObject.Assignee__r.FirstName;
		columnWork.assigneeFullName = workSObject.Assignee__r.Name;
		columnWork.assigneeId = workSObject.Assignee__c;
		columnWork.assigneePicUrl = workSObject.Assignee__r.SmallPhotoUrl;
		columnWork.qeFirstName = workSObject.QA_Engineer__r.FirstName;
		columnWork.qeFullName = workSObject.QA_Engineer__r.Name;
		columnWork.qeId = workSObject.QA_Engineer__c;
		columnWork.qePicUrl = workSObject.QA_Engineer__r.SmallPhotoUrl;
		columnWork.scheduledBuild = workSObject.Scheduled_Build__r.Name;
		columnWork.scheduledBuildId = workSObject.Scheduled_Build__c;
		columnWork.priority = workSObject.Priority__c;
		columnWork.epicId = workSObject.Epic__c;
		columnWork.epicName = workSObject.Epic__r.Name;
		columnWork.colorId = workSObject.Color__c;
		columnWork.color = workSObject.Color__r.Color__c;
		columnwork.scrumTeamId = workSObject.Scrum_Team__c;
		columnwork.productTagId = workSObject.Product_Tag__c;
		columnWork.productTag = workSObject.Product_Tag__r.Name;
		Decimal points = workSObject.Story_Points__c;
		if(points != null){
			columnWork.storyPoints = points.format();
		}
		columnWork.numberOfTasks = workSObject.Tasks__r.size();
		return columnWork;
	}

	private static List<ADM_Work__c> attachColumnsToWork(List<ADM_Work__c> worksThatNeedsColumnUpdate, Map<String, ADM_Column> columnSObjectIdtoADMColumnMap){
		List<ADM_Work__c> worksToBeUpdated = new List<ADM_Work__c>();

		if(workStatusSObjects.size() == 0){
			workStatusSObjects = ADM_WorkStatus.getAllWorkStatusesByTypes(new List<String>{'Bug', 'User Story'});
		}
		//Creating a map of WorkStatus  ID to Name eg: {'a3CB0000000008fMAA', 'In Progress'}
		Map<String,String> workIdToStatus = new Map<String,String>();
		for(ADM_Work_Status__c workStatusSObject: workStatusSObjects){
			workIdToStatus.put(workStatusSObject.Id, workStatusSObject.Name);
		}

		//Creating a map of WorkStatus Name to ADM_Column__c.Id eg: {'In Progress', ADM_Column}
		Map<String,ADM_Column> workStatusToColumnMap = new Map<String, ADM_Column>();
		List<ADM_Column_Status_Assignment__c> columnStatusAssignments = ADM_ColumnStatusAssignment.getAssignmentsFromColumnStatusMapping(workIdToStatus.keySet(), currentTeamIds);
		for(ADM_Column_Status_Assignment__c columnStatus : columnStatusAssignments){
			//Only care about columns valid for this team
			if(columnSObjectIdtoADMColumnMap.keySet().contains(columnStatus.Column__c)){//If column is not in this map then it is not part of this team
				ADM_Column columnToAssignToWorkSatus = columnSObjectIdtoADMColumnMap.get(columnStatus.Column__c);
				String key = workIdToStatus.get(columnStatus.Work_Status__c) + columnToAssignToWorkSatus.getColumnSObject().Team__c;
				if(!workStatusToColumnMap.containsKey(key)){
					workStatusToColumnMap.put(key, columnToAssignToWorkSatus);
				}
			}
		}

		for(ADM_Work__c workThatNeedsColumnUpdate : worksThatNeedsColumnUpdate){
				ADM_Column columnToAddWork = workStatusToColumnMap.get(workThatNeedsColumnUpdate.Status__c+workThatNeedsColumnUpdate.Scrum_Team__c);
				//Only update column if column is mapped to a staus (W-2915666) https://gus.my.salesforce.com/apex/adm_bugdetail?id=a07B0000001qMzC&sfdc.override=1
				if(null != columnToAddWork){
					ADM_Column leftmostLeafColumn = findLeftmostLeafColumn(columnToAddWork);
               		workThatNeedsColumnUpdate.Column__c = leftmostLeafColumn.getColumnSObject().Id;
					worksToBeUpdated.add(workThatNeedsColumnUpdate);
               	}
		}
		return worksToBeUpdated;
	}

	private static Map<String, List<String>> getColumn2WorkStatusIdsFromStatusAssigment(List<ADM_Column_Status_Assignment__c> columnStatusAssigments){
		Map<String,List<String>> column2WorkStatusIds = new Map<String,List<String>>();
		for(ADM_Column_Status_Assignment__c columnStatusAssignment: columnStatusAssigments){
			if(!column2WorkStatusIds.containsKey(columnStatusAssignment.Column__c)){//if map doesn't contains key put an empty set which will be filled in by next statement
				column2WorkStatusIds.put(columnStatusAssignment.Column__c, new List<String>());
			}
			column2WorkStatusIds.get(columnStatusAssignment.Column__c).add(columnStatusAssignment.Work_Status__c);
		}
		return column2WorkStatusIds;
	}

	private static Map<String,String> getIdToStatusNameMap(List<ADM_Work_Status__c> allWorkStatuses){
		Map<String,String> statusIdToName = new Map<String,String>();
		for(ADM_Work_Status__c workStatusSObject: allWorkStatuses){
			statusIdToName.put(workStatusSObject.Id, workStatusSObject.Name);
		}
		return statusIdToName;
	}
	

	public static List<ADM_Work_Status__c> getWorkStatusIds(Set<String> workStatusesWithoutColumn){
		List<ADM_Work_Status__c> workStatuses = [Select id, Name from ADM_Work_Status__c where Name in :workStatusesWithoutColumn and Type__c includes ('Bug' , 'User Story') order by Order__c ]; //SOQL 7
		return workStatuses;
	}

	public static Map<Id,List<FeedItem>> getFeedCountOnWork(List<FeedItem> feedItems){
		Map<Id,List<FeedItem>> workId2FeedItem = new Map<Id,List<FeedItem>>();
		for(FeedItem feedItem : feedItems){
			if(null == workId2FeedItem.get(feedItem.parentId)){
				List<FeedItem> feedsOnWork = new List<FeedItem>();
				workId2FeedItem.put(feedItem.parentId, feedsOnWork);
			}
			workId2FeedItem.get(feedItem.parentId).add(feedItem);
		}
		return workId2FeedItem;
	}

	public static Set<Id> getSubscribedWorksByCurrentUser(List<EntitySubscription> workSubscribedByUser){
		Set<Id> workIdsFromSubscription = new Set<Id>();
		for(EntitySubscription es: workSubscribedByUser){
			workIdsFromSubscription.add(es.parentId);
		}
		return workIdsFromSubscription;
	}

	private static ADM_Column findLeftmostLeafColumn(ADM_Column currentColumn){
		ADM_Column leftMostChildColumn = currentColumn;
		if(null != leftMostChildColumn.getChildren() && leftMostChildColumn.getChildren().size() > 0){//Passed in column has children so left find the 
			leftMostChildColumn = findLeftmostLeafColumn(leftMostChildColumn.getChildren()[0]);
		}
		return leftMostChildColumn;
	}

	public static List<ADM_Column> findLeafColumns(ADM_Column currentColumn, List<ADM_Column> leafHierarchy){
		leafHierarchy.add(currentColumn);
		ADM_Column leafColumn = currentColumn;
		if(null != currentColumn.getChildren() && currentColumn.getChildren().size() > 0){
			for(ADM_Column childColumn : currentColumn.getChildren()){
				findLeafColumns(childColumn, leafHierarchy);
			}
		}
		return leafHierarchy;
	}

	public static Set<String> findAllColumnNamesInColumnHierarchy(ADM_Column currentColumn, Map<String, ADM_Column> id2ADM_ColumnMap, Set<String> columnNamesInHierarchy){
		if(null != currentColumn){
			columnNamesInHierarchy.add(currentColumn.getColumnName());
			if(null != currentColumn.getParentId()){
				findAllColumnNamesInColumnHierarchy(id2ADM_ColumnMap.get(currentColumn.getParentId()), id2ADM_ColumnMap, columnNamesInHierarchy);
			}
		}		
		columnNamesInHierarchy.add(null);//All columns will have null in their hierarchy...since it is a set it only adds null one time
		return columnNamesInHierarchy;

	}

	public static String findStatusMappingFromHierarchy(ADM_Column column, Map<String, ADM_Column> columnSobjIdToADMColumnMap, Map<Id, String> columnIdToWorkStatusMap){
		String statusFromMap = columnIdToWorkStatusMap.get(column.getColumnSObject().Id);
		String statusToReturn = '';
		if(statusFromMap != null){
			statusToReturn = statusFromMap;
		}
		else{
			if(column.getParentId() != null){
				ADM_Column parentColumn = columnSobjIdToADMColumnMap.get(column.getParentId());
				if(null != parentColumn){
					statusToReturn = findStatusMappingFromHierarchy(parentColumn, columnSobjIdToADMColumnMap, columnIdToWorkStatusMap);
				}
				
			}
		}
		return statusToReturn;

	}

	public static List<ADM_ColumnUtility.LeafNodeDetails>  getLeafColumnsWithPathInfo(List<ADM_Column> admColumns, Set<String> closedColumnIds){
		Map<String, List<ADM_Column>> rootParent2Children = new Map<String, List<ADM_Column>>();
		List<ADM_ColumnUtility.LeafNodeDetails> leafNodeDetailsList = new List<ADM_ColumnUtility.LeafNodeDetails>();
		List<String> orderOfColumns = new List<String>();
		String path = '';
        boolean leafNodeFound = false;
		if(null != admColumns){
			for(ADM_Column columnIter: admColumns){
				List<ADM_Column> leafNodes = ADM_KanbanUtility.findLeafColumns(columnIter, new List<ADM_Column>());
				List<ADM_Column> children;
			    if(leafNodes.size()>0){
			        for(ADM_Column leaf: leafNodes){
			            if(leaf.getParentId() == null){
			                path = leaf.getColumnName();
			            }
			            if(leaf.getParentId() != null && null != leaf.getChildren() && leaf.getChildren().size() > 0){
                            if(leafNodeFound && null !=  path && null != leaf.getParentName() && !path.endsWithIgnoreCase(' ' + leaf.getParentName())){
                                String removeAfter = leaf.getParentName();
                                String removeStr = path.subStringAfter(removeAfter);
                                path = path.removeEnd(removeStr);
                                leafNodeFound = false;
                    		}
			                
			                path += ' > ' + leaf.getColumnName() ;
			            }
			            else{
			                
			                if(null != leaf.getParentName() && path.containsIgnoreCase(leaf.getParentName())){
			                   if(!path.endsWithIgnoreCase(' ' + leaf.getParentName())){
			                   
			                        String removeAfter = leaf.getParentName();
			                        String removeStr = path.subStringAfter(removeAfter);
			                        path = path.removeEnd(removeStr);
			                    }
			                }
			                if(null == leaf.getChildren()){
			                   ADM_ColumnUtility.LeafNodeDetails leafNodeDetails = new ADM_ColumnUtility.LeafNodeDetails();
			                    if( path.equals(leaf.getColumnName())){
                                    leafNodeDetails.path = path;
                                }
                                else{
                                    leafNodeDetails.path = path + ' > ' + leaf.getColumnName();
                                }
                                if(null != closedColumnIds && closedColumnIds.size() >0){
                                	leafNodeDetails.isClosedColumn = closedColumnIds.contains(leaf.getColumnSObject().Id);
                                }
                                else{
                                	leafNodeDetails.isClosedColumn = false;
                                }
			                    
			                    leafNodeDetails.columnId = leaf.getColumnSObject().Id;
			                    leafNodeDetailsList.add(leafNodeDetails); 
                                leafNodeFound = true;
                                
			                }
			             }
			         }
			    }
			}
		}
		

		return leafNodeDetailsList;

	}
	private static void assignWorkColumnRankToZero(List<ADM_Work__c> worksToGetZeroColumnRank){
		for(ADM_Work__c workToGetZeroColumnRank: worksToGetZeroColumnRank){
			workToGetZeroColumnRank.Column_Rank__c = 0;
		}
	}
	@future
	public static void updateWorkWithColumnsAsync(List<Id> workIds, Set<String> workTeamIds ){
		try {
			if(null != workTeamIds && workTeamIds.size() > 0){//Only do this if team ids is not null...otherwise we can't find ADM_Column__c and no need to proceed.
				List<ADM_Work__c> worksToBeUpdated = updateWorkWithColumns(workIds, workTeamIds);
				if(null != worksToBeUpdated && worksToBeUpdated.size() > 0){
					assignWorkColumnRankToZero(worksToBeUpdated);
					update worksToBeUpdated;
				}
			}
			
		} catch(Exception e) {
	         ADM_ExceptionHandler.saveException(e, 'ADM_KanBanUtility.updateWorkWithColumns(). Line:' + e.getLineNumber() + ' Stack Trace:' + e.getStackTraceString() + ' Work Ids:' + workIds + ' workTeamIds:' + workTeamIds);
	    }	
	}

	
	public static void updateWorkWithColumnsSync(List<Id> workIds, Set<String> workTeamIds ){
		try {
			if(null != workTeamIds && workTeamIds.size() > 0){//Only do this if team ids is not null...otherwise we can't find ADM_Column__c and no need to proceed.
				List<ADM_Work__c> worksToBeUpdated = updateWorkWithColumns(workIds, workTeamIds);
				assignWorkColumnRankToZero(worksToBeUpdated);
				if(null != worksToBeUpdated && worksToBeUpdated.size() > 0){
					update worksToBeUpdated;
				}
			}
			
		} catch(Exception e) {
	         ADM_ExceptionHandler.saveException(e, 'ADM_KanBanUtility.updateWorkWithColumns(). Line:' + e.getLineNumber() + ' Stack Trace:' + e.getStackTraceString() + ' Work Ids:' + workIds + ' workTeamIds:' + workTeamIds);
	    }
	}

	//Splitting this so that this method can be unit tested
	@TestVisible
	private static List<ADM_Work__c> updateWorkWithColumns(List<Id> workIds, Set<String> workTeamIds ){
		List<ADM_Work__c> worksToBeUpdated = null;
		//This should be clear already, but explicitely clearing it.
		currentTeamIds.clear();
		currentTeamIds.addAll(workTeamIds);
		if(null != workTeamIds && workTeamIds.size() > 0){//Only do this if team ids is not null...otherwise we can't find ADM_Column__c and no need to proceed.{
			List<ADM_Column> admColumnsByTeam = new List<ADM_Column>();
			List<ADM_Column__c> columnSObjs = ADM_ColumnQueryUtils.getColumnsByTeams(workTeamIds);
			if(columnSObjs != null && columnSObjs.size() > 0){
				 admColumnsByTeam = ADM_ColumnUtility.getRootParentColumns(columnSObjs);
			}
			
			if(admColumnsByTeam.size() > 0){//Don't even worry about doing anything if Columns don't exist 
				Map<String, ADM_Column> columnSObjectIdtoADMColumnMap = new Map<String, ADM_Column>();
				Set<String> teamIdsWithKanbanEnabled = new Set<String>();
				for(ADM_Column admColumn:admColumnsByTeam){
					teamIdsWithKanbanEnabled.add(admColumn.getColumnSObject().Team__c);
				}
				getIdToColumnMap(admColumnsByTeam, columnSObjectIdtoADMColumnMap);
				List<ADM_Work__c> works = ADM_Work.getWorksForKanbanByWorkIdsAndTeamIds(workIds, teamIdsWithKanbanEnabled);
				if(null != works && works.size() > 0){
					worksToBeUpdated = attachColumnsToWork(works, columnSObjectIdtoADMColumnMap);
				}
				
			}
		}
		
		
	    return worksToBeUpdated;
	}
    
    public static void getIdToColumnMap(List<ADM_Column> columns, Map<String, ADM_Column> columnSObjectIdtoADMColumnMap){
        
        for(ADM_Column  column : columns){ 
			if(null != column.getChildren() && column.getChildren().size() > 0){
                getIdToColumnMap(column.getChildren(), columnSObjectIdtoADMColumnMap);
            }
            columnSObjectIdtoADMColumnMap.put(column.getColumnSObject().Id, column);
           
		}
        
    }

       //Updates the status of the work record based on its column id
    public static List<ADM_Work__c> updateWorkWithStatus(List<ADM_Work__c> works) {
    	Map<String, ADM_Work__c> workIdToObjectMap = new Map<String, ADM_Work__c>();
    	Set<String> teamIds = new Set<String>();
        try {
            //to optimize queries first build a list of column ids
            List<Id> columnIDs = new List<Id>();
            for(ADM_Work__c work: works) {
                 if(work.Column__c != null) {
                     columnIDs.add(work.Column__c);
                 }
            }
          
            //build map of relevant status based on applicable column IDs
            Map<Id, ADM_Column_Status_Assignment__c> statusByColumnIdMap = new Map<Id, ADM_Column_Status_Assignment__c>();
			for(ADM_Column_Status_Assignment__c statusAssignment : [select Work_Status__r.Name, Column__c, Column__r.Name from ADM_Column_Status_Assignment__c where Column__c in:columnIds ]) {
                //each column can have more then one status assigned.  Use the first one unless you find a partial match
                if(!statusByColumnIdMap.containsKey(statusAssignment.Column__c)) {
                    statusByColumnIdMap.put(statusAssignment.Column__c, statusAssignment);    
                } else {
                    //overwrite existing status mapping only if the Column and Status name partially match
                    if(statusAssignment.Column__r.Name.containsIgnoreCase(statusAssignment.Work_Status__r.Name)) {
                        statusByColumnIdMap.put(statusAssignment.Column__c, statusAssignment);    
                    }
                }
            }
						List<String> pTagIds = new List<String>();
            //finally loop work and assign correct status without having to query the status assignment table every time
            for(ADM_Work__c work : works) {
                 ADM_Column_Status_Assignment__c statusAssignment = statusByColumnIdMap.get(work.Column__c);
                 if(statusAssignment != null && statusAssignment.Work_Status__r.Name != null) {
					work.status__c = statusAssignment.Work_Status__r.Name;
                 } else { 
				    if(work.Scrum_Team__c != null){
                 	 teamIds.add(work.Scrum_Team__c);
					}
					else{
							pTagIds.add(work.Product_Tag__c);
					}

                 	 workIdToObjectMap.put(work.id, work);
                     //currently we only WARN when a work record is missing a column ID
                     System.debug('ADM_KanbanUtility.updateWorkWithStatus() Could not find a status mapping for Column ID:' + work.Column__c + ' assigned to work record:' + work.Name);
                 }
            }
            System.debug('columnIDs:' + columnIDs + ' statusByColumnIdMap:' + statusByColumnIdMap + ' works:' + works); 
						if(pTagIds != null && pTagIds.size() >0){
							teamIds.addAll(ADM_ProductTag.getTeamIdsFromTagIds(pTagIds));
						}
            
	    } catch(Exception e) {
	         ADM_ExceptionHandler.saveException(e, 'ADM_KanBanUtility.updateWorkWithStatus(). Line:' + e.getLineNumber() + ' Stack Trace:' + e.getStackTraceString() + ' Works:' + works);
	    }
		//Only do this if the map size is greater than 0 which means there are some work items which was not able to get a status assigned
	    if(workIdToObjectMap.size() > 0){
			List<ADM_Column__c> columnsByTeams = ADM_ColumnQueryUtils.getColumnsByTeams(teamIds);
	    	List<ADM_Column> admColumns = ADM_ColumnUtility.getRootParentColumns(columnsByTeams);
	    	Map<String, ADM_Column> columnSobjIdToADMColumnMap = new Map<String, ADM_Column>();

    		getIdToColumnMap(admColumns, columnSobjIdToADMColumnMap);

	    	Map<Id, String> columnIdToWorkStatusMap = new Map<Id,String>();
	    	List<ADM_Column_Status_Assignment__c> columnStatusAssignmentsByColumns = [select Work_Status__r.Name, Column__c, Column__r.Name from ADM_Column_Status_Assignment__c where Column__c in:columnsByTeams];
	    	for(ADM_Column_Status_Assignment__c columnStatusAssignmentsByColumn : columnStatusAssignmentsByColumns){
	    		columnIdToWorkStatusMap.put(columnStatusAssignmentsByColumn.Column__c, columnStatusAssignmentsByColumn.Work_Status__r.Name);
	    	}
			for(ADM_Work__c workThatNeedsStatusUpdate : workIdToObjectMap.values()){
				ADM_Column currentAssignedColumn = columnSobjIdToADMColumnMap.get(workThatNeedsStatusUpdate.column__c);
	    		String statusToAssign = findStatusMappingFromHierarchy(currentAssignedColumn, columnSobjIdToADMColumnMap, columnIdToWorkStatusMap);
	    		if(!ADM_TextUtils.isBlank(statusToAssign) ){
	    			workThatNeedsStatusUpdate.Status__c = statusToAssign;
	    		}
	    	}

	    }
        for(ADM_Work__c workIter: works){
            if(ADM_Work.CLOSED_LIKE_STATUSES.contains(workIter.Status__c.toLowerCase())){
                workIter.Closed_By__c = UserInfo.getUserName();
                workIter.Closed_On__c = System.now();
            }
            else{
                if(workIter.Closed_By__c != null || workIter.Closed_On__c != null){
                    workIter.Closed_By__c = null;
                    workIter.Closed_On__c = null;
                }
            }
        }
        return works;
            
    }

    public static Map<String,String> getWorkStatusToColumnMapping(String teamId){
    	Map<String,String> workStatusToADMColumn = new Map<String,String>();
    	
    	
    	List<ADM_Column__c> columnSObjects = ADM_ColumnQueryUtils.getColumnsByTeam(teamId);
        List<ADM_Column> columnList = null;
        if(null != columnSObjects && columnSObjects.size() > 0){
            columnList = ADM_ColumnUtility.getRootParentColumns(columnSObjects);
        }

    	Map<String, ADM_Column> columnSobjIdToADMColumnMap = new Map<String, ADM_Column>();

    	getIdToColumnMap(columnList, columnSobjIdToADMColumnMap);


    	List<ADM_Column_Status_Assignment__c> columnStatusAssignments = ADM_ColumnStatusAssignment.getAssignmentsByTeams(new Set<String> {teamId});
    	for(ADM_Column_Status_Assignment__c columnAssignment : columnStatusAssignments){
    		if(workStatusToADMColumn.get(columnAssignment.Work_Status__r.Name) == null){
    			ADM_Column currentColumnFromStatusAssignment = columnSobjIdToADMColumnMap.get(columnAssignment.Column__c);
    			ADM_Column leftMostLeafColumn = findLeftmostLeafColumn(currentColumnFromStatusAssignment);
    			workStatusToADMColumn.put(columnAssignment.Work_Status__r.Name, leftMostLeafColumn.getColumnSObject().Id);
    		}
    		else{
    			continue;
    		}
    	}
    	return workStatusToADMColumn;
    }

    public static List<ADM_Color__c> getTeamColors(String teamId){
    	return ADM_Color.getTeamColors(teamId);
    }

    public static Database.SaveResult[] removeWorksFromColumn(String columnId){
    	List<ADM_Work__c> worksWithThisColumnOrChildColumns = ADM_Work.getWorksByColumnIdAndChildColumns(columnId);
    	for(ADM_Work__c work: worksWithThisColumnOrChildColumns){
    		work.column__c = null;
    	}
    	return Database.update(worksWithThisColumnOrChildColumns, false);
    }
 }