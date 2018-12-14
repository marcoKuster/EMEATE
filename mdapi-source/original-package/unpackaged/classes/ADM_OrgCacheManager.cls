public with sharing class ADM_OrgCacheManager {
	private static Boolean Cache_enabled = false;
	static{
		setCacheEnabled();
	}

	private static void setCacheEnabled(){
		Cache_enabled = false;
		List<ADM_Cache_Metadata__mdt> cacheMDList = [select OrgCacheEnabled__c from ADM_Cache_Metadata__mdt];
		if(cacheMDList != null && cacheMDList.size() >0){
			Cache_enabled = cacheMDList[0].OrgCacheEnabled__c;
		}
	}

	public static void putList(String key, List<sObject> objects){
		if(isCacheEnabled()){
			Cache.org.put(key, objects);
		}	
	}

	public static void put(String key, Object value){
		if(isCacheEnabled()){
			Cache.org.put(key, value);
		}	
	}
		
	public static List<sObject> getList(String key){
		if(!isCacheEnabled()){
			return null;
		}
		return	(isCacheEnabled())? (List<sObject>)Cache.org.get(key) : null; 
	}

	public static List<sObject> getList(List<String> keys){
		if(!isCacheEnabled()){
			return null;
		}
		return	(isCacheEnabled())? (List<sObject>)Cache.org.get(keys) : null; 
	}
	
	public static Object get(String key){
		if(!isCacheEnabled()){
			return null;
		}
		return	(isCacheEnabled())? (Object)Cache.org.get(key) : null; 
	}

	public static Set<String> getKeys(){
		if(!isCacheEnabled()){
			return null;
		}
		return	(isCacheEnabled())? (Set<String>)Cache.org.getKeys() : null; 
	}

	public static Boolean remove(String key){
		return	(isCacheEnabled())? Cache.org.remove(key) : false; 
	}

	public static Boolean remove(List<String> keys){
		if(!isCacheEnabled()){
			return false;
		} 
		Cache.org.remove(keys);
		return true; 
	}

	public static Boolean isCacheEnabled(){
		return Cache_enabled;
	}
	
	public static Boolean toggleEnabled() {
		Cache_enabled = !Cache_enabled;
		return Cache_enabled;
	}

	
}