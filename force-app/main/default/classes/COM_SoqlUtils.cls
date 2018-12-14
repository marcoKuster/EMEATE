public with sharing class COM_SoqlUtils {
    /**
     * Create the IN clause for dynamic SOQL queries
     */
    public static String createInClause(String expression, List<String> values) {
        String inValues = '';
        for(Integer index = 0; index < values.size(); index++) {
            String columnValue = values.get(index);
            if(columnValue == null) {
                continue;
            }
            
            if(index > 0){
                inValues += ',';
            }
            inValues = inValues + '\'' + String.escapeSingleQuotes(columnValue) + '\'';
        }
        return String.escapeSingleQuotes(expression) + ' in (' + inValues + ')'; 
    }

    /**
     * Create the IN clause for dynamic SOQL queries
     */
    public static String createNotInClause(String expression, List<String> values) {
        String inString = createInClause(expression, values);
        return inString.replace(' in ', ' not in ');
    }


    /**
     * Create the IN clause for dynamic SOQL queries
     */
    public static String createInClause(String expression, Set<String> values) {
        List<String> listValues = new List<String>(values);
        return createInClause(expression,listValues);
    }
    
    public static String createOrder(String expression, String order) {
        if(null != expression){
            return String.escapeSingleQuotes(expression) + ' ' + (order != null && order.equalsIgnoreCase('DESC')? 'DESC' : 'ASC');
        }
        else{
            return '';
        }
    }

    public static String convertToQualifiedQuery(String sql){
        if((ADM_ConstantsSingleton.getInstance()).isPackagedOrg()){//Not even do anything if not in a packaged org - just return the input query
            sql = makeQualifiedQuery(sql);
        }
        return sql;
    }
    
    @TestVisible
    private static String makeQualifiedQuery(String sql){
        String originalSql =sql;
        String nameSpace = (ADM_ConstantsSingleton.getInstance()).getNameSpace();
        if(!ADM_TextUtils.isBlank(nameSpace)){//Only do this if the org has a namespace or else return the input query.
            try{
                System.debug('Calling makeQualifiedQuery to attach namespace to custom fields and CustomObject');
                String modifiedQuery ='';
                Set<String> namesToBeQualified = new Set<String>();
                String[] spintSOQL;
                modifiedQuery = sql.replaceAll(',', ' ').replaceAll('\\(',' ').replaceAll('\\)',' ');
                spintSOQL = modifiedQuery.split('[\\s]+');
                for(String iter:spintSOQL){
                    if(iter.containsIgnoreCase('__c') || iter.containsIgnoreCase('__r')){
                        String api_Name = iter.replaceAll('\\(','').replaceAll('\\)','');
                        String unQualifiedName = '';
                        if(api_Name.contains('__r')){
                            if(api_Name.contains('.') && api_Name.containsIgnoreCase('__c')){
                                String relatedObjField = api_Name.substringAfter('.');
                                unQualifiedName = relatedObjField.replace(relatedObjField.substringAfter('__c'),'');
                            }
                            else{
                                unQualifiedName = api_Name.replace(api_Name.substringAfter('__r'),'');
                            }
                        }
                        else if(api_Name.contains('.') && api_Name.containsIgnoreCase('__c')){
                            String relatedObjField = api_Name.substringAfter('.');
                            unQualifiedName = relatedObjField.replace(relatedObjField.substringAfter('__c'),'');
                        }
                        else{
                            unQualifiedName = api_Name.replace(api_Name.substringAfter('__c'),'');
                        }

                        //Adding this condition for using this method from ADM_SprintVirtualWallController. We remove anything in from of the string by doing this. 
                        //In the sprint controller the method's input is a json so Status__c actually ends up as "Status__c or {"Status__c. So we only include the substring after the double quotes.
                        if(unQualifiedName.contains('"')){
                            unQualifiedName = unQualifiedName.substringAfter('"');
                        }
                        

                        if(!unQualifiedName.startsWithIgnoreCase(nameSpace) || unQualifiedName.lastIndexOfIgnoreCase(nameSpace) > 0){//Needed for words with unQualifiedName in between for eg: ADM_Deleted_Task__c will become ADM_Deleted_Task__c since Task__c will be replaced by Task__c
                            namesToBeQualified.add(unQualifiedName);
                        }

                        
                    }
                }
                if(namesToBeQualified.size() == 0){
                    return sql;
                }
                for(String qualifiedName: namesToBeQualified){
                    String replacement = nameSpace+qualifiedName;
                    if(qualifiedName.lastIndexOfIgnoreCase(nameSpace) > 0){
                        replacement = qualifiedName.replaceAll(nameSpace, '');
                        replacement = nameSpace + replacement;
                    }
                    sql = sql.replaceAll(qualifiedName, replacement);
                }
                sql = makeQualifiedQuery(sql);
            }
            catch(Exception exp){
                System.debug(' Exception occured while doing convertToQualifiedQuery returning input sql itself '+ exp.getMessage() );
                sql = originalSql;//Some exception occured so let's fall back to the originalSql we started with
            }
        }

        return sql;
    }
    
    public static String parseSOQLForObjectName(String soql) {
        String objectName = '';
        if(soql != null) {
            soql = soql.toLowerCase();
            if(soql.contains('from')) {
                Integer indexOfFrom = soql.indexOf('from');
                //add 5 characters to account for the 4 chars in 'from' plus the space before the object name starts
                Integer indexStart = indexOfFrom + 5;
                //find the index of the next space after the object name 
                Integer indexEnd = soql.indexOf(' ', indexStart);
                objectName = soql.substring(indexStart, indexEnd);
            } 
        }
        
        return objectName;
    }
    
    public static List<String> parseSOQLForFieldList(String soql) {
        List<String> fields = new List<String>();
        soql = soql.toLowerCase();
        Integer indexOfSelect = soql.indexOf('select');
        //add 7 to account for the word 'select' plus the space
        indexOfSelect = indexOfSelect + 7;
        Integer indexOfFrom = soql.indexOf('from');
        String soqlFields = soql.substring(indexOfSelect, indexOfFrom);
        fields = soqlFields.split(',');
        return fields;
        //added brace
    }    

    
    public static Boolean checkObjectAccessibility(String sObjectName){
            Boolean isObjectAccessible = false;

            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ADM_ConstantsSingleton.getInstance().getNameSpace() + sObjectName);

            if (targetType != null) {
                Schema.DescribeSObjectResult targetDescribeResult = targetType.getDescribe();

                //check if the user has access to this object

                isObjectAccessible = targetDescribeResult.isAccessible();

            }

            return isObjectAccessible;

    }

}