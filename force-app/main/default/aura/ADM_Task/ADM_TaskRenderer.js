({
    afterRender: function (component, helper) {
    this.superAfterRender();
        // interact with the DOM here
        if (component.get('v.task').newTask) {
            component.find('taskSubject').getElement().focus();
        }
    }
})