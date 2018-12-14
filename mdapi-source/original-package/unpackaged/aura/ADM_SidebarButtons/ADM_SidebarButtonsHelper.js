({
    handleUpdatedFilters: function(component) {
        var _helper = this;

        var sprintData = component.get('v.sprintData');

        if (sprintData && _helper.filtersExist(sprintData)) {
            var filterButton = component.find('sprint-header-filter-button').getElement();
            filterButton.classList.add('sprint-button-tristate');
        } else {
            var filterButton = component.find('sprint-header-filter-button').getElement();
            filterButton.classList.remove('sprint-button-tristate');
        }
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
    },

    filtersExist: function(sprintData) {
        return Object.keys(ADM_SprintShared_Resource.getCurrTeamFilters(sprintData)).length;
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
    }
})