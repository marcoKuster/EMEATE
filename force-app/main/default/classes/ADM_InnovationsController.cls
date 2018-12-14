public class ADM_InnovationsController {

      public ADM_InnovationsController(ApexPages.StandardSetController sc){}

      public String getUrlForListView(){
       	 return System.Url.getSalesforceBaseUrl().toExternalForm();
      }
	
}