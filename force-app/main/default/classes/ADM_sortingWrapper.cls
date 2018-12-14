public with sharing class ADM_sortingWrapper {
	public String sortBy { get; set; }
	public String sortOrder { get; set; }
	
	public ADM_SortingWrapper() {
	}
	
	public ADM_SortingWrapper(String sortBy, String sortOrder) {
		this.sortBy = sortBy;
		this.sortOrder = sortOrder;
	}
}