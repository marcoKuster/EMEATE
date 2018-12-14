gus._handleWithDeferred = function(deferred) {
    return function(result, event) {
        if(event.type === 'exception') {
            deferred.reject(result, event);
        } else {
            deferred.resolve(result);
        }
    };
};

gus.getImpactsForBugType = function(bugType) {
    var deferred = new $.Deferred();
    ADM_WorkExtension.getImpactsForBugType(bugType, gus._handleWithDeferred(deferred), {escape:false});
    return deferred.then(function(result){
        var models = [];
        _.each(result, function(raw) {
            var model = new gus.ImpactModel(raw);
            models.push(model);
        });
        return models;
    });
}

gus.calculatePriority = function(/*String*/ frequencyId, /*String*/ impactId) {
    var deferred = new $.Deferred();
    ADM_WorkExtension.calculatePriority(frequencyId, impactId, gus._handleWithDeferred(deferred), {escape: false});
    return deferred.promise();
}

gus.WorkAssignment = Backbone.Model.extend({
    relations: [{
        attribute: 'Assignee__r',
        key: 'Assignee__c',
    }, {
        attribute: 'Product_Owner__r',
        key: 'Product_Owner__c',
    }, {
        attribute: 'QA_Engineer__r',
        key: 'QA_Engineer__c',
    }],
    toJSON: function() {
        var json = Backbone.Model.prototype.toJSON.apply(this, arguments);
        
        _.each(this.relations || [], function(rel) {
            var value = json[rel.attribute];
            json[rel.key] = value.get('Id');
            delete json[rel.attribute];
        });
        
        return json;
    }
}); 
gus.getWorkAssignments = function(/*String*/ severityLevel, /*ADM_Product_Tag__c*/ productTag, /*RecordType*/ recordType, /*String*/ workType, /*String*/ recipients) {
    var deferred = new $.Deferred();
    ADM_WorkExtension.getAssignments(severityLevel, productTag, recordType, workType, recipients, function(result, event) {
        if(event.type === 'exception') {
            deferred.reject(result, event);
        } else if(result.errorMessages && result.errorMessages != null && result.errorMessages.length > 0) {
            var errors = [];
            _.each(result.errorMessages, function(errorMessage) {
                errors.push({message: errorMessage});
            });
            deferred.reject(errors, event);
        } else {
            delete result.errorMessages;
            deferred.resolve(result);
        }
    }, {escape: false});
    return deferred.then(function(result){
        var model = new gus.WorkAssignment();
        var assignments = result.assignments;
        if(assignments) {
            var getOrCreateUser = function(userData) {
                var userCollection = gus.getCache(gus.UserModel);
                if(!userData || !userData.Id) {
                    return;
                }
                
                var user = userCollection.get(userData.Id);
                if(!user) {
                    user = new gus.UserModel(userData);
                    userCollection.add(user, {merge:true});
                }
                return user;
            }
            
            if(assignments.Assignee && assignments.Assignee.Id) {
                model.set('Assignee__r', getOrCreateUser(assignments.Assignee));
            }
            if(assignments.Product_Owner && assignments.Product_Owner.Id) {
                model.set('Product_Owner__r', getOrCreateUser(assignments.Product_Owner));
            }
            if(assignments.QA_Engineer && assignments.QA_Engineer.Id) {
                model.set('QA_Engineer__r', getOrCreateUser(assignments.QA_Engineer));
            }
        }
        return model;
    });
}


