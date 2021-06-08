trigger CryptoCurrencyTrigger on CryptoCurrency__c (before insert, after insert) {
    fflib_SObjectDomain.triggerHandler(CryptoCurrencies.class);
}