global with sharing class ADM_TasksController {

private transient ADM_Scrum_Team_Member__c[] m_scrumTeamMembers = null;

private ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance();

public static String ERROR_CAPEX_TASK_ON_CLOSED_STORY = 'You cannot add Quality tasks to a closed user story. Please change user story status to add Quality tasks.';
/*
public ADM_TasksController(){
    initialize();
}

/**
 * Initializes the controller with the data for the specified Sprint
 */
/*
private void initialize() {
    m_scrumTeamMembers = getTeamMembersForTeam(work.Scrum_Team__c);
}
*/

public ADM_Work__c work {
    get;
    set;
}

/**
 * Gets a list of all the team members associated to the specified team.
 */
private static List<ADM_Scrum_Team_Member__c> getTeamMembersForTeam(Id scrumTeamId) {
    return [SELECT Member_Name__r.Id, Member_Name__r.Name, Member_Name__r.FirstName, Member_Name__r.LastName, Member_Name__r.SmallPhotoUrl, Allocation__c, Role__c FROM ADM_Scrum_Team_Member__c WHERE Scrum_Team__r.Id  = :scrumTeamId AND Member_Name__r.Id != null ORDER BY Member_Name__r.Name ];
}

public String getUserSmallPhotoUrl() {
    String userId = UserInfo.getUserId();
    User activeUser = [SELECT SmallPhotoUrl FROM User WHERE Id = :userId LIMIT 1];
    return activeUser.SmallPhotoUrl;
}

public ADM_UserStoryAndTaskWrapper getWorkAndTasks() {
    ADM_Work__c[] works = [SELECT Id, Name, Subject__c, Closed__c, Assignee__r.FirstName, Assignee__r.LastName, Assignee__r.Name, Assignee__r.SmallPhotoUrl, LastModifiedDate, Status__c, RecordType.Name, Capex_Enabled__c, (SELECT Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Actual_Hours__c, LastModifiedDate, Subject__c, Status__c, Work__c, Work__r.Capex_Enabled__c, Order__c, Capex_Enabled__c FROM Tasks__r ORDER BY Order__c ASC NULLS LAST, CreatedDate ASC) FROM ADM_Work__c WHERE Id = :work.Id];
    List<ADM_UserStoryAndTaskWrapper> workAndTasks = new List<ADM_UserStoryAndTaskWrapper>();
    for(ADM_Work__c work : works) {
        ADM_UserStoryAndTaskWrapper workWrapper = new ADM_UserStoryAndTaskWrapper(work, work.RecordType);
        workAndTasks.add(workWrapper);
    }
    return workAndTasks.get(0);
}

    /**
     * Gets the list of team members associated to this sprint
     */
    public List<ADM_Scrum_Team_Member__c> getTeamMembers() {
        m_scrumTeamMembers = getTeamMembersForTeam(work.Scrum_Team__c);
        return m_scrumTeamMembers;
    }


    /**
     * Create a lightweight version of the ADM_UserStoryAndTaskWrapper so that when
     * it is serialized by the RemoteAction it only contains the sobject properties.
     */
    global class ADM_VirtualWallWork {

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

    global class TaskOrderChangeRequest {
        public Id workId;
        public List<Id> plannedTasks;
        public List<Id> inProgressTasks;
        public List<Id> completedTasks;
    }

    global virtual class SaveResponse {
        public Id Id;
        public User Assignee;
        public DateTime LastModifiedDate;

        global SaveResponse(Id id, User assignee, DateTime lastModifiedDate) {
            this.Id = id;
            this.Assignee = assignee;
            this.LastModifiedDate = lastModifiedDate;
        }
    }

    global virtual class TaskSaveResponse extends SaveResponse {
        public ADM_Task__c item;

        public TaskSaveResponse(ADM_Task__c task) {
            super(task.Id, task.Assigned_To__r, task.LastModifiedDate);
            this.item = task;
        }
    }

    public Boolean packagedOrg{
        get{
          return signletonConstants.isPackagedOrg();
        }
        set;

    }

    public String nameSpace{
        get{
          return signletonConstants.getNameSpace();
        }
        set;

    }

    @RemoteAction
    global static ADM_VirtualWallWork getWorkById(String workId) {
        ADM_Work__c[] works = [SELECT Id, Name, Closed__c, Subject__c, Assignee__r.Id, Assignee__r.FirstName, Assignee__r.LastName, Assignee__r.Name, Assignee__r.SmallPhotoUrl, LastModifiedById, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Name, LastModifiedDate, Status__c, Sprint__c, RecordType.Name, Theme__r.Name, Scheduled_Build__r.Name, Story_Points__c, (SELECT Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.FirstName, Assigned_To__r.SmallPhotoUrl, Hours_Remaining__c, Subject__c, Status__c, Work__c, Order__c, LastModifiedById, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Name, LastModifiedDate FROM Tasks__r ORDER BY Order__c ASC NULLS LAST, CreatedDate ASC) FROM ADM_Work__c WHERE Id = :workId and RecordType.Name !=:ADM_Work.TEMPLATE_RECORD_TYPE_NAME and RecordType.Name != :ADM_Work.RECORD_TYPE_NAME_INVESTIGATION];
        if(works.size() == 0) {
            return null;
        } else {
            return new ADM_VirtualWallWork(new ADM_UserStoryAndTaskWrapper(works[0]));
        }
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
    global static ADM_VirtualWallWork updateTaskOrder(TaskOrderChangeRequest request) {
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
    @AuraEnabled
    public static String updateTaskOrderAura(String jsonRequest) {
        TaskOrderChangeRequest request = (TaskOrderChangeRequest) JSON.deserialize(jsonRequest, TaskOrderChangeRequest.class);
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

        String updatedWork = ADM_SprintVirtualWallController.getWorkWrapperAsJSON(workId);
        return updatedWork;
    }

    /**
     * Gets the order of the tasks for the specified work item.
     */
    @RemoteAction
    global static TaskOrderResponse getTaskOrder(String workId) {
        ADM_VirtualWallWork work = getWorkById(workId);
        if(work != null) {
           return new TaskOrderResponse(work);
        } else {
            return null;
        }
    }

    @RemoteAction
    global static ADM_Task__c getTaskById(String taskId) {
        ADM_Task__c[] tasks = [select Actual_Hours__c, Assigned_To__c, Assigned_To__r.Id, Assigned_To__r.FirstName, Assigned_To__r.LastName, Assigned_To__r.Name, Assigned_To__r.SmallPhotoUrl, Comments__c, Hours_Remaining__c, Id, LastModifiedById, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Name, LastModifiedDate, Name, Order__c, Starting_Hours__c, Status__c, Subject__c, Work__c, Work__r.Capex_Enabled__c, Capex_Enabled__c from ADM_Task__c where Id = :taskId limit 1];
        if(tasks.size() == 0) {
            return null;
        } else {
            return tasks[0];
        }
    }

    @RemoteAction
    global static ADM_Deleted_Task__c getDeletedTaskById(String logId) {
        ADM_Deleted_Task__c[] logEntries = [select Name, Work__c, Task__c, LastModifiedById, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Name, LastModifiedDate from ADM_Deleted_Task__c where Id = :logId];
        if(logEntries.size() == 0) {
            return null;
        } else {
            return logEntries[0];
        }
    }

    /**
     * Saves the specified work object.
     */
    @RemoteAction
    global static SaveResponse saveTask(ADM_Task__c task, DateTime lastModifiedDate) {
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

        try {
            upsert task;
        } catch(Exception e) {
            String errMsg = e.getMessage();
            String[] taskErrorNonEmployee = ADM_Task.TASK_ERROR_NONEMPLOYEE.split('<0>');

            if (errMsg.containsIgnoreCase(ERROR_CAPEX_TASK_ON_CLOSED_STORY)) {
                throw new ADM_ApplicationException(ERROR_CAPEX_TASK_ON_CLOSED_STORY);
            } else if (errMsg.containsIgnoreCase(taskErrorNonEmployee[0]) && errMsg.containsIgnoreCase(taskErrorNonEmployee[1])) {
                throw new ADM_ApplicationException(errMsg.substring(errMsg.indexOf(taskErrorNonEmployee[0]), errMsg.indexOf(taskErrorNonEmployee[1]) + (taskErrorNonEmployee[1].length())));
            } else {
                throw new ADM_ApplicationException(errMsg);
            }
        }

        task = getTaskById(task.Id);
        return new TaskSaveResponse(task);
    }

    /**
     * Deletes the task corresponding to the ID from the database.
     * @returns Returns true if the deletion was successful.
     */
    @RemoteAction
    global static Boolean deleteTask(Id taskId) {
        List<ADM_Task__c> tasks = [select Id from ADM_Task__c where Id = :taskId limit 1];
        if(!tasks.isEmpty()) {
           delete tasks;
        }
        return true;
    }

    /**
     * Deletes the task corresponding to the ID from the database.
     * @returns Returns true if the deletion was successful.
     */
    @AuraEnabled
    global static Boolean deleteTaskAura(Id recordId) {
        List<ADM_Task__c> tasks = [select Id from ADM_Task__c where Id = :recordId limit 1];
        if(!tasks.isEmpty()) {
           delete tasks;
        }
        return true;
    }


    @AuraEnabled
    public static String deleteTaskAuraNew(Id recordId) {
        List<ADM_Task__c> tasks = [select Id, Work__c from ADM_Task__c where Id = :recordId limit 1];

        Id workId = tasks[0].Work__c;

        if(!tasks.isEmpty()) {
           delete tasks;
        }
        return ADM_SprintVirtualWallController.getWorkWrapperAsJSON(workId);
    }

    @AuraEnabled
    public static String getUserInfoAura() {
        User u = [select Id, Name, SmallPhotoUrl from User where Id = :UserInfo.getUserId() limit 1];
        
        return JSON.serialize(u);
    }

    @AuraEnabled
    public static void setShowDeleteTaskDialogAura() {
        ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
        
        preferences.ShowDeleteTaskDialog__c = false;
        
        upsert preferences;
    }

    @RemoteAction
    global static Boolean changeTaskStatusToInProgress(Id taskId) {
        return changeTaskStatusTo(taskId, 'In Progress');
    }

    @RemoteAction
    global static Boolean changeTaskStatusToPlanned(Id taskId) {
        return changeTaskStatusTo(taskId, 'Not Started');
    }

    @RemoteAction
    global static Boolean changeTaskStatusToCompleted(Id taskId) {
        return changeTaskStatusTo(taskId, 'Completed');
    }


    /**
     * Utility function for changing the status of a task to the specified value
     */
     @RemoteAction
    global static Boolean changeTaskStatusTo(Id taskId, String statusValue) {
        ADM_Task__c t = [select Id, Status__c from ADM_Task__c where Id = :taskId limit 1];
        if (t != null) {
            t.Status__c = statusValue;
            update t;
        }
        return true;
    }

    /**
     * Lightweight object sent when a client wants to get the order of the tasks
     * associated to a work item (using #getTaskOrder).
     */
    global class TaskOrderResponse {
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

}