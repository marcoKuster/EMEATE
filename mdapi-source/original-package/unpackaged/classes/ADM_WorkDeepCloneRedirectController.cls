public class ADM_WorkDeepCloneRedirectController {
    public String recordId{get;set;}
    public ADM_WorkDeepCloneRedirectController(){
        recordId = ApexPages.currentPage().getParameters().get('id');
    }
}