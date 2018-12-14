/*
 * Unable to create public calendars in Apex so these tests must see all data.
 */
@isTest
private class ADM_ReleaseTriggerTest {

/*
@testcaseID a1DB00000001SS7
@userstory a07B0000000F9lsIAC
@Hierarchy GUS.BugforceToGus.Releases page.Automated Release Stamping
@Expected Results The release is deleted from the calendar
*/

    static testMethod void deleteReleaseWithStamps() {
        ADM_Release__c release = ADM_Release.createTestRelease();
        ADM_Released_In__c stamp = ADM_Release.createTestReleasedIn(release);
        // attempt to delete the release - it should fail because at least 1 work item has bene stamped with this release
        try {
            Database.delete(release);
        } catch(System.DmlException e) {
            System.assertEquals(true, e.getMessage().contains('Error: Please remove all related Released In records before deleting this release.'));
        }
    }

/*
@testcaseID a1DB00000001SSW
@userstory a07B0000000F9lsIAC
@Hierarchy GUS.BugforceToGus.Releases page.Automated Release Stamping
@Expected Results  The release is deleted from the calendar
*/
    static testMethod void deleteReleaseWithoutStamps() {
        ADM_Release__c release = ADM_Release.createTestRelease();
        try {
          delete release;
          System.assertEquals(true, true);
        } catch(System.DmlException e) {
          System.assertNotEquals(true, true);
        }
    }

/*
@testcaseID a1DB00000001SS3
@userstory a07B0000000F9lsIAC
@Hierarchy GUS.BugforceToGus.Releases page.Automated Release Stamping
@Expected Results  An error that a release with that same name has already been created is generated
*/
    static testMethod void createReleasesWithDuplicateNames() {
    	final String TEST_RELEASE_NAME = 'Test Release 123';
    	
    	ADM_Release__c release1 = ADM_Release.createTestRelease(TEST_RELEASE_NAME, Datetime.now(), null);
    	
        //attempt to create a new release with the same name
        ADM_Release__c release2;
        try {
			release2 = ADM_Release.createTestRelease(TEST_RELEASE_NAME, Datetime.now(), null);
            System.assert(false, 'Test should have thrown a DML exception before it reached here');
        } catch (System.Dmlexception e) {
            System.assertEquals(true, e.getMessage().contains('duplicates value on record with id:'), '->' + e.getMessage());
        }

        //repeat with different case
        try {
            release2 = ADM_Release.createTestRelease(TEST_RELEASE_NAME.toUpperCase(), Datetime.now(), null);
            System.assert(false, 'Test should have thrown a DML exception before it reached here');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().contains('duplicates value on record with id:'), e.getMessage());
        }

        //repeat but set up two releases.  The original with no spaces and then attempt to insert a duplicate, identical except for white space
        ADM_Release__c releaseNoSpaces = ADM_Release.createTestRelease('MyTestReleaseName123', Datetime.now(), null);
        try {
        	ADM_Release__c releaseWithSpaces = ADM_Release.createTestRelease('My Test Release Name 123', Datetime.now(), null);
            System.assert(false, 'Test should have thrown a DML exception before it reached here');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().contains('duplicates value on record with id:'), e.getMessage());
        }
    }

/*
@testcaseID a1DB00000001SRd
@userstory a07B0000000F9lsIAC
@Hierarchy GUS.BugforceToGus.Releases page.Automated Release Stamping
@Expected Results The release is added to the calendar and name/date/time shows on the calendar
*/
	/**
	 * Verify that when a release having a releaseDate specified is created, a calendar event is added to the public release calendar.
	 * @author ccopek
	 **/
    static testMethod void testEventCreationOnReleaseDateInsert() {
		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null);
		
		assertEventCreation(rel);
    }
    
/*
@testcaseID a1DB00000001SRx
@userstory a07B0000000F9lsIAC
@Hierarchy GUS.BugforceToGus.Releases page.Automated Release Stamping
@Expected Results The release is updated in the calendar as well
*/
	   
	/**
	 * Verify that when a release that originally had no releaseDate is updated to have a releaseDate, a calendar event is added to the public release calendar.
	 * @author ccopek
	 **/
    static testMethod void testEventCreateOnReleaseDateUpdate() {
		ADM_Release__c rel = ADM_Release.createTestRelease();

		rel.Release_Date__c = Datetime.now();
		Database.update(rel);
				
		assertEventCreation(rel);
    }
/*
@testcaseID a1DB00000001SS2
@userstory a07B0000000F9lsIAC
@Hierarchy GUS.BugforceToGus.Releases page.Automated Release Stamping
@Expected Results The release is updated in the calendar as well
*/

	/**
	 * Verify that when a release date is updated, the event start/end dates are updated as well
	 * @author ccopek
	 **/
    static testMethod void testEventUpdateOnReleaseDateUpdate() {
		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null);

		// Now add a day to the release dateTime and verify the event start/end dateTimes are updated
		rel.Release_Date__c = rel.Release_Date__c.addHours(24);
		Database.update(rel);
				
		assertEventCreation(rel);
    }

/*
@testcaseID a1DB00000001Sa1
@userstory a07B0000000F9lsIAC
@Hierarchy GUS.BugforceToGus.Releases page.Automated Release Stamping
@Expected Results The release should be removed from calendar
*/

	/**
	 * Verify that when a release date is blanked out, the event is deleted
	 * @author ccopek
	 **/
    static testMethod void testEventDeleteOnReleaseDateRemoval() {
		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null);
		
		assertEventCreation(rel);

		// Now blank out the release date and verify the event has been deleted
		rel.Release_Date__c = null;
		Database.update(rel);
				
		List<Event> events = ADM_Release.getEventsForRelease(rel);
        if (events != null) {
			System.assert(events.size() == 0, 'There should be no events associated to the release');				
    	}
    }

