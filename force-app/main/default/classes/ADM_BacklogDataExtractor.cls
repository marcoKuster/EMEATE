public with sharing class ADM_BacklogDataExtractor {
    public ADM_BacklogDataExtractor() {

    }

    static Set<String> recordTypeIds = new Set<String>();
    static Set<String> epicIds = new Set<String>();
    static Set<String> buildIds = new Set<String>();
    static Set<String> assigneeUserIds = new Set<String>();
    static Set<String> qeUserIds = new Set<String>();
    static Set<String> poUserIds = new Set<String>();
    static Set<String> sprintIds = new Set<String>();

    public static ADM_BacklogController.BackLogManagerResponse extractAndSortData(ADM_BacklogController.BackLogManagerResponse response){
        if(response != null && response.records != null &&  response.records.size() > 0){
            for(ADM_Work__c workRecord : response.records){

            /* Extracting Record Types - Start*/
                if(!recordTypeIds.contains(workRecord.RecordTypeId)){

                    recordTypeIds.add(workRecord.RecordTypeId);
                    RecordType rType = new RecordType();
                    rType.Name = workRecord.RecordType.Name;
                    rType.Id = workRecord.RecordTypeId;
                    if(response.allRecordTypes == null){
                      response.allRecordTypes = new List<RecordType>();
                    }
                    response.allRecordTypes.add(rType);
                }
           /* Extracting Record Types - End*/

           /* Extracting Epics - Start*/
                if(workRecord.Epic__c != null && !epicIds.contains(workRecord.Epic__c)){
                    epicIds.add(workRecord.Epic__c);
                    ADM_Epic__c epic = new ADM_Epic__c();
                    epic.Name = workRecord.Epic__r.Name;
                    epic.Id = workRecord.Epic__c;
                    if(response.allEpics == null){
                      response.allEpics = new List<ADM_Epic__c>();
                    }
                    response.allEpics.add(epic);
                }
           /* Extracting Epics - End*/

           /* Extracting Builds(Found_in_Build__c) - Start*/
                if(workRecord.Found_in_Build__c != null && !buildIds.contains(workRecord.Found_in_Build__c)){
                    buildIds.add(workRecord.Found_in_Build__c);
                    ADM_Build__c build = new ADM_Build__c();
                    build.Name = workRecord.Found_in_Build__r.Name;
                    build.Id = workRecord.Found_in_Build__c;
                    if(response.allBuilds == null){
                      response.allBuilds = new List<ADM_Build__c>();
                    }
                    response.allBuilds.add(build);
                }
           /* Extracting Builds - End*/

           /* Extracting Builds(Scheduled_Build__c) - Start*/
                if(workRecord.Scheduled_Build__c != null && !buildIds.contains(workRecord.Scheduled_Build__c)){
                    buildIds.add(workRecord.Scheduled_Build__c);
                    ADM_Build__c build = new ADM_Build__c();
                    build.Name = workRecord.Scheduled_Build__r.Name;
                    build.Id = workRecord.Scheduled_Build__c;
                    if(response.allBuilds == null){
                      response.allBuilds = new List<ADM_Build__c>();
                    }
                    response.allBuilds.add(build);
                }
           /* Extracting Builds - End*/

           /* Extracting Users(Assignees) - Start*/
                if(workRecord.Assignee__c != null && !assigneeUserIds.contains(workRecord.Assignee__c)){
                    assigneeUserIds.add(workRecord.Assignee__c);
                    ADM_BacklogController.UserRecord user = new ADM_BacklogController.UserRecord();
                    user.Name = workRecord.Assignee__r.Name;
                    user.Id = workRecord.Assignee__c;
                    user.SmallPhotoUrl = workRecord.Assignee__r.SmallPhotoUrl;
                    user.UserName = workRecord.Assignee__r.UserName;
                    if(response.allAssignees == null){
                      response.allAssignees = new List<ADM_BacklogController.UserRecord>();
                    }
                    response.allAssignees.add(user);
                }
           /* Extracting Users - End*/



           /* Extracting Users(QEs) - Start*/
                if(workRecord.QA_Engineer__c != null && !qeUserIds.contains(workRecord.QA_Engineer__c)){
                    qeUserIds.add(workRecord.QA_Engineer__c);
                    ADM_BacklogController.UserRecord user = new ADM_BacklogController.UserRecord();
                    user.Name = workRecord.QA_Engineer__r.Name;
                    user.Id = workRecord.QA_Engineer__c;
                    user.SmallPhotoUrl = workRecord.QA_Engineer__r.SmallPhotoUrl;
                    user.UserName = workRecord.QA_Engineer__r.UserName;
                    if(response.allQAEngineers == null){
                      response.allQAEngineers = new List<ADM_BacklogController.UserRecord>();
                    }
                    response.allQAEngineers.add(user);
                }
           /* Extracting Users - End*/

           /* Extracting Users(POs) - Start*/
                if(workRecord.Product_Owner__c != null && !poUserIds.contains(workRecord.Product_Owner__c)){
                    poUserIds.add(workRecord.Product_Owner__c);
                    ADM_BacklogController.UserRecord user = new ADM_BacklogController.UserRecord();
                    user.Name = workRecord.Product_Owner__r.Name;
                    user.Id = workRecord.Product_Owner__c;
                    user.SmallPhotoUrl = workRecord.Product_Owner__r.SmallPhotoUrl;
                    user.UserName = workRecord.Product_Owner__r.UserName;
                    if(response.allProductOwners == null){
                      response.allProductOwners = new List<ADM_BacklogController.UserRecord>();
                    }
                    response.allProductOwners.add(user);
                }
           /* Extracting Users - End*/

           /* Extracting Sprint - Start*/
                if(workRecord.Sprint__c != null && !sprintIds.contains(workRecord.Sprint__c)){
                    sprintIds.add(workRecord.Sprint__c);
                    ADM_Sprint__c sprint = new ADM_Sprint__c();
                    sprint.Name = workRecord.Sprint__r.Name;
                    sprint.Id = workRecord.Sprint__c;
                    if(response.allSprints == null){
                      response.allSprints = new List<ADM_Sprint__c>();
                    }
                    response.allSprints.add(sprint);
                }
           /* Extracting Sprint - End*/

            }

      }
      if(response.allRecordTypes != null){
        response.allRecordTypes.sort();
      }
      if(response.allEpics != null){
        response.allEpics.sort();
      }
      if(response.allBuilds != null){
        response.allBuilds.sort();
      }
      if(response.allAssignees != null){
        response.allAssignees.sort();
      }
      if(response.allQAEngineers != null){
        response.allQAEngineers.sort();
      }
      if(response.allProductOwners != null){
        response.allProductOwners.sort();
      }
      if(response.allSprints != null){
        response.allSprints.sort();
      }
        
       
            
        return response;
    }
}