/* 
* Copyright, 2008, SALESFORCE.com
* All Rights Reserved
* Company Confidential
*
* Controller for the Work Records Tree.  Delegates most of the heavy lifting to ADM_WorkTreeUtils
*   
*/

public with sharing class ADM_WorkTreeController { 

    

    //member variable to hold the current work item being viewed - initialized in standard controller

    private ADM_Work__c currentWork;
    private Id currentWorkID;      
    private ADM_Parent_Work__c childWork;    
    private WorkTreeContainer wtc;   
    private String defaultDepthRPWhenExpanded = '8';
    private String defaultDepthRPWhenNotProvided = '5';
    private String defaultDepthRPWhenCollapsed = '0';
    private Integer currentDepth = 5;        
    public Boolean resolvedFlag = false;    
    public Boolean expandedFlag = false;    
    private String childIDBeingModified;    
    private String parentIDOfChildBeingModified;    
    ADM_Parent_Work__c newChildWork;       
    Boolean relatedChildWorkCreateFlag;
    List<String> errorMessages;
    List<String> fatalErrorMessages;
    Boolean workTreeCache;

    public String relationshipType {
        get;
        set;
    }

    public String newChildWorkName {
        get;
        set;
    }

    public ADM_WorkTreeController() {

    }          
    
    
    
    public ADM_WorkTreeController(ApexPages.StandardController stdController) {
        fatalErrorMessages = new List<String>();
        this.setWork((ADM_Work__c)stdController.getRecord()); 
    }

    static testMethod void testADM_WorkTreeController() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        wtc.ajaxOpenOnlyFilter();
        wtc.ajaxExpandFilter();
        wtc.ajaxCollapseFilter();
        //throw away test to verfiy presence of no-arg constructor
        ADM_WorkTreeController wtcna = new ADM_WorkTreeController();
        System.assert(wtcna != null);
    }

    private void initController() {
        this.currentWork = populateWork();
        
        childWork = new ADM_Parent_Work__c();
        newChildWork = new ADM_Parent_Work__c();
        newChildWork.Parent_Work__c = currentWorkID;
        relatedChildWorkCreateFlag = false;
        if(this.errorMessages == null) errorMessages = new List<String>();
        //disable cache for the initial load
        workTreeCache = false;
    }

    public ADM_Work__c getWork() { return this.currentWork; }

    public void setWork(ADM_Work__c w) {
        this.currentWork = w;
        
        //why do we check the length of the ID?
        if(w.Id != null && String.valueOf(w.Id).length() > 14) {
            this.currentWorkID = w.Id;
        }
        
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

    //inner class to act as container for meta data.     
    
    public class WorkTreeContainer { 
    
      List<ADM_WorkTreeUtils.FamilyMetaData> familyTree; Integer sizeOfFamily; Integer openOnlyFilter; Integer expandedFlag;
       
      public List<ADM_WorkTreeUtils.FamilyMetaData> getFamilyTree() {
          return familyTree;
      }  
    
      public void setFamilyTree(List<ADM_WorkTreeUtils.FamilyMetaData> newFamily) {
          familyTree = newFamily;
      }
    
      public Integer getSizeOfFamily() {
          return sizeOfFamily;
      } 
    
      public void setSizeOfFamily(Integer newSize) {
          sizeOfFamily = newSize;
      }
    
      public Integer getOpenOnlyFilter() {      
          return openOnlyFilter;
      }
      
      public Integer getExpandedFlag() {
          return expandedFlag;
      }
      
      
    
    }
    
    /*
 @testcaseID:  a1DB00000000DIe 
 @userstoryID:  a0790000000DE2MAAW
 @Hierarchy:  GUS.BugforceToGUS.Work Page.BugsCreatedInGUS.ParentChildRecords
 @ExpectedResults: The application shows indentation depending on how many levels there are on the parent/child hierarchy under the Work Records tree
 @Author = James Hatton
 */
    testMethod static void testWorkTreeContainer() {
            ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createSmallTestFamily(), 'id', 'asc'); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(work);
            ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
            
            WorkTreeContainer container = new WorkTreeContainer();
            
            System.assert(wtc.getWorkTreeContainer() != null);
            List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = wtc.getFamilyMetaData();
            container.setFamilyTree(fmdList);
            System.assert(container.getFamilyTree() != null);
            Integer sizeOfFamily = fmdList.size();
            container.setSizeOfFamily(sizeOfFamily);
            System.assertEquals(sizeOfFamily, container.getSizeOfFamily());
            container.openOnlyFilter = 1;
            container.expandedFlag = 1;
            System.assert(container.getOpenOnlyFilter() != null);
            System.assert(container.getExpandedFlag() != null); 
    }
        
    private ADM_Work__c populateWork() {
       return ADM_Work.getOneBy('id',this.currentWorkID);  
    }   
    
    //Open only command button
    public void ajaxOpenOnlyFilter() {
        //set resolvedFlag which effects the family tree when it is re-rendered. Toogle flag
        if (resolvedFlag) {
            resolvedFlag = false;
        } else {
            resolvedFlag = true;
        }
        //refresh tree
        workTreeCache = false;  
    }   
    
    //Expand all command button 
    public void ajaxExpandFilter() {       
        //set Current Depth to 8 which will effect the tree once it re-renders
        currentDepth = 8;    
        expandedFlag = true;
        //refresh tree
        workTreeCache = false;
    }
    
    //Collapse command button   
    public void ajaxCollapseFilter() {      
        //set Current Depth to 0 which will effect the tree once it re-renders
        currentDepth = 0;    
        expandedFlag = false;
        //refresh tree
        workTreeCache = false;
    }
    
    //main method which creates a container holding the work tree and relevant meta data
    public WorkTreeContainer getWorkTreeContainer() {
        //only rebuild the work container if the cache flag is set to false - necessary as this method is re-called even for ajax requests
        //outside the scope of this controller
        if(workTreeCache != null && !workTreeCache) {
            wtc = new WorkTreeContainer();
            List<ADM_WorkTreeUtils.FamilyMetaData> fmdList = getFamilyMetaData();   
            wtc.setFamilyTree(fmdList); 
            wtc.setSizeOfFamily(fmdList.size());    
            if(resolvedFlag) {  
                wtc.openOnlyFilter = 1; 
            } else {    
                wtc.openOnlyFilter = 0; 
            }         
            if(expandedFlag) {
                wtc.expandedFlag = 1;
            } else {
                wtc.expandedFlag = 0;
            }
            workTreeCache = true;
        }
        
        return wtc;
    
    }
    
    /*
 @testcaseID:  a1DB00000000DIe 
 @userstoryID:  a0790000000DE2MAAW
 @Hierarchy:  GUS.BugforceToGUS.Work Page.BugsCreatedInGUS.ParentChildRecords
 @ExpectedResults: The application shows indentation depending on how many levels there are on the parent/child hierarchy under the Work Records tree
 @Author = James Hatton
 */
    static testMethod void testGetWorkTreeContainer() {
        
        ADM_Work__c work = ADM_Work.get('id', ADM_WorkTreeUtils.createTestFamily(), 'id', 'asc'); 
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        System.assert(wtc.getWorkTreeContainer() != null);
    }   
    
