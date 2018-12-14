/** This class contains utils for creating test data for SLA Violations tests in other classes.
    It doesn't contain any actual test methods itself.
   */

@isTest
public class ADM_WorkSLATestData {

    // Current SLA settings https://sites.google.com/a/salesforce.com/support-technology-escalations/
    public static final Long MIN_IN_MILLISEC = 60 * 1000L;
    public static final Long HOUR_IN_MILLISEC = 60 * MIN_IN_MILLISEC;   
    
    public static final Long ACK_TIME_SEV1 = 7 * MIN_IN_MILLISEC;
    public static final Long ACK_TIME_SEV2 = 4 * HOUR_IN_MILLISEC;
    public static final Long ACK_TIME_SEV3 = 8 * HOUR_IN_MILLISEC;
    
    public static final Long UPDATE_TIME_SEV1 = 1 * HOUR_IN_MILLISEC;
    public static final Long UPDATE_TIME_SEV2 = 8 * HOUR_IN_MILLISEC;
    public static final Long UPDATE_TIME_SEV3 = 16 * HOUR_IN_MILLISEC;
    
    public static final String WORK_STATUS_NEW = 'New';
    public static final String WORK_STATUS_ACKNOWLEDGED = 'Acknowledged';
    public static final String WORK_STATUS_INVESTIGATING = 'Investigating';
    public static final String WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT = 'More Info Reqd from Support';
    public static final String WORK_STATUS_REJECTED = 'Rejected';
    public static final String WORK_STATUS_WAD = 'Closed - No Fix - Working as Designed';
    public static final String WORK_STATUS_DEFUNCT = 'Closed - Defunct';
    public static final String WORK_STATUS_NEWBUGLOGGED = 'Closed - New Bug Logged';
        
    
    public static final String SEV1 = '1';
    public static final String SEV2 = '2';
    public static final String SEV3 = '3';
    public static final String SEV4 = '4';
    
    public static final String USER_PROFILE_APIONLY = 'GUS API ONLY CRUD BY PERM SET';
    public static final String USER_PROFILE_SUPPORT = 'GUS Customer Support User';
    public static final String USER_PROFILE_STANDARDUSER = 'GUS User';
    
    public static final String INVESTIGATION_DEFAULT_STATUS = WORK_STATUS_NEW;
    public static final String INVESTIGATION_DEFAULT_SEV_LEVEL = SEV3;
    
    public static final Map<String, Long> ACK_TIME_MAP = new Map<String, Long>();
    static {
        ACK_TIME_MAP.put(SEV1, ACK_TIME_SEV1);
        ACK_TIME_MAP.put(SEV2, ACK_TIME_SEV2);
        ACK_TIME_MAP.put(SEV3, ACK_TIME_SEV3);
    }
    
    private static final Map<String, Long> UPDATE_TIME_MAP = new Map<String, Long>();
    static {
        UPDATE_TIME_MAP.put(SEV1, UPDATE_TIME_SEV1);
        UPDATE_TIME_MAP.put(SEV2, UPDATE_TIME_SEV2);
        UPDATE_TIME_MAP.put(SEV3, UPDATE_TIME_SEV3);
    }
    private static BusinessHours defaultBusinessHours;
    private static BusinessHours nonDefaultBusinessHours;
    
    private static ADM_Product_Tag__c productTag;
    private static ADM_Impact__c impact;
    private static ADM_Priority__c priority;
    private static ADM_Build__c build;
    private static Map<String,RecordType> recordTypesMap = new Map<String,RecordType>();
    private static User apiOnlyUser;
    private static User standardUser;
    private static User supportUser;
    private static User businessHoursUser;


