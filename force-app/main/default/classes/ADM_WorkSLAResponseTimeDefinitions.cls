public class ADM_WorkSLAResponseTimeDefinitions {

    public final static Long ONE_MINUTE_MILLISEC = 60 * 1000L;
    
    public final static String WORKTYPE_INVESTIGATION = 'Investigation';
    
    public final static String EVENTTYPE_ACK = 'Acknowledgement';
    public final static String EVENTTYPE_UPDATE = 'Update';
    public final static String EVENTTYPE_SUPPORT = 'Support';

    
        
    
	/** caches the ADM_Work_SLA_Response_Time__c by WorkType -> EventType -> SevLevel */
    private Map<String,Map<String,Map<String,SLAResponseTime>>> mapWorkTypeToEventTypeMap;
  
    
    public SLAResponseTime getInvestigationAckSLA(String severityLevel) {
        return getSLAResponseTime(WORKTYPE_INVESTIGATION, EVENTTYPE_ACK, severityLevel);
    }
    
    public SLAResponseTime getInvestigationUpdateSLA(String severityLevel) {
        return getSLAResponseTime(WORKTYPE_INVESTIGATION, EVENTTYPE_UPDATE, severityLevel);
    }
    
    public SLAResponseTime getInvestigationSupportSLA(String severityLevel) {
        return getSLAResponseTime(WORKTYPE_INVESTIGATION, EVENTTYPE_SUPPORT, severityLevel);
    }

    public SLAResponseTime getSLAResponseTime(String workType, String eventType, String severityLevel) {
        if (mapWorkTypeToEventTypeMap==null) {
            loadSLAResponseTimes();
        }
        
        Map<String,Map<String,SLAResponseTime>> mapEventTypeToSevLevelMap = mapWorkTypeToEventTypeMap.get(workType.toLowerCase());
        if (mapEventTypeToSevLevelMap==null) {
            return null;
        }
        
        Map<String,SLAResponseTime> mapSevLevelToSLA = mapEventTypeToSevLevelMap.get(eventType.toLowerCase());
        if (mapSevLevelToSLA==null) {
            return null;
        }
        return mapSevLevelToSLA.get(severityLevel.toLowerCase());
    }
    
    
    public class SLAResponseTime {
        public Long responseTimeInMinutes;
        public Boolean respectsBusinessHours;
        
        public Long ResponseTimeInMilliseconds {
            get {
                return ONE_MINUTE_MILLISEC * responseTimeInMinutes;
            }
        }
    }
        

    /////////// PRIVATE METHODS ///////////
    
    /**
     * Load the SLA Response Time values from the database (Custom Settings)
     */
    private void loadSLAResponseTimes() {
        this.mapWorkTypeToEventTypeMap = new Map<String,Map<String,Map<String,SLAResponseTime>>>();
        
        List<ADM_Work_SLA_Response_Time__mdt> responseTimes =
            [SELECT Work_Type__c, Event_Type__c, Severity_Level_or_Priority__c, Response_Time_In_Minutes__c, Respects_Business_Hours__c
             FROM ADM_Work_SLA_Response_Time__mdt];
        
        for (ADM_Work_SLA_Response_Time__mdt responseTime : responseTimes) {
            
            Map<String,Map<String,SLAResponseTime>> mapEventTypeToSevLevelMap = this.mapWorkTypeToEventTypeMap.get(responseTime.Work_Type__c.toLowerCase());
            if (mapEventTypeToSevLevelMap==null) {
                mapEventTypeToSevLevelMap = new Map<String,Map<String,SLAResponseTime>>();
                mapWorkTypeToEventTypeMap.put(responseTime.Work_Type__c.toLowerCase(), mapEventTypeToSevLevelMap);
            }
            
            Map<String,SLAResponseTime> mapSevLevelToSLA = mapEventTypeToSevLevelMap.get(responseTime.Event_Type__c.toLowerCase());
            if (mapSevLevelToSLA==null) {
                mapSevLevelToSLA = new Map<String,SLAResponseTime>();
                mapEventTypeToSevLevelMap.put(responseTime.Event_Type__c.toLowerCase(), mapSevLevelToSLA);
            }
            
            SLAResponseTime srt = new SLAResponseTime();
            srt.responseTimeInMinutes = responseTime.Response_Time_In_Minutes__c.longValue();
            srt.respectsBusinessHours = responseTime.Respects_Business_Hours__c;
            
            mapSevLevelToSLA.put(responseTime.Severity_Level_or_Priority__c.toLowerCase(), srt);
        }
    }
}