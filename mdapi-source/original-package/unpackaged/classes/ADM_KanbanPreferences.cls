public with sharing class ADM_KanbanPreferences {
	private boolean laneScrolling;
    private List<ADM_Color__c> teamColors = new List<ADM_Color__c>();
    private boolean UseColorCoding;
	private boolean ShowNumberOfDaysInColumn =true;
	private boolean ShowNumberOfTasks = true;
	private boolean ShowNumberOfPosts = true;
	private boolean ShowPriority = true;
	private boolean ShowScheduledBuild = true;
	private boolean ShowStoryPoints = true;
	private boolean ShowColoredSubjects = false;
	private boolean ShowWorkID = true;
 	private boolean ShowRecordTypeIcon = true;
	private boolean ShowQE = false;

	public boolean getLaneScrolling(){
		return this.laneScrolling;
	}

	public void setLaneScrolling(boolean laneScrollingPreference){
		this.laneScrolling = laneScrollingPreference;
	}

	public boolean getUseColorCoding(){
		//no longer any reason to hide colors for any kanban board
        return true;
	}

	public void setUseColorCoding(boolean useColorCoding){
		//no longer any reason to hide colors for any kanban board
		System.debug('WARNING setUseColorCoding() choice will be ignored.  UseColorCoding now defaults to true for all Kanban Boards.');
        this.UseColorCoding = true;
	}


	public boolean getShowNumberOfDaysInColumn(){
		return this.ShowNumberOfDaysInColumn;
	}

	public void setShowNumberOfDaysInColumn(boolean showNumberOfDaysInColumn){
		this.ShowNumberOfDaysInColumn = showNumberOfDaysInColumn;
	}

	public boolean getShowNumberOfTasks(){
		return this.ShowNumberOfTasks;
	}

	public void setShowNumberOfTasks(boolean showNumberOfTasks){
		this.ShowNumberOfTasks = showNumberOfTasks;
	}

	public boolean getShowNumberOfPosts(){
		return this.ShowNumberOfPosts;
	}

	public void setShowNumberOfPosts(boolean showNumberOfPosts){
		this.ShowNumberOfPosts = showNumberOfPosts;
	}

	public boolean getShowPriority(){
		return this.ShowPriority;
	}

	public void setShowPriority(boolean showPriority){
		this.ShowPriority = showPriority;
	}

	public boolean getShowScheduledBuild(){
		return this.ShowScheduledBuild;
	}

	public void setShowScheduledBuild(boolean showScheduledBuild){
		this.ShowScheduledBuild = showScheduledBuild;
	}

	public boolean getShowStoryPoints(){
		return this.ShowStoryPoints;
	}

	public void setShowStoryPoints(boolean showStoryPoints){
		this.ShowStoryPoints = showStoryPoints;
	}

	public boolean getShowWorkID(){
		return this.ShowWorkID;
	}

	public void setShowWorkID(boolean showWorkID){
		this.ShowWorkID = showWorkID;
	}

	public boolean getShowColoredSubjects(){
		return this.ShowColoredSubjects;
	}

	public void setShowColoredSubjects(boolean showColoredSubjects){
		this.ShowColoredSubjects = showColoredSubjects;
	}

	public boolean getShowRecordTypeIcon(){
		return this.ShowRecordTypeIcon;
	}

	public void setShowRecordTypeIcon(boolean showRecordTypeIcon){
		this.ShowRecordTypeIcon = showRecordTypeIcon;
	}

	public boolean getShowQE(){
		return this.ShowQE;
	}

	public void setShowQE(boolean showQE){
		this.ShowQE = showQE;
	}
    
    public List<ADM_Color__c> getTeamColors(){
         return this.teamColors;
    }
}