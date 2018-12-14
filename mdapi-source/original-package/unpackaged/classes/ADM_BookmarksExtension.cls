public with sharing class ADM_BookmarksExtension {
    public String bookmarkId { get; set; }
    public ADM_Bookmark__c newBookmark {
        get {
            if(newBookmark == null) newBookmark = new ADM_Bookmark__c();
            return newBookmark;
        }   
        set; 
    }
    
    public String bookmarkPrefix {
        get {
            return Schema.SObjectType.ADM_Bookmark__c.getKeyPrefix();
        }
        set;
    }
    
    private Map<String,ADM_Bookmark__c> bookmarkMap {    	 
    	get {
    		if(bookmarkMap == null) {
                bookmarkMap = new Map<String,ADM_Bookmark__c>();
                for(ADM_Bookmark__c bm : bookmarks) {
                    bookmarkMap.put(bm.Id,bm);
                }
    		}
    		return bookmarkMap;
    	}
    	set; 
	}
	
    private ADM_errorUtils errorUtils = new ADM_errorUtils();
    
    public ADM_BookmarksExtension() {}
        
    public Apexpages.Standardsetcontroller setController { 
        get {
            if(setController == null) {
                if([select count() from ADM_Bookmark__c where CreatedById =: Userinfo.getUserId()] > 0) {
                    setController = new Apexpages.Standardsetcontroller(Database.getQueryLocator([select a.Title__c, a.URL__c from ADM_Bookmark__c a where a.CreatedById = :UserInfo.getUserId() order by a.Sort_Order__c, a.CreatedDate desc nulls first]));
                } else {
                    setController = new Apexpages.Standardsetcontroller(new ADM_Bookmark__c[]{});
                }
            }
            setController.setPageSize(5);
            return setController;
        }
        set;
    }    
 
    public Integer rowStart {
        get {       
            if(!setController.getHasPrevious()) {
                if(setController.getResultSize() == 0) {
                    return 0;
                } else {
                    return 1;
                }
            } else {
                return setController.getPageSize() * (setController.getPageNumber() - 1) + 1;
            }
        }
        set;
    }
     
    public Integer rowEnd {
        get {
            if(!setController.getHasNext()) {
                return setController.getResultSize();
            } else {
                return setController.getPageSize() * setController.getPageNumber();
            }
        }
        set;
    }
    
    public List<ADM_Bookmark__c> bookmarks {
        get {
            bookmarks = new List<ADM_Bookmark__c>();
            for(ADM_Bookmark__c bm :(List<ADM_Bookmark__c>)setController.getRecords()) {
              bookmarks.add(bm);    
            }
            return bookmarks;
        }
        set;
    }
    
    public Pagereference deleteBookmark() {
        try{
        	if(bookmarkId != null) {
                ADM_Bookmark__c bookmark2delete = bookmarkMap.get(bookmarkId);
                if(bookmark2delete != null) {
                    delete bookmark2delete;
                }
        	}
        } catch(System.DmlException e) {
            ApexPages.addMessage(errorUtils.getApexpagesMessage('An error occurred deleting bookmark', e));
        }
        return refresh();
    }
    
    public Pagereference save() {
        if(newBookmark.URL__c != null && newBookmark.Title__c != null) bookmarkMap.put(bookmarkPrefix + '900000008ZZZ', newBookmark);
        Database.Upsertresult[] results = Database.upsert(bookmarkMap.values(), false);
        
        for(Database.Upsertresult result : results) {
	        if(!result.isSuccess()) {
	        	for(Database.Error error : result.getErrors()) {
	        		if(!error.getMessage().contains('ENTITY_IS_DELETED')) {
	        			ApexPages.addMessage(errorUtils.getApexpagesMessage(error.getMessage()));	
	        		}
	        	}
	        }	
        }
        
        return refresh();
    }
    
    public Pagereference refresh() {
        Pagereference pr = Page.ADM_BookmarksSidebar;
        pr.setRedirect(true);
        return pr;
    } 
}