var LookupComponent = function() {
    this.initialize.apply(this, arguments);
};
_.extend(LookupComponent.prototype, Backbone.Events, {
    initialize: function(options) {
        if(!options) options = {};
        this.modelClass = options.modelClass;
        this.nameInput = options.$nameInput;
        this.idInput = options.$idInput;
        this.$statusIndicator = options.$statusIndicator;
        this.minLength = options.minLength || 1;
        this.sObject = this.modelClass.prototype.sObjectType;
        
        this.on('loading', _.bind(function() {
            this.$statusIndicator.show();
        }, this));
        this.on('loaded', _.bind(function() {
            this.$statusIndicator.hide();
        }, this));
    },
    clear: function() {
        this._selected = null;
        this.nameInput.val('');
        this.idInput.val('');
    },
    set: function(/*Backbone.Model*/ model) {
        this._selected = model.toJSON();
        this.nameInput.val(model.get('Name'));
        this.idInput.val(model.get('Id'));
    },
    getId: function() {
        return this.idInput.val();
    },
    setId: function(/*String*/ id) {
        //no need to update if the ID is the same
        if(this.idInput.val() === id) {
            return;
        }
        
        if(this.$statusIndicator) {
            this.$statusIndicator.show();
        }
        
        gus.getOrFetch(this.modelClass, id)
            .always(_.bind(function() {
                if(this.$statusIndicator) {
                    this.$statusIndicator.hide();
                }
            }, this))
            .done(_.bind(function(model) {
                this.set(model);
            }, this))
            .fail(_.bind(function(errorMsg){
                console.warn(errorMsg);
                this.clear();
            }, this));
    },
    
    render: function() {
        this.nameInput.autocomplete({
            source: _.bind(this._onLookup, this),
            select: _.bind(this._onSelect, this),
            minLength: this.minLength,
            change: _.bind(this._onAutocompleteChange, this)
        })
        return this;
    },
    
    update: function(/*gus.SObjectModel*/ model, /*String*/ attribute) {
        if(!model.has(attribute)) {
            this.clear();
            return;
        }
        var id = model.get(attribute);
        this.setId(id);
    },
    
    /**
     * Invoked by jQuery UI autocomplete when trying to find items with the entered search term
     */
    _onLookup: function(request, response) {
        var term = request.term;
        if(!term || term.length < this.minLength) {
            return;
        }
        
        this._query(term)
            .done(function(results) {
                response(_.map(results.records, function(result) {
                    return _.extend({
                        label: result.Name || result.Id,
                        value: result.Name || result.Id
                    }, result); 
                }));
            })
            .fail(_.bind(function(){
                this._onError('Failed while executing query for autocomplete field');
            }, this));
    },
    
    /**
     * Override this method to build a SOQL query to use to search for the specified term. The term is 
     * not escaped so it could include illegal characters.
     */
    _buildQuery: function(term) {
        term = gus.soqlEncode(term);
        
        var cleanSObject = gus.soqlEncode(_.result(this, 'sObject'));
        return "select Id, Name from " + cleanSObject + " where Name like '%" + term + "%' order by Name limit 10";
    },
    
    /**
     * Executes the query with the given term. 
     * @returns $.Deferred
     */
    _query: function(term) {
        var soqlQuery = this._buildQuery(term);
        
        var load = this._startLoading();
        var deferred = new $.Deferred();
        client.query(soqlQuery, deferred.resolve, deferred.reject);
        deferred.always(function() {
            load.finish();
        });
        return deferred.promise();
    }, 
    
    /**
     * Invoked by jQuery UI autocomplete when an item is selected
     */
    _onSelect: function(event, ui) {
        var item = ui.item;
        var model = new this.modelClass(item);
        this.set(model);
    },
    
    _onAutocompleteChange: function(event, ui) {
        //user didnt select an item but assume they know what they are doing
        if(!ui.item) {
            var name = this.nameInput.val();
            if(name) {
                this._query(name)
                    .done(_.bind(function(results) {
                        if(results.totalSize == 0) {
                            this._onError('Nothing found with a name of ' + name);
                            this.clear();
                        } if(results.totalSize > 1) {
                            console.debug('name is not unique');
                            this.nameInput.val(name);
                            this.nameInput.autocomplete('search');
                        } else {
                            var item = results.records[0];
                            var model = new this.modelClass(item);
                            this.set(model);
                        }
                    
                    }, this))
                    .fail(_.bind(function() {
                        this._onError('Failed to find autocomplete match');
                    }, this));
            } else {
                this.clear();
            }
        }
    },
    
    _onError: function(attributes) {
        console.log(attributes.messages);
    },
    
    _nextLoadId: 0,
    _loads: {},
    _startLoading: function() {
        var loadId = this._nextLoadId++;
        var load = {
            id: loadId,
            finish: _.bind(function() {
                this._endLoading(load);
            }, this)
        };
        var currentlyLoading = !_.isEmpty(this._loads);
        this._loads[loadId] = load;
        if(!currentlyLoading) {
            this.trigger('loading');
        }
        return load;
    },
    _endLoading: function(load) {
        delete this._loads[load.id];
        if(_.isEmpty(this._loads)) {
            this.trigger('loaded');
        }
    }
});
LookupComponent.extend = Backbone.View.extend;

UserLookupComponent = LookupComponent.extend({
    initialize: function(options) {
        UserLookupComponent.__super__.initialize.apply(this, arguments);
        this.profileImage = options.$profileImage;
    },
    clear: function() {
        UserLookupComponent.__super__.clear.apply(this, arguments);
        this.profileImage.attr('src', '/profilephoto/005/F');
    },
    set: function(/*Backbone.Model*/ model) {
        UserLookupComponent.__super__.set.apply(this, arguments);
        
        var photoUrl;
        if(model.has('SmallPhotoUrl')) {
            photoUrl = model.get('SmallPhotoUrl');
        }
        this.profileImage.attr('src', photoUrl || '/profilephoto/005/F');
    },
    _buildQuery: function(term) {
        term = gus.soqlEncode(term);
        var cleanSObject = gus.soqlEncode(_.result(this, 'sObject'));
        return "select Id, Name, SmallPhotoUrl from " + cleanSObject + " where Name like '%" + term + "%' order by Name limit 10";
    }
});

SprintLookupComponent = LookupComponent.extend({
    _buildQuery: function(term) {
        term = gus.soqlEncode(term);
        var cleanSObject = gus.soqlEncode(_.result(this, 'sObject'));
        return "select Id, Name, Start_Date__c, End_Date__c from ADM_Sprint__c where Name like '%" + term + "%' and (End_Date__c >= TODAY or (Start_Date__c <= TODAY and End_Date__c >= TODAY)) order by Start_Date__c asc limit 10";
    }
});

/**
 * Calculates the priority
 */
PriorityCalculator = function(options) {
    this.initialize.apply(this, arguments);
};
_.extend(PriorityCalculator.prototype, {
    initialize: function(options) {
        this.frequency = options.frequency;
        this.impact = options.impact;
    },
    canCalculate: function() {
        return _.result(this, 'frequency') && _.result(this, 'impact');
    },
    calculate: function() {
        var frequency = _.result(this, 'frequency');
        var impact = _.result(this, 'impact');
        
        var deferred = $.Deferred();
        if(!frequency || !impact) {
            deferred.resolve(null);
        } else {
            if(!this._priorityCache) {
                this._priorityCache = [];
            }
            var priorityCache = this._priorityCache;
            var cached = _.where(this._priorityCache, {frequency: frequency, impact: impact});
            if(cached.length > 0) {
                deferred.resolve(cached[0].priority);
            } else {
                gus.calculatePriority(frequency, impact)
                    .done(function(result) {
                        var data = {
                            frequency: frequency,
                            impact: impact,
                            priority: result
                        };
                        priorityCache.push(data);
                        deferred.resolve(result);
                    })
                    .fail(function() {
                        deferred.reject.apply(this, arguments);
                    });
            }
        }

        return deferred.promise();
    }
});

