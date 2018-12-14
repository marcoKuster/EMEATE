public with sharing class ADM_WallControllerTests {
    
    static testMethod void testGetTeams() {
        ADM_Scrum_Team__c team1 = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        User user = ADM_WorkUser.createTestUser();
        
        Test.startTest();
        List<ADM_Scrum_Team__c> actualTeams = null;
        String actualTeamsAsJson = null;
        String actualSelectedTeamId = null;
        String actualSelectedTeamIdAsJson = null;
        System.runAs(user) {
            ApexPages.currentPage().getParameters().put('teamId', team1.Id);
            ADM_WallController controller = new ADM_WallController();
            actualTeams = controller.getTeams();
            actualTeamsAsJson = controller.getTeamsAsJson();
            actualSelectedTeamId = controller.getSelectedTeamId();
            actualSelectedTeamIdAsJson = controller.getSelectedTeamIdAsJson();
        }
        Test.stopTest();
        
        System.assert(actualTeams != null, 'Expected getTeams to return a list of teams');
        System.assertEquals(1, actualTeams.size(), 'Expected getTeams to return two teams');
        Boolean team1Found = false;
        for(ADM_Scrum_Team__c team : actualTeams) {
            if(team.Id == team1.Id) {
                team1Found = true;
            }
        }
        System.assert(team1Found, 'Expected the first team to be available');
        
        System.assert(actualTeamsAsJson != null, 'Expected getTeamsAsJson to return a non-null string');
        System.assert(actualTeamsAsJson.startsWith('['), 'Expected getTeamsAsJson to return an array: ' + actualTeamsAsJson);
        System.assert(actualTeamsAsJson.endsWith(']'), 'Expected getTeamsAsJson to return an array: ' + actualTeamsAsJson);
        System.assert(actualTeamsAsJson.contains(team1.Id), 'Expected getTeamsAsJson to contain ID of team 1 (' + team1.Id + '): ' + actualTeamsAsJson);
        
        System.assertEquals(team1.Id, actualSelectedTeamId, 'Expected the selected team ID to be set when passed in as an URL');
         //This assertion will be re-enabled once JSON bug W-1621139 is fixed.  Since 15 char are still unique the bug does not cause multiple teams to be found
        //System.assert(actualSelectedTeamIdAsJson.contains(team1.Id), 'Expected getSelectedTeamIdAsJson to be the selected team ID: ' + actualSelectedTeamIdAsJson);
    }
    
    static testMethod void testGetRecordTypes() {
        ADM_Scrum_Team__c team1 = ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName();
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('teamId', team1.Id);
        ADM_WallController controller = new ADM_WallController();
        List<RecordType> actualRecordTypes = controller.getRecordTypes();
        String actualRecordTypesAsJson = controller.getRecordTypesAsJson();
        Test.stopTest();
        
        System.assert(actualRecordTypes != null, 'Expected getRecordTypes to not be null');
        System.assert(actualRecordTypes.size() > 0, 'Expected getRecordTypes to not be empty');
        
        System.assert(actualRecordTypesAsJson != null, 'Expected getRecordTypesAsJson to not be null');
        System.assert(actualRecordTypesAsJson.startsWith('['), 'Expected getRecordTypesAsJson to be an array: ' + actualRecordTypesAsJson);
        System.assert(actualRecordTypesAsJson.endsWith(']'), 'Expected getRecordTypesAsJson to be an array: ' + actualRecordTypesAsJson);
    }
    
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000002iMr
expected results The master backlog shows where it meets the following criteria: 
            Closed = 0 
            Record type = user story + bug + todo 
            Scrum team = the scrum team on unified wall 
            Priority rank is not null 
            Theme not in trust 
            Include in prioritizer view is true
hierarchy GUS.Unified Wall.Master Panel
*/
    static testMethod void testGetMasterBacklog() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getMasterBacklog(teamId, null, null,'true');
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected all of the work items to be returned');
    }
    
/* 
userstory a07B0000000Uams
testcaseID  a1DB00000002m8X
expected results  Partial master backlog
hierarchy GUS.Unified Wall.Master Panel
*/
    static testMethod void testGetMasterBacklogPartial() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = rank++;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getMasterBacklog(teamId, 2, 2, 'true');
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(2, response.records.size(), 'Expected only two work items to be returned since we requested only 2 items');
        System.assertEquals(3, response.records.get(0).Priority_Rank__c, 'Expected priority rank of the first record returned to be 3 since we offset the list by three');
        System.assertEquals(4, response.records.get(1).Priority_Rank__c, 'Expected priority rank of the second record returned to be 4 since we offset the list by three');
    }
    
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000002iaV
expected results The feature backlog shows where it meets the following criteria: 
    Closed = 0 
    Record type = user story 
    Scrum team = the scrum team on unified wall 
    Priority rank is not null 
    Theme not in trust 
    Include in prioritizer view is true
