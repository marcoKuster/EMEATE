({
	handleSaveBugClick : function (component, event, helper) {
        
		console.log('inside handleSaveBugClick()');
        var ruleValues = component.get("v.defaultRule");
        console.log('rule:', ruleValues);
        
        // Get a reference to the method defined in the Apex controller
		var action = component.get("c.saveRule");
       
        
        action.setParams({
            "productTagId": component.get("v.productTagId"),
            "recordType":component.get("v.recordType"),
            "rule":component.get("v.defaultRule")
        });
        
        var recordType = component.get("v.recordType");
        
        // Register the callback function
        action.setCallback(this, function(actionResult) {
            console.log('saveRule() actionResult followed by return value:');
            console.log(actionResult);
            console.log('saveRule() actionResult return value:');
            console.log(actionResult.getReturnValue());
           
            var state = actionResult.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                console.log('[saveRule] state=success');
                component.set("v.defaultRule", actionResult.getReturnValue());
                
                
                //show succes message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"success",
                    "title": "Success!",
                    "message": "The " + recordType + " assignment rule has been updated successfully."
                });
                toastEvent.fire();
			
                
            }  else if (component.isValid() && state === "ERROR") {
                console.log('[saveRule] errors found... ');
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
                
                var errorToastEvent = $A.get("e.force:showToast");
                errorToastEvent.setParams({
                    "duration":"12000",
                    "type":"error",
                    "title": "Failed!",
                    "message": "There was a Lightning error when saving the Investigation assignment rule.  This will most likely be resolved by reloading and trying again."
                });
                errorToastEvent.fire();
                
            }
        }); 
        
        
        // Invoke the service
        $A.enqueueAction(action);
        
        
    	
    }   
})