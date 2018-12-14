@isTest
private class ADM_DeepCloneTests {

/*
@testcaseID a1DB00000000suj
@userstory a0790000000DCgP
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.deep clone Page
@expected results Subject, Type, Product Area, Major Func Area, Minor Func Area, Help Status, Customer, FIB, SB, Sprint, Theme, Backlog Rank, Impact, Frequency, Priority and assignees are deep cloned
@ Perforce Status, Root Cause Analysis, Attribute fields are not deep cloned 
@ Status = New
@ System fields are reset
@author: James Hatton
*/

    static testMethod void testWorkDeepCloneControllerRedirectForBug() {
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        //refresh after autoassignments
        original = ADM_Work.getOneBy('id', original.id);
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneWork();
        Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        //make sure the name field which should be unique was not cloned
        System.assert(original.Name != clone.Name, 'Name has been cloned! Original:' + original.Name + ' id:' + original.id + ' Clone:' + clone.Name + ' id:' + clone.id);
        System.assertEquals(original.Subject__c, clone.Subject__c);
        //make sure the Status was reset
        System.assertEquals('New', clone.Status__c);
        //verfiy RCA was not cloned
        System.assert(clone.Root_Cause_Analysis_2__c == null);
        //verfiy clone
        System.assertEquals(original.Product_Tag__c, clone.Product_Tag__c);
        System.assertEquals(original.Found_In_Build__c, clone.Found_In_Build__c);
        System.assertEquals(original.Scheduled_Build__c, clone.Scheduled_Build__c);
        System.assertEquals(original.Assignee__c, clone.Assignee__c);
        System.assertEquals(original.QA_Engineer__c, clone.QA_Engineer__c);
        System.assertEquals(original.UE_Engineer__c, clone.UE_Engineer__c);
        System.assertEquals(original.System_Test_Engineer__c, clone.System_Test_Engineer__c);
        System.assertEquals(original.Product_Owner__c, clone.Product_Owner__c);
        System.assertEquals(original.Tech_Writer__c, clone.Tech_Writer__c);
       
    }
    
 /*
@testcaseID a1DB00000000sv3
@userstory a0790000000DCgP
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.deep clone Page
@expected results A test failure is cloned and the "Regressed" attribute is selected, whether this attribute was in the original bug or not
@author: James Hatton
*/

    static testMethod void testWorkDeepCloneControllerRedirectForTestFailure() {
        ADM_Work__c original = ADM_Work.setupTestWork('Bug');
        original.Type__c = 'Test Failure';
        original.Priority__c = 'P1';
        insert original;
        //refresh after autoassignments
        original = ADM_Work.getOneBy('id', original.id);
        original.Type__c = 'Test Failure';
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneWork();
        Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        //make sure the name field which should be unique was not cloned
        System.assert(original.Name != clone.Name);
        System.assertEquals(original.Subject__c, clone.Subject__c);
        //make sure the Status was reset
        System.assertEquals('New', clone.Status__c);
        //verfiy RCA was not cloned
        System.assert(clone.Root_Cause_Analysis_2__c == null);
        //verfiy clone
        System.assertEquals(original.Product_Tag__c, clone.Product_Tag__c);
        System.assertEquals(original.Found_In_Build__c, clone.Found_In_Build__c);
        System.assertEquals(original.Scheduled_Build__c, clone.Scheduled_Build__c);
        System.assertEquals(original.Assignee__c, clone.Assignee__c);
        System.assertEquals(original.QA_Engineer__c, clone.QA_Engineer__c);
        System.assertEquals(original.UE_Engineer__c, clone.UE_Engineer__c);
        System.assertEquals(original.System_Test_Engineer__c, clone.System_Test_Engineer__c);
        System.assertEquals(original.Scrum_Team__c, clone.Scrum_Team__c);
        System.assertEquals(original.Product_Owner__c, clone.Product_Owner__c);
        System.assertEquals(original.Tech_Writer__c, clone.Tech_Writer__c);
        System.assert(clone.Attributes__c != null && clone.Attributes__c.contains('Regressed'));
       
    }
    
