trigger ADM_ScrumteamMember on ADM_Scrum_Team_Member__c (before insert, before update, after delete, after insert, after update) {
    ADM_ScrumTeamMemberUtils stmu = new ADM_ScrumTeamMemberUtils();
    Set<Id> memberIds = new Set<Id>();
    Map<Id,RecordType> allRecordTypesById = new Map<Id,RecordType>(ADM_RecordType.getAll());
    Boolean hasPeopleMembers = false;
    if(Trigger.isBefore) {
                
        //validate user does not already have membership in this scrum team
        Map<Id, ADM_Scrum_Team__c> teamMap = ADM_ScrumTeamMemberUtils.getScrumTeams(ADM_ScrumTeamMemberUtils.scrumteamIdsFromScrumteamMembers(Trigger.new));
        
        for(ADM_Scrum_Team_Member__c newMember : Trigger.new) {
            if ( newMember.Record_Type_Copy__c != 'Internal' ) continue;
            ADM_Scrum_Team__c t = teamMap.get(newMember.Scrum_Team__c);
            //Integer count = 0;
            if(t != null) {
                //check if user already belongs to this team
                for(ADM_Scrum_Team_Member__c existingMember: t.Scrum_Team_Members__r) {
                    
                    if ( newMember.id != existingMember.id )
                        if( existingMember.Member_Name__c != null && existingMember.Member_Name__c == newMember.Member_Name__c ) {
                            newMember.addError('This user already has a membership record with this team.');
                        }
                    
                    /*if(existingMember.Allocation__c == 0 && existingMember.id != newMember.id){count++;}*/
                }
            }
            memberIds.add( newMember.Member_Name__c );
            /*if(newMember.Allocation__c == 0){//if the memeber being edited/added has zero allocation
                //Do the check if its the first team member or if all others have zero allocation.
                if(t.Scrum_Team_Members__r.size() == 0 || count == t.Scrum_Team_Members__r.size()-1){
                    newMember.addError('Cannot have zero allocation for all members of a team');
                }
            }*/
        }
        //get current allocations for members in trigger event
        Map<Id, ADM_AllocationWrapper> allocationMap = ADM_ScrumTeamMemberUtils.totalAllocationByMemberId(memberIds);
        
        for(ADM_Scrum_Team_Member__c newMember2 : Trigger.new) {
            if ( newMember2.Record_Type_Copy__c != 'Internal' ) continue;
            ADM_AllocationWrapper aw = allocationMap.get(newMember2.Member_Name__c);
            if(aw != null) {
                
                Map<Id, Double> allocationBreakDown = aw.getAllocationBreakDown();
                Double membersPreviousAllocation = allocationBreakDown.get(newMember2.id);
                if(membersPreviousAllocation == null) membersPreviousAllocation = 0.0;
                Double memberAllocation = (aw.allocation - membersPreviousAllocation)  + newMember2.Allocation__c;
                if(memberAllocation > 100) {
                    newMember2.addError('This person is overallocated at '+ memberAllocation +'%. The person\'s current allocations are: '+
                    aw.allocationDescription +'This person has ' + (100.0 - aw.allocation) + '% of their time currently unallocated. Please adjust this allocation or other team allocations and re-submit.');
                }
            }
        }
        
    }
    
    if(Trigger.isAfter) { 
        if(Trigger.isInsert) {
            stmu.createScrumteamCaches(Trigger.New, Trigger.isInsert, Trigger.isDelete);    
        } else if(Trigger.isDelete) {
            stmu.createScrumteamCaches(Trigger.Old, Trigger.isInsert, Trigger.isDelete);
        } else if(Trigger.isUpdate) {
            stmu.createScrumteamCaches(Trigger.New, Trigger.Old);
        }
    }    
    
}