/* This package contains the methods used by scrumforce to manage the update 
   of the burndown chart on a sprint.  The sprint burndown chart is maintained by
   the burndown items object which contains 2 records per day per sprint: 1
   for the baseline and the second for the actuals.    
   */
 
public class ADM_SprintBurnDownUtils { 
    private static final Date KNOWN_SATURDAY = Date.newInstance(1901, 1, 5);
    
    public static ADM_Sprint__c[] daysBetweenMinusWeekendsAndCompanyHolidays( List<ADM_Sprint__c> sprints ) {
        
        //look up all company holidays regardless of start and end date
        List<ADM_Time_Off_Log__c> holidays = [SELECT Start_Date__c,End_Date__c FROM ADM_Time_Off_Log__c WHERE RecordType.Name = 'Company Holiday'];

        //loop through sprints and count how many company holidays have a date that falls within the start and end date of the sprints
        for(ADM_Sprint__c s: sprints) {
            Integer holidayCount = 0;
            
            for(ADM_Time_Off_Log__c h : holidays) {
                if(doesHolidayFallInSprint(h, s.Start_Date__c, s.End_Date__c)) {
                    //FIXME: this assumes that all holidays will only be one day in length
                    holidayCount++;
                }
            }
            
            s.Total_Workdays__c = daysBetweenMinusWeekends(s.Start_Date__c,s.End_Date__c) - holidayCount;
        }
        
        return sprints;
    }
    
    private static Boolean doesHolidayFallInSprint(ADM_Time_Off_Log__c holiday, Date startDate, Date endDate) {
        //check holiday and return true if the start and end date is applicable (assuming holiday start and end date will always be same day) (ie, Christmas and Christmas Eve must be different days)
        return (holiday.Start_Date__c >= startDate && holiday.Start_Date__c <= endDate);
    } 
    
    public static Integer daysBetweenMinusWeekends( Date startDate, Date endDate ) {
        
        if(startDate < KNOWN_SATURDAY || endDate < KNOWN_SATURDAY) {
            throw new ADM_ApplicationException('Unable to compare dates older than ' + KNOWN_SATURDAY);
        }
        
        //dayOfWeek: 0=sat, 1=sun
        Integer startDayOfWeek = getDayOfWeek(startDate);
        Integer endDayOfWeek = getDayOfWeek(endDate);
        Date modStartDate, modEndDate;
        
        // get to the monday
        if ( startDayOfWeek < 2 ) {
            modStartDate = startDate.addDays( 2 - startDayOfWeek );
        } else {
            modStartDate = startDate;
        }
        
        // get to last friday
        if ( endDayOfWeek < 2 ) { 
            modEndDate = endDate.addDays( -1 - endDayOfWeek );  
        } else {
            modEndDate = endDate;   
        }
        
        Integer difference = modStartDate.daysBetween(modEndDate) + 1;
        Integer weeks = Math.round( Math.floor(difference/7) );
        Integer calcResult = difference - weeks * 2; //remove the weekends
        Integer additionalDays = difference - 7*weeks +startDayOfWeek;
        if ( additionalDays > 7 ) {
            calcResult -= 2 ; //another weekend hidden in those extra days  
        } 
        return calcResult;
    }
    
    public Boolean isWeekend( Date d ) {
        return getDayOfWeek(d) < 2;
    }   
    
    /**
     * Gets the weekday number, which is a digit from 0 to 6, beginning with Saturday.
     * FIXME: why does this not use the ISO standard of 1=Monday to 7=Sunday?
     */
    public static Integer getDayOfWeek(Date value) {
        return Math.mod(KNOWN_SATURDAY.daysBetween(value), 7);
    }
    
    public static ADM_Sprint__c[] getSprintsForIds( Set<Id> ids ) {
        if ( ids.size() > 0 )
            return [select id, name, Start_Date__c, End_Date__c, scrum_team__c, total_workdays__c, Completed_Story_Points__c
                from ADM_Sprint__c where Id in :ids ];
        else
            return null;    
    }
      
    //This method returns the array of sprints for the given tasks
    public ADM_Work__c[] getStories(ADM_Task__c[] tasks) {
        
        //get the stories
        Set<Id> whatIdSet = new Set<Id>();
        for(ADM_Task__c task:tasks){
            if(task.Work__c != null && task.hours_remaining__c != null && task.hours_remaining__c > 0) whatIdSet.add(task.Work__c);
        }
        
        if(whatIdSet.size() == 0) return null;
        return [select Id, Sprint__c, Sprint__r.Start_Date__c, Sprint__r.End_Date__c, Sprint__r.Scrum_Team__c from ADM_Work__c where Id in :whatIdSet];
                
    }
    
    
    