/*
@testcaseID a1DB00000001Siu
@userstory a07B0000000F9lsIAC
@Hierarchy GUS.BugforceToGus.Releases page.Automated Release Stamping
@Expected Results The release name should be changed on calendar
*/

	/**
	 * Verify that when a release name is updated, the event subject is updated as well
	 * @author ccopek
	 **/
    static testMethod void testEventUpdateOnReleaseNameUpdate() {
		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null);

		// Now change the release name
		rel.Name = 'Change to another name';
		Database.update(rel);
				
		assertEventCreation(rel);
    }

   	private static void assertEventCreation(ADM_Release__c release) {
		List<Event> events = ADM_Release.getEventsForRelease(release);		
		/* DEBUG ON */ System.debug('ADM_Release.assertEventCreation: events=' + events);
        if (events != null) {
			System.assert(events.size() == 1, 
			  'ADM_Release.assertEventCreation: Wrong number of events created in the public calendar. Should have had 1 event created; number actually created was ' 
			  + events.size());
			Event event = events.get(0);
			System.assert(release.Name.equals(event.subject), 'Event subject was not set to the Release name.');
			System.assert(release.Release_Date__c.isSameDay(event.startDateTime), 'Event start dateTime not set as expected.');
   		}
    }
   	

/*
@testcaseID a1DB00000004nPo
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Release Date Plus Duration
*/

	/**
	 * Create release with Release Date and Duration, insert record, check that release record and created event created have correct End Time.
	 * @author snahm
	 **/
    static testMethod void testReleaseDatePlusDuration() {	
    	
    	final Integer TEST_DURATION = 120;		// Minutes

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);
		
		rel = [select Release_Date__c, Scheduled_End_Date__c from ADM_Release__c where id = :rel.id];
		/* DEBUG OFF System.Debug('testReleaseDatePlusDuration: Release=' + rel);			/* DEBUG OFF */    	
		
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'Release End Time is not correct');		
		
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG OFF System.Debug('testReleaseDatePlusDuration: Event=' + relEvent[0]);		/* DEBUG OFF */
		
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {
			System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
				'Event End Time is not correct');
    	}
    }
/*
@testcaseID a1DB00000002k0T
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Reset Duration Does Not Change End Date
*/
    /**
	 * Create release with Release Date and End Date (Duration == 120 minutes), insert record, set Duration to null, 
	 * Update record, check that Duration is still 120 minutes and End Date is correct.
	 * @author snahm
	 **/
    static testMethod void testResetDurationDoesNotChangeEndDate() {
    	
    	final Integer TEST_DURATION = 120;		// Minutes

		ADM_Release__c rel = ADM_Release.setupTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);
		Database.insert(rel);
		
		rel = [select Name, Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */ 
		System.Debug('testResetDurationDoesNotChangeEndDate: After Insert Release=' + rel);  	
		/* DEBUG */

		rel.Planned_Duration__c = null;
		Database.update(rel);

		rel = [select Name, Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */ System.Debug('testResetDurationDoesNotChangeEndDate: After Update Release=' + rel);  	/* DEBUG */    	
		
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'Release End Time should be ' + rel.Release_Date__c.addMinutes(TEST_DURATION) + ' but is ' + rel.Scheduled_End_Date__c);
		System.assert(rel.Planned_Duration__c == TEST_DURATION, 
			'Release Duration should be ' + TEST_DURATION + ' but is ' + rel.Planned_Duration__c);


		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG OFF  System.Debug('testResetDurationDoesNotChangeEndDate: Event=' + relEvent[0]);  DEBUG OFF */    	
		
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {   
			System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
				'Event End Time is not correct');
    	}    
    }    
/*
@testcaseID a1DB00000002k0J
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results GUS.Releases page.Automated Release Stamping
*/

	/**
	 * Create release with Release Date and End Date, insert record, check that release has correct Duration.
	 * @author snahm
	 **/
    static testMethod void testReleaseDatePlusEndDate() {
    	
    	final Integer TEST_DURATION = 120;

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);
		
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {
			System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
				'Event End Time is not correct');
        }
		rel = [select Planned_Duration__c from ADM_Release__c where id = :rel.id];
		
		System.assert(rel.Planned_Duration__c == TEST_DURATION, 
			'Release Duration is not correct');
    }
/*
@testcaseID a1DB00000004nPt
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Release Date Update Preseves End Date Duration
*/

	/**
	 * Create release with Release Date and End Date, insert record, Update Release Date, check that End Date is set to Release Date plus
	 * the old Duration.
	 * @author snahm
	 **/
    static testMethod void testReleaseDateUpdatePresevesEndDateDuration() {
    	
    	final Integer TEST_DURATION = 120;

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);

		rel = [select Release_Date__c from ADM_Release__c where id = :rel.id];
		
		rel.Release_Date__c = rel.Release_Date__c.addHours(4);
		Database.update(rel);

		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		
		System.assert(rel.Planned_Duration__c == TEST_DURATION, 
			'Release Duration is not correct');
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'Release End Time is not correct');
					
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {   
			System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
				'Event End Time is not correct');
    	}
    }
