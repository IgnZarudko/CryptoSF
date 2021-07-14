public with sharing class UpdateCryptoCurrencyBatch implements Database.Batchable<CryptoCurrency__c>, Database.AllowsCallouts {

    private static final Integer HOURS_PASSED = 1;

    public Iterable<CryptoCurrency__c> start(Database.BatchableContext context) {
        CryptoCurrencySelector selector = new CryptoCurrencySelector();
        return selector.selectAllNotChangedInLastHours(HOURS_PASSED);
    }

    public void execute(Database.BatchableContext context, List<CryptoCurrency__c> scope) {
        CryptoCurrencyService.updateCryptoCurrencies(scope);
    }

    public void finish(Database.BatchableContext context) {}
}
