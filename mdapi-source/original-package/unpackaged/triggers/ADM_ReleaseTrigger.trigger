/*
* Copyright, 2008, SALESFORCE.com
* All Rights Reserved
* Company Confidential
*
* Verifies no Released In objects exist prior to deleting a Release and no duplicate release names are created
*/

/*
 * Support for Release Event Templates
 *  
 *    @userstory W-2076536 https://gus.my.salesforce.com/a07B0000000dKy6 
 *    @author: snahm
 *
 * If the Release's Application has Release Event Template records, this trigger will manage the creation and updating of
 * Release Event records based on those Templates.
 * 1: When the Release record is created, create Event Template records with Event Status == Preview
 * 2: When the record is updated, update the associated Release Event records to reflect any change in:
 *      Release Name, Scheduled Date, Instances, Release Manager
 * 3: When the record is deleted, Release Events are automatically deleted as they have a master-detail relationship to Release
 */

trigger ADM_ReleaseTrigger on ADM_Release__c (before insert, before update, before delete, after insert, after update) {

    //don't want trigger to run for API calls from the sync process
    if( UserInfo.getUserName().contains('p4') || UserInfo.getUserName().contains('Perforce')){
        return;
    }

    if(Trigger.isDelete) {
        ADM_Release__c[] releases = Trigger.old;
        if( Trigger.isBefore ) {
             //for each Release check that no Released_In objects exist
             for(ADM_Release__c release: releases) {
                if (release.Number_of_Stamps__c > 0) {
                    release.addError('Error: Please remove all related Released In records before deleting this release.');
                }
             }
        }
    } else {
        //for inserts and update check name is unique
        List<ADM_Release__c> releases = Trigger.new;
        Map<Id, ADM_Release__c> releasesOld = new Map<Id, ADM_Release__c>();

        if(Trigger.old != null) {
          for(ADM_Release__c original : Trigger.old) {
            releasesOld.put(original.Id, original);
          }
        }        

        if (Trigger.isBefore) {

            for(ADM_Release__c release : releases) {
                String releaseNameNoPunc = ADM_DuplicateValidator.removeAllPunctuationAndWhitespace(release.Name);
                release.External_ID__c = release.Name;
                release.Duplicate_Validator__c = releaseNameNoPunc;
                ADM_Release__c releaseOld = releasesOld.get(release.Id);    // Will be null if this is an Insert 
                /* DEBUG OFF    System.debug('ADM_ReleaseTrigger: before date processing Release is ' + release + ' releaseOld is ' + releaseOld);  /* DEBUG */
                /*
                 * Update the Duration and/or End date fields
                 */           
                 if (release.Release_Date__c != null) {
                    release.Scheduled_End_Date__c = ADM_Release.setEndDateWithPrior(release, releaseOld);
                    // Always set Duration from End Date
                    if (release.Scheduled_End_Date__c == null) {
                        release.Planned_Duration__c = null;
                    } else {
                        release.Planned_Duration__c = ADM_Release.setDurationByEndDate(release.Release_Date__c, release.Scheduled_End_Date__c);
                    }
                 } else {   // No Release Date set
                    // clear out fields that are no longer valid
                    release.Scheduled_End_Date__c = null;
                    release.Planned_Duration__c = null;
                 }
                 
                 /* DEBUG OFF   System.debug('ADM_ReleaseTrigger: after date processing Release is ' + release);    /* DEBUG */
            }
        } else {

            Set<Id> releaseIds = new Set<Id>();
            Set<Id> appIds = new Set<ID>();         // Set of all Application Ids related to our Releases
                        
            for (ADM_Release__c r : releases) {
                releaseIds.add(r.Id);
                // Get Ids of the Application objects that are associated with our Releases         
                if (r.Application__c != null) {
                    appIds.add(r.Application__c);
                }               
            }
            if (Trigger.oldMap != null) {
                for (ADM_Release__c rOld : Trigger.old) {
                    releaseIds.add(rOld.Id);
                    if (rOld.Application__c != null) {
                        appIds.add(rOld.Application__c);
                    }
                }
            }
            /* DEBUG OFF System.debug('ADM_ReleaseTrigger: Applications Ids: ' + appIds);    /* DEBUG */
            // Get the Release Event Templates
            List<ADM_Release_Event_Template__c> retList;
            try {
                retList = [select Name, Release_Type__c, Application__c, Notify_Customers__c, 
                    Day_Offset__c, Start_Time__c, Hour_Offset__c, Minute_Offset__c, Event_Duration__c, Event_Template_Name__c, Instance_Key__c
                    from ADM_Release_Event_Template__c where Application__c =: appIds];
            } catch (Exception e) {
                System.debug('ADM_ReleaseTrigger: Unexpected exception looking up Release Event Templates:' + e + ' Line:' + e.getLineNumber());                
            }
            /* DEBUG OFF 
            {
                Integer i = 0;
                for (ADM_Release_Event_Template__c ret : retList) {
                	System.debug('ADM_ReleaseTrigger: Retrieved Release Event Template[' + i++ + ']=' + ret);
                }
            }
            /* DEBUG */          
            // Build a map of Application Ids to Release Event Template lists
            Map </*Application__c*/ Id, List<ADM_Release_Event_Template__c>> appRETListMap = new Map <Id, List<ADM_Release_Event_Template__c>>();
            for (ADM_Release_Event_Template__c ret : retList) {
                List<ADM_Release_Event_Template__c> mapList = appRETListMap.get(ret.Application__c);
                if (mapList == null) {
                    mapList = new List<ADM_Release_Event_Template__c>();
                }
                mapList.add(ret);
                appRETListMap.put(ret.Application__c, mapList);
            }

	        /*
	         * If the Release has the Scheduled Release Date set and the Application set and has Release Event Templates defined,
	         * then the Scheduled End Date must be set.
	         */
			for (ADM_Release__c r : releases) {
				if (r.Release_Date__c != null && r.Application__c != null && r.Scheduled_End_Date__c == null && !appRETListMap.isEmpty()) {
					if (appRETListMap.containsKey(r.Application__c)) {
						r.addError(
						'Error: The Scheduled End Date must be set when a Scheduled Release Date is specified and the Application has Release Event Templates.');
					}
				}
			}

            List<ADM_Release_Event__c> releaseEventsToInsert = new List<ADM_Release_Event__c>();
            List<ADM_Release_Event__c> releaseEventsToDelete = new List<ADM_Release_Event__c>();
            List<ADM_Release_Event__c> releaseEventsToUpdate = new List<ADM_Release_Event__c>();
            List<ADM_Release_Event_Template__c> releaseEventTemplates;
            /*
             * For Update and Insert, need to run this After so that the event duration validation rule gets a
             * chance to run.
             */
            if (Trigger.isInsert) {          
                for (ADM_Release__c release : releases) {
                    releaseEventTemplates = appRETListMap.get(release.Application__c);
                    /* DEBUG OFF   System.Debug('ADM_ReleaseTrigger: [Insert] Release Event Templates for Release ' + release.Name + '=' + releaseEventTemplates); /* DEBUG */                   
                    List<ADM_Release_Event__c> generatedList = ADM_ReleaseEvent.releaseEventsFromReleaseEventTemplates(releaseEventTemplates, release);
                    if (generatedList.size() > 0) {
                        releaseEventsToInsert.addAll(generatedList);
                    }
                }
            } else {        // Update
                // Retrieve Release Events for our releases
                List<ADM_Release_Event__c> reList;
                try {
                    reList = [select Name, Application_Name__c, Event_Status__c, Customer_Facing_Name__c, Deployment_Instances__c, Event_Contact__c, 
                            Release__c, Release_Name__c, Scheduled_Start__c, Scheduled_End__c, Origination__c FROM ADM_Release_Event__c 
                           WHERE Release__c =:releaseIds];
                } catch (Exception e) {
                    System.debug('ADM_ReleaseTrigger: Unexpected exception looking up Release Events:' + e + ' Line:' + e.getLineNumber());             
                }
                /* DEBUG OFF    
                {
	                Integer i = 0;
	                for (ADM_Release_Event__c re : reList) {
	                	System.debug('ADM_ReleaseTrigger: Retrieved Release Event[' + i++ + ']=' + re);
	                }
                }
                /* DEBUG */
                // Build a map of Release Ids to Release Event lists
                Map </*ADM_Release__c*/ Id, List<ADM_Release_Event__c>> appREListMap = new Map <Id, List<ADM_Release_Event__c>>();
                for (ADM_Release_Event__c re : reList) {
                    List<ADM_Release_Event__c> mapList = appREListMap.get(re.Release__c);
                    if (mapList == null) {
                        mapList = new List<ADM_Release_Event__c>();
                    }
                    mapList.add(re);
                    appREListMap.put(re.Release__c, mapList);
                }
                /* DEBUG OFF    
                {
	                for (Id r : appREListMap.keySet()) {
	                	List<ADM_Release_Event__c> reL = appREListMap.get(r);
						if (reL != null) {
			                Integer i = 0;
			                for (ADM_Release_Event__c re : reL) {
			                	System.debug('ADM_ReleaseTrigger: Release Event[' + i++ + '] for Release ' + r + '=' + re);
			                }
						}
	                }
                }
                /* DEBUG */

                if (Trigger.isUpdate) {
                    /* 
                     * For certain updates, we will want to delete all Release Events and 
                     * create them fresh from the Release Event Templates.
                     * For other updates, we will want to update the Release Events with the new information.
                     *
                     * See ADM_ReleaseEvent.isRefreshReleaseUpdate() and ADM_ReleaseEvent.isUpdateReleaseUpdate()
                     * for details.
                     */
                    for (Integer i=0; i < releases.size(); i++) {
                        ADM_Release__c release = releases.get(i);
                        ADM_Release__c oldRelease = Trigger.old.get(i); 
    
                        List<ADM_Release_Event__c> releaseEvents = appREListMap.get(release.Id);
                        if (releaseEvents == null) {
                            System.debug('ADM_ReleaseTrigger: Did not find a Release Event during Update for Release:' + release);      
                        }
                        if (ADM_ReleaseEvent.isRefreshReleaseUpdate(release, oldRelease)) {
                            /* DEBUG OFF     System.debug('ADM_ReleaseTrigger: is REFRESH update. release=' + release); /* DEBUG */
                            releaseEventTemplates = appRETListMap.get(oldRelease.Application__c);
                            /* DEBUG OFF     System.debug('ADM_ReleaseTrigger: Release Event Templates for Application: ' + releaseEventTemplates); /* DEBUG */
                                                        
                            // Delete the old release events
                            if (releaseEvents != null && releaseEvents.size() > 0) {
                            	// Find the Release Events which were generated from Release Event Templates
                            	List<ADM_Release_Event__c> retEvents = ADM_ReleaseEvent.eventsGeneratedFromTemplates(releaseEvents, releaseEventTemplates, 
                            		oldRelease);
                                /* DEBUG OFF   System.Debug('ADM_ReleaseTrigger: release events being DELETED:' + retEvents); /* DEBUG */
                            	if (retEvents != null) {
                                	releaseEventsToDelete.addAll(retEvents);
                            	}
                            }
                            // Create new release events
                            releaseEventTemplates = appRETListMap.get(release.Application__c);
                            /* DEBUG OFF   System.Debug('ADM_ReleaseTrigger: [Update] Release Event Templates for Release ' + release.Name + '=' + releaseEventTemplates); /* DEBUG */
                            List<ADM_Release_Event__c> generatedList = ADM_ReleaseEvent.releaseEventsFromReleaseEventTemplates(releaseEventTemplates, release);
                            if (generatedList.size() > 0) {
                                releaseEventsToInsert.addAll(generatedList);
                            } 
                        } else if (ADM_ReleaseEvent.isUpdateReleaseUpdate(release, oldRelease)) {
                            /* DEBUG OFF     System.debug('ADM_ReleaseTrigger: is UPDATE update release=' + release); /* DEBUG */
                            // Make updates to the Release Events
                            if (releaseEvents == null) {		// Release Event was missing; create a new one
                                ADM_Release_Event__c rEvent = ADM_ReleaseEvent.setupReleaseEvent(release);
                                if (rEvent != null) {
                                    releaseEventsToInsert.add(rEvent);
                                }
                            } else {
                            	releaseEventsToUpdate.addAll(ADM_ReleaseEvent.updateReleaseEventsFromRelease(releaseEvents, release, oldRelease));
                            }
                        }                        
                    }
                }
            }
			/* DEBUG OFF    
			System.debug('ADM_ReleaseTrigger: releaseEventsToDelete - ' + releaseEventsToDelete);			
			System.debug('ADM_ReleaseTrigger: releaseEventsToUpdate - ' + releaseEventsToUpdate);
			System.debug('ADM_ReleaseTrigger: releaseEventsToInsert - ' + releaseEventsToInsert);
			/* DEBUG */	

            if (releaseEventsToDelete.size() > 0) {
            	try {
                	delete releaseEventsToDelete;
		    	} catch (Exception e) {
		    		System.debug('ADM_ApplicationTrigger: Deletion of Release Events failed in Release trigger. ' + 
		    			e + ' - ' + releaseEventsToDelete);
		    	}			
            }        
            if (releaseEventsToUpdate.size() > 0) {
            	try {
                	update releaseEventsToUpdate;
		    	} catch (Exception e) {
		    		System.debug('ADM_ApplicationTrigger: Update of Release Events failed in Release trigger. ' + 
		    			e + ' - ' + releaseEventsToUpdate);
		    	}			                	
            }
            if (releaseEventsToInsert.size() > 0) {
            	try {
                	insert releaseEventsToInsert;
		    	} catch (Exception e) {
		    		System.debug('ADM_ApplicationTrigger: Insertion of Release Events failed in Release trigger. ' + 
		    			e + ' - ' + releaseEventsToInsert);
		    	}			            	
            }                         
        } 
    }
}