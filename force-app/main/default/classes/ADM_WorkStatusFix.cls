global class ADM_WorkStatusFix {
    
    global static void correctTheOrderingOfStatuses(){
        try{
            System.debug('correctTheOrderingOfStatuses() Check for existing statuses..');
            List<ADM_Work_Status__c> workStatusItems = [Select id, Name, Type__c, Order__c from ADM_Work_Status__c order by Order__c];
            if(workStatusItems.size() == 0){
                System.debug('correctTheOrderingOfStatuses() found none. returning ..');
                return;
            }
            else{
                System.debug('correctTheOrderingOfStatuses() FOUND statuses..');
                List<ADM_Work_Status__c> listToUpdate = new List<ADM_Work_Status__c>();
                for(ADM_Work_Status__c existingStatus : workStatusItems){
                    if(existingStatus.Name == 'New'){
                        existingStatus.Order__c = 10;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Triaged'){
                        existingStatus.Order__c = 20;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'In Progress'){
                        existingStatus.Order__c = 30;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Ready for Review'){
                        existingStatus.Order__c = 40;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Fixed'){
                        existingStatus.Order__c = 50;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'QA in Progress'){
                        existingStatus.Order__c = 60;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed'){
                        existingStatus.Order__c = 70;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Waiting'){
                        existingStatus.Order__c = 80;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Integrate'){
                        existingStatus.Order__c = 90;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name =='Pending Release'){
                        existingStatus.Order__c = 100;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Duplicate'){
                        existingStatus.Order__c = 110;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Never'){
                        existingStatus.Order__c = 120;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Not Reproducible'){
                        existingStatus.Order__c = 130;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Not a bug'){
                        existingStatus.Order__c = 140;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Acknowledged'){
                        existingStatus.Order__c = 150;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Investigating'){
                        existingStatus.Order__c = 160;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Defunct'){
                        existingStatus.Order__c = 170;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Duplicate'){
                        existingStatus.Order__c = 180;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Known Bug Exists'){
                        existingStatus.Order__c = 190;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - New Bug Logged'){
                        existingStatus.Order__c = 200;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - LAP Request Approved'){
                        existingStatus.Order__c = 210;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - LAP Request Denied'){
                        existingStatus.Order__c = 220;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Resolved With Internal Tools'){
                        existingStatus.Order__c = 230;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - Resolved Without Code Change'){
                        existingStatus.Order__c = 240;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - No Fix - Working as Designed'){
                        existingStatus.Order__c = 250;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - No Fix - Feature Request'){
                        existingStatus.Order__c = 260;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Closed - No Fix - Will Not Fix'){
                        existingStatus.Order__c = 270;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'More Info Reqd from Support'){
                        existingStatus.Order__c = 280;
                        listToUpdate.add(existingStatus);
                    }
                    else if(existingStatus.Name == 'Rejected'){
                        existingStatus.Order__c = 290;
                        listToUpdate.add(existingStatus);
                    }

                }
				System.debug('correctTheOrderingOfStatuses() about to update:' + listToUpdate);
                update listToUpdate;
            }
        }
        catch(Exception e){
            System.debug('Exception while running the script : '+e);
        }

    }

}