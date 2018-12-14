/*
* Copyright, 2008, SALESFORCE.com
* All Rights Reserved
* Company Confidential
* 
* Utility class used to handle heavy lifting when working with a Work Records tree structure 
*/

public class ADM_WorkTreeUtils {

	private static final Integer VALIDATION_PERFORMANCE_CAP = 5;
	private static final Integer MAXIMUM_LIST_SIZE_ALLOWED = 1000;
    

//links between Work objects are maintained in ADM_Parent_Work object.  Require wrapper meta data class to hold the generation the link is found in.  Necessary for display hierarchy
public class LinkMetaData {
    private ADM_Parent_Work__c link; 
    private Integer linkGeneration;
    
    public ADM_Parent_Work__c getLink() {
        return link;
    }
    
    public void setLink(ADM_Parent_Work__c newLink) {
        link = newLink;
    }
    
    public Integer getLinkGeneration() {
        return linkGeneration;
    }
    
    public void setLinkGeneration(Integer newLink) {
        linkGeneration = newLink;
    }
    
    public Boolean getDuplicate() {
    	if(this.getLink() != null) {
    		return this.getLink().Duplicate__c;
    	}
    	return false;
    }
}  

//Maintains meta data regarding the ADM_Work object it wraps.
public class FamilyMetaData { 
	private List<String> generations; 
    private ADM_Work__c work; 
    private Boolean duplicate;
    
    public List<String> getGenerations() {
        return generations;
    }
  
    //a list who's size is used to control the number of iterations of indentation markup
    public void setGenerations(Integer gen) {
        generations = new List<String>();
        for(Integer i=0; i < gen; i++) {
            generations.add('Generation:' + i);
        }
    }
  
    public Integer getGeneration() {
        return generations.size();
    }
  
    public Integer getPadding() {
        return generations.size() * 15;
    }
  
    public ADM_Work__c getWork() {
        return work;
    }
  
    public void setWork(ADM_Work__c workObj) {
        work = workObj;
    }
  
    public void setDuplicate(Boolean duplicate) {
        this.duplicate = duplicate;
    }
  
    public Boolean getDuplicate() {
        return this.duplicate;
    }
}  

testMethod static void testFamilyMetaData() {
  	  FamilyMetaData fmd = new FamilyMetaData();
  	  fmd.setGenerations(10);  	   	 
  	  System.assert(fmd.getGeneration() != null);
  	  System.assert(fmd.getPadding() != null);
  	  fmd.setWork(new ADM_Work__c());
  	  System.assert(fmd.getWork() != null);
  }
  	

public static Boolean isValidRecordTypeAssociation(String recordType) {
	if(recordType.equalsIgnoreCase(ADM_Work.BUG_RECORD_TYPE_NAME) || recordType.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_TODO) || recordType.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_USERSTORY) || recordType.equalsIgnoreCase(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION)) {
		return true;
	}
	return false;
}

public static String getRecordTypeErrorMsg(String recordType) {
	return 'Work cannot be related to a ' + recordType;
}

public static Boolean anchestorExists(Id currentWorkID, Id newWorkID) {
   	Set<String> uniqueAnchestors = ADM_WorkTreeUtils.getUniqueAncestors(currentWorkID);
   	if (uniqueAnchestors.contains(newWorkID)) {
   		return true;	
   	} else {
   		return false;	
   	}		
}


testMethod static void testAnchestorExists() {
	String currentWorkID = createSmallTestFamily();
	String newWorkID = (ADM_Work.createTestWork()).id;
	//work IDs are not related to expect false to be returned
	System.assertEquals(false, anchestorExists(currentWorkID, newWorkID));
	
}	