    public static void setupTestData() {
        BusinessHours nonDefaultBhs = ADM_WorkSLATestData.getNonDefaultBusinessHours();
        boolean hasNonDefaultBHs = (nonDefaultBhs!=null);  // does org have a second business hours defined?

        //System.debug('nonDefaultBhs.Id='+nonDefaultBhs.Id);
        //System.debug('defaultBhs.Id='+ADM_WorkSLATestData.getDefaultBusinessHours().Id);

        ADM_Scrum_Team__c teamWithDefaultBHS = ADM_WorkSLATestData.createTeamWithBHS(ADM_WorkSLATestData.TEAMNAME_WITH_DEFAULT_BUSINESS_HOURS, ADM_WorkSLATestData.getDefaultBusinessHours().Id, false);
        ADM_Scrum_Team__c teamWithoutBHS = ADM_WorkSLATestData.createTeamWithBHS(ADM_WorkSLATestData.TEAMNAME_WITHOUT_BUSINESS_HOURS, null, false);
        List<ADM_Scrum_Team__c> teamsToInsert = new List<ADM_Scrum_Team__c> {
                teamWithDefaultBHS,
                teamWithoutBHS
            };

        ADM_Scrum_Team__c teamWithNonDefaultBHS = null;
        if (hasNonDefaultBHs) {
            teamWithNonDefaultBHS = ADM_WorkSLATestData.createTeamWithBHS(ADM_WorkSLATestData.TEAMNAME_WITH_NONDEFAULT_BUSINESS_HOURS, nonDefaultBhs.Id, false);
            teamsToInsert.add(teamWithNonDefaultBHS);
        }
        insert teamsToInsert;
        
        for (ADM_Scrum_Team__c t : teamsToInsert) {
            ADM_ProductTag.createAndInsertProductTagForTeam(t);
        }
        ADM_Build.createTestBuild('Test' + String.valueOf(Math.random()));
        insert new ADM_Impact__c(Name=String.valueOf(Math.random()));
        insert new ADM_Priority__c(Name='priority');
        
        User userWithBusinessHours = createUser('businesshours', 'TestUser', null, USER_PROFILE_STANDARDUSER);
        
        insert new List<User> {
            userWithBusinessHours,
            createUser('standard', 'TestUser', null, USER_PROFILE_STANDARDUSER),
            createUser('support', 'TestUser', null, USER_PROFILE_SUPPORT),
            createUser('apionly', 'TestUser', null, USER_PROFILE_APIONLY)
        };
        
        if(userWithBusinessHours != null && nonDefaultBhs != null) {
            insert new ADM_User_Business_Hours__c(User__c = userWithBusinessHours.Id, Business_Hours__c = nonDefaultBhs.Id); // ADM_WorkSLATestData.getDefaultBusinessHours().Id);  
        }
            
    }
    
    public static BusinessHours getDefaultBusinessHours() {
        if (defaultBusinessHours==null) defaultBusinessHours = [SELECT Id, Name, IsDefault FROM BusinessHours WHERE IsDefault = true];
        return defaultBusinessHours;
    }
    
    public static BusinessHours getNonDefaultBusinessHours() {
        if (nonDefaultBusinessHours==null) {
            List<BusinessHours> hours = [SELECT Id, Name, IsDefault FROM BusinessHours WHERE IsDefault = false AND Name LIKE 'Europe/Ireland%' LIMIT 1];
            if(hours != null && hours.size() > 0) {
                nonDefaultBusinessHours = hours.get(0);
            }
        }
        return nonDefaultBusinessHours;
    }

    public static ADM_Impact__c getImpact() {
        if (impact==null) impact = [SELECT Id FROM ADM_Impact__c LIMIT 1];
        return impact;
    }
    
    public static ADM_Priority__c getPriority() {
        if (priority==null) priority = [SELECT Id FROM ADM_Priority__c LIMIT 1];
        return priority;
    }

    public static ADM_Product_Tag__c getProductTag() {
        if (productTag==null) productTag = [SELECT Id FROM ADM_Product_Tag__c LIMIT 1];
        return productTag;
    }
    
    public static ADM_Build__c getBuild() {
        if (build==null) build = [SELECT Id FROM ADM_Build__c LIMIT 1];
        return build;
    }
    
    public static RecordType getRecordTypeFor(String recordTypeName) {
        RecordType recordType = recordTypesMap.get(recordTypeName);
        if (recordType==null && !recordTypesMap.containsKey(recordTypeName)) {
            recordType = [SELECT Id, Name FROM RecordType WHERE Name = :recordTypeName ];
            recordTypesMap.put(recordTypeName, recordType);
        }
        return recordType;
    }
    
    public static User getStandardUser() {
        if (standardUser==null) loadUsers();
        return standardUser;
    }
    
