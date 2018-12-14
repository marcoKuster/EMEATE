({  
    initialize: function(component, event, helper) {    
        var action = component.get("c.getScopeChangeJSON");
        
        action.setParams({
            "sprintId": component.get("v.sprintId")
        });
        
        // Register the callback function
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();

            if (component.isValid() && state === "SUCCESS") {
                var scopeData = actionResult.getReturnValue();

                if (typeof scopeData === 'string') {
                    scopeData = JSON.parse(scopeData);
                }

                var nameSpace = scopeData.sprintData.nameSpace;

                for(var property in scopeData) {
                    scopeData = ADM_Util.serializeSprintDataForNamespace(scopeData, property, nameSpace);
                }
                
                var committedStoryPoints = scopeData.sprintCommitment.storyPoints;
                var committedNumOfItems = scopeData.sprintCommitment.numOfItems;
                
                var committedColumns = [
                    {label: 'Id', fieldName: 'work.Name', cssClass: 'adm-col_small', linkIdField: 'work.Id'},
                    {label: 'Type', fieldName: 'work.Record_Type__c', cssClass: 'adm-col_small'},
                    {label: 'Subject', fieldName: 'work.Subject__c', cssClass: 'adm-max-width_5'}, 
                    {label: 'Status', fieldName: 'work.Status__c', cssClass: 'adm-col_small'},
                    {label: 'Assignee', fieldName: 'work.Assignee__r.Name', cssClass: 'adm-col_small'},
                ];
                var addedColumns = [
                    {label: 'Id', fieldName: 'Name', cssClass: 'adm-col_small', linkIdField: 'Id'},
                    {label: 'Type', fieldName: 'Record_Type__c', cssClass: 'adm-col_small'},{label: 'Subject', fieldName: 'Subject__c', cssClass: 'adm-max-width_5'},
                    {label: 'Status', fieldName: 'Status__c', cssClass: 'adm-col_small'},
                    {label: 'Assignee', fieldName: 'Assignee__r.Name', cssClass: 'adm-col_small'},
                ];
                var removedColumns = [
                    {label: 'Id', fieldName: 'work.Name', cssClass: 'adm-col_small', linkIdField: 'work.Id'},
                    {label: 'Type', fieldName: 'work.Record_Type__c', cssClass: 'adm-col_small'},
                    {label: 'Subject', fieldName: 'work.Subject__c', cssClass: 'adm-max-width_5'},
                    {label: 'Status', fieldName: 'work.Status__c', cssClass: 'adm-col_small'},
                    {label: 'Assignee', fieldName: 'work.Assignee__r.Name', cssClass: 'adm-col_small'},
                ];
                
                if (scopeData.sprintData.sprintInfo.Scrum_Team__r.Velocity_Type__c != 'Record Count') {
                    committedColumns.push({label: 'Committed (' + scopeData.committedPoints + ')', fieldName: 'committedStoryPoints', cssClass: 'adm-col_small adm-align_right'});
                    committedColumns.push({label: 'Current (' + scopeData.currentCommittedPoints + ')', fieldName: 'work.Story_Points__c', cssClass: 'adm-col_small adm-align_right', conditionalCssClass: 'pointsDiffCssClass'});
                    removedColumns.push({label: 'Committed (' + scopeData.removedPoints + ')', fieldName: 'committedStoryPoints', cssClass: 'adm-col_small adm-align_right'});
                    removedColumns.push({label: 'Current (' + scopeData.currentRemovedPoints + ')', fieldName: 'work.Story_Points__c', cssClass: 'adm-col_small adm-align_right', conditionalCssClass: 'pointsDiffCssClass'});
                    addedColumns.push({label: 'Current (' + scopeData.currentAddedPoints + ')' , fieldName: 'Story_Points__c', cssClass: 'adm-col_small adm-align_right'});
                }

                component.set("v.sprintCommitment", scopeData.sprintCommitment);
                component.set("v.committedWork", scopeData.committedWork);
                component.set("v.addedWork", scopeData.addedWork);
                component.set("v.removedWork", scopeData.removedWork);
                
                component.set('v.committedColumns', committedColumns);
                component.set('v.addedColumns', addedColumns);
                component.set('v.removedColumns', removedColumns);

                if ($A.util.isEmpty(component.get("v.sprintData"))) {
                    component.set("v.sprintData", scopeData.sprintData);
                }
            } else if (component.isValid() && state === "ERROR") {
                var errors = actionResult.getError();
                console.log('errors:',errors);
                ADM_Util.handleErrorInConsole(errors);
            }
        });
        // Invoke the service
        $A.enqueueAction(action);

        component.set('v.sidebarOptions', {"chartOptions":{"showSprintCommitmentChart":true}});
    },

    navigateToCommitment : function (component, event, helper) {
        var menuItem = event.detail.menuItem;
            
        var evt = $A.get("e.force:navigateToComponent");
        
        evt.setParams({
            componentDef : "c:ADM_Work_Commitment",
            componentAttributes: {
                sprintId : menuItem.get("v.value")
            }
        });
        
        evt.fire();
    }
})