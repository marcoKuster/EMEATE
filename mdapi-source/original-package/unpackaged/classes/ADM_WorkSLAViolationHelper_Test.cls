@isTest
class ADM_WorkSLAViolationHelper_Test {

    final static String DUMMY_WORK_ID = ADM_Work__c.sObjectType.getDescribe().getKeyPrefix() + 'c0000008iBgT';
    final static String DUMMY_ASSIGNEE_ID = '005B0000000goeV';
    final static String DUMMY_CS_CONTACT_ID = '005T0000000mz3X';
    final static String DUMMY_TEAM_ID = ADM_Scrum_Team__c.sObjectType.getDescribe().getKeyPrefix() + 'c0000004oQRk';
    final static String DUMMY_PROFILE_ID = '00eT0000000mLex';
    
    /** Insert sample data to be used by other test methods */
    @testSetup static void setup() {
        ADM_WorkSLATestData.setupTestData();
    }
    
    /**
     * Functional test for ADM_WorkSLAViolationHelper.createAndInsertSLAViolations()
     */
    @isTest static void test_CreateSLAViolation_DML() {
        // insert some data
        ADM_Scrum_Team__c team = ADM_WorkSLATestData.createTeamWithBHS('scrum team', null, true);
        ADM_Work__c workNew = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.INVESTIGATION_DEFAULT_SEV_LEVEL, ADM_WorkSLATestData.WORK_STATUS_NEW, team.Id, null, false);
        ADM_Work__c workInvestigating = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.INVESTIGATION_DEFAULT_SEV_LEVEL, ADM_WorkSLATestData.WORK_STATUS_INVESTIGATING, team.Id, null, false);
        ADM_Work__c workMoreInfoRequired = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.INVESTIGATION_DEFAULT_SEV_LEVEL, ADM_WorkSLATestData.WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT, team.Id, null, false);
        
        List<ADM_Work__c> works = new List<ADM_Work__c>{ workNew, workInvestigating, workMoreInfoRequired };
        insert works;
        
        // now set the SLA Due Time in the past to trigger a violation state
        Set<id> workIds = new Set<Id>();
        for (ADM_Work__c w : works) {
            workIds.add(w.Id);
            w.Due_Date__c = System.now().addHours(-8);
        }
        update works;
        
        Test.startTest();
        //create the SLA violations
        System.assertEquals(works.size(), ADM_WorkSLAViolationHelper.createAndInsertSLAViolations(works).size());
        Test.stopTest();

        List<SLA_Violation__c> violations = [SELECT Id, Name, Work__c, Status__c, Closed__c, Type__c, Assigned_To__c, Severity_Level__c
                                             FROM SLA_Violation__c WHERE Work__c IN :workIds];
        System.assertEquals(3, violations.size());
        
        for (SLA_Violation__c violation : violations) {
            System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONSTATUS_OPEN, violation.Status__c);
            System.assertEquals(false, violation.Closed__c);
            
            if (violation.Work__c == workNew.Id) {
                System.assertEquals(workNew.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_ACKNOWLEDGMENT, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getStandardUser().Id, violation.Assigned_To__c);
                
            } else if (violation.Work__c == workInvestigating.id) {
                System.assertEquals(workInvestigating.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_UPDATE, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getStandardUser().Id, violation.Assigned_To__c);

            } else if (violation.Work__c == workMoreInfoRequired.Id) {
                System.assertEquals(workMoreInfoRequired.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_SUPPORT, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getSupportUser().Id, violation.Assigned_To__c);

            } else {
                System.assert(false, 'Error: Found unexpected SLA Violation record');
            }
        }        
    }
    
    
    /**
     * Unit tests for ADM_WorkSLAViolationHelper.createSLAViolation(), which doesn't commit DB changes
     */
    @isTest static void test_CreateSLAViolation() {
        System.assertEquals(null, ADM_WorkSLAViolationHelper.createSLAViolation(null));
        
        ADM_Work__c work_bug = generateDummyWork(ADM_Work.RECORD_TYPE_NAME_BUG,ADM_WorkSLATestData.WORK_STATUS_NEW);
        System.assertEquals(null, ADM_WorkSLAViolationHelper.createSLAViolation(work_bug));
        
        ADM_Work__c work_rejected = generateDummyWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, ADM_WorkSLATestData.WORK_STATUS_REJECTED);
        System.assertEquals(null, ADM_WorkSLAViolationHelper.createSLAViolation(work_rejected));
        
        ADM_Work__c work_new = generateDummyWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, ADM_WorkSLATestData.WORK_STATUS_NEW);
        SLA_Violation__c violation_new = ADM_WorkSLAViolationHelper.createSLAViolation(work_new);
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONSTATUS_OPEN, violation_new.Status__c);
        System.assertEquals(DUMMY_WORK_ID, violation_new.Work__c);
        System.assertEquals(ADM_WorkSLATestData.INVESTIGATION_DEFAULT_SEV_LEVEL, violation_new.Severity_Level__c);
        System.assertEquals(DUMMY_TEAM_ID, violation_new.Team__c);
        System.assertEquals(DUMMY_ASSIGNEE_ID, violation_new.Assigned_To__c);
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_ACKNOWLEDGMENT,violation_new.Type__c);
        
        ADM_Work__c work_acked = generateDummyWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, ADM_WorkSLATestData.WORK_STATUS_INVESTIGATING);
        SLA_Violation__c violation_acked = ADM_WorkSLAViolationHelper.createSLAViolation(work_acked);
        System.assertEquals(DUMMY_ASSIGNEE_ID, violation_acked.Assigned_To__c);
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_UPDATE,violation_acked.Type__c);

        ADM_Work__c work_investigating = generateDummyWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, ADM_WorkSLATestData.WORK_STATUS_INVESTIGATING);
        SLA_Violation__c violation_investigating = ADM_WorkSLAViolationHelper.createSLAViolation(work_investigating);
        System.assertEquals(DUMMY_ASSIGNEE_ID, violation_investigating.Assigned_To__c);
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_UPDATE,violation_investigating.Type__c);

        ADM_Work__c work_moreinfo = generateDummyWork(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, ADM_WorkSLATestData.WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT);
        SLA_Violation__c violation_moreinfo = ADM_WorkSLAViolationHelper.createSLAViolation(work_moreinfo);
        System.assertEquals(DUMMY_CS_CONTACT_ID, violation_moreinfo.Assigned_To__c);
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_SUPPORT,violation_moreinfo.Type__c);
    }
    
    /**
     * Unit tests for ADM_WorkSLAViolationHelper.getViolationType()
     */
    @isTest static void test_GetViolationType() {
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_ACKNOWLEDGMENT, ADM_WorkSLAViolationHelper.getViolationType(ADM_WorkSLATestData.WORK_STATUS_NEW));
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_UPDATE, ADM_WorkSLAViolationHelper.getViolationType(ADM_WorkSLATestData.WORK_STATUS_INVESTIGATING));
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_UPDATE, ADM_WorkSLAViolationHelper.getViolationType(ADM_WorkSLATestData.WORK_STATUS_ACKNOWLEDGED));
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_SUPPORT, ADM_WorkSLAViolationHelper.getViolationType(ADM_WorkSLATestData.WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT));
        System.assertEquals(null, ADM_WorkSLAViolationHelper.getViolationType(ADM_WorkSLATestData.WORK_STATUS_REJECTED));
        System.assertEquals(null, ADM_WorkSLAViolationHelper.getViolationType(ADM_WorkSLATestData.WORK_STATUS_NEWBUGLOGGED));
    }
    
    /**
     * Basic unit test for ADM_WorkSLAViolationHelper.createAndInsertSLAViolation()
     */
    @isTest static void test_CreateAndInsertSLAViolation() {
        // set up test data
        ADM_Scrum_Team__c team = ADM_WorkSLATestData.createTeamWithBHS('scrum team', null, true);
        ADM_Work__c workNew = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV3, ADM_WorkSLATestData.WORK_STATUS_NEW, team.Id, null, true);
        
        Test.startTest();
        // test null handling
        System.assertEquals(null, ADM_WorkSLAViolationHelper.createAndInsertSLAViolation(null));
        
        // test valid Id
        Id slaViolationId = ADM_WorkSLAViolationHelper.createAndInsertSLAViolation(workNew.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, slaViolationId);
        
        SLA_Violation__c violation = [SELECT Id, Name, Work__c, Status__c, Closed__c, Type__c, Assigned_To__c, Severity_Level__c
                                             FROM SLA_Violation__c WHERE Id = :slaViolationId];
        System.assertNotEquals(null, violation);
        
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONSTATUS_OPEN, violation.Status__c);
        System.assertEquals(false, violation.Closed__c);
        System.assertEquals(workNew.Id, violation.Work__c);
        System.assertEquals(workNew.Severity_Level__c, violation.Severity_Level__c);
        System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_ACKNOWLEDGMENT, violation.Type__c);
        System.assertEquals(ADM_WorkSLATestData.getStandardUser().Id, violation.Assigned_To__c);
    }
    
    
    /**
     * Unit tests for ADM_WorkSLAViolationHelper.closeAndUpdateSLAViolations(), ensuring fields are updated correctly
     */
    @isTest static void test_CloseAndUpdateViolations_DML() {
        // insert some data
        ADM_Scrum_Team__c team = ADM_WorkSLATestData.createTeamWithBHS('scrum team', null, true);
        ADM_Work__c workNew = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV3, ADM_WorkSLATestData.WORK_STATUS_NEW, team.Id, null, false);
        ADM_Work__c workInvestigating = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV2, ADM_WorkSLATestData.WORK_STATUS_INVESTIGATING, team.Id, null, false);
        ADM_Work__c workMoreInfoRequired = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV1, ADM_WorkSLATestData.WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT, team.Id, null, false);
        
        List<ADM_Work__c> works = new List<ADM_Work__c>{ workNew, workInvestigating, workMoreInfoRequired };
        insert works;
        
        // now set the SLA Due Time in the past to trigger a violation state
        Set<id> workIds = new Set<Id>();
        for (ADM_Work__c w : works) {
            workIds.add(w.Id);
            w.Due_Date__c = System.now().addHours(-8);
        }
        update works;
        System.assertEquals(works.size(), ADM_WorkSLAViolationHelper.createAndInsertSLAViolations(works).size());
        
        Test.startTest();
        //close the SLA violations
        ADM_WorkSLAViolationHelper.closeAndUpdateSLAViolations(works);
        Test.stopTest();
        
        List<SLA_Violation__c> violations = [SELECT Id, Name, Work__c, Status__c, Closed__c, Type__c, Assigned_To__c, Severity_Level__c
                                             FROM SLA_Violation__c WHERE Work__c IN :workIds];
        
        System.assertEquals(3, violations.size());
        
        for (SLA_Violation__c violation : violations) {
            System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONSTATUS_CLOSED, violation.Status__c);
            System.assertEquals(true, violation.Closed__c);
            
            if (violation.Work__c == workNew.Id) {
                System.assertEquals(workNew.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_ACKNOWLEDGMENT, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getStandardUser().Id, violation.Assigned_To__c);
                
            } else if (violation.Work__c == workInvestigating.id) {
                System.assertEquals(workInvestigating.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_UPDATE, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getStandardUser().Id, violation.Assigned_To__c);

            } else if (violation.Work__c == workMoreInfoRequired.Id) {
                System.assertEquals(workMoreInfoRequired.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_SUPPORT, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getSupportUser().Id, violation.Assigned_To__c);

            } else {
                System.assert(false, 'Error: Found unexpected SLA Violation record');
            }
        }   
    }
    
    
    /**
     * Test that SLA violations get created correctly when an investigation is updated with Out_of_SLA__c = true
     */
   /* @isTest static void ftest_OpenAndCloseSLAViolations() {
        // insert some data
        ADM_Scrum_Team__c team = ADM_WorkSLATestData.createTeamWithBHS('scrum team', null, true);
        ADM_Work__c workNew = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV3, ADM_WorkSLATestData.WORK_STATUS_NEW, team.Id, null, false);
        ADM_Work__c workInvestigating = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV2, ADM_WorkSLATestData.WORK_STATUS_INVESTIGATING, team.Id, null, false);
        ADM_Work__c workMoreInfoRequired = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV1, ADM_WorkSLATestData.WORK_STATUS_MOREINFOREQUIREDFROMSUPPORT, team.Id, null, false);
        ADM_Work__c workNoCase = ADM_WorkSLATestData.createInvestigation(ADM_WorkSLATestData.SEV3, ADM_WorkSLATestData.WORK_STATUS_INVESTIGATING, team.Id, null, false);
        List<ADM_Work__c> works = new List<ADM_Work__c>{ workNew, workInvestigating, workMoreInfoRequired, workNoCase };
        insert works;

        // Phase I. Open SLA violations
        Set<id> workIds = new Set<Id>();
        List<ADM_Case__c> cases = new List<ADM_Case__c>();
        List<ADM_Work__c> worksOpenViolations = new List<ADM_Work__c>();
        for (ADM_Work__c w : works) {
            workIds.add(w.Id);
            if (w.Id != workNoCase.Id) {
                cases.add( ADM_WorkSLATestData.createCaseForWork(w.Id) );
            }
            // create a new Work record with just the fields we want to update
            worksOpenViolations.add( new ADM_Work__c(Id = w.Id, Out_of_SLA__c = true) );
        }
        insert cases; // work must have 1+ cases for SLA Violaton to get created
        update worksOpenViolations; 
        
        // query violations to assert values
        List<SLA_Violation__c> openViolations = [SELECT Id, Name, Work__c, Status__c, Closed__c, Type__c, Assigned_To__c, Severity_Level__c
                                                 FROM SLA_Violation__c WHERE Work__c IN :workIds];
        
        System.assertEquals(3, openViolations.size());
        
        Test.startTest();
        
        for (SLA_Violation__c violation : openViolations) {
            // violations should be open
            System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONSTATUS_OPEN, violation.Status__c, ''+violation);
            System.assertEquals(false, violation.Closed__c);
            
            if (violation.Work__c == workNew.Id) {
                System.assertEquals(workNew.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_ACKNOWLEDGMENT, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getStandardUser().Id, violation.Assigned_To__c);
                
            } else if (violation.Work__c == workInvestigating.id) {
                System.assertEquals(workInvestigating.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_UPDATE, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getStandardUser().Id, violation.Assigned_To__c);

            } else if (violation.Work__c == workMoreInfoRequired.Id) {
                System.assertEquals(workMoreInfoRequired.Severity_Level__c, violation.Severity_Level__c);
                System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONTYPE_SUPPORT, violation.Type__c);
                System.assertEquals(ADM_WorkSLATestData.getSupportUser().Id, violation.Assigned_To__c);

            } else {
                System.assert(false, 'Error: Found unexpected SLA Violation record');
            }
        }
        
        
        // Phase II. Close SLA violations
        
        // 1. Satisfy SLA by acknowledging a New investigation
        update new ADM_Work__c(Id=workNew.Id, Status__c=ADM_WorkSLATestData.WORK_STATUS_ACKNOWLEDGED);
        // 2. Satisfy SLA by posting a Chatter comment as a T&P user on an inv in Investigating status
        System.runAs(ADM_WorkSLATestData.getStandardUser()) {
            insert new List<FeedItem> {
                    new FeedItem(ParentId=workInvestigating.Id, Body='Made a lot of progress'),
                    new FeedItem(ParentId=workNoCase.Id, Body='This inv is internal but still important')
                };
            
        }
        // 3. Satisfy SLA by posting a Chatter comment as a Support user on an inv in More Info Required status
        System.runAs(ADM_WorkSLATestData.getSupportUser()) {            
            FeedItem post = new FeedItem();
            post.ParentId = workMoreInfoRequired.Id;
            post.Body = 'Calling the customer today';
            insert post;
        }
        
        List<ADM_Work__c> queriedWork = [SELECT Id, Out_of_SLA__c FROM ADM_Work__c WHERE id IN :workIds];
        for (ADM_Work__c work : queriedWork) {
            System.assertEquals(false, work.Out_of_SLA__c);
        }
        
        // re-query violations to assert new values
        List<SLA_Violation__c> closedViolations = [SELECT Id, Name, Work__c, Status__c, Closed__c, Type__c, Assigned_To__c, Severity_Level__c
                                                   FROM SLA_Violation__c WHERE Work__c IN :workIds];
        
        System.assertEquals(3, closedViolations.size());
        for (SLA_Violation__c violation : closedViolations) {
            System.assertEquals(ADM_WorkSLAViolationHelper.VIOLATIONSTATUS_CLOSED, violation.Status__c, ''+violation);
            System.assertEquals(true, violation.Closed__c);
        }
        Test.stopTest();
    } */

    
    
    /****** HELPER METHODS ******/
    
    
    
    static ADM_Work__c generateDummyWork(String recordTypeName, String status) {
        return new ADM_Work__c(
            Type__c = recordTypeName,
            RecordTypeId = ADM_WorkSLATestData.getRecordTypeFor(recordTypeName).Id,
            Status__c = status,
            Id = DUMMY_WORK_ID,
            Severity_Level__c = ADM_WorkSLATestData.INVESTIGATION_DEFAULT_SEV_LEVEL,
            Assignee__c = DUMMY_ASSIGNEE_ID,
            CS_Contact__c = DUMMY_CS_CONTACT_ID,
            Scrum_Team__c = DUMMY_TEAM_ID,
            Subject__c = 'subject',
            Details_and_Steps_to_Reproduce__c = 'details and steps to reproduce',
            Impact__c = ADM_WorkSLATestData.getImpact().Id,
            Priority__c = ADM_WorkSLATestData.getPriority().Id,
            Product_Tag__c = ADM_WorkSLATestData.getProductTag().Id,
            Found_in_Build__c = ADM_WorkSLATestData.getBuild().Id
            );
    }
}