public static Boolean childExists(Id currentWorkID, Id newWorkID) {
	
	List<ADM_Parent_Work__c> topGeneration = [select Parent_Work__c, Child_Work__c, Duplicate__c from ADM_Parent_Work__c where Parent_Work__c = :currentWorkID];
	Map<String, List<LinkMetaData>> familyTree = buildFamilyTree(topGeneration, VALIDATION_PERFORMANCE_CAP, new Set<String>());
	//combine family tree with 1st generation into 1 set of unique IDs.  
	Set<String> childIDs = new Set<String>(); 
	childIDs.addAll(convertLinkListToChildIDList(topGeneration));   //convertLinkMetaDataListToChildIDSet(convertParentLinkToLinkMetaData(topGeneration, 0));
	childIDs.addAll(convertFamilyTreeToChildIDSet(familyTree));
	//check if newWorkID is a desendant of currentWorkID
	if (childIDs.contains(newWorkID)) {
		return true;
	} else {
		return false;	
	}			
}		

public static Set<String> getUniqueAncestors(Id workID) {
	
	
	List<ADM_Parent_Work__c> parents = [select Parent_Work__c, Child_Work__c from ADM_Parent_Work__c where Child_Work__c = :workID];
	Set<String> parentIDs = new Set<String>();
	parentIDs = addParentIDToSet(parents, parentIDs);
	Integer i = 0;
	while (i < VALIDATION_PERFORMANCE_CAP) {
		parents = [select Parent_Work__c, Child_Work__c from ADM_Parent_Work__c where Child_Work__c in :parentIDs];
		if (parents.size() == 0) {
			//no more anchestors found
			break;
		} else {	
			parentIDs = addParentIDToSet(parents, parentIDs);
		}
		i++;	  
	}
	return parentIDs;		
}



private static Set<String> addParentIDToSet(List<ADM_Parent_Work__c> parents, Set<String> parentIDs) {
	for(ADM_Parent_Work__c parent: parents) {
		parentIDs.add(parent.Parent_Work__c);		
	}
	return parentIDs;		
}

private static Set<String> convertFamilyTreeToChildIDSet(Map<String, List<LinkMetaData>> familyTree) {
	
	//first add the keys
	Set<String> keyset = familyTree.keySet();
	Set<String> childIDs = new Set<String>();
	childIDs.addAll(keyset);
	//now add the children
	for(String key : keyset) {
		childIDs.addAll(convertLinkMetaDataListToChildIDSet(familyTree.get(key)));	
	}	
	return childIDs;	
}

private static Set<String> convertLinkMetaDataListToChildIDSet(List<LinkMetaData> lmds) {
	Set<String> childIDs = new Set<String>();
	for(LinkMetaData lmd: lmds) {
		childIDs.add(lmd.getLink().Child_Work__c);
	}
	return childIDs;		
}

  
private static Set<String> convertParentWorkListToChildIDSet(List<ADM_Parent_Work__c> links) {
	Set<String> childIDs = new Set<String>();
	for(ADM_Parent_Work__c l: links) {
		childIDs.add(l.Child_Work__c); 
	}
	return childIDs;		
}	

private static Set<String> convertParentWorkListToParentIDSet(List<ADM_Parent_Work__c> links) {
	Set<String> parentIDs = new Set<String>();
	for(ADM_Parent_Work__c l: links) {
		parentIDs.add(l.Parent_Work__c);
	}
	return parentIDs;		
}		

testMethod static void testConvertParentWorkList() {
	Id childID = ADM_ParentWork.parentWorkTestSetupParents(2);
	List<ADM_Parent_Work__c> relationships = [select id, Child_Work__c, Child_Work__r.Name, Parent_Work__c, Parent_Work__r.Name from ADM_Parent_Work__c where Child_Work__c = :childID];
	System.assert(convertParentWorkListToChildIDSet(relationships) != null);
	System.assert(convertParentWorkListToParentIDSet(relationships) != null);
	System.assert(convertLinkListToParentIDList(relationships) != null);
	System.assert(convertLinkListToChildNameList(relationships) != null);
	System.assert(convertLinkListToParentNameList(relationships) != null);
	System.assert(convertLinkListToParentNameList(relationships) != null);
}


