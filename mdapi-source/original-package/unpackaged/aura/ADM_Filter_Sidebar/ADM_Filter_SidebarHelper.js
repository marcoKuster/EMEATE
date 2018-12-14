({
    updateFilterOptions: function(component, sprintData) {
        var assignees = [];
        var qaAssignees = [];
        var recordTypes = [];
        var statuses = [];
        var themes = [];
        var newCustomerFacingFeatureOptions = [];
        var wallPreferences = component.get("v.sprintData.wallPreferences");
        var teamId = component.get("v.sprintData.sprintInfo.Scrum_Team__c");
        var filters = wallPreferences.teams[teamId].filters
        var that = this;

        sprintData.sprintWork.forEach(function(work) {
            var currentWorkRecord = work.m_story;

            if (currentWorkRecord.Assignee__r != null) {
                assignees = that.updateFilterOptionsArr(currentWorkRecord.Assignee__r.Id, currentWorkRecord.Assignee__r.Name, filters['Assignee__r.Id'], assignees);
            }
            if (currentWorkRecord.QA_Engineer__r != null) {
                qaAssignees = that.updateFilterOptionsArr(currentWorkRecord.QA_Engineer__r.Id, currentWorkRecord.QA_Engineer__r.Name, filters['QA_Engineer__r.Id'], qaAssignees);
            }
            if (currentWorkRecord.RecordType != null) {
                recordTypes = that.updateFilterOptionsArr(currentWorkRecord.RecordType.Name, currentWorkRecord.RecordType.Name, filters['RecordType.Name'], recordTypes);
            }
            if (currentWorkRecord.Status__c != null) {
                statuses = that.updateFilterOptionsArr(currentWorkRecord.Status__c, currentWorkRecord.Status__c, filters['Status__c'], statuses);
            }
            if (currentWorkRecord.Theme_Assignments__r != null && currentWorkRecord.Theme_Assignments__r.totalSize > 0) {
                var workThemes = currentWorkRecord.Theme_Assignments__r.records;

                if (workThemes) {
                    for (var t = 0, len = workThemes.length; t < len; t++) {
                        if (workThemes[t].Theme__r != null) {
                            themes = that.updateFilterOptionsArr(workThemes[t].Theme__r.Id, workThemes[t].Theme__r.Name, filters['theme'], themes);
                        }
                    }
                }
            }
            if (newCustomerFacingFeatureOptions.length == 0 && (currentWorkRecord.Capex_Enabled__c == true || (sprintData.sprintInfo != null && sprintData.sprintInfo.Scrum_Team__r != null && sprintData.sprintInfo.Scrum_Team__r.Capex_Enabled__c == true))) {
                var capexFilter = filters['Capex_Enabled__c'];
                newCustomerFacingFeatureOptions.push({
                    label: 'True',
                    value: true,
                    checked: ADM_SprintShared_Resource.valIsInFilterArr(true, capexFilter)
                });
                newCustomerFacingFeatureOptions.push({
                    label: 'False',
                    value: false,
                    checked: ADM_SprintShared_Resource.valIsInFilterArr(false, capexFilter)
                })
            }
        });

        // now loop through & add any filters which don't correspond to current sprintWork values
        // (so that users can uncheck them even if they aren't on any visible work items)
        for (var key in filters) {
            filters[key].forEach(function(filter) {
                var id;
                var label;
                if (typeof filter === 'string') {
                    id = filter;
                    label = filter;
                } else if (typeof filter === 'object') {
                    id = filter.val,
                    label = filter.label;
                }
                if (key === 'Assignee__r.Id') {
                    assignees = that.updateFilterOptionsArr(id, label, filters[key], assignees);
                } else if (key === 'QA_Engineer__r.Id') {
                    qaAssignees = that.updateFilterOptionsArr(id, label, filters[key], qaAssignees);
                } else if (key === 'RecordType.Name') {
                    recordTypes = that.updateFilterOptionsArr(id, label, filters[key], recordTypes);
                } else if (key === 'Status__c') {
                    statuses = that.updateFilterOptionsArr(id, label, filters[key], statuses);
                } else if (key === 'theme') {
                    themes = that.updateFilterOptionsArr(id, label, filters[key], themes);
                }
            })
        }

        if (newCustomerFacingFeatureOptions.length > 0) {
            component.set("v.newCustomerFacingFeatureOptions", newCustomerFacingFeatureOptions);
        }

        if (assignees.length > 0) {
            component.set("v.assignees", assignees.sort(this.sortObjectsByLabel));
        }

        if (qaAssignees.length > 0) {
            component.set("v.qaAssignees", qaAssignees.sort(this.sortObjectsByLabel));
        }

        if (recordTypes.length > 0) {
            component.set("v.recordTypes", recordTypes.sort(this.sortObjectsByLabel));
        }

        if (statuses.length > 0) {
            component.set("v.statuses", statuses.sort(this.sortObjectsByLabel));
        }

        if (themes.length > 0) {
            component.set("v.themes", themes.sort(this.sortObjectsByLabel));
        }
    },

    updateFilterOptionsArr: function(id, label, preferencesFilterArr, filterOptionsArr) {
        var that = this;
        if (!preferencesFilterArr) {
            preferencesFilterArr = [];
        }
        if (!filterOptionsArr) {
            filterOptionsArr = [];
        }
        var filterObj = {
            label: label,
            value: id,
            checked: ADM_SprintShared_Resource.valIsInFilterArr(id, preferencesFilterArr)
        };

        if (!that.arrayContainsObject(preferencesFilterArr, filterObj) && !that.arrayContainsObject(filterOptionsArr, filterObj)) {
            return filterOptionsArr.concat(filterObj);
        } else {
            return filterOptionsArr;
        }
    },

    filterWorkItems: function(component, sprintData, filters) {
        var workFiltered = {};

        sprintData.sprintWork.forEach(function(work) {
            workFiltered[work.m_story.Id] = ADM_SprintShared_Resource.isWorkItemVisible(work, filters);
        });

        var filterWork = $A.get("e.c:ADM_Event_Filter_Work");

        if (!!filterWork) {
            filterWork.setParams({"workVisibility" : workFiltered});
            filterWork.fire();
        }
    },

    arrayContainsObject: function(arr, obj) {
        if (!arr || !obj) {
            return false;
        }

        for (var i = 0, arrLen = arr.length; i < arrLen; i++) {
            if (arr[i].value == obj.value) {
                return true;
            }
        }

        return false;
    },

    sortObjectsByLabel: function(a, b) {
        return a.label.toLowerCase().localeCompare(b.label.toLowerCase());
    }
})