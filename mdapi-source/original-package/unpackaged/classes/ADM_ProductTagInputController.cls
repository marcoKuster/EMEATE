//has to have global scope to be used inside an MDP page since salesforce wraps MDP actions in iframes
global with sharing class ADM_ProductTagInputController {
    private transient Boolean showGuidedTour = null;
    ADM_ConstantsSingleton signletonConstants = ADM_ConstantsSingleton.getInstance();
    private static List<ADM_Product_Tag__c> pTags = new List<ADM_Product_Tag__c>();
    private static String PTAG_CACHE_KEY = 'CachedPTagList';
    private static String PTAG_CACHE_KEY_COUNT = 'CachedPTagKeyCount';
    /**
     * Gets true when the product tag guided tour should be shown.
     */
    public Boolean getShowGuidedTour() {
        try {
            if(this.showGuidedTour == null) {
                //retrieve the user preferences for the current user
                ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
                this.showGuidedTour = preferences.ShowProductTagGuidedTour__c;
            }
            return this.showGuidedTour;
        } catch(Exception exc) {
            System.debug(Logginglevel.WARN, 'Exception occurred while retrieving User Preferences. Returning false. ' + exc.getMessage());
            return false;
        }
    }
    
    /**
     * Gets the list of available product tags given the specified record type. If 
     * the productTagId is specified, it is retrieved also.  This allows the
     * input to retrieve all available tags and the tag that is loaded.
     */
    @RemoteAction
    global static List<ADM_Product_Tag__c> getTags(String recordType, String productTagId) {
        List<ADM_Product_Tag__c> tags = new List<ADM_Product_Tag__c>();
        
        //get the list of all tags assigned to the record type and add them to 
        //the list.
        if(!ADM_TextUtils.isBlank(recordType)) {
            tags.addAll(getTagsForRecordType(recordType));
        }
        
        //if the ID is specified and valid, add it to the list
        if(!ADM_TextUtils.isBlank(productTagId) && !ADM_ProductTag.contains(tags, productTagId)) {
            ADM_Product_Tag__c currentTag = getTagById(productTagId);
            
            if(currentTag != null) {
                //add the current to the beginning if the list of available tags is not null
                if(tags.isEmpty()) {
                    tags.add(currentTag);
                } else {
                    tags.add(0, currentTag);
                }
            } else {
                System.debug('Unable to find product tag with ID of \''+ productTagId +'\'');
            }
        }
        
        return tags;
    }
    
    /**
     * Change the user preference to never show the Guided Tour again.
     */
    @RemoteAction
    global static void neverShowGuidedTour() {
        ADM_User_Preferences__c preferences = ADM_User_Preferences__c.getInstance(UserInfo.getUserId());
        preferences.ShowProductTagGuidedTour__c = false;
        upsert preferences;
    }
    
    /**
     * Gets the product tag for the specified ID.  If the ID is null, then a 
     * null reference is returned.
     */
    private static ADM_Product_Tag__c getTagById(String productTagId) {
        ADM_Product_Tag__c currentTag = [
            select
                Id,
                Name,
                Team__r.Name
            from 
                ADM_Product_Tag__c
            where
                Id = :productTagId
            limit 1
        ]; 
        return currentTag;
    }
    
    private static List<ADM_Product_Tag__c> queryPtags(String rType) {
      return [select Id, Name, Team__r.Name from ADM_Product_Tag__c where  Active__c = true and Team__r.Active__c = true and
          Id in (select Product_Tag__c from ADM_Tag_Assignment__c where Record_Type__c = :rType)];
    }

    /**
     * Gets the list of active product tags given the specified record type.
     */
    private static List<ADM_Product_Tag__c> getTagsForRecordType(String recordType) {
      boolean expOccured = false; 
      try{
        if(pTags != null && pTags.size() == 0){

          Integer cacheKeyCounter = (Integer) ADM_OrgCacheManager.get(PTAG_CACHE_KEY_COUNT);
          Integer keyCounter = 0;
          if(cacheKeyCounter == null){
        //if the user is requesting the types for the 'Template', then give
        //them the bug
        if(recordType == ADM_Work.TEMPLATE_RECORD_TYPE_NAME) {
            recordType = ADM_Work.BUG_RECORD_TYPE_NAME;
        }
            System.debug(' Since key  '+ PTAG_CACHE_KEY_COUNT + ' was not found proceeding to query Product Tag record');
            pTags = queryPtags(recordType);
            List<ADM_Product_Tag__c> tempList = new List<ADM_Product_Tag__c>();

            for(Integer count = 0; ptags != null && count < ptags.size(); count++){
              tempList.add(ptags.get(count));
              if(count >= 4000 && math.mod(count, 4000) == 0){
                System.debug(' seems like there are more than 4000 Product Tags so creating multiple keys with key prefix '+ PTAG_CACHE_KEY);
                ADM_OrgCacheManager.putList(PTAG_CACHE_KEY + keyCounter++, tempList);
                tempList = new List<ADM_Product_Tag__c>();
              }
            }

            if(tempList.size() > 0){
              System.debug(' final ADM_Product_Tag__c list has '+ tempList.size() + ' ADM_Product_Tag__c');
              ADM_OrgCacheManager.putList(PTAG_CACHE_KEY + keyCounter++, tempList);
            }
            System.debug(' no of keys used to store user cache '+ keyCounter);
            //ADM_OrgCacheManager.put(USER_CACHE_KEY_COUNT, keyCounter);

            ADM_OrgCacheManager.put(PTAG_CACHE_KEY_COUNT, keyCounter); //incrementing keycounter as it is 0 index based count will be always +1
          }
          else{
            System.debug(' Product Tag list exist in Org Cache getting it from there, cacheKeyCounter -> ' + cacheKeyCounter);
            pTags = new List<ADM_Product_Tag__c>();
            for(Integer keyCount = 0; keyCount <  cacheKeyCounter ; keyCount++){
              System.debug(' Retrieving '+  PTAG_CACHE_KEY + keyCount);
              pTags.addAll((List<ADM_Product_Tag__c>) ADM_OrgCacheManager.getList(PTAG_CACHE_KEY + keyCount));
            }
          }
        }
      }
      catch(Cache.CacheException ce){
        System.debug(' CacheException happened while retrieving product tags '+ ce.getMessage() + ' line number '+ ce.getLineNumber());
        System.debug(ce.getMessage());
        expOccured = true;
        ADM_ExceptionHandler.saveException(ce, 'CacheException happened while retrieving product tags:' + ce + ' Line:' + ce.getLineNumber());
      }
      catch(Exception exp){
        System.debug(' exception happened while retrieving product tags '+ exp.getMessage() + ' line number '+ exp.getLineNumber());
        System.debug('Attempting to retrieve product tags one more time');
        expOccured = true;
        ADM_ExceptionHandler.saveException(exp, 'Exception happened while retrieving product tags:' + exp + ' Line:' + exp.getLineNumber());
      }
      //We don't want work page to fail because of exception happening in Cache or due to any other failues..so if exception happened
      //check product tags list is empty and if yes requery to fill it.
      if(expOccured && ptags != null && ptags.size() == 0){
          if(recordType == ADM_Work.TEMPLATE_RECORD_TYPE_NAME) {
            recordType = ADM_Work.BUG_RECORD_TYPE_NAME;
          }
          ptags = queryPtags(recordType);
      }
        
      return ptags;
    }

     public String nameSpace{
        get{
          return signletonConstants.getNameSpace().replace('__', '.');
        }
        set;
       
    }

}