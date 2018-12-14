({
    openModal : function(component, event, helper) {
        if (event.getParam("modalName") != 'ADM_Work_Modal') return;
        
        var data = event.getParam("modalData");
        component.set("v.workData", data);
        /*
         * Dynamically creating this force:recordEdit is the way to go here. BUt there is currently a known bug.
         * http://salesforce.stackexchange.com/questions/148634/dynamically-created-component-with-auraid-set-as-a-facet-inside-a-parent-compo/148845#148845
         * https://gus.my.salesforce.com/a07B0000001DsHCIA0
         * Once these bugs are fixed we can uncomment this code
        $A.createComponent(
            "force:recordEdit",
            {
                "aura:id": "edit",
                "recordId": data
            },
            function(recordEdit, status, errorMessage) {
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(recordEdit);
                    component.set("v.body", body);
                    //alert('success');
                    //document.querySelector('.spinner-container').classList.add('slds-hide');
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        } else {
                            console.log("Error: " + JSON.stringify(errors));
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            }
        );
        */
        component.find('slds-modal').getElement().classList.add('slds-fade-in-open');
        document.querySelector('.slds-backdrop').classList.add('slds-backdrop--open');
        
        window.setTimeout($A.getCallback(function() {
        	var rew = component.find("recordEditWrapper");
        	
        	document.querySelector('.spinner-container').classList.add('slds-hide');
        	
        	$A.util.removeClass(rew, 'slds-hide');
        }), 1000);
    },
    
    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },
    
    save : function(component, event, helper) {
        var recordEdit = component.find("recordEdit");
        var saveEvent = recordEdit.get("e.recordSave");
        saveEvent.fire();
    },
    
    handleSaveSuccess : function(component, event, helper) {
        helper.closeModal(component);
    }
})