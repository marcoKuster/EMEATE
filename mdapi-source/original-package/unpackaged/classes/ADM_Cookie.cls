public with sharing class ADM_Cookie {
	
	public ADM_Cookie(String cookieName, String defaultTab) {
		this.name = cookieName;
		this.defaultTabName = defaultTab;
	}
	
    public String name { get; set; }
    
    public String defaultTabName { get; set; }
    
    public String activeTab { 
		get {
			if(activeTab == null) {
				Cookie acTab = Apexpages.currentPage().getCookies().get(name);
				if(acTab == null) {
					acTab = new Cookie(name, defaultTabName, null, 1, false);
					Apexpages.currentPage().setCookies(new Cookie[]{acTab});
				}
				activeTab = acTab.getValue();
			}
			return activeTab;
		} 
		set; 
	}

}