    //This method returns the array of stories for the given tasks
    public ADM_Work__c[] getStories(Map<Id, ADM_Task__c> oldTasks, Map<Id, ADM_Task__c> newTasks) {
        
        //get the stories
        Set<Id> whatIdSet = new Set<Id>();
        Set<Id> idSet     = newTasks == null ? oldTasks.keySet() : newTasks.keySet();
        
        for(Id taskId:idSet){
            
            ADM_Task__c oldTask = oldTasks.get(taskId);
            
            if(newTasks != null) {
                ADM_Task__c newTask = newTasks.get(taskId);
                if(oldTask.hours_remaining__c != newTask.hours_remaining__c) whatIdSet.add(newTask.Work__c);
                
            } else if(oldTask.hours_remaining__c != null) {
                whatIdSet.add(oldTask.Work__c);  
            }
        }
        
        if(whatIdSet.size() == 0) return null;
        return [select Id, Sprint__c, Sprint__r.Start_Date__c, Sprint__r.End_Date__c, Sprint__r.Scrum_Team__c from ADM_Work__c where Id in :whatIdSet];
                
    }
    
    /**
     * Deletes all of the burndown items for the specified sprints, then recreates all of them
     */
    public void rebuildBurndownItems(ADM_Sprint__c[] sprints) {
        
        //delete all of the burndown items
        Database.delete([select ID from ADM_Burndown_Item__c where Sprint__c in :sprints and Type__c != 'DerbySprint_Baseline'], false);
        
        createItems(sprints);
    }
    
    public void createItems(ADM_Sprint__c[] sprints) {
        ADM_Burndown_Item__c[] items = new ADM_Burndown_Item__c[0];
        
        for(ADM_Sprint__c sprint : sprints) {
            //need to add a day to the end to get the sprint calculation to zero.
            Date iteratorDate = sprint.End_Date__c.addDays(1);
            //FELIX: not sure why I originally set it at -1Integer daysLeftCounter = -1;
            Integer daysLeftCounter = 0;
           
            while ( iteratorDate >= sprint.Start_Date__c ) {
                if ( isWeekend( iteratorDate ) && iteratorDate != sprint.End_Date__c.addDays(1) ) {
                    //If exclude weekends and is weekend and not the last day of sprint then skip this day.
                    iteratorDate = iteratorDate.addDays(-1);
                    continue;
                }
                
                ADM_Burndown_Item__c actualItem = new ADM_Burndown_Item__c();
                actualItem.Sprint__c          = sprint.Id;
                actualItem.Type__c            = 'Actual';
                actualItem.Date__c            = iteratorDate;
                actualItem.Scrum_Team__c      = sprint.Scrum_Team__c;
                actualItem.Days_Remaining__c  = daysLeftCounter;
                actualItem.Hours_Remaining__c = 0;
                items.add(actualItem);                                         
                
                ADM_Burndown_Item__c baselineItem = new ADM_Burndown_Item__c();
                baselineItem.Sprint__c          = sprint.Id;
                baselineItem.Type__c            = 'Baseline';
                baselineItem.Date__c            = iteratorDate;
                baselineItem.Scrum_Team__c      = sprint.Scrum_Team__c;
                baselineItem.Days_Remaining__c  = daysLeftCounter;
                baselineItem.Hours_Remaining__c = 0;
                
                items.add(baselineItem);
                daysLeftCounter += 1;
                iteratorDate = iteratorDate.addDays(-1);
            }
        }
        
        if(items.size() > 0) {
            insert items;
        }
    }   

    public void createSprintBurnDownIdeal(List<String> sprintIds){
        List<ADM_Sprint__c> sprintRecords = ADM_Sprint.getSprintsDetailsById(sprintIds);
        createSprintBurnDownIdeal(sprintRecords);
    }

    public void createSprintBurnDownIdeal(List<ADM_Sprint__c> sprints){
      if(sprints != null && sprints.size() > 0){

              List<ADM_Burndown_Item__c> burnDownItems = [Select Sprint__c, Type__c, Date__c, Scrum_Team__c, Days_Remaining__c from ADM_Burndown_Item__c
                                             where Type__c = 'DerbySprint_Baseline' and Sprint__c in :sprints order by Date__c asc];

            if(burnDownItems != null && burnDownItems.size() >0){
               deleteIdealBurnDownItems(burnDownItems);
            }

            List<ADM_Work__c> worksAssignedToThisSprint = [Select Sprint__c, Story_Points__c, Closed_On__c from ADM_Work__c where Sprint__c in :sprints];
              //Check for total Burn down items Points remaining is same as Story points or else update burndown items
            Map<String, Double> sprintIdToTotalPoints = calculateTotalStoryPointsForSprints(worksAssignedToThisSprint);

            List<ADM_Task__c> tasksInThisSprint = new List<ADM_Task__c>();

            for (ADM_Sprint__c sprint : sprints) {
                List<ADM_Task__c> tasks = [Select Actual_Hours__c, Completed_On__c, SprintId__c, Starting_Hours__c, Work__c, Work__r.Sprint__c from ADM_Task__c where Work__r.Sprint__c = :sprint.Id];
  
                if (tasks != null && tasks.size() >0) {
                    tasksInThisSprint.addAll(tasks);
                }
            }

            Map<String, Double> sprintIdToTotalHours = calculateTotalTaskHoursForSprints(tasksInThisSprint);

            createIdealBurnDownItems(sprintIdToTotalPoints, sprintIdToTotalHours, sprints);
              }
              }
    
