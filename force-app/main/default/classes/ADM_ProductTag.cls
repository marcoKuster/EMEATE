public with sharing class ADM_ProductTag {
	/**
	 * Gets the product tag for the specified ID value
	 */
	public static ADM_Product_Tag__c get(Id productTagId) {
        if(productTagId == null) {
            return null;
        }
		return [select Id, Name, Active__c, Team__c from ADM_Product_Tag__c where Id = :productTagId limit 1];
	}
	
    /**
     * Creates and inserts a new product tag with a random name for the specified team.
     */
	public static ADM_Product_Tag__c createAndInsertProductTagForTeam(ADM_Scrum_Team__c team) {
        ADM_Product_Tag__c productTag = new ADM_Product_Tag__c();
        productTag.Name = 'tag' + Math.random();
        productTag.Active__c = true;
        productTag.Team__c = team.Id; 
        insert productTag;
        return productTag;
	}
	
    public static List<String> getTeamIdsFromTagIds(List<String> tagIds){
        List<String> teamIds = new List<String>();
        List<ADM_Product_Tag__c> tags = [Select Team__c from ADM_Product_Tag__c where id in :tagIds];
        if(tags != null && tags.size() >0){
            for(ADM_Product_Tag__c tag : tags){
                teamIds.add(tag.Team__c);
            }
        }

        return teamIds;
    }

	/**
	 * Creates and inserts a new product tag with a random name.
	 */
	public static ADM_Product_Tag__c createAndInsertProductTag() {
		return createAndInsertProductTagForTeam(ADM_ScrumTeam.createAndInsertScrumTeamWithRandomName());
	}
	
    /**
     * Returns true when the list of product tags contains the specified ID.
     */
    public static Boolean contains(List<ADM_Product_Tag__c> tags, String productTagId) {
        for(ADM_Product_Tag__c tag : tags) {
            if(tag.Id == productTagId) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Removes the tag with the specified ID from the set.
     */
     
    public static Set<ADM_Product_Tag__c> removeTagById(Set<ADM_Product_Tag__c> tags, String tagID) {
    	
    	
        ADM_Product_Tag__c matchingTag = null;
        
        for(ADM_Product_Tag__c tag : tags) {
            if(tag.Id == tagID) {
                matchingTag = tag;
                break;
            }
        }
        
        if(matchingTag != null) {
            tags.remove(matchingTag);
        }
        
        return tags;
    }
}