hierarchy GUS.Unified Wall.Feature Panel
*/
    static testMethod void testGetBackburner() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
            work.Status__c = 'New';
            work.Use_Prioritizer__c = true;
            work.Priority_Rank__c = null;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getBackburner(teamId, null, null);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getBackburner to return all of the work items');
    }
 
/* 
userstory a07B0000000Uams
testcaseID  a1DB00000002m8c
expected results Partial backburner
hierarchy GUS.Unified Wall.Backburner Panel
*/   
    static testMethod void testGetBackburnerPartial() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
            work.Status__c = 'New';
            work.Use_Prioritizer__c = true;
            work.Priority_Rank__c = null;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getBackburner(teamId, 2, 2);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(2, response.records.size(), 'Expected only two work items to be returned since we requested only 2 items');
    }
  
/* 
userstory a07B0000000Uams
testcaseID  a1DB00000002iaV
expected results The feature backlog shows where it meets the following criteria: 
        Closed = 0 
        Record type = user story 
        Scrum team = the scrum team on unified wall 
        Priority rank is not null 
        Theme not in trust 
        Include in prioritizer view is true
hierarchy GUS.Unified Wall.Feature Panel
*/  
    static testMethod void testGetFeatureBacklog() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'User Story');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getFeatureBacklog(teamId, null, null);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getFeatureBacklog to return all of the work items');
    }
    
/* 
userstory a07B0000000Uams
testcaseID  a1DB00000002m8h
expected results Partial feature panel
hierarchy GUS.Unified Wall.Feature Panel
*/
    static testMethod void testGetFeatureBacklogPartial() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'User Story');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = rank++;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getFeatureBacklog(teamId, 2, 2);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(2, response.records.size(), 'Expected only two work items to be returned since we requested only 2 items');
        System.assertEquals(3, response.records.get(0).Priority_Rank__c, 'Expected priority rank of the first record returned to be 3 since we offset the list by three');
        System.assertEquals(4, response.records.get(1).Priority_Rank__c, 'Expected priority rank of the second record returned to be 4 since we offset the list by three');
    }
    
/* 
userstory a07B0000000Uams
testcaseID  a1DB00000002iaV
expected results Feature backlog does not show trust items
hierarchy GUS.Unified Wall.Feature Panel
*/
    static testMethod void testFeatureBacklogShouldNotShowTrustItems() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'User Story');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        upsert works;
        
        //assign one item to the trust theme
        ADM_Theme__c trustTheme = ensureTrustTheme();
        ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
        themeAssignment.Work__c = works.get(0).Id;
        themeAssignment.Theme__c = trustTheme.Id;
        upsert themeAssignment;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getFeatureBacklog(teamId, null, null);
        Test.stopTest();
        
        System.assertEquals(9, response.numberOfRecords, 'Expected the number of records to be 9; all work items except for the one with Trust theme');
        System.assertEquals(9, response.records.size(), 'Expected getFeatureBacklog to return 9 work items; all work items except for the one with Trust theme');
        
    }
    
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000002ii8
expected results The feature rank will change to reflect the positioning of all the dragged items. User can refresh and items will stay in same position
hierarchy GUS.Unified Wall.Feature Rank
*/
    static testMethod void testSetFeatureRank() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(3, 'User Story');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Feature_Rank__c = rank++;
        }
        upsert works;
        works = [select Id, Feature_Rank__c, Scrum_Team__c from ADM_Work__c where Id in :works order by Feature_Rank__c];
        
        //get the team of the work items
        Id teamId = getTeamId(works);
        
        //reverse the rank
        works.get(0).Feature_Rank__c = 3;
        works.get(1).Feature_Rank__c = 2;
        works.get(2).Feature_Rank__c = 1;
        
        Test.startTest();
        ADM_WallController.setFeatureRank(teamId, works);
        Test.stopTest();
        
        List<ADM_Work__c> actualWorks = [select Id, Feature_Rank__c from ADM_Work__c where Scrum_Team__c = :teamId order by Feature_Rank__c];
        System.assertEquals(3, actualWorks.size(), 'Expected there to be three items assigned');
        System.assertEquals(1, actualWorks.get(0).Feature_Rank__c, 'Expected the rank of the first item to be 1');
        System.assertEquals(works.get(2).Id, actualWorks.get(0).Id, 'Expected the first item to have changed rank');
        System.assertEquals(2, actualWorks.get(1).Feature_Rank__c, 'Expected the rank of the second item to be 2');
        System.assertEquals(works.get(1).Id, actualWorks.get(1).Id, 'Expected the second item to have changed rank');
        System.assertEquals(3, actualWorks.get(2).Feature_Rank__c, 'Expected the rank of the third item to be 3');
        System.assertEquals(works.get(0).Id, actualWorks.get(2).Id, 'Expected the third item to have changed rank');
    }
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000004i2M
expected results The master rank will change to reflect the positioning of all the dragged items. User can refresh and items will stay in same position
hierarchy GUS.Unified Wall.Master Backlog Rank
*/
    
    static testMethod void testSetBacklogRank() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(3, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = rank++;
        }
        upsert works;
        works = [select Id, Priority_Rank__c, Scrum_Team__c from ADM_Work__c where Id in :works order by Priority_Rank__c];
        
        //get the team of the work items
        Id teamId = getTeamId(works);
        
        //reverse the rank
        works.get(0).Priority_Rank__c = 3;
        works.get(1).Priority_Rank__c = 2;
        works.get(2).Priority_Rank__c = 1;
        
        Test.startTest();
        ADM_WallController.setBacklogRank(teamId, works);
        Test.stopTest();
        
        List<ADM_Work__c> actualWorks = [select Id, Priority_Rank__c from ADM_Work__c where Scrum_Team__c = :teamId order by Priority_Rank__c];
        System.assertEquals(3, actualWorks.size(), 'Expected there to be three items assigned');
        System.assertEquals(1, actualWorks.get(0).Priority_Rank__c, 'Expected the rank of the first item to be 1');
        System.assertEquals(works.get(2).Id, actualWorks.get(0).Id, 'Expected the first item to have changed rank');
        System.assertEquals(2, actualWorks.get(1).Priority_Rank__c, 'Expected the rank of the second item to be 2');
        System.assertEquals(works.get(1).Id, actualWorks.get(1).Id, 'Expected the second item to have changed rank');
        System.assertEquals(3, actualWorks.get(2).Priority_Rank__c, 'Expected the rank of the third item to be 3');
        System.assertEquals(works.get(0).Id, actualWorks.get(2).Id, 'Expected the third item to have changed rank');
    }
    
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000002iMw
expected results The trust backlog shows where it meets the following criteria: 
    Closed = 0 
    Record type = user story + bug + todo 
    Scrum team = the scrum team on unified wall 
    Priority rank is not null 
    Theme = trust 
    Include in prioritizer view is true
