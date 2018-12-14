public with sharing class ADM_SprintChartsController2 {

	public Id sprintId { get; set; }

	private static Integer DEFAULT_SPRINTS = 6;
	private static Integer TOTAL_SPRINTS = 0;
	private static Integer DEFAULT_CHART_HEIGHT = 256;

    public static final Integer VIEW_BY_USER = 0;
    public static final Integer VIEW_BY_STORY = 1;
    public static final Integer VIEW_BY_ROLE = 2;

    private ADM_Sprint__c m_sprintBacklog;

    private Map<Id,String> m_idToMemberNameMap;
    private Map<Id,List<ADM_Task__c>> m_ownerIdToTaskListMap;
    private Map<Id,List<ADM_Task__c>> m_storyIdToTaskListMap;
    private Map<Id,String> m_idToStoryNameMap;
    private Map<Id, ADM_Task__c> m_idToTaskMap;
    public Map<Id, Double> m_idHoursAvailableMap;
    public Map<Id, Double> m_idHoursAssignedMap;
    private Map<Id, Double> m_idHoursStoryMap;
    private Map<Id, ADM_Scrum_Team_Member__c> m_idToMemberObjMap;

    private List<Id> m_memberIdsSet;
    private List<Id> m_storyIdsSet;

    private ADM_Scrum_Team_Member__c[] m_scrumTeamMembers;
    private ADM_Time_Off_Log__c[] m_ptoResults;
    private ADM_Time_Off_Log__c[] m_companyHolidaysResults;
    private ADM_Work__c[] m_storiesAndTasks, m_storiesToAdd;
    private List<ADM_Burndown_Item__c> m_burndownItems;

    private Boolean m_initDone;
    private Integer m_viewChartByOption;

    private Id m_taskIdForUpdate;

	private List<HoursByAssigneeChartData> m_hoursByAssigneeChartData;

	public Id m_scrumTeamId;

    //RESULT LISTS & STRINGS
    public ADM_SprintChartsController2() {
    	m_initDone = false;
        m_idToMemberNameMap = new Map<Id,String>();
        m_idToStoryNameMap = new Map<Id, String>();
        m_memberIdsSet = new List<Id>();
        m_idHoursAvailableMap = new Map<Id, Double>();
        m_idHoursAssignedMap = new Map<Id, Double>();
        m_idToMemberObjMap = new Map<Id, ADM_Scrum_Team_Member__c>();
        m_hoursByAssigneeChartData = null;
    }

    public ADM_SprintChartsController2(ADM_SprintVirtualWallController controller) {
	    this();
    }

    public ADM_SprintChartsController2(String sprintId) {
    	this();
    	this.sprintId = sprintId;
    	init();
    }

    public void init() {

    	if (!m_initDone) {
    		m_initDone = true;

	        try {
				if(sprintId != null) {

		        	m_sprintBacklog = [SELECT Scrum_Team__c,Name, Hours_in_a_work_day__c, Discount_Work__c, Start_Date__c, End_Date__c, Total_Workdays__c  From ADM_Sprint__c WHERE Id = :sprintId];
		        	sprintId = m_sprintBacklog.Id;
				} else {

					return;
				}

				m_scrumTeamId = m_sprintBacklog.Scrum_Team__c;

		        initializeScrumTeamMembers();
		        initializeStoriesAndTasks();
		        initializeBurndownItems();
		        initializeCompanyHolidays();

				// Need to get available hours data for proper calculation of all the chart data.
				calculateAvailableHoursData();

				// Default view chart is by user
		        m_viewChartByOption = VIEW_BY_USER;

	        }catch (System.Exception e)  {


	        }
    	}
    }

	/*************************
	 **  GETTERS and SETTERS
	 *************************/
    public List<ADM_Sprint__c> sprints {
        get {
        	if(sprints == null) {
	            sprints = new List<ADM_Sprint__c>();
	            String teamId = getScrumTeamId();
				sprints = getMySprints(teamId,6);
        	}
            return sprints;
        }
        set;
    }

	public ADM_Sprint__c getThisSprint() {
		if (!m_initDone) {
			init();
		}
		return m_sprintBacklog;
	}

	public void setThisSprint(ADM_Sprint__c s) {
		m_sprintBacklog = s;
	}

    public Integer getDefaultChartHeight() {
    	return DEFAULT_CHART_HEIGHT;
    }

    public Integer getHoursByAssigneeChartDataHeight() {
    	if (m_HoursByAssigneeChartData == null) {
    		getHoursByAssigneeChartData();
    	}
    	Integer chartHeight = DEFAULT_CHART_HEIGHT;
    	if (m_HoursByAssigneeChartData.size() > 12) {
    		// The default chart height of 256 will support up to 12 names before names start getting dropped to fit in the
    		// vertical space. After 12 we need to start bumping up the height. We will bump the height by 20 for each name
    		// over 12
    		chartHeight = chartHeight + (20 * (m_HoursByAssigneeChartData.size() - 12));
    	}
    	return chartHeight;
    }

    public List<HoursByAssigneeChartData> getHoursByAssigneeChartData() {
    	if (m_HoursByAssigneeChartData != null) {
    		return m_hoursByAssigneeChartData;
    	}

		if (!m_initDone) {
			init();
		}

		m_HoursByAssigneeChartData = new List<HoursByAssigneeChartData>();

        try {
            if ( m_viewChartByOption == VIEW_BY_USER ) {
            	// View by User
                for (Id mid:m_memberIdsSet ){
                	String memName = m_idToMemberNameMap.get( mid );
                    if ( memName == null) {
    	            	memName = mid;
            	    } else if ( memName.length() > 15 ){
                        memName = memName.substring(0,12)+'...';
    	            }

                    if ( m_idHoursAvailableMap.get(mid) == null || m_idHoursAssignedMap.get( mid ) == null ) continue;

					m_hoursByAssigneeChartData.add(getHoursByAssigneeChartData(memName,m_idHoursAvailableMap.get(mid),m_idHoursAssignedMap.get(mid)));
                }
            } else if ( m_viewChartByOption == VIEW_BY_ROLE ) {
            	// View by Role
            	Map<String,Double> roleToHoursAvailable = new Map<String,Double>();
            	Map<String,Double> roleToHoursAssigned = new Map<String,Double>();
                for (Id mid:m_memberIdsSet ){
                	String memName = m_idToMemberObjMap.get(mid).Role__c;
                	if ( memName == null ) {
                    	memName = 'Other';
                	}

                    if ( m_idHoursAvailableMap.get(mid) == null || m_idHoursAssignedMap.get( mid ) == null ) continue;

					if (roleToHoursAvailable.get(memName) == null) {
						roleToHoursAvailable.put(memName, m_idHoursAvailableMap.get(mid));
						roleToHoursAssigned.put(memName, m_idHoursAssignedMap.get(mid));
					} else {
						// Remove the hoursAvailable and hoursAssigned values from the map for the current role. The remove
						// call will return the current value.  Increment the value, and add it back to the map.
						Double hoursAvailable = roleToHoursAvailable.remove(memName);
						roleToHoursAvailable.put(memName, hoursAvailable + m_idHoursAvailableMap.get(mid));
						Double hoursAssigned = roleToHoursAssigned.remove(memName);
						roleToHoursAssigned.put(memName, hoursAssigned + m_idHoursAssignedMap.get(mid));
					}
                }
                // Loop through all role names
                for (String memName : roleToHoursAvailable.keySet()) {
					m_hoursByAssigneeChartData.add(getHoursByAssigneeChartData(memName, roleToHoursAvailable.get(memName), roleToHoursAssigned.get(memName)));
                }
            } else {
            	// View by Story

                for (Id sid:m_storyIdsSet ) {
                    String storyName = m_idToStoryNameMap.get( sid );
                    if ( storyName.length() > 15 ) storyName = storyName.substring(0,12)+'...';
                    if ( m_idHoursStoryMap.get( sid ) != null && m_idHoursStoryMap.get( sid ) > 0.0 && storyName.length() > 0 ) {

                        m_HoursByAssigneeChartData.add(new HoursByAssigneeChartData(storyName,
                        					m_idHoursStoryMap.get( sid ),
                        					0,
                        					0));
                    }
                }
            }
        } catch (Exception e ) {
            // do nothing

        }
        if (m_hoursByAssigneeChartData.size() == 0) {
        	// No data available.  Need to initialize data so a blank chart is displayed
            m_HoursByAssigneeChartData.add(new HoursByAssigneeChartData('',
            					0,
            					0,
            					0));

        }
        return m_HoursByAssigneeChartData;
    }

    public void calculateAvailableHoursData() {
		if (!m_initDone) {
			init();
		}

        try {
	        Id scrumTeamId = m_sprintBacklog.Scrum_Team__c;

	        Double hoursInDay = m_sprintBacklog.Hours_in_a_work_day__c;
	        Double timeDiscount = m_sprintBacklog.Discount_Work__c;

	        if ( hoursInDay == null || hoursInDay == 0.0 ) hoursInDay = 6.0;
	        if ( timeDiscount == null) timeDiscount = 0.0;
	        else timeDiscount = timeDiscount/100.0;

	        Integer totalDays = m_sprintBacklog.Start_Date__c.daysBetween( m_sprintBacklog.End_Date__c );
	        Integer workingDays = 0;
	        if ( m_sprintBacklog.Start_Date__c.daysBetween( System.today() ) > 0 )
	            workingDays = ADM_SprintBurnDownUtils.daysBetweenMinusWeekends( System.today(), m_sprintBacklog.End_Date__c );
	        else
	            workingDays = ADM_SprintBurnDownUtils.daysBetweenMinusWeekends( m_sprintBacklog.Start_Date__c, m_sprintBacklog.End_Date__c );
	        // I think daysBetweenMinusWeekends returns the days between so if you want to count today you need to +1 so doing this;
	        Double hoursRemaining = workingDays * hoursInDay - ( workingDays * hoursInDay * timeDiscount );


	        //GET Team member information
	        loadMemberNameMap( m_scrumTeamMembers );


	        Map<Id, Double> idToAllocationMap = new Map<Id, Double>();
	        Map<Id, String> idToNameMap = new Map<Id, String>();
	        Map<Id, Double> idToPTOMap = new Map<Id, Double>();
	        Map<Id, Double> idToAssignedHoursMap = new Map<Id, Double>();
	        m_memberIdsSet = new List<Id>();
	        for (ADM_Scrum_Team_Member__c member:m_scrumTeamMembers ) {
	            m_memberIdsSet.add( member.Member_Name__r.Id );
	            if ( member.Allocation__c != null && member.Allocation__c < 100.0 ) {
	                idToAllocationMap.put( member.Member_Name__r.Id, member.Allocation__c );
	                idToNameMap.put( member.Member_Name__r.Id, member.Member_Name__r.Name + ' ('+member.Allocation__c+'%)' );
	            } else {
	                idToAllocationMap.put( member.Member_Name__r.Id, 100.0 );
	                idToNameMap.put( member.Member_Name__r.Id, member.Member_Name__r.Name );
	            }
	            m_idToMemberObjMap.put( member.Member_Name__r.Id, member );
	        }


	        // GET Team PTO
	        initializePTOResults();
	        Map<Id, List<Date>> idToPTORange = new Map<Id, List<Date>>();
	        if ( m_companyHolidaysResults.size() > 0 ) {
	            for ( ADM_Scrum_Team_Member__c member:m_scrumTeamMembers ) {
	                for ( ADM_Time_Off_Log__c holiday:m_companyHolidaysResults ) {
	                    idToPTORange.put( member.Member_Name__r.Id, new List<Date>() );
	                    idToPTORange.get( member.Member_Name__r.Id ).addAll( new Date[]{holiday.Start_Date__c, holiday.End_Date__c} );
	                }
	            }
	        }

	        for ( ADM_Time_Off_Log__c ptoEntry: m_ptoResults ) {
	            if ( ptoEntry.RecordType.Name == 'PTOn' && ptoEntry.Approved__c == false ) continue;
	            if ( ptoEntry.RecordType.Name == 'PTOn' ) { // Handing the approved request


	                if ( ptoEntry.Start_Date__c.daysBetween( System.today() )>= 0 &&
	                     ptoEntry.End_Date__c.daysBetween( System.today() ) <= 0 ) { // IN THE ZONE
	                    if ( ptoEntry.Allocation__c == null ) ptoEntry.Allocation__c = 100.0;
	                    if ( idToAllocationMap.get( ptoEntry.User__r.Id ) == null ) // User is 100% allocated to the team
	                        idToAllocationMap.put( ptoEntry.User__r.Id, 100.0 - ptoEntry.Allocation__c );
	                    else {
	                        Double originalAllocation = idToAllocationMap.get( ptoEntry.User__r.Id );
	                        Double adjustedAllocation = originalAllocation* ptoEntry.Allocation__c / 100.0;

	                        idToAllocationMap.put( ptoEntry.User__r.Id, originalAllocation - adjustedAllocation );
	                    }
	                    String name = idToNameMap.get(ptoEntry.User__r.Id);
	                    if ( name.indexOf('(') > 0 )
	                        name = name.substring( 0, name.indexOf('(') -1 );
	                    name += ' ('+idToAllocationMap.get(ptoEntry.User__r.Id)+'% incl PTOn)';
	                    idToNameMap.put( ptoEntry.User__r.Id, name);

	                    continue;
	                }

	            }

	            if ( idToPTORange.get( ptoEntry.User__r.Id ) == null ){
	                idToPTORange.put( ptoEntry.User__r.Id, new List<Date>() );
	                idToPTORange.get( ptoEntry.User__r.Id ).addAll( new Date[]{ptoEntry.Start_Date__c, ptoEntry.End_Date__c} );
	            } else {
	                List<Date> dateList = idToPTORange.get( ptoEntry.User__r.Id );
	                Boolean updatedRange = false;
	                for ( Integer i = 0; i < dateList.size(); i +=2 ) {
	                    if ( ptoEntry.Start_Date__c.daysBetween( dateList[i] ) > 0 && ptoEntry.End_Date__c.daysBetween(dateList[i]) < 0
	                        && ptoEntry.End_Date__c.daysBetween( dateList[i+1] )>= 0 ) {
	                        dateList[i] = ptoEntry.Start_Date__c;
	                        updatedRange = true;
	                        break;
	                    }
	                    else if ( ptoEntry.Start_Date__c.daysBetween( dateList[i] ) >= 0 && ptoEntry.End_Date__c.daysBetween( dateList[i+1] ) <= 0 ) {
	                        dateList[i] = ptoEntry.Start_Date__c;
	                        dateList[i+1] = ptoEntry.End_Date__c;
	                        updatedRange = true;
	                        break;
	                    }
	                    else if ( ptoEntry.Start_Date__c.daysBetween( dateList[i] ) <= 0 && ptoEntry.Start_Date__c.daysBetween( dateList[i+1] ) >= 0
	                        && ptoEntry.End_Date__c.daysBetween( dateList[i+1] ) < 0 ) {
	                        dateList[i+1] = ptoEntry.End_Date__c;
	                        updatedRange = true;
	                        break;
	                    }
	                    else if ( ptoEntry.Start_Date__c.daysBetween( dateList[i] ) <= 0 && ptoEntry.End_Date__c.daysBetween( dateList[i+1] ) >= 0 ) {
	                        updatedRange = true;
	                        break;
	                    }
	                }
	                if ( !updatedRange )
	                    dateList.addAll( new Date[]{ptoEntry.Start_Date__c, ptoEntry.End_Date__c} );

	            }
	        }

	        for ( Id userId:idToPTORange.keySet() ) {
	            List<Date> dateRanges = idToPTORange.get( userId );

	            for (Integer i = 0; i< dateRanges.size(); i+=2 ) {
	                Date modifiedPTOStartDate = null;
	                Date modifiedPTOEndDate = null;
	                if ( dateRanges[i].daysBetween( m_sprintBacklog.Start_Date__c ) >=0 )
	                    modifiedPTOStartDate = m_sprintBacklog.Start_Date__c;
	                else
	                    modifiedPTOStartDate = dateRanges[i];

	                if ( modifiedPTOStartDate.daysBetween( System.today() ) >= 0 )
	                    modifiedPTOStartDate = System.today();

	                if ( dateRanges[i+1].daysBetween( m_sprintBacklog.End_Date__c ) <=0 )
	                    modifiedPTOEndDate = m_sprintBacklog.End_Date__c;
	                else
	                    modifiedPTOEndDate = dateRanges[i+1];

	                if ( modifiedPTOStartDate.daysBetween( modifiedPTOEndDate ) < 0 )
	                    modifiedPTOStartDate = modifiedPtoEndDate;

	                Double ptoDays = ADM_SprintBurnDownUtils.daysBetweenMinusWeekends(  modifiedPTOStartDate, modifiedPTOEndDate );
	                if ( idToPTOMap.get( userId ) == null )
	                    idToPTOMap.put( userId, ptoDays );
	                else
	                    idToPTOMap.put( userId, idToPTOMap.get( userId ) + ptoDays );
	            }
	        }

	        //GET STORIES AND TASKS
	        //RESET the list holder
	        m_ownerIdToTaskListMap = new Map<Id, List<ADM_Task__c>>();
	        m_storyIdToTaskListMap = new Map<Id, List<ADM_Task__c>>();
	        m_storyIdsSet = new List<Id>();
	        m_idHoursStoryMap = new Map<Id, Double>();
	        for ( ADM_Work__c storyAndTasks:m_storiesAndTasks ) {
	            m_storyIdsSet.add( storyAndTasks.Id );
	            addStoryToStoryNameMap( storyAndTasks );
	            loadTaskListMap( storyAndTasks.Tasks__r, storyAndTasks.Id );
	            for ( ADM_Task__c t:storyAndTasks.Tasks__r ) {
	                if ( t.Hours_Remaining__c == null ) t.Hours_Remaining__c = 0.0;
	                if ( idToAssignedHoursMap.get( t.Assigned_To__c) == null )
	                    idToAssignedHoursMap.put( t.Assigned_To__c, t.Hours_Remaining__c );
	                else
	                    idToAssignedHoursMap.put( t.Assigned_To__c, idToAssignedHoursMap.get( t.Assigned_To__c ) + t.Hours_Remaining__c );
	                if ( m_idHoursStoryMap.get( storyAndTasks.Id ) == null )
	                    m_idHoursStoryMap.put( storyAndTasks.Id, t.Hours_Remaining__c );
	                else
	                    m_idHoursStoryMap.put( storyAndTasks.Id, m_idHoursStoryMap.get( storyAndTasks.Id ) + t.Hours_Remaining__c );
	            }
	        }

            for (Id id:m_memberIdsSet ){

				String name = '';
				if ( m_viewChartByOption == VIEW_BY_USER ) {
                	name = idToNameMap.get(id);
				} else {
					// Else by role
	                name = m_idToMemberObjMap.get(id).Role__c;
	                if ( name == null )
	                    name = 'Other';
				}

                Double assignedHours = idToAssignedHoursMap.get(id);

                if ( assignedHours == null ) assignedHours = 0.0;
                assignedHours = roundToNearest( assignedHours, 10 );

                Double pto = idToPTOMap.get( id );
                if ( pto == null ) pto = 0.0;
                else if (pto < 0 ) {
                    pto= 0.0;
                }

                Double availableHours = ( workingDays - pto ) * hoursInDay -
                                        ( workingDays - pto ) * hoursInDay * timeDiscount;
                if ( availableHours < 0.0 ) availableHours = 0.0;

                availableHours *= idToAllocationMap.get(id)/100.0;

                availableHours = Math.round( availableHours * 10.0 ) / 10.0;

                m_idHoursAvailableMap.put( id, availableHours );
                m_idHoursAssignedMap.put( id, assignedHours );
            }


        } catch (System.Exception e) {

        }
    }

    public String getBurndownChartURL() {
		if (!m_initDone) {
			init();
		}

        try {
	        List<Double>baselineItems = new List<Double>();
	        List<Double>actualItems = new List<Double>();
	        List<String>dates = new List<String>();
	        Double max = 0.0;
	        String lastDate = '';
	        Double todayIndex = -1.0;
	        String todayLabel = null;
	        Double todayPosition = -1.0;

	        if ( m_burndownItems.size() > 0 ) {

		  dates.add( getStringDateForChart( m_burndownItems.get(0).Date__c ) );
	            lastDate = getStringDateForChart( m_burndownItems.get(0).Date__c );
	            dates.add( getStringDateForChart( m_burndownItems.get(m_burndownItems.size()-1).Date__c ) );
	        } else return '';

	        Integer totalSize = m_burndownItems.size()/2;

	        for ( ADM_Burndown_Item__c b:m_burndownItems ) {
	            if ( b.Type__c == 'Baseline' )
	                baselineItems.add( b.Hours_Remaining__c );
	            else if ( b.Type__c == 'Actual' ) {  // Actual
	                if ( b.Date__c.daysBetween( System.today() ) >= 0 )
	                    actualItems.add( b.Hours_Remaining__c );
	                else actualItems.add( -1.0 );
	            }

	            try {
		            if(b.Hours_Remaining__c != null) {
		            	max = Math.ceil( Math.max( max, b.Hours_Remaining__c ) );
		            }
	            } catch (Exception e) {

	            }

	            if ( b.Type__c == 'Baseline' && todayLabel == null && System.today().daysBetween( b.Date__c ) >= 0 ) {
	                todayLabel = getStringDateForChart( System.today() );
	                // USE Min since I want the current position - 1 either the actual or the baseline will be that since
	                // this should be the first time I run into the date.
	                todayPosition = Math.round( (baselineItems.size()-0.5) * 1000.0 / totalSize )/10.0;
	                todayIndex = baselineItems.size() - 1;
	            }

	        }

	        //Don't display anything if TODAY is before the first burndown item
	        if ( System.today().daysBetween( m_burndownItems.get(0).Date__c ) >= 0 ) todayLabel = null;

	        ADM_GoogleChartOptions chartOptions = new ADM_GoogleChartOptions();
	        chartOptions.setStaticAxisLabels( dates );
	        chartOptions.setChartTitle( 'Sprint Burndown' );
	        List< List<Double> > dataLists = new List< List<Double> >();
	        chartOptions.setDataSetColors( new String[]{ 'FF0000','0000FF'} );
	        chartOptions.setShouldNormalizeData( false );
	        if ( todayLabel != null ) {
	            chartOptions.setStaticAxisMarkerLabels( new String[]{ todayLabel } );
	            chartOptions.setStaticAxisMarkerLabelPositions( new Double[]{ todayPosition } );
	            chartOptions.setStaticAxisMarkers( new Double[]{ todayIndex } );
	            chartOptions.setDataSetToMark( 1 );

	            //create the flag for the base line
                Double baselineValue = 0.0;
                if(baselineItems.get( todayIndex.intValue() ) > 0) {
                    baselineValue = Math.round(baselineItems.get( todayIndex.intValue() )*10.0)/10.0;
                }
                chartOptions.addChartFlag( ''+baselineValue, 'FF0000', 0, Math.round(todayIndex), 10 );

                //create the flag for the actual line
                if ( todayIndex >= actualItems.size() )
                    chartOptions.addChartFlag( ''+actualItems.get( actualItems.size()-1 ), '0000FF',1,actualItems.size()-1 , 10 );
                else
                    chartOptions.addChartFlag( ''+actualItems.get( todayIndex.intValue() ), '0000FF', 1, Math.round(todayIndex), 10 );
	        }
	        dataLists.add( baselineItems );
	        dataLists.add( actualItems );
	        String burndownChartURL = ADM_GoogleChartsHelper.getURLForLineChart( ADM_GoogleChartsHelper.SMALL_CHART, dataLists, chartOptions );

	        return burndownChartURL;
	    } catch (System.Exception e) {

        	return null;
        }
    }

    public Integer getViewChartByOption() {
		if (!m_initDone) {
			init();
		}

    	return m_viewChartByOption;
	}

    public List<SelectOption> getViewByOptions() {
		if (!m_initDone) {
			init();
		}

        List<SelectOption> l = new List<SelectOption>();
        l.add( new SelectOption( String.valueOf( VIEW_BY_USER ), 'By User' ) );
        l.add( new SelectOption( String.valueOf( VIEW_BY_STORY ), 'By Story' ) );
        l.add( new SelectOption( String.valueOf( VIEW_BY_ROLE ), 'By Role' ) );
        return l;
    }

    public Id getScrumTeamId() {
		if (!m_initDone) {
			init();
		}

    	return m_scrumTeamId;
    }

	public void setScrumTeamId(String scrumTeamId) {
		m_scrumTeamId = scrumTeamId;
	}

	public String getSelectedList() {
		return '';
	}

    public void setTaskIdForUpdate(Id tid ) {
        m_taskIdForUpdate = tid;
    }

    public void setViewChartByOption( Integer i ) {
        m_viewChartByOption = i;
    }

	/********************
	 ** REMOTE ACTIONS & AURA ENABLED
	 ********************/
	@RemoteAction
	public static Integer getTotalSprints(String teamId) {
		Integer counter = [select count() from ADM_Sprint__c a where a.Completed_Story_Points__c != null and a.Scrum_Team__c = :teamId and a.Days_Remaining__c like 'CLOSED%' limit 10];
		return counter;
	}

	@AuraEnabled
	public static String getTotalSprintsAura(String teamId) {
		Integer counter = ADM_SprintChartsController2.getTotalSprints(teamId);
		String counterJSON = JSON.serialize(counter);
		return counterJSON;
	}

	@RemoteAction
	public static Integer getTotalSprintsWithCommitments(String teamId) {
		Integer counter = [select count() from ADM_Sprint__c a where a.Committed_Story_Points_Completed__c != null and a.Scrum_Team__c = :teamId and a.Days_Remaining__c like 'CLOSED%' limit 10];
		return counter;
	}

	@AuraEnabled
	public static String getTotalSprintsWithCommitmentsAura(String teamId) {
		Integer counter = ADM_SprintChartsController2.getTotalSprintsWithCommitments(teamId);
		
		String counterJSON = JSON.serialize(counter);
		
		return counterJSON;
	}

	@RemoteAction
	public static List<ADM_Sprint__c> getCurrSprints(String teamId, Integer numberSprints) {
		ADM_SprintChartsController2 sc = new ADM_SprintChartsController2();
		List<ADM_Sprint__c> results = sc.getMySprints(teamId, numberSprints);
		return results;
	}

	@AuraEnabled
	public static String getCurrSprintsAura(String teamId, String numberSprints) {
		Integer numSprints = Integer.valueOf(numberSprints.trim());
		List<ADM_Sprint__c> results = ADM_SprintChartsController2.getCurrSprints(teamId, numSprints);
		String resultsJSON = JSON.serialize(results);
		return resultsJSON;
	}

	@RemoteAction
	public static String updateSprintBurndownChart(Id sprintId) {
		ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprintId);
		return sc.getBurndownChartURL();
	}

	@RemoteAction
	public static HoursByAssigneeChart updateHoursAvailableChart(Id sprintId, Integer viewChartByOption) {
		ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprintId);
		sc.setViewChartByOption(viewChartByOption);
		HoursByAssigneeChart chartInfo = new HoursByAssigneeChart();
		chartInfo.chartData = sc.getHoursByAssigneeChartData();
		chartInfo.chartHeight = sc.getHoursByAssigneeChartDataHeight();
		return chartInfo;
	}

	@AuraEnabled
	public static String updateHoursAvailableChartAura(Id sprintId, Integer viewChartByOption) {
		HoursByAssigneeChart chartInfo = ADM_SprintChartsController2.updateHoursAvailableChart(sprintId, viewChartByOption);
		String chartInfoJSON = JSON.serialize(chartInfo);
		return chartInfoJSON;
	}

	@RemoteAction
    public static void recalcBaseline(Id sprintId) {
        ADM_Sprint__c sprint = [select Scrum_Team__c, Start_Date__c, End_Date__c, Total_Workdays__c
            from ADM_Sprint__c where Id = :sprintId];
        ADM_SprintBurnDownUtils.recalculateBaseline( sprint );
    }

	/**********************
	 ** Helper Methods
	 **********************/
	private List<ADM_Sprint__c> getMySprints(String teamId, Integer numberSprints) {
		Integer breakPt;
		Integer maxNum = 10;

        List<ADM_Sprint__c> sprintResults = new List<ADM_Sprint__c>();
        List<ADM_Sprint__c> sprints2Return = new List<ADM_Sprint__c>();

    	sprintResults = [select a.Hours_in_a_work_day__c, a.Name, a.Start_Date__c, a.End_Date__c, a.Days_Remaining__c, a.Committed_Story_Points_Completed__c, a.Completed_Story_Points__c, a.Completion_Committed_Story_Points__c from ADM_Sprint__c a where a.Completed_Story_Points__c != null and a.Scrum_Team__c = :teamId and a.Days_Remaining__c like 'CLOSED%' order by a.End_Date__c desc limit 10];

    	TOTAL_SPRINTS = sprintResults.size();

    	if(numberSprints > TOTAL_SPRINTS || numberSprints < 2) {
    		breakPt = DEFAULT_SPRINTS;
    	} else {
    		breakPt = numberSprints;
    	}

        for(ADM_Sprint__c sprintResult : sprintResults) {
            sprints2Return.add(sprintResult);
            if(sprints2Return.size() == breakPt) break;
        }

        return sprints2Return;
	}

    private String getStringDateForChart( Date d ) {
        return d.month()+'/'+d.day();
    }