/*
@testcaseID a1DB00000004nPy
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Clone With Bad End Date
*/

	/**
	 * Create release with Release Date and bad End Date (date in past) as can happen with Cloned records and Duration as non-default, insert record, check that 
	 * End Date is set to Release Date plus the old Duration.
	 * @author snahm
	 **/
    static testMethod void testCloneWithBadEndDate() {
    	
    	final Integer TEST_DURATION = 120;
    	final Integer DEFAULT_DURATION = 60;	// Default duration used when Duration and End Date are not specified or is bad
		final Integer MAXEVENTDURATION = /* 14 Days */ 14 * 24 * 60;	// This is a contraint of the Event object


		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', 
			Datetime.now(),
			Datetime.now().addDays(-7), // end date before start date: bad
			TEST_DURATION);
		
		rel = [select Name, Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		
		System.assert(rel.Planned_Duration__c == TEST_DURATION, 
			'Release Duration should be ' + TEST_DURATION + ' but is ' + rel.Planned_Duration__c);
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'Release End Time should be ' + (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)) + 
			' but is ' + rel.Scheduled_End_Date__c);
					
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {
		  System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'Event End Time should be ' + (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)) + 
			' but is ' + relEvent[0].endDateTime);
        }
			
		ADM_Release__c relnew = ADM_Release.setupTestRelease(rel.Name.reverse(),	// Create a different release name
			rel.Release_Date__c.addMinutes(MAXEVENTDURATION + TEST_DURATION),
			rel.Scheduled_End_Date__c,
			-TEST_DURATION);			// Negative duration
		relnew.Planned_GUS_Release_Date__c = rel.Release_Date__c;
		relnew.Planned_GS0_End_Date__c = null;
		relnew.Planned_GS0_Duration__c = null;	// Null
		Database.insert(relnew);
		
		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c, Planned_GS0_Duration__c
			from ADM_Release__c where id = :relnew.id];
		
		System.assert(rel.Planned_Duration__c == DEFAULT_DURATION, 
			'Release Duration should be ' + DEFAULT_DURATION + ' but is ' + rel.Planned_Duration__c);
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (DEFAULT_DURATION*60)), 
			'Release End Time should be ' + (rel.Release_Date__c.getTime()/1000 + (DEFAULT_DURATION*60)) + 
			' but is ' + rel.Scheduled_End_Date__c);
		System.assert(rel.Planned_GS0_Duration__c == null, 
			'Release Duration should be NULL but is ' + rel.Planned_GS0_Duration__c);
					
		relEvent = ADM_Release.getEventsForRelease(rel);
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {
			System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (DEFAULT_DURATION*60)), 
				'Event End Time should be ' + (rel.Release_Date__c.getTime()/1000 + (DEFAULT_DURATION*60)) + 
				' but is ' + relEvent[0].endDateTime);	
    	}    
    }    
/*
@testcaseID a1DB00000004nPy
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Reset End Date And Duration To Null
*/

	/**
	 * Create release with Release Date and End Date, insert record, set Release Date and Duration to null, check that End Date 
	 * and Duration remain null.
	 * @author snahm
	 **/
    static testMethod void testResetEndDateAndDurationToNull() {
    	
    	final Integer TEST_DURATION = 120;

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);

		rel = [select Release_Date__c from ADM_Release__c where id = :rel.id];
		
		rel.Scheduled_End_Date__c = null;
		rel.Planned_Duration__c = null;
		Database.update(rel);

		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		
		System.assert(rel.Planned_Duration__c == null, 
			'Release Duration should be null but is ' + rel.Planned_Duration__c);
		System.assert(rel.Scheduled_End_Date__c == null, 
			'Release End Time should be null but is ' + rel.Scheduled_End_Date__c);
    }  
/*
@testcaseID a1DB00000004nQ8
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results End Date Update Sets Duration
*/

	/**
	 * Create release with Release Date and End Date, insert record, Update End Date and Duration, but set the Duration 
	 * to be a different amount than is correct, check that Duration is set to Release Date plus the new End Date
	 * (ie, End Date takes precedence over Duration).
	 * @author snahm
	 **/
    static testMethod void testEndDateUpdateSetsDuration() {
    	
    	final Integer TEST_DURATION = 120;
    	final Integer TIME_ADDED = 240;

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);

		rel = [select Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		
		rel.Scheduled_End_Date__c = rel.Scheduled_End_Date__c.addMinutes(TIME_ADDED);
		rel.Planned_Duration__c = TIME_ADDED;		// Should actually be (TEST_DURATION + TIME_ADDED)
		Database.update(rel);

		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		
		System.assert(rel.Planned_Duration__c == (TEST_DURATION + TIME_ADDED), 
			'Release Duration is not correct');
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION + TIME_ADDED) * 60), 
			'Release End Time is not correct');
					
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {   
		  System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION + TIME_ADDED) * 60), 
			'Event End Time is not correct');
    	}
    }
/*
@testcaseID a1DB00000004nQD
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Duration Sets End Date If Null
*/

	/**
	 * Create release with Release Date and End Date, insert record, set End Date to null and set Duration to a different value,
	 * check that End Date is set to Release Date plus Duration (ie, End Date set from Duration when End Date is null).
	 * @author snahm
	 **/
    static testMethod void testDurationSetsEndDateIfNull() {
    	
    	final Integer TEST_DURATION = 120;
    	final Integer NEW_DURATION = 75;

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);

		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG OFF  System.Debug('testDurationSetsEndDateIfNull: after insert Release=' + rel);		/* DEBUG */    	
		
		rel.Scheduled_End_Date__c = null;
		rel.Planned_Duration__c = NEW_DURATION;
		Database.update(rel);

		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG OFF  System.Debug('testDurationSetsEndDateIfNull: after update Release=' + rel);		/* DEBUG */    	
		
		System.assert(rel.Planned_Duration__c == NEW_DURATION, 
			'Release Duration is not correct');
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (NEW_DURATION) * 60), 
			'Release End Time is not correct');
					
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG OFF   System.Debug('testDurationSetsEndDateIfNull: Event=' + relEvent[0]);	/* DEBUG */    	
		
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {   
		  System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (NEW_DURATION) * 60), 
			'Event End Time is not correct');
    	}            
    }            