  /*
@testcaseID a1DB00000000sv4
@userstory a0790000000DCgP
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.deep clone Page
@expected results A test change is cloned and the "Regressed" attribute is selected, whether this attribute was in the original bug or not
@author: James Hatton
*/

    static testMethod void testWorkDeepCloneControllerRedirectForTestChange() {
        ADM_Work__c original = ADM_Work.setupTestWork('Bug');
        original.Type__c = 'Test Change';
        original.Priority__c = 'P1';
        insert original;
        //refresh after autoassignments
        original = ADM_Work.getOneBy('id', original.id);
        original.Type__c = 'Test Failure';
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneWork();
        Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        //make sure the name field which should be unique was not cloned
        System.assert(original.Name != clone.Name);
        System.assertEquals(original.Subject__c, clone.Subject__c);
        //make sure the Status was reset
        System.assertEquals('New', clone.Status__c);
        //verify RCA was not cloned
        System.assert(clone.Root_Cause_Analysis_2__c == null);
        //verify clone
        System.assertEquals(original.Product_Tag__c, clone.Product_Tag__c);
        System.assertEquals(original.Found_In_Build__c, clone.Found_In_Build__c);
        System.assertEquals(original.Scheduled_Build__c, clone.Scheduled_Build__c);
        System.assertEquals(original.Assignee__c, clone.Assignee__c);
        System.assertEquals(original.QA_Engineer__c, clone.QA_Engineer__c);
        System.assertEquals(original.UE_Engineer__c, clone.UE_Engineer__c);
        System.assertEquals(original.System_Test_Engineer__c, clone.System_Test_Engineer__c);
        System.assertEquals(original.Scrum_Team__c, clone.Scrum_Team__c);
        System.assertEquals(original.Product_Owner__c, clone.Product_Owner__c);
        System.assertEquals(original.Tech_Writer__c, clone.Tech_Writer__c);
        System.assert(clone.Attributes__c != null && clone.Attributes__c.contains('Regressed'));
       
    }
    
/*
@testcaseID a1DB00000000sup
@userstory a0790000000DCgP
@hierarchy GUS.ScrumforceToGUS.Work Page.User Story.deep clone page
@expected results  Subject, Description, Product Area, Major Func Area, Minor Func Area, Help Status, Customer, SB, Sprint, Theme, Backlog Rank, Story Points and assignees are deep cloned 
@ Perforce Status, Attribute fields are not deep cloned. "Requires Testing" is selected 
@ Status = New
@ System fields are reset
@author: James Hatton
*/

   static testMethod void testWorkDeepCloneControllerRedirectForUserStory() {
        ADM_Work__c original = ADM_Work.createTestWork('User Story');
        //refresh after autoassignments
        original = ADM_Work.getOneBy('id', original.id);
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneWork();
        Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        //make sure the name field which should be unique was not cloned
        System.assert(original.Name != clone.Name);
        System.assertEquals(original.Subject__c, clone.Subject__c);
        //make sure the Status was reset
        System.assertEquals('New', clone.Status__c);
        //verfiy RCA was not cloned
        System.assert(clone.Root_Cause_Analysis_2__c == null);
        //verfiy clone
        System.assertEquals(original.Product_Tag__c, clone.Product_Tag__c);
        System.assertEquals(original.Found_In_Build__c, clone.Found_In_Build__c);
        System.assertEquals(original.Scheduled_Build__c, clone.Scheduled_Build__c);
        System.assertEquals(original.Assignee__c, clone.Assignee__c);
        System.assertEquals(original.QA_Engineer__c, clone.QA_Engineer__c);
        System.assertEquals(original.UE_Engineer__c, clone.UE_Engineer__c);
        System.assertEquals(original.System_Test_Engineer__c, clone.System_Test_Engineer__c);
        System.assertEquals(original.Product_Owner__c, clone.Product_Owner__c);
        System.assertEquals(original.Tech_Writer__c, clone.Tech_Writer__c);
        System.assert(clone.Attributes__c != null && clone.Attributes__c.contains('Requires Testing'));
       
    }
    
    
/*
@testcaseID a1DB00000000suk
@userstory a0790000000DCgP
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.deep clone Page
@expected results A screen with options appears after clicking the Deep Clone Button. The screen contains the options to clone on the left and a preview of what the user is cloning on the right.
@author: James Hatton
*/
    static testMethod void testAcceptanceCriterionCloner() {
        //setup intial clone
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        //give it some AC
        ADM_Acceptance_Criterion__c ac = new ADM_Acceptance_Criterion__c();
        ac.Work__c = original.id;
        ac.Name = 'Test 123';
        ac.Description__c = 'Test ABC';
        insert ac;
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        PageReference pr = wdc.cloneWork();
       Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        
        try {
            List<ADM_Acceptance_Criterion__c> originalAC = [select id, Name, Description__c, Status__c from ADM_Acceptance_Criterion__c where Work__c = :original.id];
            List<ADM_Acceptance_Criterion__c> clonedAC = [select id, Name, Description__c, Status__c from ADM_Acceptance_Criterion__c where Work__c = :clone.id];
            System.assertEquals(originalAC.size(), clonedAC.size(), 'Expected all acceptance criteria to be cloned');
        } catch (Exception e) {
            System.assert(false, 'Did not expect an excpetion to be thrown:' + e);
        }    
    }
    