/*
@testcaseID a1DB00000000QTx
@userstory a07B0000000NsMtIAK
@Expected Results When days pass in a sprint, the sprint burndown is updated and calculated by the amount of hours in a day, bringing down the hours for each team member
@Hierarchy GUS.ScrumforceToGUS.Social Sprint.Charts and Tasks.Detail page
*/

    static testMethod void testStringDateForChart() {
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
        Date d = Date.newInstance(2008, 1, 1);
        System.assertEquals('1/1', sc.getStringDateForChart(d));
    }

    private void initializeScrumTeamMembers() {
        m_scrumTeamMembers = [SELECT Member_Name__r.Id, Member_Name__r.Name, Allocation__c, Role__c FROM ADM_Scrum_Team_Member__c WHERE Scrum_Team__r.Id  = :m_sprintBacklog.Scrum_Team__c ORDER BY Member_Name__r.Name ];
    }
/*
@testcaseID a1DB00000002chr
@userstory a07B0000000NsMtIAK
@Expected Results The blue bar represents the number of hours available that are not assigned to any tasks. The green bar represents the assigned hours. The red bar represents the hours assigned to tasks that are over the available hours.
@Hierarchy GUS.ScrumforceToGUS.Social Sprint.Charts and Tasks.Detail page
*/
    static testMethod void testInitializeScrumTeamMembers() {
    	ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
		System.assert(sc.m_scrumTeamMembers != null);
		System.assertEquals(1, sc.m_scrumTeamMembers.size());
    }

    private void initializePTOResults() {
        m_ptoResults = [SELECT Id, User__r.Id, Start_Date__c, End_Date__c, Allocation__c, Approved__c, RecordType.Name FROM ADM_Time_Off_Log__c WHERE User__r.Id IN :m_memberIdsSet AND Start_Date__c <= :m_sprintBacklog.End_Date__c AND End_Date__c >= :m_sprintBacklog.Start_Date__c AND End_Date__c >= :System.Today()];
    }