//starting with the List of top generation links builds a Map of families in the format ParentID ---> List of Family Members 
public static Map<String, List<LinkMetaData>> buildFamilyTree( List<ADM_Parent_Work__c> topGeneration, Integer depth, Set<String> knownAncestors) {
    
    //set parents to top of the family tree
    List<ADM_Parent_Work__c> parents = topGeneration;
    Integer generationCounter = 0;
    
    //add list to Map data structure which stores in parent key - List of children format
    Map<String, List<LinkMetaData>> families = new Map<String, List<LinkMetaData>>();   
    Set<String> setOfAllIds = new Set<String>();
    while (depth > 0) { 
        generationCounter ++;
        
        List<ADM_Parent_Work__c> children = getChildrenLinks(convertLinkListToChildIDList(parents));         		
		
		//remove known achestors and self references to safe guard against garbage data
		children = ADM_WorkTreeUtils.removeChildItemFromList(knownAncestors, children);
		children = ADM_WorkTreeUtils.removeChildItemFromList(setOfAllIds, children);
        
        //add to family
        families = addFamilyToMap(families, children, generationCounter);
        
        //maintain list of all ids to catch self referential relationships
        if(setofAllIds.size() + children.size() >= MAXIMUM_LIST_SIZE_ALLOWED) {
        	break;
        } else {
        	setofAllIds.addAll(convertParentWorkListToChildIDSet(children));
		}
			
		//the children of this iteration become the parents of the next
        parents = children;
        
        depth --;
    }
    
    System.debug('Families Size:' + families.size());  
    return families;
}
 

public static List<ADM_Parent_Work__c> removeChildItemFromList(Set<String> childIDs, List<ADM_Parent_Work__c> links) {
	ADM_Parent_Work__c link;
	for(Integer i = links.size()-1; i >= 0; i--) {
		link = links.get(i);
		if(childIDs.contains(link.Child_Work__c)) {
			links.remove(i);
		}
	}
	return links;
}



//adds family to correct poistion in list based on their relation to the top generation.  Children follow parents, parents follow grandparents etc
public static List<LinkMetaData> addFamilyToList(List<LinkMetaData> masterList,  Map<String, List<LinkMetaData>> families) {
    Integer index = 0;
    String key = '';
    LinkMetaData lmd = new LinkMetaData();
    Integer listSize = masterList.size();
    Integer innerIndex = 0;
    
    for (Integer i =0; i < masterList.size(); i ++) {
        lmd = (LinkMetaData)masterList.get(i);
        //check for children in map based on parentID
        key = lmd.getLink().Child_Work__c;       
        if(families.containsKey(key)) {                    
            /*APEX supports addAll(List) but not addAll(index, List) like Java which adds list at specified index and shifts remaining contents to the right
            ------
                masterList.addAll(index, (List<LinkMetaData>)families.get(lmd.getLink().Parent_Work__c));            
            ------  */  
            //Instead track this manually using innnerIndex integer var 
            List<LinkMetaData> tempChildren = families.get(key);
            innerIndex = i + 1;               
            for(LinkMetaData child: tempChildren) {
                //check to see if inner index is greater or equal to the list size and if so add child to the end of the list
                if(innerIndex >= masterList.size()) {
                    masterList.add(child);
                } else {
                    //to keep correct order each link meta data obj is added after its predecessor
                    masterList.add(innerIndex, child);
                }                                          
                innerIndex ++;
                if(masterList.size() == MAXIMUM_LIST_SIZE_ALLOWED) {
                    System.debug('Reached Maximum List Size Cap');
                    break;
                }
            }
            //remove item from family to prevent self references due to garbage data
            families.remove(key); 
        }
        if(masterList.size() == MAXIMUM_LIST_SIZE_ALLOWED) {
            System.debug('Reached Maximum List Size Cap');
            break;
        }

    }
    System.debug('Returning Master List. Size:' + masterList.size());    
    return masterList;
}

