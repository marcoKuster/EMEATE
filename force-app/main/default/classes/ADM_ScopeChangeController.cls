public with sharing class ADM_ScopeChangeController {
    
    @AuraEnabled
    public static String getScopeChangeJSON(Id sprintId) {
        return JSON.serialize(getScopeChange(sprintId));
    }

    private static ScopeChange getScopeChange(Id sprintId) {
        Map<Id, ADM_Work__c> currentWorkInSprint = new Map<Id, ADM_Work__c>(ADM_Work.getWorksBySprint(sprintId));
        ADM_Work_Commitment__c[] commitments = [SELECT Committed_Story_Points__c, Work__c, Work__r.Assignee__c, Work__r.Assignee__r.Name, Work__r.Id, Work__r.Name, Work__r.Subject__c, Work__r.Status__c, Work__r.Story_Points__c, Work__r.Record_Type__c FROM ADM_Work_Commitment__c WHERE Sprint__c = :sprintId];
        ScopeChangeItem[] committedWork = new List<ScopeChangeItem>();
        ScopeChangeItem[] removedWork = new List<ScopeChangeItem>();
        Decimal committedWorkTotalPoints = 0;
        Decimal committedWorkCurrentPoints = 0;
        Decimal removedWorkTotalPoints = 0;
        Decimal removedWorkCurrentPoints = 0;
        Decimal addedWorkCurrentPoints = 0;

        for (ADM_Work_Commitment__c workCommitment : commitments) {
            ScopeChangeItem workItem = new ScopeChangeItem();
            Decimal committedStoryPoints = (workCommitment.Committed_Story_Points__c != null ? workCommitment.Committed_Story_Points__c : 0);
            
            if (workCommitment.Work__r.Story_Points__c == null) {
                workCommitment.Work__r.Story_Points__c = 0;
            }

            Decimal workStoryPoints = workCommitment.Work__r.Story_Points__c;
            
            workItem.work = workCommitment.Work__r;
            workItem.committedStoryPoints = committedStoryPoints;
            
            if (workStoryPoints != committedStoryPoints) {
                workItem.pointsDiffCssClass = 'adm-text-color_orange';
            }
            
            if (currentWorkInSprint.containsKey(workCommitment.Work__r.Id)) {
                committedWork.add(workItem);
                currentWorkInSprint.remove(workCommitment.Work__r.Id);
                committedWorkTotalPoints += committedStoryPoints;
                committedWorkCurrentPoints += workStoryPoints;
            } else {
                removedWork.add(workItem);
                currentWorkInSprint.remove(workCommitment.Work__r.Id);
                removedWorkTotalPoints += committedStoryPoints;
                removedWorkCurrentPoints += workStoryPoints;
            }
        }

        for (ADM_Work__c work : currentWorkInSprint.values()) {
            addedWorkCurrentPoints += (work.Story_Points__c != null ? work.Story_Points__c : 0);
        }

        ScopeChange scopeChange = new ScopeChange();

        scopeChange.committedWork.addAll(committedWork);
        scopeChange.addedWork.addAll(currentWorkInSprint.values());
        scopeChange.removedWork.addAll(removedWork);
        scopeChange.committedPoints = committedWorkTotalPoints;
        scopeChange.currentCommittedPoints = (committedWorkCurrentPoints != null ? committedWorkCurrentPoints : 0);
        scopeChange.removedPoints = removedWorkTotalPoints;
        scopeChange.currentRemovedPoints = (removedWorkCurrentPoints != null ? removedWorkCurrentPoints : 0);
        scopeChange.currentAddedPoints = addedWorkCurrentPoints;
        scopeChange.sprintData = getSprintData(sprintId);
        scopeChange.sprintCommitment = getSprintWorkCommitment(sprintId);
        
        return scopeChange;
    }
    

    private static ADM_SprintVirtualWallController.SprintData getSprintData(Id sprintId) {
        return ADM_SprintVirtualWallController.getSprintData(sprintId);
    }

    @AuraEnabled
    public static String getSprintJSON(Id sprintId) {
        return JSON.serialize(getSprintData(sprintId));
    }

    @AuraEnabled
    public static String setSprintWorkCommitment(String sprintId, Boolean defOfReady) {
        Integer existingCommitmentCount = [SELECT Count() FROM ADM_Work_Commitment__c WHERE Sprint__c = :sprintId];

        if (existingCommitmentCount == 0) {
            ADM_Work__c[] works = [SELECT Id, Name, Subject__c , Closed__c, Assignee__r.Id, Assignee__r.FirstName, Assignee__r.LastName, Assignee__r.Name, Assignee__r.SmallPhotoUrl, QA_Engineer__r.FirstName, QA_Engineer__r.Id, QA_Engineer__r.LastName, QA_Engineer__r.Name, QA_Engineer__r.SmallPhotoUrl, LastModifiedDate, LastModifiedById, Status__c, Sprint__c, Sprint__r.Start_Date__c, Sprint__r.End_Date__c, RecordType.Name, Theme__r.Name, Scheduled_Build__r.Name, Story_Points__c, Sprint_Rank__c, Capex_Enabled__c FROM ADM_Work__c WHERE Sprint__r.Id = :sprintId ORDER BY Sprint_Rank__c ASC NULLS LAST, Priority_Rank__c ASC NULLS LAST, CreatedDate ASC];
            ADM_Sprint__c sprint = [SELECT Id,Name,Scrum_Team__c,Completed_Story_Points__c,Days_Remaining__c,Definition_of_Ready_Met__c,Scrum_Team__r.Name,Scrum_Team__r.Story_Point_Scale__c,Scrum_Team__r.Capex_Enabled__c,Start_Date__c,End_Date__c FROM ADM_Sprint__c WHERE Id =: sprintId];
            ADM_Work_Commitment__c[] commitments = new List<ADM_Work_Commitment__c>();
            Decimal totalStoryPoints = 0;
            Integer workItemCount = 0;

            for (ADM_Work__c work : works) {
                ADM_Work_Commitment__c workCommitment = new ADM_Work_Commitment__c();

                workCommitment.Work__c = work.Id;
                workCommitment.Sprint__c = sprint.Id;
                workCommitment.Committed_Story_Points__c = work.Story_Points__c;

                totalStoryPoints += (work.Story_Points__c != null ? work.Story_Points__c : 0);
                workItemCount++;

                commitments.add(workCommitment);
            }
            
            if (sprint.Definition_of_Ready_Met__c != defOfReady) {
                sprint.Definition_of_Ready_Met__c = defOfReady;
            }

            sprint.Committed_Points__c = totalStoryPoints;
            sprint.Committed_Items__c = workItemCount;

            update sprint;

            Set<Id> sprintIds = new Set<Id>{sprint.Id};
            ADM_SprintBurnDownUtils.asyncCalculateVelocity(sprintIds);

            SprintCommitment sprintCommitment = new SprintCommitment();

            sprintCommitment.storyPoints = totalStoryPoints;
            sprintCommitment.numOfItems = workItemCount;

            insert commitments;

            return JSON.serialize(sprintCommitment);
        } else {
            throw new AuraHandledException(Label.ADM_Commitment_Exists_On_Sprint);
        }
    }

    public static Map<Id, ADM_Work_Commitment__c> getSprintWorkCommitmentMap(String sprintId) {
        Map<Id, ADM_Work_Commitment__c> commitmentMap = new Map<ID, ADM_Work_Commitment__c>([SELECT Committed_Story_Points__c, Work__r.RecordTypeId FROM ADM_Work_Commitment__c WHERE Sprint__c = :sprintId]);

        return commitmentMap;
    }

    public static SprintCommitment getSprintWorkCommitment(String sprintId) {
        List<ADM_Work_Commitment__c> commitments = getSprintWorkCommitmentMap(sprintId).values();
        List<ADM_Work__c> committedWork = new List<ADM_Work__c>();
        Decimal totalStoryPoints = 0;
        Integer workItemCount = 0;

        for (ADM_Work_Commitment__c workCommitment : commitments) {
            committedWork.add(workCommitment.Work__r);

            workItemCount++;

            totalStoryPoints += (workCommitment.Committed_Story_Points__c != null ? workCommitment.Committed_Story_Points__c : 0);
        }

        SprintCommitment commitment = new SprintCommitment();

        commitment.committedWork = committedWork;
        commitment.storyPoints = totalStoryPoints;
        commitment.numOfItems = workItemCount;

        return commitment;
    }

    public static List<Id> getWorkIdsCommittedToInSprint(String sprintId) {
        List<ADM_Work_Commitment__c> commitments = getSprintWorkCommitmentMap(sprintId).values();
        List<Id> commitmentWorkIds = new List<Id>();

        for (ADM_Work_Commitment__c workCommitment : commitments) {
            commitmentWorkIds.add(workCommitment.Work__c);
        }

        return commitmentWorkIds;
    }
    
    @AuraEnabled
    public static String getSprintWorkCommitmentJSON(String sprintId) {
        return JSON.serialize(getSprintWorkCommitment(sprintId));
    }

    public class ScopeChange {
        public ScopeChangeItem[] committedWork;
        public ADM_Work__c[] addedWork;
        public ScopeChangeItem[] removedWork;
        public Decimal committedPoints;
        public Decimal currentCommittedPoints;
        public Decimal removedPoints;
        public Decimal currentRemovedPoints;
        public Decimal currentAddedPoints;
        public ADM_SprintVirtualWallController.SprintData sprintData;
        public SprintCommitment sprintCommitment;

        public ScopeChange() {
            this.committedWork = new List<ScopeChangeItem>();
            this.addedWork = new List<ADM_Work__c>();
            this.removedWork = new List<ScopeChangeItem>();
        }
    }

    public class ScopeChangeItem {
        public ADM_Work__c work;
        public Decimal committedStoryPoints;
        public String pointsDiffCssClass;

        public ScopeChangeItem() {}
    }

    public class SprintCommitment {
        public Decimal storyPoints;
        public Integer numOfItems;
        public List<ADM_Work__c> committedWork;

        public SprintCommitment() {}
    }
}