PriorityComponent = Backbone.View.extend({
    events: {
        'click a#priorityOverrideLink': '_onPriorityOverrideLinkClick'
    },
    initialize: function(options) {
        this.dialogTemplate = _.template($('#template-priorityOverride').html());
        this.calculator = (options) ? options.calculator : void 0;
    },
    render: function() {
        if(this.model.has('Priority__c')) {
            this._priorityCurrent = this.model.get('Priority__c');
            this._priority = this.model.get('Priority__c'); 
        }
        if(this.model.has('Priority_Override_Explanation__c')) {
            this._overrideReason = this.model.get('Priority_Override_Explanation__c');
        }
        this.update();
        return this;
    },
    getPriority: function() {
        return this._priority;
    },
    getOverrideReason: function() {
        return this._overrideReason;
    },
    getCalculatedPriority: function() {
        return this._calculatedPriority;
    },
    update: function(options) {
        options = _.defaults(options || {}, {resetOverride: false});
        var $priority = this.$('.priority').empty();
        
        this._calculatePriority()
            .done(_.bind(function(calculatedPriority) {
                var priority = _.result(this, '_priority');
                var priorityCurrent = _.result(this, '_priorityCurrent');
                var canCalculate = _.result(this, '_canCalculate');
                
                if(options.resetOverride) {
                    priority = this._priority = calculatedPriority;
                    delete this._overrideReason;
                }
                
                if((priorityCurrent && this.model.isNew()) || !canCalculate) {
                    $priority.append($('<span style="color: gray">To Be Calculated</span>'));
                }
                
                if(priorityCurrent && !canCalculate) {
                    $priority.append($(_.template('<span style="color: gray"> - Previously <%- priority %></span>', {priority: priority})));
                }
                
                if(priority && priority == calculatedPriority) {
                    $priority.append(document.createTextNode(priority));
                }
                
                if(priority && priority != calculatedPriority && canCalculate) {
                    $priority.append($(_.template('<span style="padding:0 3px; margin:0 3px 0 0; color: white; background-color: orange; font-weight: bold;"><%- priority %></span><i>Overridden (Default&nbsp;<%- calculatedPriority %>)</i>', {priority: priority, calculatedPriority: calculatedPriority})));
                }
                
                if(priority && canCalculate) {
                    //TODO figure out a way this can be toggled on (for new work page) and off for MDP screens so that we can share the static resource
                    //$priority.append($('<a id="priorityOverrideLink" href="#" style="padding-left: 1em;">Override</a>'));
                }
                
            }, this))
            .fail(_.bind(function() {
                this._onError('Failed to calculate priority');
            }, this));
        
        return this;
    },
    _canCalculate: function() {
        return this.calculator.canCalculate();
    },
    _calculatePriority: function() {
        var $status = this.$('#priorityStatus').show();
        return this.calculator.calculate()
            .always(_.bind(function(result) {
                this._calculatedPriority = result;
                $status.hide();
            }, this));
    },
    _onPriorityOverrideLinkClick: function(event) {
        event.stopPropagation();
        event.preventDefault();
        var view = this;
        
        var $dialog = $(this.dialogTemplate()).dialog({
            modal: true,
            resizable: false,
            width: 560,
            buttons: {
                'OK': function() {
                    view._priority = $dialog.find('#priorityInput').val();
                    view._overrideReason = $dialog.find('#priorityOverrideReason').val();
                    view.update();
                    $dialog.dialog('close');
                },
                'Cancel': function() {
                    $dialog.dialog('close');
                }
            }, 
            close: function() {
                $dialog.remove();
            }
        });
        
        //load the priority values
        $dialog.find('#priorityInput').empty().attr('disabled', 'disabled');
        $dialog.find('#priorityOverrideReason').attr('disabled', 'disabled');
        this._getPriorityValues()
            .done(_.bind(function(values) {
                //load the drop down
                $dialog.find('#priorityInput').removeAttr('disabled').empty();
                _.each(values, _.bind(function(value) {
                    $('<option>').text(value).attr('value', value).appendTo($dialog.find('#priorityInput'));
                }, this));
                
                //set the values within the dialog box
                $dialog.find('.priorityCalculated').text(this._calculatedPriority);
                $dialog.find('#priorityInput').val(this._priority).change();
                $dialog.find('#priorityOverrideReason').removeAttr('disabled').val(this._overrideReason);
            }, this))
            .fail(_.bind(function() {
                this._onError('Failed to load the priority values');
            }, this));
        
    },
    _getPriorityValues: function() {
        if(this._priorityValues) {
            var deferred = new $.Deferred();
            deferred.resolve(this._priorityValues);
            return deferred.promise();
        } else {
            return gus.WorkModel.getPriorityValues()
                .done(_.bind(function(values) {
                    this._priorityValues = values;
                }, this))
        }
    },
    _onError: function(attributes) {
        console.error(attributes.messages);
    }
});

