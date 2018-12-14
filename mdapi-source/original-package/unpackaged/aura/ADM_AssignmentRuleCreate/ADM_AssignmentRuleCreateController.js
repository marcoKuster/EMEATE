({
	handleSaveBugClick : function (component, event, helper) {
        
		console.log('inside handleSaveBugClick()');
        var ruleValues = component.get("v.defaultRule");
        //TODO: File platform bug or use hack workaround to reolve bug when saving twice described here: http://salesforce.stackexchange.com/questions/152577/unable-to-read-sobject-error-in-lightning-component-when-record-has-been-queried
        ruleValues.attributes = null;
        console.log('rule:', ruleValues);
        console.log(' product tag:' + component.get("v.productTagId") + ' recordType:' + component.get("v.recordType"));
        
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
                console.log('[saveRule] state=success,');
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
                var errorString = "";
                if (errors) {
                    for(var i = 0 ; i <= errors.length ; i++){
                        if(errors[i] && errors[i].message) {
                            console.log("Error message: " + errors[i].message);
                            errorString = "Error Message " + i + ":" + errors[i].message;
                        }
                    }
                } else {
                    console.log("Unknown error!");
                    errorString = "Unknown error please check the console for more information."
                }
                
                var errorToastEvent = $A.get("e.force:showToast");
                errorToastEvent.setParams({
                    "duration":"12000",
                    "type":"error",
                    "title": "Failed!",
                    "message": "There was a Lightning error when saving the " + recordType + " assignment rule.  This will most likely be resolved by reloading and trying again."
                });
                errorToastEvent.fire();
                
            }
        }); 
        
        
        // Invoke the service
        $A.enqueueAction(action);
        
        
    	
    }   
})