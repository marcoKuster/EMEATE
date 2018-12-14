public with sharing class ADM_Planner_ReleaseVisualizerController {
	private Id teamId = null;
	private String teamNameString = null;

	public ADM_Planner_ReleaseVisualizerController() {
		teamId = ApexPages.currentPage().getParameters().get('teamId');
		System.debug('teamId = ' + teamId);
	}

	private static Integer storyPointsPerRow = 5;

	public String getTeamName() {
		if (teamNameString == null) {
			try {
				teamNameString = [select Name from ADM_Scrum_Team__c where Id = :teamId].get(0).Name;
			}
			catch (System.Exception e) {
				teamNameString = 'Unknown';
			}
		}
		return teamNameString;
	}

	public Integer getAverageVelocity() {
		List<ADM_Sprint__c> sprints = [select Completed_Story_Points__c from ADM_Sprint__c
																		where Scrum_Team__c = :teamId and End_Date__c <= TODAY order by End_Date__c desc limit 8];
		Integer totalPoints = 0;
		Integer totalSprints = 0;
		for (ADM_Sprint__c sprint : sprints) {
			if (sprint.Completed_Story_Points__c != null) {
				totalPoints += sprint.Completed_Story_Points__c.intValue();
				totalSprints++;
			}
		}

		Integer average = 0;

		try {

			average = totalPoints / totalSprints;
		}
		catch (System.Exception e)
		{
			average = 0;
		}

		return average;
	}

	public List<ADM_Sprint__c> getPlanningSprints() {
		List<ADM_Sprint__c> sprints = [select Id, Name, Projected_Velocity__c from
			ADM_Sprint__c where Scrum_Team__c = :teamId and End_Date__c > TODAY order by End_Date__c limit 8];
		return sprints;
	}

	private Integer getSprintPoints(Id sprintId) {
		// Note: the sum result will be passed back in the AggregateResult object
		// with an implied alias of 'expr0'
		AggregateResult[] results = [select SUM(Story_Points__c) from ADM_Work__c
			where Sprint__c = :sprintId];

		if (results[0].get('expr0') != null) {
			return Integer.valueOf(results[0].get('expr0'));
		}
		else {
			return 0;
		}
	}

	public Component.Apex.OutputPanel getSprintsToBeDisplayed() {

		try {

			Component.Apex.OutputPanel dynPanel = new Component.Apex.OutputPanel();

			// This layout makes the output panel a <div> rather than a <span>
			dynPanel.layout = 'block';
			dynPanel.styleClass = 'sprint-complex';

			List<ADM_Sprint__c> sprints = getPlanningSprints();
			Integer averageVelocity = getAverageVelocity();

			for (ADM_Sprint__c sprint : sprints) {

				String generatedHTML = '';
				
				Component.Apex.OutputPanel sprintPanel = new Component.Apex.OutputPanel();
				sprintPanel.layout = 'block';
				Component.Apex.OutputText htmlTxt = new Component.Apex.OutputText();
				// Setting escape = 'false' will allow HTML to be inserted directly
				htmlTxt.escape = false;

				Id sprintId = sprint.Id;
				Integer sprintPoints = getSprintPoints(sprintId);
				Integer pointLimit;

				generatedHTML += '<div>'; // Start the div

				if (sprint.Projected_Velocity__c != null) {
					pointLimit = sprint.Projected_Velocity__c.intValue();
				}
				else {
					pointLimit = averageVelocity;
				}

				generatedHTML += '<div class="sprint" onclick="window.parent.navigateFrame(\'/' + sprintId +
					'\');"><div>';
				
				Integer displayedPointCount = 0;
				// First render the filled sprint points if needed
				if (sprintPoints > 0) {
					for (Integer p = 0; p < sprintPoints; p++) {
						// For each sprint point planned in this sprint, style it one of two
						// ways:
						// a) 'filled' - if this sprint point is less than or equal to either the
		        //     sprint projected velocity (if set), or the average velocity (if not set)
		        // b) 'over' - if this sprint point is over the limit determined above
						if (p < pointLimit) {
							generatedHTML += '<div class="filled"></div>';
						}
						else {
							generatedHTML += '<div class="over"></div>';
						}
						// We closed the current row <div> if p is a multiple of 5
						// for neatness
						if (math.mod(++displayedPointCount, storyPointsPerRow) == 0) {
							generatedHTML += '</div><div>';
						}
					}
				}

				// If we still have leftover points in this sprint, place empty divs
				// to represent them up to the point limit
				for (Integer p = sprintPoints; p < pointLimit; p++) {
					generatedHTML += '<div></div>';
					if (math.mod(++displayedPointCount, storyPointsPerRow) == 0) {
						generatedHTML += '</div><div>';
					}
				}

				// Close the last row div and the inner div
				generatedHTML += '</div></div>';

				// Output the sprint name
				generatedHTML += sprint.Name;

				// Close off the div for this sprint
				generatedHTML += '</div>';

				// Add the generated HTML to this sprint visualizer panel
				htmlTxt.value = generatedHTML;
				sprintPanel.childComponents.add(htmlTxt);

				// Add this sprint visualizer to the top-level container div
				dynPanel.childComponents.add(sprintPanel);

			}

			return dynPanel;
		}
		catch (System.Exception e) {
			// Return an empty panel if there was an exception
			return new Component.Apex.OutputPanel();
		}
	}

}