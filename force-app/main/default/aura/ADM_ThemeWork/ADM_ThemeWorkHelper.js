({
	getThemeAssignedWorkList : function(component) {
       
		var action = component.get("c.getWorkItemsJSON");
        action.setParams({"themeId" : component.get("v.recordId")});
		
        action.setCallback(this, function(actionResult){
         var state = actionResult.getState();
            
         if(component.isValid() && state === "SUCCESS") {
            var themeAssignedResult = JSON.parse(actionResult.getReturnValue());
             var normalisedThemWorkDataArray = [];
             if(themeAssignedResult){
                 for(var count=0; count<themeAssignedResult.works.length; count++){
                     var workIter = themeAssignedResult.works[count];
                     
                     var workObj = { 
                         Id : workIter.Id,
                         Name : workIter.Name,
                         RecordTypeName    :  workIter.RecordType.Name,
                         Assignee__c :  workIter[themeAssignedResult.nameSpace + 'Assignee__c'],
                         Subject__c    :  workIter[themeAssignedResult.nameSpace + 'Subject__c'],
                         Priority__c  :  workIter[themeAssignedResult.nameSpace + 'Priority__c'],
                         Scheduled_Build_Name__c  :  workIter[themeAssignedResult.nameSpace + 'Scheduled_Build_Name__c'],
                         Scrum_Team_Name__c  :  workIter[themeAssignedResult.nameSpace + 'Scrum_Team_Name__c'],
                         Scrum_Team__c   :  workIter[themeAssignedResult.nameSpace + 'Scrum_Team__c'],
                         Status__c   :  workIter[themeAssignedResult.nameSpace + 'Status__c'],
                      }
                     //now additional fields with reference - special care as reference can be null
                     if(workIter[themeAssignedResult.nameSpace + 'Assignee__r']){
                         workObj.Assignee__r =  {Name : workIter[themeAssignedResult.nameSpace + 'Assignee__r']['Name'], Id :  workIter[themeAssignedResult.nameSpace + 'Assignee__c']};
                     }
                      normalisedThemWorkDataArray.push(workObj);
                 }
                    
             }
             //console.log('actionReturn' , normalisedThemWorkDataArray);
             component.set("v.themeWorkData", normalisedThemWorkDataArray);
            component.set("v.sortAsc", "true");
            component.set("v.sortField", "Name");    
             component.set("v.noOfItems", normalisedThemWorkDataArray.length);
            component.set("v.displayHeader", "true");
         } else if (component.isValid() && state === "ERROR") {
         	 console.log('[getThemeAssignedWorkList] errors found... ');
             var errors = actionResult.getError();
             console.log(errors); 
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
		// Invoke the service
        $A.enqueueAction(action);        
	},
    sortBy: function(component, field){
       var sortAsc = component.get("v.sortAsc");
       var records = component.get("v.themeWorkData");
       var sortField = component.get("v.sortField");
        sortAsc = field == sortField? !sortAsc: true;
        records.sort(function(a,b){
            var aField = '';
            var bField = '';
            if(field.indexOf('__r.') > -1){
                aField = a[field.split('.')[0]];
                bField = b[field.split('.')[0]];
                aField = aField[field.split('.')[1]];
                bField = bField[field.split('.')[1]];
            }
            else{
                 aField = a[field];
                 bField = b[field];
            }
           
            var t1 = aField == bField,
                t2 = aField > bField;
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.themeWorkData", records);

    },
    openWorkEditModal: function(component, workItemId) {
        var themeId = component.get("v.recordId");
        var editPageUrl = '/apex/ADM_WorkCreateEdit?id=' + workItemId + '&retUrl=/' + themeId;
		var navigateEvt = $A.get("e.force:navigateToURL");
		navigateEvt.setParams({
			"url": editPageUrl
		});
		navigateEvt.fire();
	},
    removeThemeWorkAssignment : function(component, workId, callback) {
            var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
            showSpinner.setParams({
                "show": true
            })
            showSpinner.fire();
    
            var action = component.get("c.removeThemeWorkAssignment");
    		var themeId = component.get("v.recordId");
            action.setParams({"workId": workId,
                              "themeId": themeId
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
    			
                if (component.isValid() && state === "SUCCESS") {
                    var retVal = response.getReturnValue();
    
                    if (typeof retVal === 'boolean' && retVal) {
                        var noOfitemsCurrent = component.get("v.noOfItems");
                        noOfitemsCurrent--; //One item is removed from the theme.
                        component.set("v.noOfItems", noOfitemsCurrent);
                        var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
                        showSpinner.setParams({
                            "show": false
                        });
                        showSpinner.fire();
                    	if (callback) {
                            callback(workId);
                        }
                    }
                } else if (state === "ERROR") {
                    var errors = response.getError();
    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
    
                            toastEvent.setParams({
                                "key": "error",
                                "title": "Error",
                                "message": errors[0].message,
                                "type": "error",
                                "mode": "sticky"
                            });
    
                            toastEvent.fire();
                        } else if (errors[0] && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
    
                            toastEvent.setParams({
                                "key": "error",
                                "title": "Error",
                                "message": errors[0].pageErrors[0].message,
                                "type": "error",
                                "mode": "sticky"
                            });
    
                            toastEvent.fire();
                        } else {
                            var toastEvent = $A.get("e.force:showToast");
    
                            toastEvent.setParams({
                                "key": "error",
                                "title": "Error",
                                "message": JSON.stringify(errors),
                                "type": "error",
                                "mode": "sticky"
                            });
    
                            toastEvent.fire();
                        }
                        var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
                        showSpinner.setParams({
                            "show": false
                        });
                        showSpinner.fire();
    
                    } else {
                        console.error("Unknown error");
    
                        var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
                        showSpinner.setParams({
                            "show": false
                        });
                        showSpinner.fire();
                    }
                }
            });
            $A.enqueueAction(action);
        }
})