public class PartnerPlanViewRedirect 
{
    
    Private final Partner_Plan__c pp;
    Private id pp_QP_ID;
    public PartnerPlanViewRedirect(ApexPages.StandardController stdController) 
    {
		this.pp = (Partner_Plan__c)stdController.getRecord();
        Partner_plan__c pp = [select quarterly_plan__c from Partner_Plan__c where id=:pp.id limit 1];
        pp_QP_ID = pp.Quarterly_Plan__c;
  	}
	
    public pagereference redirectToQuarterlyPlan()
    {
    	PageReference pg = new PageReference ('/'+pp_QP_ID);
        pg.setRedirect(true);
		return pg;

    }
}