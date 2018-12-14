({

    showToast : function(component, event, helper) {
        console.log('Showimg toast');
        var toggleText = component.find("toggleId");
        $A.util.removeClass(toggleText, "slds-hide");  
    },
    
    closeToast : function(component, event, helper) {
        console.log('inhere');
        var toggleText = component.find("toggleId");
        $A.util.addClass(toggleText, "slds-hide");  
    }
})