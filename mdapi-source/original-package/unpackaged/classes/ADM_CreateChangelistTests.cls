/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ADM_CreateChangelistTests {
    static final String comments = 'comments';
    static String releaseName = 'uber kewl release';
    static final String changelistNumber = '99999999';
    static final String RELEASE_2_USE = ADM_ReleaseDetailAccumulator.RELEASE_2_USE;
    static final String none = '--None--';

    static Boolean hasRelease(String rName) {
        List<ADM_Release__c> els = [select Id from ADM_Release__c where Name = : rName];

        if(els == null || els.size() == 0) {
          return false;
        }
        return true;
    }

    static ADM_Released_In__c getReleaseStamp(String workId, String rName) {
      List<ADM_Released_In__c> els = new List<ADM_Released_In__c>();
      ADM_Released_In__c el;
      els = [select Reverted__c from ADM_Released_In__c where Work__c =: workId and Release__r.Name = : rName];
      if(els.size() > 0) {
        return els.get(0);
      } else {
        return el;
      }
    }

    testMethod static void createChangelistWithTaskWithReleaseStampReverted(){
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();

      ADM_Task__c task = new ADM_Task__c();
      task.Assigned_To__c = work.Assignee__c;
      task.Actual_Hours__c = 1.0;
      task.Comments__c = comments;
      task.Hours_Remaining__c = task.Actual_Hours__c;
      task.Work__c = work.Id;
      task.Subject__c = task.Comments__c;
      insert task;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';
      describe += '        @revert@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = releaseName;
      pc.Work__c = work.Id;
      pc.Task__c = task.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(work.Id, releaseName);

      System.assertEquals(task.Id, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
      System.assertEquals(true, hasRelease(releaseName));
      System.assertNotEquals(null, stamp);
      System.assertEquals(true, stamp.Reverted__c);

      delete stamp;
    }

    testMethod static void createChangelistWithoutTaskWithReleaseStampReverted(){
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';
      describe += '        @revert@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = releaseName;
      pc.Work__c = work.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      System.assertEquals(1, cls.size());
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(work.Id, releaseName);

      System.assertEquals(null, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
      System.assertEquals(true, hasRelease(releaseName));
      System.assertNotEquals(null, stamp);
      System.assertEquals(true, stamp.Reverted__c);

      delete stamp;
    }

    testMethod static void createChangelistWithTaskWithReleaseStampFromRelease2UseWithReleaseReverted() {
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();

      ADM_Task__c task = new ADM_Task__c();
      task.Assigned_To__c = work.Assignee__c;
      task.Actual_Hours__c = 1.0;
      task.Comments__c = comments;
      task.Hours_Remaining__c = task.Actual_Hours__c;
      task.Work__c = work.Id;
      task.Subject__c = task.Comments__c;
      insert task;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';
      describe += '        @revert@';
      describe += '\n\n' + RELEASE_2_USE + releaseName + '2@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = releaseName;
      pc.Work__c = work.Id;
      pc.Task__c = task.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(work.Id, releaseName + '2');

      System.assertEquals(task.Id, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
      System.assertEquals(true, hasRelease(releaseName + '2'));
      System.assertNotEquals(null, stamp);
      System.assertEquals(true, stamp.Reverted__c);

      delete stamp;
    }

    testMethod static void createChangelistWithTaskWithReleaseStampFromRelease2UseWithoutReleaseReverted() {
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();

      ADM_Task__c task = new ADM_Task__c();
      task.Assigned_To__c = work.Assignee__c;
      task.Actual_Hours__c = 1.0;
      task.Comments__c = comments;
      task.Hours_Remaining__c = task.Actual_Hours__c;
      task.Work__c = work.Id;
      task.Subject__c = task.Comments__c;
      insert task;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';
      describe += '        @revert@';
      describe += '\n\n' + RELEASE_2_USE + releaseName + '2@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = none;
      pc.Work__c = work.Id;
      pc.Task__c = task.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(work.Id, releaseName + '2');

      System.assertEquals(task.Id, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
      System.assertEquals(true, hasRelease(releaseName + '2'));
      System.assertNotEquals(null, stamp);
      System.assertEquals(true, stamp.Reverted__c);

      delete stamp;
    }

    testMethod static void createChangelistWithTaskWithReleaseStamp(){
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();
      String workId = work.Id;

      ADM_Task__c task = new ADM_Task__c();
      task.Assigned_To__c = work.Assignee__c;
      task.Actual_Hours__c = 1.0;
      task.Comments__c = comments;
      task.Hours_Remaining__c = task.Actual_Hours__c;
      task.Work__c = work.Id;
      task.Subject__c = task.Comments__c;
      insert task;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = releaseName;
      pc.Work__c = work.Id;
      pc.Task__c = task.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(workId, releaseName);

      System.assertEquals(task.Id, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
      System.assertEquals(true, hasRelease(releaseName));
      System.assertNotEquals(null, stamp);
      System.assertNotEquals(true, stamp.Reverted__c);

      delete stamp;
    }

    testMethod static void createChangelistWithoutTaskWithReleaseStamp(){
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();
      String workId = work.Id;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = releaseName;
      pc.Work__c = work.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      System.assertEquals(1, cls.size());
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(workId, releaseName);

      System.assertEquals(null, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
      System.assertEquals(true, hasRelease(releaseName));
      System.assertNotEquals(null, stamp);
      System.assertEquals(false, stamp.Reverted__c);

      delete stamp;
    }


    testMethod static void createChangelistWithTaskWithoutReleaseStamp(){
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();
      String workId = work.Id;

      ADM_Task__c task = new ADM_Task__c();
      task.Assigned_To__c = work.Assignee__c;
      task.Actual_Hours__c = 1.0;
      task.Comments__c = comments;
      task.Hours_Remaining__c = task.Actual_Hours__c;
      task.Work__c = work.Id;
      task.Subject__c = task.Comments__c;
      insert task;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = '--None--';
      pc.Work__c = work.Id;
      pc.Task__c = task.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(workId, releaseName);

      System.assertEquals(task.Id, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
    }


    testMethod static void verifyChangelistCount(){
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();
      String workId = work.Id;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = '--None--';
      pc.Work__c = work.Id;
      pcs.add(pc);

      insert pcs;
      ADM_Work__c count = [select Number_of_Change_Lists__c from ADM_Work__c where Id = : workId];
      System.assertEquals(1, count.Number_of_Change_Lists__c);
    }

    testMethod static void createChangelistWithoutTaskWithoutReleaseStamp(){
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();
      String workId = work.Id;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Work__c = work.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      System.assertEquals(1, cls.size());
      ADM_Change_List__c cl = cls.get(0);

      System.assertEquals(null, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
    }

    testMethod static void createChangelistWithTaskWithReleaseStampFromRelease2UseWithRelease() {
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();
      String workId = work.Id;

      ADM_Task__c task = new ADM_Task__c();
      task.Assigned_To__c = work.Assignee__c;
      task.Actual_Hours__c = 1.0;
      task.Comments__c = comments;
      task.Hours_Remaining__c = task.Actual_Hours__c;
      task.Work__c = work.Id;
      task.Subject__c = task.Comments__c;
      insert task;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';
      describe += '\n\n' + RELEASE_2_USE + releaseName + '2@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = releaseName;
      pc.Work__c = work.Id;
      pc.Task__c = task.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(workId, releaseName + '2');

      System.assertEquals(task.Id, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
      System.assertEquals(true, hasRelease(releaseName + '2'));
      System.assertEquals(false,stamp.Reverted__c);

      delete stamp;
    }

    testMethod static void createChangelistWithTaskWithReleaseStampFromRelease2UseWithoutRelease() {
      ADM_ChangelistDetailAccumulator cld = new ADM_ChangelistDetailAccumulator();
      List<ADM_Perforce_Connector__c> pcs = new List<ADM_Perforce_Connector__c>();
      ADM_Perforce_Connector__c pc = new ADM_Perforce_Connector__c();
      List<ADM_Change_List__c> cls = new List<ADM_Change_List__c>();

      Test.startTest();
          ADM_Work__c work = ADM_Work.createTestBug();
      Test.stopTest();
      String workId = work.Id;

      ADM_Task__c task = new ADM_Task__c();
      task.Assigned_To__c = work.Assignee__c;
      task.Actual_Hours__c = 1.0;
      task.Comments__c = comments;
      task.Hours_Remaining__c = task.Actual_Hours__c;
      task.Work__c = work.Id;
      task.Subject__c = task.Comments__c;
      insert task;

      String describe = '';
      describe += '        Testing new ARS';
      describe += '        ' + ADM_WorkUtils.GUS_URL + work.Id;
      describe += '        @rev jhatton@';
      describe += '\n\n' + RELEASE_2_USE + releaseName + '2@';

      pc.Describe__c = '# A Perforce Change Specification.\n##  Change:      The change number. \'new\' on a new changelist.\n#  Date:        The date this specification was last modified.#  Client:      The client on which the changelist was created.  Read-only.#  User:        The user who created the changelist.\n#  Status:      Either \'pending\' or \'submitted\'. Read-only.\n#  Description: Comments about the changelist.  Required.\n#  Jobs:        What opened jobs are to be closed by this changelist.\n#               You may delete jobs from this list.  (New changelists only.)\n#  Files:       What opened files from the default changelist are to be added\n#               to this changelist.  You may delete files from this list.\n#               (New changelists only.)\n\nChange: 921073\n\nDate:   2009/02/25 10:35:33\n\nClient: alwilliams-wsr\n\nUser:   alexis.williams\n\nStatus: pending\n\nDescription:\n' + describe;
      pc.Changelist__c = changelistNumber;
      pc.Release__c = none;
      pc.Work__c = work.Id;
      pc.Task__c = task.Id;
      pcs.add(pc);

      insert pcs;
      cls = [select Id, Task__c, Comments__c from ADM_Change_List__c where Work__c = : work.Id];
      ADM_Change_List__c cl = cls.get(0);
      ADM_Released_In__c stamp = getReleaseStamp(workId, releaseName + '2');

      System.assertEquals(task.Id, cl.Task__c);
      System.assertEquals(true, cl.Comments__c.contains(work.Id));
      System.assertEquals(true, hasRelease(releaseName + '2'));
      System.assertEquals(false, stamp.Reverted__c);

      delete stamp;
    }
}