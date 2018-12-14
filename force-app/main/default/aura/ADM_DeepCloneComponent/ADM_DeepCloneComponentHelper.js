({
    getWorkDetails : function(component) {
        console.log('WorkId : ',component.get("v.workId"));
        console.log('Inside work details');
        var action = component.get("c.getWorkDetails");
        action.setParams({ workId : component.get("v.workId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var workDetails = response.getReturnValue();
                var work = workDetails.workObj;
                var nameSpace = workDetails.nameSpace;
                console.log('workDetailsWithNamespace :',workDetails);

                //We do the following so that we can replace the namespace  from the properties with a ''. So for ex: tasks[0].Subject__c becomes tasks[0].Subject__c
                for(property in workDetails){
                    if(property !== 'nameSpace'){
                        for(workDetailsChild in workDetails[property]){
                            for(workDetailsInnerProperty in workDetails[property][workDetailsChild]){   
                                workDetails[property][workDetailsChild][workDetailsInnerProperty.replace(nameSpace, '')] = workDetails[property][workDetailsChild][workDetailsInnerProperty];
                            }
                        }
                    }
               }
                console.log('workDetailsWithoutNamespace : ', workDetails);

                //Set
                component.set("v.workDetails",workDetails);
                component.set("v.workObj",workDetails.workObj);  
            }
            else {
                console.log('error:' + state);
                console.log(workDetails.status);
                console.log(workDetails.errorMessage);
            }
            });
        $A.enqueueAction(action);
    },
    
    saveWork : function(component,deepCloneOptions) {
        var value = component.get("v.deepCloneOptionValue");
        console.log('Value : ',value);
        console.log('in helper');
        deepCloneOptions.workId = component.get("v.workId");
        console.log(deepCloneOptions);
        console.log('going to redirect');

        var action = component.get("c.deepCloneWork");
       
        
        action.setParams({ deepCloneOptions : deepCloneOptions});
        //action.setParams({ sampleParam : sampleParam});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State : ', state);
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('res : ', res);
                sforce.one.navigateToURL('/'+res);
            }
            else {
                console.log('error:' + state); 
                console.log('res : ', res);
            }
            });
        $A.enqueueAction(action);
    },
    
})