/*
 * Copyright (c) 2012, salesforce.com, inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the
 * following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 * the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or
 * promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

public class RemoteTKController {
    private static String makeError(String message, String errorCode) {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('message', message);
        gen.writeStringField('errorCode', errorCode);
        gen.writeEndObject();
        gen.writeEndArray();
        
        return gen.getAsString();
    }
    
    private static String writeFields(String objtype, SObject obj, String fields) {
        Map<String, Object> fieldMap = null;
        try {
            fieldMap = (Map<String, Object>)JSON.deserializeUntyped(fields);
        } catch (JSONException je) {
            return makeError(je.getMessage(), 'JSON_PARSER_ERROR');
        }
        String qualifiedObjtype = ADM_TextUtils.makeQualifiedName(objtype);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(qualifiedObjtype);
        
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        
        try {
            for (String key : fieldMap.keySet()) {
                if (targetFields.get(key) == null) {
                    return '[{"message":"Field '+key+' does not exist on object type '+qualifiedObjtype+'","errorCode":"INVALID_FIELD"}]';
                }
                
                Object value = fieldMap.get(key);
                Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
                
                if (value instanceof String && valueType != Schema.DisplayType.String) {
                    // Coerce an incoming String to the correct type
                    String svalue = (String)value;
                    
                    if (valueType == Schema.DisplayType.Date) {
                        obj.put(key, Date.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Percent ||
                           valueType == Schema.DisplayType.Currency) {
                        obj.put(key, svalue == '' || svalue == null ? null : Decimal.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Double) {
                        obj.put(key, svalue == '' || svalue == null ? null : Double.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Integer) {
                        obj.put(key, Integer.valueOf(svalue));
                    } else {
                        obj.put(key, svalue);
                    }
                } else {
                    // Just try putting the incoming value on the object
                    obj.put(key, value);
                }
            }
        } catch (SObjectException soe) {
            System.debug('writeFields() SObjectException:' + soe + ' stacktace:' + soe.getStackTraceString());
            return makeError(soe.getMessage(), 'INVALID_FIELD');
        } catch (Exception e) {
            System.debug('writeFields() Exception:' + e + ' stacktace:' + e.getStackTraceString());
            return makeError(e.getMessage(), 'INVALID_FIELD');
        }
        
        return null;
    }
    
    @remoteAction
    public static String describe(String objtype) {
        // Just enough to make the sample app work!
        String qualifiedObjtype = ADM_TextUtils.makeQualifiedName(objtype);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(qualifiedObjtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        
        Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
        
        List<Object> fields = new List<Object>();
        for (String key : fieldMap.keySet()) {
            Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
            Map<String, Object> field = new Map<String, Object>();
            
            field.put('type', descField.getType().name().toLowerCase());
            field.put('name', descField.getName());
            field.put('label', descField.getLabel());
            List<String> references = new List<String>();
            for (Schema.sObjectType t: descField.getReferenceTo()) {
                references.add(t.getDescribe().getName());
            }
            if (!references.isEmpty()) {
                field.put('referenceTo', references);
            }
            
            fields.add(field);
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('fields', fields);
        
        return JSON.serialize(result);
    }
    
    @remoteAction
    public static String create(String objtype, String fields) {
        String qualifiedObjtype = ADM_TextUtils.makeQualifiedName(objtype);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(qualifiedObjtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        
        SObject obj = targetType.newSObject();

        String error = writeFields(qualifiedObjtype, obj, fields);
        if (error != null) {
            return error;
        }
        Schema.DescribeSObjectResult targetDescribeResult = targetType.getDescribe();
        if (!targetDescribeResult.isCreateable()){
            error = 'Your user account does not have permission to create objects of type:' + obj; 
            return error;
        }    

        
        
        try {
            insert obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('id', obj.id);
        result.put('errors', new List<String>());
        result.put('success', true);
        
        return JSON.serialize(result);
    }
    
     @remoteAction
    public static String retrieve(String objtype, String id, String fieldlist) {
        
        //if no field list was specified, then retrieve a list of all of the fields for the object
        //otherwise, use the field list for the query
        String qualifiedObjtype = ADM_TextUtils.makeQualifiedName(objtype);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(qualifiedObjtype);
        String accessibleFieldList = '';
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        } else  {
            Schema.DescribeSObjectResult targetDescribeResult = targetType.getDescribe();
            if (!targetDescribeResult.isAccessible()){
                System.debug('retieve() returning Your user account does not have permission to view OBJECTS of type:' + objtype);
                return makeError('Your user account does not have permission to view objects of type:' + objtype, 'NOT_VISIBLE'); 
            }  
        }
        
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        //if field list is null build a list of all fields - these will be checked later for visbility  
        if(fieldlist == null || fieldlist == '') {
            fieldlist = '';
            for (String field : targetFields.keySet()) {
                if (fieldlist.length() > 0) {
                    fieldlist += ',';
                }
                fieldlist += field;
            }
            
        } else {
        
            Boolean containsId = false;
            for (String field : fieldlist.split(',')) {
                if (field.equalsIgnoreCase('id')){
                    containsId = true;
                    break;
                }
            }
        
            if (!containsId) {
                fieldlist = 'Id,'+fieldlist;
            }
        }
        //finally check that each field is viewable (could be hidden by FLS)
        for (String field : fieldlist.split(',')) {
            //check fields are part of the object
            if (targetFields.containsKey(field)) {
                Schema.DescribeFieldResult dr = targetFields.get(field).getDescribe();
                //only add the field to the query list if its accessible
                if (dr.isAccessible()){
                    if (accessibleFieldList.length() > 0) {
                        accessibleFieldList += ',';
                    }
                    accessibleFieldList += field;
                } else {
                    System.debug('retieve()  Your user account does not have permission to view FIELD: ' + field + ' for object: ' + objtype + ' so it wont be included in the query');
                }      
            }
        }
        
        String soql = 'SELECT '+accessibleFieldList+' FROM '+qualifiedObjtype+' WHERE Id = \''+id+'\'';
        List<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return makeError(qe.getMessage(), 'INVALID_QUERY');
        }
        
        return JSON.serialize(records[0]);
    }
    
    @remoteAction
    public static String upser(String objtype, String externalIdField, String externalId, String fields) {
        String qualifiedObjtype = ADM_TextUtils.makeQualifiedName(objtype);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(qualifiedObjtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        
        SObject obj = targetType.newSObject(externalId);
        
        String error = writeFields(qualifiedObjtype, obj, fields);
        if (error != null) {
            return error;
        }
        
        Schema.DescribeSObjectResult targetDescribeResult = targetType.getDescribe();
        if (!targetDescribeResult.isCreateable() && targetDescribeResult.isUpdateable()){
            error = 'Your user account does not have permission to upsert objects of type:' + objtype;
            return error;
        }  
        
        Schema.SObjectField sobjField = targetType.getDescribe().fields.getMap().get(externalIdField);
        
        Database.Upsert(obj, sobjField);
        
        return null;
    }

    @remoteAction
    public static String updat(String objtype, String id, String fields) {
        String qualifiedObjtype = ADM_TextUtils.makeQualifiedName(objtype);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(qualifiedObjtype);
        
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        
        SObject obj = targetType.newSObject(id);
        
        String error = writeFields(qualifiedObjtype, obj, fields);
        if (error != null) {
            return error;
        }
        
        Schema.DescribeSObjectResult targetDescribeResult = targetType.getDescribe();
        if (!targetDescribeResult.isUpdateable()){
            error = 'Your user account does not have permission to update objects of type:' + objtype;
            return error;
        } 

        try {
            update obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        return null;
    }

    @remoteAction
    public static String del(String objtype, String id) {
        String qualifiedObjtype = ADM_TextUtils.makeQualifiedName(objtype);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(qualifiedObjtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        } else {
            Schema.DescribeSObjectResult targetDescribeResult = targetType.getDescribe();
            if (!targetDescribeResult.isDeletable()){
                return makeError('Your user account does not have permission to delete objects of type:' + objtype, 'NOT_ALLOWED');
            } 
        }
        
        SObject obj = targetType.newSObject(id);
        
        try {
            delete obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        return null;
    }

    @remoteAction
    public static String query(String soql) {
        List<sObject> records = new List<sObject>();
        //parse soql for object name so that we can check the user has permission to access it
        String objectName = COM_SoqlUtils.parseSOQLForObjectName(soql);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        if (targetType == null) {
            System.debug('RemoteTKController.query() unrecognized object name:' + objectName);
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        } else {
            Schema.DescribeSObjectResult targetDescribeResult = targetType.getDescribe();
            if (!targetDescribeResult.isAccessible()){
                return makeError('Your user account does not have permission to view objects of type:' + objectName, 'NOT_ALLOWED');
            } 
            //finally check that each field is viewable (could be hidden by FLS)
            Map<String,Schema.DescribeFieldResult> finalMap = new Map<String, Schema.DescribeFieldResult>();
            // map of all fields in the object
            Map<String, Schema.SObjectField> objectFields = targetDescribeResult.fields.getMap();
            List<String> fields = COM_SoqlUtils.parseSOQLForFieldList(soql);
            for(String field : fields){
                // check fields are part of the object
                if (objectFields.containsKey(field)) {
                  Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
                  if (!dr.isAccessible()){
                        return makeError('Your user account does not have permission to view field ' + field + ' for object ' + objectName, 'NOT_ALLOWED');
                    }      
                }
            }
        }
        
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return makeError(qe.getMessage(), 'INVALID_QUERY');
        } 
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);
        
        return JSON.serialize(result);
    }

    
    
    
    
}