//helper method which creates a family of related work items and returns the id of the head parent
@IsTest
public static String createTestFamily() {
	ADM_Work__c work1 = ADM_Work.createTestWork();    
    ADM_Work__c work2 = ADM_Work.createTestWork();
    ADM_Work__c work3 = ADM_Work.createTestWork();
    //ADM_Work__c work4 = ADM_Work.createTestWork();
    //ADM_Work__c work5 = ADM_Work.createTestWork(); 
    
    //relate 2 and 3 as 1st generation children of work 1
    ADM_Parent_Work__c link1to2 = new ADM_Parent_Work__c();
    link1to2.Parent_Work__c = work1.id;
    link1to2.Child_Work__c = work2.id;
    System.debug('Work1 ID:' + work1.id + ' Work2 ID:' + work2.id);
    Database.insert(link1to2);
    
    ADM_Parent_Work__c link1to3 = new ADM_Parent_Work__c();
    link1to3.Parent_Work__c = work1.id;
    link1to3.Child_Work__c = work3.id;
    System.debug('Work1 ID:' + work1.id + ' Work3 ID:' + work3.id);
    Database.insert(link1to3);
    
    //relate 4 and 5 to 3... leave 2 as childless
    /*ADM_Parent_Work__c link3to4 = new ADM_Parent_Work__c();
    link3to4.Parent_Work__c = work3.id;
    link3to4.Child_Work__c = work4.id;
    Database.insert(link3to4); */
    
   /* ADM_Parent_Work__c link3to5 = new ADM_Parent_Work__c();
    link3to5.Parent_Work__c = work3.id;
    link3to5.Child_Work__c = work5.id;
    Database.insert(link3to5);*/
    
    return work1.id;
	
}	

//creates smaller family then test helper above to concerve SOQL queries due to gov limit for test methods
@IsTest
public static String createSmallTestFamily() {
	
   
	List<ADM_Work__c> workList = ADM_Work.createListOfWork(3, 'Bug');
	insert workList;   
    
    //relate 2 and 3 as 1st generation children of work 1
    ADM_Parent_Work__c link1to2 = new ADM_Parent_Work__c();
    link1to2.Parent_Work__c = workList.get(0).id;
    link1to2.Child_Work__c = workList.get(1).id;
    
    Database.insert(link1to2);
    
    ADM_Parent_Work__c link1to3 = new ADM_Parent_Work__c();
    link1to3.Parent_Work__c = workList.get(0).id;
    link1to3.Child_Work__c =workList.get(2).id;
   
    Database.insert(link1to3);
    
   
    
    return workList.get(0).id;
	
}	

testMethod static void testAddFamilyToList() {
    
    
    List<ADM_Parent_Work__c> childlinks1stGen = ADM_WorkTreeUtils.getChildrenLinks(createTestFamily());   
    List<ADM_WorkTreeUtils.LinkMetaData> lmd1stGen = ADM_WorkTreeUtils.convertParentLinkToLinkMetaData(childlinks1stGen, 0);    
    //prepare data for method test
    List<ADM_WorkTreeUtils.LinkMetaData> masterList = lmd1stGen;             
    Map<String, List<ADM_WorkTreeUtils.LinkMetaData>> families = ADM_WorkTreeUtils.buildFamilyTree(childlinks1stGen, 5, new Set<String>());    
    //test add family tree to master list maintaining the sort order by placing children after their parents, and parents after their grandparents etc
    masterList = ADM_WorkTreeUtils.addFamilyToList(masterList, families);
    //verify size
    System.assertEquals(2, masterList.size(), 'Unexpected number of Family members');
    
}


//extracts the ADM_Parent_Work.Child_Work__c ID and stores in List of Strings compatible with SOQL IN CLAUSE
public static List<String> convertLinkListToChildIDList(List<ADM_Parent_Work__c> links) {
    List<String> childIDs = new List<String>();
    for(ADM_Parent_Work__c link : links) {
        childIDs.add(link.Child_Work__c);
    }        
    return childIDs;        
}

