public class ADM_ReleasedInDetailAccumulator {
    private ADM_Released_In__c releasedIn;
    private List<ADM_Released_In__c> releasedIns;

    public ADM_ReleasedInDetailAccumulator() {
        releasedIn = new ADM_Released_In__c();
        releasedIns = new List<ADM_Released_In__c>();
    }

    private ADM_Released_In__c getReleasedIn(ADM_Change_List__c changelist, Id releaseId) {
        releasedIn.Work__c = changelist.Work__c;
        releasedIn.Reverted__c = false;
        releasedIn.Release__c = releaseId;
        releasedIn.External_ID__c = releasedIn.Work__c + '@' + releasedIn.Release__c;

        if(changelist.Comments__c.toLowerCase().contains('@revert@')) {
            releasedIn.Reverted__c = true;
        }

        return releasedIn;
    }

    public List<ADM_Released_In__c> getReleasedIns(List<ADM_Change_List__c> changelists, Map<String, ADM_Release__c> releaseMap) {
        ADM_Release__c release;
        Pattern autoIntegrate = Pattern.compile('@rev autointegrate@');

        for(ADM_Change_List__c changelist : changelists) {
            release = releaseMap.get(changelist.Release_Name__c);
            Matcher isAutoIntegrate = autoIntegrate.matcher(changelist.Comments__c);

            if(release != Null && !isAutoIntegrate.find()) {
                releasedIns.add(getReleasedIn(changelist, release.Id));
            }
        }

        return releasedIns;
    }

    public Set<String> getReleasedInIds(List<ADM_Released_In__c> releasedIns) {
        List<Database.Upsertresult> results = Database.upsert(releasedIns, ADM_Released_In__c.External_ID__c, false);
        Set<String> releasedInIds = new Set<String>();

        for(Database.Upsertresult result : results) {
            if(result.isSuccess()) {
                releasedInIds.add(result.getId());
            }
        }

        return releasedInIds;
    }

}