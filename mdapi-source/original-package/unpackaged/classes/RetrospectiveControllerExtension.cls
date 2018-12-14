/**
    Retrospective Controller Extension to handle Submit and Share actions
**/
public with sharing class RetrospectiveControllerExtension {

    public static final String STATUS_NEW = 'New';
    public static final String STATUS_SHARED_WITH_MANAGER = 'Shared with Manager';
    public static final String STATUS_COMPLETED = 'Complete';
    
    private static final String ERROR_COMMENTS_SECTION_REQUIRED_FOR_SHARING = 'All fields in comments section should be filled before sharing.'; 
    private static final String ERROR_COMMENTS_SECTION_REQUIRED_FOR_SUBMISSION = 'All fields in comments section should be filled before submission.'; 
    private static final String ERROR_ONE_RETRO_PER_RELEASE = 'A retrospective already exists for this release.';
    
    private static final String LABEL_WHAT_WENT_WELL = 'What Went Well';
    private static final String LABEL_WHAT_DIDNT_GO_WELL = 'What Didn\'t Go Well';
    private static final String LABEL_WHAT_TO_DO_BETTER = 'What To Do Better Next Time';
    private static final String LABEL_OVERALL_RATING = 'Overall Rating';
    
    private static final String ERROR_COMMENTS_MAX_LENGTH_EXCEEDED = 'Value for fields in comments section should not exceed 32000 characters.'; 

    private static final Integer COMMENTS_MAX_LENGTH = 32000; 

    public Retrospective__c retrospective;
    
    public String whatWentWellLabel {get {return LABEL_WHAT_WENT_WELL;}}
    public String whatDidNotGoWellLabel {get {return LABEL_WHAT_DIDNT_GO_WELL;}}
    public String whatToDoBetterLabel {get {return LABEL_WHAT_TO_DO_BETTER;}}
    public String overallRatingLabel {get {return LABEL_OVERALL_RATING;}}
    
    public boolean canEdit {
        get {
            if (this.retrospective.Status__c == STATUS_NEW && isEmployee) return true;
            if (this.retrospective.Status__c == STATUS_SHARED_WITH_MANAGER && isManager) return true;
            return false;
        }
    }
    
    public boolean canSubmit {
        get { return (this.retrospective.Status__c == STATUS_NEW && isEmployee); }
    }

    public boolean canShare {
        get { 
              return(this.retrospective.Status__c == STATUS_SHARED_WITH_MANAGER && isManager);
            }
    }

    public boolean isEmployee {
        get { return (UserInfo.getUserId() == this.retrospective.User__c); }
    }
    
    public boolean isManager {
        get { return (UserInfo.getUserId() == this.retrospective.Manager__c); }
    }
    
    public String customErrorMessage {get; private set;}

    public boolean hasCustomError {
        get {
            return (customErrorMessage != null && customErrorMessage.length() > 0); 
        } 
    }

    public RetrospectiveControllerExtension(ApexPages.StandardController stdController) {
    	initializeProperties((Retrospective__c)stdController.getRecord());
    }
    
    public void initializeProperties(Retrospective__c retrospective) {
        this.retrospective = retrospective;
        this.customErrorMessage = null;
        if (this.retrospective.Id == null) {
            if (this.retrospective.Manager__c == null) {
                Id manager = [Select ManagerId from User where Id = :UserInfo.getUserId()].ManagerId;
                if (manager != null) {
                    this.retrospective.Manager__c = manager;
                }
            
            }

            if (this.retrospective.Status__c == null) {
                this.retrospective.Status__c = STATUS_NEW;
            }
            
            this.retrospective.User__c = UserInfo.getUserId();
        }
    }
    
    public PageReference cancel() {
    
        PageReference pageRef = new PageReference('/apex/Feedback' );
        pageRef.setRedirect(true);
        return pageRef;
    
    }
    
    public PageReference save() {
        
        if (this.isEmployee) {
            if (this.retrospective.What_Went_Well_employee__c.length() > COMMENTS_MAX_LENGTH
                || this.retrospective.What_Didn_t_Go_Well_employee__c.length() > COMMENTS_MAX_LENGTH
                || this.retrospective.What_To_Do_Better_Next_Time_employee__c.length() > COMMENTS_MAX_LENGTH
                ) {
                    this.customErrorMessage = ERROR_COMMENTS_MAX_LENGTH_EXCEEDED;
                    return null;
            }
        }
        else if (this.isManager) {
            if (this.retrospective.What_Went_Well_manager__c.length() > COMMENTS_MAX_LENGTH
                || this.retrospective.What_Didn_t_Go_Well_manager__c.length() > COMMENTS_MAX_LENGTH
                || this.retrospective.What_To_Do_Better_Next_Time_manager__c.length() > COMMENTS_MAX_LENGTH
                ) {
                    this.customErrorMessage = ERROR_COMMENTS_MAX_LENGTH_EXCEEDED;
                    return null;
            }
        }
        
        // TODO: Ganesh - review_period should be renamed as retrospective_period at some point.
        if (this.isEmployee) {
            List<Retrospective__c> existingRetros = [Select Id from Retrospective__c where Review_Period__c = :this.retrospective.Review_Period__c AND User__c = :UserInfo.getUserId()];
            for (Retrospective__c existingRetro: existingRetros) {
                if (existingRetro.Id != this.retrospective.Id) {
                    this.customErrorMessage = ERROR_ONE_RETRO_PER_RELEASE;
                    return null;
                }
            }
        }
        if (this.retrospective.Manager__c == this.retrospective.User__c) {
            this.retrospective.Manager__c.addError('Manager cannot be same as the user.');
            return null;
        }
        
        if (this.retrospective.Id == null) {
            return insertRetrospective();
        }
        else {
            return updateRetrospective();
        } 
    }
    
    public PageReference insertRetrospective() {
        this.retrospective.User__c = UserInfo.getUserId();
        insert this.retrospective;
        PageReference pageRef = new PageReference('/' + this.retrospective.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference updateRetrospective() {
        update this.retrospective;
        PageReference pageRef = new PageReference('/' + this.retrospective.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
        Submit the retrospective
    **/
    public PageReference submitToManager() {
        String theId = ApexPages.currentPage().getParameters().get('id');
        
        if (isEmpty(this.retrospective.What_Went_Well_employee__c)
            || isEmpty(this.retrospective.What_Didn_t_Go_Well_employee__c)
            || isEmpty(this.retrospective.What_To_Do_Better_Next_Time_employee__c)
            ) {
                this.customErrorMessage = ERROR_COMMENTS_SECTION_REQUIRED_FOR_SUBMISSION;
                return null;
        }


        // Update status on retrospective    
        this.retrospective.Status__c = STATUS_SHARED_WITH_MANAGER;
        update this.retrospective;
        
        // TODO: Ganesh - Move this to trigger so you can manage add/remove sharing as the record is changed
        Retrospective__Share mgrShareRecord = new Retrospective__Share();
        mgrShareRecord.parentId = this.retrospective.Id;
        mgrShareRecord.UserOrGroupId = this.retrospective.Manager__c;
        mgrShareRecord.accessLevel = 'Edit';
        insert mgrShareRecord;
    
        ADM_Release__c reviewPeriod = getReviewPeriodById(this.retrospective.Review_Period__c);
        String reviewPeriodName = reviewPeriod.Name;
        
        // Send out feed posts
        FeedItem userPost = new FeedItem();
        userPost.ParentId = UserInfo.getUserId();
        userPost.Body = ' just completed a ' + reviewPeriodName + ' Release Retrospective.';
        insert userPost;
       
        FeedItem managerPost = new FeedItem();
        managerPost.ParentId = this.retrospective.Manager__c;
        String firstName = UserInfo.getFirstName();
        managerPost.Body = firstName;
        if (firstName.endswith('s')) {
            managerPost.Body += '’ ';
        } else {
            managerPost.Body += + '’s ';
        }
        managerPost.Body += reviewPeriodName + ' Release Retrospective is ready for your comments.';
        insert managerPost;
 
        // Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private boolean isEmpty(String str) {
    	return (str == null || str == '');
    }
    
    /**
        Share the retrospective
    **/
    public PageReference shareWithEmployee() {
        String theId = ApexPages.currentPage().getParameters().get('id');
        
        if (isEmpty(this.retrospective.What_Went_Well_manager__c)
            || isEmpty(this.retrospective.What_Didn_t_Go_Well_manager__c)
            || isEmpty(this.retrospective.What_To_Do_Better_Next_Time_manager__c)
            ) {
            this.customErrorMessage = ERROR_COMMENTS_SECTION_REQUIRED_FOR_SHARING;
            return null;
        }
        
    
        this.retrospective.Status__c = STATUS_COMPLETED;
        update this.retrospective;
        
        ADM_Release__c reviewPeriod = getReviewPeriodById(this.retrospective.Review_Period__c);
        String reviewPeriodName = reviewPeriod.Name;
     
        User reviewOwner = this.getUserById(this.retrospective.User__c);
           
        // Send out feed posts
        FeedItem managerPost = new FeedItem();
        managerPost.ParentId = this.retrospective.Manager__c;
        managerPost.Body = UserInfo.getFirstName() + ' just completed ' + reviewOwner.firstName;
        if (reviewOwner.firstName.endswith('s')) {
            managerPost.Body += '’ ';
        } else {
            managerPost.Body += '’s ';
        }
        managerPost.Body += reviewPeriodName + ' Release Retrospective.';
        insert managerPost;
   
        FeedItem userPost = new FeedItem();
        userPost.ParentId = this.retrospective.User__c;
        userPost.Body = 'Your ' + reviewPeriodName + ' Release Retrospective is ready. Don’t forget to have a conversation with ' + UserInfo.getFirstName() + ' about it.';
        insert userpost;
        
        // Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private ADM_Release__c getReviewPeriodById(String releaseId) {
        return [select id, name from ADM_Release__c where ADM_Release__c.id = :releaseId];
    }
    
    private User getUserById(String userId) {
        return [select id, firstName from User where User.id = :userId];
    }
    
}