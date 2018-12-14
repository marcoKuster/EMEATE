/*
* Copyright, 2008, SALESFORCE.com
* All Rights Reserved
* Company Confidential
*
* Controller for the Work Related Lists to extend them to allow inline async modification.
*/

public with sharing class ADM_WorkRelatedListController {

    //member variable to hold the current work item being viewed - initialized in standard controller
    private ADM_Work__c work;
	
	private Id currentWorkID;

    //any errors are added to this list and diplayed to the user
    List<String> errorMessages;
    List<String> fatalErrorMessages;

    //maintain the size of the lists for display
    @TestVisible private  Integer relatedChangeListSize = 0;
    @TestVisible private  Integer relatedChildWorkListSize = 0;
    @TestVisible private  Integer relatedParentWorkListSize = 0;
    @TestVisible private  Integer relatedReleaseListSize = 0;
    @TestVisible private  Integer related62OrgCaseListSize = 0;

    //visual force will re-populate the lists on every page load (including ajax requests). Cache the lists unless create, edit or delete action
    //has been called to save on SOQL improving performance
    Boolean releaseCache;
    Boolean sixtyTwoOrgCache;
    Boolean parentsCache;
    Boolean changesCache;

    //masters lists to hold the related objects
    List<ADM_Released_In__c> releases;
    List<ADM_Case__c> cases;
    List<ADM_Parent_Work__c> parents;
    List<ADM_Change_List__c> changes;

    public String clSearchUrl { get; set; }

    //on load related lists are limited to 5 records
    Boolean changeListLimit = true;
    Boolean sixtyTwoOrgCaseLimit = true;
    Boolean releaseLimit = true;


    public ADM_WorkRelatedListController() {
    	
    	
    }

    public ADM_WorkRelatedListController(ADM_Work__c work) {
        
        this.work = work;
        this.currentWorkID = work.id;
        //this.currentWorkID = work.id;
        errorMessages = new List<String>();
        initController(); 
    }


    //The extension constructor initializes the private member variable
    //work by using the getRecord method from the standard controller. 

    public ADM_WorkRelatedListController(ApexPages.StandardController stdController) { 
        
        this.work = (ADM_Work__c)stdController.getRecord();
        try {
            if(this.work.Id != null && String.valueOf(this.work.Id).length() > 14) {
                //work object from the controller is not fully populated - flesh out the fields we need
                this.work = populateWork();
                initController();
            }
         } catch (Exception e) {
            fatalErrorMessages = new List<String>();
            fatalErrorMessages.add('An unexpected error has occured during the construction of the related lists');
            //set the cache flags to true to prevent the controller trying to populate the lists.  Even if the visual force tags which call these tags are told not to render they still get called on the controller
            releaseCache = true;
            sixtyTwoOrgCache = true;
            parentsCache = true;
            changesCache = true;

         }
    }

	private void initController() { 
		try {
                
                //turn cache off to allow list to be populated on load.
                releaseCache = false;
                sixtyTwoOrgCache = false;
                parentsCache = false;
                changesCache = false;

                if(this.errorMessages == null) errorMessages = new List<String>(); 

                //populate related lists
                getRelatedReleasesList();
                getRelated62OrgCaseList();
                getRelatedChangeLists();
                
                
            
         } catch (Exception e) {
            fatalErrorMessages = new List<String>();
            fatalErrorMessages.add('An unexpected error has occured during the construction of the related lists:' + e + ' line:' + e.getLineNumber());
            //set the cache flags to true to prevent the controller trying to populate the lists.  Even if the visual force tags which call these tags are told not to render they still get called on the controller
            releaseCache = true;
            sixtyTwoOrgCache = true;
            parentsCache = true;
            changesCache = true;

         }	
		
		
	}
    
    public ADM_Work__c getWork() { return this.work; }

	public void setWork(ADM_Work__c w) {
    	
        this.work = w;
    	//finalize initialization once the comonent parameter for work is set.  If you attempt this in the constructor work will be null because visual
    	//force components call the constructor before the components parameters have been populated
    	initController();
    	
        
    }
    
     public Id getWorkID() { return this.currentWorkID; }

	public void setWorkID(Id wid) {
    	this.currentWorkID = wid;
    	//finalize initialization once the comonent parameter for work is set.  If you attempt this in the constructor work will be null because visual
    	//force components call the constructor before the components parameters have been populated
    	initController();
    }

    private ADM_Work__c populateWork() {
        return ADM_Work.getOneBy('id', currentWorkID);
    }

    public Boolean getChangeListLimit() {
        return changeListLimit;
    }

    public void enableChangeListLimit() {
        changeListLimit = true;
        //refresh the list with new limit setting
        changesCache = false;
    }

    public void disableChangeListLimit() {
        changeListLimit = false;
        //refresh the list with new limit setting
        changesCache = false;
    }

    public Boolean getSixtyTwoOrgCaseLimit() {
        return sixtyTwoOrgCaseLimit;
    }

    public void enable62OrgCaseLimit() {
        sixtyTwoOrgCaseLimit = true;
        //refresh the list with new limit setting
        sixtyTwoOrgCache = false;
    }

    public void disable62OrgCaseLimit() {
        sixtyTwoOrgCaseLimit = false;
        //refresh the list with new limit setting
        sixtyTwoOrgCache = false;
    }

    public Boolean getReleaseLimit() {
        return releaseLimit;
    }

    public void enableReleaseLimit() {
        releaseLimit = true;
        //turn off cache as the cached list does not have the limit in place
        releaseCache = false;
    }


    public void disableReleaseLimit() {
        releaseLimit = false;
        //turn off  cache as the cached list has the limit in place
        releaseCache = false;
    }

    //the size of each related list is exposed for display purposes
    public Integer getRelatedParentWorkListSize() {
        if (relatedParentWorkListSize == null) {
            relatedParentWorkListSize = [select count() from ADM_Parent_Work__c where Child_Work__c = :currentWorkID];
        }

        return relatedParentWorkListSize;
    }

    public Integer getRelatedChangeListSize() {
        return relatedChangeListSize;
    }

    public Integer getRelatedReleaseListSize() {
        return relatedReleaseListSize;
    }

    public Integer getRelated62OrgCaseListSize() {
        return related62OrgCaseListSize;
    }

    public List<ADM_Released_In__c> getRelatedReleasesList() {
        if (releaseCache != null && !releaseCache) {
            if (releaseLimit) {
                releases = [select Release__r.Name, Release__r.Release_Date__c, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, Reverted__c from ADM_Released_In__c where Work__c = :currentWorkID LIMIT 5];
                relatedReleaseListSize = [select count() from ADM_Released_In__c where Work__c = :currentWorkID];
            } else {
                releases = [select Release__r.Name, Release__r.Release_Date__c, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, Reverted__c from ADM_Released_In__c where Work__c = :currentWorkID];
                relatedReleaseListSize = releases.size();
            }
            releaseCache = true;
        }
        return releases;
    }

    public List<ADM_Change_List__c> getRelatedChangeLists() {
        if(changesCache != null && !changesCache) {
            relatedChangeListSize = [select count() from ADM_Change_List__c where Work__c = :currentWorkID];

            if(relatedChangeListSize > 1000) {
                Schema.DescribeSObjectResult clSchema = Schema.SObjectType.ADM_Change_List__c;
                clSearchUrl = ADM_WorkUtils.GUS_URL + '/search/SearchResults?searchType=1&sen=' + clSchema.getKeyPrefix() + '&setLast=1&sbstr=' + work.Name + '&search=+Go!+';
            }

            if (changeListLimit) {
                changes = [select Task__c, Changelist__c, Check_In_By__c, Check_In_Date__c, Comments__c from ADM_Change_List__c where Work__c = :currentWorkID order by Check_In_Date__c desc LIMIT 5];

            } else {
                if(relatedChangeListSize <= 1000) {
                    changes = [select Task__c, Changelist__c, Check_In_By__c, Check_In_Date__c, Comments__c from ADM_Change_List__c where Work__c = :currentWorkID order by Check_In_Date__c desc];
                } else {
                    changes = [select Task__c, Changelist__c, Check_In_By__c, Check_In_Date__c, Comments__c from ADM_Change_List__c where Work__c = :currentWorkID order by Check_In_Date__c desc limit 1000];
                }
            }


            changesCache = true;
        }
        return changes;
    }

    public List<ADM_Case__c> getRelated62OrgCaseList() {
        if(sixtyTwoOrgCache != null && !sixtyTwoOrgCache) {
            if(sixtyTwoOrgCaseLimit) {
                cases =  [select Name, Account_Link__c, Parent_Account_Link__c, Cases_Link__c, Case_Owner_Link__c, Case_Subject_Link__c, Case_Created_Date__c, LastModifiedDate from ADM_Case__c where Work__c = :currentWorkID order by Case_Created_Date__c DESC LIMIT 5];
                related62OrgCaseListSize = [select count() from ADM_Case__c where Work__c = :currentWorkID];
            } else {
                cases =  [select Name, Account_Link__c, Parent_Account_Link__c, Cases_Link__c, Case_Owner_Link__c, Case_Subject_Link__c, Case_Created_Date__c, LastModifiedDate from ADM_Case__c where Work__c = :currentWorkID order by Case_Created_Date__c DESC];
                related62OrgCaseListSize = cases.size();
            }
            sixtyTwoOrgCache = true;
        }
        return cases;
    }


    //Return a list of any error messages for display
    public List<String> getErrorMessages() {
        return errorMessages;
    }

    public List<String> getFatalErrorMessages() {
        return fatalErrorMessages;
    }
    
    @TestVisible
    private void addDuplicateItemErrorMsg() {
        errorMessages.add('This work item does not have a unique ID.');
    }

    @TestVisible
    private void addSelfReferenceErrorMsg() {
        errorMessages.add('A work item cannot be related to itself');
    }

    @TestVisible
    private void addInvalidItemErrorMsg(String input, String thing) {
        errorMessages.add('Please enter a valid ' + thing + '. ' + input + ' is invalid');
    }

    @TestVisible
    private void addReferenceExistsErrorMsg() {
        errorMessages.add('A prior relationship already exists');
    }

    @TestVisible
    private void addReferenceExistsErrorMsg(String thing) {
        errorMessages.add('A prior ' + thing + ' already exists');
    }

    @TestVisible
    private void addReferenceExistsErrorMsg(String workID, String relationship) {
        errorMessages.add('A prior ' +  relationship + ' already exists with WorkID:' + workID);
    }

    @TestVisible
    private void clearErrorMessages() {
        errorMessages = new List<String>();
    }

}