    public Map<String, Double> calculateTotalStoryPointsForSprints(List<ADM_Work__c> works){
      Double totalStoryPoints = 0;
      Map<String, Double> sprintIdToTotalPoints = new Map<String, Double>();
      for(ADM_Work__c work : works){
          totalStoryPoints = sprintIdToTotalPoints.get(work.Sprint__c);
          Double workStoryPoint = (work.Story_Points__c == null)?0:work.Story_Points__c;
          if(totalStoryPoints == null){
            totalStoryPoints = workStoryPoint;
      }
          else{
            totalStoryPoints += workStoryPoint;
    }
          sprintIdToTotalPoints.put(work.Sprint__c, totalStoryPoints);
      }
      return sprintIdToTotalPoints;
    }

    public Map<String, Double> calculateTotalTaskHoursForSprints(List<ADM_Task__c> tasks) {
        Double totalTaskHours = 0;
        Map<String, Double> sprintIdToTotalTaskHours = new Map<String, Double>();

        for(ADM_Task__c task : tasks){
            totalTaskHours = sprintIdToTotalTaskHours.get(task.Work__r.Sprint__c);
            Double workTaskHours = (task.Starting_Hours__c == null) ? 0 : task.Starting_Hours__c;
          
            if(totalTaskHours == null){
                totalTaskHours = workTaskHours;
            } else {
                totalTaskHours += workTaskHours;
            }
          
            sprintIdToTotalTaskHours.put(task.Work__r.Sprint__c, totalTaskHours);
        }
      
        return sprintIdToTotalTaskHours;
    }

    public void deleteIdealBurnDownItems(List<ADM_Burndown_Item__c> burnDownItems){
            delete burndownItems;
        }

    private void createIdealBurnDownItems(Map<String, Double> sprintIdToTotalPoints, Map<String, Double> sprintIdToTotalHours, List<ADM_Sprint__c> sprints){
        List<ADM_Burndown_Item__c> burnDownItemsToUpdate = new List<ADM_Burndown_Item__c>();

        for(ADM_Sprint__c sprint: sprints){
        Double sprintTotalWorkDays = sprint.Total_Workdays__c;
          Integer reminingWorkDay = 1;
        Date iteratorDate = sprint.End_Date__c;
          Double totalStoryPoints = sprintIdToTotalPoints.get(sprint.Id);
            totalStoryPoints = (totalStoryPoints == null)?0:totalStoryPoints;
            Double totalTaskHours = sprintIdToTotalHours.get(sprint.Id);
            totalTaskHours = (totalTaskHours == null) ? 0 : totalTaskHours;
            Double coefficient = 0;

            if(sprintTotalWorkDays != 0){
                coefficient = totalStoryPoints / (sprintTotalWorkDays);
            }

            Double hoursCoefficient = 0;

            if(sprintTotalWorkDays != 0){
                hoursCoefficient = totalTaskHours / (sprintTotalWorkDays);
            }
          
          
        Integer daysLeftCounter = 0;

        while(iteratorDate >=  sprint.Start_Date__c){
            Double calculatedIdealStoryPoints = totalStoryPoints - (coefficient * (sprintTotalWorkDays - reminingWorkDay));
                Double calculatedIdealTaskHours = totalTaskHours - (hoursCoefficient * (sprintTotalWorkDays - reminingWorkDay));
            ADM_Burndown_Item__c burnDownItem = new ADM_Burndown_Item__c();
            burnDownItem.Points_Remaining__c = calculatedIdealStoryPoints;
                burnDownItem.Hours_Remaining__c = calculatedIdealTaskHours;
            burnDownItem.Sprint__c = sprint.Id;
            burnDownItem.Type__c = 'DerbySprint_Baseline';

            if ( isWeekend( iteratorDate ) && iteratorDate != sprint.End_Date__c ) {
                //If exclude weekends and is weekend and not the last day of sprint then skip this day.
                iteratorDate = iteratorDate.addDays(-1);
                continue;
            }

            burnDownItem.Date__c = iteratorDate;
            burnDownItem.Scrum_Team__c = sprint.Scrum_Team__c;
            burnDownItem.Days_Remaining__c  = daysLeftCounter;
            daysLeftCounter += 1;
            iteratorDate = iteratorDate.addDays(-1);
            //System.debug('Here is '+ burnDownItem);

            burnDownItemsToUpdate.add(burnDownItem);
            reminingWorkDay++;
        }
        }

        if(burnDownItemsToUpdate.size() > 0){
            upsert burnDownItemsToUpdate;
        }

    }

    public ActualSprintData getSprintRealBurnDownItems(ADM_Sprint__c sprint, String itemsType){
      ActualSprintData actualSprintData = new ActualSprintData();
      Date todayDate = System.today();
        
        if(todayDate > sprint.End_Date__c || sprint.Start_Date__c <= todayDate && sprint.End_Date__c >= todayDate){
        Map<Date, Double> sprintRealBurnDownMap = new Map<Date, Double>();
        
        if(sprint != null){
                if (itemsType == 'Story Points') {
          List<ADM_Work__c> worksInThisSprint = [ Select Sprint__c, Story_Points__c, Closed_On__c, Closed__c from ADM_Work__c where Sprint__c = :sprint.Id order BY Closed_On__c];
          actualSprintData = mapActualSprintBurndownChart(worksInThisSprint, sprint);
                } else if (itemsType == 'Task Hours') {
                    actualSprintData = mapActualSprintTaskHoursBurndownChart(sprint);
                }
        }
      }
      
      return actualSprintData;
    }

