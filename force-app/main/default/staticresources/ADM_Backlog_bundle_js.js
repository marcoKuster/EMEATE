/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _middleware = __webpack_require__(5);

	var _middleware2 = _interopRequireDefault(_middleware);

	var _reducerEnhancers = __webpack_require__(6);

	var _reducerEnhancers2 = _interopRequireDefault(_reducerEnhancers);

	var _reducers = __webpack_require__(7);

	var _reducers2 = _interopRequireDefault(_reducers);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	var _index = __webpack_require__(8);

	var _index2 = _interopRequireDefault(_index);

	var _index3 = __webpack_require__(17);

	var _index4 = _interopRequireDefault(_index3);

	var _index5 = __webpack_require__(27);

	var _index6 = _interopRequireDefault(_index5);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	// IMPORTANT: ADM_BACKLOG_PAGE_VARS with certain props, like teamid & sprintid are required as global objets outside of this app //

	var Provider = ReactRedux.Provider,
	    connect = ReactRedux.connect,
	    createStore = Redux.createStore,
	    applyMiddleware = Redux.applyMiddleware,
	    ReduxThunk = window.ReduxThunk.default;

	var mapStateToWorkManagerTableAppProps = function mapStateToWorkManagerTableAppProps(state, ownProps) {
	    return {
	        dataObject: _selectors2.default.getDataObject(state),
	        recordsToDisplay: _selectors2.default.getRecordsToDisplay(state),
	        numVisibleRecordsWithoutHeaders: _selectors2.default.getNumVisibleRecordsWithoutHeaders(state),
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerTableAppProps = function mapDispatchToWorkManagerTableAppProps(dispatch, ownProps) {
	    return {
	        refreshData: function refreshData(dataObject, overrideHistoryCheck, initialLoad, viewChangeRequested, paramId, selectedText) {
	            dispatch(_actionCreators2.default.refreshData(dataObject, overrideHistoryCheck, initialLoad, viewChangeRequested, paramId, selectedText));
	        }
	    };
	};

	var WorkManagerTableApp = React.createClass({
	    displayName: 'WorkManagerTableApp',

	    getInitialState: function getInitialState() {
	        return {
	            windowWidth: window.innerWidth
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        window.addEventListener('resize', this.handleWindowResize);
	    },

	    componentWillMount: function componentWillMount() {
	        this.props.refreshData(this.props.dataObject, null, true);
	    },

	    componentWillUnmount: function componentWillUnmount() {
	        window.removeEventListener('resize', this.handleWindowResize);
	    },

	    handleWindowResize: function handleWindowResize(e) {
	        this.setState({ windowWidth: window.innerWidth });
	    },

	    render: function render() {
	        if (!this.props || !this.props.dataObject || !this.props.dataObject || !this.props.dataObject.recordIds || !this.props.dataObject.recordsObj || !this.props.dataObject.columns) {
	            return React.createElement(
	                'div',
	                { className: 'slds-spinner--large', style: { 'margin': '0px auto' } },
	                React.createElement('img', { src: '/resource/' + this.props.nameSpace + 'SLDS091/assets/images/spinners/slds_spinner_brand.gif', alt: 'Loading...' })
	            );
	        }

	        var dataObject = this.props.dataObject;
	        var recordsToDisplay = this.props.recordsToDisplay;
	        var windowWidth = !globalWorkManagerIsInAloha ? this.state.windowWidth : this.state.windowWidth - 20;
	        var numVisibleRecordsWithoutHeaders = this.props.numVisibleRecordsWithoutHeaders;

	        return React.createElement(
	            'div',
	            { className: 'slds', style: { width: windowWidth } },
	            React.createElement(_index2.default, { numVisibleRecordsWithoutHeaders: numVisibleRecordsWithoutHeaders, windowWidth: windowWidth, fullscreenId: "workManagerOutputPanelWrapper" }),
	            React.createElement(_index6.default, { windowWidth: windowWidth, dataObject: dataObject }),
	            React.createElement(_index4.default, { recordsToDisplay: recordsToDisplay, dataObject: dataObject }),
	            React.createElement('div', { className: 'slds-modal-backdrop' })
	        );
	    }
	});

	WorkManagerTableApp = connect(mapStateToWorkManagerTableAppProps, mapDispatchToWorkManagerTableAppProps)(WorkManagerTableApp);
	//============================================================== END WORKMANAGERTABLE ==============================================================//


	// <Provider store={createStore(REDUCERS, _.compose(
	//         applyMiddleware(ReduxThunk),
	//         window.devToolsExtension ? window.devToolsExtension() : f => f
	//     ))}>
	//     <WorkManagerTableApp />
	// </Provider>,
	// <Provider store={createStore(REDUCERS, applyMiddleware(ReduxThunk, CUSTOMMIDDLEWARE.logger))}>

	ReactDOM.render(React.createElement(
	    Provider,
	    { store: createStore(_reducers2.default, applyMiddleware(ReduxThunk)) },
	    React.createElement(WorkManagerTableApp, null)
	), document.getElementById('work-manager-app'));

/***/ },
/* 1 */
/***/ function(module, exports) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
		value: true
	});

	var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

	function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

	var helper = {

		//============================================================== UTILS FOR WORKING WITH DATA OBJECT ====================================================================//
		labelToDataObjectProp: function labelToDataObjectProp(label) {
			switch (label) {
				case 'Found In Build':
				case 'Scheduled Build':
					return 'allBuilds';
				case 'Status':
					return 'allWorkStatuses';
				case 'Epic':
				case 'Sprint':
				case 'Kanban State':
				case 'Product Tag':
				case 'Record Type':
				case 'Assignee':
				case 'QA Engineer':
				case 'Product Owner':
					return 'all' + label.replace(' ', '') + 's';
				case 'Points':
					return 'all' + label.replace(' ', '');
				default:
					return 'clientsideGrouping';
			}
		},

		getNewUpdatedSprints: function getNewUpdatedSprints(updatedRecordIds, dataObject) {
			var updatedSprints = dataObject.updatedSprints;
			var newUpdatedSprints = updatedSprints.slice();

			updatedRecordIds.forEach(function (selectedId) {
				var thisSprintId = dataObject.recordsObj[selectedId].Sprint_id;
				if (!thisSprintId) {
					thisSprintId = 'NO SPRINT';
				}
				if (newUpdatedSprints.indexOf(thisSprintId) === -1) {
					newUpdatedSprints = newUpdatedSprints.concat(thisSprintId);
				}
			});
			return newUpdatedSprints;
		},

		getRecordsFromDataObject: function getRecordsFromDataObject(dataObject) {
			return dataObject.recordIds.map(function (recordId) {
				return dataObject.recordsObj[recordId];
			});
		},

		//============================================================== DISPLAYING/UPDATING DATA OBJECT ====================================================================//
		mapColumnLabelToWidth: function mapColumnLabelToWidth(label) {
			if (!label) return 300;
			switch (label) {
				case 'ID':
				case 'Priority':
					return 100;
				case 'Subject':
					return 300;
				case 'Assignee':
				case 'QA Engineer':
				case 'Product Owner':
				case 'Epic':
					return 200;
				case 'Status':
				case 'Sprint':
				case 'Kanban State':
				case 'Product Tag':
				case 'Found In Build':
				case 'Scheduled Build':
				case 'Created Date':
				case 'Modified Date':
					return 150;
				case 'Points':
				case 'Rank':
					return 75;
				case 'Record Type':
					return 30;
				default:
					return 300;
			}
		},

		orderDates: function orderDates(sortColumn, sortDirection) {
			return function (a, b) {
				if (sortColumn && sortColumn.slice(-4).toLowerCase() !== 'date') return 0;
				return sortDirection === 'descending' ? new Date(b) - new Date(a) : new Date(a) - new Date(b);
			};
		},

		orderStatuses: function orderStatuses(dataObject, sortColumn, sortDirection) {
			var allWorkStatusesObj = dataObject.allWorkStatuses.reduce(function (obj, curr) {
				obj[curr.Name] = { order: curr.Order__c };
				return obj;
			}, {});

			return function (a, b) {
				if (sortColumn !== 'Status') return 0;
				var statusA = allWorkStatusesObj[a];
				var statusB = allWorkStatusesObj[b];
				if (statusA === statusB) {
					return 0;
				} else if (!statusA) {
					return sortDirection === 'ascending' ? 1 : -1;
				} else if (!statusB) {
					return sortDirection === 'ascending' ? -1 : 1;
				} else if (sortDirection === 'ascending') {
					return statusA.order < statusB.order ? -1 : 1;
				} else {
					return statusA.order < statusB.order ? 1 : -1;
				}
			};
		},

		makeNoGroupLast: function makeNoGroupLast(arrayOfStrings) {
			var helper = this;
			var noGroupIdx = helper.findIndex(arrayOfStrings, function (str) {
				return str.indexOf('NO ') === 0;
			});
			if (noGroupIdx !== -1) {
				var noGroup = arrayOfStrings[noGroupIdx];
				var beg = arrayOfStrings.slice(0, noGroupIdx);
				var end = arrayOfStrings.slice(noGroupIdx + 1, arrayOfStrings.length);
				return beg.concat(end).concat(noGroup);
			} else {
				return arrayOfStrings;
			}
		},

		setDisplayForFilteredAndMovedRecords: function setDisplayForFilteredAndMovedRecords(filterString, records, selected) {
			var helper = this;
			if (!filterString || filterString.length === 0) {
				return records.map(function (record) {
					return _extends({}, record, { display: true });
				});
			}

			var filterObj = helper.makeFilterObj(filterString, records);
			var arrays = Object.keys(filterObj).reduce(function (arr, key) {
				arr.push(filterObj[key]);
				return arr;
			}, []);

			if (arrays.length === 0) return records;

			var intersection = helper.getIntersection(arrays);

			return records.map(function (record) {
				var recordClone = _extends({}, record);
				recordClone.display = intersection.indexOf(record.Id) !== -1 ? true : false;
				if (recordClone.moved || selected.indexOf(record.Id) !== -1 || recordClone.rowHeader) {
					// dont hide moved or selected records even if they are filtered out.
					recordClone.display = true;
				}
				return recordClone;
			});
		},

		makeRecordsAndHeadersFromGroupings: function makeRecordsAndHeadersFromGroupings(groupings, dataObject, sortColumn, sortDirection) {
			var recordsToDisplay = [];
			var helper = this;

			var orderedGroupings = Object.keys(groupings);
			if (sortColumn === 'Status') {
				orderedGroupings = orderedGroupings.sort(helper.orderStatuses(dataObject, sortColumn, sortDirection));
			} else if (sortColumn === 'Modified Date' || sortColumn === 'Created Date') {
				orderedGroupings = orderedGroupings.sort(helper.orderDates(sortColumn, sortDirection));
			} else if (sortColumn === 'Points') {
				orderedGroupings = orderedGroupings.map(function (numberString) {
					return numberString.indexOf('NO ') !== 0 ? parseInt(numberString, 10) : numberString;
				}).sort(helper.makeSortNumsFunc(sortDirection)).map(function (num) {
					return num.toString();
				});
			} else {
				orderedGroupings = orderedGroupings.sort(helper.makeSortStringsFunc(sortDirection));
			}
			orderedGroupings = helper.makeNoGroupLast(orderedGroupings);

			orderedGroupings.forEach(function (group) {
				groupings[group].forEach(function (recordId, idx) {
					if (idx === 0) {
						recordsToDisplay.push({ idOfFirstRecord: recordId, rowHeader: group, display: true }); // add rowHeader
					}
					recordsToDisplay.push(_extends({}, dataObject.recordsObj[recordId], { display: true }));
				});
			});

			return recordsToDisplay;
		},

		makeSortNumsFunc: function makeSortNumsFunc(sortDirection) {
			return function (a, b) {
				if (sortDirection !== 'descending') {
					sortDirection = 'ascending';
				}
				if (a === b) {
					return 0;
				} else if (!a && a !== 0) {
					return sortDirection === 'ascending' ? 1 : -1;
				} else if (!b && b !== 0) {
					return sortDirection === 'ascending' ? -1 : 1;
				} else if (a > b) {
					return sortDirection === 'ascending' ? 1 : -1;
				} else if (a < b) {
					return sortDirection === 'ascending' ? -1 : 1;
				}
			};
		},

		makeSortStringsFunc: function makeSortStringsFunc(sortDirection) {
			return function (a, b) {
				if (sortDirection !== 'descending') {
					sortDirection = 'ascending';
				}
				var a = a ? a.toLowerCase() : undefined;
				var b = b ? b.toLowerCase() : undefined;
				if (a === b) {
					return 0;
				} else if (!a) {
					return sortDirection === 'ascending' ? 1 : -1;
				} else if (!b) {
					return sortDirection === 'ascending' ? -1 : 1;
				} else if (a > b) {
					return sortDirection === 'ascending' ? 1 : -1;
				} else if (a < b) {
					return sortDirection === 'ascending' ? -1 : 1;
				}
			};
		},

		setDisplayBasedOnSearch: function setDisplayBasedOnSearch(searchTerm, recordsToDisplay, selected, columns) {
			if (typeof searchTerm !== 'undefined' && searchTerm !== '') {
				recordsToDisplay = recordsToDisplay.map(function (record) {
					if (record.rowHeader || !record.display || selected.indexOf(record.Id) !== -1 || record.moved) return record;

					var recordDataString = '';
					columns.forEach(function (column) {
						if (record[column.label + '_value'] && record[column.label + '_value'] !== 0) {
							recordDataString += ' ' + record[column.label + '_value'];
						}
					});
					record.display = recordDataString.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1 ? true : false;
					return record;
				});
			}
			return recordsToDisplay;
		},

		updateRecordsBasedOnRank: function updateRecordsBasedOnRank(recordIds, targetRecord, selectedIds, recordsObj, sortColumn, sortDirection) {
			var helper = this;
			// sort the records in rank order
			var records = recordIds.map(function (id) {
				return recordsObj[id];
			});
			var orderedRecordIds = helper.sortNonGroupableRecords(records, sortColumn, sortDirection).map(function (record) {
				return record.Id;
			});

			// then update based on drag
			var updatedRecordIds = helper.updateRecordIdsBasedOnDrag(orderedRecordIds, selectedIds, targetRecord.Id, sortDirection);
			var updatedRecordsObj = {};

			for (var idx = 0, len = updatedRecordIds.length; idx < len; idx++) {
				var _extends2;

				var value = idx + 1;
				var valueProp = 'Rank_value';
				var recordId = updatedRecordIds[idx];
				// var valuePropMoved = column.label + '_moved_light';
				var valuePropMoved = sortColumn + '_moved_dark';
				updatedRecordsObj[recordId] = _extends({}, recordsObj[recordId], (_extends2 = {}, _defineProperty(_extends2, valueProp, value), _defineProperty(_extends2, valuePropMoved, true), _extends2));
			}

			selectedIds.forEach(function (id) {
				updatedRecordsObj[id].moved = true;
			});

			return {
				recordIds: updatedRecordIds,
				recordsObj: updatedRecordsObj
			};
		},

		updateRecordIdsBasedOnDrag: function updateRecordIdsBasedOnDrag(recordIds, selected, dropTargetId, sortDirection) {
			var helper = this;
			var unselectedIds = [];
			var indexOfTarget;
			var indexOfSelected;
			var originalIndexOfTarget;
			var orderedSelected = [];
			var selectedLength = selected.length;

			for (var idx = 0, len = recordIds.length; idx < len; idx++) {
				var recordId = recordIds[idx];
				if (recordId === dropTargetId) {
					originalIndexOfTarget = idx;
				}

				// For performance, stop looping once we've reached all selected items
				if (orderedSelected.length === selectedLength) {
					var _unselectedIds;

					var remainingIds = recordIds.slice(idx);
					unselectedIds = (_unselectedIds = unselectedIds).concat.apply(_unselectedIds, _toConsumableArray(remainingIds));
					break;
				}
				if (selected.indexOf(recordId) === -1) {
					unselectedIds.push(recordId);
				} else {
					indexOfSelected = idx;
					orderedSelected.push(recordId);
				}
			}

			var indexOfTarget = helper.findIndex(unselectedIds, function (recordId) {
				return recordId === dropTargetId;
			});
			// if we're dragging downwards, adjust
			if (indexOfSelected < originalIndexOfTarget) {
				indexOfTarget++;
			}
			var arrBeforeTarget = unselectedIds.slice(0, indexOfTarget);
			var arrAfterTarget = unselectedIds.slice(indexOfTarget, unselectedIds.length);
			var updatedRecordIds = arrBeforeTarget.concat(orderedSelected).concat(arrAfterTarget);
			if (sortDirection === 'descending') {
				updatedRecordIds = updatedRecordIds.reverse();
			}
			return updatedRecordIds;
		},

		sortNonGroupableRecords: function sortNonGroupableRecords(records, label, sortDirection) {
			var sortedRecords = _.sortBy(records, function (record) {
				var value = record[label + '_value'];
				// Handle sorting ID's like numbers instaed of strings (to handle ID's with different lengths)
				if (label === 'ID' && value && value.indexOf('W-') === 0) {
					return parseInt(value.replace('W-', ''), 10);
				}
				// underscore's _.sortBy method needs undefined returned to put null items at the bottom
				if (value === null || typeof value === 'undefined') {
					return undefined;
				}
				return typeof value === 'string' ? value.toLowerCase() : value;
			});

			if (sortDirection === 'descending') {
				sortedRecords.reverse();
			}

			return sortedRecords;
		},

		showVelocityLine: function showVelocityLine(options, searchTerm, teamId) {
			// TODO - break each line out into own function -- then check each & surface the reason why velocity line isn't
			// showing up in the UI if options.showVelocityLine is true but something else is false
			var noFilters = function noFilters(options, teamId) {
				return !options.filters || typeof options.filters === 'string' || !options.filters[teamId];
			};
			var noSearchTerm = function noSearchTerm(searchTerm) {
				return !searchTerm || typeof searchTerm === 'string' && searchTerm.length === 0;
			};
			var avgVelocityExists = function avgVelocityExists(options) {
				return typeof options.averageVelocity === 'number' && options.averageVelocity > 0;
			};

			return options && options.showVelocityLine && noFilters(options, teamId) && noSearchTerm(searchTerm) && avgVelocityExists(options);
		},

		giveRecordsVelocityLine: function giveRecordsVelocityLine(label, records, options, searchTerm, teamId) {
			var helper = this;
			var showVelocityLine = helper.showVelocityLine(options, searchTerm, teamId);

			if (label === 'Rank' && !showVelocityLine) {
				return records.map(function (record) {
					return _extends({}, record, { velocityLine: false });
				});
			} else if (label === 'Rank' && showVelocityLine) {
				var storyPointsCount = 0;
				var numRecords = records.length;
				return records.reduce(function (updatedRecords, record, idx) {
					// Don't do anything with the first record.
					var storyPoints = record["Points_value"];
					if (storyPoints) {
						storyPointsCount += storyPoints;
						if (storyPointsCount > options.averageVelocity) {
							storyPointsCount = storyPoints;
							return [].concat(_toConsumableArray(updatedRecords), [_extends({}, record, { velocityLine: true })]);
						} else {
							return [].concat(_toConsumableArray(updatedRecords), [_extends({}, record, { velocityLine: false })]);
						}
					} else {
						return [].concat(_toConsumableArray(updatedRecords), [_extends({}, record, { velocityLine: false })]);
					}
				}, []);
			}

			return records;
		},

		makeFilterObj: function makeFilterObj(filterString, records) {
			var globalFilterObj = {};
			// substring(0, filterString.length - 1) is to get rid of the expected trailing comma in the filterString
			if (!filterString || filterString === '') return globalFilterObj;
			var filterObjectsArr = filterString !== '' ? filterString.substring(0, filterString.length - 1).split(",").map(function (filter) {
				return filter.split("-");
			}) : [];
			// each filterObjectArray should be exactly 3 elements
			if (filterObjectsArr.length === 0 || filterObjectsArr[0].length === 1 || filterObjectsArr[0].length === 2) return globalFilterObj;
			records.forEach(function (record) {
				filterObjectsArr.forEach(function (filterObj) {
					// filterProp is something like "RecordTypeId". filterVal is the actual ID. i.e. "23982374329823"
					// this was necessary to achieve parity with how old filters were created.
					var filterProp = filterObj[1];
					var filterPropVal = filterObj[2] !== 'null' ? filterObj[2] : null;
					var addIdToGlobalFilterObj = function addIdToGlobalFilterObj(filterProp, id) {
						!globalFilterObj[filterProp] ? globalFilterObj[filterProp] = [id] : globalFilterObj[filterProp].push(id);
					};
					if (filterProp === 'RecordTypeId' && record['Record Type_id'] === filterPropVal) {
						addIdToGlobalFilterObj(filterProp, record.Id);
					} else if (filterProp === 'Found_in_Build') {
						if (record['Found In Build_id'] === filterPropVal || !record['Found In Build_id'] && filterPropVal === null) {
							addIdToGlobalFilterObj(filterProp, record.Id);
						}
					} else if (filterProp === 'status' && record.Status_value && record.Status_value.replace(/ +/g, '').toLowerCase() === filterPropVal) {
						addIdToGlobalFilterObj(filterProp, record.Id);
					} else if (filterProp === 'story_points') {
						if (record.Points_value && record.Points_value === parseInt(filterPropVal, 10)) {
							addIdToGlobalFilterObj(filterProp, record.Id);
						} else if (!record.Points_value && filterPropVal === null) {
							addIdToGlobalFilterObj(filterProp, record.Id);
						}
					} else if (filterProp === 'Column') {
						if (record['Kanban State_id'] && record['Kanban State_id'] === filterPropVal || !record['Kanban State_id'] && !filterPropVal) {
							addIdToGlobalFilterObj(filterProp, record.Id);
						}
					} else {
						if (record[filterProp.replace(/_/g, ' ') + '_id'] === filterPropVal || !record[filterProp.replace(/_/g, ' ') + '_id'] && !filterPropVal) {
							addIdToGlobalFilterObj(filterProp, record.Id);
						}
					}
				});
			});
			return globalFilterObj;
		},

		updateColumnsBasedOnSort: function updateColumnsBasedOnSort(columns, sort) {
			if (!columns || !sort) {
				console.error('tried to update columns based on sort but no columns or sort: ', columns, sort);
				return;
			}
			return columns.map(function (column) {
				return column.label;
			}).reduce(function (arr, label) {
				if (label === sort.column) {
					arr.push({ label: sort.column, direction: sort.direction });
					return arr;
				} else {
					arr.push({ label: label });
					return arr;
				}
			}, []);
		},

		makeFilterDisplayString: function makeFilterDisplayString(filters) {
			// TODO - This is a hack
			// To fix, add filterObj to the dataObject, then remove all this code.
			if (!filters) {
				return '';
			}
			var parsedFilters = filters.split(',').slice(0, -1);
			var returnResult = parsedFilters.reduce(function (result, filter) {
				var addToFilterDisplayString = filter.split('-')[1];
				if (addToFilterDisplayString === 'RecordTypeId') {
					var addToResult = 'Record Type, ';
					if (result.indexOf(addToResult) === -1) {
						addToFilterDisplayString = addToResult;
					} else {
						addToFilterDisplayString = '';
					}
				} else if (addToFilterDisplayString === 'status') {
					var addToResult = 'Status, ';
					if (result.indexOf(addToResult) === -1) {
						addToFilterDisplayString = addToResult;
					} else {
						addToFilterDisplayString = '';
					}
				} else if (addToFilterDisplayString === 'Column') {
					var addToResult = 'Kanban State, ';
					if (result.indexOf(addToResult) === -1) {
						addToFilterDisplayString = addToResult;
					} else {
						addToFilterDisplayString = '';
					}
				} else if (['QA_Engineer', 'Product_Tag', 'Found_in_Build', 'Scheduled_Build'].indexOf(addToFilterDisplayString) > -1) {
					var addToResult = addToFilterDisplayString.replace(/_+/g, ' ') + ', ';
					if (result.indexOf(addToResult) === -1) {
						addToFilterDisplayString = addToResult;
					} else {
						addToFilterDisplayString = '';
					}
				} else if (addToFilterDisplayString === 'story_points') {
					var addToResult = 'Points, ';
					if (result.indexOf(addToResult) === -1) {
						addToFilterDisplayString = addToResult;
					} else {
						addToFilterDisplayString = '';
					}
				} else {
					if (result.indexOf(addToFilterDisplayString) === -1) {
						addToFilterDisplayString = addToFilterDisplayString + ', ';
					} else {
						addToFilterDisplayString = '';
					}
				}

				return result += addToFilterDisplayString;
			}, '');
			return returnResult;
		},

		//============================================================== UTILITY ====================================================================//
		findIndex: function findIndex(arr, fn) {
			if (!arr || !fn || typeof fn !== 'function' || (typeof arr === 'undefined' ? 'undefined' : _typeof(arr)) !== 'object') {
				console.warn('bad array or function passed into findIndex');
				return -1;
			}

			for (var i = 0, len = arr.length; i < len; i++) {
				if (fn(arr[i]) === true) {
					return i;
				}
			}
			return -1;
		},

		formatDate: function formatDate(date) {
			return moment(date).format('MM/DD/YYYY');
		},

		getIntersection: function getIntersection(arrays) {
			return arrays.shift().reduce(function (res, v) {
				if (res.indexOf(v) === -1 && arrays.every(function (a) {
					return a.indexOf(v) !== -1;
				})) res.push(v);
				return res;
			}, []);
		},

		makeNoLabel: function makeNoLabel(label) {
			return 'NO ' + label.toUpperCase();
		},

		addNamespace: function addNamespace(val, nameSpace) {
			return nameSpace && (val.indexOf('__c') !== -1 || val.indexOf('__r') !== -1) ? nameSpace + val : val;
		},

		makeRecordValFromColumnVal: function makeRecordValFromColumnVal(record, val, nameSpace) {
			// could be smarter about this I'm sure, but this works so leaving for now.
			var helper = this;
			if (!val && val !== 0) return null;
			var valsArr = val.indexOf('.') > -1 ? val.split('.') : [val];
			if (!nameSpace) {
				nameSpace = '';
			}

			if (valsArr.length === 1) return record[helper.addNamespace(valsArr[0], nameSpace)];else if (valsArr.length === 2) return record[helper.addNamespace(valsArr[0], nameSpace)] && record[helper.addNamespace(valsArr[0], nameSpace)][helper.addNamespace(valsArr[1], nameSpace)] ? record[helper.addNamespace(valsArr[0], nameSpace)][helper.addNamespace(valsArr[1], nameSpace)] : null;else if (valsArr.length === 3) return record[valsArr[0]] && record[valsArr[0]][valsArr[1]] && record[valsArr[0]][valsArr[1]][valsArr[2]] ? record[valsArr[0]][valsArr[1]][helper.addNamespace(valsArr[2], nameSpace)] : null;else if (valsArr.length === 4) return record[valsArr[0]] && record[valsArr[0]][valsArr[1]] && record[valsArr[0]][valsArr[1]][valsArr[2]] && record[valsArr[0]][valsArr[1]][valsArr[2]][valsArr[3]] ? record[valsArr[0]][valsArr[1]][valsArr[2]][helper.addNamespace(valsArr[3])] : null;
		},

		makeRecordTypeIcon: function makeRecordTypeIcon(recordType) {
			var recordTypeIcon;
			if (recordType == 'Bug') {
				recordTypeIcon = 'new_custom34';
			} else if (recordType == 'User Story') {
				recordTypeIcon = 'new_custom55';
			} else if (recordType == 'Investigation') {
				recordTypeIcon = 'new_custom39';
			} else if (recordType == 'ToDo') {
				recordTypeIcon = 'new_custom26';
			} else {
				recordTypeIcon = 'new_custom62';
			}
			return recordTypeIcon;
		},

		//============================================================== STRESS TESTING ====================================================================//
		createRandomString: function createRandomString(length) {
			return Math.round(Math.pow(36, length + 1) - Math.random() * Math.pow(36, length)).toString(36).slice(1);
		},

		getRandomElem: function getRandomElem(arr) {
			var length = arr.length;
			var idx = Math.floor(Math.random() * length);
			return arr[idx];
		},

		createTestRecord: function createTestRecord() {
			var helper = this;
			var id = helper.createRandomString(18);
			var name = 'W-' + helper.createRandomString(7);
			var subject = helper.createRandomString(30);
			var rank = helper.getRandomElem([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
			var storypoints = helper.getRandomElem([1, 2, 3, 5, 8, 13, 21]);
			var status = helper.getRandomElem(["New", "Triaged", "In Progress", "Ready for Review", "Fixed", "QA In Progress", "Closed", "Waiting", "Integrate", "Pending Release", "Duplicate", "Never", "Closed - New Bug Logged", "Closed - No Fix - Working as Designed", "Closed - Defunct", "Closed - No Fix - Will Not Fix", "Not Reproducible", "Closed - LAP Request Denied", "Not a bug", "Closed - Resolved Without Code Change", "Closed - Resolved With Internal Tools", "Closed - Doc/Usability", "Closed - Resolved with DB Script", "More Info Reqd from Support", "Closed - LAP Request Approved", "Rejected", "Closed - Duplicate", "Closed - No Fix - Feature Request", "Investigating", "Closed - Known Bug Exists", "Acknowledged"]);
			return {
				"testRecord": true,
				"attributes": {
					"type": "ADM_Work__c",
					"url": "/services/data/v37.0/sobjects/ADM_Work__c/" + id
				},
				"Id": id,
				"CreatedDate": "2016-02-10T17:03:14.000+0000",
				"LastModifiedDate": "2016-05-03T13:34:14.000+0000",
				"RecordTypeId": "0129000000006gDAAQ",
				"Name": name,
				"Subject__c": subject,
				"Priority_Rank__c": rank,
				"Story_Points__c": storypoints,
				"Status__c": "In Progress",
				"Found_in_Build__c": "a0622000000HmdjAAC",
				"Epic__c": "a3Q22000000CaRMEA0",
				"Column__c": "a3022000000000hAAA",
				"Product_Tag__c": "a1a22000000006OAAQ",
				"QA_Engineer__c": "005T0000000nFUeIAM",
				"Product_Owner__c": "005T0000000nFUeIAM",
				"Assignee__c": "00522000000Q3HXAA0",
				"CurrencyIsoCode": "USD",
				"RecordType": {
					"attributes": {
						"type": "RecordType",
						"url": "/services/data/v37.0/sobjects/RecordType/0129000000006gDAAQ"
					},
					"Name": "User Story",
					"Id": "0129000000006gDAAQ"
				},
				"Epic__r": {
					"attributes": {
						"type": "ADM_Epic__c",
						"url": "/services/data/v37.0/sobjects/ADM_Epic__c/a3Q22000000CaRMEA0"
					},
					"Name": "Navigation App Version 1",
					"Id": "a3Q22000000CaRMEA0",
					"CurrencyIsoCode": "USD"
				},
				"Column__r": {
					"attributes": {
						"type": "ADM_Column__c",
						"url": "/services/data/v37.0/sobjects/ADM_Column__c/a3022000000000hAAA"
					},
					"Name": "Code In Progress",
					"Id": "a3022000000000hAAA",
					"CurrencyIsoCode": "USD"
				},
				"Product_Tag__r": {
					"attributes": {
						"type": "ADM_Product_Tag__c",
						"url": "/services/data/v37.0/sobjects/ADM_Product_Tag__c/a1a22000000006OAAQ"
					},
					"Name": "Sample Product Tag",
					"Id": "a1a22000000006OAAQ",
					"CurrencyIsoCode": "USD"
				},
				"Found_in_Build__r": {
					"attributes": {
						"type": "ADM_Build__c",
						"url": "/services/data/v37.0/sobjects/ADM_Build__c/a0622000000HmdjAAC"
					},
					"Name": "st1.0",
					"Id": "a0622000000HmdjAAC",
					"CurrencyIsoCode": "USD"
				},
				"QA_Engineer__r": {
					"attributes": {
						"type": "User",
						"url": "/services/data/v37.0/sobjects/User/005T0000000nFUeIAM"
					},
					"Name": "James Hatton",
					"Username": "jhatton@gus.com.alexbaden",
					"SmallPhotoUrl": "https://gus--AlexBaden--c.cs27.content.force.com/profilephoto/005/T",
					"Id": "005T0000000nFUeIAM",
					"CurrencyIsoCode": "USD"
				},
				"Product_Owner__r": {
					"attributes": {
						"type": "User",
						"url": "/services/data/v37.0/sobjects/User/005T0000000nFUeIAM"
					},
					"Name": "James Hatton",
					"Username": "jhatton@gus.com.alexbaden",
					"SmallPhotoUrl": "https://gus--AlexBaden--c.cs27.content.force.com/profilephoto/005/T",
					"Id": "005T0000000nFUeIAM",
					"CurrencyIsoCode": "USD"
				},
				"Assignee__r": {
					"attributes": {
						"type": "User",
						"url": "/services/data/v37.0/sobjects/User/00522000000Q3HXAA0"
					},
					"Name": "Alex Baden Admin",
					"Username": "alexadmin@gus.com.alexbaden",
					"SmallPhotoUrl": "https://gus--AlexBaden--c.cs27.content.force.com/profilephoto/005/T",
					"Id": "00522000000Q3HXAA0",
					"CurrencyIsoCode": "USD"
				}
			};
		},

		createTestRecords: function createTestRecords(num) {
			var helper = this;
			var records = [];
			for (var i = 0; i < num; i++) {
				records.push(helper.createTestRecord());
			}
			return records;
		}
	};

	exports.default = helper;

/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

	var ACTIONCREATORS = {

	    addMoved: function addMoved(id, column) {
	        return {
	            type: 'ADD_MOVED',
	            id: id,
	            column: column
	        };
	    },

	    clearErrorMessages: function clearErrorMessages() {
	        return {
	            type: 'CLEAR_ERROR_MESSAGES'
	        };
	    },

	    clearFilters: function clearFilters(teamId) {
	        return {
	            type: 'CLEAR_FILTERS',
	            teamId: teamId
	        };
	    },

	    clearHistory: function clearHistory() {
	        return {
	            type: 'CLEAR_HISTORY'
	        };
	    },

	    clearMoved: function clearMoved() {
	        return {
	            type: 'CLEAR_MOVED'
	        };
	    },

	    clearSelected: function clearSelected() {
	        return {
	            type: 'CLEAR_SELECTED'
	        };
	    },

	    handleHeaderClick: function handleHeaderClick(label, sort, columns) {
	        var ACTIONCREATORS = this;
	        return function (dispatch, getState) {
	            dispatch(ACTIONCREATORS.updateSort(label, columns));
	            dispatch(ACTIONCREATORS.clearSelected());
	            // using setTimeout so that this fires on next event loop. This is an ugly (but effective) alternative to using a promise for flow control.
	            setTimeout(function () {
	                var cb = function cb(err, success) {
	                    if (err) console.error(err);else console.log('User preferences successfully saved!');
	                };
	                var currentState = getState();
	                var sort = currentState.dataObject.sort;
	                var updatedColumns = _helper2.default.updateColumnsBasedOnSort(columns, sort);
	                dispatch(ACTIONCREATORS.updateColumns(label, sort));
	                dispatch(ACTIONCREATORS.saveUserPreferenceAsJSON(updatedColumns, currentState.dataObject.options, cb));
	            }, 0);
	        }.bind(this);
	    },

	    loadingTable: function loadingTable(bool) {
	        return {
	            type: 'LOADING_TABLE',
	            bool: bool
	        };
	    },

	    massEditRecords: function massEditRecords(label, value) {
	        return {
	            type: 'MASS_EDIT_RECORDS',
	            label: label,
	            value: value
	        };
	    },

	    overrideDataObjectProp: function overrideDataObjectProp(prop, val) {
	        return {
	            type: 'OVERRIDE_DATA_OBJECT_PROP',
	            prop: prop,
	            val: val
	        };
	    },

	    returnToPreviousState: function returnToPreviousState(history) {
	        return {
	            type: 'RETURN_TO_PREVIOUS_STATE',
	            history: history
	        };
	    },

	    saveState: function saveState(dataObject) {
	        return {
	            type: 'SAVE_STATE',
	            dataObject: dataObject
	        };
	    },

	    saving: function saving(status) {
	        return {
	            type: 'SAVING',
	            status: status
	        };
	    },

	    toggleCheckbox: function toggleCheckbox(id, shiftKey, visibleRecordIds) {
	        return {
	            type: 'TOGGLE_CHECKBOX',
	            id: id,
	            shiftKey: shiftKey,
	            visibleRecordIds: visibleRecordIds
	        };
	    },

	    toggleCheckboxIfUnchecked: function toggleCheckboxIfUnchecked(id) {
	        return {
	            type: 'TOGGLE_CHECKBOX_IF_UNCHECKED',
	            id: id
	        };
	    },

	    toggleColumn: function toggleColumn(label, columns) {
	        var activeColumnLabels = columns.map(function (column) {
	            return column.label;
	        });
	        var columnIsActive = function columnIsActive(label) {
	            return activeColumnLabels.indexOf(label) > -1 ? true : false;
	        };
	        var currentlyActive = columnIsActive(label);

	        return {
	            type: 'TOGGLE_COLUMN',
	            currentlyActive: currentlyActive,
	            label: label
	        };
	    },

	    toggleModal: function toggleModal(name) {
	        return {
	            type: 'TOGGLE_MODAL',
	            name: name
	        };
	    },

	    toggleSelectAll: function toggleSelectAll(selectedBoolean) {
	        return {
	            type: 'TOGGLE_SELECT_ALL',
	            selectedBoolean: selectedBoolean
	        };
	    },

	    toggleSidePanel: function toggleSidePanel(name) {
	        return {
	            type: 'TOGGLE_SIDE_PANEL',
	            name: name
	        };
	    },

	    toggleVisibleCheckboxes: function toggleVisibleCheckboxes(arrayOfIds) {
	        return {
	            type: 'TOGGLE_VISIBLE_CHECKBOXES',
	            arrayOfIds: arrayOfIds
	        };
	    },

	    updateAllColumns: function updateAllColumns(allColumns) {
	        return {
	            type: 'UPDATE_ALL_COLUMNS',
	            allColumns: allColumns
	        };
	    },

	    updateColumns: function updateColumns(label, sort) {
	        return {
	            type: 'UPDATE_COLUMNS',
	            label: label,
	            sort: sort
	        };
	    },

	    updateDataObjectProp: function updateDataObjectProp(prop, val) {
	        return {
	            type: 'UPDATE_DATA_OBJECT_PROP',
	            prop: prop,
	            val: val
	        };
	    },

	    updateErrorMessages: function updateErrorMessages(messages) {
	        return {
	            type: 'ERROR_MESSAGES',
	            messages: messages
	        };
	    },

	    updateFilters: function updateFilters(filterToAppend, teamId) {
	        return {
	            type: 'UPDATE_FILTERS',
	            filterString: filterToAppend,
	            teamId: teamId
	        };
	    },

	    updateFiltersAndSavePreferences: function updateFiltersAndSavePreferences(filterToAppend, clearFilters) {
	        var ACTIONCREATORS = this;
	        return function (dispatch, getState) {
	            var teamId = _selectors2.default.getTeamId(getState());

	            if (clearFilters) {
	                dispatch(ACTIONCREATORS.clearFilters(teamId));
	            } else {
	                dispatch(ACTIONCREATORS.updateFilters(filterToAppend, teamId));
	            }
	            // using setTimeout so that this fires on next event loop. This is an ugly alternative to using a promise for flow control.
	            setTimeout(function () {
	                var currentState = getState();
	                var cb = function cb(err, success) {
	                    if (err) {
	                        console.error(err);
	                    } else {
	                        console.log('User preferences saved! ');
	                    }
	                };
	                dispatch(ACTIONCREATORS.saveUserPreferenceAsJSON(currentState.dataObject.columns, currentState.dataObject.options, cb));
	            }, 0);
	        }.bind(this);
	    },

	    unselectHiddenRecords: function unselectHiddenRecords(selected) {
	        return {
	            type: 'UNSELECT_HIDDEN_RECORDS',
	            selected: selected
	        };
	    },

	    updateIsFullscreen: function updateIsFullscreen(bool) {
	        return {
	            type: 'IS_FULLSCREEN',
	            bool: bool
	        };
	    },

	    updateHeader: function updateHeader(title) {
	        return {
	            type: 'UPDATE_HEADER',
	            title: title
	        };
	    },

	    updateRanks: function updateRanks(targetRecord) {
	        return {
	            type: 'UPDATE_RANKS',
	            targetRecord: targetRecord
	        };
	    },

	    updateOption: function updateOption(prop, val) {
	        return {
	            type: 'UPDATE_OPTION',
	            prop: prop,
	            val: val
	        };
	    },

	    updateOptions: function updateOptions(options) {
	        return {
	            type: 'UPDATE_OPTIONS',
	            options: options
	        };
	    },

	    updateRecord: function updateRecord(id, prop, val) {
	        return {
	            type: 'UPDATE_RECORD',
	            id: id,
	            prop: prop,
	            val: val
	        };
	    },

	    updateScrollNeedsUpdate: function updateScrollNeedsUpdate(bool) {
	        return {
	            type: 'SCROLL_NEEDS_UPDATE',
	            bool: bool
	        };
	    },

	    updateSearchTerm: function updateSearchTerm(searchText) {
	        return {
	            type: 'UPDATE_SEARCH_TERM',
	            text: searchText
	        };
	    },

	    updateSort: function updateSort(label, columns) {
	        return {
	            type: 'UPDATE_SORT',
	            label: label,
	            columns: columns
	        };
	    },

	    updateScrollTop: function updateScrollTop(y) {
	        return {
	            type: 'UPDATE_SCROLLTOP',
	            y: y
	        };
	    },

	    updateGroup: function updateGroup(group, groupName, targetId) {
	        var that = this;

	        return function (dispatch, getState) {
	            if (!group || !groupName && groupName !== 0 || !targetId) {
	                return;
	            }
	            var dataObject = getState().dataObject;
	            var oldGroup = dataObject[group];
	            var newGroup = _extends({}, oldGroup);
	            var targetGroup = newGroup[groupName];
	            var targetIdx = targetGroup.indexOf(targetId);
	            var selected = dataObject.selected;
	            var sort = dataObject.sort;

	            Object.keys(oldGroup).forEach(function (thisGroupName) {
	                newGroup[thisGroupName] = oldGroup[thisGroupName].filter(function (recordId) {
	                    return selected.indexOf(recordId) === -1;
	                });
	            });

	            newGroup[groupName] = newGroup[groupName].slice(0, targetIdx).concat(selected).concat(newGroup[groupName].slice(targetIdx, newGroup[groupName].length));

	            dispatch(that.updateDataObjectProp(group, newGroup));

	            // update selected records;
	            var newRecordsObj = _extends({}, dataObject.recordsObj);
	            selected.forEach(function (selectedId) {
	                var currentRecord = dataObject.recordsObj[selectedId];
	                var valueProp = sort.column + '_value';
	                var idProp = sort.column + '_id';
	                var smallPhotoUrlProp = sort.column + '_smallPhotoUrl';
	                var linkProp = sort.column + '_link';
	                var targetRecord = dataObject.recordsObj[targetId].rowHeader ? dataObject.recordsObj[targetRecord.idOfFirstRecord] : dataObject.recordsObj[targetId];

	                newRecordsObj[selectedId] = _extends({}, currentRecord, _defineProperty({}, valueProp, targetRecord[valueProp]), _defineProperty({}, smallPhotoUrlProp, targetRecord[smallPhotoUrlProp]), _defineProperty({}, idProp, targetRecord[idProp]), _defineProperty({}, linkProp, targetRecord[linkProp]), { moved: true }, _defineProperty({}, sort.column + '_moved_dark', true));
	            });

	            dispatch(that.updateDataObjectProp('recordsObj', newRecordsObj));
	        };
	    },

	    updateUpdatedSprints: function updateUpdatedSprints(updatedRecordIds) {
	        var that = this;

	        return function (dispatch, getState) {
	            var currentState = getState();
	            var dataObject = currentState.dataObject;
	            var newUpdatedSprints = _helper2.default.getNewUpdatedSprints(updatedRecordIds, dataObject);

	            dispatch(that.updateDataObjectProp('updatedSprints', newUpdatedSprints));
	        };
	    },

	    updateView: function updateView(viewType, id) {
	        var newView = {
	            viewType: viewType,
	            sprintId: null,
	            paramId: null
	        };

	        if (viewType === 'sprint') {
	            newView.sprintId = id;
	        } else if (id != null) {
	            newView.paramId = id;
	        }

	        return {
	            type: 'UPDATE_VIEW',
	            viewType: newView.viewType,
	            paramId: newView.paramId,
	            sprintId: newView.sprintId
	        };
	    },

	    //============================================================== VISUALFORCE REMOTING ==============================================================//

	    getSprintChart: function getSprintChart(sprintId, cb) {
	        return function (dispatch) {
	            Visualforce.remoting.Manager.invokeAction(ADM_BACKLOG_PAGE_VARS.getSprintChart, sprintId, function (result, event) {
	                if (event.status) {
	                    var result = JSON.parse(result);
	                    cb(null, result);
	                } else {
	                    cb(event.message, null);
	                    console.error('there was an error in getSprintChart');
	                }
	            }, { escape: false });
	        };
	    },

	    getThroughputChart: function getThroughputChart(numWeeks, teamId, cb) {
	        return function (dispatch) {
	            Visualforce.remoting.Manager.invokeAction(ADM_BACKLOG_PAGE_VARS.getThroughputChart, numWeeks, teamId, function (result, event) {
	                if (event.status) {
	                    var result = JSON.parse(result);
	                    cb(null, result);
	                } else {
	                    cb(event.message, null);
	                    console.error('there was an error in getThroughputChart');
	                }
	            }, { escape: false });
	        };
	    },

	    getPanelWorkItemsAsJSON: function getPanelWorkItemsAsJSON(viewChangeRequested, paramId, type, selectedText, dataObject) {
	        var that = this;
	        return function (dispatch, getState) {
	            dispatch(that.loadingTable(true));
	            if (!paramId) paramId = $('#buttonTitle h1').attr('data-id');
	            if (!selectedText) selectedText = $('#buttonTitle h1').attr('data-text');
	            if (!type) type = 'backlog';
	            var sprintId = type === 'sprint' ? paramId : ADM_BACKLOG_PAGE_VARS.sprintId;
	            var teamId;
	            if (type === 'backlog') {
	                teamId = paramId || _selectors2.default.getTeamId(getState());
	            } else {
	                teamId = _selectors2.default.getTeamId(getState());
	            }

	            var paramObject = {
	                teamId: teamId,
	                sprintId: sprintId,
	                paramId: paramId
	            };

	            console.log(paramObject);
	            console.log(type);

	            var isReactCall = true;

	            Visualforce.remoting.Manager.invokeAction(ADM_BACKLOG_PAGE_VARS.getPanelWorkItemsAsJSON, paramObject, type, isReactCall, '1000', '0', function (result, event) {
	                dispatch(that.loadingTable(false));
	                if (event.status) {
	                    var result = JSON.parse(result);
	                    console.log(result);
	                    var defaultView = result.defaultView; //This variable is set to true if we have to fall back to show Backlog view; eg: querying for an invalid sprint id and it never returns any work items for it.
	                    if (defaultView) {
	                        paramObject.paramId = result.team.Id;
	                    }
	                    dispatch(that.getPanelWorkItemsAsJSONSuccess(result, selectedText, defaultView, paramObject.paramId));
	                } else {
	                    console.error('there was an error in getPanelWorkItemsAsJSON');
	                }
	            }, { escape: false });
	        };
	    },

	    getPanelWorkItemsAsJSONSuccess: function getPanelWorkItemsAsJSONSuccess(result, headerTitle, defaultView, paramId) {
	        if (defaultView) {
	            headerTitle = result.team.Name;
	            console.info('No records found for this data selection. Showing all records.');
	        }

	        return {
	            type: 'GET_PANEL_WORK_ITEMS_AS_JSON_SUCCESS',
	            result: result,
	            headerTitle: headerTitle,
	            headerId: paramId,
	            defaultView: defaultView
	        };
	    },

	    getUserPreferencesAsJSON: function getUserPreferencesAsJSON(initialLoad, cb) {
	        var that = this;
	        return function (dispatch, getState) {
	            dispatch(that.loadingTable(true));
	            Visualforce.remoting.Manager.invokeAction(ADM_BACKLOG_PAGE_VARS.getUserPreferencesAsJSON, function (result, event) {
	                if (event.status) {
	                    var result = JSON.parse(result);
	                    dispatch(that.loadingTable(false));
	                    dispatch(that.getUserPreferencesAsJSONSuccess(result, initialLoad));
	                    if (!initialLoad) {
	                        dispatch(that.updateScrollNeedsUpdate(true));
	                    }
	                    if (typeof cb === 'function') cb();
	                } else {
	                    console.error('there was an error in getUserPreferencesAsJSON');
	                    dispatch(that.loadingTable(false));
	                    if (typeof cb === 'function') cb();
	                }
	            }, { escape: false });
	        };
	    },

	    getUserPreferencesAsJSONSuccess: function getUserPreferencesAsJSONSuccess(result, initialLoad) {
	        return {
	            type: 'GET_USER_PREFERENCES_AS_JSON_SUCCESS',
	            result: result,
	            initialLoad: initialLoad
	        };
	    },

	    refreshData: function refreshData(dataObject, overrideHistoryCheck, initialLoad, viewChangeRequested, paramId, selectedText) {
	        var that = this;
	        var successCB = function successCB(dispatch, viewType) {
	            dispatch(that.getUserPreferencesAsJSON(initialLoad, dispatch(that.getPanelWorkItemsAsJSON(viewChangeRequested, paramId, viewType, selectedText, dataObject))));
	            dispatch(that.clearHistory());
	        };

	        return function (dispatch, getState) {
	            var currentState = getState();
	            var history = currentState.history;
	            if (!overrideHistoryCheck && history && history.past && history.past.length > 0) {
	                var confirmation = confirm('You have unsaved changes! Are you sure you want to refresh before saving?');
	                if (confirmation) {
	                    successCB(dispatch, currentState.view.viewType);
	                }
	            } else {
	                successCB(dispatch, currentState.view.viewType);
	            }
	        };
	    },

	    saveUserPreferenceAsJSON: function saveUserPreferenceAsJSON(columns, options, cb) {
	        return function (dispatch) {
	            var userPreference = JSON.stringify({ columns: columns, options: options });
	            console.log(userPreference);

	            Visualforce.remoting.Manager.invokeAction(ADM_BACKLOG_PAGE_VARS.saveUserPreferenceAsJSON, userPreference, function (result, event) {
	                if (event.status) {
	                    if (typeof cb === 'function') cb(null, result);
	                } else {
	                    if (typeof cb === 'function') cb(event.message, null);
	                }
	            }, { escape: false });
	        };
	    },

	    saveWorks: function saveWorks(dataObject, paramId, selectedText, refreshPage) {
	        var ACTIONCREATORS = this;

	        return function (dispatch) {
	            dispatch(ACTIONCREATORS.saving('started'));
	            var movedWork = dataObject.recordIds.reduce(function (result, id) {
	                var record = dataObject.recordsObj[id];
	                var recordKeys = Object.keys(record);
	                var updatedColumnLabels = [];
	                recordKeys.forEach(function (recordKey) {
	                    if (recordKey.indexOf('_moved_dark') !== -1 && record[recordKey] === true) {
	                        updatedColumnLabels.push(recordKey.replace('_moved_dark', ''));
	                    }
	                });
	                if (updatedColumnLabels.length > 0) {
	                    var resultObj = {
	                        Id: id
	                    };
	                    updatedColumnLabels.forEach(function (updatedColumnLabel) {
	                        dataObject.allColumns.forEach(function (column) {
	                            if (column.label === updatedColumnLabel) {
	                                if (column.id) {
	                                    var idProp = column.id.replace('work.', '');
	                                    resultObj[idProp] = record[column.label + '_id'];

	                                    // this handles things that were dragged into "NO SPRINTS", for example - since server expects
	                                    // null to blank out values
	                                    if (typeof resultObj[idProp] === 'undefined') {
	                                        resultObj[idProp] = null;
	                                    }
	                                } else if (column.value) {
	                                    var valueProp = column.value.replace('work.', '');
	                                    resultObj[valueProp] = record[column.label + '_value'];
	                                }
	                            }
	                        });
	                    });
	                    result.push(resultObj);
	                }
	                return result;
	            }, []);

	            if (!_.isEmpty(movedWork) && !dataObject.stressTest) {
	                console.log(movedWork);
	                Visualforce.remoting.Manager.invokeAction(ADM_BACKLOG_PAGE_VARS.saveWorks, movedWork, false, function (result, event) {
	                    var errorMessages = [];
	                    var resultLen = result ? result.length : 0;

	                    for (var i = 0; i < resultLen; i++) {
	                        errorMessages.push(result[i]['work'].Name + ': ' + result[i].errorMessages);
	                    }

	                    dispatch(ACTIONCREATORS.updateSprintOrders());

	                    if (event.status && refreshPage) {
	                        dispatch(ACTIONCREATORS.saving('finished'));
	                        dispatch(ACTIONCREATORS.refreshData(dataObject, true, null, paramId, selectedText));
	                    } else if (event.status && errorMessages.length == 0) {
	                        dispatch(ACTIONCREATORS.saving('finished'));
	                    } else {
	                        dispatch(ACTIONCREATORS.saving('finished'));
	                        dispatch(ACTIONCREATORS.updateErrorMessages(errorMessages));
	                    }
	                }, { escape: false });
	            } else {
	                var reason = dataObject.stressTest ? ' we are in a stresstest' : ' nothing was moved.';
	                console.info('saveWorks was called but nothing was saved because ' + reason);
	                console.info('movedWork: ', movedWork);
	                dispatch(ACTIONCREATORS.saving('finished'));
	            }
	        };
	    },

	    updateSprintOrders: function updateSprintOrders() {
	        var ACTIONCREATORS = this;

	        return function (dispatch, getState) {
	            var currentState = getState();
	            var dataObject = currentState.dataObject;

	            dataObject.updatedSprints.forEach(function (sprintId) {
	                if (sprintId === 'NO SPRINT') {
	                    console.log('NO SPRINT updated, records are: ', dataObject.sprints['NO SPRINT']);
	                } else {
	                    var allSprints = dataObject.allSprints.concat(dataObject.oldSprints);
	                    allSprints.forEach(function (sprintObj) {
	                        if (sprintObj.Id === sprintId) {
	                            var sprintName = sprintObj.Name;
	                            var requestObj = {
	                                sprintId: sprintId,
	                                workIds: dataObject.sprints[sprintName]
	                            };
	                            Visualforce.remoting.Manager.invokeAction(ADM_BACKLOG_PAGE_VARS.updateSprintOrder, requestObj, function (result, event) {
	                                console.log(result);
	                            }, { escape: false });
	                        }
	                    });
	                }
	            });
	            dispatch(ACTIONCREATORS.updateDataObjectProp('updatedSprints', []));
	        };
	    }
	};

	exports.default = ACTIONCREATORS;

/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _reselect = __webpack_require__(4);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	// these are non-memoized since they don't transform data
	var getSort = function getSort(state) {
	    return state.dataObject.sort;
	},
	    getLoadingTable = function getLoadingTable(state) {
	    return state.loadingTable;
	},
	    getDataObject = function getDataObject(state) {
	    return state.dataObject;
	},
	    getNameSpace = function getNameSpace(state) {
	    return state.dataObject.nameSpace;
	},
	    getTeamId = function getTeamId(state) {
	    return state.dataObject.team && state.dataObject.team.Id ? state.dataObject.team.Id : ADM_BACKLOG_PAGE_VARS.teamId;
	},
	    getFilters = function getFilters(state) {
	    return state.dataObject.options.filters;
	},
	    // use getTeamFilters instead if need that
	getTeamFilters = function getTeamFilters(state) {
	    return state.dataObject.options.filters[getTeamId(state)] || '';
	},
	    getSearchTerm = function getSearchTerm(state) {
	    return state.searchTerm;
	},
	    getAllColumns = function getAllColumns(state) {
	    return state.dataObject.allColumns;
	},
	    getColumns = function getColumns(state) {
	    return state.dataObject.columns;
	},
	    getSelected = function getSelected(state) {
	    return state.dataObject.selected;
	},
	    getSortColumn = function getSortColumn(state) {
	    return state.dataObject.sort.column;
	},
	    getSortDirection = function getSortDirection(state) {
	    return state.dataObject.sort.direction;
	},
	    getHistory = function getHistory(state) {
	    return state.history;
	},
	    getSidePanel = function getSidePanel(state) {
	    return state.sidePanel;
	},
	    getPendingSaves = function getPendingSaves(state) {
	    return state.saving;
	},
	    getScrollNeedsUpdate = function getScrollNeedsUpdate(state) {
	    return state.scrollNeedsUpdate;
	},
	    getScrollTop = function getScrollTop(state) {
	    return state.scrollTop;
	},
	    getIsFullscreen = function getIsFullscreen(state) {
	    return state.isFullscreen;
	},
	    getSprints = function getSprints(state) {
	    return state.dataObject.sprints;
	},
	    getView = function getView(state) {
	    return state.view;
	};

	var getRecordsFromDataObject = (0, _reselect.createSelector)([getDataObject], function (dataObject) {
	    return _helper2.default.getRecordsFromDataObject(dataObject);
	});

	var getRecordsToDisplay = (0, _reselect.createSelector)([getDataObject, getSearchTerm, getColumns, getTeamFilters, getSelected, getSortColumn, getSortDirection, getTeamId], function (dataObject, searchTerm, columns, filters, selected, sortColumn, sortDirection, teamId) {
	    if (!columns) {
	        return [];
	    }
	    var recordsToDisplay = [];
	    var currentColumn = dataObject.allColumns.filter(function (column) {
	        return column.label === sortColumn;
	    })[0];
	    var groupable = currentColumn.groupable;
	    // sort and give row headers if needed
	    if (groupable) {
	        var groupings = dataObject[sortColumn.toLowerCase() + 's'];
	        recordsToDisplay = _helper2.default.makeRecordsAndHeadersFromGroupings(groupings, dataObject, sortColumn, sortDirection);
	    } else {
	        var records = dataObject.recordIds.map(function (id) {
	            return dataObject.recordsObj[id];
	        });
	        recordsToDisplay = _helper2.default.sortNonGroupableRecords(records, sortColumn, sortDirection);
	        if (sortColumn === 'Rank') {
	            recordsToDisplay = _helper2.default.giveRecordsVelocityLine(sortColumn, recordsToDisplay, dataObject.options, searchTerm, teamId);
	        }
	    }

	    // display filtered, moved records
	    recordsToDisplay = _helper2.default.setDisplayForFilteredAndMovedRecords(filters, recordsToDisplay, selected);
	    // perform search
	    recordsToDisplay = _helper2.default.setDisplayBasedOnSearch(searchTerm, recordsToDisplay, selected, columns);
	    // hide records with display = false
	    recordsToDisplay = recordsToDisplay.filter(function (record) {
	        return !!record.display;
	    });

	    return recordsToDisplay;
	});

	var getVisibleRecordIdsWithoutHeaders = (0, _reselect.createSelector)([getRecordsToDisplay], function (recordsToDisplay) {
	    return recordsToDisplay.filter(function (record) {
	        return !record.rowHeader;
	    }).map(function (record) {
	        return record.Id;
	    });
	});

	var getNumVisibleRecordsWithoutHeaders = (0, _reselect.createSelector)([getVisibleRecordIdsWithoutHeaders], function (visibleRecordIdsWithoutHeaders) {
	    return visibleRecordIdsWithoutHeaders.length;
	});

	var getCurrentColumn = (0, _reselect.createSelector)([getAllColumns, getSortColumn], function (allColumns, sortColumn) {
	    if (allColumns) {
	        return allColumns.filter(function (column) {
	            return column.label === sortColumn;
	        })[0];
	    } else {
	        return null;
	    }
	});

	var getFilterDisplayString = (0, _reselect.createSelector)([getTeamFilters], function (filters) {
	    return _helper2.default.makeFilterDisplayString(filters);
	});

	var getAllPoints = (0, _reselect.createSelector)([getRecordsFromDataObject], function (records) {
	    var result = _.uniq(_.pluck(records, 'Points_value')).filter(function (val) {
	        return val !== null;
	    }).sort(function (a, b) {
	        return a - b;
	    }).map(function (point) {
	        return { Name: point };
	    }).concat([{ Name: null }]);

	    return result;
	});

	// unfortunately, have to do this b/c of scoping 'this' issues - Input selectors
	// dont have access to 'this' to call each other if directly in object.

	// we can share these across components because no distinct props are being passed in.
	// https://github.com/reactjs/reselect/blob/master/README.md#q-can-i-share-a-selector-across-multiple-components
	var SELECTORS = {
	    getSort: getSort,
	    getLoadingTable: getLoadingTable,
	    getDataObject: getDataObject,
	    getNameSpace: getNameSpace,
	    getFilters: getFilters,
	    getTeamFilters: getTeamFilters,
	    getSearchTerm: getSearchTerm,
	    getAllColumns: getAllColumns,
	    getColumns: getColumns,
	    getSelected: getSelected,
	    getSortColumn: getSortColumn,
	    getSortDirection: getSortDirection,
	    getTeamId: getTeamId,
	    getHistory: getHistory,
	    getSidePanel: getSidePanel,
	    getPendingSaves: getPendingSaves,
	    getAllPoints: getAllPoints,
	    getScrollNeedsUpdate: getScrollNeedsUpdate,
	    getScrollTop: getScrollTop,
	    getIsFullscreen: getIsFullscreen,
	    getView: getView,

	    getRecordsFromDataObject: getRecordsFromDataObject,
	    getRecordsToDisplay: getRecordsToDisplay,
	    getVisibleRecordIdsWithoutHeaders: getVisibleRecordIdsWithoutHeaders,
	    getNumVisibleRecordsWithoutHeaders: getNumVisibleRecordsWithoutHeaders,
	    getCurrentColumn: getCurrentColumn,
	    getFilterDisplayString: getFilterDisplayString
	};

	exports.default = SELECTORS;

/***/ },
/* 4 */
/***/ function(module, exports) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});

	var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

	exports.defaultMemoize = defaultMemoize;
	exports.createSelectorCreator = createSelectorCreator;
	exports.createSelector = createSelector;
	exports.createStructuredSelector = createStructuredSelector;

	function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

	// START RESELECT CODE //
	function defaultEqualityCheck(a, b) {
	  return a === b;
	}

	function defaultMemoize(func) {
	  var equalityCheck = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : defaultEqualityCheck;

	  var lastArgs = null;
	  var lastResult = null;
	  return function () {
	    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
	      args[_key] = arguments[_key];
	    }

	    if (lastArgs !== null && lastArgs.length === args.length && args.every(function (value, index) {
	      return equalityCheck(value, lastArgs[index]);
	    })) {
	      return lastResult;
	    }
	    lastArgs = args;
	    lastResult = func.apply(undefined, args);
	    return lastResult;
	  };
	}

	function getDependencies(funcs) {
	  var dependencies = Array.isArray(funcs[0]) ? funcs[0] : funcs;

	  if (!dependencies.every(function (dep) {
	    return typeof dep === 'function';
	  })) {
	    var dependencyTypes = dependencies.map(function (dep) {
	      return typeof dep === 'undefined' ? 'undefined' : _typeof(dep);
	    }).join(', ');
	    throw new Error('Selector creators expect all input-selectors to be functions, ' + ('instead received the following types: [' + dependencyTypes + ']'));
	  }

	  return dependencies;
	}

	function createSelectorCreator(memoize) {
	  for (var _len2 = arguments.length, memoizeOptions = Array(_len2 > 1 ? _len2 - 1 : 0), _key2 = 1; _key2 < _len2; _key2++) {
	    memoizeOptions[_key2 - 1] = arguments[_key2];
	  }

	  return function () {
	    for (var _len3 = arguments.length, funcs = Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
	      funcs[_key3] = arguments[_key3];
	    }

	    var recomputations = 0;
	    var resultFunc = funcs.pop();
	    var dependencies = getDependencies(funcs);

	    var memoizedResultFunc = memoize.apply(undefined, [function () {
	      recomputations++;
	      return resultFunc.apply(undefined, arguments);
	    }].concat(memoizeOptions));

	    var selector = function selector(state, props) {
	      for (var _len4 = arguments.length, args = Array(_len4 > 2 ? _len4 - 2 : 0), _key4 = 2; _key4 < _len4; _key4++) {
	        args[_key4 - 2] = arguments[_key4];
	      }

	      var params = dependencies.map(function (dependency) {
	        return dependency.apply(undefined, [state, props].concat(args));
	      });
	      return memoizedResultFunc.apply(undefined, _toConsumableArray(params));
	    };

	    selector.resultFunc = resultFunc;
	    selector.recomputations = function () {
	      return recomputations;
	    };
	    selector.resetRecomputations = function () {
	      return recomputations = 0;
	    };
	    return selector;
	  };
	}

	function createSelector() {
	  return createSelectorCreator(defaultMemoize).apply(undefined, arguments);
	}

	function createStructuredSelector(selectors) {
	  var selectorCreator = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : createSelector;

	  if ((typeof selectors === 'undefined' ? 'undefined' : _typeof(selectors)) !== 'object') {
	    throw new Error('createStructuredSelector expects first argument to be an object ' + ('where each property is a selector, instead received a ' + (typeof selectors === 'undefined' ? 'undefined' : _typeof(selectors))));
	  }
	  var objectKeys = Object.keys(selectors);
	  return selectorCreator(objectKeys.map(function (key) {
	    return selectors[key];
	  }), function () {
	    for (var _len5 = arguments.length, values = Array(_len5), _key5 = 0; _key5 < _len5; _key5++) {
	      values[_key5] = arguments[_key5];
	    }

	    return values.reduce(function (composition, value, index) {
	      composition[objectKeys[index]] = value;
	      return composition;
	    }, {});
	  });
	}

