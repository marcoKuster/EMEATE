public with sharing class ADM_CommonControllerExtension{

    private ApexPages.StandardController controllerObj;
    public ADM_CommonControllerExtension(ApexPages.StandardController controllerObj){
        this.controllerObj = controllerObj;
    }

     public Pagereference doSaveAndNew(){
        if (controllerObj.save() != null) {
            SObject so = controllerObj.getRecord();
            Schema.Describesobjectresult result = so.getSobjectType().getDescribe();
            return new PageReference('/' + result.getKeyPrefix() + '/e');
        }
        return null;
     }

     public Pagereference doSaveAndEdit(){
        if (controllerObj.save() != null) {
            SObject so = controllerObj.getRecord();
            return new PageReference('/' + so.Id + '/e');
        }
        return null;
     }
     
     public Pagereference doSaveAndDetail(){
        String retUrl = '';
        if (controllerObj.save() != null) {
            retUrl = ApexPages.currentPage().getParameters().get('retURL');   
            if(!ADM_TextUtils.isNull(retUrl) && !ADM_TextUtils.isBlank(retUrl)) {
                return new PageReference(retUrl);
            }
            else{
                SObject so = controllerObj.getRecord();
                return new PageReference('/' + so.Id);
            }
        }
        return null;
     }

     public Pagereference doSaveAndListView(){
        if (controllerObj.save() != null) {
            SObject so = controllerObj.getRecord();
            Schema.Describesobjectresult result = so.getSobjectType().getDescribe();
            return new PageReference('/' + result.getKeyPrefix());
        }
        return null;
     }
}