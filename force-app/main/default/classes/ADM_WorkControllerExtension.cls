public with sharing class ADM_WorkControllerExtension {  
    //member variable to hold the current work item being viewed initialized in standard controller
    ADM_Work__c work;
    ADM_Severity__c[] severities;
    
    User user;
    
    String priority;
    String status;
    String helpStatus;
    String workType;
    String severity;
    RecordType recordType;
    String tabStyle;
    String requiredInput = 'requiredInput';
    String nonRequiredInput = '';
    
    public transient Map<String, String> params = new Map<String, String>();
    public transient String assignee = '';
    public transient String qa = '';
    public transient String ue = '';
    public transient String techwriter = '';
    public transient String prodowner = '';
    public transient String systest = '';
    public transient String seniorManagmentPOC = '';
    public transient String scrumteamName = '';
    public transient String relatedUrl = '';
    
    public String commentHelpText {
        get {           
            return 'When you click the Save button, your comment will be added to the Work record and included in an email to the names listed in the Email Notifications section.';
        }    
        set;    
    }
    
    public Map<String, String> getParams() {
        for(String key : params.keySet()) {          
            params.put(key, EncodingUtil.urlEncode(params.get(key), 'UTF-8'));
        }
        return params;
    }
    
    public String getRelatedUrl() {
        if(!ADM_TextUtils.isBlank(work.Related_Url__c)) {
            relatedUrl = ADM_URLUtils.formatTextAsHref(work.Related_Url__c);
        }       
        return relatedUrl;
    }
    
    public ADM_FieldWrapper details {
        get {
            if(details == null) details =  new ADM_FieldWrapper('');
            return details;
        }
        set;
    }
    
    public String retUrl { 
        get {
            retUrl = '';
            if(params != null && params.containsKey('retURL')) {
                retUrl = params.get('retURL');
            }
            return retUrl;
        }
        set;
    }
    
    public String clonePageVar {
        get {
            clonePageVar = '';
            if(params != null && params.containsKey('clone')) {
                clonePageVar = params.get('clone');
            }
            return clonePageVar;
        }
        set;
    }

    public String gusUrl {
        get {
            if(gusUrl == null) {
                gusUrl = ADM_WorkUtils.GUS_URL;
            }
            return gusUrl;
        }
        set;
    }

    public PageReference checkRequestRDMgr() {
        if ( work.Request_RD_Mgr_Review__c &&
            ( !ADM_TextUtils.isNull(work.Product_Area__c) ) &&
            ( !ADM_TextUtils.isNull(work.Major_Func_Area__c) ) &&
            ( !ADM_TextUtils.isBlank(work.Severity_Level__c) ) )
            return getAutoAssignedWork();
        return null;

    }
    
    public ADM_WorkAssignment.AssignmentContext getAssignmentsForWork() {
        ADM_Product_Tag__c productTag = ADM_ProductTag.get(work.Product_Tag__c);
        return ADM_WorkAssignment.getAssignments(work.Severity_Level__c, productTag, recordType, work.Type__c, this.HiddenReps);
    }
    
    public Pagereference getAutoAssignedWork() {
        
        
        ADM_WorkAssignment.AssignmentContext assignments = getAssignmentsForWork();
        
        //TODO: why do we replace the error messages only in investigations, but
        //all other types we add the error messages
        List<String> assignmentErrors = (assignments.errorMessages != null)? assignments.errorMessages : new List<String>();
        for(String errorMessage: assignmentErrors) {
            work.addError(errorMessage);
        }
        if(assignments.assignments != null) {
            assignments.assignments.apply(work);
        }
        
        this.HiddenReps = assignments.recipients;
        
        
        
        
        List<String> userIds = new List<String>();
        if(work.Assignee__c != null) {
            userIds.add(work.Assignee__c);
        }
        if(work.QA_Engineer__c != null) {
            userIds.add(work.QA_Engineer__c);
        }
        if(work.UE_Engineer__c != null) {
            userIds.add(work.UE_Engineer__c);
        }
        if(work.Tech_Writer__c != null) {
            userIds.add(work.Tech_Writer__c);
        }
        if(work.Product_Owner__c != null) {
            userIds.add(work.Product_Owner__c);
        }
        if(work.System_Test_Engineer__c != null) {
            userIds.add(work.System_Test_Engineer__c);
        }
        if(work.Senior_Management_POC__c != null) {
            userIds.add(work.Senior_Management_POC__c);
        }
        if(work.Scrum_Team__c != null) {
            scrumteamName = ADM_ScrumTeam.get('Id', work.Scrum_Team__c).Name;
        }
         
        Map<Id,User> users = new Map<Id,User>([Select Name from User where Id in : userIds]);
        User userFromMap = null;

        if(work.Assignee__c != null) {
            userFromMap = users.get(work.Assignee__c);
            if(userFromMap != null) {
                setAssignee(String.escapeSingleQuotes(userFromMap.Name));
                userFromMap = null;
            }
        }
        if(work.QA_Engineer__c != null) {
            userFromMap = users.get(work.QA_Engineer__c);
            if(userFromMap != null) {
                setQa(String.escapeSingleQuotes(userFromMap.Name));
                userFromMap = null;
            }
        }
        if(work.UE_Engineer__c != null) {
            userFromMap = users.get(work.UE_Engineer__c);
            if(userFromMap != null) {
                setUe(String.escapeSingleQuotes(userFromMap.Name));
                userFromMap = null;
            }
        }
        if(work.Tech_Writer__c != null) {
            userFromMap = users.get(work.Tech_Writer__c);
            if(userFromMap != null) {
                setTechwriter(String.escapeSingleQuotes(userFromMap.Name));
                userFromMap = null;
            }
        }
        if(work.Product_Owner__c != null) {
            userFromMap = users.get(work.Product_Owner__c);
            if(userFromMap != null) {
                setProdOwner(String.escapeSingleQuotes(userFromMap.Name));
                userFromMap = null;
            }
        }
        if(work.System_Test_Engineer__c != null) {
            userFromMap = users.get(work.System_Test_Engineer__c);
            if(userFromMap != null) {
                setSystest(String.escapeSingleQuotes(userFromMap.Name));
                userFromMap = null;
            }
        }
        if(work.Senior_Management_POC__c != null) {
            userFromMap = users.get(work.Senior_Management_POC__c);
            if(userFromMap != null) {
                setSeniorManagementPOC(String.escapeSingleQuotes(userFromMap.Name));
                userFromMap = null;
            }
        }
        
        return null;
    }
    
     /**
     * @param severityLevel The severity level value
     * @param productTag The product tag
     * @param recordTypeId The record type
     * @param workType The work type value
     * @param recipients The current list of recipients
     */
    @RemoteAction
    public static ADM_WorkAssignment.AssignmentContext getAssignments(String severityLevel, ADM_Product_Tag__c productTag, RecordType recordType, String workType, String recipients) {
    	return ADM_WorkAssignment.getAssignments(severityLevel, productTag, recordType, workType, recipients);
    }

    public String getScrumteamName() { return scrumteamName; }
    private void setScrumteamName(String s) { scrumteamName = s; }

    public String getAssignee() { return assignee; }
    private void setAssignee(String s) { assignee = s; }

    public String getQa() { return qa; }
    private void setQa(String s) { qa = s; }

    public String getUe() { return ue; }
    private void setUe(String s) { ue = s; }

    public String getTechwriter() { return techwriter; }
    private void setTechwriter(String s) { techwriter = s; }

    public String getProdOwner() { return prodowner; }
    private void setProdOwner(String s) { prodowner = s; }

    public String getSystest() { return systest; }
    private void setSystest(String s) { systest = s; }

    public String getSeniorManagementPOC() { return seniorManagmentPOC; }
    private void setSeniorManagementPOC(String s) { seniorManagmentPOC = s; }
    
    private transient User suggestedSeniorManagementPOC;
    public User getSuggestedSeniorManagementPOC() {
        return suggestedSeniorManagementPOC;
    }
    public String getSuggestedSeniorManagementPOCAsJSON() {
        User poc = getSuggestedSeniorManagementPOC();
        return JSON.serialize(poc);
    }

    public Boolean renderType {
        get {
            if(renderType == null) {
                if(recordType.Name.equals(ADM_Work.BUG_RECORD_TYPE_NAME) || recordType.Name.equals(ADM_Work.TEMPLATE_RECORD_TYPE_NAME)) {
                    renderType = true;
                } else {
                    renderType = false;
                }
            }
            return renderType;
        }
        set;
    }

    public Boolean renderFrequencyAndImpact {
        get {
            if(renderFrequencyAndImpact == null) {
                if(recordType.Name.equals(ADM_Work.BUG_RECORD_TYPE_NAME)) {
                    renderFrequencyAndImpact = true;
                } else {
                    renderFrequencyAndImpact = false;
                }
            }
            return renderFrequencyAndImpact;
        }
        set;
    }
    
    public Boolean hasErrorMessages {
        get {
            return ApexPages.hasMessages();
        }
    }

    public static final Boolean CLONE_OPTION_PRESERVE_ID = false;
    public static final Boolean CLONE_OPTION_IS_DEEP_CLONE = true;

    Boolean isWorkTemplate;
    Boolean isNewWork = false;
    Boolean isClone = false;
    Boolean hasComments;
    transient Boolean isNewRecordType = false;

    public String priorityNew { get; set; }
    public String priorityExplanationNew { get; set; }
    public String priorityCurrent { get; set; }
    public String priorityPreExisting{ get; set; }

   
    private static ApexPages.StandardController stdC;

    public ADM_WorkControllerExtension() {}

    public ADM_WorkControllerExtension(ApexPages.StandardController stdController) {
        params.putAll(System.currentPageReference().getParameters());
        //grab the user data and set it
        setUser();
        //keep copy of standard controller - used by other methods such as populateWork()
        stdC = stdController;
        //populate the work object
        populateWork();
        populateIsWorkTemplate();
        
         //encode hidden recipients field for client side subscriber functionality
        populateRecipients();
        
        setWorkValuesFromUrl();
        if(work != null ) {
            setWorkType(work.Type__c);
            
            setProductArea(work.Product_Area__c);
            setMajorFunctionalArea(work.Major_Func_Area__c);
            setPriority(work.Priority__c);
            this.priorityCurrent = work.Priority__c;
            this.priorityNew = work.Priority__c;
            this.priorityExplanationNew = work.Priority_Override_Explanation__c;
            
            //see if anything can be autoassigned based on preloaded values
            if(getIsNewWork() && work.Product_Tag__c != null) {
                this.getAutoAssignedWork();
            }
            
            //get the suggested senior management point of contact when an investigation
            if(!getIsNewWork() && recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
                ADM_WorkAssignment.AssignmentContext assignmentContext = getAssignmentsForWork();
                if(assignmentContext != null && assignmentContext.assignments != null && assignmentContext.assignments.Senior_Management_POC != null) {
                    List<User> users = [select Id, Name from User where ID = :assignmentContext.assignments.Senior_Management_POC.Id];
                    if(users.size() > 0) {
                        suggestedSeniorManagementPOC = users.get(0);
                    }
                }
            }
        }
        //setup the values we'll need for our dependent pick lists
        populateWorkType();
       
        
    }

    //temporary store for encoded version of recipients
    public String HiddenReps { 
        get;
        set;
    } 

    private void populateRecipients() {
        try {
            //only attempt for edit of work records
            if(work != null && work.id != null) {
                this.HiddenReps = ADM_NotificationUtils.encodeRecipientList(ADM_Work_Subscriber.getByList(new List<Id>{work.id}));
            } else {
                //new work item - auto subscribe the creator
                this.HiddenReps = ADM_NotificationUtils.MANUALLY_ASSIGNED_PREFIX + ADM_NotificationUtils.HIDDEN_RECIPIENT_TYPE_DELIMITER + UserInfo.getName(); 
            }
            
        } catch (System.Exception e) {
            
        }
        
    }

    public void doNothing() {}
    
    public void cancelPriorityChange() {
        priorityNew = work.Priority__c;
        priorityExplanationNew = work.Priority_Override_Explanation__c;
    }

    public String getRequiredInputType() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME)) {
            return requiredInput;
        }

        return nonRequiredInput;
    }

    public String getRequiredInputStatus() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_TODO) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
            return requiredInput;
        }

        return nonRequiredInput;
    }
    
    public String getRequiredInputProductTag() {
        //TODO: how does this relate to required fields defined in ADM_Work?
        if(recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) || recordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
            return requiredInput;
        }
        return nonRequiredInput;
    }

    public String getRequiredInputProductTagInstructions() {
        String productTagInstructions = '';
        if((recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) || recordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) &&
            (!isNewWork && isBlank(work.Product_Tag__c) && isBlank(work.Scrum_Team__c))) {
                productTagInstructions = 'It looks like you\'ve stumbled across a record without a Product Tag, because it was never assigned to a Team.   Please choose one before saving your change.  To help pick, the prior Product Area was: ' +
                work.Product_Area__c + ' and the Major Functional Area: ' + work.Major_Func_Area__c;
        }
        return productTagInstructions;      
    }
    
    public String getRequiredInputProductArea() {
        return nonRequiredInput;
    }

    public String getRequiredInputPriority() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_TODO) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
            return requiredInput;
        }

        return nonRequiredInput;
    }

    public String getRequiredInputMajorFuncArea() {
        return nonRequiredInput;
    }

    public String getRequiredInputMinorFuncArea() {
        return nonRequiredInput;
    }
    
    public String getRequiredInputCsContact() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
            return requiredInput;
        }

        return nonRequiredInput;
    }
        

    public String getRequiredInputSubject() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) || recordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_TODO) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
            return requiredInput;
        }

        return nonRequiredInput;
    }

    public String getRequiredInputFoundInBuild() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME)) {
            return requiredInput;
        }

        return nonRequiredInput;
    }

    public String getRequiredInputScrumteam() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) || recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
            return requiredInput;
        }

        return nonRequiredInput;
    }

    public String getRequiredInputScheduledBuild() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME)) {
            return requiredInput;
        }

        return nonRequiredInput;
    }

    public String getRequiredInputAssignee() {
        if(recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) || getRecordType().Name.toLowerCase() == ADM_Work.RECORD_TYPE_NAME_TODO) {
            return requiredInput;
        }

        return nonRequiredInput;
    }

    private void setUser() { this.user = ADM_WorkUser.get(UserInfo.getUserId()); }

    public User getUser() { return this.user; }

    private Map<String, ADM_Build__c> validateBuilds(List<String> buildNames) {
        //validate build against External ID (which holds the build name) because external ID is case sensitive
        List<ADM_Build__c> builds = [select id, Name, External_ID__c from ADM_Build__c where External_ID__c in :buildNames];
        Map<String, ADM_Build__c> buildsMap = new Map<String, ADM_Build__c>();
        if(!builds.isEmpty()) {
            for(ADM_Build__c b : builds) {
                buildsMap.put(b.External_ID__c, b);
            }
        }
        return buildsMap;
    }

    static testMethod void testValidateBuild() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        ADM_Build__c tBuild = ADM_Build.createTestBuild();
        List<String> buildNames = new List<String>();
        buildNames.add('grendel');
        Map<String, ADM_Build__c> mBuild = wrl.validateBuilds(buildNames);
        System.assert(mBuild.keySet().size() == 0);
        buildNames.clear();
        buildNames.add(tBuild.Name);
        mBuild = wrl.validateBuilds(buildNames);
        System.assert(mBuild != null);
        ADM_Build__c vBuild = mBuild.get(tBuild.Name);
        System.assert(tBuild.id == vBuild.id);

    }

    private void validateWork() {
        //combine retrieval of found in build and scheduled build if populated
        String requiredFieldMessage = ' is a required field.';
        List<String> buildNames = new List<String>();
        String fBuildName = work.Found_In_Build_Copy__c;
        String sBuildName = work.Scheduled_Build_Copy__c;
        /******************************************
        *
        * Common Validation shared between record types
        *
        ******************************************/        
        ADM_Work.WorkType workType = ADM_Work.getWorkType(recordType);
        String tagInput =  System.currentPageReference().getParameters().get('productTagInput');
        
        if(workType.isRequiredField('Product_Tag__c') && isBlank(work.Product_Tag__c) && tagInput != null) {
            //user may have hit save before the Product Tag id could be populated.  Attempt to populate if the name is unique
            try {
                
                List<ADM_Tag_Assignment__c> tags = [select Product_Tag__c from ADM_Tag_Assignment__c where Product_Tag__r.Name =:tagInput and Product_Tag__r.Active__c =:true and Record_Type__c =:recordType.Name ];
                if(tags != null && tags.size() == 1) {
                    work.Product_Tag__c = tags.get(0).Product_Tag__c;        
                } else if(tags.size() > 1) {
                    work.addError(tagInput + ' product tag is used by more then one team.  Please specifiy the version of the tag you intended by selecting one of the auto-suggestions.');
                } else if(tagInput.trim() == '') {
                    work.addError('Product Tag is a required field. Please specifiy a product tag by entering a tag or team name and selecting one of the suggestions.');
                } else {
                     work.addError(tagInput + ' is not a valid tag name for this record type.  Please enter a tag or team name to see the valid suggestions.');
                }  
            } catch(System.exception e) {
                
            }
            
        } else if(workType.isRequiredField('Product_Tag__c') && isBlank(work.Product_Tag__c)) {
            work.addError('Product Tag' + requiredFieldMessage );
        }
        
        
        if(!isBlank(fBuildName)) {
            buildNames.add(fBuildName);
        }
        
        if(!isBlank(sBuildName)) {
            buildNames.add(sBuildName);
        }
        
        Map<String, ADM_Build__c> buildMap = new Map<String, ADM_Build__c>();
        buildMap = validateBuilds(buildNames);
        
        if(!isBlank(fBuildName)) {
            if(buildMap.containsKey(fBuildName)) {
                work.Found_In_Build__c = buildMap.get(fBuildName).id;
            } else {
                work.addError('Found In Build contained an invalid Build, ' + work.Found_in_Build_Copy__c + ', name (lookup to the Build object).');
            }
        } else {
            //found in build is null or empty.  This is valid for some record types such as Templates
            work.Found_In_Build__c = null;
        }
        
        if(!isBlank(sBuildName)) {
            if(buildMap.containsKey(sBuildName)) {
                work.Scheduled_Build__c = buildMap.get(sBuildName).id;
            } else {
                work.addError('Scheduled Build contained an invalid Build, ' + work.Scheduled_Build_Copy__c + ', name (lookup to the Build object)');
            }
        } else {
            work.Scheduled_Build__c = null;
        }
        
        /******************************************
        *
        * Record Type dependent validation
        *
        ******************************************/
        
        if(recordType.Name.equalsIgnoreCase(adm_work.BUG_RECORD_TYPE_NAME)) {
            
            //check to make sure all the required fields have been completed or add an error message
            if(workType.isRequiredField('Status__c' ) && isBlankOrNone(work.Status__c)) {
                work.addError('Status' + requiredFieldMessage);
            }
            if(workType.isRequiredField('Type__c' ) && isBlankOrNone(work.Type__c)) {
                work.addError('Type' + requiredFieldMessage);
            }
            if(workType.isRequiredField('Priority__c' ) && isBlankOrNone(work.Priority__c)) {
                work.addError('Priority' + requiredFieldMessage);
            }
            
            if(workType.isRequiredField('Minor_Func_Area__c' ) && isBlankOrNone(work.Minor_Func_Area__c)) {
                work.addError('Minor Functional Area' + requiredFieldMessage);
            }
            if(workType.isRequiredField('Subject__c' ) && isBlankOrNone(work.Subject__c)) {
                work.addError('Subject' + requiredFieldMessage);
            }

            if(workType.isRequiredField('Found_In_Build__c' ) && isBlank(fBuildName)) {
                work.addError('Found In Build' + requiredFieldMessage);
            }

            if(workType.isRequiredField('Scheduled_Build__c' ) && isBlank(sBuildName)) {
                if(work.Type__c == ADM_Work.BUG_TYPE_PICKLIST_ENTRY) {
                    work.addError('Scheduled Build' + requiredFieldMessage);
                }
            }
            
            if (work.Details_and_Steps_to_Reproduce__c != null && work.Details_and_Steps_to_Reproduce__c.length() > 30000) {
                work.addError('Details and Steps to Reproduce cannot be longer than 30,000 characters.');
            }
            
            if (work.Description__c != null && work.Description__c.length() > 31000) {
                work.addError('A single comment cannot be longer than 31,000 characters. Consider using an attachment or linking to the source system.');
            }
            
            

           if(work.Type__c != null && ADM_Work.TYPES_WHERE_FREQUENCY_APPLIES.contains(work.Type__c)) {
                if(work.Frequency__c == null) {
                    work.addError('Frequency' + requiredFieldMessage);
                } else {
                    if((work.Priority__c != priorityCurrent && work.Priority__c != getCalculatedPriority()) || (work.Priority__c != getCalculatedPriority() && priorityCurrent == null) || (priorityPreExisting != null && work.Priority__c != getCalculatedPriority())) { //this logic has to support both pre existing as well as new work records
                        if(work.Priority_Override_Explanation__c.equalsIgnoreCase(ADM_Work.PRIORITY_OVERRIDE_EXPLANATION) || work.Priority_Override_Explanation__c == '') {
                            work.addError('The Priority has been overridden. Reason for Override' + requiredFieldMessage);
                        }
                    }
                }
            }


            if(ADM_Work.BUG_RECORD_TYPE_REQ_FIELDS.contains('Impact__c' ) && work.Impact__c == null) {
                work.addError('Impact' + requiredFieldMessage);
            }

        } else if(recordType.Name.equalsIgnoreCase(ADM_Work.TEMPLATE_RECORD_TYPE_NAME)) {
            
            if(workType.isRequiredField('Template_Name__c' ) && isBlank(work.Template_Name__c)) {
                work.addError('Template Name' + requiredFieldMessage);
            }
            if(workType.isRequiredField('Template_Description__c') && isBlank(work.Template_Description__c)) {
                work.addError('Template Description' + requiredFieldMessage);
            }
            //for templates only validate Parent Work ID
            if(work.Parent_ID__c != null) {
                List<String> trimmedWorkItems = ADM_ParentWork.trimWorkItems(ADM_ParentWork.splitWorkItems(work.Parent_ID__c));
                List<ADM_Work__c> validatedWorkItems = ADM_ParentWork.validateWorkItems(trimmedWorkItems);
                if(trimmedWorkItems.size() > validatedWorkItems.size()) {
                     //validated list is smaller so trimmed list must contain invalid Work-ID
                     if (trimmedWorkItems.size() == 1) {
                            work.addError('Invalid Parent Work ID.');
                     } else {
                            work.addError('At least one Parent Work ID is invalid');
                     }
                }
                //make sure none of the validated work items match the current work record

                for(ADM_Work__c validWork : validatedWorkItems) {
                    if(validWork.id == work.id) {
                        //parent ID cannot be set to your own id
                        work.addError('Invalid Parent Work ID.  Work item cannot be related to itself.');
                    }
                }
            }
        } else if(recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_TODO)) {
            
            if(workType.isRequiredField('Assignee__c' ) && isBlank(work.Assignee__c)) {
                work.addError('Assignee' + requiredFieldMessage);
            }
            if(workType.isRequiredField('Subject__c' ) && isBlankOrNone(work.Subject__c)) {
                work.addError('Subject' + requiredFieldMessage);
            }
            if(workType.isRequiredField('Status__c' ) && isBlankOrNone(work.Status__c)) {
                work.addError('Status' + requiredFieldMessage);
            }
            if(workType.isRequiredField('Priority__c' ) && isBlankOrNone(work.Priority__c)) {
                work.addError('Priority' + requiredFieldMessage);
            }
        } else if(recordType.Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
            
            //TODO: move work modifications out of the validation method 
            work.Priority__c = null;

            if (work.Details_and_Steps_to_Reproduce__c != null && work.Details_and_Steps_to_Reproduce__c.length() > 30000) {
                work.addError('Details and Steps to Reproduce cannot be longer than 30,000 characters.');
            }

        }
        
        //TODO: move work modifications out of the validation method
        work.Priority_Default__c = getCalculatedPriority();
        
    }

    public PageReference nullReturn() { return null; }

    public PageReference cloneWork() {
        PageReference pr = Page.ADM_WorkEdit;
        pr.setRedirect(true);
        String id = System.currentPageReference().getParameters().get('id');
        pr.getParameters().put('id',id);
        pr.getParameters().put('clone','1');
        pr.getParameters().put('retURL','/' + work.id);
        return pr;
    }

    static testMethod void testCloneWork() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        PageReference clone = wrl.cloneWork();
        System.assert(clone.getParameters().get('clone') == '1');
    }


    public PageReference saveAndView() {
        return saveAndView(false);
    }

    public Pagereference saveAndView(Boolean view) {
        
        validateWork();
        //mark the origin of this work record - useful for validation to know where the changes were made
        work.Origin__c = ADM_WorkTriggerStaticDataStore.EDIT_PAGE_ORIGIN;

        String retUrl = System.currentPageReference().getParameters().get('retUrl');
        PageReference pr;

        ADM_TextUtils textUtil = new ADM_TextUtils();

        try {
            
            ADM_NotificationUtils.validateEncodedRecipients(this.HiddenReps);
            
            //store receipients so they can be processed by the Work after trigger
            work.Encoded_Recipients_Txt_Area__c = this.HiddenReps;
        } catch (ADM_UnexpectedValueException ue) {
            work.addError('"' + textUtil.unEscapeHTML(ue.unexpectedValue) + '" is not a valid entry for other recipients. Please enter the name of a GUS user or email address.  Users must be active and email addresses must end in "salesforce.com"');
            
        } catch (System.exception e) {
            
        }
        
        if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
            if(work.Details__c != null && details != null && work.Details__c.equalsIgnoreCase(details.fieldLabel)) work.Details__c = null;
            try{
                Database.UpsertResult result = Database.upsert(work);
                
                if(result.isSuccess()) {
                    String id = result.getId(); 
                    
                    if(!view) {
                        if(isClone || isNewWork) {
                            pr = new PageReference('/' + id);
                        } else if(retUrl != null && retUrl.length() > 0){
                            pr = new PageReference(retUrl);
                        } else {
                            pr = new PageReference('/' + id);
                        }
                    } else {
                        pr = pr = Page.ADM_selectWorkRecordType;
                    }

                    pr.setRedirect(true);
                    return pr;
                }
            } catch (System.DmlException e) {
                
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    if (e.getDmlMessage(i).contains('INVALID_EMAIL_ADDRESS')) {
                        // Invalid email address error needs to be reformatted.
                        String errorMessage = e.getDmlMessage(i);
                        String distListOnWorkSubscriber = ADM_ConstantsSingleton.getInstance().getNameSpace() + 'Distribution_List__c';
                        String textBeforeInvalidEmail = 'INVALID_EMAIL_ADDRESS, Distribution List: invalid email address: ';
                        String textAfterInvalidEmail = ': ['+distListOnWorkSubscriber+']';
                        Integer invalidEmailStart = errorMessage.indexOf(textBeforeInvalidEmail) + textBeforeInvalidEmail.length();
                        Integer invalidEmailEnd = errorMessage.indexOf(textAfterInvalidEmail);
                        String invalidEmail = errorMessage.substring(invalidEmailStart, invalidEmailEnd);
                        work.addError(textUtil.unEscapeHTML(invalidEmail) + ' is not a valid email address on other recipients.');
                    } else {
                        work.addError(e.getDmlMessage(i));
                    }
                }
            }
        }

        return null;
    }



    static testMethod void testSaveAndView() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        wrl.saveAndView();
        System.assertEquals(1, [select count() from ADM_Work__c where id = : work.id]);
    }

    // commenting this out for right now because i don't think it is necessary to have this here since we are only extending the controller and will make use oseverity the standardController method instead
    public PageReference saveAndNew() {
        return saveAndView(true);
    }

    static testMethod void testSaveAndNew() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        wrl.saveAndNew();
        System.assertEquals(1, [select count() from ADM_Work__c where id = : work.id]);
    }

    public PageReference cancel(){
        String retUrl = System.currentPageReference().getParameters().get('retUrl');
        PageReference pr;

        try {
            if(retURL != null && retURL != 'null' && retURL.startsWith('/') && retURL.length() > 1) {
                pr = new PageReference(retUrl);
                pr.setRedirect(true);
            } else if(work != null && work.id != null) {
                
                pr = new PageReference('/' +  work.id);
                pr.setRedirect(true);
            } else {
                pr = new PageReference('/home/home.jsp');
                pr.setRedirect(true);
            }
        } catch (System.NullPointerException npe) {
             try {
                
                pr = new PageReference('/home/home.jsp');
                pr.setRedirect(true);
             } catch (System.Exception e) {
                
                return null;
             }
        }
        return pr;
    }