gus.WorkView = Backbone.View.extend({
    tagName: 'div', 
    className: 'view-workForm',
    initialize: function(options) {
        this.template = _.template($('#' + this.templateName).html());
        this.statusValues = options.statusValues;
    }, 
    render: function() {
        this.$el.html(this.template({model: this.model}));
        
        this.renderChildren();
        this.updateFromModel();
        
        return this;
    },
    renderChildren: function() {
        //bind the save button
        this.$('#saveButton').on('click', _.bind(this._onSave, this));
        
        //get a reference to each of the input fields
        this.$subjectInput = this.$('#subjectInput');
        this.assignedToComponent = this._createUserLookupComponent('assignedTo');
        this.productOwnerComponent = this._createUserLookupComponent('productOwner');
        this.qaEngineerComponent = this._createUserLookupComponent('qaEngineer');
        this.sprintComponent = this._createSprintLookupComponent('sprint');
        this.$commentInput = this.$('#commentInput');
        this.foundInBuildComponent = this._createLookupComponent(gus.BuildModel, 'foundInBuild');
        this.scheduledBuildComponent = this._createLookupComponent(gus.BuildModel, 'scheduledBuild');
        
        //create the product tag component
        this.productTagComponent = new ProductTag({el: $('.productTagContainer'), dataStore: this._buildProductTagDataStore()}).render();
        $(this.productTagComponent).on('change:tag', _.bind(function() {
            if(this.productTagComponent) {
                this.updateAssignments();
            }
        }, this));
        $(this.productTagComponent).on('remove', _.bind(function() {
            //remove the assignments
            this.assignedToComponent.clear();
            this.productOwnerComponent.clear();
            this.qaEngineerComponent.clear();
        }, this));
        
        //create the status picklist field options
        var $statusInput = this.$statusInput = this.$('#statusInput').empty().attr('disabled', 'disabled');
        var $statusStatus = this.$('#statusStatus').show();
        this.model.getRecordType()
            .then(function(recordType) {
                return gus.WorkModel.getStatusValues(recordType.get('Name'));
            })
            .always(function() {
                $statusStatus.hide();
            })
            .done(function(values){
                $statusInput.empty().removeAttr('disabled');
                _.each(values, function(value) {
                    $('<option>').text(value).attr('value', value).appendTo($statusInput);
                });
            })
            .fail(_.bind(function() {
                this._onError('Error loading status values for record type: ' + this.model.get('RecordTypeId'))
            }, this));
        
        //create the related lists container
        var relatedListView = new gus.RelatedListView({model: this.model});
        this.$('.relatedListsContainer').empty().append(relatedListView.render().el);
    },
    updateFromModel: function() {
        var view = this;
        this.$subjectInput.val(this.model.get('Subject__c'));
        this.$statusInput.val(this.model.get('Status__c'));
        this.$commentInput.val(this.model.get('Description__c'));
        
        //update the header
        this.model.getRecordType()
            .done(function(recordType) {
                view.$('.recordTypeName').text(recordType.get('Name'));
            })
            .fail(function() {
                view._onError({messages: ['Failed to retrieve the record type: ' + view.model.get('RecordTypeId')]});
            });
        
        //update the product tag component
        this.productTagComponent.showStatus();
        var fetchingProductTag = this.model.getProductTag()
            .always(function() {
                view.productTagComponent.hideStatus();
            })
            .done(_.bind(function(productTag) {
                if(!productTag) {
                    this.productTagComponent.hideStatus();
                    return;
                }
                var productTagData = productTag.toJSON();
                
                //we need to retrieve the related team
                this.productTagComponent.showStatus();
                productTag.getTeam()
                    .always(_.bind(function() {
                        this.productTagComponent.hideStatus();
                    }, this))
                    .done(_.bind(function(team) {
                        if(team) {
                            productTagData.Team__r = team.toJSON();
                            this.productTagComponent.selectTag(productTagData);
                        }
                    }, this))
                    .fail(function() {
                        view._onError({messages: ['Failed to retrieve the team: ' + productTag.get('Team__c')]});
                    });
                
            }, this))
            .fail(function() {
                view._onError({messages: ['Failed to retrieve the product tag: ' + view.model.get('Product_Tag__c')]})
            });
        
        //update the sprint
        this.sprintComponent.update(this.model, 'Sprint__c');
        
        //update the user components
        this.assignedToComponent.update(this.model, 'Assignee__c');
        this.productOwnerComponent.update(this.model, 'Product_Owner__c');
        this.qaEngineerComponent.update(this.model, 'QA_Engineer__c');
        
        //update the build components
        this.foundInBuildComponent.update(this.model, 'Found_in_Build__c');
        this.scheduledBuildComponent.update(this.model, 'Scheduled_Build__c');
    },
    updateAssignments: function() {
        var formData = this._getFormAttributes();
        
        var severityLevel, productTag, recordType, workType, recipients = '';
        
        severityLevel = formData['Severity__c'] || '';
        
        if(formData['Product_Tag__c']) {
            productTag = {Id: formData['Product_Tag__c']};
        }
        
        if(this.model.get('RecordTypeId')) {
            recordType = {Id: this.model.get('RecordTypeId')};
        }
        
        if(this.model.get('Type__c')) {
            workType = this.model.get('Type__c');
        }
        
        if(productTag && recordType && workType) {
            var view = this;
            gus.getWorkAssignments(severityLevel, productTag, recordType, workType, recipients)
                .done(function(assignments) {
                    if(!view.assignedToComponent.getId() && assignments.has('Assignee__r')) {
                        view.assignedToComponent.set(assignments.get('Assignee__r'));
                    }
                    if(!view.productOwnerComponent.getId() && assignments.has('Product_Owner__r')) {
                        view.productOwnerComponent.set(assignments.get('Product_Owner__r'));
                    }
                    if(!view.qaEngineerComponent.getId() && assignments.has('QA_Engineer__r')) {
                        view.qaEngineerComponent.set(assignments.get('QA_Engineer__r'));
                    }
                })
                .fail(function(result){
                    console.warn('Failed to retrieve the work assignments: ' + result[0].message);
                    view._onError(result);
                });
        } else {
            console.log('unable to update assignments because not all required fields are entered');
        }
    },
    _onError: function(errors) {
        if(!_.isArray(errors)){
            errors = [errors];
        }
        
        _.each(errors, function(error) {
            if(error.message) {
                console.warn(error.message);
            } else {
                console.warn(error);
            }
        });
    },
    _onSave: function() {
        var $saveStatusIcon = this.$('#saveStatus').show();
        try {
            var values = this._getFormAttributes();
            this.model.save(values, {
                wait: true,
                success: _.bind(function() {
                    $saveStatusIcon.hide();
                    console.debug('save successful model:');
                    console.debug(this.model)
                    console.debug(' values:');
                    console.debug(values);
                    //show a success message and clear the error messages
                    this.$('.page-success-container').empty().show().text('Save successful').get(0).scrollIntoView();
                    this.$('#page-success-work-id').empty().text(values.id)
                    this.$('.page-error-container').empty().hide()
                }, this), 
                error: _.bind(function(model, xhr, options) {
                    $saveStatusIcon.hide();
                    if(xhr.readyState == 0 || xhr.status == 0) {
                        console.warn('url changed during save');
                        return;
                    }
                
                    try {
                        this.$('.page-success-container').empty().hide();
                        var $errorContainer = this.$('.page-error-container').empty().hide();
                        var pageErrors = JSON.parse(xhr.responseText);
                        
                        if(pageErrors.length > 0) {
                            if(pageErrors.length > 1) {
                                var $pageErrorList = $('<ul>').appendTo($errorContainer);
                                _.each(pageErrors, function(pageError) { $('<li>').text(pageError.message).appendTo($pageErrorList); })
                            } else {
                                $errorContainer.text(pageErrors[0].message);
                            }
                            
                            $errorContainer.show().get(0).scrollIntoView();
                        }
                        
                    } catch(e) {
                        console.warn(e);
                        console.error('Error occurred while saving: ' + xhr.responseText);
                    }
                }, this)
            });
        } catch(e) {
            $saveStatusIcon.hide();
            console.error('Error occurred while saving:' + e);
            alert(e);
        }
    },
    /**
     * Gets the attributes from the form 
     */
    _getFormAttributes: function() {
        var values = {};
        
        if(this.$commentInput.val()) {
            values['Description__c'] = this.$commentInput.val();
        }
        
        if(this.$statusInput.val()) {
            values['Status__c'] = this.$statusInput.val();
        }
        
        var subject = this.$subjectInput.val();
        if(subject) {
            values['Subject__c'] = subject;
        }
        
        var assignee = this.assignedToComponent.getId();
        if(assignee) {
            values['Assignee__c'] = assignee;
        }
        
        var productOwner = this.productOwnerComponent.getId();
        if(productOwner) {
            values['Product_Owner__c'] = productOwner;
        }
        
        var qaEngineer = this.qaEngineerComponent.getId();
        if(qaEngineer) {
            values['QA_Engineer__c'] = qaEngineer;
        }
        
        var sprint = this.sprintComponent.getId();
        if(sprint) {
            values['Sprint__c'] = sprint;
        } 
        
        if(this.foundInBuildComponent.getId()) {
            values['Found_in_Build__c'] = this.foundInBuildComponent.getId()
        }
        if(this.scheduledBuildComponent.getId()) {
            values['Scheduled_Build__c'] = this.scheduledBuildComponent.getId()
        }
        
        var productTagId = this.productTagComponent.getValue();
        if(productTagId) {
            values['Product_Tag__c'] = productTagId;
        }
        
        return values;
    },
    _createLookupComponent: function(modelClass, /*String*/ prefix) {
        var component = new LookupComponent({
            modelClass: modelClass,
            $nameInput: $('#' + prefix + 'Input'),
            $idInput: $('#' + prefix + 'Id'),
            $statusIndicator: $('#' + prefix + 'Status')
        });
        component.render();
        return component;
    },
    _createUserLookupComponent: function(/*String*/ prefix) {
        var component = new UserLookupComponent({
            modelClass: gus.UserModel,
            $nameInput: $('#' + prefix + 'Input'),
            $idInput: $('#' + prefix + 'Id'),
            $statusIndicator: $('#' + prefix + 'Status'),
            $profileImage: $('#' + prefix + 'ProfileImage')
        });
        component.render();
        return component;
    },
    _createSprintLookupComponent: function(/*String*/ prefix) {
        var component = new SprintLookupComponent({
            modelClass: gus.SprintModel,
            $nameInput: $('#' + prefix + 'Input'),
            $idInput: $('#' + prefix + 'Id'),
            $statusIndicator: $('#' + prefix + 'Status')
        });
        component.render();
        return component;
    },
    _getPicklistValue: function($input) {
        //for convenience, we reuse the getReferenceValue method
        return this._getReferenceValue($input);
    },
    _getReferenceValue: function($input) {
        if($input.is(':disabled')) {
            return void 0;
        }
        
        var value = $input.val();
        if(value === '--None--') {
            return void 0;
        }
        return value;
    },
    _buildProductTagDataStore: function() {
        var productTagDataStore = new ProductTagDataStore();
        var tagListData = [];
        var teamCache = gus.getCache(gus.TeamModel);
        gus.getCache(gus.ProductTagModel).each(function(productTag) {
            var team = teamCache.get(productTag.get('Team__c'));
            if(team) {
                 var tagData = productTag.toJSON();
                 tagData.Team__r = team.toJSON();
                 tagListData.push(tagData);
            }
        });
        productTagDataStore.reset(tagListData);
        return productTagDataStore;
    }
});

