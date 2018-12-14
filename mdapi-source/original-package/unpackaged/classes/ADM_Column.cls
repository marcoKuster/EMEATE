public with sharing class ADM_Column Implements Comparable{
	@AuraEnabled
    public final ADM_Column__c column;
	@AuraEnabled
    public String columnName;
	@AuraEnabled
    public List<ADM_Column> children;
    @AuraEnabled
	public String parentId;
    @AuraEnabled
	public String parentName;
    @AuraEnabled
	public List<ColumnWorkItem> workItems = new List<ColumnWorkItem>();
	private Map<Id, String> columnWorkStatusMap = new  Map<Id, String>();
	List<Id> orderedWorkStatusIds = new List<Id>();
	private boolean isClosedLike = false;

	public ADM_Column(ADM_Column__c column) {
		this.column = column;
		this.columnName = column.Name;
		this.parentId = column.Parent_Column__c;
		if(null != column.Parent_Column__r){
			this.parentName = column.Parent_Column__r.Name;
		}
	}

	
    public String getColumnName(){
		return this.columnName;
	}

	
    public List<ADM_Column> getChildren(){
		return this.children;
	}

	public void setChildren(List<ADM_Column> children){
		this.children = children;
	}

   	
	public ADM_Column__c getColumnSObject(){
		return this.column;
	}
    
    
    public ADM_Column__c getColumn(){
		return this.column;
	}

	public String getParentId(){
		return this.parentId;
	}

	public String getParentName(){
		return this.parentName;
	}

    
	public List<ColumnWorkItem> getWorkItems(){
		return this.workItems;
	}

    
	public Map<Id, String> getMappedWorkStatuses(){
		return columnWorkStatusMap;
	}

	public List<Id> getOrderedWorkStatusIds(){
		return orderedWorkStatusIds;
	}

	public boolean getClosedLike(){
		return this.isClosedLike;
	}

	public void setClosedLike(boolean isClosedLike){
		this.isClosedLike = isClosedLike;
	}

	//Can only be used for Children of same parents
	public Integer compareTo(Object compareTo){
		ADM_Column__c 	compareToColumn =  ((ADM_Column)compareTo).getColumnSObject();

		Integer returnValue = 0;

		if(!ADM_TextUtils.areIdsEqual(this.column.Parent_Column__c,compareToColumn.Parent_Column__c)){
			String msg = 'Cannot compare Columns of different parents';
			ADM_ObjectNotComparableException once = new ADM_ObjectNotComparableException(msg);
			once.message = msg;
			throw once;
		}
		else{
			if(this.column.Level__c < compareToColumn.Level__c){
				returnValue = -1;
			}
			else if(this.column.Level__c > compareToColumn.Level__c){
				returnValue = 1;
			}
			else{
				if(this.column.Position__c < compareToColumn.Position__c){
					returnValue = -1;
				}
				else if(this.column.Position__c > compareToColumn.Position__c){
					returnValue = 1;
				}
				else{
					returnValue = 0;
				}
			}
		}

		return returnValue;
	}

	public class ColumnWorkItem{
		@AuraEnabled
        public String workId {get; set;}
		@AuraEnabled
        public String workTitle  {get; set;}
		@AuraEnabled
        public String subject {get; set;}
		@AuraEnabled
        public Integer columnRank {get; set;}
		@AuraEnabled
        public String recordType {get; set;}
		@AuraEnabled
        public String assigneeId {get; set;}
		@AuraEnabled
		public String assigneeFirstName {get; set;}
		@AuraEnabled
		public String assigneeFullName {get; set;}
		@AuraEnabled
        public String assigneePicUrl {get; set;}
		@AuraEnabled
		public String qeFirstName {get; set;}
		@AuraEnabled
		public String qeFullName {get; set;}
		@AuraEnabled
        public String qeId {get; set;}
        @AuraEnabled
		public String qePicUrl {get; set;}
		@AuraEnabled
		public String storyPoints {get; set;}
		@AuraEnabled
		public Integer numberOfPosts {get; set;}
		@AuraEnabled
        public boolean isUserSubscribed {get; set;}
		@AuraEnabled
        public boolean needsColumnUpdate {get; set;}
        @AuraEnabled
        public String scheduledBuild;
		@AuraEnabled
        public String scheduledBuildId;
		@AuraEnabled
        public String priority;
		@AuraEnabled
        public Map<String, Map<String, String>> columnIdToTimeSpent;
		@AuraEnabled
        public Map<String, String> themeIdToNameMap;
		@AuraEnabled
        public String epicId;
		@AuraEnabled
        public String epicName;
        @AuraEnabled
        public String colorId;
        @AuraEnabled
		public String color;
		@AuraEnabled
		public Integer numberOfTasks;
		@AuraEnabled
		public String scrumTeamId;
		@AuraEnabled
		public String productTagId;
		@AuraEnabled
		public String productTag;


	}
	

	
}