public class ADM_ScrumTeam {
	
	public static final String TEST_SCRUM_TEAM = 'GUS Test Suite Team Name';
		public static final String TEST_PROGRAM_NAME = 'GUS Test Suite Program';
	public static final String RECORD_TYPE_NAME_PROGRAM = 'Program Team';
	public static final String RECORD_TYPE_NAME_SCRUM_TEAM = 'Scrum Team';
	
	public static ADM_Scrum_Team__c[] get(String columnName, Set<String> columnValues) {
		return get(columnName, new List<String>(columnValues));	
	}
	
	public static ADM_Scrum_Team__c[] get(String columnName, List<String> columnValues) {

		ADM_Scrum_Team__c[] scrumTeams = new ADM_Scrum_Team__c[]{};
		
		try{
			
			if(columnName.equalsIgnoreCase('Name')) {
				
				scrumTeams = [ 
					Select a.SystemModstamp, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedById From ADM_Scrum_Team__c a
					Where Name in :columnValues ];				 	
			}
			
			else if(columnName.equalsIgnoreCase('Id')) {
				
				scrumTeams = [ 
					Select a.SystemModstamp, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedById From ADM_Scrum_Team__c a
					Where Id in :columnValues ];				 	
			}
			
			return scrumTeams;			
		}
		
		catch(System.Exception e) {
			
			return scrumTeams;
		}		
	}
	
	public static ADM_Scrum_Team__c createTestScrumTeam() {
		return createTestScrumTeam(TEST_SCRUM_TEAM);
	}
	
	public static ADM_Scrum_Team__c createTestScrumTeam(String name) {
            ADM_Scrum_Team__c team = setupTestScrumTeam(name);
            Database.insert(team);
            team = [select SystemModstamp, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, External_ID__c, CreatedDate, CreatedById, Active__c, Capex_Enabled__c From ADM_Scrum_Team__c where Id = :team.Id];
            return team;
    }

    public static ADM_Scrum_Team__c createTestCapexEnabledScrumTeam(String name) {
            ADM_Scrum_Team__c team = setupTestScrumTeam(name);
            team.Capex_Enabled__c = true;
            Database.insert(team);
            team = [select SystemModstamp, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, External_ID__c, CreatedDate, CreatedById, Active__c, Capex_Enabled__c From ADM_Scrum_Team__c where Id = :team.Id];
            return team;
    }

    public static ADM_Scrum_Team__c createTestScrumTeamAndCloud(String name) {
                        ADM_Scrum_Team__c team = setupTestScrumTeamAndCloud(name);
                        Database.insert(team);
                        team = [select SystemModstamp, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, External_ID__c, CreatedDate, CreatedById, Active__c, Capex_Enabled__c From ADM_Scrum_Team__c where Id = :team.Id];
            return team;
	}
	
    public static ADM_Scrum_Team__c setupTestScrumTeam(String name) {
            ADM_Scrum_Team__c team = new ADM_Scrum_Team__c();
            team.Name = name;
            team.Cloud__c = 'Chatter';

        	team.Team_Home_Page__c = 'salesforce.com';
            team.recordtypeid = [select id from RecordType where name =:RECORD_TYPE_NAME_SCRUM_TEAM].id; 
            team.Active__c = true;

            return team;
	}
    
    public static ADM_Scrum_Team__c setupTestScrumTeamAndCloud(String name) {
                    ADM_Parent_Cloud__c parentCloud = new ADM_Parent_Cloud__c(Name=name);
                    insert parentCloud;

              ADM_Cloud__c newCloud = new ADM_Cloud__c(Name=name);
                     newCloud.Parent_Cloud__c = parentCloud.Id;
                    insert newCloud;

                    ADM_Scrum_Team__c team = new ADM_Scrum_Team__c();
                    team.Name = name;
                    team.Cloud_LU__c = newCloud.Id;

                team.Team_Home_Page__c = 'salesforce.com';
                    team.recordtypeid = [select id from RecordType where name =:RECORD_TYPE_NAME_SCRUM_TEAM].id;
                    team.Active__c = true;
                    return team;
   }
    public static ADM_Scrum_Team_Member__c setupTestScrumTeamMember(Id userId,Id teamId) {
        ADM_Scrum_Team_Member__c teamMember = new ADM_Scrum_Team_Member__c();
        teamMember.member_name__c = userId;
        teamMember.scrum_team__c = teamId;
        return teamMember;
        
    }
    
	/**
	 * Creates and inserts a team with a random name.
	 */
	@IsTest
	public static ADM_Scrum_Team__c createAndInsertScrumTeamWithRandomName() {
		return ADM_ScrumTeam.createTestScrumTeam(TEST_SCRUM_TEAM + String.valueOf(Math.random() * 100000).mid(0, 5));
	}
    @IsTest
    public static ADM_Scrum_Team__c createAndInsertScrumTeamAndCloudWithRandomName() {
        return ADM_ScrumTeam.createTestScrumTeamAndCloud(TEST_SCRUM_TEAM + String.valueOf(Math.random() * 100000).mid(0, 5));
    }
	
	@IsTest
	public static ADM_Scrum_Team__c createTestProgram() {
		ADM_Scrum_Team__c prog = new ADM_Scrum_Team__c();
		prog.Cloud__c = 'Chatter';
		prog.recordtypeid = [select id from RecordType where name =:RECORD_TYPE_NAME_PROGRAM].id;
		prog.name = TEST_PROGRAM_NAME;
		Database.insert( prog );
		return prog;
	}
	
