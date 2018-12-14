({
        updateFilterOptions : function(component, event, helper) {
            var sprintData = component.get("v.sprintData");
            console.log('sd: ', sprintData);
            if (sprintData) {
                // need to setTimeout so that filters are updated before updating options.
                setTimeout($A.getCallback(function() {
                    helper.updateFilterOptions(component, sprintData);
                }))
            }
        },

        toggleFilter : function(component, event, helper) {
            if (component.isValid()) {
                var sprintData = component.get("v.sprintData");
                var filterChecked = event.getSource().get("v.value");
                var filterField = event.getSource().get("v.name");
                var wallPreferences = sprintData.wallPreferences;
                var teamId = sprintData.sprintInfo.Scrum_Team__c;
                var filters = wallPreferences.teams[teamId].filters;
                var filterValue = event.getSource().get("v.text");
                var filterLabel = event.getSource().get("v.label");

                if (!filters[filterField]) {
                    filters[filterField] = [];
                }

                var filterValueIndex = ADM_SprintShared_Resource.getIdxInFilterArr(filterValue, filters[filterField]);

                if (filterChecked && filterValueIndex == -1) {
                    filters[filterField].push({val: filterValue, label: filterLabel});
                } else if (!filterChecked && filterValueIndex >= 0) {
                    filters[filterField].splice(filterValueIndex, 1);

                    if (filters[filterField].length == 0) {
                        delete filters[filterField];
                    }
                }

                helper.filterWorkItems(component, sprintData, filters);

                wallPreferences.teams[teamId].filters = filters;

                var action = component.get("c.setWallPreferenceJSONAura");
                action.setParams({"wallPreferences": JSON.stringify(wallPreferences)});
                $A.enqueueAction(action);
            }
        },

        clearFilters : function(component, event, helper) {
            var checkboxes = component.find("filterCheckbox");
            if (!!checkboxes) {
                var sprintData = component.get("v.sprintData");
                var checkboxesLen = checkboxes.length;
                var workFiltered = {};
                var wallPreferences = sprintData.wallPreferences;
                var teamId = sprintData.sprintInfo.Scrum_Team__c;

                sprintData.sprintWork.forEach(function(work) {
                    workFiltered[work.m_story.Id] = true;
                });

                var filterWork = $A.get("e.c:ADM_Event_Filter_Work");
                filterWork.setParams({"workVisibility" : workFiltered});
                filterWork.fire();

                wallPreferences.teams[teamId].filters = {};

                var action = component.get("c.setWallPreferenceJSONAura");
                action.setParams({"wallPreferences": JSON.stringify(wallPreferences)});
                $A.enqueueAction(action);
            }
        }
    })