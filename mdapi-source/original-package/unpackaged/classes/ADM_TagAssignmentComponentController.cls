public with sharing virtual class ADM_TagAssignmentComponentController {
    
    private transient ADM_Product_Tag__c ptag;
    private transient Boolean pReadOnly = null;
    private transient Boolean showGuidedTour = null;
    
    public ADM_Product_Tag__c tag {
        get {
            if(ptag == null && tagID != null) {
                ptag = [select id, Name, Team__c from ADM_Product_Tag__c where id =:tagID];
            }
            return ptag;
        }
        set {
            ptag = value;
        }
    }
    
    public String tagID { 
        get;
        set;
    }
    
    public Boolean readOnly {
        get {
            if(this.pReadOnly == null) {
                if(tag == null) {
                    
                    return true;
                }
                
                
                pReadOnly = !isCurrentUserOnTeam(tag.Team__c);
            }
            
            return pReadOnly;
        }
        set {
            pReadOnly = value;
        }
    }
    
    /**
     * Gets true when the product tag guided tour should be shown.
     */
    public Boolean getShowGuidedTour() {
        try {
            if(this.showGuidedTour == null) {
                //retrieve the user preferences for the current user
                ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
                this.showGuidedTour = preferences.ShowProductTagAssignmentGuidedTour__c;
            }
            return this.showGuidedTour;
        
        } catch(Exception exc) {
            
            return false;
        }
    }
    
    private transient String pMatrixInfoMessageWrapperStyle = null;
    
    public String matrixInfoMessageWrapperStyle {
        get {
            if (this.pMatrixInfoMessageWrapperStyle == null) {
                Boolean foundAssignment = false;  
                            
                for (TeamRuleWrapper wrapper : getTeamRuleAssignments()) {
                    if (wrapper.bugAssigned || wrapper.storyAssigned || wrapper.investigationAssigned) {
                        foundAssignment = true;
                        break;
                    }
                }
                
                if (!readOnly && !foundAssignment) {
                    pMatrixInfoMessageWrapperStyle = '';
                } else {
                    pMatrixInfoMessageWrapperStyle = 'visibility:hidden';
                }
            }
            
            return pMatrixInfoMessageWrapperStyle;
        }
        set {
            pMatrixInfoMessageWrapperStyle = value;
        }
    }
    
    private transient String puserFullNameList;
    
   public String userFullNameList {
        get {
            if(puserFullNameList == null) {
                //get the list of user's full names
                puserFullNameList = '';
                //check if we're in the package and build users based on perm set
                ADM_ConstantsSingleton singletonConstants = ADM_ConstantsSingleton.getInstance();
                //if we're in the package we limit the user lookup to users with our package perm set.  Unless were running tests because we can't assign user perm sets in tests due to the error 'MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa)'
                if(singletonConstants.isPackagedOrg() && !Test.isRunningTest()) {
                    System.debug('userFullNameList() identified this is a packaged org');
                    //customer orgs can have over 100K active users so limit by perm set
                    List<PermissionSet> permSets =  [select id from PermissionSet where Name = 'Agile_Accelerator_User' or Name = 'Agile_Accelerator_Admin'];
                    Boolean isFirst = true;
                    for(User u : [Select Id, Name, SmallPhotoUrl From User Where IsActive = true and id in (select AssigneeId from PermissionSetAssignment where PermissionSetId in:permSets)]) {
                        System.debug('u:' + u);
                        if(!isFirst) {
                            puserFullNameList += ',';
                        }
                        puserFullNameList += u.Name;
                        isFirst = false;
                    }
                    System.debug('userFullNameList() puserFullNameList:' + puserFullNameList + ' permSets:' + permSets);
                } else {
                    System.debug('userFullNameList() this is NOT a packaged org');
                    Boolean isFirst = true;
                    for(User u : [Select Id, Name, SmallPhotoUrl From User Where IsActive = true limit 50000]) {
                        if(!isFirst) {
                            puserFullNameList += ',';
                        }
                        puserFullNameList += u.Name;
                        isFirst = false;
                    }
                }
                
                
            }
            return puserFullNameList;
        }
    }
    
    private List<TeamRuleWrapper> teamRuleAssignments;
    
    public List<TeamRuleWrapper> getTeamRuleAssignments() { 
        try {
            if((teamRuleAssignments == null || teamRuleAssignments.size() == 0) && tag != null) {
                teamRuleAssignments = populateTeamRuleAssignments(tag.Team__c, tag.id); 
            }
        } catch (Exception e) {
            
            teamRuleAssignments = new List<TeamRuleWrapper>();
        }
        
        return teamRuleAssignments;
    }
    
    private List<ADM_Assignment_Rule__c> getTeamRules(String teamID) {
        return [select id, Product_Owner__r.Name, Assignee_Assignment__r.Name, Sev_1_Assignee__r.Name, Sev_2_Assignee__r.Name, Sev_3_Assignee__r.Name, Sev_4_Assignee__r.Name, QA_Assignment__r.Name, Tech_Writer_Assignment__r.Name, Systest_Assignment__r.Name, UE_Engineer__r.Name, Senior_Management_POC_Assignment__r.Name, Exception_Request_POC__r.Name, Additional_Emails__c from ADM_Assignment_Rule__c where Inactive__c =:false and Scrum_Team_Assignment__c =: teamID order by CreatedDate DESC];
    }
    
    private List<TeamRuleWrapper> populateTeamRuleAssignments(String teamID, String tagID) {
        List<TeamRuleWrapper> wrappers = new List<TeamRuleWrapper>();
        
        //get the rules associated to the team
        List<ADM_Assignment_Rule__c> assignmentRules = getTeamRules(teamID);
        Set<Id> assignmentRuleIds = new Set<Id>();
        for(ADM_Assignment_Rule__c assignmentRule : assignmentRules) {
            assignmentRuleIds.add(assignmentRule.Id);
        }
        
        //get a list of tag assignments associated to the rules
        List<ADM_Tag_Assignment__c> assignments = [
            select 
                Id, 
                Record_Type__c, 
                Product_Tag__r.Id,
                Product_Tag__r.Name,
                Assignment_Rule__c
            from
                ADM_Tag_Assignment__c 
            where
                Product_Tag__c = :tagId or 
                Assignment_Rule__c in :assignmentRuleIds
        ];
        
        //filter the list of assignments to only those associated to the tag
        List<ADM_Tag_Assignment__c> tagAssignments = getAssignmentsForTag(assignments, tagId);
        
        //filter the list to only those assignments that are used by
        List<ADM_Tag_Assignment__c> usedByAssignments = getAssignmentsNotForTag(assignments, tagId);
        
        for(ADM_Assignment_Rule__c rule : assignmentRules) {
            Set<ADM_Product_Tag__c> usedBy = getTagsUsedBy(usedByAssignments, rule);
            
            TeamRuleWrapper trw = new TeamRuleWrapper(usedBy);
            trw.rule = rule;
            trw.readOnly = readOnly;
            trw = populateAssignment(trw, tagAssignments);
            wrappers.add(trw);
        }
        return wrappers;    
    }
    
    /**
     * Populates the assignment values on the wrapper given the assignments.
     */
    private TeamRuleWrapper populateAssignment(TeamRuleWrapper wrapper, List<ADM_Tag_Assignment__c> assignments) {
        
        for(ADM_Tag_Assignment__c assignment: assignments) {
            
            if(assignment.Assignment_Rule__c == wrapper.rule.id) {
                if(assignment.Record_Type__c == ADM_Work.BUG_RECORD_TYPE_NAME) {
                    wrapper.bugAssignment = assignment;
                    
                } else if(assignment.Record_Type__c == ADM_Work.RECORD_TYPE_NAME_USERSTORY) {
                    wrapper.storyAssignment = assignment;
                    
                } else if(assignment.Record_Type__c == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) {
                    wrapper.investigationAssignment = assignment;
                    
                }
            }
        }
        
        return wrapper;
        
    }
    
    /**
     * Gets all of the tag assignments for the specified tag ID 
     */
    private List<ADM_Tag_Assignment__c> getAssignmentsForTag(List<ADM_Tag_Assignment__c> assignments, String tagId) {
        List<ADM_Tag_Assignment__c> tagAssignments = new List<ADM_Tag_Assignment__c>();
        for(ADM_Tag_Assignment__c assignment: assignments) {
            if(tagId == assignment.Product_Tag__c) {
                tagAssignments.add(assignment);
            }
        }
        return tagAssignments;
    }
    
    /**
     * Gets all of the tag assignments that are not associated to tag ID. This
     * is the inverse of #getAssignmentsForTag 
     */
    private List<ADM_Tag_Assignment__c> getAssignmentsNotForTag(List<ADM_Tag_Assignment__c> assignments, String tagId) {
        List<ADM_Tag_Assignment__c> tagAssignments = new List<ADM_Tag_Assignment__c>();
        for(ADM_Tag_Assignment__c assignment: assignments) {
            if(tagId != assignment.Product_Tag__c) {
                tagAssignments.add(assignment);
            }
        }
        return tagAssignments;
    }
    
    /**
     * Gets a set of product tags that are used by the specified assignment rule. 
     *
     * More specifically, the set contains all product tags in which 
     * ADM_Tag_Assignment.Assignment_Rule equals the specified rule.
     */
    private Set<ADM_Product_Tag__c> getTagsUsedBy(List<ADM_Tag_Assignment__c> assignments, ADM_Assignment_Rule__c rule) {
        if(rule == null) {
            return new Set<ADM_Product_Tag__c>();
        }
        
        Set<ADM_Product_Tag__c> tagSet = new Set<ADM_Product_Tag__c>();
        for(ADM_Tag_Assignment__c assignment : assignments) {
            if(assignment.Assignment_Rule__c == rule.Id) {
                tagSet.add(assignment.Product_Tag__r);
            }
        }
        return tagSet;
    }
    
    /**
     * Gets the name of the current user. This is virtual to allow the test 
     * methods to override the name returned.
     */
    public virtual String getCurrentUserName() {
        return UserInfo.getName();
    }
    
    /**
     * Determines if the current user is on the specified team
     */
    private Boolean isCurrentUserOnTeam(String teamId) {
        String userName = getCurrentUserName();
        
        //get the list of memberships for the user
        List<ADM_Scrum_Team_Member__c> teamMemberships = [select Id, Name, Scrum_Team__c from ADM_Scrum_Team_Member__c where Member_Name__r.Name = :userName];
        
        //only allow team members to edit the product tag
        Boolean hasMembership = false;
        for(ADM_Scrum_Team_Member__c teamMembership : teamMemberships) {
            if(teamMembership.Scrum_Team__c == teamId) {
                hasMembership = true;
            }
        }
        
        
        return hasMembership;
    }
    
    @RemoteAction
    public static void unselectAssignmentRule(String currentTagID, String recordType) {
         if(recordType == 'story') recordType = 'User Story';
         removeTagAssignment(currentTagID, recordType);
    }
    
    @RemoteAction 
    public static void selectNewAssignmentRule(String ruleID, String recordType, String currentTagID) {
        
        
        ADM_TagAssignmentComponentController.saveNewTagAssignment(ruleID, recordType, currentTagID);
        
    }
    
        
    
    @RemoteAction
    public static void saveNewAssignmentRule(String productOwner, String assignee, String qe, String tw, String perfeng, String ue, String smpoc, String erpoc, String otherreps, Boolean useForBug, Boolean useForStory, Boolean useForInvestigation, String currentTagID, String scrumTeamID, String sev1Assignee, String sev2Assignee, String sev3Assignee, String sev4Assignee) {
      
         List<String> names = new List<String>{productOwner, assignee, qe, tw, perfeng, ue, smpoc, erpoc, sev1Assignee, sev2Assignee, sev3Assignee, sev4Assignee};
         Map<String, Id> userNameMap = getUserNameMap(names);
         
         ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
         
         
         if(userNameMap.containsKey(productOwner)) {
              rule.Product_Owner__c = userNameMap.get(productOwner);
         } else if(productOwner != null && productOwner != '') {
             throw new ADM_UnexpectedValueException(productOwner + ' is not an active user');
         } else {
            throw new ADM_UnexpectedValueException('Product Owner is a required field'); 
         } 
         
         if(userNameMap.containsKey(assignee) && (useForBug || useForStory)) {
              rule.Assignee_Assignment__c = userNameMap.get(assignee);
         } else if(assignee != null && assignee != '') {
             throw new ADM_UnexpectedValueException(assignee + ' is not an active user');
         } else if (useForBug || useForStory){
            throw new ADM_UnexpectedValueException('Assignee is a required field'); 
         }     
         
         if(userNameMap.containsKey(sev1Assignee) && (useForInvestigation)) {
              rule.Sev_1_Assignee__c = userNameMap.get(sev1Assignee);
         } else if(sev1Assignee != null && sev1Assignee != '') {
             throw new ADM_UnexpectedValueException(sev1Assignee + ' is not an active user');
         } else if (useForInvestigation) {
            throw new ADM_UnexpectedValueException('Sev 1 Assignee is a required field.'); 
         }
         
         if(userNameMap.containsKey(sev2Assignee) && (useForInvestigation)) {
              rule.Sev_2_Assignee__c = userNameMap.get(sev2Assignee);
         } else if(sev2Assignee != null && sev2Assignee != '') {
             throw new ADM_UnexpectedValueException(sev2Assignee + ' is not an active user');
         } else if (useForInvestigation) {
            throw new ADM_UnexpectedValueException('Sev 2 Assignee is a required field'); 
         } 
         
         if(userNameMap.containsKey(sev3Assignee) && (useForInvestigation)) {
              rule.Sev_3_Assignee__c = userNameMap.get(sev3Assignee);
         } else if(sev3Assignee != null && sev3Assignee != '') {
             throw new ADM_UnexpectedValueException(sev3Assignee + ' is not an active user');
         } else if (useForInvestigation) {
            throw new ADM_UnexpectedValueException('Sev 3 Assignee is a required field'); 
         } 
         
         if(userNameMap.containsKey(sev4Assignee) && (useForInvestigation)) {
              rule.Sev_4_Assignee__c = userNameMap.get(sev4Assignee);
         } else if(sev4Assignee != null && sev4Assignee != '') {
             throw new ADM_UnexpectedValueException(sev4Assignee + ' is not an active user');
         } else if (useForInvestigation) {
            throw new ADM_UnexpectedValueException('Sev 4 Assignee is a required field'); 
         }  
         
         
         
         rule.Scrum_Team_Assignment__c = scrumTeamID;
         
         
         if(userNameMap.containsKey(qe)) {
             rule.QA_Assignment__c = userNameMap.get(qe);
         } else if(qe != null && qe != '') {
             throw new ADM_UnexpectedValueException(qe + ' is not an active user');
         }
         
         if(userNameMap.containsKey(tw)) {
              rule.Tech_Writer_Assignment__c = userNameMap.get(tw);
         } else if(tw != null && tw != '') {
             throw new ADM_UnexpectedValueException(tw + ' is not an active user');
         }
         
         if(userNameMap.containsKey(ue)) {
              rule.UE_Engineer__c = userNameMap.get(ue);
         } else if(ue != null && ue != '') {
             throw new ADM_UnexpectedValueException(ue + ' is not an active user');
         }
         
         
         if(userNameMap.containsKey(perfeng)) {
             rule.Systest_Assignment__c = userNameMap.get(perfeng);
         } else if(perfeng != null && perfeng != '') {
             throw new ADM_UnexpectedValueException(perfeng + ' is not an active user');
         }
         
         if(userNameMap.containsKey(smpoc)) {
             rule.Senior_Management_POC_Assignment__c = userNameMap.get(smpoc);
         } else if(smpoc != null && smpoc != '') {
             throw new ADM_UnexpectedValueException(smpoc + ' is not an active user');
         }
         
         if(userNameMap.containsKey(erpoc)) {
             rule.Exception_Request_POC__c = userNameMap.get(erpoc);
         } else if(erpoc != null && erpoc != '') {
             throw new ADM_UnexpectedValueException(erpoc + ' is not an active user');
         }
         
         rule.Additional_Emails__c = otherreps;
         
         String duplicateAssignmentRuleId = ADM_AssignmentRule.checkForDuplicateAssignmentRule(rule);
         if (duplicateAssignmentRuleId != null) {
            String errorMessage = 'An identical assignment rule already exists in the matrix below.  To edit this rule click ';
            errorMessage = errorMessage + '<a href="/' + duplicateAssignmentRuleId + '">here.</a> ';
            // Trying to create a duplicate assignment rule.  Throw an exception with appropriate error message.
            throw new ADM_UnexpectedValueException(errorMessage);
         }
         
         insert rule;
         
         //create assignment for each applicable record type
         if(useForBug) saveNewTagAssignment(rule.id, ADM_Work.BUG_RECORD_TYPE_NAME, currentTagID);
         if(useForStory) saveNewTagAssignment(rule.id, ADM_Work.RECORD_TYPE_NAME_USERSTORY, currentTagID);  
         if(useForInvestigation) saveNewTagAssignment(rule.id, ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, currentTagID); 
        
    }
    
    /**
     * Change the user preference to never show the Guided Tour again.
     */
    @RemoteAction
    public static void neverShowGuidedTour() {
        ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
        preferences.ShowProductTagAssignmentGuidedTour__c = false;
        upsert preferences;
    }
    
    @RemoteAction
    public static void deleteAssignmentRule(Id ruleId) {
        List<ADM_Assignment_Rule__c> assignmentRules = [select ID from ADM_Assignment_Rule__c where Id = :ruleId];
        if(assignmentRules.isEmpty()) {
            return;
        }
        
        delete assignmentRules.get(0);
    }
    
    private static void removeTagAssignment(String currentTagID, String recordType) {
        List<ADM_Tag_Assignment__c> previousAssignments = [select id from ADM_Tag_Assignment__c where Product_Tag__c =:currentTagID and Record_Type__c =:recordType];
        if(previousAssignments != null && previousAssignments.size() > 0) {
            
            Database.delete(previousAssignments);
        }   
    
    } 
    
    private static void saveNewTagAssignment(String ruleID, String recordType, String currentTagID) {
        if(recordType == 'story') recordType = 'User Story';
        //first remove any existing tag assignments for this record type since we only allow one tag rule assignment per team per record type (enforceed by compound key)
        removeTagAssignment(currentTagID, recordType);
        //now insert new one
        ADM_Tag_Assignment__c ta = new ADM_Tag_Assignment__c();
        ta.Record_Type__c = recordType;
        ta.Product_Tag__c = currentTagID;
        ta.Assignment_Rule__c = ruleID;
        insert ta;
        
        
    }
    
    private static Map<String, Id> getUserNameMap(List<String> names) {
        Map<String, Id> userNameMap = new Map<String, Id>();
        
        for(User u: [select id, name from User where name in:names and IsActive =:true]) {
            userNameMap.put(u.name, u.id);
        }
        
        return userNameMap;
    }    
    
    public void reloadMatrix() {
        //reset to force reload
        teamRuleAssignments = null;
    }
    
    public class TeamRuleWrapper {
        public TeamRuleWrapper(Set<ADM_Product_Tag__c> usedBy) {
            
            //create the concatenated comma-seperated list of uesd by tags
            this.usedBy = '';
            boolean isFirst = true;
            for(ADM_Product_Tag__c tag : usedBy) {
                if(isFirst) {
                    isFirst = false;
                } else {
                    this.usedBy += ', ';
                }
                
                this.usedBy += tag.Name;
            }
            
            //create the truncated version of the used by
            Integer truncationSize = 24;
            if(this.usedBy.length() < truncationSize) {
                this.truncatedUsedBy = this.usedBy;
            } else {
                this.truncatedUsedBy = this.usedBy.substring(0, truncationSize).trim() + '...';
            }
        }
        
        public ADM_Assignment_Rule__c rule { get; set; }
        public ADM_Tag_Assignment__c bugAssignment { get; set; }
        public ADM_Tag_Assignment__c storyAssignment { get; set; }
        public ADM_Tag_Assignment__c investigationAssignment { get; set; }
        
        public Boolean bugAssigned {
            get {
                return bugAssignment != null;
            }
        }
        public Boolean storyAssigned {
            get {
                return storyAssignment != null;
            }
        }
        public Boolean investigationAssigned {
            get {
                return investigationAssignment != null;
            }
        }
        
        /**
         * Determines if this rule is able to be modified
         */
        public Boolean readOnly { get; set; }
        
        /**
         * The comma-separated list of tags using this assignment rule
         */
        public String usedBy { get; set; }
        
        /**
         * The shortened version of the usedBy property.
         */
        public String truncatedUsedBy { get; set; }
   }
}