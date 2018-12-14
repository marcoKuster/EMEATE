global class ADM_WorkUser {
    private static final String FIELD_NAMES = 'Id, Alias, FirstName, LastName, Email, UserName , Show_All_Work_Comments__c, Name, Profile.Name, ProfileId, Notification_Level__c, FederationIdentifier';
    private static final String FIELD_NAMES_WITHOUT_FEDERATION_ID = 'Id, Alias, FirstName, LastName, Email, UserName , Show_All_Work_Comments__c, Name, Profile.Name, ProfileId, Notification_Level__c';
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_SELECT2 = 'select ' + FIELD_NAMES_WITHOUT_FEDERATION_ID + ' ';
    private static final String SQL_FROM = 'from User';

    private static Id systemAdministratorProfileId;
    public static final String TEST_USERNAME = 'tuser@gus.com';
    public static final String TEST_FIRST_NAME = 'Test';
    public static final String TEST_LAST_NAME = 'User';
    public static final String TEST_EMAIL = 'gusteam@salesforce.com';

    public static final String SIXTY_TWO_ORG_USERNAME_PREFIX = '62Org';

    public static User[] getAllBy(String columnName, List<String> columnValues, Integer rowStart, Integer rowEnd, String sortBy, String sortOrder) {
        User[] users = new User[0];

        String inColumnValues = COM_SoqlUtils.createInClause(columnName, columnValues);
        users = queryUserObject(inColumnValues,rowStart,rowEnd,sortBy,sortOrder);
        return users;
    }
    /*
        Sample of expected input map with values... This is to avoid multiple SOQL queries and to
        dynamically create query with id and non id values...

        columnNameToValueMap.put('id', new Set<String>{'005235553353535'});
        columnNameToValueMap.put('username,email,alias',new Set<String>{'am','pm','gm','cm'});

    */
    public static User[] getAllBy(Map<String,Set<String>> columnNameToValueMap, Integer rowStart, Integer rowEnd, String sortBy, String sortOrder) {
        User[] users = new User[0];


        String inColumnValues = '';
        for(String columNameKeyFromMap:columnNameToValueMap.keySet()) {
                for(String columnName:columNameKeyFromMap.split(',')) {
                    inColumnValues+= ((''.equals(inColumnValues))?' (' : ' or ') + COM_SoqlUtils.createInClause(columnName, columnNameToValueMap.get(columNameKeyFromMap));
                }
        }
        inColumnValues += ')';

        users = queryUserObject(inColumnValues,rowStart,rowEnd,sortBy,sortOrder);


        return users;
    }

    private static User[] queryUserObject(String inColumnValues, Integer rowStart, Integer rowEnd, String sortBy, String sortOrder){
        User[] users = new User[0];

        String sql = getSOQLQueryForUsers(inColumnValues, sortBy, sortOrder);

        try{

            Integer i = 0;
            List<User> userResult = Database.query(sql);
            for(User user : userResult) {
                i++;
                if(i >= rowStart && i <= rowEnd) {
                    users.add(user);
                }
            }
        } catch(System.Exception e) {
            System.debug('Exception occured' + e);
        }
        return users;
    }

    public static User get(String columnValue) {
        List<User> users = getAllBy('ID', new List< String >{columnValue}, 0, 1, 'Id', 'asc');
        if(users.size() == 0) {
            return null;
        } else {
            return users.get(0);
        }
    }

    WebService static String getProfileName(String pid) {
        try{

            Profile p = [ select Name from Profile Where Id =: pid ];
            return p.Name;
        }
        catch(System.QueryException e) {
            return '';
        }
    }

    public static User[] getUsers(String columnName, Set<String> columnValues) {
        return getAllBy(columnName, new List<String>(columnValues), 0, 1000, 'Id', 'asc');
    }

    public static User[] getUsers(String columnName, Set<String> columnValues, Integer rowEnd) {
        return getAllBy(columnName, new List<String>(columnValues), 0, rowEnd, 'Id', 'asc');
    }

    public static User[] getUsers(Map<String,Set<String>> columnNameToValueMap){
        return getAllBy(columnNameToValueMap, 0, 10000, 'Id', 'asc');
    }

    public static User[] getUsers(String columnName, List< String> columnValues) {
        return getAllBy(columnName, columnValues, 0, 1000, 'Id', 'asc');
    }

    public static Map<String, User> convertUserListToUserIdentifierMap(List<User> users) {
        Map<String, User> userMap = new Map<String, User>();
        for(User u : users) {
            userMap.put(u.alias, u);
            userMap.put(u.username, u);
            userMap.put(u.email, u);
            String usernamePrefix = u.username.substring(0, u.username.indexOf('@')); //grab user name prefix without the @org part
            userMap.put(usernamePrefix, u);
        }
        return userMap;
    }

    public static User[] getByAnyUserIdentification(Set<String> userIdentification) {
        User[] users = null;

        try{
            users = [
                select Id, Alias, FirstName, LastName, Name, Email, UserName , Show_All_Work_Comments__c
                from User
                where(
                    Alias in :userIdentification
                    or UserName in :userIdentification
                    or Email in :userIdentification
               )
                    and IsActive = true
            ];
        } catch(System.Exception e) {
            users = new User[0];
        }
        return users;
    }

    public static Boolean verify(String uid) {
        return [select count() from User where Id =: uid] == 1;
    }

    /**
     * Determines if the given user is the special Email2GUS user account.
     */
    public static Boolean isEmail2GusUser(User user) {
        return user.Name.toLowerCase().contains('email2gus');
    }


    public Static String customerSupportUser {
        get {
            return 'GUS Customer Support User';
        }
        set;
    }

    private static Id getSystemAdministratorProfileId() {
        if(systemAdministratorProfileId == null) {
            systemAdministratorProfileId = [select id from Profile where Name = 'System Administrator'].id;
        }
        return systemAdministratorProfileId;
    }

     @IsTest
    public static User createTest62Orguser() {
        User user;
        List<User> users = [select id from User where Name = '62 Org'];
        if(users == null || users.size() == 0) {
            user = new User();
            user.FirstName = '62';
            user.LastName = 'Org';
            user.Alias = 'new62';
            user.Email = 'gusteam@salesforce.com';
            user.TimeZoneSidKey = 'America/Los_Angeles';
            user.LocaleSidKey = 'en_US';
            user.EmailEncodingKey = 'ISO-8859-1';
            user.ProfileId = getSystemAdministratorProfileId();
            user.LanguageLocaleKey = 'en_US';
            user.CommunityNickname = user.Alias;
            String userSuffix = Userinfo.getOrganizationName().replace(' ', '');
            user.UserName = user.FirstName + user.LastName + '@' + userSuffix + '.com';
            //DML is allowed on the user object for later API versions
            Database.insert(user);
        } else {
            user = users.get(0);
        }
        return user;
    }

     @IsTest
    public static User setupTestUser() {
        User user = new User(Username = TEST_USERNAME + Math.random(), //username has to be unique across all tests
                            FirstName = TEST_FIRST_NAME,
                            LastName = TEST_LAST_NAME + Math.random(),
                            Email = TEST_EMAIL,
                            Alias = 'test',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1',
                            EmployeeNumber = String.valueOf(Math.random()*1000000).right(6),
                            ProfileId = getSystemAdministratorProfileId(), //only safe to assume the Sys Admin profile exists
                            LanguageLocaleKey = 'en_US');
        return user;
    }

   @TestVisible
    public static User setupTestInactiveUser() {
        User user = new User(Username = TEST_USERNAME + Math.random(), //username has to be unique across all tests
                            FirstName = TEST_FIRST_NAME,
                            LastName = TEST_LAST_NAME + Math.random(),
                            Email = TEST_EMAIL,
                            Alias = 'test',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1',
                            IsActive = false,
                            ProfileId = getSystemAdministratorProfileId(), //only safe to assume the Sys Admin profile exists
                            LanguageLocaleKey = 'en_US');
        return user;
    }

    //helper method to dynamically create user.  prevents unit tests relying on existing records
    @IsTest
    public static User createTestUser() {
         User user = new User(Username = TEST_USERNAME + Math.random(), //username has to be unique across all tests
                            FirstName = TEST_FIRST_NAME,
                            LastName = TEST_LAST_NAME,
                            Email = TEST_EMAIL,
                            Alias = 'test',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1',
                            ProfileId = getSystemAdministratorProfileId(), //only safe to assume the Sys Admin profile exists
                            LanguageLocaleKey = 'en_US',
                            EmployeeNumber = String.valueOf(Math.random()*1000000).right(6),
                            IsActive = true);

        //DML is allowed on the user object for later API versions
        try {
            Database.insert(user);
        } catch(System.Exception e) {
            if (e.getMessage().contains('Employee number is already in use')) {
                user = createTestUser();
            }
        }

        return user;
    }

    //helper method to dynamically create user.  This user does not have an EmployeeNumber set.
    @IsTest
    public static User createNonEmployeeTestUser() {
         User user = new User(Username = TEST_USERNAME + Math.random(), //username has to be unique across all tests
                            FirstName = TEST_FIRST_NAME,
                            LastName = TEST_LAST_NAME,
                            Email = TEST_EMAIL,
                            Alias = 'test',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1',
                            ProfileId = getSystemAdministratorProfileId(), //only safe to assume the Sys Admin profile exists
                            LanguageLocaleKey = 'en_US',
                            IsActive = true);

        //DML is allowed on the user object for later API versions
        Database.insert(user);
        return user;
    }

    //helper method to dynamically create user.  prevents unit tests relying on existing records
    @IsTest
    public static User createInactiveTestUser() {
         User user = new User(Username = TEST_USERNAME + Math.random(), //username has to be unique across all tests
                            FirstName = TEST_FIRST_NAME,
                            LastName = TEST_LAST_NAME,
                            Email = TEST_EMAIL,
                            Alias = 'test',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1',
                            ProfileId = getSystemAdministratorProfileId(), //only safe to assume the Sys Admin profile exists
                            LanguageLocaleKey = 'en_US',
                            EmployeeNumber = String.valueOf(Math.random()*1000000).right(6),
                            IsActive = false);

        //DML is allowed on the user object for later API versions
        try {
            Database.insert(user);
        } catch(System.Exception e) {
            if (e.getMessage().contains('Employee number is already in use')) {
                user = createInactiveTestUser();
            }
        }

        return user;
    }

    @IsTest
    public static User createTestUserWithRandomName() {
         User user = setupTestUser();

        //DML is allowed on the user object for later API versions
        Database.insert(user);
        return user;
    }

    //helper method to dynamically create user.  prevents unit tests relying on existing records
    @IsTest
    public static User createTestGUSUser() {
         User user = null;
         if([select count() from Profile where Name = 'GUS User'] == 1) {
             user = new User(Username = TEST_USERNAME + Math.random(), //username has to be unique across all tests
                                FirstName = TEST_FIRST_NAME,
                                LastName = TEST_LAST_NAME,
                                Email = TEST_EMAIL,
                                Alias = 'test',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                EmailEncodingKey = 'ISO-8859-1',
                                ProfileId = [select id from Profile where Name = 'GUS User'].id,
                                LanguageLocaleKey = 'en_US');

              //DML is allowed on the user object for later API versions
              Database.insert(user);
         }

        return user;
    }

    /**
     * Gets the OSC user if it exists or creates and inserts the OSC if not found. This
     * ensures that the test data is always available.
     */
    @IsTest
    public static User createTestOSCUser() {
        List<User> users = [select Id, Name from User where Name = 'OSC' limit 1];
        if(users.isEmpty()) {
            User user = new User(Username = ADM_WorkUser.TEST_USERNAME + Math.random(),
                                LastName = 'OSC',
                                Email = ADM_WorkUser.TEST_EMAIL,
                                Alias = 'osc',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                EmailEncodingKey = 'ISO-8859-1',
                                ProfileId = getSystemAdministratorProfileId(), //only safe to assume the Sys Admin profile exists
                                LanguageLocaleKey = 'en_US');
            Database.insert(user);

            return user;
        } else {
            return users.get(0);
        }
    }



    public static Map<String, Profile> getProfilesMapOfNames() {
        List<Profile> profiles = new List<Profile>();
        Map<String, Profile> els = new Map<String, Profile>();

        profiles = [Select p.Name, p.Id From Profile p where p.Name != NULL];
        for(Profile p : profiles) {
            els.put(p.Name, p);
        }

        return els;
    }

    //helper method to dynamically create user.  prevents unit tests relying on existing records
    @IsTest
    public static User createTestGUSCustomerSupportUser() {
        Map<String, Profile> profiles = ADM_WorkUser.getProfilesMapOfNames();
        User user;

        //= [select id from Profile where Name =  limit 1].Id;
       if(profiles.containsKey(ADM_WorkUser.customerSupportUser)) {
            user = new User(Username = TEST_USERNAME + Math.random(), //username has to be unique across all tests
              FirstName = TEST_FIRST_NAME,
              LastName = TEST_LAST_NAME,
              Email = TEST_EMAIL,
              Alias = 'tcsu',
              TimeZoneSidKey = 'America/Los_Angeles',
              LocaleSidKey = 'en_US',
              EmailEncodingKey = 'ISO-8859-1',
              ProfileId = profiles.get(ADM_WorkUser.customerSupportUser).Id,
              LanguageLocaleKey = 'en_US');
              //DML is allowed on the user object for later API versions
            Database.insert(user);
        }

        return user;
    }

    @TestVisible
    private static String getSOQLQueryForUsers(String inColumnValues, String sortBy, String sortOrder){
        ADM_ConstantsSingleton globalConstants = ADM_ConstantsSingleton.getInstance();

        String sql = '';

        if('true' == globalConstants.getIsFederationFieldAvailable()){
            sql = SQL_SELECT + SQL_FROM + ' where IsActive = true and ' + inColumnValues + ' order by ' + COM_SoqlUtils.createOrder(sortBy, sortOrder);
        }
        else{
            sql = SQL_SELECT2 + SQL_FROM + ' where IsActive = true and ' + inColumnValues + ' order by ' + COM_SoqlUtils.createOrder(sortBy, sortOrder);
        }

        return sql;
    }

    public static Map<String,List<User>> getUsersBasedOnFederationIdCheck(List<User> users){
        Map<String,List<User>> email2UsersMap = new Map<String,List<User>>();
        for(User userIter: users){
            List<User> usersListFromMap = email2UsersMap.get(userIter.email.toLowerCase());
            if(null == usersListFromMap){
                usersListFromMap = new List<User>();
            }
            if(checkFederationIdentifierOnUser(userIter)){
                usersListFromMap.clear();// At this point it is irrelavant what is there in the list we add this user to the list as the only user as user with FederationId takes priority over other users
            }

            /* If federationId is available the list will be cleared by above if condition and the only user will be added here.
               If federationId is not available add this users to the list of users which already exists.
            */
            if(usersListFromMap.size() == 1){
                if(checkFederationIdentifierOnUser(usersListFromMap.get(0))){
                    continue; //There is already a user with FederationIdentifier no need to add any more to this list. So the list size will remain 1 and the check above will help not to add any Non- FederationIdentifier user to the list
                }
            }
            usersListFromMap.add(userIter);
            email2UsersMap.put(userIter.email.toLowerCase(), usersListFromMap);

        }
        return email2UsersMap;
    }
    /*
        Checking avaialabiity of FederationIdentifier just in case caller didn't check it before making this call. Better to be defensive than exception with unexpected failures.
    */
    public static Boolean checkFederationIdentifierOnUser(User user){
        /*
                Some orgs don't have FederationIdentifier so have to do the check in a dynamic way
        */
        SObject userSObject = (SObject)user;
        ADM_ConstantsSingleton globalConstants = ADM_ConstantsSingleton.getInstance();
        if('true' == globalConstants.getIsFederationFieldAvailable() && !ADM_TextUtils.isNull((String)userSObject.get('FederationIdentifier'))){
            return true;
        }
        return false;
    }
}