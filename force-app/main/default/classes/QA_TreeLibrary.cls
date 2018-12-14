public with sharing class QA_TreeLibrary {
    /**
    * Container class for all of the variables used to communicate with the VF page and those that keep track of the status of the tree.
    **/
    public class Tree {
        // variables needed to communicate with the VF page.
        public Integer uiWidth { get; set; }
        public String baseHierarchy { get; set; }
        public String branchesCookie { get; set; }
        public String hierCookie { get; set; }
        public String postOpenTask { get; set; }
        public Boolean showAddTCBtn { get; set; }
        public String addTCsPath { get; set; }
        public String treePath { get; set; }
        public String selectedBranch { get; set; }
        public String elemId { get; set; }
        public String targetBranchId { get; set; }
        public String targetElemId { get; set; }
        public String curDetails { get; set; }
        public String selectedId { get; set; }
        public String selectedPath { get; set; }
        public String markAsStatus { get; set; }
        public String changedOrderId { get; set; }
        public String changedOrderPath { get; set; }
        public Integer changedOrderValue { get; set; }
        public List<String> curBranch { get; set; }
        public List<String> openBranchQueue { get; set; }
        public String openBranchHier { get; set; }
        public String acHier { get; set; }
        public String acMatches { get; set; }
        public Integer acMatchCount { get; set; }
        public String searchTerm { get; set; }
        public String searchPath { get; set; }
        public String searchMatches { get; set; }
        public String relatedToFilter { 
            get {
                if(this.relatedToFilter == null)
                    this.relatedToFilter = 'All';
                return this.relatedToFilter;
            }
            set;
        }
        public String priorityFilter { 
            get {
                if(this.priorityFilter == null)
                    this.priorityFilter = 'All';
                return this.priorityFilter;
            }
            set;
        }
        public String executionTypeFilter {
            get {
                if(this.executionTypeFilter == null)
                    this.executionTypeFilter = 'All';
                return this.executionTypeFilter;
            }
            set;
        }
        public String statusFilter {
            get {
                if(this.statusFilter == null)
                    this.statusFilter = 'All';
                return this.statusFilter;
            }
            set;
        }
        public QA_Test_Execution__c dummyTE { get; set; }
        
        //stores primary controller info if the tree is used to extend a standard controller (i.e. sprint detail page)
        public Id id;
        private Schema.SObjectType sobjectType;
        
        //return url
        private String returnUrl;
        
        //autocomplete status trackers to make the AC cache work
        private Integer acLastDepth;
        private String[] acLastHierArr;
        private List<String> acLastMatches;
        
        //status variables used by this controller and controllers that extend it
        public Set<String> selectedIDs;
        private Map<String, Integer> selectedPaths;
        private Map<String, Integer> changedOrders;
        private Map<String, Integer> changedOrderPaths;
        private Map<String, Integer> openBranches;
        
        //initialize the object
        public Tree() {
            this.uiWidth = 0;
            this.baseHierarchy = 'All';     
            this.showAddTCBtn = false;
            this.elemId = null;
            this.curDetails = '';
            this.acLastDepth = -1;
            this.acLastHierArr = null;
            this.sobjectType = null;
            this.addTCsPath = '';
            
            this.openBranchQueue = new List<String>();
            this.curBranch = new List<String>();
            this.selectedIDs = new Set<String>();
            this.selectedPaths = new Map<String, Integer>();
            this.changedOrders = new Map<String, Integer>();
            this.changedOrderPaths = new Map<String, Integer>();
            this.openBranches = new Map<String, Integer>();
            this.acLastMatches = new List<String>();
            
            this.dummyTE = new QA_Test_Execution__c();
        }
    }
    
    public Tree tree{ get; set; }
    
    /**
    * Returns any confirmation, warning, or error messages.
    **/
    public String confirmationMessage{
        get {
            String tmpStr = this.confirmationMessage;
            this.confirmationMessage = '';
            return tmpStr;
        }
        set { this.confirmationMessage = value; }
    }
    
    /**
    * Initialize the tree library.
    **/
    public QA_TreeLibrary() {
        this.tree = new Tree();
        this.confirmationMessage = '';
        
        //generate return url
        String curUrl = ApexPages.currentPage().getUrl();
        if (curUrl == null || curUrl == '') {
            this.tree.returnUrl = '';
        } else {
            if(curUrl.contains('?')){
            	//we shouldn't need this, but was causing some errors for Neil's user
            	Integer questionInd = curUrl.indexOf('?');
            	if(questionInd < 0)
            		this.tree.returnUrl = curUrl;
            	else
            		this.tree.returnUrl = curUrl.substring(0, curUrl.indexOf('?'));
            } else {
            	this.tree.returnUrl = curUrl;
            }
        }
    }
    
    /**
    * Initialize the tree library with a standard controller.
    **/
    public QA_TreeLibrary(ApexPages.StandardController stdController){
        this.tree = new Tree();
        this.confirmationMessage = '';
        
        //get the controller id, used to query TEs for that specific controller
        this.tree.id = stdController.getId();
        //set the return url
        this.tree.returnUrl = this.tree.id;
        //check what type of controller it is (Sprint or User Story)
        this.tree.sobjectType = stdController.getRecord().getSObjectType();
    }
    
    /**
    * Parses a string of branches and adds in the appropriate order the branches to tree.openBranchesQueue.
    *
    * @param branchesStr String of '|~|' pattern delimated branches to add to tree.openBranchesQueue.
    **/
    public void fillOpenBranchesQueue(String branchesStr){
        //clear the task values so old task isn't performed again after everything loads
        this.tree.postOpenTask = '';
        
        //if branches string not empty, fill the queue
        if(branchesStr != null && !branchesStr.equals('')){
            //if no sobjectType, then a TC tree, so have to add path sequentially since everything is loaded dynamically 
            //i.e. for branch "Branch 1.Branch 2.Branch 3", have to add "Branch 1" and "Branch 1.Branch 2" to the queue before the actual branch
            if(this.tree.sobjectType == null){
                //build up a list of sets of branches ordered by depth to fill up the open branches queue since an inner branch can't be opened until its containing branch is opened
                List<Set<String>> branches = new List<Set<String>>();
                List<String> pathArr = new List<String>();
                String curPath;
                for(String curBranch : branchesStr.split('[|][~][|]')) { //split up each branch
                        pathArr = curBranch.split('[.]');
                        
                        //add each path sequentially
                        curPath = '';
                        for(Integer i = 0; i < pathArr.size(); i++){
                            if(i == 0)
                                curPath += pathArr[i];
                            else
                                curPath += '.' + pathArr[i];
                            
                            if(i < branches.size())
                                branches[i].add(curPath);
                            else
                                branches.add(new Set<String>{curPath});
                        }
                }
                
                //fill up the open branches queue
                for(Set<String> curBranchSet : branches)
                    for(String curBranch : curBranchSet)
                        this.tree.openBranchQueue.add(EncodingUtil.urlDecode(curBranch, 'UTF-8'));
            } else {
                //if there is a sobjectType, then its a TE tree, so you dont have to add the paths sequentially         
                for(String curBranch : branchesStr.split('[|][~][|]'))
                    this.tree.openBranchQueue.add(EncodingUtil.urlDecode(curBranch, 'UTF-8'));
            }
        }
    }
    
    /**
    * Fill up tree.openBranchesQueue with the branches string stored in a cookie.
    **/
    public void initializeBranches(){
        fillOpenBranchesQueue(this.tree.branchesCookie);
    }
    
    /**
    * Dummy function since all actionFunctions have to have an associated function.
    **/
    public void doNothing(){ }
    
    /**
    * Generates the HTML for TE tree.
    **/
    private String getBaseTETree() {
        //try to query for all of the matching TEs, and sort them by status, assignee, and hierarchy, just as the branches of the tree are organized
        try{
            return QA_TreeLibraryStatic.getBaseTETree(this.tree.sobjectType, 
                                                   this.tree.uiWidth, 
                                                   this.tree.statusFilter, 
                                                   this.tree.relatedToFilter, 
                                                   this.tree.executionTypeFilter, 
                                                   this.tree.id, 
                                                   this.tree.showAddTCBtn);
        } catch(Exception e) {
            return 'Tree not initialized. Error: ' + e.getMessage();
        }
    }
    
    /**
    * Generates the HTML for TC tree.
    *
    * @param this.tree.baseHierarchy The top most hierarchy to generate the tree for with "All" or "" indicating the entire tree.
    **/
    private String getBaseTCTree() {
        //try{
            //try to query for the appropriate Test Cases
            if(this.tree.baseHierarchy.equals('')) this.tree.baseHierarchy = 'All';
            String baseHierarchy = this.tree.baseHierarchy;
            baseHierarchy = QA_TreeLibraryStatic.escapeSpecials(baseHierarchy, false);
            
            //generate the HTML
            String html = '<table width=\"' + this.tree.uiWidth + '\" bgcolor=\"#F2F2F2\" id=\"' + baseHierarchy + '.table\" cellpadding=\"0\" cellspacing=\"0\" class=\"textRegular borderLeftDark borderRightDark borderTopDark borderBottomDark\"><tbody>';
            html += '<tr><td><div id=\"' + baseHierarchy + '.div\">';
            html += '<table cellpadding=\"0\" cellspacing=\"0\" class=\"textRegular sizeFill\"><tbody>';
            html += '<tr height=\"22\" id=\"' + baseHierarchy + '.highlight\" onmouseover=\"toggleHighlight(\'' + baseHierarchy + '\')\" onmouseout=\"toggleHighlight(\'' + baseHierarchy + '\')\" class=\"defaultCursor\">';
            html += '<td width=\"20\" onmousedown=\"toggleBranch(\'' + baseHierarchy + '\')\" bgcolor=\"#DDDDDD\" style=\"vertical-align: middle; text-align: right\"><img id=\"' + baseHierarchy + '.twist\" src=\"/img/twistySubhDown.gif\" /></td>';
            html += '<td>';
            html += '<table cellpadding=\"0\" cellspacing=\"0\" class=\"textRegular sizeFill\">';
            html += '<tr><td onmousedown=\"toggleBranch(\'' + baseHierarchy + '\')\" style=\"vertical-align: middle; text-align: left\">';
            html += '<input type=\"hidden\" id=\"' + baseHierarchy + '.count\" value=\"0\" />';
            html += '<input type=\"hidden\" id=\"' + baseHierarchy + '.name\" value=\"' + baseHierarchy + '\" />';
            html += '<input type=\"hidden\" id=\"' + baseHierarchy + '.loaded\" value=\"true\" />';
            html += '<div id=\"' + baseHierarchy + '.label\" class=\"textBold\">&nbsp;&nbsp;' + baseHierarchy + '</div>';
            html += '</td>';
            html += '<td width=\"200\" style=\"vertical-align: middle; text-align: right\">';
            if(this.tree.showAddTCBtn && baseHierarchy != 'All') html += '(<a onmousedown=\"addTCs(\"' + baseHierarchy + '\")\" class=\"bodyTextUnderline\">Add Test Cases</a>)&nbsp;&nbsp;';
            html += '</td></tr></table>';
            html += '</td>';
            html += '</tr>';
            html += '<tr><td height=\"2\" colspan=\"2\" bgcolor=\"#BBBBBB\"></td></tr>';
            html += '<tr id=\"' + baseHierarchy + '.branch\">';
            html += '<td bgcolor=\"#EEEEEE\"></td>';
            html += '<td class=\"treeBranch\"><div id=\"' + baseHierarchy + '.content\">';
            
            //generate the first level of branches
            if(baseHierarchy.equals('All')){ //if the path is All, load the base tree
                for(QA_Hierarchy__c curHier : [SELECT Name, Full_Path__c, Id FROM QA_Hierarchy__c WHERE Depth__c = 0 AND Count__c > 0 ORDER BY Name]){
                    String name = EncodingUtil.urlEncode(curHier.Name,'UTF-8');    
                    String fullPath = EncodingUtil.urlEncode(curHier.Full_Path__c,'UTF-8');
                    html += QA_TreeLibraryStatic.generateBranch(name, fullPath, '', false, false, false, this.tree.showAddTCBtn);
                }
            }else{ //if a path is set, i.e. path filter is set
                //just in case the base hierarchy ended with a "." by accident
                if(baseHierarchy.endsWith('.')) baseHierarchy = baseHierarchy.substring(0, baseHierarchy.length()-1);
                Integer hierDepth = baseHierarchy.split('[.]').size();
                
                for(QA_Hierarchy__c curHier : [SELECT Name, Full_Path__c, Id FROM QA_Hierarchy__c WHERE Full_Path__c LIKE :(baseHierarchy + '.%') AND Depth__c = :hierDepth AND Count__c > 0 ORDER BY Name]){
                    String name = EncodingUtil.urlEncode(curHier.Name,'UTF-8');    
                    String fullPath = EncodingUtil.urlEncode(curHier.Full_Path__c,'UTF-8');
                	html += QA_TreeLibraryStatic.generateBranch(name, fullPath, '', false, false, false, this.tree.showAddTCBtn);
            	}
            }

            //generate any TCs if they exist
            if(!baseHierarchy.equals('All')){ //root hierarchy cant have TCs so don't even bother if it is
                QA_Test_Case__c[] tcs;
                try {
                    //query TCs based on the filter by generating a dyncamic query
                    
                    String query = 'SELECT Brief_Description__c, Order__c, Hierarchy__c, Id, Is_Obsolete__c FROM QA_Test_Case__c WHERE Hierarchy__c = \'' + QA_TreeLibraryStatic.escapeHierarchy(baseHierarchy) + '\'';
                    if(this.tree.priorityFilter != 'All') query += ' AND Priority__c = \'' + String.escapeSingleQuotes(this.tree.priorityFilter) + '\'';
                    query +=  ' ORDER BY Order__c, Name';
                    
                    tcs = Database.query(query); 
                    } catch(Exception e){
                      tcs = new QA_Test_Case__c[0];
                }
                
                //generate all of the TC elements
                for(QA_Test_Case__c curTC : tcs)
                html += QA_TreeLibraryStatic.generateTestCase(curTC.Brief_Description__c, baseHierarchy, curTC.Order__c.intValue(), curTC.Id, curTC.Is_Obsolete__c, false, this.tree.returnUrl);
            }
            
            html += '</div></td>';
            html += '</tr>';
            html += '</tbody></table>';
            html += '</div></td></tr>';
            html += '</tbody></table>';
            
            return html;
        /*} catch(Exception e) {
            return 'Tree not initialized. Error: ' + e.getMessage();
        }*/
    }
    
    /**
    * Generic call to get the base tree, will choose the appropriate method based on the sobjectType.
    **/
    public String getBaseTree(){
        //clear out the selected lists since its a new tree
        this.tree.selectedIDs.clear();
        this.tree.selectedPaths.clear();
        
        //route to the correct function     
        if(this.tree.sobjectType == null)
            return getBaseTCTree();
        else
            return getBaseTETree();
    }
    
    /**
    * Generates the HTML for the TC details drop down and stores it in this.tree.curDetails.
    **/
    private void loadTCDetails() { 
        try{
            //query and generate the HTML
            String tcId = this.tree.elemId;
            QA_Test_Case__c curTC = [SELECT Hierarchy__c, Steps_to_Reproduce__c, Expected_Results__c, Execution_Type__c, Priority__c, Name FROM QA_Test_Case__c WHERE Id = :tcId];
            
            this.tree.curDetails = '<table width=\\"100%\\" cellspacing=\\"0\\" cellpadding=\\"0\\" class=\\"textRegular\\"><tbody>';
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Hierarchy', QA_TreeLibraryStatic.escapeSpecials(curTC.Hierarchy__c, true), true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Steps to Reproduce', QA_TreeLibraryStatic.escapeSpecials(curTC.Steps_to_Reproduce__c, true), true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Expected Results', QA_TreeLibraryStatic.escapeSpecials(curTC.Expected_Results__c, true), true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Execution Type', QA_TreeLibraryStatic.escapeSpecials(curTC.Execution_Type__c, true), true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Priority', curTC.Priority__c, true);
            this.tree.curDetails += '</tbody></table>';
        }catch(Exception e){
            this.tree.curDetails = 'Error loading details for the Test Case, it may have been deleted, please reload the page and try again.';
        }
    }
    
    /**
    * Generates the HTML for the TE details drop down and stores it in this.tree.curDetails.
    **/
    private void loadTEDetails() {
        try{
            //query and generate the HTML
            String teId = this.tree.elemId;
            QA_Test_Execution__c curTE = [SELECT Name, User_Story__r.Name, Number_of_Executions__c, Date_of_Last_Execution__c, Type__c, Test_Case__r.Expected_Results__c 
                                        FROM QA_Test_Execution__c WHERE Id = :teId];
            
            String numOfExecutionStr = (curTE.Number_of_Executions__c == null) ? 'Information not provided.' : curTE.Number_of_Executions__c.format();
            String lastExecutionStr = (curTE.Date_of_Last_Execution__c == null) ? 'Information not provided.' : curTE.Date_of_Last_Execution__c.format('EEE, MM-dd-yyyy h:mm:ss a z');
            
            this.tree.curDetails = '<table width=\\"100%\\" cellspacing=\\"0\\" cellpadding=\\"0\\" class=\\"textRegular\\"><tbody>'; 
            if(tree.sobjectType == QA_Test_Plan__c.getSObjectType() || tree.sobjectType == ADM_Sprint__c.getSObjectType()) this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('User Story', '<a target=\\"_blank\\" href=\\"/' + curTE.User_Story__c + '\\">' + curTE.User_Story__r.Name + '</a>', true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Test Execution Number', curTE.Name, true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Expected Results', QA_TreeLibraryStatic.escapeSpecials(curTE.Test_Case__r.Expected_Results__c, true), true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Type', QA_TreeLibraryStatic.escapeSpecials(curTE.Type__c, true), true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Last Execution', lastExecutionStr, true);
            this.tree.curDetails += QA_TreeLibraryStatic.generateDetailRow('Number of Executions', numOfExecutionStr, true);
            this.tree.curDetails += '</tbody></table>';
        }catch(Exception e){
            this.tree.curDetails = 'Error loading details for the Test Execution, it may have been deleted, please reload the page and try again.';
        }
    }
    
    /**
    * Generic call to get details for an element, will choose the appropriate method based on the sobjectType.
    **/
    public void loadDetails(){
        if(this.tree.sobjectType == null)
            loadTCDetails();
        else
            loadTEDetails();
    }
    
    /**
    * Gets the list of open branches sorted by sets of the branches of the same depth.
    **/
    public List<Set<String>> getOpenBranches(){
        List<Set<String>> branches = new List<Set<String>>();
        
        List<String> pathArr;
        String curPath;
        for(String curBranch : this.tree.openBranches.keySet()) {
            if(this.tree.openBranches.get(curBranch) > 0){
                pathArr = curBranch.split('[.]');
                
                curPath = '';
                for(Integer i = 0; i < pathArr.size(); i++){
                    if(i == 0)
                        curPath += pathArr[i];
                    else
                        curPath += '.' + pathArr[i];
                    
                    if(i < branches.size())
                        branches[i].add(curPath);
                    else
                        branches.add(new Set<String>{curPath});
                }
            }
        }
        
        return branches;
    }
    
    /**
    * Returns a string of open branches sperated by '|~|'.
    **/
    public String getOpenBranchesString(){
        String openBranchesString = '';
        
        Boolean firstBranch = true;
        for(String curBranch : this.tree.openBranches.keySet()){
            if(this.tree.openBranches.get(curBranch) > 0){
                if(firstBranch){
                    openBranchesString = EncodingUtil.urlEncode(curBranch, 'UTF-8');
                    firstBranch = false;    
                }else{
                    openBranchesString += '|~|' + EncodingUtil.urlEncode(curBranch, 'UTF-8');
                }
            }
        }
        
        return openBranchesString;
    }
    
    /**
    * Removes a branch from the list of open branches.
    **/
    public void removeOpenBranch(){
        if(!this.tree.selectedBranch.equals('All')){
            Integer count = this.tree.openBranches.get(this.tree.selectedBranch);
            if(count == null)
                this.tree.openBranches.put(this.tree.selectedBranch, 0);
            else
                this.tree.openBranches.put(this.tree.selectedBranch, count - 1);
        }
    }
    
    /**
    * Add a branch from the list of open branches.
    **/
    public void addOpenBranch(){
        if(!this.tree.selectedBranch.equals('All')){
            Integer count = this.tree.openBranches.get(this.tree.selectedBranch);
            if(count == null)
                this.tree.openBranches.put(this.tree.selectedBranch, 1);
            else
                this.tree.openBranches.put(this.tree.selectedBranch, count + 1);
        }
    }
    
    /**
    * Generate a branch for a TC hierarchy and store it in this.tree.curBranch.
    **/
    private void loadTCBranch() {
        //get the path of the branch to open
        String path = this.tree.treePath;
        String hierPath = '%';
        Integer pathDepth;
        
        //if the path is 'All' retrieve everything with depth 0, else retrieve the branch desired
        if(path.equals('All') || path.equals('')){
            pathDepth = 0;
        } else {
            this.tree.openBranches.put(path, 1);
            pathDepth = path.split('[.]').size();
            hierPath = path + '.' + hierPath;
        }
        
        this.tree.curBranch.clear();

        //query the hierarchies in the current branch and add the hierarchies to the branch
        for(QA_Hierarchy__c curHier : [SELECT Name, Full_Path__c, Id FROM QA_Hierarchy__c WHERE Depth__c = :pathDepth AND Count__c >= 1 AND Full_Path__c LIKE :hierPath ORDER BY Name])
            this.tree.curBranch.add(QA_TreeLibraryStatic.generateBranch(curHier.Name, curHier.Full_Path__c, '', false, false, true, this.tree.showAddTCBtn));
        
        //query and add the TCs to the branch if the branch is not the root
        if(!path.equals('All')){
            String baseHierarchy; 
            if(this.tree.baseHierarchy == '') baseHierarchy = 'All';
            
            String query = 'SELECT Brief_Description__c, Order__c, Hierarchy__c, Id, Is_Obsolete__c FROM QA_Test_Case__c ';
            query += ' WHERE Hierarchy__c = \'' + QA_TreeLibraryStatic.escapeHierarchy(path) + '\'';
            if(this.tree.priorityFilter != 'All')query += ' AND Priority__c = \'' + String.escapeSingleQuotes(this.tree.priorityFilter) + '\'';
            if(this.tree.executionTypeFilter != 'All') query += ' AND Execution_Type__c INCLUDES (\'' + String.escapeSingleQuotes(this.tree.executionTypeFilter) + '\')';
            query +=  ' ORDER BY Order__c, Name';
            QA_Test_Case__c[] tcs = Database.query(query);
            
			addTestCasesToBranch(tcs, path);            
        }
    }
    
    public void addTestCasesToBranch(QA_Test_Case__c[] tcs, String path) {
        for(QA_Test_Case__c curTC : tcs) {
        	// since order__c is not required we need to handle the case where it's null. for now simply set it to 0 so it show up on top
        	integer order = (curTc.order__c==Null)?0:curTc.order__c.intValue();        	
            this.tree.curBranch.add(QA_TreeLibraryStatic.generateTestCase(curTC.Brief_Description__c, path, order, curTC.Id, curTC.Is_Obsolete__c, true, this.tree.returnUrl));
        }    	
    }
    
    /**
    * Generate a branch for a TC hierarchy and store it in this.tree.curBranch.
    **/
    private void loadTEBranch() {
        this.tree.curBranch.clear();
        //put path in open branches set
        this.tree.openBranches.put(this.tree.treePath, 1);
        //query for the TEs of the given parameter and generate a branch with them
        List<String> pathArr = this.tree.treePath.split('[~][.]');
        
        if(pathArr.size() >=3)
            QA_TreeLibraryStatic.loadTEBranch(this.tree.sobjectType, 
                                           this.tree.statusFilter, 
                                           this.tree.relatedToFilter, 
                                           this.tree.executionTypeFilter, 
                                           this.tree.id, 
                                           this.tree.curBranch, 
                                           pathArr, 
                                           this.tree.returnUrl);
    }
    
    /**
    * Generic call to get a branch, will choose the appropriate method based on the sobjectType.
    **/
    public void loadBranch(){
        if(this.tree.sobjectType == null)
            loadTCBranch();
        else
            loadTEBranch();
    }
    
    /**
    * Add an element to the list of selected, also keep track of all the hierarchies that selected elements were from to
    * be able to open them later after an operation.
    **/
    public void selectElem(){
        try{
            if(this.tree.selectedIDs.add(this.tree.selectedId)){
                //if element is not already in the list, add it and increase the count for the hierarchies of selected elements
                Integer pathCount = this.tree.selectedPaths.get(this.tree.selectedPath);
                if(pathCount == null)
                    this.tree.selectedPaths.put(this.tree.selectedPath, 1);
                else
                    this.tree.selectedPaths.put(this.tree.selectedPath, pathCount + 1);
                    
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(1, 'Selected 1 element, ' + this.tree.selectedIDs.size() + ' now selected.');
            }else{
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Element already selected.');
            }
        }catch(Exception e){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(3, 'Error in selecting elements, please try again.');
        }
    }
    
    /**
    * Add a list of elements to the list of selected, also keep track of all the hierarchies that selected elements were from to
    * be able to open them later after an operation.
    **/
    public void selectElems(){
        try{
            List<String> idArr = this.tree.selectedId.split(','); //split the string of element ids
            //split the string of element paths, '|~|' used as the delimeter in case commas are in hierarchy paths
            List<String> pathArr = this.tree.selectedPath.split('[|][~][|]');
            
            Integer numSelected = 0;
            for(Integer i=0; i<idArr.size(); i++){ //go through all of the elements and add them
                if(!idArr[i].equals('') && idArr[i] != null && this.tree.selectedIDs.add(idArr[i])){
                    //if element is not already in the list, add it and increase the count for the hierarchy of current element
                    Integer pathCount = this.tree.selectedPaths.get(pathArr[i]);
                    if(pathCount == null)
                        this.tree.selectedPaths.put(pathArr[i], 1);
                    else
                        this.tree.selectedPaths.put(pathArr[i], pathCount + 1);
                        
                    numSelected++;
                }
            }
            
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(1, 'Selected ' + numSelected + ' element(s), ' + this.tree.selectedIDs.size() + ' now selected.');
        }catch(Exception e){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(3, 'Error in selecting elements, please try again.');
        }
    }
    
    /**
    * Remove an element from the list of selected, also keep track of all the hierarchies that selected elements were from to
    * be able to open them later after an operation.
    **/
    public void deselectElem(){
        try{
            if(this.tree.selectedIDs.remove(this.tree.selectedId)){
                //if element removed successfully, decrement the count for the hierarches of selected elements,
                //and if the count is 0, remove the hierarches from the selected list
                Integer pathCount = this.tree.selectedPaths.get(this.tree.selectedPath);
                if(pathCount != null){
                    if(pathCount <= 1)
                        this.tree.selectedPaths.remove(this.tree.selectedPath);
                    else
                        this.tree.selectedPaths.put(this.tree.selectedPath, pathCount - 1);
                }
                
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(1, 'Unselected 1 element, ' + this.tree.selectedIDs.size() + ' now selected.');
            }else{
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Element not selected selected.');
            }
        }catch(Exception e){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(3, 'Error in unselecting elements, please try again.');
        }
    }
    
    /**
    * Remove a list of elements from the list of selected, also keep track of all the hierarchies that selected elements were from to
    * be able to open them later after an operation.
    **/
    public void deselectElems(){
        try{
            List<String> idArr = this.tree.selectedId.split(','); //split the string of element ids
            //split the string of element paths, '|~|' used as the delimeter in case commas are in hierarchy paths
            List<String> pathArr = this.tree.selectedPath.split('[|][~][|]');
            
            Integer numSelected = 0;
            for(Integer i=0; i<idArr.size(); i++){ //go through all of the elements and remove them
                if(!idArr[i].equals('') && idArr[i] != null && this.tree.selectedIDs.remove(idArr[i])){
                    //if element removed successfully, decrement the count for the hierarches of selected elements,
                    //and if the count is 0, remove the hierarches from the selected list
                    Integer pathCount = this.tree.selectedPaths.get(pathArr[i]);
                    if(pathCount != null){
                        if(pathCount <= 1)
                            this.tree.selectedPaths.remove(pathArr[i]);
                        else
                            this.tree.selectedPaths.put(pathArr[i], pathCount - 1);
                    }   
                    
                    numSelected++;
                }
            }
        
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(1, 'Unselected ' + numSelected + ' element(s), ' + this.tree.selectedIDs.size() + ' now selected.');
        }catch(Exception e){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(3, 'Error in unselecting elements, please try again.');
        }
    }
    
    /**
    * Returns a string of selected element ids.
    **/
    public String getSelectedIDs(String del){
        if(this.tree.selectedIDs.isEmpty()){
            return '';
        }else{
            //create the string, making sure there is no comma after the last element
            String selectedIDStr = '';
            for(String curId : this.tree.selectedIDs) selectedIDStr +=  curId + del;
            
            return selectedIDStr.substring(0, selectedIDStr.length() - 1);
        }
    }
    
    /**
    * Returns a string of paths with selected element id.
    **/
    public String getSelectedPaths(){
        if(this.tree.selectedPaths.isEmpty()){
            return '';
        }else{
            //create the string, making sure there is no comma after the last element
            String selectedPathStr = null;
            for(String curPath : this.tree.selectedPaths.keySet()){
                if(selectedPathStr == null)
                    selectedPathStr = curPath;
                else
                    selectedPathStr += '|~|' + curPath;
            }
            
            return selectedPathStr;
        }
    }
    
    /**
    * Removes the id of a TC that no longer needs its order changed, also keep track of all the hierarchies that TC were from to
    * be able to open them later after an operation.
    **/
    public void removeChangedOrder(){
        if(this.tree.changedOrders.remove(this.tree.changedOrderId) != null){
            //if TC removed successfully, decrement the count for the hierarches of selected TCs,
            //and if the count is 0, remove the hierarches from the selected list
            Integer pathCount = this.tree.changedOrderPaths.get(this.tree.changedOrderPath);
            if(pathCount != null){
                if(pathCount <= 1)
                    this.tree.changedOrderPaths.remove(this.tree.changedOrderPath);
                else
                    this.tree.changedOrderPaths.put(this.tree.changedOrderPath, pathCount - 1);
            }
        }
    }
    
    /**
    * Add the id of a TC that needs its order changed, also keep track of all the hierarchies that TC were from to
    * be able to open them later after an operation.
    **/
    public void addChangedOrder(){
        if(this.tree.changedOrders.put(this.tree.changedOrderId, this.tree.changedOrderValue) == null){
            //if element is not already in the list, add it and increase the count for the hierarchies of selected elements
            Integer pathCount = this.tree.changedOrderPaths.get(this.tree.changedOrderPath);
            if(pathCount == null)
                this.tree.changedOrderPaths.put(this.tree.changedOrderPath, 1);
            else
                this.tree.changedOrderPaths.put(this.tree.changedOrderPath, pathCount + 1);
        }
    }
    
    /**
    * Save the changes to the TC orders.
    **/
    public void changeOrders(){
        if(this.tree.changedOrders.isEmpty()){ //incase no orders where selected, notify the user
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please change the order of at least one Test Case.');
        }else{
            //query the TCs whose orders will be changed and change their orders
            QA_Test_Case__c[] tcs = [SELECT Brief_Description__c, Id, Order__c FROM QA_Test_Case__c WHERE Id in :this.tree.changedOrders.keySet()];
            for(QA_Test_Case__c curTC : tcs) curTC.Order__c = this.tree.changedOrders.get(curTC.Id);
            
            try{//try a batch update
                Database.SaveResult[] results = Database.update(tcs);
                
                //record all failures and successes and report it back to the user
                Integer successes = 0, failures = 0;
                String successStr, failureStr;
                for(Integer i=0; i<results.size(); i++) {
                    if(results[i].isSuccess()){
                        successes++;
                        if(successStr == null)
                            successStr = '<a href=\"/' + tcs[i].Id + '\" class=\"textRegular\" target=\"_top\">' + QA_TreeLibraryStatic.escapeSpecials(tcs[i].Brief_Description__c, false) + '</a>(' + Math.round(tcs[i].Order__c) + ')';
                        else    
                            successStr += ', <a href=\"/' + tcs[i].Id + '\" class=\"textRegular\" target=\"_top\">' + QA_TreeLibraryStatic.escapeSpecials(tcs[i].Brief_Description__c, false) + '</a>(' + Math.round(tcs[i].Order__c) + ')';
                    }else{
                        failures++;
                        if(failureStr == null)
                            failureStr = '<a href=\"/' + tcs[i].Id + '\" class=\"textRegular\" target=\"_top\">' + QA_TreeLibraryStatic.escapeSpecials(tcs[i].Brief_Description__c, false) + '</a>(' + Math.round(tcs[i].Order__c) + ')';
                        else
                            failureStr += ', <a href=\"/' + tcs[i].Id + '\" class=\"textRegular\" target=\"_top\">' + QA_TreeLibraryStatic.escapeSpecials(tcs[i].Brief_Description__c, false) + '</a>(' + Math.round(tcs[i].Order__c) + ')';
                    }
                }
                
                this.confirmationMessage = '';
                if(successes > 0)
                    this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(1, 'Changed the order of ' + successes + ' Test Cases(s): ' + successStr + '.');
                if(failures > 0)
                    this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(3, 'Error changing the order of ' + failures + ' Test Cases(s): ' + failureStr + '.');
            }catch(Exception e){ //report error
                this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(3, 'Error changing the order of Test Cases.');
            }finally{ //clean up
                this.tree.changedOrders.clear();
                this.tree.changedOrderPaths.clear();
                fillOpenBranchesQueue(getOpenBranchesString()); //fill the open branches queue so the tree reloads with the correct branches
            }
        }
    }
    
    /**
    * Save the changes to the TE statuses.
    **/
    public void markAs(){
        if(this.tree.selectedIDs.isEmpty()){ //incase no TEs where selected, warn the user
        	String statusStr = 'Unknown';
        	if (null != this.tree.markAsStatus) statusStr = this.tree.markAsStatus;
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one Test Execution to mark as ' + statusStr);
        }else{
            //query the TEs that need to be modified and modify them and do a batch update
            QA_Test_Execution__c[] tes = [SELECT Id, Name, Status__c FROM QA_Test_Execution__c WHERE Id in :this.tree.selectedIDs];
            for(QA_Test_Execution__c curTE : tes) curTE.Status__c = this.tree.markAsStatus;
            
            try{//try to update
                Database.SaveResult[] results = Database.update(tes);
                
                //record all failures and successes and report it back to the user
                Integer successes = 0, failures = 0;
                String successStr, failureStr;
                for(Integer i=0; i<results.size(); i++) {
                    if(results[i].isSuccess()){
                        successes++;
                        if(successStr == null)
                            successStr = '<a href=\"/' + tes[i].Id + '\" class=\"textRegular\" target=\"_top\">' + tes[i].Name + '</a>';
                        else    
                            successStr += ', <a href=\"/' + tes[i].Id + '\" class=\"textRegular\" target=\"_top\">' + tes[i].Name + '</a>';
                    }else{
                        failures++;
                        if(failureStr == null)
                            failureStr = '<a href=\"/' + tes[i].Id + '\" class=\"textRegular\" target=\"_top\">' + tes[i].Name + '</a>';
                        else
                            failureStr += ', <a href=\"/' + tes[i].Id + '\" class=\"textRegular\" target=\"_top\">' + tes[i].Name + '</a>';
                    }
                }
                
                this.confirmationMessage = '';
                if(successes > 0)
                    this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(1, 'Marked ' + successes + ' (' + successStr + ') Test Execution(s) as ' + this.tree.markAsStatus + '.');
                if(failures > 0)
                    this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(3, 'Error marking ' + failures + ' (' + failureStr + ') Test Execution(s) as ' + this.tree.markAsStatus + '.');
            }catch(Exception e){ //report error
                this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(3, 'Error marking the status of Test Executions.');
            }finally{ //clean up
                this.tree.selectedIDs.clear();
                this.tree.selectedPaths.clear();
                fillOpenBranchesQueue(getOpenBranchesString()); //fill the open branches queue so the tree reloads with the correct branches
            }
        }
    }
    
    /**
    * Clone selected TEs.
    **/
    public void cloneTEs(){
        if(this.tree.selectedIDs.isEmpty()){ //incase no TEs where selected, warn the user
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one Test Execution to clone.');
        }else{
            //query the TEs that need to be cloned and clone them and do a batch insert
            QA_Test_Execution__c[] tes = [SELECT Assignee__c, Status__c, Type__c, Date_of_Last_Execution__c, Number_of_Executions__c, User_Story__c, Test_Case__c FROM QA_Test_Execution__c WHERE Id in :this.tree.selectedIDs];
            QA_Test_Execution__c[] newTEs = new QA_Test_Execution__c[tes.size()];
            for(Integer i=0; i<tes.size(); i++) newTEs[i] = tes[i].clone(false, true);
            
            try{
                Database.SaveResult[] results = Database.insert(newTEs);
                
                //record all failures and successes and report it back to the user
                Integer successes = 0, failures = 0;
                for(Integer i=0; i<results.size(); i++) {
                    if(results[i].isSuccess())
                        successes++;
                    else
                        failures++;
                }
                
                this.confirmationMessage = '';
                if(successes > 0)
                    this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(1, 'Cloned ' + successes + ' Test Execution(s).');
                if(failures > 0)
                    this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(3, 'Error cloning ' + failures + ' Test Execution(s).');
            }catch(Exception e){ //report error
                this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(3, 'Error cloning selected Test Executions.');
            }finally{ //clean up
                this.tree.selectedIDs.clear();
                this.tree.selectedPaths.clear();
                fillOpenBranchesQueue(getOpenBranchesString()); //fill the open branches queue so the tree reloads with the correct branches
            }
        }
    }
    
    /**
    * Delete selected elements.
    **/
    public void deleteSelected(){
        if(this.tree.selectedIDs.isEmpty()){ //incase no element was selected, warn the user
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one object to delete.');
        }else{
            //generate a list of ids of the elements that need to be deleted
            List<String> idList = new List<String>();
            for(String curId : this.tree.selectedIDs) idList.add(curId);
            
            try{
                Database.DeleteResult[] results = Database.delete(idList);
                
                //record all failures and successes and report it back to the user
                Integer successes = 0, failures = 0;
                String failureStr;
                for(Integer i=0; i<results.size(); i++) {
                    if(results[i].isSuccess()){
                        successes++;
                    }else{
                        failures++;
                        if(failureStr == null)
                            failureStr = '<a href=\"/' + results[i].getId() + '\" target=\"_top\">' + results[i].getId() + '</a>';
                        else
                            failureStr += ', <a href=\"/' + results[i].getId() + '\" target=\"_top\">' + results[i].getId() + '</a>';
                    }
                }
                
                this.confirmationMessage = '';
                if(successes > 0)
                    this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(1, 'Deleted ' + successes + ' object(s).');
                if(failures > 0)
                    this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(3, 'Error deleting ' + failures + ' (' + failureStr + ') object(s).');
            }catch(Exception e){ //report error
                this.confirmationMessage += QA_TreeLibraryStatic.generateMessageBox(3, 'Error deleting selected elements.');
            }finally{ //clean up
                this.tree.selectedIDs.clear();
                this.tree.selectedPaths.clear();
                fillOpenBranchesQueue(getOpenBranchesString()); //fill the open branches queue so the tree reloads with the correct branches
            }
        }
    }
    
    /**
    * Generate the page reference to the change TE to different US page.
    **/
    public PageReference moveTEtoDifferentUS(){
        if(this.tree.selectedIDs.isEmpty()){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one Test Exectuion to move to a different User Story.');
        }else if(this.tree.dummyTE.User_Story__c == null){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select a valid User Story to move to.');
        }else{
        	ADM_Work__c workObj = null;
        	try {
        		workObj = [SELECT Name FROM ADM_Work__c WHERE Id = :this.tree.dummyTE.User_Story__c AND ADM_Work__c.Type__c = 'User Story'];
        	} catch (Exception e){
        		this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(3, 'The User Story must be a User Story Work Object.');
        		return null;
        	}
            try{
                //query the needed US and TEs
                String usName = workObj.Name;
                List<QA_Test_Execution__c> changeTEs = [SELECT Id, User_Story__c FROM QA_Test_Execution__c WHERE Id IN :this.tree.selectedIDs ORDER BY Name];
                for(QA_Test_Execution__c curTE : changeTEs) curTE.User_Story__c = this.tree.dummyTE.User_Story__c ; //update TEs with new US
                
                Database.update(changeTEs);
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(1, 'Moved ' + changeTEs.size() + ' Test Execution(s) to <a href=\"/' + QA_TreeLibraryStatic.escapeSpecials(this.tree.dummyTE.User_Story__c, false) + '\" class=\"textRegular\" target=\"_top\">' + usName + '</a>.');
            }catch(Exception e){
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(3, 'Error in moving Test Executions to a different User Story.');
                return null;
            }finally{
                this.tree.selectedIDs.clear();
                this.tree.selectedPaths.clear();
                fillOpenBranchesQueue(getOpenBranchesString()); //fill the open branches queue so the tree reloads with the correct branches
            }
        }
        return null;
    }
    
    /**
    * Generate the page reference to the switch TE assignee page.
    **/
    public PageReference switchTEAssignee(){    
        if(this.tree.selectedIDs.isEmpty()){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one Test Exectuion to stwitch to a different Assignee.');
        }else if(this.tree.dummyTE.Assignee__c == null){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select a valid Assignee to switch to.');
        }else{
            try{
                String assigneeName = [SELECT Name FROM User WHERE Id = :this.tree.dummyTE.Assignee__c].Name;
                List<QA_Test_Execution__c> changeTEs = [SELECT Id, User_Story__c FROM QA_Test_Execution__c WHERE Id IN :this.tree.selectedIDs ORDER BY Name];
                for(QA_Test_Execution__c curTE : changeTEs) curTE.Assignee__c = this.tree.dummyTE.Assignee__c ; //update TEs with new assignee
                
                Database.update(changeTEs);
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(1, 'Switched ' + changeTEs.size() + ' Test Execution(s) to <a href=\"/' + QA_TreeLibraryStatic.escapeSpecials(this.tree.dummyTE.Assignee__c,false)+ '\" class=\"textRegular\" target=\"_top\">' + assigneeName + '</a>.');
            }catch(Exception e){
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(3, 'Error in switching Test Executions to a new Assignee.');
                return null;
            }finally{
                this.tree.selectedIDs.clear();
                this.tree.selectedPaths.clear();
                fillOpenBranchesQueue(getOpenBranchesString()); //fill the open branches queue so the tree reloads with the correct branches
            }
        }
        return null;
    }
    
    /**
    * Generate the page reference to mass edit test cases.
    **/
    public PageReference massEditTCs(){
        if(this.tree.selectedIDs.isEmpty()){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one Test Case to edit.');
            return null;
        }else{
            return new PageReference('/apex/QA_MassEditTC?cases=' + this.getSelectedIDs(';') + '&rid=' + this.tree.returnUrl);
        }
    }
    
    /**
    * Generate the page reference to generate annotations.
    **/
    public PageReference generateAnnotations(){
        if(this.tree.selectedIDs.isEmpty()){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one Test Case to generate annotations for.');
            return null;
        }else{
            return new PageReference('/apex/QA_GenerateAnnotations?cases=' + this.getSelectedIDs(';') + '&rid=' + this.tree.returnUrl);
        }
    }
    
    
    /**
    * Generate the page reference to add TC to a US.
    **/
    public PageReference addTCtoUS(){
        if(this.tree.selectedIDs.isEmpty()){
            this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Please select at least one Test Case to add to a User Story.');
            return null;
        }else{
            return new PageReference('/apex/QA_AddTCtoUS?cases=' + this.getSelectedIDs(';') + '&rid=' + this.tree.returnUrl);
        }
    }
    
    /**
    * Generate the page reference to add new test cases.
    **/
    public PageReference addTCs(){
        return new PageReference('/apex/QA_AddTestCases?hier=' + this.tree.addTCsPath);
    }
    
    /**
    * Returns if there are anymore elements in the open branches queue.
    **/
    public Boolean getAnymoreOpenBranches(){
        return !this.tree.openBranchQueue.isEmpty();
    }
    
    /**
    * If there are more elements in the open branches queue, dequeue and return it.
    **/
    public String getNextOpenBranch(){
        if(!this.tree.openBranchQueue.isEmpty()){
            return EncodingUtil.urlEncode(this.tree.openBranchQueue.remove(0), 'UTF-8');
        }else{
            return null;    
        }
    }
    
    /**
    * Add a single to the open branch queue.
    **/
    public void openBranchPath(){
        //decode the hierarchy string first
        String queryHier = EncodingUtil.urlDecode(this.tree.selectedBranch, 'UTF-8');
        
        //split the path and build and add sequentially to the queue, use different delimiter for different trees
        if(this.tree.sobjectType == null){
            String fullPath = null;
            for(String curBranch : queryHier.split('[.]')){
                if(fullPath == null)
                    fullPath = curBranch;
                else
                    fullPath += '.' + curBranch;
                    
                this.tree.openBranchQueue.add(fullPath);
            }
        }else{
            String[] branchArr = queryHier.split('[~][.]');
            
            if(branchArr.size() == 3){
                this.tree.openBranchQueue.add(branchArr[0] + '~');
                this.tree.openBranchQueue.add(branchArr[0] + '~.' + branchArr[1] + '~');
                this.tree.openBranchQueue.add(queryHier);
            }
        }
    }
    
    /**
    * Open all of the sub branches for a given path.
    **/
    public void openAllSubBranches(){
        //decode the hierarchy string first
        String queryHier = EncodingUtil.urlDecode(this.tree.selectedBranch, 'UTF-8');
        
        //query and add all of the sub-branches if TC tree
        if(this.tree.sobjectType == null){
            List<QA_Hierarchy__c> subBranches = [SELECT Full_Path__c FROM QA_Hierarchy__c WHERE Full_Path__c LIKE :(queryHier + '.%') ORDER BY Depth__c ASC];
            
            this.tree.openBranchQueue.add(queryHier);
            for(QA_Hierarchy__c curHier : subBranches) this.tree.openBranchQueue.add(curHier.Full_Path__c);
        }else{ 
            //only open up a branch if its a hierarchy branch
            if(queryHier.split('[~][.]').size() == 3) this.tree.openBranchQueue.add(queryHier);
        }
    }

    // all the select options for the filtering pick lists
    // populated by setFilterTypes, when one is called all three populate
    public List<SelectOption> executionTypeFT {
        get {
            if(this.executionTypeFT == null) setFilterTypes();
            return this.executionTypeFT;
        }
        set;
    }
    
    public List<SelectOption> priorityFT {
        get {
            if(this.priorityFT == null) setFilterTypes();
            return this.priorityFT;
        }
        set;
    }
    
    public List<SelectOption> relatedToFT {
        get {
            if(this.relatedToFT == null) setFilterTypes();
            return this.relatedToFT;
        }
        set;
    }
    
    public List<SelectOption> statusFT {
        get {
            if(this.statusFT == null) setFilterTypes();
            return this.statusFT;
        }
        set;
    }
    
    private void setTEFilterTypes() { 
        List<Schema.PicklistEntry> executionTypes = QA_Test_Execution__c.Type__c.getDescribe().getPickListValues();
        List<Schema.PicklistEntry> statuses = QA_Test_Execution__c.Status__c.getDescribe().getPicklistValues();
        
        this.executionTypeFT = new List<SelectOption>();
        this.executionTypeFT.add(new SelectOption('All', 'All'));
        this.relatedToFT = new List<SelectOption>();
        this.relatedToFT.add(new SelectOption('All', 'All'));
        this.statusFT = new List<SelectOption>();
        this.statusFT.add(new SelectOption('All', 'All'));
        
        for(Schema.PicklistEntry executionType : executionTypes) this.executionTypeFT.add(new SelectOption(executionType.getLabel(), executionType.getLabel()));
        for(Schema.PicklistEntry status: statuses) this.statusFT.add (new SelectOption(status.getLabel(), status.getLabel())) ;
    }
    
    // sets the filter types up for each field
    private void setTCFilterTypes() {
        // then gets the picklist entries from each of the desired filter types
        List<Schema.PicklistEntry> executionTypes = QA_Test_Case__c.Execution_Type__c.getDescribe().getPickListValues();
        List<Schema.PicklistEntry> prioritys = QA_Test_Case__c.Priority__c.getDescribe().getPickListValues();

        // then adds the "All" category
        this.executionTypeFT = new List<SelectOption>();
        this.executionTypeFT.add(new SelectOption('All', 'All'));
        this.priorityFT = new List<SelectOption>();
        this.priorityFT.add(new SelectOption('All', 'All'));
        this.relatedToFT = new List<SelectOption>();
        this.relatedToFT.add(new SelectOption('All', 'All'));

        // the for each picklist entry, adds that to the selection options for each array of select options
        for(Schema.PicklistEntry executionType : executionTypes) this.executionTypeFT.add(new SelectOption(executionType.getLabel(), executionType.getLabel()));
        for(Schema.PicklistEntry priority : prioritys) this.priorityFT.add(new SelectOption(priority.getLabel(), priority.getLabel()));
    }
    
    public void setFilterTypes() { 
        if(this.tree.sobjectType == null) 
            setTCFilterTypes();
        else
            setTEFilterTypes();
    }   
    
    public void filter() {
        //fill the open branches queue so when the tree reloads, the correct branches will be open
        fillOpenBranchesQueue(getOpenBranchesString());
    }
    
    /**
    * See if there are any matches for the hierarchy autocomplete and return at most max of them.
    *
    * @param hier Partial hierarchy to match.
    * @param max The most number of matches to return.
    * @return List of matches as Strings. Each string contains the partial match and autocomplete portion seperated by "|~|".
    **/
    public List<String> getACMatches(String hier, Integer max){
        //find the depth of the partial hierarchy.
        String[] newHierArr = hier.split('[.]');
        Integer curDepth = newHierArr.size();
        QA_Hierarchy__c[] retHiers;
        
        //if the depth of the new partial hierarchy is different than that of the old, we need to do a new query since we
        //cached the results from the last depth
        if(curDepth != this.tree.acLastDepth){
            //perform a new query and fill up the cache with results
            if(curDepth == 1)
                retHiers = [SELECT Full_Path__c FROM QA_Hierarchy__c WHERE Depth__c = 0 ORDER BY Full_Path__c];
            else
                retHiers = [SELECT Full_Path__c FROM QA_Hierarchy__c WHERE Full_Path__c LIKE :(hier+'%') AND Depth__c = :(curDepth-1) ORDER BY Full_Path__c];
            
            this.tree.acLastMatches.clear();
            for(QA_Hierarchy__c curHier : retHiers) this.tree.acLastMatches.add(curHier.Full_Path__c);
        }else{
            //if the depths are the same, check to see if it is the same hierarchy that we cached, if not, need to query again
            //and fill up a new cache
            String lastBaseHier = '';
            String newBaseHier = '';
            for(Integer i=0; i<curDepth-1; i++){
                lastBaseHier += this.tree.acLastHierArr[i];
                newBaseHier += newHierArr[i];
            }
            
            if(!lastBaseHier.equals(newBaseHier)){
                retHiers = [SELECT Full_Path__c FROM QA_Hierarchy__c WHERE Full_Path__c LIKE :(hier+'%') AND Depth__c = :(curDepth-1) ORDER BY Full_Path__c];
                
                this.tree.acLastMatches.clear();
                for(QA_Hierarchy__c curHier : retHiers) this.tree.acLastMatches.add(curHier.Full_Path__c);
            }
        }

        //check the cache for matches to the partial hierarchy
        List<String> results = new List<String>();
        String matchedStr;
        Integer matchedCount = 0;
        for(String curMatch : this.tree.acLastMatches){
            if(hier.length() == curMatch.length()){ //a complete match was found
                if(curMatch.equalsIgnoreCase(hier)){
                    results.add(curMatch + '|~|');
                    matchedCount++;
                    if(matchedCount == max) break;  
                }
            }else if(hier.length() < curMatch.length()){ //a partial match was found
                matchedStr = curMatch.substring(0,hier.length());
                if(matchedStr.equalsIgnoreCase(hier)){
                    results.add(matchedStr + '|~|' + curMatch.substring(hier.length(),curMatch.length()));
                    matchedCount++;
                    if(matchedCount == max) break;  
                }
            }
        }
        
        //store the new cache variables to improve performance
        this.tree.acLastHierArr = newHierArr;
        this.tree.acLastDepth = curDepth;
        this.tree.acMatchCount = matchedCount;
        
        return results;
    }
    
    /**
    * See if there are any matches for the hierarchy autocomplete and generate the corresponding HTML for it in this.tree.acMatches.
    *
    * @param this.tree.acHier Partial hierarchy passed in from VF page to match.
    **/
    public void loadACMatches(){
        if(!this.tree.acHier.equals('')){ //if the match string is not empty get matches
            //get the matches from the autocomplete object
            List<String> matches = getACMatches(this.tree.acHier, 10);
            
            //generate output with the matches
            this.tree.acMatches = '<table bgcolor=\\"#F6F6F6\\" border=\\"0\\" cellspacing=\\"0\\" cellpadding=\\"1\\" style=\\"border-style:solid; border-width:1px; border-color:#666666\\" class=\\"textRegular\\">';
            if(matches.size() == 0){
                //if no matches are found display "No results found!"
                this.tree.acMatches += '<tr><td>No results found!</td></tr>';
            }else{
                String[] matchArr;
                String matchHTML;
                String matchId;
                //else build the table with the results
                for(Integer i=0; i<matches.size(); i++){
                    matchArr = matches[i].split('[|][~][|]');
                    if(matchArr.size() == 1){ //full match of a hierarchy
                        matchHTML = '<strong>' + QA_TreeLibraryStatic.escapeSpecials(matchArr[0], true) + '</strong>';
                        matchId = QA_TreeLibraryStatic.escapeSpecials(matchArr[0], true);
                    }else{ //partial match of a hierarchy
                        matchHTML = '<strong>' + QA_TreeLibraryStatic.escapeSpecials(matchArr[0], true) + '</strong>' + QA_TreeLibraryStatic.escapeSpecials(matchArr[1], true);
                        matchId = QA_TreeLibraryStatic.escapeSpecials(matchArr[0] + matchArr[1], true);
                    }
                    
                    this.tree.acMatches += '<tr id=\\"ACRow' + (i+1) + '\\" onmousedown=\\"setHierarchy(' + (i+1) + ')\\" onmouseover=\\"acSelect(' + (i+1) + ')\\"><td>' + matchHTML + '<input id=\\"ACRow' + (i+1) + '.hierarchy\\" type=\\"hidden\\" value=\\"' + matchId + '\\" /></td></tr>';
                }
            }
            this.tree.acMatches += '</table>';
        }else{ //if the match string empty display nothing
            this.tree.acMatches = '';
        }
    }
    
    /**
    * Generate the header for each hierachy with matched TCs.
    **/
    private String generateSearchHeader(String hier, Integer count){
        String hierE = EncodingUtil.urlEncode(hier, 'UTF-8');
        String header = '<table class=\\"textRegular\\" cellspacing=\\"0\\" cellpadding=\\"0\\" border=\\"0\\" width=\\"100%\\">';
        header += '<tr id=\\"search.' + hierE + '.header\\" class=\\"defaultCursor\\" onmousedown=\\"searchToggleSelect(\'' + hierE + '\')\\" onmouseout=\\"searchToggleHighlight(\'' + hierE + '\')\\" onmouseover=\\"searchToggleHighlight(\'' + hierE + '\')\\">';
        header += '<td width=\\"14\\" style=\\"vertical-align: middle; text-align: center\\"><img id=\\"search.' + hierE + '.twisty\\" src=\\"/img/setup_plus.gif\\"/></td>';
        header += '<td><strong>' + QA_TreeLibraryStatic.escapeSpecials(hier, true) + '</strong> (' + count + ')</td>';
        header += '</tr><tr id=\\"search.' + hierE + '.results\\" style=\\"display: none;\\"><td style=\\"vertical-align: middle; text-align: left\\"></td><td>';
        return header;
    }
    /**
    * Generate the footer for each hierachy with matched TCs.
    **/
    private String generateSearchFooter(){
        return '</td></tr></table>';
    }
    
    /**
    * Generate the link for each matched TC.
    **/
    private String generateSearchItem(String id, String hier, String item, String className){
        String hierE = EncodingUtil.urlEncode(QA_TreeLibraryStatic.escapeHierarchy(hier), 'UTF-8');
        String itemE = QA_TreeLibraryStatic.escapeSpecials(item, true);
        return '<a class=\\"' + className + '\\" href=\\"javascript:openBranchPath(\'' + hierE + '\',\'gotoHash(\\\\\'' + hierE + '|~|' + id + '\\\\\')\');\\">' + itemE + '</a><br />';
    }
    
    /**
    * Searches for Test Cases in the current hierarchy and generates a collapsable table of matching 
    * Test Cases sorted by their hierarchy stored in this.tree.searchMatches.
    *
    * @param this.tree.searchTerm Search term passed in from VF page.
    * @param this.tree.searchPath The current hierarchy path in the hierarchy filter text field from the VF page.
    **/
    public void searchTCTree(){
        //query for the TCs, given the current hierarchy path. If the path is empty, then search all TCs
        List<QA_Test_Case__c> tcs = new List<QA_Test_Case__c>();
        
        String query = 'SELECT Brief_Description__c, Hierarchy__c, Id FROM QA_Test_Case__c WHERE';
        if(!this.tree.searchPath.equals('')) query += ' (Hierarchy__c = \'' + QA_TreeLibraryStatic.escapeHierarchy(this.tree.searchPath) + '\' OR Hierarchy__c LIKE \'' + QA_TreeLibraryStatic.escapeHierarchy(this.tree.searchPath) + '.%\') AND';
        if(this.tree.priorityFilter != 'All') query += ' Priority__c = \'' + String.escapeSingleQuotes(this.tree.priorityFilter) + '\' AND';
        if(this.tree.executionTypeFilter != 'All') query += ' Execution_Type__c INCLUDES (\'' + String.escapeSingleQuotes(this.tree.executionTypeFilter) + '\') AND';
        query +=  ' Brief_Description__c LIKE \'%' + QA_TreeLibraryStatic.escapeSpecials(this.tree.searchTerm, true) + '%\' ORDER BY Hierarchy__c, Brief_Description__c LIMIT 200';
        tcs.addAll((List<QA_Test_Case__c>)Database.query(query)); 

        //if matching TCs found, generate the HTML table, else notify the user
        if(tcs.size() > 0){
            //first pass through the mathching TCs to count how many TCs are in each hierarchy
            List<Integer> hierCount = new List<Integer>();
            Integer curCount = 0;
            String lastHier = tcs[0].Hierarchy__c;
            for(QA_Test_Case__c curTC : tcs){
                //since the TC results are ordered by hierarchy, whenever the new hierarchy doesn't the old, we know we seen all of the last set
                if(lastHier.equals(curTC.Hierarchy__c)){
                    curCount++;
                }else{
                    hierCount.add(curCount);
                    curCount = 1;
                    lastHier = curTC.Hierarchy__c;
                }
            }
            hierCount.add(curCount);
            
            //second pass through the matching TCs to generate the HTML table
            lastHier = tcs[0].Hierarchy__c;
            Integer curHier = 0;
            
            this.tree.searchMatches = generateSearchHeader(lastHier, hierCount[curHier++]);
            for(QA_Test_Case__c curTC : tcs){
                if(lastHier.equals(curTC.Hierarchy__c)){
                    this.tree.searchMatches += generateSearchItem(curTC.Id, curTC.Hierarchy__c, curTC.Brief_Description__c, 'textRegular');
                }else{
                    this.tree.searchMatches += generateSearchFooter();
                    this.tree.searchMatches += generateSearchHeader(curTC.Hierarchy__c, hierCount[curHier++]);
                    this.tree.searchMatches += generateSearchItem(curTC.Id, curTC.Hierarchy__c, curTC.Brief_Description__c, 'textRegular');
                    lastHier = curTC.Hierarchy__c;
                }
            }
            this.tree.searchMatches += generateSearchFooter();
            
            if(tcs.size() == 200)
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Found over 200 Test Cases, only the first 200 are provided, please narrow down your search details.');
            else
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(1, 'Found ' + tcs.size() + ' Test Case(s).');
        }else{
            this.tree.searchMatches = 'No Test Cases found!';
        }
    }
    
    /**
    * Searches for Test Executions in the current hierarchy and generates a collapsable table of matching 
    * Test Executions sorted by their hierarchy stored in this.tree.searchMatches.
    *
    * @param this.tree.searchTerm Search term passed in from VF page.
    * @param this.tree.searchPath The current hierarchy path in the hierarchy filter text field from the VF page.
    **/
    public void searchTETree() { 
        List<QA_Test_Execution__c> tes = new List<QA_Test_Execution__c>();

        //query for the TEs
        String query = '';
        if(this.tree.sobjectType == ADM_Sprint__c.getSObjectType())
            query = 'SELECT Test_Case__r.Brief_Description__c, Test_Case__r.Hierarchy__c, Id, Status__c, Assignee__r.Name FROM QA_Test_Execution__c WHERE User_Story__r.Sprint__r.Id = \'' + this.tree.id + '\'';
        else if(this.tree.sobjectType == ADM_Work__c.getSObjectType()) 
            query = 'SELECT Test_Case__r.Brief_Description__c, Test_Case__r.Hierarchy__c, Id, Status__c, Assignee__r.Name FROM QA_Test_Execution__c WHERE User_Story__r.Id = \'' + this.tree.id + '\'';
        else if(this.tree.sobjectType == QA_Test_Plan__c.getSObjectType())
            query = 'SELECT Test_Case__r.Brief_Description__c, Test_Case__r.Hierarchy__c, Id, Status__c, Assignee__r.Name FROM QA_Test_Execution__c WHERE User_Story__r.Test_Plan__r.Id = \'' + this.tree.id + '\'';

        if(this.tree.statusFilter != 'All') query += ' AND Status__c = \'' + String.escapeSingleQuotes(this.tree.statusFilter) + '\'';
        if(this.tree.executionTypeFilter != 'All') query += ' AND Type__c = \'' + this.tree.executionTypeFilter + '\'';
        query += ' AND Test_Case__r.Brief_Description__c LIKE \'%' + QA_TreeLibraryStatic.escapeSpecials(this.tree.searchTerm, true) + '%\' ORDER BY Test_Case__r.Hierarchy__c, Status__c, Test_Case__r.Brief_Description__c LIMIT 200';
        tes.addAll((List<QA_Test_Execution__c>)Database.query(query));

        if(tes.size() > 0){
            //first pass through the mathching TEs to count how many TEs are in each hierarchy
            List<Integer> hierCount = new List<Integer>();
            Integer curCount = 0;
            String lastHier = tes[0].Test_Case__r.Hierarchy__c;
            for(QA_Test_Execution__c curTE : tes){
                //since the TC results are ordered by hierarchy, whenever the new hierarchy doesn't the old, we know we seen all of the last set
                if(lastHier.equals(curTE.Test_Case__r.Hierarchy__c)){
                    curCount++;
                }else{
                    hierCount.add(curCount);
                    curCount = 1;
                    lastHier = curTE.Test_Case__r.Hierarchy__c;
                }
            }
            
            hierCount.add(curCount);
            
            //second pass through the matching TCs to generate the HTML table
            String className;
            Integer curHier = 0;
            lastHier = tes[0].Test_Case__r.Hierarchy__c;
            
            this.tree.searchMatches = generateSearchHeader(QA_TreeLibraryStatic.escapeSpecials(lastHier, true), hierCount[curHier++]);
            for(QA_Test_Execution__c curTE : tes){
                if(curTE.Status__c.equals('Passed')) className = 'colorPassed';
                else if(curTE.Status__c.equals('Planned')) className = 'colorPlanned';
                else if(curTE.Status__c.equals('Failed')) className = 'colorFailed';
                else if(curTE.Status__c.equals('Blocked')) className = 'colorBlocked';
                
                if(lastHier.equals(curTE.Test_Case__r.Hierarchy__c)){
                    this.tree.searchMatches += generateSearchItem(curTE.Id, curTE.Status__c + '~.' + curTE.Assignee__r.Name + '~.' + QA_TreeLibraryStatic.escapeSpecials(curTE.Test_Case__r.Hierarchy__c, true), QA_TreeLibraryStatic.escapeSpecials(curTE.Test_Case__r.Brief_Description__c, true), className);
                }else{
                    this.tree.searchMatches += generateSearchFooter();
                    this.tree.searchMatches += generateSearchHeader(QA_TreeLibraryStatic.escapeSpecials(curTE.Test_Case__r.Hierarchy__c, true), hierCount[curHier++]);
                    this.tree.searchMatches += generateSearchItem(curTE.Id, curTE.Status__c + '~.' + curTE.Assignee__r.Name + '~.' + QA_TreeLibraryStatic.escapeSpecials(curTE.Test_Case__r.Hierarchy__c, true), QA_TreeLibraryStatic.escapeSpecials(curTE.Test_Case__r.Brief_Description__c, true), className);
                    lastHier = curTE.Test_Case__r.Hierarchy__c;
                }
            }
            this.tree.searchMatches += generateSearchFooter();
            
            if(tes.size() == 200)
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(2, 'Found over 200 Test Executions, only the first 200 are provided, please narrow down your search details.');
            else
                this.confirmationMessage = QA_TreeLibraryStatic.generateMessageBox(1, 'Found ' + tes.size() + ' Test Execution(s).');
        }else{
            this.tree.searchMatches = 'No Test Executions found!';
        }
    }
    
    /**
    * Generic call to search a tree, will choose the appropriate search based on the sobjectType.
    **/
    public void searchTree(){
        if(this.tree.sobjectType == null)
            searchTCTree();
        else
            searchTETree();
    }
}