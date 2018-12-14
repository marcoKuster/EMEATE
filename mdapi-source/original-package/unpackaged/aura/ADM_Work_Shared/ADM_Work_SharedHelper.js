({
    saveRecord : function(component, obj, recordType, callback) {
        var jsonStr = JSON.stringify(obj);
        var action;

        if (recordType === "Work") {
            action = component.get("c.saveWork");
        } else if (recordType === "Task") {
            action = component.get("c.saveTask");
        }

        ADM_SprintShared_Resource.showSpinner();
        action.setParams({"jsonObj": jsonStr});
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var wrappedWorkData = response.getReturnValue();

                if (typeof wrappedWorkData === 'string') {
                    wrappedWorkData = JSON.parse(wrappedWorkData);
                }

                if (recordType === "Work") {
                    var updateSprintData = $A.get("e.c:ADM_Event_Update_SprintData");
                    updateSprintData.setParams({
                        "data": wrappedWorkData[0],
                        "recordType": recordType
                    })
                    updateSprintData.fire();
                } else {
                    ADM_SprintShared_Resource.hideSpinner();
                }

                if (callback) {
                    callback(wrappedWorkData[0]);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                ADM_Util.handleErrorWithToast(errors);
                ADM_SprintShared_Resource.hideSpinner();
            }
        });
        $A.enqueueAction(action);
    }
})