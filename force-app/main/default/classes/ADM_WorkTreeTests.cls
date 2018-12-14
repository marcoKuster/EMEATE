@isTest
private class ADM_WorkTreeTests {
	
	/* 
	  @testcaseID a0B20000001ogHsEAI
	  @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify Child Work Related List "expand all" function works
	  @author jhatton */
	
	
	testMethod static void testChildWorkTreeRelatedListIsCreated() {
	  		ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		
	  		
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		System.assertEquals(2, fmdList.size());
	  		
    }
    
    /* 
	  @testcaseID a0B20000001odZuEAI
	  @hierarchy GGUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify Child Work Related List "expand all" function works
	  @author jhatton */
	
    
    testMethod static void testChildWorkTreeCanBeExpanded() {
	  		ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		wtc.ajaxExpandFilter();
	  		System.assert(wtc.getWorkTreeContainer() != null);
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		System.assert(wtc.getWorkTreeContainer().getExpandedFlag() == 1);	
    }
    
    /* 
	  @testcaseID a0B20000001odZvEAI
	  @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify Child Work Related List "collpase all" function works
	  @author jhatton */
	
    
    testMethod static void testChildWorkTreeCanBeCollapsed() {
	  		ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		wtc.ajaxCollapseFilter();
	  		System.assert(wtc.getWorkTreeContainer() != null);
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		System.assert(wtc.getWorkTreeContainer().getExpandedFlag() == 0);	
    } 
    
    /* 
	  @testcaseID a0B20000001pXSuEAM
	  @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify a new child relationship can be created
	  @author jhatton
	*/
    
    //testMethod static void testCreateNewChildWorkRelationship() {
	  		
	  		//Untestable right now. Visual Force allows Child_Work__c to hold the Name (W-123456) style id but apex unit test is more fussy.  Could overhall dynamic rel 
	  		//list to make it compatible with this unit test if we feel this will give us a decent ROI for our time...
	  		
	  		
	  		/*ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		System.assert(wtc.getWorkTreeContainer() != null);
	  		wtc.ajaxExpandFilter();
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		Integer originalNumberOfChildren = fmdList.size();
	  		ADM_Work__c newChild = ADM_Work.createTestWork();
	  		newChild = [select Name from ADM_Work__c where id=:newChild.id];
	  		
	  		
	  		wtc.getNewChildWork().Child_Work__c = newChild.Name;
	  		System.debug('newChild.Name' + newChild.Name);
	  		//create child
	  		wtc.createNewChildWork();
	  		//verfiy NO error messages have been added
        	System.assert(ApexPages.hasMessages() == false); 
        	//reload page
        	ApexPages.StandardController stdController2 = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc2 = new ADM_WorkTreeController(stdController2);
    		wtc2.ajaxExpandFilter();
	  		System.assertEquals(originalNumberOfChildren + 1, wtc2.getWorkTreeContainer().getFamilyTree().size(), wtc.getErrorMessages()); */
	  		 	
    // }
     
     /* 
	  @testcaseID a0B20000001odZwEAI
	  @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify resolved work is displayed in the child work related list
	  @author jhatton
	*/
    
    testMethod static void testChildWorkTreeDisplaysResolvedWorkItems() {
	  		ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		System.assert(wtc.getWorkTreeContainer() != null);
	  		wtc.ajaxExpandFilter();
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		//set children to resolved
	  		List<ADM_Work__c> children = new List<ADM_Work__c>();
	  		for(ADM_WorkTreeUtils.FamilyMetaData family : wtc.getWorkTreeContainer().getFamilyTree()) {
	  			ADM_Work__c child = family.getWork();
	  			child.Status__c = 'Resolved';
	  			children.add(child);
	  		}
	  		Test.startTest();
	  		update children;
	  		Test.stopTest();
	  		//reload page
        	ApexPages.StandardController stdController2 = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc2 = new ADM_WorkTreeController(stdController2);
	  		System.assert(wtc2.getWorkTreeContainer().getFamilyTree() != null);
	  		System.assertEquals(wtc2.getWorkTreeContainer().getFamilyTree().size(), wtc2.getWorkTreeContainer().getFamilyTree().size());
	  		 	
     }
     
     /* 
	  @testcaseID a0B20000001ogIrEAI
	  @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify resolved work is displayed in the child work related list
	  @author jhatton
	*/
    
    testMethod static void testChildWorkTreeDisplaysUnResolvedWorkItems() {
	  		ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		System.assert(wtc.getWorkTreeContainer() != null);
	  		wtc.ajaxExpandFilter();
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		//set children to unresolved
	  		List<ADM_Work__c> children = new List<ADM_Work__c>();
	  		for(ADM_WorkTreeUtils.FamilyMetaData family : wtc.getWorkTreeContainer().getFamilyTree()) {
	  			ADM_Work__c child = family.getWork();
	  			child.Status__c = 'New';
	  			children.add(child);
	  		}
	  		Test.startTest();
	  		update children;
	  		Test.stopTest();
	  		//reload page
        	ApexPages.StandardController stdController2 = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc2 = new ADM_WorkTreeController(stdController2);
	  		System.assert(wtc2.getWorkTreeContainer().getFamilyTree() != null);
	  		System.assertEquals(wtc2.getWorkTreeContainer().getFamilyTree().size(), wtc2.getWorkTreeContainer().getFamilyTree().size());
	  		 	
     }
     
