public with sharing class ADM_SessionCacheManager {
	
	private static Boolean Cache_enabled = false;
	static{
		setCacheEnabled();
	}

	private static void setCacheEnabled(){
		Cache_enabled = false;
		List<ADM_Cache_Metadata__mdt> cacheMDList = [select SessionCacheEnabled__c from ADM_Cache_Metadata__mdt];
		if(cacheMDList != null && cacheMDList.size() >0){
			Cache_enabled = cacheMDList[0].SessionCacheEnabled__c;
		}
	}

	public static void putList(String key, List<sObject> objects){
		if(isCacheEnabled()){
			Cache.session.put(key, objects);
		}	
	}

	public static void put(String key, Object value){
		if(isCacheEnabled()){
			Cache.session.put(key, value);
		}	
	}
		
	public static List<sObject> getList(String key){
		if(!isCacheEnabled()){
			return null;
		}
		return	(isCacheEnabled())? (List<sObject>)Cache.session.get(key) : null; 
	}

		
	public static Object get(String key){
		if(!isCacheEnabled()){
			return null;
		}
		return	(isCacheEnabled())? (Object)Cache.session.get(key) : null; 
	}

	public static Set<String> getKeys(){
		if(!isCacheEnabled()){
			return null;
		}
		return	(isCacheEnabled())? (Set<String>)Cache.session.getKeys() : null; 
	}

	public static Boolean remove(String key){
		return	(isCacheEnabled())? Cache.session.remove(key) : false; 
	}

	public static Boolean isCacheEnabled(){
		return Cache_enabled;
	}
	
	public static Boolean toggleEnabled() {
		Cache_enabled = !Cache_enabled;
		return Cache_enabled;
	}

}