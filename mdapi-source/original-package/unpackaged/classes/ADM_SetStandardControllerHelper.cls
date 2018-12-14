public with sharing class ADM_SetStandardControllerHelper {
    List<String> selectedRecordTypes;
    List<String> selectedPriorities;
    List<String> selectedStatuses;
    List<String> selectedScheduledBuilds;
    String releaseId;
    public String query { get; set;}
    public String queryOriginal { get; set; }

    public ADM_SetStandardControllerHelper(String releaseId, List<String> selectedRecordTypes, List<String> selectedPriorities, List<String> selectedStatuses, List<String> selectedScheduledBuilds) {
       this.releaseId = releaseId;
       this.selectedPriorities = selectedPriorities;
       this.selectedRecordTypes = selectedRecordTypes;
       this.selectedScheduledBuilds = selectedScheduledBuilds;
       this.selectedStatuses = selectedStatuses;

       String FIELD_NAMES = 'Work__r.RecordType.Name, Work__r.Id, Work__r.Subject__c, Work__r.Priority__c, Work__r.Status__c, Work__r.Scheduled_Build__c, Work__r.Scheduled_Build__r.Name, Work__r.Name, Work__c, CreatedDate, Reverted__c, Release__r.Name, Release__c, Stamped_On__c';
       String TABLE = 'ADM_Released_In__c';
       String WHERE_CLAUSE = ' where Release__c = \'' + String.escapeSingleQuotes(releaseId) + '\'';
       String ORDER_BY = 'order by Work__r.Name, CreatedDate';
       String query = '';

       this.queryOriginal = 'select ' + FIELD_NAMES + ' from ' + TABLE + WHERE_CLAUSE + ORDER_BY + ' limit 10000';

       WHERE_CLAUSE += arrayToString('Work__r.RecordType.Name', selectedRecordTypes);
       WHERE_CLAUSE += arrayToString('Work__r.Priority__c', selectedPriorities);
       WHERE_CLAUSE += arrayToString('Work__r.Status__c', selectedStatuses);
       WHERE_CLAUSE += arrayToString('Work__r.Scheduled_Build__r.Name', selectedScheduledBuilds);

       this.query = 'select ' + FIELD_NAMES + ' from ' + TABLE + WHERE_CLAUSE + ORDER_BY + ' limit 10000';
    }

    public Apexpages.Standardsetcontroller getSetController() {
        return getSetController(20);
    }

    public Apexpages.Standardsetcontroller getSetController(Integer i) {
        Apexpages.Standardsetcontroller setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        setCon.setPageSize(i);
        return setCon;
    }

    private String arrayToString(String column, List<String> els) {
        String returnVar = '';

        for(String el : els){
            returnVar = returnVar + '\'' + String.escapeSingleQuotes(el.trim()) + '\''  + ',';
        }
        
        if(returnVar.endsWith(',')) {
            returnVar = returnVar.substring(0, returnVar.length() - 1);
        }

        if(returnVar.length() > 0) {
            returnVar = ' and ' + column + ' in ('+ returnVar + ')';
        }

        return returnVar;
    }
    
    static testMethod void testQuery() {
    	ADM_Release__c release = new ADM_Release__c();
        release.Name = 'Test Release';
        insert release;
        
        List<String> recordTypes = new List<String>{'Bug'};
        List<String> priorities = new List<String>{'P0'};
        List<String> statuses = new List<String>{'New'};
        List<String> scheduledBuilds = new List<String>{'Test Build'};
    	
    	ADM_SetStandardControllerHelper helper = new ADM_SetStandardControllerHelper(release.Id, recordTypes, priorities, statuses, scheduledBuilds);
    	
    	System.assert(helper.query != null, 'Expected the query property to not be null');
        System.assert(helper.queryOriginal != null, 'Expected the queryOriginal property to not be null');
        System.assert(helper.getSetController() != null, 'Expected the getSetController method to not return null');
    }
}