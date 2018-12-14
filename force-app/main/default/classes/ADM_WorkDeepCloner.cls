public with sharing class ADM_WorkDeepCloner {
    
    public Boolean cloneAcceptanceCriteria { get; set; }
    public Boolean cloneTasks { get; set; }
    public Boolean cloneThemeAssignments { get; set; }
    public String parentValue { get; set; }
    public String childValue { get; set; }
    
    public ADM_WorkDeepCloner() {
        cloneAcceptanceCriteria = true;
        cloneTasks = true;
        cloneThemeAssignments = true;
    } 
    
    public ADM_Work__c clone(ADM_Work__c original) {
        SavePoint savePoint = Database.setSavePoint();
        ADM_Work__c clone = null;
        try {
            //update to standard query once Apex clone() bug is fixed W-912508
            original = [select Name, Details__c, Test_Plan__c, Scrum_Team_Name__c, Sprint_Name__c, Attributes__c, Executive_Involved__c,Severity_Level__c,Request_RD_Mgr_Review__c,Critical_CRM_Feature__c,Red_Account__c,Deal_at_Risk__c,Estimated_Financial_Impact__c,Details_and_Steps_to_Reproduce__c, Senior_Management_POC__c, CS_Contact__c, Num_Of_Prod_Occ__c, Scrumforce_ID__c, Budget_ID__c, Additional_Details__c,Use_Prioritizer__c,User_Type__c,Story_Points__c,Priority_Rank__c,Theme__c, Sprint__c, Last_Modified_By_Copy__c,Last_Modified_By__c,Priority_Mapping__c,Priority_Mapping_Copy__c,Priority_Default__c,Priority_Override_Explanation_Copy__c,Priority_Override_Explanation__c,Frequency__c, Impact__c, Impact__r.Name, Preserve_Formatting__c, Preserve_Formatting_Copy__c, Scheduled_Build_Copy__c, Found_In_Build_Copy__c,Root_Cause_Analysis_2__c, Number_of_Cases__c, ftest__c, Type__c, Template_Name__c, Template_Description__c, Tech_Writer__c, System_Test_Engineer__c, UE_Engineer__c, SystemModstamp, Subscribe_to_Work__c, Subject__c, Status__c, Security__c, Scrum_Team__c, Schema__c, Scheduled_On__c, Scheduled_Build__c, Related_URL__c, Regressed__c, RecordType.Name, RecordType.Id,RecordTypeId, QA_Engineer__c, Product_Owner__c, Product_Child__c, Product_Tag__c, Priority__c, Perforce_Status__c, Minor_Func_Area__c, Help_Status__c, Found_in_Build__c, Description__c, Customer__c, Assignee__c  from ADM_Work__c where id =:original.id];
            
            //clone the work
            clone = original.clone(false, true);
            
            //remove the fields that shouldn't be cloned
            clone = ADM_WorkUtils.removeFieldsNotApplicableForClone(clone);   
            
            //set the fields of the clone
            clone = ADM_WorkUtils.initializeFieldsForClone(clone);
            
            clone.Frequency__c = original.Frequency__c;
            clone.Impact__c = original.Impact__c;
            if(original.Type__c != 'Bug') {
                clone.Priority__c = original.Priority__c;
            }
            
            //set the attributes of the clone
            try {
                if(original.Type__c == 'Test Failure' || original.Type__c == 'Test Change') {
                    //attributes should be null since it is one of the fields which is not cloned
                    if(clone.Attributes__c == null) clone.Attributes__c = 'Regressed;';
                } else if(original != null && original.RecordType != null && original.RecordType.Name == 'User Story') {
                    //attributes should be null since it is one of the fields which is not cloned
                    if(clone.Attributes__c == null) clone.Attributes__c = 'Requires Testing;';
                }
                 
            } catch (Exception ea) {
                //catch exception but don't give up with clone...
                System.debug('Unexpected exception working with clone attributes:' + ea);
            }
           
            
            insert clone;
            
            
            //each related object implements ADM_DeepCloneInterface 
            Id originalWorkId = original.Id;
            Id clonedWorkId = clone.Id;
            if(cloneAcceptanceCriteria) ADM_AcceptanceCriterionCloner.clone(originalWorkId, clonedWorkId);
            if(cloneTasks) ADM_TaskCloner.clone(originalWorkId, clonedWorkId);
            if(childValue != 'None') ADM_ChildWorkCloner.cloneAccordingToType(originalWorkId, clonedWorkId, childValue);
            if(parentValue != 'None') ADM_ParentWorkCloner.cloneAccordingToType(originalWorkId, clonedWorkId, parentValue);
            if(cloneThemeAssignments) (new ADM_WorkDeepCloner.ADM_ThemeAssignmentCloner()).clone(originalWorkId, clonedWorkId);
        
        } catch (Exception e) {
            Database.rollback(savePoint);
            System.debug('Unexpected exception cloning work:' + e);
            throw e;
        }
        
        return clone;
    }
    
    public class ADM_ThemeAssignmentCloner implements ADM_DeepCloneInterface {
        public void clone(Id originalWorkId, Id clonedWorkId) {
            try {
                List<ADM_Theme_Assignment__c> clonedAssignments = new List<ADM_Theme_Assignment__c>();
                
                List<ADM_Theme_Assignment__c> originalThemeAssignments = [select Theme__c from ADM_Theme_Assignment__c where Work__c = :originalWorkId];
                for(ADM_Theme_Assignment__c originalAssignment : originalThemeAssignments) {
                    ADM_Theme_Assignment__c clonedAssignment = originalAssignment.clone(false, true);
                    clonedAssignment.Work__c = clonedWorkId;
                    clonedAssignments.add(clonedAssignment);
                }
                
                insert clonedAssignments;
            } catch(Exception exc) {
                System.debug('Unexpected exception cloning theme assignments:' + exc);
            }
        }
        public void cloneAccordingToType(Id originalID, Id cloneID, String whatToClone){}
    }
}