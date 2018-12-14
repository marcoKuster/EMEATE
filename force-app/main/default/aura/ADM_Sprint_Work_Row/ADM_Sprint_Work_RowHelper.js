({
	openWorkEditModal: function(component, workItemId, source) {
		var userPerms = component.get("v.userPermSets");

		if (userPerms.filter(function(perm) { return perm.PermissionSet.Name == 'LEX_Sprint_Wall_Work_Edit_AB_Test'; }).length > 0 && source == 'workid') {
			var modalEvt = $A.get("e.c:ADM_Open_Modal");
			modalEvt.setParams({
				"modalName": "ADM_Work_Modal",
				"modalData": workItemId
			});
			modalEvt.fire();
		} else {
			var nameSpace = component.get("v.nameSpace");
			var sprintId = component.get("v.sprintId");
			var editPageUrl = '/apex/'+nameSpace+'ADM_WorkCreateEdit?id=' + workItemId + '&retUrl=/' + sprintId + '&Sprint__c=' + sprintId;

			var navigateEvt = $A.get("e.force:navigateToURL");
			navigateEvt.setParams({
				"url": editPageUrl
			});
			navigateEvt.fire();
		}
	},

	saveSubject: function(component, event, helper) {
		var input = event.target;
		var workId = input.getAttribute("data-work-id");
		var outputElm = component.find('subject').getElement();
		var inputContainerElm = component.find('subject-input-container').getElement();
		var editIcon = component.find('sprint-work-subject');

		outputElm.classList.toggle('slds-hide');
		inputContainerElm.classList.toggle('slds-hide');
		$A.util.toggleClass(editIcon, "editing");


		if (outputElm.firstChild.innerText != input.value) {
			outputElm.firstChild.innerText = input.value;

			var work = {
				'Id': workId,
				'Subject__c': input.value
			};

			helper.saveRecord(component, work, 'Work', function(response) {

			});
		}
	},

	updateStoryPointOptions: function (component, event, helper) {
		var storyPointScale = component.get('v.storyPointScale');
		var storyPoints = component.get('v.work.m_story.Story_Points__c');
		var storyPointOptions = [];
		var pointsInScale = false;

		if (!storyPointScale && !storyPoints && storyPoints !== null && storyPoints !== 0) {
			return;
		}

		var nullOption = {
			value: '',
			label: '-',
			selected: storyPoints === null
		}
		storyPointOptions.push(nullOption);

		for (var i = 0, len = storyPointScale.length; i < len; i++) {
			var option = {
				value: storyPointScale[i],
				label: storyPointScale[i],
				selected: (''+storyPointScale[i]) === (''+storyPoints)
			}
			if (option.selected) {
				pointsInScale = true;
			}

			storyPointOptions.push(option);
		}

		if (!pointsInScale && storyPoints !== null) {
			var option = {
				value: storyPoints,
				label: storyPoints,
				selected: true
			}
			storyPointOptions.unshift(option);
		}

		component.set('v.storyPointOptions', storyPointOptions);
	},

	isElementInViewport: function(el) {
		if (!el) {
			return false;
		}
		var rect = el.getBoundingClientRect();
		if (!rect) {
			return false;
		}
	    var visible = (rect.top <= (window.innerHeight || document.documentElement.clientHeight));

	    return visible;
	},

	checkElementVisibility: function(component, helper, el) {
		var visible = helper.isElementInViewport(el);

        if (visible) {
        	if (component.get("v.toggleState") === "expanded") {
			    helper.showTasks(component);
			}
        } else {
        	setTimeout($A.getCallback(function() {
				if (component.get("v.toggleState") === "expanded") {
				    helper.showTasks(component);
				}
			}), 1000);
        }

	},

	showTasks : function(component) {
        component.set("v.tasksVisible", true);
    }
})