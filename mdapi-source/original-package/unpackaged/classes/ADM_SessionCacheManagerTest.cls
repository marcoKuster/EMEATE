@isTest
public class ADM_SessionCacheManagerTest {
    
	@isTest
    public static void testSessionCacheToggle(){
        
        if ( ADM_SessionCacheManager.isCacheEnabled()){
             ADM_SessionCacheManager.toggleEnabled();
            System.assert(! ADM_SessionCacheManager.isCacheEnabled());
        } else {
             ADM_SessionCacheManager.toggleEnabled();
            System.assert( ADM_SessionCacheManager.isCacheEnabled());
        }
	}
    
    @isTest
    public static void testBasicSessionCacheUsage(){

        if (ADM_SessionCacheManager.isCacheEnabled()){
    
            String test_key = 'key'+ System.currentTimeMillis();
            String test_data = 'data1.' + System.currentTimeMillis();

            // Put something in the cache, return it and confirm
        	 ADM_SessionCacheManager.put( test_key, test_data );
            String return_object = (String)  ADM_SessionCacheManager.get( test_key );
            System.assertEquals( test_data, return_object );
       
            // Now remove the element
             ADM_SessionCacheManager.remove( test_key );
            
            // Put something in the cache, return it and confirm
            String return_object_second = (String)  ADM_SessionCacheManager.get( test_key );
            System.assertEquals( null, return_object_second );
                   
        } else {
            System.debug('Skipping execution of testBasicSessionCacheUsage since the cache isn\'t ');
        }    

    }
    
}