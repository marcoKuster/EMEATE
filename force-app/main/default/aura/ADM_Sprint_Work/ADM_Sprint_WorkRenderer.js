({
    afterRender: function(component, helper) {
        this.superAfterRender();
        var taskHeaderRow = component.find('taskHeaderRow');
        if (taskHeaderRow) {
            taskHeaderRow.getElement().classList.add('slds-hide');
        }
    },

    unrender: function(component, helper) {
        this.superUnrender();
        if (component && component.isValid() && component.get('v.onMousemoveCB')) {
            window.removeEventListener('mousemove', component.get('v.onMousemoveCB'));
        }
    }
})