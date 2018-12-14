public with sharing class RetrospectiveMiniController {
	public String userId {get; set;}
	public List<RetrospectiveMiniDetail> retros {get; private set;}
	
	public RetrospectiveMiniController() {
		initView();
	}
	
	private static Map<String, String> IMAGE_MAP = new Map<String, String>(); 
	
	private void initView() {
		List<Retrospective__c> retrospectives =  [Select Id, Overall_Rating_employee__c, Overall_Rating_manager__c, Review_Period__r.Name from Retrospective__c 
		    where User__c = :UserInfo.getUserId() 
		    order by Review_Period__r.Release_Date__c desc limit 2];
		    
		retros = new List<RetrospectiveMiniDetail>();
		
		for (Retrospective__c record: retrospectives) {
			RetrospectiveMiniDetail retro  = new RetrospectiveMiniDetail();
			retro.retroId = record.Id;
			retro.userRatingImageName = getRatingImageName(record.Overall_Rating_employee__c);
			retro.mgrRatingImageName = getRatingImageName(record.Overall_Rating_manager__c);
			retro.ratingPeriod = record.Review_Period__r.Name;
			retros.add(retro);
		}
	}
	
	private String getRatingImageName(String rating) {
		if (rating == null) return null;
		
		if (IMAGE_MAP.isEmpty()) {
			initializeImageMap();
		}
		
		return IMAGE_MAP.get(rating);
	}
	
	private void initializeImageMap() {
		IMAGE_MAP.put('Sunny', 'sunny.gif');
		IMAGE_MAP.put('Partly Sunny', 'partlysunny.gif');
		IMAGE_MAP.put('Cloudy', 'cloudy.gif');
		IMAGE_MAP.put('Rain Showers', 'rainy.gif');
		IMAGE_MAP.put('Blizzard', 'snow_showers.gif');
	}
	
	
	class RetrospectiveMiniDetail {
		public Id retroId {get; set;}
		public String userRatingImageName {get; set;}
		public String mgrRatingImageName {get; set;}
		public String ratingPeriod {get; set;}
	}
	
	private static testMethod void testGetRatingImageName() {
    	RetrospectiveMiniController controller = new RetrospectiveMiniController();
    	System.assertEquals(null, controller.getRatingImageName(null));
    	System.assertEquals(null, controller.getRatingImageName('xyz'));
    	System.assert(controller.getRatingImageName('Sunny').endsWith('.gif'));
	}

}