/**
 * After retrieving a list of users, this class will help index the users by
 * different properties so that they are easier to find.  This class also only
 * builds the indexes once, so calling the getBy* methods will not use as many
 * additional script statements.
 */
public with sharing class ADM_UserCache {
    private User[] users = new User[0];
    private Map<Id, User> idIndex;
    private Map<String, User> emailIndex;
    
    public ADM_UserCache() {
    }
    
    /** 
     * Creates a new cache from the list of users
     */
    public ADM_UserCache(User[] users) {
        this.add(users);
    }
    
    /**
     * Creates a new cache from the specified map of users
     */
    public ADM_UserCache(Map<Id, User> idIndex) {
        this.idIndex = idIndex;
        this.users = idIndex.values();
    }
    
    /**
     * Adds the specified list of users to the cache.
     */
    public void add(User[] users) {
        this.users.addAll(users);
        this.emailIndex = null;
        this.idIndex = null;
    }
    
    /**
     * Determines if the cache contains the specified ID
     */
    public Boolean contains(Id id) {
        return getIdIndex().containsKey(id);
    }
    
    /**
     * Gets the user with the specified ID. If no user is cached with the 
     * specified ID, a null reference.
     */
    public User getById(String id) {
        if(id == null) {
            return null;
        }
        
        return getIdIndex().get(id);
    }
    
    /**
     * Gets the user with the specified email. If no user is cached with the 
     * specified email, a null reference.
     */
    public User getByEmail(String email) {
        if(email == null) {
            return null;
        }
        
        if(emailIndex == null) {
            emailIndex = new Map<String, User>();
            for(User user : users) {
                if(user.Email == null) {
                    continue;
                }
                
                //since we want email address lookup to be case insensitive
                //we will store the email in lower case format
                emailIndex.put(user.Email.toLowerCase(), user);
            }
        }
        
        return emailIndex.get(email.toLowerCase());
    }
    
    private Map<Id, User> getIdIndex() {
    	if(idIndex == null) {
            idIndex = new Map<Id, User>(users);
        }
        return idIndex;
    }
}