    static testMethod void testCloneWithoutAcceptanceCriterion() {
        //setup intial clone
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        
        //give it some AC
        ADM_Acceptance_Criterion__c ac = new ADM_Acceptance_Criterion__c();
        ac.Work__c = original.id;
        ac.Name = 'Test 123';
        ac.Description__c = 'Test ABC';
        insert ac;
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneAcceptanceCriteria = false;
        PageReference pr = wdc.cloneWork();
        
        //retrieve clone and compare with original
        Id cloneID = wdc.getCloneOfWork().Id;
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        
        try {
            Integer numberOfClones = [select count() from ADM_Acceptance_Criterion__c where Work__c = :cloneID];
            System.assertEquals(0, numberOfClones, 'Expected none of the acceptance criterion to be cloned');
        } catch (Exception e) {
            System.assert(false, 'Did not expect an excpetion to be thrown:' + e);
        }    
    }


        static testMethod void testDeepCloneGetWorkDetails(){
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        ADM_Acceptance_Criterion__c ac = new ADM_Acceptance_Criterion__c();
        ac.Work__c = original.id;
        ac.Name = 'Test 123 ac';
        ac.Description__c = 'Test ABC';
        insert ac;
        
        ADM_Task__c t = new ADM_Task__c();
        t.Work__c = original.id;
        t.Subject__c = 'Test 123';
        t.Assigned_To__c = UserInfo.getUserId();
        insert t;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        List<ADM_Parent_Work__c> plist = new List<ADM_Parent_Work__c>();
        
        for(Integer i = 0; i <2; i++) {
            //make the 1st record child of the rest
            ADM_Parent_Work__c rel = new ADM_Parent_Work__c();
            rel.Parent_Work__c = original.id;
            rel.Child_Work__c = works.get(i).id;
            plist.add(rel);
        }
        
        insert plist;
        
        List<ADM_Parent_Work__c> clist = new List<ADM_Parent_Work__c>();
        
        for(Integer i = 2; i < 6; i++) {
            //make the 1st record child of the rest
            ADM_Parent_Work__c rel = new ADM_Parent_Work__c();
            rel.Parent_Work__c = works.get(i).id;
            rel.Child_Work__c = original.id;
            clist.add(rel);
        }
        
        insert clist;

        ADM_WorkDeepCloneController.DeepCloneWorkDetailResponse workDetails = ADM_WorkDeepCloneController.getWorkDetails(original.id);
        System.assertEquals(workDetails.tasks.size(), 1);
        System.assertEquals(workDetails.tasks.get(0).Subject__c, 'Test 123');
        System.assertEquals(workDetails.ac.size(), 1);
        System.assertEquals(workDetails.ac.get(0).Name, 'Test 123 ac');
        System.assertEquals(workDetails.childWork.size(), 2);
        System.assertEquals(workDetails.parentWork.size(), 4);
        System.assertEquals(workDetails.workObj.id, original.id);
        System.assertEquals(workDetails.workObj.Status__c, original.Status__c);
        
    }
    
    
    static testMethod void testdeepCloneWorkForLightning(){
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        
        ADM_Acceptance_Criterion__c ac = new ADM_Acceptance_Criterion__c();
        ac.Work__c = original.id;
        ac.Name = 'Test 123 ac';
        ac.Description__c = 'Test ABC';
        insert ac;
        
        ADM_Task__c t = new ADM_Task__c();
        t.Work__c = original.id;
        t.Subject__c = 'Test 123';
        t.Assigned_To__c = UserInfo.getUserId();
        insert t;

        Map<String,Object> deepCloneOptions = new Map<String,Object>();
        deepCloneOptions.put('isTheme',true);
        deepCloneOptions.put('isAc',true);
        deepCloneOptions.put('isTasks',true);
        deepCloneOptions.put('isParent',true);
        deepCloneOptions.put('isChild',true);
        deepCloneOptions.put('parentSelect','Records');
        deepCloneOptions.put('childSelect','Records');
        deepCloneOptions.put('workId',original.id);

        String recId =  ADM_WorkDeepCloneController.deepCloneWork(deepCloneOptions);
        
        ADM_Work__c workObject = [select id, Name, Subject__c, Status__c, Scrum_Team__c,Scrum_Team__r.Name, Scrum_Team__r.id, Theme__c  from ADM_Work__c where id=:recId];
        List<ADM_Task__c> tasks = [select id, Name, Subject__c, Hours_Remaining__c from ADM_Task__c where Work__c =: recId ];
        List<ADM_Acceptance_Criterion__c> acList = [select id, Name, Description__c from ADM_Acceptance_Criterion__c where Work__c=: recId];
        
        System.assertEquals(workObject.Subject__c, original.Subject__c);
        System.assertEquals(tasks.size(), 1);
        System.assertEquals(tasks.size(), 1);
        System.assertEquals(tasks.get(0).Subject__c, 'Test 123');
        System.assertEquals(acList.get(0).Name, 'Test 123 ac');

    }
    
/*
@testcaseID a1DB00000000sul
@userstory a0790000000DCgP
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.deep clone Page
@expected results A screen with options appears after clicking the Deep Clone Button. The screen contains the options to clone on the left and a preview of what the user is cloning on the right.
@author: James Hatton
*/
    static testMethod void testTaskCloner() {
        //setup intial clone
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        
        ADM_Task__c t = new ADM_Task__c();
        t.Work__c = original.id;
        t.Subject__c = 'Test 123';
        t.Assigned_To__c = UserInfo.getUserId();
        insert t;
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        PageReference pr = wdc.cloneWork();
        Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        
        try {
            List<ADM_Task__c> originals = [select id from ADM_Task__c where Work__c = :original.id];
            List<ADM_Task__c> clones = [select id from ADM_Task__c where Work__c = :clone.id];
            System.assertEquals(originals.size(), clones.size(), 'Expected all of the tasks to be cloned');
        } catch (Exception e) {
            System.assert(false, 'Did not expect an excpetion to be thrown:' + e);
        }
        
    }
    
