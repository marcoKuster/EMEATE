global with sharing class ADM_InvestigationExtension extends ADM_WorkCommonExtension {
    ADM_Work__C work;
    Id profileId;
    String profileName; 
    public ADM_InvestigationExtension(ApexPages.StandardController stdController) {
        super(stdController);
        work = getSelectedWork();
        setProfileName();
    }

    public Pagereference doSaveInvestigationAndNew(){      
        if(profileName.equalsIgnoreCase('gus customer support user') && getIsNew() == true && ADM_TextUtils.isBlank(work.CS_Contact__c)) {
            setCSContactDefault(work);
        }
        return doSaveAndNew();
     }

    public Pagereference doSaveInvestigationAndDetail(){
        if(profileName.equalsIgnoreCase('gus customer support user') && getIsNew() == true && ADM_TextUtils.isBlank(work.CS_Contact__c)) {
            setCSContactDefault(work);
        }
        return doSaveAndDetail();
    }

    private void setCSContactDefault(ADM_Work__c work){
        work.CS_Contact__c = UserInfo.getUserId();
    }

    public PageReference doClone() {
        PageReference pr;
        boolean isSFXPagePreferred = ADM_ConstantsSingleton.getInstance().getUserLightningExperiencePreferred();
        if(isSFXPagePreferred){
            pr = Page.ADM_InvestigationEditSds;           
        }
        else{
             pr = Page.ADM_InvestigationEdit;
        }
        pr.setRedirect(true);
        pr.getParameters().put('id', getSelectedWork().Id);
        pr.getParameters().put('clone','1');
        pr.getParameters().put('retURL','/' + getSelectedWork().Id);
        return pr;
    }

    private void setProfileName(){
        profileId = UserInfo.getProfileId();
        profileName = [Select Name from Profile where Id =: profileId limit 1 ].Name;
    }

    protected override void setDefaultValues(ADM_Work__c work) {
        super.setDefaultValues(work); 
        //set the default properties for an Investigation
        try{
            setProfileName();
            if(this.profileName.equalsIgnoreCase('gus customer support user') && getIsNew() == true){
                work.CS_Contact__c = Userinfo.getUserId();
            }
        }
        catch(Exception e){
            System.debug('Exception fetching profile Id and Name and setting Support Contact for Investigation : '+ e);
        }
    }
    
    /** Investigation SLA Monitoring - Returns true if SLA Due Time is in the past */
    public Boolean getIsSLAOverdue() {
        return work.Due_Date__c!=null && (System.now().getTime() > work.Due_Date__c.getTime());
    }
    
    /** Investigation SLA Monitoring - Returns the field label to display for the time remaining until SLA is violated */
    public String getSLACountdownLabel() {
        String msg = '';
        try{
            if (work.Due_Date__c != null) {
            
                if (work.Status__c == 'New') {
                    msg = 'Acknowledgement Due';
                } else if (work.Status__c == 'More Info Reqd from Support') {
                    msg = 'Update Due From Support';
                } else {
                    msg = 'Update Due From T&P';
                }
            }
        }
        catch(Exception e){
            System.debug('iSLA Exception in getting SLA count down label for Investigation : ' + e);
        }
        
        return msg;
    }
    
    public String getSLACountdownLabelStyle() {
        String style = '';
        try{
            if (work.Due_Date__c != null) {
                Long diffHours = (work.Due_Date__c.getTime() - System.now().getTime()) / (60 * 60 * 1000);
                if (diffHours < 1) {
                    style = 'color:red';
                }
            }
        }
        catch(Exception e){
            System.debug('iSLA Exception in getting SLA count down label style for Investigation : ' + e);
        }
        
        return style;
    }
    
    public String getSLACountdownStyle() {
        String style = '';
        try{
            if (work.Due_Date__c != null) {
                Long diffHours = (work.Due_Date__c.getTime() - System.now().getTime()) / (60 * 60 * 1000);
                if (diffHours < 1) {
                    style = 'color:red';
                } else if (diffHours < 4) {
                    style = 'color:darkorange';
                } else {
                    style = 'color:green';
                }
            }
        }
        catch(Exception e){
            System.debug('iSLA Exception in getting SLA count down style for Investigation : ' + e);
        }
        
        return style;
    }
    
    /** Investigation SLA Monitoring - Returns the diff between now and the SLA Due Time (absolute value) */
    public String getSLADueTimeDiff() {
        String msg = '';
        try {
            if (work.Due_Date__c != null) {
                Long diffMilliseconds = Math.abs(work.Due_Date__c.getTime() - System.now().getTime());
                Long diffMinutes = diffMilliseconds / (60 * 1000);
                
                Long minutesPart = Math.mod(diffMinutes, 60);
                Long hoursPart = Math.mod(diffMinutes/60, 24);
                Long daysPart = diffMinutes / (24 * 60);
            
                if (getIsSLAOverdue()) {
                    msg = 'Overdue by ';
                } else {
                    msg = 'In ';
                }
            
                if (daysPart > 0) {
                    msg += daysPart;
                    msg += (daysPart > 1) ? ' Days ' : ' Day ';
                }
                if (hoursPart > 0) {
                    msg += hoursPart;
                    msg += (hoursPart > 1) ? ' Hours ' : ' Hour ';
                }
                if (minutesPart > 0) {
                    msg += minutesPart;
                    msg += (minutesPart > 1) ? ' Minutes ' : ' Minute ';
                }
            }
        }
        catch(Exception e){
            System.debug('iSLA Exception in getting SLA due time diff for Investigation : ' + e);
        }
               
        return msg;
    }
}