public with sharing class ADM_PriorExt {
    public String teamId { get; set; }
    public transient List<ADM_Work__c> backlogRecs { get; set; }
    public transient List<ADM_Work__c> backburnerRecs { get; set; }
    public transient ADM_Scrum_Team__c team { get; set; }
    public String users { get; set; }
    public String builds { get; set; }
    public String sprints { get; set; }
    public String themes { get; set; }
    public String ptScale { get; set; } 
    public List<String> statusValsInv { get; set; }
    public List<String> statusValsTodo { get; set; }
    public List<String> statusValsUs { get; set; }
    public List<String> statusValsBug { get; set; }
    public static ADM_Cookie cookie;
    
    private static Integer DEFAULT_SPRINTS = 6;
    private static Integer MAX_SPRINTS = 10; 
    private static Integer TOTAL_SPRINTS = 0;
    
    public static Integer numberOfSprints;
    private static Integer calculatedVelocity = 0;
    private static final String selectClause = 'select Id, Details__c, RecordType.Name, Sprint__c, Sprint__r.Name, Use_Prioritizer__c, User_Type__c, LastModifiedDate, Name, Theme__c, Theme__r.Name, Subject__c, Priority_Rank__c, Priority__c, Story_Points__c, Status__c, Scheduled_Build__c, Scheduled_Build__r.Name, Closed_On__c, (select Theme__r.Name from Theme_Assignments__r) ';
    private static final String fromClause = ' from ADM_Work__c';
    private static final String whereClause = ' where Closed__c = 0 and RecordType.Name != \'Template\'';
    private static final String inPrioritize = ' and Use_Prioritizer__c = ';
    private static final String orderByClause = ' order by Priority_Rank__c, Id';
    private static final String limitClause = ' limit 1';
    private static final String FINBONACCI_SEQ = '0,1,2,3,5,8,13,21';
    private transient String soql = ''; 
         
    public ADM_Cookie getCookie() {
        return cookie;
    }
    
    public ADM_PriorExt() { }
    
    public Integer getDefaultSprints() {
        return DEFAULT_SPRINTS;
    }
    
    public Integer getMaxSprints() {
        return MAX_SPRINTS;
    }
    
    public Integer getTotalSprints() {
        return TOTAL_SPRINTS;
    }
    
    public ADM_PriorExt(ApexPages.StandardController controller) {
        List<ADM_Sprint__c> sprintResults = new List<ADM_Sprint__c>();
        Integer m_sprintsLen;
        
        teamId = System.currentPageReference().getParameters().get('scrumteamId');
        backlogRecs = new List<ADM_Work__c>();
        backburnerRecs = new List<ADM_Work__c>();
        team = new ADM_Scrum_Team__c();
        
        ADM_errorUtils err = new ADM_errorUtils();
        
        
        //get the list of object names for use in the JavaScript on the client
        users = getNamesAsJSON([select Name from User where IsActive = true]);
        builds = getNamesAsJSON([select Name from ADM_Build__c where Name != NULL order by Name asc]);
        sprints = getNamesAsJSON([select Name from ADM_Sprint__c where Scrum_Team__c = :teamId and (End_Date__c = null or End_Date__c >= : System.today()) order by Name asc]);
        themes = getNamesAsJSON([select Name from ADM_Theme__c where Active__c = true order by Name asc]);
        
        for(ADM_Sprint__c rec : [select Id from ADM_Sprint__c a where a.Completed_Story_Points__c != null and a.Scrum_Team__c = :teamId and a.Days_Remaining__c like 'CLOSED%' order by a.End_Date__c desc limit 10]) {
            sprintResults.add(rec);
        }
        
        statusValsInv = ADM_Work.getStatusValues('Investigation');
        statusValsTodo = ADM_Work.getStatusValues('ToDo');
        statusValsUs = ADM_Work.getStatusValues('User Story');
        statusValsBug = ADM_Work.getStatusValues('Bug');
        
        m_sprintsLen = sprintResults.size(); 
        TOTAL_SPRINTS = m_sprintsLen;
        
        if(sprintResults != null && sprintResults.size() < 10) {
            MAX_SPRINTS = m_sprintsLen + 1;
        }
        
        if(m_sprintsLen < 7 && m_sprintsLen > 1) {
            DEFAULT_SPRINTS = 2;            
        } else if(m_sprintsLen < 2) {
            MAX_SPRINTS = 0;
            DEFAULT_SPRINTS = 0; 
        } else {
            DEFAULT_SPRINTS = 6;
        }       
        
        
        
        if(teamId == null) {
            //#error condition don't continue
        } else {
            team = [select Name, Story_Point_Scale__c from ADM_Scrum_Team__c where Id =: teamId limit 1];
            teamId = String.escapeSingleQuotes(teamId); 
            
            if(ADM_TextUtils.isBlank(team.Story_Point_Scale__c)) {
                ptScale = FINBONACCI_SEQ;
            } else {
                ptScale = team.Story_Point_Scale__c;
            }
            
            soql = selectClause + fromClause + whereClause + inPrioritize + ' true and Scrum_Team__c = \'' + teamId + '\' and Priority_Rank__c != null' + orderByClause + limitClause;
            
            try {
                backlogRecs = Database.query(soql); 
            } catch(System.DmlException e) {
                System.debug('Exception getting backlog in ADM_PriorExt constructor:' + e);       
            } 
            
            soql = selectClause + fromClause + whereClause + inPrioritize + ' true and Scrum_Team__c = \'' + teamId + '\' and Priority_Rank__c = null order by CreatedDate DESC' + limitClause;
            
            try {
                backburnerRecs = Database.query(soql);
            } catch(System.DmlException e) {
                System.debug('Exception getting backburner in ADM_PriorExt constructor:' + e);       
            }
        }
        
        //check if cookie already exists
        Cookie c = Apexpages.currentPage().getCookies().get('velocityControl_' + team.id);
        if(c == null) {
            
            cookie = new ADM_Cookie('velocityControl_' + team.id, String.valueOf(DEFAULT_SPRINTS));
            numberOfSprints = DEFAULT_SPRINTS;
        } else {
            cookie = new ADM_Cookie('velocityControl_' + team.id, String.valueOf(c.getValue()));
            
            try {
                numberOfSprints = Integer.valueOf(c.getValue());
            } catch(Exception e) {
                System.debug('exception parsing cookie value:' + e);
                numberOfSprints = DEFAULT_SPRINTS;
            }   
        }   
    }
    
    public String getStatusValuesAsJson() {
        return JSON.serialize(ADM_Work.getStatusValues());
    }
    
    static String getLastId(List<SObject> recs) {
        String recId = '';
        
        List<String> recIds = ADM_WorkUtils.extractElsFromSobjects(recs, 'Id');
        
        if(!recIds.isEmpty()) {
            recId = recIds.get(recIds.size() - 1);
        }
        
        return recId;
    }
    
    @RemoteAction
    public static ADM_DmlResult getMoreRecs(String bbId, String blId, String rank) {
        ADM_DmlResult result;
        String lastId = '';
        List<ADM_Work__c> backlog, backburner = new List<ADM_Work__c>();
        
        result = new ADM_DmlResult(bbId + '|' + blId, true);
        
        try {
            if(blId != null && blId != '') {
                 result.backlog = getBacklogUpdate(blId, rank);
                 backlog = getBacklogUpdate(getLastId(result.backlog), rank);
            }
        } catch (Exception e) {
            System.debug('getMoreRecs() exception getting backlog e:' + e + ' line:' + e.getLineNumber());
        }   
        
        try {
            
            if(bbId != null && bbId != '') {
                result.backburner = getBackburnerUpdate(bbId);
                
                backburner = getBackburnerUpdate(getLastId(result.backburner));
            }   
        } catch (Exception e2) {
            System.debug('getMoreRecs() exception getting backburner e2:' + e2 + ' line:' + e2.getLineNumber());
        }    
        
        if( (backlog == null || backlog.isEmpty()) && (backburner == null || backburner.isEmpty()) ) {
            result.hasMore = false;
        } else {
            result.hasMore = true;
        }
        
        return result;
    }
    
    @RemoteAction 
    public static List<ADM_Work__c> getBacklogUpdate(String workId, String rank) {
        List<ADM_Work__c> recs = new List<ADM_Work__c>();
        List<ADM_Work__c> recs_2 = new List<ADM_Work__c>();
        ADM_Work__c rec = new ADM_Work__c();
        Integer counter = -1;
        Integer idx = 0;
        Integer upperLimit = 50;
        
        try {
            recs = [select Id, Priority_Rank__c, Scrum_Team__c from ADM_Work__c where Id = :workId];
            
            if(recs.isEmpty()) {
                
            } else {
                rec = recs[0];
                recs = new List<ADM_Work__c>(); 
                
                String soql = selectClause + fromClause + whereClause + inPrioritize + ' true and Scrum_Team__c = \'' + rec.Scrum_Team__c + '\' and Priority_Rank__c != null' + orderByClause + ' limit 200';
                recs_2 = Database.query(soql); 
                
                for(ADM_Work__c rec_2 : recs_2) {
                    if(counter > -1 && recs.size() < upperLimit) {
                        counter++;
                        recs.add(rec_2);
                    }
                    if(rec_2.Id == rec.Id) {
                        if(idx == 0) upperLimit = 49;
                        counter = 0;
                    }
                    idx++;
                } 
                
                
                recs = scrubPriorityRanks(recs, Decimal.valueOf(rank));                                   
            }
        
           
            
        } catch(System.DmlException e) {
            System.debug('Exception in getBacklogUpdate() e:' + e + ' line:' + e.getLineNumber());  
        }   
        
        return recs;
    }
    
    @RemoteAction
    public static List<ADM_Work__c> getBacklog(String teamId) {
        List<ADM_Work__c> recs = new List<ADM_Work__c>();
         
        String soql = selectClause + fromClause + whereClause + inPrioritize + ' true and Scrum_Team__c = :teamId and Priority_Rank__c != null' + orderByClause + ' limit 200';
        
        try {
            recs = Database.query(soql); 
        } catch(System.DmlException e) {
            System.debug('Exception in getBacklog() e:' + e + ' line:' + e.getLineNumber());  
        }
        
        return recs;
    }
    
    @RemoteAction
    public static List<ADM_Work__c> getBackburnerUpdate(String workId) {
        List<ADM_Work__c> recs = new List<ADM_Work__c>();
        List<ADM_Work__c> recs_2 = new List<ADM_Work__c>();
        ADM_Work__c rec = new ADM_Work__c();
        Integer counter = -1;
        Integer idx = 0;
        Integer upperLimit = 50;
        
        try {
            recs = [select Id, Scrum_Team__c from ADM_Work__c where Id = :workId];
            
            if(recs.isEmpty()) {
            } else {
                rec = recs[0];
                recs = new List<ADM_Work__c>(); 
                
                String soql = selectClause + fromClause + whereClause + inPrioritize + ' true and Scrum_Team__c = \'' + rec.Scrum_Team__c + '\' and Priority_Rank__c = null order by CreatedDate DESC limit 200';
                recs_2 = Database.query(soql); 
                
                for(ADM_Work__c rec_2 : recs_2) {
                    if(counter > -1 && recs.size() < upperLimit) {
                        counter++;
                        recs.add(rec_2);
                    }
                    if(rec_2.Id == rec.Id) {
                        if(idx == 0) upperLimit = 49;
                        counter = 0;
                    }
                    idx++;
                }
            }        
        } catch(System.DmlException e) {
            System.debug('Exception in getBackburnerUpdate() e:' + e + ' line:' + e.getLineNumber());   
        }
        
        return recs;
    }
    
    @RemoteAction 
    public static ADM_DmlResult updateWorkVals(String workId, String subject, String details, String status) {
        ADM_DmlResult result = null;
        
        if(!ADM_TextUtils.isNull(workId) && (!ADM_TextUtils.isNull(subject) || !ADM_TextUtils.isNull(details) || !ADM_TextUtils.isNull(status))) {
            ADM_Work__c work = [select Id, Name, Subject__c, Details__c, Status__c from ADM_Work__c where Id =: workId];
            
            if(!ADM_TextUtils.isNull(subject)) work.Subject__c = subject;
            if(!ADM_TextUtils.isNull(details)) work.Details__c = details;
            if(!ADM_TextUtils.isNull(status)) work.Status__c = status;
            
            Database.Saveresult rec = Database.update(work,false);
            result = ADM_DmlResult.createFromSaveResult(rec);
            if(rec.isSuccess()) {
                work = [select Id, Name, Status__c, Closed__c, Details__c, Subject__c from ADM_Work__c where Id =: workId];
                result.work = work;
            }
        }
        
        return result;
    }
    
    @RemoteAction 
    public static ADM_DmlResult updateStoryPts(String workId, string storyPts) {
        ADM_DmlResult result = null;
        
        if(!ADM_TextUtils.isBlank(workId) && !ADM_TextUtils.isBlank(storyPts)) {
            ADM_Work__c work = [select Id, Name, Story_Points__c from ADM_Work__c where Id =: workId];
            
            if(storyPts == '--') {
                work.Story_Points__c = null;    
            } else {
                work.Story_Points__c = Double.valueOf(storyPts);
            }
            
            Database.Saveresult rec = Database.update(work,false);
            result = ADM_DMLResult.createFromSaveResult(rec);
            if(rec.isSuccess()) {
                work = [select Id, Name, Story_Points__c from ADM_Work__c where Id =: workId];
                result.work = work;
            }
        }
        
        return result;
    }
    
    @RemoteAction
    public static List<ADM_Work__c> getFiltered(String teamId, String obj, String val) {
    	val = EncodingUtil.urlDecode(val, 'UTF-8');
    	
    	if(obj == 'Theme') {
    		return getFilteredByTheme(teamId, val);
    	}
    	
        List<ADM_Work__c> recs = new List<ADM_Work__c>();
        List<ADM_Work__c> blRecs = new List<ADM_Work__c>();
        List<ADM_Work__c> bbRecs = new List<ADM_Work__c>();
        
        String soql = '';
        
        soql = selectClause + fromClause + whereClause + inPrioritize + ' true and Scrum_Team__c = :teamId and Priority_Rank__c != null and ' + String.escapeSingleQuotes(obj) + ' = :val ' + orderByClause + ' limit 200';
        
        try {
            blRecs = Database.query(soql); 
        } catch(System.DmlException e) {
            //#error happened getting recs       
        } 
        
        soql = selectClause + fromClause + whereClause + inPrioritize + ' true and Scrum_Team__c = :teamId and Priority_Rank__c = null  and ' + String.escapeSingleQuotes(obj) + ' = :val order by CreatedDate DESC limit 300';
        
        try {
            bbRecs = Database.query(soql); 
        } catch(System.DmlException e) {
            //#error happened getting recs       
        } 
        
        recs.addAll(blRecs);
        recs.addAll(bbRecs);
        
        return recs;
    }
    
    @RemoteAction
    public static List<ADM_Work__c> getFilteredByTheme(String teamId, String themeName) {
        String soql = selectClause + fromClause + whereClause + inPrioritize + ' true '; 
        soql += ' and Scrum_Team__c = :teamId ';
        
    	if(ADM_TextUtils.isBlank(themeName)) {
            soql += ' and Id not in (select Work__c from ADM_Theme_Assignment__c) ';
    		
    	} else {
            soql += ' and Id in (select Work__c from ADM_Theme_Assignment__c where Theme__r.Name = :themeName) ';
    	}
    	
        soql += ' order by Priority_Rank__c NULLS LAST, CreatedDate DESC ';
        soql += ' limit 500';
    
        return Database.query(soql);
    }
    
    @RemoteAction
    public static List<ADM_PriorExt.UpdateAssignmentResult> updateAssignments(Id teamId, String workIds, String buildName, String sprintName, String themeName) {
        List<String> ids = workIds.split(',');
        List<ADM_Work__c> works = new List<ADM_Work__c>();
        ADM_Build__c aBuild = new ADM_Build__c();
        ADM_Sprint__c aSprint = new ADM_Sprint__c();
        ADM_Theme__c aTheme = new ADM_Theme__c();
        
        if(!ADM_TextUtils.isBlank(buildName) && !buildName.equalsIgnoreCase('remove') && !buildName.equalsIgnoreCase('ignore')) {
            List<ADM_Build__c> builds = [select Id from ADM_Build__c where Name = :buildName];
            if(builds.isEmpty()) {
            	throw new ADM_ApplicationException('Unable to find build with name of "' + buildName + '"');
            }
            aBuild = builds.get(0);
        }
        
        if(!ADM_TextUtils.isBlank(sprintName) && !sprintName.equalsIgnoreCase('remove') && !sprintName.equalsIgnoreCase('ignore')) {
        	List<ADM_Sprint__c> sprints = [select Id from ADM_Sprint__c where Name = :sprintName];
        	if(sprints.isEmpty()) {
        		throw new ADM_ApplicationException('Unable to find sprint with name of "' + sprintName + '"');
        	}
            aSprint = sprints.get(0);
        }
        
        if(!ADM_TextUtils.isBlank(themeName) && !themeName.equalsIgnoreCase('ignore')) {
            List<ADM_Theme__c> themes = [select Id, Name from ADM_Theme__c where Name = :themeName and Active__c = true limit 1];
            if(themes.isEmpty()) {
                throw new ADM_ApplicationException('Unable to find theme with name of "' + themeName + '"');
            }
            aTheme = themes.get(0);
        }
        
        
        Map<Id, ADM_PriorExt.UpdateAssignmentResult> resultMap = new Map<Id, ADM_PriorExt.UpdateAssignmentResult>();
        List<ADM_Theme_Assignment__c> newThemeAssignments = new List<ADM_Theme_Assignment__c>();
        
        for(ADM_Work__c work : [select Id, Scheduled_Build__c, Theme__c, Sprint__c, (select Theme__c from Theme_Assignments__r where Theme__c = :aTheme.Id) from ADM_Work__c where Id in : ids]) {
            
            //add a new result for each of the work items found
            ADM_PriorExt.UpdateAssignmentResult result = new ADM_PriorExt.UpdateAssignmentResult();
            result.Id = work.Id;
            resultMap.put(work.Id, result);
            
            //change the build
            if(aBuild.Id != null) { 
                work.Scheduled_Build__c = aBuild.Id;
            } else if(buildName.equalsIgnoreCase('remove')) {
                work.Scheduled_Build__c = null;
            }
            
            //change the sprint
            if(aSprint.Id != null) {
                work.Sprint__c = aSprint.Id;
            } else if(sprintName.equalsIgnoreCase('remove')) {
                work.Sprint__c = null;
            }
            
            //add a new theme
            if(aTheme.Id != null) {
                result.theme = aTheme;
                
                //if we didn't already find a theme assignment for this work/theme combination, then
                //we need to create a new one
                //since we filtered the work query relationship for both Theme and Work we only need to check
                //if any exist in the collection.
                if(work.Theme_Assignments__r.isEmpty()) {
                    ADM_Theme_Assignment__c themeAssignment = new ADM_Theme_Assignment__c();
                    themeAssignment.Work__c = work.Id;
                    themeAssignment.Theme__c = aTheme.Id;
                    newThemeAssignments.add(themeAssignment);
                }
            }
            
            works.add(work);
        }
        
        //update the work records
        if(!works.isEmpty()) {
            List<Database.Saveresult> recs = Database.update(works,false);
            
            for(Database.SaveResult saveResult : recs) {
                ADM_PriorExt.UpdateAssignmentResult result = resultMap.get(saveResult.getId());
                result.workDmlResult = ADM_DmlResult.createFromSaveResult(saveResult);
            }
        }
        
        //add the new theme assignments and save the errors if they occur
        if(!newThemeAssignments.isEmpty()) {
            List<Database.Saveresult> saveResults = Database.insert(newThemeAssignments, false);
            
            for(Integer index = 0; index < saveResults.size(); index++) {
                Database.SaveResult saveResult = saveResults.get(index);
                ADM_Theme_Assignment__c themeAssignment = newThemeAssignments.get(index);
                Id workId = themeAssignment.Work__c;
                
                ADM_PriorExt.UpdateAssignmentResult result = resultMap.get(workId);
                result.themeDmlResult = ADM_DmlResult.createFromSaveResult(saveResult);
            }
        }
        
        return resultMap.values();
    }
    
    @RemoteAction    
    public static List<ADM_Work__c> updateBacklogRank(String strings2Update) {
        Map<String, String> work2Update = new Map<String, String>();
        List<ADM_Work__c> works = new List<ADM_Work__c>();      
        Integer i;
        String key, value;
        
        
        
        for(String string2Update : strings2Update.split(',')) {
            i = 0;
                
            for(String val : string2Update.split('=')) {
                if(i == 0) {
                    key = val;
                } else {
                    value = val;
                }
                i++;
            }
            work2Update.put(key, value);
        }
        
        //try {
            works = [select Priority_Rank__c, Id from ADM_Work__c where Id =: work2Update.keySet() order by Priority_Rank__c];
            
            for(ADM_Work__c work : works) { 
                Decimal val = Decimal.valueOf(work2Update.get(work.Id));
                
                if(val > 0) {
                    work.Priority_Rank__c = val;
                } else {
                    work.Priority_Rank__c = null;
                }
            }
            
            update works;
               
            works = [select Priority_Rank__c, Id from ADM_Work__c where Id =: work2Update.keySet() order by Priority_Rank__c];            
        /*} catch(System.Exception e) {
            System.debug('updateBacklogRank() Unexpected exception updating backlog rank:' + e);
            
        }*/
        
        return works;           
    }
    
    private String cleanupString(String s) {
        if(s != null && s.length() > 0) {
            s = ADM_TextUtils.removeTrailingComma(s);
            s = String.escapeSingleQuotes(s);
        }
        return s;
    } 
    
    private String getNamesAsJSON(List<sObject> objects) {
        List<String> buildNames = new List<String>();
        for(sObject entry : objects) {
            buildNames.add((String)entry.get('Name'));
        }
        return JSON.serialize(buildNames);
    }
    
    public Integer getCalculatedVelocity() {
        
        if(calculatedVelocity == null || calculatedVelocity == 0) {
            calculatedVelocity = recalculateVelocity(numberOfSprints, teamId);
            return calculatedVelocity;
        } else {
            return calculatedVelocity;
        }
            
    }
    
    @RemoteAction
    public static Integer recalculateVelocity(Integer newNumberOfSprints, String teamId) {
        try {
            numberOfSprints = newNumberOfSprints;
            List<ADM_Sprint__c> sprints  = [select  a.Completed_Story_Points__c from ADM_Sprint__c a where a.Completed_Story_Points__c != null and a.Scrum_Team__c = :teamId and a.Days_Remaining__c like 'CLOSED%' order by a.End_Date__c desc limit :numberOfSprints];
            //average velocity
            Decimal velocity = 0;
            for(ADM_Sprint__c s : sprints) {
                
                velocity = velocity + s.Completed_Story_Points__c;
            }
            if(sprints.size() > 1) {
                velocity = velocity/sprints.size(); 
                calculatedVelocity = Integer.valueOf(velocity);
            }
          
            
            return calculatedVelocity;
        } catch (Exception e) {
            System.debug('Unexpected exception calculating velocity. e:' + e + ' line:' + e.getLineNumber());
            return 0;
        }    
    }
    
     @RemoteAction
    public static List<ADM_Work__c> scrubPriorityRanks(List<ADM_Work__c> works, Decimal lastKnownRank) {
        
       Decimal k = lastKnownRank + 1;
       for(ADM_Work__c w: works) {
            w.Priority_Rank__c = k;
            k ++;
        }
        
        return works;
        
        
        /****
          
          Initial implementation.  Comment to ensure it's checked in for history and then remove comment
        
        //ok to assume work is in rank order.  If not we could sort using a Comparator and apex-lang's ArrayUtils class
        
         Map<Decimal, ADM_Work__c> mapWorkByRank = new Map<Decimal, ADM_Work__c>();
        
        //loop and if a duplicate is found add 1 to subsequent records      
        Integer i = 0;
        //store work to be updated as a map as it may require several updates
        Map<Id, ADM_Work__c> workToBeUpdated = new Map<Id, ADM_Work__c>();
        for(ADM_Work__c w : works) {
            if(mapWorkByRank.containsKey(w.Priority_Rank__c)) {
                 
                //pull previous unique rank and add 1
                Decimal previousBacklogRank = works.get(i-1).Priority_Rank__c;
                w.Priority_Rank__c = previousBacklogRank + 1;
                workToBeUpdated.put(w.id, w);
                //add one to all subsequent records 
                Integer j = i + 1;
                while(j < works.size()) {
                    ADM_Work__c w2 = works.get(j);
                    w2.Priority_Rank__c = w2.Priority_Rank__c + 1;
                    workToBeUpdated.put(w2.id, w2);
                }
                
                mapWorkByRank.put(w.Priority_Rank__c, w);
                
            } else {
                
                mapWorkByRank.put(w.Priority_Rank__c, w);
            }
            i++;
        }
        
        
        
        //commit new backlog ranks to the db
        Database.update(workToBeUpdated.values()); 
        
        //return scrubed work list
        return works; */
        
            
    }
    
    public class UpdateAssignmentResult {
        public Id Id;
        public ADM_DmlResult workDmlResult;
        public ADM_DmlResult themeDmlResult;
        public ADM_Theme__c theme;
    }
   
}