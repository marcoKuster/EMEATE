global class ADM_AutoAssignWorkAction {
	private List<ADM_Tag_Assignment__c> tagAssignments = null;
	private Map<Id, ADM_Assignment_Rule__c> assignmentRulesById = null;
	private Map<Id, RecordType> recordTypesById = null;
	private Map<Id, User> users = null;
	private ADM_Assignment_Rule__c helpAssignmentRule = null;
    private User osc = null;
	
    
    
	public ADM_AutoAssignWorkAction (
		Map<Id, ADM_Assignment_Rule__c> assignmentRulesById,
		List<ADM_Tag_Assignment__c> tagAssignments,
		Map<Id, RecordType> recordTypesById,
		Map<Id, User> users, 
		ADM_Assignment_Rule__c helpAssignmentRule) {
		
		this.assignmentRulesById = assignmentRulesById;
		this.tagAssignments = tagAssignments;
		this.recordTypesById = recordTypesById;
		this.users = users;
		this.helpAssignmentRule = helpAssignmentRule;
      
		
	}
	
	/**
	 * Applies the assignment rules to the specified work records
	 */
	public List<ADM_Work__c> applyAssignmentRules(List<ADM_Work__c> works) {
		
		for( ADM_Work__c work : works) {
			//get the assignments for the given work
            Assignment assignment = getAssignments(work);
			
			//apply the modification to the work object
			assignment.apply(work);
		}
		
		
		return works;
	}
	
    /**
     * Gets the assignments assigned for the specified work 
     */
	public Assignment getAssignments(ADM_Work__c work) {
		AssignmentRequest request = createRequestFromWork(work);
        
        //preload the assignment object with the starting values
        Assignment assignment = createAssignmentFromWork(work);
        
        //executes the rules for the the given request and assignments
        executeRules(request, assignment);
        
        return assignment;
	}
	
	/**
	 * Gets the assignments assigned for the specified values. 
	 */
	public Assignment getAssignments(
        ADM_Product_Tag__c productTag,
        Boolean investigation,
        Boolean helpType,
        Boolean managerReview,
        RecordType recordType,
        String severity) {
        
        //create the request from the given parameters
        AssignmentRequest request = new AssignmentRequest();
        request.setProductTag((productTag == null)? null : productTag.Id);
        request.setInvestigation(investigation);
        request.setHelpType(helpType);
        request.setRequestRdMgrReview(managerReview);
        request.setRecordType(recordType);
        request.severity = severity;
        
        //create an empty assignment context
        Assignment assignment = new Assignment();
        
        //executes the rules for the the given request and assignments
        executeRules(request, assignment);
        
        return assignment;
    }
	
	/**
	 * Executes the assignment rules with the values given in the request and then
	 * modifies the assignment context.
	 */
	private void executeRules(AssignmentRequest request, Assignment assignment) {
		
        
        //if there is an assignment rule for the specified work, then apply the  
        //assignments to the work
        ADM_Assignment_Rule__c rule = getAssignmentRule(request);
        if(rule != null) {
        	System.debug('Applying the assignment rule');
            apply(rule, request, assignment);
        }
        
        //this investigation only edge case should apply 
        if(request.isInvestigation() && request.severity == '1') {
        	System.debug('Applying the OSC investigation rule');
            User osc = getOscUser();
            if(osc != null && assignment.Assignee == null) {
                assignment.Assignee = osc;
                System.debug('changed Assignee to ' + osc.id);
            }
        }
        
        //if the type is "help" and there has not been an assignee yet, then
        //set the assignee to the one defined in the help rule
        ADM_Assignment_Rule__c helpRule = getHelpAssignmentRule();
        if(helpRule != null && assignment.Assignee == null && request.isHelpType()) {
            System.debug('Applying the help rule');
            if(!isNull(helpRule.Assignee_Assignment__c) && isActiveUser(helpRule.Assignee_Assignment__c)) {
                assignment.Assignee = getUserById(helpRule.Assignee_Assignment__c);
                assignment.Tech_Writer = getUserById(helpRule.Assignee_Assignment__c);
            }
        }
	}
	
	/**
	 * Gets the assignment rule for the specified work record.
	 */
	private ADM_Assignment_Rule__c getAssignmentRule(AssignmentRequest request) {
		if(ADM_TextUtils.isBlank(request.getProductTag())) {
			return null;
		}
		
		//get the tag assignment record associated to the specified product tag
		//and record type
		ADM_Tag_Assignment__c tagAssignment = getTagAssignment(request.getProductTag(), request.getRecordTypeName());
		if(tagAssignment != null && !ADM_TextUtils.isBlank(tagAssignment.Assignment_Rule__c)) {
			return getAssignmentRuleById(tagAssignment.Assignment_Rule__c);
		} else {
			return null;
		}
	}
	
    /**
     * Gets the OSC user from the list of users.
     */
    private User getOscUser(){
        System.debug('entered getOscUser() osc initial value:' + osc + ' users:' + users);
        if(osc == null) {
            for(User u : users.values()) {
                if(u.Name.equalsIgnoreCase('site reliability') || u.Name.equalsIgnoreCase('osc')) {
                    System.debug('OSC/Service Management user found with ID of ' + u.Id);
                    osc = u;
                    break;
                }
            }
            
            if(osc == null) {
                System.debug('OSC user not found');
            }
        }
        System.debug('exiting getOscUser() osc:' + osc);
        return osc;
    }
    
	/**
	 * Determines if the specified user ID is active.
	 */
	private Boolean isActiveUser(Id userId) {
		return users.containsKey(userId);
	}
	
	private User getUserById(Id userId) {
		if(!users.containsKey(userId)) {
			return null;
		}
		return users.get(userId);
	}
	
	/**
	 * Gets the record type corresponding to the specified ID.
	 */
	private RecordType getRecordTypeById(Id recordTypeId) {
		if(!recordTypesById.containsKey(recordTypeId)) {
    		throw new ADM_ApplicationException('Unable to find record type with ID of ' + recordTypeId);
		}
		
		return recordTypesById.get(recordTypeId);
	}
	
	/**
	 * Gets the assignment rule corresponding to the product tag ID for the given
	 * record type. If no rule is found, then a null reference is returned.
	 */
	private ADM_Tag_Assignment__c getTagAssignment(Id tagId, String recordTypeName) {
		//if the work record is a template, then we need to get the assignment
		//rule for the "Bug" record type
		if(recordTypeName == ADM_Work.TEMPLATE_RECORD_TYPE_NAME) {
			recordTypeName = ADM_Work.BUG_RECORD_TYPE_NAME;
		}
		
		for(ADM_Tag_Assignment__c tagAssignment : tagAssignments) {
			
			if(tagAssignment.Product_Tag__c == tagId && tagAssignment.Record_Type__c == recordTypeName) {
				return tagAssignment;
			}
			
		}
		return null;
	}
	
	private Boolean isInvestigation(ADM_Work__c work) {
        RecordType recordType = getRecordTypeById(work.RecordTypeId);
        return recordType.Name == ADM_Work.RECORD_TYPE_NAME_INVESTIGATION;
	}
	
	/**
	 * Determines if the work object is of type help
	 */
	private Boolean isHelpType(ADM_Work__c work) {
        return work.Type__c != null &&  work.Type__c.equalsIgnoreCase( 'help' );
	}
	
	/**
	 * Apply the assignment rule to the assignment object
	 */
	private void apply(ADM_Assignment_Rule__c rule, AssignmentRequest request, Assignment assignment) {
		//handle convoluted special cases for Investigation process: Each Severity can have a different assignee
        if(request.isInvestigation() && assignment.Assignee == null) {
            if(request.severity == '1') {
            	assignment.Assignee = getUserById(rule.Sev_1_Assignee__c);
            } else if(request.severity == '2') {
            	assignment.Assignee = getUserById(rule.Sev_2_Assignee__c);
            } else if(request.severity == '3') {
            	assignment.Assignee = getUserById(rule.Sev_3_Assignee__c);
            } else if(request.severity == '4') {
            	assignment.Assignee = getUserById(rule.Sev_4_Assignee__c);
            }
            System.debug('changed Assignee of Investigation');
        }
        
        //another edge case this time for the Help value of the Type picklist
        if(assignment.Assignee == null) {
            if(request.isHelpType()) {
                if(!isNull(rule.Tech_Writer_Assignment__c) && isActiveUser(rule.Tech_Writer_Assignment__c)) {
                    assignment.Assignee = getUserById(rule.Tech_Writer_Assignment__c);
                    System.debug('changed Assignee ');
                    
                    assignment.Tech_Writer = getUserById(rule.Tech_Writer_Assignment__c);
                    System.debug('changed Tech Writer');
                }
            } else {
                if(!isNull(rule.Assignee_Assignment__c) && isActiveUser(rule.Assignee_Assignment__c)) {
                    assignment.Assignee = getUserById(rule.Assignee_Assignment__c); 
                    System.debug('changed Assignee');
                }
            }
        }
        
        if(assignment.QA_Engineer == null && !isNull(rule.QA_Assignment__c) && isActiveUser(rule.QA_Assignment__c)) {
            assignment.QA_Engineer = getUserById(rule.QA_Assignment__c);
            System.debug('changed the QA Engineer ');
        }
        
        if(assignment.UE_Engineer == null && !isNull(rule.UE_Engineer__c) && isActiveUser(rule.UE_Engineer__c) && !request.isInvestigation()) {
            assignment.UE_Engineer = getUserById(rule.UE_Engineer__c);
            System.debug('changed the UE Engineer ');
        }
        
        if((request.getRecordTypeName() == ADM_Work.RECORD_TYPE_NAME_USERSTORY|| request.getRecordTypeName() == ADM_Work.BUG_RECORD_TYPE_NAME) &&assignment.Tech_Writer == null && !isNull(rule.Tech_Writer_Assignment__c) && isActiveUser(rule.Tech_Writer_Assignment__c)) {
            assignment.Tech_Writer = getUserById(rule.Tech_Writer_Assignment__c);
            System.debug('changed the Tech Writer ');
        }
        
        if(rule.Scrum_Team_Assignment__c != null ) {
        	// Always set scrum team
            assignment.Scrum_Team = rule.Scrum_Team_Assignment__c;
            System.debug('set the Scrum Team');
        }
        
        if(assignment.Product_Owner == null && !isNull(rule.Product_Owner__c) && isActiveUser(rule.Product_Owner__c)) {
            assignment.Product_Owner = getUserById(rule.Product_Owner__c);
            System.debug('changed the Product Owner ');
        }
        
        if(assignment.System_Test_Engineer == null && !isNull(rule.Systest_Assignment__c) && isActiveUser(rule.Systest_Assignment__c) && !request.isInvestigation()) {
            assignment.System_Test_Engineer = getUserById(rule.Systest_Assignment__c);
            System.debug('changed the System Test Engineer ');
        }
        
        if(request.isRequestRdMgrReview() && assignment.Senior_Management_POC == null && !isNull(rule.Senior_Management_POC_Assignment__c) && isActiveUser(rule.Senior_Management_POC_Assignment__c)) {
            assignment.Senior_Management_POC = getUserById(rule.Senior_Management_POC_Assignment__c);
            System.debug('changed the Senior Management ');
        } else if(request.isRequestRdMgrReview() == false) {
             assignment.Senior_Management_POC = null;
        }
        
        if(assignment.Email_Subscription_ID  == null || (ADM_WorkTriggerStaticDataStore.requestOrigin != null && ADM_WorkTriggerStaticDataStore.requestOrigin.equalsIgnoreCase(ADM_WorkTriggerStaticDataStore.NEXT_GEN_EDIT_PAGE_ORIGIN)))  {
            assignment.Email_Subscription_ID = rule.Additional_Emails__c;
            System.debug('changed the Email Subscription');
        }
        
        if(assignment.Exception_Request_POC == null && !isNull(rule.Exception_Request_POC__c) && isActiveUser(rule.Exception_Request_POC__c)) {
            assignment.Exception_Request_POC = getUserById(rule.Exception_Request_POC__c);
            System.debug('changed the Exception_Request_POC__c ');
        }
	}
	
	private ADM_Assignment_Rule__c getHelpAssignmentRule() {
		return helpAssignmentRule;
	}
	
	private ADM_Assignment_Rule__c getAssignmentRuleById(Id ruleAssignmentId) {
		if(!assignmentRulesById.containsKey(ruleAssignmentId)) {
    		throw new ADM_ApplicationException('Unable to find assignment rule with ID of ' + ruleAssignmentId);
		}
		
		return assignmentRulesById.get(ruleAssignmentId);
	}
	
	/**
	 * Apply the auto assignment rules for the specified work
	 */
	public static List<ADM_Work__c> applyAutoAssignmentRules(List<ADM_Work__c> works) {
		ADM_AutoAssignWorkAction action = createActionForWork(works);
		return action.applyAssignmentRules(works);
	}
	
	/**
	 * Creates an action that will work with the specified work objects
	 */
	public static ADM_AutoAssignWorkAction createActionForWork(List<ADM_Work__c> works) {
		return (new Builder()).buildFor(works);
	}
	
    /**
     * Creates an action that will work with the specified tags
     */
	public static ADM_AutoAssignWorkAction createActionForTags(List<String> tagIds) {
		return (new Builder()).buildFor(tagIds);
	}
	
    /**
     * Creates an action that will work with the specified tags
     */
    public static ADM_AutoAssignWorkAction createActionForTags(List<ADM_Product_Tag__c> tags) {
        return (new Builder()).buildFor(tags);
    }
    
	/**
	 * Determines if the specified string is null
	 */
	private static Boolean isNull(String s) {
		return ADM_TextUtils.isNull(s);
	}
	
	/**
	 * Gets a list of all the assignment rules for the specified ID values. If the
	 * assignment rules IDs list is empty, then an empty list is returned.
	 */
	private static List<ADM_Assignment_Rule__c> getAssignmentRulesById(List<String> assignmentRuleIds) {
		if(assignmentRuleIds.isEmpty()) {
			return new List<ADM_Assignment_Rule__c>();
		}

		return ADM_AssignmentRule.getAll('Id', assignmentRuleIds, 0, 10000, 'Id', 'ASC', true);
	}
	
	private AssignmentRequest createRequestFromWork(ADM_Work__c work) {
		AssignmentRequest request = new AssignmentRequest();
        request.setProductTag(work.Product_Tag__c);
		request.setInvestigation(isInvestigation(work));
		request.setHelpType(isHelpType(work));
		request.setRequestRdMgrReview(work.Request_RD_Mgr_Review__c);
		request.setRecordType(getRecordTypeById(work.RecordTypeId));
		request.severity = work.Severity_Level__c;
		return request;
	}
	
	private Assignment createAssignmentFromWork(ADM_Work__c work) {
		Assignment assignment = new Assignment();
		assignment.Assignee = getUserById(work.Assignee__c);
		assignment.Senior_Management_POC = getUserById(work.Senior_Management_POC__c);
		assignment.QA_Engineer = getUserById(work.QA_Engineer__c);
		assignment.UE_Engineer = getUserById(work.UE_Engineer__c);
		assignment.Tech_Writer = getUserById(work.Tech_Writer__c);
		assignment.Scrum_Team = work.Scrum_Team__c;
		assignment.Product_Owner = getUserById(work.Product_Owner__c);
		assignment.System_Test_Engineer = getUserById(work.System_Test_Engineer__c);
		assignment.Email_Subscription_ID = work.Email_Subscription_ID__c;
		return assignment;
	}
	
	global class AssignmentRequest {
        private String productTag;
		private Boolean investigation;
		private Boolean helpType;
		private Boolean managerReview = false;
		private RecordType recordType;
        public String severity;
        
        public void setProductTag(String productTag) {
        	this.productTag = productTag;
        }
        public String getProductTag() {
        	return this.productTag;
        }
		
		public void setInvestigation(Boolean investigation) {
			this.investigation = investigation;
		}
        public Boolean isInvestigation() {
        	return investigation;
        }
        
        public void setHelpType(Boolean helpType) {
        	this.helpType = helpType;
        }
        public Boolean isHelpType(){
        	return helpType;
        }
        
        public void setRequestRdMgrReview(Boolean managerReview) {
        	this.managerReview = managerReview;
        }
        public Boolean isRequestRdMgrReview() {
        	return managerReview;
        }
        
        public void setRecordType(RecordType recordType) {
        	this.recordType = recordType;
        } 
        public RecordType getRecordType() {
            return this.recordType;
        }
        public String getRecordTypeName() {
        	return (this.recordType == null)? null : this.recordType.Name;
        }
	}
	
	global class Assignment {
		public User Assignee;
		public User Tech_Writer;
		public User QA_Engineer;
		public User UE_Engineer;
		public User Product_Owner;
		public User System_Test_Engineer;
		public User Senior_Management_POC;
		public User Exception_Request_POC;
        public String Scrum_Team;
		public String Email_Subscription_ID;
		
		/**
		 * Applies the assignment properties to the specified work. If the work 
		 * property is specified (ie not null), it will not be overwritten.
		 */
		public void apply(ADM_Work__c work) {
			
			if(work.Assignee__c == null && this.Assignee != null) {
	           work.Assignee__c = this.Assignee.Id;
			}
			
			if(work.Tech_Writer__c == null && this.Tech_Writer != null) {
	           work.Tech_Writer__c = this.Tech_Writer.Id;
			}

			if(work.Request_RD_Mgr_Review__c && work.Senior_Management_POC__c == null && this.Senior_Management_POC != null) {
	           work.Senior_Management_POC__c = this.Senior_Management_POC.Id;
			}
			
			if(work.QA_Engineer__c == null && this.QA_Engineer != null) {
	           work.QA_Engineer__c = this.QA_Engineer.Id;
			}
			
			if(work.UE_Engineer__c == null && this.UE_Engineer != null) {
	           work.UE_Engineer__c = this.UE_Engineer.Id;
			}
			
						
			if (this.Scrum_Team != null) {
				// Always set work scrum team
				work.Scrum_Team__c = this.Scrum_Team;
			}
			
			if(work.Product_Owner__c == null && this.Product_Owner != null) {
	           work.Product_Owner__c = this.Product_Owner.Id;
			}
			
			if(work.System_Test_Engineer__c == null && this.System_Test_Engineer != null) {
	           work.System_Test_Engineer__c = this.System_Test_Engineer.Id;
			}
			if(work.Email_Subscription_ID__c == null || (ADM_WorkTriggerStaticDataStore.requestOrigin != null && ADM_WorkTriggerStaticDataStore.requestOrigin.equalsIgnoreCase(ADM_WorkTriggerStaticDataStore.NEXT_GEN_EDIT_PAGE_ORIGIN))) {
	           work.Email_Subscription_ID__c = this.Email_Subscription_ID;
			}
		}
	}
	
	public class Builder {
		private Map<Id, User> usersById;
		private Map<Id, RecordType> recordTypesById;
		private List<ADM_Work__c> worksForBuilder;
        
		public Builder withUsers(Map<Id, User> usersById) {
			this.usersById = usersById;
			return this;
		}
		
		public Builder withRecordTypes(Map<Id, RecordType> recordTypesById) {
			this.recordTypesById = recordTypesById;
			return this;
		}
		
		public ADM_AutoAssignWorkAction buildFor(List<ADM_Work__c> works) {
			//get a list of all the product tags that are associated to each of the
			//work records
			List<String> tagIds = new List<String>();
			if(works != null) {
				for(ADM_Work__c work : works) {
					if(!ADM_TextUtils.isBlank(work.Product_Tag__c)) {
						tagIds.add(work.Product_Tag__c);
					}
				}
                worksForBuilder = new List<ADM_Work__c>();
                worksForBuilder = works;
			}
			return buildFor(tagIds);
		}
		
		public ADM_AutoAssignWorkAction buildFor(List<ADM_Product_Tag__c> tags) {
			List<String> tagIds = new List<String>();
			if(tags != null) {
				for(ADM_Product_Tag__c tag : tags) {
					if(tag != null){
					    tagIds.add(tag.Id);
					}
				}
			}
			return buildFor(tagIds);
		}
		
		public ADM_AutoAssignWorkAction buildFor(List<String> tagIds) {
			//prime the tag assignment cache with all the assignments used by 
			//the product tags retrieved
			List<ADM_Tag_Assignment__c> tagAssignments = ADM_TagAssignment.getAllWhereProductTagIdEquals(tagIds);
			
			//prime the assignment rules with all of rules associated to the 
			//product tags
			List<String> assignmentRuleIds = new List<String>();
			for(ADM_Tag_Assignment__c tagAssignment : tagAssignments) {
				if(!ADM_TextUtils.isBlank(tagAssignment.Assignment_Rule__c)) {
				    assignmentRuleIds.add(tagAssignment.Assignment_Rule__c);
				}
			}
			List<ADM_Assignment_Rule__c> assignmentRuleList = getAssignmentRulesById(assignmentRuleIds);
			Map<Id, ADM_Assignment_Rule__c> assignmentRulesById = ADM_AssignmentRule.convertAssignmentRuleListToMapById(assignmentRuleList);
			
			//get the help rule
			ADM_Assignment_Rule__c helpAssignmentRule = ADM_AssignmentRule.getHelp(assignmentRuleList);
			
			//create a record type data accessor
			if(recordTypesById == null) {
				recordTypesById = ADM_RecordType.getAllAsMapById();
			}
			
			//get a list of all the active users
			System.debug('inside buildFor() tag IDs:' + tagIds);
            if(usersById == null) {
                System.debug('buildFor() usersById is null');
                //check if we're in the package and build users based on perm set
                ADM_ConstantsSingleton singletonConstants = ADM_ConstantsSingleton.getInstance();
                //if wer're in the package we limit the user lookup to users with our package perm set.  Unless were running tests because we can't assign user perm sets in tests due to the error 'MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa)'
                if(singletonConstants.isPackagedOrg() && !Test.isRunningTest()) {
                    System.debug('buildFor() identified this is a packaged org');
                    //customer orgs can have over 100K active users so limit by perm set
                    List<PermissionSet> permSets =  [select id from PermissionSet where Name = 'Agile_Accelerator_User' or Name = 'Agile_Accelerator_Admin'];
             		usersById = new Map<Id, User>();
                    //still use a SOQL for loop for populating the map in case we have more then 10 thousand perm set users
                    for(User user : [Select Id, Name, SmallPhotoUrl From User Where IsActive = true and id in (select AssigneeId from PermissionSetAssignment where PermissionSetId in:permSets)]) {
                        usersById.put(user.id, user);
                    }
                } else {
                    System.debug('buildFor() this is NOT a packaged org');
                    usersById = new Map<Id, User>();
                    if (!Test.isRunningTest()) {
                    	//instead of fetching all users (which can take > 2 sec for just 5K users), build a list of just the relevant users based on the Work records and Assignment Rules in the current batch
                    	Set<Id> relevantUserIds = new Set<Id>();
                        //add relevant users from assignment rules
                        relevantUserIds = ADM_AssignmentRule.buildUserIdsFromAssignmentRules(assignmentRuleList);
                        //add relevant users from Works
                        if(this.worksForBuilder != null) {
                        	relevantUserIds.addAll(ADM_Work.buildUserIdsFromWorks(this.worksForBuilder));    
                        }
                        if(helpAssignmentRule != null) {
                       		 //add users from help rule
                        	 relevantUserIds.add(helpAssignmentRule.Assignee_Assignment__c);     
                        }
                       
                        //lookup relevant userIds plus the id for the Site Reliability User necessary for some Investigation assignments
                        System.debug('buildFor() about to lookup these relevantUserIds:' + relevantUserIds);
                        for(User user : [Select Id, Name, SmallPhotoUrl From User Where IsActive = true and (id in:relevantUserIds or name = 'Site Reliability')]) {
                        	usersById.put(user.id, user);
                    	}
                        System.debug('buildFor() found:' + usersById);
                    }
                    else{
                    	for(User user : [Select Id, Name, SmallPhotoUrl From User Where IsActive = true order by createdDate desc limit 200]) {
                        	usersById.put(user.id, user);
                    	}
                    }
                }
			}
			System.debug('buildFor() usersById is populated and looks like this:' + usersById);
			//create the action
			ADM_AutoAssignWorkAction action = new ADM_AutoAssignWorkAction(assignmentRulesById, tagAssignments, recordTypesById, usersById, helpAssignmentRule);
			return action;
		}
        
        
	}
}