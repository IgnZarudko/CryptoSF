@isTest
public with sharing class CryptoCurrencyTriggerTest {

    @isTest
    public static void insertCryptoCurrencyWithAlreadyExistingSymbol_Test() {
        CryptoCurrency__c cryptoCurrency = new CryptoCurrency__c(Name = 'unknown', Symbol__c = 'TEST');

        insert cryptoCurrency;

        CryptoCurrency__c cryptoDuplicate = new CryptoCurrency__c(Name = 'unknown', Symbol__c = 'TEST');

        Test.startTest();

            Database.SaveResult result = Database.insert(cryptoDuplicate, false);

        Test.stopTest();

        System.assert(!result.isSuccess(), 'Operation should not be successful');
        System.assertEquals(1, result.getErrors().size(), 'There are more errors than expected');
    }
}
