public class ADM_GoogleChartOptions {
	private List<String> m_staticAxisLabels;
	private List<String> m_staticAxisMarkerLabels;
	private List<Double> m_staticAxisMarkerLabelPositions;
	private List<Double> m_staticAxisMarkers;
	private Integer m_dataSetToMark;
	private Boolean m_makeDerivedAxisWholeNumbers;
	private String m_chartTitle;
	private Boolean m_showAllXAxisMarkers;
	private List<String> m_dataSetColors;
	private Boolean m_normalizeData;
	private List<String> m_flags;
	
	public ADM_GoogleChartOptions( ) {
		m_makeDerivedAxisWholeNumbers = false;
		m_dataSetToMark = -1;
		m_normalizeData = true;
		
	}
	
	public List<String> getStaticAxisLabels() { return m_staticAxisLabels; }
	
	public void setStaticAxisLabels( List<String> l ) { 
		if ( m_staticAxisLabels == null ) m_staticAxisLabels = new List<String>();
		for( String s:l ) m_staticAxisLabels.add( s.replace('#','') );
	}
	
	public List<String> getStaticAxisMarkerLabels() { return m_staticAxisMarkerLabels;	}
	
	public void setStaticAxisMarkerLabels( List<String> l ) { m_staticAxisMarkerLabels = l; }
	
	public List<Double> getStaticAxisMarkerLabelPositions() { return m_staticAxisMarkerLabelPositions; }
	
	public void setStaticAxisMarkerLabelPositions( List<Double> pos ) { m_staticAxisMarkerLabelPositions = pos; }
	
	public List<Double> getStaticAxisMarkers() { return m_staticAxisMarkers; }
	
	public void setStaticAxisMarkers( List<Double> markers ) { m_staticAxisMarkers = markers; }
	
	public Integer getDataSetToMark() { return m_dataSetToMark; }
	
	public void setDataSetToMark( Integer i ) { m_dataSetToMark = i; }
	
	public Boolean getMakeDerivedAxisWholeNumbers() { return m_makeDerivedAxisWholeNumbers; }
	
	public void setMakeDerivedAxisWholeNumbers( Boolean b ) { m_makeDerivedAxisWholeNumbers = b; }
	
	public String getChartTitle() { return m_chartTitle; }
	
	public void setChartTitle( String title ) { 
		m_chartTitle = title.replace(' ','+'); 
	}
	
	public List<String> getDataSetColors() { return m_dataSetColors; }
	
	public void setDataSetColors( List<String> colors ) { m_dataSetColors = colors; }
	
	public Boolean getShouldNormalizeData() { return m_normalizeData; }
	
	public void setShouldNormalizeData( Boolean b ) { m_normalizeData = b; }
	
	public void addChartFlag( String text, String color, Integer index, Integer dataPointIndex, Integer textSize ) {
		if ( m_flags == null )
			m_flags = new List<String>();
		m_flags.add( 'f'+text+','+color+','+index+','+dataPointIndex+','+textSize );
	}
	
	public List<String> getChartFlags() {
		return m_flags;	
	}
	
}