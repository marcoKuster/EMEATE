({
	doInit: function(component, event, helper) {
		helper.setUtilityBarHeight(component);
	},
	toggleSidebar : function(component, event, helper) {
        var sidebar = event.getParam("sidebar");

        if (sidebar != '') {
            component.set('v.sidebarOpen', true);
        } else {
            component.set('v.sidebarOpen', false);
        }
    },
	locationChangeHandler : function(component, event, helper) {
		window.removeEventListener('resize', component._sidebarResizeFn);
    }
})