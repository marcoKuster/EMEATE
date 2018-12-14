public with sharing class ADM_Chart {
	@TestVisible
    private String title;
	@TestVisible
    private String subTitle;
	private List<Series> seriesList = new List<Series>();
	@TestVisible
    private XAxis xAxis;
	@TestVisible
    private YAxis yAxis;

	public ADM_Chart(String title, String subTitle){
		this.title = title;
		this.subTitle = subTitle;
	}
	public class XAxis{
		String title;
		Integer futureIndex;
		List<Object> categories = new List<Object>();
		public XAxis(String title){
			this.title = title;
		}

		public List<Object> getCategories(){
			return this.categories;
		}

		public void setCategories(List<Object> categories){
			this.categories = categories;
		}

		public void setFutureIndex(Integer futureIndex){
			this.futureIndex = futureIndex;
		}

        public String getTitle(){
            return title;
        }

    }

	public class YAxis{
		String title;
		public YAxis(String title){
			this.title = title;
		}
        
        public String getTitle(){
            return title;
        }
	        
	}

	public XAxis getXAxis(){
		return this.xAxis;
	}
	
    public YAxis getYAxis(){
		return this.yAxis;
	}

    public void setXAxis(XAxis xAxis){
		this.xAxis = xAxis;
	}

	public void setYAxis(YAxis yAxis){
		this.yAxis = yAxis;
	}

	public List<Series> getSeriesList(){
		return this.seriesList;
	}

	public class Series{
		@TestVisible
		private String name;
		@TestVisible	
		private List<Object> data = new List<Object>();
		public Series(String name){
			this.name = name;
		}

		public void setData(List<Object> data){
			this.data = data;
		}
	}
}