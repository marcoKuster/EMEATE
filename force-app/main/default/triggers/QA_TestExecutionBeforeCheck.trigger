trigger QA_TestExecutionBeforeCheck on QA_Test_Execution__c (before insert, before update) {
    // Create new CJOs for every bug in the list
    // EXAMPLE:
    // Assume we are inserting 1 test execution with bugs: "12345,67890" and
    // the only existing bug is 12345
    //
    // The result should be 2 new CJOs, a new bug: 67890
    // 1. Create a list of all the bugs to retrieve and a list of ids with bugs
    // 1.a. Fail the executions that have bug issues
    List<String> allBugs = new List<String>();
    Map<ID, List<String>> executionBugs = new Map<Id, List<String>>();
    Boolean[] errors = new Boolean[Trigger.new.size()];
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        String bugs = Trigger.new[i].Bugs__c;
        if (bugs == null)
            continue;

        if(!bugs.equals(bugs.replace(' ',''))){
            bugs = bugs.replace(' ','');
            bugs = bugs.replace('\t','');
        }
        if(bugs.startsWith(',')){
            bugs = bugs.replaceFirst(',*','');
        }
        bugs = bugs.replaceAll(',,*', ',');

        if(bugs.endsWith(',')){
            bugs = bugs.substring(0, bugs.length()-1);
        }


        String[] bugsArr = bugs.split('[,]');
        Set<String> bugSet = new Set<String>(bugsArr);
        bugs = '';
            for (String bug : bugSet) {
             if(bug.startsWith('0')){
                 bug = bug.replaceFirst('0*','');
             }
             bugs = bugs + bug + ',';
            }
        bugs = bugs.substring(0, bugs.length()-1); //replace ',' at the last place
        bugsArr = bugs.split('[,]');
        if (bugsArr.size() > 0){
            for (String bug : bugsArr) {
                if(!(Pattern.matches('W-\\d{6}',bug) || Pattern.matches('0*[1-9]\\d{3,6}', bug))){
                //Bug logged with QA force team    
		//Trigger.new[i].Bugs__c.addError('Bug# '+bug+ ' has an incorrect range or incorrect format. Bugs should be a number between 1000 - 10000000 or else it should start with \'W-\' followed by a six digit number');
                    //errors[i] = true;
                }

            }
        }
        Trigger.new[i].Bugs__c = bugs;  //replace all the ',' without any number inbetween like 12345,,,123456 to 12345,123456
    }

    // check that no limits are hit
    Integer newCjos = 0;
    Integer removedCjos = 0;
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        String[] beforeBugArray = new String[0];
        if (Trigger.isUpdate && Trigger.old[i].Bugs__c != null)
            beforeBugArray = Trigger.old[i].Bugs__c.replace(' ','').split('[,]');

        String[] afterBugArray = new String[0];
        if (Trigger.new[i].Bugs__c != null)
            afterBugArray = Trigger.new[i].Bugs__c.replace(' ','').split('[,]');

        Set<String> bugs = new Set<String>(beforeBugArray);
        bugs.removeAll(afterBugArray);
        removedCjos += bugs.size();

        bugs = new Set<String>(afterBugArray);
        bugs.removeAll(beforeBugArray);
        newCjos += bugs.size();
    }
    if (newCjos * 2 + removedCjos > Limits.getLimitDMLRows() ||
        Math.min(2, newCjos * 2 / 200) + Math.min(1, removedCjos / 100) > Limits.getLimitQueries() ||
        newCjos + removedCjos > Limits.getLimitQueryRows())
        for (QA_Test_Execution__c exec : Trigger.new)
            exec.Bugs__c.addError('Too many bugs. Reduce the number of executions being updated');
}