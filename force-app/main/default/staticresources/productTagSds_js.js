
function ProductTagDataStore(parameters) {
    parameters = parameters || {};

    this._data = [];

    //set up the comparator
    var stringSort = function(string1, string2) {
        var string1Lower = string1.toLowerCase();
        var string2Lower = string2.toLowerCase();

        if(string1Lower < string2Lower) {
            return -1;
        }
        if(string1Lower > string2Lower) {
            return 1;
        }
        return 0;
    };
    this.comparator = parameters.comparator || function(tag1, tag2) {

        //sort by team name
        var teamSort = stringSort(tag1.Team__r.Name, tag2.Team__r.Name);
        if(teamSort != 0) {
            return teamSort;
        }

        //sort by tag name
        return stringSort(tag1.Name, tag2.Name);
    };

    var matchesTagName = function(tag, /*String*/name) {
       return tag && tag.Name && name.toLowerCase() === tag.Name.toLowerCase();
    };

    /**
     * Gets the first tag with the specified name.
     */
    this.getTagByName = function(/*String*/ name) {
        return this.first(function(tag) {
            return matchesTagName(tag, name);
        });
    };

    /**
     * Gets all of the tags with the specified name.
     */
    this.getTagsByName = function(/*String*/ name) {
        return this.filter(function(tag) {
            return matchesTagName(tag, name);
        });
    };

    /**
     * Gets the tag with the specified ID.
     */
    this.getTagById = function(/*String*/ id) {
        return this.first(function(value) {
            return value.Id === id;
        });
    };

    /**
     * Searches the product tags for one matching the specified search
     * term.
     */
    this.search = function(/*String*/ term) {
        var termParts = term.split(' ');

        /**
         * @function
         * @description This search algorithm splits the specified search term
         * into parts by the space. Each part must be found in the team or the name
         * field.
         *
         * For example, given the search term "dog biscuit", the parts "dog" and
         * "biscuit" must be found within either the team name or the tag.
         *
         * @param {Object} value The sObject representing the product tag.
         */
        var andSearchAlgo = function(value) {
            var haystack = this.getTeamName(value) + ' ' + this.getTagName(value);

            for(index = 0; index < termParts.length; index++) {
                var needle = $.trim(termParts[index]);

                //disregard any blank
                if(needle == null || needle.length == 0) {
                    continue;
                }

                //disregard the delimiter if specified
                if(needle == '>') {
                    continue;
                }

                if(haystack.toLowerCase().indexOf(needle.toLowerCase()) == -1) {
                    return false;
                }
            }

            return true;
        };

        return $.grep(this._data, $.proxy(andSearchAlgo, this));
    };

    this.getTeamName = function(value) {
        return value.Team__r.Name;
    };

    this.getTagName = function(value) {
        return value.Name;
    }
}
ProductTagDataStore.prototype = {
    first: function(iter) {
        for(var index = 0; index < this._data.length; index++) {
            var value = this._data[index];
            if(iter.apply(value, [value, index])) {
                return value;
            }
        }
        return void 0;
    },
    each: function(iter) {
        for(var index = 0; index < this._data.length; index++) {
            var value = this._data[index];
            iter.apply(value, [value, index]);
        }
    },
    filter: function(iter) {
        var items = [];
        for(var index = 0; index < this._data.length; index++) {
            var value = this._data[index];
            if(iter.apply(value, [value, index])) {
                items.push(value);
            }
        }
        return items;
    },
    sort: function() {
        this._data.sort(this.comparator);
    },
    reset: function(data) {
        this._data = data;
        this.sort();
        $(this).triggerHandler('reset');
    }
};


