@isTest
private class AccountQueryServiceTest {
    @TestSetup
    static void setup() {
        insert new List<Account>{
            new Account(Name = 'Test Account 1', Industry = 'Technology',Phone ='+918888887788'),
            new Account(Name = 'Test Account 2', Industry = 'Finance',Phone='+918888887888')
        };
    }

    @isTest
    static void testGetAllAccounts() {
        List<Account> accounts = AccountQueryService.getAllAccounts();
        System.assertEquals(2, accounts.size(), 'Expected 2 accounts');
        System.assertEquals('Test Account 1', accounts[0].Name, 'Expected sorted by Name');
    }
}
