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
private class ADM_Validate_Team_Dependency_Test {
	static testMethod void testDelete() {
        List<ADM_Work__c> work = new List<ADM_Work__c>();
        List<ADM_Team_Dependency__c> elsOld = new List<ADM_Team_Dependency__c>();
        Map<Id,ADM_Team_Dependency__c> elsNew = new Map<Id,ADM_Team_Dependency__c>();
        ADM_Team_Dependency__c td = new ADM_Team_Dependency__c();
        
        Test.startTest();
        ADM_Scrum_Team__c dependentTeam = ADM_ScrumTeam.createTestScrumTeam('Alpha');
        ADM_Work__c dependentBug = ADM_Work.createTestBug();
        ADM_Product_Tag__c tag = [select id, Team__c from ADM_Product_Tag__c where id=:dependentBug.Product_Tag__c];
        tag.Team__c = dependentTeam.Id;
        update tag;
        ADM_Scrum_Team__c providingTeam = ADM_ScrumTeam.createTestScrumTeam('Beta');
       
        ADM_Work__c deliverableBug = ADM_Work.createTestBug();
        ADM_Product_Tag__c tag2 = [select id, Team__c from ADM_Product_Tag__c where id=:deliverableBug.Product_Tag__c];
        tag2.Team__c = providingTeam.Id;
        update tag2;
        
        work.add(dependentBug);
        work.add(deliverableBug);
        
        update work;
        
        td.Deliverable__c = 'test';
        td.Dependent_User_Story__c = dependentBug.Id;
        td.Dependent_Team__c = dependentTeam.Id;
        td.Provider_Team__c = providingTeam.Id;
        td.Provider_User_Story__c = deliverableBug.Id;
        
        elsOld.add(td);
        elsNew.put(td.Id,td);
        
        insert td;
        
        Test.stopTest();
        
        delete td;
	}
	
	/*
	testcaseID a1DB00000002gqV
	userstory a0790000000DB5w
	Hierarchy GUS.Work.Bug.New Page
	Expected Results Error gets generated
	*/

	static testMethod void validateNoTemplatesInTeamDependency() {
        List<ADM_Work__c> work = new List<ADM_Work__c>();
        List<ADM_Team_Dependency__c> elsOld = new List<ADM_Team_Dependency__c>();
        Map<Id,ADM_Team_Dependency__c> elsNew = new Map<Id,ADM_Team_Dependency__c>();
        ADM_Team_Dependency__c td = new ADM_Team_Dependency__c();
        
        Test.startTest();
        ADM_Scrum_Team__c dependentTeam = ADM_ScrumTeam.createTestScrumTeam('Alpha');
        ADM_Work__c dependentStory = ADM_Work.createTestTemplate();
        dependentStory.Scrum_Team__c = dependentTeam.Id;
        
        ADM_Scrum_Team__c providingTeam = ADM_ScrumTeam.createTestScrumTeam('Beta');
       
        ADM_Work__c deliverableStory = ADM_Work.createTestTemplate();
        deliverableStory.Scrum_Team__c = providingTeam.Id;
        
        work.add(dependentStory);
        work.add(deliverableStory);
        
        update work;
        
        td.Deliverable__c = 'test';
        td.Dependent_User_Story__c = dependentStory.Id;
        td.Dependent_Team__c = dependentTeam.Id;
        td.Provider_Team__c = providingTeam.Id;
        td.Provider_User_Story__c = deliverableStory.Id;
        
        elsOld.add(td);
        elsNew.put(td.Id,td);
        
        Test.stopTest();
        
        try {
            insert td;	
        } catch(System.Exception e) {
            System.assert(String.valueOf(e).contains('Work templates cannot be assigned to team dependencies'));
        }
    }
	
	/*
	testcaseID a1DB00000000rF9
	userstory a0790000000DB5w
	Hierarchy GUS.Work.Bug.New Page
	Expected Results An error gets generated that the item cannot become duplicate because there is a team dependency
	*/
	
    static testMethod void testValidateTeamDependencyWithCorrectTeamDesignations() {
        List<ADM_Work__c> work = new List<ADM_Work__c>();
        List<ADM_Team_Dependency__c> elsOld = new List<ADM_Team_Dependency__c>();
        Map<Id,ADM_Team_Dependency__c> elsNew = new Map<Id,ADM_Team_Dependency__c>();
        ADM_Team_Dependency__c td = new ADM_Team_Dependency__c();
        
        Test.startTest();
        ADM_Scrum_Team__c dependentTeam = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Work__c dependentStory = ADM_Work.createTestBug();
        dependentStory.Scrum_Team__c = dependentTeam.Id;
        
        ADM_Scrum_Team__c providingTeam = ADM_ScrumTeam.createTestScrumTeam('Beta');
        
        ADM_Work__c deliverableStory = ADM_Work.createTestBug();
        deliverableStory.Scrum_Team__c = providingTeam.Id;
        
        work.add(dependentStory);
        work.add(deliverableStory);
        
        update work;
        
        td.Deliverable__c = 'test';
        td.Dependent_User_Story__c = dependentStory.Id;
        td.Dependent_Team__c = dependentTeam.Id;
        td.Provider_Team__c = providingTeam.Id;
        td.Provider_User_Story__c = deliverableStory.Id;
        
        elsOld.add(td);
        elsNew.put(td.Id,td);
        
        Test.stopTest();
        
        ADM_Validate_Team_Dependency.validateTeamDependencies(elsOld, elsNew);
        
        System.assert(!Apexpages.hasMessages(),'error: was not expecting to have any errors!');
        
    }
	
