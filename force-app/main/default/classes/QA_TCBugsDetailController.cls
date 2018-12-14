public with sharing class QA_TCBugsDetailController {
	

	 Id id;
     List<ADM_Work__c> bugsList; //create a List of QAForce Bug for the corresponding Test Case(TC) record
     String bugNumSortDirection = '^';
     String prioritySortDirection = '^';
     String statusSortDirection = '^';
     String qaEngineerSortDirection = '^';
     String assigneeSortDirection = '^';
     String scheduledBuildSortDirection = '^';
     String subjectSortDirection = '^'; 
     
     String sortColumn = 'BugNum';
     
     String sortVariableName = 'BugNumber ASC';
     Integer counter = 0;
     String showAllVariableName = 'Show All';
     Boolean flag = true;
     Boolean showFewMore = true;
     Integer showFewMoreCtr = 10;
     Integer rowsToReturn = 10;
     String orderByColumn = 'Bug_Number';
     
     public QA_TCBugsDetailController(){
     	
     }
         
     public QA_TCBugsDetailController(ApexPages.StandardController stdController){
		try{ id = stdController.getId(); //initialize id by getting it from the URL
        } catch (Exception e) {
            id = null;
        }	
     }
    
    //Get the bugs associated to a TC record and initialize it a bugList
    public List<ADM_Work__c> getBugsList(){
    	if(flag){
    		flag = false;
	    	Set<String> bugsSet = new Set<String>();
	     	for(QA_Test_Execution__c record: [select Bugs__c from QA_Test_Execution__c where Test_Case__c =: id ] ){
	            
	            if(record.Bugs__c != null){
	                String[] bugsArray = record.Bugs__c.split('[,]');
	                
	                for (Integer i = 0; i < bugsArray.size(); i++){
	                    //ignore the duplicate bugs by comparing it with the set object before adding it to a set
	                    if(bugsSet.size() < 1000){
	                        bugsSet.add(bugsArray[i]);
	                    }
	                }       
	            }
	        
	        }
	        //get the number of bug records associated to this TC
	        counter = [select count() from ADM_Work__c where Name in :bugsSet];
	       //get the bug number, status and description associated to the bug
	        if(sortVariableName == 'BugNumber ASC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'BugNumber DESC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Name DESC LIMIT 1000];
	        
	        else if(sortVariableName == 'Subject ASC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Subject__c ASC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'Subject DESC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Subject__c DESC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'Priority ASC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Priority__c ASC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'Priority DESC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Priority__c DESC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'Status ASC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Status__c ASC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'Status DESC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Status__c DESC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'QA ASC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY QA_Engineer__r.Name ASC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'QA DESC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY QA_Engineer__r.Name DESC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'Assignee ASC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Assignee__r.Name ASC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'Assignee DESC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Assignee__r.Name DESC,Name ASC LIMIT 1000];
	        
	        else if(sortVariableName == 'SB ASC')
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Scheduled_Build__r.Name ASC,Name ASC LIMIT 1000];
	        
	        else 
	            bugsList = [select Id, Priority__c, QA_Engineer__r.Name, Subject__c, Assignee__r.Name, Scheduled_Build__r.Name, Name, Status__c, Description__c from ADM_Work__c where Name in :bugsSet ORDER BY Scheduled_Build__r.Name DESC,Name ASC LIMIT 1000];
	        
	        //if there are no bugs associated to the TC record then return null
	        if(bugsList.isEmpty())
	            return null;
	        else
	            return bugsList;
            
    	}
    	else{
    		if(bugsList.isEmpty())
            	return null;
	        else
	            return bugsList;
    	}
    }
    
    public void showMore(){
    	if(showFewMore){
    		showFewMoreCtr = showFewMoreCtr + 10;
    		rowsToReturn = rowsToReturn + 10;
    	}
    	if((counter - showFewMoreCtr < 10) ){
    		showFewMore = false;
    		if((counter - showFewMoreCtr == 0))
    			showAllVariableName = 'First 10';
    	}
    	
    }
    
    public Integer getRowstoReturn(){
    	return (counter < rowsToReturn) ? counter : rowsToReturn ;
    }
    
    public Boolean getshowFewMore(){
    	return showFewMore;
    }
    
    public Integer getBugsListSize(){
        return bugsList.size();
    }
    //order by BugNumber
    public void orderBugNumber(){
    	flag = true;
    	sortColumn = 'BugNum';
        if (bugNumSortDirection == '^') {
            bugNumSortDirection = 'v';
            sortVariableName = 'BugNumber DESC';
        }
        else {
            bugNumSortDirection = '^';
            sortVariableName = 'BugNumber ASC';
        }
    }
    //order by Subject
    public void orderSubject(){
    	flag = true;
    	sortColumn = 'Subject';
        if (subjectSortDirection == '^') {
            subjectSortDirection = 'v';
            sortVariableName = 'Subject DESC';
        }
        else {
            subjectSortDirection = '^';
            sortVariableName = 'Subject ASC';
        }
    }
    //order by Priority
    public void orderPriority(){
    	flag = true;
    	sortColumn = 'Priority';
        if (prioritySortDirection == '^') {
            prioritySortDirection = 'v';
            sortVariableName = 'Priority DESC';
        }
        else {
            prioritySortDirection = '^';
            sortVariableName = 'Priority ASC';
        }
    }
    //order by Status__c
    public void orderStatus(){
    	flag = true;
    	sortColumn = 'Status';
        if (statusSortDirection == '^') {
            statusSortDirection = 'v';
            sortVariableName = 'Status DESC';
        }
        else {
            statusSortDirection = '^';
            sortVariableName = 'Status ASC';
        }
    }
    //order by QA
    public void orderQAEngineer(){
    	flag = true;
    	sortColumn = 'QA';
        if (qaEngineerSortDirection == '^') {
            qaEngineerSortDirection = 'v';
            sortVariableName = 'QA DESC';
        }
        else {
            qaEngineerSortDirection = '^';
            sortVariableName = 'QA ASC';
        }
    }
    //order by Priority
    public void orderAssignee(){
    	flag = true;
    	sortColumn = 'Assignee';
        if (assigneeSortDirection == '^') {
            assigneeSortDirection = 'v';
            sortVariableName = 'Assignee DESC';
        }
        else {
            assigneeSortDirection = '^';
            sortVariableName = 'Assignee ASC';
        }
    }
    //order by Scheduled_Build__c
    public void orderScheduledBuild(){
    	flag = true;
    	sortColumn = 'SB';
        if (scheduledBuildSortDirection == '^') {
            scheduledBuildSortDirection = 'v';
            sortVariableName = 'SB DESC';
        }
        else {
            scheduledBuildSortDirection = '^';
            sortVariableName = 'SB ASC';
        }
    }
    //returns the BugNum column sort direction
    public String getBugNumSortDirection(){
        return bugNumSortDirection;
    }
    //returns the Subject column sort direction
    public String getSubjectSortDirection(){
        return subjectSortDirection;
    } 
    //returns the Priority column sort direction
    public String getPrioritySortDirection(){
        return prioritySortDirection;
    } 
    //returns the Status column sort direction
    public String getStatusSortDirection(){
        return statusSortDirection;
    } 
    //returns the QA Engineer column sort direction
    public String getQaEngineerSortDirection(){
        return qaEngineerSortDirection;
    } 
    //returns the Assignee column sort direction
    public String getAssigneeSortDirection(){
        return assigneeSortDirection;
    } 
    //returns the Scheduled Build column sort direction
    public String getScheduledBuildSortDirection(){
        return scheduledBuildSortDirection;
    } 
    public Integer getCount(){
        return counter;
    }
    
    public void showAll(){
    	if(showAllVariableName == 'Show All'){
    		showFewMore = false;
    		rowsToReturn = counter;
    		showAllVariableName = 'First 10';
    	}
    	else{
    		rowsToReturn = 10;
    		showFewMore = true;
    		showAllVariableName = 'Show All';
    	}
    }
    
    public String getshowAllVariableName(){
        return showAllVariableName;
    }
    
     public String getSortColumn(){
        return sortColumn;
    }
    //Test Method
    private static testMethod void testTCBugDetail(){
        //create a TCBugDetail object
        QA_TCBugsDetailController testObj = new QA_TCBugsDetailController();
        List<ADM_Work__c> bugsList;
        
        //create user story
        ADM_Work__c us = ADM_Work.createTestWork('User Story');
        
        //create a Test Case
        if([select count() from QA_Hierarchy__c where Name = 'API'] == 0) {
            QA_Hierarchy__c hierarchy = new QA_Hierarchy__c();
            hierarchy.Name = 'API';
            hierarchy.Depth__c = 0;
            insert hierarchy;
        }
        QA_Test_Case__c testcase = new QA_Test_Case__c();
        testcase.Hierarchy__c = 'API.TCMassEdit.Test';
        testcase.Brief_Description__c = 'Trigger Test';
        testcase.Expected_Results__c = 'Pass';
        testcase.Execution_Type__c = 'Manual';
        insert(testcase);
        
        //create a Test Execution record with Status as Passed and Number of Execution = 0 and Bugs = null
        //This should invoke the trigger and automatically update Number of Execution = 1 when it is Passed or Failed
        QA_Test_Execution__c case1 = new QA_Test_Execution__c();
        case1.Test_Case__c = testcase.id;
        case1.Status__c = 'Passed';
        case1.Assignee__c = UserInfo.getUserId();
        case1.User_Story__c = us.id;
        case1.Number_of_Executions__c = 0;
        
        case1.Bugs__c = null;
        insert(case1);
        
        testObj.id = testcase.id;
        testObj.orderBugNumber();
        bugsList = testObj.getBugsList(); //get the bugs associated to the TC
        String[] bugsArray; 
        Integer ctr = 0;
        Set<String> bugs; 
        try{
            if(bugsList != null){ //if there are any bugs associated to TC then get the details of the bug
            bugsArray = case1.Bugs__c.split('[,]');
            bugs = new Set<String>(bugsArray);
            
                for(ADM_Work__c bug : bugsList){
                    if(bugs.contains(bug.Name)){
                    ctr++;
                    System.assertEquals(bug.Status__c,'New');
                    System.assertEquals(bug.Description__c, null);
                    }
                   
                }
                System.assertEquals(ctr,bugs.size());
            }else{
                System.assertEquals(bugsList,null);
            }
            
        }catch(Exception e){
            
        }
        //create a Test Case
        QA_Test_Case__c testcase1 = new QA_Test_Case__c();
        testcase1.Hierarchy__c = 'API.TCMassEdit.Test';
        testcase1.Brief_Description__c = 'Trigger Test';
        testcase1.Expected_Results__c = 'Pass';
        testcase1.Execution_Type__c = 'Manual';
        insert(testcase1);
        
        
        //create a Test Execution record with Status as Passed and Number of Execution = 0
        //This should invoke the trigger and automatically update Number of Execution = 1 when it is Passed or Failed
        QA_Test_Execution__c case2 = new QA_Test_Execution__c();
        case2.Test_Case__c = testcase1.id;
        case2.Status__c = 'Passed';
        case2.Assignee__c = UserInfo.getUserId();
        case2.User_Story__c = us.id;
        case2.Number_of_Executions__c = 0;
        case2.Bugs__c = '1234,12345,123456';
        insert(case2);
        
        testObj.id = testcase1.id;
        testObj.orderBugNumber();
        bugsList = testObj.getBugsList(); //get the bugs associated to the TC
        
        
        if(bugsList != null){ //if there are any bugs associated to TC then get the details of the bug
        bugsArray = case2.Bugs__c.split('[,]');
        bugs = new Set<String>(bugsArray);
        ctr =0;
            for(ADM_Work__c bug : bugsList){
                if(bugs.contains(bug.Name)){
                System.assertEquals(bug.Status__c,'New');
                System.assertEquals(bug.Description__c, null);
                ctr++;
                }
            }
           System.assertEquals(ctr,testObj.getBugsListSize());
         //  System.assertEquals('v',testObj.getsortDirection());
        }else{
            System.assertEquals(bugsList,null);
        }
        
        //create a Test Case in the same hierarchy
        QA_Test_Case__c testcase2 = new QA_Test_Case__c();
        testcase2.Hierarchy__c = 'API.TCMassEdit.Test';
        testcase2.Brief_Description__c = 'Trigger Test1';
        testcase2.Expected_Results__c = 'Pass';
        testcase2.Execution_Type__c = 'Manual';
        insert(testcase2);
        
        //create a Test Execution record with Status as In Progress and Number of Execution < 0 and Date of Last execution > current date
        //This should invoke the trigger and it should throw an error message for Number of Execution < 0 and Date of Last execution > current date
        QA_Test_Execution__c case3 = new QA_Test_Execution__c();
        case3.Test_Case__c = testcase.id;
        case3.Status__c = 'In Progress';
        case3.Assignee__c = UserInfo.getUserId();
        case3.User_Story__c = us.id;
        case3.Number_of_Executions__c = -1;
        case3.Date_of_Last_Execution__c = datetime.now()+1;
        
        try {
        insert(case3);
        delete(case3);
            System.assert(false); // should have triggered an exception;
        } catch (Exception e) {
        }
        
        //In this case bug field white space,tab space and extra comma should be trimmed and only the digits seperated by comma should be stored
        QA_Test_Execution__c case4 = new QA_Test_Execution__c();
        case4.Test_Case__c = testcase.id;
        case4.Status__c = 'In Progress';
        case4.Assignee__c = UserInfo.getUserId();
        case4.User_Story__c = us.id;
        case4.Number_of_Executions__c = 1;
        case4.Date_of_Last_Execution__c = datetime.now();
        case4.Bugs__c = ',,,,,90  091,90    092,,,,,00000090920,';
        insert(case4);
        
        Set<String> expectedBugs = new Set<String>(new String[] {'90091','90092','90920'});
        List<String> actualBugs = [SELECT Bugs__c FROM QA_Test_Execution__c where id =: case4.id ].Bugs__c.split( '[,]' );
        System.assertEquals( expectedBugs.size(), actualBugs.size() );
        for( String actualBug : actualBugs )
        	System.assert( expectedBugs.contains( actualBug ) );
        
        case4.Bugs__c = ',,12345,0001000,,123456    ,';
        update(case4);
        
        bugsArray = case4.Bugs__c.split('[,]');
        expectedBugs = new Set<String>(new String[] {'12345','1000','123456'});
        actualBugs = [SELECT Bugs__c FROM QA_Test_Execution__c where id =: case4.id ].Bugs__c.split( '[,]' );
        System.assertEquals( expectedBugs.size(), actualBugs.size() );
        for( String actualBug : actualBugs ) {
        	System.assert( expectedBugs.contains( actualBug ) );
        }
		
		//check for lazy load
		System.assertEquals( false , testObj.flag);
		testObj.id = testcase.id;
		bugsList = testObj.getBugsList(); //get the bugs associated to the TC
        System.assertEquals(false , testObj.flag);
        
        
        //check for sorting functionality
        bugsArray = case2.Bugs__c.split('[,]');
        
        //check for sorting bug number
        testObj.orderBugNumber();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('v' , testObj.getBugNumSortDirection());
        System.assertEquals('BugNumber DESC' , testObj.sortVariableName);
        testObj.orderBugNumber();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('^' , testObj.getBugNumSortDirection());
        System.assertEquals('BugNumber ASC' , testObj.sortVariableName);
        
        //check for sorting Subject
        testObj.orderSubject();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('v' , testObj.getSubjectSortDirection());
        System.assertEquals('Subject DESC' , testObj.sortVariableName);
        bugsList = testObj.getBugsList(); 
        System.assertEquals(false , testObj.flag);
        testObj.orderSubject();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('^' , testObj.getSubjectSortDirection());
        System.assertEquals('Subject ASC' , testObj.sortVariableName);
        bugsList = testObj.getBugsList(); 
        System.assertEquals(false , testObj.flag);
        
        //check for sorting Priority
        testObj.orderPriority();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('v' , testObj.getPrioritySortDirection());
        System.assertEquals('Priority DESC' , testObj.sortVariableName);
        bugsList = testObj.getBugsList(); 
        System.assertEquals(false , testObj.flag);
        testObj.orderPriority();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('^' , testObj.getPrioritySortDirection());
        System.assertEquals('Priority ASC' , testObj.sortVariableName);
        bugsList = testObj.getBugsList(); 
        System.assertEquals(false , testObj.flag);
        
        //check for sorting Assignee
        testObj.orderAssignee();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('v' , testObj.getassigneeSortDirection());
        System.assertEquals('Assignee DESC' , testObj.sortVariableName);
		testObj.orderAssignee();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('^' , testObj.getassigneeSortDirection());
        System.assertEquals('Assignee ASC' , testObj.sortVariableName);
       
        //check for sorting QAEngineer
        testObj.orderQAEngineer();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('v' , testObj.getQaEngineerSortDirection());
        System.assertEquals('QA DESC' , testObj.sortVariableName);
        testObj.orderQAEngineer();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('^' , testObj.getQaEngineerSortDirection());
        System.assertEquals('QA ASC' , testObj.sortVariableName);
        
        //check for sorting Scheduled Build
        testObj.orderScheduledBuild();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('v' , testObj.getScheduledBuildSortDirection());
        System.assertEquals('SB DESC' , testObj.sortVariableName);
        testObj.orderScheduledBuild();
        System.assertEquals(true , testObj.flag);
        System.assertEquals('^' , testObj.getScheduledBuildSortDirection());
        System.assertEquals('SB ASC' , testObj.sortVariableName);
        
        ADM_Work__c[] bugArr = [Select Id from ADM_Work__c where Name in : bugsArray];
        delete(bugArr);
        
        //check for an incorrect bug format
        case4.Bugs__c = 'X-1234';
        try{
        update(case4);
        }catch(DmlException e){
        System.assertEquals('Bug# '+case4.Bugs__c+ ' has an incorrect range or incorrect format. Bugs should be a number between 1000 - 10000000 or else it should start with \'W-\' followed by a six digit number',e.getDmlMessage(0));        
        }
        case4.Bugs__c = '1234';
        
        //check for min hierarchy depth
        testcase2.Hierarchy__c = 'API';
        try{
        update(testcase2);
        }catch(DmlException e){
        System.assertEquals('The hierarchy must have a depth of at least 2!',e.getDmlMessage(0));
        }
          
        
        //check for invalid base hierarchy name
        testcase2.Hierarchy__c = 'Financial.Level2.Level3.Level4.Level5';
        try{
        update(testcase2);
        }catch(DmlException e){
        System.assertEquals('Please provide a valid base hierarchy!',e.getDmlMessage(0));
        }
        
        //update TE without Assignee
        case4.Assignee__c = null;
        try{
        update(case4);
        } catch (DmlException e) {
        System.assertEquals('Test Execution Insert|Update Error: Assignee is mandatory to insert|update a test execution record.',e.getDmlMessage(0));
        }
        case4.Assignee__c = UserInfo.getUserId();
        
        //update TE without US
        case4.User_Story__c = null;
        try{
        update(case4);
        } catch (DmlException e) {
        System.assertEquals('Test Execution Insert|Update Error: User Story is mandatory to insert|update a test execution record.',e.getDmlMessage(0));
        }
                
        //Clean up
        delete(case1);
        delete(case2);
        delete(case4);
        try{
        String name = [Select Id,Status__c from QA_Test_Execution__c where Id =: case4.Id].Status__c;
        System.assert(false); // should have triggered an exception;
        }
        catch(Exception e){
        }
        
        delete(testcase2);
        delete(testcase1);
        delete(testcase);
        delete(us);
     } 

	
	

}