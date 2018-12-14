({
    toggleSidebar : function(component, event, helper) {
        var sidebar = event.getParam("sidebar");

        if (sidebar != '') {
            var minWidth = sidebar === 'filter' ? '300px' : '400px';
            component.set('v.component', sidebar);
            component.set('v.minWidth', minWidth);
        } else {
            component.set('v.component', '');
            component.set('v.minWidth', '0px');
        }
    }
})