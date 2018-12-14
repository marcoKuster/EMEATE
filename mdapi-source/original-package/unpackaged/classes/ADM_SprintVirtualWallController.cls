public with sharing class ADM_SprintVirtualWallController {
    private static final String[] DEFAULT_POINT_SCALE = new String[]{'0','1','2','3','5','8','13','21'};

    private transient Id m_sprintId = null;
    private transient ADM_Sprint__c m_sprint = null;
    private transient ADM_Scrum_Team_Member__c[] m_scrumTeamMembers = null;
    private transient ADM_UserStoryAndTaskWrapper[] m_storiesAndTasks = null;
    private transient List<SelectOption> m_statusValues = null;
    private transient List<ADM_Theme__c> m_themes = null;
    private transient List<RecordType> m_recordTypes = null;
    private transient List<StatusType> m_statusTypes = null;
    private transient String m_name = null;
    private transient User m_defaultAssignee = null;
    private transient Boolean backlogViewPreference = null;
    private transient String[] storyPointScale = null;
    private transient Boolean isSprintOrdered = null;
    private transient Boolean showGuidedTour = null;
    private transient Boolean showMoveUncompletedTasksDialog = null;
    private transient Boolean showRemoveWorkFromSprintDialog = null;
    private transient Boolean showMoveWorkToOtherSprintDialog = null;
    private transient Boolean showMoveTaskToCompletedDialog = null;
    private transient Boolean showMoveTaskToInProgressDialog = null;
    private transient Boolean showDeleteTaskDialog = null;

    public Id getBugRecordTypeId() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Bug' AND sObjectType = 'ADM_Work__c'];
        
        return (rt != null ? rt.Id : null);
    }

    public Id getUserStoryRecordTypeId() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'User_Story' AND sObjectType = 'ADM_Work__c'];
        
        return (rt != null ? rt.Id : null);
    }

    public Id getInvestigationRecordTypeId() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Investigation' AND sObjectType = 'ADM_Work__c'];
        
        return (rt != null ? rt.Id : null);
    }

    public ADM_Sprint__c getSprint() {
        return this.m_sprint;
    }

    public void setSprintId(Id sprintId) {
        this.m_sprintId = sprintId;
        initialize(sprintId);
    }

    public static SprintData getSprintData(Id sprintId) {
        //setup streaming api here. 
        //Since these need to be only set up one time, we query the count and only proceed if its less than 5 to set up all push topics.
        Integer count = [select count() from PushTopic where Name in ('DeletedTaskUpdates','WorkHistory','WorkUpdates','TaskUpdates','SprintUpdates')];
        if (count != 5 && !Test.isRunningTest()) {
            ApexPages.StandardController stdControl;
            ADM_SprintDetailExtension ext = new ADM_SprintDetailExtension(stdControl);
            ext.ensurePushTopics();
        }
        
        ADM_Sprint__c sprint = [SELECT Id,Name,Scrum_Team__c,Committed_Story_Points_Completed__c,Completion_Committed_Story_Points__c,Committed_Items_Completed__c,Completion_Committed_Items__c,Committed_Items__c,Committed_Points__c,Completed_Items__c,Completed_Story_Points__c,Completion_Items__c,Completion_Story_Points__c,Days_Remaining__c,Definition_of_Ready_Met__c,Scrum_Team__r.Name,Scrum_Team__r.Story_Point_Scale__c,Scrum_Team__r.Capex_Enabled__c,Scrum_Team__r.Velocity_Type__c,Start_Date__c,End_Date__c from ADM_Sprint__C where id =: sprintId];
        String rawScale = sprint.Scrum_Team__r.Story_Point_Scale__c;

        SprintData sprintData = new SprintData();

        sprintData.sprintInfo = sprint;
        sprintData.sprintObjPrefix = getSprintObjPrefix();
        sprintData.scrumTeamMembers = getTeamMembersForTeam(sprint.Scrum_Team__c);
        sprintData.sprintWork = getWorkAndTasksForSprint(sprintId);
        sprintData.nextSprintId = ADM_SprintNavigationController.findTheNextSprintId(sprint);
        sprintData.previousSprintId = ADM_SprintNavigationController.findThePreviousSprintId(sprint);
        sprintData.statusTypes = getStatusTypeList();
        sprintData.storyPointScale = (rawScale == null || rawScale.trim().length() == 0 ? DEFAULT_POINT_SCALE : rawScale.split(','));
        sprintData.plannedVelocity =  calculatePlannedVelocity(sprintId);
        sprintData.userPreferences = getUserPreferences();
        sprintData.wallPreferences = getWallPreferenceJSON();
        sprintData.nameSpace = ADM_ConstantsSingleton.getInstance().getNameSpace();
        return sprintData;
    }

    @AuraEnabled
    public static String getSprintJSON(Id sprintId) {
        //returning JSON here so that all data about a sprint can be sent across in 1 lightweight call and for ease of use in js helpers/controllers.
        //Then just the data that is need for any component can be passed via an attribute.
        return JSON.serialize(getSprintData(sprintId));
    }

    @AuraEnabled
    public static String getSprintChartAura(String sprintId, String dataType) {
        String sprintChartAsJSON = ADM_BacklogController.getSprintChartAura(sprintId, dataType);
        return sprintChartAsJSON;
    }

    @AuraEnabled
    public static String saveWork(String jsonObj) {
        jsonObj = COM_SoqlUtils.convertToQualifiedQuery(jsonObj);
        //We are getting back JSON as a lightweight container for saving just the data that has changed and not having to pass all work and task data.                   
        ADM_Work__c work = (ADM_Work__c) JSON.deserialize(jsonObj, ADM_Work__c.class);
        
        upsert work;

        return getWorkWrapperAsJSON(work.Id);
    }

    @AuraEnabled
    public static String saveTask(String jsonObj) {
        //We are getting back JSON as a lightweight container for saving just the data that has changed and not having to pass all work and task data.
        jsonObj = COM_SoqlUtils.convertToQualifiedQuery(jsonObj);
        ADM_Task__c task = (ADM_Task__c) JSON.deserialize(jsonObj, ADM_Task__c.class);

        upsert task;

        return getWorkWrapperAsJSON(task.Work__c);
    }
    
    @AuraEnabled
    public static void saveUserPreference(String jsonStr) {
        ADM_User_Preferences__c preferences = (ADM_User_Preferences__c) JSON.deserialize(jsonStr, ADM_User_Preferences__c.class);
        
        if (preferences.Id == null) {
            ADM_User_Preferences__c userPref = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
            Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(jsonStr);
            List<String> keys = new List<String>();
            keys.addAll(obj.keyset());
            
            for (String key : keys) {
                userPref.put(key, preferences.get(key));
            }
            
            upsert userPref;
        } else {
        upsert preferences;
    }
    }
    
    @AuraEnabled
    public static String getWorkCreateEditPage(String recordType) {
        RecordType recType = ADM_RecordType.getByName(recordType, 'ADM_Work__c');

        return ADM_Work.getWorkCreateEditPage(UserInfo.getUserId(), recType).getUrl() + '?RecordType=' + recType.Id;
    }
    
    @AuraEnabled
    public static String getSprintObjPrefix() {
        return ADM_SprintLocatorController.getSprintObjPrefix();
    }

    @AuraEnabled
    public static List<ListView> getSprintListView() {
        return ADM_SprintLocatorController.getSprintListView();
    }
    
    @AuraEnabled
    public static String getUserInfoAura() {
        Id userId = UserInfo.getUserId();
        User u = [select Id, Name, SmallPhotoUrl from User where Id = :userId limit 1];
        List<PermissionSetAssignment> userPermSet = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId];
        
        UserData userData = new UserData();

        userData.user = u;
        userData.permSets = userPermSet;

        return JSON.serialize(userData);
    }

    @AuraEnabled
    public static void setWallPreferenceJSONAura(String wallPreferences) {
        String userId = UserInfo.getUserId();
        User user = [select Wall_Preference__c  from User where id = : userId limit 1];

        user.Wall_Preference__c = wallPreferences;
        
        update user ;
    }

    @AuraEnabled
    public static String getSprintWorkCommitment(String sprintId) {
        return ADM_ScopeChangeController.getSprintWorkCommitmentJSON(sprintId);
    }
    
    private static String getWallPreferenceJSON() {
        try {
            String userId = UserInfo.getUserId();
            List<User> json = [select Wall_Preference__c  from User where id = : userId];
            return json[0].Wall_Preference__c;
        } catch(Exception e) {
            System.debug('Unable to retrieve JSON values from Wall_Preference__c object.' + e);
            return '';
        }
    }

    public Id getSprintId() {
        return this.m_sprintId;
    }

    public String getSprintName() {
        return this.m_name;
    }

    public Id theNextSprint;

    public Id getTheNextSprint() {
        if(getSprint() != null) {
            Id sprintId = getSprintId();
            ADM_Sprint__c sprint = [SELECT Id,Scrum_Team__c,Start_Date__c,End_Date__c from ADM_Sprint__C where id =: sprintId];
            return ADM_SprintNavigationController.findTheNextSprintId(sprint);
        } else {
            return null;
        }
    }

    public Boolean getCurrentUserLightningDesktopPreference() {
        return ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
    }

    /**
     * Gets the list of stories associated to the sprint
     */
    public ADM_UserStoryAndTaskWrapper[] getStories() {
        return m_storiesAndTasks;
    }

    /**
     * Gets the list of team members associated to this sprint
     */
    public List<ADM_Scrum_Team_Member__c> getTeamMembers() {
        return m_scrumTeamMembers;
    }

     public List<StatusType> getStatusTypes() {
        if(m_statusTypes == null) {
           m_statusTypes = new List<StatusType>();
           m_statusTypes.addAll(ADM_SprintVirtualWallController.getStatusTypeList());
        }

        return m_statusTypes;
    }

    /**
     * Gets a list of themes that are in use within this sprint
     */
    public List<ADM_Theme__c> getThemesInUse() {
        if(m_themes == null) {
            Set<ADM_Theme__c> themeSet = new Set<ADM_Theme__c>();
            for(ADM_UserStoryAndTaskWrapper workWrapper : getStories()) {
                ADM_Theme__c theme = workWrapper.getWork().Theme__r;
                if(theme != null && !themeSet.contains(theme)) {
                    themeSet.add(theme);
                }
            }

            //create a map of themes by name for sorting
            Map<String, List<ADM_Theme__c>> themeNameMap = new Map<String, List<ADM_Theme__c>>();
            for(ADM_Theme__c theme : themeSet) {
                //initialize the list map if its a new name
                if(!themeNameMap.containsKey(theme.Name)) {
                    themeNameMap.put(theme.Name, new List<ADM_Theme__c>());
                }

                themeNameMap.get(theme.Name).add(theme);
            }

            //sort the list of names
            List<String> themeNames = new List<String>(themeNameMap.keySet());
            themeNames.sort();

            //create a new list from the sorted values
            m_themes = new List<ADM_Theme__c>();
            for(String themeName : themeNames) {
                m_themes.addAll(themeNameMap.get(themeName));
            }

            //TODO sort by created date when themes with the same name
        }
        return m_themes;
    }

    /**
     * Determines if the sprint contains any themes.
     */
    public boolean getContainsThemes() {
        return getThemesInUse().size() > 0;
    }

    /**
     * Gets a list of record types that are in use within this sprint
     */
    public List<RecordType> getRecordTypesInUse() {
        if(m_recordTypes == null) {

            //each record type should have a unique name, so no need to store a
            //list of record types per name
            Map<String, RecordType> recordTypeNameMap = new Map<String, RecordType>();
            for(ADM_UserStoryAndTaskWrapper workWrapper : getStories()) {
              RecordType recordType = workWrapper.getRecordType();
              if(!recordTypeNameMap.containsKey(recordType.Name)) {
                recordTypeNameMap.put(recordType.Name, recordType);
              }
            }

            //sort the list
            List<String> recordTypeNames = new List<String>(recordTypeNameMap.keySet());
            recordTypeNames.sort();

            //create a new list from the sorted values
            m_recordTypes = new List<RecordType>();
            for(String name : recordTypeNames) {
                m_recordTypes.add(recordTypeNameMap.get(name));
            }
        }
        return m_recordTypes;
    }

    /**
     * Gets the default task assignee
     */
    public Id getDefaultAssigneeId() {
        return m_defaultAssignee.Id;
    }

    /**
     * Gets the default task assignee
     */
    public User getDefaultAssignee() {
        return m_defaultAssignee;
    }

    /**
     * Gets the story point scale for the team as an array
     */
    public String[] getStoryPointScale() {
        if(storyPointScale == null) {
            try {
                ADM_Sprint__c sprint = getSprint();
                String rawScale = sprint.Scrum_Team__r.Story_Point_Scale__c;
                if(rawScale == null || rawScale.trim().length() == 0) {
                    storyPointScale = DEFAULT_POINT_SCALE;
                } else {
                    storyPointScale = rawScale.split(',');
                }
            } catch(Exception exc) {
                System.debug(LoggingLevel.WARN, 'Error while trying to determine Story Point Scale. ' + exc.getMessage());
                storyPointScale = DEFAULT_POINT_SCALE;
            }
        }
        return storyPointScale;
    }

    /**
     * Gets the story point scale for the team as an array formatted as JSON.
     */
    public String getStoryPointScaleAsJson() {
        return JSON.serialize(getStoryPointScale());
    }

    /**
     * Indicates whether or not to show the backlog view.
     */
    public Boolean getBacklogViewPreference() {
        try {
            if(this.backlogViewPreference == null) {
                //retrieve the user preferences for the current user
                ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
                this.backlogViewPreference = preferences.ShowBacklogviewonVirtualWall__c;
            }
            return this.backlogViewPreference;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving User Preferences. Returning false. ' + exc.getMessage());
            return false;
        }
    }

    /**
     * Determines if the work items have been ordered for this sprint.
     */
    public Boolean getIsSprintOrdered() {
        if(isSprintOrdered == null) {
            isSprintOrdered = false;
            for(ADM_UserStoryAndTaskWrapper story : getStories()) {
                if(story.getStory().Sprint_Rank__c != null) {
                    isSprintOrdered = true;
                    break;
                }
            }
        }
        return isSprintOrdered;
    }

    /**
     * Gets true when the virtual wall guided tour should be shown.
     */
    public Boolean getShowGuidedTour() {
        try {
            if(this.showGuidedTour == null) {
                this.showGuidedTour = getUserPreferences().ShowVirtualWallGuidedTour__c;
            }
            return this.showGuidedTour;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving User Preferences. Returning false. ' + exc.getMessage());
            return false;
        }
    }

    /**
     * Gets true when the "Move Uncompleted Tasks" dialog should be shown when the Work is closed
     */
    public Boolean getShowMoveUncompletedTasksDialog() {
        try {
            if(this.showMoveUncompletedTasksDialog == null) {
                this.showMoveUncompletedTasksDialog = getUserPreferences().ShowMoveUncompletedTasksDialog__c;
            }
            return this.showMoveUncompletedTasksDialog;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving Show "Move Uncompleted Tasks" Dialog Preference. Returning true. ' + exc.getMessage());
            return true;
        }
    }

    /**
     * Gets true when the "Remove Work from Sprint" dialog should be shown
     */
    public Boolean getShowRemoveWorkFromSprintDialog() {
        try {
            if(this.showRemoveWorkFromSprintDialog == null) {
                this.showRemoveWorkFromSprintDialog = getUserPreferences().ShowRemoveWorkFromSprintDialog__c;
            }
            return this.showRemoveWorkFromSprintDialog;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving Show "Remove Work from Sprint" Dialog Preference. Returning true. ' + exc.getMessage());
            return true;
        }
    }

    /**
     * Gets true when the "Move to next Sprint" dialog should be shown
     */
    public Boolean getShowMoveWorkToOtherSprintDialog() {
        try {
            if(this.showMoveWorkToOtherSprintDialog == null) {

                this.showMoveWorkToOtherSprintDialog = getUserPreferences().ShowMoveWorkToOtherSprintDialog__c;
            }
            return this.showMoveWorkToOtherSprintDialog;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving Show "Move Work to another Sprint" Dialog Preference. Returning true. ' + exc.getMessage());
            return true;
        }
    }

    /**
     * Gets true when the "Move Task To Completed" dialog should be shown
     */
    public Boolean getShowMoveTaskToCompletedDialog() {
        try {
            if(this.showMoveTaskToCompletedDialog == null) {
                this.showMoveTaskToCompletedDialog = getUserPreferences().ShowMoveTaskToCompletedDialog__c;
            }
            return this.showMoveTaskToCompletedDialog;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving Show "Move Task To Completed" Dialog Preference. Returning true. ' + exc.getMessage());
            return true;
        }
    }

    /**
     * Gets true when the "Move Task To In Progress" dialog should be shown
     */
    public Boolean getShowMoveTaskToInProgressDialog() {
        try {
            if(this.showMoveTaskToInProgressDialog == null) {
                this.showMoveTaskToInProgressDialog = getUserPreferences().ShowMoveTaskToInProgressDialog__c;
            }
            return this.showMoveTaskToInProgressDialog;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving Show "Move Task To In Progress" Dialog Preference. Returning true. ' + exc.getMessage());
            return true;
        }
    }

    /**
     * Gets true when the "Delete Task" dialog should be shown
     */
    public Boolean getShowDeleteTaskDialog() {
        try {
            if(this.showDeleteTaskDialog == null) {
                this.showDeleteTaskDialog = getUserPreferences().ShowDeleteTaskDialog__c;
            }
            return this.showDeleteTaskDialog;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving Show "Delete Task" Dialog Preference. Returning true. ' + exc.getMessage());
            return true;
        }
    }

    /**
     * Reinitializes the properties for the currently displayed sprint. This
     * is mainly used in testing after a value has been changed.
     */
    public void refresh() {
        initialize(this.m_sprintId);
    }

    /**
     * Initializes the controller with the data for the specified Sprint
     */
    private void initialize(Id sprintId) {
        m_sprint = [select Scrum_Team__c, Name, Scrum_Team__r.Story_Point_Scale__c, Scrum_Team__r.Capex_Enabled__c from ADM_Sprint__c where Id = :sprintId];
        m_scrumTeamMembers = getTeamMembersForTeam(m_sprint.Scrum_Team__c);
        m_storiesAndTasks = getWorkAndTasksForSprint(m_sprint.Id);
        m_statusValues = null;
        m_themes = null;
        m_recordTypes = null;
        m_defaultAssignee = determineDefaultAssignee();
        m_name = m_sprint.Name;
    }

    /**
     * Determine the default task assignee
     */
    private User determineDefaultAssignee() {
        List<ADM_Scrum_Team_Member__c> teamMembers = getTeamMembers();
        Id currentUserId = UserInfo.getUserId();

        //if the current user is in the team or the team does not have any team members, they become the default assignee
        if(teamMembers.size() == 0 || ADM_ScrumTeamMemberUtils.containsUser(teamMembers, currentUserId)) {
            return [select Id, Name, FirstName, LastName, SmallPhotoUrl from User where Id = :currentUserId];
        }

        //if the team contains a scrum master, assign it to them
        List<ADM_Scrum_Team_Member__c> scrumMasters = ADM_ScrumTeamMemberUtils.getScrumMasters(teamMembers);
        if(!scrumMasters.isEmpty()) {
            return scrumMasters.get(0).Member_Name__r;
        }

        System.debug('Setting the default assignee for tasks to the first team member');
        return teamMembers.get(0).Member_Name__r;
    }

    /**
     * Saves the specified work object.
     */
    @RemoteAction
    public static SaveResponse saveWork(ADM_Work__c work, DateTime lastModifiedDate) {      
        if(ADM_SchemaManager.isObjectUpsertable('ADM_Work__c')){
            if(work == null) {
                return null;
            }
            if(lastModifiedDate != null && work.Id != null) {
                List<ADM_Work__c> currentWorkList = [select Id, Name, LastModifiedDate, LastModifiedBy.Name from ADM_Work__c where Id = :work.Id];
                if(!currentWorkList.isEmpty()) {
                    ADM_Work__c currentWork = currentWorkList.get(0);

                    //check to see if the record has been modified since the current user has downloaded
                    if(currentWork.LastModifiedDate != lastModifiedDate && currentWork.LastModifiedBy.Id != UserInfo.getUserId()) {
                        throw new ADM_ApplicationException('Egads! ' + currentWork.LastModifiedBy.Name + ' modified work ' + currentWork.Name + ' since your last sync. Refresh the page to retrieve the latest data.');
                    }
                }
            }
            upsert work;

            ADM_VirtualWallWork updatedWork = getWorkById(work.Id);
            return new WorkSaveResponse(updatedWork);
        }
        else{
             System.debug('Current user has no upsert access to ADM_Work__c');
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Work__c');
        }

    }

    /**
     * Calculates the Planned Velocity
     */
    @RemoteAction
    public static Integer calculatePlannedVelocity(Id sprintId) {
        try{
            Integer storyPoints = ADM_SprintVirtualWallController.getStoryPointsForSprint(sprintId);
            return storyPoints;
        }
        catch(Exception e){
            System.debug('Error fetching and calculating Planned Velocity Value : '+e);
            return 0;
        }
    }


    private static Integer getStoryPointsForSprint(Id sprintId){

       AggregateResult[] groupedResults =
            [select SUM(Story_Points__c)sum from ADM_Work__c where Sprint__c  =: sprintId AND Status__c NOT IN ('Duplicate') group by Sprint__c];
       if(groupedResults!=null){
            Object queryResult =   groupedResults[0].get('sum');
            Integer storyPoints = Integer.valueOf(queryResult);
            return storyPoints != null ? storyPoints : 0;
       }
       else
            return 0;
    }

    /**
     * Closes the specified work item and completes all tasks that are associated.
     */
    @RemoteAction
    public static SaveResponse closeWorkAndTasks(Id workId) {
            if(workId == null) {
                return null;
            }

            List<ADM_Work__c> currentWorkList = [select Id, Name, Status__c, RecordType.Name, (select Status__c, Hours_Remaining__c from Tasks__r) from ADM_Work__c where Id = :workId];
            if(currentWorkList.isEmpty()) {
               //if the work ID specified is not found, then just return a null
               return null;
            }

            ADM_Work__c work = currentWorkList.get(0);

            //close the work item
            if(work.RecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG || work.RecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY) {
                work.Status__c = 'Closed';
            } else if(work.RecordType.Name == ADM_Work.RECORD_TYPE_NAME_TODO) {
                work.Status__c = 'Completed';
            }

            //Complete each of the associated tasks
            for(ADM_Task__c task : work.Tasks__r) {
                task.Status__c = 'Completed';
                task.Hours_Remaining__c = 0;
            }

            if(ADM_SchemaManager.isObjectUpdateable('ADM_Work__c')){
                update work;
            }
            else{
                 System.debug('Current user has no upsert access to ADM_Work__c');
                 throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Work__c');
            }

            if(ADM_SchemaManager.isObjectUpdateable('ADM_Task__c')){
                update work.Tasks__r;
            }
            else{
                 System.debug('Current user has no upsert access to ADM_Task__c');
                 throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Task__c');
            }

            ADM_VirtualWallWork updatedWork = getWorkById(workId);
            return new WorkSaveResponse(updatedWork);
    }

    /**
     * Saves the specified work object.
     */
    @RemoteAction
    public static SaveResponse saveTask(ADM_Task__c task, DateTime lastModifiedDate) {
        if(ADM_SchemaManager.isObjectUpsertable('ADM_Task__c')){
            if(task == null) {
                return null;
            }

            if(lastModifiedDate != null && task.Id != null) {
                List<ADM_Task__c> currentTaskList = [select Id, Name, LastModifiedDate, LastModifiedBy.Name from ADM_Task__c where Id = :task.Id];
                if(!currentTaskList.isEmpty()) {
                    ADM_Task__c currentTask = currentTaskList.get(0);

                    //check to see if the record has been modified since the current user has downloaded
                    if(currentTask.LastModifiedDate != lastModifiedDate && currentTask.LastModifiedBy.Id != UserInfo.getUserId()) {
                       throw new ADM_ApplicationException('Egads! ' + currentTask.LastModifiedBy.Name + ' modified task ' + currentTask.Name + ' since your last sync. Refresh the page to retrieve the latest data.');
                    }
                }
            }

            upsert task;
            task = getTaskById(task.Id);
            return new TaskSaveResponse(task);
        }
        else{
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Task__c');
        }
    }

    /**
     * Deletes the task corresponding to the ID from the database.
     * @returns Returns true if the deletion was successful.
     */
    @RemoteAction
    public static Boolean deleteTask(Id taskId) {
        if(ADM_SchemaManager.isObjectDeletable('ADM_Task__c')){
            List<ADM_Task__c> tasks = [select Id from ADM_Task__c where Id = :taskId limit 1];
            if(!tasks.isEmpty()) {
               delete tasks;
            }
            return true;
        }
        else{
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Task__c');
        }
    }

    @RemoteAction
    public static Boolean changeTaskStatusToInProgress(Id taskId) {
        return changeTaskStatusTo(taskId, 'In Progress');
    }

    @RemoteAction
    public static Boolean changeTaskStatusToPlanned(Id taskId) {
        return changeTaskStatusTo(taskId, 'Not Started');
    }

    @RemoteAction
    public static Boolean changeTaskStatusToCompleted(Id taskId) {
        return changeTaskStatusTo(taskId, 'Completed');
    }

    /**
     * Utility function for changing the status of a task to the specified value
     */
     @RemoteAction
    public static Boolean changeTaskStatusTo(Id taskId, String statusValue) {
        if(ADM_SchemaManager.isObjectUpdateable('ADM_Task__c')){
            ADM_Task__c t = [select Id, Status__c from ADM_Task__c where Id = :taskId limit 1];
            if (t != null) {
                t.Status__c = statusValue;
                update t;
            }
            return true;
        }
        else{
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Task__c');
        }
    }

    /**
     * Given the list of work IDs, the order of the work (within the sprint) is
     * updated sequentially. All work associated to the sprint and not found in
     * the list of IDs will have their order reset to null.
     *
     * More specifically, if given the following list of ID values
     *    [a0sB00000008dmW, a0sB00000008jhA, a0sB00000008dpQ]
     *
     * Results in the following updates
     *    work[Id=a0sB00000008dmW].Sprint_Rank__c = 1
     *    work[Id=a0sB00000008jhA].Sprint_Rank__c = 2
     *    work[Id=a0sB00000008dpQ].Sprint_Rank__c = 3
     */
    @RemoteAction
    public static WorkOrderChangeResponse updateWorkOrder(WorkOrderChangeRequest request) {
        if(ADM_SchemaManager.isObjectUpdateable('ADM_Work__c')){
            if(request.sprintId == null) {
                System.debug('Unable to change the order of the work items because the sprint was not specified.');
                return null;
            }

            //get all of the work items for the specified sprint
            Map<Id, ADM_Work__c> workMap = new Map<Id, ADM_Work__c>([select Id, Sprint_Rank__c from ADM_Work__c where Sprint__c = :request.sprintId]);

            //reset all rank to null
            for(ADM_Work__c work : workMap.values()) {
                work.Sprint_Rank__c = null;
            }

            //set the new order
            if(request.workIds != null) {
                for(Integer index = 0; index < request.workIds.size(); index++) {
                    String workId = request.workIds.get(index);

                    //make sure the ID is valid
                    if(!workMap.containsKey(workId)) {
                        System.debug(LoggingLevel.WARN, 'ID at index ' + index + ' is not a valid work ID. Skipping this index.');
                        continue;
                    }

                    ADM_Work__c work = workMap.get(workId);
                    work.Sprint_Rank__c = index + 1;
                }
            }

            //bulk update the work items
            Database.update(workMap.values());

            WorkOrderChangeResponse response = new WorkOrderChangeResponse();
            response.sprintId = request.sprintId;
            response.works = [select Id, LastModifiedDate, Sprint_Rank__c from ADM_Work__c where Sprint__r.Id = :request.sprintId and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME and RecordType.Name != :ADM_Work.RECORD_TYPE_NAME_INVESTIGATION ORDER BY Sprint_Rank__c ASC NULLS LAST, Priority_Rank__c ASC NULLS LAST, CreatedDate ASC];
            return response;
        }
        else{
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Work__c');
        }
    }

    @AuraEnabled
    public static String updateWorkOrderAura(String jsonRequest) {
        if(ADM_SchemaManager.isObjectUpdateable('ADM_Work__c')){
            WorkOrderChangeRequest request = (WorkOrderChangeRequest) JSON.deserialize(jsonRequest, WorkOrderChangeRequest.class);

            if(request.sprintId == null) {
                System.debug('Unable to change the order of the work items because the sprint was not specified.');
                return null;
            }

            //get all of the work items for the specified sprint
            Map<Id, ADM_Work__c> workMap = new Map<Id, ADM_Work__c>([select Id, Sprint_Rank__c from ADM_Work__c where Sprint__c = :request.sprintId]);

            //reset all rank to null
            for(ADM_Work__c work : workMap.values()) {
                work.Sprint_Rank__c = null;
            }

            //set the new order
            if(request.workIds != null) {
                for(Integer index = 0; index < request.workIds.size(); index++) {
                    String workId = request.workIds.get(index);

                    //make sure the ID is valid
                    if(!workMap.containsKey(workId)) {
                        System.debug(LoggingLevel.WARN, 'ID at index ' + index + ' is not a valid work ID. Skipping this index.');
                        continue;
                    }

                    ADM_Work__c work = workMap.get(workId);
                    work.Sprint_Rank__c = index + 1;
                }
            }

            //bulk update the work items
            Database.update(workMap.values());

            WorkOrderChangeResponse response = new WorkOrderChangeResponse();
            response.sprintId = request.sprintId;
            response.works = [select Id, LastModifiedDate, Sprint_Rank__c from ADM_Work__c where Sprint__r.Id = :request.sprintId and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME and RecordType.Name != :ADM_Work.RECORD_TYPE_NAME_INVESTIGATION ORDER BY Sprint_Rank__c ASC NULLS LAST, Priority_Rank__c ASC NULLS LAST, CreatedDate ASC];
            return JSON.serialize(response);
        }
        else{
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Work__c');
        }
    }


    /**
     * Removes the sprint ordering from all of the work items in the given sprint.
     */
    @RemoteAction
    public static Boolean resetWorkOrder(Id sprintId) {
        if(ADM_SchemaManager.isObjectUpdateable('ADM_Work__c')){
            if(sprintId == null) {
                System.debug('Unable to change the order of the work items because the sprint was not specified.');
                return false;
            }

            //get all of the work items for the specified sprint
            List<ADM_Work__c> works = [select Id, Sprint_Rank__c from ADM_Work__c where Sprint__c = :sprintId];

            //reset all rank to null
            for(ADM_Work__c work : works) {
                work.Sprint_Rank__c = null;
            }

            Database.update(works);
            return true;
        }
        else{
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Work__c');
        }
    }

    /**
     * Gets the order of the work items within the sprint
     */
    @RemoteAction
    public static List<Id> getWorkOrder(Id sprintId) {
        List<ADM_UserStoryAndTaskWrapper> workList = getWorkAndTasksForSprint(sprintId);
        List<Id> workIdList = new List<Id>();
        for(ADM_UserStoryAndTaskWrapper work : workList) {
            workIdList.add(work.getId());
        }
        return workIdList;
    }

    /**
     * Given the list of tasks, the order is updated sequentially. Any task
     * assigned to the given work item but not in the array of tasks is given
     * a null order.
     *
     * More specifically, if given the following list of ID values
     *    [a0sB00000008dmW, a0sB00000008jhA, a0sB00000008dpQ]
     *
     * Results in the following updates
     *    task[Id=a0sB00000008dmW].Order__c = 1
     *    task[Id=a0sB00000008jhA].Order__c = 2
     *    task[Id=a0sB00000008dpQ].Order__c = 3
     */
    @RemoteAction
    public static ADM_VirtualWallWork updateTaskOrder(TaskOrderChangeRequest request) {
        if(ADM_SchemaManager.isObjectUpdateable('ADM_Work__c')){
            Id workId = request.workId;

            System.debug('plannedTasks: ' + request.plannedTasks.size());
            System.debug('inProgressTasks: ' + request.inProgressTasks.size());
            System.debug('completedTasks: ' + request.completedTasks.size());

            Map<Id, ADM_Task__c> taskMap = new Map<Id, ADM_Task__c>([SELECT Id, Status__c, Order__c From ADM_Task__c WHERE Work__c = :workId]);

            //reset all order values to null
            for(ADM_Task__c task : taskMap.values()) {
                task.Order__c = null;
            }

            //change the planned tasks to the order specified
            for(Integer index = 0; index < request.plannedTasks.size(); index++) {
                String taskId = request.plannedTasks.get(index);

                //if the ID specified in the order is not a valid task ID skip it
                if(!taskMap.containsKey(taskId)) {
                    System.debug(LoggingLevel.WARN, 'ID at index ' + index + ' is not a valid task ID. Skipping this index.');
                    continue;
                }

                ADM_Task__c task = taskMap.get(taskId);
                task.Order__c = index + 1;
                if(task.Status__c == 'In Progress' || task.Status__c == 'Completed') {
                    task.Status__c = 'Not Started';
                }
            }

            //change the in progress tasks to the order specified
            for(Integer index = 0; index < request.inProgressTasks.size(); index++) {
                String taskId = request.inProgressTasks.get(index);

                //if the ID specified in the order is not a valid task ID skip it
                if(!taskMap.containsKey(taskId)) {
                    System.debug(LoggingLevel.WARN, 'ID at index ' + index + ' is not a valid task ID. Skipping this index.');
                    continue;
                }

                ADM_Task__c task = taskMap.get(taskId);
                task.Order__c = index + 1;
                if(task.Status__c != 'In Progress') {
                    task.Status__c = 'In Progress';
                }
            }

            //change the completed tasks to the order specified
            for(Integer index = 0; index < request.completedTasks.size(); index++) {
                String taskId = request.completedTasks.get(index);

                //if the ID specified in the order is not a valid task ID skip it
                if(!taskMap.containsKey(taskId)) {
                    System.debug(LoggingLevel.WARN, 'ID at index ' + index + ' is not a valid task ID. Skipping this index.');
                    continue;
                }

                ADM_Task__c task = taskMap.get(taskId);
                task.Order__c = index + 1;
                if(task.Status__c != 'Completed') {
                    task.Status__c = 'Completed';
                }
            }

            Database.update(taskMap.values());

            ADM_VirtualWallWork updatedWork = getWorkById(workId);
            return updatedWork;
        }
        else{
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Task__c');
        }
    }

    /**
     * Gets the order of the tasks for the specified work item.
     */
    @RemoteAction
    public static TaskOrderResponse getTaskOrder(String workId) {
        ADM_VirtualWallWork work = getWorkById(workId);
        if(work != null) {
           return new TaskOrderResponse(work);
        } else {
            return null;
        }
    }

    @RemoteAction
    public static ADM_Task__c getTaskById(String taskId) {
        ADM_Task__c[] tasks = [select Actual_Hours__c, Assigned_To__c, Assigned_To__r.Id, Assigned_To__r.FirstName, Assigned_To__r.LastName, Assigned_To__r.Name, Assigned_To__r.SmallPhotoUrl, Comments__c, Hours_Remaining__c, Id, LastModifiedById, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Name, LastModifiedDate, Name, Order__c, Starting_Hours__c, Status__c, Subject__c, Work__c, Work__r.Capex_Enabled__c, Capex_Enabled__c from ADM_Task__c where Id = :taskId limit 1];
        if(tasks.size() == 0) {
            return null;
        } else {
            return tasks[0];
        }
    }

    @RemoteAction
    public static ADM_Deleted_Task__c getDeletedTaskById(String logId) {
        ADM_Deleted_Task__c[] logEntries = [select Name, Work__c, Task__c, LastModifiedById, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Name, LastModifiedDate from ADM_Deleted_Task__c where Id = :logId];
        if(logEntries.size() == 0) {
            return null;
        } else {
            return logEntries[0];
        }
    }

    @RemoteAction
    public static ADM_VirtualWallWork getWorkById(String workId) {
        ADM_Work__c[] works = [SELECT Id, Name, Closed__c, Subject__c, Assignee__r.Id, Assignee__r.FirstName, Assignee__r.LastName, Assignee__r.Name, Assignee__r.SmallPhotoUrl, QA_Engineer__r.Id, QA_Engineer__r.FirstName, QA_Engineer__r.LastName, QA_Engineer__r.Name, QA_Engineer__r.SmallPhotoUrl, LastModifiedById, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Name, LastModifiedDate, Status__c, Sprint__c, RecordType.Name, Theme__r.Name, Scheduled_Build__r.Name, Story_Points__c, (SELECT Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Subject__c, Status__c, Work__c, Order__c, LastModifiedById, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Name, LastModifiedDate FROM Tasks__r ORDER BY Order__c ASC NULLS LAST, CreatedDate ASC), (SELECT Id, Theme__r.Id, Theme__r.Name from Theme_Assignments__r ORDER BY Theme__r.Name) FROM ADM_Work__c WHERE Id = :workId and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME];
        if(works.size() == 0) {
            return null;
        } else {
            return new ADM_VirtualWallWork(new ADM_UserStoryAndTaskWrapper(works[0]));
        }
    }
    
    @RemoteAction
    public static void setBacklogPreference(boolean backlogview) {
        ADM_User_Preferences__c preferences = getUserPreferences();
        preferences.ShowBacklogviewonVirtualWall__c = backlogview;
        upsert preferences;
    }

    /**
     * Change the user preference to never show the Guided Tour again.
     */
    @RemoteAction
    public static void neverShowGuidedTour() {
        ADM_User_Preferences__c preferences = getUserPreferences();
        preferences.ShowVirtualWallGuidedTour__c = false;
        upsert preferences;
    }

    /**
     * Change the user preference to never show the "Move Uncompleted Tasks" dialog again.
     */
    @RemoteAction
    public static void neverShowMoveUncompletedTasksDialog() {
        ADM_User_Preferences__c preferences = getUserPreferences();
        preferences.ShowMoveUncompletedTasksDialog__c = false;
        upsert preferences;
    }

    /**
     * Change the user preference to never show the "Remove Work from Sprint" dialog again.
     */
    @RemoteAction
    public static void neverShowRemoveWorkFromSprintDialog() {
        ADM_User_Preferences__c preferences = getUserPreferences();
        preferences.ShowRemoveWorkFromSprintDialog__c = false;
        upsert preferences;
    }

    /**
     * Change the user preference to never show the "Move Work to Other Sprint" dialog again.
     */
    @RemoteAction
    public static void neverShowMoveWorkToOtherSprintDialog() {
        ADM_User_Preferences__c preferences = getUserPreferences();
        preferences.ShowMoveWorkToOtherSprintDialog__c = false;
        upsert preferences;

    }

    /**
     * Change the user preference to never show the "Move Task To Completed" dialog again.
     */
    @RemoteAction
    public static void neverShowMoveTaskToCompletedDialog() {
        ADM_User_Preferences__c preferences = getUserPreferences();
        preferences.ShowMoveTaskToCompletedDialog__c = false;
        upsert preferences;
    }

    /**
     * Change the user preference to never show the "Move Task To In Progress" dialog again.
     */
    @RemoteAction
    public static void neverShowMoveTaskToInProgressDialog() {
        ADM_User_Preferences__c preferences = getUserPreferences();
        preferences.ShowMoveTaskToInProgressDialog__c = false;
        upsert preferences;
    }

    /**
     * Change the user preference to never show the "Delete Task" dialog again.
     */
    @RemoteAction
    public static void neverShowDeleteTaskDialog() {
        ADM_User_Preferences__c preferences = getUserPreferences();
        preferences.ShowDeleteTaskDialog__c = false;
        upsert preferences;
    }

    /**
     * Gets all of the work instances and tasks for the given sprint
     */
    private static List<ADM_UserStoryAndTaskWrapper> getWorkAndTasksForSprint(Id sprintId) {
        ADM_Work__c[] works = [SELECT Id, Name, Subject__c , Closed__c, Assignee__r.Id, Assignee__r.FirstName, Assignee__r.LastName, Assignee__r.Name, Assignee__r.SmallPhotoUrl, QA_Engineer__r.FirstName, QA_Engineer__r.Id, QA_Engineer__r.LastName, QA_Engineer__r.Name, QA_Engineer__r.SmallPhotoUrl, LastModifiedDate, LastModifiedById, Status__c, Sprint__c, Sprint__r.Start_Date__c, Sprint__r.End_Date__c, RecordType.Name, Theme__r.Name, Scheduled_Build__r.Name, Story_Points__c, Sprint_Rank__c, Capex_Enabled__c, (SELECT Id, Assigned_To__c, Assigned_To__r.Id, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Actual_Hours__c,  LastModifiedDate, Subject__c, Status__c, Work__c, Work__r.Capex_Enabled__c, Work__r.Sprint__c, Order__c, Capex_Enabled__c FROM Tasks__r ORDER BY Order__c ASC NULLS LAST, CreatedDate ASC), (SELECT Id, Theme__r.Id, Theme__r.Name from Theme_Assignments__r ORDER BY Theme__r.Name) FROM ADM_Work__c WHERE Sprint__r.Id = :sprintId and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME  ORDER BY Sprint_Rank__c ASC NULLS LAST, Priority_Rank__c ASC NULLS LAST, CreatedDate ASC];
        return getWorkResultsInWrapper(works);
    }

    @AuraEnabled
    public static String getWorkWrapperAsJSON(String workId){
        System.debug(' inside controller getWorkWrapperAsJSON '+  workId);
        ADM_Work__c[] works = [SELECT Id, Name, Subject__c , Closed__c, Assignee__r.Id, Assignee__r.FirstName, Assignee__r.LastName, Assignee__r.Name, Assignee__r.SmallPhotoUrl, QA_Engineer__r.FirstName, QA_Engineer__r.Id, QA_Engineer__r.LastName, QA_Engineer__r.Name, QA_Engineer__r.SmallPhotoUrl, LastModifiedDate, LastModifiedById, Status__c, Sprint__c, Sprint__r.Start_Date__c, Sprint__r.End_Date__c, RecordType.Name, Theme__r.Name, Scheduled_Build__r.Name, Story_Points__c, Sprint_Rank__c, Capex_Enabled__c, (SELECT Id, Assigned_To__c, Assigned_To__r.Id, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Actual_Hours__c,  LastModifiedDate, Subject__c, Status__c, Work__c, Work__r.Capex_Enabled__c, Order__c, Capex_Enabled__c FROM Tasks__r ORDER BY Order__c ASC NULLS LAST, CreatedDate ASC), (SELECT Id, Theme__r.Id, Theme__r.Name from Theme_Assignments__r ORDER BY Theme__r.Name) FROM ADM_Work__c WHERE Id = :workId and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME  ORDER BY Sprint_Rank__c ASC NULLS LAST, Priority_Rank__c ASC NULLS LAST, CreatedDate ASC];
        return JSON.serialize(getWorkResultsInWrapper(works));
    }

    private static List<ADM_UserStoryAndTaskWrapper> getWorkResultsInWrapper(List<ADM_Work__c> works){
        List<ADM_UserStoryAndTaskWrapper> storiesAndTasks = new List<ADM_UserStoryAndTaskWrapper>();
        for(ADM_Work__c story : works) {
            ADM_UserStoryAndTaskWrapper storyWrapper = new ADM_UserStoryAndTaskWrapper(story, story.RecordType);
            storyWrapper.getThemeNameCsv();
            storiesAndTasks.add(storyWrapper);
        }
        return storiesAndTasks;
    }

    @AuraEnabled
    public static  String getSessionId(){
        return UserInfo.getSessionId();
    }

    /**
     * Gets a list of all the team members associated to the specified team.
     */
    private static List<ADM_Scrum_Team_Member__c> getTeamMembersForTeam(Id scrumTeamId) {
        return [SELECT Member_Name__r.Id, Member_Name__r.Name, Member_Name__r.FirstName, Member_Name__r.LastName, Member_Name__r.SmallPhotoUrl, Allocation__c, Role__c FROM ADM_Scrum_Team_Member__c WHERE Scrum_Team__r.Id  = :scrumTeamId AND Member_Name__r.Id != null AND Member_Name__r.IsActive = true ORDER BY Member_Name__r.Name ];
    }

    private static List <StatusType> getStatusTypeList() {
        Map<String, StatusType> statusMap = new Map<String, StatusType>();
        Map<String, RecordType> recordTypesByName = ADM_RecordType.mapRecordTypeListByName(ADM_RecordType.getAll());

        //since we store the status values by record type (record type => status value)
        //we need to invert the map so that we store by status value (status value => record type) but in a list so that the sort order is maintained
        Map<String,List<String>> statusMapByRecordTypeName = ADM_Work.getStatusValues();

        List<StatusType> statusTypeList = new List<StatusType>();
        for(String recordTypeName : statusMapByRecordTypeName.keySet()) {
            RecordType recordType = recordTypesByName.get(recordTypeName);
            if(recordType == null) {
                continue;
            }

            for(String statusValue : statusMapByRecordTypeName.get(recordTypeName)) {
                StatusType statusType = null;
                statusType = new StatusType(statusValue);
                statusType.addRecordType(recordType);
                statusTypeList.add(statusType);
            }
        }

        return statusTypeList;
    }

    /**
     * Retrieves the user preferences for the current user
     */
    private static ADM_User_Preferences__c getUserPreferences() {
        return ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
    }

    /**
     * Lightweight object sent when a client wants to get the order of the tasks
     * associated to a work item (using #getTaskOrder).
     */
    public class TaskOrderResponse {
        public Id workId;
        public List<Id> notStartedTasks = new List<Id>();
        public List<Id> inProgressTasks = new List<Id>();
        public List<Id> completedTasks = new List<Id>();

        public TaskOrderResponse(ADM_VirtualWallWork work) {
            workId = work.work.Id;

            for(ADM_Task__c task : work.notStartedTasks) {
                notStartedTasks.add(task.Id);
            }
            for(ADM_Task__c task : work.inProgressTasks) {
                inProgressTasks.add(task.Id);
            }
            for(ADM_Task__c task : work.completedTasks) {
                completedTasks.add(task.Id);
            }
        }
    }

    /**
     * Create a lightweight version of the ADM_UserStoryAndTaskWrapper so that when
     * it is serialized by the RemoteAction it only contains the sobject properties.
     */
    public class ADM_VirtualWallWork {

        public ADM_Work__c work { get; set; }
        public List<ADM_Task__c> notStartedTasks { get; set; }
        public List<ADM_Task__c> inProgressTasks { get; set; }
        public List<ADM_Task__c> completedTasks { get; set; }

        public ADM_VirtualWallWork(ADM_UserStoryAndTaskWrapper wrapper) {
            this.work = wrapper.getWork();
            this.notStartedTasks = wrapper.getPlannedTasks();
            this.inProgressTasks = wrapper.getInProgressTasks();
            this.completedTasks = wrapper.getCompletedTasks();
        }
    }

    public virtual class SaveResponse {
        public Id Id;
        public User Assignee;
        public User QA_Engineer;
        public DateTime LastModifiedDate;

        public SaveResponse(Id id, User assignee, User qa_engineer, DateTime lastModifiedDate) {
            this.Id = id;
            this.Assignee = assignee;
            this.QA_Engineer = qa_engineer;
            this.LastModifiedDate = lastModifiedDate;
        }
    }

    public virtual class TaskSaveResponse extends SaveResponse {
        public ADM_Task__c item;

        public TaskSaveResponse(ADM_Task__c task) {
            super(task.Id, task.Assigned_To__r, task.Assigned_To__r, task.LastModifiedDate);
            this.item = task;
        }
    }

    public virtual class WorkSaveResponse extends SaveResponse {
        public ADM_VirtualWallWork item;

        public WorkSaveResponse(ADM_VirtualWallWork work) {
            super(work.work.Id, work.work.Assignee__r, work.work.QA_Engineer__r, work.work.LastModifiedDate);
            this.item = work;
        }
    }

    public class TaskOrderChangeRequest {
        public Id workId;
        public List<Id> plannedTasks;
        public List<Id> inProgressTasks;
        public List<Id> completedTasks;
    }

    public class WorkOrderChangeRequest {
        public Id sprintId;
        public List<Id> workIds;
    }

    public class WorkOrderChangeResponse {
        public Id sprintId;
        public List<ADM_Work__c> works;
    }

    public class StatusType {
        private String value;
        private String label;
        private Set<RecordType> recordTypes;

        public StatusType(String value) {
            this.value = value;
            this.label = value;
            this.recordTypes = new Set<RecordType>();
        }

        public String getLabel() {
            return this.label;
        }

        public String getValue() {
            return this.value;
        }

        public Set<RecordType> getRecordTypes() {
            return this.recordTypes;
        }

        public String getRecordTypesAsAliasCsv() {
            Set<String> recordTypeAliases = new Set<String>();
            for(RecordType recordType : recordTypes) {
                String alias = ADM_RecordType.getRecordTypeAlias(recordType);
                recordTypeAliases.add(alias);
            }
            return ADM_TextUtils.joinSet(recordTypeAliases, ',');
        }

        public Boolean containsRecordType(String recordTypeName) {
            for(RecordType recordType : recordTypes) {
                if(recordType.Name == recordTypeName) {
                    return true;
                }
            }
            return false;
        }

        public void addRecordType(RecordType recordType) {
            this.recordTypes.add(recordType);
        }
    }

    public class SprintData {
        public Id nextSprintId;
        public Id previousSprintId;
        public ADM_User_Preferences__c userPreferences;
        public List<ADM_Scrum_Team_Member__c> scrumTeamMembers;
        public ADM_Sprint__c sprintInfo;
        public String sprintObjPrefix;
        public List<ADM_UserStoryAndTaskWrapper> sprintWork;
        public List<StatusType> statusTypes;
        public String[] storyPointScale;
        public String wallPreferences;
        public Integer plannedVelocity;
        public String nameSpace;
        public SprintData() {}
    }
    
    public class UserData {
        public User user;
        public List<PermissionSetAssignment> permSets;

        public UserData() {}
    }
}