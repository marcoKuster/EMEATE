@isTest
private class ADM_BacklogUtilityTest {
    
    @isTest static void testGetMasterBacklog() {
        Set<String> additionalFields = new Set<String>();
        additionalFields.add('Epic__c');
        additionalFields.add('Scheduled_Build__c');
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug', additionalFields);
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        //Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_BacklogController.QueryParameters parameters = new ADM_BacklogController.QueryParameters();
        parameters.teamId = getTeamId(works);
        ADM_BacklogController.BackLogManagerResponse response = ADM_BacklogUtility.getPanelWorkItemsByType(parameters, 'backlog', false, 10, 0);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected all of the work items to be returned');
    }

    @isTest static void testGetBackburnerPanel() {
        Set<String> additionalFields = new Set<String>();
        additionalFields.add('Sprint__c');
        additionalFields.add('QA_Engineer__c');
        additionalFields.add('Product_Owner__c');
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug', additionalFields);
        for(ADM_Work__c work : works) {
            work.Status__c = 'New';
            work.Use_Prioritizer__c = true;
            work.Priority_Rank__c = null;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];

        ADM_BacklogController.QueryParameters parameters = new ADM_BacklogController.QueryParameters();
        parameters.teamId = getTeamId(works);
        
        ADM_BacklogController.BackLogManagerResponse response = ADM_BacklogUtility.getPanelWorkItemsByType(parameters, 'backburner', false, 10, 0);
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getBackburner to return all of the work items');
    }

