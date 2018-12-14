public class ADM_Investigation_Ack_Controller {
   
    public final static String ISINVESTIGATION = 'ISINVESTIGATION';
    public final static String STATUSTEXT = 'STATUSTEXT';
	public final static String STATUSCOLOR = 'STATUSCOLOR';
    public final static String COUNTDOWNTEXT = 'COUNTDOWNTEXT';
    public final static String DUEDATE = 'DUEDATE';
    public final static String COLOR = 'COLOR';
    
    @AuraEnabled
    public static Map<String,String> getDataMap( Id workId ) {
        
        Map<String,String> dataMap = new Map<String,String>();
        
        List<ADM_Work__c> work_list = [SELECT Id, Record_Type__c, Due_Date__c, Status__c FROM ADM_Work__c WHERE Id =: workId];
        ADM_Work__c work = (ADM_Work__c)work_list.get(0);
        
        if (work.Record_Type__c  == 'Investigation'){
            dataMap.put(ISINVESTIGATION,'true');
        } else {    
            dataMap.put(ISINVESTIGATION,'false');
            // Exit early since the other fields won't be there.
            return dataMap; 
        }
            
        String countdownTextRetrieved = getSLADueTimeDiff(work);
        dataMap.put( COUNTDOWNTEXT , countdownTextRetrieved );        
		dataMap.put( DUEDATE , (String.valueOf(work.Due_Date__c.getTime())));
        dataMap.put( STATUSTEXT,  getSLACountdownLabel( work ));
        dataMap.put( STATUSCOLOR,  getSLACountdownStyle( work ));
        
        return dataMap;
        
    }

    @AuraEnabled
    public static String getSLADueTimeDiff( ADM_Work__c work ) {
        
        String msg = '';
        
        try {
            if (work.Due_Date__c != null) {
                Long diffMilliseconds = Math.abs(work.Due_Date__c.getTime() - System.now().getTime());
                Long diffMinutes = diffMilliseconds / (60 * 1000);
                
                Long minutesPart = Math.mod(diffMinutes, 60);
                Long hoursPart = Math.mod(diffMinutes/60, 24);
                Long daysPart = diffMinutes / (24 * 60);
            
                if ( getIsSLAOverdue( work ) ) {
                    msg = 'Overdue by ';
                } else {
                    msg = 'Due in ';
                }
            
                if (daysPart > 0) {
                    msg += daysPart;
                    msg += (daysPart > 1) ? ' days ' : ' day ';
                }
                if (hoursPart > 0) {
                    msg += hoursPart;
                    msg += (hoursPart > 1) ? ' hours ' : ' hour ';
                }
                if (minutesPart > 0) {
                    msg += minutesPart;
                    msg += (minutesPart > 1) ? ' minutes ' : ' minute ';
                }
            }
        }
        catch(Exception e){
            System.debug('iSLA Exception in getting SLA due time diff for Investigation : ' + e);
        }
               
        return msg;
    }
    
    public static Boolean getIsSLAOverdue( ADM_Work__c work ) {
        return work.Due_Date__c!=null && (System.now().getTime() > work.Due_Date__c.getTime());
    }

    public static String getSLACountdownLabel( ADM_Work__c work  ) {
        
        String msg = '';
        try{
            if (work.Due_Date__c != null) {
                if (work.Status__c == 'New') {
                    msg = 'Acknowledgement';
                } else if (work.Status__c == 'More Info Reqd from Support') {
                    msg = 'Update Due From Support';
                } else {
                    msg = 'Update Due From T&P';
                }
            } 
        }
        
        catch(Exception e){
            System.debug('iSLA Exception in getting SLA count down label for Investigation : ' + e);
        }
        
        return msg;
    }
    
    public static String getSLACountdownStyle( ADM_Work__c work ) {
        String style = '';
        try{
            if (work.Due_Date__c != null) {
                Long diffHours = (work.Due_Date__c.getTime() - System.now().getTime()) / (60 * 60 * 1000);
                if (diffHours < 1) {
                    style = 'slds-text-color--error';
                } else if (diffHours < 4) {
                    style = 'orange-font';
                } else {
                    style = 'green-font';
                }
            }
        }
        catch(Exception e){
            System.debug('iSLA Exception in getting SLA count down style for Investigation : ' + e);
        }
   
        return style;
    }
        
}