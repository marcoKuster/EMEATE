@isTest
public with sharing class ADM_ScopeChangeControllerTest {
    static testMethod void testSprintWorkCommitmentNoWork() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();

        ADM_ScopeChangeController.setSprintWorkCommitment(sprint.Id, false);

        ADM_ScopeChangeController.SprintCommitment wc = ADM_ScopeChangeController.getSprintWorkCommitment(sprint.Id);
        
        System.assert(wc != null, 'Expected Sprint Commitment to be returned');
        System.assertEquals(0, wc.storyPoints, 'Expected committed story points to be 0');
        System.assertEquals(0, wc.numOfItems, 'Expected the number of committed items to be 0');

        ADM_SprintVirtualWallController.SprintData sd = (ADM_SprintVirtualWallController.SprintData) JSON.deserialize(ADM_ScopeChangeController.getSprintJSON(sprint.Id), ADM_SprintVirtualWallController.SprintData.class);

        System.assertEquals(false, sd.sprintInfo.Definition_of_Ready_Met__c, 'Expected DOR to be false');
    }

   static testMethod void testSprintWorkCommitmentWithWork() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        
        ADM_Work__c story = ADM_Work.createTestWork('User Story');
        story.Sprint__c = sprint.Id;
        story.Story_Points__c = 8;
        update story;

        ADM_ScopeChangeController.setSprintWorkCommitment(sprint.Id, true);

        ADM_ScopeChangeController.SprintCommitment wc = (ADM_ScopeChangeController.SprintCommitment) JSON.deserialize(ADM_ScopeChangeController.getSprintWorkCommitmentJSON(sprint.Id), ADM_ScopeChangeController.SprintCommitment.class);
        
        System.assert(wc != null, 'Expected Sprint Commitment to be returned');
        System.assertEquals(8, wc.storyPoints, 'Expected committed story points to be 8');
        System.assertEquals(1, wc.numOfItems, 'Expected the number of committed items to be 1');

        ADM_ScopeChangeController.ScopeChange sc = (ADM_ScopeChangeController.ScopeChange) JSON.deserialize(ADM_ScopeChangeController.getScopeChangeJSON(sprint.Id), ADM_ScopeChangeController.ScopeChange.class);
    
        System.assert(sc != null, 'Expected Scope Change to be returned');
        System.assertEquals(1, sc.committedWork.size(), 'Expected committed work size to be 1');
        System.assertEquals(0, sc.addedWork.size(), 'Expected added work size to be 0');
        System.assertEquals(0, sc.removedWork.size(), 'Expected removed work size to be 0');
        System.assertEquals(8, sc.currentCommittedPoints, 'Expected committed points to be 8');
        System.assertEquals(0, sc.removedPoints, 'Expected removed points to be 0');
        System.assertEquals(0, sc.currentRemovedPoints, 'Expected current removed points to be 0');
        System.assertEquals(0, sc.currentAddedPoints, 'Expected current added points to be 0');
        Test.startTest();
        ADM_SprintVirtualWallController.SprintData sd = (ADM_SprintVirtualWallController.SprintData) JSON.deserialize(ADM_ScopeChangeController.getSprintJSON(sprint.Id), ADM_SprintVirtualWallController.SprintData.class);
        Test.stopTest();
        System.assertEquals(true, sd.sprintInfo.Definition_of_Ready_Met__c, 'Expected DOR to be true');
    }
}