hierarchy GUS.Unified Wall.Trust Panel
*/
    static testMethod void testGetTrustBacklog() {
        ADM_Theme__c trustTheme = ensureTrustTheme();
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        upsert works;
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        
        //create theme assignments for each work item relating to the theme
        List<ADM_Theme_Assignment__c> themeAssignments = new List<ADM_Theme_Assignment__c>();
        for(ADM_Work__c work : works) {
           ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
           themeAssignment.Work__c = work.id;
           themeAssignment.Theme__c = trustTheme.id;
           themeAssignments.add(themeAssignment);
        }
        insert themeAssignments;
        
        //get the team of the work items
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getTrustBacklog(teamId, null, null);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getTrustBacklog to return all of the work items');
    }
/* 
userstory a07B0000000Uams
testcaseID  a1DB00000002m8r
expected results Partial trust panel
hierarchy GUS.Unified Wall.Trust Panel
*/
    
    static testMethod void testGetTrustBacklogPartial() {
        ADM_Theme__c trustTheme = ensureTrustTheme();
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = rank++;
        }
        upsert works;
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        
        //create theme assignments for each work item relating to the theme
        List<ADM_Theme_Assignment__c> themeAssignments = new List<ADM_Theme_Assignment__c>();
        for(ADM_Work__c work : works) {
           ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
           themeAssignment.Work__c = work.id;
           themeAssignment.Theme__c = trustTheme.id;
           themeAssignments.add(themeAssignment);
        }
        insert themeAssignments;
        
        //get the team of the work items
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getTrustBacklog(teamId, 2, 2);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(2, response.records.size(), 'Expected only two work items to be returned since we requested only 2 items');
        System.assertEquals(3, response.records.get(0).Priority_Rank__c, 'Expected priority rank of the first record returned to be 3 since we offset the list by three');
        System.assertEquals(4, response.records.get(1).Priority_Rank__c, 'Expected priority rank of the second record returned to be 4 since we offset the list by three');
    }
    
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000002iiD
expected results The trust rank will change to reflect the positioning of all the dragged items. User can refresh and items will stay in same position
hierarchy GUS.Unified Wall.Trust Backlog Rank
*/
    static testMethod void testSetTrustRank() {
        ADM_Theme__c trustTheme = ensureTrustTheme();
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(3, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Theme__c = null;
           work.Trust_Rank__c = rank++;
        }
        upsert works;
        works = [select Id, Trust_Rank__c, Scrum_Team__c from ADM_Work__c where Id in :works order by Trust_Rank__c];
        
        //create theme assignments for each work item relating to the theme
        List<ADM_Theme_Assignment__c> themeAssignments = new List<ADM_Theme_Assignment__c>();
        for(ADM_Work__c work : works) {
           ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
           themeAssignment.Work__c = work.id;
           themeAssignment.Theme__c = trustTheme.id;
           themeAssignments.add(themeAssignment);
        }
        insert themeAssignments;
        
        //get the team of the work items
        Id teamId = getTeamId(works);
        
        //reverse the rank
        works.get(0).Trust_Rank__c = 3;
        works.get(1).Trust_Rank__c = 2;
        works.get(2).Trust_Rank__c = 1;
        
        Test.startTest();
        ADM_WallController.setTrustRank(teamId, works);
        Test.stopTest();
        
        List<ADM_Work__c> actualWorks = [select Id, Trust_Rank__c from ADM_Work__c where Id in :works order by Trust_Rank__c];
        System.assertEquals(3, actualWorks.size(), 'Expected there to be three items assigned');
        System.assertEquals(1, actualWorks.get(0).Trust_Rank__c, 'Expected the rank of the first item to be 1');
        System.assertEquals(works.get(2).Id, actualWorks.get(0).Id, 'Expected the first item to have changed rank');
        System.assertEquals(2, actualWorks.get(1).Trust_Rank__c, 'Expected the rank of the second item to be 2');
        System.assertEquals(works.get(1).Id, actualWorks.get(1).Id, 'Expected the second item to have changed rank');
        System.assertEquals(3, actualWorks.get(2).Trust_Rank__c, 'Expected the rank of the third item to be 3');
        System.assertEquals(works.get(0).Id, actualWorks.get(2).Id, 'Expected the third item to have changed rank');
    }
    
    static testMethod void testGetTheme() {
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'Test Theme';
        theme.Active__c = true;
        insert theme;
        
        Test.startTest();
        ADM_Theme__c actualTheme = ADM_WallController.getTheme(theme.Id);
        Test.stopTest();
        System.assert(actualTheme != null, 'Expected the theme to be returned');
    }
    
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000002iN6
expected results The theme backlog shows where it meets the following criteria: 
    Closed = 0 
    Record type = user story + bug + todo 
    Scrum team = the scrum team on unified wall 
    Theme is selected theme
