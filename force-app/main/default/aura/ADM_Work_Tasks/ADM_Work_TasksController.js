({
	initialize : function(component, event, helper) {
		setTimeout($A.getCallback(function() { // needed to ensure that elements are available when trying to access them.
			if (component.isValid()) {
				var plannedTasks = component.find('plannedTasksContainer').getElement().querySelector('[data-col-name="plannedTasks"]');
				var inProgressTasks = component.find('inProgressTasksContainer').getElement().querySelector('[data-col-name="inProgressTasks"]');
				var completedTasks = component.find('completedTasksContainer').getElement().querySelector('[data-col-name="completedTasks"]');
				var options = {
					containers: [plannedTasks, inProgressTasks, completedTasks],
					moves: function(el, source, handle, sibling) {
						return handle.classList.contains('gripper');
		            }
				}

				var drake = dragula(options)

				drake.on('drop', $A.getCallback(function(el, target, source, sibling) {
					drake.cancel(true) // lightning doesnt like dragula owning the DOM, so we cancel the update & update the DOM with lightning.

					var movedTaskId = el.dataset.taskId;
					var movingFromCol = source.dataset.colName;
					var movingToCol = target.dataset.colName;
					var recordBelowId = sibling && sibling.dataset ? sibling.dataset.taskId : null; // if dropped as the last item in the list, this is null
					var movingFromTasks = component.get('v.' + movingFromCol);
					var movingToTasks = component.get('v.' + movingToCol);
					var movingFromTasksLength = movingFromTasks.length;
					var movingToTasksLength = movingToTasks.length;
					var updatedMovingFromTasks = [];
					var updatedMovingToTasks = [];
					var movedTask = undefined;

					// remove the movedTask from movingFromTasks
					for (var i = 0; i < movingFromTasksLength ; i++) {
						var task = movingFromTasks[i];

						if (task.Id === movedTaskId) {
							movedTask = task;
						} else {
							updatedMovingFromTasks.push(task);
						}
					}

					if (!movingToTasksLength) { // moving to an empty column;
						if (movedTask) {
							updatedMovingToTasks.push(movedTask);
						}
					} else {
						for (var i = 0; i < movingToTasksLength ; i++) {
							var task = movingToTasks[i];

							if (!task){
								continue;
							} else if (task.Id === movedTaskId) {
								continue;
							} else if (task.Id === recordBelowId) { // add task above where it was dropped
								updatedMovingToTasks.push(movedTask);
								updatedMovingToTasks.push(task);
							} else if (!recordBelowId && (i + 1 === movingToTasksLength)) { // if dropped at bottom of column
								updatedMovingToTasks.push(task);
								updatedMovingToTasks.push(movedTask);
							} else {
								updatedMovingToTasks.push(task);
							}
						}
					}
					component.set('v.' + movingFromCol, updatedMovingFromTasks);
					component.set('v.' + movingToCol, updatedMovingToTasks);

					var plannedTaskIds = component.get('v.plannedTasks').map(function(task) {
						return task.Id;
					});
					var inProgressTaskIds = component.get('v.inProgressTasks').map(function(task) {
						return task.Id;
					});
					var completedTaskIds = component.get('v.completedTasks').map(function(task) {
						return task.Id;
					});

					helper.updateTaskOrder(
						component,
						plannedTaskIds,
						inProgressTaskIds,
						completedTaskIds
					);

				}));
			}
		}), 500)
	},

	createNewTask : function(component, event, helper) {
		var taskColName;
		var taskColStatus;
		var workId;
		var componentWorkId = component.get('v.workId');
		var statusToColumnMap = {"Not Started" : "plannedTasks", "In Progress" : "inProgressTasks", "Completed" : "completedTasks"};
		
		if (event.getParam && event.getParam('workId') && event.getParam('workId') === componentWorkId) { // application-level event fired
			taskColName = ((event.getParam && event.getParam('taskStatus')) ? statusToColumnMap[event.getParam('taskStatus')] : 'plannedTasks');
			taskColStatus = ((event.getParam && event.getParam('taskStatus')) ? event.getParam('taskStatus') : 'Not Started');
			workId = event.getParam('workId');
		} else if (event.target && event.target.getAttribute && event.target.getAttribute("data-col-name") && event.target.getAttribute("data-col-status")) {
			taskColName = event.target.getAttribute("data-col-name");
			taskColStatus = event.target.getAttribute("data-col-status");
			workId = componentWorkId;
		} else {
			return;
		}

		helper.createNewTask(component, taskColName, taskColStatus, workId);
	},

	updateUserPref : function(component, event, helper) {
		var userPrefs = component.get("v.userPrefs");
		var field = event.getParam("field");
		var value = event.getParam("value");

		userPrefs[field] = value;

		component.set("v.userPrefs", userPrefs);
	},

	toggleCollapsedTasks: function(component, event, helper) {
		if (event && event.target && event.target.getAttribute && event.target.getAttribute('data-col-name')) {
			var colName = event.target.getAttribute('data-col-name');
			var collapsedColName = 'v.' + colName + 'Collapsed';
			var collapsedAttributeValue = component.get(collapsedColName);

			component.set(collapsedColName, !collapsedAttributeValue);
		} else {
			console.error('No column name found when clicking expandTasks');
			return;
		}
	},

	noop: function() {

	},

	handleDeleteUnsavedTask: function(component, event, helper) {
		var workId = event.getParam('workId');
		var status = event.getParam('status');
		if (workId === component.get('v.workId')) {
			var plannedTasksBefore = component.get('v.plannedTasks');
			var inProgressTasksBefore = component.get('v.inProgressTasks');
			var completedTasksBefore = component.get('v.completedTasks');

			var plannedTasksWithoutNew = plannedTasksBefore.filter(function(task) {
				return !task.newTask;
			});
			var inProgressTasksWithoutNew = inProgressTasksBefore.filter(function(task) {
				return !task.newTask;
			});
			var completedTasksWithoutNew = completedTasksBefore.filter(function(task) {
				return !task.newTask;
			});

			if (plannedTasksBefore.length !== plannedTasksWithoutNew.length) {
				component.set('v.plannedTasks', plannedTasksWithoutNew);
			} else if (inProgressTasksBefore.length !== inProgressTasksWithoutNew.length) {
				component.set('v.inProgressTasks', inProgressTasksWithoutNew);
			} else if (completedTasksBefore.length !== completedTasksWithoutNew.length) {
				component.set('v.completedTasks', completedTasksWithoutNew);
			}
		}
	}

})