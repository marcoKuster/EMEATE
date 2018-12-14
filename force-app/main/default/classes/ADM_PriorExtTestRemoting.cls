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
private class ADM_PriorExtTestRemoting {
    private static String lorem = 'lorem ipsum dolor sit amet';

    @IsTest
    private static ADM_PriorExt setupPrioritizer() {
        List<ADM_Work__c> recs = new List<ADM_Work__c>();
        List<ADM_Sprint__c> sprints = new List<ADM_Sprint__c>();
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam(); 
        ADM_Product_Tag__c tag = [select id, Team__c from ADM_Product_Tag__c where id =:work.Product_Tag__c];
        tag.Team__c = team.id;
        update tag;
        work.Product_Tag__c = tag.id;
        update work;
        work = [select id, Subject__c, Status__c, Use_Prioritizer__c, Found_In_Build__c, Scheduled_Build__c, Type__c, Impact__c, Frequency__c, Scrum_Team__c, Sprint__c, Product_Tag__c from ADM_Work__c where id=:work.id];
        System.assertEquals(work.Scrum_Team__c, team.id);
        
        ADM_Sprint__c sprint;
        
        
        
        for(Integer i = 0; i < 3; i++) {
            ADM_Work__c w = work.clone(false, false);
            w.Use_Prioritizer__c = true;
            w.Priority_Rank__c = null;
            recs.add(w);
        }
        
        //repeat but add a priority rank
        for(Integer j = 1; j < 2; j++) {
            ADM_Work__c w = work.clone(false, false);
            w.Use_Prioritizer__c = true;
            w.Priority_Rank__c = j;
            recs.add(w);
        }
        
        insert recs;
        
        
        String sprintName = '';
        List<String> alpha = new List<String>{'a','b','c','d','e','f','g','h','i','j','k'};
        
        for(Integer i = 0; i < 7; i++) {
            sprint = new ADM_Sprint__c();
            
            if(i == 6) {
                sprint.Start_Date__c = Date.today().addDays(-1);
                sprint.End_Date__c = Date.today();
            } else {
                sprint.Start_Date__c = Date.today().addDays(-100 - i - 1);
                sprint.End_Date__c = Date.today().addDays(-100 - i);
                sprint.Completed_Story_Points__c = i;   
            }
            
            sprintName = String.valueOf(sprint.Start_Date__c.month());
            
            if(sprintName.length() == 1) {
                sprintName = '0' + sprintName;
            }
            
            sprintName = sprint.Start_Date__c.year() + '.' + sprintName;
            
            if(i == 6) {
                sprintName += alpha.get(0);
            } else {
                sprintName += alpha.get(i);
            }
            
            sprintName += '-' + team.Name;
            sprint.Name = sprintName;
            sprint.Scrum_Team__c = team.Id;
            
            sprints.add(sprint);                
        }
        
        insert sprints; 
        
        System.debug('-->' + work.Scrum_Team__c);
        
        System.currentPageReference().getParameters().put('scrumteamId', team.id);
        Apexpages.Standardcontroller ctrl = new Apexpages.Standardcontroller(work);
        ADM_PriorExt ext = new ADM_PriorExt(ctrl);
        
        System.assertEquals(work.Scrum_Team__c, ext.teamId);
        
        return ext;     
    }
    
    /*
    @testcaseID a1DB000000018or
    @userstoryID a07B0000000Eq0GIAS
    @hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.In-Row Edit Bug
    @Expected Results Error message is generated that Sprint is invalid. Other changes made on the details view are not lost
    @ Author: Alexis Williams 
    */
 
     /*
    @testcaseID a1DB000000018os
    @userstoryID a07B0000000Eq0GIAS
    @hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.In-Row Edit Bug
    @Expected Results Error message is generated that Theme is invalid. Other changes made on the details view are not lost
    @ Author: Alexis Williams 
    */

     /*
    @testcaseID a1DB000000018ox
    @userstoryID a07B0000000Eq0GIAS
    @hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.In-Row Edit Bug
    @Expected Results The Subject saves normally
    @ Author: Alexis Williams 
    */


     /*
    @testcaseID a1DB000000018p2
    @userstoryID a07B0000000Eq0GIAS
    @hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.In-Row Edit User Story
    @Expected Results User can save changes when in-row editing a user story in the Prioritizer
    @ Author: Alexis Williams 
    */


    /*
    @testcaseID a1DB000000018ow
    @userstoryID a07B0000000Eq0GIAS
    @hierarchy GUS.ScrumforceToGUS.ScrumTeams.Prioritizer.In-Row Edit Bug
    @Expected Results Error is generated
    @ Author: Alexis Williams 
    */
    static testMethod void testUpdateWorkVals() {
        ADM_PriorExt ext = setupPrioritizer();
        ADM_Work__c work = ext.backlogRecs.get(0);
        ADM_DmlResult result;
        String workId, subject, details, status;
        
        //#1 Call method without any valid values       
        result = ADM_PriorExt.updateWorkVals(workId, subject, details, status);
        System.assertEquals(null, result);
        
        //#2 Call without any valid subject, details, or status & a valid workId
        result = ADM_PriorExt.updateWorkVals(work.Id, subject, details, status);
        System.assertEquals(null, result);
        
        //#3 Call with valid subject only
        subject = 'Test';
        result = ADM_PriorExt.updateWorkVals(workId, subject, details, status);
        System.assertEquals(null, result);
        
        //#4 Call with valid details only
        details = 'Test';
        subject = null;
        result = ADM_PriorExt.updateWorkVals(workId, subject, details, status);
        System.assertEquals(null, result);
        
        //#5 Call with valid status only
        details = null;
        status = 'New';
        subject = null;     
        result = ADM_PriorExt.updateWorkVals(workId, subject, details, status);
        System.assertEquals(null, result); 
    }
    
 

    

    
   
    
}