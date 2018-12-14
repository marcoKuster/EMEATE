@isTest
public class ADM_OrgCacheManagerTest {

    @isTest
    public static void testCacheToggle(){
        
        if (ADM_OrgCacheManager.isCacheEnabled()){
            ADM_OrgCacheManager.toggleEnabled();
            System.assert(!ADM_OrgCacheManager.isCacheEnabled());
        } else {
            ADM_OrgCacheManager.toggleEnabled();
            System.assert(ADM_OrgCacheManager.isCacheEnabled());
        }
	}
    
    @isTest
    public static void testBasicCacheUsage(){
        
        if (ADM_OrgCacheManager.isCacheEnabled()){
    
            String test_key = 'key'+ System.currentTimeMillis();
            String test_data = 'data1.' + System.currentTimeMillis();

            // Put something in the cache, return it and confirm
        	ADM_OrgCacheManager.put( test_key, test_data );
            String return_object = (String) ADM_OrgCacheManager.get( test_key );
            System.assertEquals( test_data, return_object );
       
            // Now remove the element
            ADM_OrgCacheManager.remove( test_key );
            
            // Put something in the cache, return it and confirm
            String return_object_second = (String) ADM_OrgCacheManager.get( test_key );
            System.assertEquals( null, return_object_second );


        } else {
            System.debug('Skipping execution of testBasicCacheUsage since the cache isn\'t ');
        }
           
    }
    
}