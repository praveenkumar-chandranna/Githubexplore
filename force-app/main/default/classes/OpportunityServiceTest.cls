@isTest
private class OpportunityServiceTest {

    @isTest
    static void testCreateOpportunity() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Test.startTest();
        Opportunity opp = OpportunityService.createOpportunity('Test Opp', 'Prospecting', Date.today().addDays(30), acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, opp.Id);
        Opportunity result = [SELECT Name, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Test Opp', result.Name);
        System.assertEquals('Prospecting', result.StageName);
    }

    @isTest
    static void testCreateOpportunityWithAmount() {
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;

        Test.startTest();
        Opportunity opp = OpportunityService.createOpportunityWithAmount('Amount Opp', 'Qualification', Date.today().addDays(60), acc.Id, 50000);
        Test.stopTest();

        Opportunity result = [SELECT Amount FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(50000, result.Amount);
    }

    @isTest
    static void testUpdateStage() {
        Account acc = new Account(Name = 'Test Account 3');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Stage Opp', StageName = 'Prospecting', CloseDate = Date.today().addDays(30), AccountId = acc.Id);
        insert opp;

        Test.startTest();
        OpportunityService.updateStage(opp.Id, 'Closed Won');
        Test.stopTest();

        Opportunity result = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Closed Won', result.StageName);
    }

    @isTest
    static void testUpdateCloseDate() {
        Account acc = new Account(Name = 'Test Account 4');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Date Opp', StageName = 'Prospecting', CloseDate = Date.today().addDays(30), AccountId = acc.Id);
        insert opp;

        Test.startTest();
        OpportunityService.updateCloseDate(opp.Id, Date.today().addDays(90));
        Test.stopTest();

        Opportunity result = [SELECT CloseDate FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(Date.today().addDays(90), result.CloseDate);
    }
}