public static List<String> convertLinkListToParentIDList(List<ADM_Parent_Work__c> links) {
    List<String> parentIDs = new List<String>();
    for(ADM_Parent_Work__c link : links) {
        parentIDs.add(link.Parent_Work__c);
    }        
    return parentIDs;        
}

public static List<String> convertLinkListToChildNameList(List<ADM_Parent_Work__c> links) {
    List<String> childIDs = new List<String>();
    for(ADM_Parent_Work__c link : links) {
        childIDs.add(link.Child_Work__r.Name);
    }        
    return childIDs;        
} 

/**
 * Given a list of parent links, a list of the Parent Work's names is returned.
 */
public static List<String> convertLinkListToParentNameList(List<ADM_Parent_Work__c> links) {
    List<String> parentIDs = new List<String>();
    for(ADM_Parent_Work__c link : links) {
        parentIDs.add(link.Parent_Work__r.Name);
    }        
    return parentIDs;        
}   

testMethod static void testConvertLinkListToChildIDList() {
    List<ADM_Parent_Work__c> childLinks = [select Child_Work__c from ADM_Parent_Work__c limit 3];
    List<String> results = convertLinkListToChildIDList(childLinks);
    //verify same number were returned
    System.assertEquals(childLinks.size(), results.size(), 'An unexpected number of Child IDs were returned');
    //verify the same links exist and are in the same order)
    Integer i = 0;
    for (ADM_Parent_Work__c link: childLinks) {
        System.assertEquals(results[i], link.Child_Work__c, 'Result ID does not match orginal input.  Either invalid data or invalid sort order. List Position:' + i);
        i++;
    }
    
}     

//groups objects with the same parent and stores in Families Map using the parentID as the key e.g. Key ParentID ---> List of Family Memebers (wrapped in LinkMetaData objects)
public static Map<String, List<LinkMetaData>> addFamilyToMap(Map<String, List<LinkMetaData>> families, List<ADM_Parent_Work__c> newMembers, Integer generation) {   
    String previousParent = '';
    String currentParent = '';
    List<ADM_Parent_Work__c> family = new List<ADM_Parent_Work__c>();
    Integer i = 0;
    for(ADM_Parent_Work__c link: newMembers) {
        i ++;
        currentParent = link.Parent_Work__c;         
        if (previousParent.equals(currentParent)) {
            //do nothing - apex didn't like !
        } else {
            if (family.size() > 0) {                
                families.put(previousParent, convertParentLinkToLinkMetaData(family, generation)); 
                family = new List<ADM_Parent_Work__c>();
            }    
        }
        family.add(link);
        previousParent = link.Parent_Work__c;        
        //if its the last iteration add remaining family members using currentParent as the key
        if(i == newMembers.size()) {
            //add any remaining family 
            if (family.size() > 0) {                
                families.put(currentParent, convertParentLinkToLinkMetaData(family, generation)); 
                family = new List<ADM_Parent_Work__c>();
            }  
        }        
    }    
    return families;
}

//wraps ADM_Parent_Work inside LinkMetaData object preseving meta data such as the link generation
public static List<LinkMetaData> convertParentLinkToLinkMetaData(List<ADM_Parent_Work__c> links, Integer generation) {
    List<LinkMetaData> lmdList = new List<LinkMetaData>();
    LinkMetaData lmd;
    for (ADM_Parent_Work__c link: links) {
        lmd = new LinkMetaData();
        lmd.setLinkGeneration(generation);
        lmd.setLink(link);
        lmdList.add(lmd);
    }    
    return lmdList;
}

testMethod static void testConvertParentLinkToLinksMetaData() {
    List<ADM_Parent_Work__c> links = [select Child_Work__c from ADM_Parent_Work__c limit 3];
    List<LinkMetaData> results = convertParentLinkToLinkMetaData(links, 1);
    //verify same number were returned
    System.assertEquals(links.size(), results.size(), 'An unexpected number of LinkMetaData objects were returned');
    //verify the same links exist and are in the same order)
    Integer i = 0;
    for (ADM_Parent_Work__c link: links) {
        System.assertEquals(link.Child_Work__c, results[i].getLink().Child_Work__c, 'Result ID does not match orginal input.  Either invalid data or invalid sort order. List Position:' + i);
        i++;
    }
}

