public class ADM_Validate {
    private static final Set<String> RESTRICTED_ATTRIBUTES = new Set<String>{'System Impact'};
    private static final String requiredFieldMessage = ' is a required field. ';
    private static final Set<String> statusTypesIndicatingWorkRecordUnresolved = new Set<String>{'New', 'In Progress'};
    private static Boolean isBulk = false;
    private static Boolean isInsert = false;
    private static final Map<String, ADM_FieldWrapper> fieldNameLabelMap = ADM_Work.getMapOfFieldNameLabelPairs();

    public static final Set<String> STATUS_VALUES_WHICH_REQUIRE_PARENT = new Set<String>{'Duplicate', 'Closed - Duplicate'};
    public static final Set<String> STATUS_VALUES_WHICH_REQUIRE_CHILD = new Set<String>{'Closed - New Bug Logged', 'Closed - Known Bug Exists'};
    public static final String RESTRICTED_GROUP = 'R&DTechDirectors';

    public static void validateWork(List<ADM_Work__c> newWorks, List<ADM_Work__c> originalWorks, Map<Id,RecordType> recordTypesByID) {

        // see if this is multiple items being processed
        if(newWorks.size() > 1) {
            isBulk = true;
        }

        //validate p4 status is null if status of work is not open
        validatePerforceStatusWhenNotOpen(newWorks, originalWorks);

        //validate any modifications to priority and dependent feilds
        validatePriority(newWorks, originalWorks);

        //validate Backlog Rank so that its not negative
        validateBacklogRank(newWorks);

        //validate the required fields

        validateRequiredFields(newWorks, recordTypesByID);

        //when status is set to duplicate validate the work record has been made a child of the original

        validateParentExistsForDuplicateStatus(newWorks, recordTypesByID);

        //validate only approved users can modify the Number_Of_Cases__c field

        validateNumberOfCases(newWorks, originalWorks);


        //Validate Additional Fields based on Product Tag in WorkObject
        validateAdditionalFields(newWorks, recordTypesByID);

        //add method called validate readme notes field as required when No. of cases or no of Known Issues > 0
         validateReadMeNotes( newWorks, recordTypesByID);

         validateCapexTasks(newWorks, originalWorks, recordTypesByID);

    }



