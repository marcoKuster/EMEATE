public class ADM_GoogleChartsHelper {
	
	//Data for mapping to Extended coding values
	private static final String EXTENDED_ENC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-.';
	private static final String SIMPLE_ENC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
	private static final Double DOUBLE_MIN_INFINITY = Math.pow( -2, 63);
	private static final Double DOUBLE_MAX_INFINITY = Math.pow( 2, 63) - 1;	
	
	public static final String TINY_CHART='280x210';
	public static final String SMALL_CHART = '320x256';
	public static final String MEDIUM_CHART = '480x384';
	public static final String LARGE_CHART = '640x512';
	
	public static final String HORIZONTAL_BAR_CHART = '&cht=bhs';
	public static final String VERTICAL_BAR_CHART = '&cht=bvs';
	
	public static final Integer LOW_ENC = 0;
	public static final Integer MED_ENC = 1;
	public static final Integer HIGH_ENC = 2;
	
	//If you don't have max then pass 0.0
	public static String getTextEncodingForData( List<Double> data, Double max, Boolean starting ) {
		String result;
		if ( starting ) result = 't:';
		else result = '|';
		if ( max == null ) // NO max identified so need to figure out Max
			for ( Double d:data ) max = Math.max( max, d );
		for ( Double d:data ) {
			if ( d < 0.0 ) result += '-1,';
			else {
				Double dataPoint = Math.round( d*1000.0/max )/10.0; // double to the nearest 10th
				result += dataPoint+',';
			}
		}
		result = result.substring( 0, result.length()- 1 );
		
		return result;
	}
		
	public static String getURLForLineChart( String sizeOfChart, List< List<Double> > dataLists, ADM_GoogleChartOptions chartOptions ) {
		String result = 'https://chart.googleapis.com/chart?cht=lc&chs='+sizeOfChart;
		
		Double originalMax = DOUBLE_MIN_INFINITY;
		Double originalMin = DOUBLE_MAX_INFINITY;
		Double max = 0.0;
		Boolean useDecimalsForXAxis = false;
		Boolean useDecimalsForYAxis = false;
		Map<Integer, String> chartDataPoints = new Map<Integer,String>();
		
		
		//Figure out the Max for the data
		for( List<Double> dataList:dataLists ) 
			for (Double d:dataList ){ 
				originalMax = Math.max( originalMax, d );
				originalMin = Math.min( originalMin, d );
			}
		
		if ( chartOptions.getShouldNormalizeData() ) {
			if ( originalMin != 0.0 ) { // Normalize the data
				for( List<Double> dataList:dataLists ) 
					for ( Integer i = 0; i < dataList.size(); i++ )
						dataList[i] -= originalMin; // normalize values to 0	
			}
			max = Math.ceil( originalMax - originalMin ); // normalized max	
		} else {
			max = originalMax;
			originalMin = 0.0;
		}
		// Round the max to the closest multiple of 5 or 10; if max == 1 then leave max as it is.
		if ( max == 0.0 ) max = 1.0;
		if ( max < 1.0 ) max = 1.0;
		if ( max > 1.0 )
			if ( max <= 100.0 ) max += ( 10 - Math.mod( max.intValue(), 10 ) );
			else max += 100 - Math.mod( max.intValue(), 100 );

		
		//Now that I have the max figure out the data points
		Boolean starting = true;
		//TODO Allow user to pick encoding
		Integer encodingType = MED_ENC;
		String chartData = '';
		for( List<Double> dataList:dataLists ) {
			chartData += getTextEncodingForData( dataList, max, starting );
			starting = false;
		}
		
		result += '&chd='+chartData;
		
		// LOGIC for figuring out what the Y-label
		String axes = '&chxt=y';
		String axesStyles = '&chxs=0,000000,10,0';
		String yAxisLabels = '';
		String chartGrid = '&chg=0,';
		if ( max <= 1.0 ) {
			yAxisLabels = '0:||0.25|0.50|0.75|1.0';
			chartGrid += '25';
		} else {
			yAxisLabels = '0:|';
			if ( max < 100.0 ) {
				for ( Integer i=0; i <= max; i+= 10 ) yAxisLabels += i+'|';
				yAxisLabels = yAxisLabels.substring(0, yAxisLabels.length() - 1 );
				chartGrid += Math.round(1000.0/max * 100.0)/100.0; 
			} else {
				for ( Integer i=0; i < 10; i++ )
					yAxisLabels += (max * i/10 + originalMin).intValue() +'|';
				yAxisLabels += (max + originalMin).intValue();
				chartGrid += '10';
			}
		}
		
		//LOGIC for figuring out what the x-labels should be\
		List<String> xAxisLabelsList = chartOptions.getStaticAxisLabels();
		String xAxisLabels1, xAxisLabels2, xAxisMarkerLabelPositions, xAxisMarkerPositions;
		Integer xlistSize = xAxisLabelsList.size();
		if ( xAxisLabelsList != null && xlistSize > 0 ) {
			axes += ',x';
			axesStyles += '|1,000000,10,0';
			xAxisLabels1 = '|1:|';
			for (String label:xAxisLabelsList ) 
				xAxisLabels1 += label+'|';
			xAxisLabels1 = xAxisLabels1.substring( 0, xAxisLabels1.length() - 1 );
		}
		
		if ( chartOptions.getStaticAxisMarkerLabels() != null ) {
			axes += ',x';
			if ( xAxisLabels1 != null ) {
				xAxisLabels2 = '|2:|';
				xAxisMarkerLabelPositions ='2,';
				axesStyles += '|2,3399CC,10,0';
			} else {
				xAxisLabels2 = '|1:|';
				xAxisMarkerLabelPositions ='1,';
				axesStyles += '|1,3399CC,10,0';
			}
			for ( String label: chartOptions.getStaticAxisMarkerLabels() )
				xAxisLabels2 += label+'|';
			xAxisLabels2 = xAxisLabels2.substring( 0, xAxisLabels2.length() - 1 );
		}
		
		if ( chartOptions.getStaticAxisMarkerLabelPositions() != null )
			for ( Double d: chartOptions.getStaticAxisMarkerLabelPositions() )
				xAxisMarkerLabelPositions += Math.round( d*10 )/10 +',';
		
		xAxisMarkerPositions = '';
		if ( chartOptions.getStaticAxisMarkers() != null )
			for (Double d: chartOptions.getStaticAxisMarkers() )
				xAxisMarkerPositions += 'v,3399CC,'+chartOptions.getDataSetToMark()+','+d+',1|';
		else
			xAxisMarkerPositions = null;
	
		
		result += axes;
		result += axesStyles;
				
		if ( xAxisLabels1 != null && xAxisLabels2 != null )
			result += '&chxl='+yAxisLabels + xAxisLabels1 + xAxisLabels2 + chartGrid;
		else if ( xAxisLabels1 != null )
			result += '&chxl='+yAxisLabels + xAxisLabels1 + chartGrid;		
		else
			result += '&chxl='+yAxisLabels + chartGrid;
			
		if ( xAxisMarkerLabelPositions != null ) {
			xAxisMarkerLabelPositions = xAxisMarkerLabelPositions.substring( 0, xAxisMarkerLabelPositions.length() - 1 );
			result += '&chxp='+xAxisMarkerLabelPositions;
		}
		
		if ( xAxisMarkerPositions != null ) {
			xAxisMarkerPositions = xAxisMarkerPositions.substring( 0, xAxisMarkerPositions.length() - 1 );
			result += '&chm='+xAxisMarkerPositions;
		}
		
		if ( chartOptions.getChartTitle() != null ) 
			result += '&chtt=' + chartOptions.getChartTitle();
		
		if ( chartOptions.getDataSetColors() != null ) {
			String colors = '';
			for ( String c : chartOptions.getDataSetColors() )
				colors += c+',';
			if ( colors.length() > 0 ) {
				colors = colors.substring(0, colors.length() - 1 ); 
				result += '&chco='+colors;	
			}
		}
		
		if ( chartOptions.getChartFlags() != null && chartOptions.getChartFlags().size() > 0 ) {
			String flagsAdd = '&chm=';
			for( String flag:chartOptions.getChartFlags() ) {
				flagsAdd += flag + '|';
			}
			result += flagsAdd.substring( 0, flagsAdd.length() - 1 );			
		}
				
		
		return result;
	}
	
	public static String getURLForBarChart( String sizeOfChart, String barChartType, List<List <Double>> dataLists, ADM_GoogleChartOptions chartOptions ) {
		if ( barChartType != HORIZONTAL_BAR_CHART ) barChartType = VERTICAL_BAR_CHART;
		
		String result = 'https://chart.googleapis.com/chart?'+barChartType+'&chs='+sizeOfChart;
		
		Double max = DOUBLE_MIN_INFINITY;
		
		//Have to resum all of the data since each data list is a group whose total value adds to the max
		List<Double> summedData = new List<Double>();
		if ( dataLists.size() > 1 ) 
			summedData = dataLists[0].clone();
		
		for (Integer i=1; i< dataLists.size(); i++ ) {
			List<Double> dl = dataLists[i];
			Integer j = 0;
			for (Double d : dl ) {
				if ( d > 0.0 ) {
					if ( j < summedData.size() ) summedData[j] += d;
					else summedData.add( d );
				}
				max = Math.max( max, summedData[j] );
				j+=1;	
			}	
		}
		if ( max < 0 ) max = 1.0;
		else if ( max < 1 ) max = 1.0;				
		if ( max > 10 && max <50 ) max += 5 - Math.mod( max.intValue(), 5 );
		else if ( max > 50 && max < 100 ) max += 10 - Math.mod( max.intValue(), 10 );
		else if ( max > 100 ) max += 100 - Math.mod( max.intValue(), 100 );
		
		Boolean starting = true;
		//TODO Allow user to pick encoding
		Integer encodingType = MED_ENC;
		String chartData = '';
		for( List<Double> dataList:dataLists ) {
			chartData += getTextEncodingForData( dataList, max, starting );
			starting = false;
		}
		result += '&chd='+chartData;
		
		//Logic for the derived data axis labels
		String derivedDataAxisLabels = '0:|';
		String chartGrid = '&chg=';
		if ( barChartType == VERTICAL_BAR_CHART ) chartGrid +='0,';
		if ( max <= 10 ) {
			for ( Integer i=0; i < max.intValue(); i++ )
				derivedDataAxisLabels += i + '|';
			chartGrid += roundToNearest( 100.0/max.intValue(), 10 )+',';
		} else if ( max <= 50 ) {
			for ( Integer i=0; i < max.intValue(); i+=5 )
				derivedDataAxisLabels += i + '|';
			chartGrid += roundToNearest( 100.0/(max.intValue()/5.0), 10 )+',';
		} else {
			for ( Integer i=0; i < 10; i++ )
				derivedDataAxisLabels += (max * i/10).intValue() +'|';
			chartGrid += '10,';
		}
		
		derivedDataAxisLabels += max.intValue();
		if ( barChartType == HORIZONTAL_BAR_CHART ) chartGrid +='0,';
		chartGrid += '1,5';
		result += chartGrid;
		String staticDataAxisLabels = null;
		List<String> staticDataAxisLabelsList = chartOptions.getStaticAxisLabels();		
		if ( staticDataAxisLabelsList != null && staticDataAxisLabelsList.size() > 0 ) {
			if ( barChartType == HORIZONTAL_BAR_CHART ) {
				// SINCE GOOGLE CHARTS displays labels from bottom to top while displays data from top to bottom we have to reverse the labels list
				for (String label:staticDataAxisLabelsList ) 
					staticDataAxisLabels = label+'|'+staticDataAxisLabels;
				staticDataAxisLabels = '|1:|' + staticDataAxisLabels;				
			} else { // VERTICAL
				staticDataAxisLabels = '|1:|';
				for (String label:staticDataAxisLabelsList ) 
					staticDataAxisLabels += label+'|';		
			}
			
			staticDataAxisLabels = staticDataAxisLabels.substring( 0, staticDataAxisLabels.length() - 1 );
		}
		
		//TODO: add the chbh sizing baseed on size of statid data axis labels
		
		if ( staticDataAxisLabelsList.size() <= 4 )
			result += '&chbh=40';
		else if ( staticDataAxisLabelsList.size() <= 7 )
			result += '&chbh=25';
		else if ( staticDataAxisLabelsList.size() <= 9 )
			result += '&chbh=19';		
		else if ( staticDataAxisLabelsList.size() <= 11 )
			result += '&chbh=16';		
		else if ( staticDataAxisLabelsList.size() <= 13 )
			result += '&chbh=13';
		else if ( staticDataAxisLabelsList.size() <= 16 )
			result += '&chbh=10';
		else if ( staticDataAxisLabelsList.size() <=20 )
			result += '&chbh=5';
		else 
			result += '&chbh=3';
		
		if ( barChartType == HORIZONTAL_BAR_CHART ) {
			if ( staticDataAxisLabels != null )
				result += '&chxt=x,y';
			else
				result += '&chxt=x';			
		} else {
			if ( staticDataAxisLabels != null )
				result += '&chxt=y,x';
			else 
				result += '&chxt=y';
		}
				
		if ( staticDataAxisLabels != null )
			result += '&chxl='+derivedDataAxisLabels+staticDataAxisLabels;
		else
			result += '&chxl='+derivedDataAxisLabels;

		if ( chartOptions.getChartTitle() != null ) 
			result += '&chtt=' + chartOptions.getChartTitle();

		if ( chartOptions.getDataSetColors() != null ) {
			String colors = '';
			for ( String c : chartOptions.getDataSetColors() )
				colors += c+',';
			if ( colors.length() > 0 ) {
				colors = colors.substring(0, colors.length() - 1 ); 
				result += '&chco='+colors;	
			}
		}
		return result;
	}
	
	private static Double roundToNearest( Double toRound, Double toThe ) {
		return Math.round( toRound * toThe )/toThe;	
	}		
	
	public class GoogleChartsHelperClassException extends Exception {}
	
	static testMethod void testGetUrlForHorizontalBarChart() {
		String sizeOfChart = MEDIUM_CHART;
		String barChartType = HORIZONTAL_BAR_CHART;
		
		ADM_GoogleChartOptions chartOptions = new ADM_GoogleChartOptions();
		chartOptions.setStaticAxisLabels(new List<String>{'d1','d2'});
		chartOptions.setChartTitle('Test Chart');
		chartOptions.setDataSetColors(new List<String>{'4D89F9','C6D9FD'});
		
        List<List<Double>> dataLists = new List<List<Double>>();
        dataLists.add(new List<Double>{10, 50, 60, 80, 40, 60, 30});
        dataLists.add(new List<Double>{50, 60, 100, 40, 30, 40, 30});
		
		String url = ADM_GoogleChartsHelper.getURLForBarChart(sizeOfChart, barChartType, dataLists, chartOptions);
		
		System.assert(url != null);
		System.assert(url.startsWith('https://chart.googleapis.com/chart'), 'Expected a charts URL: ' + url);
        System.assert(url.contains('cht=bhs'), 'Expected charts URL to be a horizontal bar chart (bhs): ' + url);
        System.assert(url.contains('chs=480x384'), 'Expected charts URL to be 480x384: ' + url);
        
        //data is returned at 50% original value
        System.assert(url.contains('chd=t:5.0,25.0,30.0,40.0,20.0,30.0,15.0|25.0,30.0,50.0,20.0,15.0,20.0,15.0'), 'Expected chart to have the correct data:' + url);
        
        System.assert(url.contains('chtt=Test+Chart'), 'Expected charts URL to contain the title: ' + url);
        System.assert(url.contains('chco=4D89F9,C6D9FD'), 'Expected charts URL to have the colors specified: ' + url);
        System.assert(url.contains('chxt=x,y'), 'Expected charts URL: ' + url);
	}
	
    static testMethod void testGetUrlForVerticalBarChart() {
        String sizeOfChart = MEDIUM_CHART;
        String barChartType = VERTICAL_BAR_CHART;
        
        ADM_GoogleChartOptions chartOptions = new ADM_GoogleChartOptions();
        chartOptions.setStaticAxisLabels(new List<String>{'d1','d2'});
        chartOptions.setChartTitle('Test Chart');
        chartOptions.setDataSetColors(new List<String>{'4D89F9','C6D9FD'});
        
        List<List<Double>> dataLists = new List<List<Double>>();
        dataLists.add(new List<Double>{1, 5, 6, 8, 4, 6, 3});
        dataLists.add(new List<Double>{5, 6, 10, 4, 3, 4, 3});
        
        String url = ADM_GoogleChartsHelper.getURLForBarChart(sizeOfChart, barChartType, dataLists, chartOptions);
        
        System.assert(url != null);
        System.assert(url.startsWith('https://chart.googleapis.com/chart'), 'Expected a charts URL: ' + url);
        System.assert(url.contains('cht=bvs'), 'Expected charts URL to be a vertical bar chart (bvs): ' + url);
        System.assert(url.contains('chs=480x384'), 'Expected charts URL to be 480x384: ' + url);
        
        //data is returned at 50% original value
        System.assert(url.contains('chd=t:5.0,25.0,30.0,40.0,20.0,30.0,15.0|25.0,30.0,50.0,20.0,15.0,20.0,15.0'), 'Expected chart to have the correct data:' + url);
        
        System.assert(url.contains('chtt=Test+Chart'), 'Expected charts URL to contain the title: ' + url);
        System.assert(url.contains('chco=4D89F9,C6D9FD'), 'Expected charts URL to have the colors specified: ' + url);
        System.assert(url.contains('chxt=y,x'), 'Expected charts URL: ' + url);
    }
    
    static testMethod void testGetUrlForLineChart() {
        String sizeOfChart = MEDIUM_CHART;
        
        ADM_GoogleChartOptions chartOptions = new ADM_GoogleChartOptions();
        chartOptions.setStaticAxisLabels(new List<String>{'d1','d2'});
        chartOptions.setStaticAxisMarkerLabels(new List<String>{'l1', 'l2'});
        chartOptions.setStaticAxisMarkerLabelPositions(new List<Double>{10, 20});
        chartOptions.setChartTitle('Test Chart');
        chartOptions.setDataSetColors(new List<String>{'4D89F9','C6D9FD'});
        chartOptions.setShouldNormalizeData(true);
        
        List<List<Double>> dataLists = new List<List<Double>>();
        dataLists.add(new List<Double>{1, 5, 6, 8, 4, 6, 3});
        dataLists.add(new List<Double>{5, 6, 10, 4, 3, 4, 3});
        
        String url = ADM_GoogleChartsHelper.getURLForLineChart(sizeOfChart, dataLists, chartOptions);
        
        System.assert(url != null);
        System.assert(url.startsWith('https://chart.googleapis.com/chart'), 'Expected a charts URL: ' + url);
        System.assert(url.contains('chs=480x384'), 'Expected charts URL to be 480x384: ' + url);
    }
}