//Builds list of work objects wrapped in FamilyMetaData class.  Delegates the heavy lifting to ADM_WorkTreeUtils
    private List<ADM_WorkTreeUtils.FamilyMetaData> getFamilyMetaData() {
    
        try {
            //retrieve children of work item instantiated in the constructor
            String id = currentWorkID;
            List<ADM_Parent_Work__c> childlinks1stGen = ADM_WorkTreeUtils.getChildrenLinks(id);     
            
            //scrub data to ensure the work record is not a child of itself and that is parents arn't also listed as children       
            Set<String> setOfIdsFlaggedForRemoval = new Set<String>();
                
            //save the first generation of children in master list for display              
            List<ADM_WorkTreeUtils.LinkMetaData> lmd1stGen = ADM_WorkTreeUtils.convertParentLinkToLinkMetaData(childlinks1stGen, 0);
            List<ADM_WorkTreeUtils.LinkMetaData> masterList = lmd1stGen;
            
            //Check if any of the 1st generation children are children themselves and repeat (based on depth parameter)
            Map<String, List<ADM_WorkTreeUtils.LinkMetaData>> families = ADM_WorkTreeUtils.buildFamilyTree(childlinks1stGen, parseDepth(), setOfIdsFlaggedForRemoval);
        
            //add family tree to master list maintaining the sort order by placing children after their parents, and parents after their grandparents etc
            masterList = ADM_WorkTreeUtils.addFamilyToList(masterList, families);
             
            //convert LinkMetaData objects to FamilyMetaData objects suitable for display       
            return ADM_WorkTreeUtils.convertLinkMetaDataToFamilyMetaData(masterList, resolvedFlag);
        } catch (Exception e) {
            
            System.debug('An error has occurred during the construction of the related child work list. e:' + e + ' stack trace:' + e.getStackTraceString() + ' line:' + e.getLineNumber());
            if(fatalErrorMessages == null) {
                fatalErrorMessages = new List<String>();
            } 
            fatalErrorMessages.add('An error has occurred during the construction of the related child work list.  Exception:' + e + ' Stack Trace:' + e.getStackTraceString() + ' Line:' + e.getLineNumber());
            //set the cache flag to true to prevent the controller trying to populate the lists.  Even if the visual force tags which call these tags are told not to render they still get called on the controller
            workTreeCache = true;
            return new List<ADM_WorkTreeUtils.FamilyMetaData>();
         }      
    
    }

    
    public List<String> getFatalErrorMessages() {
        if(fatalErrorMessages != null) {            
            return fatalErrorMessages;
        } else {
            return null;
        }   
    } 
    
    public Integer getFatalErrorMessagesSize() {
         if(fatalErrorMessages != null) {
            return fatalErrorMessages.size();
        } else {
            return 0;
        }
    }
    
    //Retrieves the depth request parameter and enforces a performance cap
    
    private Integer parseDepth() {
        return currentDepth;
    }
    
    //these method handle inline ajax addition of new children
    public void setRelatedChildWorkCreateFlag() {        
            relatedChildWorkCreateFlag = true;
    }
    
    public Boolean getRelatedChildWorkCreateFlag() {        
            return relatedChildWorkCreateFlag;
    }
    
    public ADM_Parent_Work__c getNewChildWork() {
            return newChildWork;
    }
    
    public PageReference cancelChildWorkNew() {
            relatedChildWorkCreateFlag = false;        
            return null;
    }

    public PageReference createNewChildWork() {  
        ADM_Parent_Work__c child = new ADM_Parent_Work__c();
        try {
            //clear any left over error messages
            clearErrorMessages();
            String[] arrParentWorkIds = ADM_ParentWork.splitWorkItems(this.newChildWorkName);
            
            List<ADM_Work__c> validatedWorkItems = ADM_ParentWork.validateWorkItems(ADM_ParentWork.trimWorkItems(arrParentWorkIds));
            
            //compare user input to validated list size
            if(arrParentWorkIds.size() > validatedWorkItems.size()) {           
                addInvalidWorkItemErrorMsg(this.newChildWorkName); 
            }        
            //for each valid parent work ID entered check if a relationship already exists and if it doesn't create one        
            for( ADM_Work__c validPWork : validatedWorkItems ){
                //if prior relationship doesn't exist insert
                if(ADM_WorkTreeUtils.anchestorExists(currentWorkID, validPWork.Id)) {
                    //work ID already exists as parent
                    addReferenceExistsErrorMsg(validPWork.Name, 'ancestor');    
                } else if (ADM_WorkTreeUtils.childExists(currentWorkID, validPWork.Id)) {
                    //work ID already exists as child
                    addReferenceExistsErrorMsg(validPWork.Name, 'descendent');                     
                } else if(!ADM_WorkTreeUtils.isValidRecordTypeAssociation(validPWork.RecordType.Name)) {
                    addRecordTypeErrorMsg(validPWork.RecordType.Name);
                } else if (validPWork.Id == currentWorkID) {
                    addSelfReferenceErrorMsg();
                } else {
                    child = new ADM_Parent_Work__c();
                    child.Parent_Work__c = currentWorkID;
                    child.Child_Work__c = validPWork.Id;
                    
                    if('duplicate'.equalsIgnoreCase(this.relationshipType)) {
                        child.Duplicate__c = true;
                    } else {
                        child.Duplicate__c = false;
                    }
                    
                    //refresh tree
                    workTreeCache = false;
                    this.newChildWorkName = '';
                    Database.SaveResult sr = ADM_ParentWork.add(child);            
                    //if relating duplicate then set the child work record's status to Duplicate
                    if('duplicate'.equalsIgnoreCase(this.relationshipType)) {
                        try {
                            //need to determine record type due to different applicable statuses
                            Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
                            ADM_Work__c duplicate = [select id, RecordTypeId, status__c from ADM_Work__c where id=:validPWork.Id];
                            if(workRecordTypesById.get(duplicate.recordTypeId).Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
                                duplicate.status__c = 'Closed - Duplicate';     
                            } else {
                                duplicate.status__c = 'Duplicate';
                            }
                            
                            update duplicate;
                        }  catch (Exception e) {
                            
                            errorMessages.add('An error occurred while attempting to mark the child work records status to duplicate.');
                            return null;
                        }
                    }
                 
                 }     
            }
            
            
            //re-init newParentWork member variable for next time 
            newChildWork = new ADM_Parent_Work__c(); 
            newChildWork.Parent_Work__c = currentWorkID; 
            //reset the display       
            relatedChildWorkCreateFlag = false;   
            return null;
        } catch (Exception e) {
            
            
            errorMessages.add('An error has occurred while attempting to relate a new child work record Exception:' + e + ' Parent Work:' + child);
            return null;
         }         
    }
    
