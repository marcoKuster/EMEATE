@isTest
public class QuarterPeriodTests {
	
	/*
	@testcaseID a1DB00000001PjM
	@userstory a07B0000000LIecIAG
	@Hieararchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a valid value, the parse method should return a valid QuarterPeriod
	@Author: Jared Pearson
	*/

	/**
	 * Given a valid value, the parse method should return a valid QuarterPeriod
	 */
	public static testMethod void testParseSuccess(){
		String value = 'FY12-Q1';
		Integer expectedYear = 2012;
		Integer expectedIndex = 1;
		
		QuarterPeriod quarter = QuarterPeriod.parse(value);
		
		System.assert(quarter != null, 'parse should never return null');
		System.assertEquals(expectedYear, quarter.getYear());
		System.assertEquals(expectedIndex, quarter.getIndex());
	}
	
	/*
	@testcaseID a1DB00000001PjR
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a valid Fourth Quarter value, the parse method should return a valid QuarterPeriod
	@Author: Jared Pearson
	*/

	/**
	 * Given a valid Fourth Quarter value, the parse method should return a 
	 * valid QuarterPeriod
	 */
	public static testMethod void testParseSuccessQuarter4(){
		String value = 'FY12-Q4';
		Integer expectedYear = 2012;
		Integer expectedIndex = 4;
		
		QuarterPeriod quarter = QuarterPeriod.parse(value);
		
		System.assert(quarter != null, 'parse should never return null');
		System.assertEquals(expectedYear, quarter.getYear());
		System.assertEquals(expectedIndex, quarter.getIndex());
	}
	
	/*
	@testcaseID a1DB00000001PjW
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a invalid prefix in the value, the parse method should throw an ADM_UnexpectedValueException.
	@Author: Jared Pearson
	*/

	/**
	 * Given a invalid prefix in the value, the parse method should throw an 
	 * ADM_UnexpectedValueException.
	 */
	public static testMethod void testParseInvalidPrefix(){
		String value = 'AY12-Q1'; //invalid prefix
		
		try {
			QuarterPeriod quarter = QuarterPeriod.parse(value);
		} catch (ADM_UnexpectedValueException exc) {
			return;
		}
		
		System.assert(true, 'Expected exception ADM_UnexpectedValueException but was never thrown');
	}

	/*
	@testcaseID a1DB00000001Pjb
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a invalid year in the value, the parse method should throw an ADM_UnexpectedValueException.
	@Author: Jared Pearson
	*/
	
	/**
	 * Given a invalid year in the value, the parse method should throw an 
	 * ADM_UnexpectedValueException.
	 */
	public static testMethod void testParseInvalidYear(){
		String value = 'FYA2-Q1'; //invalid prefix
		
		try {
			QuarterPeriod quarter = QuarterPeriod.parse(value);
		} catch (ADM_UnexpectedValueException exc) {
			return;
		}
		
		System.assert(true, 'Expected exception ADM_UnexpectedValueException but was never thrown');
	}
	

	/*
	@testcaseID a1DB00000001Pjg
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a invalid value length, the parse method should throw an ADM_UnexpectedValueException.
	@Author: Jared Pearson
	*/

	/**
	 * Given a invalid value length, the parse method should throw an 
	 * ADM_UnexpectedValueException.
	 */
	public static testMethod void testParseInvalidLength(){
		String value = 'FY12Q1'; //invalid length
		
		try {
			QuarterPeriod quarter = QuarterPeriod.parse(value);
		} catch (ADM_UnexpectedValueException exc) {
			return;
		}
		
		System.assert(true, 'Expected exception ADM_UnexpectedValueException but was never thrown');
	}
	

	/*
	@testcaseID a1DB00000001Pjl
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a invalid delimiter in the value, the parse method should throw an ADM_UnexpectedValueException.
	@Author: Jared Pearson
	*/

	/**
	 * Given a invalid delimiter in the value, the parse method should throw an 
	 * ADM_UnexpectedValueException.
	 */
	public static testMethod void testParseInvalidDelimiter(){
		String value = 'FY12aQ1'; //invalid/missing '-Q' delimiter
		
		try {
			QuarterPeriod quarter = QuarterPeriod.parse(value);
		} catch (ADM_UnexpectedValueException exc) {
			return;
		}
		
		System.assert(true, 'Expected exception ADM_UnexpectedValueException but was never thrown');
	}
	
