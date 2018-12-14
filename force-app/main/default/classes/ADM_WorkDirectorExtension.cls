/**
Description: Directs the user to either the classic or next generation work page based on their user preference	
**/

public with sharing class ADM_WorkDirectorExtension{

    private transient RecordType currentRecordType = null;
    private transient Boolean newRecord = null;
    
    public ADM_WorkDirectorExtension(ApexPages.StandardController stdController) {
    	//locate record type
        Id currentRecordTypeId = null;
        String recTypeParam = System.currentPageReference().getParameters().get('RecordType');
        String recTypeNameParam = System.currentPageReference().getParameters().get('RecordTypeLogicalName');
        //if RecordType is passed as a parameter use that (in case the user is changing the record type)
        if(!ADM_TextUtils.isBlank(recTypeParam)) {
            this.currentRecordType = ADM_RecordType.getById(recTypeParam);
        } else if(!ADM_TextUtils.isBlank(recTypeNameParam)) {
        	//attempt to retrieve by logical name
       		this.currentRecordType = ADM_RecordType.getByName(recTypeNameParam, 'ADM_Work__c');	
        } else if(stdController.getRecord() != null) {
        	ADM_Work__c work = (ADM_Work__c)stdController.getRecord();
            this.currentRecordType = ADM_RecordType.getById(work.RecordTypeId);
        } 

        /*
                If currentRecordType is null at this point - default it to Bug Record Type
                Apex test will be created to ensure this assumption and will fail in any org where Bug Record Type doesn't exist.
                https://gus.my.salesforce.com/a07B0000000dHMkIAM
        
        */
        if(null == currentRecordType) {
            currentRecordType = ADM_RecordType.getByName('Bug', 'ADM_Work__c');  
        }
        
        //track if this is a new record or an edit to an existing record - assume its new unless the stdController is populated
        newRecord = true;
        if(stdController.getRecord() != null) {
        	ADM_Work__c work = (ADM_Work__c)stdController.getRecord();
            if(work != null && work.id != null) {
                newRecord = false;
            }
        }

        
    } 
    
    public PageReference redirectDetailPage() {
        // MK modified to return to Work Tab
        // return ADM_Work.getWorkDetailPage(UserInfo.getUserId(), this.currentRecordType); //original line
        Pagereference p = new Pagereference('/lightning/o/ADM_Work__c/list?filterName=00B1U0000014qY7UAI');
        p.setRedirect(true);
        return p;
    }


    public PageReference redirectCreateOrEditPage() {
    	return ADM_Work.getIndependentWorkCreateOrEditPage(UserInfo.getUserId(), this.currentRecordType, newRecord);
    }

    public PageReference redirectDeepClone(){
        return ADM_Work.getWorkDeepClonePage(UserInfo.getUserId(), this.currentRecordType);
    }
}