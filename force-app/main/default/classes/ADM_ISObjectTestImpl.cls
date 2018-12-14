/*
 *	This class implements the ADM_ISObject interface for representing foreign custom
 *	objects in test scenarios. This implemenation creates a mock version of the foreign
 *	object.
 *
 *    @userstory W-3409362 https://gus.my.salesforce.com/a07B0000002ZSY6 
 *    @author: snahm
 * 
 */
 
 public class ADM_ISObjectTestImpl implements ADM_ISObject {
    private Map <String, Object> Fields;
    private SObject SObj;
    
    public Object get (String f) {
    	return Fields.get(f);
    }
    public void put (String f, Object o) {
    	Fields.put(f, o);
    }
    public void putSObject(SObject so) {
    	this.SObj = so;
    }
    
    public SObject getSObject() {
    	return this.SObj;
    }
    
    public ADM_ISObjectTestImpl(SObject so) {
    	this.Fields = new Map<String, Object>();
    	putSObject(so);
    }
}