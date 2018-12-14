/**
 * Creates a string in which all of the users' names are delimited by the
 * specified delimiter.
 */
public with sharing class COM_UserFullNameListBuilder {
	private String delimiter;
	private String value;
	private String userFullNameList = '';
	private Boolean firstUser = true;
	
	/**
	 * Creates a new builder with the specified delimiter
	 */
	public COM_UserFullNameListBuilder(String delimiter) {
		this.delimiter = delimiter;
	}
	
	/**
	 * Creates a string in which all of the users' names are delimited by the
	 * specified delimiter.
	 */
	public String buildString() {
		return userFullNameList;
	}
	
	/**
	 * Adds a user to the list; The user must have a Name and must not be null.
	 */
	public void addUser(User user) {
		if(user == null) {
			throw new ADM_UnexpectedValueException('user cannot be null');
		}
		
		if (!firstUser) {
    		userFullNameList += delimiter;
    	} else {
    		firstUser = false;
    	}
   		userFullNameList += user.Name;
	}
}