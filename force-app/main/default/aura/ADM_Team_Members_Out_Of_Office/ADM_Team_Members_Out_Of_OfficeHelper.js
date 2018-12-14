({
    outOfOfficeListOfTeamMembers : function(component) {
        // Get a reference to the list of Out of Office entries for team Members - Calling Apex class methods
        var action = component.get("c.getTeamMembersOutOfOfficeList");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        // Register the callback function
        action.setCallback(this, function(actionResult) {
           
            var state = actionResult.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                console.log('[getTeamMembersOutOfOfficeList] state=success-- return value :');
                component.set("v.outOfOfficeList", actionResult.getReturnValue());
                                
            }  else if (component.isValid() && state === "ERROR") {
                console.log('[getTeamMembersOutOfOfficeList] errors found... ');
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