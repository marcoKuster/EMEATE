public with sharing class ADM_ReleaseRelatedListController {
    ADM_SetStandardControllerHelper helper { get; set; }
    
    public Set<String> selectedStamps {
        get {
            if(selectedStamps == null) {
                selectedStamps = new Set<String>();
            }
            return selectedStamps;
        }
        set;
    }
    
    public Integer numberOfStamps { get; set; }

    public String query { get; set; }    

    public String GUS_URL {
        get {
            return ADM_WorkUtils.GUS_URL;
        }
        set;
    }
    
    public String assignReleaseDivStyle {
        get ;
        set;
    }
    
    public String buttonsDivStyle {
        get ;
        set;
    }

  Map<String,List<Map<String,ADM_Released_In__c>>> allStamps {
    get {
      if(allStamps == null) {
        allStamps = new Map<String,List<Map<String,ADM_Released_In__c>>>();
      }
      return allStamps;
    }
    set;
  }

  List<Map<String,ADM_Released_In__c>> allStamps2add {
    get {
      if(allStamps2add == null) {
        allStamps2add = new List<Map<String,ADM_Released_In__c>>();
      }
      return allStamps2add;
    }
    set;
  }

  List<Map<String,ADM_Released_In__c>> allStamps2del {
    get {
      if(allStamps2del == null) {
        allStamps2del = new List<Map<String,ADM_Released_In__c>>();
      }
      return allStamps2del;
    }
    set;
  }

  public List<Map<String,ADM_Released_In__c>> allStampsFrom {
    get {
      if(allStampsFrom == null) {
        allStampsFrom = new List<Map<String,ADM_Released_In__c>>();
      }
      return allStampsFrom;
    }
    set;
  }

  List<Map<String,ADM_Released_In__c>> allStampsTo {
    get {
      if(allStampsTo == null) {
        allStampsTo = new List<Map<String,ADM_Released_In__c>>();
      }
      return allStampsTo;
    }
    set;
  }

  Map<String,ADM_Released_In__c> stamps2add {
    get {
      if(stamps2add == null) {
        stamps2add = new Map<String,ADM_Released_In__c>();
      }
      return stamps2add;
    }
    set;
  }

  Map<String,ADM_Released_In__c> stamps2del {
    get {
      if(stamps2del == null) {
        stamps2del = new Map<String,ADM_Released_In__c>();
      }
      return stamps2del;
    }
    set;
  }

    Integer numberOfReleasesFrom {
      get {
        return setCon.getResultSize();
      }
      set;
    }
    
    Set<String> openBatchJobStatusValues = new Set<String> {'queued', 'processing', 'preparing' };

    public Boolean hasBatchJobs {
        get {
            List<ADM_Release_Stamp_Batch_ID__c> batches = new List<ADM_Release_Stamp_Batch_ID__c>();
            batches = [select Batch_ID__c, Release__c, Release_To__c, Action__c from ADM_Release_Stamp_Batch_ID__c where Release__c = : releaseId];
            List<String> batchIds = ADM_WorkUtils.extractElsFromSobjects(batches, 'Batch_ID__c');
            List<AsyncApexJob> jobs = [Select Status from AsyncApexJob where Id in : batchIds];
            for(AsyncApexJob job : jobs) {
                if(openBatchJobStatusValues.contains(job.Status.toLowerCase())) {
                    return true;
                }
            }
            return false;
        }
        set;
    }

    transient ADM_Released_In__c stamp2add { get; set; }
    ADM_Release__c release { get; set; }
    public List<ADM_StampsWrapper> stampsWrapper { get; set; }
    public Boolean releaseAssignmentEnabled { get; set; }
    public String releaseId { get; set; }
    public String stampId { get; set; }
    Integer hasBeenLoaded { get; set; }
    transient String message { get; set; }
    public Integer MAP_SIZE_MAX = 1000;
    public Integer maxNumberOfStamps = 10000;
    
    public ADM_Release__c autoCompleteRelease {
      get {
        if(autoCompleteRelease == null) {
          autoCompleteRelease = new ADM_Release__c(Name='');
        }
        return autoCompleteRelease;
      }
      set;
  }
    ApexPages.standardController controllerObj = null;
    
    public ADM_ReleaseRelatedListController(ApexPages.StandardController controller) {
        this.controllerObj = controller;
    	this.release = (ADM_Release__c) controller.getRecord();
        releaseId = (String)this.release.Id;
    }

    // Simple accessors for the System.UserInfo theme methods
    public String getContextUserUiTheme() {
        return UserInfo.getUiTheme();
    }    
    public String getContextUserUiThemeDisplayed() {
        return UserInfo.getUiThemeDisplayed();
    }    

    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                try {               
                    Integer maxTransfer = MAP_SIZE_MAX + 1;
                    String messageTooBig = '';
                    String messageMoreThanMax = 'Please be aware transferring ' + Integer.valueOf(MAP_SIZE_MAX + 1) + '+ release stamps will require the request to be completed in batch. You will receive an email when the jobs have been completed.';
                    message = System.currentPageReference().getParameters().get('message');
                    hideAssignReleaseControlsAndShowAssignReleaseButton();
                    numberOfStamps = Integer.valueOf([select Number_of_Stamps__c from ADM_Release__c where Id =: releaseId].Number_of_Stamps__c);
                    if(numberOfStamps > maxNumberOfStamps) {
                        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([
                            select Work__r.RecordType.Name, Work__r.Id, Work__r.Subject__c, Work__r.Priority__c, Work__r.Status__c, Work__r.Scheduled_Build__c, Work__r.Scheduled_Build__r.Name, Work__r.Name, Work__c, CreatedDate, Reverted__c, Release__r.Name, Release__c, Stamped_On__c
                            from ADM_Released_In__c
                            where Release__c =: releaseId
                            order by Work__r.Name, CreatedDate
                            limit 10000
                        ]));
                        messageTooBig = ' There are a total of ' + numberOfStamps + ' records in this release. This page is limited to displaying only ' + maxNumberOfStamps + ' records. Please use a list view of Released In records to view more than ' + maxNumberOfStamps + ' release stamps. ';                                      
                    } else {
                        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([
                            select Work__r.RecordType.Name, Work__r.Id, Work__r.Subject__c, Work__r.Priority__c, Work__r.Status__c, Work__r.Scheduled_Build__c, Work__r.Scheduled_Build__r.Name, Work__r.Name, Work__c, CreatedDate, Reverted__c, Release__r.Name, Release__c, Stamped_On__c
                            from ADM_Released_In__c
                            where Release__c =: releaseId
                            order by Work__r.Name, CreatedDate
                        ]));
                    }
                    helper = new ADM_SetStandardControllerHelper(releaseId, new List<String>(), new List<String>(), new List<String>(), new List<String>());
                    query = helper.query.replace(' limit 10000', '');
                    release = [select Name from ADM_Release__c where Id =: releaseId];
                    if(hasBeenLoaded == null) {
                        if(message != null) {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,message));
                        } else {
                            if(setCon.getResultSize() == 0) {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'This release does not have any release stamps.'));
                            } else if(hasBatchJobs) {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'The Assign Release button will be enabled automatically once all outstanding jobs against this Release have been settled.'));
                            } else if(setCon.getResultSize() > maxTransfer && numberOfStamps > maxNumberOfStamps) {
                                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, messageMoreThanMax + messageTooBig));
                            } else if(setCon.getResultSize() > maxTransfer && numberOfStamps <= maxNumberOfStamps) {
                                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, messageMoreThanMax));
                            }
                        }
                        hasBeenLoaded = 1;
                    }
                } catch (System.QueryException e) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred. The release you selected may no longer exist! ' + e + '.'));
                }
            }
            return setCon;
        }
        set;
    }

    public List<ADM_StampsWrapper> getStamps() {
        if(stampsWrapper != null) {
            for(ADM_StampsWrapper stampWrapper : stampsWrapper) {
                if(stampWrapper.checked) {
                    if(!selectedStamps.contains(stampWrapper.stamp.Id)) {
                        selectedStamps.add(stampWrapper.stamp.Id);
                    }
                } else {
                    if(selectedStamps.contains(stampWrapper.stamp.Id)) {
                        selectedStamps.remove(stampWrapper.stamp.Id);
                    }
                }
            }
        }
        stampsWrapper = new List<ADM_StampsWrapper>();
        for(ADM_Released_In__c stamp : (List<ADM_Released_In__c>)setCon.getRecords()) {
            ADM_StampsWrapper wrapper = new ADM_StampsWrapper();
            wrapper.stamp = stamp;
            wrapper.checked = selectedStamps.contains(stamp.Id);
            stampsWrapper.add(wrapper);
        }
        return stampsWrapper;
    }

     // indicates whether there are more records after the current page set.
     public Boolean hasNext {
         get {
             return setCon.getHasNext();
         }
         set;
     }

     // indicates whether there are more records before the current page set.
     public Boolean hasPrevious {
         get {
             return setCon.getHasPrevious();
         }
         set;
     }

     // returns the page number of the current page set
     public Integer pageNumber {
         get {
             return setCon.getPageNumber();
         }
         set;
     }

     // returns the page size of the current page set
     public Integer pageSize {
         get {
             return setCon.getPageSize();
         }
         set;
     }

     public Integer resultSize {
       get {
         return setCon.getResultSize();
       }
       set;
     }

     // returns the first page of records
     public void first() {
         setCon.first();
     }

     // returns the last page of records
     public void last() {
         setCon.last();
     }

     // returns the previous page of records
     public void previous() {
         setCon.previous();
     }

     // returns the next page of records
     public void next() {
         setCon.next();
     }

     // returns the PageReference of the original page, if known, or the home page.
     public void cancel() {
         setCon.cancel();
     }
     
     public Pagereference doCancel(){
               
     Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Release__c;
     return new PageReference('/' + result.getKeyPrefix() + '/o');
     
     }
     
     public String getListViewLink(){
               
     Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Release__c;
     String objectPrefix = '/' + result.getKeyPrefix() + '/o';
     return objectPrefix;
     
     }
     
     
     public Pagereference doSaveAndNew(){
         SObject so = controllerObj.getRecord(); 
         upsert so;
         Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Release__c;
         return new PageReference('/' + result.getKeyPrefix() + '/e');
     }

     public Integer rowStart {
       get {
         if(!hasPrevious) {
           return 1;
         } else if(hasNext){
           return (getStamps().size() * (pageNumber - 1)) + 1;
         } else {
           return resultSize - getStamps().size() + 1;
         }
       }
       set;
     }

     public Integer rowEnd {
       get {
         if(!hasNext) {
           return resultSize;
         } else {
           return getStamps().size() * pageNumber;
         }
       }
    set;
  }

    public PageReference nothing() { return null; }

    public PageReference enableReleaseAssignment() {
        this.releaseAssignmentEnabled = true;
        return null;
    }
    
    public void showAssignReleaseControlsAndHideAssignReleaseButton(){
       this.assignReleaseDivStyle = 'display:none';
       this.buttonsDivStyle = 'display:block';
    }
    
    public void hideAssignReleaseControlsAndShowAssignReleaseButton(){
    
       this.assignReleaseDivStyle = 'display:block';
       this.buttonsDivStyle = 'display:none'; 
    
    }
    
    public PageReference disableReleaseAssignment() {
        hideAssignReleaseControlsAndShowAssignReleaseButton();
        this.releaseAssignmentEnabled = false;
        return null;
    }

    public PageReference deleteStamp(){
        if(stampId != null){
            try{
                Database.DeleteResult result = Database.delete(stampId);
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                }
            }
        }
        PageReference pr = null;
        if (!getContextUserUiTheme().equals('Theme4d') && !getContextUserUiTheme().equals('Theme4t')) {
            pr = Page.ADM_ReleaseRelatedList;
            pr.setRedirect(true);
            pr.getParameters().put('id',System.currentPageReference().getParameters().get('id'));                
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Your request has been successfully completed.'));
            setCon = null;		// Force a refresh of the stamp list
        }
        return pr;
    }

    public PageReference refresh() {
        PageReference pr = null;
        if (!getContextUserUiTheme().equals('Theme4d') && !getContextUserUiTheme().equals('Theme4t')) {
            pr = Page.ADM_ReleaseRelatedList;
            pr.setRedirect(true);
            pr.getParameters().put('id',System.currentPageReference().getParameters().get('id'));                
        } else {
            setCon = null;		// Force a refresh of the stamp list
        }
        return pr;
    }

    public PageReference DeleteAll() {
      process();
      return saveAndReturn();
    }

    public Pagereference Copy() {
      showAssignReleaseControlsAndHideAssignReleaseButton();
      process(true, false);
      return saveAndReturn();
    }

    public Pagereference Transfer() {
      showAssignReleaseControlsAndHideAssignReleaseButton();
      process(false, false);
      return saveAndReturn();
    }

    public Pagereference CopyAll() {
      showAssignReleaseControlsAndHideAssignReleaseButton();
      process(true, true);
      return saveAndReturn();
    }

    public Pagereference TransferAll() {
      showAssignReleaseControlsAndHideAssignReleaseButton();
      process(false, true);      
      return saveAndReturn();
    }

    private Boolean hasStampsSelected() {
        Boolean selected = false;
        if(stampsWrapper != null) {
            for(ADM_StampsWrapper stamp : stampsWrapper) {
                if(stamp.checked) {
                    selected = true;
                    break;
                }
            }
        }
        return selected;
    }

    private Boolean hasNoStampsSelected() {
        return !hasStampsSelected();
    }

    public void convertStampsWrapper(Boolean isCopy, String release2use) {
      Map<String,ADM_Released_In__c> stampsFrom = new Map<String,ADM_Released_In__c>();

    for (ADM_StampsWrapper stamp : stampsWrapper) {
      if (stamp.checked) {
        stampsFrom.put(stamp.stamp.Work__c,stamp.stamp);
      }
    }

    allStampsFrom.add(stampsFrom);
    }

    public void flushAddStamps() {
        allStamps2add.add(stamps2add);
        stamps2add = new Map<String,ADM_Released_In__c>();
    }

    public void flushDeleteStamps() {
        allStamps2del.add(stamps2del);
        stamps2del = new Map<String,ADM_Released_In__c>();
    }

    public void cleanupStamps() {
    if(!stamps2add.isEmpty()) allStamps2add.add(stamps2add);
    if(!stamps2del.isEmpty()) allStamps2del.add(stamps2del);

    allStamps.put('delete', allStamps2del);
    allStamps.put('insert', allStamps2add);

        stamps2add = null;
        stamps2del = null;
    }

    private void process() {
        if(numberOfReleasesFrom < MAP_SIZE_MAX + 1) {
            allStampsFrom = ADM_ReleasedIn.getStampsFromQuery(query);
            allStamps.put('delete', allStampsFrom);
        } else {
            ADM_StampBatchDelete stampBatchDelete = new ADM_StampBatchDelete(releaseId, query);
            Id idOfBatchDelete = Database.executeBatch(stampBatchDelete);

            ADM_Release_Stamp_Batch_ID__c stampBatchId = new ADM_Release_Stamp_Batch_ID__c();
            stampBatchId.Release__c = releaseId;
            stampBatchId.Batch_ID__c = idOfBatchDelete;
            stampBatchId.Action__c = 'Delete All';
            insert stampBatchId;
        }
    }

  // displays the selected items
  private void process(Boolean isCopy, Boolean isAll) {
    try {
      if(autoCompleteRelease.Name == null) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Select a release to use.'));
      } else if(autoCompleteRelease.Name == release.Name) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Select a different release to use other than the one you are currently viewing.'));
      } else if(!hasNoStampsSelected() || isAll){
        ADM_Release__c release2use = [select Id from ADM_Release__c where Name =: autoCompleteRelease.Name];
        allStampsTo = ADM_ReleasedIn.getStampsForRelease(release2use.Id);
        Boolean hasMatch;
        List<ADM_Release_Stamp_Batch_ID__c> stampBatchIds = new List<ADM_Release_Stamp_Batch_ID__c>();
        ADM_Release_Stamp_Batch_ID__c stampBatchId;

        if(isAll) {
          if(numberOfReleasesFrom < MAP_SIZE_MAX + 1) {
            allStampsFrom = ADM_ReleasedIn.getStampsFromQuery(query);
          } else {
            ADM_StampBatch stampBatch = new ADM_StampBatch(releaseId, release2use.Id, query);
            Id idOfBatch = Database.executeBatch(stampBatch);

            stampBatchId = new ADM_Release_Stamp_Batch_ID__c();
            stampBatchId.Release__c = releaseId;
            stampBatchId.Batch_ID__c = idOfBatch;
            stampBatchId.Action__c = 'Copy All';
            stampBatchId.Release_To__c = release2use.Id;
            stampBatchIds.add(stampBatchId);

            if(!isCopy) {
                ADM_StampBatchDelete stampBatchDelete = new ADM_StampBatchDelete(releaseId, query);
                Id idOfBatchDelete = Database.executeBatch(stampBatchDelete);

                stampBatchId = new ADM_Release_Stamp_Batch_ID__c();
                stampBatchId.Release__c = releaseId;
                stampBatchId.Batch_ID__c = idOfBatchDelete;
                stampBatchId.Action__c = 'Transfer All';
                stampBatchId.Release_To__c = release2use.Id;
                stampBatchIds.add(stampBatchId);
            }

            insert stampBatchIds;
          }
        } else {
            convertStampsWrapper(isCopy, release2use.Id);
        }

        for(Map<String,ADM_Released_In__c> stampsFrom : allStampsFrom) {
          for(String work : stampsFrom.keySet()) {
            hasMatch = false;
            for(Map<String,ADM_Released_In__c> stampsTo : allStampsTo) {
              if(stampsTo.containsKey(work)) {
                hasMatch = true;
                break;
              }
            }
            if(!hasMatch) {
              stamp2add = stampsFrom.get(work).clone(false,true,true);
              stamp2add.Release__c = release2use.Id;

              stamps2add.put(stamp2add.Work__c, stamp2add);
              if(!isCopy) stamps2del.put(work,stampsFrom.get(work));

                if(stamps2add.size() == MAP_SIZE_MAX) {
                    flushAddStamps();
                }
                if(stamps2del.size() == MAP_SIZE_MAX) {
                    flushDeleteStamps();
                }
            } else if(hasMatch && !isCopy){
              stamps2del.put(work,stampsFrom.get(work));

                if(stamps2add.size() == MAP_SIZE_MAX) {
                    flushAddStamps();
                }
                if(stamps2del.size() == MAP_SIZE_MAX) {
                              flushDeleteStamps();
                }
            }
          }
        }
      } else {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Nothing was selected.'));
      }
      cleanupStamps();
    } catch (System.QueryException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred. The release you selected, ' + autoCompleteRelease.Name + ', may no longer exist! ' + e + '.'));
    }
  }

    private PageReference saveAndReturn() {
        for(String state : allStamps.keySet()) {
            if(state.equalsIgnoreCase('delete')) {
                List<String> stampCacheIds = new List<String>();
                for(Map<String,ADM_Released_In__c> listOfDeletes : allStamps.get(state)) {
                    try {
                        if(!listOfDeletes.isEmpty()) {
                            String releaseIds2remove = '';
                            ADM_Release_Stamp_Cache__c stampCache = new ADM_Release_Stamp_Cache__c();

                            if(allStamps.get(state).size() > 2) {
                                for(ADM_Released_In__c release2remove : listOfDeletes.values()) {
                                    releaseIds2remove += ',' + release2remove.Id;
                                }

                                stampCache.Stamp_ID_List__c = releaseIds2remove.replaceFirst(',', '');
                                insert stampCache;
                                stampCacheIds.add(stampCache.Id);
                            } else {
                                delete listOfDeletes.values();
                            }
                        }
                    } catch (System.DmlException e) {
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                        }
                    }
                }
                if(!stampCacheIds.isEmpty()) {
                    deleteStampsAsynchronously(stampCacheIds);
                }
            } else {
                for(Map<String,ADM_Released_In__c> listOfInserts : allStamps.get(state)) {
                    try {
                        if(!listOfInserts.isEmpty()) insert listOfInserts.values();
                    } catch (System.DmlException e) {
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                        }
                    }
                }
            }
        }

        stamps2add = null;
        stamps2del = null;
        allStamps2add = null;
        allStamps2del = null;

        if(Apexpages.hasMessages()) return null;
        PageReference pr = null;
        if (!getContextUserUiTheme().equals('Theme4d') && !getContextUserUiTheme().equals('Theme4t')) {
            pr = Page.ADM_ReleaseRelatedList;
            pr.setRedirect(true);
            pr.getParameters().put('id',System.currentPageReference().getParameters().get('id'));                
            if(!hasBatchJobs) {
                pr.getParameters().put('message', 'Your request has been successfully completed');
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Your request has been successfully completed.'));
            setCon = null;		// Force a refresh of the stamp list
        }
        return pr;
    }

    @Future
    public static void deleteStampsAsynchronously(List<String> stampCacheIds) {
      List<ADM_Release_Stamp_Cache__c> stampsCached = [select Stamp_ID_List__c, CreatedById from ADM_Release_Stamp_Cache__c where Id in : stampCacheIds];
      Integer totalWork = 0;
      String releaseName = '';

      for(ADM_Release_Stamp_Cache__c stampCached : stampsCached) {
        List<ADM_Released_In__c> releases2remove = [select Id, Release__c, Release__r.Name from ADM_Released_In__c where Id in : stampCached.Stamp_ID_List__c.split(',')];
        releaseName = releases2remove.get(0).Release__r.Name;
        totalWork += releases2remove.size();
        Database.delete(releases2remove, true);
      }

      User user = [select FirstName, LastName, Email from User where Id =: stampsCached.get(0).CreatedById];
        Messaging.SingleEmailMessage wMail = new Messaging.SingleEmailMessage();
        ADM_ConstantsSingleton settings = ADM_ConstantsSingleton.getInstance();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<String> emailAddresses = new List<String>();
        String html = 'Release, ' + releaseName + ', has had ' + totalWork + ' release stamp(s) successfully deleted.';

        emailAddresses.add(user.Email);

        wMail.setToAddresses(emailAddresses);
        wMail.setBccSender( false );
        wMail.setSaveAsActivity( false );
        wMail.setUseSignature( true );
        wMail.setSubject( html );
        wMail.setHtmlBody( html );
        wMail.setPlainTextBody( html );
        wMail.setSenderDisplayName(user.FirstName + ' ' + user.LastName);
        wMail.setReplyTo(settings.getEmail2GusAddress());
        emails.add(wMail);

        List<Messaging.SendEmailResult> ser = Messaging.sendEmail(emails);
    }
}