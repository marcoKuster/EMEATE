@IsTest
private class ADM_StringHolderTest{
    static testmethod void testStringHolder() {
        ADM_StringHolder sh = new ADM_StringHolder();
        sh.theString = 'it';
        System.assertEquals('it', sh.theString, 'theString should be what we set it to');
    }
}