public class ADM_TextUtils {
    
    public static Boolean containsHTML(String content) {
        if(!ADM_TextUtils.isBlank(content)) {
            content = content.normalizeSpace();
            String strippedContent = content.stripHtmlTags();
            if(content.length() > strippedContent.length()) {
                //the original content must have contained an html tag as the stripped version is shorter
                return true;
            }
        } 
        //field is empty or doesn't contain html tags
        return false;
    } 
    
    public String replaceEOL(String s) {
        return s.replaceAll('\\n', '<br/>');    
    }  

    public static String replaceBR(String s) {  
        return s.replaceAll('<br/>','\n');  
    }  

    public static String unescapeBR(String s) {  
        return s.replaceAll('&lt;br/&gt;','<br/>');  
    }  
    
    public String escapeAmpersand(String s) {
        return s.replaceAll('&', '&amp;');
    }
    
    public String escapeHTML(String s) {        
        return escapeForwardSlash(escapeDoubleQuote(escapeSingleQuote(escapeGt(escapeLt(escapeAmpersand(s))))));
    }
    
    public String unEscapeHTML(String s) {
        s = s.replaceAll('&amp;', '&');
        s = s.replaceAll('&lt;', '<');
        s = s.replaceAll('&gt;', '>');
        s = s.replaceAll('&#39;', '\'');
        s = s.replaceAll('&quot;', '"');
        return s.replaceAll('&#47', '/');
    }
    
    public String escapeSingleQuote(String s) {
        return s.replace('\'', '&#39;');
    }
    
    public String escapeGt(String s) {
        return s.replaceAll('>', '&gt;');
    }
    
    public String escapeLt(String s) {
        return s.replaceAll('<','&lt;');
    }
    
    public String escapeGtAndLt(String s) {
        return escapeGt(escapeLt(s));
    }
    
    public String escapeDoubleQuote(String s) {
        return s.replace('"', '&quot;');        
    }
    
    public String replaceSingleQuotes(String s) {       
        String escapeSingleQuote = '\'';
        
        if(s.startsWith(escapeSingleQuote) && s.endsWith(escapeSingleQuote)) {
            s = s.substring(1,s.length() - 1);
        }
        
        return s;
    }
    
    public String escapeForwardSlash(String s) {
        return s.replaceAll('/','&#47;');
    }
    
    public static String oldSchoolSalesforceID(String id) {
        return id.substring(0,15);
    }
    
    /**
     * Determines if the value specified is whitespace, an empty string, or null 
     */
    public static Boolean isBlank(String value) {
        return value == null || value.length() == 0 || value.trim().length() == 0;
    }
    
    /**
     * Determines if the value specified is null.
     */
    public static Boolean isNull(String value) {
        return value == null;
    }
    
    /**
     * Removes the trailing comma and all whitespace after.
     */
    public static String removeTrailingComma(String s) {
        if(s != null) {
            if(s.endsWith(', ') || s.endsWith(',')) {
                s = s.substring(0, s.lastIndexOf(','));
            }
        }
        
        return s;
    }
    
    /**
     * Converts the string value to a boolean. The values 'true' and '1' evaluate to true, the values 'false' and '0' evaluate to false.
     * All other values throw a ADM_UnexpectedValueException.
     */
    public static Boolean toBoolean(String s) {
        if(s.equalsIgnoreCase('true') || s.equals('1')) {
            return true;
        } else if(s.equalsIgnoreCase('false') || s.equals('0')) {
            return false;
        } else {
            throw new ADM_UnexpectedValueException('Provided string must be of the type: true or false, 1 or 0');
        }
    }
    
    /**
     * Converts the string value to a double. Throws a ADM_UnexpectedValueException if the value can't be converted.
     */
    public static Double toDouble(String s) {
        if(Pattern.matches('\\d.*',s)) {
            return Double.valueOf(s);
        } else {
            throw new ADM_UnexpectedValueException('Provided string must be a double');
        }
    }
    
    /*
      Wrapper of UTF-8 decoding
    */
    
    public Static String getUTF8DecodedValue(String value){
        String decodedValue = value;
        try{
            if(!ADM_TextUtils.isBlank(value)){
                decodedValue = EncodingUtil.urlDecode(value,'UTF-8');
            }
        }
        catch(System.StringException sE){
            System.debug(LoggingLevel.ERROR,'Error while decoding '+ sE);
        }
        return decodedValue;
    }
    
    /*
      Wrapper of UTF-8 encoding
    */
    
    public Static String getUTF8EncodedValue(String value){
        String encodedValue = value;
        try{
            if(!ADM_TextUtils.isBlank(value)){
                encodedValue = EncodingUtil.urlEncode(value,'UTF-8');
            }
        }
        catch(System.StringException sE){
            System.debug(LoggingLevel.ERROR,'Error while encoding '+ sE);
        }
        return encodedValue;
    }

    /** 
     * Utility method to convert a string of ids to ids
     */

