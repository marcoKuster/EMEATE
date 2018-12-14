/*
    When you install a managed package with a post-install script, Salesforce creates a special ghost user under which all of the post install activities occur.

    So the scheduled job ADM_WorkUnsubscriber needs special permission - hence we have to explicitly make it "without sharing"

    http://salesforce.stackexchange.com/questions/32607/installhandler-runs-under-a-special-ghost-user-what-rights-does-it-have

*/
global without sharing class AgileManager_PostInstallScripts implements InstallHandler {


   /*
      This is a convenient method to install sample data by calling this method. On installation of package the method which is called is
      onInstall(installContext context)
   */
   public String INVESTIGATION_RECORDTYPE ='';
   public String BUG_RECORDTYPE ='';
   public String USERSTORY_RECORDTYPE ='';
   public void installHere(){
       try{
           doInstall(null);
       }
       catch(Exception exc){
           System.debug('Exception occured while doing install scripts. Message -> ' + exc.getMessage());
       }
   }
   
  

   global void onInstall(InstallContext context) {
       try{
           
           doCreateWorkStatuses();

           /*
              Do the post install steps only for one time and not for upgrades
           */
           if(context != null && !context.isUpgrade()){
              doPostInstallActions(context);
           }
           if(context.isUpgrade()){
              updateUserPreferenceForKanbanConfig();
              addDefaultColorsToExistingTeams();
           }
           
       }
       catch(AgileManager_InstallException postInstallExcp){
              postInstallExcp.handle(context);
       }
    }


    private void doCreateWorkStatuses(){
      ADM_WorkStatus.correctTheOrderingOfStatuses();
      ADM_WorkStatus.createAllWorkStatuses();

    }

  
   /*
      Post Install actions include installing sample data and scheduling WorkUnsubscriber job
    
   */
   private void doPostInstallActions(InstallContext context){
      try{
          doInstall(context);
      }
      catch(Exception exp){
         AgileManager_InstallDataException postIntallDataException =  new AgileManager_InstallDataException('Exception while installing Sample Data');
         postIntallDataException.setMessage(exp.getMessage());
         throw postIntallDataException;
      }
   }

    private void doInstall(InstallContext context){
       //assign perm set to the installing user so that the app functions correctly and assignment rules fire for setup data etc
        PermissionSetAssignment psa = new PermissionSetAssignment();
        try {
          List<PermissionSet> permSets =  [select id from PermissionSet where Name = 'Agile_Accelerator_Admin']; 
            if(permSets != null && permSets.size() == 1) {
                if(context != null){
                  psa.AssigneeId = context.installerID();
                }
                else{
                  psa.AssigneeId = UserInfo.getUserId();
                }
                
                psa.PermissionSetId = permSets.get(0).id;
            } 
            if(Test.isRunningTest()){
              User adminuser = [select Id from User where id = :context.installerID()];
              System.runAs(adminuser){
                insert psa;
            }     
            }else{
              insert psa;           
            }
                
        } catch (Exception e) {
            System.debug('Error assigning permission set to installing user. e:' + e);
        }
        
        
        
       Map<String, String> recordTypeMap = getRecordTypeMap();
       INVESTIGATION_RECORDTYPE = recordTypeMap.get('Investigation');
       BUG_RECORDTYPE = recordTypeMap.get('Bug');
       USERSTORY_RECORDTYPE = recordTypeMap.get('User Story');
       List<ADM_Impact__c> impacts = installImpacts();
       List<ADM_Frequency__c> frequencies = installFrequencies();
       List<ADM_Priority__c> priorities = installPriorities();
       List<ADM_Priority_Mapping__c> priorityMappings = installPriorityMapping(impacts, frequencies, priorities);
       List<ADM_Type__c> types = installTypes();
       List<ADM_Impact_Type__c> impactTypes = installImpactTypes(impacts, types);
       ADM_Scrum_Team__c team = installScrumTeam();
       ADM_Build__c build = installBuild();
       ADM_Scrum_Team_Member__c teamMember = installScrumTeamMember(context, team); 
       ADM_Sprint__c sprint = installSprint(team);
       ADM_Product_Tag__c pTag =  installProductTag(team);
       ADM_Assignment_Rule__c rule = installAssignmentRule(context, team);
       List<ADM_Tag_Assignment__c> tagAssignments = installTagAssignments(rule, pTag);
       Map<String, String> impactMap = getImpactMap();
       Map<String, String> frequencyMap = getFrequencyMap();
        
       ADM_Epic__c epic = installEpic('Navigation App Version 1');
        
       List<ADM_Work__c> sampleWorksToInsert = new List<ADM_Work__c>();
       ADM_Work__c gpslocationRenderingError = setupSampleWork(sprint, team, pTag, 'Bug', impactMap.get('Malfunctioning'),frequencyMap.get('Always'), 'P1', build, 'GPS locations rendering incorrectly', 'Bug');
       gpslocationRenderingError.Use_Prioritizer__c = true;
       sampleWorksToInsert.add(gpslocationRenderingError);
        
       ADM_Work__c noOptionForTollRoadSkip = setupSampleWork(sprint, team, pTag, 'Bug', impactMap.get('Poor Usability'),frequencyMap.get('Sometimes'), 'P3', build, 'No option for skipping toll roads', 'Bug');
       noOptionForTollRoadSkip.Use_Prioritizer__c = true;
       sampleWorksToInsert.add(noOptionForTollRoadSkip);
        
        
       ADM_Work__c point2PointStory = setupSampleWork(sprint, team, pTag, 'User Story', null, null, null, build, 'Point to point navigation', 'User Story');
       point2PointStory.Priority_rank__c = 1;
       point2PointStory.Use_Prioritizer__c = true;
       point2PointStory.Epic__c = epic.Id;
       sampleWorksToInsert.add(point2PointStory);
        
        
       ADM_Work__c audioTurnByTurnStory = setupSampleWork(null, team, pTag, 'User Story', null, null, null, build, 'Audio turn by turn navigation', 'User Story');
       audioTurnByTurnStory.Priority_rank__c = 2;
       audioTurnByTurnStory.Use_Prioritizer__c = true;
       audioTurnByTurnStory.Epic__c = epic.Id;
       sampleWorksToInsert.add(audioTurnByTurnStory);
        
        
       ADM_Work__c searchByHotelStory = setupSampleWork(sprint, team, pTag, 'User Story', null, null, null, build, 'Search by Hotel', 'User Story');
       searchByHotelStory.Priority_rank__c = 3;
       searchByHotelStory.Use_Prioritizer__c = true;
       searchByHotelStory.Epic__c = epic.Id;
       sampleWorksToInsert.add(searchByHotelStory);
        
        
       ADM_Work__c showTrafficStory = setupSampleWork(sprint, team, pTag, 'User Story', null, null, null, build, 'Show traffic', 'User Story');
       showTrafficStory.Priority_rank__c = 4;
       showTrafficStory.Use_Prioritizer__c = true;
       showTrafficStory.Epic__c = epic.Id;
       sampleWorksToInsert.add(showTrafficStory);
        
        
       ADM_Work__c txtFriednETAStory = setupSampleWork(sprint, team, pTag, 'User Story', null, null, null, build, 'Text Friend ETA', 'User Story');
       txtFriednETAStory.Use_Prioritizer__c = true;
       txtFriednETAStory.Epic__c = epic.Id;
       sampleWorksToInsert.add(txtFriednETAStory);
       
       ADM_Work__c controlByVoiceCommandStory = setupSampleWork(null, team, pTag, 'User Story', null, null, null, build, 'Control by voice commands', 'User Story');
       controlByVoiceCommandStory.Use_Prioritizer__c = true;
       controlByVoiceCommandStory.Epic__c = epic.Id;
       sampleWorksToInsert.add(controlByVoiceCommandStory);
        
        
       ADM_Work__c publicTrafficMapStory = setupSampleWork(null, team, pTag, 'User Story', null, null, null, build, 'Maps for public transport', 'User Story');
       publicTrafficMapStory.Use_Prioritizer__c = true;
       publicTrafficMapStory.Epic__c = epic.Id;
       sampleWorksToInsert.add(publicTrafficMapStory);
        
        
       ADM_Work__c trackUserLocationStory = setupSampleWork(null, team, pTag, 'User Story', null, null, null, build, 'Prompt user for location tracking permission', 'User Story');
       trackUserLocationStory.Use_Prioritizer__c = true;
       trackUserLocationStory.Epic__c = epic.Id;
       sampleWorksToInsert.add(trackUserLocationStory);
        
       System.debug('Going to insert works');
       insert sampleWorksToInsert;
        
        
       

    }
    
    private Map<String, String> getRecordTypeMap(){
       List<RecordType> types = [select id, name from RecordType where name in ('Investigation', 'Bug', 'User Story') and SObjectType = 'ADM_Work__c'];
       Map<String, String> mapToReturn = new Map<String, String>();
       for(RecordType rt: types){
           mapToReturn.put(rt.Name, rt.Id);
       }
       return mapToReturn;
   }
   
   
   private List<ADM_Impact__c> installImpacts(){
        List<ADM_Impact__c> impacts = new List<ADM_Impact__c>();
        ADM_Impact__c impact = new ADM_Impact__c();
        impact.Name = 'Performance';
        impact.Order__c = 20.0;
        impact.Example__c = 'A frequently used page takes 10 seconds to load, or times out.';
        impact.Description__c = 'Actual or potential slowdown that makes the app difficult or impossible to use.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Security';
        impact.Order__c = 30.0;
        impact.Example__c = 'Users can update an account when they should have read-only permissions.';
        impact.Description__c = 'Opens possibility of attack against the SFDC system, data integrity, or customer privacy.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Crash, Data Loss, or Corruption';
        impact.Order__c = 10.0;
        impact.Example__c = 'Outlook Edition fails and gives an error message on launch. The delete button on a field or record removes unrelated data. Saving a record replaces an unrelated record.';
        impact.Description__c = 'Data loss. Freeze. Browser or client application crashes.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Company Reputation';
        impact.Order__c = 40.0;
        impact.Example__c = 'Your brand name is misspelled.';
        impact.Description__c = 'Potential to harm company reputation or subject the companyto ridicule.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Poor Usability';
        impact.Order__c = 60.0;
        impact.Example__c = 'Users have to click five links to go back to the information they just viewed.';
        impact.Description__c = 'UI isn\'t as designed or needs design. Forces awkward user experience. 508 compliance issues.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Has Workaround';
        impact.Order__c = 80.0;
        impact.Example__c = 'Package uninstall fails because it doesn\'t detect a custom object dependency (Workaround: manually remove dependency).  Default sort order on reports is incorrect.';
        impact.Description__c = 'Feature is broken or functionality doesn\'t behave as designed, but has workaround.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Cosmetic Doc/UI Text';
        impact.Order__c = 100.0;
        impact.Example__c = 'Missing period at end of sentence.';
        impact.Description__c = 'Cosmetic issues like punctuation errors, missing information.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Malfunctioning';
        impact.Order__c = 50.0;
        impact.Example__c = 'A package installation fails with no visible information to the user.';
        impact.Description__c = 'Functionality broken with no acceptable workaround for the customer.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Incorrect Doc/UI Text';
        impact.Order__c = 70.0;
        
        impact.Example__c = 'Broken image. Clicking "Help for this page" opens an irrelevant help page.';
        impact.Description__c = 'Errors of fact. Misspelled or badlyungrammatical text.';
        impacts.add(impact);
        impact = new ADM_Impact__c();
        impact.Name = 'Fit & Finish UI';
        impact.Order__c = 90.0;
        impact.Example__c = 'An image and text are too close together. A few pixels of padding around the image would make the page more readable.';
        impact.Description__c = 'UI issues that don\'t impair usability, such as padding, spacing, positioning, etc.';
        impacts.add(impact);
        insert impacts;
        return impacts;
   }
    
    private Map<String, String> getImpactMap(){
        Map<String, String> impactMap = new Map<String, String>();
        for(ADM_Impact__c impact: [Select id, name from adm_Impact__c]){
            impactMap.put(impact.Name, impact.Id);
        }
        return impactMap;
    }
   
   private List<ADM_Frequency__c> installFrequencies(){
        List<ADM_Frequency__c> frequencies = new List<ADM_Frequency__c>();
        ADM_Frequency__c frequency = new ADM_Frequency__c();
        frequency.Name = 'Sometimes';
        frequency.Order__c = 30.0;
        frequencies.add(frequency);
        
        frequency = new ADM_Frequency__c();
        frequency.Name = 'Always';
        frequency.Order__c = 10.0;
        frequencies.add(frequency);
        
        frequency = new ADM_Frequency__c();
        frequency.Name = 'Often';
        frequency.Order__c = 20.0;
        frequencies.add(frequency);
        
        frequency = new ADM_Frequency__c();
        frequency.Name = 'Rarely';
        frequency.Order__c = 40.0;
        frequencies.add(frequency);
        
        insert frequencies;
        return frequencies;
   }
    
    private Map<String, String> getFrequencyMap(){
        Map<String, String> frequencyMap = new Map<String, String>();
        for(adm_Frequency__c frequency: [Select id, name from adm_Frequency__c]){
            frequencyMap.put(frequency.Name, frequency.Id);
        }
        return frequencyMap;
    }
   
   private List<ADM_Priority__c> installPriorities(){
        List<ADM_Priority__c> priorities = new List<ADM_Priority__c>();
        ADM_Priority__c priority = new ADM_Priority__c();
        priority.Name = 'P4';
        priorities.add(priority);
        
        priority = new ADM_Priority__c();
        priority.Name = 'P0';
        priorities.add(priority);
        
        priority = new ADM_Priority__c();
        priority.Name = 'P1';
        priorities.add(priority);
        
        priority = new ADM_Priority__c();
        priority.Name = 'P2';
        priorities.add(priority);
        
        priority = new ADM_Priority__c();
        priority.Name = 'P3';
        priorities.add(priority);
        
        priority = new ADM_Priority__c();
        priority.Name = 'P99';
        priorities.add(priority);
        
        insert priorities;
        return priorities;
   }
   
   private List<ADM_Priority_Mapping__c> installPriorityMapping(List<ADM_Impact__c> impacts, List<ADM_Frequency__c> frequencies,
                                                                        List<ADM_Priority__c> priorities){
        
        
        Map<String,ADM_Priority__c> name2PriorityObject = new Map<String,ADM_Priority__c>();
        for(ADM_Priority__c priority:priorities){
            name2PriorityObject.put(priority.name, priority);
        }
        
        Map<String,String> impactFrequencyMapping = new Map<String,String>();
        impactFrequencyMapping.put('Crash, Data Loss, or Corruption'+'Always','P0');
        impactFrequencyMapping.put('Crash, Data Loss, or Corruption'+'Often','P0');
        impactFrequencyMapping.put('Crash, Data Loss, or Corruption'+'Sometimes','P1');
        impactFrequencyMapping.put('Crash, Data Loss, or Corruption'+'Rarely','P1');
        impactFrequencyMapping.put('Performance'+'Always','P0');
        impactFrequencyMapping.put('Performance'+'Often','P1');
        impactFrequencyMapping.put('Performance'+'Sometimes','P2');
        impactFrequencyMapping.put('Performance'+'Rarely','P3');
        impactFrequencyMapping.put('Security'+'Always','P1');
        impactFrequencyMapping.put('Security'+'Often','P1');
        impactFrequencyMapping.put('Security'+'Sometimes','P2');
        impactFrequencyMapping.put('Security'+'Rarely','P3');
        impactFrequencyMapping.put('Company Reputation'+'Always','P1');
        impactFrequencyMapping.put('Company Reputation'+'Often','P1');
        impactFrequencyMapping.put('Company Reputation'+'Sometimes','P2');
        impactFrequencyMapping.put('Company Reputation'+'Rarely','P3');
        impactFrequencyMapping.put('Malfunctioning'+'Always','P1');
        impactFrequencyMapping.put('Malfunctioning'+'Often','P2');
        impactFrequencyMapping.put('Malfunctioning'+'Sometimes','P3');
        impactFrequencyMapping.put('Malfunctioning'+'Rarely','P3');
        impactFrequencyMapping.put('Poor Usability'+'Always','P1');
        impactFrequencyMapping.put('Poor Usability'+'Often','P2');
        impactFrequencyMapping.put('Poor Usability'+'Sometimes','P3');
        impactFrequencyMapping.put('Poor Usability'+'Rarely','P3');
        impactFrequencyMapping.put('Incorrect Doc/UI Text'+'Always','P1');
        impactFrequencyMapping.put('Incorrect Doc/UI Text'+'Often','P2');
        impactFrequencyMapping.put('Incorrect Doc/UI Text'+'Sometimes','P3');
        impactFrequencyMapping.put('Incorrect Doc/UI Text'+'Rarely','P3');
        impactFrequencyMapping.put('Has Workaround'+'Always','P2');
        impactFrequencyMapping.put('Has Workaround'+'Often','P3');
        impactFrequencyMapping.put('Has Workaround'+'Sometimes','P3');
        impactFrequencyMapping.put('Has Workaround'+'Rarely','P4');
        impactFrequencyMapping.put('Fit & Finish UI'+'Always','P3');
        impactFrequencyMapping.put('Fit & Finish UI'+'Often','P4');
        impactFrequencyMapping.put('Fit & Finish UI'+'Sometimes','P4');
        impactFrequencyMapping.put('Fit & Finish UI'+'Rarely','P4');
        impactFrequencyMapping.put('Cosmetic Doc/UI Text'+'Always','P3');
        impactFrequencyMapping.put('Cosmetic Doc/UI Text'+'Often','P4');
        impactFrequencyMapping.put('Cosmetic Doc/UI Text'+'Sometimes','P4');
        impactFrequencyMapping.put('Cosmetic Doc/UI Text'+'Rarely','P4');
        
        List<ADM_Priority_Mapping__c> pMappings = new List<ADM_Priority_Mapping__c>();
        for(ADM_Impact__c impact:impacts){
            for(ADM_Frequency__c frequency:frequencies){
                ADM_Priority_Mapping__c pMapping = new ADM_Priority_Mapping__c();
                pMapping.Priority__c = name2PriorityObject.get(impactFrequencyMapping.get(impact.Name+frequency.Name)).Id;
                pMapping.Frequency__c = frequency.Id;
                pMapping.Impact__c = impact.Id;
        
                pMappings.add(pMapping); 
        
            }
        }
        
        insert pMappings;
        return pMappings;
   }
   private List<ADM_Type__c> installTypes(){
        List<ADM_Type__c> types = new List<ADM_Type__c>();
        ADM_Type__c type = new ADM_Type__c();
        type.name = 'Bug List';
        types.add(type);
        type = new ADM_Type__c();
        type.name = 'Integrate';
        types.add(type);
        type = new ADM_Type__c();
        type.name = 'Bug';
        types.add(type);
        type = new ADM_Type__c();
        type.name = 'Test Case';
        types.add(type);
        type = new ADM_Type__c();
        type.name = 'Test Failure';
        types.add(type);
        type = new ADM_Type__c();
        type.name = 'Test Tool';
        types.add(type);
        type = new ADM_Type__c();
        type.name = 'Help';
        types.add(type);
        type = new ADM_Type__c();
        type.name = 'Test Change';
        types.add(type);
        type = new ADM_Type__c();
        type.name = 'Translation';
        types.add(type);
        
        insert types;
        return types;
   }
   
   private List<ADM_Impact_Type__c> installImpactTypes(List <ADM_Impact__c> impacts, List<ADM_Type__c> types){
      List<ADM_Impact_Type__c> impactTypes = new List<ADM_Impact_Type__c>();
      ADM_Impact_Type__c impactType;
      for(ADM_Impact__c impact:impacts){
        for(ADM_Type__c type:types){
            impactType = new ADM_Impact_Type__c();
            impactType.Impact__c = impact.Id;
            impactType.Type__c = type.id;
            impactTypes.add(impactType);
        }                                            
      }
      insert impactTypes;
      return impactTypes;
   }
   
   private ADM_Scrum_Team__c installScrumTeam(){
       ADM_Scrum_Team__c team = new ADM_Scrum_Team__c();
       team.Name = 'Sample';
       team.cloud__c = 'IT';
        
       insert team;
       return team;
   }
   private ADM_Scrum_Team_Member__c installScrumTeamMember(InstallContext context, ADM_Scrum_Team__c team){
   
       ADM_Scrum_Team_Member__c teamMember= new ADM_Scrum_Team_Member__c();
        if(context != null){
           teamMember.Member_Name__c = context.installerID();
       }
       else{
           teamMember.Member_Name__c = UserInfo.getUserId();
       }
       
       teamMember.Scrum_Team__c = team.Id;
        
       insert teamMember;
       return teamMember;
   }
   
   private ADM_Sprint__c installSprint(ADM_Scrum_Team__c team){
        Set<String> sprintNamesForValidation = new Set<String>();
        ADM_Sprint__c sprint;
        List<ADM_Sprint__c> sprintsToInsert = new List<ADM_Sprint__c>();
        //Create 4 sample sprints
        Integer sprintIncrement = 0;
        Integer maxLoop = 4;
        for(Integer count =0; count<4; count++){
            sprint = new ADM_Sprint__c();
            Date currentDate = Date.today() + sprintIncrement;
            Date startDate;
            Date endDate;
            Integer numberOfDays = Date.daysInMonth(currentDate.year(), currentDate.month());
            String todaysDate = (System.now()+ sprintIncrement).format('yyyy-MM-dd');
            String[] dateStringSplit = todaysDate.split('-');
            sprint.Name = dateStringSplit[0] + '.'+dateStringSplit[1];
            Date midDayOfMonth;
            Date lastDayOfMonth = Date.newInstance(currentDate.year(), currentDate.month(), numberOfDays);
            if(numberOfDays == 31){
                midDayOfMonth = lastDayOfMonth - 15;     
            }
            else{
                  midDayOfMonth = lastDayOfMonth - 14;
            }
            if(Integer.valueof(dateStringSplit[2]) >15){
             sprint.Name += 'b';  
             
             startDate = midDayOfMonth;
             endDate = lastDayOfMonth;
            }
            else{
               sprint.Name += 'a';
               startDate = Date.newInstance(currentDate.year(), currentDate.month(), 1);
               endDate = midDayOfMonth -1;
            }
                   
            sprint.Name += '-Sample Team';
            
            
            
            
            sprint.Start_Date__c = startDate;
            sprint.End_Date__c = endDate;
            sprint.Scrum_Team__c = team.Id;
            sprint.Projected_Velocity__c = 15; 
            if(!sprintNamesForValidation.contains(sprint.Name)){
                sprintsToInsert.add(sprint);
                sprintNamesForValidation.add(sprint.Name);
            }
            else{
                maxLoop+=1;
            }
            
            sprintIncrement += 15;
            
        }
        
        
        insert sprintsToInsert;
        return sprintsToInsert[0];
   }
   
   private ADM_Build__c installBuild(){
        ADM_Build__c build = new ADM_Build__c();
        build.Name = 'st1.0';

        insert build;
        return build;
   }
   
   private ADM_Product_Tag__c installProductTag(ADM_Scrum_Team__c team){
        ADM_Product_Tag__c pTag = new ADM_Product_Tag__c();
        pTag.Name = 'Sample Product Tag';
        pTag.Team__c = team.Id;

        insert pTag;
        return pTag;

   }
   
   private ADM_Assignment_Rule__c installAssignmentRule(InstallContext context, ADM_Scrum_Team__c team){
       ADM_Assignment_Rule__c rule = new ADM_Assignment_Rule__c();
       if(context != null){
           rule.Assignee_Assignment__c = context.installerID();
           rule.QA_Assignment__c = context.installerID();
           rule.Product_Owner__c = context.installerID();
       }
       else{
            rule.Assignee_Assignment__c = UserInfo.getUserId();
            rule.QA_Assignment__c = UserInfo.getUserId();
            rule.Product_Owner__c = UserInfo.getUserId();
       }
       
       rule.Scrum_Team_Assignment__c = team.Id;
       insert rule;
       return rule;
   }
   
   private List<ADM_Tag_Assignment__c> installTagAssignments(Adm_Assignment_Rule__c rule, Adm_Product_Tag__c pTag ){
        List<ADM_Tag_Assignment__c> tagAssignments = new List<ADM_Tag_Assignment__c>();
        ADM_Tag_Assignment__c tAssignment = new ADM_Tag_Assignment__c();
        tAssignment.Assignment_Rule__c = rule.id;
        tAssignment.Product_Tag__c = pTag.id;
        tAssignment.Record_Type__c = 'Bug';
        tagAssignments.add(tAssignment);
        tAssignment = new ADM_Tag_Assignment__c();
        tAssignment.Assignment_Rule__c = rule.id;
        tAssignment.Product_Tag__c = pTag.id;
        tAssignment.Record_Type__c = 'User Story';
        tagAssignments.add(tAssignment);
        tAssignment = new ADM_Tag_Assignment__c();
        tAssignment.Assignment_Rule__c = rule.id;
        tAssignment.Product_Tag__c = pTag.id;
        tAssignment.Record_Type__c = 'Investigation';
        tagAssignments.add(tAssignment);
        insert tagAssignments;
        return tagAssignments;
   }
    
     private ADM_Epic__c installEpic(String epicName){
        ADM_Epic__c epic =  new ADM_Epic__c();
        epic.Name = epicName;
        insert epic;
        return epic;
   }
   
   private adm_Work__c setupSampleWork(ADM_Sprint__c sprint, ADM_Scrum_Team__c team, ADM_Product_Tag__c pTag, String type,
                             String impactId, String frequencyId,String priority, ADM_Build__c build,
                           String subject, String recordType){
    
        adm_Work__c work = new adm_Work__c();
        work.subject__c = subject;
        if(null != sprint){
            work.sprint__c = sprint.Id;                    
        }
        work.scrum_team__c = team.Id;
        work.product_tag__c = pTag.Id;
        work.type__c = type;
        work.impact__c = impactId;
        work.frequency__c = frequencyId;
        work.found_in_build__c = build.Id;
        work.status__c = 'New';
        
        String recordTypeID = '';
        if(recordType == 'Bug'){
            recordTypeID = BUG_RECORDTYPE;
        }
        else if(recordType == 'User Story'){
            recordTypeID = USERSTORY_RECORDTYPE;
        }
        else{
            recordTypeID = INVESTIGATION_RECORDTYPE;
        }
        work.RecordTypeId = recordTypeID;
        return work;
   }

   private void updateUserPreferenceForKanbanConfig(){
      List<ADM_User_Preferences__c> userPrefs = [select id, UseColorCoding__c, ShowNumberOfDaysInColumn__c, ShowNumberOfTasks__c, ShowNumberOfPosts__c, ShowPriority__c, ShowScheduledBuild__c, ShowStoryPoints__c, ShowColoredSubjects__c, ShowWorkID__c, ShowRecordTypeIcon__c, ShowQE__c from ADM_User_Preferences__c where UseColorCoding__c = null and ShowNumberOfDaysInColumn__c = null and ShowNumberOfTasks__c = null and ShowNumberOfPosts__c = null and ShowPriority__c = null and ShowScheduledBuild__c = null and ShowStoryPoints__c = null and ShowColoredSubjects__c = null and ShowWorkID__c = null and ShowRecordTypeIcon__c = null and ShowQE__c = null];

      for(ADM_User_Preferences__c userPref: userPrefs){
          userPref.UseColorCoding__c = true;
          userPref.ShowNumberOfDaysInColumn__c = true;
          userPref.ShowNumberOfTasks__c = true;
          userPref.ShowNumberOfPosts__c = true;
          userPref.ShowPriority__c = true;
          userPref.ShowScheduledBuild__c = true;
          userPref.ShowStoryPoints__c = true;
          userPref.ShowColoredSubjects__c = false; 
          userPref.ShowWorkID__c = true; 
          userPref.ShowRecordTypeIcon__c = true; 
          userPref.ShowQE__c = false;
          
      }

      update userPrefs;
   }
   
    private void addDefaultColorsToExistingTeams(){
        List<ADM_Scrum_Team__c> existingTeamsWithNoColors = [Select Id from ADM_Scrum_Team__c where Id not in (select team__c from adm_color__c where team__c != null) and Kanban__c = true];
        Set<String> teamIdsWithNoColors = new Set<String>();
        for(ADM_Scrum_Team__c existingTeamWithNoColors : existingTeamsWithNoColors){
            teamIdsWithNoColors.add(existingTeamWithNoColors.Id);
        }
        ADM_Color.createDefaultColorsFromTeamIds(teamIdsWithNoColors);
   }

  }