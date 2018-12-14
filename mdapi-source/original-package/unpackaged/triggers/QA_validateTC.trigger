trigger QA_validateTC on QA_Test_Case__c (before insert, before update) {
    //validate a test case (ensure that hierarchy meets the specifications) before submission
    QA_Hierarchy__c[] baseHiers = [SELECT Name FROM QA_Hierarchy__c WHERE Depth__c = 0 Limit 200];
    Set<String> baseHierSet = new Set<String>();
    for(QA_Hierarchy__c curHier: baseHiers) baseHierSet.add(curHier.Name);
    
    for(QA_Test_Case__c curTC : Trigger.new){
        if(curTC.Hierarchy__c != null){
            
        String trimmedHier = ''; 
        boolean isFirst = true;
        for (String hierSec : curTC.Hierarchy__c.split('[.]')) {
            if (isFirst) {
                isFirst = false;
                trimmedHier += hierSec.trim();
            } else {
                trimmedHier += '.' + hierSec.trim();
            }
        }
        curTC.Hierarchy__c = trimmedHier;   
            
        String[] hierArr = curTC.Hierarchy__c.split('[.]');
        
        //check for empty elements in the hierarchy (i.e. API..test)
        for(String curHierElem : hierArr)
            if(curHierElem == '') curTC.addError('The hierarchy must not contain empty elements!');
        
        //make sure hierarchy is within the size contraints of must be at least depth 2 and at most depth 4
        if(hierArr.size()<2) curTC.addError('The hierarchy must have a depth of at least 2!');
        if(hierArr.size()>5) curTC.addError('The hierarchy can have a depth of at most 5!');
        
        //make sure the base hierarchy is valid
        Boolean ifValidBase = false;
        for(String curBaseHier : baseHierSet){
            //check against list of base hierarchies (case insensitive)
            if(hierArr[0].toLowerCase() == curBaseHier.toLowerCase()){
                ifValidBase = true;
                //if valid base hierarchy is found, ensure correct case for the base hierarchy is maintained (i.e. aPi.test -> API.test)
                hierArr[0] = curBaseHier;   
                String newHier = hierArr[0];
                for(Integer i=1; i<hierArr.size(); i++) newHier += '.' + hierArr[i];
                curTC.Hierarchy__c = newHier;
            }
        }
        
        //if base hierarchy is invalid fire off an error
        if(!ifValidBase) curTC.addError('Please provide a valid base hierarchy!');
        }
        else{
            curTC.addError('Please provide a value in the hierarchy!');
        }
    }
}