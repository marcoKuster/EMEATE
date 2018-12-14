({
	handleSprintDataInitialized: function (component, event, helper) {
		var sprintData = component.get('v.sprintData');
        var headerRowClassList = component.find("headerRow").getElement().classList;
    	var taskHeaderRowClassList = component.find("taskHeaderRow").getElement().classList;
        	
        if (sprintData && sprintData.userPreferences && !sprintData.userPreferences.ShowBacklogviewonVirtualWall__c) {
        	headerRowClassList.add("slds-hide");
            taskHeaderRowClassList.remove("slds-hide");
        }
	},
	
	afterScriptsLoaded: function(component, event, helper) {
    	var rows = component.find('workItemRows').getElement();
        var options = {
          containers: [rows],
          moves: function(el, source, handle, sibling) {
              return handle.classList.contains('draggable');
          }
        }
        var drake = dragula(options);
        var cursorX;
        var cursorY;
        var animationFrameId;
        var rafCallback = $A.getCallback(function() {
            var windowHeight = window.innerHeight;
            var buffer = 50; // num pixels at top/bottom within table to start scroll
            var rowsElm = component.find('workItemRows').getElement();
            var rowsBottom = rowsElm.getBoundingClientRect().bottom;
            var rowsTop = rowsElm.getBoundingClientRect().top;
            var scrollAbove = rowsTop + buffer;
            var scrollBelow = (rowsBottom < windowHeight ? rowsBottom : windowHeight) - buffer;

            if (cursorY < scrollAbove) { // above the table
                rowsElm.scrollTop += (0.3 * (cursorY - scrollAbove));
            } else if (cursorY > scrollBelow) { // below the table
                rowsElm.scrollTop -= (0.3 * (scrollBelow - cursorY));
            }

            animationFrameId = window.requestAnimationFrame(rafCallback);
        });
        // set CB so that its possible to removeEventListener later
        component.set('v.onMousemoveCB', $A.getCallback(function(e){
            if (drake.dragging) {
                cursorX = e.clientX;
                cursorY = e.clientY;
            }
        }));
        window.addEventListener('mousemove', component.get('v.onMousemoveCB'));

        drake.on('drop', $A.getCallback(function(el, target, source, sibling) {
            drake.cancel(true);

            var sprintData = component.get('v.sprintData');
            var newSprintWork;
            var orderedWorkIds;

            if (sibling == null && el && el.id) {
                newSprintWork = helper.moveWorkToEnd(sprintData.sprintWork, el.id);
            } else if (el && el.id && sibling && sibling.id) {
                newSprintWork = helper.moveWorkBefore(sprintData.sprintWork, el.id, sibling.id);
            }

            if (newSprintWork) {
                sprintData.sprintWork = newSprintWork;
                orderedWorkIds = sprintData.sprintWork.map(function(work) {
                    return work.m_story.Id;
                });
                sprintData.wallReordered = true;
                component.set('v.sprintData', sprintData);
                helper.updateWorkOrder(component, orderedWorkIds);
            }
            window.cancelAnimationFrame(animationFrameId);
            animationFrameId = undefined;
       }));

       // if only one record & try to drag & release outside of table, "cancel" event gets fired instead of "out"
       drake.on('cancel', $A.getCallback(function(el, container, source) {
           window.cancelAnimationFrame(animationFrameId);
           animationFrameId = undefined;
       }));

       // drag out of the table
       drake.on('out', $A.getCallback(function(el, container, source) {
           if (drake.dragging && !animationFrameId) {
               animationFrameId = window.requestAnimationFrame(rafCallback);
           }
       }));

       // drag back into the table
       drake.on('over', $A.getCallback(function() {
           window.cancelAnimationFrame(animationFrameId);
           animationFrameId = undefined;
       }));
    },

    toggleHeaderRow : function(component, event, helper) {
        var state = event.getParam("state");
        var headerRowClassList = component.find("headerRow").getElement().classList;
        var taskHeaderRowClassList = component.find("taskHeaderRow").getElement().classList;

        if (state === 'show') {
            setTimeout($A.getCallback(function() { // needed to ensure that elements are available when trying to access them.
                headerRowClassList.add("slds-hide");
                taskHeaderRowClassList.remove("slds-hide");
            }));
        } else {
            setTimeout($A.getCallback(function() { // needed to ensure that elements are available when trying to access them.
                headerRowClassList.remove("slds-hide");
                taskHeaderRowClassList.add("slds-hide");
            }));
        }
    },
    toggleSidebar : function(component, event, helper) {
        var sidebar = event.getParam("sidebar");
        var headerRowClassList = component.find("headerRow").getElement().classList;
        var taskHeaderRowClassList = component.find("taskHeaderRow").getElement().classList;

        if (sidebar != '') {
            setTimeout($A.getCallback(function() {
                headerRowClassList.add('sprint-sidebar-open');
                taskHeaderRowClassList.add('sprint-sidebar-open');
            }))
        } else {
            setTimeout($A.getCallback(function() {
                headerRowClassList.remove('sprint-sidebar-open');
                taskHeaderRowClassList.remove('sprint-sidebar-open');
            }))
        }
    }
})