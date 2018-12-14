({
    initialize: function(component, event, helper) {
        window.setTimeout($A.getCallback(function() {
            var data = component.get("v.data"),
                columns = component.get("v.columns"),
                rowData = [];

            for (var dataCount = 0, dataLen = data.length; dataCount < dataLen; dataCount++) {
                var currdata = data[dataCount],
                    row =[];
                
                for (var colsCount = 0, colsLen = columns.length; colsCount < colsLen ; colsCount++) {
                    var field = columns[colsCount].fieldName,
                        linkIdField = (columns[colsCount].linkIdField || ''),
                        col = {};
                    
                    field = field.split('.');
                    linkIdField = linkIdField.split('.');

                    if (field.length == 1) {
                        if (currdata[field[0]]) {
                            col.value = currdata[field[0]];
                        } else {
                            col.value = null;
                        }
                    } else if (field.length == 2) {
                        if (currdata[field[0]] && currdata[field[0]][field[1]]) {
                            col.value = currdata[field[0]][field[1]];
                        } else {
                            col.value = null;
                        }
                    } else if (field.length == 3) {
                        if (currdata[field[0]] && currdata[field[0]][field[1]] && currdata[field[0]][field[1]][field[2]]) {
                            col.value = currdata[field[0]][field[1]][field[2]];
                        } else {
                            col.value = null;
                        }
                    } else {
                        col.value = null;
                    }

                    if (linkIdField.length == 1) {
                        col.linkId = currdata[linkIdField[0]];
                    } else if (linkIdField.length == 2) {
                        col.linkId = currdata[linkIdField[0]][linkIdField[1]];
                    } else {
                        col.linkId = null;
                    }

                    col.cssClass = columns[colsCount].cssClass;

                    if (currdata[columns[colsCount].conditionalCssClass] != null) {
                        col.cssClass += ' ' + currdata[columns[colsCount].conditionalCssClass];
                    }

                    row.push(col);
                }

                rowData.push(row);
            }

            component.set('v.rowData', rowData);
        }), 200);
    }
})