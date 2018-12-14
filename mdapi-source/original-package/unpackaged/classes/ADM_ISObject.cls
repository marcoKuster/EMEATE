/*
 *	Interface for representing foreign custom objects. Two implementations of this interface
 *	are used for Runtime and Test access/update of the foreign object. 
 *
 *    @userstory W-3409362 https://gus.my.salesforce.com/a07B0000002ZSY6 
 *    @author: snahm
 * 
 */

public interface ADM_ISObject {
    Object get(String s);
    void put(String s, Object o);
    SObject getSObject();
    void putSObject(SObject so);
}