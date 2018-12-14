({
    doInit : function(component, event, helper) {
        console.log('inside doInit about to call helper...')
        helper.getAssignmentRuleSelections(component, "Bug");
        helper.getAssignmentRuleSelections(component, "User Story");
        helper.getAssignmentRuleSelections(component, "Investigation");
    }
    
})