    public Map<Date, Double> getSprintIdealBurnDownItems(ADM_Sprint__c sprint) {
        return getSprintIdealBurnDownItems(sprint, 'Points');
    }

    public Map<Date, Double> getSprintIdealBurnDownItems(ADM_Sprint__c sprint, String dataType) {
        Map<Date, Double> sprintIdealBurnDownMap = new Map<Date, Double>();
        String burnDownType = 'DerbySprint_Baseline';
        
        if (dataType == 'Hours') {
            burnDownType = 'Baseline';
        }

        if (sprint != null) {
            List<ADM_Burndown_Item__c> burnDownItems = [Select Sprint__c, Type__c, Date__c, Scrum_Team__c, Days_Remaining__c, Hours_Remaining__c, Points_Remaining__c from ADM_Burndown_Item__c
                                                   where Type__c = :burnDownType and Sprint__c = :sprint.Id order by Date__c asc];
            
            sprintIdealBurnDownMap = mapIdealSprintBurndownChart(burnDownItems, dataType);
        }

        return sprintIdealBurnDownMap;
    }

    private Map<Date, Double> mapIdealSprintBurndownChart(List<ADM_Burndown_Item__c> burnDownItems, String dataType) {
        Map<Date, Double> dateToPointsMapForIdeal = new Map<Date, Double>();
        Double unitsRemaining;

        for(ADM_Burndown_Item__c burnDownItem : burnDownItems){
            if (dataType == 'Hours') {
                unitsRemaining = burnDownItem.Hours_Remaining__c;
            } else {
                unitsRemaining = burnDownItem.Points_Remaining__c;
            }

            dateToPointsMapForIdeal.put(burnDownItem.Date__c, unitsRemaining);
        }
        
        //Put an additional value to ideal burn down to show 1 more data point on XAxis Category
        if(burnDownItems != null && burnDownItems.size() >0){
          Date endDateOfSpring = burnDownItems.get(burnDownItems.size() - 1).Date__c;
          Integer counter = 1;
          while(isWeekend( endDateOfSpring.addDays(counter ))){
                counter++;
          }
          dateToPointsMapForIdeal.put(endDateOfSpring.addDays(counter ), 0);  
        }
         
        return dateToPointsMapForIdeal;
    }

    public ActualSprintData mapActualSprintBurndownChart(List<ADM_Work__c> works, ADM_Sprint__c sprint){
        ActualSprintData actualSprintData = new ActualSprintData();
        Map<String, Double> sprintIdToTotalPoints = calculateTotalStoryPointsForSprints(works);
        Double totalStoryPoints = sprintIdToTotalPoints.get(sprint.Id);
        Map<Date, Double> dateToPointsMap = new Map<Date, Double>();
        Date highestCloseDate = sprint.Start_Date__c;
        
        for(ADM_Work__c work : works){
            if(work.Closed__c == 0 || work.Closed_On__c == null){
              continue;
            }
            Double workStoryPoint = (work.Story_Points__c == null)? 0: work.Story_Points__c;
            Date closedDate = Date.newInstance(work.Closed_On__c.year(),work.Closed_On__c.month(),work.Closed_On__c.day());
            Double points = dateToPointsMap.get(closedDate);
            if(points == null){
                points = workStoryPoint;
            }
            else {
                    points += workStoryPoint;
            }
          //  System.debug('Date ' +  closedDate);
            if(closedDate >= sprint.Start_Date__c){
                dateToPointsMap.put(closedDate, points); //Only put it to map if closedDate is >= Sprint Start Date
            }
            
            if(closedDate > highestCloseDate){
              highestCloseDate = closedDate;
            }
        }

        Date iteratorDate = sprint.End_Date__c;
        Integer noOfWeekEndDays = 0;
        while(iteratorDate >=  sprint.Start_Date__c){
          if ( isWeekend( iteratorDate ) && iteratorDate != sprint.End_Date__c ) {
              //If exclude weekends and is weekend and not the last day of sprint then skip this day.
              iteratorDate = iteratorDate.addDays(-1);
              noOfWeekEndDays++;
              continue;
          }

          if(dateToPointsMap.get(iteratorDate) == null){
            if(highestCloseDate >= iteratorDate){
            dateToPointsMap.put(iteratorDate, 0);
          }
          else{
              dateToPointsMap.put(iteratorDate, null);
            }
          }

          iteratorDate = iteratorDate.addDays(-1);
        }

        List<Date> dateKeyList = new List<Date>(dateToPointsMap.keySet());
        dateKeyList.sort();
        Integer daysSpent = 0;
        Double avgVelocityInThisSprint = 0;
        Double remainingStoryPoints = totalStoryPoints;
        for(Date key: dateKeyList){
          daysSpent++;
          if(key >= System.today() && actualSprintData.futureIndex == 0){
              actualSprintData.futureIndex = daysSpent -1;
          }
          if(null != dateToPointsMap.get(key)){
            remainingStoryPoints = remainingStoryPoints - dateToPointsMap.get(key);
          }
          else{
            if(sprint.End_Date__c > System.today()){

            //Get the average velocity on this sprint
            if(avgVelocityInThisSprint == 0){
                if((daysSpent - 1) != 0){
                Decimal avg = (totalStoryPoints - remainingStoryPoints) / (daysSpent -1);
                avgVelocityInThisSprint = avg.setScale(0);//Rounded to the closest decimal at 0 scale.
                }
            }
          }
            remainingStoryPoints = remainingStoryPoints - avgVelocityInThisSprint;

          }
          if(remainingStoryPoints < 0){
            remainingStoryPoints = 0;
          }
          dateToPointsMap.put(key, remainingStoryPoints);

        }
        actualSprintData.sprintIdToTotalPoints = dateToPointsMap;

        return actualSprintData;
    }

