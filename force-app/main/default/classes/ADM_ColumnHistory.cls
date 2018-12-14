public with sharing class ADM_ColumnHistory {
    
    public static List<ADM_Column_History__c> columnHistoryList = new List<ADM_Column_History__c>();
    
    public static ADM_Column_History__c setUpColumnHistoryRecordForCurrentDateTime(ADM_Work__c work){
        ADM_Column_History__c newColumnHistory = new ADM_Column_History__c();
        newColumnHistory.Time_Entered__c = Datetime.now();
        newColumnHistory.Column__c = work.Column__c;
        newColumnHistory.Work__c = work.Id;
        return newColumnHistory;
    }

    public static List<ADM_Column_History__c> getColumnHistoryRecordsForListOfWorkIds(List<Id> workIds){
        //Here we order by Time Left and do nulls irst so that we can get the record that needs the time left to be updated first and it can go into the Map.
        List<ADM_Column_History__c> columnHistoryRecords = [Select id,Column__c,Time_Entered__c,Time_Left__c,Work__c from ADM_Column_History__c where Work__c in: workIds order by Time_Left__c nulls first];                    
        return columnHistoryRecords;
    }

    public static Map<Id,ADM_Column_History__c> getMapOfWorkIdWithColumnHistoryRecords(List<ADM_Column_History__c> columnHistoryRecords){
        Map<Id,ADM_Column_History__c> workIdWithColumnHistory = new Map<Id,ADM_Column_History__c>();
         //Mapping Work id with the Last column History Record so that Time Left can be updated. 
        for(ADM_Column_History__c columnHistory : columnHistoryRecords){
            if(workIdWithColumnHistory.get(columnHistory.Work__c) == null){
                workIdWithColumnHistory.put(columnHistory.Work__c,columnHistory);
            }
        }
        return workIdWithColumnHistory;
    }

    public static void prepareColumnHistoryRecordsForUpdateAndInsert(ADM_Column_History__c columnHistory,ADM_Work__c newWork){
        if(columnHistory != null){  
            columnHistory.Time_Left__c = Datetime.now();
            ADM_ColumnHistory.columnHistoryList.add(columnHistory);
        }
        if(null != newWork.column__c){
            //create record for new column if column__c is not null
            ADM_Column_History__c newColumnHistory = ADM_ColumnHistory.setUpColumnHistoryRecordForCurrentDateTime(newWork);
            ADM_ColumnHistory.columnHistoryList.add(newColumnHistory);
        }
        
    }

    public static void upsertColumnHistoryRecordsForColumnChange(List<ADM_Work__c> works){
        columnHistoryList = new List<ADM_Column_History__c>(); 
        List<Id> workIds = new List<Id>();
        for(ADM_Work__c work : works){
            workIds.add(work.Id);
        }
        List<ADM_Column_History__c> columnHistoryRecords = ADM_ColumnHistory.getColumnHistoryRecordsForListOfWorkIds(workIds);
        Map<Id,ADM_Column_History__c> workIdWithColumnHistory = ADM_ColumnHistory.getMapOfWorkIdWithColumnHistoryRecords(columnHistoryRecords);
        for(ADM_Work__c work : works) {
            ADM_Column_History__c columnHistory = workIdWithColumnHistory.get(work.Id); 
            ADM_ColumnHistory.prepareColumnHistoryRecordsForUpdateAndInsert(columnHistory,work);
        }
        if(ADM_ColumnHistory.columnHistoryList.size() >0){
            upsert ADM_ColumnHistory.columnHistoryList;
        }
    }

    public static Map<String,List<AggregatedColumnHistory>> getDurationFromColumnHistory(List<Id> works){
        String nameSpace =  ADM_ConstantsSingleton.getInstance().getNameSpace();
        Map<String,List<AggregatedColumnHistory>> workIdToAggColumnHistoryMap  = new Map<String,List<AggregatedColumnHistory>>();
        AggregateResult[] columnHistoryAggResults = [Select SUM(Duration_By_Work_Days__c) byWdays, SUM(Duration__c) byDuration, Column__c, work__c from ADM_Column_History__c where Work__c in :works group by column__c, work__c ];
       // Map<Id,ADM_Column_History__c> workIdWithColumnHistory = ADM_ColumnHistory.getMapOfWorkIdWithColumnHistoryRecords(columnHistoryRecords);
        for(AggregateResult ar: columnHistoryAggResults){
            AggregatedColumnHistory aggColumnHistory = new AggregatedColumnHistory((String)ar.get(nameSpace + 'Column__c'), Double.valueOf(ar.get('byWdays')), Double.valueOf(ar.get('byDuration')));
            String workID = (String)ar.get(nameSpace + 'Work__c');
            if(workIdToAggColumnHistoryMap.get(workID) == null){
                workIdToAggColumnHistoryMap.put(workID, new List<AggregatedColumnHistory>());
            }
            workIdToAggColumnHistoryMap.get(workID).add(aggColumnHistory);

        }

        return workIdToAggColumnHistoryMap;
    }

    public class AggregatedColumnHistory {
        public String columnId;
        public Integer totalWorkDays;
        public Double totalActualDays;
        public String totalActualDaysStr;
        AggregatedColumnHistory(String columnId, Double totalWorkDays, Double totalActualDays){
            this.columnId = columnId;
            this.totalWorkDays = (Integer)totalWorkDays;
            this.totalActualDays = totalActualDays;
            Double dayFraction = totalActualDays - (Integer)totalActualDays;
            Double hours = dayFraction *24;
            totalActualDaysStr = (Integer)totalActualDays + 'days ' + (Integer)hours + 'hrs ';
        
            Double hourFraction = hours - (Integer)hours;
            if(hourFraction > 0){
                Integer minutes = (Integer)(hourFraction * 60);
                totalActualDaysStr += minutes +' mins';
            }
            
        }
        
    }

}