/*
@testcaseID a1DB00000004nQE
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Clear Release Date Resets End Date
*/
      
	/**
	 * Create release with Release Date and End Date, insert record, clear Release Date, update record, check that End Date and Duration are now null.
	 * @author snahm
	 **/
    static testMethod void testClearReleaseDateResetsEndDate() {
    	
    	final Integer TEST_DURATION = 120;

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);
		
		rel = [select Planned_Duration__c from ADM_Release__c where id = :rel.id];
		System.assert(rel.Planned_Duration__c == TEST_DURATION, 
			'Release Duration is not correct');
		rel.Release_Date__c = null;
		Database.update(rel);
		
		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		System.assert(rel.Scheduled_End_Date__c == null, 
			'Release Scheduled_End_Date__c was not set to NULL');
		System.assert(rel.Planned_Duration__c == null, 
			'Release Planned_Duration__c was not set to NULL');	
    }   
/*
@testcaseID a1DB00000004nQI
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Changed Release Date Updates End Date
*/

    /**
	 * Create release with Release Date and End Date (Duration == 120 minutes), insert record, set Release Date into the past (prior day), 
	 * Update record, check that End Date is 120 minutes later than new Start Date.
	 * @author snahm
	 **/
    static testMethod void testChangedReleaseDateUpdatesEndDate() {
    	
    	final Integer TEST_DURATION = 120;		// Minutes

		Datetime relStart = Datetime.now();
		
		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', relStart, null, TEST_DURATION);

		rel = [select Name, Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */ System.Debug('testChangedReleaseDateUpdatesEndDate: before update rel=' + rel);  /* DEBUG */		
		
		rel.Release_Date__c = relStart.addHours(-24);
		Database.update(rel);

		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */ System.Debug('testChangedReleaseDateUpdatesEndDate: after update rel=' + rel);  /* DEBUG */    	
		
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'testChangedReleaseDateUpdatesEndDate: Release End Time is not correct. Should be ' +
				(rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)) + ' but is ' + rel.Scheduled_End_Date__c.getTime()/1000);

		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG ON */  System.Debug('testChangedReleaseDateUpdatesEndDate: Event=' + relEvent);  /* DEBUG */    	
		
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {   
		  System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'testChangedReleaseDateUpdatesEndDate: Event End Time is not correct. Should be ' +
			(rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)) + ' but is ' + relEvent[0].endDateTime.getTime()/1000);
    	}    
    }    

/*
@testcaseID a1DB00000002k0Y
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Changed End Date Prior To Release Date Null Duration
*/

    /**
	 * Create release with Release Date and End Date (Duration == 120 minutes), insert record, set End Date into the past (60 minutes before Release Date), 
	 * and set Duration to null. Update record, check that End Date is 60 minutes later than Start Date (that is, the incorrect End Date is not allowed)
	 * @author snahm
	 **/
    static testMethod void testChangedEndDatePriorToReleaseDateNullDuration() {

    	final Integer TEST_DURATION = 120;		// Minutes

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);

		rel = [select Release_Date__c, Scheduled_End_Date__c from ADM_Release__c where id = :rel.id];
		rel.Scheduled_End_Date__c = rel.Release_Date__c.addMinutes(-60); // set End Date into the past (60 minutes before Release Date)
		rel.Planned_Duration__c = null;
		Database.update(rel);

		rel = [select Release_Date__c, Scheduled_End_Date__c from ADM_Release__c where id = :rel.id];
		/* DEBUG OFF  System.Debug('testChangedEndDatePriorToReleaseDate: Release=' + rel);		/* DEBUG */    	

		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (ADM_Release.RELEASE_DEFAULT_DURATION*60)), 
			'Release End Time should be ' + rel.Release_Date__c.addMinutes(ADM_Release.RELEASE_DEFAULT_DURATION) + ' but is ' + rel.Scheduled_End_Date__c);

		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG ON */   System.Debug('testChangedReleaseDateUpdatesEndDate: Event=' + relEvent);	/* DEBUG */    	

		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {
		  System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (ADM_Release.RELEASE_DEFAULT_DURATION*60)), 
			'Event End Time is not correct');
    	}
    }
/*
@testcaseID a1DB00000004nQs
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results Changed End Date Prior To Release Date With Duration
*/

    /**
	 * Create release with Release Date and End Date (Duration == 120 minutes), insert record, set End Date into the past (60 minutes before Release Date), 
	 * Update record, check that End Date is 120 minutes later than Start Date (that is, the End Date is set based on the Duration)
	 * @author snahm
	 **/
    static testMethod void testChangedEndDatePriorToReleaseDateWithDuration() {

    	final Integer TEST_DURATION = 120;		// Minutes

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, TEST_DURATION);

		rel = [select Release_Date__c, Scheduled_End_Date__c from ADM_Release__c where id = :rel.id];
		rel.Scheduled_End_Date__c = rel.Release_Date__c.addMinutes(-60); // set End Date into the past (60 minutes before Release Date)
		Database.update(rel);

		rel = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG OFF  System.Debug('testChangedEndDatePriorToReleaseDate: Release=' + rel);		/* DEBUG */    	

		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'Release End Time should be ' + rel.Release_Date__c.addMinutes(TEST_DURATION) + ' but is ' + rel.Scheduled_End_Date__c);

		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG OFF   System.Debug('testChangedReleaseDateUpdatesEndDate: Event=' + relEvent);	/* DEBUG */    	

		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {   
		  System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'Event End Time is not correct');
    	}    
    }    
