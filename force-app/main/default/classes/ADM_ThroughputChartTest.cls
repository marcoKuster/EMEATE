@isTest
private class ADM_ThroughputChartTest {
	
	@isTest static void testGetThroughputChartForTeamAndGivenNumberOfWeeks() {
		List<ADM_Work__c> listOfWorks = new List<ADM_Work__c>();
		ADM_Work__c bug1 = ADM_Work.setupTestWork('Bug');
		listOfWorks.add(bug1);

		ADM_Work__c us1 = ADM_Work.setupTestWork('User Story');
		us1.Product_Tag__c = bug1.Product_Tag__c;
		us1.Scrum_Team__c = bug1.Scrum_Team__c;
		listOfWorks.add(us1);


		
		ADM_Work__c inv1 = ADM_Work.setupTestWork('Investigation');
		inv1.Product_Tag__c = bug1.Product_Tag__c;
		inv1.Scrum_Team__c = bug1.Scrum_Team__c;
		listOfWorks.add(inv1);

		insert listOfWorks;


		ADM_ThroughputChart.initializeThroughputData();
		
		listOfWorks = new List<ADM_Work__c>();
		bug1.Status__c='Closed';
		listOfWorks.add(bug1);
		us1.Status__c = 'Closed';
		listOfWorks.add(us1);
		inv1.Status__c = 'Closed - Defunct';
		listOfWorks.add(inv1);
		update listOfWorks;

		listOfWorks = new List<ADM_Work__c>();
		DateTime startofLastWeek = ADM_ThroughputChart.findStartOfPreviousWeek(Datetime.now());
		Datetime newDate = startofLastWeek.addDays(1);
		bug1.Closed_On__c = newDate;
		listOfWorks.add(bug1);
		us1.Closed_On__c = newDate.addDays(-5);
		listOfWorks.add(us1);
		inv1.Closed_On__c = newDate.addDays(-14);
		listOfWorks.add(inv1);
		update listOfWorks;

		ADM_Chart chart = ADM_ThroughputChart.getThroughputChartForTeamAndGivenNumberOfWeeks(12,bug1.Scrum_Team__c);

		System.assertEquals('Number of Work Items Closed',chart.getYAxis().getTitle());
		System.assertEquals('',chart.getXAxis().getTitle());
		System.assertEquals(12,chart.getXAxis().getCategories().size());
		System.assertEquals(startofLastWeek.addDays(6).format('M/d/YYYY'),chart.getXAxis().getCategories().get(11));

		System.assertEquals(3,chart.getSeriesList().size());

		for (ADM_Chart.Series series : chart.getSeriesList()){
			if(series.name == 'User Stories'){
				System.assertEquals(1,series.data.get(10));
			}
			if(series.name == 'Bugs'){
				System.assertEquals(1,series.data.get(11));
			}
			if(series.name == 'Investigations'){
				System.assertEquals(1,series.data.get(9));
			}
		}


	}
	
}