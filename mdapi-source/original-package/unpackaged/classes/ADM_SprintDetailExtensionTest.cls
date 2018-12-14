@isTest
public class ADM_SprintDetailExtensionTest {

     @isTest(SeeAllData=true)
    static void testensurePushTopics() {

        ApexPages.StandardController stdControl ;
       ADM_SprintDetailExtension sde = new ADM_SprintDetailExtension(stdControl);
        sde.ensurePushTopics();
        List<PushTopic> pushTopics = [select Name, Query, ApiVersion, NotifyForOperations, NotifyForFields from PushTopic];
        System.assert(pushTopics.size() > 1);

    }

    @isTest
    static void testgetCurrentUserLightningDesktopPreference() {
       Boolean lex = true;

       ApexPages.StandardController stdControl ;
       ADM_SprintDetailExtension sde = new ADM_SprintDetailExtension(stdControl);
        ADM_ConstantsSingleton  single = ADM_ConstantsSingleton.getInstance();
       single.setUserLightningExperiencePreferred(lex);
       System.assert(sde.getCurrentUserLightningDesktopPreference(), 'User Experience should have been set to LEX view');


    }

}