({
	getSprintBurndownChart : function(component, event, helper) {
		var sprintData = component.get('v.sprintData');
		var sprintId;

		if (sprintData && sprintData.sprintInfo && sprintData.sprintInfo.Id) {
			sprintId = sprintData.sprintInfo.Id;
		}
		if(component.isValid() && sprintId){
			var action = component.get("c.getSprintChartAura");

			action.setParams({
				"sprintId": sprintId,
				"dataType": "Task Hours"
			});

			action.setCallback(this, function(response) {
				var state = response.getState();

				if (state === "SUCCESS"){
					var returnValue = JSON.parse(response.getReturnValue());

					if (!$A.util.isEmpty(returnValue)) {
						var idealBurndown = returnValue.seriesList[0];
						var realBurndown = returnValue.seriesList[1];
						var futureIndex = returnValue.xAxis.futureIndex;

						component.set('v.dataAndOptions', {
							data: {
								labels: returnValue.xAxis.categories,
								datasets: [
									{
										label: realBurndown.name,
										data: futureIndex == null ? realBurndown.data : realBurndown.data.slice(0, futureIndex), // if looking at current sprint, stop at futureIndex to make line stop on current day
										borderColor: "rgba(0, 112, 210, 1)",
										backgroundColor: "rgba(0, 112, 210, 1)",
										fill: false,
										pointRadius: 0,
										borderWidth: 3,
										pointHitRadius: 5,
										pointHoverRadius: 3,
										pointHoverBackgroundColor: "rgba(0, 112, 210, 1)",
										lineTension: 0
									},
									{
										label: idealBurndown.name,
										data: idealBurndown.data,
										borderColor: "rgba(247, 177, 90, 1)",
										backgroundColor: "rgba(247, 177, 90, 1)",
										fill: false,
										pointRadius: 0,
										borderWidth: 2,
										pointHitRadius: 5,
										pointHoverRadius: 3,
										pointHoverBackgroundColor: "rgba(247, 177, 90, 1)"
									}
								]
							},
							options: {
								title: {
									display: false
								},
								legend: {
									position: 'bottom'

								},
								scales: {
									yAxes: [{
										ticks: {
											beginAtZero:true,
											suggestedMax: parseInt(idealBurndown.data[0], 10) + 1 // ensures that biggest y-value isn't top y-axis value
										},
										gridLines: {
											display: false
										}
									}],
									xAxes: [{
										gridLines: {
											display: false
										}
									}]
								},
								tooltips: {
									callbacks: {
										title: function(tooltipItems, data) {
											return 'Hours';
										},
										footer: function(tooltipItems, data) {
											return 'Remaining: ' + realBurndown.data[tooltipItems[0].index];
										}
									},
									bodyFontSize: 0,
									footerMarginTop: 0
								}
							}
						});

						helper.displayChart(component, event, helper);
					}
				} else {
					console.error("The call to getSprintBurndownChart failed with errors. See below.");
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.error("Error message: " + errors[0].message);
						}
					} else {
						console.error("Unknown error");
					}

					helper.displayErrorMessage(component, event, helper);
				}

			});
			$A.enqueueAction(action);
		}
	}
})