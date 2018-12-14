@IsTest
public class ADM_PerforceConnectorCleanupTest {
	testMethod static void testTriggerInsert() {/*		         
        ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
        ADM_ReleasedInDetailAccumulator rida = new ADM_ReleasedInDetailAccumulator();
        ADM_ReleaseDetailAccumulator rda = new ADM_ReleaseDetailAccumulator();
        */
        
        ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
        List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
        ADM_Work__c work = ADM_Work.createTestWork();
        /*ADM_Release__c release = new ADM_Release__c(Name = System.now() + 'ATHF');        
        ADM_Released_In__c releasedIn;        
        List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();
        List<ADM_Release__c> releases = new List<ADM_Release__c>();
        List<ADM_Released_In__c> releasedIns = new List<ADM_Released_In__c>();        
		
		upsert release;		
		releases.add(release);
		*/
        String describe = '';
        describe = describe + '        Testing new ARS';
        describe = describe + '        https://tapp0.salesforce.com/' + work.Id;
        describe = describe + '        @rev jhatton@';
        describe = describe + '        @revert@';
        
        pc.Describe__c = 'Change: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
        pc.Changelist__c = '921073';
        pc.Release__c = 'ATHF';     
        pc.Work__c = work.Id;   
        pcs.add(pc);
        /*cls.add(cld.getChangelist(pc.Describe__c, pc.Changelist__c, work.Id, pc.Release__c));
        releasedIns = rida.getReleasedIns(cls, rda.getReleaseMap(releases));*/
        
        
        Test.startTest();
        try{
        	Database.insert(pc);
        } catch (System.Nullpointerexception e) {
        	
        }        
        Test.stopTest();
	}
}