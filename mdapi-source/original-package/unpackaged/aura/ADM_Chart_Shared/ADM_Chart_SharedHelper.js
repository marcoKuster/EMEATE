({
	displayChart: function(component, event, helper) {
		var errorMessageElement = component.find('error-message');
		var chartElement = component.find('chart');

		if (errorMessageElement) {
			$A.util.addClass(errorMessageElement, 'slds-is-collapsed');
			$A.util.removeClass(errorMessageElement, 'slds-is-expanded');
		}

		if (chartElement) {
			$A.util.addClass(chartElement, 'slds-show');
			$A.util.removeClass(chartElement, 'slds-hide');
		}
	},
	displayErrorMessage: function(component, event, helper) {
		var errorMessageElement = component.find('error-message');
		var chartElement = component.find('chart');

		if (errorMessageElement) {
			$A.util.addClass(errorMessageElement, 'slds-is-expanded');
			$A.util.removeClass(errorMessageElement, 'slds-is-collapsed');
		}

		if (chartElement) {
			$A.util.addClass(chartElement, 'slds-hide');
			$A.util.removeClass(chartElement, 'slds-show');
		}
	}
})