    static testMethod void testCloneWithoutTasks() {
        //setup intial clone
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        
        ADM_Task__c t = new ADM_Task__c();
        t.Work__c = original.id;
        t.Subject__c = 'Test 123';
        t.Assigned_To__c = UserInfo.getUserId();
        insert t;
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneTasks = false;
        PageReference pr = wdc.cloneWork();
        
        //retrieve clone and compare with original
        Id cloneID = wdc.getCloneOfWork().Id;
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        
        try {
            Integer numberOfClones = [select count() from ADM_Task__c where Work__c = :cloneID];
            System.assertEquals(0, numberOfClones, 'Expected none of the tasks to be cloned');
        } catch (Exception e) {
            System.assert(false, 'Did not expect an excpetion to be thrown:' + e);
        }
        
    }
  
/*
@testcaseID a1DB00000000sun
@userstory a0790000000DCgP
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.deep clone Page
@expected results A screen with options appears after clicking the Deep Clone Button. The screen contains the options to clone on the left and a preview of what the user is cloning on the right. 
@author: James Hatton
*/
    static testMethod void testParentWorkCloner() {
        
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        List<ADM_Parent_Work__c> plist = new LIst<ADM_Parent_Work__c>();
        
        for(Integer i = 1; i < works.size(); i++) {
            //make the 1st record child of the rest
            ADM_Parent_Work__c rel = new ADM_Parent_Work__c();
            rel.Parent_Work__c = works.get(i).id;
            rel.Child_Work__c = works.get(0).id;
            plist.add(rel);
        }
        
        insert plist;
        
        //setup intial clone
        ADM_Work__c original = works.get(0);
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.parentValue = 'Relationships';
        PageReference pr = wdc.cloneWork();
       Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        
        try {
            List<ADM_Parent_Work__c> originals = [select id from ADM_Parent_Work__c where Child_Work__c = :original.id];
            List<ADM_Parent_Work__c> clones = [select id from ADM_Parent_Work__c where Child_Work__c = :clone.id];
            System.assertEquals(originals.size(), clones.size(), 'Expected all parent work relationships to be cloned'); 
        } catch (Exception e) {
            System.assert(false, 'Did not expect an excpetion to be thrown:' + e);
        }
        
    }
    
