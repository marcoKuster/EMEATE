public with sharing virtual class ADM_PriorityMatrixIndicator {
    public String indicatorColor {
    	get {
    		if(priority == null) return 'white';
            if(priority.equalsIgnoreCase('p0')) {
                indicatorColor = '#FF0000';
            } else if(priority.equalsIgnoreCase('p1')) {
                indicatorColor = '#FF9A00';
            } else if(priority.equalsIgnoreCase('p2')) {
                indicatorColor = '#DCFF00';
            } else if(priority.equalsIgnoreCase('p3')) {
                indicatorColor = '#90FF00';
            } else if(priority.equalsIgnoreCase('p4')) {
                indicatorColor = '#0F0';
            } 
            return indicatorColor;
    	}
    	set;
    }
    public String priority { get; set; }
    
    public ADM_PriorityMatrixIndicator() {
        this.priority = System.currentPageReference().getParameters().get('priority');
    }
    
}