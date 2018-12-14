trigger ADM_Case on ADM_Case__c (after insert, after update, after delete, after undelete) {
  
    /* This trigger calculates a roll up summary field (Work.Number_of_Cases__c) for Work records attached to the Cases in the batch.  Because the relationship between a Work Record and Case is a lookup
    field vs a master-detail a native Roll Up Summary field is not yet possible.  However it is on its way (https://success.salesforce.com/ideaView?id=08730000000BrqsAAC)
     at which point this code can be removed */
  
    List<ADM_Case__c> cases = null;
    //build list of workIDs referenced by this update
    List<String> workIDs = new List<String>();
    if(Trigger.isDelete) {
       //for delete only need to update prior work records these deleted cases reffered to
       for(ADM_Case__c aCase : Trigger.old) {
            if(aCase.Work__c != null) {
                workIDs.add(aCase.Work__c); 
            }               
       }         
    } else if(Trigger.isInsert) {
        //for inserts only need to update new work records
        for(ADM_Case__c aCase : Trigger.new) {
            if(aCase.Work__c != null) {
                workIDs.add(aCase.Work__c); 
            }               
        }
    } else if(Trigger.isUpdate) {
        //for updates need to update both the new references to Work and prior references.  
        for(ADM_Case__c aCase : Trigger.new) {
            if(aCase.Work__c != null) {
                workIDs.add(aCase.Work__c); 
            }               
        }
        for(ADM_Case__c aCase : Trigger.old) {
            if(aCase.Work__c != null) {
                workIDs.add(aCase.Work__c); 
            }               
        }
    } else if(Trigger.isUnDelete) {
        if(Trigger.new != null) {
            for(ADM_Case__c aCase : Trigger.new) {
                if(aCase.Work__c != null) {
                    workIDs.add(aCase.Work__c); 
                }               
            }
        }
        if(Trigger.old != null) {   
            for(ADM_Case__c aCase : Trigger.old) {
                if(aCase.Work__c != null) {
                    workIDs.add(aCase.Work__c); 
                }               
            }
        }   
    }
        
   //pull all the work objects in bulk that these cases relate to.  No need for limit clause as batches are already guarenteed to be chuncked in groups of 200 by trigger 
   List<ADM_Work__c> workWithCases = [select id, Name, Description__c, Number_of_Cases__c from ADM_Work__c where id in:workIDs];
  
   //Count the total # of case references per work object.  Handle in batches for performance and total partial counts in map.      
   Map<Id, List<ADM_Case__c>> workIDToCaseListMap = new Map<Id, List<ADM_Case__c>>(); 
   
   //intialize with zero counts for each work ID.  This is important to make sure the count is restored to 0 when a Case is deleted or a Work record moves between Cases
   for(Id id: workIDs) {
        workIDToCaseListMap.put(id, new List<ADM_Case__c>());
   }
        
   for(ADM_Case__c c : [select id, Work__c, Case_ID__c, Work__r.Description__c, Case_Subject__c, Account_Name__c, Parent_Account_Name__c, Case_Number__c  from ADM_Case__c where Work__c in :workIDs order by Work__c]) {
  
        if(workIDToCaseListMap.containsKey(c.Work__c)) {
            //add case to the existing entry
            List<ADM_Case__c> caseList = workIDToCaseListMap.get(c.Work__c);
            caseList.add(c);
            workIDToCaseListMap.put(c.Work__c, caseList);
        } 
   }
   
   //commit new case counts
   List<ADM_Work__c> workToBeUpdated = new List<ADM_Work__c>();
   for(ADM_Work__c work2: workWithCases) {
        if(workIDToCaseListMap.containsKey(work2.id)) {
          try {
              for(ADM_Case__c c : workIDToCaseListMap.get(work2.id)) { 
              //when the case is first inserted store a summary of the case as a comment on the work record.  This will trigger an email to the usual recipients
              if(Trigger.isInsert && Trigger.newMap.containsKey(c.id)) {
                //only store comment for new cases - list contains all cases asociated to the work record to get an accurate count (vs blindy incrementing the prior case count)
                if(work2.Description__c == null) {
                  work2.Description__c = ADM_Case.createCaseSummary(c);
                } else {
                  work2.Description__c = work2.Description__c  + '\n' + ADM_Case.createCaseSummary(c);
                } 
              }
            }
            //for inserts/updates/deletes store a fresh count - guarenteed to be accurate vs just adjusting the prior value             
              work2.Number_of_Cases__c = workIDToCaseListMap.get(work2.id).size();
              workToBeUpdated.add(work2);
          } catch(Exception e) {
            System.debug('ADM_Case.trigger() exception processing case count for work:' + work2.Id);
            throw e;
          }     
        }
   }
   
   //update work objects in bulk, but not make it all or nothing
   // Also parse any errors and record them in the GUS error log
   Database.SaveResult[] srList = Database.update(workToBeUpdated, false);
   List<Database.SaveResult> errorList = new List<Database.SaveResult>();
   
   ADM_ExceptionHandler.saveExceptions(errorList, null, 'Error while updating Work items associated with a Case', null,false);
  

}