    static testMethod void testCloneWithoutParentWork() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        
        //setup intial clone
        //make the 1st record parent of the rest
        ADM_Work__c original = works.get(0);
        
        List<ADM_Parent_Work__c> plist = new List<ADM_Parent_Work__c>();
        for(Integer i = 1; i < works.size(); i++) {
            ADM_Parent_Work__c relationship = new ADM_Parent_Work__c();
            relationship.Parent_Work__c = works.get(i).id;
            relationship.Child_Work__c = original.id;
            plist.add(relationship);
        }
        insert plist;
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        PageReference pr = wdc.cloneWork();
        
        //make sure the clone is not the same as the original
        Id cloneID = wdc.getCloneOfWork().Id;
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        
        try {
            Integer numberOfClonedRelationships = [select count() from ADM_Parent_Work__c where Child_Work__c = :cloneID];
            System.assertEquals(0, numberOfClonedRelationships, 'Expected none of the parent work relationships to be cloned'); 
        } catch (Exception e) {
            System.assert(false, 'Did not expect an exception to be thrown:' + e);
        }
        
    }

/*
@testcaseID a1DB00000000sun
@userstory a0790000000DCgP
@hierarchy GUS.ScrumforceToGUS.Work Page.Bug.deep clone Page
@expected results A screen with options appears after clicking the Deep Clone Button. The screen contains the options to clone on the left and a preview of what the user is cloning on the right. 
@author: James Hatton
*/    
    static testMethod void testChildWorkCloner() {
        
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        List<ADM_Parent_Work__c> plist = new LIst<ADM_Parent_Work__c>();
        
        for(Integer i = 1; i < works.size(); i++) {
            //make the 1st record parent of the rest
            ADM_Parent_Work__c rel = new ADM_Parent_Work__c();
            rel.Parent_Work__c = works.get(0).id;
            rel.Child_Work__c = works.get(i).id;
            plist.add(rel);
        }
        
        insert plist;
        
        //setup intial clone
        ADM_Work__c original = works.get(0);
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.childValue = 'Relationships';
        PageReference pr = wdc.cloneWork();
       Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        
        try {
            List<ADM_Parent_Work__c> originals = [select id from ADM_Parent_Work__c where Parent_Work__c = :original.id];
            List<ADM_Parent_Work__c> clones = [select id from ADM_Parent_Work__c where Parent_Work__c = :clone.id];
            System.assertEquals(originals.size(), clones.size(), 'Expected all child work relationships to be cloned'); 
        } catch (Exception e) {
            System.assert(false, 'Did not expect an excpetion to be thrown:' + e);
        }
        
    }
    
    static testMethod void testCloneWithoutChildWork() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(6, 'Bug');
        insert works;
        
        //setup intial clone
        //make the 1st record parent of the rest
        ADM_Work__c original = works.get(0);
        
        List<ADM_Parent_Work__c> plist = new List<ADM_Parent_Work__c>();
        for(Integer i = 1; i < works.size(); i++) {
            ADM_Parent_Work__c relationship = new ADM_Parent_Work__c();
            relationship.Parent_Work__c = original.id;
            relationship.Child_Work__c = works.get(i).id;
            plist.add(relationship);
        }
        insert plist;
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        PageReference pr = wdc.cloneWork();
        
        //make sure the clone is not the same as the original
        Id cloneID = wdc.getCloneOfWork().Id;
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        
        try {
            Integer numberOfClonedRelationships = [select count() from ADM_Parent_Work__c where Parent_Work__c = :cloneID];
            System.assertEquals(0, numberOfClonedRelationships, 'Expected none of the child work relationships to be cloned'); 
        } catch (Exception e) {
            System.assert(false, 'Did not expect an exception to be thrown:' + e);
        }
        
    }
    
