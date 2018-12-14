public with sharing class ADM_VelocityChart {
        public ADM_VelocityChart() {
                
        }

        public static ADM_Chart getVelocityChartInfo(Integer numOfSprints, String scrumTeamId){
                //Default number of sprints to 6.
                if(numOfSprints == null){
                        numOfSprints = 6;
                }

                List<ADM_Sprint__c> listOfSprints = [select id, Name, Completed_Story_Points__c from ADM_Sprint__c where Scrum_Team__c =:scrumTeamId and Start_Date__c <=: System.today() order by Start_Date__c desc limit :numOfSprints];
                return createAndSetChartObject(listOfSprints);
        }


        public static ADM_Chart createAndSetChartObject(List<ADM_Sprint__c> sprints){
                ADM_Chart velocityChart = new ADM_Chart('Velocity Chart', '');
        ADM_Chart.YAxis yAxis = new ADM_Chart.YAxis('Completed Story Points');
        ADM_Chart.XAxis xAxis = new ADM_Chart.XAxis('');


        //create categories for X axis
        List<Object> categories = new List<Object>();

        //Create and Set Series and data for Y axis
        ADM_Chart.Series series = new ADM_Chart.Series('');
        List<Object> seriesData = new List<Object>();

        for(ADM_Sprint__c sp: sprints){ 
                if(sp.Completed_Story_Points__c == null){
                        seriesData.add(0);
                }
                else{
                        seriesData.add(sp.Completed_Story_Points__c);
                }
                //Set categories for x axis
                categories.add(sp.Name);

        }

        //Set the data for the series 
        series.setData(seriesData);

        //add category for x axis
        xAxis.setCategories(categories);

        //Set x axis, y axis and series for the full chart;
        velocityChart.setXAxis(xAxis);
        velocityChart.setYAxis(yAxis);
        velocityChart.getSeriesList().add(series);

                return velocityChart;
        }
}