/*
@testcaseID a1DB00000004nQx
@userstory a07B0000000O9Zh
@Hierarchy GUS.Releases page.Automated Release Stamping
@Expected Results End Date With Max Duration
*/

    /**
	 * Create release with Release Date and End Date (Duration == MAXEVENTDURATION), insert record, check that End Date is 
	 * MAXEVENTDURATION later than Start Date.  Then set End Date with Duration == MAXEVENTDURATION + 1, and check that
	 * the End Date is not accepted.
	 * @author snahm
	 **/
    static testMethod void testEndDateWithMaxDuration() {

    	final Integer MAXEVENTDURATION = 14 /* Days */ * 24 * 60;		// Minutes

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', Datetime.now(), null, MAXEVENTDURATION);	

		rel = [select Release_Date__c, Scheduled_End_Date__c from ADM_Release__c where id = :rel.id];
		
		Database.update(rel);

		rel = [select Release_Date__c, Scheduled_End_Date__c from ADM_Release__c where id = :rel.id];
		/* DEBUG OFF  System.Debug('testEndDateWithMaxDuration: Release=' + rel);		/* DEBUG */    	
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (MAXEVENTDURATION*60)), 
			'Release End Time is not correct');
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG OFF   System.Debug('testEndDateWithMaxDuration: Event=' + relEvent);	/* DEBUG */    	
		// Note: Event does not preserve the milliseconds, so compare the seconds		
        if (relEvent != null) {   
		  System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (MAXEVENTDURATION*60)), 
			'testEndDateWithMaxDuration: Event End Time is not correct');
        }
			
		rel.Planned_Duration__c = MAXEVENTDURATION+1;
		try {
			Database.update(rel);
		} catch (System.DmlException eDml) {
			/* DEBUG OFF 	System.debug('testEndDateWithMaxDuration: Expected Exception seen: ' + eDml);	/* DEBUG */
			System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, eDml.getDmlType(0));
			System.assert(eDml.getDmlMessage(0).contains('FIELD_INTEGRITY_EXCEPTION'),
				'DML Exception should be FIELD_INTEGRITY_EXCEPTION; Exception=' + eDml); 
		} catch (System.Exception e) {
			System.assert(true, 'testEndDateWithMaxDuration: Unexpected exception seen' + e);
		}
		
		rel.Planned_Duration__c = MAXEVENTDURATION * 2;	// Make Duration really long
		try {
			Database.update(rel);
		} catch (System.DmlException eDml) {
			/* DEBUG OFF 	System.debug('testEndDateWithMaxDuration: Expected Exception seen: ' + eDml);	/* DEBUG */
			System.assertEquals(StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, eDml.getDmlType(0));
			System.assert(eDml.getDmlMessage(0).contains('FIELD_INTEGRITY_EXCEPTION'),
				'DML Exception should be FIELD_INTEGRITY_EXCEPTION; Exception=' + eDml); 
		} catch (System.Exception e) {
			System.assert(true, 'testEndDateWithMaxDuration: Unexpected exception seen' + e);
		}		
    }