gus.BugWorkView = gus.WorkView.extend({
    templateName: 'template-bug',
    initialize: function() {
        gus.BugWorkView.__super__.initialize.apply(this, arguments);
        this.delegateEvents(_.extend(this.events || {}, {
            'change #impactInput': '_onImpactChange', 
            'change #frequencyInput': '_refreshPriority'
        }));
    },
    _onImpactChange: function() {
        this._refreshFrequency();
        this._refreshPriority();
    },
    _getFormAttributes: function() {
        var values = gus.BugWorkView.__super__._getFormAttributes.apply(this, arguments);
        
        if(this.$detailsAndStepsInput.val()) {
            values['Details_and_Steps_to_Reproduce__c'] = this.$detailsAndStepsInput.val();
        }
        
        if(this._getImpact()) {
            values['Impact__c'] = this._getImpact();
        }
        
        if(this._getFrequency()) {
            values['Frequency__c'] = this._getFrequency();
        }
        
        var priority = this.priorityComponent.getPriority();
        if(priority) {
            values['Priority__c'] = priority;
        }
        
        var overrideReason = this.priorityComponent.getOverrideReason();
        if(overrideReason) {
            values['Priority_Override_Explanation__c'] = overrideReason;
        }
        
        if(this.$('.ftestInput').val()) {
            values['ftest__c'] = this.$('.ftestInput').val();
        }
        
        if(this.$('.rootCauseAnalysisInput').val()) {
            values['Root_Cause_Analysis_2__c'] = this.$('.rootCauseAnalysisInput').val();
        }
        
        var perforceStatus = this._getPicklistValue(this.$perforceStatusInput);
        if(perforceStatus) {
            values['Perforce_Status__c'] = perforceStatus;
        }
        
        return values;
    },
    renderChildren: function() {
        gus.BugWorkView.__super__.renderChildren.apply(this, arguments);
        
        this.$impactInput = this.$('#impactInput');
        this.$detailsAndStepsInput = this.$('#detailsAndStepsInput');
        this.$frequencyInput = this.$('#frequencyInput');
        
        //initialize the priority component
        this.priorityComponent = new PriorityComponent({
            el: this.$('.priority-container'), 
            model: this.model,
            calculator: new PriorityCalculator({
                frequency: _.bind(this._getFrequency, this),
                impact: _.bind(this._getImpact, this)
            })
        }).render();
        
        //load the perforce status values
        this.$perforceStatusInput = this.$('#perforceStatusInput').empty().attr('disabled', 'disabled');
        this.$('#perforceStatusStatus').show();
        gus.WorkModel.getPerforceStatusValues()
            .always(_.bind(function() {
                this.$('#perforceStatusStatus').hide();
            }, this))
            .done(_.bind(function(values) {
                this.$perforceStatusInput.empty().removeAttr('disabled', 'disabled').append($('<option>--None--</option>'));
                _.each(values, _.bind(function(value) {
                    $('<option>').text(value).attr('value', value).appendTo(this.$perforceStatusInput);
                }, this));
            }, this))
            .fail(_.bind(function() {
                this._onError('Error loading Source Control Status values');
            }, this));
        
        //create the frequency options
        var loadingFrequency = this._renderFrequency();
        
        //create the impact options
        var loadingImpact = this._renderImpact();
        
        $.when(loadingFrequency, loadingImpact).done(_.bind(function() {
            //after we load the frequency and impact, we need to update the priority
            this.priorityComponent.update();
        }, this));
    },
    updateFromModel: function() {
        gus.BugWorkView.__super__.updateFromModel.apply(this, arguments);
        
        //update fields
        this.$perforceStatusInput.val(this.model.get('Perforce_Status__c'));
        this.$('.ftestInput').val(this.model.get('ftest__c'));
        this.$('.rootCauseAnalysisInput').val(this.model.get('Root_Cause_Analysis_2__c'));
        
        this.$detailsAndStepsInput.val(this.model.get('Details_and_Steps_to_Reproduce__c'));
    },
    _getImpact: function() {
        return this._getReferenceValue(this.$impactInput);
    },
    _renderImpact: function() {
        var $impactStatus = this.$('#impactStatus').show();
        this.$impactInput.empty().attr('disabled', 'disabled').append($('<option value="">--None--</option>'));
        return gus.getImpactsForBugType(this.model.get('Type__c'))
            .done(_.bind(function(impacts) {
                
                _.each(impacts, _.bind(function(impact){
                    $('<option>').attr('value', impact.get('Id')).text(impact.get('Name')).appendTo(this.$impactInput);
                }, this));
                
                this.$impactInput.removeAttr('disabled').val(this.model.get('Impact__c'));
            }, this))
            .always(function() {
                $impactStatus.hide();
            })
            .fail(_.bind(function() {
                this._onError('Failed to load the Impacts for work type: ' + this.model.get('Type__c'));
            }, this));
    },
    _getFrequency: function() {
        return this._getReferenceValue(this.$frequencyInput);
    },
    _renderFrequency: function() {
        this.$frequencyInput.empty().attr('disabled', 'disabled').append($('<option value="">--None--</option>'));
        this.$('#frequencyStatus').show();
        gus.getCache(gus.FrequencyModel).each(_.bind(function(frequency) {
            $('<option>').attr('value', frequency.get('Id')).text(frequency.get('Name')).appendTo(this.$frequencyInput);
        }, this));
        this.$frequencyInput.removeAttr('disabled').val(this.model.get('Frequency__c'));
        this.$('#frequencyStatus').hide();
        
        var deferred = new $.Deferred();
        deferred.resolve();
        return deferred;
    }, 
    _refreshFrequency: function() {
        var impact = this._getImpact();
        if(!impact) {
            this.$frequencyInput.attr('disabled', 'disabled');
        } else {
            this.$frequencyInput.removeAttr('disabled');
        }
    },
    _refreshPriority: function() {
        this.priorityComponent.update({resetOverride: true});
    }
});

