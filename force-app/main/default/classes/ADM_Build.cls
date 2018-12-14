public class ADM_Build {
	
	public static final String TEST_BUILD_NAME = 'ApexTestBuild';
	
	public static ADM_Build__c[] getAllBy( String columnName, List< String> columnValues ){
		ADM_Build__c[] builds = new ADM_Build__c[]{};
		
		try{
			
			if( columnName.equalsIgnoreCase('ownerid') ){
				
				builds = [ 
					Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
					From ADM_Build__c a 
					where OwnerId in :columnValues 
				];
			}
			
			else if( columnName.equalsIgnoreCase('name') ){
				
				builds = [ 
					Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
					From ADM_Build__c a 
					where Name in :columnValues 
				];
			}			
			
			else if( columnName.equalsIgnoreCase('lastmodifiedby') ){
				 
				builds = [ 					
					Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
					From ADM_Build__c a 
					where LastModifiedById in :columnValues 
				];
			}
			
			else if( columnName.equalsIgnoreCase('id') ){
				
				builds = [ 
					Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
					From ADM_Build__c a 
					where Id in :columnValues 
				];
			}
			
			else if( columnName.equalsIgnoreCase('external_id__c') ){
				
				builds = [ 
					Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
					From ADM_Build__c a 
					where External_ID__c in :columnValues 
				];
			}
			
			else if( columnName.equalsIgnoreCase('createdby') ){
				
				builds = [ 
					Select a.Owner.Email, a.Owner.Name, a.Owner.Id, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedBy.Email, a.LastModifiedBy.Name, a.LastModifiedBy.Id, a.LastModifiedById, a.Id, a.External_ID__c, a.CreatedDate, a.CreatedBy.Email, a.CreatedBy.Name, a.CreatedBy.Id, a.CreatedById 
					From ADM_Build__c a 
					where CreatedById in :columnValues 
				];
			}
							
			return builds;
		}
		
		catch( System.Exception e ){			
			
			return builds;
		}
	}	
	
	public static ADM_Build__c match( ADM_Build__c[] builds, String bid ){
		ADM_Build__c emptyBuild = new ADM_Build__c();
		
		for( ADM_Build__c b : builds ){
		
			if( b.Id == bid ){
				
				return b;
			}	
		}
		
		//return an emptyBuild cuz no one was found
		return emptyBuild;
	}
	
	public static ADM_Build__c get( String columnName, String columnValue ){
		ADM_Build__c build = new ADM_Build__c();
		ADM_Build__c[] builds;
		List< String> columnValues = new List< String >();
		
		columnValues.add( columnValue );		
		builds = getAllBy( columnName, columnValues );
		build = ADM_Build.match( builds, columnValue );
		
		return build;
	}
	
	public static testMethod void testGet() {
		ADM_Build__c build1 = createTestBuild();
		ADM_Build__c build2 = ADM_Build.get('id', build1.id);
		System.assertEquals(build1.id, build2.id, 'Build IDS do not match.  Build1:' + build1.id + ' Build2:' + build2.id);
		System.assertEquals(build1.name, build2.name, 'Build Names do not match.  Build1:' + build1.name + ' Build2:' + build2.name);
	}
	
	public static testMethod void testGetAllBy() {
		ADM_Build__c build1 = createTestBuild();
		List<String> columnValues = new List<String>();
		columnValues.add(build1.id);
		ADM_Build__c[] builds = ADM_Build.getAllBy('id', columnValues);
		System.assertEquals(build1.id, builds[0].id, 'Build IDS do not match.  Build1:' + build1.id + ' Build[0]:' + builds[0].id);
		System.assertEquals(build1.name, builds[0].name, 'Build Names do not match.  Build1:' + build1.name + ' Build[0]:' + builds[0].name);
		//retreive via name
		columnValues = new List<String>();
		columnValues.add(build1.name);
		builds = ADM_Build.getAllBy('name', columnValues);
		System.assertEquals(build1.id, builds[0].id, 'Build IDS do not match.  Build1:' + build1.id + ' Build[0]:' + builds[0].id);
		System.assertEquals(build1.name, builds[0].name, 'Build Names do not match.  Build1:' + build1.name + ' Build[0]:' + builds[0].name);
		
	}	
	
	public static ADM_Build__c createTestBuild() {
		ADM_Build__c build = new ADM_Build__c();
		build.Name = TEST_BUILD_NAME;
		Database.insert(build);
		return build;
	}	
	
	public static ADM_Build__c createTestBuild(String name) {
		ADM_Build__c build = new ADM_Build__c();
		build.Name = name;
		Database.insert(build);
		return build;
	}		
}