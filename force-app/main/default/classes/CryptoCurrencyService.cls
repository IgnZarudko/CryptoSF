public with sharing class CryptoCurrencyService {

    private static String LATEST_QUOTES_URL = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest';

    private static String ACCESS_TOKEN_KEY = 'X-CMC_PRO_API_KEY';
    private static String ACCESS_TOKEN = '34ed1f2a-e39f-42d6-aeac-e4e0c1d46e59';

    public static void validateDuplicateSymbol(List<CryptoCurrency__c> newCryptoCurrencies) {
        CryptoCurrencySelector selector = new CryptoCurrencySelector();

        //Get Symbol Set of records to be inserted
        Set<String> symbolSet = CryptoCurrencyUtil.getSymbolSet(newCryptoCurrencies);

        //Get Currencies with this Symbols
        List<CryptoCurrency__c> existingCryptoCurrencies = selector.selectBySymbol(symbolSet);

        //Get Symbol Set of symbols that exist and should be added
        Set<String> existingSymbolSet = CryptoCurrencyUtil.getSymbolSet(existingCryptoCurrencies);
        
        //Add error for currencies that have duplicate symbol
        for (CryptoCurrency__c cryptoCurrency : newCryptoCurrencies) {
            if (existingSymbolSet.contains(cryptoCurrency.Symbol__c)) {
                cryptoCurrency.addError('CryptoCurrency with this symbol already exists');
            } 
        }
    }

    @future (callout=true)
    public static void updateCryptoCurrenciesBySymbolsAsync(Set<String> symbolSet) {
        CryptoCurrencySelector selector = new CryptoCurrencySelector();
        
        List<CryptoCurrency__c> records = selector.selectBySymbol(symbolSet);

        updateCryptoCurrencies(records);
    }

    public static void updateCryptoCurrencies(List<CryptoCurrency__c> records) {
        
        List<CryptoCurrency__c> cryptoCurrencies = getValidCryptoCurrencies(records);

        Set<String> symbolSet = CryptoCurrencyUtil.getSymbolSet(cryptoCurrencies);

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
            registerCryptoCurrenciesUpdates(cryptoCurrencies, responseCryptoMap, uow);   
        }
        //If response is bad, pass Callout Error
        else {
            for (CryptoCurrency__c cryptoCurrency: cryptoCurrencies) {
                cryptoCurrency.Name__c = 'Callout Error';
                uow.registerDirty(cryptoCurrency);
            }
        }
        
        //Commit updates
        uow.commitWork();
    }

    //Get list of crypto currencies which have no errors
    public static List<CryptoCurrency__c> getValidCryptoCurrencies(List<CryptoCurrency__c> allCryptoCurrencies) {
        List<CryptoCurrency__c> cryptoCurrencies = new List<CryptoCurrency__c>();
        
        for(CryptoCurrency__c cryptoCurrency: allCryptoCurrencies) {
            if (!cryptoCurrency.hasErrors()) {
                cryptoCurrencies.add(cryptoCurrency);
            }
        }

        return cryptoCurrencies;
    }

    //Register updates of crypto currencies
    private static void registerCryptoCurrenciesUpdates(List<CryptoCurrency__c> oldCryptoCurrencies, 
                                                            Map<String, Object> responseCryptoMap, 
                                                            fflib_SObjectUnitOfWork uow) {
        for (CryptoCurrency__c cryptoCurrency: oldCryptoCurrencies) {

            //Get JSON Object with data
            Object cryptoCurrencyJson = responseCryptoMap.get(cryptoCurrency.Symbol__c);
            //If There is no such element, put error message
            if (cryptoCurrencyJson == null) {
                cryptoCurrency.Name__c = 'Invalid Symbol';
                cryptoCurrency.Symbol__c = cryptoCurrency.Symbol__c + ' - error';
            }
            //Else try to parse
            else {
                //Get JSON String of current currency
                String cryptoCurrencyString = JSON.serialize(cryptoCurrencyJson);
                CryptoCurrencyWrapper wrapper;
                try {
                    //Try to parse it to wrapper
                    wrapper = CryptoCurrencyWrapper.parse(cryptoCurrencyString);
                    cryptoCurrency = fillCryptoCurrencyFromWrapper(cryptoCurrency, wrapper);
                }
                //Pass parse error, if couldn't parse JSON
                catch(JSONException e) {
                    System.debug('Exception when parsing CryptoCurrency');
                    System.debug(e.getStackTraceString());
                    cryptoCurrency.Name__c = 'Parse Error';
                    cryptoCurrency.Symbol__c = cryptoCurrency.Symbol__c + ' - error';
                }
            }
            //Register CryptoCurrency
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

    private static CryptoCurrency__c fillCryptoCurrencyFromWrapper(CryptoCurrency__c cryptoCurrency, CryptoCurrencyWrapper wrapper) {
        System.debug(cryptoCurrency.Symbol__c);
        System.debug(wrapper == null);

        cryptoCurrency.Name__c = wrapper.name;
        cryptoCurrency.Market_Cap__c = wrapper.quote.USD.market_cap;
        cryptoCurrency.Price__c = wrapper.quote.USD.price;
        cryptoCurrency.Volume__c = wrapper.quote.USD.volume_24h;

        return cryptoCurrency;
    }

}
