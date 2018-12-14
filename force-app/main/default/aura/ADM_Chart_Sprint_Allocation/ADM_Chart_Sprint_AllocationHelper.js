({
	getAllocationChartData : function(component, event, helper) {
		var sprintData = component.get('v.sprintData');
		var viewBy = component.get('v.viewBy');
		var sprintId;

		if (sprintData && sprintData.sprintInfo && sprintData.sprintInfo.Id) {
			sprintId = sprintData.sprintInfo.Id;
		}

		if(component.isValid() && sprintId){
			var action = component.get("c.updateHoursAvailableChartAura");

			action.setParams({
				"sprintId": sprintId,
				"viewChartByOption": viewBy
			});

			action.setCallback(this, function(response) {
				var state = response.getState();

				if (state === "SUCCESS"){
					var returnValue = JSON.parse(response.getReturnValue());
					var chartData = returnValue.chartData;
					var chartHeight = returnValue.chartHeight;
					console.log(returnValue);

					if (!chartData) {
						console.error('getAllocationChartData successful but no chartData retrieved');
						return;
					}

					var assigneeNames = [];
					var assigned = [];
					var over = [];
					var under = [];

					chartData.forEach(function(dataObj) {
						assigneeNames.push(dataObj.assigneeName);
						assigned.push(dataObj.Assigned);
						over.push(dataObj.Over);
						under.push(dataObj.Under);
					})

					component.set('v.chartHeight', chartHeight);
					component.set('v.dataAndOptions', {
						data: {
							labels: assigneeNames,
							datasets: [
								{
									label: 'Assigned',
									data: assigned,
									borderColor: "rgba(50,175,92,1)",
									backgroundColor: "rgba(50,175,92,1)",
						            hoverBackgroundColor: "rgba(50,175,92,1)"
								},
								{
									label: 'Over',
									data: over,
									borderColor: "rgba(245,103,91,1)",
									backgroundColor: "rgba(245,103,91,1)",
						            hoverBackgroundColor: "rgba(245,103,91,1)"
								},
								{
									label: 'Under',
									data: under,
									borderColor: "rgba(0,112,210,1)",
									backgroundColor: "rgba(0,112,210,1)",
						            hoverBackgroundColor: "rgba(0,112,210,1)"
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
								xAxes: [{
									ticks: {
										beginAtZero:true
									},
									gridLines: {
										display: false
									},
									stacked: true
								}],
								yAxes: [{
									ticks: {
										beginAtZero:true
									},
									gridLines: {
										display: false
									},
									stacked: true
								}]
							},
							responsive: false,
							tooltips: {
								enabled: true
							}
						}
					});
					helper.displayChart(component, event, helper);
				} else {
					console.error("The call to getAllocationChartData failed with errors. See below.");
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