global class ADM_RecordType {
    private static final String FIELD_NAMES = 'SystemModstamp, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, Id, Description, CreatedDate, CreatedById, BusinessProcessId';
    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';
    private static final String SQL_FROM = 'from RecordType';
    private static List<RecordType> allRecordTypes = null;

    WebService static String getId( String Name ){
        String id = '';

        try{

            RecordType r = [ Select Id from RecordType r Where Name =: Name Limit 1 ];
            id = r.id;
            return id;
        }
        catch( System.QueryException e ){

            return id;
        }
    }
    
    public static RecordType[] getAllBy( String columnName, List< String > columnValues ){
        RecordType[] els = new RecordType[0];
        try{
            String sql = SQL_SELECT + SQL_FROM + ' where ' + COM_SoqlUtils.createInClause(columnName, columnValues) + ' order by Name asc';
            els = Database.query(sql);
        }
        catch( System.Queryexception e ){}
        return els;
    }
    
    public static RecordType match( RecordType[] els, String Id ){

        for( RecordType el : els ){
            if( el.Id == Id ){
                return el;
            }
        }

        return null;
    }

    public static RecordType[]getAll(){
        return getAllAsList();
    }
    
    public static List<RecordType> getAllAsList() {
        if(allRecordTypes == null) {
            allRecordTypes = [
                select id, name
                from RecordType
		where name != NULL
                order by Name
            ];
        }

        return allRecordTypes;
    }
    
    public static Map<Id, RecordType> getAllAsMapById() {
        return mapRecordTypeListByID(getAllAsList());
    }

    public static RecordType get( String columnValue ){
        return getById(columnValue);
    }
    
    /**
     * Gets the record type with the specified ID. If no record type corresponds to the 
     * specified record type, then a null reference is returned.
     */
    public static RecordType getById(String id) {
        String soql = SQL_SELECT + SQL_FROM + ' where Id = :id limit 1';
        return first(Database.query(soql));
    }
    
    /**
     * Gets the record type corresponding to the specified name and SObjectType. If no record type
     * matches, then a null reference is returned.
     */
    public static RecordType getByName(String name, String sObjectType) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectType);
        String sobjectTypeName = targetType.getDescribe().getName();
        String soql = SQL_SELECT + SQL_FROM + ' where Name = :name and SobjectType = :sobjectTypeName limit 1';
        return first(Database.query(soql));
    }
    
    /**
     * Gets the first record type from the list of record types.
     */
    public static RecordType first(List<RecordType> recordTypes) {
        if(!recordTypes.isEmpty()) {
            return recordTypes.get(0); 
        } else {
            return null; 
        }
    }
    
    /** 
     * Gets the record type with the specified name for the specified type. If no record type matches,
     * then an ADM_ApplicationException is thrown.
     */
    public static RecordType ensureByName(String name, String sObjectType) {
        RecordType recordType = getByName(name, sObjectType);
        if(recordType == null) {
            throw new ADM_ApplicationException('No RecordType found with the name ' + name);
        }
        return recordType;
    }

    public static Map<Id, RecordType> mapRecordTypeListByID(List<RecordType> types) {
        Map<Id, RecordType> recordTypesByID = new Map<Id, RecordType>();
        for(RecordType t : types) {
            recordTypesByID.put(t.id, t);
        }
        return recordTypesByID;
    }
    
    public static Map<String, RecordType> mapRecordTypeListByName(List<RecordType> types) {
        Map<String, RecordType> recordTypesByName = new Map<String, RecordType>();
        for(RecordType t : types) {
            recordTypesByName.put(t.Name, t);
        }
        return recordTypesByName;
    }
    
    /**
     * Creates a CSS/HTML safe alias of the Record Type name. 
     */
    public static String getRecordTypeAlias(RecordType recordType) {
        if(recordType == null) {
            return null;
        }
        
        return recordType.Name.replaceAll(' ', '_').toLowerCase();
    }
    
    
    /**
     * Gets the record type specified in the URL. If no record type is specified, then a null reference is
     * returned. The following URL parameters are valid with either an ID or the name.
     *   - RecordTypeLogicalName
     *   - RecordTypeName
     *   - RecordType
     *
     * @param sObjectType The sObject type of the record type to retrieve
     */
    public static RecordType getRecordTypeFromUrl(String sObjectType) {
        Map<String, String> pageParameters = System.currentPageReference().getParameters();
         
        String recordTypeParameter = pageParameters.get('RecordTypeLogicalName');
        
        if(ADM_TextUtils.isBlank(recordTypeParameter)) {
            recordTypeParameter = pageParameters.get('RecordTypeName');
        }
        
        if(ADM_TextUtils.isBlank(recordTypeParameter)) {
            recordTypeParameter = pageParameters.get('RecordType');
        } 
        
        RecordType recordType = null;
        try{
            if(!ADM_TextUtils.isBlank(recordTypeParameter)) {
                if(ADM_TextUtils.isValidIdFormat(recordTypeParameter)) {
                    recordType = ADM_RecordType.getById(recordTypeParameter);
                } else {
                    recordType = ADM_RecordType.ensureByName(recordTypeParameter, sObjectType);
                }
            }
        }
        catch(ADM_ApplicationException ex){
            COM_PageUtils.addErrorMessageToPage(ex);
            System.debug(LoggingLevel.WARN, 'Returning null RecordType ' + ex);
        }
        return recordType;
    }
}