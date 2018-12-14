({
    onMouseover: function(cmp, event, helper) {
        if (cmp.isValid()) {
            var tooltip = cmp.find('tooltip');

            helper.makePositionFromNubbinClass(cmp, event, helper);
            cmp.set('v.hovered', true);
			cmp.set('v.ariaHidden', "false");
        }
    },
    onMouseout: function(cmp, event, helper) {
        if (cmp.isValid()) {
			var tooltip = cmp.find('tooltip')

            cmp.set('v.hovered', false);
            cmp.set('v.ariaHidden', "true");
        }
    }
})