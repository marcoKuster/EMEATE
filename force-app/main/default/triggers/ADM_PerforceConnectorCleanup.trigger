trigger ADM_PerforceConnectorCleanup on ADM_Perforce_Connector__c (before insert) {
  ADM_TextUtils textUtils = new ADM_TextUtils();
  Map<String, ADM_Release__c> releaseMap;
  List<ADM_Release__c> releases;
  List<ADM_Change_List__c> changeLists;
  List<ADM_Released_In__c> releasedIns;
  List<ADM_Release__c> releasesUpserted;
  Set<String> releaseIds;
  Set<String> changelistIds;
  Set<String> releasedInIds;
  ADM_Change_List__c changelist;
  ADM_Released_In__c releasedIn;
  String escapeSingleQuote = '\'';

  ADM_ChangelistDetailAccumulator changelistDetailAccumulator = new ADM_ChangelistDetailAccumulator();
  ADM_ReleasedInDetailAccumulator releasedInDetailAccumulator = new ADM_ReleasedInDetailAccumulator();
  ADM_ReleaseDetailAccumulator releaseDetailAccumulator = new ADM_ReleaseDetailAccumulator();

  for(ADM_Perforce_Connector__c pc : Trigger.new) {
        pc.Changelist__c = pc.Changelist__c.replaceAll(escapeSingleQuote,'');
        pc.Work__c = pc.Work__c.replaceAll(escapeSingleQuote,'');
        pc.Describe__c = textUtils.replaceSingleQuotes(pc.Describe__c);
        if(pc.Release__c != null) pc.Release__c = textUtils.replaceSingleQuotes(pc.Release__c);
        pc.Release__c = releaseDetailAccumulator.getRelease2Use(pc);
        if(pc.Task__c != null) pc.Task__c = pc.Task__c.replaceAll(escapeSingleQuote,'');
  }
    changelists = changelistDetailAccumulator.getChangelists(Trigger.new);
     releases = releaseDetailAccumulator.getReleases(Trigger.new);
     releaseIds = releaseDetailAccumulator.getReleaseIds(releases);
     changelistIds = changelistDetailAccumulator.getChangelistIds(changelists);

  if(releaseIds != null && !releaseIds.isEmpty()) {
    releasesUpserted = ADM_Release.getAllBy('Id', releaseIds);
    releasedIns = releasedInDetailAccumulator.getReleasedIns(changelists, releaseDetailAccumulator.getReleaseMap(releasesUpserted));
    releasedInIds = releasedInDetailAccumulator.getReleasedInIds(releasedIns);
  }
}