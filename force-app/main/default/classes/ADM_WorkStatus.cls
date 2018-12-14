public class ADM_WorkStatus {

    private static Set<String> statusNotForMapping = new Set<String>{'New'};

    public static void createAllWorkStatuses() {
        try{
            //Check if the work status type field has already been populated and if so return.
            List<ADM_Work_Status__c> workStatusesWithtype = [Select id, Type__c from ADM_Work_Status__c where Type__c != null];
            if(workStatusesWithtype.size() > 0){
                return;
            }
            List<ADM_Work_Status__c> workStatusItems = new List<ADM_Work_Status__c>();
            ADM_Work_Status__c workStatus = new ADM_Work_Status__c(Name = 'New');
            workStatus.Type__c = 'Bug;User Story;Investigation';
            workStatus.Order__c = 10;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Triaged');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 20;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'In Progress');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 30;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Ready for Review');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 40;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Fixed');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 50;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'QA In Progress');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 60;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 70;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Waiting');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 80;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Integrate');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 90;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Pending Release');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 100;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Duplicate');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 110;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Never');
            workStatus.Type__c = 'Bug;User Story';
            workStatus.Order__c = 120;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Not Reproducible');
            workStatus.Type__c = 'Bug;';
            workStatus.Order__c = 130;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Not a bug');
            workStatus.Type__c = 'Bug;';
            workStatus.Order__c = 140;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Acknowledged');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 150;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Investigating');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 160;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - Defunct');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 170;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - Duplicate');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 180;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - Known Bug Exists');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 190;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - New Bug Logged');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 200;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - LAP Request Approved');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 210;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - LAP Request Denied');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 220;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - Resolved With Internal Tools');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 230;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name =  'Closed - Resolved Without Code Change');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 240;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - No Fix - Working as Designed');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 250;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - No Fix - Feature Request');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 260;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Closed - No Fix - Will Not Fix');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 270;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'More Info Reqd from Support');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 280;
            workStatusItems.add(workStatus);
            workStatus = new ADM_Work_Status__c(Name = 'Rejected');
            workStatus.Type__c = 'Investigation;';
            workStatus.Order__c = 290;
            workStatusItems.add(workStatus);

            insert workStatusItems;
        }
        catch(Exception e){
            System.debug('Exception while running the script : '+e);
        }
    }


     public static void createOrUpdateAllWorkStatusRecords(){
        try{
            //Check if the work status type field has already been populated and if so return.
            List<ADM_Work_Status__c> workStatusesWithtype = [Select id, Type__c from ADM_Work_Status__c where Type__c != null];
            if(workStatusesWithtype.size() > 0){
                return;
            }
            //Describe api to get all values of status picklist and add it to a list of string
            Schema.DescribeFieldResult fieldResult = ADM_Work__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
            List<SelectOption> priorityOptions = new List<SelectOption>();
            List<String> statuses = new List<String> ();
            for(Schema.Picklistentry pickListEntry : pickListEntries) {
                statuses.add(pickListEntry.getLabel());
            }
            //Create map of existing statuses - name with status object
            List<ADM_Work_Status__c> workStatusItems = [Select id, Name, Type__c, Order__c from ADM_Work_Status__c where Name != NULL order by Order__c];

            //create individual maps for Bug,User Story and Investigation statuses as status with string 
            Map<String,String> investigationStatus = new  Map<String,String>();
            Map<String,String> bugStatus = new  Map<String,String>();
            Map<String,String> userStoryStatus = new  Map<String,String>();

            for(String status : ADM_Work.STATUS_VALUES_BUG){
                bugStatus.put(status,'Bug;');
            }
            for(String status : ADM_Work.STATUS_VALUES_USERSTORY){
                userStoryStatus.put(status,'User Story;');
            }
            for(String status : ADM_Work.STATUS_VALUES_INVESTIGATION){
                investigationStatus.put(status,'Investigation;');
            }

            //Final map of all statuses with type they belong to
            Map<String,String> allStatuses = new  Map<String,String>();
            for(String st : statuses){
                
                if(bugStatus.get(st) != null){
                    if(allStatuses.get(st) != null){
                        allStatuses.put(st,allStatuses.get(st)+'Bug;');
                    }
                    else{
                        allStatuses.put(st,'Bug;');
                    }

                }
                if(userStoryStatus.get(st) != null){
                    if(allStatuses.get(st) != null){
                        allStatuses.put(st,allStatuses.get(st) +'User Story;');
                    }
                    else{
                        allStatuses.put(st,'User Story;');
                    }
                }
                if(investigationStatus.get(st) != null){
                    if(allStatuses.get(st) != null){
                        allStatuses.put(st,allStatuses.get(st)+'Investigation;');
                    }
                    else{
                        allStatuses.put(st,'Investigation;');
                    }
                }
            }
            //start ordering from last left for new statuses. For old ones order already exists.

            Integer lastElementIndex = 0;
            Integer order;
            //If there are no statuses we call the script to populate statuses for the sake of right order.
            if(workStatusItems.size() == 0){
                ADM_WorkStatus.createAllWorkStatuses();
            }
           
            Map<String,ADM_Work_Status__c> workStatusNameWithStatusObject = new Map<String,ADM_Work_Status__c>();
            //Again querying because now the statuses are populated
            workStatusItems = [Select id, Name, Type__c, Order__c from ADM_Work_Status__c where Name != NULL order by Order__c];
            lastElementIndex = workStatusItems.size() - 1;
            order = Integer.valueOf(workStatusItems.get(lastElementIndex).Order__c) + 10 ;
            for(ADM_Work_Status__c status : workStatusItems){
                workStatusNameWithStatusObject.put(status.Name,status);
            }

            //Create new status object and add to list, update old ones if needed ad upsert all.
            List<ADM_Work_Status__c> statusesToBeUpserted = new List<ADM_Work_Status__c>();
            for(String st : allStatuses.keySet()){
                if(workStatusNameWithStatusObject.get(st) == null){
                    ADM_Work_Status__c workStatus = new ADM_Work_Status__c(Name = st, Type__c = allStatuses.get(st), Order__c = order);
                    order+=10;
                    statusesToBeUpserted.add(workStatus);
                }
                else{
                    ADM_Work_Status__c existingStatus = workStatusNameWithStatusObject.get(st);
                    existingStatus.Type__c = allStatuses.get(st);
                    statusesToBeUpserted.add(existingStatus);
                }
            }

            upsert statusesToBeUpserted;
        }
        catch(Exception e){
            System.debug('Exception while creating Work Status records : '+e);
        }

    }


    public static void correctTheOrderingOfStatuses(){
        try{
            List<ADM_Work_Status__c> workStatusItems = [Select id, Name, Type__c, Order__c from ADM_Work_Status__c where Name != NULL order by Order__c];
            if(workStatusItems.size() == 0){
                return;
            }
            else{
                List<ADM_Work_Status__c> listToUpdate = new List<ADM_Work_Status__c>();
                for(ADM_Work_Status__c existingStatus : workStatusItems){
                    if(existingStatus.Name == 'New'){
                        existingStatus.Order__c = 10;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Triaged'){
                        existingStatus.Order__c = 20;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'In Progress'){
                        existingStatus.Order__c = 30;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Ready for Review'){
                        existingStatus.Order__c = 40;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Fixed'){
                        existingStatus.Order__c = 50;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'QA in Progress'){
                        existingStatus.Order__c = 60;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed'){
                        existingStatus.Order__c = 70;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Waiting'){
                        existingStatus.Order__c = 80;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Integrate'){
                        existingStatus.Order__c = 90;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name =='Pending Release'){
                        existingStatus.Order__c = 100;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Duplicate'){
                        existingStatus.Order__c = 110;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Never'){
                        existingStatus.Order__c = 120;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Not Reproducible'){
                        existingStatus.Order__c = 130;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Not a bug'){
                        existingStatus.Order__c = 140;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Acknowledged'){
                        existingStatus.Order__c = 150;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Investigating'){
                        existingStatus.Order__c = 160;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Defunct'){
                        existingStatus.Order__c = 170;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Duplicate'){
                        existingStatus.Order__c = 180;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Known Bug Exists'){
                        existingStatus.Order__c = 190;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - New Bug Logged'){
                        existingStatus.Order__c = 200;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - LAP Request Approved'){
                        existingStatus.Order__c = 210;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - LAP Request Denied'){
                        existingStatus.Order__c = 220;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Resolved With Internal Tools'){
                        existingStatus.Order__c = 230;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Resolved Without Code Change'){
                        existingStatus.Order__c = 240;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - No Fix - Working as Designed'){
                        existingStatus.Order__c = 250;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - No Fix - Feature Request'){
                        existingStatus.Order__c = 260;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - No Fix - Will Not Fix'){
                        existingStatus.Order__c = 270;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'More Info Reqd from Support'){
                        existingStatus.Order__c = 280;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Rejected'){
                        existingStatus.Order__c = 290;
                        listToUpdate.add(existingStatus);
                    }

                }

                update listToUpdate;
            }
        }
        catch(Exception e){
            System.debug('Exception while running the script : '+e);
        }

    }

     /**
    * Get all Work Statuses.
    */
    @RemoteAction
    public static List<ADM_Work_Status__c> getAllWorkStatusesByTypes(List<String> types) {
        String includeString = getIncludeTypeString(types);
        String soql = 'Select id, Name, Type__c from ADM_Work_Status__c where Type__c includes (' + includeString + ') order by Order__c';
        List<ADM_Work_Status__c> existingWorkStatuses = Database.query(soql);
        return existingWorkStatuses;
    }

     /**
    * Get all Work Status Names.
    */
  
    public static List<String> getAllWorkStatusNamesByTypes(List<String> types) {
        String includeString = getIncludeTypeString(types);
        List<String> workStatusNames = new List<String>();
        String soql = 'Select Name from ADM_Work_Status__c where Type__c includes (' + includeString + ') order by Order__c';
        List<ADM_Work_Status__c> existingWorkStatuses = Database.query(soql);
        for(ADM_Work_Status__c workStatus : existingWorkStatuses){
            workStatusNames.add(workStatus.Name);
        }
        return workStatusNames;
    }

     public static  WorkStatusResult getAllWorkStatusesResult() {
        List<ADM_Work_Status__c> existingWorkStatuses =  getAllWorkStatusesByTypes(new List<String>{'Bug', 'User Story'});
        Map<String, String> workStatusNameToId = new  Map<String, String>();
        List<String> orderedWorkStatuses = new List<String>();
        for(ADM_Work_Status__c workStatus : existingWorkStatuses){
            if(!statusNotForMapping.contains(workStatus.Name)){// Ignore New and Triaged
                workStatusNameToId.put(workStatus.Name, workStatus.Id);
                orderedWorkStatuses.add(workStatus.Name);
            }
           
        }
        WorkStatusResult wsr = new WorkStatusResult();
        wsr.workStatusNameToId = workStatusNameToId;
        wsr.orderedWorkStatuses = orderedWorkStatuses;
        return wsr;
    }

    /**
    * Get all Work Statuses.
    */
    public static ADM_Work_Status__c getWorkStatusByName(String statusName) {
        ADM_Work_Status__c workStatus = null;
        List<ADM_Work_Status__c> existingWorkStatuses = [Select id, Name from ADM_Work_Status__c where Name = :statusName order by Order__c];
        if(null !=  existingWorkStatuses){
            workStatus =  existingWorkStatuses[0];
        }
        return workStatus;
    }

    private static String getIncludeTypeString(List<String> types){
        String includeString = '';
        for(String type : types){
            includeString += '\'' + type + '\'' + ',';
        }
        includeString = includeString.substring(0,includeString.lastIndexOf(','));
        return includeString;
    }

    public class WorkStatusResult{
        public List<String> orderedWorkStatuses = new List<String>();
        public Map<String, String> workStatusNameToId = new  Map<String, String>();
    }



}