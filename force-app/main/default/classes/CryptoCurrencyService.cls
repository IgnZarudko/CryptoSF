public with sharing class CryptoCurrencyService {

    private static String LATEST_QUOTES_URL = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest';

    private static String ACCESS_TOKEN_KEY = 'X-CMC_PRO_API_KEY';
    private static String ACCESS_TOKEN = '34ed1f2a-e39f-42d6-aeac-e4e0c1d46e59';

    @future (callout=true)
    public static void updateCryptoCurrenciesBySymbols(Set<String> symbolSet) {

        CryptoCurrenciesSelector cryptoSelector = new CryptoCurrenciesSelector();

        List<CryptoCurrency__c> cryptoCurrencies = cryptoSelector.selectBySymbol(symbolSet);

        String commaSeparatedSymbols = symbolSet
                                        .toString()
                                        .replace('{', '')
                                        .replace('}', '')
                                        .replace(' ', '');

        String parametrizedUrl = LATEST_QUOTES_URL + '?symbol=' + commaSeparatedSymbols + '&skip_invalid=true';
        
        System.debug('URL: ' + parametrizedUrl);

        HttpRequest req = new HttpRequest();
        
        req.setMethod('GET');
        req.setEndpoint(parametrizedUrl);
        req.setHeader(ACCESS_TOKEN_KEY, ACCESS_TOKEN);
        req.setHeader('Accept', 'application/json');

        HttpResponse res = new Http().send(req);

        System.debug('Response: ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());

        //think about is it good to leave response code here
        if (res.getStatusCode() == 200) {
            Map<String,Object> responseCryptoMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

            //Work with map to update created records
            responseCryptoMap = (Map<String, Object>) responseCryptoMap.get('data');

            for (CryptoCurrency__c cryptoCurrency: cryptoCurrencies) {
                Object cryptoCurrencyJson = responseCryptoMap.get(cryptoCurrency.Symbol__c);
                if (cryptoCurrencyJson == null) {
                    cryptoCurrency.addError('There is no such CryptoCurrency');
                }
                else {
                    String cryptoCurrencyString = JSON.serialize(cryptoCurrencyJson);
                    CryptoCurrencyModel model = CryptoCurrencyModel.parse(cryptoCurrencyString);
                    cryptoCurrency = fillCryptoCurrencyFromModel(cryptoCurrency, model);
                }
            }

            //Update currencies without errors
            Database.update(cryptoCurrencies, false);
        }
        else {
            throw new CalloutException('Response were not received, code ' + res.getStatusCode());
        }
    }

    private static CryptoCurrency__c fillCryptoCurrencyFromModel(CryptoCurrency__c cryptoCurrency, CryptoCurrencyModel model) {
        System.debug(cryptoCurrency.Symbol__c);
        System.debug(model == null);

        cryptoCurrency.Name = model.name;
        cryptoCurrency.Market_Cap__c = model.quote.USD.market_cap;
        cryptoCurrency.Price__c = model.quote.USD.price;
        cryptoCurrency.Volume__c = model.quote.USD.volume_24h;

        return cryptoCurrency;
    }

}
