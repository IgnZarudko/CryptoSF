public with sharing class CryptoCurrenciesSelector extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CryptoCurrency__c.Symbol__c,
            CryptoCurrency__c.Name,
            CryptoCurrency__c.Id
        };
    }

    public Schema.SObjectType getSObjectType() {
        return CryptoCurrency__c.getSObjectType();
    }

    public List<CryptoCurrency__c> selectById(Set<Id> idSet) {
        return (List<CryptoCurrency__c>) selectSObjectsById(idSet);
    } 

    public List<CryptoCurrency__c> selectBySymbol(Set<String> symbolSet) {
        return (List<CryptoCurrency__c>) Database.query(
                newQueryFactory()
                    .setCondition('Symbol__c IN :symbolSet')
                    .toSOQL()
            );
    }

}
