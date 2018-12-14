public class ADM_Problem_Controller {

    @AuraEnabled
    public static List<Map<String,String>> getProblemList( String workId ){

        List<Map<String,String>> listOfProblems = new List<Map<String,String>>();    
                
        try {

      String tempId = String.valueOf(workId);
             List<sObject> sobjList = Database.query(
                'SELECT Id, Problem__c, Problem__r.Name, Problem__r.Id, Problem__r.Problem_State__c, Problem__r.Problem_Description__c FROM SM_Problem_Work_Junction__c  WHERE Work__c  =: tempId');
            
            if(sobjList != null && sobjList.size() > 0) {
                // Iterate over the object list   
                for ( sObject temp : sobjList ){ 
                    SObject problem = temp.getSObject('Problem__r');
                    String description = (String)problem.get('Problem_Description__c');
                    String status = (String)problem.get('Problem_State__c');
                    String name = (String)problem.get('Name');
                    String probId = (String)problem.get('Id');
                    Map<String,String> mapTemp = new Map<String,String>();
                     mapTemp.put('DESC',description);
                    mapTemp.put('STATUS',status);
                    mapTemp.put('PROBLEM_NAME',name);
                     mapTemp.put('PROBLEM_ID',probId);
                    listOfProblems.add(mapTemp);
                } // for loop  
            } // if not null
  
        } catch(System.QueryException qe) {    
        
      System.debug('The SM_Problem__c object isn\'t available to query.');
        
        } catch(Exception e) {    
            
            System.debug('There was a general exception trying to retrieve the SM_Problem__c object');

        }
 
    return listOfProblems;
    }
}