//for each LinkMetaData object in the list retrieve the actual ADM_Work object and wrap in FamilyMetaData class to preserve meta data useful for display purposes
public static List<FamilyMetaData> convertLinkMetaDataToFamilyMetaData(List<LinkMetaData> linkObjs, Boolean resolvedFlag) {
    List<FamilyMetaData> fmdList;
    FamilyMetaData fmd = new FamilyMetaData();
    List<ADM_Work__c> workObjs = new List<ADM_Work__c>();    
    List<String> familyids = new List<String>();
    String previousParent = null; 
    Integer i = 0;
    ADM_Parent_Work__c link;    
    //build list of workIDs so they can be retrieved with one SQL call
    for(LinkMetaData lmd: linkObjs) {
        link = lmd.getLink();
        familyids.add(link.Child_Work__c);
    }
    //retrieve work objects
    workObjs = getWorkObjects(familyids, resolvedFlag);
    //preseve meta data    
    fmdList = copyGenerationFromLinkObjToFMDObj(linkObjs, workObjs);    
    //return workObjs;
    return fmdList;
}

testMethod static void testConvertLinkMetaDataToFamilyMetaData() {
    List<ADM_Parent_Work__c> links = [select Child_Work__c, Parent_Work__c, Duplicate__c from ADM_Parent_Work__c limit 3];
    List<LinkMetaData> lmds = convertParentLinkToLinkMetaData(links, 1);
    List<FamilyMetaData> fmds = convertLinkMetaDataToFamilyMetaData(lmds, false);
    //verify same number were returned
    /*System.assertEquals(lmds.size(), fmds.size(), 'An unexpected number of FamilyMetaData objects were returned');
    //loop fmds and verify each work object it wraps is in fact populated
    Integer i = 0;
    for(FamilyMetaData fmd: fmds) {
        System.assert(fmd.getWork() != null);
        //verify the generation is the same
        System.assertEquals(lmds[i].getLinkGeneration(), fmd.getGenerations().size(), 'Generation Meta Data attribute does not match');
        i++;
    }*/
}

//copy generation parameter from LinkMetaData object to Family Meta Data Object.  Match the two objects based on ADM_Parent_Work__c.Child_Work__c and ADM_Work__c.Id
public static List<FamilyMetaData> copyGenerationFromLinkObjToFMDObj(List<LinkMetaData> linkObjs, List<ADM_Work__c> workObjs) {
    //convert List of workObjs to Map so the work object can be located by id
    Map<String, ADM_Work__c> workMap = convertWorkListToWorkMap(workObjs);
    FamilyMetaData fmd;
    List<FamilyMetaData> fmdList = new List<FamilyMetaData>();
    ADM_Work__c work;
    //loop through link objs and create FamilyMetaData object.
    for(LinkMetaData lmd: linkObjs) {
        if(workMap.containsKey(lmd.getLink().Child_Work__c)) {
            fmd = new FamilyMetaData();
            fmd.setGenerations(lmd.getLinkGeneration());
            fmd.setDuplicate(lmd.getDuplicate());
            work =  workMap.get(lmd.getLink().Child_Work__c);
            //maintain parent ID inside work object - useful for inline edit/delete
            work.Parent_ID__c = lmd.getLink().Parent_Work__c;
            fmd.setWork(work);
            fmdList.add(fmd);
        }
    }
    return fmdList;
}

//modifies data structure from List to Map.  
public static Map<String, ADM_Work__c> convertWorkListToWorkMap(List<ADM_Work__c> workList) {    
    Map<String, ADM_Work__c> workMap = new Map<String, ADM_Work__c>(); 
    for(ADM_Work__c work: workList) {
        workMap.put(work.Id, work);
    }    
    return workMap;
}

