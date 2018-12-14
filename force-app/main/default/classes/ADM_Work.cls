public class ADM_Work {
    private static Map<String, WorkType> workTypesByRecordTypeName = new Map<String, WorkType>();
    private static final String WORK_FIELD_NAMES = 'a.Due_Date__c, a.Account__c, a.Account__r.Name, a.Email2GUS_Addresses__c, a.Details__c, a.Test_Plan__c, a.Product_Tag_Name__c, a.Scrum_Team_Name__c, a.Sprint_Name__c, a.Found_In_Build_Name__c, a.Scheduled_Build_Name__c, a.Number_of_Change_Lists__c,a.Attributes__c, a.Executive_Involved__c,a.Severity_Level__c,a.Request_RD_Mgr_Review__c,a.Critical_CRM_Feature__c,a.Red_Account__c,a.Deal_at_Risk__c,a.Estimated_Financial_Impact__c,a.Details_and_Steps_to_Reproduce__c, a.Senior_Management_POC__c, a.CS_Contact__c, a.Num_Of_Prod_Occ__c, a.Scrumforce_ID__c, a.Budget_ID__c, a.Record_Type__c, a.Additional_Details__c,a.Use_Prioritizer__c,a.User_Type__c,a.Story_Points__c,a.Priority_Rank__c,a.Theme__c, a.Sprint__c, a.Last_Modified_By_Copy__c,a.Last_Modified_By__c,a.Priority_Mapping__c,a.Priority_Mapping_Copy__c,a.Priority_Default__c,Priority_Override_Explanation_Copy__c,a.Priority_Override_Explanation__c,a.Frequency__c, a.Impact__c, a.Impact__r.Name, a.Preserve_Formatting__c, a.Preserve_Formatting_Copy__c, a.Scheduled_Build_Copy__c, a.Found_In_Build_Copy__c,a.Root_Cause_Analysis_2__c, a.Number_of_Cases__c, a.ftest__c, a.Type__c, a.Template_Name__c, a.Template_Description__c, a.Tech_Writer__c, a.System_Test_Engineer__c, a.UE_Engineer__c, a.SystemModstamp, a.Subscribe_to_Work__c, a.Subject__c, a.Status__c, a.Security__c, a.Scrum_Team__c, a.Schema__c, a.Scheduled_On__c, a.Scheduled_Build__c, a.Resolved__c, a.Resolved_On__c, a.Resolved_By__c, a.Related_URL__c, a.Regressed__c, a.RecordType.Name, a.RecordType.Id,a.RecordTypeId, a.QA_Engineer__c, a.Product_Owner__c, a.Product_Child__c, a.Product_Area__c, a.Priority__c, a.Perforce_Status__c, a.Parent_ID__c, a.OwnerId, a.Name, a.Minor_Func_Area__c, a.Major_Func_Area__c, a.Last_Updated_By__c, a.LastModifiedDate, a.LastModifiedById, a.Is_Template__c, a.Is_Ignorable__c, a.IsDeleted, a.Id, a.Help_Status__c, a.Found_in_Build__c, a.External_ID__c, a.Email_Subscription_ID__c, a.Email_On_Save__c, a.Email_On_Save_Copy__c, a.Description__c, a.Customer__c, a.Created_On_import__c, a.CreatedById, a.Complete_By__c, a.Comment_Copy__c, a.Closed__c, a.Closed_On__c, a.Closed_By__c, a.Bug_Number__c, a.Assignee__c, a.Assigned_On__c, a.Age__c, a.Age_With_Scrum_Team__c, a.Age_With_Scrum_Team_When_Closed__c, a.of_Test_Failures__c, a.Encoded_Recipients_Txt_Area__c, a.Product_Tag__c, a.Test_Failure_Status__c, a.Readme_Notes__c, a.visual_link_num_of_Test_Failures__c,' +
                                                    'a.Resolution__c, a.Assignee__r.SmallPhotoUrl, a.QA_Engineer__r.SmallPhotoUrl, a.Product_Owner__r.SmallPhotoUrl, a.Tech_Writer__r.SmallPhotoUrl, a.Column__c, a.Column__r.Id, a.Column__r.Name, a.Color__c, a.Color__r.Name, a.Color__r.Color__c, a.Capex_Enabled__c';
    private static final String BASIC_WORK_FIELD_NAMES = 'a.CreatedBy.Name, a.CreatedDate, a.LastModifiedBy.Name, a.Due_Date__c, a.Account__c, a.Account__r.Name, a.Details__c, a.Number_of_Change_Lists__c, a.Executive_Involved__c,a.Severity_Level__c,a.Request_RD_Mgr_Review__c,a.Critical_CRM_Feature__c,a.Red_Account__c,a.Deal_at_Risk__c,a.Estimated_Financial_Impact__c,a.Details_and_Steps_to_Reproduce__c, a.Senior_Management_POC__c, a.CS_Contact__c, a.Num_Of_Prod_Occ__c, a.Record_Type__c, a.Additional_Details__c,a.Story_Points__c,a.Priority_Rank__c, a.Sprint__c, a.Frequency__c, a.Impact__c, a.Root_Cause_Analysis_2__c, a.Number_of_Cases__c, a.ftest__c, a.Type__c, a.Tech_Writer__c, a.System_Test_Engineer__c, a.UE_Engineer__c, a.Subject__c, a.Status__c, a.Security__c, a.Scrum_Team__c, a.Schema__c, a.Scheduled_On__c, a.Scheduled_Build__c, a.Related_URL__c, a.RecordType.Name, a.RecordType.Id,a.RecordTypeId, a.QA_Engineer__c, a.Product_Owner__c, a.Priority__c, a.Perforce_Status__c, a.Name, a.LastModifiedDate, a.LastModifiedById, a.Id, a.Help_Status__c, a.Found_in_Build__c, a.Description__c, a.Customer__c, a.CreatedById, a.Assignee__c, a.of_Test_Failures__c, a.Product_Tag__c, a.Test_Failure_Status__c, a.Readme_Notes__c, a.Resolution__c, a.Capex_Enabled__c';

    private static final String WORK_UPDATEABLE_FIELD_NAMES = 'Due_Date__c,Account__c,Account__r.Name,Severity_Level__c,Number_of_Cases__c,Executive_Involved__c,CS_Contact__c,Request_RD_Mgr_Review__c,Red_Account__c,Deal_at_Risk__c,Senior_Management_POC__c,Estimated_Financial_Impact__c,Minor_Func_Area__c,Critical_CRM_Feature__c,Details__c, Details_and_Steps_to_Reproduce__c, Story_Points__c, Sprint__c, Frequency__c, Impact__c, Root_Cause_Analysis_2__c, ftest__c, Subject__c, Status__c, Scrum_Team__c, Scheduled_Build__c, QA_Engineer__c, Product_Owner__c, Tech_Writer__c, Readme_Notes__c, Help_Status__c, Priority__c, Perforce_Status__c, Parent_ID__c, Found_in_Build__c, Description__c, Assignee__c, of_Test_Failures__c, Product_Tag__c, Test_Failure_Status__c, Customer__c, Priority_Rank__c, Use_Prioritizer__c, UE_Engineer__c, System_Test_Engineer__c, Type__c, Resolution__c, Capex_Enabled__c';
    private static final String RELATED_WORK_FIELD_NAMES = 'a.LastModifiedBy.Name, a.Product_Tag__r.Name, a.Test_Plan__r.Name, a.Scrum_Team__r.Name, a.Sprint__r.Name, a.Theme__r.Id, a.Theme__r.Name, a.Root_Cause_Analysis_2__r.Name, a.Tech_Writer__r.Email, a.Tech_Writer__r.Name, a.Tech_Writer__r.Username, a.UE_Engineer__r.Email, a.UE_Engineer__r.Name, a.UE_Engineer__r.Username, a.System_Test_Engineer__r.Email, a.System_Test_Engineer__r.Name, a.System_Test_Engineer__r.Username, a.Scheduled_Build__r.Name, a.QA_Engineer__r.Email,a.QA_Engineer__r.Name, a.QA_Engineer__r.Username, a.Product_Owner__r.Email,a.Product_Owner__r.Name, a.Product_Owner__r.Username, a.Found_in_Build__r.Name, Created_By_import__r.Email,a.Created_By_import__r.Name, a.Created_By_import__r.Username, a.Created_By_import__c, a.CreatedDate, a.CreatedBy.Email,a.CreatedBy.Name, a.CreatedBy.Username, a.Assignee__r.Email, a.Assignee__r.Name,a.Assignee__r.Username, a.Tech_Writer__r.UserPermissionsOfflineUser, a.Tech_Writer__r.UserRoleId, a.CS_Contact__r.ManagerId';
    private static final String RELATED_COMMENTS_QUERY = '(Select Name, CreatedDate, CreatedById, Body__c, LocaleCreatedDate__c, Comment_Created_By__c, Comment_Created_By__r.Name, Comment_Created_Date__c, Preserve_Formatting__c From Comment__r order by CreatedDate desc)';
    private static final String RELATED_ACCEPTANCE_CRITERION_QUERY = ' ,(Select Name, CreatedDate, CreatedById, Status__c, Description__c From Acceptance_Criteria__r order by CreatedDate desc) ';
    private static final String RELATED_TASK_QUERY = ' ,(Select Name, Actual_Hours__c, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.IsActive, Assigned_To__r.EmployeeNumber, Capex_Enabled__c, Status__c, Subject__c, Hours_Remaining__c From Tasks__r order by CreatedDate desc) ';
    private static final String FIELD_NAMES = WORK_FIELD_NAMES + ', ' + RELATED_WORK_FIELD_NAMES;
    private static final String SQL_SELECT_ONLY_WORK_FIELDS = 'select ' + WORK_FIELD_NAMES + ' ';
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_FROM = 'from ADM_Work__c a';
    private static final String KANBAN_FIELDS = ' Id, Name, Status__c, Epic__r.Name, Scheduled_Build_Name__c, Subject__c, Sprint__c, Sprint__r.Name,Sprint_Name__c, Column__c, Column_Rank__c , RecordType.Name, RecordType.Id, Assignee__r.Name, Assignee__r.FirstName, Assignee__c, Assignee__r.SmallPhotoUrl, QA_Engineer__r.Name, QA_Engineer__r.FirstName, QA_Engineer__c, QA_Engineer__r.SmallPhotoUrl, Story_Points__c, Scrum_Team__c, Scrum_Team__r.Name, Product_Tag__c, Product_Tag__r.Name, Scheduled_Build__c, Scheduled_Build__r.Name, Priority__c, Account__c, Account__r.Name, Color__c, Color__r.Name, Color__r.Color__c, Capex_Enabled__c, (select id from ADM_Work__c.Tasks__r)';
    private static final String SQL_SELECT_KANBAN = 'select ' + KANBAN_FIELDS + ' ';
    private static final String DEFAULT_STATUS_NEW = 'New';
    public static final String BUG_RECORD_TYPE_NAME = 'Bug'; //TODO: remove this; use RECORD_TYPE_NAME_BUG instead
    public static final String TEMPLATE_RECORD_TYPE_NAME = 'Template'; //TODO: remove this; use RECORD_TYPE_NAME_BUG instead
    public static final String RECORD_TYPE_NAME_BUG = 'Bug';
    public static final String RECORD_TYPE_NAME_INVESTIGATION = 'Investigation';
    public static final String RECORD_TYPE_NAME_TEMPLATE = 'Template';
    public static final String RECORD_TYPE_NAME_TODO = 'ToDo';
    public static final String RECORD_TYPE_NAME_USERSTORY = 'User Story';
    public static final String BUG_TYPE_PICKLIST_ENTRY = 'Bug';
    public static final String UI_TYPE_CLASSIC = 'Classic';
    public static final String UI_TYPE_NEXT_GENERATION = 'Next Generation';
    public static final String DEFAULT_UI_TYPE = UI_TYPE_NEXT_GENERATION;
     public static final String UI_TYPE_CUSTOM_LIGHTNING = 'Custom Lightning';
    public static final Set<String> REQ_FIELDS_INVESTIGATION = new Set<String>{'Details_and_Steps_to_Reproduce__c','Severity_Level__c','Status__c','Product_Tag__c', 'Subject__c','Scrum_Team__c','Assignee__c'};
    public static final Set<String> BUG_RECORD_TYPE_REQ_FIELDS = new Set<String>{'Found_In_Build__c','Status__c', 'Priority__c', 'Product_Tag__c', 'Subject__c'};
    public static final Set<String> USERSTORY_RECORD_TYPE_REQ_FIELDS = new Set<String>{'Scrum_Team__c', 'Status__c', 'Product_Tag__c', 'Subject__c'};
    public static final Set<String> RECORD_TYPES_IGNORABLE = new Set<String> { ADM_Work.TEMPLATE_RECORD_TYPE_NAME };
    public static final Set<String> TEMPLATE_RECORD_TYPE_REQ_FIELDS = new Set<String>{'Template_Name__c', 'Template_Description__c'};
    public static final Set<String> TODO_RECORD_TYPE_REQ_FIELDS = new Set<String>{'Subject__c','Assignee__c','Status__c','Priority__c'};
    public static final Set<String> TYPES_WHERE_FREQUENCY_APPLIES = new Set<String>{'Bug'};
    public static final Set<String> TYPES_WHERE_PRIORITY_APPLIES = new Set<String>{'Translation','Bug List', 'Feature Request', 'Test Failure', 'Test Case', 'Test Change', 'Test Tool', 'Help', 'Integrate'};
    //if modification is made to these fields an email should be sent
    public static final Set<String> RECORD_TYPES_TO_AUTOASSIGN = new Set<String>{ADM_Work.RECORD_TYPE_NAME_INVESTIGATION,ADM_Work.BUG_RECORD_TYPE_NAME,ADM_Work.RECORD_TYPE_NAME_USERSTORY};
    public static final Set<String> NOTIFICATION_FIELDS_OTHER = new Set<String>{'Subject__c','Priority__c', 'Assignee__c', 'QA_Engineer__c', 'Product_Owner__c', 'Tech_Writer__c', 'System_Test_Engineer__c', 'UE_Engineer__c', 'Perforce_Status__c', 'Scheduled_Build__c','Status__c','Test_Failure_Status__c', 'Capex_Enabled__c'};
    public static final Set<String> NOTIFICATION_FIELDS_INVESTIGATION = new Set<String>{'Customer__c','Severity_Level__c','Executive_Involved__c','Request_RD_Mgr_Review__c','Critical_CRM_Feature__c','Red_Account__c','Deal_at_Risk__c','Estimated_Financial_Impact__c','Senior_Management_POC__c','CS_Contact__c','Subject__c','Priority__c', 'Assignee__c', 'QA_Engineer__c', 'Product_Owner__c', 'Tech_Writer__c', 'System_Test_Engineer__c', 'UE_Engineer__c', 'Perforce_Status__c', 'Scheduled_Build__c','Status__c'};
    public static final Map<String, Set<String>> NOTIFICATION_FIELDS = new Map<String,Set<String>>{ADM_Work.TEMPLATE_RECORD_TYPE_NAME => new Set<String>(),ADM_Work.RECORD_TYPE_NAME_INVESTIGATION => ADM_Work.NOTIFICATION_FIELDS_INVESTIGATION,ADM_Work.BUG_RECORD_TYPE_NAME => ADM_Work.NOTIFICATION_FIELDS_OTHER,ADM_Work.RECORD_TYPE_NAME_TODO => ADM_Work.NOTIFICATION_FIELDS_OTHER,ADM_Work.RECORD_TYPE_NAME_USERSTORY => ADM_Work.NOTIFICATION_FIELDS_OTHER};
    //these are the user assignment fields notified when a chatter post on the work record is made.
    public static final Set<String> USERS_WHO_RECEIVE_NOTIFICATION_FOR_WORK = new Set<String>{'Senior_Management_POC__c', 'CS_Contact__c','Assignee__c', 'QA_Engineer__c', 'Product_Owner__c', 'Tech_Writer__c', 'System_Test_Engineer__c', 'UE_Engineer__c'};
    public static List<String> STATUS_VALUES_INVESTIGATION = new List<String>{'Acknowledged','Closed - Duplicate','Closed - Known Bug Exists','Closed - New Bug Logged','Closed - LAP Request Approved','Closed - LAP Request Denied','Closed - Resolved With Internal Tools','Closed - Resolved Without Code Change','Closed - No Fix - Working as Designed','Closed - No Fix - Feature Request','Closed - No Fix - Will Not Fix','Closed - Defunct','Investigating','More Info Reqd from Support','New','Rejected'};
    public static List<String> STATUS_VALUES_TODO = new List<String>{'New','In Progress','Deferred','Completed'};
    public static List<String> STATUS_VALUES_USERSTORY = new List<String>{'New','Triaged','In Progress','Ready for Review','Fixed','QA In Progress','Closed','Waiting','Integrate','Pending Release','Duplicate','Never'};
    public static List<String> STATUS_VALUES_BUG = new List<String>{'New','Triaged','In Progress','Ready for Review','Fixed','QA In Progress','Closed','Waiting','Integrate','Pending Release','Duplicate','Never','Not a bug','Not Reproducible'};
    public static Set<String> STATUS_VALUES_OPEN = new Set<String>{'In Progress', 'Integrate', 'New', 'Triaged', 'Ready for Review'};
     public static final  Map<String, ADM_FieldWrapper> TEXT_FIELDS_MAP = new  Map<String, ADM_FieldWrapper>{'Customer__c' => new ADM_FieldWrapper('Customer'),'Request_RD_Mgr_Review__c' => new ADM_FieldWrapper('Request R&D Mgr Review'),'Deal_at_Risk__c' => new ADM_FieldWrapper('Deal at Risk'), 'Estimated_Financial_Impact__c' => new ADM_FieldWrapper('Estimated Financial Impact'),'Critical_CRM_Feature__c' => new ADM_FieldWrapper('Critical CRM Feature or Org Inaccessible'), 'Red_Account__c' => new ADM_FieldWrapper('Red Account'),'Executive_Involved__c' => new ADM_FieldWrapper('Executive Involved'),'Severity_Level__c' => new ADM_FieldWrapper('Severity Level'),'Perforce_Status__c' => new ADM_FieldWrapper('Source Control Status'), 'Status__c' => new ADM_FieldWrapper('Status'), 'Type__c' => new ADM_FieldWrapper('Type'), 'Priority__c' => new ADM_FieldWrapper('Priority'), 'Subject__c' => new ADM_FieldWrapper('Subject'), 'User_Type__c' => new ADM_FieldWrapper('User_Type__c'), 'Additional_Details__c' => new ADM_FieldWrapper('Additional Details'), 'Use_Prioritizer__c' => new ADM_FieldWrapper('Use Prioritizer'), 'Story_Points__c' => new ADM_FieldWrapper('Story Points'), 'Test_Failure_Status__c' => new ADM_FieldWrapper('Test Failure Status'), 'Details_and_Steps_to_Reproduce__c' => new ADM_FieldWrapper('Details and Steps to Reproduce'), 'Resolution__c' => new ADM_FieldWrapper('Test Resolution'),  'Capex_Enabled__c' => new ADM_FieldWrapper('New Customer Facing Feature') };
    public static final  Map<String, ADM_FieldWrapper> ADDITIONAL_FIELDS_MAP = new  Map<String, ADM_FieldWrapper>{'Associated_URL__c' => new ADM_FieldWrapper('Associated URL'),'Apex_Hammer_Compile_Failure__c' => new ADM_FieldWrapper('Apex Hammer Compile Failure'),'Data_Silo_Test_Affected__c' => new ADM_FieldWrapper('Data Silo Test Affected'),'Environment__c' => new ADM_FieldWrapper('Environment'),'Mobile_Device__c' => new ADM_FieldWrapper('Mobile Device'),'Mobile_Device_OS__c' => new ADM_FieldWrapper('Mobile Device OS'),'Mobile_Network__c' => new ADM_FieldWrapper('Mobile Network'),'Number_of_Orgs_affected__c' => new ADM_FieldWrapper('Number of Orgs affected'),'Number_of_Tests_Classes_affected__c' => new ADM_FieldWrapper('Number of Tests/Classes affected'),'S1_App_Build_Number__c' => new ADM_FieldWrapper('S1 App Build Number'),'Schema__c' => new ADM_FieldWrapper('Requires Schema Change'),'Request_Type__c' => new ADM_FieldWrapper('Request Type'),'Component__c' => new ADM_FieldWrapper('Deployment Component/s') ,'Deployment_Type__c' => new ADM_FieldWrapper('Deployment Type'),'Access_Location__c' => new ADM_FieldWrapper('Access Location'), 'Database_Name__c' => new ADM_FieldWrapper('Database Name') , 'Modules__c' => new ADM_FieldWrapper('Module(s)') };    
    public static final  Map<String, ADM_FieldWrapper> USER_FIELDS_MAP = new  Map<String, ADM_FieldWrapper>{'Senior_Management_POC__c' => new ADM_FieldWrapper('Senior Management POC'),'CS_Contact__c' => new ADM_FieldWrapper('Support Contact'),'Assignee__c' => new ADM_FieldWrapper('Assignee'),'QA_Engineer__c' => new ADM_FieldWrapper('QA Engineer'),'Product_Owner__c' => new ADM_FieldWrapper('Product Owner'),'Tech_Writer__c' => new ADM_FieldWrapper('Tech Writer'),'System_Test_Engineer__c' => new ADM_FieldWrapper('Performance Engineer'),'UE_Engineer__c' => new ADM_FieldWrapper('UE Engineer')};
    public static final  Map<String, ADM_FieldWrapper> BUILD_FIELDS_MAP = new  Map<String, ADM_FieldWrapper>{'Found_In_Build__c' => new ADM_FieldWrapper('Found In Build'), 'Scheduled_Build__c' => new ADM_FieldWrapper('Scheduled Build'), 'Found_in_Build__c' => new ADM_FieldWrapper('Found In Build')};
    public static final Map<String, ADM_FieldWrapper> SPRINT_FIELDS_MAP = new Map<String, ADM_FieldWrapper>{'Sprint__c' => new ADM_FieldWrapper('Sprint')};
    //with the introduction of product tags a tag and a team are now tightly coupled.  When one changes so should the other.
    public static final Map<String, ADM_FieldWrapper> TEAM_FIELDS_MAP = new Map<String, ADM_FieldWrapper>{'Scrum_Team__c' => new ADM_FieldWrapper('Scrum Team'), 'Product_Tag__c' => new ADM_FieldWrapper('Product Tag')};
    public static final Map<String, ADM_FieldWrapper> FK_VALUES_MAP = new Map<String, ADM_FieldWrapper>{'Product_Tag_Name__c' => new ADM_FieldWrapper('Product Tag'), 'Scrum_Team_Name__c' => new ADM_FieldWrapper('Scrum Team'), 'Sprint_Name__c' => new ADM_FieldWrapper('Sprint'),'Found_In_Build_Name__c' => new ADM_FieldWrapper('Found In Build'), 'Scheduled_Build_Name__c' => new ADM_FieldWrapper('Scheduled Build')};
    public static final Set<String> FK_FIELD_NAMES = new Set<String>();
    public static Map<String,List<String>> STATUS_VALUES = new Map<String,List<String>>();
    public static final String LEGACY_TYPES = 'Feature Request';
    private static Map<String, ADM_FieldWrapper> ALL_FIELDS_MAP = null;
    // adding Account for Field Work MK
    private static final Set<String> WORK_AUTO_COMPLETE_FIELDS = new Set<String>{'Sprint__c','Scheduled_Build__c','Found_In_Build__c', 'Assignee__c','Product_Owner__c','QA_Engineer__c', 'Account__c', 'Account__r.Name'};
    private static final Map<String, String> fieldToSObjectType = new Map<String, String>{'Sprint__c' => 'ADM_Sprint__c', 'Scheduled_Build__c' => 'ADM_Build__c', 'Found_In_Build__c' => 'ADM_Build__c', 'Assignee__c' => 'User', 'Product_Owner__c' => 'User', 'QA_Engineer__c' => 'User', 'Account__c' => 'Account__r.Name', 'Account__r.Name' => 'Account__r.Name'};
    public static final Set<String> CLOSED_LIKE_STATUSES = new Set<String>{ 'tested', 'closed','closed-untested','closed-u/ftest','completed','not reproducible','never','not a bug', 'duplicate','closed - duplicate','closed - known bug exists','closed - new bug logged','closed - no fix - working as designed','closed - no fix - feature request','closed - no fix - will not fix','closed - lap request approved', 'closed - lap request denied','closed - resolved without code change', 'rejected', 'closed - resolved with internal tools','closed - defunct'};
    public static final String BUG_DETAIL_PAGE = 'apex/' + ADM_ConstantsSingleton.getInstance().getNameSpace() + 'ADM_BugDetail';
    public static final String USER_STORY_DETAIL_PAGE = 'apex/' + ADM_ConstantsSingleton.getInstance().getNameSpace() + 'ADM_UserStoryDetail';
    public static final String BUG_EDIT_PAGE = '/apex/' + ADM_ConstantsSingleton.getInstance().getNameSpace() + 'adm_bugedit';
    public static final String USER_STORY_EDIT_PAGE = '/apex/' + ADM_ConstantsSingleton.getInstance().getNameSpace() + 'adm_userstoryedit';
    public static final String WORK_STATUS_CLOSED = 'Closed';
    public static final String WORK_FIELD_EPIC = 'Epic__c';
    public static final String WORK_FIELD_SCRUM_TEAM = 'Scrum_Team__c';
    public static final String WORK_FIELD_SPRINT = 'Sprint__c';

    public static Set<String> getUpdateableFieldSet() {
        Set<String> fieldSet = new Set<String>(WORK_UPDATEABLE_FIELD_NAMES.split(','));
        return fieldSet;
    }

    public static ADM_Work__c[] getAll( String id ){

        String sql = SQL_SELECT + SQL_FROM + ' where id = :id order by a.CreatedDate desc';

        ADM_Work__c[] works = Database.query(sql);

        return works;

    }

    public static void removeUnnecessaryFieldsWhileChangingRecordTypes(ADM_Work__c[] worksNew, ADM_Work__c[] worksOld, Map<Id,RecordType> workRecordTypesById){
        for(Integer i = 0; i < worksNew.size(); i++) {
            String oldRecordTypeName = workRecordTypesById.get(worksOld[i].RecordTypeId).Name;
            String newRecordTypeName = workRecordTypesById.get(worksNew[i].RecordTypeId).Name;

            if(oldRecordTypeName.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME) && newRecordTypeName.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
                worksNew[i].Impact__c = null;
                worksNew[i].Frequency__c = null;
                worksNew[i].Priority__c = null;
            }

        }
    }

    @RemoteAction
    public static WorkEditorDialogMetaData getWorkEditorDialogMetaData(String Id, String teamId){
        WorkEditorDialogMetaData metaData = new WorkEditorDialogMetaData();
        if(id != null) {
            metaData.workSObject = getById(Id);
            system.debug(JSON.serialize(metadata.workSObject));
        }

        List<ADM_Work_Status__c> workStatuses = ADM_WorkStatus.getAllWorkStatusesByTypes(new List<String>{'Bug', 'User Story', 'Investigation'});

        for(ADM_Work_Status__c workStatus : workStatuses){

            if(workStatus.Type__c.toLowerCase().indexOf('bug') != -1){
                if(null == metaData.bugStatuses){
                    metaData.bugStatuses = new List<String>();
                }
                metaData.bugStatuses.add(workStatus.Name);
            }

            if(workStatus.Type__c.toLowerCase().indexOf('user story') != -1){
                if(null == metaData.userStoryStatuses){
                    metaData.userStoryStatuses = new List<String>();
                }
                metaData.userStoryStatuses.add(workStatus.Name);
            }

             if(workStatus.Type__c.toLowerCase().indexOf('investigation') != -1){
                if(null == metaData.investigationStatuses){
                    metaData.investigationStatuses = new List<String>();
                }
                metaData.investigationStatuses.add(workStatus.Name);
            }


        }
        metaData.frequencies = ADM_Frequency.getAll();
        metaData.impacts = ADM_Impact.getAllByType(BUG_RECORD_TYPE_NAME);
        metaData.priorityMappings = getPriorityMappingsByImpacts(metaData.impacts);

        for(ADM_Priority__c priority : ADM_Priority.getAll()){
            if(null == metaData.priorities){
                metaData.priorities = new List<String>();
            }
            metaData.priorities.add(priority.Name);
        }


           Schema.DescribeFieldResult fieldResult = ADM_Work__c.Severity_Level__c.getDescribe();
           List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
           for(Schema.Picklistentry ple : ples) {
               if(null == metadata.severities){
                   metadata.severities = new List<String>();
               }
               metadata.severities.add(ple.getLabel());
           }

           Schema.DescribeFieldResult helpStatusResult = ADM_Work__c.Help_Status__c.getDescribe();
           List<Schema.PicklistEntry> helpStatusResultPickListValues = helpStatusResult.getPicklistValues();
           for(Schema.Picklistentry helpStatusResultPickListValue : helpStatusResultPickListValues) {
               if(null == metadata.helpStatuses){
                   metadata.helpStatuses = new List<String>();
                   metadata.helpStatuses.add('-None-');
               }
               metadata.helpStatuses.add(helpStatusResultPickListValue.getLabel());
           }


        metaData.storyPoints = ADM_ScrumTeam.getStoryPointScaleByTeamId(teamId);
        metaData.leafNodeDetailsList = ADM_ColumnUtility.getLeafNodesByTeamId(teamId);

        return metaData;
    }

    public static List<ADM_Priority_Mapping__c> getPriorityMappingsByImpacts(List<ADM_Impact__c> impacts ){
        List<String> impactIds = new List<String>();
        for(ADM_Impact__c impact : impacts) {
            impactIds.add(impact.Id);
        }
        List<ADM_sortingWrapper> sortingWrappers = new List<ADM_sortingWrapper>();
        ADM_sortingWrapper sortingWrapperFrequency = new ADM_sortingWrapper();
        ADM_sortingWrapper sortingWrapperImpact = new ADM_sortingWrapper();

        sortingWrapperFrequency.sortBy = 'Frequency__r.Order__c';
        sortingWrapperFrequency.sortOrder = 'ASC';

        sortingWrapperImpact.sortBy = 'Impact__r.Order__c';
        sortingWrapperImpact.sortOrder = 'ASC';

        sortingWrappers.add(sortingWrapperImpact);
        sortingWrappers.add(sortingWrapperFrequency);

        return ADM_PriorityMapping.getAllBy('Impact__c', impactIds, sortingWrappers);
    }

    /**
     * Gets the work record with the matching ID. If no work record is associated
     * to the ID, a null reference is returned.
     */
    public static ADM_Work__c getById(String id) {
        List<ADM_Work__c> workList = ADM_Work.getAllBy('Id', new List<String>{id}, 0, 1, 'Id', 'ASC');
        if(workList.isEmpty()) {
            return null;
        } else {
            return workList.get(0);
        }
    }

    public static List<ADM_Work__c> getAllById(List<Id> idList) {
        //convert the list of IDs to strings
        List<String> idStringList = new List<String>();
        for(Id id : idList) {
            idStringList.add(String.valueOf(id));
        }

        return getAllById(idStringList);
    }

    public static List<ADM_Work__c> getAllById(List<String> idList) {
        return ADM_Work.getAllBy('Id', idList, 0, 1000, 'Id', 'ASC');
    }

    public static String PRIORITY_OVERRIDE_EXPLANATION {

        get {

            return 'Explain why this bug should have a different priority';

        }

        set;

    }


    public static Map<String, ADM_FieldWrapper> getLookupFieldsMap() {

        Map<String, ADM_FieldWrapper> lFieldsMap = new Map<String, ADM_FieldWrapper>();

        lFieldsMap.put('Impact__c', new ADM_FieldWrapper('Impact'));

        lFieldsMap.put('Frequency__c', new ADM_FieldWrapper('Frequency'));

        return lFieldsMap;

    }

    public static  Map<String, ADM_FieldWrapper> getMapOfFieldNameLabelPairs() {
        if(ALL_FIELDS_MAP == null) {
            Map<String, ADM_FieldWrapper> fieldNameLabelMap = new  Map<String, ADM_FieldWrapper>();
            fieldNameLabelMap.putAll(TEXT_FIELDS_MAP);
            fieldNameLabelMap.putAll(USER_FIELDS_MAP);
            fieldNameLabelMap.putAll(BUILD_FIELDS_MAP);
            fieldNameLabelMap.putAll(TEAM_FIELDS_MAP);
            fieldNameLabelMap.putAll(SPRINT_FIELDS_MAP);
            fieldNameLabelMap.putAll(FK_VALUES_MAP);
            fieldNameLabelMap.putAll(ADDITIONAL_FIELDS_MAP);
            fieldNameLabelMap.putAll(getLookupFieldsMap());
            fieldNameLabelMap.put('RecordType', new ADM_FieldWrapper('Record Type'));
            /* Moved Details_and_Steps_to_Reproduce__c to ADDITIONAL_FIELDS_MAP */
            //fieldNameLabelMap.put('Details_and_Steps_to_Reproduce__c', new ADM_FieldWrapper('Details and Steps to Reproduce'));
            //fieldNameLabelMap.put('Resolution__c', new ADM_FieldWrapper('Test Resolution'));
            ALL_FIELDS_MAP = fieldNameLabelMap;
        }
        return ALL_FIELDS_MAP;
    }

    public static  Set<String> getNamesOfFKFields() {
        if(FK_FIELD_NAMES != null) {
            FK_FIELD_NAMES.addAll(USER_FIELDS_MAP.keySet());
            FK_FIELD_NAMES.addAll(BUILD_FIELDS_MAP.keySet());
            FK_FIELD_NAMES.addAll(TEAM_FIELDS_MAP.keySet());
            FK_FIELD_NAMES.addAll(SPRINT_FIELDS_MAP.keySet());
            FK_FIELD_NAMES.addAll(FK_VALUES_MAP.keySet());
        }
        return FK_FIELD_NAMES;
    }

    public static Map<String,List<String>> getStatusValues(){
        STATUS_VALUES.put(BUG_RECORD_TYPE_NAME,ADM_Work.getStatusValuesForType('Bug'));
        STATUS_VALUES.put(TEMPLATE_RECORD_TYPE_NAME,STATUS_VALUES_BUG);
        STATUS_VALUES.put(RECORD_TYPE_NAME_TODO,STATUS_VALUES_TODO);
        STATUS_VALUES.put(RECORD_TYPE_NAME_USERSTORY,ADM_Work.getStatusValuesForType('User Story'));
        STATUS_VALUES.put(RECORD_TYPE_NAME_INVESTIGATION,ADM_Work.getStatusValuesForType('Investigation'));

        return STATUS_VALUES;
    }

    public static List<String> getStatusValuesForType(String type){

        List<String> statusesForType = new List<String>();
        List<ADM_Work_Status__c> statusValues = [Select Name from ADM_Work_Status__c where Type__c includes(: type) order by Order__c];

        for(ADM_Work_Status__c status : statusValues){
            statusesForType.add(status.Name);
        }

        return statusesForType;

    }

    /**
     * Gets the list of status values available for the given record type name.
     */
    public static List<String> getStatusValues(String recordTypeName) {
        return getStatusValues().get(recordTypeName);
    }

    /**
     * Gets a list of fields that are to trigger a notification message to be sent.
     */
    public static Set<String> getNotificationFields(String recordTypeName) {
        return ADM_Work.NOTIFICATION_FIELDS.get(recordTypeName);
    }

    public static Map<Id, ADM_Work__c> getAllByAsMap( String columnName, List<String> columnValues, Integer rowStart, Integer rowEnd, String sortBy, String sortOrder ){
        Map<Id, ADM_Work__c> workMap = new Map<Id, ADM_Work__c>();
        for(ADM_Work__c work : getAllBy(columnName, columnValues, rowStart, rowEnd, sortBy, sortOrder)) {
            workMap.put(work.id, work);
        }
        return workMap;
     }

    public static ADM_Work__c[] getAllBy( String columnName, List<String> columnValues, Integer rowStart, Integer rowEnd, String sortBy, String sortOrder ){

        ADM_Work__c[] works = new ADM_Work__c[0];
        Integer i = 0;

        try {
            String valuesInColumn = COM_SoqlUtils.createInClause(columnName, columnValues);
            String sql = SQL_SELECT + ' ,' + RELATED_COMMENTS_QUERY + ' ' + RELATED_ACCEPTANCE_CRITERION_QUERY + RELATED_TASK_QUERY + SQL_FROM + ' where ' + valuesInColumn + ' order by ' + COM_SoqlUtils.createOrder(sortBy, sortOrder);
            works = sublist(sql, rowStart, rowEnd);
        } catch( System.Exception e ){ }
        return works;

    }

     public static ADM_Work__c[] getExistingKanbanWorks(String teamId, String filterBy, Set<String> filterByValues, String otherFilter, String rowLimit){

        List<ADM_Work__c> worksForTeam;
        //sree
        String soql = SQL_SELECT_KANBAN + SQL_FROM;
        String filter = ' where Scrum_Team__c = \'' + teamId + '\'';

        if(!ADM_TextUtils.isBlank(filterBy) && filterByValues.size() > 0){
            filter += ' and '+ COM_SoqlUtils.createInClause(filterBy, filterByValues);
        }

        soql += filter;

        if(!ADM_TextUtils.isBlank(otherFilter)){
           soql += ' and ' + otherFilter;
        }


        soql += ' order by Column_Rank__c nulls last, LastModifiedDate desc ';

        if(!ADM_TextUtils.isBlank(rowLimit)){
            worksForTeam = sublist(soql, 0, Integer.valueOf(rowLimit));
        }
        else{
            worksForTeam =  Database.query(soql);
        }
        return worksForTeam;

    }

    public static ADM_Work__c[] getTeamsWork( String teamId, String filterBy, List<String> filterByValues, Boolean includeFilter, String otherFilter, String sortBy, String rowLimit ){
        List<ADM_Work__c> worksForTeam;
        //sree
        String soql = SQL_SELECT_KANBAN + SQL_FROM;
        String filter = ' where Scrum_Team__c = \'' + teamId + '\'';
        if(!ADM_TextUtils.isBlank(filterBy) && filterByValues.size() > 0){
            if(includeFilter == true){
                filter += ' and '+ COM_SoqlUtils.createInClause(filterBy, filterByValues);
            }
            else{
                filter += ' and '+ COM_SoqlUtils.createNotInClause(filterBy, filterByValues);
            }
        }
        soql += filter;
        if(!ADM_TextUtils.isBlank(otherFilter)){
           soql += ' and ' + otherFilter;
        }
        soql += ' order by ' + sortBy;
        if(!ADM_TextUtils.isBlank(rowLimit)){
            worksForTeam = sublist(soql, 0, Integer.valueOf(rowLimit));
        }
        else{
            worksForTeam =  Database.query(soql);
        }
        return worksForTeam;

    }

    public static ADM_Work__c[] getWorksForKanban( List<Id> workIds ){
        List<ADM_Work__c> works;
        String soql = SQL_SELECT_KANBAN + SQL_FROM + ' where ' + COM_SoqlUtils.createInClause('Id', workIds);
        works =  Database.query(soql);
        return works;

    }

    public static ADM_Work__c[] getWorksForKanbanByWorkIdsAndTeamIds( List<Id> workIds, Set<String> workTeamIds ){
        List<ADM_Work__c> works;
        String soql = SQL_SELECT_KANBAN + SQL_FROM + ' where ' + COM_SoqlUtils.createInClause('Id', workIds) + ' and ' + COM_SoqlUtils.createInClause('Scrum_Team__c', workTeamIds);
        works =  Database.query(soql);
        return works;

    }

    public static ADM_Work__c[] getWorksByColumnIds( Set<Id> columnIds ){
        List<ADM_Work__c> works;
        List<Id> columnIdList = new List<Id>(columnIds);
        String soql = SQL_SELECT_KANBAN + SQL_FROM + ' where ' + COM_SoqlUtils.createInClause('Column__c', columnIdList);
        works =  Database.query(soql);
        return works;

    }

    public static ADM_Work__c[] getWorksByColumnIdAndChildColumns( String columnId ){
        List<ADM_Work__c> works;
        String soql = 'Select Id, Column__c from ADM_Work__c where column__c in (select id from ADM_Column__c where Parent_Column__c = \''+ columnId + '\' or Id = \''+ columnId +'\')';
        works =  Database.query(soql);
        return works;

    }

    public static ADM_Work__c[] getWorksBySprint( String sprintId ){
        List<ADM_Work__c> worksInSprint;
        //sree
        String soql = SQL_SELECT + SQL_FROM;
        String filter = ' where Sprint__c = \'' + sprintId + '\'';
        soql += filter;

        worksInSprint =  Database.query(soql);
        return worksInSprint;

    }


    public static ADM_Work__c[] getAllLike(String columnName, List<String> columnValues, Integer rowStart, Integer rowEnd, String sortBy, String sortOrder) {
        ADM_Work__c[] works = new ADM_Work__c[]{};
        String inValues = '';
        Integer inValuesCounter = 0;
        String sql;
        String likeString = String.escapeSingleQuotes(columnName) + ' like ';

        try {
            for(String columnValue : columnValues) {
                if(inValuesCounter > 0) {
                    inValues += ' or ';
                }
                inValues += likeString + '\'' + String.escapeSingleQuotes(columnValue.trim()) + '%\' ';
                inValuesCounter++;
            }

            sql = SQL_SELECT + ' ,' + RELATED_COMMENTS_QUERY + ' ' + RELATED_ACCEPTANCE_CRITERION_QUERY + RELATED_TASK_QUERY + SQL_FROM + ' where ' + inValues + ' order by ' + COM_SoqlUtils.createOrder(sortBy, sortOrder);
            works = sublist(sql, rowStart, rowEnd);
        } catch( System.QueryException e ){
            System.debug('--->' + e);
        }
        return works;
    }

    private static ADM_Work__c[] sublist(String sql, Integer rowStart, Integer rowEnd) {
        ADM_Work__c[] works = new ADM_Work__c[0];
        Integer i = 0;
        for( ADM_Work__c work : Database.query(sql)) {
            i++;
            if(i >= rowStart && i <= rowEnd) {
                works.add( work );
            }
        }
        return works;
    }

    public static ADM_Work__c match( ADM_Work__c[] works, String bid ){

        ADM_Work__c emptywork = new ADM_Work__c();

        emptywork.Number_of_Cases__c = 0;



        for( ADM_Work__c b : works ){



            if( b.Id == bid ){



                return b;

            }

        }



        //return an emptywork cuz no one was found

        return emptywork;

    }



    public static ADM_Work__c get( String columnName, String columnValue, String sortBy, String sortOrder ){

        ADM_Work__c work = new ADM_Work__c();

        work.Number_of_Cases__c = 0;

        ADM_Work__c[] works;

        List< String> columnValues = new List< String >();

        Integer rowStart = 1;

        Integer rowEnd = 199;



        columnValues.add( columnValue );

        works = getAllBy( columnName, columnValues, rowStart, rowEnd, sortBy, sortOrder );

        work = ADM_work.match( works, columnValue );



        return work;

    }



    public static Integer getRecordCount(){

        Integer records = [ Select count() From ADM_Work__c Where RecordType.Name = 'Template' ];

        return records;

    }



    public static void save( ADM_Work__c work){

        Database.insert( work );

    }



    public static ADM_Work__c createTestBug() {

        return createTestWork(BUG_RECORD_TYPE_NAME);

    }



    public static ADM_Work__c createTestTodo() {

       return createTestWork(RECORD_TYPE_NAME_TODO);



    }



    public static ADM_Work__c createTestTemplate() {

        return createTestWorkTemplate();

    }




    public static List<ADM_Work__c> createListOfWork(Integer numberOfWorkRecords, String recordType) {
        String buildName = 'TestBuild' + String.valueOf(Math.random());
        if(buildName.length() > 80) {
            buildName = buildName.substring(0, 80);
        }
        ADM_Build__c b = new ADM_Build__c(Name=buildName);

        insert b;

        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();


        ADM_Frequency__c f = new ADM_Frequency__c (Name=String.valueOf(Math.random()));

        insert f;

        ADM_Impact__c i = new ADM_Impact__c(Name=String.valueOf(Math.random()));

        insert i;

        ADM_Type__c t = new ADM_Type__c(Name = recordType);

        insert t;

        ADM_Impact_Type__c it = new ADM_Impact_Type__c(Impact__c = i.id, Type__c = t.id);

        insert it;

        ADM_Priority__c p = new ADM_Priority__c(Name='P1');

        insert p;

        ADM_Priority_Mapping__c pm = new ADM_Priority_Mapping__c(Impact__c = i.id, Frequency__c = f.id, Priority__c = p.id);

        insert pm;
        ADM_Priority_Mapping__c[] el = ADM_PriorityMapping.getAllBy('Priority__r.Name', new List<String>{'P1'}, 'Id', 'asc');

        List<ADM_Work__c> works = new List<ADM_Work__c>();

        User u = ADM_WorkUser.createTestUser();

        Id recTypeID = [select id from RecordType where Name =: recordType].id;

        for(Integer count = 0; count < numberOfWorkRecords; count++) {
            ADM_Work__c work = new ADM_Work__c();

            work.Description__c = 'This is a test comment for record:' + count;

            work.Found_In_Build__c = b.id;

            work.Assignee__c = u.id;

            work.Frequency__c = f.id;

            work.Impact__c = i.id;

            work.Type__c = 'Bug';

            work.Story_Points__c = 5;

            work.Product_Tag__c = productTag.Id;

            work.Product_Area__c = 'GUS';

            work.Major_Func_Area__c = 'Other';

            work.Minor_Func_Area__c = String.valueOf(Math.random());

            work.Status__c = 'New';



            work.Number_of_Cases__c = 0;

            work.Subject__c = 'Test Work Record ' + count;

            work.RecordTypeId = recTypeID;

            work.Use_Prioritizer__c = true;

            if(recordType.equals(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
                work.CS_Contact__c = Userinfo.getUserId();
                work.Severity_Level__c = '1';
                work.Details_and_Steps_to_Reproduce__c = 'details and steps to reproduce';
            }

            works.add(work);
        }

        return works;
    }

    public static List<ADM_Work__c> createListOfWork(Integer numberOfWorkRecords, String recordType, Set<String> additonalFields) {
        List<ADM_Work__c> worklist = createListOfWork(numberOfWorkRecords, recordType);
        ADM_Epic__c epic;
        ADM_Sprint__c sprint;
        ADM_Scrum_Team__c team;

        if (additonalFields.contains(WORK_FIELD_EPIC)) {
            epic = ADM_Epic.createTestEpic();
        }

        if (additonalFields.contains(WORK_FIELD_SCRUM_TEAM)) {
            team = ADM_ScrumTeam.createTestScrumTeam('Random Test Suite Team Name');
        }

        if (additonalFields.contains(WORK_FIELD_SPRINT)) {
            if (team == null) {
                team = ADM_ScrumTeam.createTestScrumTeam('Random Test Suite Team Name');
            }

            sprint = ADM_Sprint.createTestSprintForTeam(team);
        }

        for(Integer count = 0; count < numberOfWorkRecords; count++) {
            ADM_Work__c work = worklist.get(count);

            if (additonalFields.contains(WORK_FIELD_EPIC)) {
                work.Epic__c = epic.Id;
            }

            if (additonalFields.contains('Product_Owner__c')) {
                work.Product_Owner__c = work.Assignee__c;
            }

            if (additonalFields.contains('QA_Engineer__c')) {
                work.QA_Engineer__c = work.Assignee__c;
            }

            if (additonalFields.contains('Scheduled_Build__c')) {
                work.Scheduled_Build__c = work.Found_In_Build__c;
            }

            if (additonalFields.contains(WORK_FIELD_SCRUM_TEAM)) {
                work.Scrum_Team__c = team.Id;
            }

            if (additonalFields.contains(WORK_FIELD_SPRINT)) {
                work.Sprint__c = sprint.Id;
            }

            worklist.set(count, work);
        }

        return worklist;
    }

    public static ADM_Work__c createTestWork(String recordType) {

        ADM_Work__c work = setupTestWork(recordType);

        if ( recordType == RECORD_TYPE_NAME_TODO || recordType == RECORD_TYPE_NAME_USERSTORY )
            work.Priority__c = 'P1';

        insert(work);

        return work;

    }

    public static boolean doesWorkExist(){
        ADM_Work__c [] works = [Select id from ADM_Work__c limit 1];
        if(works != null && works.size() >0){
            return true;
        }
        else{
            return false;
        }
    }

    public static ADM_Work__c setupTestWork(String recordType, String priority) {
        return setupTestWork(recordType, priority, 'Bug');
    }

    public static ADM_Work__c setupTestWork(String recordType) {
        return setupTestWork(recordType, 'P99', 'Bug');
    }



    //creates a test work object but does not insert it.  allows you to reuse this method but still tweak a value before inserting.  Saves hitting trigger mutiple times and hitting
    //apex test gov limits.
    public static ADM_Work__c setupTestWork(String recordType, String priority, String bugType) {

        ADM_Work__c work = new ADM_Work__c();

        ADM_Product_Tag__c productTag = ADM_ProductTag.createAndInsertProductTag();

        ADM_Frequency__c f = new ADM_Frequency__c (Name=String.valueOf(Math.random()));

        insert f;

        ADM_Impact__c i = new ADM_Impact__c(Name=String.valueOf(Math.random()));

        insert i;

        ADM_Type__c t = new ADM_Type__c(Name = bugType);

        insert t;

        ADM_Impact_Type__c it = new ADM_Impact_Type__c(Impact__c = i.id, Type__c = t.id);

        insert it;

        ADM_Priority__c p = new ADM_Priority__c(Name=priority);

        insert p;

        ADM_Priority_Mapping__c pm = new ADM_Priority_Mapping__c(Impact__c = i.id, Frequency__c = f.id, Priority__c = p.id);

        insert pm;
        ADM_Priority_Mapping__c[] el = ADM_PriorityMapping.getAllBy('Priority__r.Name', new List<String>{priority}, 'Id', 'asc');
        system.debug('@@@' + el);
        if(recordType == ADM_Work.RECORD_TYPE_NAME_USERSTORY || recordType == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {

            ADM_Scrum_Team__c scrum = new ADM_Scrum_Team__c(Name='Random Test Suite Team Name' + pm.id);
            scrum.Story_Point_Scale__c = '1,2,3,5,8,13,21';
            scrum.Cloud__c = 'Chatter';

            insert scrum;

            work.Scrum_Team__c = scrum.id;
        }

        work.Assignee__c =  ADM_WorkUser.createTestUser().id;

        work.Frequency__c = f.id;

        work.Impact__c = i.id;

        work.Type__c = 'Bug';

        work.Story_Points__c = 5;

        work.Product_Tag__c = productTag.Id;

        work.Scrum_Team__c = productTag.Team__c;

        work.Product_Area__c = 'GUS';

        work.Major_Func_Area__c = 'Other';

        work.Minor_Func_Area__c = String.valueOf(Math.random());

        work.Status__c = 'New';



        work.Number_of_Cases__c = 0;

        work.Subject__c = 'Test Work Subject';

        work.RecordTypeId = [select id from RecordType where Name =: recordType].id;

        work.Use_Prioritizer__c = true;



        if(recordType.equals(ADM_Work.TEMPLATE_RECORD_TYPE_NAME)) { //should only populate if its a template.  FYI if template name populated WorkTrigger is skipped

            work.Template_Name__c = 'Test Template';

            work.Template_Description__c = 'Test Template Description';

        } else if(recordType.equals(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
            work.CS_Contact__c = Userinfo.getUserId();
            work.Severity_Level__c = '1';
            work.Details_and_Steps_to_Reproduce__c = 'details and steps to reproduce';
        }

        ADM_Build__c build = ADM_Build.createTestBuild('Test' + String.valueOf(Math.random()));

        work.Found_in_Build__c = build.Id;

        work.Scheduled_Build__c = build.Id;

        work.Number_of_Change_Lists__c = 0;

        return work;

    }

    public static ADM_Work__c createTestWork() {

        return createTestWork(BUG_RECORD_TYPE_NAME);

    }



    public static ADM_Work__c createTestWorkTemplate() {

         return createTestWork(TEMPLATE_RECORD_TYPE_NAME);

    }

    public static ADM_Work__c createTestCapexWork() {
        ADM_Work__c work = setupTestWork(ADM_Work.RECORD_TYPE_NAME_USERSTORY);

        work.Capex_Enabled__c = true;

        insert(work);

        return work;

    }

    public static  Database.Deleteresult deleteTest(ADM_Work__c w) {

        Database.Deleteresult result = Database.delete(w);

        return result;

    }

    public static ADM_Work__c getOneBy(String columnName, String columnValue){
        ADM_Work__c work = null;

        try{
            work = Database.query(SQL_SELECT_ONLY_WORK_FIELDS + ' , ' + RELATED_WORK_FIELD_NAMES + ' ' + SQL_FROM + ' where ' + String.escapeSingleQuotes(columnName) + '= \'' + String.escapeSingleQuotes(columnValue.trim()) + '\'');
        } catch( System.QueryException e ){ }

        if(work == null) {
            work = new ADM_Work__c();
        }
        return work;
    }

   @AuraEnabled
    public static ADM_Work__c getOneByForEdit(String columnName, String columnValue){
        ADM_Work__c work = null;
        System.debug('inside getOneByForEdit');
        String q = 'select ' + BASIC_WORK_FIELD_NAMES + ' ' + SQL_FROM + ' where ' + String.escapeSingleQuotes(columnName) + '= \'' + String.escapeSingleQuotes(columnValue.trim()) + '\'';
        System.debug('getOnyByForEdit q=' + q);
        work = Database.query(q);
        if(work == null) {
            work = new ADM_Work__c();
        }
        System.debug('getOneByForEdit returning:' + work);
        return work;
    }

    private interface SetValueHandler {
        void setValue(ADM_Work__c work, String value);
    }

    private class StringSetValueHandler implements SetValueHandler {
        private final String fieldName;

        public StringSetValueHandler(String fieldName) {
            this.fieldName = fieldName;
        }

        public void setValue(final ADM_Work__c work, final String value) {
            ADM_Work.setValue(work, fieldName, value);
        }
    }

    private class ImpactSetValueHandler implements SetValueHandler {
        public void setValue(final ADM_Work__c work, final String value) {
            try{
                ADM_Work.setImpact(work, value);
            }
            catch(ADM_UnexpectedValueException unExVal){
                COM_PageUtils.addErrorMessageToPage(unExVal);
                System.debug(LoggingLevel.WARN, 'ImpactSetValueHandler was not able to set Impact for the work record ' + unExVal);
            }
        }
    }

    private class BooleanSetValueHandler implements SetValueHandler {
        private final String fieldName;

        public BooleanSetValueHandler(String fieldName) {
            this.fieldName = fieldName;
        }

        public void setValue(final ADM_Work__c work, final String value) {
            ADM_Work.setBoolean(work, fieldName, value);
        }
    }

    private class DoubleSetValueHandler implements SetValueHandler {
        private final String fieldName;

        public DoubleSetValueHandler(String fieldName) {
            this.fieldName = fieldName;
        }

        public void setValue(final ADM_Work__c work, final String value) {
            ADM_Work.setDouble(work, fieldName, value);
        }
    }

    private class ScheduledBuildCopySetValueHandler implements SetValueHandler {
        public void setValue(final ADM_Work__c work, final String value) {
            try{
                ADM_Work.setBuildName(work, 'Scheduled_Build_Copy__c', value);
            }
            catch(ADM_UnexpectedValueException unExVal){
                COM_PageUtils.addErrorMessageToPage(unExVal);
                System.debug(LoggingLevel.WARN, 'ScheduledBuildCopySetValueHandler was not able to set Build Name for the work record ' + unExVal);
            }
        }
    }

    private class ScheduledBuildSetValueHandler implements SetValueHandler {
        public void setValue(final ADM_Work__c work, final String value) {
            try{
                ADM_Work.setBuildId(work, 'Scheduled_Build__c', value);
            }
            catch(ADM_UnexpectedValueException unExVal){
                COM_PageUtils.addErrorMessageToPage(unExVal);
                System.debug(LoggingLevel.WARN, 'ScheduledBuildSetValueHandler was not able to set Build Id for the work record ' + unExVal);
            }
        }
    }

    private class FoundInBuildCopySetValueHandler implements SetValueHandler {
        public void setValue(final ADM_Work__c work, final String value) {
            try{
                ADM_Work.setBuildName(work, 'Found_In_Build_Copy__c', value);
            }
            catch(ADM_UnexpectedValueException unExVal){
                COM_PageUtils.addErrorMessageToPage(unExVal);
                System.debug(LoggingLevel.WARN, 'FoundInBuildCopySetValueHandler was not able to set Found in Build Name for the work record ' + unExVal);
            }
        }
    }

    private class FoundInBuildSetValueHandler implements SetValueHandler {
        public void setValue(final ADM_Work__c work, final String value) {
            try{
                ADM_Work.setBuildId(work, 'Found_In_Build__c', value);
            }
            catch(ADM_UnexpectedValueException unExVal){
                COM_PageUtils.addErrorMessageToPage(unExVal);
                System.debug(LoggingLevel.WARN, 'FoundInBuildSetValueHandler was not able to set Found in Build Id for the work record ' + unExVal);
            }
        }
    }

    private class SprintSetValueHandler implements SetValueHandler {
        public void setValue(final ADM_Work__c work, final String value) {
            try{
                ADM_Work.setSprint(work, 'Sprint__c', value);
            }
            catch(ADM_UnexpectedValueException unExVal){
                COM_PageUtils.addErrorMessageToPage(unExVal);
                System.debug(LoggingLevel.WARN, 'SprintSetValueHandler was not able to set Sprint for the work record ' + unExVal);
            }
        }
    }

    private class FrequencySetValueHandler implements SetValueHandler {
        public void setValue(final ADM_Work__c work, final String value) {
            try {
                ADM_Work.setFrequency(work, 'Frequency__c', value);
            }
            catch(ADM_UnexpectedValueException unExVal){
                COM_PageUtils.addErrorMessageToPage(unExVal);
                System.debug(LoggingLevel.WARN, 'FrequencySetValueHandler was not able to set Frequency for the work record ' + unExVal);
            }
        }
    }

    private static void setValue(SObject target, String fieldName, String value) {
        target.put(fieldName, value);
    }

    public static void setBoolean(SObject target, String fieldName, String value) {
        Boolean booleanValue = ADM_TextUtils.toBoolean(value);
        target.put(fieldName, booleanValue);
    }

    private static void setDouble(SObject target, String fieldName, String value) {
        Double doubleValue = ADM_TextUtils.toDouble(value);
        target.put(fieldName, doubleValue);
    }

    private static void setImpact(ADM_Work__c work, String value) {
        List<ADM_Impact__c> impactList = ADM_Impact.getAllByType(work.Type__c);

        //attempt to find the value within the ID and the Impact Name
        ADM_Impact__c foundImpact = null;
        for(ADM_Impact__c impact : impactList) {
            if(('' + impact.Id) == value || impact.Name.equalsIgnoreCase(value)) {
                foundImpact = impact;
                break;
            }
        }

        if(foundImpact != null) {
            work.Impact__c = foundImpact.Id;
        } else {
            throw new ADM_UnexpectedValueException('Provided string is not a valid impact ID or Name: ' + value);
        }
    }

    private static void setBuildName(SObject target, String fieldName, String buildNameOrId) {
        List<ADM_Build__c> builds = [select id, Name from ADM_Build__c where Name = :buildNameOrId or Id = :buildNameOrId];
        if(!builds.isEmpty()) {
            target.put(fieldName, builds.get(0).Name);
        } else {
            throw new ADM_UnexpectedValueException('Provided string is not a valid build ID or Name: ' + buildNameOrId);
        }
    }


    private static void setBuildId(SObject target, String fieldName, String buildNameOrId) {
        List<ADM_Build__c> builds = [select id from ADM_Build__c where Name = :buildNameOrId or Id = :buildNameOrId];
        if(!builds.isEmpty()) {
            target.put(fieldName, builds.get(0).Id);
        } else {
            throw new ADM_UnexpectedValueException('Provided string is not a valid build ID or Name: ' + buildNameOrId);
        }
    }

    private static void setSprint(SObject target, String fieldName, String value) {
        List<ADM_Sprint__c> sprints = [select Id from ADM_Sprint__c where Name = :value or Id = :value limit 1];

        if(!sprints.isEmpty()) {
            target.put(fieldName, sprints.get(0).Id);
        } else {
            throw new ADM_UnexpectedValueException('Provided string is not a valid sprint ID or Name: ' + value);
        }
    }

    private static void setFrequency(SObject target, String fieldName, String value) {
        List<ADM_Frequency__c> frequencies = ADM_Frequency.getByNameOrId(value);

        if(!frequencies.isEmpty()){
            target.put(fieldName, frequencies.get(0).Id);
        }
        else {
            throw new ADM_UnexpectedValueException('Provided string is not a valid frequency ID or Name: ' + value);
        }
    }

    private class Field {
        private final String name;
        private final SetValueHandler setValueHandler;

        public Field(String name, SetValueHandler setValueHandler) {
            this.name = name;
            this.setValueHandler = setValueHandler;
        }

        public String getName() {
            return this.name;
        }

        public void setValue(ADM_Work__c work, String value) {
            this.setValueHandler.setValue(work, value);
        }
    }

    public static ADM_Work__c setWorkValuesFromUrl(final ADM_Work__c work) {

        //get the field values from the URL
        Map<String, String> fieldValues = System.currentPageReference().getParameters();

        if(null != fieldValues && fieldValues.size()>0 ){
            List<ADM_Work.Field> fieldList = new List<ADM_Work.Field>{
                new Field('Subject__c', new ADM_Work.StringSetValueHandler('Subject__c')),

                //Type__c must be set before Impact__c
                new Field('Type__c', new ADM_Work.StringSetValueHandler('Type__c')),

                new Field('Priority__c', new ADM_Work.StringSetValueHandler('Priority__c')),
                new Field('Parent_ID__c', new ADM_Work.StringSetValueHandler('Parent_ID__c')),
                new Field('Child_ID__c', new ADM_Work.StringSetValueHandler('Child_ID__c')),
                new Field('Impact__c', new ADM_Work.ImpactSetValueHandler()),
                new Field('Attributes__c', new ADM_Work.StringSetValueHandler('Attributes__c')),
                new Field('Minor_Func_Area__c', new ADM_Work.StringSetValueHandler('Minor_Func_Area__c')),
                new Field('Related_URL__c', new ADM_Work.StringSetValueHandler('Related_URL__c')),
                new Field('Description__c', new ADM_Work.StringSetValueHandler('Description__c')),
                new Field('ftest__c', new ADM_Work.StringSetValueHandler('ftest__c')),
                new Field('Regressed__c', new ADM_Work.BooleanSetValueHandler('Regressed__c')),
                new Field('Security__c', new ADM_Work.BooleanSetValueHandler('Security__c')),
                new Field('Customer__c', new ADM_Work.StringSetValueHandler('Customer__c')),
                new Field('Status__c', new ADM_Work.StringSetValueHandler('Status__c')),
                new Field('Priority_Rank__c', new ADM_Work.DoubleSetValueHandler('Priority_Rank__c')),
                new Field('Story_Points__c', new ADM_Work.DoubleSetValueHandler('Story_Points__c')),
                new Field('Sprint__c', new ADM_Work.SprintSetValueHandler()),

                /*
                     For old work page - backward compatibility
                */
                new Field('Scheduled_Build__c', new ADM_Work.ScheduledBuildCopySetValueHandler()),
                new Field('Found_In_Build__c', new ADM_Work.FoundInBuildCopySetValueHandler()),

                /*
                     For new work page
                */
                new Field('Scheduled_Build__c', new ADM_Work.ScheduledBuildSetValueHandler()),
                new Field('Found_In_Build__c', new ADM_Work.FoundInBuildSetValueHandler())

            };


            for(Field field : fieldList) {
                if(!ADM_TextUtils.isNull(fieldValues.get(field.getName()))) {
                    field.setValue(work, ADM_TextUtils.getUTF8DecodedValue(fieldValues.get(field.getName())));
                }
            }

            //set frequency picklist when work type is applicable
            if(!ADM_TextUtils.isNull(fieldValues.get('Frequency__c'))) {
                if(ADM_Work.TYPES_WHERE_FREQUENCY_APPLIES.contains(work.Type__c)) {
                     //find the frequency with the specified name
                     (new ADM_Work.FrequencySetValueHandler()).setValue(work, ADM_TextUtils.getUTF8DecodedValue(fieldValues.get('Frequency__c')));
                }
            }

            //retrieve the record type from the logical name first
            RecordType recordType = null;
            if(!ADM_TextUtils.isNull(fieldValues.get('RecordTypeLogicalName')) || !ADM_TextUtils.isNull(fieldValues.get('RecordTypeName')) ||
                                            !ADM_TextUtils.isNull(fieldValues.get('RecordType'))  ){
                recordType = ADM_RecordType.getRecordTypeFromUrl('ADM_Work__c');
                if(recordType != null) {
                    work.RecordTypeId = recordType.Id;
                }
            }
            if(!ADM_TextUtils.isNull(fieldValues.get('Product_Tag__c')) && !ADM_TextUtils.isNull(fieldValues.get('Scrum_Team__c')) && recordType != null) {
                String tagName = ADM_TextUtils.getUTF8DecodedValue(fieldValues.get('Product_Tag__c'));
                String teamName = ADM_TextUtils.getUTF8DecodedValue(fieldValues.get('Scrum_Team__c'));
                ADM_Product_Tag__c productTag = ADM_Work.findProductTag(tagName, teamName, recordType.Name);
                if(productTag != null) {
                   work.Product_Tag__c = productTag.Id;
                }
            }

            try{

                //If this is a recordType Conversion then from user story - bug/ bug - user story copy details and descriptions
                String returnURL = fieldValues.get('retURL');
                /*Only do this if Not null/ non-empty returnURL exist

                */

                if(!ADM_TextUtils.isBlank(returnURL)){
                    if(returnURL.containsIgnoreCase(BUG_DETAIL_PAGE) && ApexPages.currentPage().getURL().containsIgnoreCase(USER_STORY_EDIT_PAGE)){
                        String newDetails = new ADM_TextUtils().stripHtmlTagsAndUnescapeHtml(work.Details_and_Steps_to_Reproduce__c);
                        /*
                            After long discussion in the team we are deciding to move forward with not allowing to over-write
                            Details__c in a User story if any data already exist for that field. This is to prevent the
                            data loss of Details__c initial User Story - if the User Story is converted to bug and back to
                            User Story again.

                         */
                        if(! ADM_TextUtils.isBlank(newDetails) && ADM_TextUtils.isBlank(work.Details__c)){
                            work.Details__c = newDetails;
                        }

                        // Default type__c to 'User Story' -  since this is a bug to user story conversion
                        work.Type__c = 'User Story';
                    }
                    else if(returnURL.containsIgnoreCase(USER_STORY_DETAIL_PAGE) && ApexPages.currentPage().getURL().containsIgnoreCase(BUG_EDIT_PAGE)){
                        /*
                            After long discussion in the team we are deciding to move forward with not allowing to over-write
                            Details_and_Steps_to_Reproduce__c in a Bug if any data already exist for that field. This is to prevent the
                            data loss of Details_and_Steps_to_Reproduce__c initial bug - if the bug is converted to user story and back to
                            bug again.

                         */
                        if(!ADM_TextUtils.isBlank(work.Details__c) && ADM_TextUtils.isBlank(work.Details_and_Steps_to_Reproduce__c)){
                            work.Details_and_Steps_to_Reproduce__c =  work.Details__c;
                        }

                        // Default type__c to 'Bug' -  since this is a user story to bug conversion
                        work.Type__c = 'Bug';

                    }
                }
            }
            catch(Exception exp){
                System.debug(' Exception while trying to convert recordType and copy details/details and steps to reproduce');
            }
        }

        return work;
    }
    /**
     * Gets the label for the specified field name. If the field is not found,
     * then the field name is returned.
     */
    public static String getFieldLabel(String fieldName) {
        if(getMapOfFieldNameLabelPairs().containsKey(fieldName)) {
            return getMapOfFieldNameLabelPairs().get(fieldName).fieldLabel;
        }
        return fieldName;
    }

    /**
     * Gets the configured work type for the specified record type.
     */
    public static WorkType getWorkType(RecordType recordType) {

        //check the cache
        if(workTypesByRecordTypeName.containsKey(recordType.Name)) {
            return workTypesByRecordTypeName.get(recordType.Name);
        }

        //try to create the type
        WorkType workType = null;
        if(recordType.Name == BUG_RECORD_TYPE_NAME) {

            workType = new GenericWorkType(BUG_RECORD_TYPE_REQ_FIELDS);

        } else if(recordType.Name == RECORD_TYPE_NAME_INVESTIGATION) {

            workType = new GenericWorkType(REQ_FIELDS_INVESTIGATION);

        } else if(recordType.Name == TEMPLATE_RECORD_TYPE_NAME) {

            workType = new GenericWorkType(TEMPLATE_RECORD_TYPE_REQ_FIELDS);

        } else if(recordType.Name == RECORD_TYPE_NAME_TODO) {

            workType = new GenericWorkType(TODO_RECORD_TYPE_REQ_FIELDS);

        } else if(recordType.Name == RECORD_TYPE_NAME_USERSTORY) {

            workType = new GenericWorkType(USERSTORY_RECORD_TYPE_REQ_FIELDS);

        }

        //verify that a work type was created, if not then it was because
        //the record type was not supported
        if(workType == null) {
            throw new ADM_ApplicationException('Unsupported record type \'' + recordType.Name + '\' specified');
        } else {
            workTypesByRecordTypeName.put(recordType.Name, workType);
        }

        return workType;
    }

    /**
     * Represents specifics about a work object.
     */
    public interface WorkType {

        /**
         * Determines if the specified field is required by the type definition.
         */
        Boolean isRequiredField(String fieldName);

        /**
         * Gets the value for the Status picklist when creating a new record
         */
        String getNewStatus();

        /**
         * Removes all of the field values that shouldn't be cloned from the specified work.
         */
        void removeFieldsNotApplicableForClone(ADM_Work__c work);

       /**
         * Some fields need to be initialized with values for eg: Status__c = 'New'
       */
       void initializeFieldsForClone(ADM_Work__c work);
    }

    /**
     * A generic version of the work type.
     */
    private class GenericWorkType implements WorkType{
        private Set<String> requiredFields = null;

        public GenericWorkType() {
            this.requiredFields = new Set<String>();
        }

        public GenericWorkType(Set<String> requiredFields) {
            this.requiredFields = requiredFields;
        }

        /**
         * @inheritDoc
         */
        public Boolean isRequiredField(String fieldName) {
            return requiredFields.contains(fieldName);
        }

        /**
         * @inheritDoc
         */
        public String getNewStatus() {
            return ADM_Work.DEFAULT_STATUS_NEW;
        }

        /**
         * @inheritDoc
         */
        public void removeFieldsNotApplicableForClone(ADM_Work__c work) {
            ADM_WorkUtils.removeFieldsNotApplicableForClone(work);
        }

        /**
         * @inheritDoc
         */
        public void initializeFieldsForClone(ADM_Work__c work) {
            ADM_WorkUtils.initializeFieldsForClone(work);
        }
    }


    /**
     * Creates the "WorkUpdates" PushTopic if it does not already exist
     * otherwise, a Debug message is logged.
     */
    public static void ensureWorkUpdatesPushTopic() {
        String name = 'WorkUpdates';
        String query = 'select Id, Subject__c, Status__c, Story_Points__c, Theme__c, Scheduled_Build__c, Assignee__c, QA_Engineer__c, Scrum_Team__c, Sprint__c, LastModifiedDate from ADM_Work__c';
        query = COM_SoqlUtils.convertToQualifiedQuery(query);
        Double apiVersion = 30.0;
        String notifyForOperations = 'All';
        String notifyForFields = 'Referenced';

        ADM_PushTopic.ensurePushTopic(name, query, apiVersion, notifyForOperations, notifyForFields);
    }

    /**
     * Creates the "WorkBugUpdates" PushTopic if it does not already exist
     * otherwise, a Debug message is logged.
     */
    public static void ensureBugPushTopic() {
        ensureWorkRecordTypePushTopic('WorkBugUpdates', 'Bug');
    }

    /**
     * Creates the "WorkUserStoryUpdates" PushTopic if it does not already exist
     * otherwise, a Debug message is logged.
     */
    public static void ensureUserStoryPushTopic() {
        ensureWorkRecordTypePushTopic('WorkUserStoryUpdates', 'User Story');
    }

    /**
     * Creates the "WorkToDoUpdates" PushTopic if it does not already exist
     * otherwise, a Debug message is logged.
     */
    public static void ensureToDoPushTopic() {
        ensureWorkRecordTypePushTopic('WorkToDoUpdates', 'ToDo');
    }

    /**
     * Creates the "WorkHistory" PushTopic if it does not already exist
     * otherwise, a Debug message is logged.
     */
    public static void ensureWorkHistoryPushTopic() {
        String name = 'WorkHistory';
        String query = 'select Id, Work__c, Sprint__c, Sprint_Old__c, LastModifiedDate from ADM_Work_History__c';
        Double apiVersion = 29.0;
        String notifyForOperations = 'All';
        String notifyForFields = 'All';
        query = COM_SoqlUtils.convertToQualifiedQuery(query);
        ADM_PushTopic.ensurePushTopic(name, query, apiVersion, notifyForOperations, notifyForFields);
    }

    private static void ensureWorkRecordTypePushTopic(String pushTopicName, String recordTypeName) {
        List<RecordType> recordTypes = [select Id from RecordType where Name = :recordTypeName];
        if(recordTypes.size() == 0) {
            throw new ADM_ApplicationException('Unable to find a record type with the name: ' + recordTypeName);
        }

        String name = pushTopicName;
        String query = 'select Id, Subject__c, Status__c, Story_Points__c, Theme__c, Scheduled_Build__c, Assignee__c, Scrum_Team__c, Sprint__c, LastModifiedDate from ADM_Work__c where RecordTypeId = \'' + recordTypes.get(0).Id + '\'';
        Double apiVersion = 29.0;
        String notifyForOperations = 'All';
        String notifyForFields = 'All';

        ADM_PushTopic.ensurePushTopic(name, query, apiVersion, notifyForOperations, notifyForFields);
    }

    private static String getUserWorkUserInterfaceType(Id userID) {
        try {
            User user =  [select Work_User_Interface__c from User where id = :userID];
            //lookup current users work interface setting
            if(user != null && !ADM_TextUtils.isBlank(user.Work_User_Interface__c)) {
               return user.Work_User_Interface__c;
            } else {
                return ADM_Work.DEFAULT_UI_TYPE;
            }
        } catch(Exception e) {
            System.debug('Exception retrieving user interface settings, default of:' + ADM_Work.DEFAULT_UI_TYPE + ' will be used e:' + e);
            return ADM_Work.DEFAULT_UI_TYPE;
        }
    }

    public static PageReference getWorkDetailPage(Id userID, RecordType currentRecordType) {
        String workUISetting = getUserWorkUserInterfaceType(userID);
        PageReference workDetailPage = null;
        boolean isSFXPagePreferred = ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
        try {
            if(isSFXPagePreferred &&
               (currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG ||
               currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY ||
               currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)){
                   if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG){
                       workDetailPage = Page.ADM_BugDetailSds;
                   }
                   else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY){
                       workDetailPage = Page.ADM_UserStoryDetailSds;
                   }
                   else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION){
                        workDetailPage = Page.ADM_InvestigationDetailSds;
                   }

            }else{
                        if(workUISetting == ADM_Work.UI_TYPE_CLASSIC) {
                       workDetailPage = Page.ADM_WorkDetail;
                    } else {
                        if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG ) {
                            workDetailPage =  Page.ADM_BugDetail;
                        } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY) {
                            workDetailPage =  Page.ADM_UserStoryDetail;
                        }
                        else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
                            workDetailPage =  Page.ADM_InvestigationDetail;
                        } else {
                            //only bugs and user stories have a next gen page all other record types will use ADM_WorkDetail
                            workDetailPage = Page.ADM_WorkDetail;
                        }
                    }
            }

        } catch(Exception e) {
            System.debug('Exception directing user to detail page.  Using ADM_WorkDetail as the default. e:' + e);
            workDetailPage = Page.ADM_WorkDetail;
        }
        workDetailPage.setRedirect(true);
        //preserve parameters
        workDetailPage.getParameters().putAll(System.currentPageReference().getParameters());
        return workDetailPage;
    }


    public static PageReference getWorkDeepClonePage(Id userID, RecordType currentRecordType) {
        PageReference deepClonePage = null;
        try {
                    deepClonePage=Page.ADM_WorkDeepClone;
         } catch(Exception e) {
            System.debug('Exception directing user to create/edit page.  No sensible default so we will have to throw an exception.  E:' + e);
            throw new ADM_ApplicationException('Unexpected exception when directing you to the correct create/edit page.  Exception:' + e);
         }
         deepClonePage.setRedirect(true);
         //preserve parameters
         deepClonePage.getParameters().putAll(System.currentPageReference().getParameters());
         return deepClonePage;
    }

    @AuraEnabled
    public static String getWorkCreateEditPage(String recordType) {
        RecordType recType = ADM_RecordType.getByName(recordType, 'ADM_Work__c');

        return getWorkCreateEditPage(UserInfo.getUserId(), recType).getUrl() + '?RecordType=' + recType.Id;
    }

    public static PageReference getWorkCreateEditPage(Id userID, RecordType currentRecordType) {
        String workUISetting = getUserWorkUserInterfaceType(userID);
        PageReference workCreateEditPage = null;
        boolean isSFXPagePreferred = ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
       try {
           if(isSFXPagePreferred &&
              (currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG ||
              currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY||
               currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)){
                  if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG){
                      workCreateEditPage = Page.ADM_BugEditSds;
                  } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY ){
                      if(workUISetting.equalsIgnoreCase(ADM_Work.UI_TYPE_CUSTOM_LIGHTNING)) {
                         workCreateEditPage = Page.ADM_UserStoryEditSds;//Temporarily defaulting it to Sds page while we make the LEX page production ready.
                      } else {
                          workCreateEditPage = Page.ADM_UserStoryEditSds;
                      }

                  }else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION){
                        workCreateEditPage = Page.ADM_InvestigationEditSds;
                  }

           } else{
                   if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG) {
                       if(workUISetting == ADM_Work.UI_TYPE_CLASSIC) {
                           workCreateEditPage = Page.ADM_WorkEditBug;
                       } else {
                           workCreateEditPage = Page.ADM_BugEdit;
                       }
                   } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY) {
                       if(workUISetting == ADM_Work.UI_TYPE_CLASSIC) {
                           workCreateEditPage = Page.ADM_WorkEditUserStory;
                       } else {
                           workCreateEditPage = Page.ADM_UserStoryEdit;
                       }
                   } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_TODO) {
                       workCreateEditPage = Page.ADM_WorkEditToDo;
                   } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
                       if(workUISetting == ADM_Work.UI_TYPE_CLASSIC) {
                           workCreateEditPage = Page.ADM_WorkEditInvestigation;
                       } else {
                           workCreateEditPage = Page.ADM_InvestigationEdit;
                       }

                   } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_TEMPLATE) {
                       workCreateEditPage = Page.ADM_WorkEditTemplate;
                   } else {
                       throw new ADM_ApplicationException('Unsupported record type specified: ' + currentRecordType.Name );
           }
           }

        } catch(Exception e) {
           System.debug('Exception directing user to create/edit page.  No sensible default so we will have to throw an exception.  E:' + e);
           throw new ADM_ApplicationException('Unexpected exception when directing you to the correct create/edit page.  Exception:' + e);
        }
        workCreateEditPage.setRedirect(true);
        //preserve parameters
        if (System.currentPageReference() != null && System.currentPageReference().getParameters() != null) {
            workCreateEditPage.getParameters().putAll(System.currentPageReference().getParameters());
        }
        return workCreateEditPage;
   }


   public static PageReference getIndependentWorkCreateOrEditPage(Id userID, RecordType currentRecordType, Boolean newRecord) {

       String workUISetting = getUserWorkUserInterfaceType(userID);
       PageReference workCreateEditPage = null;
       boolean isSFXPagePreferred = ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
        try {
            if(isSFXPagePreferred &&
               (currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG ||
               currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY||
                currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)){
                   if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG){
                       workCreateEditPage = Page.ADM_BugEditSds;
                  } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY ){
                      if(workUISetting.equalsIgnoreCase(ADM_Work.UI_TYPE_CUSTOM_LIGHTNING)) {
                          //currently we only support the custom lex page for edit actions due to a bug with force:inputField preventing us sharing with create actions like usual
                          if(newRecord) {
                             workCreateEditPage = Page.ADM_UserStoryEditSds;
                          } else {
                             workCreateEditPage = Page.ADM_UserStoryEditSds;//Temporarily defaulting it to Sds page while we make the LEX page production ready.
                   }

                      } else {
                       workCreateEditPage = Page.ADM_UserStoryEditSds;
                   }

                  }else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION){
                         workCreateEditPage = Page.ADM_InvestigationEditSds;
                    }

           } else{
                    if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_BUG) {
                        if(workUISetting == ADM_Work.UI_TYPE_CLASSIC) {
                            workCreateEditPage = Page.ADM_WorkEditBug;
                        } else {
                            workCreateEditPage = Page.ADM_BugEdit;
                        }
                    } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_USERSTORY) {
                        if(workUISetting == ADM_Work.UI_TYPE_CLASSIC) {
                            workCreateEditPage = Page.ADM_WorkEditUserStory;
                        } else {
                            workCreateEditPage = Page.ADM_UserStoryEdit;
                        }
                    } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_TODO) {
                        workCreateEditPage = Page.ADM_WorkEditToDo;
                    } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
                        if(workUISetting == ADM_Work.UI_TYPE_CLASSIC) {
                            workCreateEditPage = Page.ADM_WorkEditInvestigation;
                        } else {
                            workCreateEditPage = Page.ADM_InvestigationEdit;
                        }

                    } else if(currentRecordType.Name == ADM_Work.RECORD_TYPE_NAME_TEMPLATE) {
                        workCreateEditPage = Page.ADM_WorkEditTemplate;
                    } else {
                        throw new ADM_ApplicationException('Unsupported record type specified: ' + currentRecordType.Name );
                    }
            }

         } catch(Exception e) {
            System.debug('Exception directing user to create/edit page.  No sensible default so we will have to throw an exception.  E:' + e);
            throw new ADM_ApplicationException('Unexpected exception when directing you to the correct create/edit page.  Exception:' + e);
         }
         workCreateEditPage.setRedirect(true);
        //preserve parameters
        if (System.currentPageReference() != null && System.currentPageReference().getParameters() != null) {
            workCreateEditPage.getParameters().putAll(System.currentPageReference().getParameters());
        }
        return workCreateEditPage;
    }

    /**
     * Gets the product tag for the specified tag name, team name and record type
    */
    private static ADM_Product_Tag__c findProductTag(String tagName, String teamName, String recordType) {
        try {
            List<ADM_Product_Tag__c> tags = [select id from ADM_Product_Tag__c where Active__c = true and Name =:tagName and Team__r.Name =:teamName and Id in (select Product_Tag__c from ADM_Tag_Assignment__c where Record_Type__c = :recordType) limit 1];
            if(tags.isEmpty()) {
                return null;
            } else {
                return tags.get(0);
            }
        } catch(Exception e) {
            System.debug('WorkControllerExtension evalProductTag() exception retrieving tag {tagName:' + tagName + ',teamName:' + teamName + ',recordType:' + recordType + '} error:' + e);
        }
        return null;
    }

    /* WorkDialog component might sent String name or Id for some auto complete fields
    Check value to make sure Id is sent from the component or get Id from system using the name passed in*/
    public static ADM_Work__c convertNameToIdForAutoCompleteFields(ADM_Work__c work){
        SObject workSObject = (SObject)work;
        for(String fieldName:WORK_AUTO_COMPLETE_FIELDS){
                String fieldValue = (String)workSObject.get(fieldName);
                //Escaping single quotes because it causes an error on save. Check for null since method throws an exception if text is null.
                if(fieldValue!=null && fieldValue != ''){
                    fieldValue = String.escapeSingleQuotes(fieldValue);
                }
                if(!ADM_TextUtils.isValidId(fieldValue)){
                    //passed in value is not id getting it from the system.

                    List<Id> idFromNameList = getIdFromName(fieldValue, fieldName);
                    if(idFromNameList.size() >1 ){
                        workSObject.addError('Found more than one match for ' + getFieldLabel(fieldName) + ' for input string '+ fieldValue);
                    }
                    else{
                        if(idFromNameList.size() == 1 ){
                            System.debug(' converting string value of '+ fieldName + ' from ' + fieldValue + ' to ' + idFromNameList[0]);
                            workSObject.put(fieldName, idFromNameList[0]);
                        }
                        workSObject.addError(' Cannot find value matching for ' + getFieldLabel(fieldName) + ' for input string '+ fieldValue);
                    }

                }
        }

        return (ADM_Work__c)workSObject;
    }

    private static List<Id> getIdFromName(String name, String field){
        String soql = 'Select id from ';
        String sObjectType = fieldToSObjectType.get(field);
        if(null == sObjectType){
            return null;
        }
        soql += sObjectType;
        String whereCaluse = ' where name = ' + '\'' + name +'\'';
        if(sObjectType == 'User'){
            whereCaluse += ' and isActive=true';
        }
        soql += whereCaluse;

        List<SObject> results = Database.query(soql);
        List<Id> idsFound = new List<Id>();
        for(SObject iter: results){
            idsFound.add(iter.Id);
        }
        return idsFound;
    }

    public class WorkEditorDialogMetaData {
        public ADM_Work__c workSObject;
        public List<String> bugStatuses;
        public List<String> userStoryStatuses;
        public List<String> investigationStatuses;
        public List<String> storyPoints;
        public List<ADM_Impact__c> impacts;
        public List<ADM_Frequency__c> frequencies;
        public List<ADM_Priority_Mapping__c> priorityMappings;
        public List<String> priorities;
         public List <String> severities;
         public List<String> helpStatuses;
        public List<ADM_ColumnUtility.LeafNodeDetails> leafNodeDetailsList;

    }



    /**
     * Test that makes sure a PushTopic is created when no other PushTopic already
     * exists.
     */
    private void testEnsureWorkUpdatesPushTopicWithoutExisting() {

        //ensure that the push topic is not already created
        delete [select Id from PushTopic where Name = 'WorkUpdates'];

        //create the push topic
        ensureWorkUpdatesPushTopic();

        List<PushTopic> pushTopics = [select Id, Name from PushTopic where Name = 'WorkUpdates'];
        System.assertEquals(1, pushTopics.size(), 'Expected the WorkUpdates PushTopic to be created');
    }

    /**
     * Test that makes sure calling ensureWorkUpdatesPushTopic does not fail when
     * a PushTopic already exists.
     */
    private void testEnsureWorkUpdatesPushTopicWithExisting() {

        //ensure that the push topic is not already created
        delete [select Id from PushTopic where Name = 'WorkUpdates'];

        //create a push topic with the work updates name
        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = 'WorkUpdates';
        pushTopic.Query = 'select Id, Name from ADM_Work__c';
        pushTopic.ApiVersion = 25.0;
        pushTopic.NotifyForOperations = 'All';
        pushTopic.NotifyForFields = 'Referenced';
        insert pushTopic;

        //create the push topic
        ensureWorkUpdatesPushTopic();

        List<PushTopic> pushTopics = [select Id, Name, Query from PushTopic where Name = 'WorkUpdates'];
        System.assertEquals(1, pushTopics.size(), 'Expected the WorkUpdates PushTopic to be created');
        //System.assertEquals(pushTopic.Query, pushTopics.get(0).Query, 'Expected the query not to change during the call to ensureWorkUpdatesPushTopic');
    }

    static testMethod void testFindProductTag(){

        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Product_Tag__c proTag = ADM_ProductTag.createAndInsertProductTagForTeam(team);

        RecordType recordType = ADM_RecordType.getByName('Bug', 'ADM_Work__c');

        ADM_Tag_Assignment__c tagAsgnmt = ADM_TagAssignment.createAndInsertTagAssignment(proTag, recordType);


        Test.startTest();
        team = ADM_ScrumTeam.getAll(team.Id)[0];
        proTag = ADM_ProductTag.get(proTag.Id);
        ADM_Product_Tag__c actualProductTag = ADM_Work.findProductTag(proTag.Name, team.Name, recordType.Name);
        Test.stopTest();

        System.assert(null != actualProductTag, 'Expected Product Tag to be not null');
        System.assertEquals(proTag.Id,actualProductTag.id);
    }

    public static Set<Id> buildUserIdsFromWorks(List<ADM_Work__c> works) {
        Set<Id> userIds = new Set<Id>();


        for(ADM_Work__c work : works) {
            userIds.add(work.Assignee__c);
            userIds.add(work.QA_Engineer__c);
            userIds.add(work.UE_Engineer__c);
            userIds.add(work.Tech_Writer__c);
            userIds.add(work.Product_Owner__c);
            userIds.add(work.System_Test_Engineer__c);
            userIds.add(work.Senior_Management_POC__c);
        }

        return userIds;
    }


    public static List<SaveWorksError> saveWorks(String origin, List<ADM_Work__c> works, boolean allOrNone) {
        List<SaveWorksError> saveWorksErrorArray = new List<SaveWorksError>();
        if(ADM_SchemaManager.isObjectUpdateable('ADM_Work__c')){
            if(works != null) {
                for(ADM_Work__c work: works) {
                    if(origin != null){
                        work.Origin__c = origin;
                    }
                }

                Database.Saveresult[] results = Database.update(works, allOrNone);
                Integer counter = 0;
                List<Id> failedIds = new List<Id>();
                for(Database.Saveresult result : results) {
                    if(!result.isSuccess()) {
                        failedIds.add(works[counter].Id);
                    }
                    counter++;
                }

                //Getting details of DML failed works
                List<ADM_Work__c> saveFailedWorks = ADM_Work.getAllById(failedIds);
                Map<Id, ADM_Work__c> saveFailedWorksMap = new Map<Id, ADM_Work__c>();

                for(ADM_Work__c saveFailedWork : saveFailedWorks){
                    saveFailedWorksMap.put(saveFailedWork.Id, saveFailedWork);
                }
                counter = 0;
                for(Database.Saveresult result : results) {
                    if(!result.isSuccess()) {
                        SaveWorksError swr = new SaveWorksError();
                        swr.work = saveFailedWorksMap.get(works[counter].Id);//result.getId() will be null for DML exception/errors
                        swr.errorMessages = new List<String>();
                        for(Database.Error error : result.getErrors()) {
                            swr.errorMessages.add(error.getMessage());
                        }
                        saveWorksErrorArray.add(swr);
                    }
                    counter++;
                }
            }
        }
        else{
            System.debug('Current user has no update access to ADM_Work__c');
            throw new ADM_ApplicationException('User has insufficient permission to perform this operation on ADM_Work__c');
        }
        return saveWorksErrorArray;
    }


    public class SaveWorksError{
        ADM_Work__c work;
        List<String> errorMessages;
    }
}