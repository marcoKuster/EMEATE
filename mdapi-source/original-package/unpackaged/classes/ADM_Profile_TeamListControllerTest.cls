@IsTest
public class ADM_Profile_TeamListControllerTest {

    static testMethod void testGetScrumTeamsWithNullId() {

        List<ADM_Scrum_Team_Member__c> teams = ADM_Profile_TeamListController.getScrumTeams(null);
        System.assert( teams.size() == 0 );

    } 

    static testMethod void testGetScrumTeamsWithAValidId() {

		String timestamp = String.valueOf(System.currentTimeMillis());
        String randomValue = timestamp.substring( timestamp.length() - 5 , timestamp.length() );
        
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('Team' + randomValue);
		upsert team;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user = new User(UserName='dev'+ randomValue +'@test.org', ProfileId = p.Id, Email='dev'+ randomValue +'@test.org', LastName='Testing', Alias='dev'+ randomValue, EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
        insert user;
        
		ADM_Scrum_Team_Member__c dev = new ADM_Scrum_Team_Member__c(Member_Name__c=user.Id, Scrum_Team__c=team.Id, Role__c='Software Engineer', Allocation__c=2);
        upsert dev;
        
        List<ADM_Scrum_Team_Member__c> teams = ADM_Profile_TeamListController.getScrumTeams(user.Id);
		System.assertEquals( 1, teams.size() );
        
    } 
  
}