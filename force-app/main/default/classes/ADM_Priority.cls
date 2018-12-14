public class ADM_Priority {
    public static ADM_Priority__c[] getAllBy( String columnName, List< String > columnValues ){
        ADM_Priority__c[] els = new ADM_Priority__c[]{};
        
        try{
            
            if( columnName.equalsIgnoreCase('ownerid') ){                
                els = [ 
                    Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
                    From ADM_Priority__c a 
                    where OwnerId in :columnValues 
                ];
            }
            
            else if( columnName.equalsIgnoreCase('name') ){                
                els = [ 
                    Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
                    From ADM_Priority__c a 
                    where Name in :columnValues 
                ];
            }           
            
            else if( columnName.equalsIgnoreCase('lastmodifiedby') ){                 
                els = [                  
                    Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
                    From ADM_Priority__c a 
                    where LastModifiedById in :columnValues 
                ];
            }
            
            else if( columnName.equalsIgnoreCase('id') ){                
                els = [ 
                    Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
                    From ADM_Priority__c a 
                    where Id in :columnValues 
                ];
            }
            
            else if( columnName.equalsIgnoreCase('createdby') ){                
                els = [ 
                    Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
                    From ADM_Priority__c a 
                    where CreatedById in :columnValues 
                ];
            }
                            
            return els;
        }
        
        catch( System.Exception e ){
            return els;
        }
    }   
    
    static testMethod void testGetAllBy() {
    	ADM_Priority__c p = new ADM_Priority__c(Name = 'Test P');
    	insert p;
    	ADM_Priority__c[] pAll = ADM_Priority.getAllBy('id', new List<String>{p.id});
    	System.assert(pAll != null);
    	System.assert(pAll.size() > 0);
    	
    }
    
    public static ADM_Priority__c match( ADM_Priority__c[] els, String name ){
        
        for( ADM_Priority__c el : els ){
            if( el.Name == name ){                
                return el;
            }   
        }
        
        return null;
    }
    
    public static ADM_Priority__c[]getAll(){
        ADM_Priority__c[] els = [ 
            select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
            from ADM_Priority__c a
            where a.Name != NULL
            order by Name
        ];
        
        return els;
    }
    
    static testMethod void testGetAll() {
    	if([select count() from ADM_Priority__c where Name = 'P1'] == 0) {
    		 ADM_Priority__c p1 = new ADM_Priority__c(Name = 'P1');
    		 insert p1;
    	}
    	ADM_Priority__c[] pAll = ADM_Priority.getAll();
    	System.assert(pAll != null);
    	System.assert(pAll.size() > 0);
    }
    
    public static ADM_Priority__c get( String columnValue ){
        List< String > columnValues = new List< String >();        
        columnValues.add( columnValue );
        String columnName = 'Name';        
        
        ADM_Priority__c[] els = getAllBy( columnName, columnValues );
        ADM_Priority__c el = match( els, columnValue );
        
        return el;
    }
    
    static testMethod void testGet() {
    	if([select count() from ADM_Priority__c where Name = 'P1'] == 0) {
    		 ADM_Priority__c p1 = new ADM_Priority__c(Name = 'P1');
    		 insert p1;
    	}
    	ADM_Priority__c p = ADM_Priority.get('P1');
    	System.assert(p != null);
    	System.assert(p.Name == 'P1');
    }
}