@isTest
private class ADM_WorkTreeControllerTest {

/**
* @testcaseID a0B20000009gsiEEAQ
* @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-785283
* @userstory a07B0000000Dfi3IAC
* @expected results When you create a child record from a bug list work record, the child is always a bug list, and doesn't seem to be editable.
*/

    static testMethod void verifyCreatingChildOfBug() {
    	Apexpages.Standardcontroller sc;
    	ADM_WorkTreeController wtc;
    	ADM_selectWorkRecordTypeExtensions selWorkExt;
    	ADM_WorkControllerExtension wce;
        ADM_Work__c work = ADM_Work.setupTestWork('Bug','P3');
        ADM_Work__c emptyWork = new ADM_Work__c();

        Test.startTest();
            work.Type__c = 'Bug List';
            work.Priority__c = 'P1';
            insert work;
        Test.stopTest();

        sc = new Apexpages.Standardcontroller(work);
        wtc = new ADM_WorkTreeController(sc);

        System.currentPageReference().getParameters().putAll(wtc.redirectToNewChildWorkRecord().getParameters());
        sc = new Apexpages.Standardcontroller(emptyWork);
        selWorkExt = new ADM_selectWorkRecordTypeExtensions(sc);
        List<RecordType> recTypes = selWorkExt.getRecordTypes();
        for(RecordType recType : recTypes) {
        	if(recType.Name.equalsIgnoreCase('bug')) {
        		selWorkExt.setRecordType(recType.Id);
        	}
        }

        System.currentPageReference().getParameters().putAll(selWorkExt.gotoWorkEdit().getParameters());
        sc = new Apexpages.Standardcontroller(emptyWork);
        wce = new ADM_WorkControllerExtension(sc);
        List<Selectoption> workTypes = wce.getWorkTypes();
        for(Selectoption workType : workTypes) {
        	if(!workType.getLabel().equalsIgnoreCase('bug list')) {
        		wce.setWorkType(workType.getValue());
        	}
        }

        System.assertNotEquals('Bug List', wce.getRecordType().Name);
    }
    
    static testMethod void testCreateNewChildWork() {
        List<ADM_Work__c> works = ADM_Work.createListOfWork(2, 'Bug');
        insert works;
        works = [select Id, Name from ADM_Work__c where Id in :works];
        
        ADM_Work__c work = works.get(0);
        ADM_Work__c work2 = works.get(1);
        
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        wtc.newChildWorkName = work2.Name;
        wtc.relationshipType = 'duplicate';
        wtc.createNewChildWork();
        
        Test.stopTest();
        
        List<ADM_Parent_Work__c> relationships = [select Duplicate__c from ADM_Parent_Work__c where Parent_Work__c = :work.Id and Child_Work__c = :work2.Id];
        System.assertEquals(1, relationships.size(), 'Expected there to be one relationship created');
        System.assertEquals(true, relationships.get(0).Duplicate__c, 'Expected the duplicate value to be set to true since the relationship type was Duplicate');
        
    }
}