	/*
	@testcaseID a1DB00000001Pjq
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a invalid index in the value due to out of bounds, the parse method should throw an ADM_UnexpectedValueException.
	@Author: Jared Pearson
	*/

	/**
	 * Given a invalid index in the value due to out of bounds, the parse method 
	 * should throw an ADM_UnexpectedValueException.
	 */
	public static testMethod void testParseInvalidIndexDueToBounds(){
		String value = 'FY12-Q9'; //invalid index 
		
		try {
			QuarterPeriod quarter = QuarterPeriod.parse(value);
		} catch (ADM_UnexpectedValueException exc) {
			return;
		}
		
		System.assert(true, 'Expected exception ADM_UnexpectedValueException but was never thrown');
	}
	
	/*
	@testcaseID a1DB00000001Pjv
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a invalid index in the value due to non-numeric, the parse method should throw an ADM_UnexpectedValueException.
	@Author: Jared Pearson
	*/

	/**
	 * Given a invalid index in the value due to non-numeric, the parse method 
	 * should throw an ADM_UnexpectedValueException.
	 */
	public static testMethod void testParseInvalidIndexDueToNonnumeric(){
		String value = 'FY12-QA'; //invalid index 
		
		try {
			QuarterPeriod quarter = QuarterPeriod.parse(value);
		} catch (ADM_UnexpectedValueException exc) {
			return;
		}
		
		System.assert(true, 'Expected exception ADM_UnexpectedValueException but was never thrown');
	}

	/*
	@testcaseID a1DB00000001Pk0
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given an empty value, the parse method should return null
	@Author: Jared Pearson
	*/
	
	/**
	 * Given an empty value, the parse method should return null
	 */
	public static testMethod void testParseEmpty(){
		String value = ''; 
		QuarterPeriod quarter = QuarterPeriod.parse(value);
		System.assert(quarter == null, 'Expected quarter to be null');
	}
	
	/*
	@testcaseID a1DB00000001Pk5
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a null value, the parse method should return null
	@Author: Jared Pearson
	*/
	

	/**
	 * Given a null value, the parse method should return null
	 */
	public static testMethod void testParseNull(){
		String value = null; 
		QuarterPeriod quarter = QuarterPeriod.parse(value);
		System.assert(quarter == null, 'Expected quarter to be null');
	}

	/*
	@testcaseID a1DB00000001PkA
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a date within the quarter period, the contains method should return true
	@Author: Jared Pearson
	*/
	
	/**
	 * Given a date within the quarter period, the contains method should 
	 * return true
	 */
	public static testMethod void testContainsSuccess(){
		String value = 'FY12-Q1'; 
		Date dateToCheck = Date.newInstance(2011, 3, 1);
		
		//we assume Q1 is 02/01/2011 - 04/30/2011
		
		QuarterPeriod quarter = QuarterPeriod.parse(value);
		Boolean containsValue = quarter.contains(dateToCheck);
		
		System.assertEquals(true, containsValue, 'Expected true: date 03/01/2011 should be within the first quarter of fiscal year 2012');
	}
	
	/*
	@testcaseID a1DB00000001PkF
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given a date not within the quarter period, the contains method should return false
	@Author: Jared Pearson
	*/

	/**
	 * Given a date not within the quarter period, the contains method should 
	 * return false
	 */
	public static testMethod void testContainsFalse(){
		String value = 'FY12-Q1'; 
		Date dateToCheck = Date.newInstance(2012, 5, 1); //outside of the period!
		
		//we assume Q1 is 02/01/2011 - 04/30/2011
		
		QuarterPeriod quarter = QuarterPeriod.parse(value);
		Boolean containsValue = quarter.contains(dateToCheck);
		
		System.assertEquals(false, containsValue, 'Expected false: date 05/01/2012 should not be within the first quarter of fiscal year 2012');
	}

	/*
	@testcaseID a1DB00000001PkK
	@userstory a07B0000000LIecIAG
	@Hierarchy GUS.ScrumforceToGUS.Position.Recruiter Make Offer
	@Expected Results Given null, the contains method should return false
	@Author: Jared Pearson
	*/
	
	/**
	 * Given null, the contains method should return false
	 */
	public static testMethod void testContainsNull(){
		String value = 'FY12-Q1'; 
		Date dateToCheck = null;
		
		QuarterPeriod quarter = QuarterPeriod.parse(value);
		Boolean containsValue = quarter.contains(dateToCheck);
		
		System.assertEquals(false, containsValue, 'Expected false: date is null');
	}
}