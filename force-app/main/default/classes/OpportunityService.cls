public with sharing class OpportunityService {

    public static Opportunity createOpportunity(String name, String stageName, Date closeDate, Id accountId) {
        Opportunity opp = new Opportunity(
            Name = name,
            StageName = stageName,
            CloseDate = closeDate,
            AccountId = accountId
        );
        insert opp;
        return opp;
    }

    public static Opportunity createOpportunityWithAmount(String name, String stageName, Date closeDate, Id accountId, Decimal amount) {
        Opportunity opp = new Opportunity(
            Name = name,
            StageName = stageName,
            CloseDate = closeDate,
            AccountId = accountId,
            Amount = amount
        );
        insert opp;
        return opp;
    }

    public static void updateStage(Id oppId, String newStage) {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId LIMIT 1];
        opp.StageName = newStage;
        update opp;
    }

    public static void deleteOpportunity(Id oppId) {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId LIMIT 1];
        delete opp;
    }

    public static List<Opportunity> getOpportunitiesByAccount(Id accountId) {
        List<Opportunity> opps = [SELECT Id, Name, StageName, CloseDate, Amount FROM Opportunity WHERE AccountId = :accountId];
        return opps;
    }

    public static void updateCloseDate(Id oppId, Date newCloseDate) {
        Opportunity opp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :oppId LIMIT 1];
        opp.CloseDate = newCloseDate;
        update opp;
    }

    public static void updateAmount(Id oppId, Decimal newAmount) {
        Opportunity opp = [SELECT Id, Amount FROM Opportunity WHERE Id = :oppId LIMIT 1];
        opp.Amount = newAmount;
        update opp;
    }
}