/***/ },
/* 5 */
/***/ function(module, exports) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	var MIDDLEWARE = {
	    logger: function logger(store) {
	        return function (next) {
	            return function (action) {
	                console.log('dispatching', action);
	                var result = next(action);
	                console.log('next state', store.getState());
	                return result;
	            };
	        };
	    }
	};

	exports.default = MIDDLEWARE;

/***/ },
/* 6 */
/***/ function(module, exports) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	var REDUCERENHANCERS = {

	  undoable: function undoable(reducer, actionTypeWhitelistArr, undoActionType, redoActionType) {
	    // Call the reducer with empty action to populate the initial state
	    var initialState = {
	      past: [],
	      present: reducer(undefined, {}),
	      future: []
	    };
	    var actionTypeWhitelistArr = actionTypeWhitelistArr || [];

	    [undoActionType, redoActionType].forEach(function (actionType) {
	      if (actionType) actionTypeWhitelistArr.push(actionType);
	    });

	    // Return a reducer that handles undo and redo
	    return function (state, action) {
	      if (!state) return initialdataObjectReducerState;

	      var past = state.past,
	          present = state.present,
	          future = state.future;

	      if (actionTypeWhitelistArr && actionTypeWhitelistArr.indexOf(action.type) === -1) {
	        var newPresent = reducer(present, action);
	        if (present === newPresent) {
	          return state;
	        }
	        return {
	          past: past,
	          present: newPresent,
	          future: future
	        };
	      }

	      switch (action.type) {
	        case undoActionType || 'UNDO':
	          var previous = past[past.length - 1];
	          var newPast = past.slice(0, past.length - 1);
	          return {
	            past: newPast,
	            present: previous,
	            future: [present].concat(future)
	          };
	        case redoActionType || 'REDO':
	          var next = future[0];
	          var newFuture = future.slice(1);
	          return {
	            past: [].concat(past).concat(present),
	            present: next,
	            future: newFuture
	          };
	        default:
	          // Delegate handling the action to the passed reducer
	          var newPresent = reducer(present, action);
	          if (present === newPresent) {
	            return state;
	          }
	          return {
	            past: [].concat(past).concat(present),
	            present: newPresent,
	            future: []
	          };
	      }
	    };
	  }

	};

	exports.default = REDUCERENHANCERS;

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.WMREDUCERS = undefined;

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; } /* IMPORTANT - UNCOMMENT LINES 5-7 WHEN RUNNING TESTS */

	// import * as redux from 'redux';
	// import * as React from 'react/addons';
	// var Redux = redux;

	var combineReducers = Redux.combineReducers;
	// import tempDataObject from './temp/dataObject';

	var WMREDUCERS = {
	    dataObject: function dataObject(state, action) {
	        var initialState = {
	            recordIds: [], // the order of recordIds also determines a display order for the records (before they are grouped)
	            recordsObj: {},
	            options: {
	                filters: {}
	            },
	            selected: [],
	            selectAll: false,
	            sort: {
	                column: 'Rank',
	                direction: 'ascending'
	            },
	            sprints: {},
	            updatedSprints: [],
	            nameSpace: ''
	        };

	        if (!state) state = initialState;

	        switch (action.type) {
	            case 'CLEAR_SELECTED':
	                return React.addons.update(state, { selected: { $set: [] } });
	            case 'CLEAR_FILTERS':
	                if (!action.teamId) {
	                    return state;
	                }
	                return React.addons.update(state, { options: { filters: _defineProperty({}, action.teamId, { $set: '' }) } });
	            case 'CLEAR_HISTORY':
	                var newRecordsObj = state.recordIds.reduce(function (newObj, id) {
	                    var recordClone = _extends({}, state.recordsObj[id]);
	                    recordClone.moved = false;
	                    var recordCloneKeys = Object.keys(recordClone);
	                    recordCloneKeys.forEach(function (key) {
	                        if (key.indexOf('moved_dark') > -1) {
	                            recordClone[key] = false;
	                        } else if (key.indexOf('moved_light') > 1) {
	                            recordClone[key] = false;
	                        }
	                    });
	                    newObj[id] = recordClone;
	                    return newObj;
	                }, {});
	                return React.addons.update(state, { recordsObj: { $set: newRecordsObj } });
	            case 'GET_PANEL_WORK_ITEMS_AS_JSON_SUCCESS':
	                console.log(action.result);
	                var records = action.result.records || [];
	                var stressTest = false;
	                var stressNumber = 1000;
	                var recordsObj = {};
	                var recordIds = [];
	                // for anything starting with 'all', handle nulls by making them empty arrays.
	                Object.keys(action.result).forEach(function (key) {
	                    if (key.indexOf('all') === 0) {
	                        action.result[key] = action.result[key] ? action.result[key] : [];
	                    }
	                });
	                var teamName = action.result.team && action.result.team.Name ? action.result.team.Name : undefined;
	                var headerTitle = action.headerTitle ? action.headerTitle : teamName;
	                var headerId = action.headerId ? action.headerId : '';
	                var allBuilds = action.result.allBuilds.reverse();
	                var allSprints = action.result.allSprints;
	                var oldSprints = action.result.oldSprints;
	                var allPoints = [];
	                var allPointsNames = [];
	                var nameSpace = action.result.nameSpace || '';

	                if (stressTest) {
	                    var testRecords = _helper2.default.createTestRecords(stressNumber);
	                    records = records.concat(testRecords);
	                    action.result['stressTest'] = true;
	                }

	                // create allPoints
	                if (action.result && action.result.team && action.result.team.Story_Point_Scale__c) {
	                    allPoints = action.result.team.Story_Point_Scale__c.split(',').reduce(function (arr, point) {
	                        var pointInt = parseInt(point, 10);
	                        arr.push({ 'Name': pointInt });
	                        allPointsNames.push(pointInt);
	                        return arr;
	                    }, []);
	                } else {
	                    allPoints = [];
	                }

	                records.forEach(function (record, idx) {
	                    recordIds.push(record.Id);
	                    // var flattenedRecord = helper.flatten(record, {});
	                    // recordsObj[record.Id] = flattenedRecord;
	                    recordsObj[record.Id] = {};
	                    var subjectField = nameSpace ? nameSpace + 'Subject__c' : 'Subject__c';
	                    recordsObj[record.Id].longSubject = record[subjectField].length > 106 ? true : false;
	                    if (record.Story_Points__c && allPointsNames.indexOf(record.Story_Points__c) === -1) {
	                        allPoints.push({ 'Name': record.Story_Points__c });
	                        allPointsNames.push(record.Story_Points__c);
	                    }

	                    action.result.allColumns.forEach(function (column) {
	                        // NEED TO HARDCODE THIS FROM SERVER
	                        if (column.label === 'Sprint') {
	                            column.rankable = true;
	                            column.rankField = 'Sprint_Rank__c';
	                        }
	                        // END NEED TO HARDCODE
	                        var columnLabel = column.label ? column.label : null;
	                        recordsObj[record.Id][columnLabel + '_id'] = column.id ? _helper2.default.makeRecordValFromColumnVal(record, column.id.replace('work.', ''), nameSpace) : null;
	                        recordsObj[record.Id][columnLabel + '_value'] = column.value ? _helper2.default.makeRecordValFromColumnVal(record, column.value.replace('work.', ''), nameSpace) : null;
	                        recordsObj[record.Id][columnLabel + '_link'] = column.link ? _helper2.default.makeRecordValFromColumnVal(record, column.link.replace('work.', ''), nameSpace) : null;
	                        recordsObj[record.Id][columnLabel + '_smallPhotoUrl'] = column.smallPhotoUrl ? _helper2.default.makeRecordValFromColumnVal(record, column.smallPhotoUrl.replace('work.', ''), nameSpace) : null;
	                        recordsObj[record.Id]['Id'] = record.Id;
	                        if (column.rankable === true) {
	                            recordsObj[record.Id][columnLabel + '_rank'] = record[column.rankField];
	                        }
	                    });
	                });

	                allPoints = allPoints.sort(function (a, b) {
	                    return a.Name - b.Name;
	                });

	                // only show WorkStatuses that have recordTypes on the board.
	                var allWorkStatuses = action.result.allWorkStatuses.reduce(function (arr, workStatus) {
	                    var recordTypeFound = false;
	                    var typeField = nameSpace ? nameSpace + 'Type__c' : 'Type__c';
	                    var workStatusType = workStatus[typeField];

	                    action.result.allRecordTypes.forEach(function (type, recordTypeIdx) {
	                        if (workStatusType.indexOf(type.Name) > 1) {
	                            recordTypeFound = true;
	                        }
	                    });
	                    if (recordTypeFound) {
	                        arr.push(workStatus);
	                    }
	                    return arr;
	                }, []);

	                // already made the recordIds array & the recordsObj so don't need this anymore. Delete it to save memory.
	                // if (action.result.records) action.result.records = undefined;
	                var options = action.defaultView ? _extends({}, state.options, { lastView: 'backlog' }) : _extends({}, state.options);
	                if (!options.filters) {
	                    options.filters = {};
	                }
	                var newState = _extends({}, initialState, action.result, { recordIds: recordIds || [] }, { recordsObj: recordsObj || [] }, { allBuilds: allBuilds || [] }, { allSprints: allSprints || [] }, { oldSprints: oldSprints || [] }, { allWorkStatuses: allWorkStatuses || [] }, { allPoints: allPoints || [] }, { headerTitle: headerTitle || '' }, { headerId: headerId }, { options: options || {} }, { nameSpace: nameSpace || '' });

	                action.result.allColumns // TODO - Update this so not doing this loop again!
	                .forEach(function (column) {
	                    if (column.groupable) {
	                        var groupName = column.label.toLowerCase() + 's'; // i.e. "sprints"
	                        var recordRankField = groupName === 'sprints' ? 'Sprint_rank' : 'Rank_value';
	                        var groupObj = {};
	                        records.forEach(function (record, idx) {
	                            var groupName = _helper2.default.makeRecordValFromColumnVal(record, column.value.replace('work.', ''), nameSpace);
	                            if (column.label.slice(-4).toLowerCase() === 'date') {
	                                groupName = _helper2.default.formatDate(groupName);
	                            }
	                            if (!groupName && groupName !== 0) {
	                                groupName = 'NO ' + column.label.toUpperCase();
	                            }
	                            groupObj[groupName] ? groupObj[groupName].push(record.Id) : groupObj[groupName] = [record.Id];
	                        });
	                        Object.keys(groupObj).forEach(function (group) {
	                            groupObj[group] = groupObj[group].sort(function (id1, id2) {
	                                return _helper2.default.makeSortNumsFunc()(recordsObj[id1][recordRankField], recordsObj[id2][recordRankField]);
	                            });
	                        });
	                        newState[groupName] = groupObj;
	                    }
	                });

	                return newState;
	            case 'GET_USER_PREFERENCES_AS_JSON_SUCCESS':
	                console.log('gupajs: ', action.result);
	                if (!action.result || !action.result.options || !action.result.columns) {
	                    console.error('either no options, or columns passed into GET_USER_PREFERENCES_AS_JSON_SUCCESS. Action was: ', action);
	                    return state;
	                }
	                var columns = action.result.columns;
	                var options = action.result.options;

	                var sort = {
	                    column: 'Rank',
	                    direction: 'ascending'
	                };
	                columns.forEach(function (column) {
	                    if (column.direction) {
	                        sort.direction = column.direction;
	                        sort.column = column.label;
	                    }
	                });

	                if (state.defaultView || action.initialLoad) {
	                    options.lastView = 'backlog';
	                }
	                if (!options.filters || typeof options.filters === 'string') {
	                    options.filters = {};
	                }

	                if (state.defaultView) {
	                    var renderUserAlert = function renderUserAlert() {
	                        $('#nofityUserDialog .slds-text-heading--medium').text('Showing All Work');
	                        // var msg = 'No work items found for ' + type.charAt(0).toUpperCase() + type.slice(1) + ' <a href="/'+selectedId+'">' + selectedText + '</a>, showing Backlog Work items';
	                        var msg = 'No work items found for this selection. Showing all work items';
	                        $('#nofityUserDialog .slds-modal__content > div').html(msg);
	                        $('#nofityUserDialog').addClass('slds-fade-in-open');
	                        $('.slds-modal-backdrop').addClass('slds-modal-backdrop--open');
	                    };
	                    renderUserAlert();
	                }
	                var returnVal = _extends({}, state, { options: options }, { columns: columns }, { sort: sort });
	                console.log('gupajsr: ', returnVal);
	                return returnVal;
	            case 'MASS_EDIT_RECORDS':
	                var recordIdsToUpdate = state.selected.slice();
	                var sortColumn = state.sort.column;
	                var label = action.label;
	                var value = action.value;
	                var orderKey = label.toLowerCase() + 's';
	                var updatedOrderObj = _extends({}, state[orderKey]);
	                var newUpdatedSprints = state.updatedSprints.slice();
	                var id;
	                var smallPhotoUrl;
	                // var link;

	                if (value === '') return state;
	                if (label === 'Points' && value !== '(None)') {
	                    value = parseInt(value, 10);
	                }
	                var dataObjectProp = _helper2.default.labelToDataObjectProp(label);
	                var valueToUpdateTo = state[dataObjectProp].filter(function (prop) {
	                    if (prop && prop.Name && prop.Name === value) {
	                        return true;
	                    } else if (prop && prop === value) {
	                        return true;
	                    } else {
	                        return false;
	                    }
	                });

	                if (valueToUpdateTo && valueToUpdateTo.length !== 0) {
	                    valueToUpdateTo = valueToUpdateTo[0];
	                    id = valueToUpdateTo.Id;
	                    smallPhotoUrl = valueToUpdateTo.SmallPhotoUrl;
	                    // link = '/' + valueToUpdateTo.Id
	                } else if (value !== '(None)') {
	                    $('#modalMetadataProblem').addClass('slds-fade-in-open');
	                    $('.slds-modal-backdrop').addClass('slds-modal-backdrop--open');
	                }

	                if (valueToUpdateTo.length === 0 && value === '(None)') {
	                    name = null;
	                    id = null;
	                    value = null;
	                }

	                var updatedRecordsObj = state.recordIds.reduce(function (obj, recordId) {
	                    if (recordIdsToUpdate.indexOf(recordId) > -1) {
	                        var updatedRecord = _extends({}, state.recordsObj[recordId], _defineProperty({}, label + '_id', id), _defineProperty({}, label + '_value', value), _defineProperty({}, label + '_smallPhotoUrl', smallPhotoUrl), _defineProperty({}, label + '_link', null), _defineProperty({}, label + '_moved_dark', true), { moved: true });
	                        console.log('updatedRecord is: ', updatedRecord);
	                        obj[recordId] = updatedRecord;
	                        return obj;
	                    } else {
	                        obj[recordId] = state.recordsObj[recordId];
	                        return obj;
	                    }
	                }, {});

	                var previousValueObjs = recordIdsToUpdate.map(function (id) {
	                    return {
	                        id: id,
	                        prevLabelValue: state.recordsObj[id][label + '_value'] || state.recordsObj[id][label + '_value'] === 0 ? state.recordsObj[id][label + '_value'] : 'NO ' + label.toUpperCase(),
	                        prevLabelId: state.recordsObj[id][label + '_id']
	                    };
	                });
	                // remove selected ids from old ordering objects
	                previousValueObjs.forEach(function (valueObj) {
	                    updatedOrderObj[valueObj.prevLabelValue] = updatedOrderObj[valueObj.prevLabelValue].filter(function (id) {
	                        return id !== valueObj.id;
	                    });
	                });

	                if (!value && value !== 0) {
	                    value = 'NO ' + label.toUpperCase();
	                }
	                // add selected ids into new ordering objects
	                var newOrderArray = updatedOrderObj[value] || updatedOrderObj[value] === 0 ? recordIdsToUpdate.concat(updatedOrderObj[value]) : recordIdsToUpdate;

	                // for sprints, update updatedSprints on the dataObject
	                if (label === 'Sprint' && recordIdsToUpdate.length > 0) {
	                    var previousSprintIds = previousValueObjs.map(function (obj) {
	                        return obj.prevLabelId;
	                    });
	                    var newSprintId = updatedRecordsObj[recordIdsToUpdate[0]].Sprint_id;
	                    var sprintIdsToAdd = previousSprintIds.concat(newSprintId).map(function (id) {
	                        return !id ? 'NO SPRINT' : id;
	                    });

	                    sprintIdsToAdd.forEach(function (id) {
	                        newUpdatedSprints = newUpdatedSprints.indexOf(id) === -1 ? newUpdatedSprints.concat(id) : newUpdatedSprints;
	                    });
	                }

	                updatedOrderObj[value] = newOrderArray;

	                return _extends({}, state, { recordsObj: updatedRecordsObj }, _defineProperty({}, orderKey, updatedOrderObj), { updatedSprints: newUpdatedSprints });
	            case 'OVERRIDE_DATA_OBJECT_PROP':
	                if (!action || !action.prop || !action.val) return state;

	                var prop = action.prop;
	                val = action.val;
	                updateObj = {};
	                updateObj[prop] = val;
	                return _extends({}, state, updateObj);
	            case 'RETURN_TO_PREVIOUS_STATE':
	                if (!action.history || !action.history.past) return state;
	                var past = action.history.past;
	                var previousIdx = past.length - 1;
	                var previousState = past[previousIdx];
	                var newState = _extends({}, previousState);
	                return newState;
	            case 'SAVING':
	                if (!action.status || action.status !== 'started') {
	                    return state;
	                }
	                return React.addons.update(state, { selected: { $set: [] } });
	            case 'TOGGLE_CHECKBOX':
	                // TODO - REFACTOR, but be careful with shouldUpdate.
	                if (!state.selected) {
	                    return state;
	                }
	                var newSelected = state.selected.slice();
	                var shiftKeyPressed = action.shiftKey;
	                var visibleRecordIds = action.visibleRecordIds;
	                if (newSelected.indexOf(action.id) === -1 && !shiftKeyPressed) {
	                    newSelected.push(action.id);
	                } else if (newSelected.indexOf(action.id) === -1 && shiftKeyPressed) {
	                    var lastSelectedId = newSelected.slice(-1)[0];
	                    var newId = action.id;
	                    var shouldUpdate = false;
	                    var allUpdateIds = visibleRecordIds.reduce(function (arr, id) {
	                        if ((id === lastSelectedId || id === newId) && _.isEmpty(arr)) {
	                            shouldUpdate = true;
	                            arr.push(id);
	                            return arr;
	                        }
	                        if (arr.length > 0 && (id === lastSelectedId || id === newId)) {
	                            shouldUpdate = false;
	                            arr.push(id);
	                            return arr;
	                        }
	                        if (shouldUpdate) {
	                            arr.push(id);
	                            return arr;
	                        }
	                        return arr;
	                    }, []);
	                    newSelected = _.uniq(newSelected.concat(allUpdateIds));
	                } else if (newSelected.indexOf(action.id) !== -1 && shiftKeyPressed) {
	                    var lastSelectedId = newSelected.slice(-1)[0];
	                    var newId = action.id;
	                    var shouldUpdate = false;
	                    var allUpdateIds = visibleRecordIds.reduce(function (arr, id) {
	                        if ((id === lastSelectedId || id === newId) && _.isEmpty(arr)) {
	                            shouldUpdate = true;
	                            arr.push(id);
	                            return arr;
	                        }
	                        if (arr.length > 0 && (id === lastSelectedId || id === newId)) {
	                            shouldUpdate = false;
	                            arr.push(id);
	                            return arr;
	                        }
	                        if (shouldUpdate) {
	                            arr.push(id);
	                            return arr;
	                        }
	                        return arr;
	                    }, []);
	                    var idsToRemove = _.intersection(newSelected.concat(allUpdateIds), allUpdateIds);
	                    newSelected = newSelected.filter(function (selectedId) {
	                        return idsToRemove.indexOf(selectedId) === -1;
	                    });
	                } else {
	                    newSelected = newSelected.filter(function (id) {
	                        return id !== action.id;
	                    });
	                }
	                return React.addons.update(state, { selected: { $set: newSelected } });
	            case 'TOGGLE_CHECKBOX_IF_UNCHECKED':
	                if (!state.selected) {
	                    return state;
	                }
	                var newItems = state.selected.slice();
	                if (newItems.indexOf(action.id) === -1) {
	                    newItems.push(action.id);
	                }
	                return React.addons.update(state, { selected: { $set: newItems } });
	            case 'TOGGLE_COLUMN':
	                if (action.currentlyActive) {
	                    var columnsWithoutThisLabel = state.columns.filter(function (column) {
	                        return column.label !== action.label;
	                    });
	                    state = _extends({}, state, { columns: columnsWithoutThisLabel });
	                } else {
	                    var columnsCopy = state.columns.slice();
	                    columnsCopy.push({ label: action.label });
	                    state = _extends({}, state, { columns: columnsCopy });
	                }
	                return state;
	            case 'TOGGLE_SELECT_ALL':
	                if (action.boolean && action.boolean === false) {
	                    return state;
	                } else if (action.boolean) {
	                    return React.addons.update(state, { selectAll: { $set: true } });
	                }
	            case 'TOGGLE_VISIBLE_CHECKBOXES':
	                var newItems = [];
	                if (!action.arrayOfIds || !state) {
	                    return state;
	                } else if (state.selected && state.selected.length > 0) {
	                    var newState = React.addons.update(state, { selectAll: { $set: false } });
	                    return React.addons.update(newState, { selected: { $set: [] } });
	                } else if (action.arrayOfIds) {
	                    var newState = React.addons.update(state, { selectAll: { $set: true } });
	                    return React.addons.update(newState, { selected: { $set: action.arrayOfIds } });
	                }
	            case 'UPDATE_ALL_COLUMNS':
	                if (!action) return state;

	                var columns = action.allColumns;
	                return _extends({}, state, { allColumns: allColumns });
	            case 'UPDATE_COLUMNS':
	                if (!action) return state;

	                // var columns = action.columns;
	                var label = action.label;
	                var sort = action.sort;
	                var updatedColumns = _helper2.default.updateColumnsBasedOnSort(state.columns, sort);
	                return _extends({}, state, { columns: updatedColumns });
	            case 'UPDATE_DATA_OBJECT_PROP':
	                if (!action || !action.prop || !action.val) return state;
	                return _extends({}, state, _defineProperty({}, action.prop, action.val));
	            case 'UPDATE_FILTERS':
	                var filterString = action.filterString;
	                var teamId = action.teamId;

	                if (!filterString || !teamId) {
	                    return state;
	                }

	                var filters = _extends({}, state.options.filters);
	                var teamFilters = filters[teamId];

	                if (!teamFilters) {
	                    teamFilters = '';
	                }
	                if (teamFilters.indexOf(filterString + ',') !== -1) {
	                    var newString = teamFilters.replace(filterString + ',', '');
	                } else {
	                    var newString = teamFilters + filterString + ',';
	                }
	                return React.addons.update(state, { options: { filters: _defineProperty({}, teamId, { $set: newString }) } });
	            case 'UPDATE_HEADER_TITLE':
	                if (!action.headerTitle) {
	                    return state;
	                }
	                return React.addons.update(state, { headerTitle: { $set: action.headerTitle } });
	            case 'UPDATE_RANKS':
	                if (!action) return state;

	                var targetRecord = action.targetRecord,
	                    selectedItems = state.selected,
	                    records = _helper2.default.getRecordsFromDataObject(state),
	                    sortColumn = state.sort.column,
	                    sortDirection = state.sort.direction;

	                if (!targetRecord || !selectedItems || !records || !sortColumn) {
	                    console.warn('targetRecord, selectedItems, records, or sortColumn were undefined: ', targetRecord, selectedItems, records, sortColumn);
	                    return state;
	                }
	                if (sortColumn !== 'Rank') {
	                    console.error('Can only call UPDATE_RANKS while sorted by rank');
	                    return state;
	                } else {
	                    var _helper$updateRecords = _helper2.default.updateRecordsBasedOnRank(state.recordIds, targetRecord, selectedItems, state.recordsObj, sortColumn, sortDirection),
	                        recordIds = _helper$updateRecords.recordIds,
	                        recordsObj = _helper$updateRecords.recordsObj;

	                    var newState = _extends({}, state, { recordIds: recordIds }, { recordsObj: recordsObj });
	                    return newState;
	                }
	            case 'UPDATE_OPTION':
	                if (!action.prop || !action.val && action.val !== '') {
	                    return state;
	                }
	                return React.addons.update(state, { options: _defineProperty({}, action.prop, { $set: action.val }) });
	            case 'UPDATE_OPTIONS':
	                if (!action) return state;
	                var options = action.options;
	                return _extends({}, state, { options: options });
	            case 'UPDATE_SORT':
	                if (!action.label) return state;
	                var newDirection;
	                if (state.sort && state.sort.column === action.label) {
	                    newDirection = state.sort && state.sort.direction === 'ascending' ? 'descending' : 'ascending';
	                } else {
	                    newDirection = 'ascending';
	                }

	                var newSort = {
	                    column: action.label,
	                    direction: newDirection
	                };
	                return _extends({}, state, { sort: newSort });
	            default:
	                return state;
	        }
	    },

	    history: function history(state, action) {
	        var initialState = {
	            past: []
	        };

	        if (!state) {
	            state = initialState;
	        }
	        switch (action.type) {
	            case 'CLEAR_HISTORY':
	                return initialState;
	            case 'RETURN_TO_PREVIOUS_STATE':
	                if (state.past.length === 0) return state;
	                return React.addons.update(state, { past: { $apply: function $apply(past) {
	                            return past.slice(0, -1);
	                        } } });
	            case 'SAVE_STATE':
	                if (!action.dataObject) return state;
	                var newState;
	                var historyCeiling = 15;
	                if (state.past.length > historyCeiling) {
	                    newState = React.addons.update(state, { past: { $apply: function $apply(past) {
	                                var newPast = past.slice(1);
	                                newPast.push(action.dataObject);
	                                return newPast;
	                            } } });
	                } else {
	                    newState = React.addons.update(state, { past: { $push: [action.dataObject] } });
	                }
	                return newState;
	            default:
	                return state;
	        }
	    },

	    loadingTable: function loadingTable(state, action) {
	        if (!state) state = false;

	        switch (action.type) {
	            case 'LOADING_TABLE':
	                return action.bool ? true : false;
	            default:
	                return state;
	        }
	    },

	    pendingSaves: function pendingSaves(state, action) {
	        // since saves are asynchronous, just count up for pending save, and down for completed save.
	        // when saving is at 0, we know we aren't saving.
	        if (!state) state = 0;
	        if (!action.status) return state;
	        switch (action.type) {
	            case 'SAVING':
	                if (action.status === 'started') {
	                    return state += 1;
	                } else if (action.status === 'finished') {
	                    return state -= 1;
	                } else {
	                    return state;
	                }
	            default:
	                return state;
	        }
	    },

	    searchTerm: function searchTerm(state, action) {
	        if (!state) state = '';

	        switch (action.type) {
	            case 'UPDATE_SEARCH_TERM':
	                return action.text;
	            default:
	                return state;
	        }
	    },

	    sidePanel: function sidePanel(state, action) {
	        var none = 'none';
	        if (!state) state = none;

	        switch (action.type) {
	            case 'TOGGLE_SIDE_PANEL':
	                if (!action.name) return state;
	                if (state === 'filter' && action.name === 'filter') return none;
	                if (state === 'massEdit' && action.name === 'massEdit') return none;
	                if (state === 'charts' && action.name === 'charts') return none;
	                return action.name;
	            case 'GET_USER_PREFERENCES_AS_JSON_SUCCESS':
	                return none;
	            default:
	                return state;

	        }
	    },

	    scrollTop: function scrollTop(state, action) {
	        if (!state) state = 0;
	        switch (action.type) {
	            case 'UPDATE_SCROLLTOP':
	                if (!action.y) return state;
	                return action.y;
	            default:
	                return state;
	        }
	    },

	    scrollNeedsUpdate: function scrollNeedsUpdate(state, action) {
	        if (!state) state = false;

	        switch (action.type) {
	            case 'SCROLL_NEEDS_UPDATE':
	                return action.bool;
	            default:
	                return state;
	        }
	    },

	    isFullscreen: function isFullscreen(state, action) {
	        if (!state) state = false;

	        switch (action.type) {
	            case 'IS_FULLSCREEN':
	                return action.bool;
	            default:
	                return state;
	        }
	    },

	    modal: function modal(state, action) {
	        var none = false;
	        if (!state) state = none;

	        switch (action.type) {
	            case 'TOGGLE_MODAL':
	                if (!action.name) return state;
	                if (state === 'velocityLine' && action.name === 'velocityLine') return none;
	                if (state === 'columns' && action.name === 'columns') return none;
	                return action.name;
	            case 'GET_USER_PREFERENCES_AS_JSON_SUCCESS':
	                return none;
	            default:
	                return state;

	        }
	    },

	    errorMessages: function errorMessages(state, action) {
	        if (!state) state = [];

	        switch (action.type) {
	            case 'CLEAR_ERROR_MESSAGES':
	                return [];
	            case 'ERROR_MESSAGES':
	                return action.messages;
	            default:
	                return state;

	        }
	    },

	    view: function view(state, action) {
	        if (!state) {
	            state = {
	                viewType: 'backlog',
	                paramId: null,
	                sprintId: null
	            };
	        };

	        switch (action.type) {
	            case 'UPDATE_VIEW':
	                if (!action.viewType) return state;
	                return _extends({}, state, {
	                    viewType: action.viewType,
	                    paramId: action.paramId,
	                    sprintId: action.sprintId
	                });
	            case 'GET_PANEL_WORK_ITEMS_AS_JSON_SUCCESS':
	                if (action.defaultView) {
	                    // defaultView is true when we try to query for something (like a sprint) and no records are returned, so we get all the backlog records back.
	                    return _extends({}, state, {
	                        viewType: 'backlog',
	                        paramId: action.headerId,
	                        sprintId: null
	                    });
	                } else {
	                    return state;
	                }
	            default:
	                return state;
	        }
	    }
	};

	var REDUCERS = combineReducers({
	    searchTerm: WMREDUCERS.searchTerm,
	    dataObject: WMREDUCERS.dataObject,
	    sidePanel: WMREDUCERS.sidePanel,
	    loadingTable: WMREDUCERS.loadingTable,
	    pendingSaves: WMREDUCERS.pendingSaves,
	    history: WMREDUCERS.history,
	    scrollTop: WMREDUCERS.scrollTop,
	    scrollNeedsUpdate: WMREDUCERS.scrollNeedsUpdate,
	    isFullscreen: WMREDUCERS.isFullscreen,
	    modal: WMREDUCERS.modal,
	    errorMessages: WMREDUCERS.errorMessages,
	    view: WMREDUCERS.view
	});

	var WMREDUCERS = exports.WMREDUCERS = WMREDUCERS;
	exports.default = REDUCERS;

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _WorkManagerDataPicker = __webpack_require__(10);

	var _WorkManagerDataPicker2 = _interopRequireDefault(_WorkManagerDataPicker);

	var _WorkManagerColumnsModal = __webpack_require__(11);

	var _WorkManagerColumnsModal2 = _interopRequireDefault(_WorkManagerColumnsModal);

	var _WorkManagerVelocityLineModal = __webpack_require__(12);

	var _WorkManagerVelocityLineModal2 = _interopRequireDefault(_WorkManagerVelocityLineModal);

	var _WorkManagerSearchField = __webpack_require__(14);

	var _WorkManagerSearchField2 = _interopRequireDefault(_WorkManagerSearchField);

	var _WorkManagerOptionsButton = __webpack_require__(15);

	var _WorkManagerOptionsButton2 = _interopRequireDefault(_WorkManagerOptionsButton);

	var _WorkManagerFullscreenButton = __webpack_require__(16);

	var _WorkManagerFullscreenButton2 = _interopRequireDefault(_WorkManagerFullscreenButton);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerPageHeaderProps = function mapStateToWorkManagerPageHeaderProps(state, ownProps) {

	    return {
	        dataObject: state.dataObject,
	        selected: state.dataObject.selected,
	        sidePanel: state.sidePanel,
	        pendingSaves: state.pendingSaves,
	        history: state.history,
	        filters: _selectors2.default.getTeamFilters(state),
	        filterDisplayString: _selectors2.default.getFilterDisplayString(state),
	        modal: state.modal,
	        errorMessages: state.errorMessages,
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerPageHeaderProps = function mapDispatchToWorkManagerPageHeaderProps(dispatch, ownProps) {
	    return {
	        undo: function undo(history) {
	            dispatch(_actionCreators2.default.returnToPreviousState(history));
	        },
	        saveWorks: function saveWorks(dataObject, paramId, selectedText, refreshPage) {
	            dispatch(_actionCreators2.default.clearHistory());
	            dispatch(_actionCreators2.default.saveWorks(dataObject, paramId, selectedText, refreshPage));
	        },
	        toggleSidePanel: function toggleSidePanel(whichPanel) {
	            dispatch(_actionCreators2.default.toggleSidePanel(whichPanel));
	        },
	        toggleModal: function toggleModal(name) {
	            dispatch(_actionCreators2.default.toggleModal(name));
	        },
	        clearErrorMessages: function clearErrorMessages() {
	            dispatch(_actionCreators2.default.clearErrorMessages());
	        }
	    };
	};

	var WorkManagerPageHeader = React.createClass({
	    displayName: 'WorkManagerPageHeader',

	    propTypes: function propTypes() {
	        return {
	            numVisibleRecordsWithoutHeaders: React.PropTypes.number.isRequired,
	            windowWidth: React.PropTypes.number.isRequired,
	            fullscreenId: React.PropTypes.string
	        };
	    },

	    componentDidUpdate: function componentDidUpdate(prevProps) {
	        if (prevProps.modal !== 'columns' && this.props.modal === 'columns') {
	            $('#modalSelectFieldsToDisplay').addClass('slds-fade-in-open');
	            $('.slds-modal-backdrop').addClass('slds-modal-backdrop--open');
	        }

	        if (prevProps.modal !== 'velocityLine' && this.props.modal === 'velocityLine') {
	            $('#modalVelocitySettings').addClass('slds-fade-in-open');
	            $('.slds-modal-backdrop').addClass('slds-modal-backdrop--open');
	        }
	    },

	    render: function render() {
	        var dataObject = this.props.dataObject;
	        var selected = this.props.selected;

	        return React.createElement(
	            'div',
	            { className: 'slds-page-header', role: 'banner' },
	            React.createElement(
	                'div',
	                { className: 'slds-grid' },
	                React.createElement(
	                    'div',
	                    { className: 'slds-media__figure' },
	                    React.createElement(
	                        'svg',
	                        { 'aria-hidden': 'true', className: 'slds-icon slds-icon--large slds-icon-custom-73', style: { padding: '8px' } },
	                        React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/action-sprite/svg/symbols.svg#new_custom73' })
	                    )
	                ),
	                React.createElement(
	                    'div',
	                    { className: 'slds-col slds-has-flexi-truncate' },
	                    React.createElement(
	                        'p',
	                        { className: 'slds-text-heading--label' },
	                        'Work Manager'
	                    ),
	                    React.createElement(
	                        'div',
	                        { className: 'slds-grid' },
	                        React.createElement(_WorkManagerDataPicker2.default, { headerTitle: dataObject.headerTitle, headerId: dataObject.headerId, dataObject: dataObject }),
	                        this.props.windowWidth > 650 ? React.createElement(_WorkManagerOptionsButton2.default, null) : undefined,
	                        this.props.modal === 'columns' ? React.createElement(_WorkManagerColumnsModal2.default, null) : undefined,
	                        this.props.modal === 'velocityLine' ? React.createElement(_WorkManagerVelocityLineModal2.default, null) : undefined
	                    )
	                ),
	                React.createElement(
	                    'div',
	                    null,
	                    this.props.pendingSaves ? React.createElement(
	                        'div',
	                        { className: 'saving-indicator slds-p-top--large slds-p-right--large' },
	                        React.createElement(
	                            'div',
	                            { className: 'header-x-small-spinner' },
	                            React.createElement('img', { src: '/resource/' + this.props.nameSpace + 'SLDS091/assets/images/spinners/slds_spinner_brand.gif', alt: 'Loading...' })
	                        ),
	                        React.createElement(
	                            'div',
	                            null,
	                            'Saving...'
	                        )
	                    ) : undefined,
	                    this.props.errorMessages && _.isArray(this.props.errorMessages) && this.props.errorMessages.length > 0 ? React.createElement(
	                        'div',
	                        { className: 'slds-notify_container adm-workmanager--error' },
	                        React.createElement(
	                            'div',
	                            { className: 'slds-notify slds-notify--toast slds-theme--error', role: 'alert' },
	                            React.createElement(
	                                'span',
	                                { className: 'slds-assistive-text' },
	                                'Error'
	                            ),
	                            React.createElement(
	                                'button',
	                                { className: 'slds-button slds-notify__close slds-button--icon-inverse', onClick: this.props.clearErrorMessages },
	                                React.createElement(
	                                    'svg',
	                                    { 'aria-hidden': 'true', className: 'slds-button__icon slds-button__icon--large' },
	                                    React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#close' })
	                                ),
	                                React.createElement(
	                                    'span',
	                                    { className: 'slds-assistive-text' },
	                                    'Close'
	                                )
	                            ),
	                            React.createElement(
	                                'div',
	                                { className: 'slds-notify__content slds-grid' },
	                                React.createElement(
	                                    'svg',
	                                    { 'aria-hidden': 'true', className: 'slds-icon slds-icon--small slds-m-right--small slds-col slds-no-flex' },
	                                    React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#ban' })
	                                ),
	                                React.createElement(
	                                    'div',
	                                    { className: 'slds-col slds-align-middle' },
	                                    this.props.errorMessages.map(function (message) {
	                                        return React.createElement(
	                                            'h2',
	                                            { className: 'slds-text-body--regular' },
	                                            message
	                                        );
	                                    })
	                                )
	                            )
	                        )
	                    ) : undefined
	                ),
	                React.createElement(
	                    'div',
	                    { id: 'managerToolbar', className: 'slds-col slds-no-flex slds-align-bottom' },
	                    React.createElement(
	                        'div',
	                        { className: 'slds-grid' },
	                        React.createElement(
	                            'div',
	                            { id: 'holderButtonSaveOrder', className: 'slds-button-group', role: 'group' },
	                            React.createElement(
	                                'button',
	                                { id: 'buttonUndo', className: 'slds-button slds-button--brand', style: { borderRight: '1px #7C94C5 solid', display: this.props.history.past.length > 0 ? 'block' : 'none' }, onClick: this.props.undo.bind(this, this.props.history) },
	                                'Undo'
	                            ),
	                            React.createElement(
	                                'button',
	                                { id: 'buttonSaveOrder', className: 'slds-button slds-button--brand', style: { borderRight: '1px #7C94C5 solid', display: this.props.history.past.length > 0 ? 'inline-block' : 'none' }, onClick: this.props.saveWorks.bind(this, dataObject, dataObject.headerId, dataObject.headerTitle, false) },
	                                'Save'
	                            )
	                        ),
	                        React.createElement(
	                            'div',
	                            { className: 'slds-button-space-left', style: { position: 'relative' } },
	                            React.createElement(_WorkManagerSearchField2.default, { name: 'quickSearch', id: 'quickSearch', className: 'slds-input', placeholder: 'Quick search' }),
	                            React.createElement(
	                                'svg',
	                                { id: 'quickSearchClear', 'aria-hidden': 'true', className: 'slds-button__icon' },
	                                React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#clear' })
	                            )
	                        ),
	                        React.createElement(
	                            'div',
	                            { className: 'slds-button-group slds-button-space-left', role: 'group' },
	                            React.createElement(
	                                'button',
	                                { id: 'buttonMassEdit', className: "slds-button slds-button--icon-border" + (this.props.sidePanel === 'massEdit' ? ' slds-is-selected' : ''), onClick: this.props.toggleSidePanel.bind(this, 'massEdit') },
	                                React.createElement(
	                                    'svg',
	                                    { 'aria-hidden': 'true', className: 'slds-button__icon' },
	                                    React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#edit' })
	                                ),
	                                React.createElement(
	                                    'span',
	                                    { className: 'slds-assistive-text' },
	                                    'Mass Edit'
	                                )
	                            ),
	                            React.createElement(
	                                'div',
	                                { id: 'modalMetadataProblem', 'aria-hidden': 'false', role: 'dialog', className: 'slds-modal' },
	                                React.createElement(
	                                    'div',
	                                    { className: 'slds-modal__container', style: { maxWidth: "360px" } },
	                                    React.createElement(
	                                        'div',
	                                        { className: 'slds-modal__header' },
	                                        React.createElement(
	                                            'h2',
	                                            { className: 'slds-text-heading--medium' },
	                                            'Potential Problem'
	                                        ),
	                                        React.createElement(
	                                            'button',
	                                            { className: 'slds-button slds-modal__close buttonCloseModal' },
	                                            React.createElement(
	                                                'svg',
	                                                { 'aria-hidden': 'true', className: 'slds-button__icon slds-button__icon--large' },
	                                                React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/action-sprite/svg/symbols.svg#close' })
	                                            ),
	                                            React.createElement(
	                                                'span',
	                                                { className: 'slds-assistive-text' },
	                                                'Close'
	                                            )
	                                        )
	                                    ),
	                                    React.createElement(
	                                        'div',
	                                        { className: 'slds-modal__content' },
	                                        React.createElement(
	                                            'div',
	                                            null,
	                                            "The metadata you entered doesn't exist in the Work Manager Interface. You must have at least one record in Work Manager that contains the metadata you used. Example: If you just created an Epic, you must have at least one work item assigned to that epic before you can filter or perform a mass edit with that new epic."
	                                        )
	                                    ),
	                                    React.createElement(
	                                        'div',
	                                        { className: 'slds-modal__footer' },
	                                        React.createElement(
	                                            'button',
	                                            { className: 'slds-button slds-button--neutral slds-button--brand buttonCloseModal' },
	                                            'Got It!'
	                                        )
	                                    )
	                                )
	                            ),
	                            React.createElement(
	                                'button',
	                                { id: 'buttonFilter', className: "slds-button slds-button--icon-border" + (this.props.sidePanel === 'filter' ? ' slds-is-selected' : '') + (this.props.sidePanel !== 'filter' && this.props.filters && this.props.filters.length > 0 ? ' tristate' : ''), onClick: this.props.toggleSidePanel.bind(this, 'filter') },
	                                React.createElement(
	                                    'svg',
	                                    { 'aria-hidden': 'true', className: 'slds-button__icon' },
	                                    React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#filterList' })
	                                ),
	                                React.createElement(
	                                    'span',
	                                    { className: 'slds-assistive-text' },
	                                    'Filter List'
	                                )
	                            ),
	                            React.createElement(
	                                'button',
	                                { id: 'buttonChart', className: "slds-button slds-button--icon-border" + (this.props.sidePanel === 'charts' ? ' slds-is-selected' : ''), onClick: this.props.toggleSidePanel.bind(this, 'charts') },
	                                React.createElement(
	                                    'svg',
	                                    { 'aria-hidden': 'true', className: 'slds-button__icon' },
	                                    React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#chart' })
	                                ),
	                                React.createElement(
	                                    'span',
	                                    { className: 'slds-assistive-text' },
	                                    'Chart'
	                                )
	                            )
	                        ),
	                        globalWorkManagerIsInAloha ? React.createElement(_WorkManagerFullscreenButton2.default, { fullscreenId: this.props.fullscreenId, nameSpace: this.props.nameSpace }) : undefined,
	                        React.createElement(
	                            'div',
	                            { className: 'slds-button-group', role: 'group' },
	                            React.createElement(
	                                'button',
	                                { id: 'buttonNewWork', className: 'slds-button slds-button--neutral', onClick: workModalOpen },
	                                'New Work'
	                            )
	                        )
	                    )
	                )
	            ),
	            React.createElement(
	                'div',
	                { className: 'slds-text-body--small slds-m-top--x-small header-small-text-container' },
	                React.createElement(
	                    'p',
	                    { className: 'slds-show--inline-block' },
	                    React.createElement(
	                        'span',
	                        null,
	                        this.props.numVisibleRecordsWithoutHeaders,
	                        ' of ',
	                        this.props.dataObject.recordIds.length,
	                        ' items'
	                    ),
	                    this.props.dataObject.sort.column ? React.createElement(
	                        'span',
	                        null,
	                        ' \u2022 Sorted by ',
	                        React.createElement(
	                            'span',
	                            { id: 'sortLabel' },
	                            this.props.dataObject.sort.column
	                        )
	                    ) : undefined,
	                    this.props.filterDisplayString ? React.createElement(
	                        'span',
	                        null,
	                        ' \u2022 Filtered by ',
	                        React.createElement(
	                            'span',
	                            { id: 'filterLabel' },
	                            this.props.filterDisplayString
	                        )
	                    ) : undefined,
	                    selected && selected.length !== 0 ? React.createElement(
	                        'span',
	                        null,
	                        ' \u2022 ',
	                        React.createElement(
	                            'span',
	                            { id: 'selectedLabel' },
	                            this.props.selected.length
	                        ),
	                        ' ',
	                        this.props.selected.length === 1 ? 'item' : 'items',
	                        ' selected'
	                    ) : undefined
	                )
	            )
	        );
	    }
	});

	WorkManagerPageHeader = connect(mapStateToWorkManagerPageHeaderProps, mapDispatchToWorkManagerPageHeaderProps)(WorkManagerPageHeader);

	exports.default = WorkManagerPageHeader;

/***/ },
/* 9 */
/***/ function(module, exports) {

	"use strict";

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	var PRESENTATIONALCOMPONENTS = {

	    ChartGroup: React.createClass({
	        displayName: "ChartGroup",

	        propTypes: {
	            label: React.PropTypes.string.isRequired,
	            content: React.PropTypes.node.isRequired,
	            open: React.PropTypes.bool.isRequired,
	            handleHeaderClick: React.PropTypes.func.isRequired,
	            nameSpace: React.PropTypes.string.isRequired
	        },

	        render: function render() {
	            var rightArrow = React.createElement(
	                "svg",
	                { "aria-hidden": "true", className: "slds-icon slds-icon--x-small" },
	                React.createElement("use", { xlinkHref: "/resource/" + this.props.nameSpace + "SLDS091/assets/icons/utility-sprite/svg/symbols.svg#right" })
	            );

	            var downArrow = React.createElement(
	                "svg",
	                { "aria-hidden": "true", className: "slds-icon slds-icon--x-small" },
	                React.createElement("use", { xlinkHref: "/resource/" + this.props.nameSpace + "SLDS091/assets/icons/utility-sprite/svg/symbols.svg#down" })
	            );

	            return React.createElement(
	                "div",
	                { className: "chartGroup" },
	                React.createElement(
	                    "div",
	                    { className: "chartTitle", onClick: this.props.handleHeaderClick },
	                    this.props.open ? downArrow : rightArrow,
	                    " ",
	                    this.props.label
	                ),
	                this.props.open ? React.createElement(
	                    "div",
	                    null,
	                    this.props.content
	                ) : undefined
	            );
	        }
	    }),

	    Checkbox: React.createClass({
	        displayName: "Checkbox",
	        componentDidMount: function componentDidMount() {
	            ReactDOM.findDOMNode(this).indeterminate = this.props.indeterminate;
	        },
	        componentDidUpdate: function componentDidUpdate() {
	            ReactDOM.findDOMNode(this).indeterminate = this.props.indeterminate;
	        },


	        render: function render() {
	            var props = this.props,
	                name = props.name,
	                value = props.value,
	                onChange = props.onChange,
	                id = props.id,
	                checked = props.checked;
	            return React.createElement(
	                "span",
	                { key: props.id },
	                React.createElement("input", { type: "checkbox", name: name, value: value, onChange: onChange, id: "select-row-" + id, checked: checked || false })
	            );
	        }
	    }),

	    ColumnsModal: React.createClass({
	        displayName: "ColumnsModal",

	        getDefaultProps: function getDefaultProps() {
	            return {
	                availableFields: [],
	                visibleFields: []
	            };
	        },

	        componentDidUpdate: function componentDidUpdate() {
	            this.createListItemsFromProps();
	        },

	        componentDidMount: function componentDidMount() {
	            this.createListItemsFromProps();

	            $('#modalSelectFieldsToDisplay .slds-picklist__options').sortable({
	                items: "> li",
	                connectWith: "#modalSelectFieldsToDisplay .slds-picklist__options",
	                containment: '#modalSelectFieldsToDisplay .slds-modal__content',
	                cursor: "move",
	                start: function start(event, ui) {
	                    if ($(ui.helper).attr('data-required') == 'true') {
	                        $("#listVisibleFields").sortable("option", "axis", "y");
	                    } else {
	                        $("#listVisibleFields").sortable("option", "axis", false);
	                    }
	                },
	                beforeStop: function beforeStop(event, ui) {
	                    if ($(ui.helper).attr('data-required') == 'true' && $(ui.helper).parent().attr('id') === 'listAvailableFields') {
	                        return false;
	                    }
	                }
	            });
	        },

	        buttonCloseModal: function buttonCloseModal() {
	            $('.slds-modal').removeClass('slds-fade-in-open');
	            $('.slds-modal-backdrop').removeClass('slds-modal-backdrop--open');
	            this.props.closeModal();
	            this.createListItemsFromProps();
	        },

	        createListItemsFromProps: function createListItemsFromProps() {
	            $('#listAvailableFields,#listVisibleFields').empty();
	            // Show visible columns in order they were saved in the visible fields column //
	            this.props.visibleFields.forEach(function (visibleField) {
	                $('#listVisibleFields').append(this.makeListItemStringFromField(visibleField));
	            }.bind(this));
	            // // Show the remaining columns in the available fields column //
	            this.props.availableFields.forEach(function (availableField) {
	                $('#listAvailableFields').append(this.makeListItemStringFromField(availableField));
	            }.bind(this));
	        },

	        makeListItemStringFromField: function makeListItemStringFromField(field) {
	            var label = field.label;
	            var required = field.required;
	            return '<li data-label="' + label + '" data-required=' + (required ? "true" : "false") + ' class="slds-picklist__item slds-has-icon slds-has-icon--left" tabindex="-1" aria-selected="false" role="option"><span class="slds-truncate">' + label + '</span></li>';
	        },

	        modalSelectFieldsToDisplayButtonSave: function modalSelectFieldsToDisplayButtonSave() {
	            // TODO - THIS SHOULD REALLY BE DONE IN THE SMART COMPONENT NOT THE DUMB ONE //
	            var that = this;
	            var updatedColumns = [];
	            var options = this.props.options;
	            var filters = this.props.filter;
	            var updatedOptions = _extends({}, options, { filters: filters });

	            $('#listVisibleFields > li').each(function () {
	                var label = $(this).attr('data-label');
	                updatedColumns.push({
	                    label: label
	                });
	            });

	            updatedColumns = updatedColumns.map(function (column) {
	                if (that.props.sort.column === column.label) {
	                    column.direction = that.props.sort.direction;
	                    return column;
	                } else {
	                    return column;
	                }
	            });

	            var cb = function (err, result) {
	                if (err) {
	                    console.error('WARNING: Failed to save User Preferences.  Error:' + event);
	                } else {
	                    console.log('User preference save successfully');
	                    $('.slds-modal').removeClass('slds-fade-in-open');
	                    $('.slds-modal-backdrop').removeClass('slds-modal-backdrop--open');
	                    this.buttonCloseModal();
	                    this.props.refreshData(this.props.dataObject);
	                }
	            }.bind(this);

	            this.props.onSave(updatedColumns, updatedOptions, cb);
	        },

	        render: function render() {

	            return React.createElement(
	                "div",
	                { id: "modalSelectFieldsToDisplay", "aria-hidden": "false", role: "dialog", className: "slds-modal" },
	                React.createElement(
	                    "div",
	                    { className: "slds-modal__container", style: { maxWidth: "528px" } },
	                    React.createElement(
	                        "div",
	                        { className: "slds-modal__header" },
	                        React.createElement(
	                            "h2",
	                            { className: "slds-text-heading--medium" },
	                            "Select Columns to Display"
	                        ),
	                        React.createElement(
	                            "button",
	                            { className: "slds-button slds-modal__close buttonCloseModal", onClick: this.buttonCloseModal },
	                            React.createElement(
	                                "svg",
	                                { "aria-hidden": "true", className: "slds-button__icon slds-button__icon--large" },
	                                React.createElement("use", { xlinkHref: "/resource/" + this.props.nameSpace + "SLDS091/assets/icons/action-sprite/svg/symbols.svg#close" })
	                            ),
	                            React.createElement(
	                                "span",
	                                { className: "slds-assistive-text" },
	                                "Close"
	                            )
	                        ),
	                        React.createElement(
	                            "p",
	                            { style: { padding: "0px 30px" } },
	                            "Drag-and-Drop between panels to pick which fields are visible and the order in which there displayed. Fields with ",
	                            React.createElement(
	                                "span",
	                                { className: "required" },
	                                "asterisks"
	                            ),
	                            " cannot be removed from visible fields."
	                        )
	                    ),
	                    React.createElement(
	                        "div",
	                        { className: "slds-modal__content" },
	                        React.createElement(
	                            "div",
	                            null,
	                            React.createElement(
	                                "div",
	                                { className: "slds-picklist--draggable slds-grid" },
	                                React.createElement(
	                                    "div",
	                                    { className: "slds-form-element slds-m-right--x-small" },
	                                    React.createElement(
	                                        "span",
	                                        { className: "slds-form-element__label", "aria-label": "select-1" },
	                                        "Available Fields"
	                                    ),
	                                    React.createElement(
	                                        "div",
	                                        { className: "slds-picklist slds-picklist--multi" },
	                                        React.createElement("ul", { id: "listAvailableFields", className: "slds-picklist__options slds-picklist__options--multi shown" })
	                                    )
	                                ),
	                                React.createElement(
	                                    "div",
	                                    { className: "slds-form-element slds-m-left--x-small" },
	                                    React.createElement(
	                                        "span",
	                                        { className: "slds-form-element__label", "aria-label": "select-2" },
	                                        "Visible Fields"
	                                    ),
	                                    React.createElement(
	                                        "div",
	                                        { className: "slds-picklist slds-picklist--multi" },
	                                        React.createElement("ul", { id: "listVisibleFields", className: "slds-picklist__options slds-picklist__options--multi shown" })
	                                    )
	                                )
	                            )
	                        )
	                    ),
	                    React.createElement(
	                        "div",
	                        { className: "slds-modal__footer" },
	                        React.createElement(
	                            "button",
	                            { className: "slds-button slds-button--neutral buttonCloseModal", onClick: this.buttonCloseModal },
	                            "Cancel"
	                        ),
	                        React.createElement(
	                            "button",
	                            { id: "modalSelectFieldsToDisplayButtonSave", className: "slds-button slds-button--neutral slds-button--brand slds-button-space-left", onClick: this.modalSelectFieldsToDisplayButtonSave },
	                            "Save"
	                        )
	                    )
	                )
	            );
	        }
	    }),

	    FullscreenButton: React.createClass({
	        displayName: "FullscreenButton",

	        propTypes: function propTypes() {
	            return {
	                onClick: React.PropTypes.func,
	                active: React.PropTypes.bool,
	                class: React.PropTypes.string,
	                nameSpace: React.PropTypes.string
	            };
	        },

	        render: function render() {
	            var classes = "slds-button slds-button--icon-border";
	            if (this.props.active) {
	                classes += " slds-is-selected";
	            }

	            return React.createElement(
	                "button",
	                { id: "buttonFullscreen", className: classes + " " + this.props.class, onClick: this.props.onClick },
	                React.createElement(
	                    "svg",
	                    { "aria-hidden": "true", className: "slds-button__icon" },
	                    React.createElement("use", { xlinkHref: "/resource/" + this.props.nameSpace + "SLDS091/assets/icons/utility-sprite/svg/symbols.svg#expand" })
	                ),
	                React.createElement(
	                    "span",
	                    { className: "slds-assistive-text" },
	                    "Full Screen"
	                )
	            );
	        }
	    }),

	    Gripper: React.createClass({
	        displayName: "Gripper",

	        render: function render() {
	            var onMouseDown = this.props.onMouseDown,
	                draggable = this.props.draggable,
	                nameSpace = this.props.nameSpace;

	            var cursor = draggable ? 'move' : 'not-allowed';

	            return React.createElement(
	                "div",
	                { onMouseDown: onMouseDown, style: { width: "100%", cursor: cursor } },
	                React.createElement(
	                    "svg",
	                    { "aria-hidden": "true", className: "slds-button__icon slds-button__icon--small slds-m-left--x-small" },
	                    React.createElement("use", { xlinkHref: "/resource/" + this.props.nameSpace + "SLDS091/assets/icons/utility-sprite/svg/symbols.svg#rows" })
	                )
	            );
	        }
	    }),

	    HeaderCell: React.createClass({
	        displayName: "HeaderCell",

	        render: function render() {
	            var props = this.props,
	                label = props.label,
	                sortDirection = props.sort && props.sort.direction ? props.sort.direction : null,
	                sortColumn = props.sort && props.sort.column ? props.sort.column : null,
	                nameSpace = props.nameSpace;
	            var arrowDirection = function arrowDirection() {
	                if (label === sortColumn && sortDirection === 'ascending') return 'up';
	                if (label === sortColumn && sortDirection === 'descending') return 'down';
	                if (label !== sortColumn) return 'up';
	                // label === sortColumn && sortDirection === 'ascending' ? 'down' : 'up')
	            };

	            return React.createElement(
	                "div",
	                { scope: "col" },
	                React.createElement(
	                    "div",
	                    { className: "slds-truncate" },
	                    label !== 'Record Type' ? label : '',
	                    React.createElement(
	                        "button",
	                        { className: "slds-button slds-button--icon-bare" },
	                        React.createElement(
	                            "svg",
	                            { "aria-hidden": "true", className: "slds-button__icon slds-button__icon--small" },
	                            React.createElement("use", { xlinkHref: "/resource/" + nameSpace + "SLDS091/assets/icons/utility-sprite/svg/symbols.svg#arrow" + arrowDirection() })
	                        ),
	                        React.createElement(
	                            "span",
	                            { className: "slds-assistive-text" },
	                            "Sort"
	                        )
	                    )
	                )
	            );
	        }
	    }),

	    HeaderTitle: React.createClass({
	        displayName: "HeaderTitle",

	        propTypes: {
	            headerTitle: React.PropTypes.string.isRequired,
	            nameSpace: React.PropTypes.string
	        },

	        getDefaultProps: function getDefaultProps() {
	            return {
	                headerTitle: '',
	                arrow: false,
	                headerId: null
	            };
	        },

	        render: function render() {
	            var downArrow = React.createElement(
	                "button",
	                { className: "slds-button slds-button--icon-bare slds-shrink-none slds-align-middle slds-m-left--x-small" },
	                React.createElement(
	                    "svg",
	                    { "aria-hidden": "true", className: "slds-button__icon" },
	                    React.createElement("use", { xlinkHref: "/resource/" + this.props.nameSpace + "SLDS091/assets/icons/utility-sprite/svg/symbols.svg#down" })
	                ),
	                React.createElement(
	                    "span",
	                    { className: "slds-assistive-text" },
	                    "View More"
	                )
	            );

	            return React.createElement(
	                "div",
	                null,
	                React.createElement(
	                    "div",
	                    { id: "buttonTitle", className: "slds-grid slds-no-space slds-type-focus" },
	                    React.createElement(
	                        "h1",
	                        { className: "slds-text-heading--medium slds-truncate", title: this.props.headerTitle, "data-text": this.props.headerTitle, "data-id": this.props.headerId },
	                        this.props.headerTitle
	                    )
	                ),
	                React.createElement(
	                    "div",
	                    { id: "dropdownDataSources", className: "slds-dropdown slds-dropdown--left slds-dropdown--menu slds-dropdown--nubbin-top slds-hide", "data-source": "backlog" },
	                    React.createElement(
	                        "ul",
	                        { className: "slds-dropdown__list", role: "menu", style: { display: 'table-cell', verticalAlign: 'top' } },
	                        React.createElement(
	                            "li",
	                            { className: "slds-dropdown__item" },
	                            React.createElement(
	                                "a",
	                                { "data-source": "backlog", href: "#", className: "slds-truncate", role: "menuitem" },
	                                "Backlog..."
	                            )
	                        ),
	                        React.createElement(
	                            "li",
	                            { className: "slds-dropdown__item" },
	                            React.createElement(
	                                "a",
	                                { "data-source": "epic", href: "#", className: "slds-truncate", role: "menuitem" },
	                                "By Epic..."
	                            )
	                        ),
	                        React.createElement(
	                            "li",
	                            { className: "slds-dropdown__item" },
	                            React.createElement(
	                                "a",
	                                { "data-source": "sprint", href: "#", className: "slds-truncate", role: "menuitem" },
	                                "By Sprint..."
	                            )
	                        ),
	                        React.createElement(
	                            "li",
	                            { className: "slds-dropdown__item" },
	                            React.createElement(
	                                "a",
	                                { "data-source": "theme", href: "#", className: "slds-truncate", role: "menuitem" },
	                                "By Theme..."
	                            )
	                        ),
	                        React.createElement(
	                            "li",
	                            { className: "slds-dropdown__item" },
	                            React.createElement(
	                                "a",
	                                { "data-source": "build", href: "#", className: "slds-truncate", role: "menuitem" },
	                                "By Build..."
	                            )
	                        ),
	                        React.createElement(
	                            "li",
	                            { className: "slds-dropdown__item" },
	                            React.createElement(
	                                "a",
	                                { "data-source": "producttag", href: "#", className: "slds-truncate", role: "menuitem" },
	                                "By Product Tag..."
	                            )
	                        )
	                    ),
	                    React.createElement(
	                        "div",
	                        { id: "dropdownDataSourcesSidePanel" },
	                        React.createElement(
	                            "div",
	                            null,
	                            React.createElement("input", { id: "dropdownDataSourcesSearch", className: "slds-input", placeholder: "" }),
	                            React.createElement(
	                                "svg",
	                                { id: "dropdownDataSourcesSearchClear", "aria-hidden": "true", className: "slds-button__icon" },
	                                React.createElement("use", { xlinkHref: "/resource/" + this.props.nameSpace + "SLDS091/assets/icons/utility-sprite/svg/symbols.svg#clear" })
	                            ),
	                            React.createElement("div", { id: "dropdownDataSourcesRecents" }),
	                            React.createElement("div", { id: "dropdownDataSourcesResults" })
	                        )
	                    )
	                )
	            );
	        }
	    }),

	    SidePanel: React.createClass({
	        displayName: "SidePanel",

	        propTypes: {
	            content: React.PropTypes.node,
	            id: React.PropTypes.string,
	            padding: React.PropTypes.bool
	        },

	        render: function render() {
	            return React.createElement(
	                "div",
	                { className: "sideContainerBox", id: this.props.id, style: { padding: this.props.padding ? "15px" : 'inherit' } },
	                this.props.content
	            );
	        }
	    }),

	    TextField: React.createClass({
	        displayName: "TextField",

	        render: function render() {
	            var props = this.props,
	                name = props.name,
	                onChange = props.onChange,
	                id = props.id,
	                placeholder = props.placeholder,
	                className = props.className;

	            return React.createElement(
	                "span",
	                { key: id },
	                React.createElement("input", { type: "text", name: name, onChange: onChange, placeholder: placeholder || '', className: className, id: id })
	            );
	        }
	    })

	};

	exports.default = PRESENTATIONALCOMPONENTS;

/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerDataPickerProps = function mapStateToWorkManagerDataPickerProps(state, ownProps) {
	    return {
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerDataPickerProps = function mapDispatchToWorkManagerDataPickerProps(dispatch, ownProps) {
	    return {
	        refreshData: function refreshData(dataObject, overrideHistoryCheck, initialLoad, viewChangeRequested, paramId, selectedText) {
	            dispatch(_actionCreators2.default.refreshData(dataObject, overrideHistoryCheck, initialLoad, viewChangeRequested, paramId, selectedText));
	        },
	        saveUserPreferenceAsJSON: function saveUserPreferenceAsJSON(columns, options, cb) {
	            dispatch(_actionCreators2.default.saveUserPreferenceAsJSON(columns, options, cb));
	        },
	        updateOption: function updateOption(prop, val) {
	            dispatch(_actionCreators2.default.updateOption(prop, val));
	        },
	        updateView: function updateView(viewType, paramId, sprintId) {
	            dispatch(_actionCreators2.default.updateView(viewType, paramId, sprintId));
	        }
	    };
	};

	var WorkManagerDataPicker = React.createClass({
	    displayName: 'WorkManagerDataPicker',

	    propTypes: {
	        headerTitle: React.PropTypes.string.isRequired,
	        headerId: React.PropTypes.string,
	        dataObject: React.PropTypes.object.isRequired
	    },

	    componentDidMount: function componentDidMount() {
	        var that = this;

	        function hideDropdowns(e) {
	            if (e) {
	                if ($(e.target).closest('.slds-dropdown').length == 0) {
	                    hideDropdownInc();
	                }
	            } else {
	                hideDropdownInc();
	            }
	        }

	        function hideDropdownInc() {
	            $('.slds-dropdown').addClass('slds-hide');
	            if ($('html').hasClass('fullscreen')) {
	                $('body').css('overflow', 'hidden');
	            } else {
	                $('body').css('overflow', 'auto');
	            }
	            $(document).unbind('click', hideDropdowns);
	        }

	        function autoCompleteResults(err, records) {
	            if (err) {
	                console.error(err);
	            } else {
	                $('#dropdownDataSourcesResults').empty();
	                if (records.length > 0) {
	                    records.forEach(function (record) {
	                        var id = record.get("Id");
	                        var name = record.get("Name");
	                        var getType = function getType(_name) {
	                            var result = 'backlog';
	                            if (_name === 'ADM_Epic__c') {
	                                result = 'epic';
	                            } else if (_name === 'ADM_Sprint__c') {
	                                result = 'sprint';
	                            } else if (_name === 'ADM_Theme__c') {
	                                result = 'theme';
	                            } else if (_name === 'ADM_Build__c') {
	                                result = 'build';
	                            } else if (_name === 'ADM_Product_Tag__c') {
	                                result = 'producttag';
	                            }
	                            return result;
	                        };
	                        var type = getType(record._name);
	                        $('#dropdownDataSourcesResults').append("<a data-id=" + id + " href='#' data-type=" + type + ">" + name + "</a>");
	                    });
	                } else {
	                    $('#dropdownDataSourcesResults').text('No results found');
	                }
	            }
	        }

	        $('.buttonCloseModal').on('click', function (e) {
	            $('.slds-modal').removeClass('slds-fade-in-open');
	            $('.slds-modal-backdrop').removeClass('slds-modal-backdrop--open');
	        });

	        $('#buttonTitle').on('click', function (e) {
	            e.stopPropagation();

	            if ($('html').hasClass('fullscreen')) {
	                var headerOffset = 0;
	            } else {
	                var headerOffset = $('.bPageHeader').height();
	            }
	            // var bottomPosition = $(this).offset().top + $(this).height() - headerOffset + 5;
	            // var leftPosition = $(this).offset().left - parseInt($('body').css('margin-left'));
	            $('#dropdownDataSources > ul a,#dropdownDataSourcesResults a').removeClass('hover selected');
	            $('#dropdownDataSourcesSidePanel').hide();
	            if ($('#dropdownDataSources').hasClass('slds-hide')) {
	                hideDropdowns();
	                // $('#dropdownDataSources').removeClass('slds-hide').css('top',bottomPosition + 'px').css('left',leftPosition + 'px');
	                // $('#dropdownDataSources').removeClass('slds-hide').css('left',leftPosition + 'px');
	                $('#dropdownDataSources').removeClass('slds-hide').css('left', '0px');
	                $('body').css('overflow', 'hidden');
	                $(document).on('click', hideDropdowns);
	                $(document).on('click', function (e) {
	                    hideDropdowns(e);
	                });
	            } else {
	                hideDropdowns();
	            }
	        });

	        var populateDataSources = function populateDataSources() {
	            $('#dropdownDataSourcesSearch').val('');
	            $('#dropdownDataSourcesSearchClear').hide();
	            $('#dropdownDataSourcesSearch').focus();

	            if ($('#dropdownDataSources').attr('data-source') == 'backlog' || $('#dropdownDataSources').attr('data-source') == 'backburner') {
	                $('#dropdownDataSourcesSearch').attr('placeholder', 'Search Teams...');
	                $('#dropdownDataSourcesResults').empty();
	                $('#dropdownDataSourcesRecents').text('Suggested Teams:');
	                $('#dropdownDataSourcesResults').prepend("<a data-id=" + that.props.dataObject.team.Id + " href='#'>" + that.props.dataObject.team.Name + "</a>");
	                // TODO: Add in other teams user has a membership to
	            } else if ($('#dropdownDataSources').attr('data-source') == 'epic') {
	                $('#dropdownDataSourcesSearch').attr('placeholder', 'Search Epics...');
	                $('#dropdownDataSourcesResults').empty();
	                $('#dropdownDataSourcesRecents').text('Suggested Epics:');
	                $.each(that.props.dataObject.allEpics, function (index, record) {
	                    // append("<a data-id=" + id + " href='#'>" + name + "</a>");
	                    $('#dropdownDataSourcesResults').prepend("<a data-id=" + record.Id + " href='#'>" + record.Name + "</a>");
	                });
	            } else if ($('#dropdownDataSources').attr('data-source') == 'sprint') {
	                $('#dropdownDataSourcesSearch').attr('placeholder', 'Search Sprints...');
	                $('#dropdownDataSourcesResults').empty();
	                $('#dropdownDataSourcesRecents').text('Suggested Sprints:');
	                $.each(that.props.dataObject.allSprints, function (index, record) {
	                    $('#dropdownDataSourcesResults').prepend("<a data-id=" + record.Id + " href='#'>" + record.Name + "</a>");
	                });
	            } else if ($('#dropdownDataSources').attr('data-source') == 'theme') {
	                $('#dropdownDataSourcesSearch').attr('placeholder', 'Search Themes...');
	                $('#dropdownDataSourcesResults').empty();
	                $('#dropdownDataSourcesRecents').text('No Theme Suggestions');
	                /*$.each(dataObject.allSprints, function(index, record) {
	                    $('#dropdownDataSourcesResults').prepend(dataSourceTemplate({
	                        Id:record.Id,
	                        Name:record.Name
	                    }));
	                });*/
	            } else if ($('#dropdownDataSources').attr('data-source') == 'build') {
	                $('#dropdownDataSourcesSearch').attr('placeholder', 'Search Builds...');
	                $('#dropdownDataSourcesResults').empty();
	                $('#dropdownDataSourcesRecents').text('Suggested Builds:');
	                $.each(that.props.dataObject.allBuilds, function (index, record) {
	                    $('#dropdownDataSourcesResults').prepend("<a data-id=" + record.Id + " href='#'>" + record.Name + "</a>");
	                });
	            } else if ($('#dropdownDataSources').attr('data-source') == 'producttag') {
	                $('#dropdownDataSourcesSearch').attr('placeholder', 'Search Product Tags...');
	                $('#dropdownDataSourcesResults').empty();
	                $('#dropdownDataSourcesRecents').text('Suggested Product Tags:');
	                $.each(that.props.dataObject.allProductTags, function (index, record) {
	                    $('#dropdownDataSourcesResults').prepend("<a data-id=" + record.Id + " href='#'>" + record.Name + "</a>");
	                });
	            }
	        };

	        $('#dropdownDataSources').on('click', 'li a', function (e) {
	            e.preventDefault();
	            e.stopPropagation();

	            $('#dropdownDataSources a').removeClass('selected');
	            $(this).addClass('selected');
	            $('#dropdownDataSourcesSidePanel').css('display', 'table-cell');
	            $('#dropdownDataSources').attr('data-source', $(this).attr('data-source'));
	            populateDataSources();
	            if ($(this).closest('li').is(':first-child')) {
	                $('#dropdownDataSourcesSidePanel').addClass('firstChild');
	            } else {
	                $('#dropdownDataSourcesSidePanel').removeClass('firstChild');
	            }
	            if ($(this).closest('li').is(':last-child')) {
	                $('#dropdownDataSourcesSidePanel').addClass('lastChild');
	            } else {
	                $('#dropdownDataSourcesSidePanel').removeClass('lastChild');
	            }
	        });

	        $('#dropdownDataSources').on('keyup', '#dropdownDataSourcesSearch', function (e) {
	            if (e.which == 38 || e.which == 40) {
	                var selectedSource = 0;
	                if (e.which == 40 && $('#dropdownDataSourcesResults a.hover').length > 0) {
	                    // Down
	                    selectedSource = $('#dropdownDataSourcesResults a.hover').index() + 1;
	                    if ($('#dropdownDataSourcesResults a:nth(' + selectedSource + ')').length == 0) {
	                        selectedSource = 0;
	                    }
	                } else if (e.which == 38 && $('#dropdownDataSourcesResults a.hover').length > 0) {
	                    // Up
	                    selectedSource = $('#dropdownDataSourcesResults a.hover').index() - 1;
	                    if (selectedSource == -1) {
	                        selectedSource = $('#dropdownDataSourcesResults a:last').index();
	                    }
	                }
	                var newScrollTop = 35 * selectedSource;
	                $('#dropdownDataSourcesResults').animate({ scrollTop: newScrollTop });
	                $('#dropdownDataSourcesResults a').removeClass('hover');
	                $('#dropdownDataSourcesResults a:nth(' + selectedSource + ')').addClass('hover');
	            } else if (e.which == 13) {
	                // Enter
	                if ($('#dropdownDataSourcesResults a.hover').length > 0) {
	                    $('#dropdownDataSourcesResults a.hover').removeClass('hover').addClass('selected');
	                    switchDataSource($('#dropdownDataSources > ul a.selected').attr('data-source'), $('#dropdownDataSourcesResults a.selected').attr('data-id'), $('#dropdownDataSourcesResults a.selected').text());
	                }
	            } else {
	                // Other
	                if ($(this).val() == '') {
	                    $('#dropdownDataSourcesSearchClear').hide();
	                    populateDataSources();
	                } else {
	                    $('#dropdownDataSourcesSearchClear').show();

	                    if ($('#dropdownDataSources').attr('data-source') == 'backlog' || $('#dropdownDataSources').attr('data-source') == 'backburner') {
	                        var keyword = '%' + $(this).val() + '%';
	                        var autoComplete = new SObjectModel.Teams();
	                        autoComplete.retrieve({ where: { Name: { like: keyword } }, limit: 100, orderby: [{ Name: 'ASC' }] }, autoCompleteResults);
	                        $('#dropdownDataSourcesRecents').text('Team Search Results:');
	                    } else if ($('#dropdownDataSources').attr('data-source') == 'epic') {
	                        var keyword = '%' + $(this).val() + '%';
	                        var autoComplete = new SObjectModel.Epics();
	                        autoComplete.retrieve({ where: { Name: { like: keyword } }, limit: 100, orderby: [{ Name: 'ASC' }] }, autoCompleteResults);
	                        $('#dropdownDataSourcesRecents').text('Epic Search Results:');
	                    } else if ($('#dropdownDataSources').attr('data-source') == 'sprint') {
	                        var keyword = '%' + $(this).val() + '%';
	                        var autoComplete = new SObjectModel.Sprints();
	                        autoComplete.retrieve({ where: { Name: { like: keyword } }, limit: 100, orderby: [{ Name: 'DESC' }] }, autoCompleteResults);
	                        $('#dropdownDataSourcesRecents').text('Sprint Search Results:');
	                    } else if ($('#dropdownDataSources').attr('data-source') == 'theme') {
	                        var keyword = '%' + $(this).val() + '%';
	                        var autoComplete = new SObjectModel.Themes();
	                        autoComplete.retrieve({ where: { Name: { like: keyword } }, limit: 100, orderby: [{ Name: 'ASC' }] }, autoCompleteResults);
	                        $('#dropdownDataSourcesRecents').text('Theme Search Results:');
	                    } else if ($('#dropdownDataSources').attr('data-source') == 'build') {
	                        var keyword = '%' + $(this).val() + '%';
	                        var autoComplete = new SObjectModel.Builds();
	                        autoComplete.retrieve({ where: { Name: { like: keyword } }, limit: 100, orderby: [{ Name: 'ASC' }] }, autoCompleteResults);
	                        $('#dropdownDataSourcesRecents').text('Build Search Results:');
	                    } else if ($('#dropdownDataSources').attr('data-source') == 'producttag') {
	                        var keyword = '%' + $(this).val() + '%';
	                        var autoComplete = new SObjectModel.ProductTags();
	                        autoComplete.retrieve({ where: { Name: { like: keyword } }, limit: 100, orderby: [{ Name: 'ASC' }] }, autoCompleteResults);
	                        $('#dropdownDataSourcesRecents').text('Product Tag Search Results:');
	                    }
	                }
	            }
	        });

	        $('#dropdownDataSourcesResults').on('click', 'a', function (e) {
	            e.preventDefault();
	            e.stopPropagation();

	            $('#dropdownDataSourcesResults a').removeClass('selected');
	            $(this).addClass('selected');

	            switchDataSource($('#dropdownDataSources > ul a.selected').attr('data-source'), $('#dropdownDataSourcesResults a.selected').attr('data-id'), $('#dropdownDataSourcesResults a.selected').text());
	        });

	        $('#dropdownDataSourcesSearchClear').on('click', function () {
	            $(this).hide();
	            $('#dropdownDataSourcesSearch').val(null).focus();
	            populateDataSources();
	        });

	        function switchDataSource(type, id, selectedText) {
	            $('#dropdownDataSources').addClass('slds-hide');
	            $('#dropdownDataSources > ul a,#dropdownDataSourcesResults a').removeClass('hover selected');
	            $('#dropdownDataSourcesSearch').attr('placeholder', '');
	            $('#dropdownDataSourcesRecents').text('');
	            $('#dropdownDataSourcesResults').empty();
	            $('#dropdownDataSourcesSidePanel').hide();
	            console.log('Changing data source to ' + type + ': ' + id);

	            that.props.updateOption('lastView', type);
	            that.props.updateView(type, id);

	            var cb = function cb(err, result) {
	                if (err) {
	                    console.error('Error when saving user prefrences after switching data picker: ', err);
	                } else {
	                    that.props.refreshData(that.props.dataObject, false, false, 'changeView', id, selectedText);
	                }
	            };
	            that.props.saveUserPreferenceAsJSON(that.props.dataObject.columns, that.props.dataObject.options, cb);
	        }
	    },

	    getDefaultProps: function getDefaultProps() {
	        return {
	            headerTitle: ''
	        };
	    },

	    render: function render() {
	        return React.createElement(
	            'div',
	            null,
	            React.createElement(_PRESENTATIONALCOMPONENTS2.default.HeaderTitle, { headerTitle: this.props.headerTitle, headerId: this.props.headerId, nameSpace: this.props.nameSpace, arrow: true }),
	            React.createElement(
	                'div',
	                { id: 'nofityUserDialog', 'aria-hidden': 'false', role: 'dialog', className: 'slds-modal' },
	                React.createElement(
	                    'div',
	                    { className: 'slds-modal__container', style: { maxWidth: "360px" } },
	                    React.createElement(
	                        'div',
	                        { className: 'slds-modal__header' },
	                        React.createElement('h2', { className: 'slds-text-heading--medium' }),
	                        React.createElement(
	                            'button',
	                            { className: 'slds-button slds-modal__close buttonCloseModal' },
	                            React.createElement(
	                                'svg',
	                                { 'aria-hidden': 'true', className: 'slds-button__icon slds-button__icon--large' },
	                                React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/action-sprite/svg/symbols.svg#close' })
	                            ),
	                            React.createElement(
	                                'span',
	                                { className: 'slds-assistive-text' },
	                                'Close'
	                            )
	                        )
	                    ),
	                    React.createElement(
	                        'div',
	                        { className: 'slds-modal__content' },
	                        React.createElement('div', null)
	                    ),
	                    React.createElement(
	                        'div',
	                        { className: 'slds-modal__footer' },
	                        React.createElement(
	                            'button',
	                            { className: 'slds-button slds-button--neutral slds-button--brand buttonCloseModal' },
	                            'Dismiss'
	                        )
	                    )
	                )
	            )
	        );
	    }
	});
	WorkManagerDataPicker = connect(mapStateToWorkManagerDataPickerProps, mapDispatchToWorkManagerDataPickerProps)(WorkManagerDataPicker);

	exports.default = WorkManagerDataPicker;

/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerColumnsModalProps = function mapStateToWorkManagerColumnsModalProps(state, ownProps) {
	    return {
	        dataObject: state.dataObject,
	        filter: _selectors2.default.getFilters(state),
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerColumnsModalProps = function mapDispatchToWorkManagerColumnsModalProps(dispatch, ownProps) {
	    return {
	        saveUserPreferenceAsJSON: function saveUserPreferenceAsJSON(columns, options, cb) {
	            dispatch(_actionCreators2.default.saveUserPreferenceAsJSON(columns, options, cb));
	        },
	        refreshData: function refreshData(dataObject) {
	            dispatch(_actionCreators2.default.refreshData(dataObject));
	        },
	        toggleModal: function toggleModal(name) {
	            dispatch(_actionCreators2.default.toggleModal(name));
	        }
	    };
	};

	var WorkManagerColumnsModal = React.createClass({
	    displayName: 'WorkManagerColumnsModal',

	    render: function render() {
	        var props = this.props,
	            dataObject = props.dataObject,
	            sort = dataObject.sort,
	            options = dataObject.options,
	            columns = dataObject.columns,
	            allColumns = dataObject.allColumns,
	            filter = props.filter,
	            saveUserPreferenceAsJSON = props.saveUserPreferenceAsJSON,
	            refreshData = props.refreshData,
	            nameSpace = props.nameSpace;

	        var self = this,
	            visibleFields = [],
	            availableFields = [],
	            visibleColumnLabels = columns.map(function (column) {
	            return column.label;
	        }),
	            closeModal = function closeModal() {
	            self.props.toggleModal('columns');
	        };
	        if (allColumns) {
	            allColumns.forEach(function (column) {
	                if (visibleColumnLabels.indexOf(column.label) === -1) {
	                    availableFields.push(column);
	                } else {

	                    visibleFields[visibleColumnLabels.indexOf(column.label)] = column;
	                }
	            });
	        }

	        return React.createElement(_PRESENTATIONALCOMPONENTS2.default.ColumnsModal, {
	            availableFields: availableFields,
	            visibleFields: visibleFields,
	            sort: sort,
	            onSave: saveUserPreferenceAsJSON,
	            options: options,
	            filter: filter,
	            refreshData: refreshData,
	            dataObject: dataObject,
	            closeModal: closeModal,
	            nameSpace: nameSpace
	        });
	    }
	});
	WorkManagerColumnsModal = connect(mapStateToWorkManagerColumnsModalProps, mapDispatchToWorkManagerColumnsModalProps)(WorkManagerColumnsModal);

	exports.default = WorkManagerColumnsModal;

/***/ },
/* 12 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _WorkManagerVelocityLineModalContent = __webpack_require__(13);

	var _WorkManagerVelocityLineModalContent2 = _interopRequireDefault(_WorkManagerVelocityLineModalContent);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerVelocityLineModalProps = function mapStateToWorkManagerVelocityLineModalProps(state, ownProps) {
	    return {
	        dataObject: _selectors2.default.getDataObject(state),
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerVelocityLineModalProps = function mapDispatchToWorkManagerVelocityLineModalProps(dispatch, ownProps) {
	    return {};
	};

	var WorkManagerVelocityLineModal = React.createClass({
	    displayName: 'WorkManagerVelocityLineModal',

	    propTypes: function propTypes() {
	        dataObject: React.PtopTypes.object.isRequired;
	    },

	    getInitialState: function getInitialState() {
	        var numOfSprintsToCalculate = 10;
	        var dataObject = this.props.dataObject;
	        var numOfSprintsToCalculateOnDataObject = dataObject.options && dataObject.options.numOfSprintsToCalculate;
	        var oldSprintsLessThan10 = dataObject && dataObject.oldSprints && dataObject.oldSprints.length < 10;

	        if (numOfSprintsToCalculateOnDataObject) {
	            numOfSprintsToCalculate = dataObject.options.numOfSprintsToCalculate;
	        } else if (oldSprintsLessThan10) {
	            numOfSprintsToCalculate = dataObject.oldSprints.length;
	        }

	        return {
	            numOfSprintsToCalculate: numOfSprintsToCalculate
	        };
	    },

	    render: function render() {
	        var self = this,
	            dataObject = this.props.dataObject,
	            numOfSprintsToCalculate = this.state.numOfSprintsToCalculate,
	            maxSprints = dataObject && dataObject.oldSprints && dataObject.oldSprints.length < 10 ? dataObject.oldSprints.length : 10,
	            nameSpace = this.props.nameSpace,
	            completedPointsFieldName = nameSpace ? nameSpace + 'Completed_Story_Points__c' : 'Completed_Story_Points__c',
	            velocityTotal = dataObject && dataObject.oldSprints ? dataObject.oldSprints.slice(0, numOfSprintsToCalculate).reduce(function (prevPoints, currSprint, idx) {
	            return prevPoints + (currSprint[completedPointsFieldName] || 0);
	        }, 0) : 0,
	            newVelocity = Math.round(velocityTotal / this.state.numOfSprintsToCalculate),
	            actualVelocity = dataObject.options && dataObject.options.averageVelocity ? dataObject.options.averageVelocity : newVelocity,
	            sprintNames = dataObject.oldSprints.map(function (sprint) {
	            return sprint.Name.substring(0, sprint.Name.indexOf('-'));
	        }),
	            sprintVelocities = dataObject.oldSprints.map(function (sprint) {
	            return sprint[completedPointsFieldName] || 0;
	        }),
	            averageSprintVelocities = _.range(numOfSprintsToCalculate).map(function (sprint) {
	            return newVelocity;
	        }),
	            updateNumOfSprintsToCalculate = function updateNumOfSprintsToCalculate(newNum) {
	            self.setState({ numOfSprintsToCalculate: newNum });
	        };

	        return React.createElement(_WorkManagerVelocityLineModalContent2.default, {
	            dataObject: dataObject,
	            maxSprints: maxSprints,
	            numOfSprintsToCalculate: numOfSprintsToCalculate,
	            sprintNames: sprintNames,
	            sprintVelocities: sprintVelocities,
	            averageSprintVelocities: averageSprintVelocities,
	            updateNumOfSprintsToCalculate: updateNumOfSprintsToCalculate
	        });
	    }
	});
	WorkManagerVelocityLineModal = connect(mapStateToWorkManagerVelocityLineModalProps, mapDispatchToWorkManagerVelocityLineModalProps)(WorkManagerVelocityLineModal);

	exports.default = WorkManagerVelocityLineModal;

/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerVelocityLineModalContentProps = function mapStateToWorkManagerVelocityLineModalContentProps(state, ownProps) {
	    return {
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerVelocityLineModalContentProps = function mapDispatchToWorkManagerVelocityLineModalContentProps(dispatch, ownProps) {
	    return {
	        toggleModal: function toggleModal(name) {
	            dispatch(_actionCreators2.default.toggleModal(name));
	        },
	        saveUserPreferenceAsJSON: function saveUserPreferenceAsJSON(columns, options, cb) {
	            dispatch(_actionCreators2.default.saveUserPreferenceAsJSON(columns, options, cb));
	        },
	        updateOptions: function updateOptions(options) {
	            dispatch(_actionCreators2.default.updateOptions(options));
	        }
	    };
	};

	var WorkManagerVelocityLineModalContent = React.createClass({
	    displayName: 'WorkManagerVelocityLineModalContent',

	    propTypes: function propTypes() {
	        return {
	            toggleModal: React.PropTypes.func.isRequired,
	            saveUserPreferenceAsJSON: React.PropTypes.func.isRequired,
	            updateOptions: React.PropTypes.func.isRequired,

	            dataObject: React.PropTypes.object.isRequired,
	            maxSprints: React.PropTypes.array.isRequired,
	            numOfSprintsToCalculate: React.PropTypes.number.isRequired,
	            sprintNames: React.PropTypes.array.isRequired,
	            sprintVelocities: React.PropTypes.array.isRequired,
	            averageSprintVelocities: React.PropTypes.array.isRequired,
	            updateNumOfSprintsToCalculate: React.PropTypes.number.isRequired
	        };
	    },

	    getInitialState: function getInitialState() {
	        return {
	            showVelocityLine: this.props.dataObject.options && this.props.dataObject.options.showVelocityLine ? this.props.dataObject.options.showVelocityLine : false,
	            averageVelocity: this.props.dataObject.options && this.props.dataObject.options.averageVelocity ? this.props.dataObject.options.averageVelocity : 0,
	            saving: false
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        var self = this,
	            maxSprints = this.props.maxSprints,
	            numOfSprintsToCalculate = this.props.numOfSprintsToCalculate,
	            updateNumOfSprintsToCalculate = this.props.updateNumOfSprintsToCalculate;

	        $("#slider-range-max").slider({
	            range: "max",
	            min: 1,
	            max: maxSprints,
	            value: numOfSprintsToCalculate,
	            slide: function slide(event, ui) {
	                updateNumOfSprintsToCalculate(ui.value);
	                self.setState({ averageVelocity: self.props.averageSprintVelocities[0] || 0, showVelocityLine: true });
	            }
	        });

	        // it is unadvisded to use forceUpdate, but cheating here b/c of jQuery / React mix
	        this.forceUpdate();
	    },

	    componentDidUpdate: function componentDidUpdate() {
	        var sprintVelocities = this.props.sprintVelocities,
	            sprintNames = this.props.sprintNames,
	            averageSprintVelocities = this.props.averageSprintVelocities,
	            numOfSprintsToCalculate = this.props.numOfSprintsToCalculate;

	        $('#sprintHistory').highcharts({
	            title: {
	                text: 'Sprint History',
	                align: 'center',
	                style: {
	                    'font-size': '11px'
	                }
	            },
	            chart: {
	                animation: false
	                //type: 'area'
	            },
	            xAxis: {
	                categories: sprintNames
	            },
	            legend: {
	                enabled: false
	            },
	            yAxis: {
	                gridLineWidth: 0,
	                title: {
	                    text: 'Points'
	                },
	                plotLines: [{
	                    value: 0,
	                    width: 1,
	                    color: '#808080'
	                }]
	            },
	            tooltip: {
	                formatter: function formatter() {
	                    return 'Velocity for <b>' + this.x + '</b> was <b>' + this.y + '</b> pts';
	                }
	            },
	            credits: {
	                enabled: false
	            },
	            series: [{
	                animation: false,
	                color: '#0070D2',
	                name: 'Sprint Velocity',
	                data: sprintVelocities,
	                dataLabels: {
	                    enabled: true
	                },
	                enableMouseTracking: false,
	                zoneAxis: 'x',
	                marker: {
	                    enabled: true,
	                    symbol: 'circle',
	                    radius: 2
	                },
	                zones: [{
	                    value: numOfSprintsToCalculate - 1
	                }, {
	                    dashStyle: 'dot',
	                    color: '#D8DDE6'
	                }]
	            }, {
	                //type:'line',
	                animation: false,
	                color: '#F7B15A',
	                name: 'Average Velocity',
	                data: averageSprintVelocities,
	                marker: {
	                    enabled: false
	                },
	                enableMouseTracking: false
	            }]
	        });
	    },

	    closeModal: function closeModal() {
	        $('.slds-modal').removeClass('slds-fade-in-open');
	        $('.slds-modal-backdrop').removeClass('slds-modal-backdrop--open');
	        this.props.toggleModal('velocityLine');
	    },

	    updateAverageVelocity: function updateAverageVelocity(e) {
	        var avgVelocityInt = parseInt(e.target.value, 10) || 0;
	        if (avgVelocityInt < 0) {
	            avgVelocityInt = 0;
	        }
	        this.setState({ averageVelocity: avgVelocityInt });
	    },

	    updateShowVelocityLineState: function updateShowVelocityLineState(e) {
	        this.setState({ showVelocityLine: !this.state.showVelocityLine });
	    },

	    onSave: function onSave(e) {
	        var self = this,
	            averageVelocity = this.state.averageVelocity || 0,
	            showVelocityLine = this.state.showVelocityLine,
	            columns = this.props.dataObject.columns,
	            numOfSprintsToCalculate = this.props.numOfSprintsToCalculate,
	            updatedOptions = _extends({}, this.props.dataObject.options, { averageVelocity: averageVelocity, showVelocityLine: showVelocityLine, numOfSprintsToCalculate: numOfSprintsToCalculate });

	        this.setState({ saving: true });

	        this.props.saveUserPreferenceAsJSON(columns, updatedOptions, function (err, result) {
	            if (err) {
	                self.setState({ saving: false });
	                console.error('WARNING: Failed to save User Preferences when updating the velocity line.  Error:' + event);
	            } else {
	                self.props.updateOptions(updatedOptions);
	                self.setState({ saving: false });
	                self.closeModal();
	            }
	        });
	    },

	    render: function render() {
	        var averageVelocity = this.state.averageVelocity,
	            showVelocityLine = this.state.showVelocityLine,
	            saving = this.state.saving,
	            averageSprintVelocities = this.props.averageSprintVelocities,
	            numOfSprintsToCalculate = this.props.numOfSprintsToCalculate,
	            updateShowVelocityLineState = this.updateShowVelocityLineState,
	            dataObject = this.props.dataObject,
	            updateAverageVelocity = this.updateAverageVelocity,
	            onSave = this.onSave,
	            closeModal = this.closeModal;

	        return React.createElement(
	            'div',
	            { id: 'modalVelocitySettings', 'aria-hidden': 'false', role: 'dialog', className: 'slds-modal' },
	            React.createElement(
	                'div',
	                { className: 'slds-modal__container' },
	                React.createElement(
	                    'div',
	                    { className: 'slds-modal__header' },
	                    React.createElement(
	                        'h2',
	                        { className: 'slds-text-heading--medium' },
	                        'Estimated Velocity Line Settings'
	                    ),
	                    React.createElement(
	                        'button',
	                        { className: 'slds-button slds-modal__close buttonCloseModal', onClick: closeModal },
	                        React.createElement(
	                            'svg',
	                            { 'aria-hidden': 'true', className: 'slds-button__icon slds-button__icon--large' },
	                            React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/action-sprite/svg/symbols.svg#close' })
	                        ),
	                        React.createElement(
	                            'span',
	                            { className: 'slds-assistive-text' },
	                            'Close'
	                        )
	                    )
	                ),
	                React.createElement(
	                    'div',
	                    { className: 'slds-modal__content' },
	                    React.createElement(
	                        'div',
	                        null,
	                        dataObject.oldSprints && dataObject.oldSprints.length > 0 ? React.createElement(
	                            'span',
	                            null,
	                            React.createElement('div', { id: 'sprintHistory', style: { height: "200px", marginBottom: "20px;" } }),
	                            React.createElement('div', { id: 'slider-range-max', style: { marginBottom: "15px", marginLeft: "90px", marginRight: "40px" } }),
	                            React.createElement(
	                                'div',
	                                { id: 'sprintHistoryInfo', className: 'slds-form-element' },
	                                'Your team averaged ',
	                                React.createElement(
	                                    'b',
	                                    null,
	                                    averageSprintVelocities[0] || 0,
	                                    ' story ',
	                                    averageSprintVelocities[0] === 1 ? 'point' : 'points'
	                                ),
	                                ' from the last ',
	                                React.createElement(
	                                    'b',
	                                    null,
	                                    numOfSprintsToCalculate,
	                                    ' ',
	                                    numOfSprintsToCalculate === 1 ? 'sprint' : 'sprints'
	                                ),
	                                '. Use the slider to adjust how many past sprints to consider or enter a custom override value below.'
	                            )
	                        ) : React.createElement(
	                            'div',
	                            { id: 'sprintHistoryEmpty' },
	                            'We dont have any sprint history for your team yet.'
	                        ),
	                        React.createElement(
	                            'div',
	                            { className: 'slds-form-element slds-m-top--small' },
	                            React.createElement(
	                                'label',
	                                { className: 'slds-checkbox--toggle slds-grid' },
	                                showVelocityLine ? React.createElement('input', { name: 'checkbox', type: 'checkbox', 'aria-describedby': 'toggle-desc', onClick: updateShowVelocityLineState, checked: true }) : React.createElement('input', { name: 'checkbox', type: 'checkbox', 'aria-describedby': 'toggle-desc', onClick: updateShowVelocityLineState }),
	                                React.createElement(
	                                    'span',
	                                    { id: 'toggle-desc', className: 'slds-checkbox--faux_container', 'aria-live': 'assertive', style: { cursor: 'pointer' } },
	                                    React.createElement('span', { className: 'slds-checkbox--faux' }),
	                                    React.createElement(
	                                        'span',
	                                        { className: showVelocityLine ? "slds-checkbox--on" : "slds-checkbox--off", style: { textAlign: 'center', display: 'block', color: showVelocityLine ? '#0070d2' : 'inherit' } },
	                                        showVelocityLine ? 'ON' : 'OFF'
	                                    )
	                                ),
	                                React.createElement(
	                                    'span',
	                                    { className: 'slds-form-element__label slds-m-left--x-small', style: { color: "inherit", fontSize: '14px' } },
	                                    'Show velocity line after ',
	                                    React.createElement('input', { type: 'number', id: 'averageVelocity', className: 'slds-input', maxlength: '2', style: { textAlign: "center", width: "60px" }, onChange: updateAverageVelocity, value: averageVelocity }),
	                                    ' story point',
	                                    averageVelocity & averageVelocity === 1 ? undefined : 's',
	                                    showVelocityLine ? ' *' : undefined
	                                )
	                            ),
	                            React.createElement(
	                                'span',
	                                { className: 'slds-form-element__help' },
	                                showVelocityLine ? '* To see the velocity line, make sure that you are sorted by the "Rank" column, there is no text in the search box, and there are no filters applied.' : undefined
	                            )
	                        )
	                    )
	                ),
	                React.createElement(
	                    'div',
	                    { className: 'slds-modal__footer' },
	                    React.createElement(
	                        'button',
	                        { className: 'slds-button slds-button--neutral buttonCloseModal', onClick: closeModal },
	                        'Cancel'
	                    ),
	                    React.createElement(
	                        'button',
	                        { id: 'modalVelocitySettingsButtonSave', className: 'slds-button slds-button--neutral slds-button--brand slds-button-space-left buttonCloseModal', disabled: saving, onClick: onSave },
	                        saving ? 'Saving...' : 'Save'
	                    )
	                )
	            )
	        );
	    }
	});

	WorkManagerVelocityLineModalContent = connect(mapStateToWorkManagerVelocityLineModalContentProps, mapDispatchToWorkManagerVelocityLineModalContentProps)(WorkManagerVelocityLineModalContent);

	exports.default = WorkManagerVelocityLineModalContent;

/***/ },
/* 14 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToSearchFieldProps = function mapStateToSearchFieldProps(state, ownProps) {
	    return {};
	};
	var mapDispatchToSearchFieldProps = function mapDispatchToSearchFieldProps(dispatch, ownProps) {
	    return {
	        onChange: function onChange(e) {
	            dispatch(_actionCreators2.default.updateSearchTerm(e.target.value));
	        }
	    };
	};

	var WorkManagerSearchField = React.createClass({
	    displayName: 'WorkManagerSearchField',

	    render: function render() {
	        var props = this.props,
	            onChange = props.onChange,
	            name = props.name,
	            id = props.id,
	            className = props.className,
	            placeholder = props.placeholder;

	        return React.createElement(_PRESENTATIONALCOMPONENTS2.default.TextField, { onChange: onChange, name: name, id: id, className: className, placeholder: placeholder });
	    }
	});
	WorkManagerSearchField = connect(mapStateToSearchFieldProps, mapDispatchToSearchFieldProps)(WorkManagerSearchField);

	exports.default = WorkManagerSearchField;

/***/ },
/* 15 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerOptionsButtonProps = function mapStateToWorkManagerOptionsButtonProps(state, ownProps) {
	    return {
	        dataObject: _selectors2.default.getDataObject(state),
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerOptionsButtonProps = function mapDispatchToWorkManagerOptionsButtonProps(dispatch, ownProps) {
	    return {
	        toggleModal: function toggleModal(name) {
	            dispatch(_actionCreators2.default.toggleModal(name));
	        }
	    };
	};

	var WorkManagerOptionsButton = React.createClass({
	    displayName: 'WorkManagerOptionsButton',

	    getInitialState: function getInitialState() {
	        return {
	            active: false,
	            optionsLeftOffset: 0
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        var optionsButton = $('#buttonListViewControls');
	        if (optionsButton) {
	            this.setState({ optionsLeftOffset: optionsButton.position().left });
	        }
	    },

	    handleButtonClick: function handleButtonClick(e) {
	        this.setState({ active: !this.state.active });
	    },

	    openColumnsModal: function openColumnsModal() {
	        this.handleButtonClick();
	        this.props.toggleModal('columns');
	    },

	    openVelocityLineModal: function openVelocityLineModal() {
	        this.handleButtonClick();
	        this.props.toggleModal('velocityLine');
	    },

	    render: function render() {
	        var options = this.props.dataObject && this.props.dataObject.options ? this.props.dataObject.options : {};
	        var showVelocityLine = options.showVelocityLine;
	        var velocityLineYellow = '#F7B15A';
	        var checkmarkIcon = React.createElement(
	            'span',
	            null,
	            React.createElement(
	                'svg',
	                { 'aria-hidden': 'true', className: 'slds-button__icon', style: { fill: velocityLineYellow } },
	                React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#success' })
	            ),
	            React.createElement(
	                'span',
	                { style: { color: velocityLineYellow } },
	                ' ON'
	            )
	        );

	        return React.createElement(
	            'div',
	            { className: 'slds-m-left--large', role: 'group' },
	            React.createElement(
	                'button',
	                { id: 'buttonListViewControls', className: 'slds-button slds-button--icon-more slds-shrink-none', 'aria-haspopup': 'true', onClick: this.handleButtonClick },
	                React.createElement(
	                    'svg',
	                    { 'aria-hidden': 'true', className: 'slds-button__icon' },
	                    React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#settings' })
	                ),
	                React.createElement(
	                    'span',
	                    { className: 'slds-assistive-text' },
	                    'Settings'
	                ),
	                React.createElement(
	                    'svg',
	                    { 'aria-hidden': 'true', className: 'slds-button__icon slds-button__icon--x-small' },
	                    React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/utility-sprite/svg/symbols.svg#down' })
	                )
	            ),
	            this.state.active ? React.createElement(
	                'div',
	                { id: 'dropdownListViewControls', className: 'slds-dropdown slds-dropdown--left slds-dropdown--menu', style: { left: this.state.optionsLeftOffset } },
	                React.createElement(
	                    'ul',
	                    { className: 'slds-dropdown__list', role: 'menu' },
	                    React.createElement(
	                        'li',
	                        { id: 'selectFieldsToDisplay', href: '#', className: 'slds-dropdown__item' },
	                        React.createElement(
	                            'a',
	                            { href: '#', className: 'slds-truncate', role: 'menuitemradio', onClick: this.openColumnsModal },
	                            'Columns...'
	                        )
	                    ),
	                    React.createElement(
	                        'li',
	                        { id: 'velocityLineSettings', href: '#', className: 'slds-dropdown__item' },
	                        React.createElement(
	                            'a',
	                            { href: '#', className: 'slds-truncate', role: 'menuitemradio', onClick: this.openVelocityLineModal },
	                            'Velocity Line... ',
	                            showVelocityLine ? checkmarkIcon : undefined
	                        )
	                    )
	                )
	            ) : undefined
	        );
	    }
	}),
	    WorkManagerOptionsButton = connect(mapStateToWorkManagerOptionsButtonProps, mapDispatchToWorkManagerOptionsButtonProps)(WorkManagerOptionsButton);

	exports.default = WorkManagerOptionsButton;

/***/ },
/* 16 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerFullscreenButtonProps = function mapStateToWorkManagerFullscreenButtonProps(state, ownProps) {
	    return {
	        isFullscreen: state.isFullscreen,
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerFullscreenButtonProps = function mapDispatchToWorkManagerFullscreenButtonProps(dispatch, ownProps) {
	    return {
	        updateIsFullscreen: function updateIsFullscreen(bool) {
	            dispatch(_actionCreators2.default.updateIsFullscreen(bool));
	        }
	    };
	};

	var WorkManagerFullscreenButton = React.createClass({
	    displayName: 'WorkManagerFullscreenButton',

	    propTypes: function propTypes() {
	        return {
	            fullscreenId: React.PropTypes.string.isRequired,
	            nameSpace: React.PropTypes.string
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        var fullscreenHandler = function () {
	            this.props.isFullscreen ? this.props.updateIsFullscreen(false) : this.props.updateIsFullscreen(true);
	        }.bind(this);

	        document.addEventListener('webkitfullscreenchange', fullscreenHandler);
	        document.addEventListener('mozfullscreenchange', fullscreenHandler);
	        document.addEventListener('fullscreenchange', fullscreenHandler);
	        document.addEventListener('MSFullscreenChange', fullscreenHandler);
	    },

	    componentWillUnmount: function componentWillUnmount() {
	        document.removeEventListener('webkitfullscreenchange', fullscreenHandler);
	        document.removeEventListener('mozfullscreenchange', fullscreenHandler);
	        document.removeEventListener('fullscreenchange', fullscreenHandler);
	        document.removeEventListener('MSFullscreenChange', fullscreenHandler);
	        this.props.updateIsFullscreen(false);
	    },

	    launchIntoFullscreen: function launchIntoFullscreen(element, e) {
	        if (element.requestFullscreen) {
	            element.requestFullscreen();
	        } else if (element.mozRequestFullScreen) {
	            element.mozRequestFullScreen();
	        } else if (element.webkitRequestFullscreen) {
	            element.webkitRequestFullscreen();
	        } else if (element.msRequestFullscreen) {
	            element.msRequestFullscreen();
	        }
	    },

	    closeFullscreen: function closeFullscreen() {
	        if (document.exitFullscreen) {
	            document.exitFullscreen();
	        } else if (document.mozCancelFullScreen) {
	            document.mozCancelFullScreen();
	        } else if (document.webkitCancelFullScreen) {
	            document.webkitCancelFullScreen();
	        } else if (document.msExitFullscreen) {
	            document.msExitFullscreen();
	        }
	    },

	    handleFullscreenClick: function handleFullscreenClick(e) {
	        var fullscreenElement = document.getElementById(this.props.fullscreenId);

	        var autocompleteEls = document.querySelectorAll('ul.ui-autocomplete');
	        var autocompleteLen = autocompleteEls.length;

	        for (var i = 0; i < autocompleteLen; i++) {
	            fullscreenElement.appendChild(autocompleteEls[i]);
	        }

	        !this.props.isFullscreen ? this.launchIntoFullscreen(fullscreenElement, e) : this.closeFullscreen();
	    },

	    render: function render() {
	        return React.createElement(_PRESENTATIONALCOMPONENTS2.default.FullscreenButton, { onClick: this.handleFullscreenClick, active: this.props.isFullscreen, 'class': "slds-button-space-left", nameSpace: this.props.nameSpace });
	    }
	});

	WorkManagerFullscreenButton = connect(mapStateToWorkManagerFullscreenButtonProps, mapDispatchToWorkManagerFullscreenButtonProps)(WorkManagerFullscreenButton);

	exports.default = WorkManagerFullscreenButton;

/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _ChartsSidePanel = __webpack_require__(18);

	var _ChartsSidePanel2 = _interopRequireDefault(_ChartsSidePanel);

	var _FilterSidePanel = __webpack_require__(24);

	var _FilterSidePanel2 = _interopRequireDefault(_FilterSidePanel);

	var _FilterSidePanelTestHeader = __webpack_require__(25);

	var _FilterSidePanelTestHeader2 = _interopRequireDefault(_FilterSidePanelTestHeader);

	var _MassEditSidePanel = __webpack_require__(26);

	var _MassEditSidePanel2 = _interopRequireDefault(_MassEditSidePanel);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerSidePanelProps = function mapStateToWorkManagerSidePanelProps(state, ownProps) {
	    return {
	        sidePanel: state.sidePanel,
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerSidePanelProps = function mapDispatchToWorkManagerSidePanelProps(dispatch, ownProps) {
	    return {};
	};

	var WorkManagerSidePanel = React.createClass({
	    displayName: 'WorkManagerSidePanel',

	    propTypes: function propTypes() {
	        return {
	            sidePanel: React.PropTypes.string.isRequired,
	            dataObject: React.PropTypes.object.isRequired,
	            recordsToDisplay: React.PropTypes.array.isRequired
	        };
	    },

	    createSidePanel: function createSidePanel(whichPanel, visibleRecords, allColumns) {
	        if (whichPanel === 'filter') {
	            var filterTest = false;
	            return !filterTest ? React.createElement(_FilterSidePanel2.default, null) : React.createElement(
	                'div',
	                null,
	                React.createElement(_FilterSidePanelTestHeader2.default, null),
	                React.createElement(_FilterSidePanel2.default, null)
	            );
	        } else if (whichPanel === 'massEdit') {
	            return React.createElement(_MassEditSidePanel2.default, null);
	        } else if (whichPanel === 'charts') {
	            var teamId = this.props.dataObject.team && this.props.dataObject.team.Id ? this.props.dataObject.team.Id : ADM_BACKLOG_PAGE_VARS.teamId;
	            return React.createElement(_ChartsSidePanel2.default, { visibleRecords: visibleRecords, allSprints: this.props.dataObject.allSprints, oldSprints: this.props.dataObject.oldSprints, currentSprint: this.props.dataObject.currentSprint, teamId: teamId, nameSpace: this.props.nameSpace });
	        }
	    },

	    render: function render() {
	        return this.props.sidePanel !== 'none' ? React.createElement(
	            'div',
	            { id: 'sideContainer' },
	            this.createSidePanel(this.props.sidePanel, this.props.recordsToDisplay, this.props.dataObject.allColumns)
	        ) : React.createElement('div', null);
	    }
	});
	WorkManagerSidePanel = connect(mapStateToWorkManagerSidePanelProps, mapDispatchToWorkManagerSidePanelProps)(WorkManagerSidePanel);

	exports.default = WorkManagerSidePanel;

/***/ },
/* 18 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _AllocationsChart = __webpack_require__(19);

	var _AllocationsChart2 = _interopRequireDefault(_AllocationsChart);

	var _RecordTypeChart = __webpack_require__(20);

	var _RecordTypeChart2 = _interopRequireDefault(_RecordTypeChart);

	var _ChartVelocity = __webpack_require__(21);

	var _ChartVelocity2 = _interopRequireDefault(_ChartVelocity);

	var _WeeklyThroughputChart = __webpack_require__(22);

	var _WeeklyThroughputChart2 = _interopRequireDefault(_WeeklyThroughputChart);

	var _SprintBurndownChart = __webpack_require__(23);

	var _SprintBurndownChart2 = _interopRequireDefault(_SprintBurndownChart);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

	var ChartsSidePanel = React.createClass({
	    displayName: 'ChartsSidePanel',

	    propTypes: {
	        visibleRecords: React.PropTypes.array.isRequired,
	        allSprints: React.PropTypes.array.isRequired,
	        oldSprints: React.PropTypes.array.isRequired,
	        currentSprint: React.PropTypes.object,
	        teamId: React.PropTypes.string.isRequired,
	        nameSpace: React.PropTypes.string.isRequired
	    },

	    getInitialState: function getInitialState() {
	        var openGroup = '';
	        if (this.props.currentSprint && this.props.currentSprint.Name) {
	            openGroup = this.props.currentSprint.Name;
	        }
	        return {
	            openGroup: openGroup
	        };
	    },

	    handleHeaderClick: function handleHeaderClick(label) {
	        var openGroupState = this.state.openGroup === label ? '' : label;
	        this.setState({ openGroup: openGroupState });
	    },

	    render: function render() {
	        var that = this;
	        var standardChartsLabel = 'Standard Charts';
	        var chartsOfVisibleWorkLabel = "Charts of Visible Work";

	        var visibleWorkCharts = React.createElement(
	            'div',
	            null,
	            React.createElement(
	                'div',
	                { className: 'chart' },
	                React.createElement(_AllocationsChart2.default, { visibleRecords: this.props.visibleRecords })
	            ),
	            React.createElement(
	                'div',
	                { className: 'chart' },
	                React.createElement(_RecordTypeChart2.default, { visibleRecords: this.props.visibleRecords })
	            )
	        );

	        var standardCharts = React.createElement(
	            'div',
	            null,
	            React.createElement(
	                'div',
	                { className: 'chart' },
	                React.createElement(_ChartVelocity2.default, { maxSprints: 4, oldSprints: this.props.oldSprints })
	            ),
	            React.createElement(
	                'div',
	                { className: 'chart' },
	                React.createElement(_WeeklyThroughputChart2.default, { numWeeks: 4, teamId: this.props.teamId })
	            )
	        );

	        var getSprintsForBurndown = function getSprintsForBurndown() {
	            var result = [];
	            that.props.currentSprint ? result.push(that.props.currentSprint) : null;
	            that.props.oldSprints ? result.push.apply(result, _toConsumableArray(that.props.oldSprints)) : null;
	            return result;
	        };

	        var sprintsForBurndown = getSprintsForBurndown();

	        var content = React.createElement(
	            'div',
	            null,
	            React.createElement(_PRESENTATIONALCOMPONENTS2.default.ChartGroup, { label: chartsOfVisibleWorkLabel, content: visibleWorkCharts, handleHeaderClick: this.handleHeaderClick.bind(this, chartsOfVisibleWorkLabel), open: chartsOfVisibleWorkLabel === this.state.openGroup, nameSpace: this.props.nameSpace }),
	            React.createElement(_PRESENTATIONALCOMPONENTS2.default.ChartGroup, { label: standardChartsLabel, content: standardCharts, handleHeaderClick: this.handleHeaderClick.bind(this, standardChartsLabel), open: standardChartsLabel === this.state.openGroup, nameSpace: this.props.nameSpace }),
	            sprintsForBurndown.map(function (sprint, idx) {
	                var burndownChart = React.createElement(_SprintBurndownChart2.default, { sprintId: sprint.Id });
	                var sprintLabel = sprint.Name;
	                return React.createElement(_PRESENTATIONALCOMPONENTS2.default.ChartGroup, { label: sprintLabel, content: burndownChart, handleHeaderClick: this.handleHeaderClick.bind(this, sprintLabel), open: sprintLabel === this.state.openGroup, key: 'sprintwithindex' + idx, nameSpace: this.props.nameSpace });
	            }.bind(this))
	        );

	        return React.createElement(_PRESENTATIONALCOMPONENTS2.default.SidePanel, { id: 'boxCharts', content: content, padding: false });
	    }
	});

	exports.default = ChartsSidePanel;

/***/ },
/* 19 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToAllocationsChartProps = function mapStateToAllocationsChartProps(state, ownProps) {
	    return {};
	};
	var mapDispatchToAllocationsChartProps = function mapDispatchToAllocationsChartProps(dispatch, ownProps) {
	    return {};
	};

	var AllocationsChart = React.createClass({
	    displayName: 'AllocationsChart',

	    propTypes: function propTypes() {
	        return {
	            visibleRecords: React.PropTypes.array.isRequired,
	            additionalFilters: React.PropTypes.string
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        var visibleRecords = this.props.visibleRecords;
	        var additionalFilters = this.props.additionalFilters;
	        var allottedUsers = [];
	        var allottedData = [];
	        var totalStoryPoints = 0;
	        var groupedRecordsByAssigneeId = _.groupBy(visibleRecords, 'Assignee_id');

	        Object.keys(groupedRecordsByAssigneeId).forEach(function (id) {
	            allottedUsers.push(groupedRecordsByAssigneeId[id][0].Assignee_value);
	            var thisUsersPoints = 0;
	            groupedRecordsByAssigneeId[id].forEach(function (record) {
	                if (record.Points_value) {
	                    thisUsersPoints += record.Points_value;
	                }
	            });
	            allottedData.push(thisUsersPoints);
	        });

	        totalStoryPoints = allottedData.reduce(function (prev, curr) {
	            return prev + curr;
	        }, 0);

	        if (totalStoryPoints > 0) {
	            var chartTitle = additionalFilters ? 'Sprint Allocation (' + totalStoryPoints + ' Points)' : 'Allocation (' + totalStoryPoints + ' Points)';
	            var chartHeight = 100 + allottedUsers.length * 30;
	            $('#boxCharts div#allocationChart').css('height', 'auto').empty().highcharts({ // TODO: Height needs to differ based on size of people (20 pixel per person?)
	                chart: {
	                    type: 'bar',
	                    width: 300,
	                    height: chartHeight
	                },
	                title: {
	                    text: chartTitle,
	                    style: {
	                        fontSize: '12px'
	                    }
	                },
	                xAxis: {
	                    categories: allottedUsers,
	                    title: {
	                        text: null
	                    }
	                },
	                yAxis: {
	                    gridLineWidth: 0,
	                    min: 0,
	                    title: {
	                        text: null
	                    },
	                    labels: {
	                        enabled: false
	                    }
	                },
	                tooltip: {
	                    enabled: false
	                },
	                plotOptions: {
	                    bar: {
	                        dataLabels: {
	                            enabled: true
	                        }
	                    }
	                },
	                legend: {
	                    enabled: false
	                },
	                credits: {
	                    enabled: false
	                },
	                series: [{
	                    name: 'Story Points',
	                    data: allottedData,
	                    color: '#0070D2',
	                    enableMouseTracking: false

	                }]
	            });
	        }
	    },

	    render: function render() {
	        return React.createElement('div', { id: 'allocationChart' });
	    }
	});

	AllocationsChart = connect(mapStateToAllocationsChartProps, mapDispatchToAllocationsChartProps)(AllocationsChart);

	exports.default = AllocationsChart;

/***/ },
/* 20 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToRecordTypeChartProps = function mapStateToRecordTypeChartProps(state, ownProps) {
	    return {};
	};
	var mapDispatchToRecordTypeChartProps = function mapDispatchToRecordTypeChartProps(dispatch, ownProps) {
	    return {};
	};

	var RecordTypeChart = React.createClass({
	    displayName: 'RecordTypeChart',

	    propTypes: function propTypes() {
	        return {
	            visibleRecords: React.PropTypes.array.isRequired,
	            additionalFilter: React.PropTypes.string
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        // TODO - MAKE SURE THAT ITS OKAY TO NOT INCLUDE ADDITIONALFILTERS //
	        var additionalFilters = this.props.additionalFilters;
	        var visibleRecords = this.props.visibleRecords;
	        var bugCount = 0,
	            storyCount = 0,
	            investigationCount = 0;

	        visibleRecords.forEach(function (record) {
	            if (record['Record Type_value'] === 'Bug') {
	                bugCount += 1;
	            } else if (record['Record Type_value'] === 'User Story') {
	                storyCount += 1;
	            } else if (record['Record Type_value'] === 'Investigation') {
	                investigationCount += 1;
	            }
	        });

	        var totalCount = bugCount + storyCount + investigationCount;

	        //$('.sideContainerBox').hide();
	        //$('#boxCharts').show();
	        if ($('#boxCharts').is(':visible')) {
	            $('#boxCharts > #chartTitleVisibleWork').text('Charts based on visible work');

	            if (totalCount == 0) {
	                var nodata = '<div class="nodata">No data to display</div>';
	                $('#boxCharts div#recordTypeChart').css('height', '200px').empty().append(nodata);
	            } else {
	                var chartTitle = additionalFilters ? 'Work in Sprint (' + totalCount + ' Records)' : 'Visible Work (' + totalCount + ')';
	                $('#boxCharts div#recordTypeChart').css('height', 'auto').empty().highcharts({
	                    chart: {
	                        type: 'pie',
	                        width: 300,
	                        height: 200
	                    },
	                    title: {
	                        text: chartTitle,
	                        style: {
	                            fontSize: '12px'
	                        }
	                    },
	                    tooltip: {
	                        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
	                    },
	                    plotOptions: {
	                        pie: {
	                            allowPointSelect: true,
	                            cursor: 'pointer',
	                            dataLabels: {
	                                enabled: true,
	                                format: '{point.y} {point.name}'
	                            }
	                        }
	                    },
	                    credits: {
	                        enabled: false
	                    },
	                    series: [{
	                        name: "Types",
	                        colorByPoint: true,
	                        enableMouseTracking: false,
	                        data: [{
	                            color: '#58AE39',
	                            name: "Bugs",
	                            y: bugCount
	                        }, {
	                            color: '#0070D2',
	                            name: "Stories",
	                            y: storyCount
	                        }, {
	                            color: '#EB572D',
	                            name: "Investigations",
	                            y: investigationCount
	                        }]
	                    }]
	                });
	            }
	        }
	    },

	    render: function render() {
	        return React.createElement('div', { id: 'recordTypeChart' });
	    }
	});

	RecordTypeChart = connect(mapStateToRecordTypeChartProps, mapDispatchToRecordTypeChartProps)(RecordTypeChart);

	exports.default = RecordTypeChart;

/***/ },
/* 21 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToChartVelocity2Props = function mapStateToChartVelocity2Props(state, ownProps) {
	    return {
	        dataObject: state.dataObject,
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToChartVelocity2Props = function mapDispatchToChartVelocity2Props(dispatch, ownProps) {
	    return {};
	};

	var ChartVelocity2 = React.createClass({
	    displayName: 'ChartVelocity2',

	    propTypes: function propTypes() {
	        return {
	            maxSprints: React.PropTypes.number.isRequired,
	            oldSprints: React.PropTypes.array.isRequired,
	            dataObject: React.PropTypes.object.isRequired
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        var sprintNames = [];
	        var sprintVelocities = [];
	        var sprintAverage = [];
	        var oldSprints = this.props.oldSprints;
	        var dataObject = this.props.dataObject;

	        if (!oldSprints || oldSprints.length === 0) {
	            $("#velocityChart").append('<div class="nodata">No recent sprints have been completed.</div>');
	            return;
	        }

	        var sprintSort = function sprintSort(a, b) {
	            var startDateField = nameSpace ? nameSpace + 'Start_Date__c' : 'Start_Date__c';
	            var an = a[startDateField].toLowerCase(),
	                bn = b[startDateField].toLowerCase();
	            return an > bn ? -1 : 1;
	        };

	        oldSprints.sort(sprintSort); // Sort sprint data

	        $.each(oldSprints, function (index, sprint) {
	            if (index < 10) {
	                var completedPointsFieldName = nameSpace ? nameSpace + 'Completed_Story_Points__c' : 'Completed_Story_Points__c';
	                var completedPoints = sprint[completedPointsFieldName] || 0;
	                sprintNames.push(sprint.Name.substring(0, sprint.Name.indexOf('-')));
	                sprintVelocities.push(completedPoints);
	                sprintAverage.push(dataObject.options.averageVelocity);
	            }
	        });

	        var maxSprints = oldSprints.length < maxSprints ? oldSprints.length : this.props.maxSprints;

	        var newVelocity = 0;
	        for (var i = 0, len = maxSprints; i < len; i++) {
	            newVelocity += sprintVelocities[i];
	        }
	        newVelocity = Math.round(newVelocity / maxSprints);

	        var sprintAverage = [];
	        for (i = 0; i < maxSprints; i++) {
	            sprintAverage.push(newVelocity);
	        }

	        $('#velocityChart').empty().highcharts({
	            chart: {
	                width: 300,
	                height: 199
	                //animation: false
	            },
	            title: {
	                text: 'Sprint History',
	                align: 'center',
	                style: {
	                    'font-size': '11px'
	                }
	            },
	            xAxis: {
	                categories: sprintNames
	            },
	            legend: {
	                enabled: false
	            },
	            yAxis: {
	                gridLineWidth: 0,
	                title: {
	                    text: 'Points'
	                },
	                plotLines: [{
	                    value: 0,
	                    width: 1,
	                    color: '#808080'
	                }]
	            },
	            credits: {
	                enabled: false
	            },
	            series: [{
	                animation: false,
	                color: '#0070D2',
	                name: 'Sprint Velocity',
	                data: sprintVelocities.slice(0, maxSprints),
	                dataLabels: {
	                    enabled: true
	                },
	                //enableMouseTracking: false,
	                zoneAxis: 'x',
	                marker: {
	                    enabled: true,
	                    symbol: 'circle',
	                    radius: 2
	                },
	                zones: [{
	                    value: maxSprints - 1
	                }, {
	                    dashStyle: 'dot',
	                    color: '#D8DDE6'
	                }],
	                tooltip: {
	                    formatter: function formatter() {
	                        return 'Velocity for <b>' + this.x + '</b> was <b>' + this.y + '</b> pts';
	                    }
	                }
	            }, {
	                //type:'line',
	                animation: false,
	                color: '#F7B15A',
	                name: 'Average Velocity',
	                data: sprintAverage.slice(0, maxSprints),
	                marker: {
	                    enabled: false
	                },
	                tooltip: {
	                    formatter: function formatter() {
	                        return 'Average Velocity <b>' + this.y + '</b> pts';
	                    }
	                }
	                //enableMouseTracking: false
	            }]
	        });
	    },

	    render: function render() {
	        return React.createElement('div', { id: 'velocityChart' });
	    }
	});

	ChartVelocity2 = connect(mapStateToChartVelocity2Props, mapDispatchToChartVelocity2Props)(ChartVelocity2);

	exports.default = ChartVelocity2;

/***/ },
/* 22 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWeeklyThroughputChartProps = function mapStateToWeeklyThroughputChartProps(state, ownProps) {
	    return {};
	};
	var mapDispatchToWeeklyThroughputChartProps = function mapDispatchToWeeklyThroughputChartProps(dispatch, ownProps) {
	    return {
	        getThroughputChart: function getThroughputChart(numWeeks, teamId, cb) {
	            dispatch(_actionCreators2.default.getThroughputChart(numWeeks, teamId, cb));
	        }
	    };
	};

	var WeeklyThroughputChart = React.createClass({
	    displayName: 'WeeklyThroughputChart',

	    propTypes: function propTypes() {
	        return {
	            numWeeks: React.PropTypes.number.isRequired,
	            teamId: React.PropTypes.string.isRequired
	        };
	    },

	    getInitialState: function getInitialState() {
	        return {
	            loading: false
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        this.props.getThroughputChart(this.props.numWeeks, this.props.teamId, this.getThroughputChartCallback);
	    },

	    getThroughputChartCallback: function getThroughputChartCallback(err, result) {
	        if (err) {
	            console.error('there was an error');
	            return;
	        }

	        // var chartObject = JSON.parse(result);
	        var chartObject = result;
	        console.log(chartObject);

	        if (chartObject.xAxis.categories.length > 0) {
	            $('#throughputChart').highcharts({
	                chart: {
	                    width: 300,
	                    height: 299,
	                    //animation: false,
	                    type: 'column'
	                },
	                title: {
	                    text: 'Weekly Throughput',
	                    align: 'center',
	                    style: {
	                        'font-size': '11px'
	                    }
	                },
	                xAxis: {
	                    categories: chartObject.xAxis.categories.slice(0, 4)
	                },
	                yAxis: {
	                    gridLineWidth: 0,
	                    min: 0,
	                    title: {
	                        text: 'Items Closed'
	                    },
	                    stackLabels: {
	                        enabled: true,
	                        style: {
	                            fontWeight: 'bold'
	                        }
	                    }
	                },
	                legend: {
	                    enabled: false,
	                    align: 'center',
	                    verticalAlign: 'bottom',
	                    floating: true,
	                    backgroundColor: Highcharts.theme && Highcharts.theme.background2 || 'white',
	                    borderColor: '#CCC',
	                    borderWidth: 1,
	                    shadow: false,
	                    style: {
	                        'font-size': '10px'
	                    }
	                },
	                tooltip: {
	                    headerFormat: '<b>{point.x}</b><br/>',
	                    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
	                },
	                plotOptions: {
	                    column: {
	                        stacking: 'normal',
	                        dataLabels: {
	                            enabled: true,
	                            color: Highcharts.theme && Highcharts.theme.dataLabelsColor || 'white',
	                            style: {
	                                textShadow: '0 0 3px black'
	                            }
	                        }
	                    }
	                },
	                series: [{
	                    name: 'Bugs',
	                    data: chartObject.seriesList[0].data.slice(0, 4),
	                    color: '#58AE39'
	                }, {
	                    name: 'Investigations',
	                    data: chartObject.seriesList[2].data.slice(0, 4),
	                    color: '#EB572D'
	                }, {
	                    name: 'User Stories',
	                    data: chartObject.seriesList[1].data.slice(0, 4),
	                    color: '#0070D2'
	                }],
	                credits: {
	                    enabled: false
	                }
	            });
	        } else {
	            var nodata = '<div class="nodata">No data to display</div>';
	            $('#throughputChart').append(nodata);
	        }
	    },

	    render: function render() {
	        return React.createElement(
	            'div',
	            { id: 'throughputChart' },
	            React.createElement(
	                'div',
	                { className: 'slds-spinner--large', style: { margin: "0px auto" } },
	                React.createElement('img', { src: '/resource/SLDS091/assets/images/spinners/slds_spinner_brand.gif', alt: 'Loading...' })
	            )
	        );
	    }
	});

	WeeklyThroughputChart = connect(mapStateToWeeklyThroughputChartProps, mapDispatchToWeeklyThroughputChartProps)(WeeklyThroughputChart);

	exports.default = WeeklyThroughputChart;

/***/ },
/* 23 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToSprintBurndownChartProps = function mapStateToSprintBurndownChartProps(state, ownProps) {
	    return {
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToSprintBurndownChartProps = function mapDispatchToSprintBurndownChartProps(dispatch, ownProps) {
	    return {
	        getSprintChart: function getSprintChart(chartId, cb) {
	            dispatch(_actionCreators2.default.getSprintChart(chartId, cb));
	        }
	    };
	};

	var SprintBurndownChart = React.createClass({
	    displayName: 'SprintBurndownChart',

	    propTypes: function propTypes() {
	        return {
	            sprintId: React.PropTypes.string.isRequired
	        };
	    },

	    getInitialState: function getInitialState() {
	        return {
	            loading: false,
	            error: false
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        this.props.getSprintChart(this.props.sprintId, this.getSprintChartCallback);
	    },

	    getSprintChartCallback: function getSprintChartCallback(err, result) {
	        if (err) {
	            this.setState({ error: true });
	            return;
	        }

	        var chartObject = result;
	        var sprintId = this.props.sprintId;

	        if (chartObject.xAxis.categories.length > 0) {
	            // $('#boxCharts div[data-id="' + sprintId + '"]').closest('.chartGroup').find('div.chart').empty().show().highcharts({
	            $('#sprintBurndown').highcharts({
	                chart: {
	                    width: 300,
	                    height: 250
	                },
	                title: {
	                    text: 'Sprint Burndown',
	                    style: {
	                        fontSize: '12px'
	                    }
	                },
	                legend: {
	                    itemStyle: {
	                        fontSize: '10px'
	                    }
	                },
	                xAxis: {
	                    categories: chartObject.xAxis.categories
	                },
	                yAxis: {
	                    gridLineWidth: 0,
	                    title: {
	                        text: null
	                    },
	                    min: 0
	                },
	                tooltip: {
	                    formatter: function formatter() {
	                        return this.y + ' points';
	                    }
	                },
	                series: [{
	                    name: "Ideal Burndown",
	                    dashStyle: "Solid",
	                    data: chartObject.seriesList[0].data,
	                    color: '#F7B15A',
	                    marker: { enabled: false },
	                    enableMouseTracking: false
	                }, {
	                    name: "Real Burndown",
	                    data: chartObject.seriesList[1].data,
	                    marker: { enabled: false },
	                    color: '#0070D2',
	                    dashStyle: 'solid',
	                    zoneAxis: 'x',
	                    zones: [{
	                        value: chartObject.xAxis.futureIndex
	                    }, {
	                        dashStyle: 'dot'
	                    }]
	                }],
	                credits: {
	                    enabled: false
	                }
	            });
	        } else {
	            var nodata = '<div class="nodata">No data to display</div>';
	            $('#boxCharts div[data-id="' + sprintId + '"]').closest('.chartGroup').find('div.chart').empty().show().append(nodata);
	        }
	    },

	    render: function render() {
	        return this.state.error ? React.createElement(
	            'div',
	            { className: 'chart' },
	            React.createElement(
	                'div',
	                { className: 'nodata' },
	                'Error loading chart'
	            )
	        ) : React.createElement(
	            'div',
	            { id: 'sprintBurndown' },
	            React.createElement(
	                'div',
	                { className: 'slds-spinner--small', style: { margin: "0px auto" } },
	                React.createElement('img', { src: '/resource/' + this.props.nameSpace + 'SLDS091/assets/images/spinners/slds_spinner_brand.gif', alt: 'Loading...' })
	            )
	        );
	    }
	});

	SprintBurndownChart = connect(mapStateToSprintBurndownChartProps, mapDispatchToSprintBurndownChartProps)(SprintBurndownChart);

	exports.default = SprintBurndownChart;

/***/ },
/* 24 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToFilterSidePanelProps = function mapStateToFilterSidePanelProps(state, ownProps) {
	    return {
	        dataObject: _selectors2.default.getDataObject(state),
	        records: _selectors2.default.getRecordsFromDataObject(state),
	        filters: _selectors2.default.getTeamFilters(state)
	    };
	};
	var mapDispatchToFilterSidePanelProps = function mapDispatchToFilterSidePanelProps(dispatch, ownProps) {
	    return {
	        updateFiltersAndSavePreferences: function updateFiltersAndSavePreferences(filterString, clearFilters) {
	            dispatch(_actionCreators2.default.updateFiltersAndSavePreferences(filterString, clearFilters));
	        }
	    };
	};

	var FilterSidePanel = React.createClass({
	    displayName: 'FilterSidePanel',

	    propTypes: {
	        dataObject: React.PropTypes.object.isRequired,
	        updateFiltersAndSavePreferences: React.PropTypes.func.isRequired,
	        filters: React.PropTypes.string.isRequired
	    },

	    createValueForFilterCheckbox: function createValueForFilterCheckbox(recordProp, value) {
	        if (!value && value !== 0) {
	            value = null;
	        }
	        var returnVal = 'item-';
	        if (recordProp === 'Status_value') {
	            return returnVal + 'status-' + (value ? value.toString().replace(/ +/g, '').toLowerCase() : undefined);
	        } else if (recordProp === 'Points_value') {
	            return returnVal + 'story_points-' + value;
	        }
	    },

	    determineOptionsByFilter: function determineOptionsByFilter(label, column, recordIds, recordsObj, filters) {
	        if (!column.filterable) {
	            console.warn('Cannot filter column: ', column, ' since it is not filterable');
	            return;
	        }

	        if (label === 'Status' || label === 'Points') {
	            return this.makeFilterCheckboxesFromUniqueProp(label + '_value');
	        } else {
	            var labelProp = label + '_value';
	            var valProp = label + '_id';
	            return this.makeFilterCheckboxes(valProp, labelProp, recordIds, recordsObj, filters, label);
	        }
	    },

	    makeFilterCheckboxes: function makeFilterCheckboxes(valProp, labelProp, recordIds, recordsObj, filters, label) {
	        if (!valProp || !labelProp || !recordIds || !recordsObj) {
	            console.error('went to create checkboxes but there was no valProp, labelProp, recordIds or recordsObj: ', valProp, labelProp, recordIds, recordsObj);
	        }

	        var allVals = [];
	        var filterObjects = [];

	        recordIds.forEach(function (recordId) {
	            if (!recordsObj[recordId] || !recordsObj[recordId][valProp] || !recordsObj[recordId][labelProp] || allVals.indexOf(recordsObj[recordId][valProp]) !== -1) {
	                return;
	            } else {
	                var record = recordsObj[recordId];
	                var val = record[valProp];
	                var label = record[labelProp];

	                filterObjects.push({ val: val, label: label });
	                allVals.push(val);
	            }
	        });

	        var filterList = _.sortBy(filterObjects, 'label');
	        if (label === 'Sprint') {
	            filterList.reverse();
	        }
	        // TODO - Ideally this should be added to the "column" object rather than hardcoded.
	        if (['Sprint', 'Assignee', 'QA Engineer', 'Kanban State', 'Points', 'Epic', 'Found In Build', 'Scheduled Build'].indexOf(label) > -1) {
	            filterList = filterList.concat([{ val: null, label: "(None)" }]);
	        }
	        return filterList.map(function (filterObj, idx) {
	            if (label === '(None)') {
	                return React.createElement(
	                    'div',
	                    { className: 'itemRow', 'data-label': label, key: 'filter-' + val },
	                    React.createElement(
	                        'div',
	                        { className: 'itemCheckbox' },
	                        React.createElement('input', { type: 'checkbox', id: val, value: val, checked: !filters || filters.indexOf(val) === -1 ? false : true, onChange: this.props.updateFiltersAndSavePreferences.bind(this, val, false) })
	                    ),
	                    React.createElement(
	                        'div',
	                        { className: 'itemTitle' },
	                        React.createElement(
	                            'label',
	                            { htmlFor: val },
	                            label
	                        )
	                    )
	                );
	            } else {
	                var label = filterObj.label;
	                valProp = valProp.replace(/ /g, '_').replace('_id', '');
	                var filterName;
	                switch (valProp) {
	                    case 'Record_Type':
	                        filterName = 'RecordTypeId';
	                        break;
	                    case 'Found_In_Build':
	                        filterName = 'Found_in_Build';
	                        break;
	                    case 'Kanban_State':
	                        filterName = 'Column';
	                        break;
	                    default:
	                        filterName = valProp;
	                }
	                var val = 'item-' + filterName + '-' + filterObj.val;
	                return React.createElement(
	                    'div',
	                    { className: 'itemRow', 'data-label': label, key: 'filter-' + val },
	                    React.createElement(
	                        'div',
	                        { className: 'itemCheckbox' },
	                        React.createElement('input', { type: 'checkbox', id: val, value: val, checked: !filters || filters.indexOf(val) === -1 ? false : true, onChange: this.props.updateFiltersAndSavePreferences.bind(this, val, false) })
	                    ),
	                    React.createElement(
	                        'div',
	                        { className: 'itemTitle' },
	                        React.createElement(
	                            'label',
	                            { htmlFor: val },
	                            label
	                        )
	                    )
	                );
	            }
	        }.bind(this));
	    },

	    makeFilterCheckboxesFromUniqueProp: function makeFilterCheckboxesFromUniqueProp(property) {
	        var records = this.props.records;
	        var dataObject = this.props.dataObject;
	        var makeCheckbox = function (prop, idx) {
	            var checkboxVal = this.createValueForFilterCheckbox(property, prop);
	            return React.createElement(
	                'div',
	                { className: 'itemRow', 'data-label': prop, key: 'itemRow-' + prop + idx },
	                React.createElement(
	                    'div',
	                    { className: 'itemCheckbox' },
	                    React.createElement('input', { type: 'checkbox', id: checkboxVal, value: checkboxVal, checked: !this.props.filters || this.props.filters.indexOf(checkboxVal + ',') === -1 ? false : true, onChange: this.props.updateFiltersAndSavePreferences.bind(this, checkboxVal, false) })
	                ),
	                React.createElement(
	                    'div',
	                    { className: 'itemTitle' },
	                    React.createElement(
	                        'label',
	                        { htmlFor: checkboxVal },
	                        checkboxVal && checkboxVal.endsWith('null') ? '(None)' : prop
	                    )
	                )
	            );
	        }.bind(this);

	        var checkboxes = _.uniq(_.pluck(records, property)).filter(function (val) {
	            return val !== null;
	        }).sort(function (a, b) {
	            if (a > b) return 1;
	            if (a < b) return -1;
	            return 0;
	        }).map(makeCheckbox);

	        // add (None)
	        // if (['Points_value'].indexOf(property) !== -1) {
	        //     checkboxes = checkboxes.concat([makeCheckbox(null, checkboxes.length)])
	        // }

	        return checkboxes;
	    },

	    render: function render() {
	        var filterableColumns = this.props.dataObject.allColumns.filter(function (column) {
	            return column.filterable === true;
	        });

	        var content = filterableColumns.map(function (column, idx) {
	            var label = column.label;

	            return React.createElement(
	                'div',
	                { className: 'filterTopic', 'data-label': label, key: 'filter-topic-' + label },
	                React.createElement(
	                    'div',
	                    null,
	                    label
	                ),
	                React.createElement(
	                    'div',
	                    { className: 'itemList' },
	                    this.determineOptionsByFilter(label, column, this.props.dataObject.recordIds, this.props.dataObject.recordsObj, this.props.filters)
	                )
	            );
	        }.bind(this));

	        return React.createElement(
	            'div',
	            null,
	            React.createElement(_PRESENTATIONALCOMPONENTS2.default.SidePanel, { id: "boxFilter", content: content, padding: true }),
	            this.props.dataObject.options && this.props.filters && this.props.filters !== '' ? React.createElement(
	                'div',
	                { id: 'clearFilters', onClick: this.props.updateFiltersAndSavePreferences.bind(this, null, true) },
	                React.createElement(
	                    'a',
	                    { href: '#' },
	                    'Clear Filters'
	                )
	            ) : undefined
	        );
	    }
	});

	FilterSidePanel = connect(mapStateToFilterSidePanelProps, mapDispatchToFilterSidePanelProps)(FilterSidePanel);

	exports.default = FilterSidePanel;

/***/ },
/* 25 */
/***/ function(module, exports) {

	"use strict";

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	// This will be used once we are controlling for whether the records are open or closed //

	var FilterSidePanelTestHeader = React.createClass({
	    displayName: "FilterSidePanelTestHeader",

	    getInitialState: function getInitialState() {
	        return {
	            showOptions: false
	        };
	    },

	    toggleShowOptions: function toggleShowOptions() {
	        this.setState({ showOptions: !this.state.showOptions });
	    },

	    render: function render() {
	        return React.createElement(
	            "div",
	            { className: "testShowWorkContainer" },
	            !this.state.showOptions ? React.createElement(
	                "span",
	                null,
	                React.createElement(
	                    "span",
	                    { className: "testShowWork" },
	                    "SHOW: ",
	                    React.createElement(
	                        "span",
	                        { className: "testShowWorkType" },
	                        "OPEN WORK"
	                    )
	                ),
	                React.createElement(
	                    "span",
	                    { className: "testChange", onClick: this.toggleShowOptions },
	                    "CHANGE"
	                )
	            ) : React.createElement(
	                "div",
	                { className: "filterTopic", "data-label": 'ShowMe', key: 'filter-topic-' + 'ShowMe' },
	                React.createElement(
	                    "span",
	                    { className: "testChange", onClick: this.toggleShowOptions },
	                    "CLOSE"
	                ),
	                React.createElement(
	                    "div",
	                    { className: "testShowWork" },
	                    "SHOW:"
	                ),
	                React.createElement(
	                    "div",
	                    { className: "itemList" },
	                    React.createElement(
	                        "div",
	                        { className: "itemRow" },
	                        React.createElement(
	                            "div",
	                            { className: "itemCheckbox" },
	                            React.createElement("input", { id: "OpenWork", type: "checkbox", checked: true })
	                        ),
	                        React.createElement(
	                            "div",
	                            { className: "itemTitle" },
	                            React.createElement(
	                                "label",
	                                { htmlFor: "OpenWork" },
	                                "Open Work"
	                            )
	                        )
	                    ),
	                    React.createElement(
	                        "div",
	                        { className: "itemRow" },
	                        React.createElement(
	                            "div",
	                            { className: "itemCheckbox" },
	                            React.createElement("input", { id: "OpenAndClosedWork", type: "checkbox" })
	                        ),
	                        React.createElement(
	                            "div",
	                            { className: "itemTitle" },
	                            React.createElement(
	                                "label",
	                                { htmlFor: "OpenAndClosedWork" },
	                                "Open And Closed Work"
	                            )
	                        )
	                    ),
	                    React.createElement(
	                        "div",
	                        { className: "itemRow" },
	                        React.createElement(
	                            "div",
	                            { className: "itemCheckbox" },
	                            React.createElement("input", { id: "ClosedWork", type: "checkbox" })
	                        ),
	                        React.createElement(
	                            "div",
	                            { className: "itemTitle" },
	                            React.createElement(
	                                "label",
	                                { htmlFor: "ClosedWork" },
	                                "Closed Work"
	                            )
	                        )
	                    )
	                )
	            )
	        );
	    }
	});

	exports.default = FilterSidePanelTestHeader;

/***/ },
/* 26 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToMassEditSidePanelProps = function mapStateToMassEditSidePanelProps(state, ownProps) {
	    return {
	        dataObject: state.dataObject,
	        allPoints: _selectors2.default.getAllPoints(state)
	    };
	};
	var mapDispatchToMassEditSidePanelProps = function mapDispatchToMassEditSidePanelProps(dispatch, ownProps) {
	    return {
	        massEditRecords: function massEditRecords(label, value) {
	            dispatch(_actionCreators2.default.massEditRecords(label, value));
	        },
	        saveState: function saveState(dataObject) {
	            dispatch(_actionCreators2.default.saveState(dataObject));
	        }
	    };
	};

	var MassEditSidePanel = React.createClass({
	    displayName: 'MassEditSidePanel',


	    propTypes: {
	        dataObject: React.PropTypes.object.isRequired,
	        massEditRecords: React.PropTypes.func
	    },

	    getInitialState: function getInitialState() {
	        return {
	            focusedVal: ''
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        $('#modalMetadataProblem .buttonCloseModal').on('click', function (e) {
	            $('.slds-modal').removeClass('slds-fade-in-open');
	            $('.slds-modal-backdrop').removeClass('slds-modal-backdrop--open');
	        });
	    },

	    makeDataListOptions: function makeDataListOptions(label) {
	        var that = this;
	        var dataObjectProp = _helper2.default.labelToDataObjectProp(label);
	        var filterList = [];
	        if (label === 'Points') {
	            filterList = this.props.allPoints.map(function (pointObj) {
	                return { Name: pointObj.Name || pointObj.Name === 0 ? pointObj.Name : '(None)' };
	            });
	        } else {
	            filterList = this.props.dataObject[dataObjectProp] || [];
	        }

	        // TODO - This list should really be passed in with allColumns as a prop called something like massEditNoneable (there could also be filterNoneable, etc.)
	        if (['Sprint', 'QA Engineer', 'Epic', 'Found In Build', 'Scheduled Build'].indexOf(label) > -1) {
	            filterList = filterList.concat([{ Name: "(None)" }]);
	        }
	        var result = filterList.map(function (item, idx) {
	            var value = item.Name || item.Name === 0 ? item.Name : item;
	            var display;
	            if (item.Name === '(None)') {
	                value = null;
	                var display = item.Name;
	            };
	            var id = item.Id;
	            var smallPhotoUrl = item.SmallPhotoUrl;
	            if (typeof value === 'number') {
	                value = value.toString();
	            }
	            return React.createElement(
	                'option',
	                { 'data-value': display ? display : value, 'data-id': id, 'data-smallphotourl': smallPhotoUrl, key: id + value },
	                display ? display : value
	            );
	        });

	        // This gives us an empty initial option for the Status dropdown
	        if (label === 'Status') {
	            result = [React.createElement('option', { key: 'empty-status' })].concat(result);
	        }

	        return result;
	    },

	    onDatalistChange: function onDatalistChange(label, e) {
	        if (this.state.focusedVal !== e.target.value) {
	            this.props.saveState(this.props.dataObject);
	            this.props.massEditRecords(label, e.target.value);
	        }
	    },

	    setFocusedVal: function setFocusedVal(e) {
	        this.setState({ focusedVal: e.target.value });
	    },

	    render: function render() {
	        var content;
	        if (this.props.dataObject.selected.length > 0) {
	            content = React.createElement(
	                'div',
	                { id: 'massEditOptions' },
	                React.createElement(
	                    'form',
	                    null,
	                    this.props.dataObject.allColumns.filter(function (column) {
	                        return column.editable;
	                    }).map(function (column, index) {
	                        var label = column.label,
	                            id = label.toLowerCase().split(' ').join(''),
	                            editType = column.editType;

	                        return React.createElement(
	                            'div',
	                            { className: 'filterTopic', 'data-label': label, key: label + index + '-filterTopic' },
	                            React.createElement(
	                                'div',
	                                null,
	                                label
	                            ),
	                            React.createElement(
	                                'div',
	                                { className: 'itemList' },
	                                editType === 'input' ? React.createElement('input', { key: id + label, className: "slds-" + editType, list: id, onBlur: this.onDatalistChange.bind(this, label), onFocus: this.setFocusedVal }) : React.createElement(
	                                    'select',
	                                    { key: id + label, className: "slds-" + editType, list: id, onChange: this.onDatalistChange.bind(this, label), onFocus: this.setFocusedVal },
	                                    this.makeDataListOptions(label)
	                                ),
	                                React.createElement(
	                                    'datalist',
	                                    { id: id, key: label + id + index },
	                                    editType === 'input' ? this.makeDataListOptions(label) : undefined
	                                )
	                            )
	                        );
	                    }.bind(this))
	                )
	            );
	        } else {
	            content = React.createElement(
	                'div',
	                { id: 'massEditNone' },
	                'Please select some work items to the left first.'
	            );
	        }
	        return React.createElement(
	            'div',
	            null,
	            React.createElement(_PRESENTATIONALCOMPONENTS2.default.SidePanel, { id: 'boxMassEdit', content: content, padding: true })
	        );
	    }
	});

	MassEditSidePanel = connect(mapStateToMassEditSidePanelProps, mapDispatchToMassEditSidePanelProps)(MassEditSidePanel);

	exports.default = MassEditSidePanel;

/***/ },
/* 27 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _WorkManagerCell = __webpack_require__(28);

	var _WorkManagerCell2 = _interopRequireDefault(_WorkManagerCell);

	var _WorkManagerGripperCell = __webpack_require__(29);

	var _WorkManagerGripperCell2 = _interopRequireDefault(_WorkManagerGripperCell);

	var _WorkManagerRecordCheckbox = __webpack_require__(30);

	var _WorkManagerRecordCheckbox2 = _interopRequireDefault(_WorkManagerRecordCheckbox);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var FlexTable = ReactVirtualized.FlexTable; // IMPORTANT: ADM_BACKLOG_PAGE_VARS with certain props, like teamid & sprintid are required as global objets outside of this app //

	var FlexColumn = ReactVirtualized.FlexColumn;

	var connect = ReactRedux.connect,
	    DragLayer = ReactDnD.DragLayer,
	    DragDropContext = ReactDnD.DragDropContext,
	    HTML5Backend = ReactDnDHTML5Backend;

	var mapStateToWorkManagerTableProps = function mapStateToWorkManagerTableProps(state, ownProps) {
	    return {
	        sort: _selectors2.default.getSort(state),
	        loadingTable: _selectors2.default.getLoadingTable(state),
	        recordsToDisplay: _selectors2.default.getRecordsToDisplay(state),
	        visibleRecordIdsWithoutHeaders: _selectors2.default.getVisibleRecordIdsWithoutHeaders(state),
	        currentColumn: _selectors2.default.getCurrentColumn(state),
	        history: _selectors2.default.getHistory(state),
	        scrollTop: _selectors2.default.getScrollTop(state),
	        scrollNeedsUpdate: _selectors2.default.getScrollNeedsUpdate(state),
	        isFullscreen: _selectors2.default.getIsFullscreen(state),
	        view: _selectors2.default.getView(state),
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerTableProps = function mapDispatchToWorkManagerTableProps(dispatch, ownProps) {
	    return {
	        handleHeaderClick: function handleHeaderClick(label, sort, columns) {
	            dispatch(_actionCreators2.default.handleHeaderClick(label, sort, columns));
	        },
	        refreshData: function refreshData(dataObject, overrideHistoryCheck, initialLoad, viewChangeRequested, paramId, selectedText) {
	            dispatch(_actionCreators2.default.refreshData(dataObject, overrideHistoryCheck, initialLoad, viewChangeRequested, paramId, selectedText));
	        },
	        updateScrollTop: function updateScrollTop(y) {
	            dispatch(_actionCreators2.default.updateScrollTop(y));
	        },
	        updateScrollNeedsUpdate: function updateScrollNeedsUpdate(bool) {
	            dispatch(_actionCreators2.default.updateScrollNeedsUpdate(bool));
	        }
	    };
	};

	var WorkManagerTable = React.createClass({
	    displayName: 'WorkManagerTable',

	    propTypes: function propTypes() {
	        return {
	            windowWidth: React.PropTypes.number.isRequired,
	            dataObject: React.PropTypes.object.isRequired
	        };
	    },

	    componentDidMount: function componentDidMount() {
	        window.onbeforeunload = function (e) {
	            if (this.props.history.past.length > 0) {
	                return 'You have unsaved changes!';
	            }
	        }.bind(this);
	        globalWorkModalSaveCB = function (err, result) {
	            if (err) {
	                console.error('there was an error and it was: ', err);
	            } else {
	                this.props.refreshData(this.props.dataObject, null, false, null, this.props.headerId, this.props.dataObject.headerTitle);
	            }
	        }.bind(this);
	    },

	    componentWillUnmount: function componentWillUnmount() {
	        globalWorkModalSaveCB = undefined;
	    },

	    componentDidUpdate: function componentDidUpdate(prevProps, prevState) {
	        if ($('.group-row-header')) {
	            $(".FlexTable").on("scroll", function (e) {
	                $.each($(".group-row-header"), function (idx, header) {
	                    $(this).css({ left: e.currentTarget.scrollLeft + 50 });
	                });
	            });
	        }
	        if (this.FlexTable) {
	            this.FlexTable.recomputeRowHeights();

	            if (!prevProps.scrollNeedsUpdate && this.props.scrollNeedsUpdate) {
	                this._scrollTop = this.props.scrollTop;
	                this.props.updateScrollNeedsUpdate(false);
	                setTimeout(function () {
	                    this._scrollTop = undefined;
	                }.bind(this), 0);
	            }
	        }
	    },

	    getColumnsBasedOnWindowSize: function getColumnsBasedOnWindowSize(windowWidth, columns) {
	        if (windowWidth <= 450) {
	            return columns.filter(function (column) {
	                return column.label === 'Subject';
	            });
	        } else if (windowWidth <= 650) {
	            return columns.filter(function (column) {
	                return ['Subject', 'Rank', 'Status'].indexOf(column.label) > -1;
	            });
	        } else {
	            return columns;
	        }
	    },

	    _setFlexTableRef: function _setFlexTableRef(ref) {
	        this.FlexTable = ref;
	    },

	    render: function render() {
	        if (!this.props || !this.props.dataObject || !this.props.dataObject || !this.props.dataObject.recordIds || !this.props.dataObject.recordsObj || !this.props.dataObject.columns) {
	            return React.createElement(
	                'div',
	                { className: 'slds-spinner--large', style: { 'margin': '0px auto' } },
	                React.createElement('img', { src: '/resource/' + this.props.nameSpace + 'SLDS091/assets/images/spinners/slds_spinner_brand.gif', alt: 'Loading...' })
	            );
	        }
	        var dataObject = this.props.dataObject;
	        var columns = dataObject.columns;
	        var sort = dataObject.sort;
	        var sortColumn = sort.column;
	        var sortDirection = sort.direction;
	        var selected = dataObject.selected;
	        var recordsToDisplay = this.props.recordsToDisplay;
	        var windowWidth = this.props.windowWidth;
	        var columnsBasedOnWindowSize = this.getColumnsBasedOnWindowSize(windowWidth, dataObject.columns);
	        var tableWidth = columnsBasedOnWindowSize.reduce(function (prev, curr) {
	            return prev + _helper2.default.mapColumnLabelToWidth(curr.label);
	        }, 60);
	        var pageHeader = $(".slds-page-header").outerHeight();
	        var appBodyHeader = $('#AppBodyHeader').outerHeight();
	        var windowInnerHeight = $(window).innerHeight();
	        var oneHeaderHeight = $('#oneHeader').outerHeight();
	        var appBodyHeader = $('#AppBodyHeader').outerHeight();
	        var sldsPageHeader = $('.slds-page-header').outerHeight();
	        var bPageFooter = $('.bPageFooter').outerHeight();
	        var tableHeight = globalWorkManagerIsInAloha && !this.props.isFullscreen ? windowInnerHeight - appBodyHeader - sldsPageHeader - bPageFooter : windowInnerHeight - 117;
	        if (windowWidth > tableWidth) {
	            tableWidth = windowWidth;
	        }

	        if (!this.props || !this.props.dataObject || !this.props.dataObject || !this.props.dataObject.recordIds || !this.props.dataObject.recordsObj || !this.props.dataObject.columns) {
	            return React.createElement(
	                'div',
	                { className: 'slds-spinner--large', style: { 'margin': '0px auto' } },
	                React.createElement('img', { src: '/resource/' + this.props.nameSpace + 'SLDS091/assets/images/spinners/slds_spinner_brand.gif', alt: 'Loading...' })
	            );
	        }

	        return React.createElement(
	            'div',
	            null,
	            this.props.loadingTable === true ? React.createElement(
	                'div',
	                { className: 'slds-spinner--large', style: { 'margin': '0px auto', height: tableHeight } },
	                React.createElement('img', { src: '/resource/' + this.props.nameSpace + 'SLDS091/assets/images/spinners/slds_spinner_brand.gif', alt: 'Loading...' })
	            ) : React.createElement(
	                FlexTable,
	                {
	                    ref: this._setFlexTableRef,
	                    width: tableWidth,
	                    height: tableHeight,
	                    headerHeight: 28,
	                    rowHeight: function rowHeight(idx) {
	                        var thisRecord = recordsToDisplay[idx];
	                        return thisRecord.rowHeader ? 28 : 37;
	                    },
	                    rowsCount: recordsToDisplay.length,
	                    rowGetter: function rowGetter(index) {
	                        return recordsToDisplay[index];
	                    },
	                    overscanRowsCount: 1,
	                    onHeaderClick: function (dataKey, columnData) {
	                        if (dataKey !== 'checkbox' && dataKey !== 'gripper') {
	                            this.props.handleHeaderClick(dataKey, sort, columns);
	                        }
	                    }.bind(this),
	                    className: 'slds-table slds-table--bordered',
	                    headerClassName: 'work-manager-column-header',
	                    rowClassName: function (rowIdx) {
	                        var className = '';
	                        var record = recordsToDisplay[rowIdx];

	                        if (rowIdx === -1) className += 'slds-text-heading--label ';
	                        if (record && record.rowHeader) className += 'groupCell ';
	                        if (record && selected && selected.indexOf(record.Id) > -1) className += ' selected';
	                        if (record && record.moved) className += ' moved';
	                        if (record && record.velocityLine && rowIdx !== 0) className += ' velocity-line';

	                        return className;
	                    }.bind(this),
	                    onScroll: function (scroll) {
	                        var scrollTop = scroll.scrollTop;
	                        this.props.updateScrollTop(scrollTop);
	                    }.bind(this),
	                    scrollTop: this._scrollTop
	                },
	                windowWidth > 650 ? React.createElement(FlexColumn, {
	                    dataKey: 'checkbox',
	                    minWidth: 25,
	                    width: 25,
	                    disableSort: true,
	                    headerRenderer: function headerRenderer(columnData, dataKey, disableSort, headerLabelUnused, sortBy, sortDirection) {
	                        return React.createElement(_WorkManagerRecordCheckbox2.default, { isToggleAll: true, name: 'select-all', id: "select-all", visibleRecordIds: this.props.visibleRecordIdsWithoutHeaders, value: "checkbox" });
	                    }.bind(this),
	                    cellRenderer: function cellRenderer(cellData, cellDataKey, rowData, rowIndex, columnData) {
	                        var record = recordsToDisplay[rowIndex];
	                        var content = record.rowHeader ? undefined : React.createElement(_WorkManagerRecordCheckbox2.default, {
	                            name: "select-row-" + record.Id,
	                            value: "checkbox",
	                            id: record.Id,
	                            visibleRecordIds: this.props.visibleRecordIdsWithoutHeaders
	                        });
	                        return React.createElement(_WorkManagerCell2.default, { content: content, record: rowData });
	                    }.bind(this)
	                }) : React.createElement(FlexColumn, { dataKey: 'checkbox', width: 0 }),
	                windowWidth > 650 ? React.createElement(FlexColumn, {
	                    dataKey: 'gripper',
	                    minWidth: 30,
	                    width: 30,
	                    disableSort: true,
	                    cellRenderer: function (cellData, cellDataKey, rowData, rowIndex, columnData) {
	                        var record = recordsToDisplay[rowIndex];
	                        var draggable = this.props.currentColumn.draggable;
	                        if (this.props.currentColumn.label === 'Subject' || this.props.currentColumn.label === 'Modified Date' || this.props.currentColumn.label === 'Created Date' || this.props.view.viewType !== 'backlog') {
	                            draggable = false;
	                        }
	                        var content = record.rowHeader ? undefined : React.createElement(_WorkManagerGripperCell2.default, { id: record.Id, record: rowData, draggable: draggable });
	                        return React.createElement(_WorkManagerCell2.default, { content: content, id: record.Id, record: rowData });
	                    }.bind(this)
	                }) : React.createElement(FlexColumn, { dataKey: 'gripper', width: 0 }),
	                columnsBasedOnWindowSize.map(function (column, columnIdx) {
	                    var label = column.label;
	                    var width = _helper2.default.mapColumnLabelToWidth(label);
	                    var headerClass = column.label === sortColumn ? sortDirection : '';

	                    return React.createElement(FlexColumn, {
	                        label: label === 'Record Type' ? '' : label,
	                        dataKey: label,
	                        minWidth: width,
	                        maxWidth: label === 'Subject' ? undefined : width,
	                        width: width,
	                        flexGrow: label === 'Subject' ? 2 : 1,
	                        key: label + columnIdx,
	                        headerRenderer: function headerRenderer(columnData, dataKey, disableSort, headerLabelUnused, sortBy, sortDirection) {
	                            return React.createElement(_PRESENTATIONALCOMPONENTS2.default.HeaderCell, { label: label, sort: this.props.sort, nameSpace: this.props.nameSpace });
	                        }.bind(this),
	                        headerClassName: "slds-is-sortable " + headerClass,
	                        cellRenderer: function cellRenderer(cellData, cellDataKey, rowData, rowIndex, columnData) {
	                            var value = rowData[label + '_value'];
	                            var link = rowData[label + '_link'];
	                            var smallPhotoUrl = rowData[label + '_smallPhotoUrl'];
	                            var id = rowData[label + '_id'];

	                            if (cellDataKey === 'Modified Date' || cellDataKey === 'Created Date') {
	                                if (typeof value !== 'undefined' && value !== '') {
	                                    value = _helper2.default.formatDate(value);
	                                }
	                            }
	                            var classNames;
	                            if (rowData[column.label + '_moved_dark']) {
	                                classNames = 'moved-dark';
	                            } else if (rowData[column.label + '_moved_light']) {
	                                classNames = 'moved-light';
	                            };

	                            if (cellDataKey === 'Record Type') {
	                                var content = React.createElement(
	                                    'svg',
	                                    { 'aria-hidden': 'true', className: 'slds-icon slds-icon--x-small slds-icon-text-default' },
	                                    React.createElement('use', { xlinkHref: '/resource/' + this.props.nameSpace + 'SLDS091/assets/icons/action-sprite/svg/symbols.svg#' + _helper2.default.makeRecordTypeIcon(value) })
	                                );
	                                return React.createElement(_WorkManagerCell2.default, { content: content, id: rowData.Id, record: rowData });
	                            }
	                            return rowData.rowHeader ? React.createElement(_WorkManagerCell2.default, { content: columnIdx === 0 ? React.createElement(
	                                    'div',
	                                    { className: 'group-row-header', ref: "group-row-header", record: rowData },
	                                    rowData.rowHeader
	                                ) : '', record: rowData }) : React.createElement(_WorkManagerCell2.default, { content: value, id: rowData.Id, href: link, record: rowData, classNames: classNames, smallPhotoUrl: smallPhotoUrl, columnLabel: label, overrideLink: label === 'Subject' ? true : false });
	                        }.bind(this)
	                    });
	                }.bind(this))
	            )
	        );
	    }
	});

	var WorkManagerDragLayerCollect = function WorkManagerDragLayerCollect(monitor) {
	    return {};
	};
	WorkManagerTable = DragLayer(WorkManagerDragLayerCollect)(WorkManagerTable);
	WorkManagerTable = connect(mapStateToWorkManagerTableProps, mapDispatchToWorkManagerTableProps)(WorkManagerTable);

	var WorkManagerTableContainer = DragDropContext(HTML5Backend)(WorkManagerTable);
	//============================================================== END WORKMANAGERTABLE ==============================================================//

	exports.default = WorkManagerTableContainer;

/***/ },
/* 28 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect,
	    DropTarget = ReactDnD.DropTarget;

	var pendingUpdateFn = null;
	var requestedFrame = null;
	var drawFrame = function drawFrame() {
	    pendingUpdateFn.apply(undefined, arguments);
	    setTimeout(function () {
	        pendingUpdateFn = null;
	        requestedFrame = null;
	    }, 0);
	};

	var workManagerCellSharedThrottledFunc = function workManagerCellSharedThrottledFunc(updateFn) {
	    for (var _len = arguments.length, args = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
	        args[_key - 1] = arguments[_key];
	    }

	    pendingUpdateFn = updateFn;
	    if (!requestedFrame) {
	        requestedFrame = requestAnimationFrame(function () {
	            drawFrame.apply(undefined, args);
	        });
	    }
	};

	var WorkManagerCellDropTarget = {
	    drop: function drop(props, monitor) {
	        if (props.sort.column === 'Sprint') {
	            var targetId = !props.record.rowHeader ? props.record.Id : props.record.idOfFirstRecord;
	            props.updateUpdatedSprints([targetId]);
	        }
	        return {
	            id: props.id,
	            item: monitor.getItem()
	        };
	    },

	    hover: function hover(props, monitor) {
	        var draggedItem = monitor.getItem();
	        var draggedId = draggedItem.id;
	        var dropTargetRecord = props.record;
	        var recordsObj = props.recordsObj;
	        var selected = props.selected;
	        var sortColumn = props.sort.column;

	        if (props.sort && props.sort.column) {
	            var targetId = !dropTargetRecord.rowHeader ? dropTargetRecord.Id : dropTargetRecord.idOfFirstRecord;

	            if (props.sort.column === 'Rank') {
	                if (selected.indexOf(targetId) === -1) {
	                    workManagerCellSharedThrottledFunc(props.updateRanks, dropTargetRecord);
	                }
	            } else {
	                if (selected.indexOf(targetId) === -1) {
	                    var group = props.sort.column.toLowerCase() + 's';
	                    var groupName = recordsObj[targetId][props.sort.column + '_value'];
	                    if (!groupName && groupName !== 0) {
	                        groupName = 'NO ' + props.sort.column.toUpperCase();
	                    }
	                    workManagerCellSharedThrottledFunc(props.updateGroup, group, groupName, targetId);
	                }
	            }
	        }
	    }
	};
	var WorkManagerCellDropCollect = function WorkManagerCellDropCollect(connect, monitor) {
	    return {
	        connectDropTarget: connect.dropTarget()
	    };
	};
	var WorkManagerCell = React.createClass({
	    displayName: 'WorkManagerCell',

	    getInitialState: function getInitialState() {
	        return { hover: false };
	    },

	    mouseOver: function mouseOver() {
	        this.setState({ hover: true });
	    },

	    mouseOut: function mouseOut() {
	        this.setState({ hover: false });
	    },

	    handleCellClick: function handleCellClick(e) {
	        if (this.props.content === this.props.record.Subject_value) {
	            // selectedWork is a global variable
	            selectedWork = this.props.id;
	            e.preventDefault();
	            if (navigator.userAgent.match(/Mobile/i) && (typeof sforce === 'undefined' ? 'undefined' : _typeof(sforce)) == 'object') {
	                sforce.one.navigateToSObject(selectedWork);
	            } else if (navigator.userAgent.match(/Mobile/i) && (typeof sforce === 'undefined' ? 'undefined' : _typeof(sforce)) !== 'object') {
	                location.href = '/' + selectedWork;
	            } else {
	                workModalOpen();
	            }
	        }
	    },

	    componentWillUnmount: function componentWillUnmount() {
	        cancelAnimationFrame(requestedFrame);
	    },

	    render: function render() {
	        var props = this.props,
	            connectDropTarget = props.connectDropTarget,
	            content = props.content,
	            href = props.href,
	            classNames = props.classNames,
	            smallPhotoUrl = props.smallPhotoUrl,
	            columnLabel = props.columnLabel,
	            hover = this.state.hover,
	            overrideLink = props.overrideLink;

	        var className = 'slds-text-body--small work-manager-cell ' + classNames;
	        var LinkedColContent = React.createElement(
	            'a',
	            { href: '/' + href, target: '_blank' },
	            content
	        );

	        return connectDropTarget(React.createElement(
	            'span',
	            null,
	            React.createElement(
	                'div',
	                { className: className },
	                href && !overrideLink ? React.createElement(
	                    'a',
	                    { href: '/' + href, target: '_blank', className: columnLabel === 'Epic' ? 'long-subject-cell' : 'slds-truncate' },
	                    smallPhotoUrl ? React.createElement(
	                        'span',
	                        { className: 'slds-avatar slds-avatar--circle slds-avatar--x-small slds-m-right--x-small' },
	                        React.createElement('img', { src: smallPhotoUrl })
	                    ) : undefined,
	                    content
	                ) : React.createElement(
	                    'div',
	                    { onMouseOver: this.mouseOver, onMouseOut: this.mouseOut, className: columnLabel === 'Subject' ? 'long-subject-cell' : 'slds-truncate', onClick: this.handleCellClick },
	                    columnLabel === 'Subject' ? LinkedColContent : content
	                )
	            ),
	            columnLabel === 'Subject' && props && props.record && props.record.longSubject && hover ? React.createElement(
	                'div',
	                { className: 'slds-popover slds-popover--tooltip slds-nubbin--top slds-text-body--small', role: 'tooltip', style: { position: 'absolute' } },
	                React.createElement(
	                    'div',
	                    { className: 'slds-popover__body', style: { wordBreak: 'break-word', overflowWrap: 'break-word' } },
	                    content
	                )
	            ) : undefined
	        ));
	    }
	});
	var WorkManagerDropTargetCell = DropTarget('ROW', WorkManagerCellDropTarget, WorkManagerCellDropCollect)(WorkManagerCell);
	var mapStateToWorkManagerDropTargetCellProps = function mapStateToWorkManagerDropTargetCellProps(state, ownProps) {
	    return {
	        selected: state.dataObject.selected,
	        sort: state.dataObject.sort,
	        recordsObj: state.dataObject.recordsObj,
	        recordIds: state.dataObject.recordIds,
	        classNames: ownProps.classNames
	    };
	};
	var mapDispatchToWorkManagerDropTargetCellProps = function mapDispatchToWorkManagerDropTargetCellProps(dispatch, ownProps) {
	    return {
	        updateRanks: function updateRanks(targetRecord) {
	            dispatch(_actionCreators2.default.updateRanks(targetRecord));
	        },
	        updateGroup: function updateGroup(group, groupName, targetId, selected) {
	            dispatch(_actionCreators2.default.updateGroup(group, groupName, targetId, selected));
	        },
	        updateUpdatedSprints: function updateUpdatedSprints(arrayOfSprintIds) {
	            dispatch(_actionCreators2.default.updateUpdatedSprints(arrayOfSprintIds));
	        }
	    };
	};
	WorkManagerDropTargetCell = connect(mapStateToWorkManagerDropTargetCellProps, mapDispatchToWorkManagerDropTargetCellProps)(WorkManagerDropTargetCell);

	exports.default = WorkManagerDropTargetCell;

/***/ },
/* 29 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	var _selectors = __webpack_require__(3);

	var _selectors2 = _interopRequireDefault(_selectors);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect,
	    DragSource = ReactDnD.DragSource;

	var mapStateToWorkManagerGripperCellProps = function mapStateToWorkManagerGripperCellProps(state, ownProps) {
	    return {
	        dataObject: state.dataObject,
	        sort: state.dataObject.sort,
	        selected: state.dataObject.selected,
	        filter: _selectors2.default.getTeamFilters(state),
	        history: state.history,
	        nameSpace: _selectors2.default.getNameSpace(state)
	    };
	};
	var mapDispatchToWorkManagerGripperCellProps = function mapDispatchToWorkManagerGripperCellProps(dispatch, ownProps) {
	    return {
	        onBeginDrag: function onBeginDrag(dataObject) {
	            dispatch(_actionCreators2.default.saveState(dataObject));
	            if (dataObject.sort.column === 'Sprint') {
	                dispatch(_actionCreators2.default.updateUpdatedSprints(dataObject.selected));
	            }
	        },
	        onMouseDown: function onMouseDown(id) {
	            dispatch(_actionCreators2.default.toggleCheckboxIfUnchecked(id));
	        },
	        returnToPreviousState: function returnToPreviousState(history) {
	            dispatch(_actionCreators2.default.returnToPreviousState(history));
	        },
	        clearSelected: function clearSelected() {
	            dispatch(_actionCreators2.default.clearSelected());
	        }
	    };
	};

	var WorkManagerGripperCellDragSource = {
	    canDrag: function canDrag(props) {
	        return props.draggable ? true : false;
	    },

	    beginDrag: function beginDrag(props) {
	        props.onBeginDrag(props.dataObject);
	        return {
	            id: props.id,
	            onBegindrag: props.onBeginDrag,
	            record: props.record
	        };
	    },
	    endDrag: function endDrag(props, monitor, component) {
	        var didDrop = monitor.didDrop();
	        if (!didDrop) {
	            props.returnToPreviousState(props.history);
	        } else {
	            props.clearSelected();
	        }
	    }
	};
	var WorkManagerGripperCellCollect = function WorkManagerGripperCellCollect(connect, monitor) {
	    return {
	        connectDragSource: connect.dragSource()
	    };
	};
	var WorkManagerGripperCell = React.createClass({
	    displayName: 'WorkManagerGripperCell',

	    render: function render() {
	        var props = this.props,
	            id = props.id,
	            connectDragSource = props.connectDragSource,
	            onMouseDown = props.onMouseDown,
	            draggable = props.draggable,
	            nameSpace = props.nameSpace;

	        return connectDragSource(React.createElement(
	            'div',
	            null,
	            React.createElement(_PRESENTATIONALCOMPONENTS2.default.Gripper, { onMouseDown: onMouseDown.bind(this, id), draggable: draggable, nameSpace: nameSpace })
	        ));
	    }
	});
	WorkManagerGripperCell = DragSource('ROW', WorkManagerGripperCellDragSource, WorkManagerGripperCellCollect)(WorkManagerGripperCell);
	WorkManagerGripperCell = connect(mapStateToWorkManagerGripperCellProps, mapDispatchToWorkManagerGripperCellProps)(WorkManagerGripperCell);

	exports.default = WorkManagerGripperCell;

/***/ },
/* 30 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	    value: true
	});

	var _actionCreators = __webpack_require__(2);

	var _actionCreators2 = _interopRequireDefault(_actionCreators);

	var _helper = __webpack_require__(1);

	var _helper2 = _interopRequireDefault(_helper);

	var _PRESENTATIONALCOMPONENTS = __webpack_require__(9);

	var _PRESENTATIONALCOMPONENTS2 = _interopRequireDefault(_PRESENTATIONALCOMPONENTS);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	var connect = ReactRedux.connect;

	var mapStateToWorkManagerRecordCheckboxProps = function mapStateToWorkManagerRecordCheckboxProps(state, ownProps) {
	    return {
	        selected: state.dataObject.selected,
	        selectAll: state.dataObject.selectAll
	    };
	};
	var mapDispatchToWorkManagerRecordCheckboxProps = function mapDispatchToWorkManagerRecordCheckboxProps(dispatch, ownProps) {
	    return {
	        onChange: function onChange(e) {
	            if (ownProps.isToggleAll) {
	                dispatch(_actionCreators2.default.toggleVisibleCheckboxes(ownProps.visibleRecordIds));
	            } else {
	                dispatch(_actionCreators2.default.toggleCheckbox(ownProps.id, e.nativeEvent.shiftKey, ownProps.visibleRecordIds));
	            }
	        }
	    };
	};

	var WorkManagerRecordCheckbox = React.createClass({
	    displayName: 'WorkManagerRecordCheckbox',


	    render: function render() {
	        var props = this.props,
	            selected = props.selected,
	            onChange = props.onChange,
	            name = props.name,
	            value = props.value,
	            id = props.id,
	            isToggleAll = props.isToggleAll,
	            selectAll = props.selectAll,
	            visibleRecordIds = props.visibleRecordIds,
	            checked,
	            indeterminate;

	        if (isToggleAll) {
	            checked = selectAll ? true : false;
	            indeterminate = !selectAll && selected.length !== visibleRecordIds.length ? true : false;
	        } else {
	            checked = selected.indexOf(id) === -1 ? false : true;
	        }

	        return React.createElement(_PRESENTATIONALCOMPONENTS2.default.Checkbox, { onChange: onChange, name: name, value: value, id: id, checked: checked, indeterminate: indeterminate });
	    }
	});
	WorkManagerRecordCheckbox = connect(mapStateToWorkManagerRecordCheckboxProps, mapDispatchToWorkManagerRecordCheckboxProps)(WorkManagerRecordCheckbox);

	exports.default = WorkManagerRecordCheckbox;

/***/ }
/******/ ]);