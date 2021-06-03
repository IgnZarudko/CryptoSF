trigger CryptoCurrencyTrigger on CryptoCurrency__c (before insert) {
    fflib_SObjectDomain.triggerHandler(CryptoCurrencies.class);
}