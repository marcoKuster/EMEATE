public with sharing class ADM_ScrumTeamMemberUtils {
    private List<String> getSuccesses(List<ADM_Scrum_Team_Cache__c> caches) {       
        List<String> cacheIds = new List<String>(); 
        Database.Saveresult[] results = Database.insert(caches,false);
        
        for(Database.Saveresult result : results) {
            if(result.isSuccess()) {
                cacheIds.add(result.getId()); 
            } else {
                System.debug('an error occurred: ' + result.getErrors());               
            }
        }
        
        return cacheIds;
    }
    
    public void createScrumteamCaches(ADM_Scrum_Team_Member__c[] members, Boolean isInsert, Boolean isDelete) {
        List<ADM_Scrum_Team_Cache__c> caches = ADM_ScrumteamCacheUtils.getTeamMemberCaches(members, isInsert, isDelete);
        List<String> cacheIds = new List<String>(); 
        
        Database.Saveresult[] results = Database.insert(caches,false);
        
        for(Database.Saveresult result : results) {
            if(result.isSuccess()) {
                cacheIds.add(result.getId()); 
            } else {
                System.debug('an error occurred: ' + result.getErrors());               
            }
        }
        
        //don't create public group membership for Agile Accelerator package
        if(!ADM_ConstantsSingleton.getInstance().isPackagedOrg() || Test.isRunningTest()) {
            if(!cacheIds.isEmpty()) {
                if(isInsert) {
                    asynchronouslyCreateGroupMembers(cacheIds);
                } else if(isDelete) {
                    asynchronouslyDeleteGroupMembers(cacheIds);
                }
            }
        }    
    }
    
    public void createScrumteamCaches(ADM_Scrum_Team_Member__c[] members2add, ADM_Scrum_Team_Member__c[] members2remove) {
        List<ADM_Scrum_Team_Cache__c> caches = new List<ADM_Scrum_Team_Cache__c>();
        caches.addAll(ADM_ScrumteamCacheUtils.getTeamMemberCaches(members2add, true, false));
        caches.addAll(ADM_ScrumteamCacheUtils.getTeamMemberCaches(members2remove, false, true));
        List<String> cacheIds = new List<String>(); 
        
        Database.Saveresult[] results = Database.insert(caches,false);
        
        for(Database.Saveresult result : results) {
            if(result.isSuccess()) {
                cacheIds.add(result.getId()); 
            } else {
                System.debug('an error occurred: ' + result.getErrors());               
            }
        }
        
        if(!cacheIds.isEmpty()) {
            asynchronouslyHandleGroupMembers(cacheIds);
        }
    }  
    
    @Future
    private static void asynchronouslyHandleGroupMembers(List<String> cacheIds) {
        List<GroupMember> groupMembers = new List<GroupMember>();
        
        Map<Id,ADM_Scrum_Team_Cache__c> caches = new Map<Id,ADM_Scrum_Team_Cache__c>([select Group_ID__c, Name__c, Deleted__c, Inserted__c, Type__c, ScrumteamOrScrumteamMember__c from ADM_Scrum_Team_Cache__c where Id in : cacheIds]);
        
        List<String> memberIdsFromCaches = ADM_ScrumteamCacheUtils.idsFromScrumTeamField(caches.values());
        
        Map<Id,ADM_Scrum_Team_Member__c> members = new Map<Id,ADM_Scrum_Team_Member__c>([select Id, Name, Scrum_Team__c from ADM_Scrum_Team_Member__c where Id in : memberIdsFromCaches]);
        
        List<String> scrumteamIds = scrumteamIdsFromScrumteamMembers(members.values());
        
        Map<Id,ADM_Scrum_Team__c> scrumteams = new Map<Id,ADM_Scrum_Team__c>([select Id, Name, Team_Email_Group_ID__c from ADM_Scrum_Team__c where Id in : scrumteamIds]);
        
        List<ADM_Scrum_Team_Cache__c> caches2Delete = new List<ADM_Scrum_Team_Cache__c>();
        List<ADM_Scrum_Team_Cache__c> caches2Add = new List<ADM_Scrum_Team_Cache__c>();
        
        if(!caches.isEmpty()) {
            for(ADM_Scrum_Team_Cache__c cache : caches.values()) {
                    if(cache.Deleted__c) {
                        caches2Delete.add(cache);
                    } else if(cache.Inserted__c) {
                        caches2Add.add(cache);
                    }
            }
            //#1). Take care of the deletes first            
            for(ADM_Scrum_Team_Cache__c cache2Delete : caches2Delete) {
                for(GroupMember[] m_members : [Select g.Id From GroupMember g where g.GroupId =: cache2Delete.Group_ID__c and UserOrGroupId =: cache2Delete.Name__c]) {
                    groupMembers.addAll(m_members);                 
                }
            }
            
            if(!groupMembers.isEmpty()) {
                Database.Deleteresult[] results = Database.delete(groupMembers,false);
                
                for(Database.Deleteresult result : results) {
                    if(!result.isSuccess()) {
                        System.debug('Error occurred deleting group: ' + result.getErrors());
                    }
                }   
            }
            
            groupMembers = new List<GroupMember>();
            
            //#2). Take care of the adds now
            for(ADM_Scrum_Team_Cache__c cacheAdd : caches2Add) {
                try {
                    ADM_Scrum_Team_Member__c member = members.get(cacheAdd.ScrumteamOrScrumteamMember__c);
                    ADM_Scrum_Team__c team = scrumteams.get(member.Scrum_Team__c);          
                    groupMembers.add(new GroupMember(GroupId = team.Team_Email_Group_ID__c, UserOrGroupId = cacheAdd.Name__c));
                } catch(System.Exception e) {
                   System.debug('An error occurred getting the members and or teams!' + e); 
                }   
            }
            
            if(!groupMembers.isEmpty()) {
                Database.Saveresult[] results = Database.insert(groupMembers,false);
                
                for(Database.Saveresult result : results) {
                    if(!result.isSuccess()) {
                        System.debug('Error occurred inserted a group: ' + result.getErrors());
                    }
                }   
            }            
        }
    }
    
    @Future
    private static void asynchronouslyDeleteGroupMembers(List<String> cacheIds) {
        List<GroupMember> groupMembers = new List<GroupMember>();
        
        for(ADM_Scrum_Team_Cache__c cache : [select Group_ID__c, Name__c, Type__c, ScrumteamOrScrumteamMember__c from ADM_Scrum_Team_Cache__c where Id in : cacheIds]) {
            for(GroupMember[] members : [Select g.Id From GroupMember g where g.GroupId =: cache.Group_ID__c and UserOrGroupId =: cache.Name__c]) {
                Database.Deleteresult[] results = Database.delete(members,false);
                
                for(Database.Deleteresult result : results) {
                    if(!result.isSuccess()) {
                        System.debug('Error occurred deleting group: ' + result.getErrors());
                    }
                }
            }
        }
    }  
    
    public static List<String> scrumteamIdsFromScrumteamMembers(List<ADM_Scrum_Team_Member__c> members) {
        List<String> ids = new List<String>();
        if(!members.isEmpty()) {
            for(ADM_Scrum_Team_Member__c member : members) {
                ids.add(member.Scrum_Team__c);
            }
        }
        
        return ids;
    } 
    
    public List<String> getScrumTeamIds() {
        List<ADM_Scrum_Team_Member__c> membership = [select id, Scrum_Team__c, Member_Name__c from ADM_Scrum_Team_Member__c where Member_Name__c =:UserInfo.getUserId() and Scrum_Team__c != null and Scrum_Team__r.Active__c = true order by Allocation__c DESC];
        List<String> teamIds = new List<String>();
        if(membership != null) {
            for(ADM_Scrum_Team_Member__c member: membership){
              teamIds.add(member.Scrum_Team__c);
            }
        }

        return teamIds;
    }
    
    @Future
    private static void asynchronouslyCreateGroupMembers(List<String> cacheIds) {
        try{
            List<GroupMember> groupMembers = new List<GroupMember>();
            Map<Id,ADM_Scrum_Team_Cache__c> caches = new Map<Id,ADM_Scrum_Team_Cache__c>([select Name__c, Type__c, ScrumteamOrScrumteamMember__c from ADM_Scrum_Team_Cache__c where Id in : cacheIds]);
            List<String> memberIdsFromCaches = ADM_ScrumteamCacheUtils.idsFromScrumTeamField(caches.values());
            Map<Id,ADM_Scrum_Team_Member__c> members = new Map<Id,ADM_Scrum_Team_Member__c>([select Id, Name, Scrum_Team__c from ADM_Scrum_Team_Member__c where Id in : memberIdsFromCaches]);
            List<String> scrumteamIds = scrumteamIdsFromScrumteamMembers(members.values());
            Map<Id,ADM_Scrum_Team__c> scrumteams = new Map<Id,ADM_Scrum_Team__c>([select Id, Name, Team_Email_Group_ID__c from ADM_Scrum_Team__c where Id in : scrumteamIds]);
            
            if(!caches.isEmpty()) {
                for(ADM_Scrum_Team_Cache__c cache : caches.values()) {
                    try {
                        ADM_Scrum_Team_Member__c member = members.get(cache.ScrumteamOrScrumteamMember__c);
                        ADM_Scrum_Team__c team = scrumteams.get(member.Scrum_Team__c);          
                        groupMembers.add(new GroupMember(GroupId = team.Team_Email_Group_ID__c, UserOrGroupId = cache.Name__c));
                    } catch(System.Exception e) {
                       System.debug('An error occurred getting the members and or teams!' + e); 
                    }
                }
                
                Database.Saveresult[] results = Database.insert(groupMembers,false);
                
                for(Database.Saveresult result : results) {
                    if(!result.isSuccess()) {
                        System.debug('Error occurred inserted a group: ' + result.getErrors());
                    }
                }
            }
        }
        catch(Exception exp){
            ADM_ExceptionHandler.saveException(exp, 'Error occurred while inserting group member by Future method');
        }
    }
    
    public static ADM_Scrum_Team_Member__c createScrumteamMember(String ScrumteamId, User user) {
        ADM_Scrum_Team_Member__c member = new ADM_Scrum_Team_Member__c(Member_Name__c = user.Id, Scrum_Team__c = ScrumteamId, Allocation__c = 10);
        insert member;
        return member;
    }
    
    public static Map<Id, ADM_Scrum_Team__c> getScrumTeams(List<String> ids) {
        Map<Id,ADM_Scrum_Team__c> teams = new Map<Id,ADM_Scrum_Team__c>([select Name, (select Member_Name__c, Allocation__c from Scrum_Team_members__r) from ADM_Scrum_Team__c where Id in : ids]);
        return teams;
    }
    
    public static Map<Id, ADM_AllocationWrapper> totalAllocationByMemberId(Set<Id> ids) {
        //max allocation percentage is only enfored for Internal members
        List<ADM_Scrum_Team_Member__c> members = [select id, Member_Name__c, Allocation__c, Scrum_Team__r.Name from ADM_Scrum_Team_Member__c where Record_Type_Copy__c =:'Internal' and Scrum_Team__r.Active__c = true and Member_Name__c in : ids];
        Map<Id, ADM_AllocationWrapper> allocationMap = new Map<Id, ADM_AllocationWrapper>();
        String description = '';
        for(ADM_Scrum_Team_Member__c m : members) {
            if(m != null) {
                if(m.Allocation__c == null) m.Allocation__c = 0.0;
                description += m.Scrum_Team__r.Name + ': ' + m.Allocation__c + '%, '; 
                if(allocationMap.containsKey(m.Member_Name__c)) { 
                    ADM_AllocationWrapper aw = allocationMap.get(m.Member_Name__c);
                    aw.getAllocationBreakDown().put(m.id, m.Allocation__c);
                    aw.allocationDescription = description;
                    aw.allocation += m.Allocation__c;
                    //re-insert
                    allocationMap.put(m.Member_Name__c, aw);
                } else {
                    allocationMap.put(m.Member_Name__c, new ADM_AllocationWrapper(m.Allocation__c, description, m.id));
                }
            }
        }
        return allocationMap;
    }
    
    /**
     * Determine if the specified user Id is a member within the given list of team members.
     */
    public static Boolean containsUser(List<ADM_Scrum_Team_Member__c> teamMembers, Id userId) {
        for(ADM_Scrum_Team_Member__c teamMember : teamMembers) {
            if(teamMember.Member_Name__c == userId) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Returns a list of all the team members that are in the scrum master role
     */
    public static List<ADM_Scrum_Team_Member__c> getScrumMasters(List<ADM_Scrum_Team_Member__c> teamMembers) {
        List<ADM_Scrum_Team_Member__c> scrumMasters = new List<ADM_Scrum_Team_Member__c>();
        for(ADM_Scrum_Team_Member__c teamMember : teamMembers) {
            if(teamMember.Role__c == 'Scrum Master') {
                scrumMasters.add(teamMember);
            }
        }
        return scrumMasters;
    }
}