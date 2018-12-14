public class ADM_Severity_Type {
	private static final String FIELD_NAMES = 'a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedById, Type__r.Name, Type__r.Id, Severity__r.Name, Severity__r.Id';
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_FROM = 'from ADM_Severity_Type__c a';
	
    public static void create(){
        ADM_Severity__c[] severities = [ select Name from ADM_Severity__c where Name != NULL order by Name ];
        List<String> typeList = new List<String>{'Test Change','Test Case','Test Failure','Test Tool','Skunkforce'};
        ADM_Type__c[] types = [ select Name from ADM_Type__c where Name in : typeList order by Name ]; 
        
        for(ADM_Severity__c severity : severities){
        	for(ADM_Type__c t : types){
        		ADM_Severity_Type__c st = new ADM_Severity_Type__c(Type__c=t.id,Severity__c=severity.id);
        		Database.insert(st);
        	}            	
        }
    }
    
    //use this method to get all of the elements in the custom object where they are in a specific list
    public static ADM_Severity_Type__c[] getAllBy( String columnName, List< String > columnValues ){
        ADM_Severity_Type__c[] st = null;
        try {
        	String inColumnValues = COM_SoqlUtils.createInClause(columnName, columnValues);
        	String sql = SQL_SELECT + SQL_FROM + ' where ' + inColumnValues;
        	
            st = Database.query(sql);
        } catch( System.Exception e ) {
            st = new ADM_Severity_Type__c[0];
        }
        return st;
    }   
    
    public static ADM_Severity_Type__c match( ADM_Severity_Type__c[] elements, String id ){
        List<ADM_Severity_Type__c> matches = new List<ADM_Severity_Type__c>();
        ADM_Severity_Type__c match = new ADM_Severity_Type__c();
        
        for( ADM_Severity_Type__c el : elements ){        
            if( el.Id == id ){                
                matches.add(el);
            }   
        }
        
        if(matches.size() > 1){
        	//prolly need to throw an error here because it should not match more than 1 id
        }
        else if(matches.isEmpty()){
        	//don't throw an error cuz it has not returned a match
        }
        else if(matches.size() == 1){
        	//good to go cuz we should only have 1 match for a unique id... i think
        	match = matches.get(0);
        }
        
        return match;
    }
    
    public static ADM_Severity_Type__c getBySeverityType( String workType, String severity ){
        ADM_Severity_Type__c st = [
            select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, 
                a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, 
                a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedById, Type__r.Name, 
                Type__r.Id, Severity__r.Name, Severity__r.Id 
            from ADM_Severity_Type__c a
            where type__r.name =: workType and severity__r.name =: severity
        ];
        
        return st;
    }
    
    // send in an id and we will send you back the element
    public static ADM_Severity_Type__c get( String columnValue ){
        List< String > columnValues = new List< String >();        
        columnValues.add( columnValue );
        String columnName = 'Id';
        
        //get an array of elements where the id might have matched... it really should just be one though, right?
        ADM_Severity_Type__c[] elements = getAllBy( columnName, columnValues );
        //use the match method that takes an Id and matches it against a 
        ADM_Severity_Type__c element = match( elements, columnValue );
                
        return element;
    }

}