    private static final String FIELD_NAMES = 'a.SystemModstamp, a.Story_Point_Scale__c, a.Scrum_Meeting_Time_Location__c, a.Product_Area__c, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedById, a.Active__c, a.Capex_Enabled__c';
	private static final String RELATED_FIELD_NAMES = '';			 
	//FIELD_NAMES = FIELD_NAMES + ', ' + RELATED_FIELD_NAMES;			 
	    
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_FROM = 'from ADM_Scrum_Team__c a';
    
    public static ADM_Scrum_Team__c[] getAll(String id) {
    	String sql = SQL_SELECT + SQL_FROM + ' where id = :id order by a.CreatedDate desc';
        ADM_Scrum_Team__c[] els = Database.query(sql);
        return els;   
    }

    public static List<String> getStoryPointScaleByTeamId(String id){
        String sql = 'select Story_Point_Scale__c, id from adm_scrum_team__c where id = :id order by CreatedDate desc';
        ADM_Scrum_Team__c[] els = Database.query(sql);
        List<String> storyPoints = new List<String>();
        if(els != null && els.size() >0 &&  els[0].Story_Point_Scale__c != null ){
            storyPoints = els[0].Story_Point_Scale__c.split(',');
        }
        else{
            storyPoints.add('0');
            storyPoints.add('1');
            storyPoints.add('2');
            storyPoints.add('3');
            storyPoints.add('5');
            storyPoints.add('8');
            storyPoints.add('13');
            storyPoints.add('21');
        }
        return storyPoints;
    }
    
    public static ADM_Scrum_Team__c[] getAllBy(String columnName, List<String> columnValues, Integer rowStart, Integer rowEnd, String sortBy, String sortOrder) {
        ADM_Scrum_Team__c[] els = new ADM_Scrum_Team__c[0];
        String inValues = '';
        Integer inValuesCounter = 0;
        Integer i = 0;
        
        String sql;
        
        try{
        	String inColumnValues = COM_SoqlUtils.createInClause(columnName, columnValues);
        	
        	sql = SQL_SELECT + SQL_FROM + ' where ' + inColumnValues + ' order by ' + COM_SoqlUtils.createOrder(sortBy, sortOrder);
        	
        	
            for(ADM_Scrum_Team__c el : Database.query(sql)) {                        	 
                i++;
                if(i>= rowStart && i <= rowEnd) {
                    els.add(el);
                }
            }
        }
        
        catch(System.Exception e) { }
        return els;
    }   
    
    public static ADM_Scrum_Team__c match(ADM_Scrum_Team__c[] els, String id) {
        ADM_Scrum_Team__c emptyEl = new ADM_Scrum_Team__c();
        
        for(ADM_Scrum_Team__c b : els) {
        
            if(b.Id == id) {
                
                return b;
            }   
        }
        
        //return an emptyEl cuz no one was found
        return emptyEl;
    }
    
    public static Map<String, String> findUsedTeamNames(Set<String> namesToValidate ){
        Map<String, String> usedTeamNameIdMap = new Map<String, String>();
        for(ADM_Team_Name_History__c teamName : [Select Name, Team__c, Team__r.Name from ADM_Team_Name_History__c where name in :namesToValidate]){
           	usedTeamNameIdMap.put(teamName.Name.toLowerCase(), teamName.Team__r.Name);

        }
        return usedTeamNameIdMap;
    }



    public static void recordTeamNameChange(Map<String, String> teamOldNameIdMap ){
        List<ADM_Team_Name_History__c> teamNameHistories = new List<ADM_Team_Name_History__c>();
        for(String teamNameBefore : teamOldNameIdMap.keySet()){
            ADM_Team_Name_History__c teamNameHistory = new ADM_Team_Name_History__c();
            teamNameHistory.Name = teamNameBefore;
            teamNameHistory.Team__c = teamOldNameIdMap.get(teamNameBefore);
            teamNameHistories.add(teamNameHistory);

        }
        Database.insert(teamNameHistories, false);
    }

    
    
    public static ADM_Scrum_Team__c get(String columnName, String columnValue, String sortBy, String sortOrder) {
        ADM_Scrum_Team__c el = new ADM_Scrum_Team__c();
        ADM_Scrum_Team__c[] els;
        List<String> columnValues = new List<String>();
        Integer rowStart = 1;
        Integer rowEnd = 199;
        
        columnValues.add(columnValue);        
        els = getAllBy(columnName, columnValues, rowStart, rowEnd, sortBy, sortOrder);
        el = ADM_ScrumTeam.match(els, columnValue);
        
        return el;
    }
    
    public static ADM_Scrum_Team__c get(String key, String value) {
    	return get(key, value, 'Name', 'ASC');
    }
    
    public static List<ADM_Scrum_Team_Member__c> getUsersByRoleOrderedByAllocation(Id team, String role) {
    	List<ADM_Scrum_Team_Member__c> users = new List<ADM_Scrum_Team_Member__c>();
    	for(ADM_Scrum_Team_Member__c member : [select Member_Name__c, Member_Name__r.Email from ADM_Scrum_Team_Member__c where Scrum_Team__c = :team and Role__c =:role order by Allocation__c DESC]) {
    		users.add(member);
    	}
    	return users;
    }		    
}