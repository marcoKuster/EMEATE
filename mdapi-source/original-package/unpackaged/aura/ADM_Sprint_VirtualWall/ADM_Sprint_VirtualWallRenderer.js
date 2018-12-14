({
	afterRender: function (component, helper) {
        this.superAfterRender();
        var sidebarResizeFn = function() {
			var headerWrapperContainer = component.find('headerWrapperContainer').getElement();

            if (window && headerWrapperContainer && component && component.isValid()) {
                var headerWrapperBottom = headerWrapperContainer.getBoundingClientRect().bottom;
                var sidebarHeight = window.innerHeight - headerWrapperBottom;
				var workRowsHeight = sidebarHeight - 29;

				// adjust heights for utilitybar and sidebar, if needed
				var utilityBarHeight = component.get('v.utilityBarHeight')
				if (utilityBarHeight) {
					sidebarHeight -= utilityBarHeight;
					workRowsHeight -= utilityBarHeight;
				}

                component.set('v.sidebarHeight', sidebarHeight + 'px');
				component.set('v.workRowsHeight', workRowsHeight + 'px');
            }
        };

		// have to set this on component. Can't set as attribute of "Object" type --
		// https://gus.lightning.force.com/one/one.app#/sObject/0D5B000000U7wfbKAB/view

		component._sidebarResizeFn = sidebarResizeFn;
		window.setTimeout($A.getCallback(function() {
			if (component && typeof component._sidebarResizeFn === 'function') {
				component._sidebarResizeFn();
			}
		}), 1000);
		// run this so the proper values get set when the page loads
        window.addEventListener('resize', component._sidebarResizeFn);
    },
    unrender: function (component, helper) {
		this.superUnrender();

		if (window && component && component.isValid()) {
            window.removeEventListener('resize', component._sidebarResizeFn);
        }
		delete component._sidebarResizeFn;
    }
})