    public static User getBusinessHoursUser() {
        if (businessHoursUser==null) loadUsers();
        return businessHoursUser;
    }
    
    public static User getSupportUser() {
        if (supportUser==null) loadUsers();
        return supportUser;
    }
    
    public static User getAPIOnlyUser() {
        if (apiOnlyUser==null) loadUsers();
        return apiOnlyUser;
    }
    
    private static void loadUsers() {
        List<User> testUsers = [SELECT Id,Name,Firstname,Lastname,Email,ProfileId
                                FROM User
                                WHERE lastname = 'TestUser'
                                  AND (firstname = 'standard'
                                       OR firstname = 'support'
                                       OR firstname = 'apionly'
                                       OR firstname = 'businesshours')];
        for (User u : testUsers) {
            if (u.firstname == 'standard') {
                standardUser = u;
            } else if (u.firstname == 'support') {
                supportUser = u;
            } else if (u.firstname == 'apionly') {
                apiOnlyUser = u;
            } else if (u.firstname == 'businesshours') {
                businessHoursUser = u;
            }
        }
    }
    
    /**
    * Create an Investigation with proper severty level
    * @param severityLevel The severity level of the investigation
    * @return New investigation
    */
    public static ADM_Work__c createInvestigationWithSevLevel(String severityLevel){
        return createMockInvestigation(severityLevel, null, null, null);
    }
    
