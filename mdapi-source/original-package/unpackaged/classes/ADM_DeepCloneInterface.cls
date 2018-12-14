public virtual interface ADM_DeepCloneInterface {

	// No access modifier is necessary for interface methods - these are always public or global depending on the interface visibility 
	void cloneAccordingToType(Id originalID, Id cloneID, String whatToClone);
	void clone(Id originalID, Id cloneID);
}