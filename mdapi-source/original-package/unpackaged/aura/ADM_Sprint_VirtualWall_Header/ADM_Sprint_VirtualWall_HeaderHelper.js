({
    filtersExist: function(sprintData) {
        return Object.keys(ADM_SprintShared_Resource.getCurrTeamFilters(sprintData)).length;
    },
    getNumVisibleWork: function (component) {
        var sprintData = component.get('v.sprintData');
        if (!sprintData || !sprintData.sprintWork) {
            return 0;
        }

        return sprintData.sprintWork.filter(function(work) {
            return work.visible
        }).length;
    },
    updateNumVisibleWork: function (component) {
        var _helper = this;
        var sprintData = component.get('v.sprintData');
        if (!sprintData) {
            return;
        }
        var numVisibleWork = _helper.getNumVisibleWork(component);
        component.set('v.numVisibleWork', numVisibleWork);

    },
    updateFilterString: function (component, event, helper) {
        var _helper = this;
        window.setTimeout($A.getCallback(function() {
            var filterString = '';
            var sprintData = component.get('v.sprintData');
            if (!sprintData) {
                return;
            }
            var teamId = sprintData.sprintInfo.Scrum_Team__c;
            if(helper.filtersExist(sprintData)) {
                filterString = _helper.makeFilterStringFromFilterObj(sprintData.wallPreferences.teams[teamId].filters);
            }

            if (filterString !== component.get('v.filterString')) {
                component.set('v.filterString', filterString);
            }
        }), 0);
    },
    makeFilterStringFromFilterObj: function(filters) {
        var _helper = this;
        if (!filters || Object.keys(filters).length === 0) {
            return '';
        }
        return Object.keys(filters).reduce(function(acc, curr, keyIdx) {
            filters[curr].forEach(function(item, idx) {
                if (idx === 0) {
                    acc = acc.concat(_helper.makeDisplayableFilterKey(curr) + ': ');
                }
                if (typeof item === 'object') {
                    if (idx === 0) {
                        acc = acc.concat(' ' + item.label)
                    } else {
                        acc = acc.concat(', ' + item.label)
                    }
                } else {
                    if (idx === 0) {
                        acc = acc.concat(' ' + item)
                    } else {
                        acc = acc.concat(', ' + item)
                    }
                }

                if (filters[curr].length === idx + 1 && Object.keys(filters).length !== keyIdx + 1 ) {
                    acc = acc.concat(' | ');
                }
            })
            return acc;
        }, '');
    },
    makeDisplayableFilterKey: function(key) {
        if (key === 'Capex_Enabled__c') {
            return 'New Customer Facing Feature'; // special case
        }
        return this.capitalize(key.split('__')[0].split('.')[0]);
    },
    capitalize: function(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    },
    goToSprintListView: function(component) {
        var action = component.get("c.getSprintListView");
        var sprintData = component.get('v.sprintData');
        var nameSpace = sprintData.nameSpace;
        var scope = nameSpace+'ADM_Sprint__c'
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listview = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listview.Id,
                    "listViewName": "All",
                    "scope": scope
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    updateUserPref: function(component, field, fieldVal) {
        if (component.isValid() && component.get('v.sprintData') && component.get('v.sprintData').userPreferences) {
            var sprintData = component.get('v.sprintData');

            // only execute if the value has changed
            if (sprintData.userPreferences[field] != fieldVal) {
                //update the local user pref value
                var updateUserPref = $A.get("e.c:ADM_Event_Update_User_Pref");
                updateUserPref.setParams({"field" : field, "value" : fieldVal});
                updateUserPref.fire();


                 //Setting the field with the namespace so save works on package.
                var nameSpace = sprintData.nameSpace;
                if(nameSpace!=null && nameSpace!=''){
                    field = nameSpace+field;
                } 
                
                 
                //update user pref on the server
                var userPrefParams = {}
                userPrefParams['Id'] = sprintData.userPreferences.Id;
                userPrefParams[field] = fieldVal;

                var action = component.get("c.saveUserPreference");
                action.setParams({"jsonStr": JSON.stringify(userPrefParams)});
                $A.enqueueAction(action);
            }
        }
    },
    refreshUsersAndNumVisibleWork: function(component, helper) {
        var usersInHeader = component.get('v.users');
        var sprintData = component.get('v.sprintData');
        if (sprintData) {
            var usersOnWall = ADM_SprintShared_Resource.getUsersForFiltering(sprintData.sprintWork);
            var usersInFilter = ADM_SprintShared_Resource.getCurrTeamFilters(sprintData).users;
            var usersWhoShouldBeInHeader = usersOnWall.slice();

            // if there's a user in the filter who is not in the header, add them.
            if (usersInFilter) {
                var usersInFilterIds = usersInFilter.map(function(user) {return user.val});
                var usersOnWallIds = usersOnWall.map(function(user) {return user.Id});
                usersInFilterIds.forEach(function(userId, idx) {
                    if (usersOnWallIds.indexOf(userId) === -1) {
                        var userToAddToHeader = {Id: usersInFilter[idx].val, Name: usersInFilter[idx].label, initials: ADM_SprintShared_Resource.getInitials(usersInFilter[idx].label)};
                        usersWhoShouldBeInHeader = usersWhoShouldBeInHeader.concat(userToAddToHeader);
                    }
                });
            } else {
                component.set('v.users', usersWhoShouldBeInHeader);
            }

            // Need setTimeout just in case v.users got updated above.
            window.setTimeout($A.getCallback(function() {
                var usersInHeaderIds = ADM_Util.getIds(usersInHeader);
                var usersWhoShouldBeInHeaderIds = ADM_Util.getIds(usersWhoShouldBeInHeader);

                if (!ADM_Util.arraysEqual(usersInHeaderIds, usersWhoShouldBeInHeaderIds)) {
                    component.set('v.users', usersWhoShouldBeInHeader)
                }
                if (helper.getNumVisibleWork(component) !== component.get('v.numVisibleWork')) {
                    helper.updateNumVisibleWork(component);
                }
            }))
        }
    },

    getSprintWorkCommitment: function(component) {
        var action = component.get("c.getSprintWorkCommitment");
        var sprintData = component.get("v.sprintData");

        action.setParams({sprintId : sprintData.sprintInfo.Id});

        action.setCallback(this, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                component.set('v.sprintCommitment', JSON.parse(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    
    handleChatterSidebarInitialization: function(component) {
        if (component.isValid()) {
            var sprintData = component.get("v.sprintData");
            if (sprintData
                && sprintData.userPreferences
                && sprintData.userPreferences.ShowChatteronVirtualWall__c
                && component.find('sprint-header-chatter-button')
                && component.find('sprint-header-chatter-button').getElement()
            ) {
                component.find('sprint-header-chatter-button').getElement().click();
            }
        }
    }
})