/*
@testcaseID a1DB00000002chw
@userstory a07B0000000NsMtIAK
@Expected Results The time off will show as hours reduced for every team member, in the case of a company holiday, and as time reduced for a specific member, in case of PTO
@Hierarchy GUS.ScrumforceToGUS.Social Sprint.Charts and Tasks.Detail page
*/
     static testMethod void testInitializePTOResults() {
    	ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
		List<ADM_Work__c> workInSprint = [SELECT Id, Name, Subject__c, Status__c, (SELECT Id, Hours_Remaining__c, Subject__c, Work__c, Assigned_To__r.Name, Assigned_To__c, LastModifiedDate From Tasks__r ) From ADM_Work__c Where Sprint__r.Id = :sprint.id];
        List<ADM_Task__c> tasks = workInSprint[0].Tasks__r;
        ADM_Task__c task = tasks[0];
        sc.m_taskIdForUpdate = task.id;
        sc.m_viewChartByOption = ADM_SprintChartsController2.VIEW_BY_USER;
        sc.calculateAvailableHoursData();

		System.assert(sc.m_ptoResults != null);
		System.assertEquals(1, sc.m_ptoResults.size());
    }

    private void initializeCompanyHolidays() {
        m_companyHolidaysResults = [SELECT Start_Date__c, End_Date__c FROM ADM_Time_Off_Log__c WHERE RecordType.Name = 'Company Holiday' AND Start_Date__c >= :System.Today() AND Start_Date__c <= :m_sprintBacklog.End_Date__c AND End_Date__c >= :m_sprintBacklog.Start_Date__c AND End_Date__c <= :m_sprintBacklog.End_Date__c];
    }

    private void initializeBurndownItems() {
        m_burndownItems = [SELECT Date__c, Hours_Remaining__c, Type__c FROM ADM_Burndown_Item__c WHERE Sprint__r.Id = :sprintId ORDER BY Date__c ASC];
    }

    private void initializeStoriesAndTasks() {

        m_storiesAndTasks = new List<ADM_Work__c>();

        for(ADM_Work__c story:[SELECT Id, Name, Subject__c, Status__c, Theme__c, Assignee__c, Scheduled_Build__c, Story_Points__c, Closed_On__c, RecordType.Name,  (SELECT Id, Assigned_To__c, Hours_Remaining__c, Subject__c, Status__c, Work__c, Assigned_To__r.Name, LastModifiedDate From Tasks__r WHERE Status__c != 'Completed' limit 1000) From ADM_Work__c WHERE Sprint__r.Id = :sprintId and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME ORDER BY Priority_Rank__c ASC limit 1000] ) {
        	m_storiesAndTasks.add(story);
        }
    }

    private void loadMemberNameMap( ADM_Scrum_Team_Member__c[] members ) {
        if (members != null )
            for( ADM_Scrum_Team_Member__c member:members )
                m_idToMemberNameMap.put( member.Member_Name__r.Id, member.Member_Name__r.Name );
        else {
            ADM_Sprint__c backlog = [SELECT Scrum_Team__c FROM ADM_Sprint__c WHERE Id = :m_sprintBacklog.Id];
            for( ADM_Scrum_Team_Member__c member:[SELECT Member_Name__r.Id, Member_Name__r.Name FROM ADM_Scrum_Team_Member__c WHERE Scrum_Team__r.Id  = :backlog.Scrum_Team__c] )
                m_idToMemberNameMap.put( member.Member_Name__r.Id, member.Member_Name__r.Name );
        }
    }
