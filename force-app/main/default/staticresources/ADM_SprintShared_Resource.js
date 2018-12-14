window.ADM_SprintShared_Resource = (function() {

    var isWorkItemVisible = function(work, filters) {
        var workItemVisible = true;
        var sprintWorkRecord = work.m_story;

        if (Object.keys(filters).length > 0) {
            for (var key in filters) {
                var workFieldValue;

                if (key.indexOf('.') != -1) {
                    var keys = key.split('.');
                    if (sprintWorkRecord[keys[0]] != null) {
                        workFieldValue = sprintWorkRecord[keys[0]][keys[1]];
                    } else {
                        workItemVisible = false;
                    }
                } else {
                    workFieldValue = sprintWorkRecord[key];
                }

                if (workItemVisible) {
                    if (key == "theme") {
                        if (sprintWorkRecord.Theme_Assignments__r != null && sprintWorkRecord.Theme_Assignments__r.totalSize > 0) {
                            var workThemes = sprintWorkRecord.Theme_Assignments__r.records;
                            var workContainsFilterTheme = false;

                            var themesLen = workThemes.length;

                            for (var t=0 ; t < themesLen ; t++) {
                                if (!workContainsFilterTheme) {
                                    if (workThemes[t].Theme__r != null && ADM_SprintShared_Resource.valIsInFilterArr(workThemes[t].Theme__r.Id, filters[key])) {
                                        workContainsFilterTheme = true;
                                    }
                                }
                            }

                            if (workContainsFilterTheme) {
                                workItemVisible = true;
                            } else {
                                workItemVisible = false;
                            }
                        } else {
                            workItemVisible = false;
                        }
                    } else if (key == 'users') {
                        workItemVisible = atLeastOneUserInFilter(work, filters[key]);
                    } else if (ADM_SprintShared_Resource.valIsInFilterArr(workFieldValue, filters[key])) {
                        workItemVisible = true;
                    } else {
                        workItemVisible = false;
                    }
                }
            }
        }

        return workItemVisible;
    }

    var isString = function(val) {
        return typeof val === 'string';
    }

    var isObj = function(val) {
        return typeof val === 'object';
    }

    var isArr = function(val) {
        return Array.isArray(val);
    }

    var isBool = function(val) {
        return typeof val === 'boolean';
    }

    var valIsInFilterArr = function(val, filterArr) {
        return typeof val != null && filterArr && ADM_SprintShared_Resource.getIdxInFilterArr(val, filterArr) !== -1;
    }

    var getIdxInFilterArr = function(value, filterArr) {
        for (var i = 0; i < filterArr.length; i++) {
            if (ADM_SprintShared_Resource.matchesFilterValue(value, filterArr[i])) {
                return i;
            }
        }

        return -1;
    }

    var matchesFilterValue = function(value, filterValue) {
        // for backwords compatibility:
        // We used to just store "value", now we store {val: 'value', label: 'label'},
        // so we need to check it both ways
        return ADM_SprintShared_Resource.isObj(filterValue) ?
            filterValue.val === value
            : filterValue === value
    }

    var createUserMap = function(works) {
        // takes in works array & returns a map of users with the Id as the key and the val as the user object.
        var userMap = {};

        if (!works || !ADM_SprintShared_Resource.isArr(works)) {
            return userMap;
        }

        var updateUserMap = function(user, userMap) {
            if (!user || !user.Id) {
                return userMap;
            }
            if (!userMap[user.Id]) {
                userMap[user.Id] = user;
            }
            return userMap
        };

        works.forEach(function(work) {
            work.m_plannedTasks.tasks.forEach(function(task) {
                userMap = updateUserMap(task.Assigned_To__r, userMap);
            })
            work.m_inProgressTasks.tasks.forEach(function(task) {
                userMap = updateUserMap(task.Assigned_To__r, userMap);
            })
            work.m_completedTasks.tasks.forEach(function(task) {
                userMap = updateUserMap(task.Assigned_To__r, userMap);
            })
            if (work.m_story && work.m_story.Assignee__r) {
                userMap = updateUserMap(work.m_story.Assignee__r, userMap);
            }
            if (work.m_story && work.m_story.QA_Engineer__r) {
                userMap = updateUserMap(work.m_story.QA_Engineer__r, userMap);
            }
        })

        return userMap;
    };

    var getUsersForFiltering = function(works) {
        // takes in works array & returns sorted users.
        var _helper = this;
        if (!works || !ADM_SprintShared_Resource.isArr(works)) {
            return;
        }
        var userMap = createUserMap(works);

        var addUserToMap = function(users, userId) {
            return users.concat(userMap[userId])
        };

        var sortUsersByName = function(a, b) {
            return a.Name.toLowerCase().localeCompare(b.Name.toLowerCase())
        };

        return Object.keys(userMap)
            .reduce(addUserToMap, [])
            .sort(sortUsersByName)
    }

    var getCurrTeamFilters = function(sprintData) {
        return sprintData
            && sprintData.sprintInfo
            && sprintData.sprintInfo.Scrum_Team__c
            && sprintData.wallPreferences
            && sprintData.wallPreferences.teams
            && sprintData.wallPreferences.teams[sprintData.sprintInfo.Scrum_Team__c]
            && sprintData.wallPreferences.teams[sprintData.sprintInfo.Scrum_Team__c].filters
                ? sprintData.wallPreferences.teams[sprintData.sprintInfo.Scrum_Team__c].filters
                : {}
    }

    var getInitials = function(name) {
        if (!name) {
            return '';
        }
        var lastSpaceIdx = name.lastIndexOf(' ');
        // if there's no space in the name, we'll just use the first letter of the first name.
        if (lastSpaceIdx === -1) {
            return name[0];
        }
        var firstInitial = name.slice(0, lastSpaceIdx)[0];
        var lastInitial = name.slice(lastSpaceIdx + 1, name.length)[0]
        return firstInitial + lastInitial;
    }

    var atLeastOneUserInFilter = function(work, filter) {
        var users = getUsersForFiltering([work]);
        for (var i = 0, len = users.length ; i < len ; i++) {
            for (var j = 0, jLen = filter.length ; j < jLen ; j++) {
                if (users[i].Id === filter[j].val) {
                    return true;
                }
            }
        }
        return false;
    }

    // you may only be able to use this if you register the event in the component youre calling it from
    var showSpinner = function() {
        var showSpinner = $A.get("e.agf:ADM_Event_Show_Spinner");
        if (showSpinner) {
            showSpinner.setParams({
                "show": true
            });
            showSpinner.fire();
        }
    }

    // you may only be able to use this if you register the event in the component youre calling it from
    var hideSpinner = function() {
        var showSpinner = $A.get("e.agf:ADM_Event_Show_Spinner");
        if (showSpinner) {
            showSpinner.setParams({
                "show": false
            });
            showSpinner.fire();
        }
    }

    return {
        isWorkItemVisible: isWorkItemVisible,
        isString: isString,
        isObj: isObj,
        isArr: isArr,
        isBool: isBool,
        valIsInFilterArr: valIsInFilterArr,
        getIdxInFilterArr: getIdxInFilterArr,
        matchesFilterValue: matchesFilterValue,
        getUsersForFiltering: getUsersForFiltering,
        getCurrTeamFilters: getCurrTeamFilters,
        getInitials: getInitials,
        showSpinner: showSpinner,
        hideSpinner: hideSpinner
    }

}());