var ProductTag = function() {
    this.initialize.apply(this, arguments);
};
ProductTag.prototype = {
    initialize: function(options) {
        this.$el = options.el instanceof $ ? options.el : $(options.el);
        this.dataStore = options.dataStore || new ProductTagDataStore();

        //the element must be present in order to attach events
        this.$el.delegate('.productTagItemRemove', 'click', $.proxy(function(event){
            event.preventDefault();
            console.debug('removing product tag:' + this.tag.Name);
            this.unselectTag();
            this.$('.productTagInput').focus();
            $(this).trigger('remove');
        }, this));
    },
    /**
     * Shows the product tag status
     */
    showStatus: function() {
        this.$('.productTagStatus').show();
    },
    hideStatus: function() {
        this.$('.productTagStatus').hide();
    },
    getValue: function() {
        if(this.tag) {
            return this.tag.Id;
        }
        return void 0;
    },
    render: function() {
        this.initializeInput();

        //create the label control
        //$('<div class="productTagItem curvedContainer" style="display:none"><span class="productTagItemBody"><span class="productTagItemTeam"></span> <span class="productTagItemName curvedContainer"></span></span><span class="productTagItemRemove" alt="Remove" title="Remove">&nbsp;</span></div>').prependTo(this.$el);
        $('<span class="slds-pill productTagItem" style="display:none"><span class="slds-pill__label"><svg aria-hidden="true" class="slds-icon slds-icon-standard-account slds-icon--small"><use xlink:href="/resource/SLDS_assets/icons/standard-sprite/svg/symbols.svg#quotes"></use></svg><span class="productTagItemTeam"></span> <span class="productTagItemName"></span></span><button class="slds-button slds-button--icon-bare productTagItemRemove"><svg aria-hidden="true" class="slds-button__icon"><use xlink:href="/resource/SLDS_assets/icons/utility-sprite/svg/symbols.svg#close"></use></svg><span class="slds-assistive-text">Remove</span></button></span>').prependTo(this.$el);
        return this;
    },
    /**
     * Initializes the input field
     */
    initializeInput: function() {
        var productTag = this;
        this.$('.productTagInput')
            .attr('aria-expanded','false')
            .attr('aria-activedescendant','')
            .attr('aria-describedby','')
            .attr('aria-haspopup','true')
            .attr('aria-autocomplete','list')
            .attr('role','combobox')
            .autocomplete({
                source: function(request, response) {
                    var searchResults = productTag.dataStore.search(request.term);
                    response(searchResults);
                },

                change: function(event, ui) {
                    var item = null;
                    if(ui.item) {
                        //user selected a known item
                        item = ui.item;
                    } else {
                        //user didnt select an item but assume they know what they are doing
                        var tagName = $(this).val();
                        var tags = productTag.dataStore.getTagsByName(tagName);
                        if(tags.length == 0) {
                            console.debug('tag name not found in the available list');
                            $(productTag).trigger('error', {message: 'No tag found with name of ' + tagName});
                        } if(tags.length > 1) {
                            console.debug('tag name is not unique');
                            $(this).autocomplete('search');

                        } else {
                            item = tags[0];
                        }
                    }

                    if(item) {
                        productTag.selectTag(item);
                    }
                },

                focus: function(event, ui) {
                    $(this).attr('aria-activedescendant','selection-' + ui.item.Id);
                    $(this).html(ui.item.Team__r.Name + ' &gt; ' + ui.item.Name);
                    return false;
                },

                select: function(event, ui) {
                    productTag.selectTag(ui.item);
                    return false;
                },
                open: function(event, ui) {
                    $(this).attr('aria-expanded','true');
                },

                close: function(event, ui) {
                    $(this).attr('aria-expanded','false').attr('aria-activedescendant','');
                }


            })
            .data("autocomplete")._renderItem = function(ul, item){
                return $('<li role="presentation"><a role="option" id="selection-' + item.Id + '"><span style="font-style:italic; color:#999"><span class="selectItemTeamName"></span>&nbsp;&gt;&nbsp;</span><span class="selectItemTagName"></span></a></li>')
                    .find('.selectItemTeamName').html(item.Team__r.Name).end()
                    .find('.selectItemTagName').html(item.Name).end()
                    .data("item.autocomplete", item)
                    .appendTo(ul);
            };
    },

    selectTag: function(/*Object*/ selectedTag, options) {
        if(!options) {
            options = {};
        }
        if(options.silent == void 0) {
            options.silent = false;
        }

        if(!this.tag || (this.tag && this.tag.Id !== selectedTag.Id)) {
            var previousValue = this.tag ? this.tag.Id : null;
            this.tag = selectedTag;

            this._updateProductTagItem(this.tag);
            this._clearAndHideInput();

            if(!options.silent) {
                $(this).trigger('change:tag');
            }
        }
    },

    unselectTag: function() {
        if(this.tag) {
            var previousValue = this.tag.Id;
            this.tag = null;

            this.showInput();
            this.$('.productTagItem').hide();

            $(this).trigger('change:tag');
        }
    },

    showInput: function() {
        this.$('.productTagInput').show();
    },

    /**
     * Clears the input and hides it from the user
     */
    _clearAndHideInput: function() {
        this.$('.productTagInput').val('').hide();
    },

    /**
     * Updates the UI for the selected interface
     */
    _updateProductTagItem: function(/*Object*/ tag) {
        this.$('.productTagItem')
            .show()
            .find('.productTagItemTeam').html(tag.Team__r.Name).end()
            .find('.productTagItemName').html(tag.Name).end();
    },

    $: function(selector) {
        return this.$el.find(selector);
    }
};
