({
	doInit: function(component, event, helper) {
		helper.showSpinner();
		setTimeout($A.getCallback(function() {
			helper.getSprintDataAndStream(component, event, helper);
		}));

		var action = component.get("c.getUserInfoAura");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var userInfo = response.getReturnValue();

                if (typeof userInfo === 'string') {
                    userInfo = JSON.parse(userInfo);
                }

                component.set('v.userInfo', userInfo);
            }
        });

        $A.enqueueAction(action);
	},

    updateSprintData: function(component, event, helper) {
		var workData = event.getParam('data');
		var recordType = event.getParam('recordType');
        var sprintData = component.get("v.sprintData");
		//serialize workData
        var nameSpace = sprintData.nameSpace;
        for(property in workData){
            workData = helper.serializeSprintDataForNamespace(workData,property,helper,nameSpace);
        }

        if (sprintData != null) {
        	var changedWorkId = workData.m_story.Id;

        	if (workData.m_story.Sprint__c == sprintData.sprintInfo.Id) {
				var changedWork = helper.getWorkById(sprintData, changedWorkId);

				if(!changedWork){
	                sprintData.sprintWork = helper.addWork(sprintData, workData);
	            } else {
					sprintData.sprintWork = helper.updateWorkById(sprintData, workData, changedWorkId);
				}

	            if(recordType === "Work"){
					helper.updateSprintVelocity(sprintData);
	            }
	        } else {
				sprintData.sprintWork = helper.getWorkBySprintId(sprintData, sprintData.sprintInfo.Id);
				helper.updateSprintVelocity(sprintData);
	        }
        }

		helper.hideSpinner();
    },
    
	locationChangeHandler: function(component, event, helper) {
		if (component && component.isValid()) {
			var timerId = component.get('v.timeoutToastTimerId'),
				token = event.getParam("token"),
            	objId = component.get("v.recordId"),
            	sprintData = component.get("v.sprintData"),
            	sprintObjPrefix = (sprintData ? sprintData.sprintObjPrefix : null),
            	inConsole = (document.querySelector('.oneConsoleLayoutContainer') != null);
			
			clearTimeout(timerId);
			var inputEvents = 'mousemove keydown mousewheel mousedown touchstart touchmove';
			if ($) {
				$(document).off(inputEvents, component._onActivity);
			}
			
			delete component._onActivity;
			
			if (inConsole && objId && (objId.substr(0, 3) == sprintObjPrefix) && token.includes(objId)) {
				helper.getSprintDataAndStream(component, event, helper, objId);
			}
		}
    },
    
    stopEventPropagation: function(component, event, helper) {
        event.stopPropagation();
    }
})