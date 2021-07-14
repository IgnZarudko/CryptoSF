public with sharing class CryptocurrencyDatatableController {
    
    private static Integer PAGE_AMOUNT_LIMIT = 10;     

    @AuraEnabled(cacheable=true)  
    public static List<CryptoCurrency__c> getCryptoCurrencies(Integer pageNumber) {
        CryptoCurrencySelector selector = new CryptoCurrencySelector();
        return selector.selectLimitedWithOffset(PAGE_AMOUNT_LIMIT, pageNumber * PAGE_AMOUNT_LIMIT);        
    }
}
