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
private class ADM_CommentsControllerExtensionTest {	
    static ADM_Work__c work {
    	get {
    		if(work == null) {
    			work = ADM_Work.createTestWork();
    		}
    		return work;
    	}
    	set;
    }
    
    static ADM_Comment__c comment {
    	get {
    		if(comment == null) {
    			comment = new ADM_Comment__c();
    			comment.Work__c = work.Id;
    			comment.Body__c = 'testing 123';
    			insert comment;
    		}
    		return comment;    		
    	}
    	set;
    }
    
    static ADM_Comment__c[] comments {
    	get {
    		if(comments == null) {
    			comments = new ADM_Comment__c[] {};
    			comments.add(comment);
    		}
    		return comments;
    	}
    	set;
    }
    
    static testMethod void testWorkRelatedListController() {
    	System.assert(comments.size() > 0);
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_CommentsControllerExtension wrl = new ADM_CommentsControllerExtension(stdController);
        System.assert(wrl.getComments().size() == comments.size());
    }
    
    static testMethod void getUser() {
        System.assert(comments.size() > 0);
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_CommentsControllerExtension wrl = new ADM_CommentsControllerExtension(stdController);
        System.assert(wrl.getUser() != null);
    }
    
    static testMethod void toggleComments() {
        System.assert(comments.size() > 0);
        ApexPages.StandardController stdController = new ApexPages.StandardController(work);
        ADM_CommentsControllerExtension wrl = new ADM_CommentsControllerExtension(stdController);
        
        if(wrl.getShowAllComments() == 'true') {
            System.assert(wrl.getCommentsStyle() == 'display:none', '->' + wrl.getCommentsStyle());	
        } else if(wrl.getShowAllComments() == 'false') {
        	System.assert(wrl.getCommentsStyle() == 'display:true', '->' + wrl.getCommentsStyle());
        }
        
        wrl.toggleComments();
        
        if(wrl.getShowAllComments() == 'true') {
            System.assert(wrl.getCommentsStyle() == 'display:none', '->' + wrl.getCommentsStyle()); 
        } else if(wrl.getShowAllComments() == 'false') {
            System.assert(wrl.getCommentsStyle() == 'display:true', '->' + wrl.getCommentsStyle());
        }
    }
    
    static testMethod void testWithOutComments() {
        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(ADM_Work.createTestWork());
        ADM_CommentsControllerExtension ext = new ADM_CommentsControllerExtension(stdController);
        System.assert(ext.getHasComments() == false);	
    }
}