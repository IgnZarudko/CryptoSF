public with sharing class CryptoCurrencies extends fflib_SObjectDomain {
    public CryptoCurrencies(List<CryptoCurrency__c> cryptoCurrencies) {
        super(cryptoCurrencies);
    }

    public override void onBeforeInsert() {
        //check that some of symbols already exist
        checkThatCurrenciesAlreadyExistBySymbol();
    }

    private void checkThatCurrenciesAlreadyExistBySymbol() {
        //Symbol Set of records to be inserted
        Set<String> symbolSet = getSymbolSet((List<CryptoCurrency__c>) Records);

        //Get SymbolSet of symbols that exist and should be added
        List<CryptoCurrency__c> alreadyExistingCurrencies = new CryptoCurrenciesSelector().selectBySymbol(symbolSet);
        Set<String> existingSymbolSet = getSymbolSet(alreadyExistingCurrencies);
        
        //Add error for currencies that have duplicate symbol
        for (CryptoCurrency__c cryptoCurrency : (List<CryptoCurrency__c>) Records) {
            if (existingSymbolSet.contains(cryptoCurrency.Symbol__c)) {
                cryptoCurrency.addError('CryptoCurrency with this symbol already exists');
            } 
        }
    }

    private Set<String> getSymbolSet(List<CryptoCurrency__c> currencies) {
        Set<String> symbolSet = new Set<String>();
        
        for(CryptoCurrency__c cryptoCurrency: currencies) {
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
