({
    getSprintDataAndStream: function(component, event, helper, sprintIdParam) {
        var action,
            helper = this,
            sprintId = component.get("v.recordId");

        if (sprintIdParam && sprintIdParam != sprintId) {
            return;
        }
        
        if (!sprintId) {
            helper.goToSprintListView(component);
        }

        action = component.get("c.getSprintJSON");

        action.setParams({sprintId : sprintId});
            
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var sprintData = response.getReturnValue();

                if (typeof sprintData === 'string') {
                    sprintData = JSON.parse(sprintData);
                }
                console.log(sprintData);

                //Deserialize here
                var nameSpace = sprintData.nameSpace;
                for(property in sprintData){
                     sprintData = helper.serializeSprintDataForNamespace(sprintData,property,helper,nameSpace);
                }
                
                console.log('SprintData serialized : ', sprintData);
                    
                if (typeof sprintData.wallPreferences === 'string') {
                    sprintData.wallPreferences = JSON.parse(sprintData.wallPreferences);
                }

                if (!sprintData.wallPreferences) {
                    sprintData.wallPreferences = {};
                }

                if (!sprintData.wallPreferences.teams) {
                    sprintData.wallPreferences.teams = {};
                }

                if (!sprintData.wallPreferences.teams[sprintData.sprintInfo.Scrum_Team__c]) {
                    sprintData.wallPreferences.teams[sprintData.sprintInfo.Scrum_Team__c] = {};
                }

                if (!sprintData.wallPreferences.teams[sprintData.sprintInfo.Scrum_Team__c].filters) {
                    var defaultFilters = {'Status__c' : ['New', 'Triaged', 'In Progress', 'Ready for Review', 'Fixed',
                    'QA In Progress', 'Waiting', 'Integrate', 'Pending Release', 'Acknowledged', 'Investigating',
                    'More Info Reqd From Support', 'Deferred']};

                    sprintData.wallPreferences.teams[sprintData.sprintInfo.Scrum_Team__c].filters = defaultFilters;
                }

                component.set("v.sprintData", sprintData);
                component.set("v.nameSpace", nameSpace);
                component.set("v.sprintId", sprintData.sprintInfo.Id);
                $A.get("e.c:ADM_Event_Update_PlannedVelocity").setParams({
                    "velocity": sprintData.plannedVelocity
                }).fire();

                $A.get("e.c:ADM_Event_SprintData_Initialized").fire();

                helper.openCometDConnection(component);
                helper.initializeTimers(component);
                
                helper.hideSpinner();
            } else if (state === "ERROR") {
                helper.goToSprintListView(component);
            }
        });

        $A.enqueueAction(action);
    },
    
    serializeSprintDataForNamespace:function(sprintData,currentNode,helper,nameSpace){
        if(nameSpace != null && nameSpace!=''){
            if(typeof sprintData[currentNode] != 'object'){
                sprintData[currentNode.replace(nameSpace, '')] = sprintData[currentNode];
            }
            else{
                sprintData[currentNode.replace(nameSpace, '')] = sprintData[currentNode];
                for(innerNode in sprintData[currentNode]){
                    sprintData[currentNode] = helper.serializeSprintDataForNamespace(sprintData[currentNode],innerNode,helper,nameSpace);
                }
            }
        }
        
        return sprintData;
    },
    
    openCometDConnection : function(component) {
        if (!$.cometd.isDisconnected()) {
            $.cometd.disconnect();
        }

        var action = component.get("c.getSessionId");
        var helper = this;
        action.setCallback(this, function(a) {
            var sid = a.getReturnValue();
            var topics = component.get('v.topics');
            var apiVersion = component.get('v.apiVersion');

            //init connection
            $.cometd.configure({
               url: '/cometd/'+apiVersion+'.0',
               requestHeaders: { Authorization: 'OAuth '+sid},
               appendMessageTypeToURL: false,
            });

            var metaHandshake = $.cometd.addListener('/meta/handshake', function(message) {
                if(message.successful === false) {
                    console.log('Unable to connect to streaming API' + ((message.error) ? (': ' + message.error):''));
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"error",
                        "title": "Disconnected",
                        "mode": "Sticky",
                        "message": "The page has been disconnected and is no longer receiving updates. Please reload the page to continue."
                    });
                    toastEvent.fire();
                }
                else{
                    console.log(' successfully handshaked');
                }
            });
            var _connected = false;
            var metaDisconnect = $.cometd.addListener('/meta/disconnect', function(message) {
                if(message.successful == true) {
                    console.log('Streaming api disconnected');
                     _connected = false;
                     
                     helper.removeStreamListeners([metaHandshake, metaDisconnect, metaUnsuccessful, metaConnect], $.cometd);
                }
            });

            var metaUnsuccessful = $.cometd.addListener('/meta/unsuccessful', function(message) {
                console.info('/meta/unsuccessful: ', message);
                _connected = false;
            });

            var metaConnect = $.cometd.addListener('/meta/connect', function(message){
                if ($.cometd.isDisconnected()) {// Available since 1.1.2
                    _connected = false;
                    return;
                }
                var wasConnected = _connected;
                _connected = (message.successful == true);
                
                if (!wasConnected && _connected) {
                    console.log('Streaming api -- Connected')
                } else if (wasConnected && !_connected) {
                    console.log('Streaming api -- Disconnected ')
                    var sprintId = component.get("v.sprintId");
                    
                    if (window && window.location && window.location.href && window.location.href.indexOf(sprintId) !== -1) {
                        console.log('*** Reconnecting to streaming api ***');
                        helper.removeStreamListeners([metaHandshake, metaDisconnect, metaUnsuccessful, metaConnect], $.cometd);

                        helper.openCometDConnection(component);
                }
                }
            });

            $.cometd.handshake();
            $(document).trigger('cometd-init', $.cometd);

            $.cometd.batch(function(){
                var sprintId = component.get("v.sprintId");
                var nameSpace = component.get("v.nameSpace");
                var debouncedHandleStreamedMessage = helper.debounce(helper.handleStreamedMessage, 50);
                var userInfo = component.get('v.userInfo');

                // workUpdatesTwo and workUpdatesOne (etc) are required b/c the syntax in different orgs needed to subscribe
                // to the streaming api is different. ( /topic/foo?bar=1 VS /topic/foo?bar=='1'
                // seems to be important to set up the == subscribe syntax first, then the = syntax.

                var workUpdatesTwo = $.cometd.subscribe('/topic/WorkUpdates?'+nameSpace+'Sprint__c==\''+sprintId +'\'', $A.getCallback(function(message) {
                    // when I tried unsubscribing like this, we'd be unsubscribed from the pushTopic after the first time this callback was called,
                    // so this didn't work. - AB 5/3/17
                    // if (workUpdatesOne) {
                    //     $.cometd.unsubscribe(workUpdatesOne);
                    // }
                    //Serialize
                    var objectDetails = message.data.sobject;
                    for(property in objectDetails){
                      objectDetails = helper.serializeSprintDataForNamespace(objectDetails,property,helper,nameSpace);
                    }
                    
                    
                    if (message && message.data && message.data.sobject && message.data.sobject.Sprint__c !== sprintId) {
                        console.info('received an update for work record ' + sobject.Id + ' but its not in this sprint so were ignoring it.');
                        return; // if you have multiple tabs open you may be listening for multiple sprints at once. Ignore if not in this sprint.
                    }
                    helper.handleStreamedMessage(message, 'WorkUpdates', component, helper);
                }));

                var workUpdatesOne = $.cometd.subscribe('/topic/WorkUpdates?'+nameSpace+'Sprint__c='+sprintId , $A.getCallback(function(message) {
                    console.log('workUpdatesOne : ',message);
                    
                    var objectDetails = message.data.sobject;
                    for(property in objectDetails){
                      objectDetails = helper.serializeSprintDataForNamespace(objectDetails,property,helper,nameSpace);
                    }
                    
                    
                    
                    if (message && message.data && message.data.sobject && message.data.sobject.Sprint__c !== sprintId) {
                        console.info('received an update for work record ' + sobject.Id + ' but its not in this sprint so were ignoring it.');
                        return; // if you have multiple tabs open you may be listening for multiple sprints at once. Ignore if not in this sprint.
                    }
                    helper.handleStreamedMessage(message, 'WorkUpdates', component, helper);
                }));

                
                var taskUpdatesTwo = $.cometd.subscribe('/topic/TaskUpdates?'+nameSpace+'SprintId__c==\''+sprintId +'\'', $A.getCallback(function(message) {
                    if (message && message.data && message.data.event && message.data.event.type === 'deleted') {
                        return; // do nothing here since DeletedTaskUpdates will handle it
                    }
                    var objectDetails = message.data.sobject;
                    for(property in objectDetails){
                      objectDetails = helper.serializeSprintDataForNamespace(objectDetails,property,helper,nameSpace);
                    }

                    if (message && message.data && message.data.sobject && message.data.sobject.SprintId__c !== sprintId) {
                        console.info('received an update for task ' + sobject.Id + ' but its not in this sprint so were ignoring it.');
                        return; // if you have multiple tabs open you may be listening for multiple sprints at once. Ignore if not in this sprint.
                    }
                    
                    if (message && message.data && message.data.event && message.data.event.type === 'created' && message.data.sobject.Assigned_To__c == userInfo.user.Id) {
                        $A.get("e.c:ADM_Event_Update_TaskData").setParams({
                            "taskId": message.data.sobject.Id,
                            "task": message.data.sobject
                        }).fire();
                    } else if (message.data.sobject.LastModifiedById != userInfo.user.Id) {
                        debouncedHandleStreamedMessage(message, 'TaskUpdates', component, helper);
                    }
                }));

                var taskUpdatesOne = $.cometd.subscribe('/topic/TaskUpdates?'+nameSpace+'SprintId__c='+sprintId , $A.getCallback(function(message) {
                    if (message && message.data && message.data.event && message.data.event.type === 'deleted') {
                        return; // do nothing here since DeletedTaskUpdates will handle it
                    }
                    var objectDetails = message.data.sobject;
                    for(property in objectDetails){
                      objectDetails = helper.serializeSprintDataForNamespace(objectDetails,property,helper,nameSpace);
                    }
                    
                    if (message && message.data && message.data.sobject && message.data.sobject.SprintId__c !== sprintId) {
                        console.info('received an update for task ' + sobject.Id + ' but its not in this sprint');
                        return; // if you have multiple tabs open you may be listening for multiple sprints at once. Ignore if not in this sprint.
                    }

                    if (message && message.data && message.data.event && message.data.event.type === 'created' && message.data.sobject.Assigned_To__c == userInfo.user.Id) {
                        $A.get("e.c:ADM_Event_Update_TaskData").setParams({
                            "taskId": message.data.sobject.Id,
                            "task": message.data.sobject
                        }).fire();
                    } else if (message.data.sobject.LastModifiedById != userInfo.user.Id) {
                        debouncedHandleStreamedMessage(message, 'TaskUpdates', component, helper);
                    }

                    
                }));

                var deletedTaskUpdates = $.cometd.subscribe('/topic/DeletedTaskUpdates', $A.getCallback(function(message) {
                    var objectDetails = message.data.sobject;
                    for(property in objectDetails){
                      objectDetails = helper.serializeSprintDataForNamespace(objectDetails,property,helper,nameSpace);
                    }
                    if (message && message.data && message.data.sobject && message.data.sobject.Work__c) {
                        var sobject = message.data.sobject;
                        var sprintData = component.get('v.sprintData');
                        if (!sprintData) {
                            return;
                        }
                        var workId = sobject.Work__c;
                        if (!helper.getWorkById(sprintData, workId)) {
                            return; // this task was deleted but the work record is not in this sprint, so ignore.
                        }
                    } else {
                        return;
                    }

                    helper.handleStreamedMessage(message, 'DeletedTaskUpdates', component, helper);
                }));

                var workHistoryTwo = $.cometd.subscribe('/topic/WorkHistory?'+nameSpace+'Sprint_Old__c==\''+sprintId +'\'', $A.getCallback(function(message) {
                    helper.handleStreamedMessage(message, 'WorkHistory', component, helper);
                }));

                var workHistoryOne = $.cometd.subscribe('/topic/WorkHistory?'+nameSpace+'Sprint_Old__c='+sprintId, $A.getCallback(function(message) {
                    helper.handleStreamedMessage(message, 'WorkHistory', component, helper);
                }));

                helper.hideSpinner();

                //closes connection of window close
                window.onbeforeunload = function(){
                    $.cometd.disconnect();
                };

                // handle subscriptions onhashchange
                window.onhashchange = function() {
                    helper.removeStreamListeners([metaHandshake, metaDisconnect, metaUnsuccessful, metaConnect], $.cometd);
                }
            });

        });

        $A.enqueueAction(action);

    },

    removeStreamListeners: function(channels, stream) {
        channels.forEach(function(metaChannel) {
            if (metaChannel) {
                stream.removeListener(metaChannel);
            }
        })
    },
    
    handleStreamedMessage: function(message, topic, component, _helper) {
        var sprintId = component.get("v.sprintId");

        console.log(topic + ': ', message);
        if(!message.data || !message.data.sobject) {
            console.log(' Encountered issues with ' + topic + ' section -- Please reload page and if not working contact GUS Team');
            return;
        }
        var sobject = message.data.sobject;
        var changedWorkId = (topic === 'WorkUpdates') ? sobject.Id : sobject.Work__c;
        
        _helper.updateWork(changedWorkId, topic, sobject, component);
    },
    
    refreshSprintWork: function(component, callback) {
        var action,
            helper = this,
            sprintId = component.get("v.recordId");
        
        if (!sprintId) {
            return;
        }

        action = component.get("c.getSprintJSON");

        action.setParams({sprintId : sprintId});
            
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var serverSprintData = response.getReturnValue();
                
                if (typeof serverSprintData === 'string') {
                    serverSprintData = JSON.parse(serverSprintData);
                    
                    component.set("v.sprintData.sprintWork", serverSprintData.sprintWork);
                }

                if(callback) {
                    callback();
                }
            }
        });

        $A.enqueueAction(action);
    },
    
    updateWork: function(changedWorkId, topic, sobject, component) {
        var _helper = this;
        var sprintId = component.get("v.sprintId");
        var userInfo = component.get('v.userInfo');
        
        if (window.location.href.indexOf(sprintId) == -1) {
            console.log('disconnecting inside updateWork');
            $.cometd.disconnect();
            _helper.hideSpinner();

            return;
        }
        if (!changedWorkId) {
            console.info('changedWorkId does not exist');
            _helper.hideSpinner();
            return;
        }

        var sprintData = component.get("v.sprintData");
        var nameSpace = sprintData.nameSpace;
        if (topic === 'WorkHistory') {
            var currentWork = _helper.getWorkById(sprintData, changedWorkId);
            if (!currentWork) {
                return; // work not in sprintData
            } else {
                console.log(' Removing work from the Sprint page');
                sprintData.sprintWork = _helper.deleteWorkById(sprintData, changedWorkId);
                component.set('v.sprintData', sprintData);
            }

            _helper.updateSprintVelocity(sprintData);
            _helper.hideSpinner();
        } else {
            var streamedWorkWrapperAction = component.get("c.getWorkWrapperAsJSON");
            streamedWorkWrapperAction.setParams({workId : changedWorkId});

            streamedWorkWrapperAction.setCallback(this, function(response) {
                var state = response.getState();
                
                if (component.isValid() && state === "SUCCESS") {
                    var wrapedWorkData = response.getReturnValue();      
                    if (typeof wrapedWorkData === 'string') {
                        wrapedWorkData = JSON.parse(wrapedWorkData);
                    }
                   
                    for(property in wrapedWorkData){
                      wrapedWorkData = _helper.serializeSprintDataForNamespace(wrapedWorkData,property,_helper,nameSpace);
                    }
                    var currentWork = _helper.getWorkById(sprintData, changedWorkId);                   
                    var updatedWork = wrapedWorkData[0];
                    //if !currentWork, then work was added to the sprint so this was not a reorder.
                    var isSprintRankReorder = (!currentWork ? false : (currentWork.m_story.Sprint_Rank__c != updatedWork.m_story.Sprint_Rank__c));
                    var updatedByThisUser = (updatedWork.m_story.LastModifiedById == userInfo.user.Id);
                    
                    if ((!updatedByThisUser || !isSprintRankReorder) && sprintData.wallReordered == true) {
                        sprintData.wallReordered = false;
                        
                        component.set('v.sprintData.wallReordered', false);
                    }
                    
                    var isWallReordered = sprintData.wallReordered;
                    
                    if (topic === 'WorkUpdates' && isSprintRankReorder && !isWallReordered) {
                        _helper.queueWorkDataRefresh(component, _helper, updatedWork);
                        //since all work items are being refreshed, no need to continue refreshing this one.
                        return;
                    }
                    
                    var workIsVisible = ADM_SprintShared_Resource.isWorkItemVisible(updatedWork, _helper.getFilters(sprintData));
                    updatedWork.visible = workIsVisible;

                    if(!currentWork){
                        console.log('adding work to the sprint'); //TODO - make this a toast
                        sprintData.sprintWork = _helper.addWork(sprintData, updatedWork);
                        component.set('v.sprintData', sprintData); // need to do this here or the row doesn't get added
                    } else {
                        console.log('updating work record');
                        sprintData.sprintWork = _helper.updateWorkById(sprintData, updatedWork, updatedWork.m_story.Id);
                        // component.set('v.sprintData', sprintData);
                        // don't need to do component.set here because event below takes care of it, and it is then handled
                        // by the individual workrow to just update that individual item.
                    }
                    
                    if (topic === 'WorkUpdates') {
                        _helper.updateSprintVelocity(sprintData);
                    }

                    $A.get("e.c:ADM_Event_Update_SprintData").setParams({
                        "recordType": 'Work',
                        "data": updatedWork
                    }).fire();
                    
                    _helper.hideSpinner();
                }
            });
            $A.enqueueAction(streamedWorkWrapperAction);
        }
    },

    updateSprintVelocity: function(sprintData) {
        var totalStoryPoints = 0;
        var closedStoryPoints = 0;

        sprintData.sprintWork.forEach(function(work) {
            if (work.m_story.Status__c !== 'Duplicate' && work.m_story.Story_Points__c) {
                totalStoryPoints += work.m_story.Story_Points__c;
            }
            
            if (work.m_story.Story_Points__c && (work.m_story.Status__c.startsWith('Closed') || work.m_story.Status__c == 'Completed')) {
                closedStoryPoints += work.m_story.Story_Points__c;
            }
        });

        if (sprintData.plannedVelocity !== totalStoryPoints) {
            sprintData.plannedVelocity = totalStoryPoints;
            $A.get("e.c:ADM_Event_Update_PlannedVelocity").setParams({
                "velocity": totalStoryPoints
            }).fire();
        }
        
        if (sprintData.sprintInfo.Completed_Story_Points__c !== closedStoryPoints) {
            sprintData.sprintInfo.Completed_Story_Points__c = closedStoryPoints;
            $A.get("e.c:ADM_Event_Update_ActualVelocity").setParams({
                "velocity": closedStoryPoints
            }).fire();
        }
    },

    initializeTimers: function(component){
        var timeoutInMinutes = 60;
        var inputEvents = 'mousemove keydown mousewheel mousedown touchstart touchmove';
        var timerId = null;
        var stopTimer = function() {
            clearTimeout(timerId);
        };
        var startNewTimer = function() {
            timerId = setTimeout(onTimeout, timeoutInMinutes * 60000);
            component.set('v.timeoutToastTimerId', timerId);
        };
        component._onActivity = function() {
            stopTimer();
            startNewTimer();
        };
        var onTimeout = function() {
            $.cometd.disconnect();
            stopTimer();
            $(document).off(inputEvents, component._onActivity);

            var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "type":"info",
                "title": "Timed out",
                "mode": "Sticky",
                "message": "You have been inactive for " + timeoutInMinutes + " minutes. Please reload the page to continue."
            });
            toastEvent.fire();
        }

        $(document).on(inputEvents, component._onActivity);

        startNewTimer();
    },

    getUrlParameter: function(param) {
        var pageURL = window.location.href,
            sQueryString = pageURL.split('?')[1],
            sURLVariables;

        if (!!sQueryString) {
            sURLVariables = sQueryString.split('&')
        }

        if (!!sURLVariables) {
            var urlVariablesLen = sURLVariables.length,
                parameterName,
                i;

            for (i = 0; i < urlVariablesLen; i++) {
                parameterName = sURLVariables[i].split('=');

                if (parameterName[0].toLowerCase() === param.toLowerCase()) {
                    return parameterName[1] === undefined ? true : parameterName[1];
                }
            }
        }
    },

    debounce: function(func, wait, immediate) {
        var timeout, args, context, timestamp, result;
        var now = Date.now || function() {
           return new Date().getTime();
       };

        var later = function() {
            var last = now() - timestamp;

            if (last < wait && last >= 0) {
                timeout = setTimeout($A.getCallback(later), wait - last);
            } else {
                timeout = null;
                if (!immediate) {
                    result = func.apply(context, args);
                    if (!timeout) context = args = null;
                }
            }
        };

        return function() {
            context = this;
            args = arguments;
            timestamp = now();
            var callNow = immediate && !timeout;
            if (!timeout) timeout = setTimeout($A.getCallback(later), wait);
            if (callNow) {
                result = func.apply(context, args);
                context = args = null;
            }

            return result;
        };
    },

    showSpinner: function() {
        var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
        showSpinner.setParams({
            "show": true
        })
        showSpinner.fire();
    },

    hideSpinner: function() {
        var showSpinner = $A.get("e.c:ADM_Event_Show_Spinner");
        showSpinner.setParams({
            "show": false
        })
        showSpinner.fire();
    },

    goToSprintListView: function(component) {
        var action = component.get("c.getSprintListView");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listview = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listview.Id,
                    "listViewName": "All",
                    "scope": "ADM_Sprint__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    addWork: function(sprintData, work) {
        return sprintData.sprintWork.concat(work);
    },

    getWorkById: function(sprintData, id) {
        return sprintData.sprintWork.filter(function(work) {
            return work.m_story.Id === id
        })[0];
    },

    getWorkBySprintId: function(sprintData, sprintId) {
        return sprintData.sprintWork.filter(function(work) {
            return work.m_story.Sprint__c === sprintId;
        });
    },

    updateWorkById: function(sprintData, updatedWork, id) {
        return sprintData.sprintWork.reduce(function(acc, curr){
            if (curr.m_story.Id === id) {
                return acc.concat(updatedWork);
            } else {
                return acc.concat(curr);
            }
        }, []);
    },

    deleteWorkById: function(sprintData, id) {
        return sprintData.sprintWork.filter(function(work) {
            return work.m_story.Id !== id;
        })
    },

    getFilters: function(sprintData) {
        if (sprintData && sprintData.sprintInfo && sprintData.wallPreferences && sprintData.wallPreferences.teams) {
            var teamId = sprintData.sprintInfo.Scrum_Team__c;
            return sprintData.wallPreferences.teams[teamId].filters;
        }
    },
    
    queueWorkDataRefresh: function(component, helper) {
        var queueId = component.get("v.dataRefreshQueue");
        
        if(queueId) {
            return;
        }
        
        var timeoutId = window.setTimeout($A.getCallback(function() {
            helper.refreshSprintWork(component, function() {
                component.set("v.dataRefreshQueue", '');
            });
        }), 1000);
        
        component.set("v.dataRefreshQueue", timeoutId);
    }
})