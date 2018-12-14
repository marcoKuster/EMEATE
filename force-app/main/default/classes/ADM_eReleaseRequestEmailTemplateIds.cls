/*
 *    @userstory W-1224650 https://gus.salesforce.com/a07B0000000LyH4IAK
 *    @author snahm
 */
/*
 * These email templates are set the first time they are needed by
 * the ADM_eReleaseRequestTrigger.  They effectively never
 * change, so we cache them here for efficiency.
 */

public class ADM_eReleaseRequestEmailTemplateIds {
    public static Id templatePendingId, 
                templateApprovedId, 
                templateRejectedID,
                templateNMIId,
                templateWithdrawnId;
}