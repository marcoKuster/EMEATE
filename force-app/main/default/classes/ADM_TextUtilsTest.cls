@isTest 
public class ADM_TextUtilsTest {

 testMethod static void testReplaceSingleQuotes() {
        ADM_TextUtils textUtils = new ADM_TextUtils();
        String s = '\'test\'';      
        System.assertEquals(textUtils.replaceSingleQuotes(s).equalsIgnoreCase('test'), true);
        
        s = 'test';
        System.assertEquals(textUtils.replaceSingleQuotes(s).equalsIgnoreCase('test'), true);
    }
    
    
    testMethod static void testEscapeHTML() {
        String s = '\'<>"/';
        ADM_TextUtils textUtils = new ADM_TextUtils();
        
        System.assert(textUtils.escapeHTML(s).contains('>') != true, 'Not expecting to see the greater than symbol!');
        System.assert(textUtils.escapeHTML(s).contains('<') != true, 'Not expecting to see the less than symbol!');
        System.assert(textUtils.escapeHTML(s).contains('\'') != true, 'Not expecting to see the single quote symbol!');
        System.assert(textUtils.escapeHTML(s).contains('"') != true, 'Not expecting to see the double quote symbol!');
        System.assert(textUtils.escapeHTML(s).contains('/') != true, 'Not expected to see the forward slash symblol! + _' + textUtils.escapeHTML(s).contains('/') + '_');
    }
    
   testMethod static void testReplaceEOL() {
        String s = '\\n';
        ADM_TextUtils tu = new ADM_TextUtils();
        
        System.assert(tu.replaceEOL(s).contains('<') != true, 'Where is the less than symbol?');
    }
    
    testMethod static void testEscapeGtAndLt() {
        String s = '<>';
        ADM_TextUtils textUtils = new ADM_TextUtils();
        
        System.assert(textUtils.escapeGtAndLt(s).contains('>') != true, 'Not expecting to see the greater than symbol!');
        System.assert(textUtils.escapeGtAndLt(s).contains('<') != true, 'Not expecting to see the less than symbol!');
    }
    
    testMethod static void testIsBlank() {
        System.assertEquals(true, ADM_TextUtils.isBlank(null), 'Expected isBlank(null) to return true');
        System.assertEquals(true, ADM_TextUtils.isBlank(''), 'Expected isBlank(\'\') to return true');
        System.assertEquals(true, ADM_TextUtils.isBlank(' '), 'Expected isBlank(\' \') to return true');
        System.assertEquals(false, ADM_TextUtils.isBlank('a'), 'Expected isBlank(\' \') to return true');
    }
    
  
    
    testMethod static void testJoinSet() {
        System.assertEquals('', ADM_TextUtils.joinSet(new Set<String>(), ','), 'Expected joinSet to return an empty string when the list is empty');
        System.assertEquals('apple', ADM_TextUtils.joinSet(new Set<String>{'apple'}, ','), 'Expected joinSet to return the item (with no commas)');
        
        //order cannot be guaranteed so each item needs to be checked against
        //the returned comma separated value
        String actual = ADM_TextUtils.joinSet(new Set<String>{'apple', 'banana'}, ',');
        String[] actualSplit = actual.split(',');
        System.assertEquals(2, actualSplit.size(), 'The list should contain the two items separated by a comma'); 
        for(String expected : new Set<String>{'apple', 'banana'}) {
            Boolean found = false;
            for(String actualItem : actualSplit) {
                if(expected == actualItem) {
                    found = true;
                    break;
                }
            }
            
            System.assert(found, 'Expected joinSet to contain the item: ' + expected);
        }
    }
   
    
    testMethod static void testJoinList() {
        System.assertEquals('', ADM_TextUtils.joinList(new List<String>(), ','));
        System.assertEquals('apple', ADM_TextUtils.joinList(new List<String>{'apple'}, ','));
        System.assertEquals('apple,banana', ADM_TextUtils.joinList(new List<String>{'apple', 'banana'}, ','));
    }
      
      
   testMethod static void testjoinListValues() {
        List<Set<String>> listValues = new List<Set<String>>();
        Set<String> setValue =new Set<String>{'apple'};
        listValues.add(setValue);
        System.assert(ADM_TextUtils.joinListValues(listValues).contains('apple'));
   }     

    testMethod static void testToHTML(){
        String s = '';
        //FIXME how is this is a comprehensive test?
        System.assertEquals( s, ADM_TextUtils.toHTML( s ) );
    }
    
     
   
    
    testMethod static void testIsNoneSelected() {
        System.assert(ADM_TextUtils.isNoneSelected(null), 'Expected isNoneSelected to return true when value is null');
        System.assert(ADM_TextUtils.isNoneSelected(''), 'Expected isNoneSelected to return true when value is an empty string');
        System.assert(ADM_TextUtils.isNoneSelected('--None--'), 'Expected isNoneSelected to return true when value is the default picklist value of --None--');
        System.assert(ADM_TextUtils.isNoneSelected('  '), 'Expected isNoneSelected to return true when value is a whitespace string.');
        System.assert(ADM_TextUtils.isNoneSelected('\n'), 'Expected isNoneSelected to return true when value is a whitespace string.');
    }
    
    /*
     @testcaseID  a1DB00000000kSv
     @userstoryID a07B0000000DlSE
     @Hierarchy GUS.ScrumforcetoGUS.ScrumTeams.New Chatter Group
     @ExpectedResults User is able to click on these chatter groups
     @Author = Alexis Williams
    */
    testMethod static void testRemoveTrailingCommas() {
        String s;
        System.assertEquals(null, ADM_TextUtils.removeTrailingComma(s));
        
        s = '';
        System.assertEquals(s, ADM_TextUtils.removeTrailingComma(s));
        
        s = ', ';
        System.assertEquals('', ADM_TextUtils.removeTrailingComma(s));
        
        s = 'test, test,';
        System.assertEquals('test, test', ADM_TextUtils.removeTrailingComma(s));
    }
    
    testMethod static void testIsValidIdFormat() {
        String shortId = '1234';
        String longId = '1234567890123456';
        System.assert(ADM_TextUtils.isValidIdFormat(shortId) == false,'short id is ' + shortId.length() + ' characters short and the is valid is format is ' + ADM_TextUtils.isValidIdFormat(shortId));
        System.assert(ADM_TextUtils.isValidIdFormat(longId) == true,'long id is ' + longId.length() + ' characters long and the is valid is format is ' + ADM_TextUtils.isValidIdFormat(longId));
    }
    
    testMethod static void testIsId() {
        String keyPrefixBuild = Schema.SObjectType.ADM_Build__c.getKeyPrefix();
        ADM_Build__c build = ADM_Build.createTestBuild();
        String buildId = keyPrefixBuild + '00000';

        System.assert(ADM_TextUtils.isId(build.Id, keyPrefixBuild));
        System.assert(!ADM_TextUtils.isId(buildId,keyPrefixBuild));
    }
   
   }