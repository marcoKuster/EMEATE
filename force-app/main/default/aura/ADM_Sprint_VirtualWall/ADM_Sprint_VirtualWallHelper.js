({
    setUtilityBarHeight: function(component) {
        $A.get("e.one:getViewPort").setParams({
            callback: function(data) {
                component.set('v.utilityBarHeight', data.bottom);
            }
        }).fire();
    }
})