@isTest
public class ADM_VFUtilsTest {

    @isTest
	static void testUserErrorStorage() {

    	String localError = 'Your flux capacitor is busted';
		ADM_VFUtils.userError( localError );
		System.assertEquals( true, ApexPages.hasMessages( ApexPages.Severity.ERROR ));
		System.assertEquals( localError, ApexPages.getMessages()[0].getSummary() ) ;

	}

}