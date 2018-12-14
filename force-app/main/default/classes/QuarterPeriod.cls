/**
 * Represents a quarter within a fiscal year as a period of two dates.  
 *
 * Fiscal years are represented by the ending year of the period. So fiscal year 
 * 2013 began February 1st 2012 and will end January 31st 2013. The quarters are 
 * even 3-month intervals at regular month boundaries within that. So quarters 
 * start on the first day of the following months:
 *  - February
 *  - May
 *  - August 
 *  - November
 */
public with sharing class QuarterPeriod {
	private Integer year;
	private Integer index;
	private Date startDate;
	private Date endDate;
    


    public enum Quarter {Q1, Q2, Q3, Q4}

	/**
	 * Creates a new QuarterPeriod
	 * @param index The number from 1 to 4; may not be null
	 * @param year The year in which the quarter occurred. may not be null
	 * @param startDate The start date of the quarter;  may not be null
	 * @param endDate The end date of the quarter (inclusive);  may not be null
	 */
	private QuarterPeriod(
			Integer index, 
			Integer year, 
			Date startDate, 
			Date endDate) {
		this.index = index;
		this.year = year;
		this.startDate = startDate;
		this.endDate = endDate;
	}
	
	public Integer getYear() {
		return this.year;
	}
	
	public Integer getIndex() {
		return this.index;
	}
	
	public Date getStartDate() {
		return this.startDate;
	}
	
	/**
	 * Gets the end date of the quarter. This value is inclusive meaning the date
	 * returned is within the period (ie. this.contains(this.getEndDate())) will
	 * return true.  This value will never be null.
	 */
	public Date getEndDate() {
		return this.endDate;
	}
	
	/**
	 * Determines if the specified value is within this period. If value is
	 * is null, then false is returned.
	 */
	public Boolean contains(Date value) {
		if(value == null) {
			return false;
		}
		
		//end date is inclusive!
		return this.startDate <= value && value <= this.endDate;
	}
	
	/**
	 * Parses the string for a valid QuarterPeriod.
	 *
	 * The value is expected to be in the following format:
	 *  FY##-Q# 
	 *
	 * If the value is null or an empty string, then null is returned.
	 */
	public static QuarterPeriod parse(String value) {
		if (value == null || value == '') {
			return null;
		}
		
		//ensure the valid length
		if (value.length() != 7) {
			throw new ADM_UnexpectedValueException('Invalid QuarterPeriod format: format must be FY##-Q#. ' + value);
		}
		
		//ensure the first characters are 'FY'
		if (!value.startsWith('FY')) {
			throw new ADM_UnexpectedValueException('Invalid QuarterPeriod format: missing FY. ' + value);
		}
		
		//ensure that the year and sequence are delimited by '-Q'
		if (!value.substring(4, 6).equals('-Q')) {
			throw new ADM_UnexpectedValueException('Invalid QuarterPeriod format: missing Q. ' + value);
		}
		
		//parse the year part
		Integer yearPart = -1;
		try {
			yearPart = Integer.valueOf(value.substring(2, 4));
		} catch (Exception exc) {
			throw new ADM_UnexpectedValueException('Invalid QuarterPeriod format: invalid year part. ' + value, exc);
		}
		
		//parse the index part
		Integer indexPart = -1;
		try {
			indexPart = Integer.valueOf(value.substring(6, 7));
		} catch (Exception exc) {
			throw new ADM_UnexpectedValueException('Invalid Quarter Period format: invalid index part. ' + value, exc);
		}
		
		//adjust the year
		Integer year = yearPart + 2000;
		
		//get the dates
		Date[] dates = getQuarterDates(indexPart, year);
		
		//create the new quarter period
		return new QuarterPeriod(indexPart, year, dates[0], dates[1]);
	}
	
	/**
	 * Gets the dates that denote a quarter. The zero index is the start date
	 * and the first index is the stop date (inclusive).
	 * @param index The index of the quarter. From 1 to 4; must not be null
	 * @param year The year of the quarter; must not be null
	 */
	private static Date[] getQuarterDates(Integer index, Integer year) {
		if (index < 1 || index > 4) {
			throw new ADM_UnexpectedValueException('Index must be between 1 and 4. Received: ' + index);
		}
		
		Integer[] months = new Integer[]{
			2, //february
			5, //may
			8, //august
			11 //november
		};
		
		//adjust the index from one-based to zero-based
		Integer adjustedIndex = index - 1;
		
		//determine the end date of the period
		//if the index specified is within the last quarter, then we must adjust
		//to use the first month to then calculate the date. Otherwise, we just
		//use the next index of the month array
		Integer endYear = -1;
		Integer endMonth = -1;
		if (adjustedIndex + 1 > 3) {
			endYear = year;
			endMonth = months[0];
		} else {
			endYear = year - 1;
			endMonth = months[adjustedIndex + 1];
		}
		
		return new Date[] {
			Date.newInstance(year - 1, months[adjustedIndex], 1),
			Date.newInstance(endYear, endMonth, 1).addDays(-1)
		};
	}

	/*

		Getting Fiscal year settings of Org.
	*/
	private static Integer getFiscalYearStartMonth(){
		Organization  org = new Organization() ;  
		Integer fiscalYearStartMonth = 2;
		try{
			org = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()]; 
			fiscalYearStartMonth = org.FiscalYearStartMonth;   
		}
		catch(Exception exp){
			System.debug('Error occured while querying fiscal year start month');
		}
		return fiscalYearStartMonth;
	}

	/*  

		Calculatest the last month of the passed in month's FQ. eg: if passed in month is 3 (March) then the lastMonth of its FQ will be April or 4
	*/

	private static Integer getFiscalQuarterLastMonthOf(Integer monthIndexToCalculateFQ){
        
        Integer fiscalYearStartMonthIndex = getFiscalYearStartMonth();
  		if(monthIndexToCalculateFQ < fiscalYearStartMonthIndex ){
            monthIndexToCalculateFQ  = 12+ monthIndexToCalculateFQ ;  
  		}
  
        Integer differenceofBothMonths = monthIndexToCalculateFQ - fiscalYearStartMonthIndex  ;  
        Integer currentFiscalQuarterLastMonth  = 0;   
  
        if(0 < = differenceofBothMonths && differenceofBothMonths <= 2 ) //For first quarter  
            currentFiscalQuarterLastMonth = fiscalYearStartMonthIndex  +2 ;   
        else if( 3 <= differenceofBothMonths && differenceofBothMonths <= 5) //For second quarter   
            currentFiscalQuarterLastMonth = fiscalYearStartMonthIndex  +5 ;  
        else if( 6 <= differenceofBothMonths && differenceofBothMonths <= 8) // For third quarter  
            currentFiscalQuarterLastMonth = fiscalYearStartMonthIndex  +8 ;  
        else if( 9 <= differenceofBothMonths && differenceofBothMonths <= 11) // For fourth quarter  
            currentFiscalQuarterLastMonth = fiscalYearStartMonthIndex  +11 ;  
  
        if(currentFiscalQuarterLastMonth > 12)  
            currentFiscalQuarterLastMonth  = currentFiscalQuarterLastMonth  - 12 ; 

        return currentFiscalQuarterLastMonth;
    }

    /*
			Returns an enum which is current Fiscal Quarter.

    */
    private static Quarter getCurrentFiscalQuarter(){
        Quarter currentFQ = null;
        Integer fiscalQuarterLastMonth = getFiscalQuarterLastMonthOf(system.today().month());
        Integer fiscalYearFirstQuarterStartMonth = getFiscalYearStartMonth();
        Integer fiscalYearSecondQuarterStartMonth = fiscalYearFirstQuarterStartMonth + 3;
        Integer fiscalYearThirdQuarterStartMonth = fiscalYearFirstQuarterStartMonth + 6;
    
        if(fiscalQuarterLastMonth >= fiscalYearFirstQuarterStartMonth && fiscalQuarterLastMonth <= (fiscalYearFirstQuarterStartMonth +2)){
            currentFQ = Quarter.Q1;
        }
        else if(fiscalQuarterLastMonth >= fiscalYearSecondQuarterStartMonth && fiscalQuarterLastMonth <= (fiscalYearSecondQuarterStartMonth +2)){
            currentFQ = Quarter.Q2;
        }
        else if(fiscalQuarterLastMonth > fiscalYearThirdQuarterStartMonth && fiscalQuarterLastMonth <= (fiscalYearThirdQuarterStartMonth +2)){
            currentFQ = Quarter.Q3;
        }
        else{
                currentFQ = Quarter.Q4;
        }
        return currentFQ;
    }

    /*  
		Getting Next Fiscal Quarter Name in the head count Effective_Date__c format eg: FY15-Q2

     */
    public static String getNextFiscalQuarterName(){
        Integer ordinalValueForNextFQ = 0;
        Integer currentFQOrdinalValue = getCurrentFiscalQuarter().ordinal();
        if(currentFQOrdinalValue < 3){//Only 4 quarters so if ordinal value is 3 it is 0 based index for enum so next quarter will be 0 which is same as initialized value '0'.
        	ordinalValueForNextFQ = currentFQOrdinalValue + 1;
        }
        String nextFQName = getQuarterNameByQuarterOrdinal(ordinalValueForNextFQ);
        if(ordinalValueForNextFQ < currentFQOrdinalValue){
        	Integer yearIncrement = 2;// This is because FY will always be 1 year ahead and if on last quarter the next FY quarter will be in this year +2.
            if(System.today().month() == 1){//Increment only 1 for Jan which is the last month of Last Quarter
                yearIncrement = 1;
            }
        	String nextYearYY = ''+ (System.today().year() +yearIncrement);
        	nextFQName = nextFQName.substring(0, 2) + nextYearYY.substring(2) + nextFQName.substring(4);
        }
		return nextFQName;
    }

     /*  
		Getting Last Fiscal Quarter Name in the head count Effective_Date__c format eg: FY15-Q2

     */
    public static String getLastFiscalQuarterName(){
        Integer ordinalValueForLastFQ = 3;
        Integer currentFQOrdinalValue = getCurrentFiscalQuarter().ordinal();
        if(currentFQOrdinalValue > 0){//Only 4 quarters so if ordinal value is 0 it is 0 based index for enum so last quarter will be the one with Ordinal 3.
        	ordinalValueForLastFQ = currentFQOrdinalValue - 1;
        }
        String lastFQName = getQuarterNameByQuarterOrdinal(ordinalValueForLastFQ);
        if(ordinalValueForLastFQ > currentFQOrdinalValue){
        	String lastYearYY = ''+ (System.today().year() );
        	lastFQName = lastFQName.substring(0, 2) + lastYearYY.substring(2) + lastFQName.substring(4);
        }
        return lastFQName;
		
    }

    /*  
		Getting Current Fiscal Quarter Name in the head count Effective_Date__c format eg: FY15-Q2

     */
    public static String getCurrentFiscalQuarterName(){
        Integer ordinalValueForCurrentFQ = getCurrentFiscalQuarter().ordinal();
        String currentFQName = getQuarterNameByQuarterOrdinal(ordinalValueForCurrentFQ);
        return currentFQName;
		
    }

    private static String getQuarterNameByQuarterOrdinal(Integer quarterOrdinal){
    	List<Quarter> quarters = Quarter.values();
    	Quarter quaterRecord = quarters.get(quarterOrdinal);
		Integer currentFiscalYearStartMonth = getFiscalYearStartMonth();
		Integer currentMonth = System.today().month();
		String yyStr = '';

		if(currentMonth < currentFiscalYearStartMonth){
			yyStr = ''+ (System.today().year() );
		}
		else{
			yyStr = ''+ (System.today().year() +1);
		}
		yyStr = yyStr.substring(2);

		String fQName = 'FY'+yyStr+'-'+quaterRecord.name();

		return fQName;
    }

    
}