    @isTest static void testGetFeatureBacklog() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'User Story');
        for(ADM_Work__c work : works) {
            work.Status__c = 'New';
            work.Use_Prioritizer__c = true;
            work.Priority_Rank__c = 1;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];

        ADM_BacklogController.QueryParameters parameters = new ADM_BacklogController.QueryParameters();
        parameters.teamId = getTeamId(works);
        
        ADM_BacklogController.BackLogManagerResponse response = ADM_BacklogUtility.getPanelWorkItemsByType(parameters, 'featureBacklog', false, 10, 0);
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getBackburner to return all of the work items');
    }

    @isTest static void testGetTrustBacklog() {
        ADM_Theme__c trustTheme = ensureTrustTheme();
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        upsert works;
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        
        //create theme assignments for each work item relating to the theme
        List<ADM_Theme_Assignment__c> themeAssignments = new List<ADM_Theme_Assignment__c>();
        for(ADM_Work__c work : works) {
           ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
           themeAssignment.Work__c = work.id;
           themeAssignment.Theme__c = trustTheme.id;
           themeAssignments.add(themeAssignment);
        }
        insert themeAssignments;
        
        //get the team of the work items

        ADM_BacklogController.QueryParameters parameters = new ADM_BacklogController.QueryParameters();
        parameters.teamId = getTeamId(works);
        
        Test.startTest();
        ADM_BacklogController.BackLogManagerResponse response = ADM_BacklogUtility.getPanelWorkItemsByType(parameters, 'trustBacklog', false, 10, 0);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getTrustBacklog to return all of the work items');
    
    }

   /* @isTest static void testGetThemeBacklog() {
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'Test Theme';
        theme.Active__c = true;
        insert theme;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        upsert works;
        
        List<ADM_Theme_Assignment__c> taList = new List<ADM_Theme_Assignment__c>();
        for(ADM_Work__c work : works) {
           //relate the themes to work records
           ADM_Theme_Assignment__c ta = new ADM_Theme_Assignment__c();
           ta.Work__c = work.id;
           ta.Theme__c = theme.id;
           taList.add(ta);
        }
        insert taList;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_BacklogController.BackLogManagerResponse response = ADM_BacklogUtility.getPanelWorkItemsByType(teamId, 'themeBacklog', false, 10, 0);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getThemeBacklog to return all of the work items');
    
    }

    @isTest static void testGetScheduledBuildBacklog() {
        ADM_Build__c build = new ADM_Build__c();
        build.Name = 'Test Build';
        insert build;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Scheduled_Build__c = build.Id;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_BacklogController.BackLogManagerResponse response = ADM_BacklogUtility.getPanelWorkItemsByType(teamId, 'themeBacklog', false, 10, 0);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getScheduledBuildBacklog to return all of the work items');
    
    }*/

    @isTest static void testGetDefaultBackLogColumns() {
        
        List<ADM_BacklogController.BackLogColumn> backlog_list = ADM_BacklogUtility.getDefaultBackLogColumns();
        System.assert( backlog_list.size() > 0 );
                
        // Let's assert a few items from the default list, not the entire set
        for ( ADM_BacklogController.BackLogColumn backlog_item : backlog_list  ){
            
            if ( backlog_item.value == 'work.Name' ){
                System.assert( backlog_item.showLabel == true );
                System.assert( backlog_item.required == true );
                System.assert( backlog_item.sortable == true );                
            }
            if ( backlog_item.value == 'work.Subject' ){
                System.assert( backlog_item.showLabel == true );
                System.assert( backlog_item.required == true );
                System.assert( backlog_item.sortable == true );
            }
            if ( backlog_item.value == 'work.Sprint__c' ){
                System.assert( backlog_item.showLabel == true );
                System.assert( backlog_item.required == true );
                System.assert( backlog_item.sortable == true );
            }
        }
    }

    @isTest static void testGetSprintChart() {

        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);
        sprint.Start_Date__c = System.today();
        sprint.End_Date__c = System.today() + 15;
        sprint.Total_Workdays__c=12; 
        
        update sprint;
        
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Story_Points__c = 3;
        // The fake the Sprint created above is pushed out 60 to 75 days (beginning and end)
        // So we'll leave the Closed Status__c commented out so the trtigger doesn't
        // override the pushing out the Closed date by 65 days
        // story.Status__c = 'Closed';
        story.Closed_On__c = Date.today().addDays(6);
        update story;
        
        List<ADM_Sprint__c> sprint_list = new List<ADM_Sprint__c>();
        sprint_list.add(sprint);
            
        new ADM_SprintBurnDownUtils().createSprintBurnDownIdeal( sprint_list );
        //List<ADM_Work__c> deets = [SELECT Closed_On__c, Status__c, Sprint__c from ADM_Work__c WHERE Sprint__c =:sprint.Id];

        ADM_Chart chart = ADM_BacklogUtility.getSprintChart( (String)sprint.Id );

        System.assertEquals('Day', chart.getXAxis().getTitle() );
        System.assertEquals('Story Points', chart.getYAxis().getTitle() );
        System.assertEquals('Burn Down', chart.title );        
        
        List<ADM_Chart.Series> series_list = chart.getSeriesList();
        System.assertEquals( 2 , series_list.size(), 'Expected only two series data points.');
       
        Boolean found_ideal = false;
        Boolean found_real = false;
        List<Object> ideal_objects = new List<Object>();
 		List<Object> real_objects = new List<Object>();

        for ( ADM_Chart.Series series_item : series_list ){
            if ( series_item.name == 'Real Burndown' ){
            	found_real = true;   
				real_objects = series_item.data;
            }
            if ( series_item.name == 'Ideal Burndown' ){
                found_ideal = true;
                ideal_objects = series_item.data;
            }
        }
        
        System.assert(found_ideal, 'The ideal series data was not available');
        System.assert(found_real, 'The real series data was not available');
        
        System.assert( 0 < real_objects.size() , 'The real object series list had zero entries.');
        System.assert( 0 < ideal_objects.size() , 'The ideal object series list had zero entries.');
        
        Boolean ideal_had_a_positive = false;
        Boolean real_had_a_positive = false;
        
        for ( Object o : ideal_objects ){
            if ( o instanceof Double ){
                Double d = (Double) o;
                System.assert( 0.0 <= d , 'The ideal series data wasn\'t a positive number ' + d);
                if ( 0.0 < d ) ideal_had_a_positive = true;
            }
        }

        for ( Object o : real_objects ){
            if ( o instanceof Double ){
                Double d = (Double) o;
                System.assert( 0.0 <= d , 'The real series data wasn\'t a positive number ' + d);
                if ( 0.0 < d ) real_had_a_positive = true;
            }
        }

        System.assert( ideal_had_a_positive , 'The ideal series data did not have a single positive number');
        System.assert( real_had_a_positive , 'The real series data did not have a single positive number');
        
    }

    @isTest static void testGetTaskHoursSprintChart() {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprintForTeam(team);
        sprint.Start_Date__c = System.today();
        sprint.End_Date__c = System.today() + 15;
        sprint.Total_Workdays__c=12; 
        
        update sprint;
       
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Story_Points__c = 3;
        story.Closed_On__c = Date.today().addDays(6);
        update story;

        ADM_Task__c task = new ADM_Task__c(Subject__c = 'Task1', Assigned_To__c = UserInfo.getUserId(), Actual_Hours__c = 10, Hours_Remaining__c = 10, Starting_Hours__c = 10, Work__c = story.id, Completed_On__c=Date.today().addDays(6));
        insert task;
       
        List<ADM_Sprint__c> sprint_list = new List<ADM_Sprint__c>();
        sprint_list.add(sprint);
            
        new ADM_SprintBurnDownUtils().createSprintBurnDownIdeal( sprint_list );

        ADM_Chart chart = ADM_BacklogUtility.getSprintChart( (String)sprint.Id, 'Task Hours');

        System.assertEquals('Day', chart.getXAxis().getTitle() );
        System.assertEquals('Task Hours', chart.getYAxis().getTitle() );
        System.assertEquals('Burn Down', chart.title );        
        
        List<ADM_Chart.Series> series_list = chart.getSeriesList();
        System.assertEquals( 2 , series_list.size(), 'Expected only two series data points.');
       
        Boolean found_ideal = false;
        Boolean found_real = false;
        List<Object> ideal_objects = new List<Object>();
        List<Object> real_objects = new List<Object>();

        for ( ADM_Chart.Series series_item : series_list ){
            if ( series_item.name == 'Real Burndown' ){
                found_real = true;   
                real_objects = series_item.data;
            }
            if ( series_item.name == 'Ideal Burndown' ){
                found_ideal = true;
                ideal_objects = series_item.data;
            }
        }
        
        System.assert(found_ideal, 'The ideal series data was not available');
        System.assert(found_real, 'The real series data was not available');
        
        System.assert( 0 < real_objects.size() , 'The real object series list had zero entries.');
        System.assert( 0 < ideal_objects.size() , 'The ideal object series list had zero entries.');
        
        Boolean ideal_had_a_positive = false;
        Boolean real_had_a_positive = false;
        
        for ( Object o : ideal_objects ){
            if ( o instanceof Double ){
                Double d = (Double) o;
                System.assert( 0.0 <= d , 'The ideal series data wasn\'t a positive number ' + d);
                if ( 0.0 < d ) ideal_had_a_positive = true;
            }
        }

        for ( Object o : real_objects ){
            if ( o instanceof Double ){
                Double d = (Double) o;
                System.assert( 0.0 <= d , 'The real series data wasn\'t a positive number ' + d);
                if ( 0.0 < d ) real_had_a_positive = true;
            }
        }

        System.assert( ideal_had_a_positive , 'The ideal series data did not have a single positive number');
        System.assert( real_had_a_positive , 'The real series data did not have a single positive number');
        
    }

    @isTest
    static void testBackLogControllerThrowsExceptionOnNullInput() {
        
        ADM_BacklogController.QueryParameters params = new ADM_BacklogController.QueryParameters();
        params.sprintId = '';
        
        ADM_BacklogUtility.SprintBacklogPanel panel = 
            new ADM_BacklogUtility.SprintBacklogPanel();        
        
        try {
            // Since we're only checking the params object, the other inputs can be bogus (i.e. nulls)
            panel.getWorkItems(params, null, 10, 10);
            System.assert(false,'An exception should be thrown here.');
        } catch (Exception e) {
            System.assertEquals('No sprintId was found in parameters.', e.getMessage());
        }
        
    }

    private static Id getTeamId(List<ADM_Work__c> works) {
        Id teamId = (works == null || works.isEmpty()) ? null : works.get(0).Scrum_Team__c;
        if(teamId == null) {
            throw new ADM_ApplicationException('Scrum_Team__c is null');
        }
        return teamId;
    }   

    private static ADM_Theme__c ensureTrustTheme() {
        ADM_Theme__c trustTheme = new ADM_Theme__c();
        trustTheme.Name = 'Trust';
        insert trustTheme;
        return trustTheme;
    }
}