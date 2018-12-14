@isTest
public class ADM_Severity_TypeTest {
        
    //test method i used to load the table with the values i needed for the field dependencies for the select list options
    @isTest
    static void testGetToAddresses() {
        List<String> severityNames = new List<String>{'P0','P1','P2'};
        List<ADM_Severity__c> severities = new List<ADM_Severity__c>();
        for(String severityName : severityNames) {
           ADM_Severity__c severity = new ADM_Severity__c();
           severity.Name = severityName;
           severities.add(severity);
        }
        insert severities;
        
        List<String> typeNames = new List<String>{'Test Change','Test Case','Test Failure','Test Tool','Skunkforce'};
        List<ADM_Type__c> types = new List<ADM_Type__c>();
        for(String typeName : typeNames) {
            ADM_Type__c t = new ADM_Type__c();
            t.Name = typeName;
            types.add(t);
        }
        insert types;
        
        ADM_Severity_Type.create();
        
        Integer severityTypeCount = [select count() from ADM_Severity_Type__c];
        System.assertEquals(severities.size() * types.size(), severityTypeCount);
    }
    
    @isTest
    static void testGetAllBy() {
        //create a Severity
        ADM_Severity__c s = new ADM_Severity__c();
        s.name = 'Test Severity';
                        
        //create a Type
        ADM_Type__c t = new ADM_Type__c();
        t.name = 'Bug';
        
        //create Severity Type
        ADM_Severity_Type__c st = new ADM_Severity_Type__c(Type__c=t.id,Severity__c=s.id);
        Database.insert(st);
        
        List<String> columnValues = new List<String>();
        columnValues.add(st.id);
        ADM_Severity_Type__c[] sts = ADM_Severity_Type.getAllBy('id', columnValues);
        System.assert(sts != null);
        System.assert(sts.size() == 1);
    }   
    
    @isTest
    static void testGetBySeverityType() {
        //create a Severity
        ADM_Severity__c s = new ADM_Severity__c();
        s.name = 'Test Severity';
        Database.insert(s);
                        
        //create a Type
        ADM_Type__c t = new ADM_Type__c();
        t.name = 'Bug';
        Database.insert(t);
        
        //create Severity Type
        ADM_Severity_Type__c st = new ADM_Severity_Type__c(Type__c=t.id,Severity__c=s.id);
        Database.insert(st);              
        
        List<String> columnValues = new List<String>();
        columnValues.add(st.id);
        ADM_Severity_Type__c stype = ADM_Severity_Type.getBySeverityType(t.name, s.name);
        System.assert(stype != null);
        
    }   
    
    @isTest
    static void testGet() {
        //create a Severity
        ADM_Severity__c s = new ADM_Severity__c();
        s.name = 'Test Severity';
        Database.insert(s);
                        
        //create a Type
        ADM_Type__c t = new ADM_Type__c();
        t.name = 'Bug';
        Database.insert(t);
        
        //create Severity Type
        ADM_Severity_Type__c st = new ADM_Severity_Type__c(Type__c=t.id,Severity__c=s.id);
        Database.insert(st);              
        
        
        ADM_Severity_Type__c stype = ADM_Severity_Type.get(st.id);
        System.assert(stype != null);
        
    }   
}