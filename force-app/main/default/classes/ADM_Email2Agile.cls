public class ADM_Email2Agile implements Messaging.InboundEmailHandler { 
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
      	ADM_Email2GUS gus = new ADM_Email2GUS();
        return gus.handleInboundEmail(email, envelope);
    }
}