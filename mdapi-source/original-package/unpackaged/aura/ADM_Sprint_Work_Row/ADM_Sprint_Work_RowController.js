({
	doInit: function (component, event, helper) {
		helper.updateStoryPointOptions(component, event, helper);

		var wallPreferences = component.get("v.wallPreferences");
        var teamId = component.get("v.teamId");
		var filters = wallPreferences.teams[teamId].filters
		var workRecord = component.get("v.work");
		var userPreferences = component.get("v.userPreferences");

		workRecord.visible = ADM_SprintShared_Resource.isWorkItemVisible(workRecord, filters);

		if (userPreferences && !userPreferences.ShowBacklogviewonVirtualWall__c && !component.get("v.tasksVisible")) {
			helper.showTasks(component);
		}
	},

	workAction : function (component, event, helper) {
		var menuItem = event.detail.menuItem;
		var menuItemLabel = menuItem.get("v.label");
		var menuItemValue = menuItem.get("v.value");
		var nextSprintId = component.get("v.nextSprintId");

		if (menuItemLabel === 'Move to Next Sprint' || menuItemLabel === 'Remove from Sprint') {
			var sprintId = (menuItemLabel === 'Move to Next Sprint' ? nextSprintId : '');
			var work = {
				'Id': menuItemValue,
				'Sprint__c': sprintId
			};

			helper.saveRecord(component, work, 'Work', function(response) {
				document.querySelector('#' + response.m_story.Id).remove();

				var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
		        showSpinner.setParams({
		            "show": false
		        })
		        showSpinner.fire();
			});
		} else if (menuItemLabel === 'Edit work') {
			helper.openWorkEditModal(component, menuItemValue, 'actionmenu');
		} else if (menuItemLabel === 'Add Task') {
			var newTask = $A.get("e.c:ADM_Event_New_Task");
			newTask.setParams({"workId" : menuItemValue});
			newTask.fire();
		} else if (menuItemLabel.toLowerCase().includes('flag new customer facing feature')) {
			var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
	        showSpinner.setParams({
	            "show": true
	        })
	        showSpinner.fire();

		    var work = {
				'Id': component.get("v.work.m_story.Id"),
				'Capex_Enabled__c': menuItemValue
			};

			helper.saveRecord(component, work, 'Work', function(response) {
				var hideSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
		        hideSpinner.setParams({
		            "show": false
		        })
		        hideSpinner.fire();
			});
		} else {
			window.open('/' + menuItemValue,'_blank');
		}
	},

	openWorkModal : function (component, event, helper) {
		var workItemValue = event.target.getAttribute("id");

		event.stopPropagation();
        event.preventDefault();

		helper.openWorkEditModal(component, workItemValue, 'workid');
	},

	viewWorkInTab : function (component, event, helper) {
		var workItemId = event.target.getAttribute("id");

		event.preventDefault();

		window.open('/' + workItemId,'_blank');
	},
	
	setSelectValue : function (component, event, helper) {
		var selectEl = event.target;

		var recordId = selectEl.getAttribute("data-work-id");
		var fieldName = selectEl.getAttribute("data-field-name");

		var work = {
			'Id': recordId
		};

		work[fieldName] = selectEl.options[selectEl.selectedIndex].value;

		if (work[fieldName] === '') {
			work[fieldName] = null;
		}

		helper.saveRecord(component, work, 'Work', function(response) {

		});
	},
	
	editSubjectFromIcon : function (component, event, helper) {
		var output = component.find('subject').getElement();
		
		output.click();
	},
	
	editSubject : function (component, event, helper) {
		var output = event.target || component.find('subject');
		var input = event.target.nextSibling || component.find('subject-input-container');
		var editIcon = component.find('sprint-work-subject');

		$A.util.toggleClass(output, "slds-hide");
		$A.util.toggleClass(input, "slds-hide");
		$A.util.toggleClass(editIcon, "editing");

		component.find('subjectInput').getElement().focus();
	},

	saveSubjectOnEnter : function (component, event, helper) {
		if(event.keyCode == 13) {
			component.find('subjectInput').getElement().blur();
		}
	},

	saveSubject : function (component, event, helper) {
		helper.saveSubject(component, event, helper);
	},

	toggleTasks : function (component, event, helper) {
		var work = event.target;

		var workId = work.getAttribute("data-work-id");

		var toggleTasks = $A.get("e.c:ADM_Toggle_TaskView");
		toggleTasks.setParams({"workId" : workId});
		toggleTasks.fire();
	},

	updateStoryPointOptions: function (component, event, helper) {
		helper.updateStoryPointOptions(component, event, helper);
	},

	toggleTaskLayout : function(component, event, helper) {
		var state = event.getParam("state");
		var workId = event.getParam("workId");
		var workRowWrapper = component.find('workRowWrapper').getElement();
		var workRowContainer = component.find('workRowContainer').getElement();
		var visible = helper.isElementInViewport(workRowWrapper);
		var rafId;

		if (state === 'show') {
			component.set("v.toggleState", "expanded");

			helper.checkElementVisibility(component, helper, workRowWrapper);
		}

		if (state === 'show' && visible) {
			helper.showTasks(component);
        } else if (!!workId && (workId == component.get("v.work.m_story.Id"))) {
        	workRowWrapper.classList.toggle("adm-task-layout");
            workRowContainer.classList.toggle("slds-align--absolute-center");
            workRowContainer.classList.toggle("slds-grid");
            component.set("v.tasksVisible", !component.get("v.tasksVisible"));
        } else if (state === 'hide') {
			workRowWrapper.classList.remove("adm-task-layout");
			// workRowWrapper.classList.remove("fadeIn");
            workRowContainer.classList.add("slds-align--absolute-center");
            workRowContainer.classList.add("slds-grid");
            component.set("v.tasksVisible", false);
            component.set("v.toggleState", "collapsed");
        }
	},

    filterWork : function (component, event, helper) {
		var filteredWork = event.getParam("workVisibility");
		var workId = component.get("v.work.m_story.Id");

		if (component.get("v.work.visible") !== filteredWork[workId]) {
			component.set("v.work.visible", filteredWork[workId]);
		}
	},

	updateWork : function(component, event, helper) {
		var data = event.getParam('data');
		var recordType = event.getParam('recordType');
		var workId = component.get('v.work.m_story.Id');

		if (data && data.m_story && data.m_story.Id && component.get('v.work.m_story.Id') === data.m_story.Id) {
			component.set('v.work', data);
		}
	},

	populateSelectOptions : function(component, event, helper) {
		component.set('v.selectOptionsPopulated', true);
	}
})