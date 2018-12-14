/**
 * Test utility class to support Release Event Templates
 *
 *    @testcaseID ADM_ReleaseTriggerTest
 *    @userstory W-2076536 https://gus.my.salesforce.com/a07B0000000dKy6 
 *    @author: snahm
 */
@isTest
public class ADM_ReleaseEventTemplateTestUtils {

    /*
     * Create a set of Release Event Templates to use for tests
     *
     * Test code is expected to fill in or update offsets, start time and other fields as needed before insert
     */

    public static List<ADM_Release_Event_Template__c> setupTestReleaseEventTemplates(ADM_Application__c app, String releaseType, Integer count) {
            
        final Integer TEST_DURATION = 30;
        List<ADM_Release_Event_Template__c> retList = new List<ADM_Release_Event_Template__c>();
        for (Integer i=0; i < count; i++) {
            ADM_Release_Event_Template__c ret = ADM_ReleaseEventTemplate.setupReleaseEventTemplate(app,
                'Test Template ' + i,
                TEST_DURATION,
                /*notifyCustomers*/ null,                   
                releaseType,
                /*dayOffset*/  i,      // count used for test dayOffset value
                /*hourOffset*/  null,  
                /*minuteOffset*/  null,  
                /*startTime*/  null,  
                /*instanceKey*/  null
                );
            retList.add(ret);
        }   
        return retList;
    }
}