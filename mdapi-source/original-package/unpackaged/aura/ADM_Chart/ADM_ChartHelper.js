({
	updateChart : function(component, event, helper) {
		var type = component.get('v.type');
		var dataAndOptions = component.get('v.dataAndOptions');
		var width = component.get('v.width');
		var height = component.get('v.height');
		var chartInstance = component.get('v.chartInstance');

		if (chartInstance != null && component.isValid()) {
			chartInstance.destroy();
		}

		$A.createComponent(
			"aura:html",
			{
				"tag": "canvas",
				"HTMLElements": {
					"width": width,
					"height": height
				}
			},
			function(newChart, status, errorMessage){
				if (status === "SUCCESS") {
					if (component.isValid()) {
						component.set("v.body", [newChart]);

						if (Chart && dataAndOptions) { // Chart is the Chart.js global variable
							window.setTimeout( // need to do this or newChart.getElement() is null
								$A.getCallback(function() {
									var newDataAndOptions = event.getParam("value");
									var dataOptionObj = newDataAndOptions ? newDataAndOptions : dataAndOptions; // handle either new data or updated data
									var chart = newChart.getElement();
									var ctx = chart.getContext('2d');
									ctx.canvas.width = width; // set width & height explicitly so that they're handled gracefully when resizing (http://stackoverflow.com/a/21797915)
									ctx.canvas.height = height;
									Chart.defaults.global.defaultFontFamily = "'Salesforce Sans',Arial,sans-serif";

									var chartInstance = new Chart(ctx, {
										type: type,
										data: dataOptionObj.data,
										options: dataOptionObj.options
									});
									component.set('v.chartInstance', chartInstance);
								})
							, 0);
						}
					}
				} else if (status === "ERROR") {
					if (component.isValid()) {
						console.error("Error loading chart: " + errorMessage);
						$A.createComponent(
							"aura:html",
							{
								"tag": "p",
								"HTMLAttributes": {
									"class": "slds-text-color--error"
								},
								"body": "Error loading chart: " + errorMessage
							},
							function(errorText, status, errorMessage) {
								component.set("v.body", [newChart]);
							}
						);
					}
				}
			}
		);
	}
})