/*
@testcaseID a1DB00000002ci1
@userstory a07B0000000NsMtIAK
@Expected Results Members of a team are added to the chart
@Hierarchy GUS.ScrumforceToGUS.Social Sprint.Charts and Tasks.Detail page
*/
    static testMethod void testLoadMemberNameMap() {
    	ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
		List<ADM_Work__c> workInSprint = [SELECT Id, Name, Subject__c, Status__c, (SELECT Id, Hours_Remaining__c, Subject__c, Work__c, Assigned_To__r.Name, Assigned_To__c, LastModifiedDate From Tasks__r ) From ADM_Work__c Where Sprint__r.Id = :sprint.id];
        List<ADM_Task__c> tasks = workInSprint[0].Tasks__r;
        ADM_Task__c task = tasks[0];
        sc.setTaskIdForUpdate(task.id);
        sc.setViewChartByOption(ADM_SprintChartsController2.VIEW_BY_USER);
        sc.calculateAvailableHoursData();

        //load the members based on a null list - the other flow is covered by previous tests
        sc.loadMemberNameMap(null);

		System.assert(sc.m_idToMemberNameMap != null);
		System.assertEquals(1, sc.m_idToMemberNameMap.size());
    }

    private void loadTaskListMap( ADM_Task__c[] taskList, Id storyId ) {

        if (m_idToTaskMap == null) m_idToTaskMap = new Map<Id,ADM_Task__c>();

        if ( taskList != null )
            for (ADM_Task__c t:taskList ) {
                if ( m_ownerIdToTaskListMap.get( t.Assigned_To__c ) != null )
                    m_ownerIdToTaskListMap.get( t.Assigned_To__c ).add( t );
                else
                    m_ownerIdToTaskListMap.put( t.Assigned_To__c, new ADM_Task__c[]{ t } );
                m_idToTaskMap.put( t.Id, t);

                if ( m_storyIdToTaskListMap.get( storyId ) != null )
                    m_storyIdToTaskListMap.get( storyId ).add( t );
                else
                    m_storyIdToTaskListMap.put( storyId, new ADM_Task__c[]{ t } );
            }
        else {
            ADM_Work__c[] storiesAndTasks = [SELECT Id, Name, Subject__c, Status__c, (SELECT Id, Hours_Remaining__c, Subject__c, Work__c, Assigned_To__r.Name, Assigned_To__c, LastModifiedDate From Tasks__r WHERE Status__c != 'Completed' ) From ADM_Work__c WHERE Sprint__r.Id = :sprintId ORDER BY Priority_Rank__c ASC];
            for( ADM_Work__c storyWithTasks:storiesAndTasks ) {
                addStoryToStoryNameMap( storyWithTasks );
                for ( ADM_Task__c t:storyWithTasks.Tasks__r ) {
                    if ( m_ownerIdToTaskListMap.get( t.Assigned_To__c ) != null )
                        m_ownerIdToTaskListMap.get( t.Assigned_To__c ).add( t );
                    else
                        m_ownerIdToTaskListMap.put( t.Assigned_To__c, new ADM_Task__c[]{ t } );
                    m_idToTaskMap.put( t.Id, t);
                    if ( m_storyIdToTaskListMap.get( storyId ) != null )
                        m_storyIdToTaskListMap.get( storyId ).add( t );
                    else
                        m_storyIdToTaskListMap.put( storyId, new ADM_Task__c[]{ t } );
                    }
            }
        }
    }