/*
 @testcaseID:  a1DB00000000DDY
 @userstoryID:  a0790000000DE2MAAW
 @Hierarchy:  GUS.BugforceToGUS.Work Page.BugsCreatedInGUS.ParentChildRecords
 @ExpectedResults: Click on the Edit button under the Child Work Records section in the Work Details page. The user is able to make changes to Child Work and save
 @Author = James Hatton
 */
    static testMethod void testCreateNewChildWork() {
        
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        System.assert(wtc.getWorkTreeContainer() != null);
        //create a new work object
        ADM_Work__c work2 = ADM_Work.createTestWork();
     
        //add work 2 as child of work1
        wtc.setRelatedChildWorkCreateFlag();
        System.assert(wtc.getRelatedChildWorkCreateFlag() == true);
        wtc.newChildWork.Child_Work__c = work2.id;
        wtc.createNewChildWork();
        wtc.getNewChildWork();
        wtc.cancelChildWorkNew();
        System.assert(wtc.getRelatedChildWorkCreateFlag() == false);
    
        
    }  
    
    public List<String> getErrorMessages() {
        return errorMessages;   
    }
    
    private void addSelfReferenceErrorMsg() {
        errorMessages.add('A work item cannot be related to itself');   
    }
    
    private void addRecordTypeErrorMsg(String recordType) {
        errorMessages.add(ADM_WorkTreeUtils.getRecordTypeErrorMsg(recordType));   
    }
    
    private void addInvalidWorkItemErrorMsg(String input) {
        errorMessages.add('Please enter a valid Work ID. ' + input + ' is invalid');        
    }
    
    private void addReferenceExistsErrorMsg(String workID, String relationship) {
        errorMessages.add('A prior ' +  relationship + ' already exists with WorkID:' + workID);       
    }
    
    private void clearErrorMessages() {
        errorMessages = new List<String>(); 
    } 
    
    public String getChildIDBeingModified() {
        return childIDBeingModified;
    }
    
    public void setChildIDBeingModified(Id cid) {
        childIDBeingModified = cid;
    }
    
    public String getParentIDOfChildBeingModified() {
        return parentIDOfChildBeingModified;
    }
    
    public void setParentIDOfChildBeingModified(Id pid) {
        parentIDOfChildBeingModified = pid;
    }
       
    public void deleteChildWork() {
        try {
            //clear any left over error messages
            
            errorMessages = new List<String>();
            //identify join record of child work based on child being deleted and its parent
            childWork = [select Id, Parent_Work__c, Child_Work__c from ADM_Parent_Work__c where Child_Work__c = :childIDBeingModified and Parent_Work__c = :parentIDOfChildBeingModified];
            Database.delete(childWork);
            //refresh tree
            workTreeCache = false;
            childIDBeingModified = null;
            parentIDOfChildBeingModified = null;
        } catch (Exception e) {            
            errorMessages.add('An error has occurred while attempting to remove a child work releationship.');    
             
        }       
         
    }  
