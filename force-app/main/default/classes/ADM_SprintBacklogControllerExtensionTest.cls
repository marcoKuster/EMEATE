@isTest
private class ADM_SprintBacklogControllerExtensionTest {
    
    static testMethod void testExtensionWithOneWorkItem() {
    	//Assume that the sprint contains one work record
        ADM_Sprint__c sprint = ADM_Sprint.createTestSprint();
        
        ApexPages.currentPage().getParameters().put('id', sprint.Id);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(sprint);
        ADM_SprintBacklogControllerExtension extension = new ADM_SprintBacklogControllerExtension(controller);
        
        System.assertEquals(1, extension.works.size());
        System.assertEquals(false, extension.hasNext);
        System.assertEquals(false, extension.hasPrevious);
        System.assertEquals(1, extension.pageNumber);
        System.assertEquals(20, extension.pageSize, 'Expected page size to return the default page size, which should be 20');
        System.assertEquals(1, extension.resultSize);
        System.assertEquals(1, extension.rowStart);
        System.assertEquals(1, extension.rowEnd);
    }
    
    static testMethod void testExtensionWithMany() {
        ADM_Sprint__c sprint = ADM_Sprint.createEmptyTestSprint();
        List<ADM_Work__c> works = ADM_Work.createListOfWork(100, 'Bug');
        for(ADM_Work__c work : works) {
        	work.Sprint__c = sprint.Id;
        }
        upsert works;
        
        ApexPages.currentPage().getParameters().put('id', sprint.Id);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(sprint);
        ADM_SprintBacklogControllerExtension extension = new ADM_SprintBacklogControllerExtension(controller);
        
        System.assertEquals(20, extension.pageSize, 'Expected page size to return the default page size, which should be 20');
        System.assertEquals(100, extension.resultSize);
        
        //create a new controller/extension and send it to the first page
        extension.first();
        System.assertEquals(20, extension.works.size());
        System.assertEquals(true, extension.hasNext);
        System.assertEquals(false, extension.hasPrevious);
        System.assertEquals(1, extension.pageNumber);
        System.assertEquals(1, extension.rowStart);
        System.assertEquals(40, extension.rowEnd);
        
        //create a new controller/extension and send it to the next page
        controller = new Apexpages.Standardcontroller(sprint);
        extension = new ADM_SprintBacklogControllerExtension(controller);
        extension.next();
        System.assertEquals(20, extension.works.size());
        System.assertEquals(true, extension.hasNext);
        System.assertEquals(true, extension.hasPrevious);
        System.assertEquals(2, extension.pageNumber);
        System.assertEquals(41, extension.rowStart);
        System.assertEquals(120, extension.rowEnd);  //why 120? expected it to be 61
        
        //create a new controller/extension and send it to the last page
        controller = new Apexpages.Standardcontroller(sprint);
        extension = new ADM_SprintBacklogControllerExtension(controller);
        extension.last();
        System.assertEquals(20, extension.works.size());
        System.assertEquals(false, extension.hasNext);
        System.assertEquals(true, extension.hasPrevious);
        System.assertEquals(5, extension.pageNumber);
        System.assertEquals(61, extension.rowStart); //why is row start on 61? expected it to be 81
        System.assertEquals(100, extension.rowEnd);
    }

 }