/** 
 * testReleaseDateChangedApplication. 
 * This test checks correct behavior when Application changes. 
 * 1: Create release with Release Date and Duration and Core App Type, insert
 *    record, check that an event is correctly created. 
 * 2: Change the Application, verify that the Location field now has the name of 
 *    the new Application 
 * 3: Change the Application back to core and verify there is one event with 
 *    correct Location field. 
 * 
 * @testcaseID a1DB0000000304O
 * @userStory W-2076536 
 * @hierarchy GUS.Releases page.Release Events 
 * @priority High 
 * @expectedResults Test Calendar Event Location when changing Application 
 * @author snahm
 */
    static testMethod void testReleaseDateChangedApplication() {	

		final String TEST_RELEASE_NAME = 'Test Release 123';
    	final Integer TEST_DURATION = 120;		// Minutes
    	final String UPDATED_TYPE = 'Second Application Type';
    	final String UPDATED_APPLICATION = 'Second Test Application';
    	ADM_Application__c appl1 = ADM_Application.createTestApplication();
		ADM_Application__c appl2 = ADM_Application.createTestApplication(UPDATED_APPLICATION, UPDATED_TYPE);

		// 1:	Application with only Base Release Event Templates will create a single Calendar Event with Location == Release Name
		ADM_Release__c rel = ADM_Release.createTestRelease(TEST_RELEASE_NAME, appl1);
		rel = [select Release_Date__c,Scheduled_End_Date__c,Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */  System.Debug('testReleaseDateChangedApplication: Before Update Release=' + rel);			/* DEBUG */    	
		
		rel.Release_Date__c = Datetime.now();
		rel.Planned_Duration__c = TEST_DURATION;
		Database.update(rel);

		rel = [select Application__c, Release_Date__c, Planned_Duration__c, Scheduled_End_Date__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */  System.Debug('testReleaseDateChangedApplication: After Update Release=' + rel);			/* DEBUG */    	
		
		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'testReleaseDateChangedApplication: Release End Time is not correct. Expected ' + 
			(rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)) + ' but got: ' + rel.Scheduled_End_Date__c.getTime()/1000);		
		
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG ON */  System.Debug('testReleaseDateChangedApplication: Event=' + relEvent);		/* DEBUG */
		// There should be one event
		if (relEvent != null) {
			System.Assert(relEvent.size() == 1, 
				'testReleaseDateChangedApplication: Wrong number (not 1) of events returned: ' + relEvent.size());
			// Location is Application's name
			System.assert(relEvent[0].Location.compareTo(appl1.Name) == 0, 
				'testReleaseDateChangedApplication: Calendar Event\'s Location is wrong. Expected ' + appl1.Name + 
				' but is: '+ relEvent[0].Location + ' Event=' + relEvent[0]);
			// Subject is TEST_RELEASE_NAME
			System.assert(relEvent[0].Subject.compareTo(TEST_RELEASE_NAME) == 0, 
				'testReleaseDateChangedApplication: Calendar Event\'s Subject is wrong. Expected ' + TEST_RELEASE_NAME + 
				' but is: '+ relEvent[0].Subject + ' Event=' + relEvent[0]);
		}
		// 2: Change the Application
		rel.Application__c = appl2.id;
		
		Database.update(rel);
		
		rel = [select Application__c, Release_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */  System.Debug('testReleaseDateChangedApplication: Updated with Second Applcation - Release=' + rel);			/* DEBUG */ 		
		
		relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG ON */  System.Debug('testReleaseDateChangedApplication: After UPDATED_APPLICATION Change - Event=' + relEvent);		/* DEBUG */
		// There should be one event (still), but Location is Second Application's Name
		if (relEvent != null) {
			System.Assert(relEvent.size() == 1, 
				'testReleaseDateChangedApplication: Wrong number of events returned. Expected 1 but got: ' + relEvent.size());
			System.Assert(relEvent[0].Location.equals(appl2.Name), 
				'testReleaseDateChangedApplication: Calendar Event\'s Location is wrong after Release Application changed. Expected ' + 
				appl2.Name + ' but is: '+ relEvent[0].Location + ' Event=' + relEvent[0]);
			// Subject should still be the name of the release
			System.assert(relEvent[0].Subject.compareTo(TEST_RELEASE_NAME) == 0, 
				'testReleaseDateChangedApplication: Calendar Event\'s Subject is wrong. Expected ' + TEST_RELEASE_NAME + 
				' but is: '+ relEvent[0] + ' Event=' + relEvent[0]);
		}	
		// 3: Change Application back. Original Event should be found.
		rel.Application__c = appl1.id;
		Database.update(rel);
		
		rel = [select Application__c, Release_Date__c, Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */  System.Debug('testReleaseDateChangedApplication: Fourth, Update - Release=' + rel);			/* DEBUG */ 
				
		relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG ON */  System.Debug('testReleaseDateChangedApplication: Changed back to Other - Event=' + relEvent);		/* DEBUG */
		if (relEvent != null) {
			System.Assert(relEvent.size() == 1, 
				'testReleaseDateChangedApplication: Wrong number (not 1) of events returned: ' + relEvent.size());
			// Location is Application's name
			System.assert(relEvent[0].Location.compareTo(appl1.Name) == 0, 
				'testReleaseDateChangedApplication: Calendar Event\'s Location is wrong. Expected ' + appl1.Name + 
				' but is: '+ relEvent[0].Location + ' Event=' + relEvent[0]);
			// Subject is TEST_RELEASE_NAME
			System.assert(relEvent[0].Subject.compareTo(TEST_RELEASE_NAME) == 0, 
				'testReleaseDateChangedApplication: Calendar Event\'s Subject is wrong. Expected ' + TEST_RELEASE_NAME + 
				' but is: '+ relEvent[0] + ' Event=' + relEvent[0]);
    	}
    }             
/*
@testcaseID
@userstory a07B0000000dKy6
@Hierarchy GUS.Releases page.Release Events
@Expected Results Test Release Date Plus Duration
*/        
	/**
	 * Create release with Release Date and Duration, insert record, check that release record 
	 * 	and the created events have correct End Time.
	 * @author snahm
	 **/
    static testMethod void testPrimaryReleaseDatePlusDuration() {	

		final String TEST_RELEASE_NAME = 'Test Release 123';
    	final Integer TEST_DURATION = 30;		// Minutes
    	ADM_Application__c appl1 = ADM_Application.createTestCoreApplication();

		ADM_Release__c rel = ADM_Release.createTestRelease(TEST_RELEASE_NAME, appl1);
		rel.Planned_Duration__c = TEST_DURATION;
		/* DEBUG ON */  System.Debug('testPrimaryReleaseDatePlusDuration: Updated Release Date = ' + rel.Release_Date__c.getTime()/1000);
		System.Debug('testPrimaryReleaseDatePlusDuration: New Scheduled End Date should = ' 
			+ (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)));
		/* DEBUG */
		Database.update(rel);
		
		rel = [select Release_Date__c,Scheduled_End_Date__c,Planned_Duration__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */  System.Debug('testPrimaryReleaseDatePlusDuration: Release=' + rel);			/* DEBUG */    	

		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
			'testPrimaryReleaseDatePlusDuration: Release End Time is not correct. Expected ' + 
			(rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)) + ' but got: ' + rel.Scheduled_End_Date__c.getTime()/1000);
		
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG ON */  System.Debug('testReleaseDatePlusDuration: Event=' + relEvent);		/* DEBUG */
		// There should be one event for the primary
		if (relEvent != null) {
			System.Assert(relEvent.size() == 1, 'Wrong number (not 1) of events returned: ' + relEvent.size());
			// Note: Event does not preserve the milliseconds, so compare the seconds		
			System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)), 
				'Release Calendar Event End Time is not correct. Expected ' + 
				(rel.Release_Date__c.getTime()/1000 + (TEST_DURATION*60)) + ' but got: ' + relEvent[0].endDateTime.getTime()/1000);
		}
    }