/*
 @testcaseID: a1DB00000000DDZ  
 @userstoryID:  a0790000000DE2MAAW
 @Hierarchy:  GUS.BugforceToGUS.Work Page.BugsCreatedInGUS.ParentChildRecords
 @ExpectedResults: Click on the Delete button under the Child Work Records section in the Work Details page. The user is able to delete the child.
 @Author = James Hatton
 */
    
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
        wtc.childIDBeingModified = work2.id;
        wtc.parentIDOfChildBeingModified = work.id;
        wtc.deleteChildWork();
        System.assertEquals(0, [select count() from ADM_Parent_Work__c where id = :relationshipID]);
    }
    
    public PageReference redirectToNewChildWorkRecord() {
        
        PageReference newWork = Page.ADM_selectWorkRecordType;
        this.currentWork = populateWork();
        newWork.setRedirect(true); //want to change the URL as a result of navigation 
        newWork.getParameters().put('Parent_ID__c',ADM_TextUtils.getUTF8EncodedValue(this.currentWork.Name));
        //only Bugs use the Type field and even that will be deprecated soon
        if(currentWork.RecordType.Name == 'Bug') newWork.getParameters().put('Type__c',ADM_TextUtils.getUTF8EncodedValue(this.currentWork.Type__c));
        newWork.getParameters().put('Product_Tag__c',ADM_TextUtils.getUTF8EncodedValue(this.currentWork.Product_Tag__r.Name));
        newWork.getParameters().put('Minor_Func_Area__c',ADM_TextUtils.getUTF8EncodedValue(this.currentWork.Minor_Func_Area__c));
        newWork.getParameters().put('Scrum_Team__c',ADM_TextUtils.getUTF8EncodedValue(this.currentWork.Scrum_Team__r.Name));
        newWork.getParameters().put('Subject__c', ADM_TextUtils.getUTF8EncodedValue(this.currentWork.Subject__c));
        return newWork;
    } 
    
        /* 

      @testcaseID a0B20000008ykEDEAY
      @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-772699
      @userstory a07B0000000DZ3I
      @expectedResults: User is able to create parent/child records from a bug that contains special chars on subject
      @Author: James Hatton

    */   
    static testMethod void testRedirectToNewChildWorkRecord() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);        
        ADM_WorkTreeController wtc = new ADM_WorkTreeController(stdController);
        PageReference p = wtc.redirectToNewChildWorkRecord();
        System.assert(p != null);
        System.assert(p.getParameters() != null);
        System.assert(ADM_TextUtils.getUTF8DecodedValue(p.getParameters().get('Subject__c')).equals(work.Subject__c));
        //assert priority no longer copied
        String pValue = p.getParameters().get('Priority__c');
        System.assert(pValue == null);
     }
}