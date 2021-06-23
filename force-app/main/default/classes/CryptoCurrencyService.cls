public with sharing class CryptoCurrencyService {

    private static String LATEST_QUOTES_URL = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest';

    private static String ACCESS_TOKEN_KEY = 'X-CMC_PRO_API_KEY';
    private static String ACCESS_TOKEN = '34ed1f2a-e39f-42d6-aeac-e4e0c1d46e59';


    @future (callout=true)
    public static void updateCryptoCurrenciesBySymbolsAsync(Set<String> symbolSet) {
        updateCryptoCurrenciesBySymbols(symbolSet);
    }

    public static void updateCryptoCurrenciesBySymbols(Set<String> symbolSet) {
        //Create a Selector 
        //Select CryptoCurrency list by symbols
        CryptoCurrenciesSelector cryptoSelector = new CryptoCurrenciesSelector();
        List<CryptoCurrency__c> cryptoCurrencies = cryptoSelector.selectBySymbol(symbolSet);

        //Create Unit of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> {CryptoCurrency__c.getSObjectType()}
        );

        //Make a callout
        HttpResponse res = getCryptoCurrencyDataBySymbols(symbolSet);

        if (res.getStatusCode() == 200) {
            Map<String,Object> responseCryptoMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

            //Work with map to update created records
            responseCryptoMap = (Map<String, Object>) responseCryptoMap.get('data');
            
            //Update Crypto Currencies using response
            updateCryptoCurrencies(cryptoCurrencies, responseCryptoMap, uow);   
        }
        //If response is bad, pass Callout Error
        else {
            for (CryptoCurrency__c cryptoCurrency: cryptoCurrencies) {
                cryptoCurrency.Name__c = 'Callout Error';
                uow.registerDirty(cryptoCurrency);
            }
        }
        
        //Update currencies
        uow.commitWork();
    }

    private static void updateCryptoCurrencies(List<CryptoCurrency__c> oldCryptoCurrencies, Map<String, Object> responseCryptoMap, fflib_SObjectUnitOfWork uow) {
        for (CryptoCurrency__c cryptoCurrency: oldCryptoCurrencies) {

            //Get JSON Object with data
            Object cryptoCurrencyJson = responseCryptoMap.get(cryptoCurrency.Symbol__c);
            //If There is no such element, put error message
            if (cryptoCurrencyJson == null) {
                cryptoCurrency.Name__c = 'Invalid Symbol';
                // cryptoCurrency.Symbol__c = cryptoCurrency.Symbol__c + ' - error';
            }
            //Else try to parse
            else {
                //Get JSON String of current currency
                String cryptoCurrencyString = JSON.serialize(cryptoCurrencyJson);
                CryptoCurrencyModel model;
                try {
                    //Try to parse it to model
                    model = CryptoCurrencyModel.parse(cryptoCurrencyString);
                    cryptoCurrency = fillCryptoCurrencyFromModel(cryptoCurrency, model);
                }
                //Pass parse error, if couldn't parse JSON
                catch(JSONException e) {
                    System.debug('Exception when parsing CryptoCurrency');
                    System.debug(e.getStackTraceString());
                    cryptoCurrency.Name__c = 'Parse Error';
                    // cryptoCurrency.Symbol__c = cryptoCurrency.Symbol__c + ' - error';
                }
            }
            uow.registerDirty(cryptoCurrency);
        }
    }

    private static HttpResponse getCryptoCurrencyDataBySymbols(Set<String> symbolSet) {
        String commaSeparatedSymbols = symbolSet
                                        .toString()
                                        .replace('{', '')
                                        .replace('}', '')
                                        .replace(' ', '');

        String parametrizedUrl = LATEST_QUOTES_URL + '?symbol=' + commaSeparatedSymbols + '&skip_invalid=true';
        
        HttpRequest req = new HttpRequest();
        
        req.setMethod('GET');
        req.setEndpoint(parametrizedUrl);
        req.setHeader(ACCESS_TOKEN_KEY, ACCESS_TOKEN);
        req.setHeader('Accept', 'application/json');

        return new Http().send(req);
    }

    private static CryptoCurrency__c fillCryptoCurrencyFromModel(CryptoCurrency__c cryptoCurrency, CryptoCurrencyModel model) {
        System.debug(cryptoCurrency.Symbol__c);
        System.debug(model == null);

        cryptoCurrency.Name__c = model.name;
        cryptoCurrency.Market_Cap__c = model.quote.USD.market_cap;
        cryptoCurrency.Price__c = model.quote.USD.price;
        cryptoCurrency.Volume__c = model.quote.USD.volume_24h;

        return cryptoCurrency;
    }

}