    public ActualSprintData mapActualSprintTaskHoursBurndownChart(ADM_Sprint__c sprint){
        ActualSprintData actualSprintData = new ActualSprintData();
        Map<Date, Double> dateToHoursMap = new Map<Date, Double>();
        
        List<ADM_Burndown_Item__c> burnDownItems = [Select Sprint__c, Type__c, Date__c, Scrum_Team__c, Days_Remaining__c, Hours_Remaining__c, Points_Remaining__c from ADM_Burndown_Item__c
                                                   where Type__c = 'Actual' and date__c <= :System.Today() and Sprint__c = :sprint.Id order by Date__c asc];

        for (ADM_Burndown_Item__c item:burndownItems ) {
            dateToHoursMap.put(item.Date__c, item.Hours_Remaining__c);
        }

        actualSprintData.sprintIdToTaskHours = dateToHoursMap;

        return actualSprintData;
    }

    public static void recalculateBaseline( ADM_Sprint__c sprint ) {
        ADM_Burndown_Item__c[] burndownItems;
        burndownItems = [select id, date__c, upsert_key__c, days_remaining__c, hours_remaining__c, scrum_team__c, type__c, 
                sprint__c from ADM_Burndown_Item__c where sprint__c = :sprint.Id  and
                type__c = 'Baseline' ORDER BY date__c ASC];
            
        Double remainingHours = getRemainingHoursForSprint(sprint.Id);
        Double coefficient = remainingHours / sprint.Total_Workdays__c;                                     
        for (ADM_Burndown_Item__c item:burndownItems ) {
            if ( item.Days_Remaining__c != null ) 
                item.Hours_Remaining__c = coefficient * item.Days_Remaining__c;
            else    
                item.Hours_Remaining__c = coefficient * ( daysBetweenMinusWeekends( item.Date__c, sprint.End_Date__c ) );                       
        }
        update burndownItems;   
    }
    
    /* Single sprint version has been depreacted
    public static void recalculateBurndown( ADM_Sprint__c sprint ) {
        if ( sprint.End_Date__c.daysBetween( System.today() ) > 0 ) return; // Past the sprint's last day so no changes to be made to bundown items
        ADM_Burndown_Item__c[] burndownItems;
        if ( sprint.Start_Date__c.daysBetween( System.today() ) > 0  ) { // We will only deal with actuals that are >= TODAY
            burndownItems = [select id, date__c, upsert_key__c, days_remaining__c, hours_remaining__c, scrum_team__c, type__c, 
                sprint__c from ADM_Burndown_Item__c where sprint__c = :sprint.Id  and
                type__c = 'Actual' and date__c >= :System.Today() ORDER BY date__c ASC];
        } else { // Will deal with ALL burndown items
            burndownItems = [select id, date__c, upsert_key__c, days_remaining__c, hours_remaining__c, scrum_team__c, type__c, 
                sprint__c from ADM_Burndown_Item__c where sprint__c = :sprint.Id  ORDER BY date__c ASC];   
        }
        
        Double remainingHours = getRemainingHoursForSprint(sprint.Id);
        
        
        Double coefficient = remainingHours / sprint.Total_Workdays__c;                                     
        
        for (ADM_Burndown_Item__c item:burndownItems ) {
            if (item.type__c == 'Actual' ) {
                item.Hours_Remaining__c = remainingHours;   
            } else { 
                
                if ( item.Days_Remaining__c != null ) 
                    item.Hours_Remaining__c = coefficient * item.Days_Remaining__c;
                else    
                    item.Hours_Remaining__c = coefficient * ( daysBetweenMinusWeekends( item.Date__c, sprint.End_Date__c ) );                       
            }
        }
        update burndownItems;
    } */
    
