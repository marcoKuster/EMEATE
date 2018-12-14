({
	openModal : function(component, event, helper) {
        if (event.getParam("modalName") != 'ADM_Sprint_Modal') return;
        
        var data = event.getParam("modalData");
        component.set("v.sprintInfo", data);
        
		var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({"recordId": data.Id});
        editRecordEvent.fire();
	}
})