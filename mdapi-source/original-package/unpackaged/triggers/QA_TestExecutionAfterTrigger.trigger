trigger QA_TestExecutionAfterTrigger on QA_Test_Execution__c (after insert, after update) {


    // Create CJOs for every new bug in the list (and bugs, if they don't already exist)
    // Delete the CJOs for bugs that do not
    // EXAMPLE:
    // Assume we are inserting 1 test execution with bugs: "12345,67890" and
    // the only existing bug is 12345
    //
    // The result should be 2 new CJOs, a new bug: 67890
    // 1. Create a list of all bugs to create and a multilist of cjos with bugs. Create a list of all bugs to delete and a multilist of cjos to delete
    Set<String> newBugNumbers = new Set<String>();
    Set<String> oldBugNumbers = new Set<String>();
    Map<ID, Set<String>> cjosToDelete = new Map<ID, Set<String>>();
    Map<ID, Set<String>> cjosToAdd = new Map<ID, Set<String>>();
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        String[] beforeBugArray = new String[0];        
        if (Trigger.isUpdate && Trigger.old[i].Bugs__c != null) {
            String bugs = Trigger.old[i].Bugs__c;
            beforeBugArray = bugs.split('[,]');
        }

        String[] afterBugArray = new String[0];
        if (Trigger.new[i].Bugs__c != null){

            String bugs = Trigger.new[i].Bugs__c;
            afterBugArray = bugs.split('[,]');

        }

        Set<String> bugs = new Set<String>(beforeBugArray);
        bugs.removeAll(afterBugArray);
        if (bugs.size() > 0) {
            cjosToDelete.put(Trigger.new[i].Id, bugs);
            oldBugNumbers.addAll(bugs);
        }

        bugs = new Set<String>(afterBugArray);
        bugs.removeAll(beforeBugArray);
        if (bugs.size() > 0) {
            cjosToAdd.put(Trigger.new[i].Id, bugs);
            newBugNumbers.addAll(bugs);
        }
    }

    // 2. Bring the existing execution-bug records that will get deleted
    Integer loopCount = 0;
    List<QA_ExecutionBug__c> tempCjoList = new List<QA_ExecutionBug__c>();
    //tempCjoList = [select id, Work__c, Execution__c, Work__r.Name from QA_ExecutionBug__c where Execution__c in :cjosToDelete.keySet()];
    /*
    for (QA_ExecutionBug__c be : ) {
        if (cjosToDelete.get(be.Execution__c).contains(be.Work__r.Name)) {
            tempCjoList.add(be);
            if (++loopCount == 200) {
            loopCount = 0;
            delete tempCjoList;
            tempCjoList.clear();
            }
        }
    }
    delete tempCjoList;
    tempCjoList.clear();
    cjosToDelete.clear();
    */
    // 4. query for new bugs
    Map<String, ID> bugMap = new Map<String, ID>();
    /*
    for (ADM_Work__c bug : [select Id, Bug_Number__c from ADM_Work__c where Bug_Number__c in :newBugNumbers or Name in :newBugNumbers]){
        if (bug != null) {
            bugMap.put(bug.Bug_Number__c, bug.Id);
            newBugNumbers.remove(bug.Bug_Number__c);
        }
    }
*/
    // 5. create bugs that did not exist
    List<ADM_Work__c> bugsToInsert = new List<ADM_Work__c>();
    /*[ALEXIS] cannot create a work record (bug) with so little information. This needs to be refactored with some thought.
    loopCount = 0;
    Bug__c tempBug = null;
    for (String newBugNumber : newBugNumbers){
        tempBug = new Bug__c();
        tempBug.Bug_Number__c = newBugNumber;
        bugsToInsert.add(tempBug);
        if (++loopCount == 200) {
            loopCount = 0;
            Database.SaveResult[] mySaveResults = Database.Insert(bugsToInsert, true);
            for (Integer i = 0; i < mySaveResults.size(); i++)
                bugMap.put(bugsToInsert[i].Bug_Number__c, mySaveResults[i].getId());
            bugsToInsert.clear();
        }
    }
    */
    /*

    Database.SaveResult[] mySaveResults = Database.Insert(bugsToInsert, true);
    for (Integer i = 0; i < mySaveResults.size(); i++)
        bugMap.put(bugsToInsert[i].Bug_Number__c, mySaveResults[i].getId());
    bugsToInsert.clear();
    newBugNumbers.clear();

    // 6. go through the execution map and insert the CJOs
    loopCount = 0;
    QA_ExecutionBug__c tempCjo = null;
    for (ID execId : cjosToAdd.keySet()) {
        for (String bugName : cjosToAdd.get(execId)) {
            tempCjo = new QA_ExecutionBug__c();
            tempCjo.Execution__c = execId;
            tempCjo.Work__c = bugMap.get(bugName);
            tempCjoList.add(tempCjo);
            if (++loopCount == 200) {
                loopCount = 0;
                insert tempCjoList;
                tempCjoList.clear();
            }
        }
    }*/
    //insert tempCjoList;

}