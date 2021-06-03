public with sharing class CryptoCurrencies extends fflib_SObjectDomain {
    public CryptoCurrencies(List<CryptoCurrency__c> cryptoCurrencies) {
        super(cryptoCurrencies);
    }

    public override void onBeforeInsert() {
        
        Set<String> cryptoSymbolSet = new Set<String>();

        for (CryptoCurrency__c cryptoCurrency : (List<CryptoCurrency__c>) Records) {
            cryptoSymbolSet.add(cryptoCurrency.Symbol__c);
        }

        //TODO: collect Set with Symbols already exist

        Map<String, Object> cryptoCurrencyMap = new Map<String, Object>();

        try {
            cryptoCurrencyMap = getCryptoCurrencyMap(cryptoSymbolSet);
        }
        catch (CalloutException e) {
            for (CryptoCurrency__c cryptoCurrency : (List<CryptoCurrency__c>) Records) {
                cryptoCurrency.addError(e.getMessage());
            }
        }

        for (CryptoCurrency__c cryptoCurrency : (List<CryptoCurrency__c>) Records) {
            //check if this symbol already exists before
            CryptoCurrencyModel model = CryptoCurrencyModel.parse(JSON.serialize(cryptoCurrencyMap.get(cryptoCurrency.Symbol__c)));
            System.debug(model == null);
            cryptoCurrency = fillCryptoCurrencyFromModel(cryptoCurrency, model);
        }
    }

    private Map<String, Object> getCryptoCurrencyMap(Set<String> cryptoSymbolSet) {
        System.debug('trying to make callout');

        HttpResponse res = CryptoCurrencyService.makeGetCalloutBySymbols(cryptoSymbolSet);
        //think about is it good to leave response code here
        if (res.getStatusCode() == 200) {
            Map<String,Object> responseCryptoMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

            return (Map<String,Object>) responseCryptoMap.get('data');
        }
        else {
            throw new CalloutException('Response were not received, code ' + res.getStatusCode());
        }
    }

    private CryptoCurrency__c fillCryptoCurrencyFromModel(CryptoCurrency__c cryptoCurrency, CryptoCurrencyModel model) {
        System.debug(cryptoCurrency.Symbol__c);
        System.debug(model == null);

        cryptoCurrency.Name = model.name;
        cryptoCurrency.Market_Cap__c = model.quote.USD.market_cap;
        cryptoCurrency.Price__c = model.quote.USD.price;
        cryptoCurrency.Volume__c = model.quote.USD.volume_24h;

        return cryptoCurrency;
    }


    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CryptoCurrencies(sObjectList);
        }
    }
}