/*
@testcaseID a1DB00000002ci6
@userstory a07B0000000NsMtIAK
@Expected Results The sprint burndown calculates the total amount of hours (green line) and compares it to the ideal amount of hours that should have been burned during the sprint (red line)
@Hierarchy GUS.ScrumforceToGUS.Social Sprint.Charts and Tasks.Detail page
*/
    static testMethod void testLoadTaskListMap() {
    	ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        ADM_SprintChartsController2 sc = new ADM_SprintChartsController2(sprint.Id);
		List<ADM_Work__c> workInSprint = [SELECT Id, Name, Subject__c, Status__c, (SELECT Id, Hours_Remaining__c, Subject__c, Work__c, Assigned_To__r.Name, Assigned_To__c, LastModifiedDate From Tasks__r ) From ADM_Work__c Where Sprint__r.Id = :sprint.id];
        List<ADM_Task__c> tasks = workInSprint[0].Tasks__r;
        ADM_Task__c task = tasks[0];
        sc.m_taskIdForUpdate = task.id;
        sc.m_viewChartByOption = ADM_SprintChartsController2.VIEW_BY_USER;
        sc.calculateAvailableHoursData();

        Id storyId = workInSprint[0].id;

        //load the tasks based on a null list - the other flow is covered by previous tests
        sc.loadTaskListMap(null, storyId);

		System.assert(sc.m_storyIdToTaskListMap != null);
		System.assertEquals(1, sc.m_storyIdToTaskListMap.size());
    }

    private void addStoryToStoryNameMap( ADM_Work__c story ) {
        if ( m_idToStoryNameMap == null ) m_idToStoryNameMap = new Map<Id, String>();
        if ( m_idToStoryNameMap.get( story.Id ) == null )
            m_idToStoryNameMap.put( story.Id, story.Subject__c );
    }

    private Double roundToNearest( Double toRound, Double toThe ) {
        return Math.round( toRound * toThe )/toThe;
    }

	private static HoursByAssigneeChartData getHoursByAssigneeChartData(String assigneeName, Double hoursAvailable, Double hoursAssigned) {
    	if ( hoursAvailable < hoursAssigned ) {
			return new HoursByAssigneeChartData(assigneeName,hoursAvailable,(hoursAssigned - hoursAvailable),0);
        } else if (hoursAvailable > hoursAssigned) {
          	Double tempUnderAllocatedHours = hoursAvailable - hoursAssigned;
            return new HoursByAssigneeChartData(assigneeName,(hoursAvailable - tempUnderAllocatedHours),0,tempUnderAllocatedHours);
        } else {
            return new HoursByAssigneeChartData(assigneeName,hoursAssigned,0,0);
        }
 	}

    public String getPackageNameSpace() {
       ADM_ConstantsSingleton constants = ADM_ConstantsSingleton.getInstance();
       String namespace = constants.getNameSpace();
        if(namespace != null && namespace != '') {
            //return namespace including the trailing dot compatible with the apex:chart JavaScript API
            return ADM_TextUtils.escapeNameSpace(namespace);
        } else {
            return '';
        }
    }

 	public class HoursByAssigneeChartData {
 		public String assigneeName { get; set; }
 		public Double Assigned { get; set; }
 		public Double Over { get; set; }
 		public Double Under { get; set; }
 		public HoursByAssigneeChartData(String assigneeName, Double Assigned, Double Over, Double Under) {
			this.assigneeName = assigneeName;
			this.Assigned = Assigned;
			this.Over = Over;
			this.Under = Under;
 		}
 	}

 	public class HoursByAssigneeChart {
 		public Integer chartHeight;
 		public List<HoursByAssigneeChartData> chartData;
 	}
}