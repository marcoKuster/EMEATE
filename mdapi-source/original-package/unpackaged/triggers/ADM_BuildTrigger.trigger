trigger ADM_BuildTrigger on ADM_Build__c (before insert, before update, before delete) {
    
    //don't want trigger to run for API calls from the sync process
    if( UserInfo.getUserName().contains('p4') || UserInfo.getUserName().contains('Perforce')){
        return;
    }
    
    if(Trigger.isDelete) {
        ADM_Build__c[] builds = Trigger.old;    
        if( Trigger.isBefore ) {
             //for each Build check that no work records exist
             for(ADM_Build__c build: builds) {
                Integer riCount = [select count() from ADM_Work__c where Scheduled_Build__c = :build.id limit 1]; //add limit clause as we only case if one exsits and if count greater then 1000 governor limit exception will be thrown
                if (riCount > 0) {
                    build.Name.addError('Error: You must re-assign all Work items scheduled for this build before it can be deleted.');     
                }
                riCount = [select count() from ADM_Work__c where Found_in_Build__c = :build.id limit 1];
                if (riCount > 0) {
                    build.Name.addError('Error: You must re-assign all Work items found in this build before it can be deleted.');  
                }           
             }
        }
    } else {
        //for inserts and update check name is unique
        ADM_Build__c[] builds = Trigger.new;        
        Map<String, ADM_Build__c> buildsOld = new Map<String, ADM_Build__c>();
        
        if(Trigger.old != null) {
	        for(ADM_Build__c buildOld : Trigger.old) {
	        	buildsOld.put(buildOld.Id, buildOld);
	        }	
        }        
         
        if( Trigger.isBefore ) {
            Integer i = 0;
            for(ADM_Build__c build : builds) {              
                /*
                 * First do a direct comparison against the name (the SOQL is case insensitive)
                 */
                Boolean nameExists = false;
                ADM_Build__c existingBuild = null;
                
                build.Name = ADM_DuplicateValidator.removeAllWhitespace(build.Name);
                
                Integer directCount = ADM_DuplicateValidator.countBy('ADM_Build__c', 'Name', build.Name, build.id);
                if(directCount > 0) { 
                    nameExists = true;
                    if (directCount == 1) {
                        //locate existing build using the same criteria
                        existingBuild = (ADM_Build__c)(ADM_DuplicateValidator.getBy('ADM_Build__c', 'Name', build.Name, build.id)).get(0);
                    }   
                } else {
                    /*
                     * If the direct comparison passes then make sure a similar version doesn't exist without punctuation
                     */
                    
                    String buildNameNoPunc = ADM_DuplicateValidator.removeAllPunctuationAndWhitespace(build.Name);                                                   
                    Integer noPunctuationCount = ADM_DuplicateValidator.countBy('ADM_Build__c', 'Name', buildNameNoPunc, build.id);
                    if(noPunctuationCount > 0) {
                        nameExists = true;
                        if (noPunctuationCount == 1) {
                            //locate existing build using the same criteria
                            existingBuild = (ADM_Build__c)ADM_DuplicateValidator.getBy('ADM_Build__c', 'Name', buildNameNoPunc, build.id).get(0);
                        }
                    }   
                }
                /*
                 * If a build already exists with the same name then add an error message which will stop the insert/update
                 */
                if(nameExists) {
                    String errorMsg = '';
                    //If one match was found the existingBuild object will be populated to allow you to link to it                  
                    if(existingBuild != null) {
                        errorMsg = 'Another build with this name already exists. <a href=/' + existingBuild.id + '>' + existingBuild.Name + '</a>'; 
                    } else {
                        errorMsg = 'Multiple builds with this name already exist';  
                    }                       
                    build.Name.addError(errorMsg);  
                }    
                
                build.External_ID__c = build.Name;                   
                i ++;                 
            }
        }
    }   
}