     public static void recalculateBurndown(List<ADM_Sprint__c> sprints) {
        //remove any sprints where past the last
        List<ADM_Sprint__c> sprintsAllBDItems = new List<ADM_Sprint__c>();
        List<ADM_Sprint__c> sprintsActualBDItems = new List<ADM_Sprint__c>();
        Map<Id,ADM_Sprint__c> sprintsById = new Map<Id, ADM_Sprint__c>();
        for(ADM_Sprint__c sprint : sprints) {
            
            /*
            daysBetween() -Returns the number of days between the Date that called 
            the method and the compDate. If the Date that calls 
            the method occurs after the compDate, the return value 
            is negative. */
            if ( sprint.End_Date__c.daysBetween( System.today() ) > 0 ) {
                //Past the sprint's last day so no changes to be made to bundown items
            } else {
                sprintsById.put(sprint.id, sprint);
                if ( sprint.Start_Date__c.daysBetween( System.today() ) > 0  ) { 
                    // We will only deal with actuals that are >= TODAY
                    sprintsActualBDItems.add(sprint);
                } else {
                    sprintsAllBDItems.add(sprint);
                }   
            }
        }
        
        //only update burndown if elligible sprint(s) have been found
        if(sprintsById != null && sprintsById.keySet().size() > 0) {
            List<ADM_Burndown_Item__c> burndownItems = new List<ADM_Burndown_Item__c>();
            if(sprintsActualBDItems.size() > 0) {
                burndownItems.addAll([select id, date__c, upsert_key__c, days_remaining__c, hours_remaining__c, scrum_team__c, type__c, 
                    sprint__c from ADM_Burndown_Item__c where sprint__c in :sprintsActualBDItems and
                    type__c = 'Actual' and date__c >= :System.Today() ORDER BY date__c ASC]);
            }
            
            if(sprintsAllBDItems.size() > 0) {
                burndownItems.addAll([select id, date__c, upsert_key__c, days_remaining__c, hours_remaining__c, scrum_team__c, type__c, 
                    sprint__c from ADM_Burndown_Item__c where sprint__c in :sprintsAllBDItems ORDER BY date__c ASC]);
            }
            
            Map<Id, Double> remainingHoursBySprint = getRemainingHoursMapForSprints(sprints);
            
            //calc coefficient by sprint
            Map<Id, Double> coefficientBySprint = new Map<Id, Double>();
            for(Id sprintID : remainingHoursBySprint.keySet()) {
                if(sprintsById.containsKey(sprintID)) {
                    ADM_Sprint__c sprint = sprintsById.get(sprintID);
                    if(remainingHoursBySprint.containsKey(sprint.id)) {
                        Double remainingHours = remainingHoursBySprint.get(sprint.id);
                        Double coefficient = remainingHours / sprint.Total_Workdays__c;  
                        coefficientBySprint.put(sprint.id, coefficient);
                    }   
                }   
            } 
            
            //process burn down items       
            for (ADM_Burndown_Item__c item:burndownItems ) {
                if (item.type__c == 'Actual' ) {
                    item.Hours_Remaining__c = remainingHoursBySprint.get(item.Sprint__c);   
                } else { 
                   //Baseline; since I don't load baseline for sprints which have progressed to their 2nd day 
                   // this code should not execute for them 
                   if(coefficientBySprint != null && coefficientBySprint.containsKey(item.Sprint__c)) {
                        if ( item.Days_Remaining__c != null ) 
                            item.Hours_Remaining__c = coefficientBySprint.get(item.Sprint__c) * item.Days_Remaining__c;
                        else    
                            item.Hours_Remaining__c = coefficientBySprint.get(item.Sprint__c) * ( daysBetweenMinusWeekends( item.Date__c, sprintsById.get(item.Sprint__c).End_Date__c ) );   
                   }                        
                }
            }
            update burndownItems;
        }     
    }
        
     
    
        
    private static Double getRemainingHoursForSprint( Id sprintId ) {
        ADM_Work__c[] sprintStoriesWithTasks = [select Id, Name, 
            (SELECT Id, Hours_Remaining__c From Tasks__r WHERE Status__c != 'Completed' ) from ADM_Work__c where 
            Sprint__c = :sprintId ORDER BY Priority_Rank__c ASC];
        
        //Calculate the total remaining hours left
        Double remainingHours = 0.0;
        for ( ADM_Work__c sprintStory:sprintStoriesWithTasks ) {
             for ( ADM_Task__c t:sprintStory.Tasks__r ) {
                if ( t.Hours_Remaining__c != null ) 
                    remainingHours += t.Hours_Remaining__c;
             }
        }
        return remainingHours;      
    }
    
    private static Map<Id,Double> getRemainingHoursMapForSprints(List<ADM_Sprint__c> sprints) {
        
        Map<Id, Double> hoursRemainingBySprint = new Map<Id, Double>();
        ADM_Work__c[] sprintStoriesWithTasks = [select Id, Name, Sprint__c, 
            (SELECT Id, Hours_Remaining__c From Tasks__r WHERE Status__c != 'Completed' ) from ADM_Work__c where 
            Sprint__c in :sprints ORDER BY Priority_Rank__c ASC];
        
        //Calculate the total remaining hours left
        for ( ADM_Work__c sprintStory:sprintStoriesWithTasks ) {
             Double remainingHours = 0.0;
             for ( ADM_Task__c t:sprintStory.Tasks__r ) {
                if ( t.Hours_Remaining__c != null ) 
                    remainingHours += t.Hours_Remaining__c;
             }
             if(hoursRemainingBySprint.containsKey(sprintStory.Sprint__c)) {
                hoursRemainingBySprint.put(sprintStory.Sprint__c, hoursRemainingBySprint.get(sprintStory.Sprint__c) + remainingHours);
             } else {
                hoursRemainingBySprint.put(sprintStory.Sprint__c, remainingHours);
             }  
        }
        return hoursRemainingBySprint;      
    }
    
