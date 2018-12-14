@IsTest
private class ADM_TeamCreatorControllerTests{
    
  
    private static void initialize() {
        //create a new ADM_Scrum_Team__c object
        ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
        
        //create a new ADM_Scrum_Team_Member__c and add to list
         User user1 = ADM_WorkUser.createTestUser();
         User user2 = ADM_WorkUser.createTestUser();
         ADM_Scrum_Team_Member__c member1 = ADM_ScrumTeam.setupTestScrumTeamMember(user1.Id,null);
         ADM_Scrum_Team_Member__c member2 = ADM_ScrumTeam.setupTestScrumTeamMember(user2.Id,null);
         List <ADM_Scrum_Team_Member__c> memberList = new List<ADM_Scrum_Team_Member__c> {member1,member2};
         ADM_Product_tag__c testTag = new ADM_Product_Tag__c(name='testTag');
        //call insertTeamAndMembers
         String teamId = ADM_TeamCreatorController.insertTeamAndMembers(team,memberList,testTag);
        
    }
    
     /*
        test case ID: a1DB00000002iiXMAQ
        user story ID: a07B0000000LpCb
        Expected Results:  The team should be successfully created with two members and tag assignments present.
        Long Desc: Log into GUS and then go to the Team tab. Click on the Create Team Button and select ScrumTeam in the dropdown and then put in two members and create tag assignments and hit Save button
    */
    static testMethod void testInsertTeamAndMembers() {
           
        initialize();    
        //use SOQL to make sure the team and and team member were inserted and expected fields populated
         ADM_Scrum_Team__c insertedTeam = [select Id, name,Active__c,Cloud__c from ADM_Scrum_Team__c where name=:ADM_ScrumTeam.TEST_SCRUM_TEAM];
         System.assert(insertedTeam!=null,'Team creation failed');
         System.assertEquals(ADM_ScrumTeam.TEST_SCRUM_TEAM, insertedTeam.name);
         System.assertEquals(true,insertedTeam.Active__c);
    }  
    
      /*
        test case ID: a1DB00000002j04MAA
        user story ID: a07B0000000LpCb
        Expected Results:  Should get an error message displaying "Team name is required"   
        Long Desc: Try to create a team by specifying "" in the Team Name
    */ 
    static testMethod void testTeamNameIsRequired() {
     
        //setup team object missing the Name and call insertTeamAndMembers.  Catch the exception and verify the message says 'Team name is required' 
      
        ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeam('');
         User user1 = ADM_WorkUser.createTestUser();
         User user2 = ADM_WorkUser.createTestUser();
         ADM_Scrum_Team_Member__c member1 = ADM_ScrumTeam.setupTestScrumTeamMember(user1.Id,null);
         ADM_Scrum_Team_Member__c member2 = ADM_ScrumTeam.setupTestScrumTeamMember(user2.Id,null);
         List <ADM_Scrum_Team_Member__c> memberList = new List<ADM_Scrum_Team_Member__c> {member1,member2};
         ADM_Product_tag__c testTag = new ADM_Product_Tag__c(name='testTag');
        //call insertTeamAndMembers
        try {
         String teamId = ADM_TeamCreatorController.insertTeamAndMembers(team,memberList,testTag);
        }
        catch(ADM_ApplicationException e) {
             System.assertEquals('Team name is required.', e.getMessage());
        }
    } 
    
        /*
        test case ID: a1DB00000004i8zMAA
        user story ID: a07B0000000LpCb
        Expected Results:  The team creation process should fail with message "At least two team members are required"
        Long Desc: Log in with Release Mgr credentials into gus and then try to create a new team with just one member or no members in it
    */ 
    static testMethod void testAtLeastTwoTeamMembersAreRequired() {
     ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
         User user1 = ADM_WorkUser.createTestUser();
         ADM_Scrum_Team_Member__c member1 = ADM_ScrumTeam.setupTestScrumTeamMember(user1.Id,null);
          List <ADM_Scrum_Team_Member__c> memberList = new List<ADM_Scrum_Team_Member__c> {member1};
         ADM_Product_tag__c testTag = new ADM_Product_Tag__c(name='testTag');
         //call insertTeamAndMembers
         try {
         String teamId = ADM_TeamCreatorController.insertTeamAndMembers(team,memberList,testTag);
        }
        catch(ADM_ApplicationException e) {
             System.assertEquals('At least two team members are required.', e.getMessage());
        }
    } 
    