hierarchy GUS.Unified Wall.Theme Panel
*/
    static testMethod void testGetThemeBacklog() {
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'Test Theme';
        theme.Active__c = true;
        insert theme;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Priority_Rank__c = 1;
        }
        upsert works;
        
        List<ADM_Theme_Assignment__c> taList = new List<ADM_Theme_Assignment__c>();
        for(ADM_Work__c work : works) {
           //relate the themes to work records
           ADM_Theme_Assignment__c ta = new ADM_Theme_Assignment__c();
           ta.Work__c = work.id;
           ta.Theme__c = theme.id;
           taList.add(ta);
        }
        insert taList;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getThemeBacklog(teamId, theme.Id, null, null);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getThemeBacklog to return all of the work items');
    }
    /* 
userstory a07B0000000Uams
testcaseID  a1DB00000002m8w
expected results Partial theme panel
hierarchy GUS.Unified Wall.Theme Panel
*/
    static testMethod void testGetThemeBacklogPartial() {
        ADM_Theme__c theme = new ADM_Theme__c();
        theme.Name = 'Test Theme';
        theme.Active__c = true;
        insert theme;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Use_Prioritizer__c = true;
           work.Theme__c = theme.Id;
           work.Priority_Rank__c = rank++;
        }
        upsert works;
        
        List<ADM_Theme_Assignment__c> themeAssignments = new List<ADM_Theme_Assignment__c>();
        for(ADM_Work__c work : works) {
           ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
           themeAssignment.Work__c = work.id;
           themeAssignment.Theme__c = theme.id;
           themeAssignments.add(themeAssignment);
        }
        insert themeAssignments;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getThemeBacklog(teamId, theme.Id, 2, 2);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(2, response.records.size(), 'Expected only two work items to be returned since we requested only 2 items');
        System.assertEquals(3, response.records.get(0).Priority_Rank__c, 'Expected rank of the first record returned to be 3 since we offset the list by three');
        System.assertEquals(4, response.records.get(1).Priority_Rank__c, 'Expected rank of the second record returned to be 4 since we offset the list by three');
    }
    
    static testMethod void testGetBuild() {
        ADM_Build__c build = new ADM_Build__c();
        build.Name = 'Test Build';
        insert build;
        
        Test.startTest();
        ADM_Build__c actualBuild = ADM_WallController.getBuild(build.Id);
        Test.stopTest();
        
        System.assert(build != null, 'Expected the test build to be returned');
    }
    
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000002icz
expected results The build backlog shows where it meets the following criteria: 
    Closed = 0 
    Record type = user story + bug + todo 
    Scrum team = the scrum team on unified wall 
    Build is the selected build
