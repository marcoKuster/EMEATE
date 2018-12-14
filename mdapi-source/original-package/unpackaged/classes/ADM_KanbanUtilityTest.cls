@isTest
private class ADM_KanbanUtilityTest
{
	
	private static ADM_Product_Tag__c setUpTestProductTag(String teamName){
		ADM_Scrum_Team__c testTeam = ADM_ScrumTeam.createTestScrumTeam(teamName);
        ADM_Product_Tag__c productTagForTeam = ADM_ProductTag.createAndInsertProductTagForTeam(testTeam);
        return productTagForTeam;
	}

	@isTest
	static void blendColumnWithWorksShouldReturnWorkAssociatedToEachColumns()
	{

			ADM_Product_Tag__c productTagForTeam = setUpTestProductTag('TestTeam1');
			ADM_Scrum_Team__c[] testTeams =  ADM_ScrumTeam.getAll(productTagForTeam.Team__c);
			List<ADM_Column__c> defaultColumnsCreated = ADM_ColumnUtility.createDefaultColumns(testTeams);
			List<ADM_Column> admColumns = ADM_ColumnUtility.getRootParentColumns(defaultColumnsCreated);
			List<ADM_Work__c> testUserStories = ADM_Work.createListOfWork(10, 'User Story');

			Set<Id> testWorkIdsInNewStatus = new Set<Id>();
			Set<Id> testWorkIdsInTriagedStatus = new Set<Id>();
			Set<Id> testWorkIdsInProgressStatus = new Set<Id>();

			//Now make sure User stories have different Statuses
			testUserStories[0].Status__c = 'New';
			testUserStories[1].Status__c = 'Triaged';
			testUserStories[2].Status__c = 'In Progress';
			testUserStories[3].Status__c = 'In Progress';
			testUserStories[4].Status__c = 'In Progress';
			testUserStories[5].Status__c = 'New';
			testUserStories[6].Status__c = 'Triaged';
			testUserStories[7].Status__c = 'In Progress';
			testUserStories[8].Status__c = 'In Progress';
			testUserStories[9].Status__c = 'In Progress';



			List<ADM_Work__c> testWorks = new List<ADM_Work__c>();
			testWorks.addAll(testUserStories);
			for(ADM_Work__c testWork : testWorks){
				testWork.Product_Tag__c = productTagForTeam.Id;
			}
			insert testWorks;

			FeedItem testFeed1;
			FeedItem testFeed2;
			List<FeedItem> testFeedItems = new List<FeedItem>();
			List<Id> testWorkIds = new List<Id>();
			for(ADM_Work__c testWork : testWorks){
				testWorkIds.add(testWork.Id);
				testFeed1 = new FeedItem();
    			testFeed1.Body = 'Test feed1 for apex test';
	    		testFeed1.ParentId = testWork.Id;
	    	
	    		testFeed2 = new FeedItem();
	    		testFeed2.Body = 'Test feed2 for apex test';
	    		testFeed2.ParentId = testWork.Id;
	    		testFeedItems.add(testFeed1);
	    		testFeedItems.add(testFeed2);

	    		if(testWork.Status__c == 'New'){
	    			testWorkIdsInNewStatus.add(testWork.id);
	    		}
	    		else if(testWork.Status__c == 'Triaged'){
	    			testWorkIdsInTriagedStatus.add(testWork.id);
	    		}
	    		else if(testWork.Status__c == 'In Progress'){
	    			testWorkIdsInProgressStatus.add(testWork.Id);
	    		}
			}

			
			//Create EntitySubscription for first work in the list...List keeps order so will
			EntitySubscription[] testEnitySubscriptions = ADM_EntitySubscriptionUtils.createTestWorkEntitySubscriptions(testWorks[0].Id, new List<String>{UserInfo.getUserId()});
			testEnitySubscriptions.addAll(ADM_EntitySubscriptionUtils.createTestWorkEntitySubscriptions(testWorks[6].Id, new List<String>{UserInfo.getUserId()}));

			Set<Id> testWorkIdForWhichEntitySubscriptionCreated = new Set<Id>();

			testWorkIdForWhichEntitySubscriptionCreated.add(testWorks[0].Id);
			testWorkIdForWhichEntitySubscriptionCreated.add(testWorks[6].Id);

			testWorks = ADM_Work.getWorksForKanban(testWorkIds);
			Map<String,List<ADM_ColumnHistory.AggregatedColumnHistory>> aggregatedColumnHistories = ADM_ColumnHistory.getDurationFromColumnHistory(testWorkIds);
			System.debug(aggregatedColumnHistories.size());//Reminder - change this or this will fail test.

			ADM_Theme__c testTheme = ADM_ThemeUtils.createTestTheme('Theme' + Math.random());
			ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
			themeAssignment.Work__c = testWorkIds.get(0);
			themeAssignment.Theme__c = testTheme.Id;
			insert themeAssignment;

			Map<Id, List<ADM_Theme_Assignment__c>> workIdToThemAssignments = ADM_ThemeUtils.getThemeAssignmentsByWork(testWorkIds);

			List<ADM_Column> returnedColumns = ADM_KanbanUtility.blendColumnWithWorks(admColumns, testWorks, testFeedItems, testEnitySubscriptions, aggregatedColumnHistories, workIdToThemAssignments);

			for(ADM_Column returnedColumn : returnedColumns){
				for(ADM_Column.ColumnWorkItem columnWork: returnedColumn.getWorkItems()){
					System.assertEquals(2, columnWork.numberOfPosts,' Work item for Column ' + returnedColumn.getColumnName() + ' comments(feed) number didnot match');
					if(testWorkIdForWhichEntitySubscriptionCreated.contains(columnWork.workId)){
						System.assertEquals(true, columnWork.isUserSubscribed,' Work item for Column ' + returnedColumn.getColumnName() + ' should be subscribed by current user - EntitySubscription was created above');
					}
					//ColumnHistory will be populated for all work items...but only checking here for the some here to avoid redundant testing code and save apex test running time.
					System.assertNotEquals(null, columnWork.columnIdToTimeSpent, 'Expected ColumnHistory for Work item');
					for(String key : columnWork.columnIdToTimeSpent.keyset()){
						Map<String,String> timeDetailsMap = columnWork.columnIdToTimeSpent.get(key);
						System.assertEquals(3, timeDetailsMap.size(), ' Expected totalWorkDays, totalActualDays and totalActualDaysStr for work column History');
						System.assertNotEquals(null, timeDetailsMap.get('totalWorkDays'), 'Expected totalWorkDays in work column history');
						System.assertNotEquals(null, timeDetailsMap.get('totalActualDays'), 'Expected totalActualDays in work column history');
						System.assertNotEquals(null, timeDetailsMap.get('totalActualDaysStr'), 'Expected totalActualDaysStr in work column history');
					}
				}
				
				if(returnedColumn.getColumnName() == 'New'){// New column will have the works in New and Triaged status
					System.assertEquals(testWorkIdsInNewStatus.size() + testWorkIdsInTriagedStatus.size(), returnedColumn.getWorkItems().size(), ' Expected New column work items number = Works in New Status + Works in Triaged Status');
				}
				if(returnedColumn.getColumnName() == 'UI In Progress'){
					System.assertEquals(testWorkIdsInProgressStatus.size(), returnedColumn.getWorkItems().size(), ' UI In  Progress column work item number didnot match');
				}
			}

	}

