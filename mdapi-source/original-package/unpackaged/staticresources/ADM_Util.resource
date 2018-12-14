// uses the module pattern as described here:
// https://developer.salesforce.com/docs/atlas.en-us.210.0.lightning.meta/lightning/security_share_code.htm
window.ADM_Util = (function() {
    var isStr = function(val) {
        return typeof val === 'string';
    }

    var isObj = function(val) {
        return typeof val === 'object';
    }

    var isArr = function(val) {
        return Array.isArray(val);
    }

    var isBool = function(val) {
        return typeof val === 'boolean';
    }

    var getProp = function(prop, obj) {
        return obj && prop ? obj[prop] : undefined;
    }

    var getId = function(obj) {
        return getProp('Id', obj);
    }

    var getIds = function(arr) {
        return arr.map(function(elem) {
            return getId(elem);
        });
    }

    var arraysEqual = function(arr1, arr2) {
        // this fn is only for primitives. Doesn't do deep equal for objects.
        if(arr1.length !== arr2.length)
            return false;
        for(var i = arr1.length; i--;) {
            if(arr1[i] !== arr2[i])
                return false;
        }

        return true;
    }

    var _concatError = function(newError, currentErrors) {
        return !currentErrors ?
            newError
            : currentErrors.concat(', ').concat(newError);
    }

    /**
     * @param {array} errors - The error array passed back from lightning
     * @returns {string} error message string
    */
    var _createErrorMessage = function(errors) {
        if (!isArr(errors)) {
            return '';
        }
        var errMsg = '';

        errors.forEach(function(err) {
            if (err.message) {
                errMsg = _concatError(err.message, errMsg);
            }

            if (isArr(err.pageErrors)) {
                err.pageErrors.forEach(function(pageErr) {
                    if (pageErr.message) {
                        errMsg = _concatError(pageErr.message, errMsg);
                    }
                })
            }

            if (isObj(err.fieldErrors)) {
                Object.keys(err.fieldErrors).forEach(function(key) {
                    var fieldErrArr = err.fieldErrors[key];

                    if (isArr(fieldErrArr) && fieldErrArr.length > 0) {
                        fieldErrArr.forEach(function(fieldErr) {
                            if (fieldErr.message) {
                                errMsg = _concatError(fieldErr.message, errMsg);
                            }
                        })
                    }
                });
            }
        });
        return errMsg;
    }

    /**
     * @param {array} err - The error array passed back from lightning
     * @param {object} paramsObj (optional) pass in an object with keys to override
     * the default params that are used when e.force:showToast is fired.
    */
    var handleErrorWithToast = function(err, paramsObj) {
        var errMsg = _createErrorMessage(err);
        if (!errMsg) {
            errMsg = 'Unknown error occurred.';
        }
        // hacky way to determine if there is more than one error. Check whether
        // there is a comma in the error message. This would break down if there is only
        // one error message and that message has a comma.
        var defaultTitle = errMsg.includes(',') ? 'Errors' : 'Error';
        var defaultParams = {
            "key": "error",
            "title": defaultTitle,
            "message": errMsg,
            "type": "error",
            "mode": "sticky"
        }
        var params = Object.assign({}, defaultParams, paramsObj);

        $A.get("e.force:showToast").setParams(params).fire();
    }

    /**
     * @param {array} err - The error array passed back from lightning
     * @param {string} consoleMethod (optional) pass in different console methods, like 'error'
     * or 'info' to use console.error(err) or console.info(err)
    */
    var handleErrorInConsole = function(err, consoleMethod) {
        var errMsg = _createErrorMessage(err);
        var defaultConsoleMethod = 'error';
        if (!consoleMethod) {
            consoleMethod = defaultConsoleMethod;
        }
        if (!errMsg) {
            errMsg = 'Unknown error occurred.';
        }
        if (console && console[consoleMethod]) {
                console[consoleMethod](errMsg);
            }
    }

    var serializeSprintDataForNamespace = function(sprintData, currentNode, nameSpace){
        if(nameSpace != null && nameSpace!=''){
            if(typeof sprintData[currentNode] != 'object'){
                sprintData[currentNode.replace(nameSpace, '')] = sprintData[currentNode];
            }
            else{
                sprintData[currentNode.replace(nameSpace, '')] = sprintData[currentNode];
                for(var innerNode in sprintData[currentNode]){
                    sprintData[currentNode] = this.serializeSprintDataForNamespace(sprintData[currentNode], innerNode, nameSpace);
                }
            }
        }
        
        return sprintData;
    }

    return {
        isStr: isStr,
        isObj: isObj,
        isArr: isArr,
        isBool: isBool,
        arraysEqual: arraysEqual,
        getIds: getIds,
        handleErrorWithToast: handleErrorWithToast,
        handleErrorInConsole: handleErrorInConsole,
        serializeSprintDataForNamespace: serializeSprintDataForNamespace
    };
}());
