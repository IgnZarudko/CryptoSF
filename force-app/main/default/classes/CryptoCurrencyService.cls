public with sharing class CryptoCurrencyService {

    private static String LATEST_QUOTES_URL = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest';

    private static String ACCESS_TOKEN_KEY = 'X-CMC_PRO_API_KEY';
    private static String ACCESS_TOKEN = '34ed1f2a-e39f-42d6-aeac-e4e0c1d46e59';

    @future
    public static HttpResponse makeGetCalloutBySymbols(Set<String> symbols) {
        String commaSeparatedSymbols = symbols
                                        .toString()
                                        .replace('{', '')
                                        .replace('}', '')
                                        .replace(' ', '');

        String parametrizedUrl = LATEST_QUOTES_URL + '?symbol=' + commaSeparatedSymbols;
        
        System.debug('URL: ' + parametrizedUrl);

        HttpRequest req = new HttpRequest();
        
        req.setMethod('GET');
        req.setEndpoint(parametrizedUrl);
        req.setHeader(ACCESS_TOKEN_KEY, ACCESS_TOKEN);
        req.setHeader('Accept', 'application/json');

        HttpResponse res = new Http().send(req);
        System.debug('Response: ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());

        return res;
    }
}
