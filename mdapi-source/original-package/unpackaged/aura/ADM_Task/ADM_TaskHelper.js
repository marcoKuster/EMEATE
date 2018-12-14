({
    delTask : function(component) {
        if(component.isValid()) {
            var action = component.get("c.deleteTaskAuraNew");

            action.setAbortable();

            action.setParams({
                "recordId": component.get("v.task").Id
            });

            action.setCallback(this, function(actionResult) {
                var state = actionResult.getState();

                if(component.isValid() && state === "SUCCESS") {
                    setTimeout($A.getCallback(function() {
                        var wrappedWorkData = actionResult.getReturnValue();

                        if (typeof wrappedWorkData === 'string') {
                            wrappedWorkData = JSON.parse(wrappedWorkData);
                        }
                        
                        var updateSprintData = $A.get("e.c:ADM_Event_Update_SprintData");
                        updateSprintData.setParams({
                            "data": wrappedWorkData[0],
                            "recordType": "Task"
                        })
                        updateSprintData.fire();
                    }));
                    
                    component.destroy();
                }  else if (component.isValid() && state === "ERROR") {
                    console.log('[Task Deletion failed] errors found... ');
                    var errors = actionResult.getError();
                    //print error or loop error array will be better in case theres more then one
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

            $A.enqueueAction(action);
        } else {
            console.log('Task Component Helper: Delete Component - component invalid hence entered else');
        }

    },

    saveTask : function(component, field, value, action) {
        var currentRecord = component.get("v.task");
        var previousValue = component.get("v.previousFieldValue");
        var recordId = component.get("v.task").Id;
        var record;

        if (action === 'insert') {
            if (currentRecord) {
                record = {
                    Assigned_To__c: currentRecord.Assigned_To__r.Id,
                    Hours_Remaining__c: 0,
                    Subject__c: value,
                    Order__c: currentRecord.Order__c,
                    Capex_Enabled__c: false,
                    Status__c: currentRecord.Status__c,
                    Work__c: currentRecord.Work__c
                };
            }
        } else {
            if ((value != null && previousValue != value)) {
                record = {
                    'Id': recordId,
                    'Work__c': currentRecord.Work__c
                };
                
                record[field] = value;
            }
        }

        if (!$A.util.isEmpty(record)) {
            this.saveRecord(component, record, 'Task', function(response) {
                var attribute = 'v.task.' + field
                component.set(attribute, value);
                
                if (action === 'insert') {
                    component.set("v.task.Id", currentRecord.Id);
                }
            });
        }
    },

    setPreviousValue: function(component, previousValue) {
        if (component.isValid()) {
            component.set("v.previousFieldValue", previousValue);
        }
    },
    
    saveSubject: function(component, subject) {
        if (component.isValid()) {
            var task = component.get("v.task");

            if (task) {
                if (!$A.util.isEmpty(subject) && !$A.util.isEmpty(task.Id)) {
                    this.saveTask(component, 'Subject__c', subject);
                } else if (!$A.util.isEmpty(subject) && $A.util.isEmpty(task.Id)) {
                    this.saveTask(component, 'Subject__c', subject, 'insert');
                } else {
                    var deleteUnsavedTask = $A.get("e.c:ADM_Event_Delete_Unsaved_Task");
                    deleteUnsavedTask.setParams({"workId" : task.Work__c, "status": task.Status__c});
                    deleteUnsavedTask.fire();
                }
            }
        }
    }
})