/**
 * @testcaseID a0B20000009fMeXEAU
 * @userStory a07B0000000Dj9a
 * @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-793730
 * @expectedResults User stays on the bug edit page
 */
 /**
 * @testcaseID a0B20000009fMeYEAU
 * @userStory a07B0000000Dj9a
 * @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-793730
 * @expectedResults User stays on the bug edit page
 */
 /**
 * @testcaseID a0B20000009fOGOEA2
 * @userStory a07B0000000Dj9a
 * @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-793730
 * @expectedResults User is returned to the edit page
 */
 /**
 * @testcaseID a0B20000009fOGPEA2
 * @userStory a07B0000000Dj9a
 * @hierarchy GUS.BugforceToGUS.Bugs in GUS.W-793730
 * @expectedResults  User is returned to the edit page
 */
    static testMethod void testCancel() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.currentPage().getParameters().put('retUrl', '/' + work.Found_In_Build__c);
        ApexPages.currentPage().getParameters().put('id', work.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        PageReference pr = wrl.cancel();
        System.assert(pr != null);
        System.assert(pr.getUrl() != null);
        //user should be redericted to the build detail page
        System.assert(pr.getUrl().contains(work.Found_In_Build__c));
        //repeat with invalid URL (just a slash)
        ApexPages.currentPage().getParameters().put('retUrl', '/');
        ApexPages.currentPage().getParameters().put('id', work.id);
        pr = wrl.cancel();
        System.assert(pr != null);
        System.assert(pr.getUrl() != null);
        //user should be sent to work detail page for invalid URL
        System.assert(pr.getUrl().contains(work.id));
        //repeat with empty URL
        ApexPages.currentPage().getParameters().put('retUrl', ''); 
        ApexPages.currentPage().getParameters().put('id', work.id);
        pr = wrl.cancel();
        System.assert(pr != null);
        System.assert(pr.getUrl() != null);
        //user should be sent to work detail page for invalid URL
        System.assert(pr.getUrl().contains(work.id));

    }
    
    //used to return the work record of interest
    public ADM_Work__c getWork() { return this.work; }

    static testMethod void testGetWork() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        System.assert(wrl.getWork() != null);
        wrl.setWork(work);
        System.assert(wrl.getWork() != null);
    }

    public void setWork(ADM_Work__c w) { this.work = w; }
    
    

    // Getter for the workType value
    public String getWorkType() { return this.workType; }

    // Setter for the workType value
    public void setWorkType(String s) {
        
        this.workType = s;
        if(s == null) {
            clearWorkType();
        }
        List<String> values = new List<String>();
        values.add(s);
         //JH: Why is this a loop?
         for( ADM_Type__c el : ADM_Type.getAllBy('id',values) ) {
             work.Type__c = el.Name;
         }
        
        //sometimes we are not getting an ID back. we will need to set the value to s
        if(work.Type__c == null) {
            
            work.Type__c = s;
        }
    }

    public void clearWorkType() {
        this.workType = null;
        work.Type__c = null;
    }

    static testMethod void testWorkType() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        wrl.setWorkType('Bug');
        System.assertEquals('Bug', wrl.getWorkType());
        wrl.clearWorkType();
        System.assert(wrl.getWorkType() == null);
    }
   
    public void setSeverityLevel(String s) {
      work.Severity_Level__c = s;

    }

    //the on change event handler for the type picklist is tied to this method. If your change triggers
    //visual feedback then you also need to update the rerender attribute of the actionSupport visual force tag.
    public void handleTypeOnChangeEvent() {
        
        work.Impact__c = null;
        work.Frequency__c = null;
    }

    // Getter for the product area value
    public String getProductArea() { return work.Product_Area__c; }

    // Setter for the product area value
    public void setProductArea(String s) {
        work.Product_Area__c = s;        
        
    }

    // Clear the product area
    public void clearProductArea() { setProductArea(null); }

    public void clearProductAreaDependents() {
        clearMajorFunctionalArea();
    }

    public void clearAllProductAreaRelated() {
      clearProductArea();
      clearProductAreaDependents();
    }



    static testMethod void testProductAreas() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        /*TODO FIX WITH METADATA CALL**** AW ****
        wrl.setProductArea(testProductArea);
        System.assertEquals(testProductArea, wrl.getProductArea());
        */
        wrl.clearProductArea();
        System.assert(wrl.getProductArea() == null);
    }

    // Getter for the major functional area
    public String getMajorFunctionalArea() { return work.Major_Func_Area__c; }

    // Setter for the major functional area
    public void setMajorFunctionalArea(String s) {
        work.Major_Func_Area__c = s;
    }
    
    public void setAttributes(String s) {
        work.Attributes__c = s;
    }

    // Clear the major functional area
    public void clearMajorFunctionalArea() { setMajorFunctionalArea(null); }

    // Getter for the priority
    public String getPriority() { return this.priority; }

    // Setter for the priority
    public void setPriority(String s) {
        work.Priority__c = s;
    }

    public void setPriority() {
      work.Priority__c = this.priorityNew;
      work.Priority_Override_Explanation__c = this.priorityExplanationNew;
    }

    public Boolean getIsWorkTemplate() { return this.isWorkTemplate; }

    public void setIsWorkTemplate(Boolean b) { this.isWorkTemplate = b; }

    static testMethod void testWorkTemplates() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        wrl.setIsWorkTemplate(true);
        System.assertEquals(true, wrl.getIsWorkTemplate());
    }

    public String getTabStyle() { return this.tabStyle; }

    public void setTabStyle(String el) { this.tabStyle = el; }

    static testMethod void testTabStyles() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        wrl.setTabStyle('Work');
        System.assertEquals('Work', wrl.getTabStyle());
    }

    public Boolean getIsClone() { return this.isClone; }

    public void setIsClone(Boolean b) { this.isClone = b; }

    static testMethod void testClone() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        wrl.setIsClone(true);
        System.assertEquals(true, wrl.getIsClone());
    }

    public Boolean getIsNewWork() { return this.isNewWork; }

    public void setIsNewWork(Boolean b) { this.isNewWork = b; }

    public Boolean getIsNewRecordType() { return this.isNewRecordType; }
    
    public void setIsNewRecordType(Boolean b) { this.isNewRecordType = b; }
    
    static testMethod void testNewWork() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        wrl.setIsNewWork(true);
        System.assertEquals(true, wrl.getIsNewWork());
    }

    static testMethod void testNewRecordType() {
        ADM_Work__c work = ADM_Work.createTestWork();
        System.currentPageReference().getParameters().put('id', work.id);
        System.currentPageReference().getParameters().put('RecordType', ADM_Work.RECORD_TYPE_NAME_USERSTORY);
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(work);
        ADM_WorkControllerExtension ext = new ADM_WorkControllerExtension(controller);
        System.assertEquals(true, ext.getIsNewRecordType());
    }

    public List<Selectoption> getPriorities() {
        Schema.DescribeFieldResult fieldResult = ADM_Work__c.Priority__c.getDescribe();
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
        List<Selectoption> options = new List<Selectoption>();

        for(Schema.Picklistentry ple : ples) {
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }

        return options;
    }

    //beginning this work cuz it looks like VF inputField is not picking up the record type related pick list values :(
    public List<Selectoption> getStatuses() {
        List<Selectoption> options = new List<Selectoption>();
        Map<String, List<String>> statusValues = ADM_Work.getStatusValues();

        for(String statusValue : statusValues.get(recordType.Name)) {
            options.add(new Selectoption(statusValue, statusValue));
        }

        return options;
    }
    
    /**
     * @author jared.pearson@
     */
    static testMethod void testGetStatusesForBug() {
        ADM_Work__c bug = ADM_Work.createTestBug();
        
        Apexpages.Standardcontroller stdCtlrBug = new Apexpages.Standardcontroller(bug);
        ADM_WorkControllerExtension ctlrExtBug = new ADM_WorkControllerExtension(stdCtlrBug);
        
        System.assert(ctlrExtBug.getStatuses() != null);
    }
    
    /**
     * @author jared.pearson@
     */
    static testMethod void testGetStatusesForTodo() {
        ADM_Work__c todo = ADM_Work.createTestTodo();
        
        Apexpages.Standardcontroller stdCtlrTodo = new Apexpages.Standardcontroller(todo);
        ADM_WorkControllerExtension ctlrExtTodo = new ADM_WorkControllerExtension(stdCtlrTodo);
        
        System.assert(ctlrExtTodo.getStatuses() != null);
    }

    /**
     * @author jared.pearson@
     */
    static testMethod void testGetStatusesTemplate() {
        ADM_Work__c template = ADM_Work.createTestTemplate();

        Apexpages.Standardcontroller stdCtlrTemplate = new Apexpages.Standardcontroller(template);
        ADM_WorkControllerExtension ctlrExtTemplate = new ADM_WorkControllerExtension(stdCtlrTemplate);

        System.assert(ctlrExtTemplate.getStatuses() != null);
    }

    // Getter which dynamically generates the categories from the ADM_Type__c object.
    public List<SelectOption> getWorkTypes() {
        List<SelectOption> options = new List<SelectOption>();
        List<ADM_Type__c> els = ADM_Type.getAll();
        options.add(new SelectOption('', '--None--'));
        //getting ready to add new stuff in here to support adding new values on the fly
        //options.add(new SelectOption('New','New'));
        /* Loop through the severity_workType__c records creating a selectOption
         for each result with the record ID as the value and the name as the label
         displayed in the selectList */
        for (ADM_Type__c el : els) {
            options.add(new SelectOption(el.id,el.name));
        }
        return options;
    }

    static testMethod void testWorkTypes() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        System.assert(wrl.getWorkTypes() != null);
    }

    // Getter which dynamically generates the categories from the ADM_Type__c object.
    public List<SelectOption> getPrioritiess() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('', '--None--'));
        options.add(new SelectOption(work.Priority__c,work.Priority__c));

        return options;
    }

    static testMethod void testPriorities() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        work.Priority__c = 'P1';
        wrl.setPriority('P1');
        wrl.setWork(work);
        List<SelectOption> options = wrl.getPriorities();
        System.assert(options != null);
        System.assert(options.size() > 1);
    }

    public Boolean getIsDisabledProductArea() {
      if(getRecordType().Name.equals(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
         if(work.Severity_Level__c == null || work.Severity_Level__c.length() == 0 || work.Severity_Level__c.equals('--None--')) {
             return true;

         } else {
             return false;

         }
      } else {
        return false;

      }

    }
    
    /*
        Block of code that is used to populate some of the values of the
        Work record by querying the related custom objects
    */
    // Hook to setter to populate the type of work
    public void populateWorkType() {
        ADM_Type__c typeOfWork = ADM_Type.get(getWorkType());
        if(typeOfWork != null) {
            setWorkType(typeOfWork.Id);
        }
        else{
            typeOfWork = ADM_Type.get('--None--');
            if(typeOfWork != null) {
                setWorkType(typeOfWork.Id);
            }
        }
    }

   
    
    static testMethod void testPopulation() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        work.Major_Func_Area__c = 'Accounting';
        wrl.setWork(work);
        wrl.populateIsWorkTemplate();
        wrl.populateWork();
        System.assertEquals('Accounting', wrl.getMajorFunctionalArea());
        System.assertEquals(false, wrl.getIsWorkTemplate());
    }

    private void setRecordType(RecordType el) {
        this.recordType = el;
    }

    public RecordType getRecordType() {
        return this.recordType;
    }

    public void populateIsWorkTemplate() {
        setIsWorkTemplate(false);
        setTabStyle('ADM_Work__c');

        if(getRecordType() != null && getRecordType().Name.EqualsIgnoreCase('template')) {
            setIsWorkTemplate(true);
            setTabStyle('ADM_Work_Template__c');
        }
    }

    /* VisualForce does not allow arguments to be passed to
    getter method so an implementation like this is not possible:


        public Boolean getLookUpField(String fieldname) {
            return fieldsBeingEdited.get(fieldname);
        }

    Instead we have a method for each field.  Component Binding
    should help with this in a future release allowing the method
    names AND field names to be passed as an attribute of
    an <apex:component> tag. */
    public PageReference saveAllUpdatedTasks() {
        validateWork();
        PageReference pr;

        if(ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
            try{
                Database.UpsertResult result = Database.upsert(work);
                if(result.isSuccess()) {
                    String id = result.getId();
                    if(retUrl == null) {
                        pr = new PageReference('/' + id);
                    }
                    else{
                        pr = new PageReference(retUrl);
                    }
                    pr.setRedirect(true);
                    return pr;
                }
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    work.addError(e.getDmlMessage(i));
                }
            }
        }
        return null;
    }

    public PageReference cancelAllUpdatedTasks() {
        populateWork();
        setWorkType(work.Type__c);
        setPriority(work.Priority__c);
        populateWorkType();
        populateIsWorkTemplate();
        return null;
    }

    static testMethod void testUpdatedTasks() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        PageReference pr = wrl.saveAllUpdatedTasks();
        pr = wrl.cancelAllUpdatedTasks();
        //stay on the same page
        System.assert(pr == null);
    }

    private void setType(String s) { work.Type__c = s; }

    private void setSubject(String s) { work.Subject__c = s; }

    private void setMinorFuncArea(String s) { work.Minor_Func_Area__c = s; }

    private void setWorkPriority(String s) { work.Priority__c = s; }
    
    private void setRelatedURL(String s) { work.Related_URL__C = s; }

    private void setDescription(String s) { work.Description__c = s; }

    private void setFtest(String s) { work.ftest__c = s; }
    
    private void setRegressed(String s) { work.Regressed__c = evalBoolean(s); }

    private void setSecurity(String s) { work.Security__c = evalBoolean(s); }

    private void setPriorityRank(String s) { work.Priority_Rank__c = evalDouble(s,'Priority Rank'); }

    private void setSprint(String s) { work.Sprint__c = evalSprint(s); }

    private void setScrumteam(String s) { work.Scrum_Team__c = evalScrumteam(s); }

    private void setProductTag(String tagName, String teamName, String recordType) { work.Product_Tag__c = evalProductTag(tagName, teamName, recordType); }
    

    private void setStoryPoints(String s) { work.Story_Points__c = evalDouble(s,'Story Points'); }

    private String evalSprint(String s) {
        ADM_Sprint__c[] els = [select Id from ADM_Sprint__c where Name = :s];

        if(els.size() == 1) {
            return els[0].Id;
        }

        work.addError('No sprints were found with the provided name: ' + s);
        return null;
    }

    private String evalScrumteam(String s) {
        ADM_Scrum_Team__c[] els = ADM_ScrumTeam.get('Name',new List<String>{s});

        if(els.size() == 1) {
            return els[0].Id;
        }

        return null;
    }
    
    private String evalProductTag(String tagName, String teamName, String recordType) {
        try {
            List<ADM_Product_Tag__c> tags = [select id from ADM_Product_Tag__c where Active__c = true and Name =:tagName and Team__r.Name =:teamName and Id in (select Product_Tag__c from ADM_Tag_Assignment__c where Record_Type__c = :recordType) limit 1];
            if(tags.isEmpty()) {
                
                return null;
            } else {
                return tags.get(0).id;
            }
        } catch(Exception e) {
            
        }
        return null;
    }

    private Double evalDouble(String s, String fieldName) {
        if(Pattern.matches('\\d.*',s)) {
            return Double.valueOf(s);
        }
        work.addError(' Unsupported value entered : ' + fieldName + ' - ' + s + ' ');
        return null;
    }

    private Boolean evalBoolean(String s) {
        if(s.equalsIgnoreCase('true')) {
            return true;
        } else if(s.equalsIgnoreCase('false')) {
            return false;
        } else if(s.contains('1')) {
            return true;
        } else if(s.contains('0')) {
            return false;
        } else {
            //FYI apex currently won't allow re-use of System.TypeException or generic System.Exception hence custom class created
            throw new ADM_UnexpectedValueException('Provided string must be of the type: true or false, 1 or 0');
        }
    }

    static testMethod void testEvalBoolean() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        System.assert(wrl.evalBoolean('1') == true);
        System.assert(wrl.evalBoolean('0') == false);
        System.assert(wrl.evalBoolean('true') == true);
        System.assert(wrl.evalBoolean('TRUE') == true);
        System.assert(wrl.evalBoolean('false') == false);
        System.assert(wrl.evalBoolean('FALSE') == false);
        try {
            wrl.evalBoolean('garbage');
            System.assert(false, 'An ADM_UnexpectedValueException should have been thrown before you reached here');

        } catch(ADM_UnexpectedValueException e) {
            System.assert(true);
        }

    }

    private void setCustomer(String s) { work.Customer__c = s; }

    private void setStatus(String s) { work.Status__c = s; }

    private void setParentID(String s) { work.Parent_ID__c = s; }

    private void setChildID(String s) { work.Child_ID__c = s; }

    private void setImpact(String s) {
        Selectoption[] els = getImpacts();

        for(Selectoption el :els) {
            if(el.getLabel().equalsIgnoreCase(s)) {
                work.Impact__c = el.getValue();
                continue;
            }
        }

        if(work.Impact__c == null) {
            work.addError('An impact value was not found for the value entered over the URL: ' + s);
        }
    }

    private void setFrequency(String s) {
        Selectoption[] els = getFrequencies();

        for(Selectoption el :els) {
           if(el.getLabel().equalsIgnoreCase(s)) {
               work.Frequency__c = el.getValue();
               continue;
           }
        }

        if(work.Frequency__c == null) {
            work.addError('A frequency value was not found for the value entered over the URL: ' + s);
        }
    }

    private void setScheduledBuild(String s) {
        //locate Scheduled Build based on the name
        List<ADM_Build__c> builds = [select id, Name from ADM_Build__c where Name = :s];
        if(builds != null && builds.size() > 0) {
            work.Scheduled_Build_Copy__c = builds.get(0).Name;
        }
    }

    private void setFoundInBuild(String s) {
        //locate Found In Build based on the name
        List<ADM_Build__c> builds = [select id, Name from ADM_Build__c where Name = :s];
        if(builds != null && builds.size() > 0) {
            work.Found_In_Build_Copy__c = builds.get(0).Name;
        }
    }

    static testMethod void testSetBuilds() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        ADM_Build__c build = ADM_Build.createTestBuild();
        wrl.setScheduledBuild(ADM_Build.TEST_BUILD_NAME);
        wrl.setFoundInBuild(ADM_Build.TEST_BUILD_NAME);
        //verfiy scheduled build was popualted
        System.assert(wrl.getWork().Scheduled_Build_Copy__c != null);
        System.assert(wrl.getWork().Scheduled_Build_Copy__c == build.Name);
        //repeat for found in build
        System.assert(wrl.getWork().Found_In_Build_Copy__c != null);
        System.assert(wrl.getWork().Found_In_Build_Copy__c == build.Name);


    }

    private RecordType getRecordTypeFromUrl(String fieldFromUrl) {
        RecordType recordType = null;
        try {
            
            String sobjectTypeName = ADM_ConstantsSingleton.getInstance().getNameSpace() + 'ADM_Work__c';

            List<RecordType> types = [select id, name from RecordType where Name = :fieldFromUrl and SobjectType = :sobjectTypeName limit 1];
            if(!types.isEmpty()) {
                recordType = types.get(0);
            }
        } catch(System.QueryException e) {
            work.addError('An error occurred getting the record type with the value provided over the URL, ' + fieldFromUrl + ', resulting in the following error: ' + e.getMessage());
        }
        return recordType;
    }

    private String getRecordTypeIdFromUrl(String fieldFromUrl) {
        String recordTypeId;
        try {
            RecordType recordType = getRecordTypeFromUrl(fieldFromUrl);
            if(recordType == null) {
                recordTypeId = '';
            } else {
                recordTypeId = String.valueOf(recordType.Id);
            }
        } catch(System.QueryException e) {
            work.addError('An error occurred getting the record type with the value provided over the URL, ' + fieldFromUrl + ', resulting in the following error: ' + e.getMessage());
            recordTypeId = '';
        }
        return recordTypeId;
    }

    private void setRecordTypeId(String Id) {
        work.RecordTypeId = Id;
    }

    
    
    /*
        Maintain backwards compatibility for poor mans api - creating work records via HTTP GET by populating parameters over the URL. 
         Has benefit that the page is only populated, not saved so the user can tweak the data first.  Perfect candidate for selenium test.  
    
    */
    private void setWorkValuesFromUrl() {
            this.work = ADM_Work.setWorkValuesFromUrl(this.work);
    }  

    //used to set the ADM_Work__c object (record the user is working with) to the values already inserted into the database
    private void populateWork() {
        RecordType recordType;
        String id = System.currentPageReference().getParameters().get('id');        
        String recordTypeId = System.currentPageReference().getParameters().get('RecordType');
        ADM_Work__c w;
        ADM_Work__c workClone;
        //if we don't have an ID we have to assume this is a new work record request
        if(id != null) {
            w = ADM_Work.getOneBy('id',id);
            if (recordTypeId != null) {
                setIsNewRecordType(true);
            }
            
        }
        else{
            w = (ADM_Work__c)stdC.getRecord();
            setIsNewWork(true);
        }
        
        if(clonePageVar != null && clonePageVar.equalsIgnoreCase('1')) {
            workClone = w.clone(CLONE_OPTION_PRESERVE_ID, CLONE_OPTION_IS_DEEP_CLONE);
            workClone = ADM_WorkUtils.removeFieldsNotApplicableForClone(workClone);
            workClone = ADM_WorkUtils.initializeFieldsForClone(workClone);
            //if the parent ID field is already populated (as is the case with create work from template) use that otherwise copy relationships
            if(w.Parent_ID__c != null) {
                workClone.Parent_ID__c = w.Parent_ID__c;
            } else {
                workClone.Parent_ID__c = cloneParentChildRelationships(w.id);
            }
            setIsNewWork(true);
            w = workClone;
        }

        //if logical record type name is provided lookup the id.  Some consumers such as formula fields can't provide the id at run time
        String recordTypeLogicalName = System.currentPageReference().getParameters().get('RecordTypeLogicalName');
        if(recordTypeLogicalName != null) {
            String recordTypeIdFromLogicalName = getRecordTypeIdFromUrl(recordTypeLogicalName);
            if(recordTypeIdFromLogicalName != null && ADM_TextUtils.isValidIdFormat(recordTypeIdFromLogicalName)) {
               recordTypeId = recordTypeIdFromLogicalName;
            }
        }

        if(recordTypeId != null && recordTypeId.trim() != '') {
            try {
                w.recordTypeId = recordTypeId;
            } catch(System.StringException e) {
                w.addError(String.valueOf(e));
            }
        }

        //set the recordType according to what the id is
        if(recordTypeId == null && w.recordTypeId == null){
            Schema.DescribeSObjectResult workSchema = Schema.SObjectType.ADM_Work__c;
            List<Schema.RecordTypeInfo> workRecordTypeInfos = workSchema.getRecordTypeInfos();
            for(Schema.RecordTypeInfo workRecordTypeInfo : workRecordTypeInfos) {
                if((workRecordTypeInfo.getName().equalsIgnoreCase('Bug') || workRecordTypeInfo.getName().equalsIgnoreCase('Template'))
                    && workRecordTypeInfo.isDefaultRecordTypeMapping()) {
                    recordTypeId = workRecordTypeInfo.getRecordTypeId();
                    w.recordTypeId = recordTypeId;
                }
            }
        }

        recordType = ADM_RecordType.get(w.recordTypeId);

        if(recordType != null) {
            setRecordType(recordType);
        } else {
            w.recordTypeId = ADM_RecordType.getId('Bug');
            recordType = ADM_RecordType.get(w.recordTypeId);
            setRecordType(recordType);
            w.addError('An invalid record type was entered. The default record type of Bug is being used as an alternative.');
        }

        if(isNewWork) {
            
            w.Status__c = 'New';
            //initialize record type specific defaults
            if(clonePageVar == null || !clonePageVar.equalsIgnoreCase('1')) {
                ADM_Work__c[] lastWorks = [select Id, Type__c, Product_Area__c from ADM_Work__c where LastModifiedById =: this.user.Id and RecordTypeId =: recordType.Id order by LastModifiedDate desc limit 1];
                if(lastWorks.size() > 0) {
                    ADM_Work__c lastWork = lastWorks[0];
                    if(!ADM_TextUtils.isNull(lastWork.Product_Area__c)) {
                        w.Product_Area__c = lastWork.Product_Area__c;
                    }
                    if(!ADM_TextUtils.isBlank(lastWork.Type__c)) {
                        w.Type__c = lastWork.Type__c;
                    }
                }
            }
            if(getRecordType().Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_TODO)) {
                w.Priority__c = 'P4';
                w.Use_Prioritizer__c = false;
            } else if(getRecordType().Name.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY)) {
                
                w.Use_Prioritizer__c = true;
            } else if(getRecordType().Name.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME)) {
                w.Use_Prioritizer__c = false;
            } else if(getRecordType().Name.equals(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
                if(this.user.Profile.Name.equalsIgnoreCase('gus customer support user')) {
                    w.CS_Contact__c = Userinfo.getUserId();
                }
                w.Subscribe_to_Work__c = true;
                w.Use_Prioritizer__c = false;
                w.Email_On_Save__c = true;
            }
        }
        if(isClone || isNewWork) {
            if(getRecordType().Name.equalsIgnoreCase('Bug')) {
                w.Template_Description__c = null;
                w.Template_Name__c = null;
            }
        } else {
            if(w.Priority__c != null && w.Frequency__c == null && w.Impact__c == null) {
                this.priorityPreExisting = w.Priority__c;
            }
        }
        if(w.Number_of_Cases__c == null) {
            w.Number_of_Cases__c = 0;
        }

        if(w.Scheduled_Build__r != null) {
            w.Scheduled_Build_Copy__c = w.Scheduled_Build__r.Name;
        }
        if(w.Found_In_Build__r != null) {
            w.Found_In_Build_Copy__c = w.Found_In_Build__r.Name;
        }

        w.Priority_Override_Explanation__c = ADM_Work.PRIORITY_OVERRIDE_EXPLANATION;
        
        setWork(w);



    }

    /*
    @testcaseID a1DB00000001NpQ
    @userstory a07B0000000KzagIAC
    @Hierarchy GUS.ScrumforceToGUS.Work Page.Bug.Clone Page
    @Expected Results  The Number of changelists field value is not cloned from original work item
    @Author: James Hatton
    */

    testMethod static void testPopulateWork() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        wrl.populateWork();
        System.assert(wrl.getWork() != null);
        System.assert(wrl.getWork().RecordTypeId != null);
        //assert template fields were not populated
        System.assert(wrl.getWork().Template_Name__c == null);
        System.assert(wrl.getWork().Template_Description__c == null);
        //assert Number of Cases is equal to zero
        System.assert(wrl.getWork().Number_of_Cases__c == 0);
         //assert Number of Changelists is equal to zero
        System.assert(wrl.getWork().Number_of_Change_Lists__c == 0);

    }

    public String cloneParentChildRelationships(String workID) {
        //populate Parent_ID__c with comma seperated list of Work Names - relationships are created in trigger if this hidden field is populated
        String parentIDs = ADM_TextUtils.joinList(ADM_WorkTreeUtils.getParentNames(workID), ',');

        return parentIDs;
    }

    testMethod static void testCloneParentChildRelationships() {
        //create work object and relate to serveral parents
        ADM_Work__c original = [select id, RecordTypeId from ADM_Work__c where Id = :ADM_ParentWork.parentWorkTestSetupParents(2)];
        ApexPages.StandardController stdController = new ApexPages.StandardController(original);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        //verfiy that the hidden field Parent_ID__c is populated
        String parentIDs = wrl.cloneParentChildRelationships(original.id);
        System.assert(parentIDs != null);

    }

    public PageReference redirectToEmailAuthor() {

        PageReference emailAuthor = new PageReference('/_ui/core/email/author/EmailAuthor?p3_lkid=' + this.work.id);
        emailAuthor.setRedirect(true); //want to change the URL as a result of navigation
        emailAuthor.getParameters().put('p24',this.work.CreatedBy.Email);
        emailAuthor.getParameters().put('p6',this.work.Subject__c);
        emailAuthor.getParameters().put('retURL', '/' + this.work.id);


        return emailAuthor;
    }


    testMethod static void testRedirectToEmailAuthor() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        System.assert(wrl.redirectToEmailAuthor() != null);

    }

     public String getBugRecordTypeID() {
        RecordType recordType = [select Id from RecordType where Name = 'Bug'];
        return recordType.id;
    }

    testMethod static void testGetBugRecordTypeID() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        System.assert(wrl.getBugRecordTypeID() != null);
        //compare to manual lookup
        RecordType recordType = [select Id from RecordType where Name = 'Bug'];
        System.assert(wrl.getBugRecordTypeID() == recordType.id);
    }

    /* Getter which generates the options for the impacts selectList based on the current
    value of the selected workType. If there is no value selected then only
    the null option should be returned. */
    public List<SelectOption> getImpacts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        List<ADM_Impact__c> impactList = ADM_Impact.getAllByType(work.Type__c);
         for( ADM_Impact__c i : impactList) {
            options.add(new SelectOption(i.id, i.Name));
         }

        return options;
    }

    testMethod static void testGetImpacts() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        System.assert(wrl.getImpacts() != null);
        System.assert(wrl.getImpacts().size() > 0);
    }

    public List<SelectOption> getFrequencies() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        List<ADM_Frequency__c> frequencyList = ADM_Frequency.getAll();
         for( ADM_Frequency__c f : frequencyList) {
            options.add(new SelectOption(f.id, f.Name));
         }
        return options;
    }

    testMethod static void testGetFrequencies() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        System.assert(wrl.getFrequencies() != null);
        System.assert(wrl.getFrequencies().size() > 0);
    }
    
    public Boolean getIsDisabledImpacts() {
        if(work.Type__c != null) {
            return false;
        } else {
            return true;
        }
    }

    public Boolean getIsDisabledFrequencies() {
       if(ADM_Work.TYPES_WHERE_FREQUENCY_APPLIES.contains(work.Type__c)) {
            return false;
        } else {
            return true;
        }
    }

     public Boolean getIsDisabledPriority() {
       
       if(ADM_Work.TYPES_WHERE_PRIORITY_APPLIES.contains(work.Type__c)) {
            
            return false;
        } else {
            
            return true;
        }
    }

    public String getCalculatedPriority() {
       try {
            List<ADM_Priority_Mapping__c> pms = ADM_PriorityMapping.getByFrequencyAndImpact(work.Frequency__c, work.Impact__c);
            String calculatedPriority = null;

            if(pms == null || pms.size() ==0) {
                
                //dont update priority
            } else if (pms.size() > 1) {
                
                //dont update priority
            } else {
                calculatedPriority = pms[0].Priority__r.Name;
                work.Priority_Mapping__c = pms[0].Id;
            }
            return calculatedPriority;
        } catch (Exception e) {
            
            return null;
        }
    }

    public void calculatePriority() {
        //only update priority when the picklist is disabled otherwise in cases such as Feature Request you will refresh the priority picklist and loose the users input
        
        if(getIsDisabledPriority()) {
            work.Priority__c = getCalculatedPriority();
            //by request everytime 
            work.Priority_Override_Explanation__c = '';
        }
    }

    testMethod static void testCalculatePriority() {
        ADM_Work__c work = ADM_Work.createTestWork();
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_WorkControllerExtension wrl = new ADM_WorkControllerExtension(stdController);
        ADM_Frequency__c f = new ADM_Frequency__c (Name='Never Ending');
        insert f;
        ADM_Impact__c i = new ADM_Impact__c(Name='End of Days');
        insert i;

        ADM_Priority__c p = new ADM_Priority__c(Name='P99');
        insert p;
        ADM_Priority_Mapping__c pm = new ADM_Priority_Mapping__c(Impact__c = i.id, Frequency__c = f.id, Priority__c = p.id);
        insert pm;
        wrl.work.Type__c = 'Bug';
        wrl.work.Frequency__c = pm.Frequency__c;
        wrl.work.Impact__c = pm.Impact__c;
        wrl.calculatePriority();
        System.assert(wrl.work.Priority__c != null);
        System.assertEquals(p.Name, wrl.work.Priority__c);
        //verfiy the overide explanation has been reset
        System.assertEquals('', wrl.work.Priority_Override_Explanation__c);
    }
    
    public Schema.Sobjecttype getWorkSObjectType() {
        return ADM_Work__c.getSObjectType();
    }

    /**
     * Determines if the value specified is blank or null. Specifically the method
     * returns true when:
     *   - value is null or 
     *   - value is whitespace or
     *   - value is '--None--'
     */
    private static Boolean isBlankOrNone(String value) {
        return isBlank(value) || value == '--None--';
    }
    
    /**
     * Determines if the value specified is blank. Specifically the method
     * returns true when:
     *   - value is null or 
     *   - value is whitespace
     */
    private static Boolean isBlank(String value) {
        return ADM_TextUtils.isBlank(value);
    }
    
}