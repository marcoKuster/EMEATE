public class ADM_AllocationWrapper {
    	
    	public Double allocation;
    	public String allocationDescription;
    	Map<Id, Double> allocationBreakDownByScrumTeamMemberID;
    	
    	public ADM_AllocationWrapper(Double newAllocation, String newAllocationDescription, Id scrumTeamMemberID) {
    		allocation = newAllocation;
    		allocationDescription = newAllocationDescription;
    		allocationBreakDownByScrumTeamMemberID = new Map<Id, Double>();
    		allocationBreakDownByScrumTeamMemberID.put(scrumTeamMemberID, newAllocation);
    	}
    	
    	public Map<Id,Double> getAllocationBreakDown() {
    		return allocationBreakDownByScrumTeamMemberID;
    	}
    	
    	public void setAllocationBreakDown(Map<Id, Double> newAllocationMap) {
    		this.allocationBreakDownByScrumTeamMemberID = newAllocationMap;
    	}
}