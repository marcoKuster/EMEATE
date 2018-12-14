@isTest
private class ADM_VelocityChartTest
{
	@isTest
	public static void testGetVelocityChartInfo() {

		ADM_Work__c story = ADM_Work.createTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);

		Date startDate = Date.today(); 
        Date endDate = Date.today().addDays(15);
        
        String sprintMonth = startDate.month().format();
        if(sprintMonth.length() == 1) {
            sprintMonth = '0' + sprintMonth;
        }
        String sprintName = startDate.year() + '.' + sprintMonth + 'a';
        
        ADM_Sprint__c sprint = new ADM_Sprint__c(Name = sprintName, Scrum_Team__c = story.Scrum_Team__c, Start_Date__c = startDate, End_Date__c = endDate);
        insert sprint;
        
      
		story.Sprint__c = sprint.id;
		story.Story_Points__c =3;
		update story;

		Test.startTest();
		story.Status__c = 'Closed';
		update story; 
		Test.stopTest();
		ADM_Sprint__c sprint1 = [Select id, Name, Completed_Story_Points__c from ADM_Sprint__c where id = : sprint.Id limit 1];
		System.assertEquals(sprint1.Completed_Story_Points__c,3);

		ADM_Chart chart = ADM_VelocityChart.getVelocityChartInfo(null,story.Scrum_Team__c);

		System.assertEquals('Completed Story Points',chart.getYAxis().getTitle());
		System.assertEquals('',chart.getXAxis().getTitle());
		System.assertEquals(1,chart.getXAxis().getCategories().size());
		System.assertEquals(sprint.Name,chart.getXAxis().getCategories().get(0));
		
		ADM_Chart.Series series = chart.getSeriesList().get(0);
		
		System.assertEquals(3,series.data.get(0));

		
	}
}