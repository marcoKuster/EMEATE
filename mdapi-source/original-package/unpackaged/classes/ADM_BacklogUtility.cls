public with sharing class ADM_BacklogUtility {

    private static final Integer DEFAULT_PANEL_ROW_COUNT = 200;
    private static final String SELECT_FROM_TASK_RELATIONSHIP = 'select Work__c, Subject__c, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.SmallPhotoUrl, Status__c, Hours_Remaining__c, Order__c from Tasks__r order by Work__c, Status__c, Order__c NULLS LAST';
    private static final String SELECT_FROM_WORK = 'select Id, CreatedDate, LastModifiedDate, RecordType.Name, RecordTypeId, Name, Subject__c, Feature_Rank__c, Trust_Rank__c, Theme_Rank__c, Priority_Rank__c, Scheduled_Build_Rank__c, Priority__c, Story_Points__c, Status__c, Sprint__c, Sprint__r.Id, Sprint__r.Name, Sprint_Rank__c,Backburner_Rank__c, Scheduled_Build__c,Found_in_Build__c, Epic__c, Epic_Rank__c, Epic__r.Name, Color__c, Color__r.Name, Column__c, Column__r.Name, Product_Tag__c, Product_Tag__r.Name, Scheduled_Build__r.Name, Found_In_Build__r.Name, QA_Engineer__c, QA_Engineer__r.Name, QA_Engineer__r.UserName, QA_Engineer__r.SmallPhotoUrl, Product_Owner__c, Product_Owner__r.Name, Product_Owner__r.UserName, Product_Owner__r.SmallPhotoUrl, Assignee__c, Assignee__r.Name, Assignee__r.UserName, Assignee__r.SmallPhotoUrl, (' + SELECT_FROM_TASK_RELATIONSHIP + '), (select Theme__c, Theme__r.Id, Theme__r.Name from Theme_Assignments__r order by Theme__r.Name) from ADM_Work__c ';
    private static final String WHERE_CONDITION = 'Closed__c = 0 and (RecordType.Name = \'Investigation\' or RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';
    @TestVisible
    private static final String BACKLOG = 'backlog';
    private static final String BACKBURNER = 'backburner';
    private static final String FEATUREBACKLOG = 'featureBacklog';

    private static final String TRUSTBACKLOG = 'trustBacklog';
    private static final String SPRINTBACKLOG = 'sprint';
    private static final String THEMEBACKLOG = 'theme';
    private static final String EPICBACKLOG = 'epic';
    private static final String BUILDBACKLOG = 'build';
    private static final String PRODUCTTAGBACKLOG = 'producttag';


    public static ADM_BacklogController.BackLogManagerResponse getPanelWorkItemsByType(ADM_BacklogController.QueryParameters queryParameters, String type, Boolean isReactCall, Integer numberOfRows, Integer offset){
        ADM_BacklogController.BackLogManagerResponse backlogManagerResponse = new ADM_BacklogController.BackLogManagerResponse();
        BacklogManagerPanel panelType;
        String teamId = queryParameters.teamId;
        String sprintId = queryParameters.sprintId;
        if(type != null){
            if(type.equalsIgnoreCase(BACKLOG)){
                panelType = new BacklogPanel();
            }
            else if(type.equalsIgnoreCase(BACKBURNER)){
                panelType = new BackBurnerPanel();
            }
            else if(type.equalsIgnoreCase(FEATUREBACKLOG)){
                panelType = new FeatureBacklogPanel();
            }
            else if(type.equalsIgnoreCase(TRUSTBACKLOG)){
                panelType = new TrustBacklogPanel();
            }
            else if(type.equalsIgnoreCase(SPRINTBACKLOG)){
                panelType = new SprintBacklogPanel();
            }
            else if(type.equalsIgnoreCase(EPICBACKLOG)){
                panelType = new EpicBacklogPanel();
            }
            else if(type.equalsIgnoreCase(THEMEBACKLOG)){
                panelType = new ThemeBacklogPanel();
            }
            else if(type.equalsIgnoreCase(BUILDBACKLOG)){
                panelType = new ScheduledBuildBacklogPanel();
            }
            else if(type.equalsIgnoreCase(PRODUCTTAGBACKLOG)){
                panelType = new ProductTagPanel();
            }
            /*
            else if(type.equalsIgnoreCase(THEMEBACKLOG)){
                panelType = new ThemeBacklogPanel();
            }*/
        }
        List<ADM_Work__c> panelWorks = panelType.getWorkItems(queryParameters, isReactCall, numberOfRows, offset);
        if(panelWorks != null && panelWorks.size() > 0){
            backlogManagerResponse.records = panelWorks;
            backlogManagerResponse.numberOfRecords = panelWorks.size();
        }
        else{
            //  if(type.equalsIgnoreCase(SPRINTBACKLOG)){
                  panelType = new BacklogPanel();
                  panelWorks = panelType.getWorkItems(queryParameters, isReactCall, numberOfRows, offset);
                  if(panelWorks != null && panelWorks.size() > 0){
                      backlogManagerResponse.records = panelWorks;
                      backlogManagerResponse.numberOfRecords = panelWorks.size();
                      backlogManagerResponse.defaultView = true;
                  }
            //  }
        }
        ADM_BacklogDataExtractor.extractAndSortData(backlogManagerResponse);
        return backlogManagerResponse;
    }

    public interface BacklogManagerPanel {
     List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset);

    }

    public class BacklogPanel implements BacklogManagerPanel {
        List<ADM_Work__c> backLogWorkItems;
        String whereClause = WHERE_CONDITION;
        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String teamId = parameters.teamId;
            whereClause += 'and Scrum_Team__c = :teamId ';
            if(!isReactCall){
              whereClause += 'and Priority_Rank__c != null ';
            }
            //whereClause += 'and Use_Prioritizer__c = true ';
            //whereClause += 'and Priority_Rank__c != null ';
            //setUserPreferenceForSprintToggle(hideWorkWithSprint); //This method sets the User preference for BacklogHideWorkWithSprintToggle based on what the user clicks on the UW.
            String orderClause = 'Priority_Rank__c nulls last, CreatedDate, Id desc ';
            backLogWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return backLogWorkItems;
        }

    }

    public class BackBurnerPanel implements BacklogManagerPanel {
        List<ADM_Work__c> backBurnerWorkItems;
        String whereClause = WHERE_CONDITION;
        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String teamId = parameters.teamId;
            whereClause += 'and Scrum_Team__c = :teamId ';
            //whereClause += 'and Use_Prioritizer__c = true ';
            whereClause += 'and Priority_Rank__c = null ';

            String orderClause = 'Backburner_Rank__c nulls last, CreatedDate desc, Id desc';
            backBurnerWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return backBurnerWorkItems;
        }

    }

    public class FeatureBacklogPanel implements BacklogManagerPanel {
        List<ADM_Work__c> featureBacklogWorkItems;
        String whereClause = 'Closed__c = 0 ';
        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String teamId = parameters.teamId;
            whereClause += 'and RecordType.Name = \'User Story\' ';
            whereClause += 'and Scrum_Team__c = :teamId ';
            //whereClause += 'and Use_Prioritizer__c = true ';
            whereClause += 'and Priority_Rank__c != null ';
            whereClause += 'and Id not in (select Work__c from ADM_Theme_Assignment__c where Theme__r.Name = \'Trust\' and Theme__r.Scrum_Team__c = null) ';
            //Changing order to Backlog rank instead of Featurebacklog rank as suggested by Chad
            String orderClause = 'Priority_Rank__c asc nulls last, Priority_Rank__c nulls last, CreatedDate, Id desc';
            featureBacklogWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return featureBacklogWorkItems;
        }

    }

    public class TrustBacklogPanel implements BacklogManagerPanel {
        List<ADM_Work__c> trustBacklogWorkItems;
        String whereClause = WHERE_CONDITION;
        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String teamId = parameters.teamId;
            whereClause += 'and Scrum_Team__c = :teamId ';
            //whereClause += 'and Use_Prioritizer__c = true ';
            whereClause += 'and Priority_Rank__c != null ';
            whereClause += 'and Id in (select Work__c from ADM_Theme_Assignment__c where Theme__r.Name = \'Trust\' and Theme__r.Scrum_Team__c = null) ';

            //Changing order to Backlog rank instead of Trust rank as suggested by Chad
            String orderClause = 'Priority_Rank__c asc nulls last, Priority_Rank__c nulls last, CreatedDate, Id desc';

            trustBacklogWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return trustBacklogWorkItems;
        }

    }

    public class SprintBacklogPanel implements BacklogManagerPanel {
        List<ADM_Work__c> sprintBacklogWorkItems;
        String whereClause = '(RecordType.Name = \'User Story\' or RecordType.Name = \'Bug\' or RecordType.Name = \'ToDo\') ';

        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String sprintId = '';
            if(parameters.sprintId != null && parameters.sprintId.length() > 0){
              sprintId = parameters.sprintId;
            }
            else{
              sprintId = parameters.paramId;
            }
            if(ADM_TextUtils.isBlank(sprintId)) {
        		throw new ADM_ApplicationException('No sprintId was found in parameters.');
    		}
            whereClause += 'and Sprint__c = :sprintId ';
            //Changing order to Backlog rank instead of sprint rank as suggested by Chad
            String orderClause = 'Priority_Rank__c asc nulls last, CreatedDate asc, Id desc ';
            System.debug(' sprint id ' + sprintId);
            System.debug(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            sprintBacklogWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return sprintBacklogWorkItems;
        }
    }

    public class EpicBacklogPanel implements BacklogManagerPanel {
        List<ADM_Work__c> epicBacklogWorkItems;
        String whereClause = WHERE_CONDITION;

        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String epicId = parameters.paramId;
            whereClause += 'and Epic__c = :epicId ';
            String teamId = parameters.teamId;
            whereClause += 'and Scrum_Team__c = :teamId ';
            //Changing order to Backlog rank instead of Epic rank as suggested by Chad
            String orderClause = 'Priority_Rank__c asc nulls last, Priority_Rank__c asc nulls last, CreatedDate asc, Id desc ';
            System.debug(' query '+ buildListQuery(whereClause, orderClause, numberOfRows, offset));
            epicBacklogWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return epicBacklogWorkItems;
        }
    }

    public class ThemeBacklogPanel implements BacklogManagerPanel {
        List<ADM_Work__c> themeBacklogWorkItems;
        String whereClause = WHERE_CONDITION;
        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String themeId = parameters.paramId;
            String teamId = parameters.teamId;
            whereClause += 'and Scrum_Team__c = :teamId ';
            whereClause += 'and Id in (select Work__c from ADM_Theme_Assignment__c where Theme__c = :themeId) ';
            String orderClause = 'Priority_Rank__c asc nulls last, CreatedDate, Id desc';

            themeBacklogWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return themeBacklogWorkItems;
        }

    }

    public class ScheduledBuildBacklogPanel implements BacklogManagerPanel {
        List<ADM_Work__c> scheduledBuildBacklogWorkItems;
        String whereClause = WHERE_CONDITION;
        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String buildId = parameters.paramId;
            String teamId = parameters.teamId;
            whereClause += 'and Scrum_Team__c = :teamId ';
            whereClause += 'and Scheduled_Build__c = :buildId ';

            String orderClause = 'Priority_Rank__c asc nulls last, Priority_Rank__c nulls last, CreatedDate, Id desc';
            System.debug(' buildId '+ buildId + ' team id '+ teamId);
            System.debug(' query '+ buildListQuery(whereClause, orderClause, numberOfRows, offset));
            scheduledBuildBacklogWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return scheduledBuildBacklogWorkItems;
        }

    }

    public class ProductTagPanel implements BacklogManagerPanel {
        List<ADM_Work__c> productTagWorkItems;
        String whereClause = WHERE_CONDITION;
        public List<ADM_Work__c> getWorkItems(ADM_BacklogController.QueryParameters parameters, Boolean isReactCall, Integer numberOfRows, Integer offset) {
            String tagId = parameters.paramId;
            String teamId = parameters.teamId;
            whereClause += 'and Scrum_Team__c = :teamId ';
            whereClause += 'and Product_Tag__c = :tagId ';

            String orderClause = 'Priority_Rank__c asc nulls last, Priority_Rank__c nulls last, CreatedDate, Id desc';
            System.debug(' tagId '+ tagId + ' team id '+ teamId);
            System.debug(' query '+ buildListQuery(whereClause, orderClause, numberOfRows, offset));
            productTagWorkItems = Database.query(buildListQuery(whereClause, orderClause, numberOfRows, offset));
            return productTagWorkItems;
        }

    }




    private static String buildListQuery(String whereClause, String orderClause, Integer numberOfRows, Integer offset) {
        String soql = SELECT_FROM_WORK;

        //add the where clause
        if(whereClause != null && whereClause.length() > 0) {
            soql += ' where ' + whereClause + ' ';
        }

        //add the order clause
        if(orderClause != null && orderClause.length() > 0) {
            soql += ' order by ' + orderClause + ' ';
        }

        soql += limitClause(numberOfRows) + ' ';
        soql += offsetClause(offset);

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

    public static List<ADM_BacklogController.BackLogColumn> getDefaultBackLogColumns() {
        List<ADM_BacklogController.BacklogColumn> columns = new List<ADM_BacklogController.BacklogColumn>();

        ADM_BacklogController.BacklogColumn id = new ADM_BacklogController.BacklogColumn();
        id.label = 'ID';
        columns.add(id);

        ADM_BacklogController.BacklogColumn recordType = new ADM_BacklogController.BacklogColumn();
        recordType.label = 'Record Type';
        columns.add(recordType);

        ADM_BacklogController.BacklogColumn rank = new ADM_BacklogController.BacklogColumn();
        rank.label = 'Rank';
        rank.direction = 'descending';
        columns.add(rank);

        ADM_BacklogController.BacklogColumn subject = new ADM_BacklogController.BacklogColumn();
        subject.label = 'Subject';
        columns.add(subject);

        ADM_BacklogController.BacklogColumn status = new ADM_BacklogController.BacklogColumn();
        status.label = 'Status';
        columns.add(status);

        ADM_BacklogController.BacklogColumn sprint = new ADM_BacklogController.BacklogColumn();
        sprint.label = 'Sprint';
        columns.add(sprint);

        ADM_BacklogController.BacklogColumn assignee = new ADM_BacklogController.BacklogColumn();
        assignee.label = 'Assignee';
        columns.add(assignee);

        ADM_BacklogController.BacklogColumn points = new ADM_BacklogController.BacklogColumn();
        points.label = 'Points';
        columns.add(points);

        return columns;
    }

        public static List<ADM_BacklogController.BackLogColumn> getAllBackLogColumns() {
        List<ADM_BacklogController.BacklogColumn> columns = new List<ADM_BacklogController.BacklogColumn>();

        ADM_BacklogController.BacklogColumn id = new ADM_BacklogController.BacklogColumn();
        id.link = 'work.Id';
        id.label = 'ID';
        id.value = 'work.Name';
        id.showLabel = true;
        id.sortable = true;
        id.groupable = false;
        id.required = true;
        id.draggable = false;
        id.filterable = false;
        id.editable = false;
        columns.add(id);

        ADM_BacklogController.BacklogColumn recordType = new ADM_BacklogController.BacklogColumn();
        recordType.id = 'work.RecordTypeId';
        recordType.label = 'Record Type';
        recordType.value = 'work.RecordType.Name';
        recordType.showLabel = false;
        recordType.sortable = true;
        recordType.groupable = true;
        recordType.required = true;
        recordType.draggable = false;
        recordType.filterable = true;
        recordType.editable = false;
        columns.add(recordType);

        ADM_BacklogController.BacklogColumn rank = new ADM_BacklogController.BacklogColumn();
        rank.label = 'Rank';
        rank.value = 'work.Priority_Rank__c';
        rank.showLabel = true;
        rank.sortable = true;
        rank.groupable = false;
        rank.required = true;
        rank.direction = 'descending';
        rank.draggable = true;
        rank.filterable = false;
        rank.editable = false;
        columns.add(rank);

        ADM_BacklogController.BacklogColumn subject = new ADM_BacklogController.BacklogColumn();
        subject.label = 'Subject';
        subject.value = 'work.Subject__c';
        subject.link = 'work.Id';
        subject.showLabel = true;
        subject.sortable = true;
        subject.groupable = false;
        subject.required = true;
        subject.truncate = false;
        subject.style = 'min-width:300px;';
        subject.draggable = true;
        subject.filterable = false;
        subject.editable = false;
        columns.add(subject);

        ADM_BacklogController.BacklogColumn status = new ADM_BacklogController.BacklogColumn();
        status.label = 'Status';
        status.value = 'work.Status__c';
        status.showLabel = true;
        status.sortable = true;
        status.groupable = true;
        status.draggable = true;
        status.filterable = true;
        status.editable = true;
        status.editType = 'select';
        columns.add(status);

        ADM_BacklogController.BacklogColumn sprint = new ADM_BacklogController.BacklogColumn();
        sprint.id = 'work.Sprint__c';
        sprint.label = 'Sprint';
        sprint.value = 'work.Sprint__r.Name';
        sprint.link = 'work.Sprint__c';
        sprint.showLabel = true;
        sprint.sortable = true;
        sprint.groupable = true;
        sprint.draggable = true;
        sprint.filterable = true;
        sprint.editable = true;
        sprint.editType = 'input';
        columns.add(sprint);

        ADM_BacklogController.BacklogColumn kanbanColumn = new ADM_BacklogController.BacklogColumn();
        kanbanColumn.id = 'work.Column__c';
        kanbanColumn.label = 'Kanban State';
        kanbanColumn.value = 'work.Column__r.Name';
        kanbanColumn.showLabel = true;
        kanbanColumn.sortable = true;
        kanbanColumn.groupable = true;
        kanbanColumn.draggable = true;
        kanbanColumn.filterable = true;
        kanbanColumn.editable = false;
        columns.add(kanbanColumn);

        ADM_BacklogController.BacklogColumn assignee = new ADM_BacklogController.BacklogColumn();
        assignee.id = 'work.Assignee__c';
        assignee.label = 'Assignee';
        assignee.value = 'work.Assignee__r.Name';
        assignee.showLabel = true;
        assignee.sortable = true;
        assignee.groupable = true;
        assignee.link = 'work.Assignee__c';
        assignee.smallPhotoUrl = 'work.Assignee__r.SmallPhotoUrl';
        assignee.draggable = true;
        assignee.filterable = true;
        assignee.editable = true;
        assignee.editType = 'input';
        columns.add(assignee);

        ADM_BacklogController.BacklogColumn qa = new ADM_BacklogController.BacklogColumn();
        qa.id = 'work.QA_Engineer__c';
        qa.label = 'QA Engineer';
        qa.value = 'work.QA_Engineer__r.Name';
        qa.showLabel = true;
        qa.sortable = true;
        qa.groupable = true;
        qa.link = 'work.QA_Engineer__c';
        qa.smallPhotoUrl = 'work.QA_Engineer__r.SmallPhotoUrl';
        qa.draggable = true;
        qa.filterable = true;
        qa.editable = true;
        qa.editType = 'input';
        columns.add(qa);

        ADM_BacklogController.BacklogColumn productTag = new ADM_BacklogController.BacklogColumn();
        productTag.id = 'work.Product_Tag__c';
        productTag.label = 'Product Tag';
        productTag.value = 'work.Product_Tag__r.Name';
        productTag.showLabel = true;
        productTag.sortable = true;
        productTag.groupable = true;
        productTag.link = 'work.Product_Tag__c';
        productTag.draggable = false;
        productTag.filterable = true;
        productTag.editable = false;
        columns.add(productTag);

        ADM_BacklogController.BacklogColumn points = new ADM_BacklogController.BacklogColumn();
        points.label = 'Points';
        points.value = 'work.Story_Points__c';
        points.showLabel = true;
        points.sortable = true;
        points.groupable = true;
        points.draggable = true;
        points.filterable = true;
        points.editable = true;
        points.editType = 'input';
        columns.add(points);

        ADM_BacklogController.BacklogColumn epic = new ADM_BacklogController.BacklogColumn();
        epic.id = 'work.Epic__c';
        epic.label = 'Epic';
        epic.value = 'work.Epic__r.Name';
        epic.showLabel = true;
        epic.sortable = true;
        epic.groupable = true;
        epic.link = 'work.Epic__c';
        epic.draggable = true;
        epic.filterable = true;
        epic.editable = true;
        epic.editType = 'input';
        columns.add(epic);

        ADM_BacklogController.BacklogColumn priority = new ADM_BacklogController.BacklogColumn();
        priority.id = 'work.Priority__c';
        priority.label = 'Priority';
        priority.value = 'work.Priority__c';
        priority.showLabel = true;
        priority.sortable = true;
        priority.groupable = true;
        priority.draggable = true;
        priority.filterable = false;
        priority.editable = false;
        columns.add(priority);

        ADM_BacklogController.BacklogColumn foundInBuild = new ADM_BacklogController.BacklogColumn();
        foundInBuild.id = 'work.Found_in_Build__c';
        foundInBuild.label = 'Found In Build';
        foundInBuild.value = 'work.Found_in_Build__r.Name';
        foundInBuild.showLabel = true;
        foundInBuild.sortable = true;
        foundInBuild.groupable = true;
        foundInBuild.link = 'work.Found_in_Build__c';
        foundInBuild.draggable = true;
        foundInBuild.filterable = true;
        foundInBuild.editable = true;
        foundInBuild.editType = 'input';
        columns.add(foundInBuild);

        ADM_BacklogController.BacklogColumn scheduledBuild = new ADM_BacklogController.BacklogColumn();
        scheduledBuild.id = 'work.Scheduled_Build__c';
        scheduledBuild.label = 'Scheduled Build';
        scheduledBuild.value = 'work.Scheduled_Build__r.Name';
        scheduledBuild.showLabel = true;
        scheduledBuild.sortable = true;
        scheduledBuild.groupable = true;
        scheduledBuild.link = 'work.Scheduled_Build__c';
        scheduledBuild.draggable = true;
        scheduledBuild.filterable = true;
        scheduledBuild.editable = true;
        scheduledBuild.editType = 'input';
        columns.add(scheduledBuild);

        ADM_BacklogController.BacklogColumn productOwner = new ADM_BacklogController.BacklogColumn();
        productOwner.id = 'work.Product_Owner__c';
        productOwner.label = 'Product Owner';
        productOwner.value = 'work.Product_Owner__r.Name';
        productOwner.showLabel = true;
        productOwner.sortable = true;
        productOwner.groupable = true;
        productOwner.link = 'work.Product_Owner__c';
        productOwner.smallPhotoUrl = 'work.Product_Owner__r.SmallPhotoUrl';
        productOwner.draggable = true;
        productOwner.filterable = false;
        productOwner.editable = true;
        productOwner.editType = 'input';
        columns.add(productOwner);

        ADM_BacklogController.BacklogColumn createdDate = new ADM_BacklogController.BacklogColumn();
        createdDate.id = 'work.CreatedDate';
        createdDate.label = 'Created Date';
        createdDate.value = 'work.CreatedDate';
        createdDate.showLabel = true;
        createdDate.sortable = true;
        createdDate.groupable = true;
        createdDate.draggable = true;
        createdDate.filterable = false;
        createdDate.editable = false;
        columns.add(createdDate);

        ADM_BacklogController.BacklogColumn lastModifiedDate = new ADM_BacklogController.BacklogColumn();
        lastModifiedDate.id = 'work.LastModifiedDate';
        lastModifiedDate.label = 'Modified Date';
        lastModifiedDate.value = 'work.LastModifiedDate';
        lastModifiedDate.showLabel = true;
        lastModifiedDate.sortable = true;
        lastModifiedDate.groupable = true;
        lastModifiedDate.draggable = true;
        lastModifiedDate.filterable = false;
        lastModifiedDate.editable = false;
        columns.add(lastModifiedDate);

        return columns;
    }

    public static List<ADM_Product_Tag__c> getActiveProductTagsForTeam(Id teamId) {
        List<ADM_Product_Tag__c> tags = new List<ADM_Product_Tag__c>();
        try {
            tags = [select id, Name, Team__c from ADM_Product_Tag__c where Team__c = :teamId];
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception retrieving product tags e:' + e + ' teamId:' + teamId);
        }
        return tags;
    }

    public static List<ADM_Scrum_Team_Member__c> getTeamMembersForTeam(Id teamId) {
        List<ADM_Scrum_Team_Member__c> members = new List<ADM_Scrum_Team_Member__c>();
        try {
           members = [select Member_Name__r.Id, Member_Name__r.Username, Member_Name__r.Name from ADM_Scrum_Team_Member__c where Scrum_Team__c =:teamId];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception retrieving members e:' + e + ' teamId:' + teamId);
        }
        return members;
    }

    public static List<User> getUsersForTeam(Id teamId) {
        List<Id> userIds = new List<Id>();
        List<User> users = new List<User>();
        try {
            List<ADM_Scrum_Team_Member__c> members = ADM_BacklogUtility.getTeamMembersForTeam(teamId);
            for(ADM_Scrum_Team_Member__c member:members) {
                userIds.add(member.Member_Name__r.Id);
            }
            users = [select id, name, username, smallphotourl from User where id in:userIds];
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception retrieving users e:' + e + ' teamId:' + teamId);
        }
        return users;

    }

    public static List<ADM_ColumnUtility.LeafNodeDetails> getColumnsForTeamWithPathInfo(Id teamId) {
        List<ADM_ColumnUtility.LeafNodeDetails> columnsWithPath = new List<ADM_ColumnUtility.LeafNodeDetails>();
        try {
            //List<ADM_Column> columns = ADM_ColumnUtility.makeADM_ColumnListFromColumnSObjectList;
            List<ADM_Column>  admColumns = ADM_ColumnUtility.getRootParentColumns(ADM_ColumnQueryUtils.getColumnsByTeam(teamId));
            Set<String> closedColumnIds = ADM_ColumnUtility.getKanbanClosedColumns(teamId);
            columnsWithPath = ADM_KanbanUtility.getLeafColumnsWithPathInfo(admColumns, closedColumnIds);
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception retrieving columns e:' + e + ' teamId:' + teamId);
        }
        return columnsWithPath;
    }

     public static List<ADM_Sprint__c> getCurrentSprintsForTeam(Id teamId) {
        List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        try {
            sprints = [select id, Name, Start_Date__c, End_Date__c, Completed_Story_Points__c from ADM_Sprint__c where End_Date__c >= :System.today() and Scrum_Team__c = :teamId order by Start_Date__c];
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception retrieving sprints e:' + e + ' teamId:' + teamId);
        }
        return sprints;
    }
     public static List<ADM_Sprint__c> getOldSprintsForTeam(Id teamId) {
        List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        try {
            sprints = [select id, Name, Start_Date__c, End_Date__c, Completed_Story_Points__c from ADM_Sprint__c where End_Date__c < :System.today() and Scrum_Team__c = :teamId order by Start_Date__c desc limit 10];
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception retrieving sprints e:' + e + ' teamId:' + teamId);
        }
        return sprints;
    }

    public static List<ADM_Work_Status__c> getWorkStatuses() {
        return [select id, Name, Order__c, Type__c from ADM_Work_Status__c where Type__c != null order by Order__c, Name];
    }

    public static ADM_Scrum_Team__c getTeam(Id teamId) {
        return [select id, name, story_point_scale__c, Kanban__c from ADM_Scrum_Team__c where id =:teamId];
    }

    public static ADM_Chart getSprintChart(String sprintId) {
        return getSprintChart(sprintId, 'Story Points');
    }

    public static ADM_Chart getSprintChart(String sprintId, String dataType) {
      List<ADM_Sprint__c> sprints = ADM_Sprint.getSprintsDetailsById(new List<String>{sprintId});
      ADM_Sprint__c sprint = sprints[0];
      ADM_SprintBurnDownUtils utils = new ADM_SprintBurnDownUtils();
      ADM_SprintBurnDownUtils.ActualSprintData actualSprintData = utils.getSprintRealBurnDownItems(sprint, dataType);
        Map<Date, Double> sprintRealBurnDownMap;
        Map<Date, Double> sprintIdealBurnDownMap;

        if (dataType == 'Story Points') {
            sprintRealBurnDownMap = actualSprintData.getSprintIdToTotalPoints();
            sprintIdealBurnDownMap = utils.getSprintIdealBurnDownItems(sprint, 'Points');
            System.debug('sprintIdealBurnDownMap: ' + sprintIdealBurnDownMap);
        } else if (dataType == 'Task Hours') {
            sprintRealBurnDownMap = actualSprintData.getSprintIdToTaskHours();
            sprintIdealBurnDownMap = utils.getSprintIdealBurnDownItems(sprint, 'Hours');
        }

      ADM_Chart sprintBurnDownChart = null;
      if((sprintIdealBurnDownMap != null && !sprintIdealBurnDownMap.isEmpty()) || (sprintRealBurnDownMap != null && !sprintRealBurnDownMap.isEmpty())){
        sprintBurnDownChart = new ADM_Chart('Burn Down', 'Sprint');
        ADM_Chart.YAxis yAxis = new ADM_Chart.YAxis(dataType);
        ADM_Chart.XAxis xAxis = new ADM_Chart.XAxis('Day');
        if(actualSprintData.getFutureIndex() != 0){
          xAxis.setFutureIndex(actualSprintData.getFutureIndex());
        }

        sprintBurnDownChart.setYAxis(yAxis);
        sprintBurnDownChart.setXAxis(xAxis);

        //Ideal Burndown
        if(sprintIdealBurnDownMap != null && !sprintIdealBurnDownMap.isEmpty()){
          ADM_Chart.Series idealSeries = new ADM_Chart.Series('Ideal Burndown');
          List<Object> data = new List<Object>();
          List<Object> categories = new List<Object>();

          List<Date> dateKeyList = new List<Date>(sprintIdealBurnDownMap.keySet());
          dateKeyList.sort();

          for(Date key: dateKeyList){
            categories.add(key.day());
            data.add(sprintIdealBurnDownMap.get(key));
          }
          xAxis.setCategories(categories);
          idealSeries.setData(data);
          sprintBurnDownChart.getSeriesList().add(idealSeries);
        }

        //Real Burndown
        ADM_Chart.Series realSeries = new ADM_Chart.Series('Real Burndown');
        if(sprintRealBurnDownMap != null && !sprintRealBurnDownMap.isEmpty()){

          List<Object> data = new List<Object>();

          List<Date> dateKeyList = new List<Date>(sprintRealBurnDownMap.keySet());
          dateKeyList.sort();

          for(Date key: dateKeyList){
            data.add(sprintRealBurnDownMap.get(key));
          }
          realSeries.setData(data);

        }
        sprintBurnDownChart.getSeriesList().add(realSeries);//Adding empty series so high chart won't fail with null pointer - Since Data is empty Real line won't be displayed.
      }
      return sprintBurnDownChart;
    }
}