({
    
    doInitPicker : function(component, event, helper) {
        console.log(component.get('v.workId'));
        helper.getWorkDetails(component);  
    },
    
    openSummary : function(component, event, helper){
        $('.closeSummary').hide();
        $('.openSummary').show();
    },
    
    closeSummary : function(component, event, helper){
        $('.openSummary').hide();
        $('.closeSummary').show();
    },
    
    openTheme : function(component, event, helper){
        $('.closeTheme').hide();
        $('.openTheme').show();
    },
    
    closeTheme : function(component, event, helper){
        $('.openTheme').hide();
        $('.closeTheme').show();
    },
    
    openAc : function(component, event, helper){
        $('.closeAc').hide();
        $('.openAc').show();
    },
    
    closeAc : function(component, event, helper){
        $('.openAc').hide();
        $('.closeAc').show();
    },
    openTasks : function(component, event, helper){
        $('.closeTasks').hide();
        $('.openTasks').show();
    },
    
    closeTasks : function(component, event, helper){
        $('.openTasks').hide();
        $('.closeTasks').show();
    },
    openParent : function(component, event, helper){
        $('.closeParent').hide();
        $('.openParent').show();
    },
    
    closeParent : function(component, event, helper){
        $('.openParent').hide();
        $('.closeParent').show();
    },
    openChild : function(component, event, helper){
        $('.closeChild').hide();
        $('.openChild').show();
    },
    
    closeChild : function(component, event, helper){
        $('.openChild').hide();
        $('.closeChild').show();
    },
    saveWork: function(component, event, helper){
        console.log('here inside save');
        $('.saveButtonClass').hide();
        $('.spinner').show();
        var deepCloneOptions = {};
        
        var isTheme = $('.themeCheckBox').is(':checked');
        deepCloneOptions.isTheme = isTheme;
        var isAc = $('.acCheckBox').is(':checked');
        deepCloneOptions.isAc = isAc;
        var isTasks = $('.taskCheckBox').is(':checked');
        deepCloneOptions.isTasks = isTasks;
        var isParent = $('.parentCheckBox').is(':checked');
        deepCloneOptions.isParent = isParent;
        var isChild = $('.childCheckBox').is(':checked');
        deepCloneOptions.isChild = isChild;
        var parentSelect = component.find('parentSelect').get('v.value');
        deepCloneOptions.parentSelect = parentSelect+'';
        var childSelect = component.find('childSelect').get('v.value');
        deepCloneOptions.childSelect = childSelect+'';
        console.log(deepCloneOptions);
        component.set("v.deepCloneOptionValue",deepCloneOptions);
        helper.saveWork(component,deepCloneOptions); 
    },
    
    viewWorkRecord: function(component,event) {
      console.log('inside helper component:');  
      console.log(event);
      console.log(event.srcElement);
      var recId = component.get("v.workId");
      console.log(recId);
      var navEvt = $A.get("e.force:navigateToSObject");
      navEvt.setParams({
      "recordId": recId,
          "slideDevName": "detail"
      });
      navEvt.fire();
    },
    
    viewRecord: function(component,event) {
      console.log('inside helper component:');  
      console.log('inside helper component:');      
      var record = event.srcElement;
        console.log(record);
      var recId = record.id;
        console.log(record.id);
        sforce.one.navigateToURL('/'+recId);
    },
    toggle : function(component, event, helper) {
        var toggleText = component.find("deepCloneWizard");
        $A.util.toggleClass(toggleText, "toggle");

    }

})