gus.UserStoryWorkView = gus.WorkView.extend({
    templateName: 'template-userstory',
    initialize: function() {
        gus.UserStoryWorkView.__super__.initialize.apply(this, arguments);
    }, 
    renderChildren: function() {
        gus.UserStoryWorkView.__super__.renderChildren.apply(this, arguments);
        this.$detailsInput = this.$('#detailsInput');
        this.$storyPointsInput = this.$('#storyPointsInput');
    },
    _getFormAttributes: function() {
        var values = gus.UserStoryWorkView.__super__._getFormAttributes.apply(this, arguments);
        if(this.$detailsInput.val()) {
            values['Details__c'] = this.$detailsInput.val();
        }
        if(this.$storyPointsInput.val()) {
            values['Story_Points__c'] = this.$storyPointsInput.val();
        }
        return values;
    },
    updateFromModel: function() {
        gus.UserStoryWorkView.__super__.updateFromModel.apply(this, arguments);
        this.$detailsInput.val(this.model.get('Details__c'));
        
        //story points
        this.$storyPointsInput.val(this.model.get('Story_Points__c'));
    }
});

gus.RecipientView = Backbone.View.extend({
    events: {
        'click .recipient-add-button': 'showInput',
        'keyup .recipient-input': '_onInputKeyup',
        'blur .recipient-input': 'hideInput'
    },
    initialize: function() {
        this.template = _.template($('#template-recipientlist').html());
        this.entries = new Backbone.Collection();
        this.listenTo(this.entries, 'add', _.bind(function() {
            this.trigger('entryAdded');
        }, this));
        this.listenTo(this.entries, 'remove', _.bind(function() {
            this.trigger('entryRemoved');
        }, this));
    },
    render: function() {
        this.$el.html(this.template());
        
        this.$('.recipientList').empty();
        
        var encodedValue = this.model.get('Encoded_Recipients_Txt_Area__c');
        
        //decode the entries and add the models
        var entries = this._decodeValue(encodedValue);
        _.each(entries, _.bind(this._addEntry, this));
        
        return this;
    },
    setEncodedValue: function(value) {
        this.encodedValue = value;
    },
    getEncodedValue: function() {
        var output = '';
        this.entries.forEach(function(entry, index) {
            if(index > 0) {
                output += '::';
            }
            output += (entry.get('type') || 'M') + '==' + entry.get('value');
        });
        return output;
    },
    showInput: function() {
        this.$('.recipient-input').val('').show().focus();
        this.$('.recipient-add-button').hide();
    },
    hideInput: function(e) {
        this.$('.recipient-input').val('').hide();
        this.$('.recipient-add-button').show();
    },
    _onInputKeyup: function(e) {
        if(e.keyCode === 13) {
             var $recipientInput = this.$('.recipient-input');
             var newValue = $recipientInput.val();
             if(newValue) {
                 this._addEntry({value: newValue, type: 'M'});
                 this.hideInput();
             }
            return;
        }
    },
    _addEntry: function(entry) {
        //check to see if the entry is a duplicate
        var trimmedValue = $.trim(entry.value);
        if(this.entries.some(function(o){return $.trim(o.get('value')) === trimmedValue})) {
            return;
        }
        
        //add the new entry as a model
        var model = new Backbone.Model(entry);
        this.entries.add(model);
        
        //update the view
        var entryView = new gus.RecipientListItemView({
            model: model
        });
        entryView.render();
        this.$('.recipientList').append(entryView.$el);
    },
    _decodeValue: function(encodedValue) {
        if(!encodedValue) {
            return [];
        }
        
        var mySplitResult = encodedValue.split('::');
        var assigneeList = [];
        
        if(mySplitResult) {
            for(var i = 0; i < mySplitResult.length; i++){
                if(mySplitResult[i]) {
                    var myInnerSplitResult = mySplitResult[i].split('==');
                    assigneeList.push({
                        value: myInnerSplitResult[1],
                        type: myInnerSplitResult[0]
                    });
                }
            }
        }
        
        return assigneeList;
    }
});

