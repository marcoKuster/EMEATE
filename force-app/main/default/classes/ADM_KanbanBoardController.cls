public with sharing class ADM_KanbanBoardController {
    public String columnsAsJSON;
    private static transient Id selectedTeamId;
    private transient List<ADM_Scrum_Team__c> teams;
    private transient ADM_Scrum_Team__c team;
    public String teamMemberId { get; set; }
    public List<ADM_Scrum_Team_Member__c> allocations { get; set; }
    public User currentUserDetails {get;set;}

    public ADM_KanbanBoardController() {
        //Loading team's Kanban page columns
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        if(parameters.containsKey('teamId')) {
            selectedTeamId = (Id)parameters.get('teamId');
            this.teams = [select Id, Name from ADM_Scrum_Team__c where Id = :selectedTeamId];
            if(null != teams && teams.size() > 0){
                this.team = this.teams[0];
            }
        } else {
            throw new ADM_ApplicationException('Team must be specified on the URL using teamId');
        }
    }

    public static List<ADM_Column> getColumns(){
        return getColumns(selectedTeamId);
    }

    @AuraEnabled
    public static List<ADM_Column> getColumns(String selectedTeam){
        List<ADM_Column> admColumns =  intializeColumns(selectedTeam);
        return admColumns;

    }

    public String getTeamName() {
        return team.Name;
    }

    public String getTeamId() {
        return team.Id;
    }

    public String getcurrentUserPhoto() {
        String teamMemberId = UserInfo.getUserId();
        User t =[Select t.SmallPhotoUrl From User t Where t.Id =: teamMemberId];
        return t.SmallPhotoUrl;
    }

    public String getColumnsAsJSON(){
        return JSON.serialize(getColumns());

    }

    public String getColumnsAsJSONPretty(){
        return JSON.serializePretty(getColumns());
    }

    public String getWorkStatus(){
        return JSON.serializePretty(ADM_WorkStatus.getAllWorkStatusesResult());
    }

    @AuraEnabled
    public static List<ADM_Column> getColumnsAndWorks(){
        return getColumnsAndWorksForTeam(selectedTeamId);
    }

    @AuraEnabled
    public static Integer getCurrentTeamCount() {
        List<ADM_Scrum_Team_Member__c> membership = [select id, Scrum_Team__c, Member_Name__c from ADM_Scrum_Team_Member__c where Member_Name__c =:UserInfo.getUserId() and Scrum_Team__c != null order by Allocation__c DESC];
        return membership.size();
    }
    @AuraEnabled
    public String getAllTeamsLink() {
        //direct to list view for object
        Schema.DescribeSObjectResult teamDescribe = Schema.SObjectType.ADM_Scrum_Team__c;
        return teamDescribe.getKeyPrefix();
    }
    @AuraEnabled
    public static List<ADM_Scrum_Team_Member__c> getAllocations(){
        String teamMemberId = UserInfo.getUserId();
        List<ADM_Scrum_Team_Member__c> allocations =  [Select a.Id, a.RecordTypeId, a.Name, a.Scrum_Team__r.Name, a.Scrum_Team__r.Kanban__c, a.Scrum_Team__c, a.Role__c, a.Member_Name__r.Name,
                           a.Member_Name__c, a.Allocation__c From ADM_Scrum_Team_Member__c a Where a.Member_Name__c =: teamMemberId And
                           a.Scrum_Team__r.Active__c = true ORDER BY a.Allocation__c Desc NULLS Last];
        return allocations;
    }

    @AuraEnabled
    public static User getCurrentUserDetails(){
        String teamMemberId = UserInfo.getUserId();
        User t =[Select t.FirstName,t.SmallPhotoUrl From User t Where t.Id =: teamMemberId];
        return t;
    }



    @RemoteAction
    @AuraEnabled
    public static List<ADM_Column> getColumnsAndWorksForTeam(String teamId){
        try{
                List<ADM_Column> kanbanColumns = getColumns(teamId); //SOQL 1
                if(null != kanbanColumns && kanbanColumns.size()>0){

                    List<ADM_Work__c> worksForKanbanBoard = new List<ADM_Work__c>();

                    List<String> ignoreValuesForOnGoingWork = new List<String>{'New','Triaged','Closed', 'Never', 'Duplicate', 'Not a Bug', 'Not Reproducible'};
                    String recordTypeFilter = ' recordType.Name in (\'Bug\', \'User Story\')';
                    String otherFilter = recordTypeFilter;



                    Set<String> allColumnIds = ADM_ColumnUtility.getKanbanColumnsEligibleToAddWork(teamId); //All Columns on Kanban board for the team.

                    //Set<String> kanbanClosedColumnIds = ADM_ColumnUtility.getKanbanClosedColumns(teamId);//All Columns which are marked as Closed via column status assignment.

                   // allColumnIds.removeAll(kanbanClosedColumnIds);//Removing closed columns from the Set

                    //Getting list of Kanban Works for the team
                    List<ADM_Work__c> worksWithKanban= ADM_Work.getExistingKanbanWorks(teamId, 'Column__c', allColumnIds, otherFilter, null);
                    if(null != worksWithKanban && worksWithKanban.size() > 0){
                        worksForKanbanBoard.addAll(worksWithKanban);

                    }
                    List<ADM_Work__c> worksWithKanbanClosed;
                    /*if(kanbanClosedColumnIds != null && kanbanClosedColumnIds.size() > 0){
                        //Getting list of Kanban Works for the team - second query so we can set a limit of 7 for closed columns
                        worksWithKanbanClosed= ADM_Work.getExistingKanbanWorks(teamId, 'Column__c', kanbanClosedColumnIds, otherFilter, '7');
                    }*/



                    /*if(null != worksWithKanbanClosed && worksWithKanbanClosed.size() > 0){
                        worksForKanbanBoard.addAll(worksWithKanbanClosed);

                    }*/


                    if(worksForKanbanBoard.size() == 0 ){
                            otherFilter = recordTypeFilter;
                            //Getting list of work which are not new,triaged or closed
                            List<ADM_Work__c> worksOnGoing = ADM_Work.getTeamsWork(teamId, 'Status__c', ignoreValuesForOnGoingWork, false, otherFilter,'CreatedDate desc', null); //SOQL 2

                            worksForKanbanBoard.addAll(worksOnGoing);
                    }




                    /* https://gus.my.salesforce.com/apex/adm_bugdetail?id=a07B0000001DLrgIAG&sfdc.override=1
                    Not bringingin in any work items in closed status to Kanban board on initial load.
                    else{
                            otherFilter = recordTypeFilter;
                            //Getting list of work which are closed but limited to 7 rows
                            List<ADM_Work__c> worksClosed = ADM_Work.getTeamsWork(selectedTeamId, 'Status__c', new List<String>{'Closed'}, true, otherFilter ,'LastModifiedDate desc ', '7'); //SOQL 4

                            worksForKanbanBoard.addAll(worksClosed);
                    }
                    */




                    List<Id> workIds = new List<Id>();
                    for(ADM_Work__c work : worksForKanbanBoard){
                        workIds.add(work.Id);
                    }

                    Map<String,List<ADM_ColumnHistory.AggregatedColumnHistory>> aggregatedColumnHistories = ADM_ColumnHistory.getDurationFromColumnHistory(workIds);

                    Map<Id, List<ADM_Theme_Assignment__c>> workIdToThemAssignments = ADM_ThemeUtils.getThemeAssignmentsByWork(workIds);

                    List<FeedItem> feedItems = ADM_FeedItemUtil.getActualPostItemsIdsByParentId(workIds);//SOQL 5

                    EntitySubscription[] workSubscribedByUser = ADM_EntitySubscriptionUtils.getAllBy(workIds, new List<Id>{UserInfo.getUserId()}); //SOQL 6



                    return ADM_KanbanUtility.blendColumnWithWorks(kanbanColumns, worksForKanbanBoard, feedItems, workSubscribedByUser, aggregatedColumnHistories, workIdToThemAssignments);
                }
                else{
                    throw new ADM_ApplicationException('Error: This team is not configured to use Kanban.  Please check the Kanban checkbox on your team detail page.');
                }
            }
            catch(Exception exp){
                throw new ADM_ApplicationException(exp.getMessage());
            }
    }

    @RemoteAction
    public static String getColumnsAndWorksAsJSON(String teamId){
        selectedTeamId = teamId;
        return JSON.serialize(prepareKanbanData());

    }

    public static String getColumnsAndWorksAsJSON(){
        return JSON.serialize(prepareKanbanData());

    }

    public static String getColumnsAndWorksAsJSONPretty(){
        return JSON.serializePretty(prepareKanbanData());

    }

    private static KanbanData prepareKanbanData(){
        ADM_KanbanPreferences kanbanPreferences = new ADM_KanbanPreferences();
        kanbanPreferences.setLaneScrolling(ADM_User.getUserLaneScrollingPreference());
        ADM_User.setKanbanWorkCardPreferences(kanbanPreferences);
        KanbanData kanbanData = new KanbanData();
        kanbanData.columns = getColumnsAndWorks();
        kanbanData.kanbanPreferences = kanbanPreferences;
        kanbanData.teamColors = new List<ADM_Color__c>();
        List<ADM_Color__c> teamColors = ADM_KanbanUtility.getTeamColors(selectedTeamId);
        if(teamColors != null && teamColors.size() > 0 ){
            kanbanData.teamColors = teamColors;
        }
        return kanbanData;
    }

    public static String getBaseUrl(){
        return System.Url.getSalesforceBaseUrl().toExternalForm();
    }

    private static List<ADM_Column> intializeColumns(String teamId){
        List<ADM_Column__c> columnSObjects = ADM_ColumnQueryUtils.getColumnsByTeam(teamId);
        List<ADM_Column> admColumns = null;
        if(null != columnSObjects && columnSObjects.size() > 0){
            admColumns = ADM_ColumnUtility.getRootParentColumns(columnSObjects);
        }
        return admColumns;
    }

    @RemoteAction
    public static void saveKanbanPreferences(ADM_KanbanPreferences kanbanPreferences) {
        ADM_User.setUserLaneScrollingPreference(kanbanPreferences.getLaneScrolling());
    }

    @RemoteAction
    public static void saveKanbanColors(ADM_KanbanPreferences kanbanPreferences) {
        List<ADM_Color__c> teamColors = kanbanPreferences.getTeamColors();
        if(teamColors!= null && teamColors.size()>0){
            Database.upsert(teamColors);
        }
    }

    @RemoteAction
    public static void saveKanbanWorkCardPreferences(ADM_KanbanPreferences kanbanPreferences) {
        ADM_User.saveKanbanWorkCardPreferences(kanbanPreferences);
    }

    @RemoteAction
    public static void removeKanbanColors(List<String> colorIds) {
        List<ADM_Color__c> colors = ADM_Color.getColorsById(colorIds);
        if(colorIds!= null && colorIds.size()>0){
            Database.delete(colors);
        }
    }

    /**
    * Saves the specified work object.
    */
    @RemoteAction
    public static List<ADM_Work.SaveWorksError> saveWorks(List<ADM_Work__c> works, boolean allOrNone) {
        return ADM_Work.saveWorks(ADM_WorkTriggerStaticDataStore.KANBAN_BOARD_ORIGIN, works, allOrNone);
    }

     /**
    * Saves columns passed in, statusmapping is ignore if list has more than one columns.
    */
    @RemoteAction
    public static SaveColumnsResult saveColumns(List<ADM_Column> columns) {
        SaveColumnsResult result = new SaveColumnsResult();
        try{
            if(null != columns){
                if(columns.size() == 1){
                    result = addOrUpdateSingleColumn(columns[0]);
                }
                else{
                    //if it is a list of columns we don't need to save status mapping
                    result = modifyMultipleColumns(columns);
                }
            }
        }
        catch(Exception exp){
            throw new ADM_ApplicationException('Column save failed with exception.' + exp);
        }

        return result;

    }

    private static SaveColumnsResult modifyMultipleColumns(List<ADM_Column> columns){
        SaveColumnsResult result = new SaveColumnsResult();
        List<ADM_Column__c> columnsToInsert = new List<ADM_Column__c>();
        List<ADM_Column__c> columnsToUpdate = new List<ADM_Column__c>();
        for(ADM_Column column: columns){
            if(column.getColumnSObject().Id == null){
                columnsToInsert.add(column.getColumnSObject());
            }
            else{
                columnsToUpdate.add(column.getColumnSObject());
            }
        }

        if(columnsToInsert.size() > 0){
            insert columnsToInsert;
            result.action = 'Insert';
        }
        if(columnsToUpdate.size() > 0){
            update columnsToUpdate;
            result.action = 'Update';
        }
        return result;
    }

    private static SaveColumnsResult addOrUpdateSingleColumn(ADM_Column column){
        SaveColumnsResult result = new SaveColumnsResult();
        List<ADM_Column__c> columnsToUpsert = new List<ADM_Column__c>();
        ADM_Column__c columnSObject = column.getColumnSObject();
        boolean existingColumn = false;
        if(ADM_TextUtils.validateId(columnSObject.Id)){
            existingColumn = true;
        }

        if(existingColumn && null != columnSObject.get('Active__c') && false == columnSObject.Active__c){
            Integer positionIncrement = 0;
            List<ADM_Column__c> columnsWithSameIndexAndAbove = ADM_ColumnQueryUtils.getColumnsFromThisPositionAndAbove(column.getColumnSObject().Team__c, column.getColumnSObject().Parent_Column__c, column.getColumnSObject().Level__c, column.getColumnSObject().Position__c+1);
            if(null != columnsWithSameIndexAndAbove && columnsWithSameIndexAndAbove.size() >0){
                for(ADM_Column__c columnToDecrementPosition: columnsWithSameIndexAndAbove){
                    /*
                       Below we set the position of each column after column to be deleted. For instance, if column to be delete is at position 5 we set 5,6,7 for each column after position 5
                       in database now.
                    */
                    columnToDecrementPosition.Position__c = columnSObject.Position__c + positionIncrement++;
                }

            }
            if(null == columnsWithSameIndexAndAbove){
                columnsWithSameIndexAndAbove = new List<ADM_Column__c>();
            }

            if(columnsWithSameIndexAndAbove.size() == 0){//No sibling column...check there are other columns with higher levels than this column with same parents - If yes decerement column level for each of them.
                columnsToUpsert.addAll(checkAndUpdateColumnLevels(columnSObject));

            }
            //Add new column to the list so we can upsert all Sobjects together
            columnsWithSameIndexAndAbove.add(columnSObject);

            columnsToUpsert.addAll(columnsWithSameIndexAndAbove);
            upsert columnsToUpsert;
            deleteColumnStatusAssignment(columnSObject.Id);
            result.action = 'Delete';
        }
        else{

                    if(existingColumn){//Existing column : column update needed
                        update columnSObject;
                        result.newColumnId = columnSObject.Id;
                        result.action = 'Update';
                    }
                    else{
                        /*
                            Insert Column  and column status assignment, before inserting column making sure
                            Active__c = true
                        */
                        columnSObject.Active__c = true;
                        Integer positionIncrement = 1;
                        List<ADM_Column__c> columnsWithSameIndexAndAbove = getColumnsWithCurrentIndexAndAbove(column);
                        if(null != columnsWithSameIndexAndAbove && columnsWithSameIndexAndAbove.size() >0){
                            for(ADM_Column__c columnToIncrementPosition: columnsWithSameIndexAndAbove){
                                columnToIncrementPosition.Position__c = columnSObject.Position__c + positionIncrement++;
                            }
                            //Add new column to the list so we can upsert all Sobjects together
                            columnsWithSameIndexAndAbove.add(columnSObject);
                            result.action = 'Upsert';
                        }
                        else{
                            if(columnsWithSameIndexAndAbove == null){
                                columnsWithSameIndexAndAbove = new List<ADM_Column__c>();
                            }
                            columnsWithSameIndexAndAbove.add(columnSObject);
                            result.action = 'Insert';

                        }
                        upsert columnsWithSameIndexAndAbove;

                        result.newColumnId = columnSObject.Id;


                    }

                    /*
                      Delete existing column assignments and create new column assignments for insert and update.
                    */
                    if(result.action == 'Update'){
                        deleteColumnStatusAssignment(columnSObject.Id);
                    }


                    List<ADM_Column_Status_Assignment__c> columnStatusAssignments = new List<ADM_Column_Status_Assignment__c>();
                    if(null != column.getMappedWorkStatuses()){
                        for(String workStatusId: column.getMappedWorkStatuses().keySet()){
                            ADM_Column_Status_Assignment__c columnStatusAssignment = new ADM_Column_Status_Assignment__c();
                            columnStatusAssignment.Column__c = columnSObject.Id;
                            columnStatusAssignment.Work_Status__c = workStatusId;
                            columnStatusAssignments.add(columnStatusAssignment);
                        }
                        if(columnStatusAssignments.size() >0){
                           insert columnStatusAssignments;
                        }
                    }


        }

        return result;

    }


    private static List<ADM_Column__c> checkAndUpdateColumnLevels(ADM_Column__c currentColumn){
        Boolean columnHasSiblings = false;
        List<ADM_Column__c> columnsToUpdateLevel = new List<ADM_Column__c>();
        List<ADM_Column__c> columnsWithSameLevelAndAbove = ADM_ColumnQueryUtils.getColumnsFromThisLevelAndAbove(currentColumn.Team__c, currentColumn.Parent_Column__c, currentColumn.Level__c);
            if(null != columnsWithSameLevelAndAbove && columnsWithSameLevelAndAbove.size() >0){
                for(ADM_Column__c columnIter: columnsWithSameLevelAndAbove){
                    /*
                       Below we set the position of each column after column to be deleted. For instance, if column to be delete is at position 5 we set 5,6,7 for each column after position 5
                       in database now.
                    */
                    if(currentColumn.Id != columnIter.Id && currentColumn.Level__c == columnIter.Level__c){
                        columnHasSiblings = true;
                        //Siblings found no need to proceed
                        break;
                    }
                }

                if(!columnHasSiblings){
                    Integer levelIncrement = 0;
                    for(ADM_Column__c columnIter: columnsWithSameLevelAndAbove){
                        /*
                           Below we set the position of each column after column to be deleted. For instance, if column to be delete is at position 5 we set 5,6,7 for each column after position 5
                           in database now.
                        */
                        if(currentColumn.Id != columnIter.Id && currentColumn.Level__c != columnIter.Level__c){
                            columnIter.Level__c = currentColumn.Level__c + levelIncrement++;
                            columnsToUpdateLevel.add(columnIter);
                        }
                    }
                }

            }
        return columnsToUpdateLevel;

    }

    private static void deleteColumnStatusAssignment(Id columnId){
        List<ADM_Column_Status_Assignment__c> existingColumnStatusAssignments =  ADM_ColumnStatusAssignment.getAssignmentsByColumn(columnId);
        if(existingColumnStatusAssignments.size() > 0 ){
            delete existingColumnStatusAssignments;
        }
    }

    private static List<ADM_Column__c>  getColumnsWithCurrentIndexAndAbove(ADM_Column column){
        List<ADM_Column__c> columnsWithSameIndexAndAbove =  ADM_ColumnQueryUtils.getColumnsFromThisPositionAndAbove(column.getColumnSObject().Team__c, column.getColumnSObject().Parent_Column__c, column.getColumnSObject().Level__c, column.getColumnSObject().Position__c);
        return columnsWithSameIndexAndAbove;
    }
    @RemoteAction
    public static KanbanWorkFeeder getNewAndBacklogWorks(String teamId, String backLogItemCount, String newItemCount){
        selectedTeamId = teamId;
        String recordTypeFilter = ' recordType.Name in (\'Bug\', \'User Story\')';
        String otherFilter = recordTypeFilter;
        otherFilter += ' and Column__c = null ';
        otherFilter += ' and Closed__c = 0 ';
        List<ADM_Work__c> backLogItems = ADM_Work.getTeamsWork(selectedTeamId, null, null, true, otherFilter, 'Priority_Rank__c nulls last, CreatedDate, Id desc', backLogItemCount); 



        otherFilter = recordTypeFilter;
        otherFilter += ' and Column__c = null ';
        otherFilter += ' and Closed__c = 0 ';
        List<ADM_Work__c> newWorkItems = ADM_Work.getTeamsWork(selectedTeamId, null, null, true, otherFilter, 'CreatedDate desc', newItemCount);

        KanbanWorkFeeder kanbanWorkFeeder = new KanbanWorkFeeder();

        kanbanWorkFeeder.backLogWorks = backLogItems;
        kanbanWorkFeeder.recentNewWorks = newWorkItems;
        kanbanWorkFeeder.leafNodeDetails = ADM_ColumnUtility.getLeafNodesByTeamId(teamId);

        return kanbanWorkFeeder;

    }

    /* commenting this out now... I have a feeling that we this might come back in future.Let's keep this for a while and clean up later.
    private static boolean canCreateColumnStatusAssignment(ADM_Column column){
        Map<Id, String> mappedWorkStatuses = column.getMappedWorkStatuses();
        if(null != mappedWorkStatuses && mappedWorkStatuses.size()>0){// Passed in ADM_Column object has workstatus in it
            return true;
        }
        else{
            return false;
        }
    }
    */


    public Boolean getCurrentUserLightningDesktopPreference() {
        return ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
    }

    /* commenting this out now... I have a feeling that we this might come back in future.Let's keep this for a while and clean up later.
    private static boolean canCreateColumnStatusAssignment(ADM_Column column){
        Map<Id, String> mappedWorkStatuses = column.getMappedWorkStatuses();
        if(null != mappedWorkStatuses && mappedWorkStatuses.size()>0){// Passed in ADM_Column object has workstatus in it
            return true;
        }
        else{
            return false;
        }
    }
    */

    public class KanbanData{
        List<ADM_Column> columns;
        ADM_KanbanPreferences kanbanPreferences;
        List<ADM_Color__c> teamColors;
    }


    public class SaveColumnsResult{
        @TestVisible
        String action;
        @TestVisible
        String newColumnId;
    }

    public class KanbanWorkFeeder{
        @TestVisible
        List<ADM_Work__c> backLogWorks;
        @TestVisible
        List<ADM_Work__c> recentNewWorks;
        List<ADM_ColumnUtility.LeafNodeDetails> leafNodeDetails;

    }
}