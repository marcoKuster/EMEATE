public class ADM_DebugLogger {
	public static String Arrow = '========> ';
	public static String Beginning = Arrow + 'Beginning ';
	public static String Closing = Arrow + 'Closing ';
	 
	public static void write( String message ){
		System.debug( message );	
	}
}