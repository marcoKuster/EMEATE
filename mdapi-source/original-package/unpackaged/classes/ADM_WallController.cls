public with sharing class ADM_WallController {
    private static final Integer DEFAULT_PANEL_ROW_COUNT = 200;
    private static final String SELECT_FROM_TASK_RELATIONSHIP = 'select Work__c, Subject__c, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.SmallPhotoUrl, Status__c, Hours_Remaining__c, Order__c from Tasks__r order by Work__c, Status__c, Order__c NULLS LAST';
    private static final String SELECT_FROM_WORK = 'select Id, RecordTypeId, Name, Subject__c, Details__c, Details_and_Steps_to_Reproduce__c, Feature_Rank__c, Trust_Rank__c, Theme_Rank__c, Priority_Rank__c, Scheduled_Build_Rank__c, Priority__c, Story_Points__c, Status__c, Sprint__c, Sprint__r.Id, Sprint__r.Name, Sprint_Rank__c, Scheduled_Build__c,Found_in_Build__c, Epic__c, Epic_Rank__c, Product_Tag__c ,Scheduled_Build__r.Name, QA_Engineer__c, QA_Engineer__r.Name, QA_Engineer__r.SmallPhotoUrl, Product_Owner__c, Product_Owner__r.Name, Product_Owner__r.SmallPhotoUrl, Assignee__c, Assignee__r.Name, Assignee__r.SmallPhotoUrl, (' + SELECT_FROM_TASK_RELATIONSHIP + '), (select Theme__c, Theme__r.Id, Theme__r.Name from Theme_Assignments__r order by Theme__r.Name) from ADM_Work__c ';

    private transient List<ADM_Scrum_Team__c> teams;
    private transient List<RecordType> recordTypes;
    private transient Id selectedTeamId;
    private transient String panelJSONValues;
    private transient String backlogSprintToggleValue;
    private transient String userId;
    ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance();
    public ADM_WallController() {
        //allow the user to preload a teams' backlog
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        if(parameters.containsKey('teamId')) {
            this.selectedTeamId = (Id)parameters.get('teamId');
            this.teams = [select Id, Name from ADM_Scrum_Team__c where Id = :selectedTeamId];
        } else {
            throw new ADM_ApplicationException('Team must be specified on the URL using teamId');
        }
    }
    /**
     * Gets the teams to be cached on the client
     */
    public List<ADM_Scrum_Team__c> getTeams() {
        return teams;
    }
    
    public Boolean getCurrentUserLightningDesktopPreference() {
        return ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
    }

    //Always expect only one Team for getTeams() method as the query is Id = :selectedTeamId
    public String getTeamId(){
        if(getTeams().size()>0){
            return this.getTeams()[0].Id;
        }
        return '';
    }

    public String getTeamsAsJson() {
        return JSON.serialize(this.getTeams());
    }

    public String getUserId() {
        return UserInfo.getUserId();
    }

    public String getPanelJSONValues(){
        try{
            String userId = UserInfo.getUserId();
            List<User> json = [select Wall_Preference__c  from User where id = : userId];
            return json[0].Wall_Preference__c;
        }
        catch(Exception e){
            System.debug('Unable to retrieve JSON values from Wall_Preference__c object.'+e);
            return '';
        }
    }
    
    /**
     * Gets the record types to be cached on the client
     */
    public List<RecordType> getRecordTypes() {
        if(recordTypes == null) {
            String sobjectTypeName =  ADM_ConstantsSingleton.getInstance().getNameSpace() + 'ADM_Work__c';

            recordTypes = [select Id, Name from RecordType where SObjectType = :sobjectTypeName and Name != 'Template'];
        }
        return recordTypes;
    }
    
    public String getRecordTypesAsJson() {
        return JSON.serialize(getRecordTypes());
    }
    
    public Id getSelectedTeamId() {
        return this.selectedTeamId;
    }
    
    public String getSelectedTeamIdAsJson() {
        return JSON.serialize(this.getSelectedTeamId());
    }

    public Boolean packagedOrg{
        get{
          return signletonConstants.isPackagedOrg();
        }
        set;
       
    }
    
    /**
     * Sets the order of the teams backlog based on the IDs of the specified work items.
     */
    @RemoteAction
    public static void setBacklogRank(Id teamId, List<ADM_Work__c> works) {
        List<Id> workIds = new List<Id>();
        for(ADM_Work__c work : works) {
            workIds.add(work.Id);
        }
      
        //Requery the work items so that we ensure only that priority_rank is only changed
        Map<Id, ADM_Work__c> workByIdMap = new Map<Id, ADM_Work__c>([select Id, Priority_Rank__c from ADM_Work__c where Id in :workIds and Scrum_Team__c = :teamId limit 10000]);
        for(ADM_Work__c work : works) {
            if(!workByIdMap.containsKey(work.Id)) {
                System.debug(LoggingLevel.WARN, 'Work ID ' + work.Id + ' is not part of Team ' + teamId + ' backlog.');
                continue;
            }
            workByIdMap.get(work.Id).Priority_Rank__c = work.Priority_Rank__c;
        }
        update workByIdMap.values();
    }
    
    /**
     * Gets the "master" backlog for the specified team
     */
    @RemoteAction
    public static ADM_WallController.QueryResponse getMasterBacklog(Id teamId, Integer offset, Integer numberOfRows, String hideWorkWithSprint) {
        String whereClause = '';
        whereClause += 'Closed__c = 0 ';
        whereClause += 'and (RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';
        whereClause += 'and Scrum_Team__c = :teamId ';
        whereClause += 'and Use_Prioritizer__c = true ';
        whereClause += 'and Priority_Rank__c != null ';
        if(hideWorkWithSprint == 'true'){
            whereClause += 'and Sprint__c = null ';
        }
        setUserPreferenceForSprintToggle(hideWorkWithSprint); //This method sets the User preference for BacklogHideWorkWithSprintToggle based on what the user clicks on the UW.
        String orderClause = 'Priority_Rank__c nulls last, CreatedDate, Id desc ';
        
        //execute the query and save as a response
        ADM_WallController.QueryResponse response = new ADM_WallController.QueryResponse();
        response.records = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
        response.numberOfRecords = Database.countQuery(buildCountQuery(whereClause));
        return response;
    }

    public static void setUserPreferenceForSprintToggle(String hideWorkWithSprint) {
        try{
            ADM_User_Preferences__c preferences = getUserPreferences();
            if(hideWorkWithSprint == 'true') {
                preferences.BacklogHideWorkWithSprintToggle__c = true;
            }
            else{
                preferences.BacklogHideWorkWithSprintToggle__c = false;
            } 
            upsert preferences;
        }
        catch(Exception e){
            System.debug('Exception while setting BacklogHideWorkWithSprintToggle User Preference value : '+e);
        }
    }

    public Boolean getBacklogSprintToggleValue() {
        try{
            ADM_User_Preferences__c preferences = getUserPreferences();
            return preferences.BacklogHideWorkWithSprintToggle__c;
        }
        catch(Exception e){
            System.debug('Exception while retrieving BacklogHideWorkWithSprintToggle User Preference value : '+e);
            return true;
        }
        
    }

    private static ADM_User_Preferences__c getUserPreferences() {
        return ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
    }

    /**
     * Gets the backburner for the specified team
     */
    @RemoteAction
    public static ADM_WallController.QueryResponse getBackburner(Id teamId, Integer offset, Integer numberOfRows) {
        String whereClause = '';
        whereClause += 'Closed__c = 0 ';
        whereClause += 'and (RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';
        whereClause += 'and Use_Prioritizer__c = true ';
        whereClause += 'and Scrum_Team__c = :teamId ';
        whereClause += 'and Priority_Rank__c = null ';
        
        String orderClause = 'Backburner_Rank__c nulls last, CreatedDate desc, Id desc';
        
        //execute the query and save as a response
        ADM_WallController.QueryResponse response = new ADM_WallController.QueryResponse();
        response.records = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
        response.numberOfRecords = Database.countQuery(buildCountQuery(whereClause));
        return response;
    }
    
    /**
     * Gets the feature backlog for the specified team
     */
    @RemoteAction
    public static ADM_WallController.QueryResponse getFeatureBacklog(Id teamId, Integer offset, Integer numberOfRows) {
        String whereClause = 'Closed__c = 0 ';
        whereClause += 'and RecordType.Name = \'User Story\' ';
        whereClause += 'and Scrum_Team__c = :teamId ';
        whereClause += 'and Use_Prioritizer__c = true ';
        whereClause += 'and Priority_Rank__c != null ';
        whereClause += 'and Id not in (select Work__c from ADM_Theme_Assignment__c where Theme__r.Name = \'Trust\' and Theme__r.Scrum_Team__c = null) ';
        
        String orderClause = 'Feature_Rank__c nulls last, Priority_Rank__c nulls last, CreatedDate, Id desc';
        
        //execute the query and save as a response
        ADM_WallController.QueryResponse response = new ADM_WallController.QueryResponse();
        response.records = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
        response.numberOfRecords = Database.countQuery(buildCountQuery(whereClause));
        return response;
    }
    
    /**
     * Sets the order of the feature backlog based on the IDs of the specified work items.
     */
    @RemoteAction
    public static void setFeatureRank(Id teamId, List<ADM_Work__c> works) {
        List<Id> workIds = new List<Id>();
        for(ADM_Work__c work : works) {
            workIds.add(work.Id);
        }
        
        //Requery the work items so that we ensure only that feature_rank is only changed
        Map<Id, ADM_Work__c> workByIdMap = new Map<Id, ADM_Work__c>([select Id, Feature_Rank__c from ADM_Work__c where Id in :workIds and Scrum_Team__c = :teamId limit 10000]);
        for(ADM_Work__c work : works) {
            if(!workByIdMap.containsKey(work.Id)) {
                System.debug(LoggingLevel.WARN, 'Work ID ' + work.Id + ' is not part of Team ' + teamId + ' backlog.');
                continue;
            }
            workByIdMap.get(work.Id).Feature_Rank__c = work.Feature_Rank__c;
        }
        update workByIdMap.values();
    }
    
    /**
     * Gets the trust backlog for the specified team
     */
    @RemoteAction
    public static ADM_WallController.QueryResponse getTrustBacklog(Id teamId, Integer offset, Integer numberOfRows) {
        String whereClause = 'Closed__c = 0 ';
        whereClause += 'and (RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';
        whereClause += 'and Scrum_Team__c = :teamId ';
        whereClause += 'and Use_Prioritizer__c = true ';
        whereClause += 'and Priority_Rank__c != null ';
        whereClause += 'and Id in (select Work__c from ADM_Theme_Assignment__c where Theme__r.Name = \'Trust\' and Theme__r.Scrum_Team__c = null) ';
        
        String orderClause = 'Trust_Rank__c nulls last, Priority_Rank__c nulls last, CreatedDate, Id desc';
        
        //execute the query and save as a response
        ADM_WallController.QueryResponse response = new ADM_WallController.QueryResponse();
        response.records = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
        response.numberOfRecords = Database.countQuery(buildCountQuery(whereClause));
        return response;
    }
    
    /**
     * Sets the order of the teams trust backlog based on the IDs of the specified work items.
     */
    @RemoteAction
    public static void setTrustRank(Id teamId, List<ADM_Work__c> works) {
        //get the IDs of the work records specified
        List<Id> workIds = new List<Id>();
        for(ADM_Work__c work : works) {
            workIds.add(work.Id);
        }
        
        //Requery the work items so that we ensure only that trust_rank is only changed
        Map<Id, ADM_Work__c> workByIdMap = new Map<Id, ADM_Work__c>([select Id, Trust_Rank__c from ADM_Work__c where Id in :workIds and Scrum_Team__c = :teamId and Id in (select Work__c from ADM_Theme_Assignment__c where Theme__r.Name = 'Trust' and Theme__r.Scrum_Team__c = null) limit 10000]);
        for(ADM_Work__c work : works) {
            if(!workByIdMap.containsKey(work.Id)) {
                System.debug(LoggingLevel.WARN, 'Work ID ' + work.Id + ' is not part of Trust for team ' + teamId + '.');
                continue;
            }
            workByIdMap.get(work.Id).Trust_Rank__c = work.Trust_Rank__c;
        }
        update workByIdMap.values();
    }
    
    @RemoteAction
    public static ADM_Theme__c getTheme(Id themeId) {
        List<ADM_Theme__c> themes = [select Id, Name from ADM_Theme__c where Id = :themeId];
        if(themes.isEmpty()) {
            throw new ADM_ApplicationException('No theme found with the specified ID: ' + themeId);
        }
        return themes.get(0);
    }
    
    /**
     * Gets the theme backlog for the specified theme
     */
    @RemoteAction
    public static ADM_WallController.QueryResponse getThemeBacklog(Id teamId, Id themeId, Integer offset, Integer numberOfRows) {
        String whereClause = 'Closed__c = 0 ';
        whereClause += 'and (RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';
        whereClause += 'and Scrum_Team__c = :teamId ';
        whereClause += 'and Id in (select Work__c from ADM_Theme_Assignment__c where Theme__c = :themeId) ';
        
        String orderClause = 'Priority_Rank__c nulls last, CreatedDate, Id desc';
        
        //execute the query and save as a response
        ADM_WallController.QueryResponse response = new ADM_WallController.QueryResponse();
        response.records = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
        response.numberOfRecords = Database.countQuery(buildCountQuery(whereClause));
        return response;
    }
    
    @RemoteAction
    public static ADM_Build__c getBuild(Id buildId) {
        List<ADM_Build__c> builds = [select Id, Name from ADM_Build__c where Id = :buildId];
        if(builds.isEmpty()) {
            throw new ADM_ApplicationException('No build found with the specified ID: ' + buildId);
        }
        return builds.get(0);
    }
    
    /**
      * Gets the scheduled build backlog for the specified build
      */
    @RemoteAction 
    public static ADM_WallController.QueryResponse getScheduledBuildBacklog(Id teamId, Id buildId, Integer offset, Integer numberOfRows) {
        String whereClause = 'Closed__c = 0 ';
        whereClause += 'and (RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';
        whereClause += 'and Scrum_Team__c = :teamId ';
        whereClause += 'and Scheduled_Build__c = :buildId ';
        
        String orderClause = 'Scheduled_Build_Rank__c nulls last, Priority_Rank__c nulls last, CreatedDate, Id desc';
        
        //execute the query and save as a response
        ADM_WallController.QueryResponse response = new ADM_WallController.QueryResponse();
        response.records = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
        response.numberOfRecords = Database.countQuery(buildCountQuery(whereClause));
        return response;
    }
    
    @RemoteAction
    public static void setScheduledBuildRank(List<ADM_Work__c> works) {
        works = validateWorkList(works);
        update works;
    }

    @RemoteAction
    public static void setBackburnerChanges(List<ADM_Work__c> works) {
        works = validateWorkList(works);
        update works;
    }
    
    @RemoteAction
    public static ADM_Sprint__c getSprint(Id sprintId) {
        List<ADM_Sprint__c> sprints = [select Id, Name from ADM_Sprint__c where Id = :sprintId];
        if(sprints.isEmpty()) {
            throw new ADM_ApplicationException('No sprint found with the specified ID: ' + sprintId);
        }
        return sprints.get(0);
    }
    
    @RemoteAction
    public static ADM_WallController.QueryResponse getSprintBacklog(Id teamId, Id sprintId, Integer offset, Integer numberOfRows) {
        String whereClause = '(RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';
        whereClause += 'and Sprint__c = :sprintId ';
        
        String orderClause = 'Sprint_Rank__c asc nulls last, Priority_Rank__c asc nulls last, CreatedDate asc, Id desc ';
        
        //execute the query and save as a response
        ADM_WallController.QueryResponse response = new ADM_WallController.QueryResponse();
        response.records = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
        response.numberOfRecords = Database.countQuery(buildCountQuery(whereClause));
        return response;
    }
    
    @RemoteAction
    public static void setSprintRank(Id teamId, Id sprintId, List<ADM_Work__c> works) {
        works = validateWorkList(works);
        update works;
    }


    @RemoteAction
    public static ADM_Epic__c getEpic(Id epicId) {
        List<ADM_Epic__c> epics = [select Id, Name from ADM_Epic__c where Id = :epicId];
        if(epics.isEmpty()) {
            throw new ADM_ApplicationException('No epic found with the specified ID: ' + epicId);
        }
        return epics.get(0);
    }
    
    @RemoteAction
    public static ADM_WallController.QueryResponse getEpicBacklog(Id teamId, Id epicId, Integer offset, Integer numberOfRows) {
        String whereClause = '(RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';
        whereClause += 'and Scrum_Team__c = :teamId ';
        whereClause += 'and Epic__c = :epicId ';
        
        String orderClause = 'Epic_Rank__c asc nulls last, Priority_Rank__c asc nulls last, CreatedDate asc, Id desc ';
        
        //execute the query and save as a response
        ADM_WallController.QueryResponse response = new ADM_WallController.QueryResponse();
        response.records = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
        response.numberOfRecords = Database.countQuery(buildCountQuery(whereClause));
        return response;
    }
    
    @RemoteAction
    public static void setEpicRank(Id teamId, Id epicId, List<ADM_Work__c> works) {
        works = validateWorkList(works);
        update works;
    }

    @RemoteAction
    public static void setJSONValues(String jsonValue) {
        User user = [SELECT Id, Wall_Preference__c from User where Id = : UserInfo.getUserId()];
        user.Wall_Preference__c = jsonValue;
        update user;
    }

    private static String buildListQuery(String whereClause, String orderClause, Integer numberOfRows, Integer offset) {
        String soql = ADM_WallController.SELECT_FROM_WORK;
        
        //add the where clause
        if(whereClause != null && whereClause.length() > 0) {
            soql += ' where ' + whereClause + ' ';
        }
        
        //add the order clause
        if(orderClause != null && orderClause.length() > 0) {
            soql += ' order by ' + orderClause + ' ';
        }
        
        soql += ADM_WallController.limitClause(numberOfRows) + ' ';
        soql += ADM_WallController.offsetClause(offset);
        
        return soql;
    }
    
    public static String buildCountQuery(String whereClause) {
        String soql = 'select count() from ADM_Work__c ';
        
        //add the where clause
        if(whereClause != null) {
            soql += ' where ' + whereClause + ' ';
        }
        
        return soql;
    }
    
    private static String limitClause(Integer numberOfRows) {
        return ' limit ' + ((numberOfRows == null || numberOfRows == -1) ? DEFAULT_PANEL_ROW_COUNT : numberOfRows);
    }
     
    private static String offsetClause(Integer offset) {
        if(offset != null && offset > 0) {
            return ' offset ' + offset + ' ';
        }
        return '';
    }

    private static List<ADM_Work__c> validateWorkList(List<ADM_Work__c> works) {
        List<ADM_Work__c> validatedWorkList = new List<ADM_Work__c>();
        for(ADM_Work__c work: works) {
            if(work != null && work.Id != null && ADM_TextUtils.isValidIdFormat(work.Id)) {
                validatedWorkList.add(work);
            } else {
                System.debug('ADM_WallController.validatedWorkList() WARNING found invalid work record. work:' + work);
            }
        }
        return validatedWorkList;
    }
    
    public class QueryResponse {
        public List<ADM_Work__c> records;
        public Integer numberOfRecords;
    }
}