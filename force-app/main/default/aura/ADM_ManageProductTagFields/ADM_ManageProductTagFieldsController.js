({
    doInit : function(component, event, helper) {
        // Get a reference to the method defined in the Apex controller
        var action = component.get("c.getFieldList");


        action.setParams({
            "productTagId": component.get("v.recordId")

        });

        // Register the callback function
        action.setCallback(this, function(actionResult) {
            console.log('getFieldList() actionResult:');
            console.log(actionResult);
            console.log('getFieldList()  return value:');
            console.log(actionResult.getReturnValue());

            var state = actionResult.getState();

            //hide loading spinner
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");

            if(component.isValid() && state === "SUCCESS") {
                console.log('[getFieldList] state=success');
                component.set("v.productTagFields", actionResult.getReturnValue());

            }  else if (component.isValid() && state === "ERROR") {
                console.log('[getFieldList] errors found... ');
                var errors = actionResult.getError();
                console.log(errors);
                if (errors) {
                    for(var i = 0 ; i <= errors.length ; i++){
                        if(errors[i] && errors[i].message) {
                            console.log("Error message: " + errors[i].message);
                        }
                    }
                } else {
                    console.log("Unknown error!");
                }

            }
        });


        // Invoke the service
        $A.enqueueAction(action);



    },

    handleClick : function(component, event, helper) {
        // Get a reference to the method defined in the Apex controller
        var action = component.get("c.saveAdditionalFields");
         action.setParams({
            "newAdditionalFields": component.get("v.productTagFields"),
            "productTagId": component.get("v.recordId")
        });

        console.log('handleClick() fields:', component.get("v.productTagFields"));




        // Register the callback function
        action.setCallback(this, function(actionResult) {
            console.log('saveAdditionalFields() actionResult:');
            console.log(actionResult);


            var state = actionResult.getState();

            if(component.isValid() && state === "SUCCESS") {
                console.log('[saveAdditionalFields] state=success');
                //refresh and close
                // Prepare a toast UI message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success",
                    "message": "Your product tag field settings have been successfully saved.",
                    "type":"success"
                });

                // Update the UI: close panel, show toast, refresh account page
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                $A.get("e.force:refreshView").fire();

            }  else if (component.isValid() && state === "ERROR") {
                console.log('[saveAdditionalFields] errors found... state:' + state);
                var errors = actionResult.getError();
                console.log(errors);
                if (errors) {
                    for(var i = 0 ; i <= errors.length ; i++){
                        if(errors[i] && errors[i].message) {
                            console.log("Error message: " + errors[i].message);
                        }
                    }
                } else {
                    console.log("Unknown error!");
                }

            }
        });


        // Invoke the service
        $A.enqueueAction(action);

    }


})