	@isTest
	static void updateWorkWithColumnsShouldUpdateColumnOnStatusChange()
	{
		ADM_Product_Tag__c productTagForTeam = setUpTestProductTag('TestTeam1'); 
		ADM_Scrum_Team__c[] testTeams =  ADM_ScrumTeam.getAll(productTagForTeam.Team__c);
		List<ADM_Column__c> defaultColumnsCreated = ADM_ColumnUtility.createDefaultColumns(testTeams);
		List<ADM_Work__c> testUserStories = ADM_Work.createListOfWork(2, 'User Story');

		Set<String> workStatusesNeedingColumn = new Set<String>(); 
		Set<String> workTeamIds = new Set<String>();

		/*
		    To avoid the complexity of future methods and other technical difficulties, test below is not going to do update on work record,
		    rather we will pass in the work ids and status and unit test the code by asserting on the expected scenario.


		*/
		for(ADM_Work__c testWork : testUserStories){
			testWork.Product_Tag__c = productTagForTeam.Id;
			testWork.Status__c = 'In Progress';
			workStatusesNeedingColumn.add('In Progress');
			workTeamIds.add(productTagForTeam.Team__c);
			System.assert(null != productTagForTeam.Team__c);
		}
		insert testUserStories;

		List<Id> workIds = new List<Id>(); 
		
		for(ADM_Work__c testWork : testUserStories){
			workIds.add(testWork.Id);
		}


		Map<String,String> columnNameToColumnIdMap = new Map<String,String>();
		for(ADM_Column__c columnSObject : defaultColumnsCreated){
			columnNameToColumnIdMap.put(columnSObject.Name, columnSObject.Id);
		}


		
		List<ADM_Work__c> worksAfterColumnUpdate = ADM_KanbanUtility.updateWorkWithColumns(workIds, workTeamIds);
		String columnIdOfInProgressLeftMostChild = [Select id from Adm_column__c where Parent_Column__c =:ColumnNameToColumnIdMap.get('In Progress') and Level__c =0 and Position__c = 0 ].Id;//Expectation is that In Progress has only one level of child here so getting the left most child.
		
		for(ADM_Work__c workIter: worksAfterColumnUpdate){
			System.assert(null != workIter.Column__c, 'Expected column value to be populated');
			System.assertEquals(columnIdOfInProgressLeftMostChild, workIter.Column__c, 'Expected In Progress column but got different. Find the column name based on Actual Column value from this map for debugging '+ columnNameToColumnIdMap);
		}

	}

