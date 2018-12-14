({
	doInit : function(component, event, helper) {
		helper.getThemeAssignedWorkList(component);
	},
    workAction : function (component, event, helper) {
		var menuItem = event.detail.menuItem;
		var menuItemLabel = menuItem.get("v.label");
		var menuItemValue = menuItem.get("v.value");
		
        if (menuItemLabel === 'Edit work') {
			helper.openWorkEditModal(component, menuItemValue);
		} else if (menuItemLabel === 'Remove Theme') {
                helper.removeThemeWorkAssignment(component, menuItemValue, function(removedId) {
				document.querySelector('#' + removedId).remove();
			});
			
		} else {
			window.open('/' + menuItemValue,'_blank');
		}
	},
    openWorkModal : function (component, event, helper) {
		var workItemValue = event.getSource().get("v.value");
		helper.openWorkEditModal(component, workItemValue);
	},
    sortByName: function(component, event, helper){
        helper.sortBy(component, "Name");
    },
    sortByAssignee: function(component, event, helper){
        helper.sortBy(component, "Assignee__r.Name");
    },
    sortByPriority: function(component, event, helper){
        helper.sortBy(component, "Priority__c");
    },
    sortByBuild: function(component, event, helper){
        helper.sortBy(component, "Scheduled_Build_Name__c");
    },
    sortByTeam: function(component, event, helper){
        helper.sortBy(component, "Scrum_Team_Name__c");
    },
    sortByStatus: function(component, event, helper){
        helper.sortBy(component, "Status__c");
    },
    handleShowSpinner : function (component, event, helper) {
        var showSpinner = event.getParam("show");
		component.set('v.showSpinner', showSpinner);
    }
})