/*
	All instances of the same class share a single copy of the static variables. For example, all 
	triggers that are spawned by the same request can communicate with each other by viewing and updating 
	static variables in a related class.
	More here: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_static.htm.

	   
*/

public with sharing class ADM_WorkTriggerStaticDataStore {
	
	public static final String EDIT_PAGE_ORIGIN = 'ADM_WorkControllerExtension';
	public static final String NEXT_GEN_EDIT_PAGE_ORIGIN = 'ADM_WorkCommonExtension';
	public static final String NON_EDIT_PAGE_ORIGIN = 'API/ListView';
    
    public static final String KANBAN_BOARD_ORIGIN = 'ADM_KanbanBoardController';
    
    public static final String LIGHTNING_EXPERIENCE_WORK_ORIGIN = 'ADM_WorkSds';

    public static final String BACKLOG_MANAGER_ORIGIN = 'ADM_BacklogController';
	
	public static String requestOrigin;
}