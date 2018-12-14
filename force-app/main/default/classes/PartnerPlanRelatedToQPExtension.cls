public class PartnerPlanRelatedToQPExtension {
    Private final ID QP_ID;
    Public Quarterly_Plan__c QP {get;set;}
    Private list<ID> relatedPP_IDs = new list<ID>();
    Public list<Partner_Plan__c> InMarket {get;set;}
    Public list<Partner_Plan__c> Target {get;set;}
    Public list<Partner_Plan__c> PDO {get;set;}
    Public list<Partner_Plan__c> Others {get;set;}
    Public list<Partner_Plan__c> trickForTable {get;set;}
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
    Public string page {get;set;}
    Public id selectedPP_ID {get;set;}
    Public id selectedP_ID {get;set;}
    Public Partner_Plan__c thePP {get;set;}
    Private list<Partner_Plan__c> cloneTarget;
    Private list<Partner_Plan__c> cloneInMarket;
    private double EffectivePartnerTime {get;set;}
    public integer EffectivePartnerTimeI {get;set;}
    public double EffectiveFullUtilisation {get;set;}
    // filter by PAM
    public string SelectedPAM { get; set; }
    public List<SelectOption> PAMs { get; set; }
    private set<string> allPAMs = new Set<string>();
    // AllInOnePage
    Public boolean QPU_More {get;set;}
    Public string MoreorLess {get;set;}
    Public list<string> tableHeaderTarget {get;set;}
    
    
    public PartnerPlanRelatedToQPExtension(ApexPages.StandardController controller) {
        QP_ID =  controller.getId();
        QP = QuarterlyPlanValues(QP_ID);
        EffectivePartnerTime = 0.0;
        PAMs= new List<SelectOption>();
        selectedPAM = 'No';
        allPP_IDs ();
        //AllInOnePage
        QPU_More = False;
        MoreOrLess = 'More Info';
        tableHeaderTarget = new list<string>{'','Partner Name','PAM','Priority','Ad-Hoc time','Selling the Platform','TR','DP & Contract','Workshop','SR','Design Sprint', 'Comments'};
        //fixing average
        if (QP.Average_Ad_Hoc_Enablement__c == null) {QP.Average_Ad_Hoc_Enablement__c = 0.5;}
        if (QP.Current_Av_Ad_Hoc_Enablement__c == null) {QP.Current_Av_Ad_Hoc_Enablement__c = QP.Average_Ad_Hoc_Enablement__c;}
        if (QP.Average_Design_Sprint__c == null) {QP.Average_Design_Sprint__c = 24;}
        if (QP.Current_Av_Design_Sprint__c == null) {QP.Current_Av_Design_Sprint__c =QP.Average_Design_Sprint__c;}
        if (QP.Average_DP_Contract__c == null) {QP.Average_DP_Contract__c = 1.0;}
        if (QP.Current_Av_DP_Contract__c == null) {QP.Current_Av_DP_Contract__c = QP.Average_DP_Contract__c;}
        if (QP.Average_Product_Review__c == null) {QP.Average_Product_Review__c = 2.0;}
        if (QP.Current_Av_Product_Review__c == null){QP.Current_Av_Product_Review__c = QP.Average_Product_Review__c;}
        if (QP.Average_Selling_the_Platform__c == null) {QP.Average_Selling_the_Platform__c= 4.0;}
        if (QP.Current_Av_Selling_the_Platform__c == null){QP.Current_Av_Selling_the_Platform__c =QP.Average_Selling_the_Platform__c;}
        if (QP.Average_SR__c== null){QP.Average_SR__c = 0.5; }
        if (QP.Current_Av_SR__c == null) {QP.Current_Av_SR__c = QP.Average_SR__c;}
        if (QP.Average_TR__c == null ){ QP.Average_TR__c = 2.0;}
        if (QP.Current_Av_TR__c == null) {QP.Current_Av_TR__c = QP.Average_TR__c;}
        if (QP.Average_Workshop__c == null ){QP.Average_Workshop__c = 4.0;}
        if (QP.Current_Av_Workshop__c == null) {QP.Current_Av_Workshop__c = QP.Average_Workshop__c;}
            
    }
    

    public void allPP_IDs (){
        InMarket = new list<Partner_Plan__c>();
        PDO = new list<Partner_Plan__c>();   
        Target = new list<Partner_Plan__c>();
        Others = new list<Partner_Plan__c>();
        trickForTable = new List<Partner_Plan__c>();
        //Average counter & Sum
        integer counterSTP = 0;
        decimal sumSTP = 0;
        integer counterDS = 0;
        decimal sumDS = 0;
        integer counterW = 0;
        decimal sumW = 0;
        integer counterTR = 0;
        decimal sumTR = 0;
        integer counterDP = 0;
        decimal sumDP = 0;
        integer counterSR = 0;
        decimal sumSR = 0;
        integer counterPR = 0;
        decimal sumPR = 0;
        integer counterAH = 0;
        decimal sumAH = 0;
        for (Partner_Plan__c pp: [select id, admin__c,selling_the_Platform__c, Needs_selling_the_Platform__c,Account_Plan__c, Cadence_Minutes__c, 
                                  Comments__c,Investigation_Escalation__c, Design_Sprint__c, Needs_Design_Sprint__c, Has_a_DP_planned__c, 
                                  PM_Activities__c,Security_Review__c, Needs_SR__c,TR__c, Needs_TR__c,DP_Contract__c, Needs_DP_Contract__c, priority__c,
                                  Account__r.PAM__c, Account__r.name, Account__r.type,Account__r.id, Account__r.Cadence_Call_doc__c, Account__r.Tech_Account_Plan_doc__c,
                                  Selling_the_Platform_Done__c,Design_Sprint_Done__c,Workshop_Done__c,TR_Done__c,DP_Contract_Done__c,
                                  SR_Done__c,Product_review_Done__c,
                                  Product_Review__c, Needs_Product_Review__c,Total_Time__c,Workshop__c, Needs_Workshop__c, Ad_Hoc__c, Quarterly_Plan__c
                                  from Partner_Plan__c 
                                  where Quarterly_Plan__r.id = : QP_ID 
                                  order by Account__r.PAM__c,Account__r.name]) 
        {
			
            // Provide list of In-Market/PDO/Target Partners
            // Others are treated as Target
            
            if (pp.Account__r.type == 'In-Market' && (selectedPAM =='No' || selectedPAM == pp.Account__r.PAM__c))
            {               
                InMarket.add(pp); 
            } else if (pp.Account__r.type == 'PDO')
            { 
                PDO.add(pp);                              
            } else if (pp.Account__r.type == 'Prospect' && (selectedPAM =='No' || selectedPAM == pp.Account__r.PAM__c))
            { 
                Target.add(pp); 
            } else if (pp.Account__r.type == 'Other')
            {
                Others.add(pp);                           
            } 
            
            // Process Average
            if (pp.Needs_selling_the_Platform__c & pp.Selling_the_Platform__c != null) {sumSTP += pp.selling_the_Platform__c; CounterSTP++;} 
            if (counterSTP != 0) {QP.Current_Av_Selling_the_Platform__c = sumSTP/counterSTP;}
            if (pp.Needs_Design_Sprint__c & pp.Design_Sprint__c != null) {sumDS += pp.Design_Sprint__c; CounterDS++;} 
            if (counterDS != 0) {QP.Current_Av_Design_Sprint__c = sumDS/counterDS;}
            if (pp.Needs_Workshop__c & pp.Workshop__c != null) {sumW += pp.Workshop__c; CounterW++;} 
            if (counterW != 0) {QP.Current_Av_Workshop__c = sumW/counterW;}
            if (pp.Needs_TR__c & pp.TR__c != null) {sumTR += pp.TR__c; CounterTR++;} 
            if (counterTR != 0) {QP.Current_Av_TR__c = sumTR/counterTR;}
            if (pp.Needs_DP_Contract__c & pp.DP_Contract__c != null) {sumDP += pp.DP_Contract__c; CounterDP++;} 
            if (counterDP != 0) {QP.Current_Av_DP_Contract__c = sumDP/counterDP;}
            if (pp.Needs_SR__c & pp.Security_Review__c != null) {sumSR += pp.Security_Review__c; CounterSR++;} 
            if (counterSR != 0) {QP.Current_Av_SR__c = sumSR/counterSR;}
            if (pp.Needs_Product_Review__c & pp.Product_Review__c != null) {sumPR += pp.Product_Review__c; CounterPR++;} 
            if (counterPR != 0) {QP.Current_Av_Product_Review__c = sumPR/counterPR;}
            //special behaviour for Ad-hoc time
            //adding all values but divided by grand total
            if (pp.Ad_Hoc__c != null) {sumAH += pp.Ad_Hoc__c;} else {pp.Ad_Hoc__c = 0;}
            CounterAH++;
            QP.Current_Av_Ad_Hoc_Enablement__c = sumAH/counterAH;
            
            //Effective time
            if (pp.Selling_the_Platform_Done__c) {EffectivePartnerTime += pp.Selling_the_Platform__c;}
            if (pp.Design_Sprint_Done__c) {EffectivePartnerTime += pp.Design_Sprint__c;}
            if (pp.Workshop_Done__c) {EffectivePartnerTime += pp.Workshop__c;}
            if (pp.TR_Done__c) {EffectivePartnerTime += pp.TR__c;}
            if (pp.DP_Contract_Done__c) {EffectivePartnerTime += pp.DP_Contract__c;}
            if (pp.SR_Done__c) {EffectivePartnerTime += pp.Security_Review__c;}
            if (pp.Product_review_Done__c) {EffectivePartnerTime += pp.Product_Review__c;}
            EffectivePartnerTime += pp.Ad_Hoc__c;
            
            // create distinct list of PAM
            if (pp.Account__r.PAM__c != null) {allPAMs.add(pp.Account__r.PAM__c);}
            
        }
        system.debug('allPAms = '+AllPams);
        if (Target.size()>0){hasTarget = True;TargetSize = ': ' + string.valueof(Target.size());} else { hasTarget = False; TargetSize='';}
        if (InMarket.size()>0){hasInMArket = True;InMarketSize = ': ' + string.valueof(InMarket.size());} else { hasInMarket = False;InMarketSize='';}
        if (PDO.size()>0){hasPDO = True;PDOSize = ': ' + string.valueof(PDO.size());} else { hasPDO = False;PDOSize='';}
        if (Others.size()>0){hasOthers = True;OthersSize = ': ' + string.valueof(Others.size());} else { hasOthers = False;othersSize='';}
        AllPartners = string.valueof(Target.size()+InMarket.size());
        if (Target.size()>20) {
        	trickForTable.ADD(TARGET.GET(0));    
        }
        EffectivePartnerTimeI = ((EffectivePartnerTime/QP.Total_Available_Time__c)*100).IntValue();
        // cloning to keep the initial version of all activities
        cloneTarget = target.deepclone(true);
        cloneInMarket = InMarket.deepClone(true);
        
        // creating the list of PAMS for selection
        PAMs.clear();
        SelectOption opt = new SelectOption('No', 'All PAMs');
            PAMs.add(opt);
        for (string thePAM : allPAMs){
        	opt = new SelectOption(thePAM, thePAM);
            PAMs.add(opt);
        }
    }

    public void updatePPT() { 
        ComparePP(Target, cloneTarget); // define time automatically        
        ComparePP(InMarket, cloneInMarket);
        // adding all records together to do 1 Update
        list<Partner_Plan__c> allPPs = new list<Partner_Plan__c>(); 
        if (Target.size()>0) {allPPs.addAll(Target);}
        if (InMarket.size()>0) {allPPs.addAll(InMarket);}
        if (PDO.size()>0) {allPPs.addAll(PDO);}
        if (Others.size()>0) {allPPs.addAll(Others);}        
        update allPPs;
        allPP_IDs (); //reload updated data & update currentAverage
        updateQP();
    }   
    
    public void FilterPAM() {       
		AllPP_IDs();	
    }
    
    public quarterly_Plan__c QuarterlyPlanValues( ID ID){
        return [select Total_Available_Time__c,Remaining_Time__c, Partner_Time__c, Full_Utilisation__c, Total_DP_Planned__c,
              Expertise_Time__c,Scale_Activitiesq__c, Self_Enablement__c, Other_Time__c, VTO__c, PTO__c, Training__c, 
              Self_Learning__c, Dreamforce__c, Event__c, Team_Call__c, PAM_Calls__c, Internal_Strategy__c, Expert_Area__c,
              Admin_Private__c, Quarter__c, ownerID, Name, PM_Activities__c, Total_SR_Planned__c,
              Quarter__r.name,
              Total_TR_Done__c, Total_DP_Done__c, Total_SR_Done__c,Total_TR_Planned__c,
              Average_Selling_the_Platform__c, Average_Design_Sprint__c,Average_Workshop__c,Average_TR__c,
              Average_DP_Contract__c,Average_SR__c,Average_Product_Review__c,Average_Ad_Hoc_Enablement__c,
              Current_Av_Ad_Hoc_Enablement__c, Current_Av_Design_Sprint__c, Current_Av_DP_Contract__c, Current_Av_Product_Review__c,
              Current_Av_Selling_the_Platform__c, Current_Av_SR__c, Current_Av_TR__c, Current_Av_Workshop__c
              from Quarterly_Plan__c where id= : ID];
    }
    public void updateQP() {        
        update QP;
        QP = QuarterlyPlanValues (QP_ID);
    }
    
    public pagereference addPP() { 
        updatePPT();
        PageReference returnURL;
        returnURL = new PageReference('/a1b/e');
        return returnURL;
    }
    
    public String statusAction { get; set; }
    public list<SelectOption> getActions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--','--'));
        options.add(new SelectOption('Delete','Delete'));
        options.add(new SelectOption('Next','Next  Quarter'));
        return options;   
    }
    public pageReference actionIt(){
        system.debug('statusAction='+statusAction);
        if (statusAction == 'Delete') {deletePP();} else
        if (statusAction == 'Next') {nextQPP();} 
        return null;    
    }
    
    public pagereference deletePP() {       
        Partner_Plan__c pp = new Partner_plan__c();
        pp.id= selectedPP_ID;
        delete pp; 
        system.debug('pp to Delete= '+ selectedPP_ID);  
        allPP_IDs (); //reload updated data.
        QP = QuarterlyPlanValues (QP_ID);
        selectedPP_ID=null;
        return null;
    }
    
    public pagereference Update2InMarket() {       
        Account partner = new Account();
        partner.id= selectedP_ID;
        partner.type = 'In-Market';
        update partner; 
        allPP_IDs ();
        return null ;
    }
    
    public pagereference nextQPP() {
        //check if next QP exist
        Quarterly_Plan__c nextQP = new Quarterly_Plan__c();
        string nextQuarter;
        string FY;
        // quarter Qx FYyy
        integer currentQ = integer.valueof(QP.Quarter__r.name.substring(1,2));
        integer currentY = integer.valueof(QP.Quarter__r.name.substring(5,7));
        if (currentQ ==4 ){ currentQ=1;currentY++;}else {currentQ++;}
        
        nextQuarter = 'Q'+ string.valueOf(currentQ)+' FY'+string.valueof(currentY);
        system.debug('nextquarter='+nextQuarter);
        list<Quarterly_Plan__c> nextQPs = [select id from Quarterly_plan__c where quarter__r.name =:nextQuarter and ownerID =:qp.ownerID];
        if (nextQPS.size()== 1) {
            nextQP = nextQPS.get(0);
        } else {
            // need to create a new QP
            list<quarter__c> qList = [select id from quarter__c where name=:nextQuarter];
            if (qList.size() == 0) {
                // need to create a quarter
                quarter__c newQ = new Quarter__c();
                newQ.name = nextQuarter;
                currentY = integer.valueof('20'+string.valueof(currentY));
                integer month = 11;
                integer day = 1;
                if (currentQ == 1) {
                    month = 2; 
                } else if (currentQ ==2){
                    month =5;
                } else if (currentQ ==3){
                    month =8;
                }
                newQ.Start__c = date.newInstance(currentY, month, day);
                newQ.End__c = newQ.Start__c.addMonths(3).addDays(-1); 
                newQ.Year__c = CurrentY;
                insert newQ;
                qList.add(newQ);
            }              
            nextQP.ownerID = QP.OwnerId; 
            NextQP.Quarter__c= qList.get(0).id; 
            nextQP.name = QP.name.substringBefore(' ') + ' '+ nextQuarter;
            insert nextQP;
        }
        Partner_Plan__c pp = [select id, Quarterly_Plan__c from Partner_Plan__c where id=:selectedPP_ID ];
        pp.Quarterly_Plan__c = NextQp.id;
        update pp;
        allPP_IDs (); //reload updated data.
        QP = QuarterlyPlanValues (QP_ID); 
        selectedPP_ID=null;
        return null;
    }
    
    
    public pagereference createNQP() {       
        //check if next QP exist
        Quarterly_Plan__c nextQP = new Quarterly_Plan__c();
        string nextQuarter;
        string FY;
        // quarter Qx FYyy
        integer currentQ = integer.valueof(QP.Quarter__r.name.substring(1,2));
        integer currentY = integer.valueof(QP.Quarter__r.name.substring(5,7));
        if (currentQ ==4 ){ currentQ=1;currentY++;}else {currentQ++;}
        
        nextQuarter = 'Q'+ string.valueOf(currentQ)+' FY'+string.valueof(currentY);
        system.debug('nextquarter='+nextQuarter);
        list<Quarterly_Plan__c> nextQPs = [select id from Quarterly_plan__c where quarter__r.name =:nextQuarter and ownerID =:qp.ownerID];
        if (nextQPS.size()== 1) {
            nextQP = nextQPS.get(0);
        } else {
            //cloning Quarterly Plan from actual
            nextQP = QP.clone(false,false,false,false);
            // need to create a new QP
            list<quarter__c> qList = [select id from quarter__c where name=:nextQuarter];
            if (qList.size() == 0) {
                // need to create a quarter
                quarter__c newQ = new Quarter__c();
                newQ.name = nextQuarter;
                currentY = integer.valueof('20'+string.valueof(currentY));
                integer month = 11;
                integer day = 1;
                if (currentQ == 1) {
                    month = 2; 
                } else if (currentQ ==2){
                    month =5;
                } else if (currentQ ==3){
                    month =8;
                }
                newQ.Start__c = date.newInstance(currentY, month, day);
                newQ.End__c = newQ.Start__c.addMonths(3).addDays(-1); 
                newQ.Year__c = CurrentY;
                insert newQ;
                qList.add(newQ);
            }              
            nextQP.ownerID = QP.OwnerId; 
            NextQP.Quarter__c= qList.get(0).id; 
            nextQP.name = QP.name.substringBefore(' ') + ' '+ nextQuarter;
            // new average = old currentAverage
            nextQP.Average_Ad_Hoc_Enablement__c = ((QP.Average_Ad_Hoc_Enablement__c + QP.Current_Av_Ad_Hoc_Enablement__c)/2).setScale(1);
            nextQP.Average_Design_Sprint__c = ((QP.Average_Design_Sprint__c + QP.Current_Av_Design_Sprint__c)/2).setScale(1);
            nextQP.Average_DP_Contract__c = ((QP.Average_DP_Contract__c + QP.Current_Av_DP_Contract__c)/2).setScale(1);
            nextQP.Average_Product_Review__c = ((QP.Average_Product_Review__c + QP.Current_Av_Product_Review__c)/2).setScale(1);
            nextQP.Average_Selling_the_Platform__c = ((QP.Average_Selling_the_Platform__c + QP.Current_Av_Selling_the_Platform__c)/2).setScale(1);
            nextQP.Average_SR__c = ((QP.Average_SR__c + QP.Current_Av_SR__c)/2).setScale(1);
            nextQP.Average_TR__c = ((QP.Average_TR__c + QP.Current_Av_TR__c)/2).setScale(1);
            nextQP.Average_Workshop__c = ((QP.Average_Workshop__c + QP.Current_Av_Workshop__c)/2).setScale(1);
            NextQP.Team_Call__c = QP.Team_Call__c;
        	NextQP.PAM_Calls__c = Qp.PAM_Calls__c;
        	NextQp.Internal_Strategy__c = QP.Internal_Strategy__c;
        	NextQp.Expert_Area__c = QP.Expert_Area__c;
            insert nextQP;
        }
        // need to clone all PP and attached them to the new QP       
        allPP_IDs (); //reload updated data.
        list<Partner_Plan__c> clonedPPs = new list<Partner_Plan__c>();
        Partner_Plan__c clonedPP = new Partner_Plan__c();
        if (Target.size()>0)
        { 
            for (integer i=0; i<Target.size(); i++)
            {
               clonedPP = Target.get(i).clone(false,false,false,false); 
               clonedPP.Quarterly_Plan__c = NextQp.id;
               // reset values to default
               if (clonedPP.Needs_selling_the_Platform__c) {clonedPP.Selling_the_Platform__c = nextQP.Average_Selling_the_Platform__c;} else {clonedPP.Selling_the_Platform__c = 0;}
               if (clonedPP.Needs_Design_Sprint__c) {clonedPP.Design_Sprint__c = nextQP.Average_Design_Sprint__c;} else {clonedPP.Design_Sprint__c = 0;}
               if (clonedPP.Needs_Workshop__c) {clonedPP.Workshop__c = nextQP.Average_Workshop__c ;} else {clonedPP.Workshop__c = 0;}
               if (clonedPP.Needs_TR__c) {clonedPP.TR__c = nextQP.Average_TR__c;} else {clonedPP.TR__c = 0;}
               if (clonedPP.Needs_DP_Contract__c) {clonedPP.DP_Contract__c = nextQP.Average_DP_Contract__c;} else {clonedPP.DP_Contract__c = 0;}
               if (clonedPP.Needs_SR__c) {clonedPP.Security_Review__c = nextQP.Average_SR__c;} else {clonedPP.Security_Review__c = 0;}
               if (clonedPP.Needs_Product_Review__c) {clonedPP.Product_Review__c = nextQP.Average_Product_Review__c;} else {clonedPP.Product_Review__c = 0;}
               clonedPP.Ad_Hoc__c = nextQP.Average_Ad_Hoc_Enablement__c;
               clonedPPs.add(clonedPP);
            }
        } 
        if (InMarket.size()>0)
        { 
            for (integer i=0; i<InMarket.size(); i++)
            {
               clonedPP = InMarket.get(i).clone(false,false,false,false); 
               clonedPP.Quarterly_Plan__c = NextQp.id;
                // reset values to default
               if (clonedPP.Needs_selling_the_Platform__c) {clonedPP.Selling_the_Platform__c = nextQP.Average_Selling_the_Platform__c;} else {clonedPP.Selling_the_Platform__c = 0;}
               if (clonedPP.Needs_Design_Sprint__c) {clonedPP.Design_Sprint__c = nextQP.Average_Design_Sprint__c;} else {clonedPP.Design_Sprint__c = 0;}
               if (clonedPP.Needs_Workshop__c) {clonedPP.Workshop__c = nextQP.Average_Workshop__c ;} else {clonedPP.Workshop__c = 0;}
               if (clonedPP.Needs_TR__c) {clonedPP.TR__c = nextQP.Average_TR__c;} else {clonedPP.TR__c = 0;}
               if (clonedPP.Needs_DP_Contract__c) {clonedPP.DP_Contract__c = nextQP.Average_DP_Contract__c;} else {clonedPP.DP_Contract__c = 0;}
               if (clonedPP.Needs_SR__c) {clonedPP.Security_Review__c = nextQP.Average_SR__c;} else {clonedPP.Security_Review__c = 0;}
               if (clonedPP.Needs_Product_Review__c) {clonedPP.Product_Review__c = nextQP.Average_Product_Review__c;} else {clonedPP.Product_Review__c = 0;}
               clonedPP.Ad_Hoc__c = nextQP.Average_Ad_Hoc_Enablement__c;
               clonedPPs.add(clonedPP);
            }
        }
        if (PDO.size()>0)
        { 
            for (integer i=0; i<PDO.size(); i++)
            {
               clonedPP = PDO.get(i).clone(false,false,false,false); 
               clonedPP.Quarterly_Plan__c = NextQp.id;
                // reset values to default
               clonedPP.Selling_the_Platform__c = 0;
               clonedPP.Design_Sprint__c = 0;
               if (clonedPP.Needs_Workshop__c) {clonedPP.Workshop__c = nextQP.Average_Workshop__c ;} else {clonedPP.Workshop__c = 0;}
               clonedPP.TR__c = 0;
               clonedPP.DP_Contract__c = 0;
               clonedPP.Security_Review__c = 0;
               clonedPP.Product_Review__c = 0;
               clonedPP.Ad_Hoc__c = nextQP.Average_Ad_Hoc_Enablement__c;
               clonedPPs.add(clonedPP);
            }
        }
        if (Others.size()>0)
        { 
            for (integer i=0; i<Others.size(); i++)
            {
               clonedPP = Others.get(i).clone(false,false,false,false); 
               clonedPP.Quarterly_Plan__c = NextQp.id;
                // reset values to default
               clonedPP.Selling_the_Platform__c = 0;
               clonedPP.Design_Sprint__c = 0;
               if (clonedPP.Needs_Workshop__c) {clonedPP.Workshop__c = nextQP.Average_Workshop__c ;} else {clonedPP.Workshop__c = 0;}
               clonedPP.TR__c = 0;
               clonedPP.DP_Contract__c = 0;
               clonedPP.Security_Review__c = 0;
               clonedPP.Product_Review__c = 0;
               clonedPP.Ad_Hoc__c = nextQP.Average_Ad_Hoc_Enablement__c;
               clonedPPs.add(clonedPP);
            }
        }
    insert ClonedPPs;    
    //redirect to next Quartely Plan page
    PageReference nqpPage = new ApexPages.StandardController(NextQP).view();
	nqpPage.setRedirect(true);
	return nqpPage;
    }   
    
    private void ComparePP(list<Partner_Plan__c> PPs, list<Partner_Plan__c> clones)
    {
        map<id,Partner_Plan__c> mapClone = new Map<id, Partner_Plan__c>(Clones); 
        partner_plan__c clone = new Partner_Plan__c();
        for (integer i=0; i<PPs.size();i++)
        {
            //retrieve clone record
            clone= mapClone.get(PPs.get(i).ID);
            // checking fields individually
            if (clone.Needs_Selling_the_Platform__c && !PPs.get(i).Needs_Selling_the_Platform__c)
            {
                PPs.get(i).Selling_the_Platform__c = 0;
            } else if (!clone.Needs_Selling_the_Platform__c && PPs.get(i).Needs_Selling_the_Platform__c)
            {
                PPs.get(i).Selling_the_Platform__c = QP.Average_Selling_the_Platform__c;
            }
            
            if (clone.Needs_Design_Sprint__c && !PPs.get(i).Needs_Design_Sprint__c)
            {
                PPs.get(i).Design_Sprint__c = 0;
            } else if (!clone.Needs_Design_Sprint__c && PPs.get(i).Needs_Design_Sprint__c)
            {
                PPs.get(i).Design_Sprint__c = QP.Average_Design_Sprint__c;
            }
            
            if (clone.Needs_Workshop__c && !PPs.get(i).Needs_Workshop__c)
            {
                PPs.get(i).Workshop__c = 0;
            } else if (!clone.Needs_Workshop__c && PPs.get(i).Needs_Workshop__c)
            {
                PPs.get(i).Workshop__c = QP.Average_Workshop__c;
            }
            
            if (clone.Needs_TR__c && !PPs.get(i).Needs_TR__c)
            {
                PPs.get(i).TR__c = 0;
            } else if (!clone.Needs_TR__c && PPs.get(i).Needs_TR__c)
            {
                PPs.get(i).TR__c = QP.Average_TR__c;
            }
            
            if (clone.Needs_DP_Contract__c && !PPs.get(i).Needs_DP_Contract__c)
            {
                PPs.get(i).DP_Contract__c = 0;
            } else if (!clone.Needs_DP_Contract__c && PPs.get(i).Needs_DP_Contract__c)
            {
                PPs.get(i).DP_Contract__c = QP.Average_DP_Contract__c;
            }
            
            if (clone.Needs_SR__c && !PPs.get(i).Needs_SR__c)
            {
                PPs.get(i).Security_Review__c = 0;
            } else if (!clone.Needs_SR__c && PPs.get(i).Needs_SR__c)
            {
                PPs.get(i).Security_Review__c = QP.Average_SR__c;
            }
            
            if (clone.Needs_Product_review__c && !PPs.get(i).Needs_Product_review__c)
            {
                PPs.get(i).Product_review__c = 0;
            } else if (!clone.Needs_Product_review__c && PPs.get(i).Needs_Product_review__c)
            {
                PPs.get(i).Product_review__c = QP.Average_Product_Review__c;
            }            
        }
        mapClone.clear();
    }
    
    // New allInOnePage
    // 
    public void QPUsageMore() { 
        QPU_More = !QPU_More;
        if (MoreOrLess == 'More Info') { MoreOrLess = 'Less Info';} else {MoreOrLess = 'More Info';}
    }
	
	public void PPMore() { 
        QPU_More = !QPU_More;
        if (MoreOrLess == 'More Info') { MoreOrLess = 'Less Info';} else {MoreOrLess = 'More Info';}
    } 


}