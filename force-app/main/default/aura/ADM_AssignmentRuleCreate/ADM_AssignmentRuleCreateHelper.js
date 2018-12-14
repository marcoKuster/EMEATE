({
	navigateToView : function(component, destination, attributes, auraId) {
        $A.createComponent(
            destination,
            attributes || {},
            function(view){
                if(component.isValid() && auraId) {
                    var content = component.find(auraId);
               		content.set("v.body", view);
               }
            }
        );
	}
})