/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
public with sharing class ADM_WorkUserTest {
	

	

	static testMethod void testGetProfileName() {
    	List<Profile> profiles = [select Id, Name from Profile limit 1];
    	System.assert(!profiles.isEmpty(), 'Expected at least one profile to be present');
    	
    	String name = ADM_WorkUser.getProfileName(profiles.get(0).Id);
    	System.assertEquals(profiles.get(0).Name, name);
    }
    
    static testMethod void testGetProfileNameWhenNotValid() {
        String name = ADM_WorkUser.getProfileName('NotARealId');
        System.assert(name != null, 'Expected getProfileName to return an empty string when not a valid profile');
        System.assert(name.length() == 0, 'Expected getProfileName to return an empty string when not a valid profile');
    }

    static testMethod void testGet() {

        User u = [
            select Email, FirstName, LastName
            from User where isActive = true
            limit 1
        ];
        User u2 = ADM_WorkUser.get(u.Id);
        System.assertEquals(u.id, u2.id);
    }

    static testMethod void testVerify() {

        Boolean t = true;
        User u = [
            select Email, FirstName, LastName
            from User
            limit 1
        ];

        System.assertEquals(t , ADM_WorkUser.verify(u.Id));
    }

    static testMethod void getAllByTest() {
    	User user1 = ADM_WorkUser.setupTestUser();
    	User user2 = ADM_WorkUser.setupTestUser();
    	User user3 = ADM_WorkUser.setupTestUser();
    	User user4 = ADM_WorkUser.createTestUserWithRandomName();
    	String emailForUser1 = 'idontexist'+Math.random()+'@test.com';
    	user1.Email = emailForUser1;
        String userNameForUser2 = 'tuser@gus.com' + Math.random();
        String emailForUser2 = 'user2'+Math.random()+'@test.com';
    	user2.UserName = userNameForUser2;
    	user2.Email = emailForUser2;
    	String aliasForUser3 = 'testtest';
    	user3.Alias = aliasForUser3;

    	insert new User[]{user1,user2,user3};

    	Set<String> userIds = new Set<String>{user4.Id};

    	Set<String> nonIdValues = new Set<String>{emailForUser1,userNameForUser2,aliasForUser3};

    	Map<String,Set<String>> columnNameToValueMap = new Map<String,Set<String>>();

    	columnNameToValueMap.put('id', userIds);
    	columnNameToValueMap.put('username,email,alias', nonIdValues);

    	User[] usersGotFromQuery = ADM_WorkUser.getAllBy(columnNameToValueMap,0,10, 'createdDate', 'asc');

    	Map<Id, User> uMap = new Map<Id, User>(usersGotFromQuery);

    	System.assert((uMap.get(user4.id) != null), 'Expected user4 to be in the System, columnNameToValueMap was supplied with user4 id. Check getAllBy method');

    	for(User userFromQuery: usersGotFromQuery){
    		if(userFromQuery.userName.equals(user1.userName)){
    			System.assert(userFromQuery.Email.equalsIgnoreCase(user1.email), 'Expected user1 email to be ' + user1.email + ' columnNameToValueMap was supplied with user1 email. Check getAllBy method');
            }

    		if(userFromQuery.email.equals(user2.email)){
    			System.assert(userFromQuery.UserName.equalsIgnoreCase(user2.UserName), 'Expected user2 UserName to be ' + user2.UserName + ' columnNameToValueMap was supplied with user2 UserName. Check getAllBy method');
            }

    		if(userFromQuery.userName.equals(user3.userName)){
    			System.assert(userFromQuery.Alias.equalsIgnoreCase(user3.Alias), 'Expected user3 Alias to be ' + user3.Alias + ' columnNameToValueMap was supplied with user3 Alias. Check getAllBy method');
            }
    	}
    }

    static testMethod void getSOQLQueryForUsersTest(){ 
        //Before starting test asserting ADM_ConstantsSingleton isFederationFieldAvailable is null
        ADM_ConstantsSingleton globalConstants = ADM_ConstantsSingleton.getInstance();
        System.assert(null != globalConstants.getIsFederationFieldAvailable(), 'Expected Not Null value for ADM_ConstantsSingleton.isFederationFieldAvailable');
    }

    static testMethod void getSOQLQueryForUsersTest_Return_No_FederationID_Query_If_FederationIdDoesNotExist(){ 
        ADM_ConstantsSingleton globalConstants = ADM_ConstantsSingleton.getInstance();
        globalConstants.setIsFederationFieldAvailable('false');
        String inColumnValues = COM_SoqlUtils.createInClause('id', new Set<String>{UserInfo.getUserId()});
        String expectedSOQL =  'select Id, Alias, FirstName, LastName, Email, UserName , Show_All_Work_Comments__c, Name, Profile.Name, ProfileId, Notification_Level__c from User where IsActive = true and ' + inColumnValues + ' order by ' + + COM_SoqlUtils.createOrder('id', 'asc');
        String actualSOQL = ADM_WorkUser.getSOQLQueryForUsers(inColumnValues, 'id', 'asc');
        System.assert(expectedSOQL.equalsIgnoreCase(actualSOQL), ' Expected '+ expectedSOQL + ' as return value from the method');
    }

    static testMethod void getSOQLQueryForUsersTest_Return_FederationID_Query_If_FederationIdDoesExist(){ 
        ADM_ConstantsSingleton globalConstants = ADM_ConstantsSingleton.getInstance();
        globalConstants.setIsFederationFieldAvailable('true');
        String inColumnValues = COM_SoqlUtils.createInClause('id', new Set<String>{UserInfo.getUserId()});
        String expectedSOQL =  'select Id, Alias, FirstName, LastName, Email, UserName , Show_All_Work_Comments__c, Name, Profile.Name, ProfileId, Notification_Level__c, FederationIdentifier from User where IsActive = true and ' + inColumnValues + ' order by ' + + COM_SoqlUtils.createOrder('id', 'asc');
        String actualSOQL = ADM_WorkUser.getSOQLQueryForUsers(inColumnValues, 'id', 'asc');
        System.assert(expectedSOQL.equalsIgnoreCase(actualSOQL), ' Expected '+ expectedSOQL + ' as return value from the method, But got ' + actualSOQL);
    }

    static testMethod void getUsersBasedOnFederationIdCheckTest(){ 
        ADM_ConstantsSingleton globalConstants = ADM_ConstantsSingleton.getInstance();
        Boolean isFederationFieldAvailable = ('true'.equals(globalConstants.getIsFederationFieldAvailable()));
        List<User> testUsers;
        User user1 = ADM_WorkUser.setupTestUser();
        user1.Email='firsttestUserEmail@test.com';
        SObject user1SObject  = (SObject)user1;
        User user2 = ADM_WorkUser.setupTestUser();
        user2.Email= 'firsttestUserEmail@test.com'; //same email as first user
        User user3 = ADM_WorkUser.setupTestUser();
        user3.Email= 'thirdtestUserEmail@test.com'; 
        SObject user3SObject  = (SObject)user3;
        User user4 = ADM_WorkUser.setupTestUser();
        user4.Email= 'thirdtestUserEmail@test.com'; //same email as third user
        User user5 = ADM_WorkUser.setupTestUser();
        user5.Email= 'fifthtestUserEmail@test.com'; 
        if(isFederationFieldAvailable){
            
            user1SObject.put('FederationIdentifier', 'somevalue1');
            user1 = (User)user1SObject;
            user3SObject.put('FederationIdentifier', 'someValue2');
            user3 = (User)user3SObject;
        }

        testUsers  = new List<User>{user1,user2,user3,user4,user5};

        insert testUsers;

        Map<String,List<User>>  email2UsersMap = ADM_WorkUser.getUsersBasedOnFederationIdCheck(testUsers);
        if(isFederationFieldAvailable){
            System.assert(3==email2UsersMap.size(), ' please check email2UsersMap, user list didn\'t match as expected ' + email2UsersMap);
            List<User> firstUserEmailUsers = email2UsersMap.get('firsttestuseremail@test.com');
            System.assert(1==firstUserEmailUsers.size(), 'Expected 1 user in this list but got ' + firstUserEmailUsers);
            List<User> thirdUserEmailUsers = email2UsersMap.get('thirdtestuseremail@test.com');
            System.assert(1==thirdUserEmailUsers.size(), 'Expected 1 user in this list but got ' + thirdUserEmailUsers);
        }
        else{
            System.assert(5==email2UsersMap.size(), ' please check email2UsersMap, user list didn\'t match as expected ' + email2UsersMap);
            List<User> firstUserEmailUsers = email2UsersMap.get('firsttestuseremail@test.com');
            System.assert(2==firstUserEmailUsers.size(), 'Expected 2 users in this list, got ' + firstUserEmailUsers);
            List<User> thirdUserEmailUsers = email2UsersMap.get('thirdtestuseremail@test.com');
            System.assert(2==thirdUserEmailUsers.size(), 'Expected 2 users in this list, got ' + thirdUserEmailUsers);
        }
    }
}