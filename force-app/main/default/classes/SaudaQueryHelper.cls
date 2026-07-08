/**
* @File Name        : SaudaQueryHelper.cls
* @Description      : SaudaQueryHelper provides a centralized set of static utility methods used across the Sauda Booking and Rollout modules.
These methods help retrieve data related to Plants, Products, Assignments, SKUs, Users, Accounts, Geography, DPRules, etc.
Most of the methods leverage SOQL queries with WITH SECURITY_ENFORCED to ensure field-level security compliance.
* @Author           : Yash Dagdi
* @Created Date     : 2025-07-09
* @Modification Log :  
* =================================================================================
* Ver | Date       | Author      | Description
* ----|------------|-------------|-------------------------------------------------
* 1.0 | 2025-07-09 | Yash Dagdi  | Initial version for unit testing SaudaQueryHelper
*/
public with sharing class SaudaQueryHelper {

       /**
* @description Fetches active Plant Names based on RecordType Plant and IsActive flag.
* @return List of active PlantDepotRake__c Names.
*/
    public static List<AggregateResult> fetchActivePlantsAccountPDR() {
        return [ SELECT Source__r.Name plantName
            FROM AccountPDR__c 
            WHERE IsActive__c = true AND Source__c != null AND Source__r.IsActive__c = true
              AND Source__r.RecordType.Name = :System.Label.PDR_RecordType_Plant
            GROUP BY Source__r.Name
            ORDER BY Source__r.Name
        ];
    }

    /**
* @description Fetches active Oil Type based on Vertical and PlantDepotRake Name flag.
* @return List of active PlantDepotRake__c Names.
*/
    public static List<AggregateResult> fetchOilTypesByVerticalAndPlant(String vertical, String plantName) {
    return [
        SELECT Product__r.OilType__c oilType
        FROM ProductAssignment__c
        WHERE Product__r.Vertical__c = :vertical AND PlantDepotRake__r.Name = :plantName
          AND Product__r.OilType__c != null AND  IsActive__c = True
        GROUP BY Product__r.OilType__c
        ORDER BY Product__r.OilType__c
    ];
}

    /**
* @description Fetches active PlantDepotRake records based on RecordType and IsActive flag.
* @return List of active PlantDepotRake__c records.
*/
    public static List<PlantDepotRake__c> getActivePlants() {
        return [
            SELECT Id, Name, RecordType.Name
            FROM PlantDepotRake__c
            WHERE RecordType.Name =: Label.PDR_RecordType_Plant AND IsActive__c = true WITH SECURITY_ENFORCED 
        ];
    }
    /**
* @description Fetches all regions,states ().
* @return List of Geography__c records with RecordType = 'State' AND Current User Only
*/
    @AuraEnabled(cacheable=true)
    public static List<UserPlantMapping__c> currentUserStates(String verticalApi) {
        Id crntUserId = UserInfo.getUserId();
        return [select Id, Geography__c , Geography__r.Name,Vertical__c,Geography__r.ParentGeography__c,Geography__r.ParentGeography__r.Name from UserPlantMapping__c where Geography__r.RecordType.name = :System.Label.Geography_RecordType_State and User__c =:crntUserId and IsActive__c  = true AND Vertical__c =: verticalApi WITH SECURITY_ENFORCED];
    }
    
    /**
     * @description Fetches DailyAllocation__c records based on given sets of Plant, Fraction, and Vertical values.
     * @param plantSet   Set of Plant__c IDs
     * @param fractionSet  Set of Fraction__c IDs
     * @param vertSet    Set of Vertical__c values
     * @return Map of DailyAllocation__c records keyed by Id
     */
    
    public static Map<Id, DailyAllocation__c> getDailyAllocatedData(Set<Id> plantSet , Set<Id> fractionSet, Set<String> vertSet){
        return new Map<Id,DailyAllocation__c>([SELECT Id, Name, CreatedDate, AllocatedToUser__c, Fraction__c, UserType__c,
                    OilType__c, Plant__c, RolledOutQuantity__c, Vertical__c, TodayPendingQuantity__c
             FROM DailyAllocation__c
             WHERE Plant__c IN :plantSet AND Fraction__c IN :fractionSet AND Vertical__c IN :vertSet AND AllocatedToUser__c = null AND ParentAllocation__c  = null WITH SECURITY_ENFORCED]);
    }
    
    /**
    * Author : Vishal Jangid
    * Created Date : Oct 29, 2025
    **/
    public static List<SaudaBooking__c> querySaudaBooking(Id bookingId) {
        return [
            SELECT Id, Name, Dealer__c, Broker__c, Vertical__c, ValidityDays__c,
                   TraderPriceRequst__c, Remarks__c, IncoTerms__c, DutyCondition__c,
                   DepositCondition__c, DepositAmount__c, Customer_Group__c,
                   DeliveryFromDate__c, DeliveryToDate__c,
                   (SELECT Id, Name, Plant__c, FinalPriceFOR__c, OilType__c, Qty__c,SKU__r.MaterialType__c, SKU__r.DocumentType__c,
                           Discount__c, IsActive__c, PremimumMT__c, RolloutPrice__c,Secondary_Freight__c,
                           SKU__c, StorageLocation__c,Freight__c
                    FROM Sauda_Booking_SKU__r)// Where SKU__r.DocumentType__c != 'ZCQT')
            FROM SaudaBooking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
    }
    
    /**
* @description Fetching All the tasks of Current User price Rollout Tasks
* @return List of Open Tasks records.
*/
    public static List<Task> getOpenTasks() {
        Id UserId = UserInfo.getUserId();
        String subjectHelper = '%' + System.label.Task_Description_Price + '%';  //Pricing is Now Available
        return  [SELECT Id, Subject, Type, Status
                 FROM Task
                 WHERE Subject LIKE :subjectHelper
                 AND Type = :System.label.TaskType_Price_Rollout
                 AND Priority = :System.label.Priority_High
                 AND WhatId != null AND Owner.Id =:UserId WITH SECURITY_ENFORCED];
    }
    
    /**
* @description Fetches CostComponent__c
*/
    
    public static List<CostComponent__c> fetchCostComponents(Set<Id> productIds, List<String> metaDataList) {
        if (metaDataList.isEmpty() || productIds.isEmpty()) return new List<CostComponent__c>();
        
        return [SELECT Id, RecordType.Name, SKU__c, SKU__r.Name,
                CostPerMT__c, RatePerMT__c, SalesPackingCost__c, Margin_PerMT__c
                FROM CostComponent__c
                WHERE SKU__c != null
                AND IsActive__c = true
                AND SKU__c IN :productIds
                AND RecordType.Name IN :metaDataList WITH SECURITY_ENFORCED];
    }
    
    /**
* @description Fetches Cost_Component_Calculation_Rollout__mdt
*/
    @AuraEnabled
    public static List<Cost_Component_Calculation_Rollout__mdt> getAllCostComps(){
        return [Select Id,Label,Field_Name__c From Cost_Component_Calculation_Rollout__mdt WHERE Active__c = true];
    }
    
    /*
	 * returns logged In User Record.
	 */
    public static User getLoggedInUser(){
        return [SELECT Id, UserRole.DeveloperName FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
    }
    /**
* @description Fetches active PlantDepotRake records From ProductAssignment based on RecordType and IsActive flag.
* @return List of active PlantDepotRake__c records.
*/
    public static List<ProductAssignment__c> getActivePlantsFromPA() {
        return [
            SELECT PlantDepotRake__r.Id, PlantDepotRake__r.Name,Type__c
            FROM ProductAssignment__c
            WHERE Type__c =:Constants.PA_Type AND IsActive__c = true
            WITH SECURITY_ENFORCED
        ];
    }
    /**
* @description Fetches active PlantDepotRake records From ProductAssignment based on RecordType and IsActive flag.
* @return List of active PlantDepotRake__c records.
*/
    @AuraEnabled(cacheable=true)
    public static List<ProductAssignment__c> getOilTypeByPlantVert(String plantName, String vertical) {
        return [
            SELECT Product__r.OilType__c
            FROM ProductAssignment__c
            WHERE 
            Type__c = :System.Label.PDR_RecordType_Plant AND 
            IsActive__c = true AND 
            Product__r.IsActive = true AND 
            PlantDepotRake__r.Name = :plantName AND 
            Product__r.Vertical__c = :vertical
            WITH SECURITY_ENFORCED
        ];
    }
    /**
* @description Fetches dealer account details using dealerId.
* @param dealerId Id of the dealer (Account).
* @return Account record with Group1__c and IncoTerms__c.
*/
    public static Account getDealerDetails(Id dealerId){
        return [SELECT Id,recordTypeId, Name,Group1__c,IncoTerms__c,BillingState,State__c FROM Account WHERE Id = :dealerId WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    public static RecordType fetchRecordType(String ObjName, String DevName){
        return [SELECT Id,name from RecordType WHERE DeveloperName = :DevName AND SobjectType =: ObjName 
                AND IsActive = true WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    // public static List<PartnerFunction__c> fetchPartnerFunc(Id accId, String vertical){
    //     return [SELECT Ship_To_Party__c, Ship_To_Party__r.Name, Ship_To_Party__r.RecordTypeId
    //             FROM PartnerFunction__c
    //             WHERE Account__c = :accId AND Vertical__c =: vertical AND IsActive__c = true WITH SECURITY_ENFORCED];
    // }
    
    /**
* @description Fetches IncoTerm records.
* @param dealerId Id of the dealer (Account).
* @return List of Incoterm records.
*/
    public static List<IncotermAssignment__c> fetchIncoTerms(Id dealerId){
        return [SELECT IncoTerms__c, Vertical__c 
                FROM IncotermAssignment__c 
                WHERE Account__c = :dealerId WITH SECURITY_ENFORCED];
    }
    
    public Static List<AccountPDR__c> getAccountPDRByAccountIdQuery(Id accountId) {
        return [SELECT Id, Source__c, Source__r.Name, Type__c
                FROM AccountPDR__c
                WHERE AccountId__c = :accountId AND Source__c != null AND IsActive__c  = TRUE
                AND AccountId__r.IsActive__c = TRUE AND Source__r.IsActive__c  = TRUE AND Type__c = :Label.PlantTypeValue WITH SECURITY_ENFORCED];  
    }
    
    public static List<ChangeRequest__c> fetchChangeRequest(Set<Id> recIds){
        return [SELECT Name,FromCustomer__r.Name, Id, Type__c,FromCustomer__c, Vertical__c, 
                Existing_Limit__c,Total_Limit__c, Requested_Limit__c FROM ChangeRequest__c 
                WHERE Id IN: recIds AND Type__c =: Label.CR_Limit_Increase AND RecordType.DeveloperName =: Label.CR_RectType_Sauda 
                AND CustomerChangeApproval__c =: Label.SA_BOOKING_STATUS_PENDING WITH SECURITY_ENFORCED];
    }
    
    public static ChangeRequest__c fetchSingleChangeRequest(Id recId){
        return [SELECT Name, Id, Type__c,FromCustomer__c,CreatedById,CreatedBy.ManagerId,Requested_Limit__c,Existing_Limit__c,
                Total_Limit__c, Vertical__c FROM ChangeRequest__c 
                WHERE Id =: recId AND Type__c =: Label.CR_Limit_Increase AND RecordType.DeveloperName =: Label.CR_RectType_Sauda 
                WITH SECURITY_ENFORCED];
    }
    
    /**
* @description Fetches ProcessInstanceWorkitem using current user Id and Sauda Id.
* @param Current User Id, Sauda Booking id.
* @return ProcessInstanceWorkitem List.
*/
    public static List<ProcessInstanceWorkitem> getApprovalRecords(Id currentUserId, Id saudaId){
        return [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ActorId = :currentUserId 
                AND ProcessInstance.TargetObjectId = :saudaId WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    /**
* @description Retrieves vertical configuration for an account and vertical.
* @param accountId Id of the Account.
* @param vertical Vertical API value.
* @return VerticalConfiguration__c record with sauda-related values. 
*/
    public static VerticalConfiguration__c getSaudaValues(Id accountId, String vertical){
        System.debug('accountId : 290'+accountId);
        List<VerticalConfiguration__c> configs = [
            SELECT Id, AvailableSaudaLimit__c,Account__r.IsActive__c,BDO_ZH__c,IncoTerms__c,Freight_Zone__c,Customer_Group__c, Freight_Route__c, SaudaLimit__c, SaudaValidity__c
            FROM VerticalConfiguration__c
            WHERE Account__c = :accountId AND Vertical__c = :vertical AND IsActive__c = true AND Account__r.IsActive__c = true
            WITH SECURITY_ENFORCED LIMIT 1];
        if(!configs.isEmpty()){
            return configs[0];
        }
        else {
                throw new AuraHandledException(Label.LBL_NoVerticalConfiguration);
            }
        }
    
    /**
* @description Retrieves vertical configuration based on vertical.
* @param vertical Vertical API value.
* @return VerticalConfiguration__c record with sauda-related values. 
*/
    public static List<VerticalConfiguration__c> fetchVertConfigs(String vertical, Boolean isMtHoreca){
        List<VerticalConfiguration__c> configs = new List<VerticalConfiguration__c>();
        if(isMtHoreca){
            configs = [
                SELECT Id, Vertical__c, Account__c, IncoTerms__c,Account__r.RecordType.Name,
                Account__r.Id,Account__r.IsActive__c, Account__r.Name,Account__r.BillingState,Account__r.BillingCity, 
                Account__r.PartyCode__c
                FROM VerticalConfiguration__c
                WHERE Vertical__c = :vertical AND Account__r.RecordType.Name =: Label.MT_Horeca 
                AND Account__r.MT_Horeca__c = true AND IsActive__c = true
                WITH SECURITY_ENFORCED];
            return configs;
        }
        else{
            configs = [
                SELECT Id, Vertical__c, Account__c, IncoTerms__c,
                Account__r.Id,Account__r.IsActive__c, Account__r.Name,Account__r.RecordType.Name,
                Account__r.BillingState,Account__r.BillingCity, Account__r.PartyCode__c
                FROM VerticalConfiguration__c
                WHERE Vertical__c = :vertical AND Account__r.RecordType.Name =: Label.ACC_RecordType_CUSTOMER AND IsActive__c = true
                WITH SECURITY_ENFORCED];
            return configs;
        }
    }
    
    public static List<VerticalConfiguration__c> getVertConfigs(Id accountId, String vertical){
        System.debug('accountId : 290'+accountId);
        List<VerticalConfiguration__c> configs = [
            SELECT Id, AvailableSaudaLimit__c,BDO_ZH__c,BDO_ZH__r.ManagerId,IncoTerms__c,Freight_Zone__c,Customer_Group__c, Freight_Route__c, SaudaLimit__c, SaudaValidity__c
            FROM VerticalConfiguration__c
            WHERE Account__c = :accountId AND Vertical__c = :vertical AND IsActive__c = TRUE AND  Account__r.IsActive__c = TRUE
            WITH SECURITY_ENFORCED LIMIT 1];
        if(!configs.isEmpty()){
            return configs;
        }
        else{
            throw new AuraHandledException(Label.LBL_NoVerticalConfiguration);
        }
    }
    
    public static List<BrokerShipToPartyAssignment__c> fetchBrokerAssignment(Id accountId, String vertical){
        
        return [
            SELECT BrokerShipToParty__c,ProductCode__c,BrokerShipToParty__r.IsActive__c, BrokerShipToParty__r.Name,Type__c, Record_Type__c,
            BrokerShipToParty__r.RecordTypeId, BrokerShipToParty__r.PartyCode__c
            FROM BrokerShipToPartyAssignment__c
            WHERE ParentAccount__c = :accountId AND BrokerShipToParty__r.IsActive__c = true
            AND IsActive__c = true AND Vertical__c =: vertical WITH SECURITY_ENFORCED
        ];
    }
    
    public static List<BrokerShipToPartyAssignment__c> fetchBrokerSTP(Id accountId, Id stpId, String vertical){
        
        return [
            SELECT ParentAccount__r.PartyCode__c,BrokerShipToParty__c,Back_End_Margin__c,Load__c,UnloadingChargeCase__c,Discount_ConfiguredMT__c, BrokerShipToParty__r.Name,Type__c, Record_Type__c, BrokerShipToParty__r.RecordTypeId, BrokerShipToParty__r.PartyCode__c
            FROM BrokerShipToPartyAssignment__c
            WHERE ParentAccount__c = :accountId AND IsActive__c = true 
            AND Vertical__c =: vertical AND BrokerShipToParty__c =: stpId WITH SECURITY_ENFORCED
        ];
    }
    
    public static List<BrokerShipToPartyAssignment__c> fetchAllBrokerAssignment(String vertical){
        
        return [
            SELECT BrokerShipToParty__c,BrokerShipToParty__r.IsActive__c, BrokerShipToParty__r.Name,Type__c,
            Record_Type__c, BrokerShipToParty__r.RecordTypeId
            FROM BrokerShipToPartyAssignment__c
            WHERE Record_Type__c =: Label.RT_Ship_to_Party AND BrokerShipToParty__r.IsActive__c = true
            AND IsActive__c = true AND Vertical__c =: vertical WITH SECURITY_ENFORCED
        ];
    }
    
    /**
* @description Fetches active customer accounts for "Loose" vertical.
* @return List of Account records for Loose vertical.
*/
    public static List<Account> getCusotmerAccounts(){
        return [SELECT Id, Name,PartyCode__c, BillingCity, BillingState,VerticalLoose__c FROM Account WHERE IsActive__c = true 
                AND (RecordType.DeveloperName =: System.Label.ACC_RecordType_CUSTOMER OR RecordType.DeveloperName =: System.Label.BSP_RecordType_Broker)
                AND Vertical__c INCLUDES (:Label.PA_Vertical_Loose) AND VerticalLoose__c = true WITH SECURITY_ENFORCED ORDER BY Name LIMIT 10000];
    }
    
    /**
* @description Fetches all active customer accounts regardless of vertical.
* @return List of Account records.
*/
    public static List<Account> getCusotmerAccountsForHBC(){
        return [SELECT Id, Name,PartyCode__c,BillingCity, BillingState FROM Account WHERE IsActive__c = true 
                AND RecordType.DeveloperName =: System.Label.ACC_RecordType_CUSTOMER  
                WITH SECURITY_ENFORCED ORDER BY Name LIMIT 10000];
    }
    
    /**
* @description Retrieves single SKUPriceRollout record based on product, plant, oil type, and vertical.
* @param apiValue Vertical API value.
* @param product Product2 record to fetch Fraction__c.
* @param plantId Id of Plant.
* @param oilType Oil Type string.
* @param childRecordT ypeId RecordType Id of rollout item.
* @return List containing matching SKUPriceRollout__c record.
*/
    public static List<SKUPriceRollout__c> getSKURecord(String apiValue,Product2 product, Id plantId, String oilType, Id childRecordTypeId){
        return [
            SELECT Id, LoosePrice__c,ParentRollout__r.PriceRolloutCH__c,ParentRollout__r.PriceRolloutZH__c,ParentRollout__r.PriceRolloutBDO__c,ParentRollout__r.ZHTaskTracker__c,OwnerId,Premium__c,PriceRolloutBDO__c,ParentRollout__r.Status__c, Qty__c, Pending_Quantity__c FROM SKUPriceRollout__c 
            WHERE IsActive__c = true AND ParentRollout__r.Vertical__c = :apiValue AND Oil_Type__c = :oilType 
            AND Plant__c = :plantId AND ParentRollout__r.IsActive__c  = true 
            AND Fraction__c =: product.Fraction__c and RecordTypeId =:childRecordTypeId WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    /**
* @description Fetches a list of SKUPriceRollout records by their IDs.
* @param skuIds Set of SKUPriceRollout__c record IDs.
* @return List of SKUPriceRollout__c records.
*/
    public static List<SKUPriceRollout__c> fetchSKURecord(Set<Id> skuIds){
        return [
            SELECT Id, LoosePrice__c,Premium__c,ParentRollout__r.Status__c, Qty__c, Pending_Quantity__c FROM SKUPriceRollout__c 
            WHERE Id IN: skuIds WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    /**
* Get active SaudaAgreementSKU__c records created today for Vertical '30'.
*/
    
    public static Database.QueryLocator getHBCSaudaAgreementSKUForBatch() {
        String baseQuery = 
            'SELECT Id, Name, Plant__c, SKU__c, Oil_Type__c, Quantity__c, SaudaAgreement__r.Vertical__c ' +
            'FROM SaudaAgreementSKU__c ' +
            'WHERE Plant__c != null ' +
            'AND Oil_Type__c != null ' +
            'AND CreatedDate = TODAY ' +
            'AND IsActive__c = true ';
        
        // Add condition only for HBC vertical
        baseQuery += 'AND ( ' +
            '(SaudaAgreement__r.Vertical__c = \'' + System.Label.Vertical_HBC + '\' AND Oil_Type__c != \'' + System.Label.Oil_Type_Rasoi + '\') ' +
            'OR (SaudaAgreement__r.Vertical__c = \'' + System.Label.Vertical_HT + '\') ' +
            ') ';
        
        baseQuery += 'ORDER BY Plant__r.Name, Oil_Type__c, CreatedDate ASC';
        
        return Database.getQueryLocator(baseQuery);
        
    }
    
    
    /**
* Get Unit of Measure records for given Product IDs.
*/
    public static List<cgcloud__Unit_of_Measure__c> getUnitOfMeasureByProducts(Set<Id> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return new List<cgcloud__Unit_of_Measure__c>();
        }
        return [
            SELECT Id, cgcloud__Weight__c, cgcloud__Product__c, cgcloud__Product__r.Name
            FROM cgcloud__Unit_of_Measure__c
            WHERE cgcloud__Product__c IN :productIds AND cgcloud__Is_Order_Unit__c  = true
        ];
    }
    
    /**
* Get TradeTicket__c records for Vertical Bio Diesel,
* filtered by Plant IDs and Oil Types.
*/
    public static List<TradeTicket__c> getTradeTicketBioDieselRcrds(Set<Id> plantSet , Set<String> oilTypeSet ,Set<Id> ingredientSet) {
        return [SELECT Id,Plant__c ,Plant__r.Name, Ingredients__c , Ingredients__r.Name, Qty__c, Price__c, Vertical__c, IsActive__c
                FROM TradeTicket__c
                WHERE Vertical__c = :System.Label.VerticalBioDiesel
                AND RecordType.DeveloperName = :System.Label.TT_RecordType_Final
                AND IsActive__c = true
                AND Plant__c IN :plantSet
                AND OilType__c IN :oilTypeSet
                AND Ingredients__c IN :ingredientSet WITH SECURITY_ENFORCED
               ];
    }
    
    public static List<RecordType> fetchrecordTypeIds(Set<String> rtNames){
        return [SELECT Id, Name
              FROM RecordType
              WHERE SobjectType = 'CostComponent__c'
              AND Name IN :rtNames  WITH SECURITY_ENFORCED];
    }
    
    /**
* Get TradeTicket__c records created today for Vertical '30',
* filtered by Plant IDs and Oil Types.
*/
    public static List<TradeTicket__c> getTradeTickets(Set<Id> plantIds, Set<String> oilTypes , Set<String> verticals) {
        if ((plantIds == null || plantIds.isEmpty()) || (oilTypes == null || oilTypes.isEmpty()) || (verticals == null || verticals.isEmpty())) {
            return new List<TradeTicket__c>();
        }
        return [
            SELECT Id, Name, Plant__c, OilType__c, Qty__c, ConsumedQuantity__c, Price__c,Vertical__c
            FROM TradeTicket__c
            WHERE Plant__c IN :plantIds
            AND OilType__c IN :oilTypes
            AND Vertical__c IN :verticals
            AND CreatedDate = TODAY
            AND OnHold__c = false
            WITH SECURITY_ENFORCED
            ORDER BY Plant__r.Name, OilType__c, CreatedDate ASC
        ];
    }
    
    /**
* Fetch active SaudaAgreementSKU__c records for today
* matching HBC + Rasoi or SPF Vertical.
*
* @return Database.QueryLocator
*/
    public static Database.QueryLocator getActiveSaudaAgreementSKUsForToday() {
        return Database.getQueryLocator([
            SELECT Id, Name, Plant__c, Plant__r.Name, SKU__c, Oil_Type__c, Quantity__c,
            Sku__r.MaterialType__c, SaudaAgreement__r.Vertical__c
            FROM SaudaAgreementSKU__c
            WHERE IsActive__c = true
            AND (
                (SaudaAgreement__r.Vertical__c = :System.Label.Vertical_HBC AND Oil_Type__c = :System.Label.Oil_Type_Rasoi)
                OR SaudaAgreement__r.Vertical__c = :System.Label.SPF_Vertical
            )
            AND CreatedDate = TODAY
            ORDER BY Plant__r.Name, Oil_Type__c, CreatedDate ASC
        ]);
    }
    
    /**
* Fetch Ingredients records for given SKU IDs and Plant IDs.
*
* @param skuIds   Set of SKU Ids (from productIdWeightMap)
* @param plantIds Set of Plant Ids
* @return List of Ingredients__c records
*/
    public static List<Ingredients__c> getIngredientsForSKUs(Set<Id> skuIds, Set<Id> plantIds) {
        if (skuIds.isEmpty() || plantIds.isEmpty()) {
            return new List<Ingredients__c>();
        }
        
        return [
            SELECT Id, Name, SKU__c, SKU__r.Name, ParentIngredient__c,
            ParentIngredient__r.Type__c, ParentIngredient__r.ConversionPMT__c,
            ParentIngredient__r.ParentIngredient__c, PercentageUsed__c,
            Plant__c, Plant__r.Name, SKU__r.MaterialType__c
            FROM Ingredients__c
            WHERE SKU__c IN :skuIds
            AND Plant__c IN :plantIds WITH SECURITY_ENFORCED
        ];
    }
    
    /**
* Fetch active SKU Price Rollouts for given Ingredient IDs.
*
* @param ingredientIds Set of Ingredient Ids (rolloutParentIds)
* @return List of SKUPriceRollout__c records
*/
    public static List<SKUPriceRollout__c> getActiveSKUPriceRollouts(Set<Id> ingredientIds) {
        if (ingredientIds.isEmpty()) {
            return new List<SKUPriceRollout__c>();
        }
        
        return [
            SELECT Id, Premium__c, LoosePrice__c, Ingredients__c, Ingredients__r.Name,
            Plant__c, Plant__r.Name
            FROM SKUPriceRollout__c
            WHERE Ingredients__c IN :ingredientIds
            AND IsActive__c = true
        ];
    }
    
    /**
* Fetch Ingredients with pricing details for given Parent Ingredient Ids,
* filtered by record type and type values.
*
* @param ingPriceParentIds Set of Parent Ingredient Ids
* @param recordTypeId Record Type Id for Ingredients__c
* @param typeValues Set of valid Type values for ParentIngredient__r.Type__c
* @return List of Ingredients__c records
*/
    public static List<Ingredients__c> getIngredientPrices(Set<Id> ingPriceParentIds, Id recordTypeId, Set<String> typeValues) {
        if (ingPriceParentIds.isEmpty() || recordTypeId == null || typeValues.isEmpty()) {
            return new List<Ingredients__c>();
        }
        
        return [
            SELECT Id, Name, ParentIngredient__c, ParentIngredient__r.Name, 
            BasePrice__c, Plant__c, Plant__r.Name, 
            ParentIngredient__r.Type__c, ConversionPMT__c
            FROM Ingredients__c
            WHERE ParentIngredient__c IN :ingPriceParentIds
            AND RecordTypeId = :recordTypeId
            AND ParentIngredient__r.Type__c IN :typeValues
        ];
    }
    
    public static List<ProductAssignment__c> getProductAssignments(Set<Id> plants, Set<Id> productIds) {
        if (plants == null || plants.isEmpty() || productIds == null || productIds.isEmpty()) {
            return new List<ProductAssignment__c>();
        }
        
        return [
            SELECT Id,
            PlantDepotRake__c,
            Product__c,
            Product__r.Name,
            ProcessCost__c,
            Product__r.MaterialType__c
            FROM ProductAssignment__c
            WHERE ProcessCost__c != null
            AND PlantDepotRake__c IN :plants
            AND Product__c IN :productIds
        ];
    }
    
    public static List<ProductAssignment__c> getProcessCostForHT(Set<Id> plants,Set<Id> productIds) {
        List<ProductAssignment__c> assignments = [
            SELECT Id, PlantDepotRake__c, Product__c, Product__r.Name, ProcessCost__c
            FROM ProductAssignment__c 
            WHERE ProcessCost__c != null 
            AND PlantDepotRake__c IN :plants 
            AND Product__r.Vertical__c = :System.Label.Vertical_HT //'40'
            AND Product__c IN :productIds
        ];
        return assignments;
    }
    
    /**
* @description Retrieves unique ProductAssignment records by Fraction and Oil Type for a Plant.
* @param plantId Id of the Plant.
* @param oilType Oil type to filter.
* @return List of unique ProductAssignment__c records.
*/
    public static List<ProductAssignment__c> getProductsByPlantAndOilType(String plantId, String oilType) {
        List<ProductAssignment__c> assignments = [
            SELECT Product__r.Fraction__c, Product__r.Fraction__r.Name, Product__r.Fraction__r.OilType__c,Product__r.Vertical__c,Product__r.PackGroup__c,
            Product__r.CPFraction__c, Product__r.CPFraction__r.Name, Product__r.CPFraction__r.OilType__c 
            FROM ProductAssignment__c 
            WHERE PlantDepotRake__c = :plantId
            AND Product__r.OilType__c = :oilType 
            AND isActive__c = true 
            AND Product__r.isActive = true 
            AND Product__c != null
            AND (
                Product__r.Fraction__c != null
                OR (Product__r.Vertical__c = '40' 
                    AND Product__r.PackGroup__c = 'CP'
                    AND Product__r.CPFraction__c != null)
            )
            WITH SECURITY_ENFORCED
        ];
        Map<String,ProductAssignment__c> uniqueFracs =  new Map<String,ProductAssignment__c>();
        for(ProductAssignment__c assignment : assignments){
            String fracName;
            if(assignment.Product__r.Vertical__c == '40' && assignment.Product__r.PackGroup__c == 'CP'){
                fracName = assignment.Product__r.CPFraction__r.Name;
                assignment.Product__r.Fraction__r = assignment.Product__r.CPFraction__r;
            }else{
                fracName = assignment.Product__r.Fraction__r.Name;
            }
            if(!uniqueFracs.containsKey(fracName)){
                uniqueFracs.put(fracName , assignment);
            }
            //if(!uniqueFracs.containsKey(assignment.Product__r.Fraction__r.Name)){
            //    uniqueFracs.put(assignment.Product__r.Fraction__r.Name , assignment);
            //}
        }
        
        return uniqueFracs.values();
    }
    
    /**
* @description Fetches approved TraderPriceRequest record by Id.
* @param recId Id of TraderPriceRequest__c record.
* @return List containing the approved TraderPriceRequest__c record.
*/
    
    public static List<TraderPriceRequest__c> getApprovedTraderRequest(Id recId){
        return [
            SELECT Id, Name, Oil_Type__c,Duty_Condition__c, SKU__c, SKU__r.Name, Plant__c, Plant__r.Name, Quantity__c,
            PendingQTY__c, PricePerMT__c, DeliveryFromDate__c, DeliveryToDate__c
            FROM TraderPriceRequest__c
            WHERE Approval_Status__c = 'Approved' AND IsActive__c = TRUE And Id=:recId WITH SECURITY_ENFORCED
        ];
    }
    
    public static List<TraderPriceRequest__c> getTraderRequest(Integer limitSize, Integer offsetSize) {
        return [
            SELECT Id, Name, Oil_Type__c, SKU__r.Name, Plant__r.Name, Quantity__c, Duty_Condition__c,
            PendingQTY__c, PricePerMT__c, DeliveryFromDate__c, DeliveryToDate__c
            FROM TraderPriceRequest__c
            WHERE Approval_Status__c =: Constants.TPR_APPROVAL_STATUS_APPROVED 
            AND IsActive__c = TRUE And CreatedDate = Today WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT :limitSize OFFSET :offsetSize ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SaudaBooking__c> getPendingSaudaBookings() {
            return [
                SELECT Id, Name, Status__c, Plant__c, Plant__r.Name
                FROM SaudaBooking__c
                WHERE Status__c =: Label.SA_BOOKING_STATUS_PENDING WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
            ];
    }
    
    /**
* @description Gets list of ProductAssignment records for selected verticals and plant.
* @param selectedVerticals List of verticals.
* @param selectedPlantLabel Plant name to filter.
* @return List of ProductAssignment__c records.
*/
    public static List<ProductAssignment__c> getOilType(List<String> selectedVerticals, String selectedPlantLabel) {
        Set<String> verticalSet = new Set<String>();
        verticalSet.addAll(selectedVerticals); // Added R-260608-0065
        /* for(String str : selectedVerticals){
            verticalSet.add(str);
        }*/
        
        
        List<ProductAssignment__c> lsttrade = [SELECT Product__r.Id, Product__r.Name, Product__r.OilType__c
                                               FROM ProductAssignment__c  WHERE Type__c = :System.Label.PDR_RecordType_Plant AND IsActive__c = true AND Product__r.IsActive = true AND 
                                               PlantDepotRake__r.Name = :selectedPlantLabel AND Product__r.Vertical__c IN : verticalSet AND Product__r.Vertical__c != :System.Label.SPF_Vertical WITH SECURITY_ENFORCED];
        return lsttrade;
    }
    
    public static List<ProductAssignment__c> getProdAssignRecs(String apiValue, Id plantId, Boolean mtHoreca) {
        system.debug('@#mtHoreca '+mtHoreca);
        List<ProductAssignment__c> lsttrade = new List<ProductAssignment__c>();
        if(apiValue == Label.Vertical_HBC || apiValue == Label.Vertical_HT){
            if (mtHoreca) {
                lsttrade = [SELECT Product__r.Id, Product__r.Name, Product__r.OilType__c
                            FROM ProductAssignment__c  WHERE // Type__c = :Constants.PA_Type AND //V1313
                            IsActive__c = true AND Product__r.IsActive = true AND 
                            PlantDepotRake__c = :plantId AND Product__r.Vertical__c =: apiValue AND Product__r.OilType__c != null WITH SECURITY_ENFORCED];
            }
            else{
                lsttrade = [SELECT Product__r.Id, Product__r.Name, Product__r.OilType__c
                            FROM ProductAssignment__c  WHERE // Type__c = :Constants.PA_Type AND //V1313
                            IsActive__c = true AND Product__r.IsActive = true AND 
                            PlantDepotRake__c = :plantId AND Product__r.Vertical__c =: apiValue 
                            AND Product__r.IsBaseSKU__c = true AND Product__r.OilType__c != null WITH SECURITY_ENFORCED];
            }
        }
        else{
            lsttrade = [SELECT Product__r.Id, Product__r.Name, Product__r.OilType__c
                        FROM ProductAssignment__c  WHERE // Type__c = :Constants.PA_Type AND //V1313
                        IsActive__c = true AND Product__r.IsActive = true AND 
                        PlantDepotRake__c = :plantId AND Product__r.Vertical__c =: apiValue 
                        AND Product__r.OilType__c != null WITH SECURITY_ENFORCED];
        }
        return lsttrade;
    }

    /**
* @description Gets list of ProductAssignment records for selected verticals and plant.
* @param selectedVerticals List of verticals.
* @param selectedPlantLabel Plant id to filter.
* @return List of ProductAssignment__c records.
*/
     public static List<ProductAssignment__c> getOilTypeByVertPlantId(List<String> verticals, Id plantId) {
     	
        List<ProductAssignment__c> lsttrade = [SELECT Product__r.Id, Product__r.Name, Product__r.OilType__c,Product__r.Vertical__c
                                               FROM ProductAssignment__c  WHERE Type__c = :Constants.PA_Type AND IsActive__c = true AND Product__r.IsActive = true AND 
                                               PlantDepotRake__c = :plantId AND Product__r.Vertical__c IN : verticals WITH SECURITY_ENFORCED];
         return lsttrade;
     }
    /**
* @description Retrieves paginated list of SKUPriceRollout records for Trade tab view.
* @param selectedVerticals Selected vertical label.
* @param selectedPlantLabel Plant name.
* @param offset Offset for pagination.
* @param limitSize Number of records to fetch.
* @return List of SKUPriceRollout__c records.
*/
    public static List<SKUPriceRollout__c> getTrade(String selectedVerticals, String selectedPlantLabel,Integer offset,Integer limitSize){
        Id childRecordTypeId = Schema.SObjectType.SKUPriceRollout__c.getRecordTypeInfosByName().get(System.Label.SKU_Item_Record_Type)?.getRecordTypeId();
        Map<String, String> labelToApiValueMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = SKUPriceRollout__c.Vertical__c.getDescribe();
        
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            labelToApiValueMap.put(entry.getLabel(), entry.getValue());
        }
        
        String verticalApp = '';
        if (labelToApiValueMap.containsKey(selectedVerticals)) {
            verticalApp =labelToApiValueMap.get(selectedVerticals);
        }
        
        List<SKUPriceRollout__c> skuList = [
            SELECT Id, Vertical__c, Plant__r.Name, Oil_Type__c,Base_SKU__c,
            LoosePrice__c, Qty__c,Fraction__c,Fraction__r.Name,Premium__c,ParentRollout__c,ParentRollout__r.Vertical__c,Ingredients__c,Ingredients__r.Name,Ingredients__r.OilType__c
            FROM SKUPriceRollout__c
            WHERE Plant__r.Name = :selectedPlantLabel
            AND ParentRollout__r.Vertical__c =:verticalApp AND CreatedDate = TODAY  ANd IsActive__c = true
            AND ParentRollout__r.IsActive__c =true AND RecordTypeId =:childRecordTypeId  
            WITH SECURITY_ENFORCED LIMIT :limitSize OFFSET :offset
        ];
        return skuList; 
    }
    
    /**
* @description Fetches SKU records for a vertical created today.
* @param vertical Vertical API name.
* @param childRecordTypeId RecordType Id for price rollout item.
* @return List of SKUPriceRollout__c records.
*/
    public static List<Product2> fetchSKUforOilType(String vertical){
        return [select id,OilType__c from Product2 
                where IsActive = true 
                AND Vertical__c =:vertical WITH SECURITY_ENFORCED];
    }
    
    /**
* Returns ProcessInstanceWorkitem records for a given approver user.
* @param approverId The Id of the User who is the pending approver.
* @return List of ProcessInstanceWorkitem with TargetObjectId populated.
*/
    public static List<ProcessInstanceWorkitem> getPendingApprovalWorkitemsByUser(Id approverId) {
        if (approverId == null) {
            return new List<ProcessInstanceWorkitem>();
        }
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        if(profileName == System.Label.Profile_System_Administrator){
            return [
                SELECT ProcessInstanceId, ActorId, ProcessInstance.TargetObjectId
                FROM ProcessInstanceWorkitem WHERE ActorId IN (Select Id From User Where User_Type__c = 'NSM')
            ];
        }
        return [
            SELECT ProcessInstanceId, ActorId, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ActorId = :approverId
        ];
    }
    
    /**
* @description Fetches SaudaBooking__c records for Status as Draft.
* @return List of SaudaBooking__c records.
*/
    public static List<SaudaBooking__c> getPendingNSMSaudas(Set<Id> pendingSaudaIds){
        return [SELECT Id,CreatedDate, Name, Dealer__r.Name,CreatedBy.Name, DeliveryFromDate__c,Vertical__c,DeliveryToDate__c,Apporval_Status__c
                FROM SaudaBooking__c
                WHERE Active__c = true AND Id IN :pendingSaudaIds AND Status__c =: Label.SA_BOOKING_STATUS_PENDING AND Apporval_Status__c =: Label.NSM_Pending 
                AND (Apporval_Status__c =: Label.NSM_Pending OR Apporval_Status__c =: Label.Pending_CH) WITH SECURITY_ENFORCED ORDER by CreatedDate desc];
    }
    
    public static List<SaudaBooking__c> getPendingCHSaudas(Set<Id> pendingSaudaIds){
        return [SELECT Id, Name, Dealer__r.Name,CreatedBy.Name, DeliveryFromDate__c, DeliveryToDate__c,Vertical__c,Apporval_Status__c
                FROM SaudaBooking__c
                WHERE Active__c = true AND Id IN :pendingSaudaIds AND Status__c =: Label.SA_BOOKING_STATUS_PENDING AND Apporval_Status__c =: Label.Pending_CH 
                AND Approval_to_CH__c = true WITH SECURITY_ENFORCED ORDER by CreatedDate desc];
    }
    
    public static List<SaudaBooking__c> getPendingZHSaudas(Set<Id> pendingSaudaIds){
        return [SELECT Id,CreatedDate, Name, Dealer__r.Name, DeliveryFromDate__c,Unpunched_Sauda__c, DeliveryToDate__c,Vertical__c
                FROM SaudaBooking__c
                WHERE Active__c = true AND Id IN: pendingSaudaIds 
                AND ((Status__c =: Label.SA_BOOKING_STATUS_PENDING AND Unpunched_Sauda__c = false) 
                     OR (Status__c =: Label.SA_BOOKING_STATUS_SAVE AND Unpunched_Sauda__c = true)) AND 
                (Apporval_Status__c =: Label.ZH_Pending OR Apporval_Status__c =: Label.Pending_CH)
                AND (Approval_to_Manager__c = true OR Approval_to_CH__c = true) WITH SECURITY_ENFORCED ORDER by CreatedDate desc];
    }

    
    public static List<SaudaBooking__c> getPendingBDOSaudas(Set<Id> pendingSaudaIds){
        return [SELECT Id, Name, Dealer__r.Name, DeliveryFromDate__c, DeliveryToDate__c,Vertical__c
                FROM SaudaBooking__c
                WHERE Id IN: pendingSaudaIds AND Status__c =: Label.SA_BOOKING_STATUS_PENDING 
                AND Apporval_Status__c =: Label.Pending_BDO 
                AND Approval_to_BDO__c = true WITH SECURITY_ENFORCED ORDER by CreatedDate desc];
    }
    
    /**
* @description Fetches SaudaBooking__c record against record Id.
* @return record of SaudaBooking__c.
*/
    public static SaudaBooking__c fetchSaudaRecord(Id recId){
        return [SELECT Id, Name,Dealer__c,MT_Horeca__c, Approval_to_ZH__c,Unpunched_Sauda__c,CP_Sauda__c,OwnerId,Approval_to_CH__c,Approval_to_BDO__c,ShipToparty__c,ValidityDays__c,IncoTerms__c,Vertical__c,DutyCondition__c, Allocation_Count__c,
                Dealer__r.Name,Broker__c, Broker__r.Name,ShipToparty__r.Name,DepositCondition__c, DepositAmount__c, DeliveryFromDate__c, DeliveryToDate__c,
                Approval_to_Manager__c,Remarks__c,TraderPriceRequst__c,Status__c, Approval_to_NSM__c, Apporval_Status__c 
                FROM SaudaBooking__c
                WHERE Id =: recId WITH SECURITY_ENFORCED];
    }
    
    public static SaudaBooking__c getSaudaBookingById(Id bookingId) {
    return [SELECT Name FROM SaudaBooking__c WHERE Id = :bookingId WITH SECURITY_ENFORCED LIMIT 1];
}
    
    /**
* @description Fetches SaudaBookingSKU__c records for Sauda Id.
* @param SaudaBookingSKU__c Id.
* @return List of SaudaBookingSKU__c records.
*/
    public static List<SaudaBookingSKU__c> getSaudaSKUDetails(Id saudaId) {
        return [SELECT Id,NSM_MT_Discount__c,SaudaBooking__r.CP_Sauda__c,SaudaBooking__r.Unpunched_Sauda__c,Secondary_Freight__c,Special_Discount_PMT__c,Quantity_in_Pcs__c,Quantity_in_MT__c,Fraction__c,Discount_Configured__c,Actual_Base_Price__c,PTD_Price__c,Load__c,Scheme_Cost__c,Profit_Margin__c,Primary_Freight__c,Packing_Cost__c,
                Oil_Transfer_Cost__c,Material_Cost__c,Depot__c,Depot__r.Name,HoneyComb_Cost__c,Detention_Cost__c,Depot_Cost__c,Cushion_Margin__c,
                Additional_Cost__c,Name,Qty__c,Plant__c,OilType__c,ZH_Premium__c,NSM_Premium__c,
                Plant__r.Name,FinalPriceFOR__c,SKU__c,SKU__r.Name,SKU__r.GST__c,BDO_Premium__c,SKU__r.ProductCode,TotalPrice__c,
                SaudaBooking__c, RolloutPrice__c,NetWeight__c, Discount__c, Liquidation_Discount__c, Margin__c
                FROM SaudaBookingSKU__c
                WHERE SaudaBooking__c = :saudaId WITH SECURITY_ENFORCED];
    }
    
    public static List<SaudaBookingSKU__c> getSaudaSKUDetailsForNSMAndZH(Id saudaId) {
        return [SELECT Id,SRM_Price__c,NSM_MT_Discount__c,SaudaBooking__r.CP_Sauda__c,SaudaBooking__r.Unpunched_Sauda__c,Secondary_Freight__c,Special_Discount_PMT__c,Quantity_in_Pcs__c,Quantity_in_MT__c,Fraction__c,Discount_Configured__c,Actual_Base_Price__c,PTD_Price__c,Load__c,Scheme_Cost__c,Profit_Margin__c,Primary_Freight__c,Packing_Cost__c,
                Oil_Transfer_Cost__c,Material_Cost__c,Depot__c,Depot__r.Name,HoneyComb_Cost__c,Detention_Cost__c,Depot_Cost__c,Cushion_Margin__c,
                Additional_Cost__c,Name,Qty__c,Plant__c,OilType__c,ZH_Premium__c,NSM_Premium__c,
                Plant__r.Name,FinalPriceFOR__c,SKU__c,SKU__r.Name,SKU__r.GST__c,BDO_Premium__c,SKU__r.ProductCode,
                SaudaBooking__c, RolloutPrice__c,NetWeight__c, Discount__c, Liquidation_Discount__c, Margin__c
                FROM SaudaBookingSKU__c
                WHERE 
                //SaudaBooking__r.Active__c = true AND 
                SaudaBooking__c = :saudaId 
                AND (
        SaudaBooking__r.CP_Sauda__c = true
        OR ((Discount__c != null AND Discount__c != 0) 
            OR (Liquidation_Discount__c != null AND Liquidation_Discount__c != 0))
      )
                //AND ((Discount__c != null AND Discount__c !=0) OR (Liquidation_Discount__c != null AND Liquidation_Discount__c !=0)) 
                WITH SECURITY_ENFORCED];
    }
     
    
    /**
* @description Fetches base SKUs by oil type, fraction, and plant. Includes UOM as subquery.
* @param oilTypeList Set of oil types.
* @param fractionIdList Set of Fraction Ids.
* @param plantIdSet Set of PlantDepotRake Ids.
* @param limitSize Max records to return.
* @param offset Starting offset for pagination.
* @return List of Product2 records.
*/
    /*public static List<Product2> getSimulatedPriceDataQuery( Set<String> oilTypeList,Set<Id> fractionIdList,Set<Id> plantIdSet,Integer limitSize,Integer offset,Set<String> verticalSet,Boolean isRasoi){
        List<Product2> prodList = new List<Product2> ();
        
        prodList=  [SELECT Id, Name,Fraction__c,Fraction__r.Name,OilType__c,PackGroup__c,PackSizeQuantity__c,Vertical__c,(Select id,cgcloud__Weight__c,cgcloud__Is_Order_Unit__c,cgcloud__Unit_Type__c from cgcloud__Units_of_Measure__r WHERE cgcloud__Is_Order_Unit__c = true LIMIT 1),(Select id,ParentIngredient__c,PercentageUsed__c,ParentIngredient__r.Type__c,ParentIngredient__r.BasePrice__c,SKU__c,ParentIngredient__r.ConversionPMT__c,ParentIngredient__r.ParentIngredient__c from Ingredients__r WHERE RecordType.Name =: Label.NSM_SKU_Ingredients AND Plant__c IN :plantIdSet Order By SKU__c)
                    FROM Product2
                    WHERE  OilType__c IN :oilTypeList AND //Fraction__c IN :fractionIdList AND
                    IsBaseSKU__c = true AND IsActive = true AND Vertical__c IN  :verticalSet  
                    AND  ID  IN  (Select Product__c from ProductAssignment__c  WHERE PlantDepotRake__c IN :plantIdSet AND IsActive__c  = true)
                    AND ID IN ( SELECT cgcloud__Product__c FROM cgcloud__Unit_of_Measure__c WHERE cgcloud__Is_Order_Unit__c = true )
                    ORDER BY CreatedDate DESC
                    LIMIT :limitSize OFFSET :offset];
        return prodList;
    }*/
    public static List<Product2> getSimulatedPriceDataQuery(Set<String> oilTypeList, Set<Id> fractionIdList, Set<Id> plantIdSet, Integer limitSize, Integer offset, Set<String> verticalSet, Boolean isRasoi) {
        List<Product2> prodList = new List<Product2>();
        String recordTypeName = Label.NSM_SKU_Ingredients;
        
        // Base WHERE clause
        String baseWhere = 'WHERE OilType__c IN :oilTypeList AND IsBaseSKU__c = true AND IsActive = true AND Vertical__c IN :verticalSet ' +
            'AND ID IN (SELECT Product__c FROM ProductAssignment__c WHERE PlantDepotRake__c IN :plantIdSet AND IsActive__c = true) ' +
            'AND ID IN (SELECT cgcloud__Product__c FROM cgcloud__Unit_of_Measure__c WHERE cgcloud__Is_Order_Unit__c = true)';
        
        // Add Fraction__c condition based on OilType__c
        if (oilTypeList != null && oilTypeList.contains(System.Label.Oil_Type_Rasoi)) {
            baseWhere += ' AND ( (OilType__c = \''+System.Label.Oil_Type_Rasoi+'\' AND Fraction__c = null) OR (OilType__c != \''+System.Label.Oil_Type_Rasoi+'\' AND Fraction__c IN :fractionIdList) )';
        } else {
            baseWhere += ' AND Fraction__c IN :fractionIdList';
        }
        
        // Construct the full SOQL query
        String soql = 'SELECT Id, Name, Fraction__c, Fraction__r.Name, OilType__c, PackGroup__c, PackSizeQuantity__c, Vertical__c, ' +
            '(SELECT id, cgcloud__Weight__c, cgcloud__Is_Order_Unit__c, cgcloud__Unit_Type__c FROM cgcloud__Units_of_Measure__r WHERE cgcloud__Is_Order_Unit__c = true LIMIT 1), ' +
            '(SELECT id, ParentIngredient__c, PercentageUsed__c, ParentIngredient__r.Type__c, ParentIngredient__r.BasePrice__c, SKU__c, ParentIngredient__r.ConversionPMT__c, ParentIngredient__r.ParentIngredient__c ' +
            'FROM Ingredients__r WHERE RecordType.Name = :recordTypeName AND Plant__c IN :plantIdSet ORDER BY SKU__c) ' +
            'FROM Product2 ' + baseWhere + 
            ' ORDER BY CreatedDate DESC ' +
            ' LIMIT :limitSize OFFSET :offset';
        
        // Execute the query
        prodList = Database.query(soql);
        
        return prodList;
    }
    
    /**
* @description Fetches all active competitor master records.
* @return List of CompetitorMaster__c records.
*/
    public static List<CompetitorMaster__c> getCompetitorMaster() {
        List<CompetitorMaster__c> activeCompetitors = [
            SELECT Id, Name 
            FROM CompetitorMaster__c 
            WHERE IsActive__c = true
        ];
        
        return activeCompetitors;
    }
    
    /**
* @param productId Id of the Product2 record
* @return Product2 record with selected fields
* @description Retrieves a specific product based on its Id
*/
    public static Product2 getProduct(Id productId){
        return [SELECT Id,Name,PackGroup__c,BrandValue__c,Vertical__c,Fraction__c, Fraction__r.Name,OilType__c,IsIngredients__c FROM Product2 WHERE ID =: productId WITH SECURITY_ENFORCED];
    }
    
    /**
* @return List of active ProductAssignment__c records with loose vertical and specific type
* @description Gets all plant options available for Loose verticals
*/
    public static List<ProductAssignment__c> getPlantOptions() {
        List<ProductAssignment__c> records = [
            SELECT Id, PlantDepotRake__r.Name, PlantDepotRake__c
            FROM ProductAssignment__c
            WHERE Product__r.Vertical__c =: Constants.PA_Vertical_Loose AND Type__c=:Constants.PA_Type AND IsActive__c = true AND Product__r.IsActive = true
            WITH SECURITY_ENFORCED
        ];
        return records;
    }

    public static List<ProductAssignment__c> getOilTypesCompetitorPrice() {

        User currentUser = [
            SELECT Id, Name, UserVertical__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
        
        List<String> userVerticalLabels = new List<String>();
        if (String.isNotBlank(currentUser.UserVertical__c)) {
            userVerticalLabels = new List<String>(currentUser.UserVertical__c.split(';'));
        }
        
        // 2. Map Picklist Label → API Value
        Schema.DescribeFieldResult fieldResult = SKUPriceRollout__c.Vertical__c.getDescribe();
        Map<String, String> labelToApiMap = new Map<String, String>();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            labelToApiMap.put(entry.getLabel(), entry.getValue());
        }
        
        // 3. Convert user’s labels into API values
        List<String> userVerticalApis = new List<String>();
        for (String lbl : userVerticalLabels) {
            if (labelToApiMap.containsKey(lbl)) {
                userVerticalApis.add(labelToApiMap.get(lbl));
            }
        }

       List<ProductAssignment__c> records = [
            SELECT Product__r.OilType__c
            FROM ProductAssignment__c
            WHERE IsActive__c = true 
            AND Product__r.IsActive = true
            AND Product__r.Vertical__c IN :userVerticalApis
            WITH SECURITY_ENFORCED
        ];
        return records;
    }
    
    /**
* @param plantDepotName Name of the plant
* @return List of ProductAssignment__c records with OilType and Vertical
* @description Fetch oil types for the given plant depot
*/
    public static List<ProductAssignment__c> getOilTypes(String plantDepotName) {
        List<ProductAssignment__c> records = [
            SELECT Product__r.OilType__c,Product__r.Vertical__c
            FROM ProductAssignment__c
            WHERE  Product__r.Vertical__c =:System.Label.PA_Vertical_Loose AND Type__c = :System.Label.PDR_RecordType_Plant AND IsActive__c = true 
            AND Product__r.IsActive = true
            AND PlantDepotRake__r.Name = :plantDepotName WITH SECURITY_ENFORCED
        ];
        return records;
    }

    
    
    /**
* @param oilType String value representing oil type
* @return List of ProductAssignment__c records by oil type
* @description Gets product assignments based on given oil type and loose vertical
*/
    public static List<ProductAssignment__c> getCategoriesByOilType(String oilType) {
        List<ProductAssignment__c> records = [
            SELECT Id, Product__r.Name,Product__r.Vertical__c
            FROM ProductAssignment__c
            WHERE Product__r.Vertical__c =: Constants.PA_Vertical_Loose
            AND IsActive__c = true AND Product__r.IsActive = true
            AND Type__c=:Constants.PA_Type
            AND Product__r.OilType__c = :oilType
            WITH SECURITY_ENFORCED
        ];
        return records;
    }

    public static List<Product2> getCategoriesByOilTypeCompetitor(String oilType) {

         User currentUser = [
            SELECT Id, Name, UserVertical__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
        
        List<String> userVerticalLabels = new List<String>();
        if (String.isNotBlank(currentUser.UserVertical__c)) {
            userVerticalLabels = new List<String>(currentUser.UserVertical__c.split(';'));
        }
        
        // 2. Map Picklist Label → API Value
        Schema.DescribeFieldResult fieldResult = SKUPriceRollout__c.Vertical__c.getDescribe();
        Map<String, String> labelToApiMap = new Map<String, String>();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            labelToApiMap.put(entry.getLabel(), entry.getValue());
        }
        
        // 3. Convert user’s labels into API values
        List<String> userVerticalApis = new List<String>();
        for (String lbl : userVerticalLabels) {
            if (labelToApiMap.containsKey(lbl)) {
                userVerticalApis.add(labelToApiMap.get(lbl));
            }
        }

        List<Product2> records = [
            SELECT Id,  Name,IsBaseSKU__c,Vertical__c,PackGroup__c
            FROM Product2 
            WHERE Vertical__c IN :userVerticalApis
            AND IsActive = true AND IsBaseSKU__c = true
            AND OilType__c = :oilType
            WITH SECURITY_ENFORCED
        ];
        return records;
    }
    
    /**
* @return List of states as Geography__c records
* @description Fetches all state geographies
*/
    public static List<Geography__c> getStates() {
        return [SELECT Id, Name FROM Geography__c WHERE RecordType.DeveloperName =:System.label.Geography_RecordType_State WITH SECURITY_ENFORCED Order By Name];
    }
    
    /**
* @return State of the current user
* @description Retrieves the State field value of the currently logged-in user
*/
    public static String getCurrentUserState() {
        User currentUser = [SELECT Id, State,UserVertical__c FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
        return currentUser.State;
    }
    
    /**
* @param stateId Id of the parent state geography
* @return List of city geography records related to state
* @description Gets cities under a given state
*/
    public static List<Geography__c> getCitiesByState(String stateId) {
        return [
            SELECT Id, Name, ParentGeography__c,Freight_Zone__r.Name
            FROM Geography__c
            WHERE RecordType.DeveloperName =: System.label.Geography_RecordType_City
            AND Freight_Zone__r.ParentGeography__c = :stateId AND Active__c  = true
            WITH SECURITY_ENFORCED
            Order By Name
        ];
    }
    
    /**
* @return List of oil types for verticals not equal to 'Loose'
* @description Fetches distinct oil types used in active product assignments for non-loose verticals
*/
    // public static List<ProductAssignment__c> getOilTypeName() {
    //     List<ProductAssignment__c> records = [
    //         SELECT Product__r.OilType__c
    //         FROM ProductAssignment__c
    //         WHERE IsActive__c = true 
    //         AND Product__r.IsActive = true
    //         AND Product__r.Vertical__c !=: Constants.PA_Vertical_Loose
    //         WITH SECURITY_ENFORCED
    //     ];
    //     return records;
    // }
    
    public static List<ProductAssignment__c> getOilTypeName() {
        // 1. Get current user’s verticals (multi-picklist)
        User currentUser = [
            SELECT Id, Name, UserVertical__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
        
        List<String> userVerticalLabels = new List<String>();
        if (String.isNotBlank(currentUser.UserVertical__c)) {
            userVerticalLabels = new List<String>(currentUser.UserVertical__c.split(';'));
        }
        
        // 2. Map Picklist Label → API Value
        Schema.DescribeFieldResult fieldResult = SKUPriceRollout__c.Vertical__c.getDescribe();
        Map<String, String> labelToApiMap = new Map<String, String>();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            labelToApiMap.put(entry.getLabel(), entry.getValue());
        }
        
        // 3. Convert user’s labels into API values
        List<String> userVerticalApis = new List<String>();
        for (String lbl : userVerticalLabels) {
            if (labelToApiMap.containsKey(lbl)) {
                userVerticalApis.add(labelToApiMap.get(lbl));
            }
        }
        
        // 4. Query only if user has matching verticals
        List<ProductAssignment__c> records = new List<ProductAssignment__c>();
        if (!userVerticalApis.isEmpty()) {
            records = [
                SELECT Product__r.OilType__c, Product__r.Vertical__c
                FROM ProductAssignment__c
                WHERE IsActive__c = true 
                AND Product__r.IsActive = true
                AND Product__r.Vertical__c IN :userVerticalApis
                WITH SECURITY_ENFORCED
            ];
        }
        
        return records;
    }
    
    
    /**
* @param oilType Specific oil type name
* @return List of Product2 categories filtered by oil type
* @description Fetch base SKUs by oil type from non-loose verticals
*/
    // public static List<Product2> getCategoriesByOilTypeNames(String oilType) {
    //     List<Product2> records = [
    //         SELECT Id,  Name,IsBaseSKU__c,Vertical__c
    //         FROM Product2 
    //         WHERE Vertical__c !=: Constants.PA_Vertical_Loose
    //         AND IsActive = true AND IsBaseSKU__c = true
    //         AND OilType__c = :oilType
    //         WITH SECURITY_ENFORCED
    //     ];
    //     return records;
    // }
    
    public static List<Product2> getCategoriesByOilTypeNames(String oilType) {
        // 1. Get current user’s verticals
        User currentUser = [
            SELECT Id, Name, UserVertical__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
        
        List<String> userVerticalLabels = new List<String>();
        if (String.isNotBlank(currentUser.UserVertical__c)) {
            userVerticalLabels = new List<String>(currentUser.UserVertical__c.split(';'));
        }
        
        // 2. Map Picklist Label → API Value for Vertical__c
        Schema.DescribeFieldResult fieldResult = Product2.Vertical__c.getDescribe();
        Map<String, String> labelToApiMap = new Map<String, String>();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            labelToApiMap.put(entry.getLabel(), entry.getValue());
        }
        
        // 3. Convert user’s labels into API values
        List<String> userVerticalApis = new List<String>();
        for (String lbl : userVerticalLabels) {
            if (labelToApiMap.containsKey(lbl)) {
                userVerticalApis.add(labelToApiMap.get(lbl));
            }
        }
        
        // 4. Query Products only if user has valid verticals
        List<Product2> records = new List<Product2>();
        if (!userVerticalApis.isEmpty()) {
            records = [
                SELECT Id, Name, IsBaseSKU__c, Vertical__c
                FROM Product2
                WHERE IsActive = true 
                AND IsBaseSKU__c = true
                AND OilType__c = :oilType
                AND Vertical__c IN :userVerticalApis
                WITH SECURITY_ENFORCED
            ];
        }
        
        return records;
    }
    
    
    /**
* @return List of users reporting to current user
* @description Retrieves all users under the current user's management Zone Wise
*/
    public static List<User> userList(List<String> zoneList) {
        if (zoneList.isEmpty() || zoneList.contains('All')) {
            return [ 
                SELECT Id, Name 
                FROM User 
                WHERE (ManagerId = :UserInfo.getUserId()  OR Sauda_Manager__c = :UserInfo.getUserId()) AND IsActive = TRUE
                WITH SECURITY_ENFORCED
            ];
        } else {
            return [
                SELECT Id, Name 
                FROM User 
                WHERE (ManagerId = :UserInfo.getUserId() 
                 OR Sauda_Manager__c = :UserInfo.getUserId()) AND IsActive = TRUE  AND Zone__c IN :zoneList
                WITH SECURITY_ENFORCED
            ];
        } 
    }

    public static List<UserPlantMapping__c> upmListZoneWise(List<String> zoneList, String vertApi) {
        if (zoneList.isEmpty() || zoneList.contains('All')) {
            return [
                SELECT User__c, User__r.Id, User__r.Name
                FROM UserPlantMapping__c
                WHERE IsActive__c = TRUE
                AND Geography__r.Active__c = TRUE
                AND Geography__r.ParentGeography__r.RecordType.Name = 'Zone'
                AND User__r.IsActive = TRUE
                AND (User__r.ManagerId = :UserInfo.getUserId()  
                     OR User__r.Sauda_Manager__c = :UserInfo.getUserId() )
                AND User__r.MT_Horeca__c = FALSE
                AND Vertical__c = :vertApi
                WITH SECURITY_ENFORCED ];
        } 
        else {
            return [SELECT User__c, User__r.Id, User__r.Name
                    FROM UserPlantMapping__c
                    WHERE IsActive__c = TRUE
                    AND Geography__r.Active__c = TRUE
                    AND Geography__r.ParentGeography__r.RecordType.Name = 'Zone'
                    AND Geography__r.ParentGeography__r.Name IN :zoneList
                    AND User__r.IsActive = TRUE
                    AND (User__r.ManagerId = :UserInfo.getUserId() 
                         OR User__r.Sauda_Manager__c = :UserInfo.getUserId())
                    AND User__r.MT_Horeca__c = FALSE
                    AND Vertical__c = :vertApi
                    WITH SECURITY_ENFORCED];
                }
    }
    
    /**
* @return List of users reporting to current user 
* @description Retrieves all users under the current user's management State Wise
*/
    public static List<User> userListStateWise(List<String> stateList) {
        if (stateList.isEmpty() || stateList.contains('All')) {
            return [ 
                SELECT Id, Name  FROM User 
                WHERE (ManagerId = :UserInfo.getUserId() OR Sauda_Manager__c = :UserInfo.getUserId()) AND IsActive = TRUE
                WITH SECURITY_ENFORCED
            ];
        } else {
            
            return [
                SELECT Id, Name 
                FROM User 
                WHERE (ManagerId = :UserInfo.getUserId()  OR Sauda_Manager__c = :UserInfo.getUserId())
                //AND State IN :stateList 
                AND IsActive = TRUE
                WITH SECURITY_ENFORCED
            ];
        } 
    }

    public static List<UserPlantMapping__c> upmListStateWise(List<String> stateList , String vertApi) {
        if (stateList.isEmpty() || stateList.contains('All')) {
            return [
                SELECT User__c, User__r.Id, User__r.Name
                FROM UserPlantMapping__c
                WHERE IsActive__c = TRUE
                AND Geography__r.Active__c = TRUE
                AND Geography__r.RecordType.Name = 'State'
                AND User__r.IsActive = TRUE
                AND (User__r.ManagerId = :UserInfo.getUserId()  
                     OR User__r.Sauda_Manager__c = :UserInfo.getUserId() )
                AND Vertical__c = :vertApi
                AND User__r.MT_Horeca__c = FALSE
                WITH SECURITY_ENFORCED ];
        } 
        else {
            return [SELECT User__c, User__r.Id, User__r.Name
                    FROM UserPlantMapping__c
                    WHERE IsActive__c = TRUE
                    AND Geography__r.Active__c = TRUE
                    AND Geography__r.RecordType.Name = 'State'
                    AND Geography__r.Name IN :stateList
                    AND User__r.IsActive = TRUE
                    AND (User__r.ManagerId = :UserInfo.getUserId() 
                         OR User__r.Sauda_Manager__c = :UserInfo.getUserId())
                    AND Vertical__c = :vertApi
                    AND User__r.MT_Horeca__c = FALSE
                    WITH SECURITY_ENFORCED];
                }
    }
    
    /**
* @param idSet Set of manager Ids
* @return List of users reporting to specified managers
* @description Retrieves user list by manager Ids
*/
    public static List<User> useridSetList(Set<Id> idSet) {
        return [Select Id,Name,Headquarter__c from  User WHERE (ManagerId IN : idSet OR Sauda_Manager__c IN : idSet) AND IsActive = TRUE WITH SECURITY_ENFORCED] ;  
    }
    
    /**
* @param zhList List of ZH Ids (as strings)
* @return List of users reporting to specified ZH users
* @description Retrieves user list by ZH manager Ids
*/
    public static List<User> userzhListList(List<String> zhList) {
        return [Select Id,Name from  User WHERE (ManagerId IN : zhList  OR Sauda_Manager__c IN :zhList) AND IsActive = TRUE WITH SECURITY_ENFORCED];  
    }
    
    /**
* @return List of product assignments with oil type and base SKU info
* @description Retrieves product assignments for active base SKUs
*/
    public static  List<ProductAssignment__c> getOilType() {
        List<ProductAssignment__c> prAssigmentList = [Select Id,PlantDepotRake__r.name,Product__r.Name,Product__r.OilType__c, Product__r.PackGroup__c ,Product__r.Vertical__c , Product__r.Fraction__r.name,IsActive__c,Product__r.IsActive,Product__r.IsBaseSKU__c  
                                                      from ProductAssignment__c where IsActive__c  = true and Product__r.IsActive = true AND Product__r.OilType__c != NULL  WITH SECURITY_ENFORCED];//and Product__r.IsBaseSKU__c = true];
        return prAssigmentList;
    }
    
    /**
* @description Fetches all regions (Zones).
* @return List of Geography__c records with RecordType = 'Zone'
*/
    public static List<Geography__c> regionOption() {
        return [Select Id,Name from  Geography__c WHERE RecordType.DeveloperName = :System.Label.Geography_RecordType_Zone WITH SECURITY_ENFORCED];
        
    }
    
    /**
* @description Fetches all states.
* @param stringZoneList Not used in current implementation.
* @return List of Geography__c records with RecordType = 'State'
*/
    public static List<Geography__c> getState() {
        return [Select Id,Name from  Geography__c WHERE RecordType.DeveloperName =:System.label.Geography_RecordType_State WITH SECURITY_ENFORCED];
    }

    /**
    * @description Fetches all regions,states ().
    * @return List of Geography__c records with RecordType = 'State'
    */
    
    public static List<Geography__c> regionStateOptions() {
        //User crntUser = [Select Id,Zone__c  From User Where Id = :UserInfo.getUserId()];
        List<UserPlantMapping__c> upmList = [Select Id,Geography__c From UserPlantMapping__c Where Geography__r.RecordType.Name = :System.Label.Geography_RecordType_Zone And User__c = :UserInfo.getUserId()];
        
        if(upmList.isEmpty()){
        	throw new AuraHandledException(System.Label.NoUserPlantMappingFound);//'No User Plant Mapping found!');   
        }
        
        //List<String> splitStrings = crntUser.Zone__c.split(';');
        List<Id> allZones = new List<Id>();
        for(UserPlantMapping__c upm : upmList){
            allZones.add(upm.Geography__c);
        }
        return [Select Id , Name, ParentGeography__c ,ParentGeography__r.Name from  Geography__c 
                WHERE RecordType.DeveloperName = :System.label.Geography_RecordType_State
                AND ParentGeography__r.RecordType.DeveloperName = :System.Label.Geography_RecordType_Zone AND ParentGeography__c IN :allZones
                AND Active__c = True AND ParentGeography__r.Active__c = True with SECURITY_ENFORCED];
    }
    
    /**
    * @description Fetches the current logged-in User.
    * @return User record of current user
    */
    public static User getCurrentUserId(){
        User currentUser = [SELECT Manager.ManagerId,Id,ManagerId,MT_Horeca__c, Name,User_Type__c, EmployeeCode__c,UserRole.Name, UserVertical__c, 
                            Profile.Name,AccountId,Sauda_Manager__c,Sauda_Manager__r.Sauda_Manager__c,Sauda_Manager__r.EmployeeCode__c,
                            Manager.EmployeeCode__c  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser;            
    }
    
    public static User getCurrentUserManagerId(Id managerId){
        User currentUser = [SELECT Id,name,Profile.UserLicense.Name,EmployeeCode__c,MT_Horeca__c,manager.EmployeeCode__c, UserRole.Name, ManagerId FROM User WHERE Id = :managerId LIMIT 1];
        return currentUser;            
    }
    
    /**
* @description Fetches ProductAssignment__c records for a given plant and verticals.
* @param plantName Name of the plant
* @param mappedVerticals Set of vertical codes
* @return List of ProductAssignment__c
*/
    public static List<ProductAssignment__c> getProductAssignments(String plantName,Set<String> mappedVerticals ){
        List<ProductAssignment__c> assignments = [SELECT Id, Name, PlantDepotRake__r.Name, Product__r.Name, Product__r.Fraction__c, Product__r.Fraction__r.Name, Product__r.Fraction__r.Id, Product__r.Id, Product__r.IsBaseSKU__c, Product__r.PackGroup__c,Product__r.Vertical__c, Product__r.OilType__c, Product__r.ProductCode
                                                  FROM ProductAssignment__c
                                                  WHERE PlantDepotRake__r.Name = :plantName AND Product__r.IsBaseSKU__c = TRUE  AND Product__r.Vertical__c In: mappedVerticals 
                                                  WITH SECURITY_ENFORCED ORDER By Product__r.OilType__c];
        
        
        
        return assignments; 
        
    }
    
    /**
* @description Fetches ProductAssignment__c records for a given plant and verticals.
* @param plantName Name of the plant
* @param mappedVerticals Set of vertical codes
* @return List of ProductAssignment__c
*/
    public static List<ProductAssignment__c> getProductAssignmentsHtProduct(String plantName,Set<String> mappedVerticals ){
        List<ProductAssignment__c> assignments = [SELECT Id, Name, PlantDepotRake__r.Name, Product__r.Name, Product__r.Fraction__c, Product__r.Fraction__r.Name, Product__r.Fraction__r.Id, Product__r.Id, Product__r.IsBaseSKU__c, Product__r.PackGroup__c,Product__r.Vertical__c, Product__r.OilType__c, Product__r.ProductCode
                                                  FROM ProductAssignment__c
                                                  WHERE PlantDepotRake__r.Name = :plantName  AND Product__r.Vertical__c In: mappedVerticals
                                                  WITH SECURITY_ENFORCED];
        
        
        return assignments; 
        
    }
    
    /**
* @description Alternate method to fetch ProductAssignment__c records with fewer fields.
* @param plantName Name of the plant
* @param mappedVerticals Set of vertical codes
* @return List of ProductAssignment__c 
*/
    public static List<ProductAssignment__c> getassignments(String plantName,Set<String> mappedVerticals ){
        List<ProductAssignment__c> assignments = [SELECT Id, Name, PlantDepotRake__r.Name, Product__r.Name,
                                                  Product__r.IsBaseSKU__c, Product__r.PackGroup__c, Product__r.OilType__c,
                                                  Product__r.PackSizeQuantity__c, Product__r.ProductCode
                                                  FROM ProductAssignment__c
                                                  WHERE PlantDepotRake__r.Name = :plantName AND Product__r.IsBaseSKU__c = TRUE
                                                  AND Product__r.Vertical__c In: mappedVerticals
                                                  WITH SECURITY_ENFORCED];
        
        return assignments; 
    } 
    
    /**
* @description Count of Competitor_LineItem__c created by a user between start and end date.
* @param userId User Id
* @param startTime Start datetime
* @param endTime End datetime
* @return Integer count of line items 
*/
    public static Integer getLineItemCountForUser(Id userId) {
        return [SELECT COUNT() FROM Competitor_LineItem__c WHERE CreatedDate=TODAY AND CreatedById = :userId WITH SECURITY_ENFORCED];
    }
    
    /**
* @description Fetches Unit of Measure records for given Product Ids.
* @param productIds Set of Product2 Ids
* @return List of cgcloud__Unit_of_Measure__c
*/
    public static List<cgcloud__Unit_of_Measure__c> getCgCloudUnitMeasure(Set<Id> productIds){
        List<cgcloud__Unit_of_Measure__c> cgcloudUnitMeasure  = [SELECT cgcloud__Product__c,cgcloud__Pieces_per_parent_unit__c, cgcloud__Weight__c,cgcloud__Product__r.BrandValue__c
                                                                 FROM cgcloud__Unit_of_Measure__c
                                                                 WHERE cgcloud__Product__c IN :productIds
                                                                 AND BaseUnit__c =: Label.NOS_Base_Unit_UOM AND Conversion_Unit__c =: Label.CS_Conv_Unit_UOM  
                                                                 WITH SECURITY_ENFORCED ORDER by createddate desc];
        return cgcloudUnitMeasure;
        
    }
    
    public static List<SKUPriceRollout__c> fetchSKUPriceWithIng(Set<Id> parentIds, String apiValue,Product2 product, Id plantId, String oilType, Id childRecordTypeId){
        return [
            SELECT Id, Ingredients__c, LoosePrice__c,ParentRollout__r.PriceRolloutCH__c,ParentRollout__r.PriceRolloutZH__c,
            ParentRollout__r.PriceRolloutBDO__c,ParentRollout__r.ZHTaskTracker__c,OwnerId,Premium__c,PriceRolloutBDO__c,
            ParentRollout__r.Status__c, Qty__c, Pending_Quantity__c FROM SKUPriceRollout__c 
            WHERE IsActive__c = true AND ParentRollout__r.Vertical__c = :apiValue AND Oil_Type__c = :oilType 
            AND Plant__c = :plantId AND ParentRollout__r.IsActive__c  = true 
            AND Fraction__c =: product.Fraction__c and RecordTypeId =:childRecordTypeId AND Ingredients__c IN :parentIds WITH SECURITY_ENFORCED];
    }
    
    /**
* @description Fetches SKUPriceRollout__c records for ZH user with filters.
* @param plantName Name of the plant
* @param mappedVerticals Set of verticals
* @param oilTypes List of oil types
* @param childRecordTypeId RecordType Id for child rollout
* @return List of SKUPriceRollout__c
*/
    public static  List<SKUPriceRollout__c>  getRolloutsForZH(String plantName,Set<String> mappedVerticals,List<String> oilTypes, Id childRecordTypeId){
        
        List<SKUPriceRollout__c> rollouts = [SELECT Id, Base_SKU__c, Oil_Type__c,Plant__c, Plant__r.Name, LoosePrice__c, Premium__c, CreatedDate, ParentRollout__c, Fraction__c,
                                             ParentRollout__r.Vertical__c, RecordTypeId, ParentRollout__r.IsActive__c, IsActive__c,Fraction__r.Name,Qty__c,
                                             Ingredients__c,Ingredients__r.Name,Ingredients__r.OilType__c
                                             FROM SKUPriceRollout__c
                                             WHERE Plant__r.Name = :plantName AND ParentRollout__r.Vertical__c In: mappedVerticals
                                             AND RecordTypeId =:childRecordTypeId
                                             AND IsActive__c = true AND ParentRollout__r.IsActive__c = true AND (ParentRollout__r.PriceRolloutCH__c = true OR ParentRollout__r.PriceRolloutZH__c = true OR ParentRollout__r.PriceRolloutBDO__c = true)
                                             WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        
        
        
        return rollouts;
    }
    
    public static List<AccountTeamMember> getATMRecs(String Vertical, Id accId){
        return [
            SELECT Id, AccountId, UserId, User.UserVertical__c, User.ManagerId
            FROM AccountTeamMember
            WHERE User.UserVertical__c = :Vertical
            AND AccountId = :accId
            LIMIT 1];
    }
    
    /**
* Retrieves SKUPriceRollout records based on plant name, mapped verticals, and oil types
* @param plantName Name of the plant
* @param mappedVerticals Set of verticals
* @param oilTypes List of oil types
* @return List of SKUPriceRollout__c records
*/
    public static  List<SKUPriceRollout__c>  getrolloutsList(String plantName,Set<String> mappedVerticals,List<String> oilTypes ){
        List<SKUPriceRollout__c> rollouts = [ SELECT Id, Base_SKU__c, Oil_Type__c, Plant__r.Name, LoosePrice__c, CreatedDate
                                             FROM SKUPriceRollout__c
                                             WHERE Plant__r.Name = :plantName
                                             AND Vertical__c In: mappedVerticals
                                             AND Oil_Type__c In: oilTypes
                                             ORDER BY CreatedDate DESC];
        
        return rollouts;
    }
    
    /**
* Fetches DPRuleEngine records by IDs
* @param recIds Set of DPRuleEngine__c record Ids
* @return List of DPRuleEngine__c
*/
    public static List<DPRuleEngine__c> getDpRuleRecs(Set<Id> recIds){
        List<DPRuleEngine__c> dpRuleLists = [Select Id,Name, TargetLevel__c,Target_Area__c, PersonaType__c, Persona__c, 
                                             Amount__c, Amount_Type__c,  IsFavorite__c ,IsActive__c , 
                                             SKUPriceRollout__c,SKUPriceRollout__r.Name , Product_Criteria__c , value__c
                                             from DPRuleEngine__c Where Id IN: recIds WITH SECURITY_ENFORCED];
        
        return dpRuleLists;
    }
    
    /**
* Gets applied DP rules created today or marked favorite by current user
* @param currentUserId Current user Id
* @return List of DPRuleEngine__c
*/
    public static List<DPRuleEngine__c> getAppliedDpRule(Id currentUserId){
        // Used in NsmPriceAppliedRulesController
        List<DPRuleEngine__c> dpRuleLists = [Select id,Name, TargetLevel__c,Target_Area__c, PersonaType__c, Persona__c,  Amount__c, Amount_Type__c,  IsFavorite__c ,IsActive__c , Plant__r.Name,
                                             SKUPriceRollout__c,SKUPriceRollout__r.Name , Product_Criteria__c , Value__c,Product_Criteria_2__c , Value2__c, ValidFrom__c, ValidTo__c,ForCustomers__c
                                             from DPRuleEngine__c Where ((CreatedDate = today) OR IsFavorite__c = true) AND CreatedById = :currentUserId WITH SECURITY_ENFORCED];
        
        return dpRuleLists;
        
    }
    
    /**
* Fetches active Cost Component Calculation Rollout metadata
* @return List of Cost_Component_Calculation_Rollout__mdt
*/
    public  static List<Cost_Component_Calculation_Rollout__mdt> getccCalculationRollout(){
        List<Cost_Component_Calculation_Rollout__mdt>  ccList =
            [SELECT MasterLabel, Label, Field_Name__c FROM Cost_Component_Calculation_Rollout__mdt 
             WHERE Active__c = true];
        return ccList;
    }
    
    /**
* Fetches active Cost Component Calculation Sauda Booking metadata
* @return List of Cost_Component_Calculation_Sauda_Booking__mdt
*/
    public static List<Cost_Component_Calculation_Sauda_Booking__mdt> getccCalculationSaudaBooking() {
        
        List<Cost_Component_Calculation_Sauda_Booking__mdt> result = 
            new List<Cost_Component_Calculation_Sauda_Booking__mdt>();
        
        Map<String, Cost_Component_Calculation_Sauda_Booking__mdt> allMdt =
            Cost_Component_Calculation_Sauda_Booking__mdt.getAll();
        
        if (allMdt == null || allMdt.isEmpty()) {
            return result;
        }
        
        for (Cost_Component_Calculation_Sauda_Booking__mdt mdt : allMdt.values()) {
            
            if (mdt == null){
                continue;
            }
            
            Boolean isActive = (mdt.Active__c != null) ? mdt.Active__c : false;
            
            if (isActive) {
                result.add(mdt);
            }
        }
        
        return result;
    }
    
    public static List<Cost_Component_Calculation_Sauda_Booking__mdt> FetchLoadCapMdt() {
    List<Cost_Component_Calculation_Sauda_Booking__mdt> result = new List<Cost_Component_Calculation_Sauda_Booking__mdt>();

    Map<String, Cost_Component_Calculation_Sauda_Booking__mdt> allMdt =
        Cost_Component_Calculation_Sauda_Booking__mdt.getAll();

    for (Cost_Component_Calculation_Sauda_Booking__mdt rec : allMdt.values()) {
        if (rec.Active__c == true &&
            rec.Label == Label.Load_Capacity_Record_Type) 
        {
            result.add(rec);
        }
    }

    return result;
}


    
    /**
* Fetches RecordTypes of CostComponent based on given labels
* @param requiredComponentLabels Set of record type names
* @return List of RecordType
*/
    public static List<RecordType> getccRecordtypeList (Set<String> requiredComponentLabels){
        List<RecordType> ccRecordtypeList = [ SELECT Id, Name
                                             FROM RecordType
                                             WHERE SObjectType = 'CostComponent__c' AND Name IN :requiredComponentLabels
                                            ];
        
        return ccRecordtypeList;
    }
    
    public static List<AccountPDR__c> getActiveAccountPDRs(Id accountId, String vertical) {
        try {
            return [SELECT Source__c, Source__r.Name, Source__r.RecordTypeId FROM AccountPDR__c 
                    WHERE AccountId__c = :accountId AND Vertical__c =: vertical AND IsActive__c = true WITH SECURITY_ENFORCED];
        } catch (Exception ex) {
            return new List<AccountPDR__c>();
        }
    }
    
    public static List<AccountPDR__c> getAllActiveAccountPDRs(String vertical) {
        try {
            return [SELECT Source__c, Source__r.Name, Source__r.RecordTypeId FROM AccountPDR__c WHERE 
                    IsActive__c = true AND Vertical__c =: vertical WITH SECURITY_ENFORCED];
        } catch (Exception ex) {
            //System.debug('Error in getActiveAccountPDRs: ' + ex.getMessage());
            return new List<AccountPDR__c>();
        }
    }
  
    public static List<BrokerShipToPartyAssignment__c> getActiveBrokerShipToPartyAssignments(Id accountId) {
    return [SELECT BrokerShipToParty__c,BrokerShipToParty__r.PartyCode__c,BrokerShipToParty__r.BillingCity, BrokerShipToParty__r.Name,Record_Type__c, BrokerShipToParty__r.RecordTypeId FROM BrokerShipToPartyAssignment__c WHERE ParentAccount__c = :accountId AND IsActive__c = true WITH SECURITY_ENFORCED];
}
    
    public static List<BrokerShipToPartyAssignment__c> getAllActiveBrokerSTPAssignments() {
    return [SELECT BrokerShipToParty__c,Record_Type__c, BrokerShipToParty__r.Name, BrokerShipToParty__r.RecordTypeId 
            FROM BrokerShipToPartyAssignment__c WHERE IsActive__c = true 
            AND Record_Type__c =: Label.BSP_RecordType_Broker WITH SECURITY_ENFORCED LIMIT 1000];
}
public static List<TraderPriceRequest__c> getApprovedTraderPriceRequests(Id plantId) {
    return [SELECT Id, Oil_Type__c, PendingQTY__c, Quantity__c, SKU__c, SKU__r.Name, Plant__r.Name, Plant__c, PricePerMT__c, DeliveryFromDate__c, DeliveryToDate__c FROM TraderPriceRequest__c WHERE Plant__c = :plantId AND Approval_Status__c = :Label.TPR_APPROVAL_STATUS_APPROVED AND IsActive__c = true WITH SECURITY_ENFORCED];
}
    
    public static List<TraderPriceRequest__c> getApprovedTPRForPlantSkuOilType(Id plantId, Id skuId, String oilType) {
    return [SELECT Id, Oil_Type__c, PendingQTY__c, Quantity__c, SKU__c, SKU__r.Name, Plant__r.Name, Plant__c, PricePerMT__c, DeliveryFromDate__c, DeliveryToDate__c 
            FROM TraderPriceRequest__c 
            WHERE Plant__c = :plantId AND SKU__c = :skuId AND Oil_Type__c = :oilType 
            AND Approval_Status__c = :Label.TPR_APPROVAL_STATUS_APPROVED AND IsActive__c = true 
            AND CreatedDate = TODAY WITH SECURITY_ENFORCED];
}

public static List<Product2> getActiveLooseOilProducts() {
    return [SELECT Id, Name, OilType__c FROM Product2 WHERE Vertical__c = :Label.PA_Vertical_Loose AND IsActive = true WITH SECURITY_ENFORCED ORDER BY Name ASC];
}
    
    public static List<TraderPriceRequest__c> getActiveTPRById(Id traderRequestId) {
    return [SELECT Id, Oil_Type__c,Duty_Condition__c, PendingQTY__c, Quantity__c, SKU__c, SKU__r.Name, Plant__r.Name, Plant__c, PricePerMT__c, DeliveryFromDate__c, DeliveryToDate__c 
            FROM TraderPriceRequest__c 
            WHERE Id = :traderRequestId AND IsActive__c = true WITH SECURITY_ENFORCED];
}

    public static List<TraderPriceRequest__c> getActiveTraderPriceRequests(Set<Id> plantIds) {
    return [SELECT Id, Oil_Type__c, SKU__r.Name, PricePerMT__c, Plant__c, DeliveryFromDate__c, DeliveryToDate__c, PendingQTY__c 
            FROM TraderPriceRequest__c WHERE Plant__c IN :plantIds AND IsActive__c = true WITH SECURITY_ENFORCED];
}
    
    /**
* Retrieves Freight Cost Component record based on parameters
* @param recordTypeDeveloperName Developer name of the record type
* @param freightZoneName Freight Zone name
* @param freightRouteName Freight Route name
* @param sourceId Source Id
* @return CostComponent__c record or null
*/
    public static CostComponent__c getFreightCostComponent(String recordTypeDeveloperName, String freightZoneName, String freightRouteName, Id sourceId) {
        List<CostComponent__c> results = [
            SELECT Sales_FreightCost__c
            FROM CostComponent__c
            WHERE RecordType.DeveloperName = :recordTypeDeveloperName
           //Anirudh AND FreightZone__r.Name = :freightZoneName
            //ANirudh AND FreightRoute__r.Name = :freightRouteName
            AND Source__c = :sourceId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return results.isEmpty() ? null : results[0];
    }
    
    /**
* Fetches active cost components for the given product IDs
* @param productIds Set of SKU IDs
* @return List of CostComponent__c
*/
    public static List<CostComponent__c> getccList(Set<Id> productIds){
        
        List<CostComponent__c> ccList = [ SELECT Id, SKU__c, RecordTypeId, IsActive__c 
                                         FROM CostComponent__c 
                                         WHERE SKU__c IN :productIds AND IsActive__c = TRUE
                                         AND ValidFrom__c <= :Date.today() AND ValidTo__c >= :Date.today()];
        
        return ccList ;
        
    }
    
    /**
* Fetches all active DPRuleEngine__c records for PersonaType 'ZH'.
* @return List of DPRuleEngine__c records.
*/
    public static List<DPRuleEngine__c> getZHDPRules(){
        List<DPRuleEngine__c> allRules = [ SELECT Persona__c, PersonaType__c, Product_Criteria__c, Value__c, Amount_Type__c, Amount__c
                                          FROM DPRuleEngine__c
                                          WHERE IsActive__c = true AND PersonaType__c   = 'ZH'];
        return allRules ;
    }
    
    /**
* Retrieves today's DPRuleEngine__c records based on userType.
* @param userType Type of persona (e.g., 'ZH', 'BDO').
* @return List of DPRuleEngine__c records matching criteria.
*/
    public static List<DPRuleEngine__c> getDPRuleRecs(String userType){
        List<DPRuleEngine__c> allRules = [ SELECT SKU__c, Amount__c,Submitted_By_Role__c, Amount_Type__c, Persona__c,PersonaType__c, 
                                          Product_Criteria__c, Value__c, CustomerGroup__c
                                          FROM DPRuleEngine__c WHERE IsActive__c = true AND createdDate = TODAY
                                          AND PersonaType__c = :userType WITH SECURITY_ENFORCED];
        
        return allRules ;
    }
    
    /**
* Dynamically queries CostComponent__c records for a given SKU.
* @param skuId SKU Id.
* @param recordTypeNames Set of Record Type names.
* @param fieldSet Set of fields to include in query.
* @return List of SObject results based on query.
*/
    public static List<SObject> getCostComponents(String skuId, Set<String> recordTypeNames, Set<String> fieldSet) {
        if (String.isBlank(skuId) || recordTypeNames.isEmpty() || fieldSet.isEmpty()) {
            return new List<SObject>();
        }
        
        String fieldString = String.join(new List<String>(fieldSet), ', ');
        String productIdStr = '\'' + String.escapeSingleQuotes(skuId) + '\'';
        String recordTypesStr = '\'' + String.join(new List<String>(recordTypeNames), '\', \'') + '\'';
        
        String query = 'SELECT RecordType.Name, ' + fieldString + ', Source__c ' +
            ' FROM CostComponent__c ' +
            ' WHERE SKU__c = ' + productIdStr +
            ' AND RecordType.Name IN (' + recordTypesStr + ')' +
            ' AND IsActive__c = true';
        
        return Database.query(query);
    }
    
    /**
* Returns PlantDepotRake__c Id for a given plant name.
* @param plantName Name of the plant.
* @return Id of PlantDepotRake__c record.
*/
    public static Id getplantIdFromName(String plantName){
        Id plantId = [SELECT Id FROM PlantDepotRake__c WHERE Name = :plantName WITH SECURITY_ENFORCED LIMIT 1].Id;
        return plantId;   
    }
    
    /**
* Fetches one active SKUPriceRollout__c record for BP calculation based on given criteria.
* @param mappedVerticals Vertical name.
* @param oilType Oil Type value.
* @param plantId Plant record Id.
* @param childRecordTypeId RecordTypeId of the child SKU rollout.
* @return List of SKUPriceRollout__c records (max 1).
*/
    public static List<SKUPriceRollout__c> getSKURolloutForCalulatingBP(String mappedVerticals, String oilType, Id plantId, Id childRecordTypeId){
        
        List<SKUPriceRollout__c> rollouts = [ SELECT Id, LoosePrice__c, Qty__c, Pending_Quantity__c
                                             FROM SKUPriceRollout__c
                                             WHERE IsActive__c = true 
                                             AND ParentRollout__r.Vertical__c = :mappedVerticals AND Oil_Type__c = :oilType
                                             AND Plant__c = :plantId AND ParentRollout__r.IsActive__c =true 
                                             AND RecordTypeId =:childRecordTypeId LIMIT 1 ];
        return rollouts;
    }
    
    /**
* Fetches all active parent SKUPriceRollout__c records.
* @param parentRecordTypeId RecordTypeId of parent SKU.
* @return List of SKUPriceRollout__c records.
*/
    public static List<SKUPriceRollout__c> getParentSKUQuery(Id parentRecordTypeId){
        List<SKUPriceRollout__c> rollouts = [ SELECT Id, PriceRolloutBDO__c, Status__c
                                             FROM SKUPriceRollout__c 
                                             WHERE IsActive__c = true AND RecordTypeId =:parentRecordTypeId ];
        return rollouts;
    }
    
    /**
* Fetches Premium-type active DP rules.
* @return List of DPRuleEngine__c rules with Amount_Type__c = 'Premium'.
*/
    public static List<DPRuleEngine__c> getPremiumDPRulesQuery(){
        List<DPRuleEngine__c> rules = [ SELECT Product_Criteria__c, Value__c
                                       FROM DPRuleEngine__c
                                       WHERE Amount_Type__c = 'Premium' AND IsActive__c = true ];
        return rules;
    }
    
    /**
* Fetches User records by given Ids.
* @param stringList List of User Ids.
* @return List of User records.
*/
    public static List<User> getUserListInfo(List<String> stringList){
        List<User> userList = [Select id ,Name,EmployeeCode__c From USER WHERE ID IN :stringList];
        return userList;
    }
    
    /**
* Fetches ProductAssignment__c records for a plant, vertical and oil types.
* @param plantId Plant record Id.
* @param vertical Vertical string.
* @param oilTypes List of oil types.
* @return List of ProductAssignment__c records.
*/
    public static List<ProductAssignment__c> getProductsForPlant(Id plantId, String vertical, List<String> oilTypes){
        String apiValue = hbcSaudaBookingController.getAPIName(vertical);
        List<ProductAssignment__c> assignments = new List<ProductAssignment__c>();
        if(apiValue == Label.Vertical_HBC){
            assignments = [SELECT Product__c, Product__r.Name, Product__r.PackGroup__c, Product__r.Fraction__c, Product__r.GST__c,Product__r.ProductCode, 
                           Product__r.OilType__c FROM ProductAssignment__c WHERE PlantDepotRake__c = :plantId AND Product__r.IsActive = true 
                           AND Product__r.Vertical__c = :apiValue AND Product__r.IsBaseSKU__c = true AND Product__r.OilType__c IN :oilTypes
                           WITH SECURITY_ENFORCED ORDER BY Product__r.Name ASC];
        }
        else if(apiValue == Label.Vertical_HT){
            assignments = [SELECT Product__c, Product__r.Name, Product__r.PackGroup__c, Product__r.Fraction__c, Product__r.GST__c,Product__r.ProductCode, 
                           Product__r.OilType__c FROM ProductAssignment__c WHERE PlantDepotRake__c = :plantId AND Product__r.IsActive = true 
                           AND Product__r.Vertical__c = :apiValue AND Product__r.OilType__c IN :oilTypes AND Product__r.PackGroup__c =: Label.PackGroupBP
                           WITH SECURITY_ENFORCED ORDER BY Product__r.Name ASC];
        }
        else{
            assignments = [SELECT Product__c, Product__r.Name, Product__r.PackGroup__c, Product__r.Fraction__c, Product__r.GST__c,Product__r.ProductCode, 
                           Product__r.OilType__c FROM ProductAssignment__c WHERE PlantDepotRake__c = :plantId AND Product__r.IsActive = true 
                           AND Product__r.Vertical__c = :apiValue AND Product__r.OilType__c IN :oilTypes
                           WITH SECURITY_ENFORCED ORDER BY Product__r.Name ASC];
        }
        return assignments;
    }
    
    public static List<ProductAssignment__c> getAllProducts(String vertical, List<String> oilTypes){
        String apiValue = hbcSaudaBookingController.getAPIName(vertical);
        List<ProductAssignment__c> assignments = new List<ProductAssignment__c>();
        if(apiValue == Label.Vertical_HBC){
            assignments = [SELECT Product__c, Product__r.Name, Product__r.PackGroup__c, Product__r.Fraction__c, Product__r.GST__c,Product__r.ProductCode, 
                           Product__r.OilType__c FROM ProductAssignment__c WHERE Product__r.IsActive = true 
                           AND Product__r.Vertical__c = :apiValue AND Product__r.IsBaseSKU__c = true AND Product__r.OilType__c IN :oilTypes
                           WITH SECURITY_ENFORCED ORDER BY Product__r.Name ASC];
        }else{
            assignments = [SELECT Product__c, Product__r.Name, Product__r.PackGroup__c, Product__r.Fraction__c, Product__r.GST__c,Product__r.ProductCode, 
                           Product__r.OilType__c FROM ProductAssignment__c WHERE Product__r.IsActive = true 
                           AND Product__r.Vertical__c = :apiValue AND Product__r.OilType__c IN :oilTypes
                           WITH SECURITY_ENFORCED ORDER BY Product__r.Name ASC];
        }
        return assignments;
    }
    
    /**
* Aggregates PackGroups for given oil types.
* @param oilTypes List of oil type strings.
* @return List of AggregateResult with PackGroup.
*/
    public static List<AggregateResult> getPackGroupsOfOilTypeQuery(List<String> oilTypes){
        List<AggregateResult> results = [ SELECT Product__r.PackGroup__c PackGroup
                                         FROM ProductAssignment__c
                                         WHERE Product__r.OilType__c In :oilTypes
                                         GROUP BY Product__r.PackGroup__c ];
        return results;
    }
    
    /**
* Gets custom notification type used for Sauda Booking.
* @return CustomNotificationType record.
*/
    public static CustomNotificationType fetchCustomNotification(String developerName) {
        CustomNotificationType notificationType = [SELECT Id
                                                   FROM CustomNotificationType
                                                   WHERE DeveloperName =: developerName
                                                   LIMIT 1];
        return notificationType;
    }
    
    /**
* Gets today's or favorite DPRuleEngine__c records for a specific SKU.
* @param parentSkuId SKUPriceRollout__c Id.
* @return List of DPRuleEngine__c rules.
*/
    public static List<DPRuleEngine__c> getDPRuleResult(String vertApi,String plantId) {
        List<DPRuleEngine__c> dpEngList = [
            SELECT Id, Name, TargetLevel__c, Target_Area__c, PersonaType__c, Persona__c,
            Amount__c, Amount_Type__c, IsFavorite__c, IsActive__c,
            SKUPriceRollout__c, SKUPriceRollout__r.Name, CreatedBy.Name, CreatedById,
            Product_Criteria__c, Value__c, Product_Criteria_2__c, Value2__c
            FROM DPRuleEngine__c
            WHERE (CreatedDate = TODAY OR IsFavorite__c = TRUE)
            AND IsActive__c = TRUE
            AND CreatedById = :UserInfo.getUserId()
            AND Plant__c = :plantId
            AND Vertical__c = :vertApi
        ];
        return dpEngList;
    }
    
    
    public static List<DPRuleEngine__c> getDPRuleResultZH(String parentSkuId) {
        List<DPRuleEngine__c> dpEngList = [
            SELECT Id, Name, TargetLevel__c, Target_Area__c, PersonaType__c, Persona__c,
            Amount__c, Amount_Type__c, IsFavorite__c, IsActive__c,
            SKUPriceRollout__c, SKUPriceRollout__r.Name, CreatedBy.Name,
            Product_Criteria__c, Value__c
            FROM DPRuleEngine__c
            WHERE ((CreatedDate = TODAY AND IsActive__c = TRUE) OR IsFavorite__c = TRUE)
            AND SKUPriceRollout__c = :parentSkuId AND CreatedById =:Userinfo.getUserId() AND PersonaType__c = 'BDO'
        ];
        return dpEngList;
    }
    
    /**
* Gets DPRuleEngine__c records in bulk for a set of SKUPriceRollout__c Ids.
* @param parentSkuId Set of parent SKU ids.
* @return List of DPRuleEngine__c rules.
*/
    public static List<DPRuleEngine__c> getDPRuleResultBulk(Set<Id> parentSkuId) {
        List<DPRuleEngine__c> dpEngList = [
            SELECT Id, Name, TargetLevel__c, Target_Area__c, PersonaType__c, Persona__c,
            Amount__c, Amount_Type__c, IsFavorite__c, IsActive__c,
            SKUPriceRollout__c, SKUPriceRollout__r.Name, CreatedBy.Name,
            Product_Criteria__c, Value__c
            FROM DPRuleEngine__c
            WHERE ((CreatedDate = TODAY AND IsActive__c = TRUE) OR IsFavorite__c = TRUE)
            AND SKUPriceRollout__c IN :parentSkuId
        ];
        return dpEngList;
    }
    
    /**
* Gets custom notification type used for price rollout alerts.
* @return CustomNotificationType record.
*/
    public static CustomNotificationType getCustomNotification() {
        CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName =: System.label.NSM_CustomNotification_Price_Rollout_Notification LIMIT 1];
        return notificationType;
    }
    
    
    /**
* Retrieves all active PlantDepotRake__c records of type PA.
* @return List of active PlantDepotRake__c.
*/
    public static List<PlantDepotRake__c> getActivePlantsName() {
        return [
            SELECT Id, Name, RecordType.Name
            FROM PlantDepotRake__c
            WHERE RecordType.Name =: Constants.PA_Type AND IsActive__c = true WITH SECURITY_ENFORCED ];
    }
    
    /**
* Gets DPRuleEngine__c rules created by current user and linked to given rollout Ids.
* @param parentRolloutIds Set of rollout Ids.
* @param currentUserId Current user Id.
* @return List of DPRuleEngine__c records.
*/
    public static List<DPRuleEngine__c> getRulesOfCurrentUser(Set<Id> parentRolloutIds,Id currentUserId) {
        return [SELECT Id, Name, Value__c, Product_Criteria__c, SKUPriceRollout__c,Amount_Type__c,IsActive__c
                FROM DPRuleEngine__c
                WHERE 
                //SKUPriceRollout__c IN :parentRolloutIds AND 
                CreatedById = :currentUserId AND PersonaType__c = 'BDO' WITH SECURITY_ENFORCED];
    }
    
    /**
* Fetches direct subordinates of a user.
* @param curntUser Current user Id.
* @return List of User records.
*/
    public static List<User> returnUserList(Id curntUser){
        
         return  [SELECT Id FROM User WHERE ManagerId = :curntUser OR Sauda_Manager__c = :curntUser];
    }
    
    /**
* Fetches users who are two levels below the current user in hierarchy.
* @param curntUser Current user Id.
* @return List of User records.
*/
    public static List<User> returnUserListBDO(Id curntUser){
        return [SELECT Id,Name,Manager.ManagerId FROM User WHERE Manager.ManagerId = :curntUser OR  Sauda_Manager__r.Sauda_Manager__c = :curntUser];
    }
    
    /**
* Fetches users who are two levels below the current user in hierarchy.
* @param curntUser Current user Id.
* @return List of User records.
*/
    public static List<User> returnUsersBDOStateWise(Id curntUser, String stateCode){
        return [SELECT Id,Name,Manager.ManagerId FROM User WHERE (ManagerId = :curntUser OR Sauda_Manager__c = :curntUser) AND State__c = :stateCode and IsActive = true];
    }
    
    /**
* Builds a dynamic SOQL query string to fetch cost components for a SKU.
* @param productId SKU Id.
* @param fieldMap Map of RecordTypeName -> FieldName to query.
* @return String containing valid SOQL query.
*/
    public static String buildCostComponentQuery(String productId, Map<String, String> fieldMap) {
        Set<String> fieldSet = new Set<String>(fieldMap.values());
        Set<String> recordTypes = fieldMap.keySet();
        String fieldString = String.join(new List<String>(fieldSet), ', ');
        String productIdStr = '\'' + String.escapeSingleQuotes(productId) + '\'';
        String recordTypesStr= '\'' + String.join(new List<String>(recordTypes), '\', \'') + '\'';
        if(String.isBlank(productIdStr) || String.isBlank(fieldString) || String.isBlank(recordTypesStr)) {
            return null;
        }
        
        String query = 'SELECT SKU__c, RecordType.Name, ' + fieldString +
            ' FROM CostComponent__c ' +
            ' WHERE SKU__c = ' + productIdStr +
            ' AND RecordType.Name IN (' + recordTypesStr + ')';
        query += ' AND IsActive__c = true';
        
        return query;
    }
    
    /**
* Searches active Accounts linked to Vertical '10' that match the keyword.
* @param keyword Keyword to search in Account Name.
* @return List of matching Account records.
*/
    public static List<Account> ctcsearchAccounts(String keyword){
        return [
            SELECT Id, Name
            FROM Account
            WHERE Name LIKE :('%' + keyword + '%')
            AND Id IN (
                SELECT Account__c
                FROM VerticalConfiguration__c
                WHERE Vertical__c = '10'
            )
        ];
    }
    
    /**
* This method is intended to return a list of VerticalConfiguration__c records 
* Purpose : get dealer list for TBHQ
* Author : Vandana Bohra
* Created Date : July 17, 2025
* @param verticalPicklistValue The selected vertical from the picklist used to filter dealers.
* @return List of VerticalConfiguration__c records associated with the selected vertical.
*/
    public static List<AccountPDR__c> returnDealersForTBHQ(){
        return [SELECT  AccountId__r.name,AccountId__c,Source__r.name,Source__c FROM AccountPDR__c where Source__r.RecordType.DeveloperName ='Plant' WITH SECURITY_ENFORCED ORDER BY AccountId__r.Name];
    }
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public static List<AccountPDR__c> returnPlantForTBHQ(String accountId) {
        return [
            SELECT AccountId__r.Name, AccountId__c, Source__r.Name, Source__c 
            FROM AccountPDR__c 
            WHERE Source__r.RecordType.DeveloperName = 'Plant' 
            AND AccountId__c = :accountId 
            WITH SECURITY_ENFORCED 
            ORDER BY AccountId__r.Name
        ];
    }
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
* @param :  none.
* @return List of SaudaAgreement__c 
*/
    public static List<SaudaAgreement__c> returnSaudaAgreementLst(String query){
        return Database.query(query);
    }
    /**
* This method is intended to return a list of ProductAssignment__c records 
* Purpose : get ProductAssignment__c list for TBHQ
* Author : Vandana Bohra
* Created Date : July 17, 2025
* @param :  PlantDepotRake__c Id, vertialPicklistValue, Example 10 for loose
* @return List of ProductAssignment__c 
*/
    public static List<ProductAssignment__c> returnSKULst(String plantId, String verticalPicklistValue, List<String> oilTypes){
        return [SELECT Id,PlantDepotRake__r.name,Product__r.name,Product__c,Product__r.Vertical__c,Product__r.OilType__c FROM ProductAssignment__c 
                WHERE PlantDepotRake__c = :plantId and IsActive__c = true and Product__r.IsActive  = true and Product__r.Vertical__c  = :verticalPicklistValue WITH SECURITY_ENFORCED ORDER BY Product__r.Name LIMIT 49999];
    }
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public static List<sObject> getRecordsFromQuery(String query){
        String returnQuery = query + ' LIMIT 49999';
        return Database.query(returnQuery);
    }
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public static List<PlantDepotRake__c> getPlantsForTBHQ(){
        return [SELECT Id, Name FROM PlantDepotRake__c
                WITH SECURITY_ENFORCED ORDER BY Name LIMIT 49999];
    }
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public static List<Incoterm_Value__mdt> getMetdataTBHQ(String incoTerm){
        return [
            SELECT DeveloperName, MasterLabel,Picklist_Values__c,Picklist_Api_Name_CR__c
            FROM Incoterm_Value__mdt
            WHERE MasterLabel = :incoTerm
            LIMIT 1 
        ];
    }    
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public Static List<ProductAssignment__c> getOilTypeByPlantQuery(String plantId) {
        return [SELECT Id ,PlantDepotRake__r.name, Product__r.OilType__c, Product__r.name 
                FROM ProductAssignment__c
                WHERE PlantDepotRake__c =: plantId AND Product__r.OilType__c != null AND IsActive__c  = TRUE
                AND Product__r.IsActive = TRUE WITH SECURITY_ENFORCED];
    }
     
    /**
    * Author : Vandana Bohra
    * Created Date : July 17, 2025
    **/
    public Static List<Product2> getSKUByOilTypeQuery(List<String> oilTypes,String plantId) {
        
        return [SELECT Id, Name, OilType__c , ProductCode,(SELECT Id FROM Product_Assignment__r WHERE PlantDepotRake__c = :plantId AND IsActive__c = true)
                FROM Product2
                WHERE OilType__c IN :oilTypes AND Vertical__c = :Label.PA_Vertical_Loose AND IsActive = true AND IsConversion__c = true WITH SECURITY_ENFORCED];
        // AND Fraction__c != null
    }
    
    
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public Static List<SaudaConfiguration__mdt> getConversionConfiguruation(String verticalApiValue) {
        return [SELECT QualifiedApiName,Discount_Capping__c,Spot_Sauda__c,QuickOrderBooking__c,SaudaBooking__c, TBHQ_EXW_Conversion__c, 
                TBHQ_FOR_Conversion__c, Vertical__c from SaudaConfiguration__mdt WHERE Vertical__c =:verticalApiValue];
    }
    
    
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public Static Map<Id,SaudaAgreementSKU__c> getSaudaAgreementSKUs(Set<String> ids) {
        return new Map<Id, SaudaAgreementSKU__c>(
            [SELECT Id,Pending_Quantity__c , Name FROM SaudaAgreementSKU__c WHERE Id IN :ids WITH SECURITY_ENFORCED]
        );
    }
    
    /**
* Author : Kunal Mathur
* Created Date : Aug 12, 2025
**/
    public Static Map<Id, Ingredients__c> getIngMap(Set<Id> parentIds) {
        return new Map<Id, Ingredients__c>(
            [SELECT Id, Type__c,ParentIngredient__c FROM Ingredients__c WHERE Id IN :parentIds AND Active__c = true WITH SECURITY_ENFORCED]
        );
    }
    
    /**
* Author : Anirudh Sharma
* Created Date : July 22, 2025
**/
    public Static List<Ingredients__c> getSpecialityProduct() {
        return [SELECT Id,Name,Type__c,Category__c,OilType__c FROM Ingredients__c WHERE Type__c =: Label.NSM_Rolled_Out AND Active__c =true WITH SECURITY_ENFORCED ];
        
        
    }
    
    /**
* Author : Kunal Mathur
* Created Date : Aug 12, 2025
**/
    public Static List<Ingredients__c> fetchIngLists(Id skuId, Id plantId) {
        return [SELECT Id, SKU__c, PercentageUsed__c,ParentIngredient__r.ParentIngredient__c, ParentIngredient__c FROM Ingredients__c 
                WHERE SKU__c = :skuId AND Plant__c =: plantId
                AND ParentIngredient__c != null and Active__c = true WITH SECURITY_ENFORCED ];
        
        
    }
    
    /**
* @description Retrieves a list of SaudaAgreementSKU__c records with status "Pending for Release"
*              and supports pagination using limit and offset.
* 
* @param limitSize  Number of records to return.
* @param offsetSize Number of records to skip (used for pagination).
* 
* @return List of SaudaAgreementSKU__c records matching the specified criteria.
*/
     @AuraEnabled
    public static List<SaudaAgreementSKU__c> getPendingRelease(Integer limitSize, Integer offsetSize, String vertical, String searchTerm , String plantName , String oilType,String saudaType) {
        String pendingForReleaseStatus = System.Label.Sauda_Agreement_Pending_for_Release;
        String searchPattern = String.isNotBlank(searchTerm) ? '%' + String.escapeSingleQuotes(searchTerm) + '%' : '';

            // Try parse searchTerm as Date (dd/MM/yyyy or yyyy-MM-dd)
        Date searchDate;
        if (String.isNotBlank(searchTerm)) {
            try {
                if (searchTerm.contains('/')) {
                    List<String> p = searchTerm.split('/');
                    if (p.size() == 3) {
                        searchDate = Date.newInstance(
                            Integer.valueOf(p[2]),
                            Integer.valueOf(p[1]),
                            Integer.valueOf(p[0])
                        );
                    }
                } else if (searchTerm.contains('-')) {
                    searchDate = Date.valueOf(searchTerm);
                }
            } catch (Exception e) {
                searchDate = null;
            }
        }
        
        String query = 'SELECT id, SaudaAgreement__r.Name, SKU__c, SKU__r.Name, Plant__r.Name,Oil_Type__c ,SaudaAgreement__r.AccountId__r.BillingState, ' +
            'Quantity__c, SaudaAgreement__r.DeliveryFromDate__c, SaudaAgreement__r.DeliveryToDate__c,FinalPriceFOR__c, NetWeight__c,Depot__r.Name, ' +
            'SaudaAgreement__r.AccountId__r.Name, SaudaAgreement__r.Deposit_Amount__c, SaudaAgreement__r.Vertical__c,SaudaAgreement__r.SaudaBooking__r.CreatedDate, ' +
            'SaudaAgreement__r.ValidityDays__c, SaudaAgreement__r.SalesContractNumber__c, SaudaAgreement__r.SaudaBooking__r.Name,SaudaAgreement__r.Type__c ' +
            'FROM SaudaAgreementSKU__c WHERE  SaudaAgreement__r.Status__c = :pendingForReleaseStatus';
        
        if (String.isNotBlank(vertical)) {
            query += ' AND SaudaAgreement__r.Vertical__c = :vertical';
        }
        if (String.isNotBlank(plantName)) {
            query += ' AND Plant__r.Name = :plantName';
        }
        if (String.isNotBlank(oilType)) {
            query += ' AND Oil_Type__c = :oilType';
        }
        if (String.isNotBlank(saudaType)) {
            query += ' AND SaudaAgreement__r.Type__c = :saudaType';
        }

        
        if (String.isNotBlank(searchTerm) && searchTerm.startsWith('SB-')) {
        	query += ' AND SaudaAgreement__r.SaudaBooking__r.Name LIKE :searchPattern ';
        }
        else if (String.isNotBlank(searchTerm)) {
            query += ' AND (SaudaAgreement__r.SalesContractNumber__c LIKE :searchPattern ' +
                'OR SaudaAgreement__r.SaudaBooking__r.Name LIKE :searchPattern ' +
                'OR Plant__r.Name LIKE :searchPattern '+
                'OR Depot__r.Name LIKE :searchPattern '+
                'OR SKU__r.Name LIKE :searchPattern ' +
                'OR SaudaAgreement__r.AccountId__r.BillingState LIKE :searchPattern '+
                'OR SaudaAgreement__r.DeliveryFromDate__c = :searchDate ' +
                'OR SaudaAgreement__r.DeliveryToDate__c = :searchDate)';
        }
        
        
        query += ' ORDER BY CreatedDate DESC LIMIT :limitSize OFFSET :offsetSize';
        
        System.debug('query ' + query);
        return Database.query(query);
    }
    
    /**
* @description Retrieves a list of SaudaAgreementSKU__c records with status Not in ('Closed' , 'Cancelled')
*              and supports pagination using limit and offset.
* 
* @param limitSize  Number of records to return.
* @param offsetSize Number of records to skip (used for pagination).
* 
* @return List of SaudaAgreementSKU__c records matching the specified criteria.
*/
    public static List<SaudaAgreementSKU__c> getAllReleaseUnreleaseSaudas(Integer limitSize, Integer offsetSize) {
        return [
            Select id,SaudaAgreement__r.Name , SKU__c,SKU__r.Name,Plant__r.Name,SaudaAgreement__r.Released__c,
            Quantity__c,SaudaAgreement__r.DeliveryFromDate__c,SaudaAgreement__r.DeliveryToDate__c,
            SaudaAgreement__r.AccountId__r.Name,SaudaAgreement__r.Deposit_Amount__c,SaudaAgreement__r.Vertical__c,
            SaudaAgreement__r.ValidityDays__c
            from SaudaAgreementSKU__c Where SaudaAgreement__r.Status__c NOT IN ('Closed' , 'Cancelled')
            LIMIT :limitSize OFFSET :offsetSize
        ];
    }
    
    @AuraEnabled
    public static List<ChangeRequest__c> getPendingChangeRequest(Integer limitSize, Integer offsetSize, String typeFilter) {
        String baseQuery = 'SELECT Id, FromCustomer__r.Name, FromPlantDepot__r.Name, ToPlantDepot__r.Name, ' +
            'FromIncoTerm__c, ToIncoTerm__c, Vertical__c, OilType__c, Status__c, Type__c, FromSKUName__r.Name ' +
            'FROM ChangeRequest__c WHERE Status__c = \'Success\' AND Status__c != null AND Release__c = false';
        
        if (String.isNotBlank(typeFilter)) {
            baseQuery += ' AND Type__c = :typeFilter';
        }
        
        baseQuery += ' LIMIT :limitSize OFFSET :offsetSize';
        
        return Database.query(baseQuery);
    }
    @AuraEnabled
    public static List<Delta_Table__c> getdeltaRecords(Map<String, Object> params) {
        return CostComponentServiceUtility.getdeltaRecords(params);
        
    }
    
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public static List<SaudaAgreementSKU__c> saudaSkuBySauda(Set<Id> ids){
        return  [
            SELECT Id,Name,SaudaAgreement__c,SaudaAgreement__r.CreatedDate,SaudaAgreement__r.Name, 
            Pending_Quantity__c, SKU__r.Name, RolloutPrice__c, Plant__r.Name, Quantity__c, Oil_Type__c, FinalPriceFOR__c,NetWeight__c
            FROM SaudaAgreementSKU__c
            WHERE SaudaAgreement__c IN :ids
        ];
        
    }
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public static List<Delta_Table__c> deltaTableFromPlantSKUIncoTerm(String skuId,String incoTerm,String plantId){
        return  [
            SELECT Difference_Amount__c
            FROM Delta_Table__c
            WHERE From_SKU__c = :skuId
            AND From_IncoTerm__c = :incoTerm
            AND From_Plant_Depot__c = :plantId
            AND RecordType.DeveloperName = :Label.TbhqRecTypeDeveloperName
            AND Valid_From__c <= :Date.today()
            AND Valid_To__c >= :Date.today()
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
    }
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    
    public static ChangeRequest__c getRequestData(Id changeRequestId){
        
        ChangeRequest__c cr = [
            SELECT Id, Name,FromCustomer__c,FromCustomer__r.Name,
            (
                SELECT Id,
                From_Sauda__r.Name, From_Sauda__r.Released__c,
                From_Sauda_Item__r.Name, From_Sauda_Item__r.Quantity__c, From_Sauda_Item__r.Pending_Quantity__c, From_Sauda_Item__r.FinalPriceFOR__c,
                To_Sauda__r.Name, To_Sauda__r.Released__c,
                To_Sauda_Item__r.Name, To_Sauda_Item__r.Quantity__c, To_Sauda_Item__r.Pending_Quantity__c, To_Sauda_Item__r.FinalPriceFOR__c
                FROM Change_Request_Items__r
            )
            FROM ChangeRequest__c
            WHERE Id = :changeRequestId
        ]; 
        return cr;
    }
    
    /**
* Author : Yash Dagdi
* Created Date : July 23, 2025
**/
    public static List<SaudaAgreement__c> updateSaudaAgreements(List<Id> agreementIds) {
        List<SaudaAgreement__c> agreementsToUpdate =  [
            SELECT Id, Name, Status__c, IsActive__c, AccountId__c, AccountId__r.Name, Broker__r.Name,
            DeliveryFromDate__c, DeliveryToDate__c, SalesContractNumber__c
            FROM SaudaAgreement__c
            WHERE Id IN :agreementIds
        ];
        
        return agreementsToUpdate;
    }
    
    /**
* Author : Kunal Ramteke
* Created Date : July 30, 2025
**/
    public static List<SaudaAgreement__c> getSaudaAgreements(List<Id> agreementIds) {
        List<SaudaAgreement__c> agreementsToUpdate =  [
            SELECT Id, Name, Status__c, IsActive__c, AccountId__c, AccountId__r.Name, Broker__r.Name,
            DeliveryFromDate__c, DeliveryToDate__c, SalesContractNumber__c, CurrentOilRate__c, Vertical__c, Replacement_Rate__c
            FROM SaudaAgreement__c
            WHERE Id IN :agreementIds
        ];
        
        return agreementsToUpdate;
    }
    
    /**
* Author : Yash Dagdi
* Created Date : July 23, 2025
**/
    public static List<ChangeRequest__c> updateChangeRequests(List<Id> changeRequestIds) {
        List<ChangeRequest__c> updates = [SELECT Id FROM ChangeRequest__c WHERE Id IN :changeRequestIds WITH SECURITY_ENFORCED];
        
        return updates;
    }
    /**
* Author : Anirudh Sharma
* Created Date : July 28, 2025
**/
   
    public static List<Product2> getSimulatedPriceDataQueryHtProduct(Set<String> oilTypeList, Set<Id> fractionIdList, Set<Id> plantIdSet, Integer limitSize, Integer offset, Set<String> verticalSet) {
        List<Product2> prodList = new List<Product2>();
        
        String recordTypeName = Label.NSM_SKU_Ingredients;
        String packGroup = System.Label.PackGroup_BP;
        
        // Base WHERE clause
        String baseWhere = 'WHERE IsActive = true AND Vertical__c IN :verticalSet ' +
            'AND ID IN (SELECT Product__c FROM ProductAssignment__c WHERE PlantDepotRake__c IN :plantIdSet AND IsActive__c = true';
        
        if (verticalSet == null || !verticalSet.contains(System.Label.SPF_Vertical)) {
            baseWhere += ' AND Product__r.PackGroup__c = :packGroup';
        }
        
        baseWhere += ') AND ID IN (SELECT cgcloud__Product__c FROM cgcloud__Unit_of_Measure__c WHERE cgcloud__Is_Order_Unit__c = true)';
        
        if (verticalSet == null || !verticalSet.contains(System.Label.SPF_Vertical)) {
            baseWhere += ' AND Fraction__c IN :fractionIdList';
        }
        
        // Construct the full SOQL query
        String soql = 'SELECT Id, Name, Fraction__c, Fraction__r.Name, OilType__c, PackGroup__c, PackSizeQuantity__c, Vertical__c, ' +
            '(SELECT id, cgcloud__Weight__c, cgcloud__Is_Order_Unit__c, cgcloud__Unit_Type__c FROM cgcloud__Units_of_Measure__r WHERE cgcloud__Is_Order_Unit__c = true LIMIT 1), ' +
            '(SELECT id, ParentIngredient__c, PercentageUsed__c, ParentIngredient__r.Type__c, ParentIngredient__r.BasePrice__c, SKU__c, ParentIngredient__r.ConversionPMT__c, ParentIngredient__r.ParentIngredient__c ' +
            'FROM Ingredients__r WHERE RecordType.Name = :recordTypeName AND Plant__c IN :plantIdSet ORDER BY SKU__c) ' +
            'FROM Product2 ' + baseWhere + 
            ' ORDER BY CreatedDate DESC ' +
            ' LIMIT :limitSize OFFSET :offset';
        
        // Execute the query
        prodList = Database.query(soql);
        
        return prodList;
    }
    
    /**
* Author : Kunal Ramteke
* Created Date : July 30, 2025
* @description : To get the list of GroupMembers for a given set of users
* @param : userIds
* @return : List<GroupMember>
*/
    public static List<GroupMember> getGroupMemberDetails(Set<Id> userIds){
        return [SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :userIds];
    }
    
    public static Group getGroupMemberDetails(){
        return  [SELECT Id FROM Group WHERE Name =: Label.User_Business_Finance AND Type = 'Queue' LIMIT 1];
    }
    
    /** 
* Author : Kunal Ramteke
* Created Date : July 30, 2025
* @description : To get the list of ProcessInstanceWorkitem for a given set of processInstanceIds
* @param : processInstanceIds
* @return : List<ProcessInstanceWorkitem>
*/
    public static List<ProcessInstanceWorkitem> getProcessInstanceWorkItems(Id targetObjId){
        return [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :targetObjId];
    }
    
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    @AuraEnabled
    public static List<Geography__c> getGeoGraphyCityStates(String stateId){
        if(stateId == null){
            return [SELECT Id,Name FROM Geography__c WHERE RecordType.DeveloperName = :System.Label.Geography_RecordType_State WITH SECURITY_ENFORCED ORDER BY Name LIMIT 49999];
        } else{
            return [SELECT Id,Name FROM Geography__c WHERE RecordType.DeveloperName = :System.Label.Geography_RecordType_City AND ParentGeography__r.ParentGeography__r.ParentGeography__c =:stateId WITH SECURITY_ENFORCED ORDER BY Name LIMIT 49999];
        }
    }
    
    /**
* Author : Kunal Ramteke
* Created Date : August 1, 2025
* @description : To get approved trader price requests by SKU name and plant
* @param skuName Name of the SKU
* @param strPlant Plant name
* @return List of TraderPriceRequest__c records
*/
    public static List<TraderPriceRequest__c> getApprovedTraderRequestBySKU(Id skuId, Id plantId, Date fromDate, Date toDate) {
        return [
            SELECT Id, PricePerMT__c
            FROM TraderPriceRequest__c
            WHERE Approval_Status__c = 'Approved' AND IsActive__c = TRUE AND Plant__c = :plantId AND SKU__c = :skuId AND DeliveryFromDate__c <= :fromDate AND DeliveryToDate__c >= :toDate order by CreatedDate DESC
        ];
    }
    
    public static List<Ingredients__c> fetchparentChildIngredients(Set<Id> parentIds, Id plantId){
        return[SELECT Id, ParentIngredient__c,ParentIngredient__r.ParentIngredient__c, BasePrice__c, ConversionPMT__c
               FROM Ingredients__c
               WHERE ParentIngredient__c IN :parentIds
               AND RecordType.DeveloperName =: Label.RT_Ingredient_Price 
               AND Plant__c =: plantId AND Active__c = true WITH SECURITY_ENFORCED];
    }
    
    public static User getNSMUser(String verticalLabel){    
        return [SELECT Id FROM User WHERE UserVertical__c =: verticalLabel AND User_Type__c =: Label.User_NSM 
                WITH SECURITY_ENFORCED limit 1];
    }
     
    /*public static List<Logistics_Charge__c> getLogChRecs(Id shipToParty, Id accId){
        return [
            SELECT Id, UnloadingChargeCase__c, Back_End_Margin__c, Load__c, Discount_Configured__c 
            FROM Logistics_Charge__c 
            WHERE ShipToParty__c = :shipToParty AND BillToParty__c = :accId LIMIT 1];
    }*/
    
    public static LimitEnhancementRequest__c getLimitRec(Id recordId){
        return [SELECT Id, Name,createdBy.ManagerId, Customer__c,Customer__r.Name,CreatedById, RequestedlimitMT__c, ApprovedLimitMT__c, 
                                             Status__c, VerticalConfiguration__c, VerticalConfiguration__r.AvailableSaudaLimit__c, 
                                             VerticalConfiguration__r.SaudaLimit__c, VerticalConfiguration__r.Vertical__c
                                             FROM LimitEnhancementRequest__c 
                                             WHERE Id =: recordId WITH SECURITY_ENFORCED];
    }
    
    public static List<LimitEnhancementRequest__c> getLimitRecList(Set<Id> lerIdsList){
        return [SELECT Id, Name, Customer__c,Customer__r.Name, RequestedlimitMT__c, ApprovedLimitMT__c, 
                                                        Status__c, VerticalConfiguration__c, VerticalConfiguration__r.AvailableSaudaLimit__c, 
                                                        VerticalConfiguration__r.SaudaLimit__c	FROM LimitEnhancementRequest__c 
                                                        WHERE Id IN: lerIdsList WITH SECURITY_ENFORCED];
    }
    
    
    public static Map<Id, Ingredients__c> getIngredientsByParent(Set<Id> idSet,Set<Id> plantSet,Set<String> verticalSet) {
        Map<Id, Ingredients__c> ingredientMap = new Map<Id, Ingredients__c>();
        
        List<Ingredients__c> ingredients = [
            SELECT Id, Name, SKU__c, ParentIngredient__c, ParentIngredient__r.Type__c,
            PercentageUsed__c, BasePrice__c,ConversionPMT__c,ParentIngredient__r.ParentIngredient__c
            FROM Ingredients__c 
            WHERE ParentIngredient__c IN : idSet AND RecordType.Name =: Label.NSM_Ingredients_Price AND Vertical__c IN :verticalSet AND Plant__c IN :plantSet WITH SECURITY_ENFORCED
        ];
        
        for (Ingredients__c ing : ingredients) {
            // If multiple Ingredients share the same ParentIngredient__c, adjust logic accordingly
            ingredientMap.put(ing.ParentIngredient__c, ing);
        }
        
        return ingredientMap;
    }
    /**
* @description Queries Sauda Extension Policy custom metadata by vertical values
* @param verticalValues Set of vertical values to query for
* @return List of Sauda Extension Policy metadata records
*/
    public static List<Sauda_Extension_Policy__mdt> queryExtensionPoliciesByVertical(Set<String> verticalValues) {
        
        try {
            
            List<Sauda_Extension_Policy__mdt> extensionPolicies = [
                SELECT Vertical__c, Role_Group__c, Min_Days__c, DeveloperName
                FROM Sauda_Extension_Policy__mdt
                WHERE Vertical__c IN :verticalValues AND Policy_Valid_From__c <= TODAY AND Policy_Valid_To__c >= TODAY
                WITH SECURITY_ENFORCED
                ORDER BY SystemModstamp DESC
            ];
            return extensionPolicies;
            
        } catch (Exception ex) {
            
            LoggingUtility.createApexLogAsync(ex, 'queryExtensionPoliciesByVertical','SaudaQueryHelper', null);
        }
        return null;
    }
    
    public static List<SaudaBookingSKU__c> getSaudaBookingSKUs(Id bookingId) {
    if (bookingId == null) {
        return new List<SaudaBookingSKU__c>();
    }
    return [SELECT Id,SaudaBooking__r.Unpunched_Sauda__c, SKU__c, SKU__r.Name, Qty__c,OilType__c, RolloutPrice__c, Plant__c, Plant__r.Name, FinalPriceFOR__c, PremimumMT__c FROM SaudaBookingSKU__c WHERE SaudaBooking__c = :bookingId AND IsActive__c = true WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
}
    
    /**
* @description Gets current user information including role and manager details
* @return User record with Role and Manager information
*/
    public static User getCurrentUserWithRoleAndManager() {
        try {
            User currentUser = [
                SELECT Id, Name, UserRole.Name, UserRole.DeveloperName, 
                ManagerId, Manager.Name, Manager.UserRole.Name, Manager.UserRole.DeveloperName, 
                Manager.ManagerId, Manager.Manager.Name, Manager.Manager.UserRole.Name, Manager.Manager.UserRole.DeveloperName, User_Type__c, UserVertical__c
                FROM User 
                WHERE Id = :UserInfo.getUserId()
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            return currentUser;
            
        } catch (Exception ex) {
            throw new AuraHandledException('Error retrieving current user information: ' + ex.getMessage());
        }
    }

    //Query for BDO
    public static List<OrderQuickBooking__c> getQuickBookings(Set<Id> fractionIds, Set<Id> plantIds, String vertical){
        return [SELECT Id, QuantityBooked__c,Plant__c,Available_Quantity__c, Consumed_Quantity__c, Fraction__c, OwnerId 
                FROM OrderQuickBooking__c WHERE Fraction__c IN: fractionIds AND CreatedDate = TODAY 
                AND Vertical__c =: vertical AND Plant__c IN: plantIds AND CreatedById  =: UserInfo.getUserId() AND RecordTypeId = null WITH SECURITY_ENFORCED Order by CreatedDate asc];
    }
    
    //Query for ZH
    public static List<OrderQuickBooking__c> getQuickBookingsZH(Set<Id> fractionIds, Set<Id> plantIds, String vertical,String bdoId){
        return [SELECT Id, QuantityBooked__c,Plant__c,Available_Quantity__c, Consumed_Quantity__c, Fraction__c, OwnerId 
                FROM OrderQuickBooking__c WHERE Fraction__c IN: fractionIds AND CreatedDate = TODAY 
                AND Vertical__c =: vertical AND Plant__c IN: plantIds AND CreatedById  =:UserInfo.getUserId() AND OwnerId = :bdoId AND RecordTypeId = null WITH SECURITY_ENFORCED Order by CreatedDate asc];
    }
    
    
    public static Map<Id, SKUPriceRollout__c> fetchParents(Set<Id> parentIds) {
        return new Map<Id, SKUPriceRollout__c>([
            SELECT Id, PriceRolloutZH__c, PriceRolloutBDO__c, Vertical__c, RecordTypeId,PriceRolloutCH__c
            FROM SKUPriceRollout__c WHERE Id IN :parentIds
        ]);
    }
    
    public static Map<Id, SKUPriceRollout__c> fetchChildren(Set<Id> childIds) {
        return new Map<Id, SKUPriceRollout__c>([
            SELECT Id, Premium__c, ParentRollout__c, RecordTypeId, Oil_Type__c, Fraction__c, Qty__c, LoosePrice__c, Plant__c, Vertical__c, Ingredients__c
            FROM SKUPriceRollout__c WHERE Id IN :childIds WITH SECURITY_ENFORCED
        ]);
    }
    
    
    public static List<BrokerShipToPartyAssignment__c> getBrokerAssignments(Id accountId) {
    if (accountId == null) {
        return new List<BrokerShipToPartyAssignment__c>();
    }
    return [SELECT BrokerShipToParty__r.Id, BrokerShipToParty__c, BrokerShipToParty__r.Name FROM BrokerShipToPartyAssignment__c WHERE ParentAccount__c = :accountId AND BrokerShipToParty__r.RecordType.Name = :Constants.BSP_RecordType_Broker AND IsActive__c = true WITH SECURITY_ENFORCED];
}
    
    public static List<Account> getAccountIncoTerms(Id accountId) {
    if (accountId == null) {
        return new List<Account>();
    }
    return [SELECT Id, Name, IncoTerms__c FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED LIMIT 1];
}
    
    public static Account getAccountFreightCost(Id accountId) {
    if (accountId == null) {
        return null;
    }
    return [SELECT SecondaryFreight__r.Sales_FreightCost__c FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED LIMIT 1];
}
    
    public static List<Duty_Condition__mdt> getDutyCondition(String userVertical) {
    return [SELECT MasterLabel, Duty_Condition__c FROM Duty_Condition__mdt WHERE MasterLabel = :userVertical WITH SECURITY_ENFORCED LIMIT 1];
}
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    @AuraEnabled(cacheable=true)
    public static List<User> getUserRole(){
        return [SELECT Id,Name,UserRole.Id, UserRole.Name,MT_Horeca__c, User_Type__c,Manager.EmployeeCode__c
                FROM User 
                WHERE Id = :UserInfo.getUserId()];
        
    }
    
    
    /**
* Author : Vandana Bohra
* Created Date : August 04, 2025
**/
    public static List<ContentDocument> returnContentDocument(List<Id> versionId){
        List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :versionId WITH SECURITY_ENFORCED];
        return cds;
    }
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    
    
    public static List<CostComponent__c> returnCostComponents(Set<Id> skuIds){
        return [SELECT Id,OilType__c,RecordTypeId,ActualFreightCost__c,Sales_FreightCost__c,Vertical__c,
                RecordType.Name,RecordType.DeveloperName,Margin_PerMT__c,SKU__r.OilType__c,SKU__r.Fraction__c,SalesPackingCost__c,CostPerMT__c,
                Source__c,Source__r.Name,Source__r.Type__c,RatePerMT__c,SKU__c //,FreightZone__c,FreightZone__r.NAme,FreightZone__r.State__c,FreightRoute__r.Name
                FROM CostComponent__c 
                WHERE SKU__c IN :skuIds AND IsActive__c = true WITH SECURITY_ENFORCED];
    }
    
    
    /**
* Author : Vandana Bohra
* Created Date : August 4, 2025
**/
    
    @AuraEnabled
    public static String returnContentVersions(String persona) {
        try {
            if(persona == null){
                return null;
            }
            return JSON.serialize([SELECT Id,PathOnClient,VersionData,Title,CreatedDate,VersionDataUrl FROM ContentVersion WHERE Persona__c =:persona WITH SECURITY_ENFORCED ORDER BY CreatedDate desc LIMIT 49999]);
            
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    
    /**
* Author : Vandana Bohra
* Created Date : August 4, 2025
**/
    
    public static List<cgcloud__Unit_of_Measure__c> returnUnitOfMeasure(Set<Id> skuIds) {
        try {
            return [SELECT Id,cgcloud__Product__c,cgcloud__Weight__c,cgcloud__Unit_Type__c from cgcloud__Unit_of_Measure__c WHERE cgcloud__Product__c IN :skuIds AND cgcloud__Is_Order_Unit__c = true AND cgcloud__Order_Ability__c = true AND cgcloud__Weight__c != null WITH SECURITY_ENFORCED ORDER BY CreatedDate desc LIMIT 49999];
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
* Author : Vandana Bohra
* Created Date : August 4, 2025
**/
    @AuraEnabled
    public static String returnGeographyMapping(String userId,String geoType) {
        
        return JSON.serialize([SELECT Id,User__c,Geography__c,Geography__r.Name 
                               FROM UserPlantMapping__c 
                               WHERE User__c =:userId AND Geography__c != null AND Geography__r.RecordType.DeveloperName =:geoType
                               WITH SECURITY_ENFORCED ORDER BY Geography__r.Name desc LIMIT 49999]);
    }
    
    
    /**
* Author : Vandana Bohra
* Created Date : July 17, 2025
**/
    public static List<SKUPriceRollout__c> returnRolloutData(String query) {
        if (Test.isRunningTest()) {
            List<SKUPriceRollout__c> retunrList= [SELECT Id, LoosePrice__c, Qty__c, Premium__c, Fraction__c, Oil_Type__c, Plant__c, ParentRollout__c
                                                  FROM SKUPriceRollout__c WITH SECURITY_ENFORCED];
            return retunrList; 
        }
        return Database.query(query); 
    }
    
    /**
    * Author : Vandana Bohra
    * Created Date : July 17, 2025
    **/
    public static List<ProductAssignment__c> returnSkuData(String query){
        if (Test.isRunningTest()) {
            List<ProductAssignment__c> retunrList= [SELECT Id, PlantDepotRake__r.Name, Type__c, PlantDepotRake__c, Product__c, 
                                                    Product__r.Name, Product__r.Vertical__c, Product__r.Fraction__c, Product__r.BrandValue__c, Product__r.PackSizeQuantity__c, Product__r.GST__c,
                                                    Product__r.IsBaseSKU__c, Product__r.ProcessCost__c, Product__r.MaterialType__c, Product__r.OilType__c,PlantDepotRake__r.Plant__c, PlantDepotRake__r.Plant__r.Name 
                                                    FROM ProductAssignment__c WITH SECURITY_ENFORCED];
            return retunrList; 
        }
        
        return Database.query(query);
    }
    
    
    
    public static List<ProductAssignment__c> getProductAssignmentPlantOil(){
        List<ProductAssignment__c> paList = [ SELECT Id, PlantDepotRake__r.Id, PlantDepotRake__r.Name,
                                             Product__r.OilType__c, Product__r.Fraction__c,
                                             Product__r.Fraction__r.Name
                                             FROM ProductAssignment__c
                                             WHERE Type__c='Plant'
                                             AND Product__r.OilType__c != null
                                             AND Product__r.Fraction__r.Name != null
                                             AND PlantDepotRake__r.Name != null
                                             AND Product__r.Fraction__r.Vertical__c = '10'
                                            ];
 
        
        return paList;
    }
    
    
    public static User getCurrentUserTypeQuickHelper(){
        User currentUser = [
            SELECT Id, Name, Email, User_Type__c,Sauda_Manager__c,
             ManagerId ,UserVertical__c
            FROM User
            WHERE IsActive = true AND Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        return currentUser;
        
    }
    public static User getSRM(){

        User srm = [
            SELECT Id, Name, Email, User_Type__c,Sauda_Manager__c,
             ManagerId ,UserVertical__c
            FROM User
            WHERE IsActive = true AND User_Type__c =: Label.UserType_SRM
            LIMIT 1
        ];
        
        return srm;
        
    }
    
    
    
    
    public class QuickOrderWrapper {
        @AuraEnabled public String plantName;
        @AuraEnabled public String plantId;
        @AuraEnabled public String oilTypeName;
        @AuraEnabled public Id fractionId;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public String userId;
        
    }
    
    
    public static List<OrderQuickBooking__c> getchildQuickOrder(string inputone){
        
        
        QuickOrderWrapper input = (QuickOrderWrapper) JSON.deserialize(inputone, QuickOrderWrapper.class);
        
        
        List<OrderQuickBooking__c> childRecords = [
            SELECT Id, QuantityBooked__c
            FROM OrderQuickBooking__c
            WHERE CreatedDate = TODAY
            AND NSMQuickBooking__c = true
            AND Plant__c = :input.plantId
            AND OilType__c = :input.oilTypeName
            AND Fraction__c = :input.fractionId
            AND OwnerId = :input.userId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        return childRecords;
    }
    
    
    public static List<OrderQuickBooking__c> getchildQuickOrderforZh(string inputone){
        
        
        QuickOrderWrapper input = (QuickOrderWrapper) JSON.deserialize(inputone, QuickOrderWrapper.class);
        
        
        List<OrderQuickBooking__c> childRecords = [
            SELECT Id, QuantityBooked__c
            FROM OrderQuickBooking__c
            WHERE CreatedDate = TODAY
            AND ZHQuickbooking__c = true
            AND Plant__c = :input.plantId
            AND OilType__c = :input.oilTypeName
            AND Fraction__c = :input.fractionId
            AND OwnerId = :input.userId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        return childRecords;
    }
    
    
    
    public static List<OrderQuickBooking__c> getParentQuickOrder(string inputone){
        
        
        QuickOrderWrapper input = (QuickOrderWrapper) JSON.deserialize(inputone, QuickOrderWrapper.class);
        
        
        List<OrderQuickBooking__c> parentRecords = [
            SELECT Id, QuantityBooked__c
            FROM OrderQuickBooking__c
            WHERE CreatedDate = TODAY
            AND NSMQuickBooking__c = true
            AND Plant__c = :input.plantId
            AND OilType__c = :input.oilTypeName
            AND Fraction__c = :input.fractionId
            LIMIT 1
        ];
        
        return parentRecords;
    }
    
    
    
    public static List<OrderQuickBooking__c> getParentQuickOrderBDO(string inputone){
        
        
        QuickOrderWrapper input = (QuickOrderWrapper) JSON.deserialize(inputone, QuickOrderWrapper.class);
        
        
        List<OrderQuickBooking__c> parentRecords = [
            SELECT Id, QuantityBooked__c
            FROM OrderQuickBooking__c
            WHERE CreatedDate = TODAY
            AND ZHQuickbooking__c = true
            AND Plant__c = :input.plantId
            AND OilType__c = :input.oilTypeName
            AND Fraction__c = :input.fractionId
            LIMIT 1
        ];
        
        return parentRecords;
    }
    
    public static CustomNotificationType getCustomNotificationTypeQuickOrder(){
        CustomNotificationType notificationType = [
            SELECT Id
            FROM CustomNotificationType
            WHERE DeveloperName = 'Quick_Order_Alert'
            LIMIT 1
        ];
        return notificationType;
        
    }
    
    
    public static List<User> getCurrentUserListQO(){
        List<User> userList =[ 
            SELECT Id, Name, Email, User_Type__c
            FROM User
            WHERE IsActive = true 
            AND Id = :UserInfo.getUserId()
            AND User_Type__c != null
            ORDER BY Name
        ];
        
        return userList;
    }
    
    public static List<OrderQuickBooking__c>  getTodayQuickOrderData(){
        List<OrderQuickBooking__c> records = [
            SELECT Plant__c, Plant__r.Name, OilType__c, QuantityBooked__c
            FROM OrderQuickBooking__c
            WHERE QuantityBooked__c != null
            AND CreatedDate = TODAY
        ];
        
        return records;
    }
    
    
    public static List<UserPlantMapping__c>  getUserPlantMappingByUserId(String userId){
        List<UserPlantMapping__c> records =[
            SELECT Id, Name, Fraction__c, Fraction__r.Name, User__c, Plant__r.Name, Plant__c, OilType__c 
            FROM UserPlantMapping__c 
            WHERE User__c = :UserId 
            LIMIT 1
        ];
        
        return records;
        
    }
    
    public static Report getQuickOrderReport(){
        Report rpt =[select id,Name from Report where name ='New Order Quick Booking Report' limit 1];
        return rpt;
        
    }
    
    
    public static ProductAssignment__c getProductAssignmentByFraction(String selectedFractionId){
        ProductAssignment__c assignment = [
            SELECT Product__r.OilType__c
            FROM ProductAssignment__c
            WHERE Type__c = 'Plant' AND Product__r.Fraction__c = :selectedFractionId
            AND Product__r.OilType__c != null  WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        return  assignment;
    }
    
    /**
* @description Gets the current user's information
* @return User record with role and manager information
*/
    public static List<User> getUserByVerticalAndType(List<String> lstVertical, String strType) {
        String includesValues = '\'' + String.join(lstVertical, '\', \'') + '\'';
        String query = 'SELECT Id, Name, UserRole.Name, UserRole.DeveloperName, ManagerId, Manager.Name, Manager.UserRole.Name, User_Type__c, UserVertical__c FROM User WHERE UserVertical__c includes = (' + includesValues + ') AND User_Type__c = :strType';
        return Database.query(query);
    }
    
    
    public static List<Ingredients__c> getIngridentList(Set<Id> idSet,String plantName){
        
        return [Select id,ParentIngredient__c,PercentageUsed__c,ParentIngredient__r.Type__c,ParentIngredient__r.BasePrice__c,SKU__c,ParentIngredient__r.ConversionPMT__c,ParentIngredient__r.ParentIngredient__c from Ingredients__c WHERE RecordType.Name =:Label.NSM_SKU_Ingredients AND Plant__r.Name =:plantName AND SKU__c IN :idSet WITH SECURITY_ENFORCED Order By SKU__c];
    }
    
    public static Map<Id, Ingredients__c> getIngredientsByParentZH(Set<Id> idSet,String plantName,Set<String> verticalSet) {
        Map<Id, Ingredients__c> ingredientMap = new Map<Id, Ingredients__c>();
        
        List<Ingredients__c> ingredients = [
            SELECT Id, Name, SKU__c, ParentIngredient__c, ParentIngredient__r.Type__c,
            PercentageUsed__c, BasePrice__c,ConversionPMT__c,ParentIngredient__r.ParentIngredient__c
            FROM Ingredients__c 
            WHERE ParentIngredient__c IN : idSet AND RecordType.Name =: Label.NSM_Ingredients_Price AND Vertical__c IN :verticalSet AND Plant__r.Name =:plantName WITH SECURITY_ENFORCED
        ];
        
        for (Ingredients__c ing : ingredients) {
            // If multiple Ingredients share the same ParentIngredient__c, adjust logic accordingly
            ingredientMap.put(ing.ParentIngredient__c, ing);
        }
        
        return ingredientMap;
    }
    
    public static String buildCostComponentQueryBulk(Set<Id> productIds, Map<String, String> fieldMap) {
        if (productIds == null || productIds.isEmpty() || fieldMap == null || fieldMap.isEmpty()) {
            return null;
        }
        
        // Distinct fields to query
        Set<String> fieldSet = new Set<String>(fieldMap.values());
        // RecordType filters
        Set<String> recordTypes = fieldMap.keySet();
        
        String fieldString = String.join(new List<String>(fieldSet), ', ');
        String recordTypesStr = '\'' + String.join(new List<String>(recordTypes), '\', \'') + '\'';
        
        // Note: No need to escape IDs since Set<Id> is strongly typed, 
        // but we must use SOQL bind variable syntax for safety
        String query =
            'SELECT SKU__c, RecordType.Name, ' + fieldString +
            ' FROM CostComponent__c ' +
            ' WHERE SKU__c IN :productIds' +
            ' AND RecordType.Name IN (' + recordTypesStr + ')';
        
        return query;
    }
    
    public Static List<Product2> getActualProductsList(String verticalAPIName) {
        return [SELECT Id, Name
                FROM Product2
                WHERE Vertical__c = :verticalAPIName
                AND IsActive = true
                WITH SECURITY_ENFORCED
                ORDER BY Name
               ];
    }
    public Static ProductAssignment__c getPARecord (String product,String plantId) {
        return [SELECT Id, Product__c, Product__r.Fraction__c, Product__r.PackGroup__c, Product__r.PackType__c, 
                PlantDepotRake__c, Product__r.Vertical__c, Product__r.IsActive, IsActive__c,Product__r.PackSizeQuantity__c
                FROM ProductAssignment__c 
                WHERE Product__c = :product and  PlantDepotRake__c = : plantId and IsActive__c = true
                WITH SECURITY_ENFORCED
                LIMIT 1
               ];
    }
    
    public Static List<ProductAssignment__c> getProductListForSA (String verticalAPIName, ProductAssignment__c pd) {
        return [SELECT Id, Product__r.Name, Product__c, Product__r.Fraction__c, Product__r.PackGroup__c, PlantDepotRake__c, Product__r.PackType__c, 
        Product__r.Vertical__c, Product__r.IsActive, IsActive__c,Product__r.PackSizeQuantity__c
                FROM ProductAssignment__c
                WHERE Product__r.Vertical__c = :verticalAPIName
                AND Product__r.IsActive = true
                AND IsActive__c = true
                AND Product__r.Fraction__c = :pd.Product__r.Fraction__c
                AND Product__r.PackGroup__c = :pd.Product__r.PackGroup__c
                AND PlantDepotRake__c = : pd.PlantDepotRake__c
                WITH SECURITY_ENFORCED
                ORDER BY Product__r.Name];
    }
    
    public Static List<cgcloud__Unit_of_Measure__c> getOrderUnitsByProduct (Id productId) {
           String baseUnit = Label.NOS_Base_Unit_UOM;
           String conUnit = Label.CS_Conv_Unit_UOM;
        return [
            SELECT Id, cgcloud__Weight__c, cgcloud__Product__c, cgcloud__Is_Order_Unit__c, cgcloud__Pieces_per_parent_unit__c 
            FROM cgcloud__Unit_of_Measure__c 
            WHERE cgcloud__Product__c = :productId
            AND BaseUnit__c =:baseUnit AND Conversion_Unit__c =:conUnit
            WITH SECURITY_ENFORCED
        ];
    }
    
    public Static List<Delta_Table__c> getDeltaTableRecords (Id parentProductId, Id actualProductId) {
        return [SELECT DeltaPriceUnit__c
                FROM Delta_Table__c
                WHERE From_SKU__c = :parentProductId 
                AND To_SKU__c = :actualProductId WITH SECURITY_ENFORCED
                LIMIT 1
               ];
    }
    
    // Mehtod to get Sauda Allocation Record Type Id
    public Static Id getSaudaAllocationRTId (){
        return [ SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Sauda_Allocation__c' AND DeveloperName = 'Sauda_Allocation'
                WITH SECURITY_ENFORCED LIMIT 1].Id;
    }
    
    public static List<User> returnChannelHeadUserList(){
        return [SELECT Id, Name, UserRole.Name FROM User  WHERE UserRole.Name ='CH MT/HoReCa'];
    }
    
    /**
    * Author : Vandana Bohra
    * Created Date : August 15, 2025
    **/
    public static List<Ingredients__c> getIngsActuals(Set<Id> skuIds){
        return [SELECT PercentageUsed__c,Type__c,SKU__r.NAme, BasePrice__c, ParentIngredient__c,ParentIngredient__r.ParentIngredient__c, ParentIngredient__r.Type__c, SKU__c, Plant__c, ParentIngredient__r.BasePrice__c
                FROM Ingredients__c 
                WHERE SKU__c IN :skuIds AND Active__c = true AND PercentageUsed__c != null WITH SECURITY_ENFORCED];
    }
    
    /**
* Author : Vandana Bohra
* Created Date : August 15, 2025
**/
    public static List<Ingredients__c> getRolloutIngs(){
        return [SELECT Id,OilType__c, (SELECT LoosePrice__c,Ingredients__c  FROM SKU_Price_Rollout__r WHERE IsActive__c = true AND LoosePrice__c != null) 
                FROM Ingredients__c WHERE Id IN (SELECT Ingredients__c FROM SKUPriceRollout__c) 
                AND Type__c =:Label.NSM_Rolled_Out AND Active__c = true WITH SECURITY_ENFORCED];
    }
    
    /**
* Author : Vandana Bohra
* Created Date : August 15, 2025
**/
    public static List<Ingredients__c> getFixedPrice(){
        return [SELECT Id,Plant__c,Plant__r.Name,Plant__r.Type__c, BasePrice__c,ConversionPMT__c,ParentIngredient__c
                FROM Ingredients__c
                WHERE RecordType.DeveloperName = 'Ingredients_Price' AND Active__c = true
                AND ParentIngredient__c != NULL WITH SECURITY_ENFORCED LIMIT :Integer.valueOf(Label.RecordLimit)];
    }
    /**
* Author : Vandana Bohra
* Created Date : August 15, 2025
**/
    public static List<PlantDepotAssignment__c> getDepotWithPlant(){ 
        return [SELECT Id,Depot__c,Depot__r.Name,Plant__c,Plant__r.Name FROM PlantDepotAssignment__c WHERE Plant__c != null AND Depot__c != null WITH SECURITY_ENFORCED LIMIT :Integer.valueOf(Label.RecordLimit)];
    }
    
    /**
* Author : Vandana Bohra
* Created Date : August 15, 2025
**/    
    public static List<CSVExportField__mdt> getCsvMetadata(String persona){
        return [ 
            SELECT Header__c, WrapperFieldAPI__c, Order__c 
            FROM CSVExportField__mdt 
            WHERE Persona__c = :persona AND Order__c != null
            ORDER BY Order__c ASC
        ]; 
    }
    
    public Static List<SaudaBookingSKU__c> getSaudaBookingSKUQuery (Set<Id> setOfSKU, Id saudaBookingId) {
        return [SELECT Id, Name, SKU__c FROM SaudaBookingSKU__c WHERE SKU__c IN: setOfSKU AND SaudaBooking__c =: saudaBookingId WITH SECURITY_ENFORCED];
    }
    
    public Static List<Sauda_Allocation__c> getAllSaudaAllocationOfBooking (Id saudaBookingId) {
        return [ SELECT Id FROM Sauda_Allocation__c WHERE Sauda_Booking__c = :saudaBookingId WITH SECURITY_ENFORCED];
    }
    
    
    
    
    @AuraEnabled(cacheable=true)
    public static List<ProductAssignment__c> getOilTypeByVertical(String vertical) {
        return [
            SELECT Product__r.OilType__c
            FROM ProductAssignment__c
            WHERE  Product__r.Vertical__c = :vertical
            WITH SECURITY_ENFORCED
        ];
    }
    
    
    public static Product2 getBrandValue(String prodId) {
        
        return [Select id,BrandValue__c From Product2 WHERE Id =:prodId WITH SECURITY_ENFORCED];
    }
    
    
    /**
* Author : Vandana Bohra
* Created Date : Sept 1, 2025
**/    
    public static List<Cost_Component_Calculation_Rollout__mdt> getCCCRollout(){
        return [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Active__c, Field_Name__c, Not_Found_Error__c from Cost_Component_Calculation_Rollout__mdt];
    }
    
    
    /**
* Author : Vandana Bohra
* Created Date : Sept 1, 2025
**/    
    public static List<Cost_Component_Calculation_Sauda_Booking__mdt> getCCCBooking(){
        return [SELECT Id, DeveloperName, MasterLabel, Language, Label, QualifiedApiName, Active__c, Field__c from Cost_Component_Calculation_Sauda_Booking__mdt];
    }
    
    /**
* Author : Vandana Bohra
* Created Date : Sept 1, 2025
**/    
    public static List<DPRuleEngine__c> getDpRules(String persona){
        return [SELECT Id, PersonaType__c, Persona__c, Product_Criteria__c, Amount__c, Amount_Type__c,Value__c from DPRuleEngine__c WHERE PersonaType__c = :persona AND IsActive__c = true WITH SECURITY_ENFORCED];
    }
    
    
    
    
    public static List<DailyAllocation__c> getQuickOrderAdditionalData(String ZH) {
        return [
            SELECT Id, AdditionalQuantity__c, Plant__c,Plant__r.Name, OilType__c, Fraction__c,Fraction__r.Name
            FROM DailyAllocation__c WHERE AllocatedToUser__c = :UserInfo.getUserId()
            AND UserType__c =: ZH AND AdditionalQuantity__c != null AND AdditionalQuantity__c > 0];
        
    }
    
    public static List<DailyAllocation__c> getDailyAllocationList(String inputone,String usertype){
        QuickOrderWrapper input = (QuickOrderWrapper) JSON.deserialize(inputone, QuickOrderWrapper.class);
        
        List<DailyAllocation__c> daList = [
            SELECT Id, AdditionalQuantity__c
            FROM DailyAllocation__c
            WHERE Plant__c = :input.plantId
            AND OilType__c = :input.oilTypeName
            AND Fraction__c = :input.fractionId
            AND AllocatedToUser__c = :UserInfo.getUserId()
            AND UserType__c =:usertype
            LIMIT 1
        ];
        
        return daList; 
        
    }
    
    public static List<DailyAllocation__c> getchildfDailyAllocationList(String inputone){
        QuickOrderWrapper input = (QuickOrderWrapper) JSON.deserialize(inputone, QuickOrderWrapper.class);
        
        List<DailyAllocation__c> daList = [
            SELECT Id, AllocatedToUser__c, AdditionalQuantity__c,
            Plant__c, Fraction__c, Quantity__c
            FROM DailyAllocation__c
            WHERE Plant__c = :input.plantId 
            AND OilType__c = :input.oilTypeName 
            AND Fraction__c = :input.fractionId
            AND AllocatedToUser__c = :input.userId
            LIMIT 1
        ];
        
        return daList;
        
    }
    
    public static User getManagerForAllocation(Id userId ){
        User manager = [
            SELECT Id, Name, Email,Sauda_Manager__c,
             User_Type__c, ManagerId ,UserVertical__c
            FROM User
            WHERE IsActive = true AND Id = :userId
            LIMIT 1
        ];
        return manager;
    }
    
    /**
* The method is used to fetch Sauda Booking whose Allocation is Pending, status is Booked & were created today.
*/
    public static List<SaudaBooking__c> getSBRecordsOfTodayQuery() {
        return [
            SELECT Id, Name, CreatedById, Dealer__r.Name
            FROM SaudaBooking__c
            WHERE Status__c =: System.Label.SA_BOOKING_STATUS_Booked AND AllocationStatus__c =: System.Label.SA_BOOKING_STATUS_PENDING AND CreatedDate = today WITH SECURITY_ENFORCED];
    }
    
    /**
* The method is used to fetch Id of Sauda Allocation Pending's Custom Notification Type.
*/
    public Static Id getSAPendingCustomNotificationId(){
        Id notificationTypeId;
        notificationTypeId = [ SELECT Id
                              FROM CustomNotificationType 
                              WHERE DeveloperName =: System.Label.SA_Pending_CNT
                              WITH SECURITY_ENFORCED LIMIT 1].Id;
        return notificationTypeId;
    }
    
    
    /**
* Author : Vandana Bohra
* Created Date : Sept 1, 2025
**/ 
    @AuraEnabled
    public static String getBankGuarantees(String accountId){
        return JSON.serialize([SELECT Id, BankGuaranteeNumber__c, Amount__c, ExpiryDate__c, Status__c, Customer__c, CreditControlArea__c, SAPID__c from BankGuarantee__c 
                               WHERE Customer__c = :AccountId AND Status__c != 'Active' WITH SECURITY_ENFORCED]);
    }
    
    
    
    public static List<Invoice_Item__c> getInvoiceItems(String invoiceId){
        return [
            SELECT Id, Name, Invoice__c, RatePerPC__c, Product__c, Product__r.Name,
            Quantity__c, Gross_Amount__c
            FROM Invoice_Item__c
            WHERE Invoice__c = :invoiceId
            ORDER BY Name NULLS LAST
        ];
    }
    
    public static List<Invoice_Item__c> getInvoiceItemsByIds(Set<Id> invoiceItemIds){
        List<Invoice_Item__c> invoiceItems = [
            SELECT Id, Product__c, RatePerPC__c, NetAmount__c, Quantity__c, Gross_Amount__c
            FROM Invoice_Item__c
            WHERE Id IN :invoiceItemIds
        ];
        return invoiceItems;
        
    }
    
    public static List<Product2> getProducts(List<Id> productIds){
        return [SELECT Id, OilType__c FROM Product2 WHERE Id IN :productIds WITH SECURITY_ENFORCED ];
    }
    
    public static List<ProductAssignment__c> getProdAssignment(List<Id> productIds){
        return [SELECT Product__c, PlantDepotRake__c FROM ProductAssignment__c WHERE Product__c IN :productIds WITH SECURITY_ENFORCED];
    }
    
    
    public static List<Product2> getproductsWithUom(Set<Id> productIds){
        List<Product2> productsWithUom = [
            SELECT Id,
            (SELECT Id, Name, cgcloud__Pieces_per_parent_unit__c, cgcloud__Weight__c
             FROM cgcloud__Units_of_Measure__r
             LIMIT 1)
            FROM Product2
            WHERE Id IN :productIds
        ];
        return productsWithUom;
        
    }
    
    
    public static RecordType getrecordTypeOfClaim(){
        RecordType claimRt = [SELECT Id FROM RecordType WHERE 
                              DeveloperName = 'Trading_Claim' AND 
                              SobjectType = 'Claim__c' LIMIT 1];
        
        return claimRt;
        
    }
    
    
    public static RecordType getrecordTypeClaimItem(){
        RecordType claimItemRt = [SELECT Id FROM RecordType WHERE 
                                  DeveloperName = 'Trading_Invoice' 
                                  AND SobjectType = 'Claim_Item__c' LIMIT 1];
        
        
        return claimItemRt;
        
    }
    
    public static User getCurrentUserClaim(){
        User currentUser = [
            SELECT Id, Name, UserVertical__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
        
        return currentUser;
        
    }
    
    public static List<SaudaConfiguration__mdt> getSaudaConfiguration(string verticalName){
        List<SaudaConfiguration__mdt> cfgList = [
            SELECT QualifiedApiName,Duty_Condition__c, Spot_Sauda__c,MOP__c, GST_On_Claim_For_Dealer__c,
            TBHQ_EXW_Conversion__c, TBHQ_FOR_Conversion__c, Vertical__c
            FROM SaudaConfiguration__mdt
            WHERE Vertical__c = :verticalName
            LIMIT 1
        ];
        
        return cfgList;
    }
    
    
    public static List<Claim_Item__c> getClaimItems(Id claimId){
        List<Claim_Item__c> items = [
            SELECT Id, Name, Shortage_Quantity__c,Quantity__c, Per_Pc_KG__c, GrossWeight__c,
            Weight__c, PcPerUnit__c, Address_Within_Operational_Range__c, Total_Claim_Value__c, ClaimReason__c
            FROM Claim_Item__c
            WHERE Claim__c = :claimId
        ];
        return items;
        
    }
    
    public static  List<Claim_Item__c> getClaimItemsCalulation(List<Id> itemIds){
        List<Claim_Item__c> items = [
            SELECT Id, Shortage_Quantity__c,Quantity__c, Per_Pc_KG__c, GrossWeight__c, Weight__c, PcPerUnit__c, ClaimReason__c
            FROM Claim_Item__c
            WHERE Id IN :itemIds
        ];
        
        return items;
    }
    
    
    
    public static  List <Claim_Item__c> getWithinAdress(Set<Id> claimIdsToProcess){
        List <Claim_Item__c> clist =  [
            SELECT Id, Claim__c, Address_Within_Operational_Range__c
            FROM Claim_Item__c
            WHERE Claim__c IN :claimIdsToProcess
        ];
        
        return clist;
    }
    
    public static List<Product2> getParentProducts() {
        return [Select id from Product2 WHERE ISActive = true AND Fraction__c =null AND Vertical__c =: Label.H_T_Value];
    }
    
    @AuraEnabled
    public static String getAccountIdFromUser(String userId){
        List<User> uLst = [SELECT Id,AccountId FROM user WHERE Id = :userId];
        
        return uLst[0].AccountId;
    }
    
    /**
    * @description Fetches Case_Weight__c from Product2 records
    * @param productIds Set of Product2 IDs
    * @return Map<Id, Decimal> - Map of Product ID to Case Weight
    * //R-260604-0017 - CHANGES MADE: New method to fetch caseWeight from Product2.Case_Weight__c
    */
    public static Map<Id, Decimal> getCaseWeightByProducts(Set<Id> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return new Map<Id, Decimal>();
        }
        
        Map<Id, Decimal> caseWeightMap = new Map<Id, Decimal>();
        
        List<Product2> products = [
            SELECT Id, Case_Weight__c
            FROM Product2
            WHERE Id IN :productIds
            AND IsActive = true
            WITH SECURITY_ENFORCED
        ];
        
        for (Product2 prod : products) {
            if (prod.Case_Weight__c != null) {
                caseWeightMap.put(prod.Id, prod.Case_Weight__c);
            }
        }
        
        return caseWeightMap;
    }
    
    /**
    * @description Fetches Product with Case_Weight__c for a specific ID
    * @param productId Product2 ID
    * @return Product2 record or null
    * //R-260604-0017 - CHANGES MADE: New method to fetch single product with caseWeight
    */
    public static Product2 getProductWithCaseWeight(Id productId) {
        if (productId == null) {
            return null;
        }
        
        try {
            return [
                SELECT Id, Name, Case_Weight__c, OilType__c, Vertical__c, GST__c
                FROM Product2
                WHERE Id = :productId
                AND IsActive = true
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        } catch (Exception e) {
            return null;
        }
    }

    
}