gus.RecipientListItemView = Backbone.View.extend({
    tagName: 'span', 
    className: 'recipient-container',
    events: {
        'click a.recipient-remove': 'removeRecipient',
        'mouseover .recipient': 'showRemove',
        'mouseout .recipient': 'hideRemove'
    },
    initialize: function() {
        this.template = _.template('<span class="recipient"><span class="recipient-name"></span>&nbsp;<a class="recipient-remove" style="visibility:hidden">X</a></span>');
        this.listenTo(this.model, 'destroy', this.remove);
    },
    render: function() {
        this.$el.html(this.template());
        this.$('.recipient-name').text(this.model.get('value'));
        return this;
    },
    removeRecipient: function(e) {
        e.stopPropagation();
        e.preventDefault();
        this.model.destroy();
    },
    showRemove: function() {
        this.$('.recipient-remove').css('visibility', 'visible');
    },
    hideRemove: function() {
        this.$('.recipient-remove').css('visibility', 'hidden');
    }
});

gus.RelatedListView = Backbone.View.extend({
    events: {
        'click .relatedListsMenuContainer a': '_onMenuItemClicked'
    },
    initialize: function() {
        this.template = _.template($('#template-relatedlistcontainer').html());
    },
    render: function() {
        this.$el.html(this.template());
        
        //create the comments view
        var commentList = new gus.CommentList(this.model.getComments(), {
            comparator: function(model1, model2) {
                var model1Moment = model1.getAsMoment('Comment_Created_Date__c');
                var model2Moment = model2.getAsMoment('Comment_Created_Date__c');
                
                //give sorting priority to nulls
                if(model1Moment && !model2Moment) {
                    return 1;
                } else if(!model1Moment && model2Moment) {
                    return -1;
                } 
                
                //sort by descending created date
                return -model1Moment.diff(model2Moment);
            }
        });
        this.commentListView = new gus.CommentListView({
            collection: commentList
        });
        this.commentListView.render();
        
        //create the recipient view
        this.recipientView = new gus.RecipientView({
            model: this.model
        });
        this.recipientView.render();
        
        //create a blank view
        this.blankView = new Backbone.View();
        
        //start out on the comment list view
        this._switchTo(this.$('.item-comments'), this.commentListView);
        
        return this;
    },
    _onMenuItemClicked: function(event) {
        event.stopPropagation();
        event.preventDefault();
        
        var $link = $(event.target);
        if($link.hasClass('item-comments')) {
            this._switchTo($link, this.commentListView);
        } else if($link.hasClass('item-recipients')) {
            this._switchTo($link, this.recipientView);
        } else {
            //item-ereleaserequests
            //item-changelists
            //item-themes
            //item-releasestamps
            this._switchTo($link, this.blankView);
        }
    },
    _switchTo: function(link, view) {
        //change the menu
        link.closest('ul').find('li.active').removeClass('active');
        link.closest('li').addClass('active');
        
        //change the container
        this.$('.related-lists-view-container').empty().append(view.el);
    }
});
gus.CommentListItemView = Backbone.View.extend({
    tagName: 'div',
    className: 'comment',
    template: null, 
    initialize: function() {
        this.template = _.template($('#template-commentItem').html());
    },
    render: function() {
        this.$el.html(this.template(this.model.toJSON()));
        this.$('.comment-createdDate').text('[' + this.model.getAsMoment('Comment_Created_Date__c').format('MM/DD/YYYY h:mm:ss A') + ']');
        this.$('.comment-body pre').text((this.model.get('Body__c') || '').replace(/\+/g,  ' '));
        
        this.$('.comment-loading').show();
        this.model.getOrFetchRelated('Comment_Created_By__c', gus.UserModel)
            .always(_.bind(function() {
                this.$('.comment-loading').hide();
            }, this))
            .done(_.bind(function(user){
                this.$('.comment-createdBy').text(user.get('Name'));
                this.$('.comment-img').show().attr('src', user.get('SmallPhotoUrl'));
            }, this))
            .fail(_.bind(function() {
                this._onError('Failed to load the user associated to the comment: ' + this.model.get('Comment_Created_By__c'));
            }, this));
    },
    _onError: function(attributes) {
        console.error(attributes.messages);
    }
});
gus.CommentListView = Backbone.View.extend({
    tagName: 'div',
    className: 'commentListView',
    initialize: function() {
        this.template = _.template($('#template-commentview').html());
    },
    render: function() {
        this.$el.html(this.template({}));
        this.collection.each(_.bind(this._addComment, this))
        return this;
    },
    _addComment: function(comment) {
        var view = new gus.CommentListItemView({
            model: comment
        });
        view.render();
        this.$el.append(view.el);
    }
});

