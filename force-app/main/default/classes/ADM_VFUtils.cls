public class ADM_VFUtils {
	
	public static void userError(String msg){
		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, msg ) );			
	}

}