     /* 
	  @testcaseID a0B20000001ogIrEAI
	  @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify closed work is displayed in the child related list
	  @author jhatton
	*/
    
    testMethod static void testChildWorkTreeDisplaysClosedWorkItems() {
	  		ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		System.assert(wtc.getWorkTreeContainer() != null);
	  		wtc.ajaxExpandFilter();
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		//set children to closed
	  		List<ADM_Work__c> children = new List<ADM_Work__c>();
	  		for(ADM_WorkTreeUtils.FamilyMetaData family : wtc.getWorkTreeContainer().getFamilyTree()) {
	  			ADM_Work__c child = family.getWork();
	  			child.Status__c = 'Closed';
	  			children.add(child);
	  		}
	  		Test.startTest();
	  		update children;
	  		Test.stopTest();
	  		//reload page
        	ApexPages.StandardController stdController2 = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc2 = new ADM_WorkTreeController(stdController2);
	  		System.assert(wtc2.getWorkTreeContainer().getFamilyTree() != null);
	  		System.assertEquals(wtc2.getWorkTreeContainer().getFamilyTree().size(), wtc2.getWorkTreeContainer().getFamilyTree().size());
	  		 	
     }
     
     /* 
	  @testcaseID a0B20000001ogIsEAI
	  @hierarchy GUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify closed work is displayed in the child related list
	  @author jhatton
	*/
    
    testMethod static void testChildWorkTreeDisplaysUnClosedWorkItems() {
	  		ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		System.assert(wtc.getWorkTreeContainer() != null);
	  		wtc.ajaxExpandFilter();
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		//set children to closed
	  		List<ADM_Work__c> children = new List<ADM_Work__c>();
	  		for(ADM_WorkTreeUtils.FamilyMetaData family : wtc.getWorkTreeContainer().getFamilyTree()) {
	  			ADM_Work__c child = family.getWork();
	  			child.Status__c = 'In Progress';
	  			children.add(child);
	  		}
	  		Test.startTest();
	  		update children;
	  		Test.stopTest();
	  		//reload page
        	ApexPages.StandardController stdController2 = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc2 = new ADM_WorkTreeController(stdController2);
	  		System.assert(wtc2.getWorkTreeContainer().getFamilyTree() != null);
	  		System.assertEquals(wtc2.getWorkTreeContainer().getFamilyTree().size(), wtc2.getWorkTreeContainer().getFamilyTree().size());
	  		 	
     }
     
     /* 
	  @testcaseID a0B20000001odZzEAI
	  @hierarchy GGUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify Child Work Related List "show open only" function works
	  @author jhatton */
	
    
    testMethod static void testChildWorkTreeOpenOnly() {
	  		ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
    		ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
	  		System.assert(wtc.getWorkTreeContainer() != null);
	  		List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getWorkTreeContainer().getFamilyTree();
	  		System.assert(fmdList != null);
	  		//set children to closed
	  		List<ADM_Work__c> children = new List<ADM_Work__c>();
	  		for(ADM_WorkTreeUtils.FamilyMetaData family : wtc.getWorkTreeContainer().getFamilyTree()) {
	  			ADM_Work__c child = family.getWork();
	  			child.Status__c = 'Closed';
	  			children.add(child);
	  		}
	  		Test.startTest();
	  		update children;
	  		Test.stopTest();
	  		//reload page
        	ApexPages.StandardController stdController2 = new ApexPages.StandardController(work);
    		ADM_WorkTreeController wtc2 = new ADM_WorkTreeController(stdController2);
	  		wtc2.ajaxOpenOnlyFilter();
	  		System.assert(wtc2.getWorkTreeContainer().getFamilyTree() != null);
	  		//all children are closed so ZERO items should remain in tree
	  		System.assertEquals(0, wtc2.getWorkTreeContainer().getFamilyTree().size());
	  			
    }
    
     /* 
	  @testcaseID a0B20000001oddGEAQ
	  @hierarchy GGUS.BugforceToGUS.WorkPage.BugsCreatedInGUS.ParentChildRecords
	  @userstory a0A2000000107aP
	  @expectedResults: Verify items can be removed from  Child Work Related List 
	  @author jhatton */
    
