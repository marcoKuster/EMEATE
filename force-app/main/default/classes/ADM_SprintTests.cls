public with sharing class ADM_SprintTests {
    
    testMethod static void testCannotChangeStartDateAfterStart() {
        
        //create a sprint that is currently open
        Date startDate = Date.today().addDays(-1);
        Date endDate = startDate.addDays(14);
        ADM_Sprint__c sprint = createAndInsertTestSprint(startDate, endDate);
        
        try {
            Test.startTest();
            //change the sprint date
            sprint.Start_Date__c = Date.today();
            update sprint;
            Test.stopTest();
            System.assert(false, 'Expected the update to fail because the start date cant be changed after a sprint has started');
        } catch(Exception exc) {
            System.assert(exc.getMessage().contains('change') && exc.getMessage().contains('start date'), 'Expected the update to fail because the start date cant be changed after a sprint has started. Actual:' + exc.getMessage());
        }
    }
    
     testMethod static void testChangeStartDate() {
        
        //create a sprint that is in the future
        //using hard-coded dates because the logic for burndown items doesn't count weekends and the asserts below rely 
        //on exact numbers. 
        Date startDate = Date.newInstance(2026, 01, 01);
        Date endDate = Date.newInstance(2026, 01, 15);
        ADM_Sprint__c sprint = createAndInsertTestSprint(startDate, endDate);
        
        Test.startTest();
        sprint.Start_Date__c = Date.newInstance(2026, 01, 15);
        sprint.End_Date__c = Date.newInstance(2026, 01, 31);
        update sprint;
        Test.stopTest();
        
        //check to make sure the burn down items have been updated
        List<ADM_Burndown_Item__c> burndownItems = [select Id, Type__c, Date__c from ADM_Burndown_Item__c where Sprint__c = :sprint.Id order by Date__c];
        Map<String, List<ADM_Burndown_Item__c>> burndownItemsByType = new Map<String, List<ADM_Burndown_Item__c>>();
        for(ADM_Burndown_Item__c burndownItem : burndownItems) {
            System.assert(burndownItem.Type__c != null, 'Expected every burndown item to have a type');
            
            if(burndownItemsByType.containsKey(burndownItem.Type__c)) {
                burndownItemsByType.get(burndownItem.Type__c).add(burndownItem);
            } else {
                burndownItemsByType.put(burndownItem.Type__c, new List<ADM_Burndown_Item__c>{burndownItem});
            }
        }
        
        System.assertEquals(13, burndownItemsByType.get('Actual').size(), 'Expected there to be 13 actual burndown items - one for each weekday');
        System.assertEquals(13, burndownItemsByType.get('Baseline').size(), 'Expected there to be 13 baseline burndown items - one for each weekday');
        System.assertEquals(sprint.Start_Date__c, burndownItemsByType.get('Actual').get(0).Date__c, 'Expected the date of the first actual burndown item to match the first day of the sprint');
        System.assertEquals(sprint.Start_Date__c, burndownItemsByType.get('Baseline').get(0).Date__c, 'Expected the date of the first baseline burndown item to match the first day of the sprint');
    }
    
    testMethod static void testStartDateMustBeAfter1950() {
        try {
            Date startDate = Date.newInstance(1949, 01, 01);
            Date endDate = Date.newInstance(2026, 01, 15);
            ADM_Sprint__c sprint = createAndInsertTestSprint(startDate, endDate);
            System.assert(false, 'Expected an exception to be thrown since the start date is older than 1950');
        } catch(Exception exc) {
            System.assert(exc.getMessage().contains('Start date must be after'), 'Expected an exception to be thrown about the start date being older than 1950: ' + exc.getMessage());
        }
    }
    
    testMethod static void testTotalWorkingDaysChangesForChangeOfDateOnUpdate() {
        try {
            Date startDate = Date.today().toStartofWeek().addDays(7); //Done the way James wanted so that we know the number of working days in the sprint.
            Date endDate = Date.today().toStartofWeek().addDays(21);
            ADM_Sprint__c sprint = createAndInsertTestSprint(startDate, endDate);
            sprint = [SELECT  Start_Date__c,End_Date__c,Total_Workdays__c from ADM_Sprint__c];
            System.assertEquals(sprint.Total_Workdays__c,10,'Total work days gets set before insertion of the sprint');        
            sprint.End_Date__c = Date.today().toStartofWeek().addDays(23);
            update sprint;
            sprint = [SELECT  Start_Date__c,End_Date__c,Total_Workdays__c from ADM_Sprint__c];
            System.assertEquals(sprint.Total_Workdays__c,12,'Total work days gets updated once the sprint\'s start or end date is updated !');
        } catch(Exception exc) {
            System.debug('Exception : '+exc);
        }
    }
    
    private static ADM_Sprint__c createAndInsertTestSprint(Date startDate, Date endDate) {
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        
        String sprintMonth = startDate.month().format();
        if(sprintMonth.length() == 1) {
            sprintMonth = '0' + sprintMonth;
        }
        String sprintName = startDate.year() + '.' + sprintMonth + 'a';
        ADM_Sprint__c sprint = new ADM_Sprint__c();
        sprint.Name = sprintName;
        sprint.Scrum_Team__c = team.id;
        sprint.Start_Date__c = startDate;
        sprint.End_Date__c = endDate;
        insert sprint;
        
        return sprint;
    }
}