    private static void validateAdditionalFields(List<ADM_Work__c> newWorks, Map<Id, RecordType> recordTypesByID){
    try{
        if(Trigger.isInsert) {
            if((ADM_WorkTriggerStaticDataStore.requestOrigin == ADM_WorkTriggerStaticDataStore.NEXT_GEN_EDIT_PAGE_ORIGIN) || (ADM_WorkTriggerStaticDataStore.requestOrigin == ADM_WorkTriggerStaticDataStore.LIGHTNING_EXPERIENCE_WORK_ORIGIN)){
                String errorMessage = '';
                List<ADM_Additional_Field__c> additionalFields = [select Field_API_Name__c, Product_Tag__c, Type__c, Bug_Setting__c, User_Story_Setting__c, Investigation_Setting__c from ADM_Additional_Field__c where Field_API_Name__c != null ];
                Map<String,Set<String>> mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForBugs = new Map<String,Set<String>>();
                Map<String,Set<String>> mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForUserStories = new Map<String,Set<String>>();
                Map<String,Set<String>> mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForInvestigation = new Map<String,Set<String>>();

                if((additionalFields != null) && (additionalFields.size() > 0)){
                    for(ADM_Additional_Field__c af : additionalFields){
                        if(af.Bug_Setting__c == 'Required'){
                            if(mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForBugs.get(af.Product_Tag__c) == null){
                                Set<String> reqFields = new  Set<String>();
                                reqFields.add(af.Field_API_Name__c);
                                mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForBugs.put(af.Product_Tag__c, reqFields);
                            }
                            else{
                                Set<String> reqFields = mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForBugs.get(af.Product_Tag__c);
                                reqFields.add(af.Field_API_Name__c);
                                mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForBugs.put(af.Product_Tag__c, reqFields);
                            }
                        }
                        if(af.User_Story_Setting__c == 'Required'){
                            if(mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForUserStories.get(af.Product_Tag__c) == null){
                                Set<String> reqFields = new  Set<String>();
                                reqFields.add(af.Field_API_Name__c);
                                mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForUserStories.put(af.Product_Tag__c, reqFields);
                            }
                            else{
                                Set<String> reqFields = mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForUserStories.get(af.Product_Tag__c);
                                reqFields.add(af.Field_API_Name__c);
                                mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForUserStories.put(af.Product_Tag__c, reqFields);
                            }
                        }
                        if(af.Investigation_Setting__c == 'Required'){
                            if(mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForInvestigation.get(af.Product_Tag__c) == null){
                                Set<String> reqFields = new  Set<String>();
                                reqFields.add(af.Field_API_Name__c);
                                mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForInvestigation.put(af.Product_Tag__c, reqFields);
                            }
                            else{
                                Set<String> reqFields = mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForInvestigation.get(af.Product_Tag__c);
                                reqFields.add(af.Field_API_Name__c);
                                mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForInvestigation.put(af.Product_Tag__c, reqFields);
                            }
                        }
                     }

                    for(ADM_Work__c work : newWorks){
                        String workRecordType = work.RecordType.Name;
                        if(workRecordType == null) {
                            workRecordType = recordTypesByID.get(work.recordTypeId).Name;
                        }
                        if(workRecordType.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME)) {
                            Set<String> reqFields = mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForBugs.get(work.Product_Tag__c);
                            errorMessage += getErrorMessagesForRequiredFields(work,reqFields);
                        }
                        else if(workRecordType.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
                            Set<String> reqFields = mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForUserStories.get(work.Product_Tag__c);
                            errorMessage += getErrorMessagesForRequiredFields(work,reqFields);
                        }
                        else if(workRecordType.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
                            Set<String> reqFields = mapOfProductTagIdWithSetOfRequiredAdditionalFieldsPerTagForInvestigation.get(work.Product_Tag__c);
                            errorMessage += getErrorMessagesForRequiredFields(work,reqFields);
                        }


                        if(errorMessage.length() > 0) {
                            if(isBulk && !isInsert) {
                                work.addError(work.Name + ' had the following errors: ' + errorMessage);
                            } else {
                                work.addError('Please correct the following error(s): ' + errorMessage);
                            }
                        }
                    }

                }
            }
       }
    }
    catch(Exception e){
         ADM_ExceptionHandler.saveException(e, 'Exception while validating required Additional Fields for work, Line : ' + e.getLineNumber() + ' Stack Trace:' + e.getStackTraceString());
    }

}


    private static void validateTestResolutionField(List<ADM_Work__c> newWorks,Map<Id, RecordType> workRecordTypesById){
        try{
            if(Trigger.isUpdate || Trigger.isInsert) {
                for (ADM_Work__c work : newWorks) {
                    String recordTypeName = workRecordTypesById.get(work.RecordTypeId).Name;
                    if(recordTypeName == ADM_Work.RECORD_TYPE_NAME_BUG){
                        if(work.Type__c == 'Test Failure'){
                            if(work.Status__c == 'Duplicate' && (ADM_TextUtils.isBlank(work.Resolution__c))){
                                work.Resolution__c = 'Duplicate Test Failure';
                            }

                            if(work.Closed__c == 1 && ADM_TextUtils.isBlank(work.Resolution__c )){
                                work.addError('Please select a value in the test resolution picklist when closing a test failure.');
                            }
                        }

                        if(work.Type__c == 'Non Deterministic Test') {
                            if(work.Closed__c == 1 && ADM_TextUtils.isBlank(work.Resolution__c )){
                                work.addError('Please select a value in the test resolution picklist when closing a Non Deterministic test.');
                            }

                        }
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Exception while setting test resolution field : '+e);
        }
    }

    public static void validateWork(List<ADM_Work__c> newWorks, List<ADM_Work__c> originalWorks, Boolean isTriggerInsert, Map<Id, RecordType> recordTypesByID) {
        validateWork(newWorks, originalWorks, recordTypesByID);

        // pass the value of insert to our own variable to use later
        isInsert = isTriggerInsert;

        //validate group based permissions
        validateGroupBasedFieldLevelSecurity(newWorks, originalWorks);

        //validate the ftest is populated when necessary
        validateFtestField(newWorks, recordTypesByID);

        //validate the team that is associated to the work
        validateTeam(newWorks, originalWorks, isTriggerInsert);

        //validate that the test resolution field is populated in Closed/Duplicate status and if type is 'Test Failure'
        validateTestResolutionField(newWorks,recordTypesByID);
    }

    /**
     * @param oldWorks may be null
     */
    private static void validatePerforceStatusWhenNotOpen(List<ADM_Work__c> newWorks, List<ADM_Work__c> oldWorks) {

        for(Integer i = 0; i < newWorks.size(); i++) {
            ADM_Work__c newWork = new ADM_Work__c();
            ADM_Work__c oldWork = new ADM_Work__c();

            newWork = newWorks.get(i);
            if(oldWorks != null) {
                oldWork = oldWorks.get(i);
            } else {

                oldWork = new ADM_Work__c();
            }

            String p4Error = ADM_WorkPerforceStatus.getPerforceErrorWhenWorkOpened(newWork, oldWork);
            if(!ADM_TextUtils.isBlank(p4Error)) {
                newWork.addError(p4Error);
            }
        }
    }

    private static void validateFtestField(List<ADM_Work__c> newWorks, Map<Id,RecordType> recordTypesByID) {
        for(ADM_Work__c work : newWorks) {
            if(!recordTypesByID.get(work.recordTypeId).Name.equalsIgnoreCase('bug')) {
                continue;
            }
            if (work.Type__c.equalsIgnoreCase('bug')) {
                if(ADM_TextUtils.isBlank(work.ftest__c)) {
                    if(work.Number_of_Change_Lists__c > 0) {
                        if(Integer.valueOf(work.Priority__c.replaceAll('P','')) < 3 || work.Number_of_Cases__c > 0) {
                            if(work.Status__c.equalsIgnoreCase('closed') || work.Status__c.equalsIgnoreCase('closed-u/ftest') || work.Status__c.equalsIgnoreCase('tested')) {
                                work.addError('Please enter a test when closing a bug');
                            }
                        }
                    }
                }
            }

        }
    }

    private static void validateGroupBasedFieldLevelSecurity(List<ADM_Work__c> newWorks, List<ADM_Work__c> originalWorks) {

        List<GroupMember> groupMembers = new List<GroupMember>();
        try {
            groupMembers = [select id, (Select UserOrGroupId From GroupMembers) from Group where Name = :ADM_Validate.RESTRICTED_GROUP].GroupMembers;
        } catch(System.Exception e) {
            //if no group exists  "System.QueryException: List has no rows for assignment to SObject" will be thrown

        }

        List<String> els = ADM_WorkUtils.extractElsFromSobjects(groupMembers, 'UserOrGroupId');
        Set<String> userids = new Set<String>();
        userids.addAll(els);


        if(Trigger.isInsert) {
            for(ADM_Work__c work : newWorks) {
                if(containsRestrictedValue(work.Attributes__c)) {
                    //if this field has changed verify the user has permission
                    if(!userids.contains(UserInfo.getUserID())) {
                        ADM_Validate.addGroupBasedFieldLevelSecurityError(work);
                    }
                }
            }
        } else if(Trigger.isUpdate) {
            for(Integer i = 0; i < originalWorks.size(); i++) {
                ADM_Work__c original = originalWorks.get(i);
                ADM_Work__c newwork = newWorks.get(i);

                if(original != null && newwork != null) {
                    if(original.Attributes__c != newwork.Attributes__c) {
                        //if restricted value has been added or taken away then verify user has permission
                        if(
                            (containsRestrictedValue(newwork.Attributes__c) && !containsRestrictedValue(original.Attributes__c)) ||
                            (containsRestrictedValue(original.Attributes__c) && !containsRestrictedValue(newwork.Attributes__c))
                        ) {

                            if(!userids.contains(UserInfo.getUserID())) {
                                ADM_Validate.addGroupBasedFieldLevelSecurityError(newWork);
                            }
                        }
                    }
                }
            }
        }
    }

    private static Boolean containsRestrictedValue(String el) {
        for(String s : ADM_Validate.RESTRICTED_ATTRIBUTES) {
            if (el != null && el.contains(s)) {
                return true;
            }
        }
        return false;

    }

    private static void addGroupBasedFieldLevelSecurityError(ADM_Work__c work) {
        String restrictedAttributesAsString = '';
        boolean addedFirstAttribute = false;
        for(String s : ADM_Validate.RESTRICTED_ATTRIBUTES) {
            if (addedFirstAttribute) {
                restrictedAttributesAsString += ', ';
            }
            restrictedAttributesAsString += '"' + s + '"';
            addedFirstAttribute = true;
        }
        work.Attributes__c.addError(restrictedAttributesAsString + ' can only be selected by members of the R&DTechDirectors public group.');
    }

    private static void validateTeam(List<ADM_Work__c> newWorks, List<ADM_Work__c> originalWorks, Boolean isTriggerInsert) {
        //ignore for 62 Org due to nature of integration there is no one to push the error message to
        if(!UserInfo.getUserName().containsIgnoreCase(ADM_WorkUser.SIXTY_TWO_ORG_USERNAME_PREFIX)) {
            //get the list of team Ids
            List<Id> teamIds = new List<Id>();
            for(ADM_Work__c work : newWorks) {
                teamIds.add(work.Scrum_Team__c);
            }

            Map<Id, ADM_Scrum_Team__c> teams = new Map<Id, ADM_Scrum_Team__c>([select Id, Active__c from ADM_Scrum_Team__c where Id in :teamIds]);
            for(ADM_Work__c work : newWorks) {
                ADM_Scrum_Team__c team = (work.Scrum_Team__c == null)? null : teams.get(work.Scrum_Team__c);
                if(team != null && team.Active__c != true) {
                    work.Scrum_Team__c.addError('The scrum team you selected is not active');
                }
            }
        }
    }

   /*
      @testcaseID ID:a0B20000007lWZ3EAM
      @hierarchy GUS.ScrumforceToGUS.Validation
      @userstory a0A200000070dwQ
      @expectedResults: Test Failure, Test Case, Bug List, Help, Integrate, Test Change and Test Tool and no errors are generated (Frequency is a required field does not get generated)
      @author jhatton
    */

    static testMethod void testValidateWhenFrequencyIsNotRequired() {

        try {

            Map<Id, RecordType> recs = new Map<Id,RecordType>(ADM_RecordType.getAll());
            ADM_Work__c work = ADM_Work.setupTestWork('Bug');
            insert work;

            work.Frequency__c = null;
            work.Priority__c = 'P4';

            List<ADM_Work__c> workList = new List<ADM_Work__c>{work};

            //frequency should not be required for these types
            //TODO: add 'Bug List' once impact and freq become options for this type
            List<String> types = new List<String>{'Test Failure', 'Test Case', 'Help', 'Integrate', 'Test Change', 'Test Tool'};
            for(String s : types) {
                work.Type__c = s;

                ADM_Validate.validateWork(workList, workList, recs);

                System.assert(!ApexPages.hasMessages(), 'Did not expect this error:' + ApexPages.getMessages() + ' for Type:' + s);
            }

         }catch (System.DmlException e) {

            System.assert(false);

        }



    }



   /*
      @testcaseID ID:a1DB00000000Dp2
      @hierarchy GUS.Work.Bug.New Page
      @userstory a1EB00000004WfH
      @expectedResults: User is able to select any of the following types: Bug, BugList, Help, Integrate, Test Case, Test Change, Test Failure, Test Tool, Translation. Field is mandatory
      @author jhatton
    */
    static testMethod void testBugTypeRequired() {
        ADM_Work__c work = ADM_Work.createTestBug();

        //type is required so setting it to null should cause an error
        work.Type__c = null;

        List<ADM_Work__c> workList = new List<ADM_Work__c>();
        workList.add(work);
        Map<Id, RecordType> recs = new Map<Id,RecordType>(ADM_RecordType.getAll());

        ADM_Validate.validateWork(workList, workList, recs);

        //assert an error has been added
        System.assert(ApexPages.hasMessages(), 'Expected an error to be shown since the Type is a required field');
    }

   /*
      @testcaseID ID:a1DB00000000REn
      @hierarchy GUS.Work.Template.Detail page
      @userstory a0790000000D5T3
      @expectedResults: Detail, Subject, Assignments, Other Information and Notification sections show the same on Work Template page. The following new fields show on the template Detail page: Theme, Sprint
      @author jhatton
    */

    static testMethod void testValidateWorkTemplate() {

        try {

            ADM_Work__c template = ADM_Work.createTestWorkTemplate();

            List<ADM_Work__c> workList = new List<ADM_Work__c>();

            System.assert(ApexPages.hasMessages() == false);

            //remove required fields

            template.Template_Name__c = '';

            template.Template_Description__c = '';

            template.Parent_ID__c = 'aslkfh'; //garbage id

            workList.add(template);

            Map<Id,RecordType> recs = new Map<Id,RecordType>(ADM_RecordType.getAll());

            ADM_Validate.validateWork(workList, workList,recs);

            System.assert(ApexPages.hasMessages() == true);



         }catch (System.DmlException e) {

            System.assert(false);

        }



    }



    //adding in message that will be used in case we have a field that is not populated in fixed status

    private static final String fixedMessage = ' when the Status is equal to Fixed.';

    //here is the parent method that will be called to check fixed fields when the QA Engineer is set

    private static void validateFieldsForFixedStatus(List<ADM_Work__c> works) {

        for(ADM_Work__c work : works) {

            if(work.Status__c != null && work.Status__c.equalsIgnoreCase('fixed')) {

                scheduledBuild(work);

                qaEngineer(work);

            }

        }

    }

    //method to check scheduled build has been populated

    private static void scheduledBuild(ADM_Work__c work){

        //we don't check the record type here because only bugs would have this show up

        if(work.Scheduled_Build__c == null) {

            work.Scheduled_Build__c.addError('You must select a Scheduled Build' + fixedMessage);

        }

    }

    //method to check qa engineer has been populated

    private static void qaEngineer(ADM_Work__c work) {

        if(work.QA_Engineer__c == null) {

            work.QA_Engineer__c.addError('You must specify a QA Engineer' + fixedMessage);

        }

    }

    //use this method to check for a related record to be referenced when the work item is marked as a duplicate

    private static void validateParentExistsForDuplicateStatus(ADM_Work__c[] works, Map<Id,RecordType> recordTypesByID){

        ADM_Parent_Work__c[] parents;

        ADM_Parent_Work__c[] children;

        for(ADM_Work__c work : works) {

            if(work.Status__c != null && STATUS_VALUES_WHICH_REQUIRE_PARENT.contains(work.Status__c) ){

                parents = ADM_ParentWork.get(work.Id);

                if(parents == null || parents.size() < 1){

                    work.Status__c.addError('You must relate this to a Parent Work record before changing the Status to ' + work.Status__c + '.');

                } else if (parents.size() >= 1) {

                    if(recordTypesByID.get(work.recordTypeId).Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {

                        //for investigations when status is duplicate veify at least one of the parents is an investigation
                        Boolean foundInvestigation = false;
                        for(ADM_Parent_Work__c rel : parents) {
                            if(recordTypesByID.get(rel.Parent_Work__r.recordTypeId).Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
                                foundInvestigation = true;
                            }
                        }
                        if(!foundInvestigation) work.Status__c.addError('You must relate this to a parent Investigation Work record before changing the Status to Closed-Duplicate');

                    }
                }
            } else if(work.Status__c != null && STATUS_VALUES_WHICH_REQUIRE_CHILD.contains(work.Status__c)) {

                String missingChildBugErrorMsg = 'You must relate this to a child Bug work record before changing the Status to ' + work.Status__c + '.';

                children = ADM_ParentWork.getChildren(work.Id);

                if(children == null || children.size() < 1){

                    work.Status__c.addError(missingChildBugErrorMsg);

                } else if (children.size() >= 1) {

                    if(recordTypesByID.get(work.recordTypeId).Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {

                        //for investigations when status indicated a bug exists verify one of the children has the correct record type
                        Boolean foundBug = false;
                        for(ADM_Parent_Work__c rel : children) {
                            if(recordTypesByID.get(rel.Child_Work__r.recordTypeId).Name == ADM_Work.BUG_RECORD_TYPE_NAME) {
                                foundBug = true;
                            }
                        }
                        if(!foundBug) work.Status__c.addError(missingChildBugErrorMsg);

                    }
                }
            }
        }
    }


   /*
      @testcaseID ID:a1DB00000000whs
      @hierarchy GUS.ScrumforceToGUS.Investigation Process.Detail Investigation page
      @userstory a07B0000000DdcxIAC
      @expectedResults:An error gets generated stating that for that specific status, a parent ID is required and last parent ID will not be deleted
      @author jhatton
    */
    static testMethod void testValidateParentExistsForDuplicateBugStatus() {

        try {

            ADM_Work__c work = ADM_Work.createTestWork();

            //set status to duplicate

            work.Status__c = 'Duplicate';

            List<ADM_Work__c> workList = new List<ADM_Work__c>();

            workList.add(work);

            Map<Id,RecordType> recs = new Map<Id,RecordType>(ADM_RecordType.getAll());

            ADM_Validate.validateParentExistsForDuplicateStatus(workList, recs);

            System.assert(ApexPages.hasMessages());

            System.assert(ApexPages.getMessages().get(0).getDetail().contains('You must relate this to a Parent Work record'));

         }catch (System.DmlException e) {

            System.assert(false);

         }
    }

       /*
      @testcaseID ID:a1DB00000000whw
      @hierarchy GUS.ScrumforceToGUS.Investigation Process.Detail Investigation page
      @userstory a07B0000000DdcxIAC
      @expectedResults:An error gets generated stating that for that specific status, a parent ID is required
      @author jhatton
    */
    static testMethod void testValidateParentExistsForDuplicateInvestigationStatus() {

        try {

            ADM_Work__c work = ADM_Work.createTestWork('Investigation');

            //set status to duplicate

            work.Status__c = 'Closed - Duplicate';

            List<ADM_Work__c> workList = new List<ADM_Work__c>();

            workList.add(work);

            Map<Id,RecordType> recs = new Map<Id,RecordType>(ADM_RecordType.getAll());

            ADM_Validate.validateParentExistsForDuplicateStatus(workList, recs);

            System.assert(ApexPages.hasMessages());

            System.assert(ApexPages.getMessages().get(0).getDetail().contains('You must relate this to a Parent Work record'));

         }catch (System.DmlException e) {

            System.assert(false);

         }
    }

       /*
      @testcaseID ID:a1DB00000000whc
      @hierarchy GUS.ScrumforceToGUS.Investigation Process.Detail Investigation page
      @userstory a07B0000000DdcxIAC
      @expectedResults:An error gets generated stating that for that specific status, a child ID is required and last child ID will not be deleted
      @author jhatton
    */
    static testMethod void testValidateChildExistsForInvestigationNewBugLoggedStatus() {

        try {

            ADM_Work__c work = ADM_Work.createTestWork('Investigation');

            //set status to duplicate

            work.Status__c = 'Closed - New Bug Logged';

            List<ADM_Work__c> workList = new List<ADM_Work__c>();

            workList.add(work);

            Map<Id,RecordType> recs = new Map<Id,RecordType>(ADM_RecordType.getAll());

            ADM_Validate.validateParentExistsForDuplicateStatus(workList, recs);

            System.assert(ApexPages.hasMessages());

            System.assert(ApexPages.getMessages().get(0).getDetail().contains('You must relate this to a child Bug work record'));

         }catch (System.DmlException e) {

            System.assert(false);

         }
    }

   /*
      @testcaseID ID:a1DB00000000whh
      @hierarchy GUS.ScrumforceToGUS.Investigation Process.Detail Investigation page
      @userstory a07B0000000DdcxIAC
      @expectedResults:An error gets generated stating that for that specific status, a child ID is required and last child ID will not be deleted
      @author jhatton
    */
    static testMethod void testValidateChildExistsForInvestigationKnownBugExistsStatus() {

        try {

            ADM_Work__c work = ADM_Work.createTestWork('Investigation');

            //set status to duplicate

            work.Status__c = 'Closed - Known Bug Exists';

            List<ADM_Work__c> workList = new List<ADM_Work__c>();

            workList.add(work);

            Map<Id,RecordType> recs = new Map<Id,RecordType>(ADM_RecordType.getAll());

            ADM_Validate.validateParentExistsForDuplicateStatus(workList, recs);

            System.assert(ApexPages.hasMessages());

            System.assert(ApexPages.getMessages().get(0).getDetail().contains('You must relate this to a child Bug work record'));

         }catch (System.DmlException e) {

            System.assert(false);

         }
    }


   private static void validateResolvedBy(ADM_Work__c[] worksNew, ADM_Work__c[] worksOld){

        for(Integer i = 0; i < worksNew.size(); i++) {

            ADM_Work__c nw = worksNew[i];

            ADM_Work__c ow = null;

            //the original work items will only exist for edits

            if(worksOld != null) {

                ow = worksOld[i];

            }



            if(nw != null && ow != null) {

                if(nw.Resolved_By__c != ow.Resolved_By__c) {

                    //for updates only validate Resolved_By__c if it has been updated

                    evaluateResolvedByErrorMessage(nw);

                }

            } else if (nw != null) {

                //for inserts validate Resolved_By if populated

                evaluateResolvedByErrorMessage(nw);

            }

        }

    }



    private static void validateImpactByType(ADM_Work__c[] worksNew) {

        //retrieve valid type -- > impact mappings 1 time only

        Map<String, Set<String>> impactMapByType = ADM_Impact.getImpactsByTypeMap();

        //api only passes the Impact__c id so lookup object names to make user friendly error message

         Map<Id, ADM_Impact__c> impactObjects = ADM_Impact.getAllAsIDObjectMap();

        //for each work record validate the mapping

        for(ADM_Work__c work : worksNew) {

            Set<String> validImpactNamesForThisWork = impactMapByType.get(work.Type__c);

            if(validImpactNamesForThisWork != null && validImpactNamesForThisWork.contains(work.Impact__c)) {

                //valid - do nothing
            } else {

                //invalid - add error

                work.addError('Impact is not valid');
            }
        }
    }


    private static void validateBacklogRank(ADM_Work__c[] worksNew) {

        ADM_Work__c nw = null;

        for(Integer i=0; i < worksNew.size(); i++) {

            nw = worksNew[i];
            if(nw.Priority_Rank__c < 0){
                nw.addError('Backlog Rank cannot be negative.');
            }
        }
     }

    private static void validatePriority(ADM_Work__c[] worksNew, ADM_Work__c[] worksOld) {

        ADM_Work__c nw = null;

        ADM_Work__c ow = null;

        Map<String, ADM_Priority_Mapping__c> priorityByImactAndFrequency = ADM_PriorityMapping.getAllAsImpactFrequencyMap();

        ADM_Impact__c defaultImpact = ADM_Impact.getDefaultImpact();

        ADM_Frequency__c defaultFrequency = ADM_Frequency.getDefaultFrequency();

        for(Integer i=0; i < worksNew.size(); i++) {

            nw = worksNew[i];

            if(worksOld != null) {

                ow = worksOld[i];
            } else {

                ow = null;
            }



            if(nw != null & ow != null) {

                ///check if priority/impact/freq has been updated

                if((nw.Priority__c != ow.Priority__c) || (nw.Impact__c != ow.Impact__c) || (nw.Frequency__c != ow.Frequency__c)) {

                    //new origin field tracks if change was made on the gus edit screen

                    if(nw.Origin__c == null || !ADM_WorkUtils.isOriginatingFromEditPage(nw.Origin__c)) {

                        //Priority can now be manually changed in salesforce 1. Thereforce only calculate if impact and frequency have been populated.
                       if((nw.Impact__c != ow.Impact__c) || (nw.Frequency__c != ow.Frequency__c)) {
                            if(nw.Frequency__c != null && nw.Impact__c != null && nw.Type__c == 'Bug') {

                                //validate if a match is found

                                ADM_Priority_Mapping__c pm = priorityByImactAndFrequency.get(nw.Impact__c + '-' + nw.Frequency__c);

                                if(pm != null && pm.Priority__r.Name != null) {

                                    nw.Priority__c = pm.Priority__r.Name;
                                } else {

                                    nw.addError('No priority mapping has been found for Impact__c:' + nw.Impact__c + ' and Frequency__c:' + nw.Frequency__c);
                                }

                            }

                        }
                    }

                    if (nw.Origin__c == ADM_WorkTriggerStaticDataStore.KANBAN_BOARD_ORIGIN && nw.Type__c == null) {
                        assignDefaultValuesForBugType(nw, defaultImpact.Id, defaultFrequency.Id, 'Bug');
                    }
                }
            } else if (nw != null) {

                if(nw.Origin__c == null || !ADM_WorkUtils.isOriginatingFromEditPage(nw.Origin__c) || nw.Origin__c == ADM_WorkTriggerStaticDataStore.LIGHTNING_EXPERIENCE_WORK_ORIGIN) {

                    if(nw.Impact__c == null && nw.Frequency__c == null && defaultImpact != null && defaultFrequency != null) {
                         assignDefaultValuesForBugType(nw, defaultImpact.Id, defaultFrequency.Id, 'Bug');
                    }

                    else if(nw.Frequency__c != null && nw.Impact__c != null && nw.Type__c == 'Bug') {

                        //validate if a match is found

                        ADM_Priority_Mapping__c pm = priorityByImactAndFrequency.get(nw.Impact__c + '-' + nw.Frequency__c);

                        if(pm != null && pm.Priority__r.Name != null) {

                            nw.Priority__c = pm.Priority__r.Name;

                        } else {

                            nw.addError('No priority mapping has been found for Impact__c:' + nw.Impact__c + ' and Frequency__c:' + nw.Frequency__c);

                        }

                    }

                }
            }

            //empty field so subsequent edits don't assume the wrong origin

            worksNew[i].Origin__c = null;
        }

    }

    private static void validateCapexTasks(ADM_Work__c[] worksNew, ADM_Work__c[] worksOld, Map<Id, RecordType> recordTypesByID) {
        ADM_Work__c nw = null;
        ADM_Work__c ow = null;

        if (worksOld != null) {
            Set<Id> workIds = (new Map<Id,SObject>(worksOld)).keySet();
            ADM_Work__c[] works = ADM_Work.getAllById(new List<Id>(workIds));
            List<ADM_Task__c> tasksToDecapitalize = new List<ADM_Task__c>();
            Map<Id,ADM_UserStoryAndTaskWrapper> workAndTasks = new Map<Id,ADM_UserStoryAndTaskWrapper>();

            for(ADM_Work__c work : works) {
                ADM_UserStoryAndTaskWrapper workWrapper = new ADM_UserStoryAndTaskWrapper(work, work.RecordType);
                workAndTasks.put(work.Id, workWrapper);
            }

            for(Integer i=0; i < worksNew.size(); i++) {
                nw = worksNew[i];
                ow = worksOld[i];

                ADM_UserStoryAndTaskWrapper workWithTasks = workAndTasks.get(nw.Id);
                ADM_Task__c[] workTasks = workWithTasks.getTasks();
                Boolean decapitalizing = (ow.Capex_Enabled__c && !nw.Capex_Enabled__c);
                Boolean workHasTasks = (workTasks.size() > 0 ? true : false);
                Boolean workHasCapexTask = false;
                Decimal capExTaskHours = 0;

                if((recordTypesByID.get(nw.RecordTypeId).Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)  || recordTypesByID.get(nw.RecordTypeId).Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_BUG)) && (nw.Status__c == 'Closed' || decapitalizing)) {
                     if (workHasTasks) {
                        for(ADM_Task__c task : workTasks) {
                            if (task.Capex_Enabled__c) {
                                if (decapitalizing) {
                                    task.Capex_Enabled__c = false;

                                    tasksToDecapitalize.add(task);

                                    continue;
                                }

                                workHasCapexTask = true;
                                capExTaskHours = (task.Actual_Hours__c == null ? 0 : task.Actual_Hours__c);

                                if (capExTaskHours <= 0) {
                                    nw.addError('Quality task "' + task.Subject__c + '" should have Actual hours greater than 0');
                                }
                            }
                        }
                    }

                    if(nw.Capex_Enabled__c) {
                        if (!workHasCapexTask) {
                            nw.addError(nw.Name + ' cannot be closed without at least one Quality task');
                        }
                    } else if (!nw.Capex_Enabled__c && workHasCapexTask) {
                        nw.addError('Only work records with the New Customer Facing Feature flag can contain Quality tasks');
                    }
                }
            }

            if (tasksToDecapitalize.size() > 0) {
                update tasksToDecapitalize;
            }
        }
    }

    private static void assignDefaultValuesForBugType(ADM_Work__c work, String defaultImpactId, String defaultFreqId, String type){
         work.Impact__c = defaultImpactId;
         work.Frequency__c = defaultFreqId;
         work.Type__c = type;
    }



   /*
      @testcaseID ID: a1DB00000000PcZ
      @hierarchy  GUS.Work.DefectPrioritizationProcess.URL population
      @userstory  a0790000000DB87
      @expectedResults: Ensure the bug gets created with new fields, the new email subscribers get created and an email gets sent to these email notifications
      @author jhatton
    */

    static testMethod void testValidateImpactByType() {

       try {

            ADM_Work__c work = ADM_Work.createTestWork();

            ADM_Impact__c i = new ADM_Impact__c(Name='Test Impact');

            insert i;

            ADM_Type__c t = new ADM_Type__c(Name = 'Test Type');

            insert t;

            ADM_Impact_Type__c it = new ADM_Impact_Type__c(Impact__c = i.id, Type__c = t.id);

            insert it;

            work.Type__c='Test Impact';

            work.Impact__c=i.id;

            //remove the type mapping

            delete it;

            //repeat test - validation should fail

            ADM_Validate.validateImpactByType(new List<ADM_Work__c>{work});

            System.assert(ApexPages.hasMessages());

        }catch (System.DmlException e) {



            System.assert(false);

        }
    }



    private static void evaluateResolvedByErrorMessage(ADM_Work__c nw) {

        if(nw.Resolved_By__c != null) {

            //validate status is not new/in progress etc (can't really be if its been resolved)

            if(statusTypesIndicatingWorkRecordUnresolved.contains(nw.Status__c)) {

                nw.Status__c.addError('Please update the Status__c field to something other than:' + statusTypesIndicatingWorkRecordUnresolved + ' before attempting to set the Resolved_By__c field');

            }

        }

    }
   /*
      @testcaseID ID:a1DB00000000Qf8
      @hierarchy GUS.Work.User Story.Detail page
      @userstory a0790000000D5T3
      @expectedResults: User stories are set to closed, the Closed On, Resolved On, Resolved and Resolved By fields are filled out with the correct information
      @author jhatton
    */


    static testMethod void testValidateResolvedBy() {

        try {

            ADM_Work__c work = ADM_Work.createTestWork();

            //set status to new and attempt to populate Resolved_By field

            work.Status__c = 'New';

            work.Resolved_By__c = [select id from user limit 1].id;

            List<ADM_Work__c> workList = new List<ADM_Work__c>();

            workList.add(work);

            ADM_Validate.validateResolvedBy(workList, null);

            //only was to assert if an error has been added.  Apex has no way to read back the error in a unit test

            System.assert(ApexPages.hasMessages());

         }catch (System.DmlException e) {

            System.assert(false);

         }

    }



    private static void validateNumberOfCases(ADM_Work__c[] worksNew, ADM_Work__c[] worksOld){

        for(Integer i = 0; i < worksNew.size(); i++) {

            ADM_Work__c nw = worksNew[i];

            ADM_Work__c ow = null;

            //the original work items will only exist for edits

            if(worksOld != null) {

                ow = worksOld[i];

            }

            if(nw != null && ow != null) {

                if(nw.Number_Of_Cases__c != ow.Number_Of_Cases__c) {

                    if((nw.Number_Of_Cases__c != null && nw.Number_Of_Cases__c == 0) && ow.Number_Of_Cases__c == null) {

                        //this is a valid use case where preceeding code can populate # Cases with default value on users behalf

                    } else {

                        evaluateNumberOfCasesErrorMessage(nw, ow);

                    }

                }

            } else if (nw != null) {

                //for inserts validate if Number of Cases has been populated with anything other then default value

                if(nw.Number_Of_Cases__c != null && nw.Number_Of_Cases__c != 0) {

                    evaluateNumberOfCasesErrorMessage(nw, null);

                }

            }

        }

    }

   /*
      @testcaseID ID:a1DB00000000QgD
      @hierarchy GUS.Work.User Story.Edit Page
      @userstory a0790000000D5T3
      @expectedResults: # of cases are validated
      @author jhatton
    */

    static testMethod void testValidateNumberOfCases() {

        Decimal originalCount = 0;
        String newSubject = '';
        ADM_Work__c work  = null;

        try {

            //this test only applicable if GUS User profile exists (tests can't create profiles and therefore have to rely on existing data)
            User u = ADM_WorkUser.createTestGUSUser();
            if( u != null && u.id != null) {

                System.runAs(u) {
                    work = ADM_Work.createTestWork();

                    originalCount = work.Number_of_Cases__c;

                    //attempt to update the number of cases field
                    work.Number_Of_Cases__c = 100;

                    //also make a valid change
                    work.Subject__c = 'I am allowed to change the subject but not the Number of Cases field';
                    newSubject = work.Subject__c;

                    update work;

                    //we don't expect an error just the change to be ignored.

                }

                //lets verify the change was not commited
                ADM_Work__c updatedWork = [select id, Subject__c, Number_of_Cases__c from ADM_Work__c where id = : work.id];
                //this change should have been ignored
                System.assertEquals(originalCount, updatedWork.Number_Of_Cases__c);
                //this change should have been commited
                System.assertEquals(newSubject, updatedWork.Subject__c);

            }

         }catch (System.DmlException e) {

            System.assert(false);

         }

    }



    private static void evaluateNumberOfCasesErrorMessage(ADM_Work__c nw, ADM_Work__c ow) {

        /* Once we have the SOQL calls to spare - Replace hard coded profile ID with logical comparison to profile name (e.g. Sys Admin)  Have to query this as UserInfo only exposes profile ID.

                Id id1 = userinfo.getProfileId()

                select Name from profile where id = :id1;

        */

        if(UserInfo.getUserName().containsIgnoreCase(ADM_WorkUser.SIXTY_TWO_ORG_USERNAME_PREFIX) || UserInfo.getProfileId().contains('00eT0000000mLex')) { //Prod Sys Admin profile ID

            //ok to modify

        } else {

            //silently prevent modification
            if(ow != null) {
                nw.Number_of_Cases__c = ow.Number_of_Cases__c;
            } else {
                //enforce default if non-admin user attempted to insert work record with case count different to zero
                nw.Number_of_Cases__c = 0;
            }



        }

    }

    @TestVisible
    private static String getErrorMessagesForRequiredFields(ADM_Work__c work, Set<String> requiredFields) {
        String errorMessage = '';
        Sobject sobj = work;
        if(requiredFields != null){
            for(String requiredField : requiredFields) {
               if(sobj.get(requiredField) == null) {
                    //check for user friendly label and if not found default to api name
                    String fieldLabel;
                    if(fieldNameLabelMap.containsKey(requiredField)) {
                        fieldLabel = fieldNameLabelMap.get(requiredField).fieldLabel;
                    } else {
                        fieldLabel = requiredField;
                    }
                    errorMessage += fieldLabel + requiredFieldMessage;
               }
            }
        }

        return errorMessage;
    }

    private static String getTemplateErrorMessagesForRequiredFields(ADM_Work__c work) {
        String errorMessage = getErrorMessagesForRequiredFields(work, ADM_Work.TEMPLATE_RECORD_TYPE_REQ_FIELDS);
        if(work.Parent_ID__c != null) {
            validateParentWorkID(work);
        }
        return errorMessage;
    }

    private static String validateRequiredFields(List<ADM_Work__c> works, Map<Id, RecordType> recordTypesByID) {

        String errorMessage;



        for(Integer i= 0; i < works.size(); i ++) {

            ADM_Work__c work = works.get(i);

            String workRecordType = work.RecordType.Name;

            errorMessage = '';



            if(workRecordType == null) {

                workRecordType = recordTypesByID.get(work.recordTypeId).Name;

            }



            if(workRecordType.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME)) {

                //this is temp method of handling feature request validation.  will be improved once feature requests become user story record type

                if(work.Type__c != null && ADM_Work.TYPES_WHERE_FREQUENCY_APPLIES.contains(work.Type__c)) {

                    Set<String> reqFields = new Set<String>();
                    reqFields.addAll(ADM_Work.BUG_RECORD_TYPE_REQ_FIELDS);
                    reqFields.add('Frequency__c');

                    errorMessage += getErrorMessagesForRequiredFields(work, reqFields);

                } else {

                    errorMessage += getErrorMessagesForRequiredFields(work, ADM_Work.BUG_RECORD_TYPE_REQ_FIELDS);

                }

            } else if (workRecordType.equalsIgnoreCase(ADM_Work.TEMPLATE_RECORD_TYPE_NAME)) {

                errorMessage += getTemplateErrorMessagesForRequiredFields(work);

            } else if(workRecordType.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_TODO)){

                errorMessage += getErrorMessagesForRequiredFields(work, ADM_Work.TODO_RECORD_TYPE_REQ_FIELDS);

                errorMessage += getTodoPerforceStatusErrorMessage(work, workRecordType);

            } else if (workRecordType.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {

                errorMessage += getErrorMessagesForRequiredFields(work, ADM_Work.USERSTORY_RECORD_TYPE_REQ_FIELDS);

            } else if (workRecordType.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
                errorMessage += getErrorMessagesForRequiredFields(work, ADM_Work.REQ_FIELDS_INVESTIGATION);
                errorMessage += getTodoPerforceStatusErrorMessage(work, workRecordType);
            }



            if(errorMessage.length() > 0) {
                if(isBulk && !isInsert) {
                    work.addError(work.Name + ' had the following errors: ' + errorMessage);
                } else {
                    work.addError('Please correct the following error(s): ' + errorMessage);
                }
            }

        }



        return errorMessage;

    }



    private static void validateParentWorkID(ADM_Work__c work) {

        //for templates only validate Parent Work ID

        if(work.Parent_ID__c != null) {

            List<String> trimmedWorkItems = ADM_ParentWork.trimWorkItems(ADM_ParentWork.splitWorkItems(work.Parent_ID__c));

            List<ADM_Work__c> validatedWorkItems = ADM_ParentWork.validateWorkItems(trimmedWorkItems);

            if(trimmedWorkItems.size() > validatedWorkItems.size()) {

                 //validated list is smaller so trimmed list must contain invalid Work-ID

                 if (trimmedWorkItems.size() == 1) {

                       work.Parent_ID__c.addError('Invalid Parent Work ID.');

                 } else {

                       work.Parent_ID__c.addError('At least one Parent Work ID is invalid');

                 }

            }

            //make sure none of the validated work items match the current work record

            for(ADM_Work__c validWork : validatedWorkItems) {

                if(validWork.id == work.id) {

                    //parent ID cannot be set to your own id

                    work.Parent_ID__c.addError('Invalid Parent Work ID.  Work item cannot be related to itself.');

                }

            }

        }

    }

    private static void isNotTodoConversion(ADM_Work__c[] worksNew, ADM_Work__c[] worksOld) {
        RecordType[] recordTypes = ADM_RecordType.getAll();

        //JH:  Why not just compare RecordTypeId between old and new and if different throw the error.  Much more efficient.

        for(Integer i = 0; i < worksNew.size(); i++) {
            ADM_Work__c nw = worksNew[i];
            ADM_Work__c ow = worksOld[i];

            if(ow == null) {
                continue;
            }

            RecordType nwRecordType =  ADM_RecordType.match(recordTypes,nw.RecordTypeId);
            RecordType owRecordType = ADM_RecordType.match(recordTypes,ow.RecordTypeId);

            if(nwRecordType == null || owRecordType == null) {
                continue;
            }

            String nwRt = nwRecordType.Name;
            String owRt = owRecordType.Name;

            if(owRt.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_TODO) && !nwRt.equalsIgnoreCase(owRt)) {
                nw.addError(ADM_Work.RECORD_TYPE_NAME_TODO + ' records cannot be converted into different record types!');
            }
        }

    }



    public static void restrictRecordTypeConversion(ADM_Work__c[] worksNew, ADM_Work__c[] worksOld, Map<Id,RecordType> workRecordTypesById) {

         for(Integer i = 0; i < worksNew.size(); i++) {
            String oldRecordTypeName = workRecordTypesById.get(worksOld[i].RecordTypeId).Name;
            String newRecordTypeName = workRecordTypesById.get(worksNew[i].RecordTypeId).Name;
            if(worksNew[i].Capex_Enabled__c == true && !(newRecordTypeName == 'User Story' || newRecordTypeName == 'Bug')){
                 worksNew[i].addError('Cannot convert RecordType with New Customer Facing Feature enabled to anything other than a Bug or a User Story.');
            }
            else{
            if(oldRecordTypeName.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY) && newRecordTypeName.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME)) {
                //valid conversion perform any modifications to the record here

            } else if(oldRecordTypeName.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME) && newRecordTypeName.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
                //valid conversion perform any modifications to the record here

            } else if(worksOld[i].RecordTypeId != worksNew[i].RecordTypeId) {
                //invalid conversion
                worksNew[i].addError('This type of record type conversion is not supported');
            }
            }


        }
    }



    private static String getTodoPerforceStatusErrorMessage(ADM_Work__c work, String workRecordType) {
        String errorMessage = '';

        if(work.Perforce_Status__c != null && work.Perforce_Status__c.length() > 0) {
             errorMessage = workRecordType + ' records cannot have a Source Control Status specified! ';
        }

        return errorMessage;
    }

        private static void validateReadMeNotes( List<ADM_Work__c> newWorks,Map<Id, RecordType> workRecordTypesById){
        try{
            if(Trigger.isUpdate) {
                for (ADM_Work__c work : newWorks) {
                    String recordTypeName = workRecordTypesById.get(work.RecordTypeId).Name;
                    if((recordTypeName == ADM_Work.RECORD_TYPE_NAME_BUG) && (ADM_TextUtils.isBlank(work.Readme_Notes__c )) && (work.Status__c=='Closed') && !UserInfo.getUserName().containsIgnoreCase(ADM_WorkUser.SIXTY_TWO_ORG_USERNAME_PREFIX)){
                                if(work.Number_of_Cases__c > 0) {
                                work.addError('Please enter a value for the  ReadMe Notes field as Number of cases is '+ work.Number_of_Cases__c);
                             }
                                else if(work.Known_Issue_Num_Reporting_Customers__c > 0 ) {
                                    work.addError('Please enter a value for the ReadMe Notes field as Number of Known issues is '+ work.Known_Issue_Num_Reporting_Customers__c);
                                }

                 }
               }
            }
        }

         catch(Exception e){
            System.debug('Exception while saving ReadMe notes : '+e);
        }
    }

   /*
      @testcaseID ID: a1DB00000000Rvq
      @hierarchy GUS.SystemIntegrations.Code Check-Ins
      @userstory a0790000000D6Gd
      @expectedResults: error is generated
      @author jhatton
    */

    static testMethod void testGetTodoPerforceStatusErrorMessage() {

        try {

            ADM_Work__c work = ADM_Work.createTestTodo();

            work.Perforce_Status__c = ADM_WorkPerforceStatus.OPEN;

            List<ADM_Work__c> workList = new List<ADM_Work__c>();

            workList.add(work);

            Map<Id,RecordType> recs = new Map<Id,RecordType>(ADM_RecordType.getAll());

            ADM_Validate.validateWork(workList, workList,recs);

            //only was to assert if an error has been added.  Apex has no way to read back the error in a unit test

            System.assert(ApexPages.hasMessages());



         }catch (System.DmlException e) {

            System.assert(false);

        }



    }


    /*
      @testcaseID ID:a1DB00000000WiZ
      @hierarchy GUS.Work.Bug.New Page
      @userstory a0790000000D5T3
      @expectedResults: A user who's not on the R&DTechDirectors public group is able to make changes to the bug and doesn't get errors related to the system impact attribute
      @author jhatton
    */
    /**
     * Test that a user cannot create a work with a restricted attribute
     */
    static testMethod void testValidateInsertWithRestrictedAttributeValue() {
        User user = ADM_WorkUser.createTestUserWithRandomName();
        System.runAs(user) {
           try {
                ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P99', 'Bug');
                work.Attributes__c = 'System Impact';
                upsert work;
                System.assert(false, 'User should not be able to create a new work item with a restricted attribute.');
            } catch (Exception exc) {
                System.assert(exc.getMessage().contains('only be selected'), 'Expected the insert to fail due to the restricted attribute:' + exc.getMessage());
            }
        }
    }

   /*
      @testcaseID ID: a1DB00000000qM5
      @hierarchy GUS.Work.Bug.New Page
      @userstory a07B0000000DzsU
      @expectedResults: User is able to add attributes and save. These changes will not reflect as comments
      @author jhatton
    */
    /**
     * Test that a user cannot add a restricted attribute to work
     */
    static testMethod void testValidateUpdateWithRestrictedAttributeValue() {
        User user = ADM_WorkUser.createTestUserWithRandomName();
        System.runAs(user) {
            try {
                ADM_Work__c work = ADM_Work.setupTestWork('Bug', 'P99', 'Bug');
                upsert work;

                work.Attributes__c = 'System Impact';
                upsert work;
                System.assert(false, 'User should not be able to create a new work item with a restricted attribute.');
            } catch (Exception exc) {
                System.assert(exc.getMessage().contains('only be selected'), 'Expected the insert to fail due to the restricted attribute:' + exc.getMessage());
            }
        }
    }

   /*
      @testcaseID ID: a1DB000000018ov
      @hierarchy GUS.ScrumTeams.Prioritizer.In-Row Edit Bug
      @userstory a07B0000000Eq0G
      @expectedResults: test is required
      @author jhatton
    */

    static testMethod void testFTestRequired() {
        Map<Id, RecordType> recordTypesByID = new Map<Id, RecordType>([select Id, Name from RecordType]);
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        upsert work;

        work.Type__c = 'Bug';
        work.Number_of_Change_Lists__c = 1;
        work.Priority__c = 'P0';
        work.Status__c = 'Closed';
        work.ftest__c = null;

        ADM_Validate.validateFtestField(new List<ADM_Work__c>{work}, recordTypesByID);

        System.assert(ApexPages.hasMessages(), 'Expected there to be an error message because there should be an test');
    }
   /*
      @testcaseID ID:
      @hierarchy
      @userstory
      @expectedResults:
      @author jhatton
    */

    static testMethod void testWhenFixedScheduledBuildRequired() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        upsert work;

        work.Status__c = 'Fixed';
        work.Scheduled_Build__c = null;

        ADM_Validate.validateFieldsForFixedStatus(new List<ADM_Work__c>{work});

        System.assert(ApexPages.hasMessages(), 'Expected there to be an error message because Scheduled Build is required when status is fixed');
        assertContainsIgnoreCase(ApexPages.getMessages(), 'Scheduled Build', 'Expected there to be an error message because Scheduled Build is required when status is fixed');
    }

   /*
      @testcaseID ID:
      @hierarchy
      @userstory
      @expectedResults:
      @author jhatton
    */
    static testMethod void testWhenFixedQaEngineerRequired() {
        ADM_Work__c work = ADM_Work.setupTestWork('Bug');
        upsert work;

        work.Status__c = 'Fixed';
        work.QA_Engineer__c = null;

        ADM_Validate.validateFieldsForFixedStatus(new List<ADM_Work__c>{work});

        System.assert(ApexPages.hasMessages(), 'Expected there to be an error message because QA Engineer is required when status is fixed');
        assertContainsIgnoreCase(ApexPages.getMessages(), 'QA Engineer', 'Expected there to be an error message because QA Engineer is required when status is fixed');
    }
   /*
      @testcaseID ID:
      @hierarchy
      @userstory
      @expectedResults:
      @author jhatton
    */

    static testMethod void testFailOnConversionFromTodo() {
        ADM_Work__c work = ADM_Work.setupTestWork('ToDo');
        work.Priority__c = 'P0';
        upsert work;

        ADM_Work__c newWork = work.clone();
        newWork.RecordTypeId = [select Id from RecordType where Name = 'Bug'].Id;
        ADM_Validate.isNotTodoConversion(new List<ADM_Work__c>{newWork}, new List<ADM_Work__c>{work});

        System.assert(ApexPages.hasMessages(), 'Expected there to be an error message because a Todo item cannot be converted to another work type.');
        assertContainsIgnoreCase(ApexPages.getMessages(), 'cannot be converted', 'Expected there to be an error message because a Todo item cannot be converted to another work type.');

    }

    private static void assertContainsIgnoreCase(List<ApexPages.Message> messages, String value, String message) {
        Boolean found = false;
        for(ApexPages.Message m : messages) {

            if((m.getDetail() != null && m.getDetail().containsIgnoreCase(value)) ||
              (m.getSummary() != null && m.getSummary().containsIgnoreCase(value)) ) {
                found = true;
                break;
            }
        }
        System.assert(found, message);
    }
}