public with sharing class ADM_ThroughputChart {
	public static Map<String,Integer> numberOfDaysTillPreviousWeek;
	public static List<ADM_ThroughputData> throughputData;
	public static Map<String,ADM_ThroughputData> throughputMapOfClosedWeekWithObject;
	public static List<Datetime> endDatesOfEachOfTheNWeeks; //end dates of each of the 'n' weeks.
	public ADM_ThroughputChart() {

	}

	public static void initializeThroughputData(){
		numberOfDaysTillPreviousWeek = new Map<String,Integer>();
		createStartOfPreviousWeekMap(); //custom Map for finding the start of last week given today's date.
		throughputData = new List<ADM_ThroughputData>();
		throughputMapOfClosedWeekWithObject = new Map<String,ADM_ThroughputData>();
		endDatesOfEachOfTheNWeeks = new List<Datetime>();
	}

	public static ADM_Chart getThroughputChartForTeamAndGivenNumberOfWeeks(Integer numOfWeeks, String teamId){
		//Default numOfWeeks to 12 if null.
		if(numOfWeeks == null){
			numOfWeeks = 12;
		}

		//Ideally should be done in the constructor. Not sure how its called in a utility class like this.
		initializeThroughputData();

		List<ADM_Work__c> listOfWork = new List<ADM_Work__c>();

		//End Date Calculation.
		Datetime endDate = Datetime.now(); //Today's date is the ideal end date but we ignore current week. 
		Datetime startOfPreviousWeekFromEndDate = findStartOfPreviousWeek(endDate); // We ignore this week and take start of last week as end date for making it easier. This variable holds date for last monday.
		Datetime endOfPreviousWeek = startOfPreviousWeekFromEndDate.addDays(6); //So we got start of last week. But end of last week is the actual end date. So Last week's Sunday should be end date.
		
		//Number of Days Calculaion
		//For example lets say throughput chart for last 12 weeks. 
		//So 11 weeks before start of last week (which is a Monday) is start date. 
		//So 11 weeks before last Monday is again a monday since we are doing 11*7 = 77 days from last Monday. 
		//Including last week's 7 days it will be 84 days = 12 weeks which was the intended number of days.
		Integer numOfDays = (numOfWeeks-1) * 7 * -1; //Say, numofweeks=12, so 11*7=77. We multiply by -1 to go backwards in addDays method.

		//Start Date calculation
		Datetime startDate = startOfPreviousWeekFromEndDate.addDays(numOfDays); 

		//Query Work items for team where the closed_on__c falls between start and end date.
		listOfWork = [Select id,Name,Closed_On__c,RecordType.Name from ADM_Work__c where Scrum_Team__c = :teamId and Closed__c = 1 and Closed_On__c >= : startDate and Closed_On__c <= :endOfPreviousWeek and (RecordType.Name = 'Bug' or RecordType.Name = 'User Story' or RecordType.Name = 'Investigation')];

				
		//We need to store the actual date values in a List. Say the actual dates for last 12 weeks.  
		endDatesOfEachOfTheNWeeks = findEndOfEachOfLastNWeeks(startDate,numOfWeeks);

		//We use the ADM_Thruput wrapper class to store all values. Ideally for 12 weeks we will create 12 instances of the ADM_Thruput.
		//After getting the last N weeks we store it in a Map with the date as the key and ADM_Thruput as the value.
		for(Datetime dt : endDatesOfEachOfTheNWeeks){
			ADM_ThroughputData thruput = new ADM_ThroughputData(dt);
			throughputData.add(thruput);
			throughputMapOfClosedWeekWithObject.put(dt.format('M/d/YYYY'),thruput);
		}

		//We now have a Map with the last 12 weeks as the key and ADM_Thruput as values. We have already queried the Work items. 
		//Now we iterate thru the work items and calculate which week each of them fall into and update the bug/story/investigation count in the ADM_Thruput object.
		calculateWorkClosedCountForEachWeek(listOfWork);

		return createAndSetChartObject();
		
	}


	public static ADM_Chart createAndSetChartObject(){
		ADM_Chart throughputChart = new ADM_Chart('Weekly Throughput', '');
        ADM_Chart.YAxis yAxis = new ADM_Chart.YAxis('Number of Work Items Closed');
        ADM_Chart.XAxis xAxis = new ADM_Chart.XAxis('');


        //create categories for X axis
        List<Object> categories = new List<Object>();

        //Create and Set Series and data for Y axis
        ADM_Chart.Series bugSeries = new ADM_Chart.Series('Bugs');
        ADM_Chart.Series userStorySeries = new ADM_Chart.Series('User Stories');
        ADM_Chart.Series investigationSeries = new ADM_Chart.Series('Investigations');
        List<Object> bugData = new List<Object>();
        List<Object> userStoryData = new List<Object>();
        List<Object> investigationData = new List<Object>();

        for(DateTime dt: endDatesOfEachOfTheNWeeks){ //Using the list to iterate thru the Map since Map does not hold the order.
        	String str = dt.format('M/d/YYYY');
        	ADM_ThroughputData tpd = throughputMapOfClosedWeekWithObject.get(str);
        	if(tpd != null){
        		bugData.add(tpd.bugCount);
        		userStoryData.add(tpd.userStoryCount);
        		investigationData.add(tpd.investigationCount);
        	}
        	//Set categories for x axis
        	categories.add(str);

        }

        //Set the data for the 3 series 
        bugSeries.setData(bugData);
        userStorySeries.setData(userStoryData);
        investigationSeries.setData(investigationData);

        //add category for x axis
        xAxis.setCategories(categories);

        //Set x axis, y axis and series for the full chart;
        throughputChart.setXAxis(xAxis);
        throughputChart.setYAxis(yAxis);
        throughputChart.getSeriesList().add(bugSeries);
        throughputChart.getSeriesList().add(userStorySeries);
        throughputChart.getSeriesList().add(investigationSeries);

		return throughputChart;

	}


	public static void calculateWorkClosedCountForEachWeek(List<ADM_Work__c> listOfWork){

		for(ADM_Work__c work : listOfWork){
			Datetime dt = findtheEndDateOfWeekTheWorkItemWasClosed(work); //Main method which calculates which week the work's closed date falls into. 
			String dateInString = dt.format('M/d/YYYY');
			ADM_ThroughputData thruput = throughputMapOfClosedWeekWithObject.get(dateInString);
			if(thruput != null){
				if(work.RecordType.Name == 'Bug')
					thruput.bugCount+=1;
				else if (work.RecordType.Name == 'User Story')
					thruput.userStoryCount+=1;
				else if (work.RecordType.Name == 'Investigation')
					thruput.investigationCount+=1;
			}
			throughputMapOfClosedWeekWithObject.put(dateInString, thruput);
		}
	}

	public static Datetime findtheEndDateOfWeekTheWorkItemWasClosed(ADM_Work__c work){
		//Doing a version of binary search to find out which week the work was closed. 
		//Doing a binary vs a linear search because the list with which we are searching is sorted. 
		//It is much faster and cuts down the possibilities in half for every iteration.

		Integer start = 0;
		Integer end1 = endDatesOfEachOfTheNWeeks.size()-1;
		Integer mid;

		if(work.Closed_On__c <= endDatesOfEachOfTheNWeeks.get(start))
			return endDatesOfEachOfTheNWeeks.get(start);
		else if(work.Closed_On__c >= endDatesOfEachOfTheNWeeks.get(end1))
			return endDatesOfEachOfTheNWeeks.get(end1);

		while(start<=end1){
			mid = (start+end1)/2;

			//Special case when start and end are equal to mid
			if(mid==0 && work.Closed_On__c <= endDatesOfEachOfTheNWeeks.get(mid))
				return endDatesOfEachOfTheNWeeks.get(mid);
			if(mid == end1 && work.Closed_On__c >= endDatesOfEachOfTheNWeeks.get(mid)){
				return endDatesOfEachOfTheNWeeks.get(mid);
			}

			//Regular cases for binary search
			//Between mid and mid-1
			if(work.Closed_On__c <= endDatesOfEachOfTheNWeeks.get(mid) && work.Closed_On__c > endDatesOfEachOfTheNWeeks.get(mid-1))
				return endDatesOfEachOfTheNWeeks.get(mid);
			//Between mid and mid+1
			if(work.Closed_On__c <= endDatesOfEachOfTheNWeeks.get(mid+1) && work.Closed_On__c > endDatesOfEachOfTheNWeeks.get(mid))
				return endDatesOfEachOfTheNWeeks.get(mid+1);
			//Between mid and mid+1 but equal to mid
			if(work.Closed_On__c < endDatesOfEachOfTheNWeeks.get(mid+1) && work.Closed_On__c >= endDatesOfEachOfTheNWeeks.get(mid))
				return endDatesOfEachOfTheNWeeks.get(mid);
			//Between mid-1 and mid but equal to mid-1
			if(work.Closed_On__c < endDatesOfEachOfTheNWeeks.get(mid) && work.Closed_On__c >= endDatesOfEachOfTheNWeeks.get(mid-1))
				return endDatesOfEachOfTheNWeeks.get(mid-1);
			
			//If not any of these cases we reduce possibilities by half.
			if(work.Closed_On__c < endDatesOfEachOfTheNWeeks.get(mid)){
				end1 = mid-1;
			}
			else if(work.Closed_On__c > endDatesOfEachOfTheNWeeks.get(mid)){
				start = mid+1;
			}

		}

		//It will never reach this point since we will return earlier for all cases.
		return null;

	}

	public static Datetime findStartOfPreviousWeek(Datetime dateObj){
		String day = dateObj.format('E','GMT');
		Integer numOfDays =  numberOfDaysTillPreviousWeek.get(day);
		return dateObj.addDays(numOfDays);
	}

	public static List<Datetime> findEndOfEachOfLastNWeeks(Datetime startDate, Integer numOfWeeks){
		Integer i = 1;
		Datetime obj = startDate.addDays(6);
		List<DateTime> endDatesOf12Weeks = new List<DateTime> ();
		Datetime tempObj;
		while(i<=numOfWeeks){
			tempObj = obj.addDays(7);
			endDatesOf12Weeks.add(obj);
			obj = tempObj;
			i++;
		}

		return endDatesOf12Weeks;
	}

	public static void createStartOfPreviousWeekMap(){
		//Just a Map to find out the start of last week with respect to today. 
		numberOfDaysTillPreviousWeek.put('Mon',-7);
		numberOfDaysTillPreviousWeek.put('Tue',-8);
		numberOfDaysTillPreviousWeek.put('Wed',-9);
		numberOfDaysTillPreviousWeek.put('Thu',-10);
		numberOfDaysTillPreviousWeek.put('Fri',-11);
		numberOfDaysTillPreviousWeek.put('Sat',-12);
		numberOfDaysTillPreviousWeek.put('Sun',-13);
	}

	public class ADM_ThroughputData{
		Integer bugCount;
		Integer userStoryCount;
		Integer investigationCount;
		Datetime endDateOfWeek;

		public ADM_ThroughputData(Datetime endDate){
			this.bugCount = 0;
			this.userStoryCount = 0;
			this.investigationCount = 0;
			this.endDateOfWeek = endDateOfWeek;
		}
	}
}