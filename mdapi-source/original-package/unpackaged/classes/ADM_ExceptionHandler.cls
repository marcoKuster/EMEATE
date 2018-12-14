public with sharing class ADM_ExceptionHandler {


  public static Id saveException(System.Exception e) {
    return saveException(e, null);
  }
  
  public static Id saveException(System.Exception e, String data) {
    ADM_GUS_Exception__c ge = populateException(e, data);
    insert ge;
    return ge.id;
  }
  
  public static void saveExceptions(List<ADM_GUS_Exception__c> gusExceptions) {
  	if(gusExceptions == null || gusExceptions.isEmpty()) {
        return;
    }
    
    try {
      Database.insert(gusExceptions, false);
    } catch(Exception exc) {
      System.debug(LoggingLevel.WARN, 'Unable to save exceptions.');
    }
  }

  public static void saveExceptions(List<System.Exception> exceptions, String data) {
  	if(exceptions == null || exceptions.isEmpty()) {
  		return;
  	}
  	
    List<ADM_GUS_Exception__c> gusExceptions = new List<ADM_GUS_Exception__c>();
    for(System.Exception exc : exceptions) {
      ADM_GUS_Exception__c ge = populateException(exc, data);
      gusExceptions.add(ge);
    }
    saveExceptions(gusExceptions);
  }
  
    /*
     if allOrNot boolean is true all results including successful are saved
     if allOrNot boolean is false only errors are saved.

   */

  public static void saveExceptions(List<Database.SaveResult> saveResults, String name, String message, String data, Boolean saveAll) {
    if(saveResults == null || saveResults.isEmpty()) {
        return;
    }
    
    List<ADM_GUS_Exception__c> gusExceptions = new List<ADM_GUS_Exception__c>();
    for(Database.SaveResult sr : saveResults) {
      ADM_GUS_Exception__c ge = createSaveResultException(sr, name, message, data, saveAll);
      if(null != ge){
      gusExceptions.add(ge);
    }
    }
    saveExceptions(gusExceptions);
  }

	/*
     if allOrNot boolean is true all results including successful are saved
     if allOrNot boolean is false only errors are saved.

   */
  
  public static void saveExceptions(List<Database.DeleteResult> deleteResults, String name, String message, String data, Boolean saveAll) {
    if(deleteResults == null || deleteResults.isEmpty()) {
        return;
    }
    
    List<ADM_GUS_Exception__c> gusExceptions = new List<ADM_GUS_Exception__c>();
    for(Database.DeleteResult dr : deleteResults) {
      ADM_GUS_Exception__c ge = createDeleteResultException(dr, name, message, data, saveAll);
      if(null != ge){
      gusExceptions.add(ge);
    }
    }
    saveExceptions(gusExceptions);
  }
  
  /**
   * Creates a new exception about the specified save result.
   */
  private static ADM_GUS_Exception__c createSaveResultException(Database.SaveResult sr, String name, String message, String data, Boolean saveAll) {
    ADM_GUS_Exception__c ge = null;
    Database.Error [] dbErrors = sr.getErrors();
    if(saveAll || dbErrors.size()>0) {
      ge = new ADM_GUS_Exception__c();
      ge.Name = (name != null) ? name : 'Database.SaveResult';
      ge.Description__c = (message != null) ? message + ': \n\n' : '';
      for(Database.Error error : dbErrors) {
        ge.Description__c += '[' + error.getStatusCode() + '] ' + error.getMessage() + '\n\n';
      }
      ge.Data_Capture__c = getDataValue(data);
    }
    return ge;
  }
  
  /**
   * Creates a new exception about the specified save result.
   */
  private static ADM_GUS_Exception__c createDeleteResultException(Database.DeleteResult dr, String name, String message, String data, Boolean saveAll) {
    ADM_GUS_Exception__c ge = null;
    Database.Error [] dbErrors = dr.getErrors();
    if(saveAll || dbErrors.size()>0){
      ge = new ADM_GUS_Exception__c();
      ge.Name = (name != null) ? name : 'Database.DeleteResult';
      ge.Description__c = (message != null) ? message + ': \n\n' : '';
      for(Database.Error error : dbErrors) {
        ge.Description__c += '[' + error.getStatusCode() + '] ' + error.getMessage() + '\n\n';
      }
      ge.Data_Capture__c = getDataValue(data);
    }
    return ge;
  }
  
  private static ADM_GUS_Exception__c populateException(System.Exception e, String data) {
    ADM_GUS_Exception__c ge = new ADM_GUS_Exception__c();
    ge.Name = e.getTypeName(); 
    ge.Description__c = 'Cause:' + e.getCause() + ' Message:' + e.getMessage();
    ge.Data_Capture__c = getDataValue(data);
    return ge;
  }

  private static String getDataValue(String data) {
    if(data != null && data.length() > 32000) {
      return data.substring(0, 31900) + '...';
    }
    return data;
  }
}