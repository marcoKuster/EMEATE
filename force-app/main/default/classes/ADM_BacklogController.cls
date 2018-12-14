public with sharing class ADM_BacklogController {

    ADM_ConstantsSingleton singletonConstants = ADM_ConstantsSingleton.getInstance();

    private transient Id selectedTeamId;
    private transient List<ADM_Scrum_Team__c> teams;
    private transient ADM_Scrum_Team__c team;
    public String teamMemberId { get; set; }
    public List<ADM_Scrum_Team_Member__c> allocations { get; set; }
    public User currentUserDetails {get;set;}
    public Boolean showBoard = false;
    public ADM_BacklogController() {
        //Loading team's Kanban page columns
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        if(parameters.containsKey('teamId')) {
            selectedTeamId = (Id)parameters.get('teamId');
        }
        else{
             List<String> teamIds = new ADM_ScrumTeamMemberUtils().getScrumTeamIds();
             if(teamIds != null && teamIds.size() == 1){
               selectedTeamId = teamIds[0];
               parameters.put('teamId', selectedTeamId);
             }
        }
        if(selectedTeamId != null){
            this.teams = [select Id, Name, Story_Point_Scale__c from ADM_Scrum_Team__c where Id = :selectedTeamId];
            if(null != teams && teams.size() > 0){
                this.team = this.teams[0];
                showBoard = true;
            }
        }
    }

    public String getTeamName() {
        String teamName = '';
        if(team != null){
            teamName = team.Name;
        }
        return teamName;
    }

    public String getTeamStoryPointScale() {
        String storyPointScale = '';
        if(team != null){
            storyPointScale = team.Story_Point_Scale__c;
        }
        return storyPointScale;
    }

    public String getTeamId() {
        String teamId = '';
        if(team != null){
            teamId = team.Id;
        }
        return teamId;
    }

    public Boolean getShowBoard() {
        return showBoard;
    }

    public String getcurrentUserPhoto() {
        String teamMemberId = UserInfo.getUserId();
        User t =[Select t.SmallPhotoUrl From User t Where t.Id =: teamMemberId];
        return t.SmallPhotoUrl;
    }

    //Getter method for userPreference to access from VF page
    public String getUserPreferences(){
      return getUserPreferencesAsJSON();
    }

    @RemoteAction
    public static String getUserPreferencesAsJSON(){
        try{
            List<User> json = [select User_Preference__c  from User where id = : UserInfo.getUserId()];
            return json[0].User_Preference__c;
        }
        catch(Exception e){
            System.debug('Unable to retrieve JSON values from user.user_preference__c field. e:'+e);
            return '';
        }
    }

    @RemoteAction
    public static void saveUserPreferenceAsJSON(String jsonValue) {
        User user = [SELECT Id, User_Preference__c from User where Id = : UserInfo.getUserId()];
        user.User_Preference__c = jsonValue;
        update user;
    }

    @TestVisible
    private static BackLogManagerResponse getPanelWorkItems(QueryParameters parameters, String type, Boolean isReactCall, Integer numberOfRows, Integer offset) {
        String teamId = parameters.teamId;
        ADM_ConstantsSingleton singletonConstants = ADM_ConstantsSingleton.getInstance();
        BackLogManagerResponse response = ADM_BacklogUtility.getPanelWorkItemsByType(parameters, type, isReactCall, numberOfRows, offset);
        String jsonUserPreference = getUserPreferencesAsJSON();
        if(ADM_TextUtils.isblank(jsonUserPreference)) {
           response.columns = ADM_BacklogUtility.getDefaultBackLogColumns();
            response.options = null;
        } else {
           System.debug('returning user backlog column preferences jsonUserPreference:' + jsonUserPreference);
           try {
               UserPreference deserializedUserPreference = (ADM_BacklogController.UserPreference)JSON.deserialize(jsonUserPreference, ADM_BacklogController.UserPreference.class);
               response.columns =  deserializedUserPreference.columns;
            } catch (Exception e) {
                System.debug('Exception inside getPanelWorkItems() when de-serializing the user preference json.  Loading default columns instead.  exception:' + e);
                response.columns = ADM_BacklogUtility.getDefaultBackLogColumns();
            }
           try {
               UserPreference deserializedUserPreference = (ADM_BacklogController.UserPreference)JSON.deserialize(jsonUserPreference, ADM_BacklogController.UserPreference.class);
               response.options = deserializedUserPreference.options;
               response.options.lastView = type;//Returning "type" which was requested instead of what is saved in the last view
            } catch (Exception e) {
                System.debug('Exception inside getPanelWorkItems() when de-serializing the user preference json.  Loading default options instead.  exception:' + e);
                response.options = null;
            }

        }
        response.team = ADM_BacklogUtility.getTeam(teamId);
        response.allColumns = ADM_BacklogUtility.getAllBackLogColumns();
        response.allProductTags = ADM_BacklogUtility.getActiveProductTagsForTeam(teamId);
        response.allUsers = ADM_BacklogUtility.getUsersForTeam(teamId);
        response.allKanbanStates = ADM_BacklogUtility.getColumnsForTeamWithPathInfo(teamId);
        response.allSprints = ADM_BacklogUtility.getCurrentSprintsForTeam(teamId);
        response.currentSprint = ADM_Sprint.getCurrentSprintForTeam(teamId);
        response.oldSprints = ADM_BacklogUtility.getOldSprintsForTeam(teamId);
        response.allWorkStatuses = ADM_BacklogUtility.getWorkStatuses();
        response.nameSpace = singletonConstants.getNameSpace();
        return response;
    }

    @RemoteAction
    public static String getPanelWorkItemsAsJson(QueryParameters parameters, String type, Boolean isReactCall, Integer numberOfRows, Integer offset) {
        String teamId = parameters.teamId;
        String panelWorkItemsAsJSON = '';
        if(teamId != null && ((String) teamId).length() > 0){System.debug(teamId);
          panelWorkItemsAsJSON = JSON.serialize(getPanelWorkItems(parameters, type, isReactCall, numberOfRows, offset));
        }
        return panelWorkItemsAsJSON;

    }

    @RemoteAction
    public static String getThroughputChart(Integer numOfWeeks, String teamId) {
        String throughputChartAsJSON = JSON.serialize(ADM_ThroughputChart.getThroughputChartForTeamAndGivenNumberOfWeeks(numOfWeeks,teamId));
        return throughputChartAsJSON;
    }

    @RemoteAction
    public static String getVelocityChartInfo(Integer numOfSprints, String teamId) {
        String velocityChartAsJSON = JSON.serialize(ADM_VelocityChart.getVelocityChartInfo(null,teamId));
        return velocityChartAsJSON;
    }

    @RemoteAction
    public static String getSprintChart(String sprintId) {
        String sprintChartAsJSON = JSON.serialize(ADM_BacklogUtility.getSprintChart(sprintId));
        return sprintChartAsJSON;
    }

    @AuraEnabled
    public static String getSprintChartAura(String sprintId, String dataType) {
        String sprintChartAsJSON = JSON.serialize(ADM_BacklogUtility.getSprintChart(sprintId, dataType));
        return sprintChartAsJSON;
    }

    public class BacklogOptions {
        public Boolean showDebugInfo;
        public Boolean showVelocityLine;
        public Integer averageVelocity;
        public Integer numOfSprintsToCalculate;
        public String lastView;
        public String filters;
    }

    public class BackLogManagerResponse {
        public ADM_Scrum_Team__c team;
        public List<ADM_Work__c> records;
        public Integer numberOfRecords;
        public List<BacklogColumn> columns;
        public List<BacklogColumn> allColumns;
        public List<ADM_Product_Tag__c> allProductTags;
        public List<User> allUsers;
        public List<ADM_ColumnUtility.LeafNodeDetails> allKanbanStates;
        public List<ADM_Sprint__c> allSprints;
        public List<ADM_Sprint__c> oldSprints;
        public List<ADM_Work_Status__c> allWorkStatuses;
        public BacklogOptions options;
        public boolean defaultView;//This variable is set to true if we have to fall back to show Backlog view; eg: querying for an invalid sprint id and it never returns any work items for it.
        public List<RecordType> allRecordTypes;
        public List<ADM_Epic__c> allEpics;
        public List<ADM_Build__c> allBuilds;
        public List<UserRecord> allAssignees;
        public List<UserRecord> allQAEngineers;
        public List<UserRecord> allProductOwners;
        public ADM_Sprint__c currentSprint;
        public String nameSpace;
    }

    public class BacklogColumn {
        public String id;
        public String label;
        public String value;
        public Boolean showLabel;
        public Boolean sortable;
        public Boolean editable;
        public String editType;
        public Boolean groupable;
        public Boolean draggable;
        public Boolean filterable;
        public Boolean required;
        public Boolean truncate;
        public String direction;
        public String style;
        public String link;
        public String smallPhotoUrl;
    }

    public class UserPreference {
         public List<BacklogColumn> columns;
        public BacklogOptions options;
    }

    public class UserRecord implements Comparable{
      public String Name;
      public String Id;
      public String SmallPhotoUrl;
      public String Username;

      public Integer compareTo(Object compareTo) {
                Integer returnValue = 0;
          UserRecord userRecordCompareTo = (UserRecord)compareTo;
          if (Name > userRecordCompareTo.Name) {
            returnValue = 1;
          } else if (Name < userRecordCompareTo.Name) {
            returnValue = -1;
          }
        return returnValue;

      }
    }

    public class QueryParameters {
      public String teamId;
      public String sprintId;
      public String paramId;
    }

    @RemoteAction
    public static List<ADM_Work.SaveWorksError> saveWorks(List<ADM_Work__c> works, boolean allOrNone) {
        return ADM_Work.saveWorks(ADM_WorkTriggerStaticDataStore.BACKLOG_MANAGER_ORIGIN, works, allOrNone);
    }

    @RemoteAction
    public static ADM_SprintVirtualWallController.WorkOrderChangeResponse updateSprintOrder(ADM_SprintVirtualWallController.WorkOrderChangeRequest request) {
        return ADM_SprintVirtualWallController.updateWorkOrder(request);
    }

    public String nameSpace{
        get{
          return singletonConstants.getNameSpace();
        }
        set;

    }
}