	@isTest
    static void getLeafColumnsWithPathInfoTest(){

        ADM_Product_Tag__c productTagForTeam = setUpTestProductTag('TestTeam1'); 
        ADM_Scrum_Team__c[] testTeams =  ADM_ScrumTeam.getAll(productTagForTeam.Team__c);
        List<ADM_Column__c> defaultColumnsCreated = ADM_ColumnUtility.createDefaultColumns(testTeams);

        String code_in_progressID = '';
        //Create some complicated children columns Under In Progress > Code In Progress
        for(ADM_Column__c column : defaultColumnsCreated){
            if('Code In Progress'.equalsIgnoreCase(column.Name)){
                code_in_progressID = column.Id;
            }
        }

        ADM_Column__c cip1 = ADM_ColumnUtility.createColumn('CIP1', code_in_progressID, 0, 0, productTagForTeam.Team__c); 
        insert cip1;
        ADM_Column__c cip2 = ADM_ColumnUtility.createColumn('CIP2', cip1.Id, 0, 0, productTagForTeam.Team__c); 
        insert cip2;

        List<ADM_Column__c> cip2Children = new List<ADM_Column__c>();
        ADM_Column__c cip2_1 = ADM_ColumnUtility.createColumn('CIP2.1', cip2.Id, 0, 0, productTagForTeam.Team__c); 
        cip2Children.add(cip2_1);
        ADM_Column__c cip2_2 = ADM_ColumnUtility.createColumn('CIP2.2', cip2.Id, 0, 0, productTagForTeam.Team__c); 
        cip2Children.add(cip2_2);
        ADM_Column__c cip2_3 = ADM_ColumnUtility.createColumn('CIP2.3', cip2.Id, 0, 0, productTagForTeam.Team__c); 
        cip2Children.add(cip2_3);

        insert cip2Children;

        ADM_Column__c cip2_2_1 = ADM_ColumnUtility.createColumn('CIP2.2.1', cip2_2.Id, 0, 0, productTagForTeam.Team__c); 

        insert cip2_2_1;

        List<ADM_Column__c> columnSObjects = ADM_ColumnQueryUtils.getColumnsByTeam(productTagForTeam.Team__c);
        List<ADM_Column> admColumns = null;
        if(null != columnSObjects && columnSObjects.size() > 0){
            admColumns = ADM_ColumnUtility.getRootParentColumns(columnSObjects);
        }
        Set<String> closedColumnIds = ADM_ColumnUtility.getKanbanClosedColumns(productTagForTeam.Team__c);
        List<ADM_ColumnUtility.LeafNodeDetails> leafNodeDetailsList = ADM_KanbanUtility.getLeafColumnsWithPathInfo(admColumns,closedColumnIds);

        boolean expectedPathFound = false;
        for(ADM_ColumnUtility.LeafNodeDetails leafNodeDetails:leafNodeDetailsList ){
            if('In Progress > Code In Progress > CIP1 > CIP2 > CIP2.2 > CIP2.2.1'. equals(leafNodeDetails.Path)){
                System.assertEquals(cip2_2_1.Id , leafNodeDetails.columnId, 'Expected Column CIP2.2.1 to be created with Parent CIP2.2');
                expectedPathFound = true;
            }
        }
        System.assertEquals(true, expectedPathFound, 'Expected path In Progress > Code In Progress > CIP1 > CIP2 > CIP2.2 > CIP2.2.1 doesnot exist');
    }

	@isTest
    static void shouldUpdateWorkWithColumnForNewWorks(){

            Test.startTest();

            List<Id> workIdsThatNeedsColumnChange = new List<Id>();
            Set<String> workTeamIds = new Set<String>();
        	ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('Purple Team');
			ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTagForTeam(team); 		
        
            List<ADM_Work__c> testUserStories = ADM_Work.createListOfWork(2, 'User Story');
 
            for(ADM_Work__c testWork : testUserStories){
                testWork.Scrum_Team__c = team.Id;
                testWork.Status__c = 'In Progress';
                testWork.Product_Tag__c = productTag.Id;
                
                upsert testWork;
                
                workIdsThatNeedsColumnChange.add(testWork.Id);
                workTeamIds.add(testWork.Scrum_Team__c);
                System.assertEquals(null, testWork.Column__c);
            }
            
        	List<String> teamIds = new List<String>(workTeamIds);

        	ADM_Scrum_Team__c[] testTeams =  new List<ADM_Scrum_Team__c>();
        	testTeams.add(team);
        	
            List<ADM_Column__c> defaultColumnsCreated = ADM_ColumnUtility.createDefaultColumns(testTeams);
            
            ADM_KanbanUtility.updateWorkWithColumnsSync(workIdsThatNeedsColumnChange, workTeamIds);
            
            testUserStories = [Select Column__c, Scrum_Team__c, Id, Name from ADM_Work__c where Id in :testUserStories];

            Test.stopTest();
        
            System.assert( testUserStories.size() == 2 , 'The user story list was the wrong size' );
            
        	for(ADM_Work__c testWork : testUserStories){
                System.assert(null != testWork.Column__c, 
                              'The Column__c did not have an column populated' + testWork.Name + ':' + testWork.Id + ':' + testWork.Scrum_Team__c + ':' );
			}
		}
   
}