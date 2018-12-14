({
	getProductTagFields : function(component) {
        // Get a reference to the product tag fields defined in the Apex controller
		var action = component.get("c.getProductTagFields");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        // Register the callback function
        action.setCallback(this, function(actionResult) {
            console.log('actionResult:');
            console.log(actionResult);
            var state = actionResult.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                console.log('[getProductTagFields] state=success');
                component.set("v.fieldList", actionResult.getReturnValue());
                
                
            }  else if (component.isValid() && state === "ERROR") {
                console.log('[getProductTagFields] errors found... ');
                var errors = actionResult.getError();
                console.log(errors); 
                if (errors) {
                    for(var i = 1 ; i <= errors.length ; i++){
                        if(errors[i] && errors[i].message) {
                            console.log("Error message: " + errors[0].message);
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