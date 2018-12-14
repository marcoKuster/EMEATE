({
	selectUser: function (component, event, helper) {
        var user = component.find('user-button');
        var userElm = user.getElement();
        var id = userElm.getAttribute('id');
       	var name = userElm.getAttribute('title');
        var sprintData = component.get('v.sprintData');
		var selected = $A.util.hasClass(user, 'avatar-selected') ? false : true;

		$A.util.toggleClass(user, 'avatar-selected');
        userElm.blur();

        // update filters
        var teamId = sprintData.sprintInfo.Scrum_Team__c;
        if (!sprintData.wallPreferences.teams[teamId]) {
            sprintData.wallPreferences.teams[teamId] = {};
        };
        if (!sprintData.wallPreferences.teams[teamId].filters) {
            sprintData.wallPreferences.teams[teamId].filters = {}
        };
        if (!sprintData.wallPreferences.teams[teamId].filters.users) {
            sprintData.wallPreferences.teams[teamId].filters.users = [];
        }
        // more than one at once
		// var addOrRemoveUserFromUsers = function(id, name, users) {
        //     if (!users) {
        //         users = [];
        //     }
        //     var user = {label: name, val: id};
        //     var updatedUsers;
        //     if (selected) {
        //         updatedUsers = users.concat(user);
        //     } else {
        //         updatedUsers = users.filter(function(item) {return item.val !== user.val})
        //     }
        //     return updatedUsers;
        // }
        // sprintData.wallPreferences.teams[teamId].filters.users = addOrRemoveUserFromUsers(id, name, sprintData.wallPreferences.teams[teamId].filters.users);
		// end more than one at once

        // only one at once
        sprintData.wallPreferences.teams[teamId].filters.users = selected ? [{label: name, val: id}] : [];

		// remove assignee when user is clicked
        if (sprintData.wallPreferences.teams[teamId].filters['Assignee__r.Id']) {
            delete sprintData.wallPreferences.teams[teamId].filters['Assignee__r.Id']
        }
		// remove qa when user is clicked
        if (sprintData.wallPreferences.teams[teamId].filters['QA_Engineer__r.Id']) {
            delete sprintData.wallPreferences.teams[teamId].filters['QA_Engineer__r.Id']
        }
		// delete users from filters if empty
        if (sprintData.wallPreferences.teams[teamId].filters['users'] && !sprintData.wallPreferences.teams[teamId].filters['users'].length) {
            delete sprintData.wallPreferences.teams[teamId].filters['users']
        }

        var workFiltered = {};
        sprintData.sprintWork.forEach(function(work) {
            workFiltered[work.m_story.Id] = ADM_SprintShared_Resource.isWorkItemVisible(work, sprintData.wallPreferences.teams[teamId].filters);
        });

        var filterWork = $A.get("e.c:ADM_Event_Filter_Work");

        if (!!filterWork) {
            filterWork.setParams({"workVisibility" : workFiltered});
            filterWork.fire();
        }

        var action = component.get("c.setWallPreferenceJSONAura");
        action.setParams({"wallPreferences": JSON.stringify(sprintData.wallPreferences)});
        $A.enqueueAction(action);

        component.set('v.sprintData.wallPreferences', sprintData.wallPreferences);
    },
    filtersUpdated: function (component, event, helper) {

		// make sure filters are updated before running this.
		window.setTimeout($A.getCallback(function() {
			var sprintData = component.get('v.sprintData');
	        var userBtn = component.find('user-button');
			var filters = ADM_SprintShared_Resource.getCurrTeamFilters(sprintData);

	        if (filters.users) {
				var userInFilter = filters.users.filter(function(filter) {
					return filter.val === component.get('v.user.Id')
				}).length;
				// if the user is in the filter, add class. Otherwise don't.
	            if (userInFilter) {
	                $A.util.addClass(userBtn, 'avatar-selected')
	            } else {
	                if ($A.util.hasClass(userBtn, 'avatar-selected')) {
	                    $A.util.removeClass(userBtn, 'avatar-selected')
	                }
	            }
	        } else {
				if ($A.util.hasClass(userBtn, 'avatar-selected')) {
					$A.util.removeClass(userBtn, 'avatar-selected')
				}
			}
		}))
    }
})