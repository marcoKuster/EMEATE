@IsTest
public with sharing class ADM_InvestigationExtensionTest {
    
    /**
     * Ensure that the doClone method returns the correct page
     */
    public static testMethod void testDoClone() {
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_InvestigationExtension extension = new ADM_InvestigationExtension(controller);
        String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
        
        PageReference pageReference = extension.doClone();
        String qualifiedPageName = (nameSpacePrefix + 'ADM_InvestigationEdit').toLowerCase();   
        System.assert(pageReference.getUrl().containsIgnoreCase('/'+qualifiedPageName), 'Expected the page reference to go to the ADM_InvestigationEdit page: ' + pageReference.getUrl());
        System.assert(pageReference.getRedirect(), 'Expected the page reference to be a redirect');
        System.assertEquals(work.Id, pageReference.getParameters().get('id'), 'Expected the ID to be specified on the page reference');
        System.assertEquals('1', pageReference.getParameters().get('clone'), 'Expected the clone parameter to be specified on the page reference');
        System.assertEquals('/' + work.Id, pageReference.getParameters().get('retURL'), 'Expected the retURL to be specified on the page reference');
    }
    
    ///// Investigation SLAs
    
    /** Returns true if SLA_Due_Time is in the past, else false */
    @isTest
    static void testGetIsSLAOverdue() {
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_InvestigationExtension extension = new ADM_InvestigationExtension(controller);
		work.Due_Date__c = System.now().addHours(4);
        System.assertEquals(false, extension.getIsSLAOverdue());

        work.Due_Date__c = System.now().addHours(-4);
        System.assertEquals(true, extension.getIsSLAOverdue());
    }
    
    /** if Due_Date__c is null returns '',
     *  else if investigation has status New returns 'Acknowledgement Due',
     *  otherwise returns 'Update Due'
     */
    @isTest
    static void testGetSLACountdownLabel() {
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_InvestigationExtension extension = new ADM_InvestigationExtension(controller);
		
        Test.startTest();
        work.Due_Date__c = null;
        work.Status__c = 'New';
        System.assertEquals('', extension.getSLACountdownLabel());

		work.Due_Date__c = System.now();
        work.Status__c = 'New';
        System.assertEquals('Acknowledgement Due', extension.getSLACountdownLabel());

        work.Due_Date__c = System.now();
        work.Status__c = 'Investigating';
        System.assertEquals('Update Due From T&P', extension.getSLACountdownLabel());
        
        work.Due_Date__c = System.now();
        work.Status__c = 'More Info Reqd from Support';
        System.assertEquals('Update Due From Support', extension.getSLACountdownLabel());
        Test.stopTest();
    }
    
    /** Due_Date__c | Style should be:
     * 
     *   null | empty string
     *   in the past | color:red
     *   <1 hr from now | color:red
     *   >1 and <4 hrs from now | color:darkorange
     *   >4 hrs from now | color:green
     */    
    @isTest
    static void testGetSLACountdownStyle() {
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_InvestigationExtension extension = new ADM_InvestigationExtension(controller);
		
        Test.startTest();
        work.Due_Date__c = null;
        System.assertEquals('', extension.getSLACountdownStyle());
        
        work.Due_Date__c = System.now().addHours(-1);
        System.assertEquals('color:red', extension.getSLACountdownStyle());
        
        work.Due_Date__c = System.now().addMinutes(55);
        System.assertEquals('color:red', extension.getSLACountdownStyle());
        
        work.Due_Date__c = System.now().addHours(3);
        System.assertEquals('color:darkorange', extension.getSLACountdownStyle());
        
        work.Due_Date__c = System.now().addHours(5);
        System.assertEquals('color:green', extension.getSLACountdownStyle());
    }
    
    /** Due_Date__c | LabelStyle should be:
     * 
     *   null | empty string
     *   in the past | color:red
     *   <1 hr from now | color:red
     *   >1 hrs from now | empty string
     */    
    @isTest
    static void testGetSLACountdownLabelStyle() {
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_InvestigationExtension extension = new ADM_InvestigationExtension(controller);
		
        Test.startTest();
        work.Due_Date__c = null;
        System.assertEquals('', extension.getSLACountdownLabelStyle());
        
        work.Due_Date__c = System.now().addHours(-1);
        System.assertEquals('color:red', extension.getSLACountdownLabelStyle());
        
        work.Due_Date__c = System.now().addMinutes(55);
        System.assertEquals('color:red', extension.getSLACountdownLabelStyle());
        
        work.Due_Date__c = System.now().addHours(3);
        System.assertEquals('', extension.getSLACountdownLabelStyle());
        
        work.Due_Date__c = System.now().addHours(5);
        System.assertEquals('', extension.getSLACountdownLabelStyle()); 
    }
    
    /** Due_Date__c | Output should be:
     * 
     *   null | empty string
	 *
	 *   in the past | starts with 'Overdue by '
	 *   in the future | starts with 'In '
	 * 
     *   format: [x Day[s]] [y Hour[s]] [z Minute[s]]
     */    
    @isTest
    static void testGetSLADueTimeDiff() {
        ADM_Work__c work = ADM_Work.createTestWork('Investigation');
        ApexPages.StandardController controller = new ApexPages.StandardController(work);
        ADM_InvestigationExtension extension = new ADM_InvestigationExtension(controller);
		
        // padding all times by 30 sec to prevent failed assertions due to clock timing
        
        Test.startTest();
        work.Due_Date__c = null;
        System.assertEquals('', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(1*60 + 30);
        System.assertEquals('In 1 Minute ', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(5*60 + 30);
        System.assertEquals('In 5 Minutes ', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(1*3600 + 30);
        System.assertEquals('In 1 Hour ', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(4*3600 + 30);
        System.assertEquals('In 4 Hours ', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(1*24*3600 + 30);
        System.assertEquals('In 1 Day ', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(4*24*3600 + 30);
        System.assertEquals('In 4 Days ', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(10*3600 + 29*60 + 30);
        System.assertEquals('In 10 Hours 29 Minutes ', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(2*24*3600 + 10*3600 + 29*60 + 30);
        System.assertEquals('In 2 Days 10 Hours 29 Minutes ', extension.getSLADueTimeDiff());
        
        work.Due_Date__c = System.now().addSeconds(-(9*60 + 30));
        System.assertEquals('Overdue by 9 Minutes ', extension.getSLADueTimeDiff());
    }
}