hierarchy GUS.Unified Wall.Build Panel
*/
    
    static testMethod void testGetScheduledBuildBacklog() {
        ADM_Build__c build = new ADM_Build__c();
        build.Name = 'Test Build';
        insert build;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Scheduled_Build__c = build.Id;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getScheduledBuildBacklog(teamId, build.Id, null, null);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getScheduledBuildBacklog to return all of the work items');
    }
  /* 
userstory a07B0000000Uams
testcaseID  a1DB00000002m91
expected results Partial build backlog
hierarchy GUS.Unified Wall.Build Panel
*/  
    static testMethod void testGetScheduledBuildBacklogPartial() {
        ADM_Build__c build = new ADM_Build__c();
        build.Name = 'Test Build';
        insert build;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Scheduled_Build__c = build.Id;
           work.Scheduled_Build_Rank__c = rank++;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getScheduledBuildBacklog(teamId, build.Id, 2, 2);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(2, response.records.size(), 'Expected only two work items to be returned since we requested only 2 items');
        System.assertEquals(3, response.records.get(0).Scheduled_Build_Rank__c, 'Expected scheduled build rank of the first record returned to be 3 since we offset the list by three');
        System.assertEquals(4, response.records.get(1).Scheduled_Build_Rank__c, 'Expected scheduled build rank of the second record returned to be 4 since we offset the list by three');
    }
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000002iiI
expected results The build rank will change to reflect the positioning of all the dragged items. User can refresh and items will stay in same position
hierarchy GUS.Unified Wall.Build Backlog Rank
*/
    
    static testMethod void testSetScheduledBuildRank() {
        ADM_Build__c build = new ADM_Build__c();
        build.Name = 'Test Build';
        insert build;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(3, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Scheduled_Build_Rank__c = rank++;
           work.Scheduled_Build__c = build.Id;
        }
        upsert works;
        works = [select Id, Scheduled_Build_Rank__c, Scrum_Team__c from ADM_Work__c where Id in :works order by Scheduled_Build_Rank__c];
        
        //get the team of the work items
        Id teamId = getTeamId(works);
        
        //reverse the rank
        works.get(0).Scheduled_Build_Rank__c = 3;
        works.get(1).Scheduled_Build_Rank__c = 2;
        works.get(2).Scheduled_Build_Rank__c = 1;
        
        Test.startTest();
        ADM_WallController.setScheduledBuildRank(works);
        Test.stopTest();
        
        List<ADM_Work__c> actualWorks = [select Id, Scheduled_Build_Rank__c from ADM_Work__c where Scrum_Team__c = :teamId order by Scheduled_Build_Rank__c];
        System.assertEquals(3, actualWorks.size(), 'Expected there to be three items assigned');
        System.assertEquals(1, actualWorks.get(0).Scheduled_Build_Rank__c, 'Expected the rank of the first item to be 1');
        System.assertEquals(works.get(2).Id, actualWorks.get(0).Id, 'Expected the first item to have changed rank');
        System.assertEquals(2, actualWorks.get(1).Scheduled_Build_Rank__c, 'Expected the rank of the second item to be 2');
        System.assertEquals(works.get(1).Id, actualWorks.get(1).Id, 'Expected the second item to have changed rank');
        System.assertEquals(3, actualWorks.get(2).Scheduled_Build_Rank__c, 'Expected the rank of the third item to be 3');
        System.assertEquals(works.get(0).Id, actualWorks.get(2).Id, 'Expected the third item to have changed rank');
    }


    static testMethod void testSetBackburnerChanges() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(3, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Backburner_Rank__c = rank++;
        }
        upsert works;
        works = [select Id, Backburner_Rank__c, Scrum_Team__c from ADM_Work__c where Id in :works order by Backburner_Rank__c];
        
        //get the team of the work items
        Id teamId = getTeamId(works);

        //reverse the rank
        works.get(0).Backburner_Rank__c = 3;
        works.get(1).Backburner_Rank__c = 2;
        works.get(2).Backburner_Rank__c = 1;
        
        Test.startTest();
        ADM_WallController.setBackburnerChanges(works);
        Test.stopTest();
        
        List<ADM_Work__c> actualWorks = [select Id, Backburner_Rank__c from ADM_Work__c where Scrum_Team__c = :teamId order by Backburner_Rank__c];
        System.assertEquals(3, actualWorks.size(), 'Expected there to be three items assigned');
        System.assertEquals(1, actualWorks.get(0).Backburner_Rank__c, 'Expected the rank of the first item to be 1');
        System.assertEquals(works.get(2).Id, actualWorks.get(0).Id, 'Expected the first item to have changed rank');
        System.assertEquals(2, actualWorks.get(1).Backburner_Rank__c, 'Expected the rank of the second item to be 2');
        System.assertEquals(works.get(1).Id, actualWorks.get(1).Id, 'Expected the second item to have changed rank');
        System.assertEquals(3, actualWorks.get(2).Backburner_Rank__c, 'Expected the rank of the third item to be 3');
        System.assertEquals(works.get(0).Id, actualWorks.get(2).Id, 'Expected the third item to have changed rank');
    }


    static testMethod void testSetBackburnerChangesDoesNotRemoveSprintAndBuild() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        ADM_Build__c build = new ADM_Build__c();
        build.Name = 'Test Build';
        insert build;
        List<ADM_Work__c> works = ADM_Work.createListOfWork(1, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
           work.Status__c = 'New';
           work.Backburner_Rank__c = rank++;
           work.Epic_Rank__c = 2;
           work.Sprint__c = sprint.Id;
           work.Scheduled_Build__c = build.Id;
        }
        upsert works;
        works = [select Id, Backburner_Rank__c, Scrum_Team__c from ADM_Work__c where Id in :works order by Backburner_Rank__c];

        Id teamId = getTeamId(works);
        works.get(0).Backburner_Rank__c = 1;

        Test.startTest();
        ADM_WallController.setBackburnerChanges(works);
        Test.stopTest();
        
        List<ADM_Work__c> actualWorks = [select Id, Backburner_Rank__c,Scheduled_Build__c,Sprint__c,Epic_Rank__c from ADM_Work__c where Scrum_Team__c = :teamId order by Backburner_Rank__c];
        System.assertEquals(1, actualWorks.get(0).Backburner_Rank__c, 'Expected the rank of the first item to be 1');
        System.assert(actualWorks.get(0).Sprint__c != null && actualWorks.get(0).Sprint__c == sprint.Id, 'Expect the sprint to not be removed');
        System.assert(actualWorks.get(0).Scheduled_Build__c != null && actualWorks.get(0).Scheduled_Build__c  == build.Id, 'Expect the build to not be removed');
        System.assert(actualWorks.get(0).Epic_Rank__c != null && actualWorks.get(0).Epic_Rank__c == 2, 'Expect the Epic Rank to not be removed');
    }
    
    static testMethod void testGetSprint() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        
        Test.startTest();
        ADM_Sprint__c actualSprint = ADM_WallController.getSprint(sprint.Id);
        Test.stopTest();
        
        System.assert(actualSprint != null, 'Expected the sprint to be found');
    }
    
