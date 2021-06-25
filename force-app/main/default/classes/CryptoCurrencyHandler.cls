public with sharing class CryptoCurrencyHandler extends fflib_SObjectDomain {
    public CryptoCurrencyHandler(List<CryptoCurrency__c> cryptoCurrencies) {
        super(cryptoCurrencies);
    }

    public override void onBeforeInsert() {
        //Check that some of symbols already exist
        CryptoCurrencyService.validateDuplicateSymbol((List<CryptoCurrency__c>) Records);
    }

    public override void onAfterInsert() {
        //Make a callout and update
        //If symbol was not found, add error
        Set<String> symbolSet = CryptoCurrencyUtil.getSymbolSet((List<CryptoCurrency__c>) Records);

        CryptoCurrencyService.updateCryptoCurrenciesBySymbolsAsync(symbolSet);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CryptoCurrencyHandler(sObjectList);
        }
    }

}
