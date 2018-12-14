public with sharing class LockingRecords {
	private String teamId;
	public List<Locking_Record__c> locks = new List<Locking_Record__c>();
	
	public String message { 
		get {
			if(locks.isEmpty()) {
				message = '';
			} else {
				String createdByName = locks[0].CreatedBy.Name;
				//createdByName = ADM_TextUtils.getUTF8EncodedValue(createdByName);
				message = 'Team has been locked out of main branch by ' + createdByName + '. ';	
			}
			return message;
		} 
		set; 
	}
	
	public Locking_Record__c lockRecord{
		get{
			if(locks.isEmpty()){
				lockRecord = null;
			}
			else{
				lockRecord = locks[0];
			}
			return lockRecord;
		}
		set;
	}
	
	public LockingRecords(String team) {
		this.teamId = team;
	}
	
	public List<Locking_Record__c> getLocks() {		
		locks = [Select l.Id, l.Name, l.Description__c, l.CreatedBy.Name, l.CreatedById From Locking_Record__c l Where l.Status__c = 'Locked' and l.Team__c =: this.teamId order by Id desc];
		return locks; 
	}
}