//has to have global scope to be used inside an MDP page since salesforce wraps MDP actions in iframes
global with sharing class ADM_WorkAssignment {

     /**
     * @param severityLevel The severity level value
     * @param productTag The product tag
     * @param recordTypeId The record type
     * @param workType The work type value
     * @param recipients The current list of recipients
     */
    @RemoteAction
    public static AssignmentContext getAssignments(String severityLevel, ADM_Product_Tag__c productTag, RecordType recordType, String workType, String recipients) {


        AssignmentContext context = new AssignmentContext();

        recordType = ADM_RecordType.get(recordType.Id);
        Boolean investigation = recordType != null && recordType.Name.equals(ADM_Work.RECORD_TYPE_NAME_INVESTIGATION);
        Boolean helpType = workType != null &&  workType.equalsIgnoreCase('help');
        Boolean managerReview = true;

        //validate the entered information
        if(investigation) {

            //don't continue evaluating if the product tag and severity have not been set
            if(ADM_TextUtils.isBlank(severityLevel) && productTag == null) {
                return context;
            }

            String verbiage = 'Select the following item(s) to populate assignments:';
            String errorMessage = '';
            if(ADM_TextUtils.isBlank(severityLevel) || ADM_TextUtils.isNoneSelected(severityLevel)) {
              errorMessage += ' severity level,';
            }
            if(productTag == null) {
              errorMessage += ' product tag,';
            }

            if(errorMessage.length() > 0) {
                errorMessage = verbiage + errorMessage;
                if(errorMessage.endsWith(',')) {
                    errorMessage = errorMessage.substring(0, errorMessage.lastIndexOf(','));
                }
                errorMessage += '.';
                context.errorMessages.add(errorMessage);
                return context;
            }
        }

        ADM_AutoAssignWorkAction action = ADM_AutoAssignWorkAction.createActionForTags(new List<ADM_Product_Tag__c>{productTag});
        context.assignments = action.getAssignments(productTag, investigation, helpType, managerReview, recordType, severityLevel);

        //first remove any recipients added by the previous assignment rule
        if(recipients != null && recipients != '') {
            recipients = ADM_NotificationUtils.removeAutoAssignedRecipients(recipients);
        }

        //next add new ones
        context.recipients = recipients + ADM_NotificationUtils.HIDDEN_RECIPIENT_DELIMITER + ADM_NotificationUtils.encodeEmailToLine(context.assignments.Email_Subscription_ID);

        return context;
    }

    @RemoteAction
    public static PriorityMetaData getPriorityMetaData(String Id) {
        PriorityMetaData metaData = new PriorityMetaData();
        if(id != null) {
            metaData.workSObject = ADM_Work.getById(Id);
        }

        metaData.impacts = ADM_Impact.getAllByType(ADM_Work.BUG_RECORD_TYPE_NAME);
        metaData.priorityMappings = ADM_Work.getPriorityMappingsByImpacts(metaData.impacts);

        return metaData;
    }

    global class AssignmentContext {
        public List<String> errorMessages = new List<String>();
        public ADM_AutoAssignWorkAction.Assignment assignments;
        public String recipients;
    }

    global with sharing class PriorityMetaData {
        public ADM_Work__c workSObject;
        public List<ADM_Impact__c> impacts;
        public List<ADM_Priority_Mapping__c> priorityMappings;
    }

}