/* 
userstory a07B0000000Uams
testcaseID  a1DB00000002kET
expected results 
    The sprint backlog shows where it meets the following criteria: 
    Closed = 0 
    Record type = todo, user story, bug 
    Sprint is the sprint that's selected
    hierarchy GUS.Unified Wall.Sprint Panel
*/
    static testMethod void testGetSprintBacklog() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        sprint = [select Id, Scrum_Team__c from ADM_Sprint__c where Id = :sprint.Id];
        Id teamId = sprint.Scrum_Team__c;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
            work.Scrum_Team__c = teamId;
            work.Status__c = 'New';
            work.Sprint__c = sprint.Id;
        }
        upsert works;
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getSprintBacklog(teamId, sprint.Id, null, null);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getSprintBacklog to return all of the work items');
    }


/*
Test getEpic method in ADM_WallController.
*/

    static testMethod void testGetEpic() {
        ADM_Epic__c epic = ADM_Epic.createTestEpic();
        
        Test.startTest();
        ADM_Epic__c actualEpic = ADM_WallController.getEpic(epic.Id);
        Test.stopTest();
        
        System.assert(actualEpic != null, 'Expected the epic to be found');
    }

/*
Test getEpicBacklog method in ADM_WallController.
*/
 
    static testMethod void testGetEpicBacklog() {
        ADM_Epic__c epic = ADM_Epic.createTestEpic();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('Team1');
        ADM_Product_Tag__c productTagForTeam = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        for(ADM_Work__c work : works) {
            work.Product_Tag__c = productTagForTeam.Id;
            work.Status__c = 'New';
            work.Epic__c = epic.Id;
        }
        upsert works;
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getEpicBacklog(team.Id, epic.Id, null, null);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(10, response.records.size(), 'Expected getEpicBacklog to return all of the work items');
    }


    static testMethod void testGetEpicBacklogOnlyShowsWorkThatBelongsToTheTeam() {
        ADM_Scrum_Team__c team1 = ADM_ScrumTeam.createTestScrumTeam('Team1');
        ADM_Product_Tag__c productTagForTeam1 = ADM_ProductTag.createAndInsertProductTagForTeam(team1);

        ADM_Epic__c epic1 = ADM_Epic.createTestEpic();
       
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'User Story');
        ADM_Work__c workForTeam1 = works[0];    
        workForTeam1.Product_Tag__c = productTagForTeam1.Id; //
        workForTeam1.Epic__c = epic1.Id;

         ADM_Work__c workForTeam2 = works[1]; 
         workForTeam2.Epic__c = epic1.Id;


        //so now both stories have the same epic but the stories belong to seperate teams
        upsert works;
        
        
        
        Test.startTest();
   
        ADM_WallController.QueryResponse response = ADM_WallController.getEpicBacklog(team1.Id, epic1.Id, null, null);
        
        Test.stopTest();
        System.assertEquals(1, response.numberOfRecords, 'Expected the number of records to be 1');
        System.assertEquals(1, response.records.size(), 'Expected getEpicBacklog to return all of the work items');
        //finally make sure it is the right work record
        System.assertEquals(workForTeam1.Id, response.records.get(0).Id);
    }



    static testMethod void testGetEpicBacklogPartial() {
        ADM_Epic__c epic = ADM_Epic.createTestEpic();
        ADM_Scrum_Team__c team = ADM_ScrumTeam.createTestScrumTeam('Team1');
        ADM_Product_Tag__c productTagForTeam = ADM_ProductTag.createAndInsertProductTagForTeam(team);
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
            work.Product_Tag__c = productTagForTeam.Id;
            work.Status__c = 'New';
            work.Epic__c = epic.Id;
            work.Epic_Rank__c = rank++;
        }
        upsert works;
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getEpicBacklog(team.Id, epic.Id, 2, 2);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(2, response.records.size(), 'Expected only two work items to be returned since we requested only 2 items');
        System.assertEquals(3, response.records.get(0).Epic_Rank__c, 'Expected epic rank of the first record returned to be 3 since we offset the list by three');
        System.assertEquals(4, response.records.get(1).Epic_Rank__c, 'Expected epic rank of the second record returned to be 4 since we offset the list by three');
    }

    
