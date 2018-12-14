public class ADM_PurgeKanbanBoardClosedColumnJob implements Database.Batchable<sObject>, Schedulable {

    Integer batchUnit = 1000;

    public Database.QueryLocator start(Database.BatchableContext BC)
    {


        return Database.getQueryLocator([SELECT Id, Name, Column__c FROM ADM_Work__c WHERE Column__c IN (SELECT Id FROM ADM_Column__c WHERE Team__c = null AND Name='Closed')
]);
 
    }

    public void execute(Database.BatchableContext BC, List<ADM_Work__c> workList){

            for ( ADM_Work__c temp : workList ){
                temp.Column__c = null;
            }

            Database.update(workList);

    }

    public void finish(Database.BatchableContext BC)
    {
        System.debug('Finishing Closed column purge....');
    }

    public void execute(SchedulableContext ctx) {

        System.debug('Starting closed column purge....');

        ADM_PurgeKanbanBoardClosedColumnJob purgeJob = new ADM_PurgeKanbanBoardClosedColumnJob();

        ID batch = Database.executeBatch(purgeJob,batchUnit);

        System.debug('BatchID' + batch);

    }

}