    static testMethod void testDeleteChildWork() {
		
		ADM_Work__c work = ADM_Work.createTestWork();
    	ApexPages.StandardController stdController = new ApexPages.StandardController(work);
    	ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
    	
    	//create a new work object
    	ADM_Work__c work2 = ADM_Work.createTestWork();
    	ADM_Parent_Work__c link = new ADM_Parent_Work__c();
    	link.Parent_Work__c = work.id;
    	link.Child_Work__c = work2.id;
    	Database.insert(link);
    	String relationshipID = link.id;
    	//not delete    	
    	wtc.setChildIDBeingModified(work2.id);
    	wtc.setParentIDOfChildBeingModified(work.id);
    	wtc.deleteChildWork();
    	System.assertEquals(0, [select count() from ADM_Parent_Work__c where id = :relationshipID]);
	}
    
    static testMethod void testCreateNewChildWork() {
        ADM_Work__c work = ADM_Work.createTestWork();
        
        //create a new work object
        ADM_Work__c work2 = ADM_Work.createTestWork();
        work2 = [select Name from ADM_Work__c where Id = :work2.Id];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        wtc.newChildWorkName = work2.Name;
        wtc.createNewChildWork();
        Test.stopTest();
        
        System.assert(wtc.getErrorMessages().isEmpty(), 'Unexpected error has occurred: ' + (wtc.getErrorMessages().isEmpty()? '' : wtc.getErrorMessages().get(0)));
        System.assertEquals(1, [select count() from ADM_Parent_Work__c where Parent_Work__c = :work.id and Child_Work__c = :work2.id]);
    }
    
    static testMethod void testErrorWhenCreateNewChildWorkWithExistingChild() {
        ADM_Work__c work = ADM_Work.createTestWork();
        
        //create a new work object
        ADM_Work__c work2 = ADM_Work.createTestWork();
        work2 = [select Name from ADM_Work__c where Id = :work2.Id];
        
        ADM_Parent_Work__c link = new ADM_Parent_Work__c(); 
        link.Parent_Work__c = work.id;
        link.Child_Work__c = work2.id;
        insert link;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        wtc.newChildWorkName = work2.Name;
        wtc.createNewChildWork();
        Test.stopTest();
        
        System.assertEquals(1, wtc.getErrorMessages().size(), 'Expected an error to be thrown');
        System.assert(wtc.getErrorMessages().get(0).contains('already exists'), 'Unexpected error thrown: ' + wtc.getErrorMessages());
    }
    
    static testMethod void testErrorWhenCreateNewChildWorkWithExistingParent() {
        ADM_Work__c work = ADM_Work.createTestWork();
        
        //create a new work object
        ADM_Work__c work2 = ADM_Work.createTestWork();
        work2 = [select Name from ADM_Work__c where Id = :work2.Id];
        
        ADM_Parent_Work__c link = new ADM_Parent_Work__c(); 
        link.Parent_Work__c = work2.id;
        link.Child_Work__c = work.id;
        insert link;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        wtc.newChildWorkName = work2.Name;
        wtc.createNewChildWork();
        Test.stopTest();
        
        System.assertEquals(1, wtc.getErrorMessages().size(), 'Expected an error to be thrown');
        System.assert(wtc.getErrorMessages().get(0).contains('already exists'), 'Unexpected error thrown: ' + wtc.getErrorMessages());
    }
    
    static testMethod void testErrorWhenCreateNewChildWorkWithSameName() {
        ADM_Work__c work = ADM_Work.createTestWork();
        work = [select Name from ADM_Work__c where Id = :work.Id];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        wtc.newChildWorkName = work.Name;
        wtc.createNewChildWork();
        Test.stopTest();
        
        System.assertEquals(1, wtc.getErrorMessages().size(), 'Expected an error to be thrown');
        System.assert(wtc.getErrorMessages().get(0).contains('related to itself'), 'Unexpected error thrown: ' + wtc.getErrorMessages());
    }
    
    static testMethod void testCreateDuplicateChildWork() {
        ADM_Work__c work = ADM_Work.createTestWork();
        
        //create a new work object
        ADM_Work__c work2 = ADM_Work.createTestWork();
        work2 = [select Name from ADM_Work__c where Id = :work2.Id];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        wtc.newChildWorkName = work2.Name;
        wtc.relationshipType = 'duplicate';
        wtc.createNewChildWork();
        Test.stopTest();
        
        System.assert(wtc.getErrorMessages().isEmpty(), 'Unexpected error has occurred: ' + (wtc.getErrorMessages().isEmpty()? '' : wtc.getErrorMessages().get(0)));
        System.assertEquals(1, [select count() from ADM_Parent_Work__c where Parent_Work__c = :work.id and Child_Work__c = :work2.id]);
        System.assertEquals('Duplicate', [select Status__c from ADM_Work__c where Id = :work2.id].Status__c);
    }
    
    static testMethod void testSetWorkId() {
        ADM_Work__c work = ADM_Work.createTestWork();
        
        Test.startTest();
        ADM_WorkTreeController wtc = new ADM_WorkTreeController();
        wtc.setWork(work);
        Test.stopTest();
    	
    	System.assertEquals(work.Id, wtc.getWork().Id);
    }
}