/* 
userstory a07B0000000Uams
testcaseID  a1DB00000002kET
expected results Partial sprint panel
hierarchy GUS.Unified Wall.Sprint Panel
*/
    static testMethod void testGetSprintBacklogPartial() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        sprint = [select Id, Scrum_Team__c from ADM_Sprint__c where Id = :sprint.Id];
        Id teamId = sprint.Scrum_Team__c;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(10, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
            work.Scrum_Team__c = teamId;
            work.Status__c = 'New';
            work.Sprint__c = sprint.Id;
            work.Sprint_Rank__c = rank++;
        }
        upsert works;
        
        Test.startTest();
        ADM_WallController.QueryResponse response = ADM_WallController.getSprintBacklog(teamId, sprint.Id, 2, 2);
        Test.stopTest();
        
        System.assertEquals(10, response.numberOfRecords, 'Expected the number of records to be 10');
        System.assertEquals(2, response.records.size(), 'Expected only two work items to be returned since we requested only 2 items');
        System.assertEquals(3, response.records.get(0).Sprint_Rank__c, 'Expected sprint rank of the first record returned to be 3 since we offset the list by three');
        System.assertEquals(4, response.records.get(1).Sprint_Rank__c, 'Expected sprint rank of the second record returned to be 4 since we offset the list by three');
    }

    /* 
userstory a07B0000000Uams
testcaseID  a1DB00000002m9B
expected results The sprint rank will change to reflect the positioning of all the dragged items. User can refresh and items will stay in same position
hierarchy GUS.Unified Wall.Sprint Rank
*/
    static testMethod void testSetSprintRank() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        sprint = [select Id, Scrum_Team__c from ADM_Sprint__c where Id = :sprint.Id];
        Id teamId = sprint.Scrum_Team__c;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(3, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
            work.Sprint__c = sprint.Id;
            work.Status__c = 'New';
            work.Sprint_Rank__c = rank++;
        }
        upsert works;
        works = [select Id, Sprint_Rank__c, Scrum_Team__c from ADM_Work__c where Id in :works order by Scheduled_Build_Rank__c];
        
        //reverse the rank
        works.get(0).Sprint_Rank__c = 3;
        works.get(1).Sprint_Rank__c = 2;
        works.get(2).Sprint_Rank__c = 1;
        
        Test.startTest();
        ADM_WallController.setSprintRank(teamId, sprint.Id, works);
        Test.stopTest();
        
        List<ADM_Work__c> actualWorks = [select Id, Sprint_Rank__c from ADM_Work__c where Sprint__c = :sprint.Id order by Sprint_Rank__c];
        System.assertEquals(3, actualWorks.size(), 'Expected there to be three items assigned');
        System.assertEquals(1, actualWorks.get(0).Sprint_Rank__c, 'Expected the rank of the first item to be 1');
        System.assertEquals(works.get(2).Id, actualWorks.get(0).Id, 'Expected the first item to have changed rank');
        System.assertEquals(2, actualWorks.get(1).Sprint_Rank__c, 'Expected the rank of the second item to be 2');
        System.assertEquals(works.get(1).Id, actualWorks.get(1).Id, 'Expected the second item to have changed rank');
        System.assertEquals(3, actualWorks.get(2).Sprint_Rank__c, 'Expected the rank of the third item to be 3');
        System.assertEquals(works.get(0).Id, actualWorks.get(2).Id, 'Expected the third item to have changed rank');
    }