     /*
        test case ID: a1DB00000004iiw
        user story ID: a07B0000000LpCb
        Expected Results:  The team creation process should fail with message "At least two team members are required". Then query the db as well to make sure that the Team creation actually failed and that no team by that name exists.
        Long Desc: Log in with Release Mgr credentials into gus and then try to create a new team with just one member
    */ 
    static testMethod void testTeamInsertIsRolledBackIfTeamTransactionFails() {
     
        //insertTeamAndMembers() is transactional - if the team members insert fails the team should not have been inserted. Write assertions that
        testAtLeastTwoTeamMembersAreRequired();
        //use SOQL to make sure the team and and team member were not inserted 
         List <ADM_Scrum_Team__c> insertedTeams = [select Id, name,Active__c,Cloud__c from ADM_Scrum_Team__c where name=:ADM_ScrumTeam.TEST_SCRUM_TEAM];
         System.assert(insertedTeams.size()==0,'Team creation succeeded when it shouldnt have ');        
    }
    
     /*
        test case ID: a1DB00000004i8yMAA
        user story ID: a07B0000000LpCb
        Expected Results:  The team creation process should fail with message " At least one Product Tag is required for this team to be able to be assigned Work records."
        Long Desc: Log in with Release Mgr credentials into gus and then try to create a new team without having a product tag.
    */ 
    static testMethod void testProductTagIsRequired() {
     ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
         User user1 = ADM_WorkUser.createTestUser();
         User user2 = ADM_WorkUser.createTestUser();
         ADM_Scrum_Team_Member__c member1 = ADM_ScrumTeam.setupTestScrumTeamMember(user1.Id,null);
         ADM_Scrum_Team_Member__c member2 = ADM_ScrumTeam.setupTestScrumTeamMember(user2.Id,null);
         List <ADM_Scrum_Team_Member__c> memberList = new List<ADM_Scrum_Team_Member__c> {member1,member2};
         ADM_Product_tag__c testTag = new ADM_Product_Tag__c(name='');
        //call insertTeamAndMembers
         try {
         String teamId = ADM_TeamCreatorController.insertTeamAndMembers(team,memberList,testTag);
        }
        catch(Exception e) {
             System.assertEquals('At least one Product Tag is required for this team to be able to be assigned Work records.', e.getMessage());
        }
        
    }
    
     /*
        test case ID: a1DB00000004i8yMAA
        user story ID: a07B0000000LpCb
        Expected Results:  The team creation process should fail with message " At least one Product Tag is required for this team to be able to be assigned Work records."
        Long Desc: Log in with Release Mgr credentials into gus and then try to create a new team without having a product tag.
    */ 
    static testMethod void testProductTagIsRelatedToAssignmentRule() {
        //test product tag is created, assignment rule is created and two ADM_Tag_Assignment__c objects are created relating the tag to the rule (one for bugs and one for user stories)
         initialize();
         ADM_Product_Tag__c productTag  = [select Id, name,Active__c from ADM_Product_Tag__c where Name='testTag'];
         System.assert(productTag!=null,'product tag is not present for the newly created team');
         List <ADM_Tag_Assignment__c> tags  =  [select Id, name,Record_Type__c from ADM_Tag_Assignment__c where Product_Tag__c=:productTag.Id];
        System.assert(tags.size()==2,'Tag Assignments for either Bug or UserStory is missing');
        
    }
    
     /*
        test case ID: a1DB00000004ij6
        user story ID: a07B0000000LpCb
        Expected Results:  The team creation process should pass. Then query the db as well to make sure that the role of "Developer" is assigned to one team member and "Product Owner" Assigned to another
        Long Desc: Log in with Release Mgr credentials into gus and then try to create a new team with one member assigned to Developer and another assigned as Product Owner
    */ 
    static testMethod void testIfPopulatedTeamMemberWithRoleOfDeveloperIsUsedAsAssigneeOnAssignmentRule() {
   
        ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
         User user1 = ADM_WorkUser.createTestUser();
         User user2 = ADM_WorkUser.createTestUser();
         ADM_Scrum_Team_Member__c member1 = ADM_ScrumTeam.setupTestScrumTeamMember(user1.Id,null);
         ADM_Scrum_Team_Member__c member2 = ADM_ScrumTeam.setupTestScrumTeamMember(user2.Id,null);
         member1.role__c = 'Developer';
         List <ADM_Scrum_Team_Member__c> memberList = new List<ADM_Scrum_Team_Member__c> {member1,member2};
         ADM_Product_tag__c testTag = new ADM_Product_Tag__c(name='testTag');
        //call insertTeamAndMembers
         String teamId = ADM_TeamCreatorController.insertTeamAndMembers(team,memberList,testTag);
        
         ADM_Tag_Assignment__c taStory = [select Assignment_Rule__c from ADM_Tag_Assignment__c where Product_Tag__c=:testTag.Id and Record_Type__c='Bug'];
         ADM_Assignment_Rule__c rule = [select Assignee_Assignment__c, Scrum_Team_Assignment__c from ADM_Assignment_Rule__c  where Id =:taStory.Assignment_Rule__c];
         System.assertEquals(user1.Id,rule.Assignee_Assignment__c,'The userId of role does not match the user Id present in TagAssignment for Dev');
                                              
    }

