@isTest
public class ADM_EmailWorkQuickViewControllerTest {
    
    static testmethod void testFindWork() {
        String testSubject = 'subject'+System.currentTimeMillis();

        ADM_Work__c workItem = ADM_Work.createTestWork('User Story');
        workItem.Subject__c = testSubject;
        upsert workItem;

        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject]; 
        
        ADM_Work__c work = ADM_EmailWorkQuickViewController.findWork(inserted.Name);        
        
        System.assertEquals(inserted.Id, work.Id);
    }
    
    
    static testmethod void testGetTeamMembers() {
        String lastName = 'TestMember';
        
        ADM_Scrum_Team__c scrumTeam = new ADM_Scrum_Team__c(Name='testTeam');
        insert scrumTeam;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias='stand', Email='stan@dard.com', EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey='America/Los_Angeles', UserName=System.currentTimeMillis()+'stan@dard.com');
        insert u;

        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c(Scrum_Team__c=scrumTeam.Id, Member_Name__c=u.Id);        
        insert member;
        
        ADM_Scrum_Team_Member__c[] members = ADM_EmailWorkQuickViewController.getTeamMembers(scrumTeam.Id);

        System.assertEquals(1, members.size());
        System.assertEquals(lastName, members[0].Member_Name__r.Name);
    }
    
    static testmethod void testGetSprints() {
        String teamName = 'testTeam';
        String sprintName = '2017.01a - testTeam';
        
        ADM_Scrum_Team__c scrumTeam = new ADM_Scrum_Team__c(Name=teamName, Active__c=true);
        insert scrumTeam;
        
        ADM_Sprint__c sprint = new ADM_Sprint__c(Name=sprintName, Start_Date__c=Date.today(), 
                                                 End_Date__c=Date.today().addDays(12), Scrum_Team__c=scrumTeam.Id);
        insert sprint;
        
        ADM_Sprint__c[] sprints = ADM_EmailWorkQuickViewController.getSprints(scrumTeam.Id);
        
        System.assertEquals(1, sprints.size());
        System.assertEquals(sprintName, sprints[0].Name);
    }
    
    static testmethod void testGetWorkStatusList() {
                
        String workStatusName = 'testWorkStatus'+System.currentTimeMillis();
        String workType = 'Bug';

        Test.startTest();

        ADM_Work_Status__c workStatus = new ADM_Work_Status__c(Name=workStatusName, Type__c=workType, Order__c=0);
        insert workStatus;
        
        Test.stopTest();
                
        ADM_Work_Status__c[] workStatuses = ADM_EmailWorkQuickViewController.getWorkStatusList(workType);
        
        System.assertEquals(1, workStatuses.size());
        System.assertEquals(workStatusName, workStatuses[0].Name);
    }
    
    static testmethod void testGetBuilds() {
        String buildName = '210';
        
        ADM_Build__c build = new ADM_Build__c(Name=buildName);
        insert build;
        
        ADM_Build__c[] builds = ADM_EmailWorkQuickViewController.getBuilds();
        
        System.assertEquals(1, builds.size());
        System.assertEquals(buildName, builds[0].Name);
    }
    
    static testmethod void testGetSourceControlStatus() {
        String testSubject = 'subject'+System.currentTimeMillis();
        String testSourceControlStatus = 'Open Once';
        String buildName = '200.1';
        
        ADM_Work__c workItem = new ADM_Work__c(Subject__c=testSubject, Perforce_Status__c=testSourceControlStatus, Status__c='In Progress');
        
        ADM_Build__c build = new ADM_Build__c(Name=buildName);
        insert build;
        
        ADM_Build__c insertedBuild = [Select Id FROM ADM_Build__c WHERE Name = :buildName];
        workItem.Scheduled_Build__c = insertedBuild.Id;
        insert workItem;

        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        String actualSourceControlStatus = ADM_EmailWorkQuickViewController.getSourceControlStatus(inserted.Id);
        
        System.assertEquals(testSourceControlStatus, actualSourceControlStatus);    
    }
    
    static testmethod void testGetSourceControlStatuses() {
        String testSubject = 'subject'+System.currentTimeMillis();
        String buildName = '200.1';
        
        ADM_Work__c workItem = ADM_Work.createTestWork('User Story');
        workItem.Subject__c = testSubject;
        upsert workItem;
        
        ADM_Build__c build = new ADM_Build__c(Name=buildName);
        insert build;
        
        ADM_Build__c insertedBuild = [Select Id FROM ADM_Build__c WHERE Name = :buildName];
        workItem.Scheduled_Build__c = insertedBuild.Id;
        upsert workItem;
        
        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        List<String> actualSourceControlStatuses = ADM_EmailWorkQuickViewController.getSourceControlStatuses(inserted.Id);
        
        List<String> expectedStatuses = new List<String>();
        expectedStatuses.add('Open Once');
        expectedStatuses.add('Open');

        System.assertEquals(expectedStatuses, actualSourceControlStatuses);  
    }

     
    static testmethod void testSetAssignee() {
        String testSubject = 'subject'+System.currentTimeMillis();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias='stand', Email='stan@dard.com', EmailEncodingKey='UTF-8', LastName='TestMember', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey='America/Los_Angeles', UserName=System.currentTimeMillis()+'stan@dard.com');
        insert u;
        ADM_Work__c workItem = ADM_Work.createTestWork('User Story');
        workItem.Subject__c = testSubject;
        upsert workItem;
        
        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject]; 
        
        ADM_EmailWorkQuickViewController.setAssignee(u.Id, inserted.Name);
        
        ADM_Work__c work = [Select Assignee__c FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        System.assertEquals(u.Id, work.Assignee__c);
    }

    static testmethod void testSetQAEngineer() {
        String testSubject = 'subject'+System.currentTimeMillis();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias='stand', Email='stan@dard.com', EmailEncodingKey='UTF-8', LastName='TestMember', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey='America/Los_Angeles', UserName=System.currentTimeMillis()+'stan@dard.com');
        insert u;
 
        ADM_Work__c workItem = ADM_Work.createTestWork('User Story');
        workItem.Subject__c = testSubject;
        upsert workItem;
        
        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject]; 
        
        ADM_EmailWorkQuickViewController.setQAEngineer(u.Id, inserted.Name);
        
        ADM_Work__c work = [Select QA_Engineer__c FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        System.assertEquals(u.Id, work.QA_Engineer__c);
    }  
    
    static testmethod void testSetSprint() {
        String teamName = 'testTeam';
        String sprintName = '2017.01a - testTeam';
        String testSubject = 'subject';
        
        ADM_Scrum_Team__c scrumTeam = new ADM_Scrum_Team__c(Name=teamName, Active__c=true);
        insert scrumTeam;
        
        ADM_Work__c workItem = new ADM_Work__c(Subject__c=testSubject);        
        insert workItem;
        
        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        ADM_Sprint__c sprint = new ADM_Sprint__c(Name=sprintName, Start_Date__c=Date.today(), 
                                                 End_Date__c=Date.today().addDays(12), Scrum_Team__c=scrumTeam.Id);
        insert sprint;
        
        ADM_EmailWorkQuickViewController.setSprint(sprint.Id, inserted.Name);
        
        ADM_Work__c work = [SELECT Sprint__c FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        System.assertEquals(sprint.Id, work.Sprint__c);
    }
    
    static testmethod void testSetWorkStatus() {

        String testSubject = 'subject'+System.currentTimeMillis();
        String testStatus = 'testStatus'+System.currentTimeMillis();

        ADM_Work__c workItem = ADM_Work.createTestWork('User Story');
        workItem.Subject__c = testSubject;
        upsert workItem;
                
        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        ADM_EmailWorkQuickViewController.setStatus(testStatus, inserted.Name);
        
        ADM_Work__c work = [SELECT Status__c FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        System.assertEquals(testStatus, work.Status__c);
    }

    static testmethod void testSetBuild() {
        String testBuild = '206';
        String testSubject = 'testSubject';
        
        ADM_Build__c build = new ADM_Build__c(Name=testBuild);
        insert build;
        
        ADM_Work__c workItem = new ADM_Work__c(Subject__c=testSubject);
        insert workItem;
        
        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        ADM_EmailWorkQuickViewController.setBuild(build.Id, inserted.Name);
        
        ADM_Work__c work = [SELECT Scheduled_Build__c FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        System.assertEquals(build.Id, work.Scheduled_Build__c);
    }
    
    static testmethod void testSetSourceControlStatus() {
        String testSubject = 'subject';
        String testSourceControlStatus = 'Open Once';
        String buildName = '200.1';
        
        ADM_Work__c workItem = ADM_Work.setupTestWork('User Story');

        workItem.Subject__c = testSubject;
        upsert workItem;
        
        ADM_Build__c build = new ADM_Build__c(Name=buildName);
        insert build;
        
        ADM_Build__c insertedBuild = [Select Id FROM ADM_Build__c WHERE Name = :buildName];
        workItem.Scheduled_Build__c = insertedBuild.Id;
        upsert workItem;
        
        ADM_Work__c inserted = [Select Id, Name FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        ADM_EmailWorkQuickViewController.setSourceControl(testSourceControlStatus, inserted.Name);
        
        ADM_Work__c updated = [Select Id, Name, Perforce_Status__c FROM ADM_Work__c WHERE Subject__c = :testSubject];
        
        System.assertEquals(testSourceControlStatus, updated.Perforce_Status__c);
    }
    
    static testmethod void testSetNullAssigneeThrowsException() {
        AuraHandledException ex = null;
        try {
            ADM_EmailWorkQuickViewController.setAssignee(null, null);
        } catch(AuraHandledException e) {
            ex = e;
        }           
        System.assert(ex != null);
    }
    
    static testmethod void testSetNullQAEngineerThrowsException() {
        AuraHandledException ex = null;
        try {
            ADM_EmailWorkQuickViewController.setQAEngineer(null, null);
        } catch(AuraHandledException e) {
            ex = e;
        }           
        System.assert(ex != null);
    }
    
    static testmethod void testSetNullSprintThrowsException() {
        AuraHandledException ex = null;
        try {
            ADM_EmailWorkQuickViewController.setSprint(null, null);
        } catch(AuraHandledException e) {
            ex = e;
        }           
        System.assert(ex != null);
    }
    
    static testmethod void testSetNullBuildThrowsException() {
        AuraHandledException ex = null;
        try {
            ADM_EmailWorkQuickViewController.setBuild(null, null);
        } catch(AuraHandledException e) {
            ex = e;
        }           
        System.assert(ex != null);
    }
    
    static testmethod void testSetNullStatusThrowsException() {
        AuraHandledException ex = null;
        try {
            ADM_EmailWorkQuickViewController.setStatus(null, null);
        } catch(AuraHandledException e) {
            ex = e;
        }           
        System.assert(ex != null);
    }
    
    static testmethod void testSetNullSourceControlThrowsException() {
        AuraHandledException ex = null;
        try {
            ADM_EmailWorkQuickViewController.setSourceControl(null, null);
        } catch(AuraHandledException e) {
            ex = e;
        }           
        System.assert(ex != null);
    }
    
}