/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ADM_URLUtilsTest {
    testMethod static void testHTMLComment() {
    	ADM_Work__c work = ADM_Work.createTestWork();
    	ADM_Comment__c comment = new ADM_Comment__c();
    	comment.Body__c = 'https://gus.soma.salesforce.com https://gus.soma.salesforce.com';
    	comment.Comment_Created_By__c = Userinfo.getUserId();
    	comment.Work__c = work.Id;
    	insert comment;
    	
    	ADM_Comment__c[] comments = ADM_Comment.getAll(work.Id);
    	Integer urlCount = getLinkCount(comments[0].Body__c);
    	System.assert(urlCount == 2,'2 url values not found->' + urlCount);
    }
    
    private static Integer getLinkCount(String results) {
        //count the number of link objects
        Integer urlcount = 0;
        Integer index = 0;
        Integer previousIndex = 0;
        while(index > -1) {         
            //search for next occurance of href using previous index as a baseline.
            index = results.indexOf('href', previousIndex);
            previousIndex = index + 4; //add 4 to account for the length of the href
            if(index > -1) {
                urlcount = urlcount + 1;
            }
        }
        
        return urlcount;
    }
    
    testMethod static void testFormatURLStringAsHref() {
        String urls = 'https://digg.com ftp://ftp.uwm.edu/pub/ https://bbc.co.uk https://www.cnn.com www.google.com';
        String results = ADM_URLUtils.formatURLStringAsHref(urls);
        //count the number of link objects
        Integer urlcount = 0;
        Integer index = 0;
        Integer previousIndex = 0;
        while(index > -1) {         
            //search for next occurance of href using previous index as a baseline.
            index = results.indexOf('href', previousIndex);
            previousIndex = index + 4; //add 4 to account for the length of the href
            if(index > -1) {
                urlcount = urlcount + 1;
            }
        }
        //five links should have been added         
        System.assertEquals(5, urlcount, 'Unexpected Number of HREF tags. Result String:' + results);
    }   
    
    testMethod static void testTextAsHref() {
        String content = 'hello www.google.com world this is a https://bbc.co.uk certified test of the www.link.com parser';
        String results =  ADM_URLUtils.formatTextAsHref(content);
        //count the number of link objects
        Integer urlcount = 0;
        Integer index = 0;
        Integer previousIndex = 0;
        while(index > -1) {
            System.debug('test index:' + index);
            //search for next occurance of href using previous index as a baseline.
            index = results.indexOf('href', previousIndex);
            previousIndex = index + 4; //add 4 to account for the length of the href
            if(index > -1) {
                urlcount = urlcount + 1;
            }
        }
        //three links should have been added            
        System.assertEquals(3, urlcount);       
    }   
}