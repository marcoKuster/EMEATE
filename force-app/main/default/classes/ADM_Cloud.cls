public class ADM_Cloud {



    public static ADM_Cloud__c createTestCloud(String cloudName) {
       ADM_Parent_Cloud__c parentCloud = new ADM_Parent_Cloud__c(Name='Test Parent Cloud' + Math.Random());
       insert parentCloud;

        ADM_Cloud__c cloud = new ADM_Cloud__c(name=cloudName, Parent_Cloud__c=parentCloud.Id);
        insert cloud;
        return cloud;
    }

    public static Map<String, String> getCloudToPCTMap(Set<String> cloudIds){
    	Map<String, String> cloudIdToPCTMap = new Map<String, String>();
    	List<ADM_Cloud__c> clouds = [Select id, Name, Parent_Cloud__c from ADM_Cloud__c where id in :cloudIds ];
    	if(clouds != null && clouds.size() >0){
    		for(ADM_Cloud__c cloud: clouds){
    			if(cloud.Parent_Cloud__c != null){
    				cloudIdToPCTMap.put(cloud.Id, cloud.Parent_Cloud__c);
    			}
    		}
    	}
    	return cloudIdToPCTMap;
    }

    public static Map<String, ADM_Cloud__c> getCloudIdToCloudObjectMap(List<String> cloudIds){
       Set<String> cloudIdSet = new Set<String>(cloudIds);
       return getCloudIdToCloudObjectMap(cloudIdSet);
    }

    public static Map<String, ADM_Cloud__c> getCloudIdToCloudObjectMap(Set<String> cloudIds){
    	Map<String, ADM_Cloud__c> cloudIdToCloudMap = new Map<String, ADM_Cloud__c>();
    	List<ADM_Cloud__c> clouds = [Select id, Name, Parent_Cloud__c, Parent_Cloud__r.Name from ADM_Cloud__c where id in :cloudIds ];
    	if(clouds != null && clouds.size() >0){
    		for(ADM_Cloud__c cloud: clouds){

    			if(cloud.Parent_Cloud__c != null){
    				cloudIdToCloudMap.put(cloud.Id, cloud);
    			}
    		}
    	}
    	return cloudIdToCloudMap;
    }

}