testMethod static void testConvertWorkListToWorkMap() {
    List<ADM_Work__c> workList = [select id from ADM_Work__c limit 3];
    Map<String, ADM_Work__c> workMap = convertWorkListToWorkMap(workList);
    System.assertEquals(workList.size(), workMap.size(), 'The number of items in the work map does not match the number provided in the original work list data structure');
}

//retrieves list of work object based on the supplied ID and builds SOQL WHERE CLAUSE based on filters specificed by request parameters
public static List<ADM_Work__c> getWorkObjects(List<String> workIDs, Boolean resolvedFlag) {   
    //retrieve work objects based on children ids and filter by the resolved field if populated
    String resolvedParam = System.currentPageReference().getParameters().get('resolved');
    List<ADM_Work__c> workObjs = null;
    if(resolvedFlag) {
        workObjs = [select Id, Name, Assignee__r.Name, Product_Owner__r.Name, Subject__c, Status__c, Type__c, Priority__c, Scheduled_Build__r.Name, Resolved__c, Closed__c from ADM_Work__c where Resolved__c = 0 and id in :workIDs order by Created_On_import__c];  
    } else {
        workObjs = [select Id, Name, Assignee__r.Name, Product_Owner__r.Name, Subject__c, Status__c, Type__c, Priority__c, Scheduled_Build__r.Name, Resolved__c, Closed__c from ADM_Work__c where id in :workIDs order by Created_On_import__c];  
    }
    return workObjs;
}

//retieves ADM_Parent_Work objects which act as Foreign Key links.  
//This implmentation takes a single ID suitable for the top generation and will eventually support a user defined sort order
public static List<ADM_Parent_Work__c> getChildrenLinks(String id) {
    return [select Child_Work__c, Parent_Work__c, Duplicate__c from ADM_Parent_Work__c where Parent_Work__c = :id order by Parent_Work__c, Sort_Order__c, Created_Date__c];
}

public static List<ADM_Parent_Work__c> getChildrenLinksWithNames(String id) {
    return [select Child_Work__r.Name, Parent_Work__r.Name, Duplicate__c from ADM_Parent_Work__c where Parent_Work__c = :id order by Parent_Work__c, Sort_Order__c, Created_Date__c];
}

//retieves ADM_Parent_Work objects in bulk based on the List of IDs
public static List<ADM_Parent_Work__c> getChildrenLinks(List<String> ids) {
    return [select Child_Work__c, Parent_Work__c, Duplicate__c from ADM_Parent_Work__c where Parent_Work__c in :ids order by Parent_Work__c, Sort_Order__c, Created_Date__c];
}

public static List<ADM_Parent_Work__c> getParentLinksWithNames(String id) {
    return [select Child_Work__r.Name, Parent_Work__r.Name, Duplicate__c from ADM_Parent_Work__c where Child_Work__c = :id order by Parent_Work__c, Sort_Order__c, Created_Date__c];
}

/**
 * Retrieves the list of Parent Work record names for the given Child work ID.
 */
public static List<String> getParentNames(String workId) {
	return ADM_WorkTreeUtils.convertLinkListToParentNameList(ADM_WorkTreeUtils.getParentLinksWithNames(workId));
}

//retieves the parent side of ADM_Parent_Work objects in bulk. In other words give me all work that calls the list of provided IDs their child.  i.e. Give me the parents of the provided list of ids.  
public static List<ADM_Parent_Work__c> getParentLinks(List<String> childIDs) {
   	return [select Child_Work__c, Parent_Work__c, Duplicate__c from ADM_Parent_Work__c where Child_Work__c in :childIDs order by Parent_Work__c, Sort_Order__c, Created_Date__c];
}

testMethod static void testLinkLookups() {
	Id childID = ADM_ParentWork.parentWorkTestSetupParents(2);
	List<ADM_Parent_Work__c> relationships = getChildrenLinks(childID);
	System.assert(relationships != null);
	System.assert(getChildrenLinks(convertLinkListToParentIDList(relationships)) != null);
	
}

}