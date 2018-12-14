/*
 * Utility to sort Instances, used by Post Release Alert Flow and ADM_Release utilities.
 *
 *    @userstory W-2411767 https://gus.my.salesforce.com/a07B00000012EAL 
 *    @author: snahm
 *
 */
public class ADM_InstanceSort {

    /* 
     * Input is a string containing a list of instances separated either by a single space
     * or by a comma and a space. Output is the list sorted, accounting for instances with
     * single digit numbers being sorted before instances with double digit numbers. For
     * example, CS3 will come before CS11.
     *
     */
        @InvocableMethod(label='Sort Instance List' description='Input is a string containing a list of instances separated either by a single space or by a comma and a space. Output is the list sorted, accounting for instances with single digit numbers being sorted before instances with double digit numbers.')
        public static List<String> instanceSort(List<String> instanceList) {
    	/* DEBUG OFF  System.debug('ADM_ReleaseUtils.instanceSort: input instanceList="' + instanceList + '"'); /* DEBUG */
        String instances = instanceList[0];
        Boolean commaSeparated = false;

        if (instances.contains(',')) {
            commaSeparated = true;
            instances = instances.remove(',');
        }
        List <String> sl = instances.split(' ');
        // Using SelectOption to do the sort by name length before sort by lexical value
        List<SelectOption> slo = new List<SelectOption>();	
        for (String ss : sl) {
          slo.add(new SelectOption(ss.left(1) + ss.length().format(), ss));
        }
        slo.sort();
        // Create the returned string    
        instances = '';
        for (SelectOption slop : slo) {
            instances += slop.getLabel();
            if (commaSeparated) {
                instances += ', ';
            } else {
            	instances += ' ';
            }
        }
        if (commaSeparated) {
        	instances = instances.left(instances.length()-2);
        } else {
        	instances = instances.left(instances.length()-1);
        }
        instanceList[0] = instances;
        /* DEBUG OFF  System.debug('ADM_ReleaseUtils.instanceSort: output instanceList="' + instanceList + '"'); /* DEBUG */
        return(instanceList);
	}
    
    /*
     *	Takes a list of instances as a string and creates a list for the main method.
     */
    public static String instanceSort(String instanceList) {
        if (instanceList == null || instanceList.length() == 0) {
            return(instanceList);
        }
        List<String> instancesAsList = new List<String>();
        instancesAsList.add(instanceList);
        instancesAsList = instanceSort(instancesAsList);
        return(instancesAsList[0]);
    }
}