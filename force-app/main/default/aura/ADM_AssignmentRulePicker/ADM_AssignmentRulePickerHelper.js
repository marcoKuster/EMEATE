({
	navigateToView : function(component, destination, attributes, auraId) {
        $A.createComponent(
            destination,
            attributes || {},
            function(view){
                if(component.isValid() && auraId) {
                    var content = component.find(auraId);
               		content.set("v.body", view);
               }
            }
        );
	},
    
    getAssignmentRuleSelections : function(component, recordType) {
        console.log('inside getAssignmentRuleSelections() v.recordId:');
        console.log(component.get("v.recordId"));
        // Get a reference to the method defined in the Apex controller
		var action = component.get("c.getRuleByRecordType");
       
        
        action.setParams({
            "productTagId": component.get("v.recordId"),
            "recordType":recordType
        });
        
        // Register the callback function
        action.setCallback(this, function(actionResult) {
            console.log('getRuleByRecordType() for record type:' + recordType + ' actionResult followed by return value:');
            console.log(actionResult);
            console.log('getRuleByRecordType() actionResult return value:');
            console.log(actionResult.getReturnValue());
           
            var state = actionResult.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                console.log('[getRuleByRecordType] state=success');
                //can't return the value because it will be undefined until the call back runs 
                if(recordType === 'Bug') {
                    component.set("v.assignmentRulesForBugs", actionResult.getReturnValue());
                } else if (recordType === 'User Story') {
                    component.set("v.assignmentRulesForUserStories", actionResult.getReturnValue());
                } else if (recordType === 'Investigation') {
                    component.set("v.assignmentRulesForInvestigations", actionResult.getReturnValue());
                }
                
                //the recordId variable is pre-populated thanks to the flexi interface the component implements
                var productTagId = component.get("v.recordId");
                //build id based on record type with the spaces trimmed and the word wrapper added to the end
                var recordTypeLabelWithoutSpaces = recordType;
                recordTypeLabelWithoutSpaces = recordTypeLabelWithoutSpaces.replace(/ +/g, "");
                console.log('recordTypeLabelWithoutSpaces:' + recordTypeLabelWithoutSpaces);
                var wrapperid = recordTypeLabelWithoutSpaces  + "wrapper";
                //load the form to make the assignment rules editable
                var createAssignmentRuleComponentName = 'c:ADM_AssignmentRuleCreate'
                /* TODO: The c:ADM_AssignmentRuleCreateInvestigation component is a duplicate of ADM_AssignmentRuleCreate but 
                with Investigation fields. Investigations can't use the ADM_AssignmentRuleCreate component because they require
				different fields yet when we wrap the force:inputField component in aura:if it breaks.  File a 
				platform bug so that this code duplication can be removed
                */
                if(recordType === 'Investigation') {
                    createAssignmentRuleComponentName = 'c:ADM_AssignmentRuleCreateInvestigation'
                }   
                    
                $A.createComponent(
                    createAssignmentRuleComponentName,
                    { "defaultRule": actionResult.getReturnValue()[0].rule,"productTagId": productTagId,"recordType":recordType},
                    function(view){
                        if(component.isValid()) {
                            var content = component.find(wrapperid);
                            content.set("v.body", view);
                        }
                    }
                );   
                
                //finally refresh the Product Tag detail screen to ensure fields that depend on work done by 
                //the apex controller are up to date e.g. the active check box
                $A.get('e.force:refreshView').fire();
                
            }  else if (component.isValid() && state === "ERROR") {
                console.log('[getRuleByRecordType] errors found... ');
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