    public static ADM_Work__c createMockInvestigation(String severityLevel, String status, Id teamId, DateTime slaDueTime) {
        
        ADM_Work__c investigation =  new ADM_Work__c();
        
        //investigation.Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
        investigation.RecordType = getRecordTypeFor(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        investigation.RecordTypeId = getRecordTypeFor(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION).Id;
        investigation.Status__c = status;
        investigation.Scrum_Team__c = teamId;
        investigation.Severity_Level__c = severityLevel;
        investigation.Due_Date__c = slaDueTime;
        
        return investigation;
    }
    
    public static ADM_Work__c createInvestigation(String severityLevel, String status, Id teamId, DateTime slaDueTime, Boolean doInsert){
        
        ADM_Work__c investigation =  new ADM_Work__c();
       
        investigation.CS_Contact__c = Userinfo.getUserId();
        investigation.Details_and_Steps_to_Reproduce__c = 'details and steps to reproduce';
        //investigation.Type__c = ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
        investigation.RecordType = getRecordTypeFor(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        investigation.RecordTypeId = getRecordTypeFor(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION).Id;
        investigation.Assignee__c = getStandardUser().Id;
        investigation.CS_Contact__c = getSupportUser().Id;
        investigation.Severity_Level__c = severityLevel;
        investigation.Subject__c = 'Test ADM_WorkSLAMonitoringHelper';
        investigation.Scrum_Team__c = teamId;
        
        investigation.Priority__c = getPriority().Id;
        investigation.Product_Tag__c = getProductTag().Id;
        investigation.Found_in_Build__c = getBuild().Id;
        investigation.Impact__c = getImpact().Id;
        
        
        if(status == null){
            investigation.Status__c = INVESTIGATION_DEFAULT_STATUS;
        } else {
            investigation.Status__c = status;
        }
        
        if(severityLevel == null){
            investigation.Severity_Level__c = INVESTIGATION_DEFAULT_SEV_LEVEL;
        } else {
            investigation.Severity_Level__c = severityLevel;
        }
        
        if(doInsert == true){
            insert investigation;
        }
        
        // set this ater insert -- do not save this SLA Due Time to the DB
        investigation.Due_Date__c = slaDueTime;
        
        return investigation;
    }
    
    public static ADM_Case__c createCaseForWork(Id workId) {
        ADM_Case__c org62case = new ADM_Case__c();
        org62case.Work__c = workId;
        //org62case.Case_ID__c = generateRandomString(100);
        //org62case.Account_Id__c = generateRandomString(50);
        //org62case.External_ID__c = System.now().getTime().format();
        
        return org62Case;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    
    public static ADM_Scrum_Team__c createTeamWithBHS(String name, Id bhsId, Boolean doInsert){
        ADM_Scrum_Team__c team = new ADM_Scrum_Team__c();
        team.Name = name;
        team.Cloud__c = 'Chatter';
        team.Team_Home_Page__c = 'salesforce.com';
        team.recordtypeid = getRecordTypeFor(ADM_ScrumTeam.RECORD_TYPE_NAME_SCRUM_TEAM).id; // getScrumTeamRecordType().id; 
        team.Active__c = true;
        team.Business_Hours__c = bhsId;
        if(doInsert == true){
            insert team;
        }
        return team;
    }
    
    private static RecordType scrumTeamRecordType;
    private static RecordType getScrumTeamRecordType() {
         if (scrumTeamRecordType==null) scrumTeamRecordType = [select id from RecordType where name =:ADM_ScrumTeam.RECORD_TYPE_NAME_SCRUM_TEAM LIMIT 1];
         return scrumTeamRecordType;
    }
    
    
    /**
    * Return a test user for given profile
    * 
    * @param profileName the profile name of the test user
    */    
    public static User setupUserwithProfile(String profileName, String userName){
        return createUser('standard', 'testing', userName, profileName);
    }
    
    public static User createUser(String firstname, String lastname, String username, String profileName) {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name= :profileName];
        Profile p = null;
        if(profiles != null && profiles.size() > 0 ) {
            p = profiles.get(0);   
        } else {
            //prefrered profile not available.  Only profile guarenteed to exist is sys admin
            p = [SELECT Id FROM Profile WHERE Name= 'System Administrator'];
        }   
        String email = (username==null) ? (firstname + lastname + '@company.com') : username;
        
        return new User(FirstName=firstname,
                        LastName=lastname,
                        Username=email,
                        Email=email,
                        Alias=(firstname + lastname).substring(0,7),
                        CommunityNickname=(firstname + lastname).substring(0,7),
                        ProfileId=p.Id,
                        LocaleSidKey='en_US',
                        LanguageLocaleKey='en_US',
                        TimeZoneSidKey='America/Los_Angeles',
                        EmailEncodingKey='UTF-8');
    }
    
    private static TeamsWithBusinessHours teamsWithBH;
    
    public static TeamsWithBusinessHours getTeamsWithBusinessHours() {
        if (teamsWithBH==null) teamsWithBH = new TeamsWithBusinessHours();
        return teamsWithBH;
    }
    
    public final static String TEAMNAME_WITH_DEFAULT_BUSINESS_HOURS = 'TeamWithDefaultBHS';
    public final static String TEAMNAME_WITHOUT_BUSINESS_HOURS = 'TeamWithoutBHS';
    public final static String TEAMNAME_WITH_NONDEFAULT_BUSINESS_HOURS = 'TeamWithNonDefaultBHS';
    
        
    public class TeamsWithBusinessHours {
        public ADM_Scrum_Team__c teamWithDefaultBHS;
        public ADM_Scrum_Team__c teamWithoutBHS;
        public ADM_Scrum_Team__c teamWithNonDefaultBHS;
        
        public Set<Id> teamIds = new Set<Id>();
        
        private TeamsWithBusinessHours() {
            List<ADM_Scrum_Team__c> teamsWithBHs = [SELECT Id, Name, Business_Hours__c
                                             FROM ADM_Scrum_Team__c
                                             WHERE Name = :TEAMNAME_WITH_DEFAULT_BUSINESS_HOURS
                                                OR Name = :TEAMNAME_WITHOUT_BUSINESS_HOURS
                                                OR Name = :TEAMNAME_WITH_NONDEFAULT_BUSINESS_HOURS];
            
            for (ADM_Scrum_Team__c t : teamsWithBHs) {
                if (TEAMNAME_WITH_DEFAULT_BUSINESS_HOURS.equals(t.name)) {
                    teamWithDefaultBHS = t;
                } else if (TEAMNAME_WITHOUT_BUSINESS_HOURS.equals(t.name)) {
                    teamWithoutBHS = t;
                } else if (TEAMNAME_WITH_NONDEFAULT_BUSINESS_HOURS.equals(t.name)) {
                    teamWithNonDefaultBHS = t;
                }
            }
            
            teamIds.add(teamWithDefaultBHS.Id);
            teamIds.add(teamWithoutBHS.Id);
            if (teamWithNonDefaultBHS!=null) {
                teamIds.add(teamWithNonDefaultBHS.Id);
            }
        }
        
    }
}