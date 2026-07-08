public with sharing class AccountQueryService {
    public static List<Account> getAllAccounts() {
        return [SELECT Id, Name, Industry, Phone, Website FROM Account ORDER BY Name];
    }
}
