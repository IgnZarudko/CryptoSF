public with sharing class CryptoCurrencies extends fflib_SObjectDomain {
    public CryptoCurrencies(List<CryptoCurrency__c> cryptoCurrencies) {
        super(cryptoCurrencies);
    }

    public override void onBeforeInsert() {
        //Check that some of symbols already exist
        checkAlreadyExistBySymbol();
    }

    public override void onAfterInsert() {
        //Make a callout and update
        //If symbol was not found, add error
        System.debug('After insert call');
        CryptoCurrencyService.updateCryptoCurrenciesBySymbols(getSymbolSet());        
    }

    private void checkAlreadyExistBySymbol() {
        CryptoCurrenciesSelector cryptoSelector = new CryptoCurrenciesSelector();

        //Get Symbol Set of records to be inserted
        Set<String> symbolSet = getSymbolSet();

        //Get Currencies with this Symbols
        List<CryptoCurrency__c> alreadyExistingCurrencies = cryptoSelector.selectBySymbol(symbolSet);

        //Get Symbol Set of symbols that exist and should be added
        Set<String> existingSymbolSet = getSymbolSet(alreadyExistingCurrencies);
        
        //Add error for currencies that have duplicate symbol
        for (CryptoCurrency__c cryptoCurrency : (List<CryptoCurrency__c>) Records) {
            if (existingSymbolSet.contains(cryptoCurrency.Symbol__c)) {
                cryptoCurrency.addError('CryptoCurrency with this symbol already exists');
            } 
        }
    }

    private Set<String> getSymbolSet() {
        return getSymbolSet((List<CryptoCurrency__c>) Records);
    }

    private Set<String> getSymbolSet(List<CryptoCurrency__c> currencies) {
        Set<String> symbolSet = new Set<String>();
        
        for(CryptoCurrency__c cryptoCurrency: currencies) {
            //Check elements of new list, 
            //If there are duplicates not in system, but in insert data
            if (symbolSet.contains(cryptoCurrency.Symbol__c)) {
                cryptoCurrency.addError('Duplicate symbols in insert list');
            }
            symbolSet.add(cryptoCurrency.Symbol__c);
        }

        return symbolSet;
    }


    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CryptoCurrencies(sObjectList);
        }
    }
}