     /*
        test case ID: a1DB00000004ij6
        user story ID: a07B0000000LpCb
        Expected Results:  The team creation process should pass. Then query the db as well to make sure that the role of "Developer" is assigned to one team member and "Product Owner" Assigned to another
        Long Desc: Log in with Release Mgr credentials into gus and then try to create a new team with one member assigned to Developer and another assigned as Product Owner
    */ 
    static testMethod void testIfPopulatedTeamMemberWithRoleOfProductOwnerIsUsedAsProductOwnerOnAssignmentRule() {
         ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
         User user1 = ADM_WorkUser.createTestUser();
         User user2 = ADM_WorkUser.createTestUser();
         ADM_Scrum_Team_Member__c member1 = ADM_ScrumTeam.setupTestScrumTeamMember(user1.Id,null);
         ADM_Scrum_Team_Member__c member2 = ADM_ScrumTeam.setupTestScrumTeamMember(user2.Id,null);
         member2.role__c = 'Product Owner';
         List <ADM_Scrum_Team_Member__c> memberList = new List<ADM_Scrum_Team_Member__c> {member1,member2};
         ADM_Product_tag__c testTag = new ADM_Product_Tag__c(name='testTag');
        //call insertTeamAndMembers
         String teamId = ADM_TeamCreatorController.insertTeamAndMembers(team,memberList,testTag);
         ADM_Tag_Assignment__c taStory = [select Assignment_Rule__c from ADM_Tag_Assignment__c where Product_Tag__c=:testTag.Id and Record_Type__c='Bug'];
         ADM_Assignment_Rule__c rule = [select Product_Owner__c, Scrum_Team_Assignment__c from ADM_Assignment_Rule__c  where Id =:taStory.Assignment_Rule__c];    
         System.assert(user2.Id==rule.Product_Owner__c,'The userId of role does not match the user Id present in TagAssignment for ProductOwner');
         
    }    
    
     /*
        test case ID: a1DB00000002ijlMAA
        user story ID: a07B0000000LpCb
        Expected Results:  The default Story point scale is fibonacci but the user can enter a new series as well..
        Long Desc: create a new Team and then go the Story Point Scale section
    */ 
    static testMethod void testStoryPointScale() {
        initialize();
        ADM_Scrum_Team__c insertedTeam = [select Id, name,Active__c,Cloud__c,Story_Point_Scale__c from ADM_Scrum_Team__c where name=:ADM_ScrumTeam.TEST_SCRUM_TEAM];
        System.assertEquals('1,2,3,5,8,13,21',insertedTeam.Story_Point_Scale__c);
        
    }
    
     static testMethod void doCancelTest() {
       ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
       Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(team);
       ADM_TeamCreatorController controller = new ADM_TeamCreatorController(sc);
       Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Scrum_Team__c;
       String expectedUrl = '/' + result.getKeyPrefix() + '/o';
       PageReference returnPage = controller.doCancel();
       System.assertEquals(expectedUrl,returnPage.getUrl(),'Asserting if it returns back to the Team list view page on click of cancel button');
    }
    
   static testMethod void getListViewLinkTest() {
       ADM_Scrum_Team__c team = ADM_ScrumTeam.setupTestScrumTeam(ADM_ScrumTeam.TEST_SCRUM_TEAM);
       Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(team);
       ADM_TeamCreatorController controller = new ADM_TeamCreatorController(sc);
       Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Scrum_Team__c;
       String expectedUrl = '/' + result.getKeyPrefix();
       String returnUrl = controller.getListViewLink();
       System.assertEquals(expectedUrl,returnUrl,'Asserting if it returns back to the Team list view page on click of All Teams link');
    }
    
    

}