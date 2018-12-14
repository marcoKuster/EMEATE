({
    switchSidebar : function(component, event, helper) {
        var btnId = event.target.getAttribute("id");
        var btnGroupMembers = event.target.parentNode.childNodes;
        var btnGroupMembersLen = btnGroupMembers.length;
        var selectedBtnClass = 'sprint-button-selected';

        for(var i = 0; i < btnGroupMembersLen; i++) {
            btnGroupMembers[i].classList.remove(selectedBtnClass);
            btnGroupMembers[i].classList.remove('slds-is-selected');
        }

        var prevSidebar = component.get("v.sidebar");
        var currSidebar = (btnId != prevSidebar ? btnId : '');

        if (currSidebar) {
            event.target.classList.add(selectedBtnClass);
        }

        if (currSidebar === 'chatter' || prevSidebar === 'chatter') {
            var field = 'ShowChatteronVirtualWall__c';
            var fieldVal = event.target.classList.contains(selectedBtnClass);
            helper.updateUserPref(component, field, fieldVal);
        }

        var toggleSidebar = $A.get("e.c:ADM_Event_Toggle_Sidebar");
        toggleSidebar.setParams({"sidebar" : currSidebar});
        toggleSidebar.fire();

        component.set("v.sidebar", currSidebar);
    },

    handleSprintDataInitialized: function (component, event, helper) {
    	helper.handleUpdatedFilters(component);
	    helper.handleChatterSidebarInitialization(component);
    },

    handleUpdatedFilters: function (component, event, helper) {
        // setTimeout here so that we are working with the most up-to-date data
        window.setTimeout($A.getCallback(function() {
            helper.handleUpdatedFilters(component);
        }))

    }
})