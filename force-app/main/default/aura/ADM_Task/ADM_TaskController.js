({
    confirmDeleteTask: function(component, evt, helper) {
        component.set('v.displayModal', true);
        window.setTimeout($A.getCallback(function() {
            var userPrefs = component.get("v.userPrefs");

            if (!!userPrefs && userPrefs.ShowDeleteTaskDialog__c) {
                component.find('confirmDeleteTask').getElement().classList.add('slds-fade-in-open');
                document.querySelector('.slds-backdrop').classList.add('slds-backdrop--open');
            } else {
                helper.delTask(component);
            }
        }), 100);
    },

    deleteTask: function(component, evt, helper) {
        var showDeleteTaskDialogChkbox = component.find("showDeleteTaskDialogChkbox");

        if (showDeleteTaskDialogChkbox.get("v.checked")) {
            var updateUserPref = $A.get("e.c:ADM_Event_Update_User_Pref");
            updateUserPref.setParams({"field" : "ShowDeleteTaskDialog__c", "value" : false});
            updateUserPref.fire();

            var action = component.get("c.setShowDeleteTaskDialogAura");
            $A.enqueueAction(action);
        }
        component.find('confirmDeleteTask').getElement().classList.remove('slds-fade-in-open');
        document.querySelector('.slds-backdrop').classList.remove('slds-backdrop--open');
        component.set('v.displayModal', false);

        helper.delTask(component);
    },

    closeDeleteConfirm: function(component, evt, helper) {
        component.find('confirmDeleteTask').getElement().classList.remove('slds-fade-in-open');
        document.querySelector('.slds-backdrop').classList.remove('slds-backdrop--open');
        component.set('v.displayModal', false);
    },

    openTask: function(component, evt, helper) {
        window.open('/'+  component.get("v.task").Id ,'_blank');
    },

    subjectKeyPress: function(component, evt, helper) {
        var key = evt.keyCode;

        // If the user has pressed enter
        if (key === 13) {
        	var task = component.get("v.task");
        	//only create a new task on enter if this task is new. If editing an existing task don't automatically create a new on on enter.
        	if (!task.Id) {
	        	var newTask = $A.get("e.c:ADM_Event_New_Task");
				newTask.setParams({"workId" : task.Work__c, "taskStatus" : task.Status__c});
				newTask.fire();
        	}

        	//blur event calls controller.saveSubject function below
			evt.target.blur();
        }
    },

    saveSubject: function(component, evt, helper) {
        if (component.isValid()) {
            var subject = evt.target.value;

            helper.saveSubject(component, subject);
        }
    },

    saveRemainingHours: function(component, evt, helper) {
        if (component.isValid() && component.find('remainingHours') && component.find('remainingHours').getElement()) {
            var hoursRemaining = component.find("remainingHours").getElement().value;
            hoursRemaining = parseFloat(hoursRemaining.replace(/[^0-9\.]+/g,''));
            component.find("remainingHours").getElement().value = hoursRemaining;

            helper.saveTask(component, 'Hours_Remaining__c', hoursRemaining);
        }
    },

    selectText: function(component, evt, helper) {
        if (component.isValid()) {
            setTimeout($A.getCallback(function () { evt.target.select(); }), 50); //Delay sightly to allow focus to "stick" before selecting.

            helper.setPreviousValue(component, evt.target.value);
        }
    },

    saveActualHours: function(component, evt, helper) {
        if (component.isValid() && component.find('actualHours') && component.find('actualHours').getElement()) {
            var actualHoursEl = component.find("actualHours").getElement();
            var actualHours = actualHoursEl.value;
            var maxCapHoursWarningGiven = component.get("v.maxCapHoursWarningGiven");

            if (actualHours > 80 && !maxCapHoursWarningGiven) {
                alert('That\'s a lot of hours! Please make sure "Actual Hours" have been input correctly before proceeding.');
                component.set("v.maxCapHoursWarningGiven", true);
            } else {
                component.set("v.maxCapHoursWarningGiven", false);
            }

            actualHours = parseFloat(actualHours.replace(/[^0-9\.]+/g,''));
            component.find("actualHours").getElement().value = actualHours;

            helper.saveTask(component, 'Actual_Hours__c', actualHours);
        }
    },

    saveCapitalizable: function(component, evt, helper) {
        if (component.isValid()) {
            var capitalizable = evt.getSource().get("v.checked");

            helper.setPreviousValue(component, !capitalizable);

            helper.saveTask(component, 'Capex_Enabled__c', capitalizable);
        }
    },

    setPreviousValue: function(component, evt, helper) {
        var value;

        if (evt.target) {
            value = evt.target.value;
        } else if (evt.getSource()) {
            value = evt.getSource().get("v.value");
        }

        helper.setPreviousValue(component, value);
    },

    handleShowSpinner: function (component, evt, helper) {
        var show = evt.getParam('show');
        var spinnerVisible = component.get('v.spinnerVisible');

        if (spinnerVisible !== show) {
            component.set('v.spinnerVisible', show);
        }
    },

    updateTaskData : function(component, evt, helper) {
        var taskId = evt.getParam('taskId');
		var task = evt.getParam('task');
		var thisTask = component.get('v.task');

		if (thisTask.Id == null && thisTask.Subject__c === task.Subject__c) {
            component.set("v.task.Id", task.Id);
            component.set("v.task.newTask", false);
		}
    }
})