/*
Test setEpicRank method in ADM_WallController.
*/

    static testMethod void testSetEpicRank() {
        ADM_Epic__c epic = ADM_Epic.createTestEpic();
        epic = [select Id, Team__c from ADM_Epic__c where Id = :epic.Id];
        Id teamId = epic.Team__c;
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(3, 'Bug');
        Integer rank = 1;
        for(ADM_Work__c work : works) {
            work.Epic__c = epic.Id;
            work.Status__c = 'New';
            work.Epic_Rank__c = rank++;
        }
        upsert works;
        works = [select Id, Epic_Rank__c, Scrum_Team__c from ADM_Work__c where Id in :works order by Epic_Rank__c];
        
        //reverse the rank
        works.get(0).Epic_Rank__c = 3;
        works.get(1).Epic_Rank__c = 2;
        works.get(2).Epic_Rank__c = 1;
        
        Test.startTest();
        ADM_WallController.setEpicRank(teamId, epic.Id, works);
        Test.stopTest();
        
        List<ADM_Work__c> actualWorks = [select Id, Epic_Rank__c from ADM_Work__c where Epic__c = :epic.Id order by Epic_Rank__c];
        System.assertEquals(3, actualWorks.size(), 'Expected there to be three items assigned');
        System.assertEquals(1, actualWorks.get(0).Epic_Rank__c, 'Expected the rank of the first item to be 1');
        System.assertEquals(works.get(2).Id, actualWorks.get(0).Id, 'Expected the first item to have changed rank');
        System.assertEquals(2, actualWorks.get(1).Epic_Rank__c, 'Expected the rank of the second item to be 2');
        System.assertEquals(works.get(1).Id, actualWorks.get(1).Id, 'Expected the second item to have changed rank');
        System.assertEquals(3, actualWorks.get(2).Epic_Rank__c, 'Expected the rank of the third item to be 3');
        System.assertEquals(works.get(0).Id, actualWorks.get(2).Id, 'Expected the third item to have changed rank');
    }
    
/* 
userstory a07B0000000T74o
testcaseID  a1DB00000004heG
expected results All tasks should show with the following fields: 
        Assigned To 
        Subject 
        Status 
        Hours Remaining
hierarchy GUS.Unified Wall.Detail Page.Show Tasks
*/
    
    static testMethod void testGetTasksForWorks() {
        User testUser = ADM_WorkUser.createTestUser();
        
        List<ADM_Work__c> works = ADM_Work.createListOfWork(1, 'Bug');
        for(ADM_Work__c work : works) {
            work.Status__c = 'New';
            work.Use_Prioritizer__c = true;
            work.Priority_Rank__c = null;
        }
        upsert works;
        
        //get the team of the work items
        works = [select Scrum_Team__c from ADM_Work__c where Id in :works];
        Id teamId = getTeamId(works);
        
        ADM_Task__c task1 = new ADM_Task__c();
        task1.Work__c = works.get(0).Id;
        task1.Subject__c = 'Task 1';
        task1.Assigned_To__c = testUser.Id;
        insert task1;
        
        ADM_WallController.QueryResponse backburnerList = ADM_WallController.getBackburner(teamId, null, null);
        
        System.assert(backburnerList != null, 'Expected return value to never be null');
        System.assertEquals(1, backburnerList.numberOfRecords, 'Expected the list to contain one item');
        System.assertEquals(1, backburnerList.records.size(), 'Expected the list to contain one item');
        System.assertEquals(works.get(0).Id, backburnerList.records.get(0).Id, 'Expected the first key in the map to be the work with the task');
        System.assertEquals(1, backburnerList.records.get(0).Tasks__r.size(), 'Expected there to be one task returned');
        System.assertEquals(task1.Id, backburnerList.records.get(0).Tasks__r.get(0).Id, 'Expected there to be one task returned');
    }
    
    private static ADM_Theme__c ensureTrustTheme() {
        ADM_Theme__c trustTheme = new ADM_Theme__c();
        trustTheme.Name = 'Trust';
        insert trustTheme;
        return trustTheme;
    }
    
    private static Id getTeamId(List<ADM_Work__c> works) {
        Id teamId = (works == null || works.isEmpty()) ? null : works.get(0).Scrum_Team__c;
        if(teamId == null) {
            throw new ADM_ApplicationException('Scrum_Team__c is null');
        }
        return teamId;
    }
    
}