function parseVfJson(value) {
    return JSON.parse(_.unescape(value));
}



var view, selectedWork;

//set up the lookup caches
gus.getCache(gus.RecordTypeModel).reset(parseVfJson(recordTypesAsJson));
gus.getCache(gus.ProductTagModel).reset(parseVfJson(productTagsAsJson));
gus.getCache(gus.TeamModel).reset(parseVfJson(teamsAsJson));
gus.getCache(gus.ImpactModel).reset(parseVfJson(impactsAsJson));
gus.getCache(gus.FrequencyModel).reset(parseVfJson(frequenciesAsJson));

//create the work
selectedWork = new gus.WorkModel(parseVfJson(selectedWorkAsJson));

$(function() {
    var viewMappings = {
        'Bug': gus.BugWorkView,
        'User Story': gus.UserStoryWorkView
    }
    selectedWork.getRecordType()
        .done(function(recordType){
            //change the page title
            var previousTitle = $('title').text();
            if(selectedWork.isNew()) {
                $('title').text(recordType.get('Name') + ' ~ ' + previousTitle);
            } else {
                $('title').text('Work: ' + selectedWork.get('Name') + ' ~ ' + previousTitle);
            }
            
            var ViewClass = viewMappings[recordType.get('Name')];
            if(!ViewClass) {
                throw new Error('No view class found for the specified record type: ' + recordType.get('Name'));
            }
            
            view = new ViewClass({
                model: selectedWork,
                el: $('.view-workForm')
            });
            view.render();
        })
        .fail(function() {
            throw new Error('Failed to load record type: ' + selectedWork.get('RecordTypeId'));
        });
});

