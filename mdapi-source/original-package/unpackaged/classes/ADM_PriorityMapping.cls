public class ADM_PriorityMapping {
	
	 private static final String FIELD_NAMES = 'Frequency__r.Name,Frequency__c, Impact__c, Impact__r.Name,Impact__r.Order__c, Priority__c, Priority__r.Name';	
	 private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
     private static final String SQL_FROM = 'from ADM_Priority_Mapping__c ';
	
	 public static List<ADM_Priority_Mapping__c> getAllBy( String columnName, List<String> columnValues, List<ADM_sortingWrapper> sortingWrappers){
        List<ADM_Priority_Mapping__c> pms = new List<ADM_Priority_Mapping__c>();
        try{
        	String inColumnValues = COM_SoqlUtils.createInClause(columnName, columnValues);
        	String sql = SQL_SELECT + SQL_FROM + ' where ' + inColumnValues + ' order by ';
        	
            Integer i = 0;
        	for(ADM_sortingWrapper sortingWrapper : sortingWrappers) {
        		if(i > 0) {
        			sql += ', ';
        		}
        		sql += COM_SoqlUtils.createOrder(sortingWrapper.sortBy, sortingWrapper.sortOrder);
        		i++;
        	}
        	
            for( ADM_Priority_Mapping__c mapping : Database.query(sql)){                        	 
                pms.add(mapping);
            }
            
        }
        
        catch( System.Exception e ){ 
        	
        }
        
        return pms;
    }
	
	public static List<ADM_Priority_Mapping__c> getAllBy( String columnName, List<String> columnValues, String sortBy, String sortOrder ){
		return getAllBy(columnName, columnValues, new List<ADM_SortingWrapper>{new ADM_SortingWrapper(sortBy, sortOrder)});
    } 
    
    testMethod static void testGetAllBySortingMap() {
    	ADM_Priority_Mapping__c pm1 = createTest();
    	ADM_Priority_Mapping__c pm2 = createTest();    	
    	List<String> columnValues = new List<String>();
    	List<ADM_sortingWrapper> sortingWrappers = new List<ADM_sortingWrapper>();
    	ADM_sortingWrapper sortingWrapperFrequency = new ADM_sortingWrapper();
    	ADM_sortingWrapper sortingWrapperImpact = new ADM_sortingWrapper(); 
    	String columnName = 'Frequency__c';
    	
    	columnValues.add(pm1.Frequency__c);
    	columnValues.add(pm2.Frequency__c);
    	
    	sortingWrapperFrequency.sortBy = 'Frequency__r.Order__c';
    	sortingWrapperFrequency.sortOrder = 'ASC';
    	sortingWrapperImpact.sortBy = 'Impact__r.Order__c';
    	sortingWrapperImpact.sortOrder = 'ASC';
    	
    	List<ADM_Priority_Mapping__c> mappings = getAllBy(columnName, columnValues, sortingWrappers);
    	System.assert(mappings != null);    	
    	mappings = null;
    	
    	sortingWrappers.add(sortingWrapperImpact);
    	mappings = getAllBy(columnName, columnValues, sortingWrappers);    	
    	System.assert(mappings != null);    	
    	mappings = null;
    	
    	sortingWrappers.add(sortingWrapperFrequency);
    	mappings = getAllBy(columnName, columnValues, sortingWrappers);    	
    	System.assert(mappings != null);
    } 
    
    testMethod static void testGetAllBy() {
    	ADM_Frequency__c f = new ADM_Frequency__c(Name = 'Test Frequency 123', Order__c = 10);
    	insert f;
    	ADM_Impact__c i = new ADM_Impact__c(Name = 'Security', Order__c = 10);
    	insert i;
    	ADM_Priority__c p = new ADM_Priority__c(Name = 'P0');
    	insert p;
    	ADM_Priority_Mapping__c pm = new ADM_Priority_Mapping__c(Frequency__c = f.id, Impact__c = i.id, Priority__c = p.id);
    	insert pm;
    	
    	List<ADM_Priority_Mapping__c> mappings = ADM_PriorityMapping.getAllBy('Frequency__c', new List<String>{f.id}, 'id', 'desc');
    	System.assert(mappings != null);
    	//System.assert(mappings.size() > 0);
    	System.assert(mappings[0].Priority__c == p.id);
    } 
    
    public static List<ADM_Priority_Mapping__c> getByFrequencyAndImpact(Id frequencyID, Id impactID){
        List<ADM_Priority_Mapping__c> pms = null;
        try{
        	String sql = SQL_SELECT + SQL_FROM + ' where Frequency__c = :frequencyID and Impact__c = :impactID';
            
            pms = Database.query(sql);
            
        } catch( System.Exception e ){ 
        	
        	pms = new List<ADM_Priority_Mapping__c>();
        }
        return pms;
    } 
    
    @IsTest
    public static ADM_Priority_Mapping__c createTest() {
    	ADM_Frequency__c f = new ADM_Frequency__c(Name = 'Always');
    	insert f;
    	ADM_Impact__c i = new ADM_Impact__c(Name = 'Security');
    	insert i;
    	ADM_Priority__c p = new ADM_Priority__c(Name = 'P0');
    	insert p;
    	ADM_Priority_Mapping__c pm = new ADM_Priority_Mapping__c(Frequency__c = f.id, Impact__c = i.id, Priority__c = p.id);
    	insert pm;
    	
    	return pm;
    }
    
    
    
    testMethod static void testGetFrequencyAndImpact() {
    	ADM_Frequency__c f = new ADM_Frequency__c(Name = 'Always');
    	insert f;
    	ADM_Impact__c i = new ADM_Impact__c(Name = 'Security');
    	insert i;
    	ADM_Priority__c p = new ADM_Priority__c(Name = 'P0');
    	insert p;
    	ADM_Priority_Mapping__c pm = new ADM_Priority_Mapping__c(Frequency__c = f.id, Impact__c = i.id, Priority__c = p.id);
    	insert pm;
    	
    	List<ADM_Priority_Mapping__c> mappings = ADM_PriorityMapping.getByFrequencyAndImpact(f.id, i.id);
    	System.assert(mappings != null);
    	System.assert(mappings.size() > 0);
    	System.assert(mappings[0].Priority__c == p.id);
    } 
    
    public static Map<String, ADM_Priority_Mapping__c> getAllAsImpactFrequencyMap(){
        Map<String, ADM_Priority_Mapping__c> pms = new Map<String, ADM_Priority_Mapping__c>();
        
        try{        	
        	String sql = SQL_SELECT + SQL_FROM;
            
            for( ADM_Priority_Mapping__c mapping : Database.query(sql)){                        	 
                pms.put(mapping.Impact__c + '-' + mapping.Frequency__c, mapping);
            }
            
        } catch( System.Exception e ){ 
        	
        }
        return pms;
    }  
	
}