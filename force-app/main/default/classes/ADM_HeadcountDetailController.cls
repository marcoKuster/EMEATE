public with sharing class ADM_HeadcountDetailController {
	
	private transient ADM_HeadcountPermissionManager permissionManager = createDefaultPermissionManager();
    private transient PermissionSetAssignment hiringManagerPerm;
    private transient PermissionSetAssignment recPerm;
    private transient Date contextDate;
    private transient String headCountId;
    private transient String recruiterUserFullNameList;
    private transient Boolean showRequestOfferButton;
    private transient QuarterPeriod quarter;
    
    //use #getHeadCount() instead of the field directly
    private transient HeadCount__c headCount;
    
    /**
     * Gets the hiring manager permission set assignment for the current user. 
     * If the user is not assigned the hiring manager permission, a null reference
     * is returned.
     */
    public PermissionSetAssignment getHiringManagerPerm() {
    	if (hiringManagerPerm == null) {
    		hiringManagerPerm = getHiringManagerPermSet().getAssignmentFor(UserInfo.getUserId());
    	}
    	return hiringManagerPerm;
    }    
    
    /**
     * Gets the recruiter permission set assignment for the current user. 
     * If the user is not assigned the recruiter permission, a null reference
     * is returned.
     */
    public PermissionSetAssignment getRecPerm() {
    	if (recPerm == null) {
    		recPerm = getRecruitingPermSet().getAssignmentFor(UserInfo.getUserId());
    	}
    	return recPerm;
    }
    
    /**
     * Gets the first date of the quarter
     */
    public Date getQuarterStartDate() {
    	return getQuarterPeriod().getStartDate();
    }
    
    /**
     * Gets the last date of the quarter
     */
    public Date getQuarterEndDate() {
    	return getQuarterPeriod().getEndDate();
    }

    public String getRecruiterUserFullNameList() {
    	return getRecruitingPermSet().getUserFullNameList();
    } 
    
    public Boolean getShowRequestOfferButton() {
    	String hiringManagerId = this.getHeadCount().Hiring_Manager__c;
    	return (hiringManagerId != null && hiringManagerId.equals(UserInfo.getUserId()) && getHiringManagerPerm() != null);
    }

    public ADM_HeadcountDetailController(ApexPages.StandardController stdController) {
    	this(stdController, null);
    }
    
    public ADM_HeadcountDetailController(
    		ApexPages.StandardController stdController,
    		Date contextDate) {
    	this.init(stdController, contextDate);
    }
    
    private void init(ApexPages.StandardController stdController, Date contextDate) {
    	this.headCountId = ((HeadCount__c)stdController.getRecord()).Id;
    	this.contextDate = (contextDate == null) ? Date.today() : contextDate;
    }
    
    /**
     * Gets the current head count instance
     */
    private HeadCount__c getHeadCount() {
    	if(this.headCount == null)
    	{
    		
    		this.headCount = [select Id, Name, Status__c, Initial_Status_Value__c, Effective_Date__c, Hiring_Manager__c from HeadCount__c where Id=:headCountId];
    	}
    	return this.headCount;
    }
    
    /**
     * Gets the CSS class for the Recruiter Actions menu item.
     */
    public String getRecruitActionsCssClass() {
    	
    	//the effective date must be within current quarter
    	QuarterPeriod quarterPeriod = getQuarterPeriod();
    	if (quarterPeriod != null && quarterPeriod.contains(contextDate))
    	{
    		
    		
    		OfferStatus status = getOfferStatus();
	    	if (status != null){
		    	if (status == OfferStatus.OPEN)
		    		return 'recruitActionsOpen';
		    		
				else if (status == OfferStatus.IN_PROGRESS)
		    		return 'recruitActionsInProgress';
		    		
				else if (status == OfferStatus.FILLED)
		    		return 'recruitActionsFilled';
	    	}
    	}
    	
    	return '';
    }
    
    /**
     * Gets the offer status for the current head count
     */
    private OfferStatus getOfferStatus() {
    	OfferStatus status = OfferStatus.UNKNOWN;
    	String statusValue = (getHeadCount() == null) ? null : getHeadCount().Status__c;
    	
    	
    	if ('Open - New'.equalsIgnoreCase(statusValue) || 
    		'Open - Backfill'.equalsIgnoreCase(statusValue))
    		status = OfferStatus.OPEN;
    		
    	else if ('Offer In Progress'.equalsIgnoreCase(statusValue) || 
    			 'Offer Accepted'.equalsIgnoreCase(statusValue))
    		status = OfferStatus.IN_PROGRESS;
    		
		else if ('Filled'.equalsIgnoreCase(statusValue))
    		status = OfferStatus.FILLED;
    	
    	return status;
    }
    
    /**
     * Enumeration of the states a head count object can be in as it pertains
     * to the offer.
     */ 
    private enum OfferStatus {
    	UNKNOWN,
    	OPEN,
    	FILLED,
    	IN_PROGRESS
    }
    
    /**
     * Gets the quarter period to which this head count belongs.  If the context
     * date of the head count cannot be determined, then a null is returned.
     */
    private QuarterPeriod getQuarterPeriod() {
    	if(quarter == null) {
    		quarter = QuarterPeriod.parse(getHeadCount().Effective_Date__c);
    	}
    	return quarter;
    }
    
    /**
     * Gets the hiring manager permission set. The value returned will never
     * be null.
     */
    private COM_PermissionSetAdapter getHiringManagerPermSet() {
    	return permissionManager.getHiringManagerPermSet();
    }
    
    /**
     * Gets the recruiting permission set.  The value returned will never be null.
     */
    private COM_PermissionSetAdapter getRecruitingPermSet() {
    	return permissionManager.getRecruitingPermSet();
    }
    
    @RemoteAction
    public static void makeOffer(String headcountId, String jobID, String name, String startDate) {
        
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Talentforce_Offer__c', 'Target_Start_Date__c', 'Candidate_Name__c' })){
          try {

             Headcount__c hc = [select id from Headcount__c where id=:headcountId];
             hc.Talentforce_Offer__c = jobID;
             hc.Target_Start_Date__c = Date.parse(startDate);
             hc.Candidate_Name__c = name;
             update hc;
          
           } catch(ADM_UnexpectedValueException ue) {
              throw ue;
          } catch(Exception e) {
              ADM_UnexpectedValueException ue2 = new ADM_UnexpectedValueException('Error:' + e.getMessage());
              throw ue2;
          }
      }
        
    }

    @RemoteAction
    public static void requestOffer(String headcountId, String recruiter, String candidateName, String startDate) {
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Recruiter__c', 'Target_Start_Date__c', 'Candidate_Name__c' })){
              try {
              	User recruiterUser;
                  Headcount__c hc = [select id, Role__c, Effective_Date__c, Region__c from Headcount__c where id=:headcountId];
      			if(recruiter != null && recruiter.trim().length() > 0) {
      				recruiterUser = validateRecruiter(recruiter);					       		
                 	    hc.Recruiter__c = recruiterUser.id;
                  } else { 
                  	throw new ADM_UnexpectedValueException('Recruiter must be specified for the Hiring Manager Make Offer request.');
                  }  
                  hc.Target_Start_Date__c = Date.parse(startDate);
                  hc.Candidate_Name__c = candidateName;
                  update hc;
              
              	// Send the Recruiter an email with the request.
              	User currentUser = ADM_WorkUser.get(Userinfo.getUserId());
      	        Messaging.SingleEmailMessage makeOfferEmail = new Messaging.SingleEmailMessage();
      	
      			String requestOfferEmailBody = 'Hello ' + recruiterUser.FirstName + 
      				', ' + currentUser.Name + ' has requested that you begin the offer process for ' + candidateName +
      				'.\n\nPlease note this open position on the GUS Roster is intended for hiring a new ' + hc.Role__c +
      				', effective as of ' + hc.Effective_Date__c + ', in ' + hc.Region__c + 
      				'. If the fiscal quarter or region information doesn\'t match your records for this Job ID, please ask the manager to correct the Position information with their Finance Business Partner.' +
      				'\n\nTo proceed with making this offer, or to review details of the open Position, please visit ' +
      				URL.getSalesforceBaseUrl().toExternalForm() + '/' + headcountId;					
      	        makeOfferEmail.setToAddresses(new String[] {recruiterUser.email});
      	        makeOfferEmail.setBccSender( false );
      	        makeOfferEmail.setSaveAsActivity( false );
      	        makeOfferEmail.setUseSignature( true );
      	        makeOfferEmail.setSubject( 'GUS ROSTER: Request to Make Offer' );
      	        makeOfferEmail.setPlainTextBody( requestOfferEmailBody );
      	        makeOfferEmail.setSenderDisplayName(currentUser.FirstName + ' ' + currentUser.LastName);
      	        makeOfferEmail.setReplyTo(currentUser.Email);
      	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {makeOfferEmail});
         		} catch(ADM_UnexpectedValueException ue) {
              	throw ue;
              } catch(Exception e) {
                  ADM_UnexpectedValueException ue2 = new ADM_UnexpectedValueException('Error:' + e.getMessage());
                  throw ue2;
              }
      }
        
    }
    
    private static User validateRecruiter(String recruiter) {
        try {
            String recPermSetId = createDefaultPermissionManager().getRecruitingPermSet().getId();
			List<User> users = [select id, Email, FirstName from User where name=:recruiter and id in (select assigneeId from PermissionSetAssignment where PermissionSetId =: recPermSetId) limit 1];
			if (users.size() > 0) {
				return users.get(0);
			} else {
				throw new ADM_UnexpectedValueException(recruiter + ' is not a valid Recruiter User.');        	
			}
        } catch(ADM_UnexpectedValueException e) {
        	throw e; 
        } catch(Exception e) {
            throw new ADM_UnexpectedValueException('Unexpected error trying to retrieve Recruiter User: ' + e);
        }
    }
    
    @RemoteAction
    public static void confirmAcceptOffer(String headcountId, String startDate) {
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Status__c', 'Target_Start_Date__c'})){
          try {
             Headcount__c hc = [select id from Headcount__c where id=:headcountId];
             hc.Status__c = 'Offer Accepted';
             hc.Target_Start_Date__c = (ADM_TextUtils.isBlank(startDate)) ? null : Date.parse(startDate);
             update hc;
          } catch(Exception e) {
              ADM_UnexpectedValueException ue2 = new ADM_UnexpectedValueException('Error:' + e.getMessage());
              throw ue2;
          }
      }
    }
    
    @RemoteAction
    public static void confirmRevokeOffer(String headcountId) {
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Status__c', 'Target_Start_Date__c','Talentforce_Offer__c', 'Candidate_Name__c' })){
        try {
           Headcount__c hc = [select id, status__c, initial_status_value__c, candidate_name__c, target_start_date__c from Headcount__c where id=:headcountId];
           //since tracking initial status value is new logic this field isn't guarenteed to be populated
           if(hc.initial_status_value__c == null) {
           		hc.status__c = 'Open - New';
           } else {
           		hc.status__c = hc.initial_status_value__c;
           }
           
           hc.Talentforce_Offer__c = null;
           hc.Candidate_Name__c = null;
           hc.Target_Start_Date__c = null; 
           update hc;
        
        } catch(Exception e) {
            
            throw new ADM_UnexpectedValueException('Unexpected Error:' + e);
        }
      }
        
    }
    
    @RemoteAction
    public static void confirmOpenBackfill(String headcountId, String backfillDate) {
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Backfill_Date__c','Status__c' })){
          try {
             Headcount__c hc = [select id from Headcount__c where id=:headcountId];
             hc.Backfill_Date__c = Date.parse(backfillDate);
             hc.Status__c = 'Open - Backfill'; 
             update hc;
          
          } catch(Exception e) {
              
              throw new ADM_UnexpectedValueException('Error:' + e);
          }
    }

  }
    
    private static Id validateTeam(String teamName) {
    	List<ADM_Scrum_Team__c> teams;
        try {
        	teams = [select id from ADM_Scrum_Team__c where name=:teamName limit 1];
        } catch(Exception e) {
            ADM_UnexpectedValueException ue = new ADM_UnexpectedValueException('Error: ' + e.getMessage());
            ue.unexpectedValue = teamName;
            throw ue;
        }
        
        if(teams.isEmpty()) {
           throw new ADM_UnexpectedValueException('No team found with name: ' + teamName);
        }
        return teams.get(0).Id;
      
      
    }
    
    @RemoteAction
    public static void editBackfillHeadcount(String headcountId, String cloud, String team, String organization, String role, String backfillDate, String Description) {
        
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Cloud__c','Team__c', 'Organization__c', 'Role__c', 'Backfill_Date__c', 'Description__c'  })){
          try {
             Headcount__c hc = [select id from Headcount__c where id=:headcountId];
             hc.Cloud__c = cloud;
              if(team != null && team.trim().length() > 0) {
                  hc.Team__c = validateTeam(team);
             } else {
                 hc.Team__c = null;
             }     
             hc.Organization__c = organization;
             hc.Role__c = role; 
             hc.Backfill_Date__c = Date.parse(backfillDate);
             hc.Description__c = description;
             update hc;
          
          } catch(Exception e) {
              
              throw e;
          }
      }
        
    }

    @RemoteAction
    public static void editFilledHeadcount(String headcountId, String team, String organization, String role, String description) {
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Team__c', 'Organization__c', 'Role__c', 'Description__c'  })){
            try {
               Headcount__c hc = [select id from Headcount__c where id=:headcountId];
               if(team != null && team.trim().length() > 0) {
                    hc.Team__c = validateTeam(team);
               } else {
                   hc.Team__c = null;
               }      
               hc.Organization__c = organization;
               hc.Role__c = role;
               hc.Description__c = description; 
               update hc;
            } catch(Exception e) {
                
                throw e;
            }
      }
        
    }
    
    
    @RemoteAction
    public static void editInProgressHeadcount(String headcountId, String cloud, String team, String organization, String role, String startDate, String description) {
        
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Cloud__c','Team__c', 'Organization__c', 'Role__c', 'Target_Start_Date__c', 'Description__c'  })){
          try {
             Headcount__c hc = [select id from Headcount__c where id=:headcountId];
             hc.Cloud__c = cloud;
              if(team != null && team.trim().length() > 0) {
                  hc.Team__c = validateTeam(team);
             } else {
                 hc.Team__c = null;
             }     
             hc.Organization__c = organization;
             hc.Role__c = role; 
             hc.Target_Start_Date__c = (ADM_TextUtils.isBlank(startDate)) ? null : Date.parse(startDate);
             hc.Description__c = description;          
             update hc;
          
          } catch(Exception e) {
              
              throw e;
          }
      }
        
    }
    
    @RemoteAction
    public static void editNewHeadcount(String headcountId, String cloud, String team, String organization, String role, String description) {
        
        if(ADM_SchemaManager.isObjectUpdateable('Headcount__c') && ADM_SchemaManager.areFieldsUpdateable('Headcount__c', new Set<String>{'Cloud__c','Team__c', 'Organization__c', 'Role__c', 'Description__c'  })){
            try {
               Headcount__c hc = [select id from Headcount__c where id=:headcountId];
               hc.Cloud__c = cloud;
               if(team != null && team.trim().length() > 0) {
                    hc.Team__c = validateTeam(team);
               } else {
                   hc.Team__c = null;
               }     
               hc.Organization__c = organization;
               hc.Role__c = role; 
                hc.Description__c = description;
               update hc;
            
             } catch(ADM_UnexpectedValueException ue) {
                throw ue;
            } catch(Exception e) {
                ADM_UnexpectedValueException ue2 = new ADM_UnexpectedValueException('Error:' + e.getMessage());
                throw ue2;
            }
        }
        
    }
    
    /**
     * Creates the default Permission Manager instance.
     */
	private static ADM_HeadcountPermissionManager createDefaultPermissionManager() {
		return new ADM_HeadcountPermissionManager();
	}
}