//  singular trigger that handles all calls for Work...    
trigger WorkTrigger on ADM_Work__c (after insert, before insert, before update, after update) {
    ADM_Work__c[] worksNew = Trigger.new;
    ADM_Work__c[] worksOld = Trigger.old;
    
    
    //Get the record types because we need this for assignment rules and validation
    Map<Id,RecordType> workRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
    List<ADM_Work__c> workItemsThatNeedToUpdateAndInsertColumnHistory = new List<ADM_Work__c>();

    try {
        if( Trigger.isBefore && Trigger.isUpdate ) {                
            ADM_Validate.restrictRecordTypeConversion(Trigger.new, Trigger.old, workRecordTypesById); 
        }
    } catch(System.Exception e ){
        //log the error
        ADM_ExceptionHandler.saveException(e, 'Exception restricting Record Type:' + e + ' WorksNew:' + worksNew);
    }
    
    try {
        if( Trigger.isBefore && Trigger.isUpdate ) {                
            ADM_Work.removeUnnecessaryFieldsWhileChangingRecordTypes(Trigger.new, Trigger.old, workRecordTypesById); 
        }
    } catch(System.Exception e ){
        //log the error
        ADM_ExceptionHandler.saveException(e, 'Exception while changing Record Types:' + e + ' WorksNew:' + worksNew);
    }
       
        
    //evaluate if trigger is applicable - certain scenarios are exempt    
    if(UserInfo.getUserName().contains('p4') || UserInfo.getUserName().contains('Perforce') || worksNew[0].Template_Name__c != null || UserInfo.getUserName().contains('integration')){
        return;
    }    
    // decide whether the trigger is being called before or after the event
    if( Trigger.isBefore ) {
            
            try {
                /* Store origin in static data store so it can be accessed in after trigger.  It is set in ADM_WorkControllerExtension.saveAndView().  Please note:
                   - the ADM_Work__c.Origin__c field for each record is cleared to prevent it persisting to the DB once the last method that depends on it completes (see ADM_Validate)  
                   - you can't assume a batch size of 1 originates from the edit page as API clients and list view edits can also contain single records
                 */     
                
                if(worksNew.size() == 1) {  
                    ADM_WorkTriggerStaticDataStore.requestOrigin = worksNew.get(0).Origin__c;
                } 
                    
            } catch(Exception e ){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception determining origin. Line:' + e.getLineNumber() + ' Trigger.isUpdate:' + Trigger.isUpdate + ' Trigger.isInsert:' + Trigger.isInsert + ' WorksNew:' + worksNew + ' WorksOld:' + worksOld);
            }    
            
            try {
                //any values that you would like defaulted at the trigger level vs U.I are set here.  Note: please make sure the value
                //makes sense for records created from all origins (Salesforce Classic, LEX, API, S1)
                ADM_BeforeInsertOrUpdate.setDefaultValues(worksNew, workRecordTypesById);
            } catch(System.Exception e){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'ADM_BeforeInsertOrUpdate.setDefaultValues(). WorksNew:' + worksNew + ' workRecordTypesById:' + workRecordTypesById);
            }
            

            List<ADM_Work__c> workWhoseStatusNeedsUpdating = new List<ADM_Work__c>();
            try {
                if(Trigger.isUpdate) {                                       
                    for(ADM_Work__c newWork : Trigger.new) {
                        ADM_Work__c oldWork = Trigger.oldMap.get(newWork.Id);

                        //if the user changed a referenced property but did not change the associated rank, 
                        //then we need to reset the rank
                        
                        //reset the sprint rank if the sprint changes
                        try {
                            if(newWork.Sprint__c != oldWork.Sprint__c && newWork.Sprint_Rank__c == oldWork.Sprint_Rank__c) {
                                newWork.Sprint_Rank__c = null;
                            }
                        } catch(Exception e) {
                            ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception during sprint rank reset');
                        }

                        //reset theme rank if the theme changes
                        try {
                            if(newWork.Theme__c != oldWork.Theme__c && newWork.Theme_Rank__c == oldWork.Theme_Rank__c) {
                                newWork.Theme_Rank__c = null;
                            }
                        } catch(Exception e) {
                            ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception during theme rank reset');
                        }
                        
                        //reset scheduled build rank if the scheduled build changes
                        try {
                            if(newWork.Scheduled_Build__c != oldWork.Scheduled_Build__c && newWork.Scheduled_Build_Rank__c == oldWork.Scheduled_Build_Rank__c) {
                                newWork.Scheduled_Build_Rank__c = null;
                            }
                        } catch(Exception e) {
                            ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception during scheduled build rank reset');
                        }
                        //collect work whose column changed (but was not previously null i.e. not the first board load) but not it's status and the edit originated from the kanban board
                        try {
                            if((newWork.Origin__c == ADM_WorkTriggerStaticDataStore.KANBAN_BOARD_ORIGIN && oldWork.Column__c == null ) || (oldWork.Column__c != null && newWork.Column__c != oldWork.Column__c && newWork.Column__c != null && newWork.Status__c == oldWork.Status__c && newWork.Origin__c == ADM_WorkTriggerStaticDataStore.KANBAN_BOARD_ORIGIN)) {
                                newWork.Origin__c = '';
                                workWhoseStatusNeedsUpdating.add(newWork);
                            }
                        } catch(Exception e) {
                            ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception while collecting work whose column changed but not its status');
                        }

                        
                        
                    }
                    
                   
                }

                if(Trigger.isInsert){
                  for(ADM_Work__c newWork : Trigger.new) {
                      if(newWork.Column__c != null){
                        workWhoseStatusNeedsUpdating.add(newWork);
                      }
                  }
                }

                    //populates the status of the work record based on its column id
                    if(workWhoseStatusNeedsUpdating != null && workWhoseStatusNeedsUpdating.size() > 0) {
                        ADM_KanbanUtility.updateWorkWithStatus(workWhoseStatusNeedsUpdating);  
                    }
                            
            } catch(Exception e) {
                ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception during rank reset or work status update based on column id');
            }
            
            
        
        
            try {
                if( Trigger.isUpdate ) {                
                    ADM_WorkFixedAndClosedActions.setDependentFields(worksNew, worksOld);                   
                } else if (Trigger.isInsert) {
                    //Default select include in prioritizer for insert 
                    for(ADM_Work__c newWorkBeforeInsert : Trigger.new) {
                        newWorkBeforeInsert.Use_Prioritizer__c = true;
                    }
                    
                    //if record is being created with a resolved or closed status then set dependent fields accordingly
                    ADM_WorkFixedAndClosedActions.setDependentFields(worksNew);
                }
            } catch(System.Exception e ){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'ADM_WorkFixedAndClosedActions.setDependentFields(). Line:' + e.getLineNumber() + ' Trigger.isUpdate:' + Trigger.isUpdate + ' Trigger.isInsert:' + Trigger.isInsert + ' WorksNew:' + worksNew + ' WorksOld:' + worksOld);
            }
          

            try {     
               if(Trigger.isUpdate) {
                    ADM_BeforeInsertOrUpdate.clearPerforceStatusOnChanges(worksNew, worksOld);
                }
            } catch(System.Exception e){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'ADM_BeforeInsertOrUpdate..clearPerforceStatusOnChanges(). WorksNew:' + worksNew + ' WorksOld:' + worksOld);
            }  
              
             try {
                //bulk lookup product tags because fields such as work.Product_Tag__r.Team__c are not populated in this scope
                List<Id> tagIds = new List<Id>();
                for( ADM_Work__c work : worksNew ){
                    tagIds.add(work.Product_Tag__c);
                }
                Map<Id,ADM_Product_Tag__c> tagsById = new Map<Id,ADM_Product_Tag__c>([select id, Name, Team__c, Team__r.Capex_Enabled__c from ADM_Product_Tag__c where id in:tagIds]);
                
                //maintain custom time stamp values for creation date for backwards compatibility with old bug records 
                for( ADM_Work__c work : worksNew ){                                    
                    ADM_WorkObject.setCreatedImportValues( work, trigger.isInsert );
                    
                    //set type__c for User Stories, Todos and Investigations
                    String recordTypeName = null;
                    if (workRecordTypesById.get( work.RecordTypeId ) != null )
                      recordTypeName = workRecordTypesById.get( work.RecordTypeId ).Name;
                    if ( recordTypeName == ADM_Work.RECORD_TYPE_NAME_USERSTORY ||
                       recordTypeName == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION ||
                       recordTypeName == ADM_Work.RECORD_TYPE_NAME_TODO )
                      work.Type__c = recordTypeName;
                      
                    //enforce that Work.Team always equals Tag.Team
                    if(tagsById != null && tagsById.containsKey(work.Product_Tag__c) && recordTypeName != ADM_Work.RECORD_TYPE_NAME_TODO) {
                        work.Scrum_Team__c = tagsById.get(work.Product_Tag__c).Team__c;  
                    } 
                    
                    try { 
                         if(Trigger.isUpdate){
                            ADM_Work__c oldWork = Trigger.oldMap.get(work.Id); 
                            if(work.Scrum_Team__c != oldWork.Scrum_Team__c) {
                                work.Column__c = null;
                                work.Column_Rank__c = null;
                        work.Color__c = null; 
                            }
                        }
                    } catch(Exception e) {
                        ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception during changing teams and resetting column rank and column id to null');
                    }

                    try {
                        if(Trigger.isUpdate){
                            ADM_Work__c oldWork = Trigger.oldMap.get(work.Id);
                            if(work.Type__c == 'Non Deterministic Test' && oldWork.Type__c != 'Non Deterministic Test'){ 
                                work.addError('Cannot change Type to Non Deterministic Test from another value.');
                            }

                            if(oldWork.Type__c == 'Non Deterministic Test' && work.Type__c != 'Non Deterministic Test') {
                                work.addError('Cannot change Type from Non Deterministic Test to another value.');
                            }

                        }
                    }
                    catch(Exception e){
                        ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception while changing Type from or to Non Deterministic Test.');
                    }


                     if(Trigger.isInsert){
                        ADM_Product_Tag__c pTag = tagsById.get(work.Product_Tag__c);
                        if(pTag.Team__r.Capex_Enabled__c == true){
                            if(recordTypeName == ADM_Work.RECORD_TYPE_NAME_USERSTORY &&
                                       ADM_WorkTriggerStaticDataStore.requestOrigin != null &&
                                       !ADM_WorkUtils.isOriginatingFromEditPage(ADM_WorkTriggerStaticDataStore.requestOrigin)
                                       && !ADM_WorkTriggerStaticDataStore.requestOrigin.equalsIgnoreCase(ADM_WorkTriggerStaticDataStore.LIGHTNING_EXPERIENCE_WORK_ORIGIN)){
                                work.Capex_Enabled__c = true;
                            }

                        }
                     }

                     if(Trigger.isUpdate){
                        ADM_Product_Tag__c pTag = tagsById.get(work.Product_Tag__c);
                        ADM_Work__c oldWork = Trigger.oldMap.get(work.Id);
                        Boolean teamChanged = work.Scrum_Team__c != oldWork.Scrum_Team__c;

                        if(pTag.Team__r.Capex_Enabled__c == true){
                            /* Even if capex is enabled before setting capex to true on user story make sure Team change happened
                            Eg: An eligible team trying to bulk update a bunch of user stories*/
                            if(teamChanged && recordTypeName == ADM_Work.RECORD_TYPE_NAME_USERSTORY &&
                                       ADM_WorkTriggerStaticDataStore.requestOrigin != null &&
                                       !ADM_WorkUtils.isOriginatingFromEditPage(ADM_WorkTriggerStaticDataStore.requestOrigin)
                                       && !ADM_WorkTriggerStaticDataStore.requestOrigin.equalsIgnoreCase(ADM_WorkTriggerStaticDataStore.LIGHTNING_EXPERIENCE_WORK_ORIGIN)){
                                work.Capex_Enabled__c = true;
                            }
                  
                        } else{
                            if (teamChanged) {
                                work.Capex_Enabled__c = false;
                            } else if(work.Capex_Enabled__c == true) {
                               work.addError('New Customer Facing Feature field should be set to false for Non-Capitalizable Team');
                           }
                       }
                     }
                }
                    
            } catch(System.Exception e ){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'ADM_WorkObject.setCreatedImportValues(). WorksNew:' + worksNew);
            }  

            try {
                // this method is used to apply the assignment rules
                // check the work record to see if it needs to have the assignment rules applied
                (new ADM_AutoAssignWorkAction.Builder())
                    .withRecordTypes(workRecordTypesById)
                    .buildFor(worksNew)
                    .applyAssignmentRules(worksNew); //consuming 4000 script statements with batch size of 190             
           } catch(System.Exception e ){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'ADM_AutoAssignWorkAction.applyAutoAssignmentRules(). Error Line Number:' + e.getLineNumber() + ' WorksNew:' + worksNew);
            }
            
            
            ////// GUS SLA MONITORING - IS BEFORE - BEGIN //////
        	        
            // If record is an Investigation, udpate the SLA Due Time field if needed
            // This needs to fire *after* Assignment Rules have been applied
        
        	try {
                if (Trigger.isUpdate) {
                    ADM_WorkSLAMonitoringHelper.applyInvestigationSLAs(worksNew, Trigger.oldMap);
                } else if (Trigger.isInsert) {
                    ADM_WorkSLAMonitoringHelper.applyInvestigationSLAs(worksNew);
                }
            } catch(System.Exception e ){
                //log the error
                System.debug('Exception in ADM_WorkSLAMonitoringHelper.applyInvestigationSLAs() : ['+e+']');
                ADM_ExceptionHandler.saveException(e, 'ADM_WorkSLAMonitoringHelper.applyInvestigationSLAs(). Line:' + e.getLineNumber() + ' Trigger.isUpdate:' + Trigger.isUpdate + ' Trigger.isInsert:' + Trigger.isInsert + ' WorksNew:' + worksNew + ' WorksOld:' + worksOld);
            }
            ////// GUS SLA MONITORING  - IS BEFORE - END //////
            
            
            try {  
                //validate each work object - any errors are attached to the record and will cause the trigger to abort
                if(!Userinfo.getUserName().toLowerCase().contains('email2')) ADM_Validate.validateWork(worksNew, worksOld, Trigger.isInsert, workRecordTypesById); //consuming about 3000 script statements with batch size of 190               
            } catch(System.Exception e ){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'ADM_Validate.validateWork(). WorksNew:' + worksNew);
            }     
                
            try {    
                /* This method handles fields which need to be reset to null after they have been processed.  
                    For example work.Description__c field which holds a comment should not persist to the database once the comment
                    has been processed.
                                
                    It has to be fired from the trigger (not just the controller) to handle edits originating from list view inline edit
                */  
                ADM_CreateCommentAction.beforeInsertOrUpdate(worksNew);             
                
            } catch(System.Exception e ){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'ADM_CreateCommentAction.beforeInsertOrUpdate(). WorksNew:' + worksNew);
            } 
                
            try {
                ADM_WorkUtils.trackFieldChanges(worksNew, worksOld);
                
            } catch(System.Exception e ){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'ADM_WorkUtils.trackFieldChanges(). WorksNew:' + worksNew);
            }   
            
            //due to a limitation in the Streaming API, we need to track when the work record gets moved from one sprint to another
            try {
                List<ADM_Work_History__c> newWorkHistoryList = new List<ADM_Work_History__c>(); 
                for(ADM_Work__c newWork : worksNew) {
                    ADM_Work__c oldWork = null;
                    if(Trigger.oldMap != null) oldWork = Trigger.oldMap.get(newWork.Id);
                    Id oldSprint = (oldWork == null)? null : oldWork.Sprint__c;
                    
                    if(newWork.Sprint__c != oldSprint) {
                        ADM_Work_History__c workHistory = new ADM_Work_History__c();
                        workHistory.Work__c = newWork.Id;
                        workHistory.Sprint__c = newWork.Sprint__c;
                        workHistory.Sprint_Old__c = oldSprint;
                        newWorkHistoryList.add(workHistory);
                    }

                    

                }
                insert newWorkHistoryList;
            } catch(System.Exception e) {
                ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception on Line: ' + e.getLineNumber() + ' Unable to update Work History. WorksNew:' + worksNew);
            }

    } else if( Trigger.isAfter ) {
               
            try { 

                List<String> sprintIdsForNewIdealBurndown = new List<String>();
                for(ADM_Work__c newWork : worksNew) {
                  ADM_Work__c oldWork = null;
                  if(Trigger.oldMap != null) oldWork = Trigger.oldMap.get(newWork.Id);
                  Id oldSprint = (oldWork == null)? null : oldWork.Sprint__c;
                  Decimal oldStoryPoint = (oldWork ==null)?null:oldWork.Story_Points__c;
                  if(newWork.Sprint__c != oldSprint || newWork.Story_Points__c != oldStoryPoint){
                        if(null != newWork.Sprint__c){
                          sprintIdsForNewIdealBurndown.add(newWork.Sprint__c);
                        }
                        if(null != oldSprint){
                          sprintIdsForNewIdealBurndown.add(oldSprint);
                        }

                  }
                }
                if(sprintIdsForNewIdealBurndown.size() > 0){
                  new ADM_SprintBurnDownUtils().createSprintBurnDownIdeal(sprintIdsForNewIdealBurndown);
                }
                
                if(Trigger.isUpdate){ //Not needed for insertion
                    ADM_WorkUtils.removeChangedUsersFromWorkEntitySubscription(worksNew, Trigger.oldMap);
                }

                ADM_WorkUtils.processWorkSubscribers(worksNew, Trigger.isInsert, ADM_WorkTriggerStaticDataStore.requestOrigin);
                //Add entity subscribers for Work
                ADM_WorkUtils.addEntitySubscribersForWork(Trigger.newMap, Trigger.isInsert); 
                
                ADM_WorkUtils.processNotifications(worksNew, worksOld, Trigger.isInsert, Trigger.isUpdate, ADM_WorkTriggerStaticDataStore.requestOrigin); //consuming 18000 script statements with batch size of 190
                
            } catch(System.Exception e ){
                //log the error
                System.debug('WorkTrigger() processNotifications Comment Tracking UserInfo.getUserID():' + UserInfo.getUserId() + ' Line:' + e.getLineNumber() + ' e:' + e);  
        
                ADM_ExceptionHandler.saveException(e, 'ADM_WorkUtils.processNotifications(). Line:' + e.getLineNumber() + ' WorksNew:' + worksNew);
                //throw the exception rather then swallowing it to preserve the users comment in the browser in the event of an unrecoverable error
                throw e;
            } 
                
            
            try {
                //check if work item has had any relations specified and if so create           
                ADM_ParentWork.evaluateWorkRelationships(worksNew);
            } catch(System.Exception e ){
                //log the error but no need to store in ADM_Exception as there are a lot of legitmate user validation exceptions.  These are added via the TriggerRecord.addError() which the platform is treating as exceptions 
                System.debug('WorkTrigger() evaluateWorkRelationships Comment Tracking UserInfo.getUserID():' + UserInfo.getUserId() + ' Line:' + e.getLineNumber() + ' e:' + e );  
                
            }       
            System.debug('Script Statements Inside Work Trigger Used: post ADM_ParentWork.evaluateWorkRelationships - ' + Limits.getScriptStatements() + ' Allowed:' + Limits.getLimitScriptStatements());
            
           
            try {           
                //logic for user stories ported from SCRUMFORCE
                if(Trigger.isUpdate) {
                    Set<Id> sprintsToUpdate = new Set<Id>(); 
                    for(Id id:Trigger.oldMap.keySet()) {
                        if ( Trigger.newMap.get(id).Sprint__c != null ) sprintsToUpdate.add( Trigger.newMap.get(id).Sprint__c );
                        if ( Trigger.oldMap.get(id).Sprint__c != null ) sprintsToUpdate.add( Trigger.oldMap.get(id).Sprint__c );
                    }
                    //REMOVED 1 SOQL query 
                    if(sprintstoUpdate.size() > 0) ADM_SprintBurnDownUtils.recalculateBurndown(ADM_SprintBurnDownUtils.getSprintsForIds(sprintsToUpdate));
                }
                
                ADM_SprintBurnDownUtils.calculateVelocity(worksNew, worksOld);
            } catch(System.Exception e ){
                //log the error
                ADM_ExceptionHandler.saveException(e, 'Exception while Calculating Velocity. WorksNew:' + worksNew);
                
            }

            // Look for closed Investgations and close any associated Exception Requests
            try {
                List<Id> workIdsThatNeedsColumnChange = new List<Id>();
                Set<String> workTeamIds = new Set<String>();
                if (Trigger.isUpdate) {
                    List<ADM_Work__c> workThatNeedsUpdating = new List<ADM_Work__c>();


                        for (ADM_Work__c work : worksNew) {
                            ADM_Work__c previousWork = Trigger.oldMap.get(work.Id);
                            String recordTypeName = workRecordTypesById.get( work.RecordTypeId ).Name;
                            if ( recordTypeName == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION &&
                                work.Closed__c == 1 && previousWork.Closed__c != 1 ) {
                                workThatNeedsUpdating.add(work);
                            }
                            //we only need to update the column when the status was changed but the column ID was not
                            if(work.Status__c != previousWork.Status__c && work.Column__c == previousWork.column__c && work.Scrum_Team__c != null) {
                                workIdsThatNeedsColumnChange.add(work.Id);
                                workTeamIds.add(work.Scrum_Team__c);
                                
                            }
                        }
                        // Bulk update the associated Exception Requests
                        if (workThatNeedsUpdating.size() > 0) {
                            ADM_InvestigationExceptionHelper.closeAssociatedExceptionRequests(workThatNeedsUpdating);
                        }

                }
                if(Trigger.isInsert){
                  System.debug( ' is insert ');
                  for (ADM_Work__c work : worksNew) {
                    System.debug( ' workIdsThatNeedsColumnChange ' + work.Id);
                    System.debug( ' workTeamIds ' + work.Scrum_Team__c);
                    workIdsThatNeedsColumnChange.add(work.Id);
                    workTeamIds.add(work.Scrum_Team__c);
                  }
                }

                        /*
                            The below condition is going to cause confusion if you look closer. We are going against conventional way of using future/async method for batch and 
                            synchoronous method for single records. The reason why future method is not used if number of records are more than 1 is -  when the code progress 
                            this update will in turn trigger an email alert for assignees which is done using future method (ADM_WorkUtils.processChangeListAsync) for processing notification and if this is happening from 
                            updateWorkWithColumnsAsync Future method then apex will throw an error saying a future method cannot be called from a future method, to avoid that we
                            make column update using non-future method if batch size is more than 1.

                            Future method which will be called down the line is 
                        */
                        if(workIdsThatNeedsColumnChange.size() == 1){
                            ADM_KanbanUtility.updateWorkWithColumnsAsync(workIdsThatNeedsColumnChange, workTeamIds);
                        }
                        else if(workIdsThatNeedsColumnChange.size() > 1){
                            ADM_KanbanUtility.updateWorkWithColumnsSync(workIdsThatNeedsColumnChange, workTeamIds);
                        }
            } catch (System.Exception e) {
                // Log the error
                ADM_ExceptionHandler.saveException(e, 'Exception while closing associated exception requests');
            }

            try { /*

                    Only do this on After Insert/Update
                */
                if(Trigger.isUpdate || Trigger.isInsert){
                    for (ADM_Work__c work : worksNew) {
                        //if work changes columns or new work inserted in the Kanban board we update and insert in column history table.
                        if((Trigger.isInsert && work.column__c != null)|| (Trigger.isUpdate && work.Column__c != Trigger.oldMap.get(work.Id).Column__c)) {
                            //Update record for old column and insert a new record for the new column.
                            workItemsThatNeedToUpdateAndInsertColumnHistory.add(work);
                        }
                    }
                }
            } catch(Exception e) {
                ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception while inserting or upserting Work Column History');
            }


            if(workItemsThatNeedToUpdateAndInsertColumnHistory != null && workItemsThatNeedToUpdateAndInsertColumnHistory.size() >0 ){
                ADM_ColumnHistory.upsertColumnHistoryRecordsForColumnChange(workItemsThatNeedToUpdateAndInsertColumnHistory);
            }

        	////// GUS SLA MONITORING - IS AFTER - BEGIN//////
	        if (Trigger.isUpdate) {
                try {
                    ADM_WorkSLAMonitoringHelper.commitSLAViolationChanges();
                    
                } catch(System.Exception e ){
                    //log the error
                    System.debug('Exception in ADM_WorkSLAMonitoringHelper.commitSLAViolationChanges() : ['+e+']');
                    ADM_ExceptionHandler.saveException(e, 'ADM_WorkSLAMonitoringHelper.applyInvestigationSLAs(). Line:' + e.getLineNumber() + ' Trigger.isUpdate:' + Trigger.isUpdate + ' Trigger.isInsert:' + Trigger.isInsert + ' WorksNew:' + worksNew + ' WorksOld:' + worksOld);
                }
            }
            ////// GUS SLA MONITORING - IS AFTER - END //////
            
            ////// Exact Target - Update check //////
            if (Trigger.isUpdate) {

                // Build ID list for records where Perforce Status changed
                List<Id> workIdsToProcess = new List<Id>();
                for ( Integer i = 0 ; i < worksNew.size() ; i++ ){
                    if (  worksNew[i].Perforce_Status__c != worksOld[i].Perforce_Status__c  ){
                        workIdsToProcess.add(worksNew[i].Id);
                    }
                }

                //Process Ids if the list exists
                if ( workIdsToProcess.size() > 0 ){
                    try {
                        ADM_AfterInsertOrUpdate.updateStatusHistoryTableIfNeeded(workIdsToProcess);
                    } catch(System.Exception e){
                        //log the error
                        ADM_ExceptionHandler.saveException(e, 'ADM_AfterInsertOrUpdate.updateStatusHistoryTableIfNeeded(). WorksNew:' + worksNew + ' WorksOld:' + worksOld );
                    }
                }

                ////// Exact Target - Update check //////
            }
        // Look for closed work and close any associated tasks
        if (Trigger.isUpdate) {
            try {
                Map<Id,ADM_UserStoryAndTaskWrapper> workAndTasks = new Map<Id,ADM_UserStoryAndTaskWrapper>();
                List<ADM_Task__c> tasksToUpdate = new List<ADM_Task__c>();
                Set<Id> workIds = (new Map<Id,SObject>(worksNew)).keySet();
                ADM_Work__c[] works = ADM_Work.getAllById(new List<Id>(workIds));

                for(ADM_Work__c work : works) {
                    ADM_UserStoryAndTaskWrapper workWrapper = new ADM_UserStoryAndTaskWrapper(work, work.RecordType);

                    workAndTasks.put(work.Id, workWrapper);
                }

                for(ADM_Work__c work : worksNew) {
                    if (work.Id != null) {
                        ADM_UserStoryAndTaskWrapper workWithTasks = workAndTasks.get(work.Id);

                        if (workWithTasks != null) {
                            List<ADM_Task__c> openTasks = new List<ADM_Task__c>(workWithTasks.getPlannedTasks());
                            openTasks.addAll(workWithTasks.getInProgressTasks());

                            if(work.Status__c == ADM_Work.WORK_STATUS_CLOSED && openTasks.size() > 0) {
                                for(ADM_Task__c task : openTasks) {
                                    if (task.Status__c != ADM_Task.TASK_STATUS_COMPLETED) {
                                        task.Status__c = ADM_Task.TASK_STATUS_COMPLETED;

                                        tasksToUpdate.add(task);
                                    }
                                }
                            }
                        }
                    }
                }

                if (tasksToUpdate.size() > 0) {
                    update tasksToUpdate;
                }
            } catch(Exception e) {
                ADM_ExceptionHandler.saveException(e, 'WorkTrigger Exception while closing tasks on closed work items.');
            }
        }
    }
}