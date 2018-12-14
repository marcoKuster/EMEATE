public class ADM_Comment {

    private static final String FIELD_NAMES = 'a.Priority_Override_Explanation__c,a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.FirstName, a.LastModifiedBy.LastName, a.LastModifiedById, a.Id, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.FirstName, a.CreatedBy.LastName, a.CreatedById, a.Comment_Created_Date__c, a.Comment_Created_By__r.Email, a.Comment_Created_By__r.Name, a.Comment_Created_By__r.FirstName, a.Comment_Created_By__r.LastName, a.Comment_Created_By__c, a.Body__c, a.Work__c, a.LocaleCreatedDate__c, a.Preserve_Formatting__c';

    private static final String SQL_SELECT = 'select ' + FIELD_NAMES + ' ';

    private static final String SQL_FROM = 'from ADM_Comment__c a';

    public static final Integer NUMBER_OF_COMMENTS_PER_NOTIFICATION = 3;

    

    public static ADM_Comment__c[] getAll( String id ){

        ADM_Comment__c[] comments = [

            Select a.Id, a.Name, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, 

                a.CreatedBy.FirstName, a.CreatedBy.LastName, a.CreatedById, a.Comment_Created_Date__c, 

                a.Comment_Created_By__r.Email, a.Comment_Created_By__r.Name, 

                a.Comment_Created_By__r.FirstName, a.Comment_Created_By__r.LastName, 

                a.Comment_Created_By__c, a.Body__c, a.Preserve_Formatting__c, a.Posted_to_Chatter__c

            From ADM_Comment__c a            

            Where a.Work__c =: id 

            Order By a.Comment_Created_Date__c DESC ];

                        

        fixHTML(comments);

        replaceEOL(comments);

        parseCommentsForURLs(comments);

        toLocaleTime(comments);

        addPreTags(comments);

        

        return comments;    

    }
    /*

        Limiting the number of comments to 1000 or else we get collection size exceeds error in VF...ADM_Comments is deprecated and 
        1000 latest emails will be sufficient enough.
        https://gus.my.salesforce.com/apex/adm_bugdetail?id=a07B00000010O7cIAE&sfdc.override=1
        @ W-2346975 @
    */
    public static ADM_Comment__c[] getAllComments( String id ){
        ADM_Comment__c[] comments = [
            Select a.Id, a.Name, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name,
                a.CreatedBy.FirstName, a.CreatedBy.LastName, a.CreatedById, a.Comment_Created_Date__c,
                a.Comment_Created_By__r.Email, a.Comment_Created_By__r.Name, 
                a.Comment_Created_By__r.FirstName, a.Comment_Created_By__r.LastName,
                a.Comment_Created_By__c, a.Body__c, a.Preserve_Formatting__c,
                a.Created_By__c, a.Work__c
            From ADM_Comment__c a            
            Where a.Work__c =: id 
            Order By a.Comment_Created_Date__c DESC limit 1000 ];
        toLocaleTime(comments);
        return comments;
    }   

    public static ADM_Comment__c[] getAllUnprocessed( String id ){
        ADM_Comment__c[] comments = [
            Select a.Id, a.Name, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name,
                a.CreatedBy.FirstName, a.CreatedBy.LastName, a.CreatedById, a.Comment_Created_Date__c,
                a.Comment_Created_By__r.Email, a.Comment_Created_By__r.Name, 
                a.Comment_Created_By__r.FirstName, a.Comment_Created_By__r.LastName,
                a.Comment_Created_By__c, a.Body__c, a.Preserve_Formatting__c,
                a.Created_By__c, a.Work__c
            From ADM_Comment__c a            
            Where a.Work__c =: id 
            Order By a.Comment_Created_Date__c DESC ];
        toLocaleTime(comments);
        urlEncode(comments);
        return comments;
    }   
    
    public static ADM_Comment__c[] urlEncode(ADM_Comment__c[] comments) {
        for(ADM_Comment__c comment : comments) {
            if(comment.Body__c != null) {
                comment.Body__c = EncodingUtil.urlEncode(comment.Body__c, 'UTF-8');
            }           

            //if the comment was created for another person, use their information otherwise use the createdBy info
            User createdBy = comment.CreatedBy;
            if(comment.Comment_Created_By__c != null) {
            	createdBy = comment.Comment_Created_By__r;
            }
            
            //set the displayed name for the user
            comment.Created_By__c = Encodingutil.urlEncode(createdBy.Name, 'UTF-8');
        }
        return comments;
    }  

    public static ADM_Comment__c[] toLocaleTime(ADM_Comment__c[] comments) {

        for(ADM_Comment__c comment : comments) {

            if(comment.Comment_Created_Date__c != null) {

                comment.LocaleCreatedDate__c = comment.Comment_Created_Date__c.formatLong();

            }            

        }                

        

        return comments;

    }

    

    public static ADM_Comment__c[] addPreTags(ADM_Comment__c[] comments) {

        for(ADM_Comment__c comment : comments) {

            if(comment.Preserve_Formatting__c) {

                comment.Body__c = '<pre class="pre">' + comment.Body__c + '</pre>';

            }

        }

        

        return comments;

    }

    

    public static ADM_Comment__c[] adjustComments(ADM_Comment__c[] comments) {

        ADM_TextUtils textUtils = new ADM_TextUtils();

        for(ADM_Comment__c comment : comments) {

            if(comment.Body__c != null) comment.Body__c = textUtils.escapeHTML(comment.Body__c);

            if(comment.Comment_Created_Date__c != null) comment.LocaleCreatedDate__c = comment.Comment_Created_Date__c.formatLong();

            if(comment.Preserve_Formatting__c) comment.Body__c = '<pre class="pre">' + comment.Body__c + '</pre>';

        }

        return comments;

    }

    

    testMethod static void testAdjustComments() {

        ADM_Comment__c comment = new ADM_Comment__c();

        comment.Body__c = 'testAdjustComments method invoked!<test>';

        comment.Comment_Created_Date__c = System.now();

        comment.Preserve_Formatting__c = true;

        List<ADM_Comment__c> comments = new List<ADM_Comment__c>();

        comments.add(comment);

        

        ADM_Comment__c[] commentsTotallyAdjusted = ADM_Comment.adjustComments(comments);

        ADM_Comment__c commentTotallyAdjusted = commentsTotallyAdjusted.get(0);

        System.assert(commentTotallyAdjusted.Body__c.contains('&lt') == true,'Expected the < to be escaped, but I found it: ' + commentTotallyAdjusted.Body__c);
    }

    public static ADM_Comment__c[] getAllCommentsForWork(List<ID> workIds) {
    	String sql = SQL_SELECT + SQL_FROM + ' where Work__c in :workIds Order By a.Comment_Created_Date__c DESC limit 1000';
    	return Database.query(sql);
    }

    public static ADM_Comment__c[] getAllBy( String columnName, List< String> columnValues ){
        ADM_Comment__c[] comments = new ADM_Comment__c[]{};     
        
        //the previous static SOQL based IF statements on the columnName value.  Two of these names used a different spellings then the literal column name spelling.  Add code to handle this spelling
        //for any older method calls our there.  IDE doesn't have full refactor support yet, so this is necessary.
        
        if(columnName.equalsIgnoreCase('lastmodifiedby')) {
            columnName = 'LastModifiedById';    
        }
        
        if(columnName.equalsIgnoreCase('createdby')) {
            columnName = 'CreatedById';
        }       

        try{
            String inColumnValues = COM_SoqlUtils.createInClause(columnName, columnValues);
            String sql = SQL_SELECT + SQL_FROM + ' where ' + inColumnValues + ' Order By a.Comment_Created_Date__c DESC limit 1000';
            
            
            
             for(ADM_Comment__c c : Database.query(sql)) {
                comments.add(c);
             }
        } catch( System.Exception e ){
            System.debug('ADM_Comment.getAllBy() Exception:' + e);
        }
        
        return comments;
    }
    
    public static ADM_Comment__c[] replaceEOL( ADM_Comment__c[] comments ){

        for(ADM_Comment__c comment : comments){

            if(!comment.Preserve_Formatting__c) {

                comment.Body__c = comment.Body__c.replaceAll('\\n','<br/>');

                comment.Body__c = comment.Body__c.replaceAll('<br>','<br/>');

            }   

        }

        return comments;

    }

         

    public static ADM_Comment__c[] fixHTML(ADM_Comment__c[] comments) {     

        ADM_TextUtils textUtils = new ADM_TextUtils();

        

        for(ADM_Comment__c comment : comments) {

            if(comment.Body__c != null) {

                comment.Body__c = textUtils.escapeHTML(comment.Body__c);

            }

        }

        

        return comments;

    }

    

    //feed each of the comment text bodies through a url parser to add markup to any links

    private static ADM_Comment__c[] parseCommentsForURLs(ADM_Comment__c[] comments) {

        for (ADM_Comment__c comment: comments) {

            comment.Body__c = ADM_URLUtils.formatTextAsHref(comment.Body__c);   

        }

        return comments;    

    }

    

    private static testMethod void testGetAll() {

        ADM_Comment__c comment = new ADM_Comment__c();

        comment.Body__c = '<html>This is a test comment.';

        ADM_Work__c work = ADM_Work.createTestWork();

        comment.Work__c = work.id;

        comment.Preserve_Formatting__c = true;

        Database.insert(comment);

        ADM_Comment__c[] comments = getAll(work.id);

        System.assertEquals(comment.id, comments[0].id);

        System.assert(comments[0].Body__c.indexOf('</pre>') != -1);

        System.assert(comments[0].Body__c.indexOf('<html>') == -1);     

     }

    

    private static testMethod void testParseCommentsForURLs() {

        ADM_Comment__c comment = new ADM_Comment__c();

        comment.Body__c = 'This is a test comment.  With a test www.google.com url';

        ADM_Comment__c[] comments = new ADM_Comment__c[1];

        comments[0] = comment;

        ADM_Comment__c[] parsedComments = parseCommentsForURLs(comments);

        System.assert(parsedComments[0].Body__c.contains('href'), 'Expected the body of the comment to contain an href tag');

    }

    

    private static testMethod void testReplaceEOL() {

        ADM_Comment__c comment = new ADM_Comment__c();

        comment.Body__c = 'This is a test comment.  With a test www.google.com url \n this is a new line >';

        

        ADM_Comment__c[] comments = new ADM_Comment__c[1];

        comments[0] = comment;  

        

        ADM_Comment__c[] formattedComments = replaceEOL(comments);

        System.assert(formattedComments[0].Body__c.contains('<br/>'), 'Expected br tag to exist');

        

        formattedComments = fixHTML(comments);

        System.assert(formattedComments[0].Body__c.contains('>') == false, 'Expected > to be cleaned up!');

    }   

       private static testMethod void testToLocaleTime() {

        ADM_Comment__c comment = new ADM_Comment__c(Body__c = 'testing!');

        comment.Comment_Created_Date__c = System.now();
        
        List<ADM_Comment__c> comments = new List<ADM_Comment__c>();

        String timeStamp;

        

        Database.SaveResult result = Database.insert(comment);      

        comments = [select CreatedDate, LocaleCreatedDate__c, Comment_Created_Date__c from ADM_Comment__c where id = : comment.id];
        

        comments = toLocaleTime(comments);

        

        timeStamp = comment.Comment_Created_Date__c.formatLong();

        System.assert(comments[0].LocaleCreatedDate__c.equalsIgnoreCase(timeStamp), true);

    }

    



   

    

    public static ADM_Comment__c match( ADM_Comment__c[] comments, String bid ){

        ADM_Comment__c emptycomment = new ADM_Comment__c();

        

        for( ADM_Comment__c b : comments ){

        

            if( b.Id == bid ){

                

                return b;

            }   

        }

        

        //return an emptycomment cuz no one was found

        return emptycomment;

    }

    

    private static testMethod void testMatch() {

        ADM_Comment__c comment = new ADM_Comment__c();

        comment.Body__c = 'This is a test comment.';

        Database.insert(comment);

        ADM_Comment__c[] comments = new ADM_Comment__c[1];

        comments[0] = comment;

        ADM_Comment__c comment2 = new ADM_Comment__c();

        comment2.Body__c = 'This is a 2nd test comment.';

        Database.insert(comment2);

        //deliberately omit comment2 from array to force match

        //to fail

        ADM_Comment__c matchedComment = match(comments, comment2.id);       

        System.assertEquals(null, matchedComment.id);   

    }   

    

    public static ADM_Comment__c get( String columnName, String columnValue ){

        ADM_Comment__c comment = new ADM_Comment__c();

        ADM_Comment__c[] comments;

        List< String> columnValues = new List< String >();

        

        columnValues.add( columnValue );        

        comments = getAllBy( columnName, columnValues );

        comment = ADM_comment.match( comments, columnValue );

        

        return comment;

    }

    

    private static testMethod void testGet() {

        ADM_Comment__c comment = new ADM_Comment__c();

        comment.Body__c = 'This is a test comment.';

        ADM_Work__c work = ADM_Work.createTestWork();

        comment.Work__c = work.id;      

        Database.insert(comment);

        

        ADM_Comment__c comment2 = ADM_Comment.get('id', comment.id);

        System.assertEquals(comment.id, comment2.id);   

    }   

    

    public static boolean wasCommentInserted(ADM_Work__c work) {

        if( work.Comment_Copy__c != null ) {            

            return true;

        }

        

        return false;

    }

    

    private static testMethod void testWasCommentInserted() {

        ADM_Work__c work = ADM_Work.createTestWork();

        System.assertEquals(false, wasCommentInserted(work));

        work.Comment_Copy__c = 'true';

        System.assertEquals(true, wasCommentInserted(work));

    }   

    

    public static void save( ADM_Work__c work, String body ){       

        ADM_Comment__c comment = new ADM_Comment__c( 

            Body__c = body,

            Work__c = work.Id, 

            Comment_Created_Date__c = System.now(), 

            Comment_Created_By__c = work.LastModifiedById,

            Preserve_Formatting__c = work.Preserve_Formatting_Copy__c 

        );

        Database.insert( comment );

    }

    

    public static void save(List<ADM_CommentWrapper> commentWrappers) {
        List<ADM_Comment__c> comments = new List<ADM_Comment__c>();
        List<ADM_Priority_Override__c> pOverrides = new List<ADM_Priority_Override__c>();
        
        for(ADM_CommentWrapper cw : commentWrappers) {
            ADM_Comment__c comment = cw.toComment();
            if(comment == null) {
            	continue;
            }
            comments.add(comment);
            
            if(cw.work.Priority_Override_Explanation_Copy__c != null && (
              cw.work.Priority_Override_Explanation_Copy__c.length() > 0 && (cw.work.Priority_Override_Explanation_Copy__c != ADM_Work.PRIORITY_OVERRIDE_EXPLANATION))) {
                ADM_Priority_Override__c pOverride = new ADM_Priority_Override__c();
                pOverride.Work__c = cw.work.Id;
                pOverride.Priority_Override_Explanation__c = cw.work.Priority_Override_Explanation_Copy__c;
                pOverride.Priority__c = cw.work.Priority__c;
                pOverride.Priority_Default__c = cw.work.Priority_Default__c;
                pOverride.Priority_Mapping__c = cw.work.Priority_Mapping_Copy__c;
                pOverrides.add(pOverride);      
            }
        } 

        

        Database.insert(comments);

        Database.insert(pOverrides);

    }

    

    private static testMethod void testSaveWithoutLastModifiedByCopy() {

        ADM_Work__c work = ADM_Work.createTestWork();

        ADM_Comment.save(work, 'testing method testSave');

        

        //verify we can find it

        System.assertEquals(1, [select count() from ADM_Comment__c where Work__c = :work.id]);  

        

        List<ADM_CommentWrapper> commentWrappers = new List<ADM_CommentWrapper>();

        List<String> commentWrapperString = new List<String>();

        ADM_Priority_Mapping__c pm = ADM_PriorityMapping.createTest();

        User user = ADM_WorkUser.createTestUser();

        

        work.Priority_Override_Explanation_Copy__c = 'testing method testSave';

        work.Priority__c = 'P0';

        work.Priority_Default__c = 'P1';

        work.Priority_Mapping_Copy__c = pm.Id;

        

        ADM_CommentWrapper commentWrapper = new ADM_CommentWrapper(work,commentWrapperString, user );
        
        commentWrapper.body = 'testing!';

        commentWrappers.add(commentWrapper);

         

        ADM_Comment.save(commentWrappers);

        ADM_Comment__c comment = [select Comment_Created_By__c, Id, Body__c from ADM_Comment__c where Work__c = : work.Id order by Id desc limit 1];

        

        System.assert(comment.Comment_Created_By__c == user.Id);
        

    }

    public static Map<Id, List<ADM_Comment__c>> getCommentListMappedByWorkID(List<ADM_Comment__c> comments) {
    	
    	Map<Id, List<ADM_Comment__c>> workMap = new Map<Id, List<ADM_Comment__c>>();
    	for(ADM_Comment__c comment: comments) {
    		if(workMap.containsKey(comment.Work__c)) {
    			
    			workMap.get(comment.Work__c).add(comment);
    		} else {
    			
    			List<ADM_Comment__c> commentList = new List<ADM_Comment__c>();
    			commentList.add(comment);
    			workMap.put(comment.Work__c, commentList);
    		}
    	}
    	
    	return workMap;
    }

    

}