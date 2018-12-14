public class ADM_Type {
    public static ADM_Type__c[] getAllBy( String columnName, List< String > columnValues ){
        ADM_Type__c[] els = new ADM_Type__c[]{};
        
        try{
        	if( columnName.equalsIgnoreCase('name') ){                
                els = [ 
                    Select a.Name, a.Id 
                    From ADM_Type__c a 
                    where Name in :columnValues 
                ];
            }
            else if( columnName.equalsIgnoreCase('id') ){                
                els = [ 
                    Select a.Name, a.Id 
                    From ADM_Type__c a 
                    where Id in :columnValues 
                ];
            }
                            
            return els;
        }
        
        catch( System.Exception e ){
            return els;
        }
    }   
    
    public static ADM_Type__c match( ADM_Type__c[] els, String name ){
        
        for( ADM_Type__c el : els ){
            if( el.Name == name ){                
                return el;
            }   
        }
        
        return null;
    }
    
    public static ADM_Type__c[]getAll(){
    	ADM_Type__c[] els = [ 
            select a.Name, a.Id 
            from ADM_Type__c a
            where a.Name != NULL
            order by Name
        ];
        
        return els;
    }
    
    public static ADM_Type__c get( String columnValue ){
        List< String > columnValues = new List< String >();        
        columnValues.add( columnValue );
        String columnName = 'Name';        
        
        ADM_Type__c[] els = getAllBy( columnName, columnValues );
        ADM_Type__c admType = match( els, columnValue );
        
        return admType;
    }
}