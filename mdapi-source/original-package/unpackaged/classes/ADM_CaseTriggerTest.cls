@isTest
private class ADM_CaseTriggerTest {
    
    static testMethod void testTriggerOnInsert() {
        User u = ADM_WorkUser.createTest62Orguser(); 
        
        System.runAs(u) { 
            //create a work object
            ADM_Work__c work = ADM_Work.createTestWork();
            ADM_Work__c work2 = ADM_Work.createTestWork();
            
            //create a case
            ADM_Case__c newCase = new ADM_Case__c();
            newCase.Work__c = work.id;
            newCase.Case_Number__c = '12345';
            
            //insert the case and verify the works count was adjusted
            insert newCase;     
            ADM_Work__c modifiedWork = ADM_Work.get('id', work.id, 'id', 'ASC');        
            System.assertEquals(1, modifiedWork.Number_of_Cases__c);
        }    
    }   
    
    static testMethod void testTriggerOnUpdate() {
        User u = ADM_WorkUser.createTest62Orguser(); 
        
        System.runAs(u) { 
            Test.startTest();
            //create a work object
            ADM_Work__c work = ADM_Work.createTestWork();
            ADM_Work__c work2 = ADM_Work.createTestWork();
            
            //create a case
            ADM_Case__c newCase = new ADM_Case__c();
            newCase.Work__c = work.id;
            newCase.Case_Number__c = '12345';
            insert newCase;
            Test.stopTest();
            
            //modify the case and verify the original works count is adjusted back to 0
            ADM_Case__c modifiedCase = [select id, Work__c from ADM_Case__c where id = :newCase.id];
            modifiedCase.Work__c = work2.id;
            update modifiedCase;
            ADM_Work__c modifiedWork = ADM_Work.get('id', work.id, 'id', 'ASC');        
            System.assertEquals(0, modifiedWork.Number_of_Cases__c);
        }    
    }   
    
    static testMethod void testTriggerOnDelete() {
        User u = ADM_WorkUser.createTest62Orguser(); 
        
        System.runAs(u) { 
            Test.startTest();
            //create a work object
            ADM_Work__c work = ADM_Work.createTestWork();
            
            //create a case
            ADM_Case__c newCase = new ADM_Case__c();
            newCase.Work__c = work.id;
            newCase.Case_Number__c = '12345';
            
            //insert the case 
            insert newCase;     
            
            //delete the case verify the works count remains zero (not -1)
            delete newCase;
            Test.stopTest();
            ADM_Work__c modifiedWork = [select id, Number_of_Cases__c from ADM_Work__c where id =:work.id];
            System.assertEquals(0, modifiedWork.Number_of_Cases__c);
        }    
    }  
    
    static testMethod void testCommentIsAddedWhenCaseIsInserted() {
        User u = ADM_WorkUser.createTest62Orguser(); 
        
        System.runAs(u) { 
            //create a work object
            ADM_Work__c work = ADM_Work.createTestWork();
            ADM_Work__c work2 = ADM_Work.createTestWork();
            
            //create a case
            ADM_Case__c newCase = new ADM_Case__c();
            newCase.Work__c = work.id;
            newCase.Case_Number__c = '12345';
            
            //insert the case and verify the works count was adjusted
            insert newCase;     
            ADM_Work__c modifiedWork = ADM_Work.get('id', work.id, 'id', 'ASC');        
            System.assertEquals(1, modifiedWork.Number_of_Cases__c);
            
            //verify a comment on Work was created
            ADM_Comment__c comment = [select id, Body__c from ADM_Comment__c where Work__c=:work.id order by CreatedDate DESC limit 1];
            System.assert(comment.Body__c.contains('Added related 62 Org Case'), ' Unexpected Comment:' + comment);
            System.assert(comment.Body__c.contains('Case:' + newCase.Case_Number__c), ' Unexpected Comment:' + comment);
        }    
    }   
    
    //a comment should only be added to the work record when a case is first related to it, and not every time the case is edited
    static testMethod void testCommentIsNOTAddedWhenCaseIsUpdated() {
        User u = ADM_WorkUser.createTest62Orguser(); 
        
        System.runAs(u) { 
            Test.startTest();
            //create a work object
            ADM_Work__c work = ADM_Work.createTestWork();
            ADM_Work__c work2 = ADM_Work.createTestWork();
            
            //create a case
            ADM_Case__c newCase = new ADM_Case__c();
            newCase.Work__c = work.id;
            newCase.Case_Number__c = '12345';
            insert newCase;
            Test.stopTest();
            
            //verify a comment on Work was created for the INSERT
            ADM_Comment__c comment = [select id, Body__c from ADM_Comment__c where Work__c=:work.id order by CreatedDate DESC limit 1];
            System.assert(comment.Body__c.contains('Added related 62 Org Case'), ' Unexpected Comment:' + comment);
            System.assert(comment.Body__c.contains('Case:' + newCase.Case_Number__c), ' Unexpected Comment:' + comment);
            
            //edit the case
            newCase.Case_Subject__c = 'test subject';
            newCase.Case_Number__c = '999';
            update newCase;
            
            //verify a comment WAS NOT created for the EDIT
            ADM_Comment__c comment2 = [select id, Body__c from ADM_Comment__c where Work__c=:work.id order by CreatedDate DESC limit 1];
            System.assert(!comment2.Body__c.contains('Case:999'), ' Did not expect this comment to be created when a case is edited:' + comment2 + ' with body:' + comment2.Body__c);
        }    
    }   
    
      
    
    
     
}