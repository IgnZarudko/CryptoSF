public with sharing class UpdateCryptoCurrencyScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        Database.executeBatch(new UpdateCryptoCurrencyBatch());
    }
}
