public with sharing class ADM_MessageComponentController {
	public ADM_MessageComponentController() {}
	
	public void setLocalSrc(String s) {
		this.src = s;
	}
	
	public String getLocalSrc() {
		return this.src;
	}
	
	public String src {
		get; set; 
	}
}