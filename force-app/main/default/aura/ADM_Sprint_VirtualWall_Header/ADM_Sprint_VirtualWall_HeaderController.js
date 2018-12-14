({
    menuNavigation : function (component, event, helper) {
        var menuItem = event.detail.menuItem;
        var menuItemLabel = menuItem.get("v.label");
        var menuItemVal = (menuItemLabel === 'All Sprints' ? menuItem.get("v.value").substring(0, 4) : menuItem.get("v.value"));

        if (menuItemLabel === 'Sprint Detail') {
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
            	"recordId": component.get("v.sprintData").sprintInfo.Id
            });
            editRecordEvent.fire();
        } else if (menuItemLabel === 'Previous Sprint' || menuItemLabel === 'Next Sprint') {
            /*
            var objEvent = $A.get("e.force:navigateToSObject");
            objEvent.setParams({
              "recordId": menuItemVal
            });
            objEvent.fire();
            */
        	//Need to use window.location to avoid multiple sub tabs in Lightning Console
        	window.location = '/' + menuItemVal; //'#/sObject/'+menuItemVal+'/view';
        } else if (menuItemLabel === 'All Sprints') {
        	helper.goToSprintListView(component);
        } else {
            var navigateEvt = $A.get("e.force:navigateToURL");
            navigateEvt.setParams({
              "url": menuItemVal
            });
            navigateEvt.fire();
        }
    },

    createWork : function (component, event, helper) {
        var sprintData = component.get("v.sprintData");
        /*
        //We should use e.force:createRecord in 210 once the Product tags functionality is fixed in core
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "ADM_Work__c",
            "defaultFieldValues": {
                'Sprint__c' : sprintData.sprintInfo.Id
            }
            "recordTypeId": sprintData.sprintInfo.Id
        });
        createRecordEvent.fire();
        */

        var action = component.get("c.getWorkCreateEditPage");

        action.setParams({recordType : event.getSource().get("v.value")});

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var createPageUrl = response.getReturnValue() + '&retUrl=/' + sprintData.sprintInfo.Id + '&Sprint__c=' + sprintData.sprintInfo.Id;

                var navigateEvt = $A.get("e.force:navigateToURL");
                navigateEvt.setParams({
                    "url": createPageUrl
                });
                navigateEvt.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    } else {
                        console.log("Error: " + JSON.stringify(errors));
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    handleClick : function(component, event, helper) {
        var btnId = event.target.getAttribute("id");
        var btnGroup = event.target.parentNode.id;
        var btnGroupMembers = event.target.parentNode.childNodes;
        var btnGroupMembersLen = btnGroupMembers.length;
        var sprintData = component.get("v.sprintData");
        var selectedBtnClass = 'sprint-button-selected';

        for(var i = 0; i < btnGroupMembersLen; i++) {
            btnGroupMembers[i].classList.remove(selectedBtnClass);
            btnGroupMembers[i].classList.remove('slds-is-selected');
        }

        if (btnGroup === 'toggleTaskGroup') {
            event.target.classList.add(selectedBtnClass);

            var toggleTasks = $A.get("e.c:ADM_Toggle_TaskView");
            toggleTasks.setParams({"state" : (btnId === 'expanded' ? 'show' : 'hide')});
            toggleTasks.fire();

            var field = 'ShowBacklogviewonVirtualWall__c';
            var fieldVal = (btnId === 'expanded' ? false : true);

            helper.updateUserPref(component, field, fieldVal);
        }

        if (btnGroup === 'sidebarGroup') {
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
        }
    },

    toggleNewWorkDropDown : function (component, event, helper) {
        var ddContainer = event.target.parentNode;

        if (ddContainer.classList.contains('slds-is-open')) {
            ddContainer.classList.remove('slds-is-open');
        } else {
            ddContainer.classList.add('slds-is-open');
            event.target.focus();
        }
    },

    hideNewWorkDropDown : function (component, event, helper) {
        setTimeout($A.getCallback(function() {
            var ddContainer = event.target.parentNode;

            ddContainer.classList.remove('slds-is-open');
        }), 200);
    },

    handleShowSpinner : function (component, event, helper) {
        var showSpinner = event.getParam("show");

        component.set('v.showSpinner', showSpinner);

        var sprintData = component.get('v.sprintData');
        if (sprintData && !showSpinner) {
            helper.refreshUsersAndNumVisibleWork(component, helper);
        }
    },

    handleUpdatePlannedVelocity: function (component, event, helper) {
        component.set('v.plannedVelocity', event.getParam('velocity'));
    },

    handleUpdateActualVelocity: function (component, event, helper) {
    	component.set('v.actualVelocity', event.getParam('velocity'));
    },

    handleUpdatedFilters: function (component, event, helper) {
        // setTimeout here so that we are working with the most up-to-date data
        window.setTimeout($A.getCallback(function() {
            helper.updateNumVisibleWork(component, event, helper);
            helper.updateFilterString(component, event, helper);
        }))

    },

    handleSprintDataInitialized: function (component, event, helper) {
    	var sprintData = component.get("v.sprintData");
    	
    	if (sprintData) {
	    	helper.updateNumVisibleWork(component, event, helper);
	        helper.updateFilterString(component, event, helper);
            helper.getSprintWorkCommitment(component);
	        helper.handleChatterSidebarInitialization(component);
	
	        component.set('v.actualVelocity', sprintData.sprintInfo.Completed_Story_Points__c || 0);
    	}
    },

    goToScopeChangeReport : function(component) {
        var sprintData = component.get("v.sprintData");

        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ADM_Work_Commitment",
            componentAttributes: {
                sprintId : sprintData.sprintInfo.Id,
                sprintData : sprintData
            }
        });
        evt.fire();
    },

    setSprintCommitment : function(component, helper) {
        var modalBody;
        var sprintData = component.get("v.sprintData");

        $A.createComponent("c:ADM_Commitment_Modal", {sprintId : sprintData.sprintInfo.Id},
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;

                    component.find('overlayLib').showCustomModal({
                        header: "Commitment Confirmation",
                        body: modalBody,
                        showCloseButton: false,
                        cssClass: "cADM_Commitment_Modal",
                        closeCallback: function() {
                            var action = component.get("c.getSprintWorkCommitment");

                            action.setParams({sprintId : sprintData.sprintInfo.Id});

                            action.setCallback(this, function(response){
                                var state = response.getState();

                                if (component.isValid() && state === "SUCCESS") {
                                    component.set('v.sprintCommitment', JSON.parse(response.getReturnValue()));
                                }
                            });
                            $A.enqueueAction(action);
                        }
                    })
                }
            }
        );
    }
})