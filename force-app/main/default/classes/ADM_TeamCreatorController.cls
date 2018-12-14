public with sharing class ADM_TeamCreatorController{
    public static final integer MAX_NUMBER_OF_MEMBERS = 5;
    
    public ADM_TeamCreatorController(ApexPages.StandardController controller) {
    	
    	teamMembers = new List<ADM_Scrum_Team_Member__c>();
    	for(Integer index = 0; index < MAX_NUMBER_OF_MEMBERS; index++) {
    		teamMembers.add(new ADM_Scrum_Team_Member__c());
    	}
    	
    }
    
    public ADM_Scrum_Team__c team {
        get;
        set;
    }
    
    public List<ADM_Scrum_Team_Member__c> teamMembers {
        get;
        set;
    }  
    
    public List<String> getUniqueMemberIDs() {
        List<String> ids = new List<String>();
        for(Integer i = 1; i <= MAX_NUMBER_OF_MEMBERS; i++) {
            ids.add(String.valueOf(i));   
        }    
        return ids;
    }
    
    public String getListViewLink() {
        Schema.DescribeSObjectResult teamDescribe = Schema.SObjectType.ADM_Scrum_Team__c;
        String objectPrefix = '/' + teamDescribe.getKeyPrefix();
        return objectPrefix;
    }
    
    @RemoteAction
    public static String insertTeamAndMembers(ADM_Scrum_Team__c team, List<ADM_Scrum_Team_Member__c> members, ADM_Product_Tag__c tag) {
        
        //team and team member insert must both succeed else roll everything back
        Savepoint sp = Database.setSavepoint();
        try {
           //TODO why does platform autopopulate blank names with the record ID - hence we must validate ourselves
           if(ADM_TextUtils.isBlank(team.Name)) throw new ADM_ApplicationException('Team name is required.');
           
           //intentionally validate this here vs trigger or validation rule to allow the trigger to still batch load teams without members
           if(members.size() < 2) throw new ADM_ApplicationException('At least two team members are required.'); 
           
           if(ADM_TextUtils.isBlank(tag.Name)) throw new ADM_ApplicationException('At least one Product Tag is required for this team to be able to be assigned Work records.');
            
            
           Id teamID = insertTeam(team);
           for(ADM_Scrum_Team_Member__c member : members) {
                member.Scrum_Team__c = team.id;     
           }
           insertTeamMembers(members);
           tag.Team__c = team.id; 
           insertTag(tag); 
           createAssignmentRuleAndAssignToTag(tag, members); 
            
           return team.id;
            
        } catch(Exception e) {
          Database.rollback(sp);
          throw e;  
        }    
    }
    
  
    public static Id insertTeam(ADM_Scrum_Team__c team) {
        insert team;
        return team.id;
    }

    
    public static void insertTeamMembers(List<ADM_Scrum_Team_Member__c> members) {
        insert members;
    }
    
     public Pagereference doCancel(){          
     Schema.Describesobjectresult result = Schema.Sobjecttype.ADM_Scrum_Team__c;
     return new PageReference('/' + result.getKeyPrefix() + '/o');
     
     }
    
    public static void insertTag(ADM_Product_Tag__c tag) {
        insert tag;
    }
    
    public static void createAssignmentRuleAndAssignToTag(ADM_Product_Tag__c tag, List<ADM_Scrum_Team_Member__c> members) {
        //Default first two members as Assignee and PO on rule. Safe to assume list size is two as that is the minimum team size
        Id assigneeID = members.get(0).Member_Name__c;
        Id productOwnerID = members.get(1).Member_Name__c;
        //now that defaults values are guarenteed inspect roles and if a role has been declared use the correct member
        for(ADM_Scrum_Team_Member__c member: members) {
            //populate assigneeID with first team member with Role of developer.  If multiple matches last matching member will be used 
            if(member.Role__c == 'Developer') {
                assigneeID = member.Member_Name__c;    
            } else if(member.Role__c == 'Product Owner') {
                productOwnerID = member.Member_Name__c;
            }    
        }    
        
        //create Assignment Rule
        ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
        rule.Scrum_Team_Assignment__c = tag.Team__c;
        rule.Assignee_Assignment__c = assigneeID;
        rule.Product_Owner__c = productOwnerID;
        insert rule;
        //create Tag Assignment relating the team to the rule
        ADM_Tag_Assignment__c taBug = new ADM_Tag_Assignment__c();
        taBug.Record_Type__c = 'Bug';
        taBug.Product_Tag__c = tag.id;
        taBug.Assignment_Rule__c = rule.id;
        
        ADM_Tag_Assignment__c taStory = new ADM_Tag_Assignment__c();
        
        taStory.Record_Type__c = 'User Story';
        taStory.Product_Tag__c = tag.id;
        taStory.Assignment_Rule__c = rule.id;
        
        List<ADM_Tag_Assignment__c> taList = new List<ADM_Tag_Assignment__c>{taBug, taStory};
        //insert tag assignments relating rules to tags
        insert taList;    
    }
}