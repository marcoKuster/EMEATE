({
	handleValueChange : function(component, event, helper) {
		if (typeof Chart !== 'undefined') { // Chart is the Chart.js global variable
			helper.updateChart(component, event, helper)
		}
	}
})