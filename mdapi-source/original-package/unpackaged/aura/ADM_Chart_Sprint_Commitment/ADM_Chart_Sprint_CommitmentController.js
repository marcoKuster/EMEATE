({
	doInit : function(component, event, helper) {
		helper.getTotalSprintsWithCommitmentsAura(component, event, helper);
	},
	updateChart: function(component, event, helper) {
		helper.getCurrSprintsAura(component, event, helper);
	}
})