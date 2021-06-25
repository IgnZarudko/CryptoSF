@isTest
public with sharing class CryptoCurrencyTriggerTest {

    @isTest
    public static void insertCryptoCurrencySuccess_Test() {
        Test.setMock(HttpCalloutMock.class, getSuccessMock());

        CryptoCurrency__c cryptoCurrency = new CryptoCurrency__c(Symbol__c = 'TEST');

        Test.startTest();

            insert cryptoCurrency;

        Test.stopTest();

        cryptoCurrency = [SELECT Id, Name__c, Price__c, Market_Cap__c, Volume__c FROM CryptoCurrency__c WHERE Id = :cryptoCurrency.Id];

        System.assertEquals('Test Crypto', cryptoCurrency.Name__c);
        System.assertEquals(300, cryptoCurrency.Price__c);
        System.assertEquals(123456789, cryptoCurrency.Volume__c);
        System.assertEquals(987654321, cryptoCurrency.Market_Cap__c);
    }

    @isTest
    public static void insertCryptoCurrencyWithAlreadyExistingSymbol_Test() {
        Test.setMock(HttpCalloutMock.class, getSuccessMock());

        CryptoCurrency__c cryptoCurrency = new CryptoCurrency__c(Symbol__c = 'TEST');

        insert cryptoCurrency;

        CryptoCurrency__c cryptoDuplicate = new CryptoCurrency__c(Symbol__c = 'TEST');

        Test.startTest();

            Database.SaveResult result = Database.insert(cryptoDuplicate, false);

        Test.stopTest();

        System.assert(!result.success);
        System.assertEquals(1, result.getErrors().size());
    }

    @isTest
    public static void insertCryptoCurrencyBadResponseBody_Test() {
        Test.setMock(HttpCalloutMock.class, getBadResponseBodyMock());

        CryptoCurrency__c cryptoCurrency = new CryptoCurrency__c(Symbol__c = 'TEST');

        Test.startTest();
            
            insert cryptoCurrency;

        Test.stopTest();

        cryptoCurrency = [SELECT Id, Name__c, Symbol__c FROM CryptoCurrency__c WHERE Id = :cryptoCurrency.Id];

        System.assertEquals('Parse Error', cryptoCurrency.Name__c);
        System.assertEquals('TEST - error', cryptoCurrency.Symbol__c);
    }    

    @isTest
    public static void insertCryptoCurrencyBadResponseCode_Test() {
        Test.setMock(HttpCalloutMock.class, getBadResponseCodeMock());

        CryptoCurrency__c cryptoCurrency = new CryptoCurrency__c(Symbol__c = 'TEST');

        Test.startTest();
            
            insert cryptoCurrency;

        Test.stopTest();

        cryptoCurrency = [SELECT Id, Name__c, Symbol__c FROM CryptoCurrency__c WHERE Id = :cryptoCurrency.Id];

        System.assertEquals('Callout Error', cryptoCurrency.Name__c);
    }

    private static StaticResourceCalloutMock getSuccessMock() {
        return getMockWithBody(200, 'CryptoCurrencyResponseBody');
    }

    private static StaticResourceCalloutMock getBadResponseCodeMock() {
        return getMockWithBody(404, 'CryptoCurrencyResponseBody');
    }

    private static StaticResourceCalloutMock getBadResponseBodyMock() {
        return getMockWithBody(200, 'CryptoCurrencyBadResponseBody');
    }

    private static StaticResourceCalloutMock getMockWithBody(Integer responseCode, String staticResourceName) {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(staticResourceName);
        mock.setStatusCode(responseCode);
        mock.setHeader('Content-Type','application/json');

        return mock;
    }
}
