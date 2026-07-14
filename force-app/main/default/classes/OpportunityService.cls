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
}
