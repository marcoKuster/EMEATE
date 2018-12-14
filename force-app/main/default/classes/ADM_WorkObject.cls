Global class ADM_WorkObject {
    
      
    public static void setCreatedImportValues( ADM_Work__c w, Boolean isInsert ){
        // if this is insert we want to set using these cuz the others are not accessible
        if( isInsert ){         
            w.Created_On_Import__c = System.now();      
            w.Created_By_Import__c = UserInfo.getUserId();
        }
        else{
            //populate if null        
            if( w.Created_On_Import__c == null){            
                w.Created_On_Import__c = w.CreatedDate;      
            }           
            // SAA
            if( w.Created_By_Import__c == null ){
                w.Created_By_Import__c = w.CreatedById;     
            }
        }       
    }
    
    
}