/** 
 * testMultipleReleaseDateTest
 * Test with multiple events. Create two releases, then update both and update
 * them together. Releases should be correctly updated. 
 * 
 * @testcaseID a1DB0000000304P
 * @userStory W-2076536 
 * @hierarchy GUS.Releases page.Release Events 
 * @priority High
 * @Expected Results
 * @author snahm
 */
	static testMethod void testMultipleReleaseDateTest() {	

		final String TEST_RELEASE_NAME = 'Test Release 123';
    	final Integer TEST_DURATION = 30;		// Minutes
    	Datetime now = Datetime.now();

		List<ADM_Release__c> rels = new List<ADM_Release__c>(); 

    	ADM_Application__c appl1 = ADM_Application.createTestCoreApplication();

		rels.add(ADM_Release.createTestRelease(TEST_RELEASE_NAME, appl1));
		rels[0].Release_Date__c = now;
		Database.update(rels[0]);

		/* DEBUG ON */
		ADM_Release__c rel = [select Name, Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c
			 from ADM_Release__c where Id = :rels[0].id][0];
		System.Debug('testMultipleReleaseDateTest: First Release after insert =' + rel);
		List<Event> relEvent = ADM_Release.getEventsForRelease(rels[0]);
		System.Debug('testMultipleReleaseDateTest: Events for First Release =' + relEvent);
		/* DEBUG */

		rels.add(ADM_Release.createTestRelease('Test Release 456', appl1));
		rels[1].Release_Date__c = now;
		Database.update(rels[1]);

		/* DEBUG ON */
		rel = [select Name, Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c from ADM_Release__c 
			where Id = :rels[1].id][0];
		System.Debug('testMultipleReleaseDateTest: Second Release after insert =' + rel);
		relEvent = ADM_Release.getEventsForRelease(rels[1]);
		System.Debug('testMultipleReleaseDateTest: Events for Second Release =' + relEvent);
		/* DEBUG */			

		rels[0].Name = 'Test Release 789';
		// Make a change to the legacy release
		rels[0].Scheduled_End_Date__c = rels[0].Release_Date__c.addMinutes(30);
		//   and the second release
		rels[1].Scheduled_End_Date__c = rels[1].Release_Date__c.addMinutes(30);		

		System.Debug('testMultipleReleaseDateTest: before update rels=' + rels);
		
		Database.Update(rels);								
		
		Set <ID> relsId = new Set<ID>();
		relsId.add(rels[0].id);
		relsId.add(rels[1].id);
		
		rels = [select Release_Date__c, Scheduled_End_Date__c, Planned_Duration__c
			from ADM_Release__c where id = :relsId];
			
		/* DEBUG ON */  System.Debug('testMultipleReleaseDateTest: After update of both releases=' + rels);	/* DEBUG */    	

		System.assert(rels[0].Scheduled_End_Date__c == rels[0].Release_Date__c.addMinutes(30), 
			'testMultipleReleaseDateTest: Release End Time is not correct. Should be ' + (rels[0].Release_Date__c.addMinutes(30)) 
			+ ' but is ' + rels[0].Scheduled_End_Date__c);
		System.assert(rels[1].Scheduled_End_Date__c == rels[1].Release_Date__c.addMinutes(30), 
			'testMultipleReleaseDateTest: Release End Time is not correct. Should be ' + rels[1].Release_Date__c.addMinutes(30) 
			+ ' but is ' + rels[1].Scheduled_End_Date__c);
    }
    
