({
    calculateCommitments : function(component, sprintWork) {
        var bugs = [],
            userStories = [],
            investigations = [],
            todos = [],
            nonVelocityStatuses = ['Duplicate','Not a bug','Not Reproducible','Never'],
            nonVelocityStatusesInSprint = [],
            storyPoints = 0,
            workCount = 0;
        
        for(var i = 0, len = sprintWork.length; i < len; i++) {
            if (nonVelocityStatuses.includes(sprintWork[i].m_story.Status__c)) {
                if (!nonVelocityStatusesInSprint.includes(sprintWork[i].m_story.Status__c)) {
                    nonVelocityStatusesInSprint.push(sprintWork[i].m_story.Status__c);
                }
            }
            
            storyPoints += (sprintWork[i].m_story.Story_Points__c != null ? sprintWork[i].m_story.Story_Points__c : 0);
        
            if(sprintWork[i].recordType.Name == 'Bug') {
                bugs.push(sprintWork[i]);
            } else if(sprintWork[i].recordType.Name == 'User Story') {
                userStories.push(sprintWork[i]);
            } else if(sprintWork[i].recordType.Name == 'Investigation') {
                investigations.push(sprintWork[i]);
            } else if(sprintWork[i].recordType.Name == 'ToDo') {
                todos.push(sprintWork[i]);
            }

            workCount++;
        }

        component.set("v.bugCount", bugs.length);
        component.set("v.userStoryCount", userStories.length);
        component.set("v.investigationCount", investigations.length);
        component.set("v.todoCount", todos.length);
        component.set("v.nonVelocityStatusesInSprint", nonVelocityStatusesInSprint);
        component.set("v.storyPoints", storyPoints);
        component.set("v.workCount", workCount);
    }
})