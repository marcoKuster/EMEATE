//has to have global scope to be used inside an MDP page since salesforce wraps MDP actions in iframes
global with sharing class ADM_RichAutoCompleteController {
	private Id selectedUserId;
	private transient User selectedUser;
	
	public ADM_RichAutoCompleteController() {
	}
	
	public SObject currentSObject {
		get;
		set;
	}
	
	public String currentField {
		get;
		set;
	}
	
	public String name {
		get {
            if(name == null) {
                 User user = getSelectedUser();
                 if(user != null) {
                    name = user.Name;
                 }
            }
            return name;
        }
		set;
	}
	
	public String profileImageUrl {
		get {
			if(profileImageUrl == null) {
				 User user = getSelectedUser();
				 if(user != null) {
                    profileImageUrl = user.SmallPhotoUrl;
				 } else {
                    profileImageUrl = '/profilephoto/005/F';
				 }
			}
			return profileImageUrl;
		}
		set;
	}
	
	private Id getSelectedUserId() {
		if(selectedUserId == null) {
	        if(currentSObject == null || currentField == null) {
	            return null;
	        }
	        
	        this.selectedUserId = (Id)currentSObject.get(currentField);
		}
		return selectedUserId;
	}
	
	private User getSelectedUser() {
		if(selectedUser != null) {
			return selectedUser;
		}
		Id selectedUserId = getSelectedUserId();
		
		List<User> users = [select Id, Name, SmallPhotoUrl from User where Id = :selectedUserId];
		if(users.isEmpty()) {
			return null; 
		}
		
		selectedUser = users.get(0);
		return selectedUser;
 	}

    @RemoteAction
    global static Map<String, Object> getUsersWithNameLike(String name) {
    	Integer returnLimit = 10;
    	
    	//add the wildcard characters for the name
    	name = name.replace('%', '\\%');
    	name = '%' + name + '%';
    	
        List<User> matchingUsers = [select Id, Name, SmallPhotoUrl from User where IsActive = true and Name like :name limit :returnLimit];
        
        Map<String, Object> resultsMap = new Map<String, Object>();
        resultsMap.put('results', matchingUsers);
        return resultsMap;
    }

}