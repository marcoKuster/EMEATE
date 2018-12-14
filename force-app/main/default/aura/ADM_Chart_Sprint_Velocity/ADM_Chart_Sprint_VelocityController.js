({
	doInit : function(component, event, helper) {
		helper.getTotalSprintsAura(component, event, helper);
	},
	updateChart: function(component, event, helper) {
		helper.getCurrSprintsAura(component, event, helper);
	}
})