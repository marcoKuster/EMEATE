@isTest
public class ADM_SLAViolationTriggerTest {

    @isTest
    public static void saveSLAViolation(){
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        List<ADM_Work__c> works = new List<ADM_Work__c>();
        works.add(work);
        List<SLA_Violation__c> violations = ADM_WorkSLAViolationHelper.createAndInsertSLAViolations(works);
		System.debug('Hello : '+violations);
        violations.get(0).Status__c = 'Closed';
        update violations;
        System.assertEquals(violations.get(0).Status__c, 'Closed');
    }
    
    @isTest
    public static void saveSLAViolationWithTeamAsNull(){
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        List<ADM_Work__c> works = new List<ADM_Work__c>();
        works.add(work);
        List<SLA_Violation__c> violations = ADM_WorkSLAViolationHelper.createAndInsertSLAViolations(works);
		System.debug('Hello : '+violations);
        violations.get(0).Status__c = 'Closed';
        violations.get(0).Team__c = null;
        update violations;
        System.assertEquals(violations.get(0).Status__c, 'Closed');
    }
}