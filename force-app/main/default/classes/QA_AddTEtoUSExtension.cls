public with sharing class QA_AddTEtoUSExtension {
    public class TEResult{
        public QA_Test_Execution__c te { get; set; }
        public String isSuccess { get; set; }
        public String id { get; set; }
        public String tcName { get; set; }

        public TEResult(Database.SaveResult saveResult, QA_Test_Execution__c te, String tcName) {
            this.te = te;
            this.tcName = tcName;

            if(saveResult.isSuccess()) {
                isSuccess = '/img/approvals/checkbox_16x16.gif';
                id = saveResult.getId();
            } else {
                isSuccess = '/img/approvals/stopsign_16x16.gif';
                id = '';
            }
        }
    }

    public class ParameterException extends Exception {}

    public ADM_TextUtils admTextUtils = new ADM_TextUtils();
    public String curUSID { get; set; } //GET parameter for the User Story id
    public String curTPID { get; set; } //GET parameter for the Test Plan id
    public QA_Test_Execution__c baseTE { get; set; } //base TE to capture user input
    public ADM_Work__c curUS { get; set; } //the current US
    public ADM_Work__c[] possibleUS { get; set; } //possible USs if a TP id is passed in
    public Integer possibleUSSize {get; set;}
    public QA_TreeLibrary treeLib;
    public Integer currentStep { get; set; }
    public Boolean bugValidationError;

    public List<QA_Test_Case__c> selectedTestCases { get; set; } //selected TC list
    public List<TEResult> createdTEResults { get; set; } //selected TC list

    public QA_AddTEtoUSExtension(QA_TreeLibrary treeLib) {
        this.curUSID = System.currentPageReference().getParameters().get('usid');
        this.curTPID = System.currentPageReference().getParameters().get('tpid');

        if(this.curUSID != null) {
            this.curUS = ADM_Work.getOneBy('Id', this.curUSID);

            this.currentStep = 1;
        } else if(this.curTPID != null) {
            this.possibleUS = ADM_Work.getAllBy('Test_Plan__c', new List<String>{this.curTPID}, 1, 1000, 'Id', 'ASC');
            possibleUSSize = possibleUS.size();

            this.currentStep = 0;
        } else {
            throw new ParameterException('No User Story nor Test Plan ID provided.');
        }

        this.treeLib = treeLib;

        this.selectedTestCases = new List<QA_Test_Case__c>();
        this.createdTEResults = new List<TEResult>();
        this.baseTE = new QA_Test_Execution__c();
        this.bugValidationError = false;
    }

    public String getUserStoryInfo() {
        String html = '<table width=\"100%\">';
        html += '<tr><td width=\"150px\"><strong>User Story:</strong></td>';
        html += '<td><a target=\"_blank\" href=\"/' + this.curUS.Id + '\">' + this.curUS.Name + '</a></td></tr>';
        if(this.curUS.Description__c != null) {
            html += '<tr><td>' + admTextUtils.escapeHTML(this.curUS.Description__c) + '</td></tr>';
        }
        
        if(this.curUS.Sprint__r.Name != null) {
            html += '<tr><td><strong>Sprint:</strong></td>';
            html += '<td>' + admTextUtils.escapeHTML(this.curUS.Sprint__r.Name)+ '</td></tr>';
        }
        
        html += '</table>';

        return html;
    }

    public PageReference toStep2() {
        if(this.treeLib.tree.selectedIDs.isEmpty()) {
            this.treeLib.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one Test Case.');
        } else {
            this.selectedTestCases = [Select Id, Brief_Description__c, Hierarchy__c, Execution_Type__c, Priority__c from QA_Test_Case__c WHERE Id in :this.treeLib.tree.selectedIDs];
            this.currentStep = 2;
        }
        return null;
    }

    public PageReference createTEs() {
        //validate bug numbers
        Integer bugNum;
        this.bugValidationError = false;
        if(this.baseTE.Bugs__c != null) {
            //iterate through bug list and make sure all are valid bug ids
            for(String curBug : this.baseTE.Bugs__c.split(',')) {
                curBug = curBug.trim();

                //either in the form of "W-000000" or an integer between 1000 and 10000000
                if(curBug.startsWith('W-') && curBug.length() == 8) {
                    try{
                        bugNum = Integer.valueOf(curBug.substring(2)); //strip the "W-" and check if the rest is an integer
                    } catch(Exception e) { //not an integer
                        this.bugValidationError = true;
                        return null;
                    }
                //make sure its an integer between 1000 and 10000000
                } else if(curBug.length() >= 4 && curBug.length() <= 8) {
                    try{
                        bugNum = Integer.valueOf(curBug); //convert string to integer and make sure its the right size
                        if(bugNum < 1000 || bugNum > 10000000) {
                            this.bugValidationError = true;
                            return null;
                        }
                    } catch(Exception e) { //not an integer
                        this.bugValidationError = true;
                        return null;
                    }
                //not in the correct form
                } else {
                    this.bugValidationError = true;
                    return null;
                }
            }
        }

        //if no status selected, set it as planned
        if(this.baseTE.Status__c == null) this.baseTE.Status__c = 'Planned';
        //validations to make sure theres a date of last execution for passed and failed statuses
        if((baseTE.Status__c.equals('Passed') || baseTE.Status__c.equals('Failed')) && baseTE.Date_of_Last_Execution__c == null) return null;

        //create a new execution for each selected TE
        List<QA_Test_Execution__c> newTEs = new List<QA_Test_Execution__c>();
        for(QA_Test_Case__c curTC : this.selectedTestCases) {
            QA_Test_Execution__c newTE = new QA_Test_Execution__c();
            newTE.Test_Case__c = curTC.Id;
            newTE.Assignee__c = this.baseTE.Assignee__c;
            newTE.Type__c = this.baseTE.Type__c;
            newTE.User_Story__c = this.curUSID;
            newTE.Status__c = this.baseTE.Status__c;
            newTE.Bugs__c = this.baseTE.Bugs__c;
            newTE.Number_Of_Executions__c = this.baseTE.Number_Of_Executions__c;
            newTE.Build_of_Last_Execution__c = this.baseTE.Build_of_Last_Execution__c;
            newTE.Date_of_Last_Execution__c = this.baseTE.Date_of_Last_Execution__c;

            newTEs.add(newTE);
        }
        
        try {
            Database.SaveResult[] results = Database.insert(newTEs);
            for(Integer i=0; i<results.size(); i++) {
                this.createdTEResults.add(new TEResult(results[i], newTEs[i], this.selectedTestCases[i].Brief_Description__c));
            } 
    
            this.currentStep = 3;   
        } catch (System.DmlException e) {
            Apexpages.addMessages(e);
        }

        return null;
    }

    public String getBugValidationError() {
        if(this.bugValidationError) {
            return '<strong>Error: </strong>Bugs should be seperated by \',\' and be a number between 1000 - 10000000 or else it should start with \'W-\' followed by a six digit number';
        } else {
            return '';
        }
    }

    public Boolean getDateRequired() {
        if(baseTE.Status__c == 'Passed' || baseTE.Status__c == 'Failed') {
            return true;
        } else {
            return false;
        }
    }

    public PageReference toReturnPage() {
        if(curTPID != null) {
            return new PageReference('/' + curTPID);
        } else {
            return new PageReference('/' + curUSID);
        }
    }

}