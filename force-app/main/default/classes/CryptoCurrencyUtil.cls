public with sharing class CryptoCurrencyUtil {
    //Get Symbol Set of incoming crypto currencies
    public static Set<String> getSymbolSet(List<CryptoCurrency__c> cryptoCurrencies) {
        return getSymbolMap(cryptoCurrencies).keySet();
    }

    //Get Map with key Symbol and value CryptoCurrency of incoming crypto currencies
    public static Map<String, CryptoCurrency__c> getSymbolMap(List<CryptoCurrency__c> cryptoCurrencies) {
        Map<String, CryptoCurrency__c> symbolMap = new Map<String, CryptoCurrency__c>();

        for(CryptoCurrency__c cryptoCurrency: cryptoCurrencies) {
            //Check elements of new list, 
            //If there are duplicates not in system, but in insert data
            //And current element has no errors
            if (symbolMap.get(cryptoCurrency.Symbol__c) == null && !cryptoCurrency.hasErrors()) {
                symbolMap.put(cryptoCurrency.Symbol__c, cryptoCurrency);
            }
        }

        return symbolMap;
    }
}
