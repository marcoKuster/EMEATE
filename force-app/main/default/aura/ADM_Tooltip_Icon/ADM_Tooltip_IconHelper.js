({
	makePositionFromNubbinClass: function(cmp, event, helper) {
		var nubbinClass = cmp.get('v.nubbinClass');

		if (nubbinClass === 'slds-nubbin--bottom-left') {
			var tooltipStyle = 'position:absolute;bottom:150%;margin-left:-2rem;min-width:10rem;max-width:10rem;';
			cmp.set('v.tooltipStyle', tooltipStyle);
		} else if (nubbinClass === 'slds-nubbin--bottom-right') {
			var tooltipStyle = 'position:absolute;bottom:150%;margin-left:-9rem;min-width:10rem;max-width:10rem;';
			cmp.set('v.tooltipStyle', tooltipStyle);
		}
	}
})