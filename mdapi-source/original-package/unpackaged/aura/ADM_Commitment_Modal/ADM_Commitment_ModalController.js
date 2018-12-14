({
    initialize: function(component, event, helper) {
        var action = component.get("c.getSprintJSON");

        action.setParams({
            "sprintId": component.get("v.sprintId")
        });
        // Register the callback function
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();

            if (component.isValid() && state === "SUCCESS") {
                var sprintData = actionResult.getReturnValue();

                if (typeof sprintData === 'string') {
                    sprintData = JSON.parse(sprintData);
                }

                var sprintWork = sprintData.sprintWork;

                var nameSpace = sprintData.nameSpace;
                for(property in sprintWork){
                    sprintWork = ADM_Util.serializeSprintDataForNamespace(sprintWork, property, nameSpace);
                }

                helper.calculateCommitments(component, sprintWork);

                var sprintInfo = sprintData.sprintInfo;

                for(property in sprintInfo){
                    sprintInfo = ADM_Util.serializeSprintDataForNamespace(sprintInfo, property, nameSpace);
                }

                component.set("v.sprintInfo", sprintInfo);
            } else if (component.isValid() && state === "ERROR") {
                var errors = actionResult.getError();
                
                ADM_Util.handleErrorInConsole(errors);
                ADM_Util.handleErrorWithToast(errors);
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
    },
    
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },
    handleOK : function(component, event, helper) {
        var dorChecked = component.find("DefinitionOfReady").get("v.checked");
        var sprintInfo = component.get("v.sprintInfo");
        var action = component.get("c.setSprintWorkCommitment");

        action.setParams({
            sprintId : sprintInfo.Id,
            defOfReady : dorChecked
        });

        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();

            if (component.isValid() && state === "SUCCESS") {
                component.find("overlayLib").notifyClose();
            } else if (component.isValid() && state === "ERROR") {
                var errors = actionResult.getError();
                
                component.set('v.errors', errors);
            }
        });

        $A.enqueueAction(action);
    }
})