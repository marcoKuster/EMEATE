@isTest
public class ADM_Email2AgileTest {

    @isTest
    static void testEmailAgileHandler(){
        
        ADM_Email2Agile emailer = new ADM_Email2Agile();
        try {
        	Messaging.InboundEmailResult nullEmailHandler = emailer.handleInboundEmail( null, null );
			// Purposely fail if you get to the this point
			System.assert(false, 'Null inputs for the handler should throw an error ');
        } catch ( System.NullPointerException npe ){
            // Do nothing since this is expected
        }

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
 
        email.subject = 'Test subject';
        email.fromAddress = 'bogus@bogus';		
        
        Messaging.InboundEmailResult emailHandler = emailer.handleInboundEmail( email, envelope );
        // There's no Work object, so we should empty this error
        System.assertEquals( 'Error: Work ID not found in Subject', emailHandler.message );
        
    }

}