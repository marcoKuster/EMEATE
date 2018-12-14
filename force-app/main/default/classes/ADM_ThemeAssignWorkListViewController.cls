public with sharing class ADM_ThemeAssignWorkListViewController {
    private List<WorkWrapper> currentlyDisplayedWork = null;
    private static String nameSpacePrefix = ADM_ConstantsSingleton.getInstance().getNameSpace();
    // Property used to hold all the work for the current theme.
    // The theme assignments are added and removed from here to keep
    // track if the checkboxes on the VF page should be checked, which
    // the page gets from the current wrapped work items.
    private Map<Id, ADM_Theme_Assignment__c> getThemeAssignments() {
        List<ADM_Work__c> workItems = workList == null ? null : (List<ADM_Work__c>)workList.getRecords();
        Map<Id, ADM_Theme_Assignment__c> themeAssignments = new Map<Id, ADM_Theme_Assignment__c>();
        
        if (workItems != null) {
            String query = 'SELECT Id, Work__c, Theme__c FROM ADM_Theme_Assignment__c WHERE Theme__c = \''+aTheme.Id+'\' AND Work__c IN :workItems';
            for (ADM_Theme_Assignment__c ta : Database.query(query)) {
                themeAssignments.put(ta.Work__c, ta);
            }
        }
        
        return themeAssignments;
    }
    
    // Properties for the VF component attributes
    // Prefixed with an "a" since VF doesn't allow the name and assignTo to be the same.
    // See ADM_ThemeAssignWorkListView for descriptions
    public String aLabel {get; set;}
    public String aQuery {get; set {
        if (aQuery != null && !aQuery.equals(value)) {
            //Clear the workList to regenerate from the query
        	workList = null;
        }
        aQuery = value;
    }}
    private Integer worklistSize;
    public String aListCount {get {
        if (aLabel.equalsIgnoreCase('Assigned Work') && worklistSize != null) {
            if (worklistSize == 1) {
	            return ' - 1 item';
            } else if (worklistSize == 0) {
                return ' - no items';
            } else {
                return ' - ' + worklistSize + ' items';
            }
        } else return '';
    } set; }
    public Integer aPageSize {get; set;}
    public ADM_Theme__c aTheme {get; set {
        if (aTheme == null || aTheme.Id != value.Id) {
            //Clear the workList and themeAssignment to the list with the right theme
        	workList = null;
        }
        
        aTheme = value;
    }}
    public String aBackgroundColor {get; set {
    	aBackgroundColor = value != null && !String.isEmpty(value) ? 'background:'+value+';' : '';
    }}
    /**
     * True if all currently displayed work items have the current theme. Otherwise false.
     * This is also set to true by the user, which then calls assign() to give all the 
     * currently displayed work records the current theme.
     */
    public boolean selectedAll {get; set;}
  
    private List<sObject> generateWorkResultsFromSOSL() {
        List<sObject> results = new List<sObject>();
        if (aQuery !='.') {
            if (aQuery.left(6).equalsIgnoreCase('SELECT')) {
                try {
	                results = Database.query(aQuery);
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, e.getMessage()));
                }
            } else {
                try {
                    List<List<sObject>> soslResults = Search.query(aQuery);
                    if (soslResults.size() != 1) {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 'Invalid SOSL results'));
                    } else {
                        results = soslResults.get(0); 
                    }
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, e.getMessage()));
                }
            }
        }
        return results;
    }
    
    public static final String fields =
        'Id, '+
        'Name, ' +
        'RecordType.Name, '+
        nameSpacePrefix + 'Subject__c, ' +
        nameSpacePrefix + 'Priority__c, ' +
        nameSpacePrefix +'Type__c, ' +
        nameSpacePrefix +'Product_Tag__c, ' +
        nameSpacePrefix +'Product_Tag_Name__c, ' +
        nameSpacePrefix +'Details__c, ' +
        nameSpacePrefix +'Details_and_Steps_to_Reproduce__c, ' +
        nameSpacePrefix +'Scheduled_Build__c, ' +
        nameSpacePrefix +'Scheduled_Build_Name__c, ' +
        nameSpacePrefix +'Assignee__c, ' +
        nameSpacePrefix +'Assignee__r.Name, ' +
        nameSpacePrefix +'Scrum_Team__c, ' +
        nameSpacePrefix +'Scrum_Team_Name__c, ' +
        nameSpacePrefix +'Status__c';
    
    // Pagination controllers for the work results
    public ApexPages.StandardSetController workList {
        get {
            if (aQuery != null && aQuery == '.') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Please search for records to add.'));
            } else {
                if (workList == null) {
                    List<sObject> items = null;
                    if (aQuery != null && !String.isEmpty(aQuery)) {
                        items = generateWorkResultsFromSOSL();
                        if (items.size() > 0) {
                            workList = new ApexPages.StandardSetController(items);
                            workList.setPageSize(aPageSize);
                        } else {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'No matching work records'));
                        }
                    } else {
                        String query = 'SELECT ' + fields + ' FROM ADM_Work__c WHERE Id IN (SELECT Work__c FROM ADM_Theme_Assignment__c WHERE Theme__c = \''+aTheme.id+'\') ORDER BY Name LIMIT 10000';
                        Database.QueryLocator ql = Database.getQueryLocator(query);
                        workList = new ApexPages.StandardSetController(ql);
                        if (workList.getResultSize() > 0) {
                        	workList.setPageSize(aPageSize);
                            worklistSize = workList.getResultSize();
                        } else {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'This theme has no assigned work records'));
                        }
                    }
                    
                }
            }
            return workList;
        } set;
    }
    
    // We need an empty controller for the VF compoenet
    public ADM_ThemeAssignWorkListViewController() {}
    
    public Boolean getHasLabel() {
        return aLabel != null && !String.isEmpty(aLabel);
    }
    
    // Returns the total avalible pages in the workList
    public Integer getAvailablePages() {
        Decimal totalPages = Math.floor((workList.getResultSize() / workList.getPageSize()));
        totalPages += ((Math.mod(workList.getResultSize(), aPageSize) > 0) ? 1 : 0);
        return (Integer)totalPages;
    }
    
    public Boolean getHasMoreThanOnePage() {
        return getAvailablePages() > 1;
    }
    
    /**
     * If selectedAll is true, it will assign the theme to all displayed work records that
     * do not have the theme. If selected all is false, it will remove the theme from all 
     * displayed work records that do have it.
     * 
     * Called by the "Select/Deselect All" checkbox in the VF component.
     */
    public void changeAll() {
        if (currentlyDisplayedWork != null) {
            for (WorkWrapper wrapper : currentlyDisplayedWork) {
            	wrapper.hasTheme = selectedAll;   
            }
        }
        updateAssignedThemes();
    }
    
    /**
     * Adds and removes themes to the displayed work records, if any have been changed.
     * 
     * Called when an individual checkbox is clicked, to add or remove the current theme from a
     * work record. Also called by changeAll to update added/removed themes. 
     */
    public void updateAssignedThemes() {
        if (currentlyDisplayedWork != null) {
            List<ADM_Theme_Assignment__c> toAdd = new List<ADM_Theme_Assignment__c>();
            List<ADM_Theme_Assignment__c> toRemove = new List<ADM_Theme_Assignment__c>();

            for (WorkWrapper wrapper : currentlyDisplayedWork) {
                //Mark as add or removed, only if the record has changed
                if (wrapper.hasTheme && !wrapper.hadTheme()) {
                    ADM_Theme_Assignment__c assign = new ADM_Theme_Assignment__c();
                    assign.Work__c = wrapper.work.Id;
                    assign.Theme__c = aTheme.Id;
                    toAdd.add(assign);
                    wrapper.assignment = assign;
                } else if (!wrapper.hasTheme && wrapper.hadTheme()) {
                    toRemove.add(wrapper.assignment);
                    wrapper.assignment = null;
                }
            }
            
            insert toAdd;
            delete toRemove;
        }
    }
    
    @AuraEnabled
    public static String getWorkItemsJSON(String themeId) {
        String query = 'SELECT ' + fields + ' FROM ADM_Work__c WHERE Id IN (SELECT Work__c FROM ADM_Theme_Assignment__c WHERE Theme__c = \''+themeId+'\') ORDER BY Name LIMIT 10000';
    	List<ADM_Work__c> items = Database.query(query);
        WorkData data = null;
        if(items != null && items.size() > 0){
            data = new WorkData();
            data.nameSpace = nameSpacePrefix;
            data.works = items;
        }
        return  JSON.serialize(data);
    }

    @AuraEnabled
    public static boolean removeThemeWorkAssignment(String workId, String themeId) {
        //We are getting back JSON as a lightweight container for saving just the data that has changed and not having to pass all work and task data.
       /*ADM_Theme_Assignment__c [] themeAssignments = [select id, Theme__c from ADM_Theme_Assignment__c where work__c=:workId and Theme__c=:themeId];
        if(themeAssignments.size() == 1){//Only delete if you get exactly one record, more than one record should not happen

        }*/
        try{
            ADM_ThemeInputController.removeThemeFromWork((Id)workId, (Id)themeId);
            return true;
        }
        catch(Exception exp){
            throw exp;
        }

    }

    /**
     * Get the wrapped work records of the current page.
     */
    public List<WorkWrapper> getWorkItems() {
        List<ADM_Work__c> items = workList != null ? (List<ADM_Work__c>)workList.getRecords() : new List<ADM_Work__c>();
        List<WorkWrapper> wrappers = new List<WorkWrapper>();
		Map<Id, ADM_Theme_Assignment__c> themes = getThemeAssignments();
        
        // If all the work records have the theme, we should set the selectedAll flag
        boolean isAllSelected = true;
        for (ADM_Work__c work : items) {
            boolean has = themes.containsKey(work.Id);
            String details = String.isEmpty(work.Details__c) ? work.Details_and_Steps_to_Reproduce__c : work.Details__c;
            
            wrappers.add(new WorkWrapper(work, themes.get(work.Id), details));
            isAllSelected = isAllSelected && has;
        }
        selectedAll = isAllSelected;
        currentlyDisplayedWork = wrappers;
        return currentlyDisplayedWork;
    }
    

    public class WorkData {
        public String nameSpace;
        public List<ADM_Work__c> works;

    }

    /**
     * A simple structure to containe the work record and a boolean if is has the current theme.
     * This is needed for visualforce to remember and work with the information in the list view.
     */
    public class WorkWrapper {
        public boolean hasTheme { get; set; }
        public ADM_Work__c work { get; set; }
        public ADM_Theme_Assignment__c assignment { get; set; }
        public String details { get; set; }
        
        public WorkWrapper(ADM_Work__c work, ADM_Theme_Assignment__c theme, String details) {
            this.assignment = theme;
            this.hasTheme = theme != null;
            this.work = work;
            this.details = details;
        }
        
        public boolean hadTheme() {
            return assignment != null;
        }
    }
}