/**
 * testReleaseDateDeletedEvents.
 * Create release with Release Date and Duration, insert record, delete the
 * Calendar event, update release Duration, update record; check that release was
 * recreated.
 *
 * @testcaseID a1DB0000000304Q
 
 * @userStory W-2076536 
 * @hierarchy GUS.Releases page.Release Events
 * @Expected Results Release was recreated
 * @priority High 
 * @author snahm 
 */
    static testMethod void testReleaseDateDeletedEvents() {	

    	final Integer TEST_DURATION = 30;		// Minutes
    	final Integer UPDATED_DURATION = 90;

		ADM_Application__c appl1 = ADM_Application.createTestApplication('Sherrifs Office', 'Law Enforcement');

		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', appl1);
		rel.Release_Date__c = Datetime.now();
		rel.Planned_Duration__c = TEST_DURATION;			
		Database.update(rel);

		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG ON */  System.Debug('testReleaseDateDeletedEvents: After Insert - Event=' + relEvent);		/* DEBUG */
		// There should be one event
		if (relEvent != null) {
			System.Assert(relEvent.size() == 1, 'testReleaseDateDeletedEvents: Wrong number (not 1) of events returned: ' + relEvent.size());
			Event primaryEvent = relEvent[0];
	
			System.Assert(primaryEvent != null, 'testReleaseDateDeletedEvents: Could not find release event');
			Database.delete(primaryEvent);		// Delete it
		}
		rel.Planned_Duration__c = UPDATED_DURATION;	// Change the Planned Duration to trigger an update
		Database.update(rel);
		//		
		relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG OFF  System.Debug('testReleaseDateDeletedEvents: After release Update - Event=' + relEvent);		/* DEBUG */
		// There should be one
		if (relEvent != null) {
			System.Assert(relEvent.size() == 1, 
				'testReleaseDateDeletedEvents: After deletion of original event and Release update, Wrong number (not 1) of events returned: ' + 
				relEvent.size());
		}
		rel = [select Release_Date__c, Scheduled_End_Date__c from ADM_Release__c where id = :rel.id];
		/* DEBUG ON */  System.Debug('testReleaseDateDeletedEvents: Release=' + rel);			/* DEBUG */    	

		System.assert(rel.Scheduled_End_Date__c.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (UPDATED_DURATION*60)), 
			'testReleaseDateDeletedEvents: Release End Time is not correct. Expected: ' + 
			(rel.Release_Date__c.getTime()/1000 + (UPDATED_DURATION*60)) + ' but got: ' + rel.Scheduled_End_Date__c.getTime()/1000);
		
		// Note: Event does not preserve the milliseconds, so compare the seconds
		if (relEvent != null) {	
		  System.assert(relEvent[0].endDateTime.getTime()/1000 == (rel.Release_Date__c.getTime()/1000 + (UPDATED_DURATION*60)), 
			'testReleaseDateDeletedEvents: Event End Time is not correct. Expected: ' + (rel.Release_Date__c.getTime()/1000 + (UPDATED_DURATION*60)) + 
			' but got: ' + relEvent[0].endDateTime.getTime()/1000);
		}
    }
    
	/*
	@testcaseID a1DB00000002nb4
	@Hierarchy GUS.Releases page.Automated Release Stamping
	@Expected Results Appplications show on release page
	 * Test insertion of Release when its Application__c was created without an Application_Type__c.
	 * @author snahm
	 * @userstory a07B0000000MUaj
	 **/
    static testMethod void testApplicationNullAppType() {	    
        
    	final Integer TEST_DURATION = 30;		// Minutes

        ADM_Application__c app = ADM_Application.createTestApplication();
		/* DEBUG ON */ System.debug('testApplicationNullAppType: app=' + app);	/* DEBUG */
		ADM_Release__c rel = ADM_Release.createTestRelease('Test Release 123', app);
		rel.Release_Date__c = Datetime.now();
		rel.Planned_Duration__c = TEST_DURATION;			
		/* DEBUG ON */  System.debug('testApplicationNullAppType: about to update rel=' + rel); /* DEBUG */      
        Database.update(rel);
   
        rel = [select Application__c from ADM_Release__c where Id =: rel.id];
        /* DEBUG ON */  System.debug('testApplicationNullAppType: after test 1 release=' + rel); /* DEBUG */
        System.Assert(rel.Application__c == app.Id, 
        	'testApplicationNullAppType: Application__c field not correctly set on Insert. Is ' + 
        	rel.Application__c + ' but should be ' + app.Id);
        	
		List<Event> relEvent = ADM_Release.getEventsForRelease(rel);
		/* DEBUG ON */  System.Debug('testApplicationNullAppType: After rel insert - Event=' + relEvent);		/* DEBUG */
		// There should be one event
		if (relEvent != null) {
			System.Assert(relEvent.size() == 1, 'testApplicationNullAppType: Wrong number (not 1) of events returned: ' + relEvent.size());    	
			// Note: Event does not preserve the milliseconds, so compare the seconds		
			System.assert(relEvent[0].Location.equals(app.Name), 
				'testApplicationNullAppType: Calendar Event Location is not correct. Should be "' + app.Name + '" but is "' + relEvent[0].Location + '"');
    	}
    }
    
    /**
	 * Test validation rule for Deployment_Instances__c, implemented with a complex REGEX.
	 * @author snahm
	 * @userstory a07B0000000VhsWIAS
	 **/
    static testMethod void testDeploymentInstanceValidation() {	    

		List<String> GOOD_INSTANCE_LIST = new List<String> {
			'CS2',						// GOOD_ONE_INSTANCE
			'SR12 AP11',				// GOOD_TWO_INSTANCES
			'GS0 SR1 CS1 CS2 CS3 CS4 CS7 CS8 CS9 CS10 CS11 CS12 CS13 CS14 CS15 CS16 CS17 CS18 CS19 SR2 CS5 CS6 EU1 EU0 EU2 EU3 NA0 NA1 NA2 NA3 NA4 NA5 NA6 NA7 NA8 NA9 NA10 NA11 NA12 NA13 NA14 NA15 NA16 AP0 AP1'
										// GOOD_MULTIPLE_INSTANCES		
		};

		List<String> BAD_INSTANCE_LIST = new List<String>{ 
			'CS9,CS10,CS11,CS12',		// BAD_COMMAS
    		'eu2 EU3 NA0',				// BAD_LOWERCASE
			'GS0 SR1 CS1  CS2 CS3',		// BAD_EXCESS_SPACES
			'GS0SR1 CS1 CS2 CS3',		// BAD_NO_SPACE
			'GS0	SR1	CS1	CS2 CS3',	// BAD_TABS
			'AP123'						// BAD_DIGITS
		};
        
        /*
         * NOTE: createTestRelease() creates the release record with a null Deployment_Instance__c
         * field, so that case is tested implicitly in the successful creation of the record.
         */
		ADM_Release__c rel = ADM_Release.createTestRelease();
		System.Assert(rel != null && rel.id != null, 'testDeploymentInstanceValidation: Failed to create Release record with empty Deployment Instance field.');
		
		for (String instance : GOOD_INSTANCE_LIST) {
			rel.Deployment_Instances__c = instance;
			try {
				Database.update(rel);
			} catch (DmlException e) {
				System.assert(false, 'testDeploymentInstanceValidation: Valid value for Deployment Instance, "' +
					instance + '" encountered a database exception: ' + e);
			}
		}
		
		for (String instance : BAD_INSTANCE_LIST) {
			rel.Deployment_Instances__c = instance;
			try {
				Database.update(rel);
				System.assert(false, 'testDeploymentInstanceValidation: Invalid value for Deployment Instance, "' +
					instance + '" was entered without validation rule exception');
			} catch (DmlException e) {
            //Assert Error Message
            	System.assert(e.getDmlStatusCode(0).contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
            		'Unexpected exception encountered when inserting invalid value for Deployment Instance, "' +
					instance + '" Expected FIELD_CUSTOM_VALIDATION_EXCEPTION, but was: ' + e );
			}
		}
    }        
}