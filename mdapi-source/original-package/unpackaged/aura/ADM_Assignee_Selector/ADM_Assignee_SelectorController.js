({
    toggleAssigneeSelect : function (component, event, helper) {
        var assigneeContainer = component.find('assignee-selector-container');

        if (assigneeContainer) {
            var assigneeContainerElm = assigneeContainer.getElement();
            var open = component.get('v.open');
            component.set('v.open', !open);

            if (assigneeContainerElm.classList.contains('slds-is-open')) {
                assigneeContainerElm.classList.remove('slds-is-open');
            } else {
                assigneeContainerElm.classList.add('slds-is-open');
                assigneeContainerElm.focus();
            }
        }
    },

    showAssigneeSelect : function (component, event, helper) {
        window.setTimeout($A.getCallback(function() {
            var assigneeContainer = component.find('assignee-selector-container');
            if (assigneeContainer) {
                var assigneeContainerElm = assigneeContainer.getElement();
                assigneeContainerElm.classList.add('slds-is-open');
                component.set('v.open', true);
            }
        }), 200);
    },
    
    hideAssigneeSelect : function (component, event, helper) {
        window.setTimeout($A.getCallback(function() {
            var assigneeContainer = component.find('assignee-selector-container');
            if (assigneeContainer) {
                var assigneeContainerElm = assigneeContainer.getElement();
                assigneeContainerElm.classList.remove('slds-is-open');
                component.set('v.open', false);
            }
        }), 200);
    },


    setAssignee : function (component, event, helper) {
        if (component.isValid()) {
            var recordObj = component.get("v.record");
            var assigneeField = component.get("v.assigneeField");
            var recordType = component.get("v.recordType");

            var record = {
                'Id': recordObj.Id
            };

            if (recordType === "Task") {
                record.Work__c = recordObj.Work__c;
            }
            record[assigneeField] = event.getSource().get("v.value");

            helper.saveRecord(component, record, recordType, function(response) {
                if (component.isValid() && typeof response === 'object') {
                    var team = component.get("v.team");
                    var assigneeId;

                    // if we use recordTypes other than Work or Task, we need to handle them here.
                    if (recordType === 'Work' && response.m_story) {
                        assigneeId = response.m_story[assigneeField];
                    } else if (recordType === 'Task') {
                        assigneeId = record[assigneeField];
                    }

                    if (assigneeId && team) {
                        for (var i = 0, teamLen = team.length ; i < teamLen ; i++) {
                            var teamMember = team[i];
                            if (teamMember.Member_Name__r && teamMember.Member_Name__r.Id == assigneeId) {
                                component.set('v.assignee', teamMember.Member_Name__r);
                                break;
                            }
                        }
                    }
                    var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
                    if (showSpinner) {
                        showSpinner.setParams({
                            "show": false
                        })
                        showSpinner.fire();
                    }
                }
            });

            $A.util.removeClass(component, 'slds-is-open');
        }
    }
})