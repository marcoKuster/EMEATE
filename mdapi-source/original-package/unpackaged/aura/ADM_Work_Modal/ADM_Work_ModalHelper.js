({
	closeModal : function(component) {
        //component.set("v.body", ""); use this when dynamically loading force:recordEdit component
        component.set("v.workData", '');
        
        component.find('slds-modal').getElement().classList.remove('slds-fade-in-open');
        document.querySelector('.slds-backdrop').classList.remove('slds-backdrop--open');
        document.querySelector('.spinner-container').classList.remove('slds-hide');
        
        var rew = component.find("recordEditWrapper");
        $A.util.addClass(rew, 'slds-hide');
    }
})