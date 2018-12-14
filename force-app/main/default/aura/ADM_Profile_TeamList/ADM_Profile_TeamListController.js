({
	teamLookUpAction : function(component, event, helper) {
        
		if(component.isValid()){

			var action = component.get("c.getScrumTeams");
				action.setParams({
				    "userId": component.get("v.recordId")
			});
		
			action.setCallback(this, function(response) {
			
				var state = response.getState();
				if (state === "SUCCESS"){				
					component.set("v.members", response.getReturnValue());
				} else if ( state === "INCOMPLETE" ){
					    console.error("An incomplete error was returned calling c.getScrumTeams.");
				} else {
					console.error("The call to c.getScrumTeams failed with errors. See below.");
				    var errors = response.getError();
					if (errors) {
					    if (errors[0] && errors[0].message) {
							console.error("Error message: " + errors[0].message);
					    }
					} else {
					    console.error("Unknown error");
                    }
				}

			});
		
			$A.enqueueAction(action);

		}
    }
    
})