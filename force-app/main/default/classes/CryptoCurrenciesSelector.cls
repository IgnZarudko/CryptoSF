public with sharing class CryptoCurrenciesSelector extends fflib_SObjectSelector {
    public Schema.SObjectType getSObjectType() {
        return CryptoCurrency__c.getSObjectType();
    }

    public List<Schema.SObjectField> getSObjectFieldSetList() {
        return new List<Schema.SObjectField> {
            CryptoCurrency__c.Symbol__c,
            CryptoCurrency__c.Name,
            CryptoCurrency__c.Id
        };
    }

    public List<CryptoCurrency__c> selectById(Set<Id> idSet) {
        return (List<CryptoCurrency__c>) selectSObjectsById(idSet);
    } 

}
