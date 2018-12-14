public with sharing class QA_PendingExecutionsController {

    String destState = ''; //var used to change the state
    String sortBy = 'Name'; //var used to change the sorting method
    String filterBy = 'All'; //var used to filer the TEs
    TEContainer[] testExecs = new TEContainer[]{}; //array of the wrapper var
    String bugList = ''; //var used when entering a bug list to add to a TE
    Boolean isUpdating = false;
    String assignee = UserInfo.getUserId(); //get the id of the user viewing the page, to ensure only the user's TEs will show
    String lastSort = '';

    public Boolean init {
        get {
            if(init == null)
                init = false;
            return init;
        }
        set { init = value; }
    }
    String sortDir = 'ASC';
    String sortCol = '';

    public String getSortCol() { return this.sortCol; }
    public void setSortCol(String value) { this.sortCol = value; }

    //container/wrapper class used to enable the use of checkboxes
    public class TEContainer {
        public QA_Test_Execution__c TE;
        public QA_Test_Case__c TC;
        public Boolean cbox;
        public Boolean isUpdating;
        public Boolean locked = false;
        public Boolean editBriefDesc = false;
        public Boolean editLongDesc = false;
        public Boolean editStatus = false;
        public Boolean editEResults = false;
        public Boolean editHier = false;
        public Boolean editType = false;
        public Boolean editBugs = false;
        public String originalBriefDesc;
        public String originalLongDesc;
        public String originalStatus;
        public String originalEResults;
        public String originalHier;
        public String originalType;
        public String originalBugs;
        public Integer index;

        public TEContainer (QA_Test_Execution__c te, Integer i){ //constructor for the container
            this.index = i;
            this.cbox = false;
            this.TE = te;
            isUpdating = false;
            TC = [SELECT Id, name, Brief_Description__c, Steps_to_Reproduce__c, Hierarchy__c,
                        Expected_Results__c FROM QA_Test_Case__c WHERE Id =: TE.Test_Case__c];
            this.setAllOrigs();
        }

        public Integer getIndex(){ return this.index; }

        public String getTEID(){
            return TE.Id;
        }

        public void setAllOrigs() {
            if ( TE != null && TC != null) { //used to 'revert' the stuff
                originalBriefDesc = TC.Brief_Description__c;
                originalLongDesc = TC.Steps_to_Reproduce__c;
                originalStatus = TE.Status__c;
                originalEResults = TC.Expected_Results__c;
                originalHier = TC.Hierarchy__c;
                originalType = TE.Type__c;
                originalBugs = TE.Bugs__c;
            }
        }

        public void setAllEdit(boolean a) {
            this.editBriefDesc = a;
            this.editLongDesc = a;
            this.editStatus = a;
            this.editEResults = a;
            this.editHier = a;
            this.editBugs = a;
            this.editType = a;
        }

        public void setAllEditsBackToOriginal() {
            TE.Bugs__c = originalBugs;
            TE.Status__c = originalStatus;
            TE.Type__c = originalType;
            //TC.Brief_Description__c = originalBriefDesc;
            //TC.Steps_to_Reproduce__c = originalLongDesc;
            //TC.Expected_Results__c = originalEResults;
            //TC.Hierarchy__c = originalHier;
            refreshTC();
        }

        public Boolean refreshTC() {
            Boolean success = true;
            try { TC = [SELECT Id, name, Brief_Description__c, Steps_To_Reproduce__c, Hierarchy__c,
            Expected_Results__c FROM QA_Test_Case__c where Id =: TE.Test_Case__c]; }
            catch (exception e) {
                success = false;
            }
            return success;
        }

        public QA_Test_Execution__c getTe(){ return this.TE; }
        public QA_Test_Case__c getTc(){ return this.TC; }

        public boolean getCbox(){ return this.cbox; }
        public void setCbox(boolean b){ this.cbox = b; }

        public Boolean getIsUpdating () { return this.isUpdating; }
        public void setIsUpdating (boolean a) { this.isUpdating = a; }

        public String getBriefDesc() { return this.TC.Brief_Description__c; }
        public String getStepsReproduce() { return this.TC.Steps_To_Reproduce__c; }
        public String getEResults() { return this.TC.Expected_Results__c; }
        public String getHier() { return this.TC.Hierarchy__c; }

        public Boolean otherColumnEditing() { return ( editBriefDesc || editLongDesc || editStatus || editEResults || editHier || editType || editBugs ); }

        public Boolean getShouldEditBriefDesc() { return this.editBriefDesc; }
        public void setShouldEditBriefDesc(boolean a){
            if (this.locked) return;
            this.editBriefDesc = true;
            isUpdating = true;
        }

        public Boolean getShouldEditLongDesc() { return this.editLongDesc; }
        public void setShouldEditLongDesc(boolean a) {
            if (this.locked) return;
            this.editLongDesc = true;
            isUpdating = true;
        }

        public Boolean getShouldEditStatus() { return this.editStatus; }
        public void setShouldEditStatus(boolean a){
            if (this.locked) return;
            this.editStatus = true;
            isUpdating = true;
        }

        public Boolean getShouldEditEResults() { return this.editEResults; }
        public void setShouldEditEResults(boolean a){
            if (this.locked) return;
            this.editEResults = true;
            isUpdating = true;
        }

        public Boolean getShouldEditHier() { return this.editHier; }
        public void setShouldEditHier(boolean a){
            if (this.locked) return;
            this.editHier = true;
            isUpdating = true;
        }

        public Boolean getShouldEditType() { return this.editType; }
        public void setShouldEditType(boolean a) {
            if (this.locked) return;
            this.editType = true;
            isUpdating = true;
        }

        public Boolean getShouldEditBugs() { return this.editBugs; }
        public void setShouldEditBugs(boolean a){
            if (this.locked) return;
            this.editBugs = true;
            isUpdating = true;
        }

        public String getRevertBriefDesc() { return null; }
        public void setRevertBriefDesc(String a) {
            this.TC.Brief_Description__c = originalBriefDesc;
            this.editBriefDesc = false;
        }
        public String getRevertLongDesc() { return null; }
        public void setRevertLongDesc(String a) {
            this.TC.Steps_to_Reproduce__c = originalLongDesc;
            this.editLongDesc = false;
        }
        public String getRevertStatus() {return null; }
        public void setRevertStatus(String a) {
            this.TE.Status__c = originalStatus;
            this.editStatus = false;
        }
        public String getRevertEResults() { return null; }
        public void setRevertEResults(String a) {
            this.TC.Expected_Results__c = originalEResults;
            this.editEResults = false;
        }
        public String getRevertHier() { return null; }
        public void setRevertHier(String a) {
            this.TC.Hierarchy__c = originalHier;
            this.editHier = false;
        }
        public String getRevertBugs() { return null; }
        public void setRevertBugs(String a) {
            this.TE.Bugs__c = originalBugs;
            this.editBugs = false;
        }
        public String getRevertType() { return null; }
        public void setRevertType(String a) {
            this.TE.Type__c = originalType;
            this.editType = false;
        }

        public String getUserStory(){
            if(this.TE.User_Story__r.name == NULL){ return '';}
            else{ return this.TE.User_Story__r.name; }
        }
        public String getTESprint(){
            if(this.TE.User_Story__r.Sprint__r.name == NULL){ return ''; }
            else{ return this.TE.User_Story__r.Sprint__r.name; }
        }
        public String getTEScrum(){
            if(this.TE.User_Story__r.Sprint__r.Scrum_Team__c == NULL){ return ''; }
            else { return this.TE.User_Story__r.Sprint__r.Scrum_Team__r.name; }
        }

    }

    //used to populate the pageBlockTable with the pending test executions
    public TEContainer[] getTestExecs() {
        if (init==false) {
            this.filter();
            init=true;
        }
        return this.testExecs;
    }

    public void sortByCol() {
        toggleSort(this.sortBy);
        PageReference pg =  this.filter();
    }

    public void toggleSort(String col) {
        
        if(col != this.lastSort) {
            this.sortDir = 'ASC';
            return;
        }
        if(this.sortDir == 'ASC')
            this.sortDir = 'DESC';
        else
            this.sortDir = 'ASC';
    }

    public String getSortDir() { return sortDir; }
    public void setSortDir(String dir) { sortDir = dir; }

    public void doNothing(){}

    public PageReference changeStatus() {
        for(TEContainer tmpTE: this.testExecs){
            if(tmpTE.cbox == true && tmpTE.TE.Status__c != destState){
                tmpTE.TE.Status__c = destState;
                String toRevert = tmpTE.TE.Status__c;
                try { upsert(tmpTE.TE); }
                catch (Exception e) { tmpTE.TE.Status__c = toRevert; }
                tmpTE.originalStatus = tmpTE.TE.Status__c;
            }
            tmpTE.cbox = false; //clears the check boxes after the commandButton is pressed
        }
        return null;
    }

    public PageReference addBugs() {
        boolean failed = false;
        if (bugList == '') return null;
        else {
            bugList.trim();
            for(TEContainer tmpTE: this.testExecs){
                if(tmpTE.cbox == true){
                    tmpTE.cbox = false;
                    String toRevert = tmpTE.TE.Bugs__c;
                    if(tmpTE.TE.Bugs__c == null) tmpTE.TE.Bugs__c  = bugList;
                    else tmpTE.TE.Bugs__C = tmpTE.TE.Bugs__c + ',' + bugList;
                    try { upsert(tmpTE.TE); }
                    catch (Exception e){ tmpTE.TE.Bugs__c = toRevert; }
                    tmpTE.originalBugs = tmpTE.TE.Bugs__c;
                }
            }
            bugList = '';
            return null;
        }
    }

    //iterate through all of the checkboxes and enable them
    public void selectAll(){
        if (isUpdating==false) {
            for(TEContainer tmpTE: this.testExecs){
            tmpTE.cbox = true;
            }
        }
    }

    //iterate through all of the checkboxes and disable them
    public void selectNone(){
        if (isUpdating==false) {
            for(TEContainer tmpTE: this.testExecs){
                tmpTE.cbox = false;
            }
        }
    }

    //this tests if the size is over 49, since there is a 50 object return limit on the SOQL query
    public Boolean getTESizeOverFifty() {
        if (testExecs.size() == 50) return true;
        else return false;
    }

    public void lockOthers(){
        for (TEContainer temp : testExecs) {
            if (!temp.isUpdating) temp.locked = true;
            else temp.locked = false;
        }
    }

    public void unlockAll() { //unlock current only if there isn't other stuff editing
        boolean unlock = true;
        for (TEContainer temp : testExecs) {
            if (temp.isUpdating && temp.otherColumnEditing()) {
                unlock = false;
            }
        }
        if (unlock) {
            for (TEContainer temp : testExecs) {
                temp.setIsUpdating(false);
                temp.setAllEdit(false);
                temp.locked = false;
            }
        }
    }

    public void resetTestExecs(){
        this.testExecs = new TEContainer[]{};
    }

    public PageReference saveAllUpdatedTEs() {
        for (TEContainer temp : testExecs) {
            if (temp != null) {
                if (temp.getIsUpdating()) {
                    temp.setIsUpdating(false);
                    temp.setAllEdit(false);
                    if(temp.TC.Brief_Description__c == null || temp.TC.Brief_Description__c == '') {
                        temp.TC.Brief_Description__c = temp.originalBriefDesc;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter a value for the Brief Description!');
                        ApexPages.AddMessage(myMsg);
                    }
                    if(temp.TC.Hierarchy__c == null || temp.TC.Hierarchy__c == '') {
                        temp.TC.Hierarchy__c = temp.originalHier;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter a value for the Hierarchy!');
                        ApexPages.AddMessage(myMsg);
                    }
                    try {
                        update(temp.TC);
                        update(temp.TE);
                    } catch (Exception e) {
                        //revert only the stuff that failed. I.E. if the upsert for it worked, than it won't actually get reverted with the cancel method
                        cancelAllUpdatedTEs();
                    }
                    temp.setAllOrigs();
                }
            temp.locked = false;
            }
        }
        refreshTCs();
        return null;
    }

    public void refreshTCs() {
        Boolean failure = false;
        for (TEContainer temp : testExecs) {
            if (!temp.refreshTC()) failure = true;
            }
        if (failure) this.filter();
    }

    public PageReference cancelAllUpdatedTEs() {
        this.setIsUpdating(false);
        for (TEContainer temp : testExecs) {
            if (temp != null) {
                temp.setIsUpdating(false);
                temp.setAllEdit(false);
                temp.locked = false;
                temp.setAllEditsBackToOriginal();
            }
        }
        return null;
    }

    //populates the 'Mark As' select list
    public List<SelectOption> getMarkOptions() {
        List<SelectOption> markOptions = new List<SelectOption>();
        Schema.DescribeFieldResult F = QA_Test_Execution__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> statusOptions = F.getPicklistValues();
        for (Schema.PicklistEntry statusOption : statusOptions )
            markOptions.add( new SelectOption( statusOption.getLabel(), statusOption.getLabel() ) );
        return markOptions;
    }

    //populates the filtering options list
    public List<SelectOption> getFilterOptions() {
        List<SelectOption> filterOptions = new List<SelectOption>();
        filterOptions.add(new SelectOption('All','All'));
        filterOptions.add(new SelectOption('Test Executions to Automate','Test Executions to Automate'));
        Schema.DescribeFieldResult F = QA_Test_Execution__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> executionTypes = F.getPicklistValues();
        for (Schema.PicklistEntry executionType : executionTypes )
            filterOptions.add( new SelectOption( executionType.getLabel(), executionType.getLabel() ) );
        return filterOptions;
    }

    //populates the 'Sort By' select list
    public List<SelectOption> getSortOptions() {
        List<SelectOption> sortOptions = new List<SelectOption>();
        //sortOptions.add(new SelectOption('SORTBY','Sort By'));
        sortOptions.add(new SelectOption('TE Number','TE Number'));
        sortOptions.add(new SelectOption('Test Case','Test Case Number'));
        sortOptions.add(new SelectOption('Status','Status'));
        sortOptions.add(new SelectOption('Hierarchy','Hierarchy'));
        sortOptions.add(new SelectOption('Brief Description','Brief Description'));
        sortOptions.add(new SelectOption('User Story','User Story'));
        sortOptions.add(new SelectOption('Sprint','Sprint'));
        sortOptions.add(new SelectOption('Scrum','Scrum Team'));
        return sortOptions;
    }


    public Boolean getIsUpdating() {
        for (TEContainer temp: testExecs) {
            if (temp != null) {
                if (temp.isUpdating) {
                    this.isUpdating = true;
                    return this.isUpdating;
                }
            }
        }
        this.isUpdating = false;
        return this.isUpdating;
    }
    public void setIsUpdating(Boolean a) { isUpdating = a; }

    public String getDestState() { return this.destState; }
    public void setDestState(String destState) { this.destState = destState; }

    public String getSortBy() { return this.sortBy; }
    public void setSortBy(String sortBy) { this.sortBy = sortBy;}
    

    public String getFilterBy() { return this.filterBy; }
    public void setFilterBy(String filterBy) { this.filterBy = filterBy;}

    public String getBugList() { return this.bugList; }
    public void setBugList(String bugList) { this.bugList = bugList; }

    public void setAssignee(String assignee){
        this.assignee = assignee;
    }

    //perform the filtering on the set of objects
    public PageReference filter() {
        Integer counter = 1;
        this.testExecs = new TEContainer[]{};
        List<QA_Test_Execution__c> temp;

        if(sortCol.equals('Sprint')) this.sortBy = 'User_Story__r.Sprint__c';
        else if (sortCol.equals('TE Number')) this.sortBy = 'Name';
        else if (sortCol.equals('Name')) this.sortBy = 'Name';
        else if (sortCol.equals('Test Case')) this.sortBy = 'Test_Case__r.name';
        else if (sortCol.equals('Brief Description')) this.sortBy = 'Test_Case__r.Brief_Description__c';
        else if (sortCol.equals('Status')) this.sortBy = 'Status__c';
        else if (sortCol.equals('User Story')) this.sortBy = 'User_Story__r.Name';
        else if (sortCol.equals('Bugs')) this.sortBy = 'Bugs__c';
        else if (sortCol.equals('Hierarchy')) this.sortBy = 'Test_Case__r.Hierarchy__c';
        else if (sortCol.equals('Scrum')) this.sortBy = 'User_Story__r.Sprint__r.Scrum_Team__r.name';


        if(filterBy == 'All') {
            String strSOQL = 'Select Id, Number_of_Executions__c, name, Type__c, Bugs__c, Status__c, Test_Case__c, User_Story__r.name, User_Story__r.Sprint__c, User_Story__r.Sprint__r.Scrum_Team__r.name, User_Story__r.Sprint__r.name FROM QA_Test_Execution__c WHERE Assignee__c = \'' + String.escapeSingleQuotes(assignee) + '\' AND Status__c != \'Passed\' ORDER BY ' + sortBy + ', name ' + sortDir + ' LIMIT 50';
            temp = Database.query(strSOQL);
        }
        else if (filterBy == 'Test Executions to Automate') {
            String strSOQL = 'Select Id, Number_of_Executions__c, name, Type__c, Bugs__c, Status__c, Test_Case__c, User_Story__r.name, User_Story__r.Sprint__c, User_Story__r.Sprint__r.Scrum_Team__r.name, User_Story__r.Sprint__r.name FROM QA_Test_Execution__c WHERE Assignee__c = \'' + String.escapeSingleQuotes(assignee) + '\' AND Status__c != \'Passed\' AND Type__c != \'Manual\' ORDER BY ' + sortBy + ', name ' + sortDir + ' LIMIT 50';
            temp = Database.query(strSOQL);
        }
        else {
            String strSOQL = 'Select Id, Number_of_Executions__c, name, Type__c, Bugs__c, Status__c, Test_Case__c, User_Story__r.name, User_Story__r.Sprint__c, User_Story__r.Sprint__r.Scrum_Team__r.name, User_Story__r.Sprint__r.name FROM QA_Test_Execution__c WHERE Assignee__c = \'' + String.escapeSingleQuotes(assignee) + '\' AND Status__c != \'Passed\' AND Type__c = \'' + String.escapeSingleQuotes(filterBy) + '\' ORDER BY ' + sortBy + ', name ' + sortDir + ' LIMIT 50';
            temp = Database.query(strSOQL);
        }

        if (temp != null) {
            for (QA_Test_Execution__c tmpTE : temp) {
                    this.testExecs.add(new TEContainer(tmpTE, counter++));
                }
        }

        lastSort = sortBy;
        return null;
    }

}