    public static void forceSprintRecalc( ID sprintId ) {
        ADM_Sprint__c[] sprints = [select id, start_date__c, end_date__c, total_workdays__c from ADM_Sprint__c where id = :sprintId ];
        ADM_SprintBurnDownUtils.recalculateBurndown(sprints);
    }
    
    public static void findFutureSprints() {
        ADM_Burndown_Item__c[] burndownItems = [select id, date__c, upsert_key__c, days_remaining__c, hours_remaining__c, scrum_team__c, type__c, 
                sprint__c from ADM_Burndown_Item__c where date__c > :System.Today() and days_remaining__c < 0 ORDER BY date__c DESC];
        for (ADM_Burndown_Item__c bi: burndownItems ) {
            
        }
    }
    
    
    public static void patchBurndownItems(Id sprintId) {
        ADM_Burndown_Item__c[] burndownItems = [select id, date__c, upsert_key__c, days_remaining__c, hours_remaining__c, scrum_team__c, type__c, 
                sprint__c from ADM_Burndown_Item__c where sprint__c = :sprintId  ORDER BY date__c DESC];
        Boolean oldStyleCalc = false;
        for (ADM_Burndown_Item__c bi: burndownItems ) {
            if ( bi.Days_Remaining__c == -1 ) {
                oldStyleCalc = true;
            }
            bi.Days_Remaining__c +=1;
        }
        
        if ( oldStyleCalc ) {
            
            update burndownItems;
            ADM_Sprint__c[] sprints = [select id, start_date__c, end_date__c, total_workdays__c from ADM_Sprint__c where id = :sprintId ];
            ADM_SprintBurnDownUtils.recalculateBurndown(sprints);
        } else {
            
        }
        
    }
    
    public static void calculateVelocity(List<ADM_Work__c> worksNew, List<ADM_Work__c> worksOld) {
        // Logic to force sprint total closed story point recalculation
        
        Set<Id> sprintsToRecalc = getSprintsApplicableForVelocityRecalculation(worksNew, worksOld);
        if(!sprintsToRecalc.isEmpty()) {
            asyncCalculateVelocity( sprintsToRecalc );
        }
    }
    
    /*
    Addint the following method to provide an asynchronous way to calculate total velocity which should prevent us reaching a
    a total of more than 20 SOQL commands when processing the Work After trigger. 
    */
    @future 
    public static void asyncCalculateVelocity(Set<Id> sprintsToRecalc) {
        // recalculating total story points closed for applicable sprints       
        
        
        Map<Id, ADM_Sprint__c> sMap = new Map<Id, ADM_Sprint__c>([select Id, Name from ADM_Sprint__c where Id in :sprintsToRecalc and Scrum_Team__r.Active__c = true]);
        
        if(sMap.isEmpty()) {
            return;
        }
        
        Map<Id, SprintCompletedWorkData> completedWorkBySprint = calculateVelocityBySprintID(sMap);       
        
        //update sprints
        List<ADM_Sprint__c> sprints = convertCompletedStoryPointsMapToSprintList(completedWorkBySprint, sMap);
        
        update sprints;
    }
    
    private static Set<Id> getSprintsApplicableForVelocityRecalculation(List<ADM_Work__c> worksNew, List<ADM_Work__c> worksOld) {
        Set<Id> sprintsToRecalc = new Set<Id>();
        
        /*cases where velocity needs to be recalculated
            i)   Work Item has been created with closed status
            ii)  Work Item has been updated from open to closed
            iii) Previously closed Work item has had its Sprint modified (update new and former sprints)
            iv)  Previously closed Work item is having its story points updated
        */  
        
        for (Integer i = 0; i < worksNew.size(); i++ ) {
            if(worksOld == null || worksOld.size() == 0 || worksOld[i] == null) {
                //handle case i
                
                if(worksNew[i].Closed__c == 1 && worksNew[i].Sprint__c != null) {
                    
                    sprintsToRecalc.add(worksNew[i].Sprint__c);
                }
            } else {
                //handle case ii
                
                if(worksOld[i].Status__c != worksNew[i].Status__c) {
                    
                    if(worksNew[i].Sprint__c != null) sprintsToRecalc.add(worksNew[i].Sprint__c);
                    if(worksOld[i].Sprint__c != null) sprintsToRecalc.add(worksOld[i].Sprint__c);
                }
                
                if(worksOld[i].Closed__c == 1 && worksNew[i].Closed__c == 1) {
                    
                    //handle case iii
                    if(worksOld[i].Sprint__c != worksNew[i].Sprint__c) {
                        
                        if(worksNew[i].Sprint__c != null) sprintsToRecalc.add(worksNew[i].Sprint__c);
                        if(worksOld[i].Sprint__c != null) sprintsToRecalc.add(worksOld[i].Sprint__c);
                    }
                    //handle case iv
                    if(worksOld[i].Story_Points__c != worksNew[i].Story_Points__c) {
                        
                        if(worksNew[i].Sprint__c != null) sprintsToRecalc.add(worksNew[i].Sprint__c);
                        if(worksOld[i].Sprint__c != null) sprintsToRecalc.add(worksOld[i].Sprint__c);
                    }                       
                }
            }
        }
        
        return sprintsToRecalc;
    }
    
