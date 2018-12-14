public class ADM_CoreValues {
    
    public static final String LINK_KEY = 'Link'; 
    private ADM_UserCache userCache;
    private Map<Id,RecordType> recordTypesById;
    
    public ADM_CoreValues(ADM_UserCache userCache, Map<Id,RecordType> recordTypesById) {
        this.userCache = userCache;
        this.recordTypesById = recordTypesById;
    }
    
    /**
     * Creates a map of values from the given work object
     */
    public Map<String, String> getCoreValues(ADM_Work__c work, Boolean isInsert) {
        
        
        String recordTypeName = recordTypesById.get(work.RecordTypeId).Name;
        Map<String, String> coreValues = new Map< String, String >();
        Set<String> labels = getKeys(recordTypeName, isInsert);
        Sobject s = work;

        for(String label : labels) {
            try {
                if(label.equalsIgnoreCase('link')) {
                    String gusUrlLink = ADM_WorkUtils.GUS_URL + '/' + String.valueOf(s.get('Id'));
                    coreValues.put(label, '<a href="' + gusUrlLink + '">' + gusUrlLink + '</a>');
                } else {
                    //convert label to field name
                    String name = label.replaceAll(' ','_') + '__c'; 
                    
                    //create the foreign key name
                    String fkName = name.replaceAll('__c', '_Name__c');
                    
                    //get the value of the object from the sobject
                    String value = String.valueOf(s.get(name));
                    if(value == null) {
                        value = '';
                    }
                    
                    if(label.equalsIgnoreCase('type')) {
                        if(recordTypeName == ADM_Work.BUG_RECORD_TYPE_NAME) {
                            coreValues.put(label, recordTypeName);
                            if(value != null && !ADM_Work.LEGACY_TYPES.contains(value) && value != 'User Story') {
                                coreValues.put(label, value);
                            }
                        } else {
                            coreValues.put(label, recordTypeName);
                        }
                    }
                    else if(label.equalsIgnoreCase('Description')){//https://gus.my.salesforce.com/apex/adm_userstorydetail?id=a07B0000000dypR&sfdc.override=1
                        name = 'Details__c';
                        value = String.valueOf(s.get(name));//User story requirement - truncate is not required because ADM_ChangeListMessage.CoreValueWriter truncates it after 3200..Let's use that and be standard across all the fields.
                        coreValues.put(label, value);
                        
                    }
                    else if((label.equalsIgnoreCase('assignee') || label.equalsIgnoreCase('cs contact') || label.equalsIgnoreCase('qa engineer')) && value.length() > 0 && userCache.contains(value)) {
                        User user = userCache.getById(value);
                        if(user == null) {
                            
                            continue;
                        }
                        
                        try {
                            if(label.equalsIgnoreCase('qa engineer')) {
                                if(recordTypeName.equals(ADM_Work.RECORD_TYPE_NAME_USERSTORY) || recordTypeName.equals(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION) || recordTypeName.equals(ADM_Work.BUG_RECORD_TYPE_NAME)) {
                                    coreValues.put(label, user.Name);
                                }
                            } else {
                                coreValues.put(label, user.Name);
                            }
                        } catch(Exception exc) {
                            
                            coreValues.put(label, user.Id);
                        }
                    } else if(ADM_Work.FK_VALUES_MAP.containsKey(fkName)) {
                        coreValues.put(label, String.valueOf(s.get(fkName)));
                    } else {
                        coreValues.put(label, value); 
                    }
                }
                
            } catch (System.Exception e) {
                
            }
        }
        
        //FIXME why does this key get removed during updates?
        if(!isInsert) {
            
            coreValues.remove('Details and Steps to Reproduce');
        }

        return coreValues;
    }
    
    public static List< String > keys(){
        List< String > keys = new List< String >();
        
        keys.add(LINK_KEY);
        keys.add('Type');
        keys.add('Subject');
        keys.add('Product Tag');
        keys.add('Scheduled Build');
        keys.add('Priority');
        keys.add('Status');
        keys.add('Help Status');
        keys.add('Assignee');
        keys.add('QA Engineer');
        keys.add('Scrum Team');
        keys.add('CS Contact');
        keys.add('Severity Level');
        keys.add('Details and Steps to Reproduce');
        keys.add('Description');
        
        return keys;
    }
    
    public static Map<String,Set<String>> getKeysByRecordType() {
        Map<String,Set<String>> keysByRecordType = new Map<String,Set<String>>();
        Set<String> keysAll = new Set<String>();
        keysAll.addAll(ADM_CoreValues.keys());
        keysAll.remove('CS Contact');
        keysAll.remove('Severity Level');
        
        Set<String> keysInvestigation = new Set<String>();
        keysInvestigation.addAll(ADM_CoreValues.keys());
        keysInvestigation.remove('Priority');
        keysInvestigation.remove('Help Status');
        keysInvestigation.remove('Scheduled Build');
        
        Set<String> keysTodo = new Set<String>();
        keysTodo.addAll(ADM_CoreValues.keys());
        keysTodo.remove('QA Engineer');
        
        keysByRecordType.put(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION, keysInvestigation);
        keysByRecordType.put(ADM_Work.RECORD_TYPE_NAME_TODO, keysTodo);
        keysByRecordType.put(ADM_Work.RECORD_TYPE_NAME_USERSTORY, keysAll);
        keysByRecordType.put(ADM_Work.BUG_RECORD_TYPE_NAME, keysAll);
        keysByRecordType.put(ADM_Work.TEMPLATE_RECORD_TYPE_NAME, keysAll);
        
        return keysByRecordType;
    }
    
    public static Set<String> getKeys(String recordTypeName, Boolean isInsert) {
        Set<String> keys = getKeysByRecordType().get(recordTypeName);
        if(!isInsert) {
            keys.remove('Details and Steps to Reproduce');
        }
        return keys;
    }
    
    /**
     * Creates a map of values from the given work object
     */
    public static Map<String, String> getCoreValues(Boolean isInsert, ADM_Work__c work, Map<Id, User> uMap, Map<Id,RecordType> workRecordTypesById) {
        return getCoreValues(isInsert, work, new ADM_UserCache(uMap), workRecordTypesById);
    }
    
    /**
     * Creates a map of values from the given work object
     */
    public static Map<String, String> getCoreValues(Boolean isInsert, ADM_Work__c work, ADM_UserCache userCache, Map<Id,RecordType> workRecordTypesById) {
        ADM_CoreValues coreValues = new ADM_CoreValues(userCache, workRecordTypesById);
        return coreValues.getCoreValues(work, isInsert);
    }

    /**
     * Creates a map of values for the given work object as if it were updated.
     */
    public static Map<String, String> getCoreValues(ADM_Work__c w, Map<Id, User> uMap, Map<Id,RecordType> workRecordTypesById) {
        return getCoreValues(false, w, uMap, workRecordTypesById);
    }


   
}