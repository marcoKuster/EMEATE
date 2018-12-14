@isTest
private class ADM_ColorTriggerTest {
	private 
	@isTest static void TestColorDeactivationRemovesColorFromWorkCard() {
		ADM_Work__c bug = ADM_Work.createTestBug();
		ADM_Color__c testColor = ADM_Color.createColor('Test', '#000000', bug.Scrum_Team__c, 1);

		insert testColor;

		bug.Color__c = testColor.Id;
		update bug;

		ADM_Work__c bugAfterUpdate = [Select Color__c from ADM_Work__c where id = :bug.Id];
		System.assert(null != bugAfterUpdate.Color__c);
		
		Database.delete(testColor);//Deleting color should remove it's reference from work objects.


		bugAfterUpdate = [Select Color__c from ADM_Work__c where id = :bug.Id];

		System.assertEquals(null, bugAfterUpdate.Color__c, 'Expected color__c reference to be deleted as color ' + testColor.Name + ' was deactivated');
	}
	
	
	
}