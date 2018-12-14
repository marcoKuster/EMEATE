global without sharing class ADM_FeedItemUtil {

    public static Integer getNonTrackedChangedFeedItemsCountByParentID(Id parentID) {
        return  [select count() from FeedItem where ParentId =:parentID and Type != 'TrackedChange'];
    }

    public static Integer getFeedItemsCountByParentID(Id parentID) {
        return  [select count() from FeedItem where ParentId =:parentID];
    }

    public static List<FeedItem> getRecentFeedItemsByParentId(List<Id> parentIDs) {
        return  [Select ContentFileName, LinkUrl, Type, CreatedBy.Name, CreatedById,CreatedDate, isRichText,
                              Body,ParentId, (Select FieldName, OldValue, NewValue FROM feedTrackedChanges ORDER BY Id DESC) from FeedItem where parentId = :parentIDs
                               and type <> 'CreateRecordEvent' order by createdDate desc limit 5];
    }

     public static List<FeedItem> getFeedItemsIdsByParentId(List<Id> parentIDs) {
        return  [Select Id, ParentId from FeedItem where parentId = :parentIDs];
    }

    /*
      Feed item which is actually a post by user and not tracked changes.
    */

    public static List<FeedItem> getActualPostItemsIdsByParentId(List<Id> parentIDs) {
        return  [Select Id, ParentId from FeedItem where parentId = :parentIDs and Type  != 'TrackedChange'];
    }

    public static void createFeedItems(Map<Id, String> parentIdToFeedBodyMap, String postType){
      List<FeedItem> feedItemsToPost = new List<FeedItem>();
      for(Id parentId: parentIdToFeedBodyMap.keyset()){
        FeedItem groupFeedPost = new FeedItem(Body=parentIdToFeedBodyMap.get(parentId), ParentId =parentId, Type=postType);
        feedItemsToPost.add(groupFeedPost);
      }
      if(feedItemsToPost.size()>0){
        insert feedItemsToPost;
      }

    }

}