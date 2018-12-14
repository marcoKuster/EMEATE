trigger ADM_CertificationTrigger on ADM_Certification__c (before insert, after insert, after delete) {
    
    ADM_Certification__c [] newCertifications = Trigger.new;
    if (newCertifications != null){
    
        if(Trigger.isBefore){
            for(ADM_Certification__c certification : newCertifications){
                if(certification.Type__c != null){
                    certification.Certified__c = true;
                    if(certification.Certified_On__c == null){//If provided a certification type and date not given then we default it to today
                        certification.Certified_On__c = System.today();
                    }
                }
            }
        }
        if(Trigger.isAfter){
            List<User> usersToBeUpdated = new List<User>();
            Map<String, Set<ADM_Certification__c>> mapUserCerticiationToType = new Map<String, Set<ADM_Certification__c>>();
            for(ADM_Certification__c certification: newCertifications){
                Set<ADM_Certification__c> certificationSet = mapUserCerticiationToType.get(certification.User__c);
                if(certification.Type__c != null){
                    if(certificationSet == null){
                        certificationSet = new Set<ADM_Certification__c>();
                    }
                    certificationSet.add(certification);
                }
                mapUserCerticiationToType.put(certification.User__c, certificationSet);
            }
    
            List<User> users = [Select id, Name, Certified_Scrum_Master__c, Certified_Product_Owner__c, Scrum_Master_Certified_Date__c, Product_Owner_Certified_Date__c
                                 from User where id in :mapUserCerticiationToType.keySet() and isActive = true];
    
            if(users != null && users.size() > 0){
                for(User userIter: users){
                    Set<ADM_Certification__c> certificationSet = mapUserCerticiationToType.get(userIter.Id);
                    if(certificationSet != null){
                        for(ADM_Certification__c certification:certificationSet){
                            if(certification.Type__c != null){
                                if('Scrum Master'.equals(certification.Type__c)){
                                    userIter.Scrum_Master_Certified_Date__c = certification.Certified_On__c;
                                    userIter.Certified_Scrum_Master__c = true;
                                }
                                else if('Product Owner'.equals(certification.Type__c)){
                                    userIter.Product_Owner_Certified_Date__c = certification.Certified_On__c;
                                    userIter.Certified_Product_Owner__c = true;
                                }
                             }
    
                        }
                        usersToBeUpdated.add(userIter);
                    }
                }
            }
            if(usersToBeUpdated != null && usersToBeUpdated.size() >0){
                Database.update(usersToBeUpdated, false);
            }
    
         }
    
    } // new update
 
    if (Trigger.isAfter){
        if (Trigger.isDelete){
        
            final String PRODUCT_OWNER = 'Product Owner';
            final String SCRUM_MASTER = 'Scrum Master';
                
            Set<Id> productOwnersSet = new Set<Id>();
            Set<Id> scrumMasterSet = new Set<Id>();
            
            ADM_Certification__c [] deleteCertifications = Trigger.old;
            for(ADM_Certification__c certification : deleteCertifications){
                
                if ( certification.Type__c == PRODUCT_OWNER ){
                    productOwnersSet.add(certification.User__c);
                }
 
                if ( certification.Type__c == SCRUM_MASTER ){
                    scrumMasterSet.add(certification.User__c);
                }
            }
          
            Set<Id> userIdsToRevise = new Set<Id>();
            
            userIdsToRevise.addAll(productOwnersSet);
            userIdsToRevise.addAll(scrumMasterSet);
                
            List<User> usersToRevise = 
                [SELECT Id, Certified_Scrum_Master__c, Certified_Product_Owner__c FROM User WHERE Id IN :userIdsToRevise]; 
            
            for( User u : usersToRevise  ){
                if ( productOwnersSet.contains(u.Id) ){
                    u.Certified_Product_Owner__c = false; 
                }
                    
                if ( scrumMasterSet.contains(u.Id) ){   
                    u.Certified_Scrum_Master__c = false;        
                }
            }
            
            Database.update(usersToRevise);
        }
    }


}