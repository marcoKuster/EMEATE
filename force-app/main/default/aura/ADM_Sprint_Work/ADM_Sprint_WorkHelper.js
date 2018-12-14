({
    updateWorkOrder: function(component, orderedWorkIds) {
        var action = component.get('c.updateWorkOrderAura');
        var sprintId = component.get("v.sprintData.sprintInfo.Id");
        var request = {
            workIds: orderedWorkIds,
            sprintId: sprintId
        };
        var jsonRequest = JSON.stringify(request);
        if (ADM_SprintShared_Resource) {
                ADM_SprintShared_Resource.showSpinner();
        }
        action.setParams({"jsonRequest": jsonRequest});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = JSON.parse(response.getReturnValue());
                console.log(returnValue);
                if (ADM_SprintShared_Resource) {
                        ADM_SprintShared_Resource.hideSpinner();
                }
            } else if (state === "INCOMPLETE") {
                console.log('state is INCOMPLETE');
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error('errors: ', errors);
                if (ADM_Util) {
                        ADM_Util.handleErrorWithToast(errors);
                }
                if (ADM_SprintShared_Resource) {
                        ADM_SprintShared_Resource.hideSpinner();
                }
            }
        });
        $A.enqueueAction(action);
    },
    moveWorkToEnd: function(sprintWork, id) {
        var movedWork;
        var sprintWorkWithoutMoved = sprintWork.filter(function(work) {
            if (work.m_story.Id === id) {
                movedWork = work; // side effect
                return false;
            } else {
                return true;
            }
        });
        var result = sprintWorkWithoutMoved.concat(movedWork);

        console.log(result);
        return result;
    },
    moveWorkBefore: function (sprintWork, movingId, targetId) {
        var movingWork;
        var targetWork;

        sprintWork.forEach(function(work) {
            if (work.m_story.Id === movingId) {
                movingWork = work;
            } else if (work.m_story.Id === targetId) {
                targetWork = work;
            }
        });

        var result = sprintWork.reduce(function(acc, work) {
            var workId = work.m_story.Id;

            if (workId === movingId) {
                // skip this case to effectively remove from old position.
            } else if (workId === targetId) {
                acc.push(movingWork);
                acc.push(targetWork);
            } else if (workId !== movingId) {
                acc.push(work);
            }

            return acc;
        }, []);
        console.log(result);

        return result;
    }
})