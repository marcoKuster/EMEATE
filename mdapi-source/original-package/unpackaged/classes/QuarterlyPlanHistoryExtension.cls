public class QuarterlyPlanHistoryExtension {
    public list<wrapperHistory> allHistory {get;set;}
    Private final ID QP_ID;
    Public Quarterly_Plan__c QP {get;set;}
    Private list<ID> relatedPP_IDs = new list<ID>();
    Public list<Partner_Plan__c> InMarket {get;set;}
    Public list<Partner_Plan__c> Target {get;set;}
    Public list<Partner_Plan__c> PDO {get;set;}
    Public list<Partner_Plan__c> Others {get;set;}
    public list<id> IDs {get;set;}
    Public boolean hasTarget {get;set;}
    Public boolean hasInMarket {get;set;}
    Public boolean hasPDO {get;set;}
    Public boolean hasOthers {get;set;}
    Public string TargetSize {get;set;}
    Public string InMarketSize {get;set;}
    Public string PDOSize {get;set;}
    Public string OthersSize {get;set;}
    Public string AllPartners {get;set;}
    Public id selectedPP_ID {get;set;}
    Public Partner_Plan__c thePP {get;set;}
    
    public QuarterlyPlanHistoryExtension (ApexPages.StandardController controller) {
        QP_ID =  controller.getId();
        allHistory = new list<wrapperHistory>();
        allPPH ();
    }  
    
    public void allPPH (){
        map<id,Partner_plan__c> pp = new map<id, Partner_plan__c>(
                                                                    [select id, account__r.name 
                                                                     from Partner_Plan__c 
                                                                     where Quarterly_Plan__r.id = : QP_ID]
                                                                    );
        system.debug('PP size='+pp.size());
        for (Partner_Plan__History pph: [select     createdDate,
                                            Field,
                                            OldValue,
                                            NewValue,
                                            ParentID
                                            
                                  from Partner_Plan__History 
                                   where ParentId in :pp.keySet() 
                                 ]) 
        {
            allHistory.add(new wrapperHistory(pph.CreatedDate, pph.Field, string.valueof(pph.OldValue), string.valueof(pph.NewValue), pp.get(pph.ParentId).account__r.name));                        
        }
        system.debug(allHistory.size());
    }
    
    public class wrapperHistory {
        public Datetime createdDate {get;set;}
        public string field {get;set;}
        public string oldValue {get;set;}
        public string newValue {get;set;}
        public string PartnerName {get;set;}
        
        //constructor
        public wrapperHistory(Datetime d, String f, String ov, String nv, String pn){
            createdDate = d;
            Field = f;
            OldValue = ov;
            NewValue = nv;
            PartnerName = pn;           
        }
        
        
    }
    
    
}