/*
 *	This class implements the ADM_ISObject interface for representing foreign custom
 *	objects in runtime scenarios. This implemenation uses the direct-field access
 *	mechanism of the SObject class (get/put).
 *
 *    @userstory W-3409362 https://gus.my.salesforce.com/a07B0000002ZSY6 
 *    @author: snahm
 * 
 */
 
 public class ADM_ISObjectRuntimeImpl implements ADM_ISObject {
    private SObject SObj;
    
    public Object get (String f) {
    	return SObj.get(f);
    }
    public void put (String f, Object o) {
    	SObj.put(f, o);
    }
    public void putSObject(SObject so) {
    	this.SObj = so;
    }
    
    public SObject getSObject() {
    	return this.SObj;
    }
    
    public ADM_ISObjectRuntimeImpl(SObject so) {
    	putSObject(so);
    }
    
}