	/*
	testcaseID a1DB00000002gqa
	userstory a0790000000DB5w
	Hierarchy GUS.Work.Bug.New Page
	Expected Results An error gets generated that the item cannot become duplicate because there is a team dependency
	*/
    static testMethod void testValidateTeamDependencyWithDependentUserStoryAssignedToWrongTeam() {
        List<ADM_Work__c> work = new List<ADM_Work__c>();
        List<ADM_Team_Dependency__c> elsOld = new List<ADM_Team_Dependency__c>();
        Map<Id,ADM_Team_Dependency__c> elsNew = new Map<Id,ADM_Team_Dependency__c>();
        ADM_Team_Dependency__c td = new ADM_Team_Dependency__c();
        
        Test.startTest();
        ADM_Scrum_Team__c junkTeam = ADM_ScrumTeam.createTestScrumTeam('Alpha');
        ADM_Scrum_Team__c goodTeam = ADM_ScrumTeam.createTestScrumTeam('Beta');
        ADM_Work__c dependentBug = ADM_Work.createTestBug();
        ADM_Product_Tag__c tag = [select id, Team__c from ADM_Product_Tag__c where id =:dependentBug.Product_Tag__c];
        tag.Team__c = junkTeam.Id;
        update tag;
        
        work.add(dependentBug);
        
        update work;
        
        td.Deliverable__c = 'test';
        td.Dependent_User_Story__c = dependentBug.Id;
        td.Dependent_Team__c = junkTeam.Id;
        td.Provider_Team__c = goodTeam.Id;
        td.Provider_User_Story__c = td.Dependent_User_Story__c;
        
        elsOld.add(td);
        elsNew.put(td.Id,td);
        
        Test.stopTest();
        
        try {
            insert td;
        } catch (System.Dmlexception e) {
            System.assert(e.getMessage().contains('This User Story must be on the backlog of the team providing the deliverable.'));
        }
    }
	
	/*
	testcaseID a1DB00000002gqa
	userstory a0790000000DB5w
	Hierarchy GUS.Work.Bug.New Page
	Expected Results Error generated
	*/
    static testMethod void testValidateTeamDependencyWithProviderUserStoryAssignedToWrongTeam() {
        ADM_Scrum_Team__c otherTeam = ADM_ScrumTeam.createTestScrumTeam('Alpha');
        
        ADM_Work__c dependentWork = ADM_Work.createTestBug();
        ADM_Work__c providerWork = ADM_Work.createTestBug();
        
        //reload the work so that we get the scrum team associated to the work
        Map<Id, ADM_Work__c> workMap = new Map<Id, ADM_Work__c>([select Id, Scrum_Team__c from ADM_Work__c where Id in (:dependentWork.Id, :providerWork.Id)]);
        dependentWork = workMap.get(dependentWork.Id);
        providerWork = workMap.get(providerWork.Id);
        
        ADM_Team_Dependency__c td = new ADM_Team_Dependency__c();
        td.Deliverable__c = 'test';
        td.Dependent_User_Story__c = dependentWork.Id;
        td.Dependent_Team__c = otherTeam.Id; //the dependent work team != dependent team
        td.Provider_User_Story__c = providerWork.Id;
        td.Provider_Team__c = providerWork.Scrum_Team__c;
        
        try {
            Test.startTest();
            insert td;
            Test.stopTest();
            System.assert(false, 'Expected the insert to fail because the dependent team is not the team that owns the work');
        } catch (System.Dmlexception e) {
            System.assert(e.getMessage().contains('This User Story must be on the backlog of the team with the dependency.'), e.getMessage());
        }
    }
    
    /**
    Creates a Team Dependency without specifying the work with dependency.  A valid use case.
    *@testcaseID a0B20000007jjPPEAY
    *@hierarchy GUS.ScrumforceToGUS
    *@userstory a0A20000006R5Zj
    *@expectedResults Team Dependency saves successfully (no error displayed) 
	*/
    
    static testMethod void testValidateTeamDependencyWithNoWorkWithDependency() {
    	List<ADM_Work__c> work = new List<ADM_Work__c>();
        List<ADM_Team_Dependency__c> elsOld = new List<ADM_Team_Dependency__c>();
        Map<Id,ADM_Team_Dependency__c> elsNew = new Map<Id,ADM_Team_Dependency__c>();
        ADM_Team_Dependency__c td = new ADM_Team_Dependency__c();
        Test.startTest();
        td.Deliverable__c = 'test';
        //Dependent_User_Story__c field deliberately not populated
        ADM_Scrum_Team__c dependentTeam = ADM_ScrumTeam.createTestScrumTeam();
        ADM_Scrum_Team__c providingTeam = ADM_ScrumTeam.createTestScrumTeam('Beta');
        td.Deliverable__c = 'test';
        td.Dependent_Team__c = dependentTeam.Id;
        td.Provider_Team__c = providingTeam.Id;
        elsOld.add(td);
        elsNew.put(td.Id,td);
        Test.stopTest();
        
        try {
            insert td;
            System.assert(!Apexpages.hasMessages(),'error: was not expecting to have any errors!');
            System.assert(td.id != null);
        } catch (System.Dmlexception e) {
            System.assert(false, 'Did not expect exception - should allowed to save without specifing dependent user story');
        }
    	
    	
    }
}