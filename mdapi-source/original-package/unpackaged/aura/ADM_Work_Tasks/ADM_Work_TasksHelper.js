({
    updateTaskOrder: function(component, plannedTasks, inProgressTasks, completedTasks) {
        var action = component.get('c.updateTaskOrderAura');
        var workId = component.get('v.workId');

        var request = {
            workId: workId,
            plannedTasks: plannedTasks,
            inProgressTasks: inProgressTasks,
            completedTasks: completedTasks
        };
        var jsonRequest = JSON.stringify(request);
        console.log(jsonRequest);

        ADM_SprintShared_Resource.showSpinner()
        action.setParams({"jsonRequest": jsonRequest});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = JSON.parse(response.getReturnValue());
                console.log(returnValue);

                var nameSpace = component.get('v.nameSpace');
                for(property in returnValue){
                      returnValue = this.serializeDataForNamespace(returnValue,property,this,nameSpace);
               }
                
                
                $A.get("e.c:ADM_Event_Update_SprintData").setParams({
                    "recordType": 'Work',
                    "data": returnValue[0]
                }).fire();
            } else if (state === "INCOMPLETE") {
                console.log('state is INCOMPLETE');
            } else if (state === "ERROR") {
                var errors = response.getError();
                ADM_Util.handleErrorWithToast(errors);
                ADM_SprintShared_Resource.hideSpinner()
            }
        });
        $A.enqueueAction(action);
    },
    
    serializeDataForNamespace:function(sprintData,currentNode,helper,nameSpace){
        if(nameSpace!=null && nameSpace!=''){
            if(typeof sprintData[currentNode] != 'object'){
                sprintData[currentNode.replace(nameSpace, '')] = sprintData[currentNode];
            }
            else{
                sprintData[currentNode.replace(nameSpace, '')] = sprintData[currentNode];
                for(innerNode in sprintData[currentNode]){
                    sprintData[currentNode] = helper.serializeDataForNamespace(sprintData[currentNode],innerNode,helper,nameSpace);
                }
            }
        }
        return sprintData;
    },
    

    createNewTask: function(component, taskColName, taskColStatus, workId) {
        if (!component || !taskColName || !taskColStatus || !workId) {
            return;
        }

        var action = component.get("c.getUserInfoAura");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var userInfo = response.getReturnValue();
                var taskCol = component.get("v." + taskColName);

                if (typeof userInfo === 'string') {
                    userInfo = JSON.parse(userInfo);
                }

                var newTask = {
                    Assigned_To__r: userInfo,
                    Hours_Remaining__c: 0,
                    Subject__c: "",
                    Order__c: taskCol && taskCol.length ? (taskCol.length + 1) : 0,
                    Capex_Enabled__c: false,
                    Work__r: {},
                    Status__c: taskColStatus,
                    Work__c: workId,
                    newTask: true // this gets set here, but overridden when the task gets saved
                };

                newTask.Work__r.Capex_Enabled__c = component.get("v.workIsCapex");

                var updatedColumn = taskCol.concat(newTask);

                if (newTask.Order__c == 5) {
                   component.set('v.' + taskColName + 'Collapsed', false);
                }

                component.set('v.' + taskColName, updatedColumn);
            }
        });

        $A.enqueueAction(action);
    }
})