    private static Map<Id, SprintCompletedWorkData> calculateVelocityBySprintID(Map<Id, ADM_Sprint__c> sMap) {
        Map<Id, SprintCompletedWorkData> completedWorkBySprint = new Map<Id, SprintCompletedWorkData>();
        if ( sMap != null && sMap.size() > 0 ) {
            //bulk lookup any work related to sprints
            Map<Id, ADM_Work__c> wMap = new Map<Id, ADM_Work__c>([select Id, Story_Points__c, Sprint__c from ADM_Work__c where Sprint__c in :sMap.keySet() and (Status__c LIKE 'Closed%' OR Status__c = 'Completed')]);
            Map<Id, List<Id>> commitmentWorkIdsBySprint = new Map<Id, List<Id>>();
            List<Id> commitmentWorkIds = new List<Id>();

            if(wMap != null & wMap.size() > 0) {
                for(Id id: wMap.keySet()) {
                    ADM_Work__c w = wMap.get(id);
                    ADM_Sprint__c s = sMap.get(w.Sprint__c);
                    
                    if (!commitmentWorkIdsBySprint.containsKey(w.Sprint__c)) {
                        commitmentWorkIds = ADM_ScopeChangeController.getWorkIdsCommittedToInSprint(w.Sprint__c);

                        commitmentWorkIdsBySprint.put(w.Sprint__c, commitmentWorkIds);
                    } else {
                        commitmentWorkIds = commitmentWorkIdsBySprint.get(w.Sprint__c);
                    }

                    if(w != null && s != null) {
                        SprintCompletedWorkData completedWork;

                        if(completedWorkBySprint.containsKey(s.id)) {
                            completedWork = completedWorkBySprint.get(s.id);
                            completedWork.completedPoints += (w.Story_Points__c != null ? w.Story_Points__c : 0);
                        } else {
                            completedWork = new SprintCompletedWorkData();
                            completedWork.completedPoints = (w.Story_Points__c != null ? w.Story_Points__c : 0);
                        }
System.debug('commitmentWorkIds: '+commitmentWorkIds);
System.debug('work Id: '+w.Id);
System.debug('commitmentWorkIds.contains(workId): '+commitmentWorkIds.contains(w.Id));
                        if (commitmentWorkIds.contains(w.Id)) {
System.debug('Setting committed work completed values');
                            completedWork.committedPointsCompleted += (w.Story_Points__c != null ? w.Story_Points__c : 0);
                            completedWork.committedItemsCompleted = completedWork.committedItemsCompleted + 1;
                        }
System.debug('completedWork: '+completedWork);
                        completedWork.completedItems = completedWork.completedItems + 1;

                        completedWorkBySprint.put(s.id, completedWork);
                    }
                }
            }
            //if no closed work was found for sprint but sprint exists in sMap need to ensure its velocity is reset to zero
            for(Id id : sMap.keySet()) {
                if(!completedWorkBySprint.containsKey(id)) {
                    //add zero
                    completedWorkBySprint.put(id, new SprintCompletedWorkData());
                }
            }
        }
        return completedWorkBySprint;

    }

    private static List<ADM_Sprint__c> convertCompletedStoryPointsMapToSprintList(Map<Id, SprintCompletedWorkData> completedWorkBySprint, Map<Id, ADM_Sprint__c> sMap) {
        List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        for(Id sid :completedWorkBySprint.keySet()) {
            ADM_Sprint__c sprint = sMap.get(sid);
            if(sprint != null) {
                SprintCompletedWorkData completedWork = completedWorkBySprint.get(sid);

                sprint.Completed_Story_Points__c = completedWork.completedPoints;
                sprint.Completed_Items__c = completedWork.completedItems;
                sprint.Committed_Story_Points_Completed__c = completedWork.committedPointsCompleted;
                sprint.Committed_Items_Completed__c = completedWork.committedItemsCompleted;

                sprints.add(sprint);
            }
        }
        return sprints;
    }  
    
    public class ActualSprintData {
      Map<Date, Double> sprintIdToTotalPoints = new Map<Date, Double>();
      Map<Date, Double> sprintIdToTaskHours = new Map<Date, Double>();
      Integer futureIndex = 0;

      public Map<Date, Double> getSprintIdToTotalPoints(){
        return this.sprintIdToTotalPoints;
      }

      public Map<Date, Double> getSprintIdToTaskHours(){
        return this.sprintIdToTaskHours;
      }

      public Integer getFutureIndex(){
        return this.futureIndex;
      }
    }

    public class SprintCompletedWorkData {
        Double completedPoints = 0;
        Integer completedItems = 0;
        Double committedPointsCompleted = 0;
        Integer committedItemsCompleted = 0;
    }
    
    public class ClosedSprintException extends Exception {}
    
}