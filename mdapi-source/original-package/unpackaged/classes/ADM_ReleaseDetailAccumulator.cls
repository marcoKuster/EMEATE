public class ADM_ReleaseDetailAccumulator 
{
  private List<ADM_Release__c> releases;
  private ADM_Release__c release;
  public static final String RELEASE_2_USE = '@release2use ';

  public ADM_ReleaseDetailAccumulator() {
    releases = new List<ADM_Release__c>();
    release = new ADM_Release__c();
  }

  public String getRelease2Use(ADM_Perforce_Connector__c connector) {
    List<String> lines = connector.Describe__c.split('\n');

    for(String line : lines) {
      String lineOriginal = line;
      line = line.toLowerCase();

      if(line.contains(RELEASE_2_USE)) {
        line = lineOriginal.substring(RELEASE_2_USE.length(), lineOriginal.length());

        if(line.indexOf('@') > -1) {
          line = line.substring(0,line.indexOf('@'));
        }

        connector.Release__c = line;
        continue;
      }
    }

    return connector.Release__c;
  }

  public List<ADM_Release__c> getReleases(ADM_Perforce_Connector__c[] connectors) {
    for(ADM_Perforce_Connector__c connector : connectors) {
      if(connector.Release__c != null && !connector.Release__c.replaceAll('-','').equalsIgnoreCase('none')) {
        releases.add(getRelease(connector));
      }
    }

    return releases;
  }

  public Set<String> getReleaseIds(List<ADM_Release__c> releases) {
    List<Database.Upsertresult> results = Database.upsert(releases, ADM_Release__c.External_ID__c, false);
    Set<String> releaseIds = new Set<String>();
    Pattern exceptionPattern = Pattern.compile('href=/(\\w{15,18})(>)');

    for(Database.Upsertresult result : results) {
      if(result.isSuccess()) {
        releaseIds.add(result.getId());
      } else {
        for(Database.Error e : result.getErrors()){
          matcher exceptionMatcher = exceptionPattern.matcher(e.getMessage());
          if(exceptionMatcher.find()) {
            releaseIds.add(exceptionMatcher.group(1));
          }
        }
      }
    }

    return releaseIds;
  }

  private ADM_Release__c getRelease(ADM_Perforce_Connector__c connector) {
    release.Name = connector.Release__c;
    release.External_ID__c = connector.Release__c.trim().replace('\\s','');

    return release;
  }

  public Map<String, ADM_Release__c> getReleaseMap(List<ADM_Release__c> releases) {
    Map<String, ADM_Release__c> releaseMap = new Map<String, ADM_Release__c>();

    for(ADM_Release__c release : releases) {
      releaseMap.put(release.Name, release);
    }

    return releaseMap;
  }

}