/*
@testcaseID a1DB00000004lUV
@userstory a07B0000000U7fP
@hierarchy GUS.Multi Themes.Deep Cloning
@expected results Multiple themes will be deep cloned along with other items such as AC, tasks, parent and/or child records
*/  
    static testMethod void testThemeAssignmentCloner() {
        
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'TestTheme-asdfzxcv2';
        insert theme;
        
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = original.Id;
        themeAssignment.Theme__c = theme.Id;
        insert themeAssignment;
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneThemeAssignments = true;
        PageReference pr = wdc.cloneWork();
       Id cloneID = wdc.getCloneOfWork().Id;
        //retrieve clone and compare with original
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        ADM_Work__c clone = ADM_Work.getOneBy('id', cloneID);
        
        try {
            List<ADM_Theme_Assignment__c> clones = [select id from ADM_Theme_Assignment__c where Work__c = :clone.id];
            System.assertEquals(1, clones.size(), 'Expected all theme assignments to be cloned'); 
        } catch (Exception e) {
            System.assert(false, 'Did not expect an excpetion to be thrown:' + e);
        }
        
    }
    
    static testMethod void testCloneWithoutThemeAssignments() {
        
        ADM_Work__c original = ADM_Work.createTestWork('Bug');
        
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'TestTheme-asdfzxcv2';
        insert theme;
        
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = original.Id;
        themeAssignment.Theme__c = theme.Id;
        insert themeAssignment;
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneThemeAssignments = false;
        PageReference pr = wdc.cloneWork();
        
        //make sure the clone ID is not the same as the 
        Id cloneID = wdc.getCloneOfWork().Id;
        System.assert(cloneID != null);
        System.assert(cloneID != original.id);
        
        try {
            Integer numberOfClones = [select count() from ADM_Theme_Assignment__c where Work__c = :cloneID];
            System.assertEquals(0, numberOfClones, 'Expected none of the theme assignments to be cloned'); 
        } catch (Exception e) {
            System.assert(false, 'Did not expect an exception to be thrown:' + e);
        }
        
    }
    
     /**
     * Test clone will set Status to 'New'
     */
    public testMethod static void testDeepCloneSetStatusFieldToNew() {
        ADM_Work__c work = ADM_Work.createTestWork('Bug');
        work.Status__c = 'In Progress';
        update work;
        
        ADM_Work__c original = [select id, RecordTypeId, Status__c from ADM_Work__c where Id = :work.Id];
        
        System.assert('In Progress' == original.Status__c, 'Expeced In Progress status for original work record');
        
        
        ApexPages.StandardController std = new ApexPages.StandardController(original);
        ADM_WorkDeepCloneController wdc = new ADM_WorkDeepCloneController(std);
        wdc.cloneWork();
        ADM_Work__c clonedWork = wdc.getCloneOfWork();
       
        System.assert(clonedWork.Status__c == 'New', 'Expected New status for cloned Work record');
    }
}