    public static Set<Id> convertSetOfStringToIds(Set<String> stringIds){
        Set<Id> ids = new Set<Id>();
        for(String stringId: stringIds){
            ids.add(stringId);
        }

        return ids;

    }
        
  
    /** 
     * Concatenates the set of strings so that the delimiter is placed between each.
     *
     * Since the order within the Set is not guaranteed, neither is the order of the returned
     * items in the string.
     */
    public static String joinSet(Set<String> values, String delimiterValue) {
        Boolean firstValue = true;
        String joined = '';
        for(String value : values) {
            if(!firstValue) {
                joined += delimiterValue;
            } else {
                firstValue = false;
            }
            joined += value;
        }
        return joined;
    }

    public static Set<Id> joinListValues(List<Set<Id>> values){
        return ADM_TextUtils.joinSetValues(new Set<Set<Id>>(values));
    }

    public static Set<String> joinListValues(List<Set<String>> values){
        return ADM_TextUtils.joinSetValues(new Set<Set<String>>(values));
    }

    public static Set<String> joinSetValues(Set<Set<String>> values){
        Set<String> joinedSet = new Set<String>();
        for(Set<String> value : values){
            joinedSet.addAll(value);
        }
        return joinedSet;
    }

    public static Set<Id> joinSetValues(Set<Set<Id>> values){
        Set<Id> joinedSet = new Set<Id>();
        for(Set<Id> value : values){
            joinedSet.addAll(value);
        }
        return joinedSet;
    }
    
    
     /** 
     * Concatenates the list of strings so that the delimiter is placed between each.
     */
    public static String joinList(List<String> values, String delimiterValue) {
        String joined = '';
        for(Integer index = 0; index < values.size(); index++) {
            joined += values.get(index);
            if(index < values.size() - 1) {
                joined += delimiterValue;
            }
        }
        return joined;
    }
    
    public static Boolean isId(String sObjectId, String keyPrefix) {
        if(sObjectId.startsWith(keyPrefix) && (sObjectId.length() >= 15 && sObjectId.length() <= 18)) {
            return true;
        } else {
            return false;
        }
    }
    
    public static Boolean isValidIdFormat(String Id) {
        if(Id.length() >=15 && Id.length() <=18) {
            return true;
        } else {
            return false;
        }
    }

    public static Boolean isValidId(String Id) {
        try {
            Id testId = Id;
            return true;
        } catch(System.Exception e) {
            return false;
        }
    }

    public String stripHtmlTagsAndUnescapeHtml(String content){
        String result = unEscapeHTML(content.stripHtmlTags());
        return result;
    }

    //validates a string is in ID format using pattern matching id
    static public Boolean validateId(String idParam) {
        if(null == idParam){
            return false;
        }
        String id = String.escapeSingleQuotes(idParam);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return true;
        }
        return false;
    }

    static public Boolean validateIDWithObjPrefix(String prefix, String idParam){
        if(idParam.startsWithIgnoreCase(prefix)){
            return validateId(idParam);
        }

        return false;
    }
    private static final String nbsp = '&nbsp;&nbsp;&nbsp;&nbsp;';
    public static String toHTML( String s ) {

        String htmlString = '';
        Integer iCount = 0;
        String charExtracted = '';
        Integer iCharCodeAt = 0;

        Pattern lf = Pattern.compile('[\\n]');
        htmlString = lf.matcher( s ).replaceAll('<br />');

        Pattern tab = Pattern.compile('[\\t]');
        htmlString = tab.matcher( htmlString ).replaceAll('&nbsp;&nbsp;&nbsp;&nbsp;');

        return htmlString;
    }
    
     /**
     * Determines if no value was selected on a pick list. 
     */
    public static Boolean isNoneSelected(String value) {
        if( ADM_TextUtils.isBlank(value)) {
            return true;
        } else if(value.equalsIgnoreCase('--none--')) {
            return true;
        } else if(value.replaceAll('\\n','').replaceAll('\\s','').length() == 0) {
            return true;
        } else {
            return false;
        }
    }
    
    //some apis such as the apex:charts Javascript utlilitys require the namespace prefix to be agf. vs 
    public static String escapeNameSpace(String namespace) {
        return namespace.replace('__', '.');
    }

    /*some remote method calls fail if correct namespaced object name is not used for Schema describe calls. 
     below method call will make sure the object name is prefixed with namespace and if not will add namespace 
     prefix to the string if available.

    */
    public static String makeQualifiedName(String name) {
        ADM_ConstantsSingleton singletonInstance = ADM_ConstantsSingleton.getInstance();
        if(singletonInstance.isPackagedOrg() && name.endsWithIgnoreCase('__c')){//Only do this if this is a packaged or and a Custom object that ends with __c [Objects such as Account, User etc will be spared.]
            if(!name.startsWithIgnoreCase(singletonInstance.getNameSpace())){
                name = singletonInstance.getNameSpace() + name;
            }
        }

        return name;
        
    }

    public static Boolean areIdsEqual(String id1, String id2){
        Boolean areIdsEqual = false;
        if(null == id1 || null == id2){
            areIdsEqual = (id1 == id2);
        }
        else if(id1.length() == 15 && id2.length() == 15 && id1.equals(id2)){//Incase they are 15 character long and case sensitive - 
            areIdsEqual = true;
        }
        else if(id1.length() == 18 && id2.length() == 18 && id1.equalsIgnoreCase(id2)){ //18 character long and case insensitive
            areIdsEqual = true;
        }
        
        return areIdsEqual;
    }
 
}