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
        try {
            CryptoCurrencyService.updateCryptoCurrenciesBySymbols(getSymbolSet());        
        }
        catch (CalloutException e) {
            for (CryptoCurrency__c cryptoCurrency: (List<CryptoCurrency__c>) Records) {
                cryptoCurrency.addError(e.getStackTraceString());
            }
        }
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

    private Set<String> getSymbolSet(List<CryptoCurrency__c> cryptoCurrencies) {
        return getSymbolMap(cryptoCurrencies).keySet();
    }

    private Map<string, CryptoCurrency__c> getSymbolMap() {
        return getSymbolMap((List<CryptoCurrency__c>) Records);
    }

    private Map<String, CryptoCurrency__c> getSymbolMap(List<CryptoCurrency__c> cryptoCurrencies) {
        Map<String, CryptoCurrency__c> symbolMap = new Map<String, CryptoCurrency__c>();

        for(CryptoCurrency__c cryptoCurrency: cryptoCurrencies) {
            //Check elements of new list, 
            //If there are duplicates not in system, but in insert data
            if (symbolMap.get(cryptoCurrency.Symbol__c) == null) {
                cryptoCurrency.addError('Duplicate symbols in insert list');
            }
            else {
                symbolMap.put(cryptoCurrency.Symbol__c, cryptoCurrency);
            }
        }

        return symbolMap;
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CryptoCurrencies(sObjectList);
        }
    }
}
