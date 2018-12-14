@isTest
public class ADM_ParentWorkTriggerTest {
	
	static testMethod void testTrigger() {
		ADM_Work__c work1 = ADM_Work.createTestWork();    
    	ADM_Work__c work2 = ADM_Work.createTestWork();
    
    
    	//relate 2 and 3 as 1st generation children of work 1
    	ADM_Parent_Work__c link1to2 = new ADM_Parent_Work__c();
    	link1to2.Parent_Work__c = work1.id;
    	link1to2.Child_Work__c = work2.id;
    	
    	Database.insert(link1to2);
			
	}	
	
  /*
      @testcaseID a1DB00000000rFA
      @hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Detail Page
      @userstory a0790000000DB5w
      @expectedResults An error gets generated: You cannot remove the only remaining parent of a work record with a status of "Duplicate".
    */

      /*
      @testcaseID a1DB00000000rF7
      @hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Detail Page
      @userstory a0790000000DB5w
      @expectedResults GUS adds both work items as parents, with no distiction to which one is original
    */


	static testMethod void testTheLastParentCannotBeDeletedIftheChildsStatusIsDuplicate() {
		List<ADM_Work__c> works = ADM_Work.createListOfWork(4, 'Bug');
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
        
        //1st verfiy a regular child CAN be deleted with mutiple parents regardless of status
		try {
			ADM_Parent_Work__c p = plist.get(0);
			String pid = p.id;
			delete p;
			System.assertEquals(0, [select count() from ADM_Parent_Work__c where id = :pid]);
		} catch (System.Exception e) {
			System.assert(false, 'Unexpected exception removing relationship:' +e);
		}
		
		//2nd verfiy a parent can be deleted even if its child as duplicate status so long as at least one parent remains
		try {
			ADM_Parent_Work__c p2 = plist.get(1);
			p2.Duplicate__c = true;
			update p2;
			
			ADM_Work__c dupe = works.get(0);
			dupe.Status__c = 'Duplicate';
			update dupe;
			//verify parent can still be deleted as the dupe has more then one
			String pid2 = p2.id;
			delete p2;
			System.assertEquals(0, [select count() from ADM_Parent_Work__c where id = :pid2]);
		} catch (System.Exception e) {
			System.assert(false, 'Unexpeted exception removing 2nd relationship:' +e);
		}
		
		//3rd verify a parent CANNOT be deleted  if its child has duplicate status and only one parent remains
		try {
			ADM_Parent_Work__c p3 = plist.get(2);
		    String pid3 = p3.id;
			delete p3;
			System.assert(false, 'An exception should have been thrown before the code reached here');
		} catch (DmlException e) { 
//            System.assert(e.getMessage().contains('You cannot remove the only remaining parent of a work record with a status of "Duplicate"'), e.getMessage());
        }
		
		
		
	}

}