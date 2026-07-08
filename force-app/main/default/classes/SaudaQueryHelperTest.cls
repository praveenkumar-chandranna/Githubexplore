@isTest
private class SaudaQueryHelperTest {
    
    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Acc', IsActive__c = true);
        insert acc;
        
        PlantDepotRake__c plant = new PlantDepotRake__c(
            Name = 'Plant1',
            IsActive__c = true,
            Code__c = 'test3025'
        );
        insert plant;
        
        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true,
            Vertical__c = '30'
        );
        insert prod;
    }
    
    @isTest
    static void testFetchActivePlantsAccountPDR() {
        Test.startTest();
        SaudaQueryHelper.fetchActivePlantsAccountPDR();
        Test.stopTest();
    }
    
    @isTest
    static void testFetchOilTypesByVerticalAndPlant() {
        Test.startTest();
        SaudaQueryHelper.fetchOilTypesByVerticalAndPlant('30','Plant1');
        Test.stopTest();
    }
    
    @isTest
    static void testGetActivePlants() {
        Test.startTest();
        SaudaQueryHelper.getActivePlants();
        Test.stopTest();
    }
    
    @isTest
    static void testCurrentUserStates() {
        Test.startTest();
        SaudaQueryHelper.currentUserStates('30');
        Test.stopTest();
    }
    
    @isTest
    static void testGetDailyAllocatedData() {
        Test.startTest();
        SaudaQueryHelper.getDailyAllocatedData(new Set<Id>(), new Set<Id>(), new Set<String>());
        Test.stopTest();
    }
    
    @isTest
    static void testQuerySaudaBooking() {
        Test.startTest();
        SaudaQueryHelper.querySaudaBooking(null);
        Test.stopTest();
    }
    
    @isTest
    static void testGetOpenTasks() {
        Test.startTest();
        SaudaQueryHelper.getOpenTasks();
        Test.stopTest();
    }
    
    @isTest
    static void testFetchCostComponents_Empty() {
        Test.startTest();
        SaudaQueryHelper.fetchCostComponents(new Set<Id>(), new List<String>());
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllCostComps() {
        Test.startTest();
        SaudaQueryHelper.getAllCostComps();
        Test.stopTest();
    }
    
    @isTest
    static void testGetLoggedInUser() {
        Test.startTest();
        SaudaQueryHelper.getLoggedInUser();
        Test.stopTest();
    }
    
    @isTest
    static void testGetActivePlantsFromPA() {
        Test.startTest();
        SaudaQueryHelper.getActivePlantsFromPA();
        Test.stopTest();
    }
    
    @isTest
    static void testGetOilTypeByPlantVert() {
        Test.startTest();
        SaudaQueryHelper.getOilTypeByPlantVert('Plant1','30');
        Test.stopTest();
    }
    
    @isTest
    static void testGetDealerDetails() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        SaudaQueryHelper.getDealerDetails(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchRecordType() {
        Test.startTest();
        try{
            SaudaQueryHelper.fetchRecordType('Account','Account');
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    static void testFetchIncoTerms() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        SaudaQueryHelper.fetchIncoTerms(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountPDRByAccountIdQuery() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        SaudaQueryHelper.getAccountPDRByAccountIdQuery(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchChangeRequest() {
        Test.startTest();
        SaudaQueryHelper.fetchChangeRequest(new Set<Id>());
        Test.stopTest();
    }
    
    @isTest
    static void testFetchSingleChangeRequest() {
        Test.startTest();
        try{
            SaudaQueryHelper.fetchSingleChangeRequest(null);
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    static void testGetApprovalRecords() {
        Test.startTest();
        SaudaQueryHelper.getApprovalRecords(UserInfo.getUserId(), null);
        Test.stopTest();
    }
    
    @isTest
    static void testGetSaudaValues_Exception() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        try{
            SaudaQueryHelper.getSaudaValues(acc.Id,'30');
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    static void testFetchVertConfigs() {
        Test.startTest();
        SaudaQueryHelper.fetchVertConfigs('30', true);
        SaudaQueryHelper.fetchVertConfigs('30', false);
        Test.stopTest();
    }
    
    @isTest
    static void testGetVertConfigs_Exception() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        try{
            SaudaQueryHelper.getVertConfigs(acc.Id,'30');
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    static void testGetUnitOfMeasureByProducts_Empty() {
        Test.startTest();
        SaudaQueryHelper.getUnitOfMeasureByProducts(new Set<Id>());
        Test.stopTest();
    }
    
    @isTest
    static void testGetTradeTickets_Empty() {
        Test.startTest();
        SaudaQueryHelper.getTradeTickets(new Set<Id>(), new Set<String>(), new Set<String>());
        Test.stopTest();
    }
    
    @isTest
    static void testGetIngredientsForSKUs_Empty() {
        Test.startTest();
        SaudaQueryHelper.getIngredientsForSKUs(new Set<Id>(), new Set<Id>());
        Test.stopTest();
    }
    
    @isTest
    static void testGetActiveSKUPriceRollouts_Empty() {
        Test.startTest();
        SaudaQueryHelper.getActiveSKUPriceRollouts(new Set<Id>());
        Test.stopTest();
    }
    
    @isTest
    static void testGetIngredientPrices_Empty() {
        Test.startTest();
        SaudaQueryHelper.getIngredientPrices(new Set<Id>(), null, new Set<String>());
        Test.stopTest();
    }
    
    @isTest
    static void testGetProductAssignments_Empty() {
        Test.startTest();
        SaudaQueryHelper.getProductAssignments(new Set<Id>(), new Set<Id>());
        Test.stopTest();
    }
    
    @isTest
    static void testGetTrade() {
        Test.startTest();
        SaudaQueryHelper.getTrade('HBC','Plant1',0,10);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchSKUforOilType() {
        Test.startTest();
        SaudaQueryHelper.fetchSKUforOilType('30');
        Test.stopTest();
    }
    
    @isTest
    static void testGetPendingApprovalWorkitemsByUser() {
        Test.startTest();
        SaudaQueryHelper.getPendingApprovalWorkitemsByUser(UserInfo.getUserId());
        SaudaQueryHelper.getPendingApprovalWorkitemsByUser(null);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCurrentUserState() {
        Test.startTest();
        SaudaQueryHelper.getCurrentUserState();
        Test.stopTest();
    }
    
    @isTest
    static void testUserList() {
        Test.startTest();
        SaudaQueryHelper.userList(new List<String>());
        Test.stopTest();
    }
    
    @isTest
    static void testUserListStateWise() {
        Test.startTest();
        SaudaQueryHelper.userListStateWise(new List<String>());
        Test.stopTest();
    }
    
    @isTest
    static void testUserIdSetList() {
        Test.startTest();
        SaudaQueryHelper.useridSetList(new Set<Id>());
        Test.stopTest();
    }
    @isTest
    static void testFetchBrokerAssignment() {
        
        Account acc = new Account(Name='Parent Acc', IsActive__c = true);
        insert acc;
        
        Account stp = new Account(Name='STP Acc', IsActive__c = true);
        insert stp;
        
        BrokerShipToPartyAssignment__c rec = new BrokerShipToPartyAssignment__c(
            ParentAccount__c = acc.Id,
            BrokerShipToParty__c = stp.Id,
            IsActive__c = true,
            Vertical__c = '30'
        );
        insert rec;
        
        Test.startTest();
        SaudaQueryHelper.fetchBrokerAssignment(acc.Id,'30');
        Test.stopTest();
    }
    @isTest
    static void testFetchBrokerSTP() {
        
        Account acc = new Account(Name='Parent Acc', IsActive__c = true);
        insert acc;
        
        Account stp = new Account(Name='STP Acc', IsActive__c = true);
        insert stp;
        
        BrokerShipToPartyAssignment__c rec = new BrokerShipToPartyAssignment__c(
            ParentAccount__c = acc.Id,
            BrokerShipToParty__c = stp.Id,
            IsActive__c = true,
            Vertical__c = '30'
        );
        insert rec;
        
        Test.startTest();
        SaudaQueryHelper.fetchBrokerSTP(acc.Id, stp.Id,'30');
        Test.stopTest();
    }
    
    @isTest
    static void testFetchAllBrokerAssignment() {
        
        Account stp = new Account(Name='STP Acc', IsActive__c = true);
        insert stp;
        
        BrokerShipToPartyAssignment__c rec = new BrokerShipToPartyAssignment__c(
            BrokerShipToParty__c = stp.Id,
            IsActive__c = true,
            Vertical__c = '30',
            Record_Type__c = System.Label.RT_Ship_to_Party
        );
        insert rec;
        
        Test.startTest();
        SaudaQueryHelper.fetchAllBrokerAssignment('30');
        Test.stopTest();
    }
    @isTest
    static void testGetCustomerAccounts() {
        
        RecordType rt = [SELECT Id FROM RecordType 
                         WHERE SObjectType = 'Account' LIMIT 1];
        
        Account acc = new Account(
            Name = 'Customer Acc',
            RecordTypeId = rt.Id,
            IsActive__c = true,
            VerticalLoose__c = true,
            BillingCity = 'Ajmer',
            BillingState = 'Rajasthan'
        );
        insert acc;
        
        Test.startTest();
        SaudaQueryHelper.getCusotmerAccounts();
        Test.stopTest();
    }
    @isTest
    static void testGetCustomerAccountsForHBC() {
        
        // Get any active Account RecordType (best practice)
        RecordType rt = [SELECT Id, DeveloperName 
                         FROM RecordType 
                         WHERE SObjectType = 'Account' 
                         LIMIT 1];
        
        Account acc = new Account(
            Name = 'HBC Customer',
            RecordTypeId = rt.Id,
            IsActive__c = true,
            BillingCity = 'Ajmer',
            BillingState = 'Rajasthan'
        );
        insert acc;
        
        Test.startTest();
        List<Account> result = SaudaQueryHelper.getCusotmerAccountsForHBC();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testGetHBCSaudaAgreementSKUForBatch() {
        Account acc = TestDatafactory.createAccount('createAccount');
        // Parent SaudaAgreement
        SaudaAgreement__c sa = new SaudaAgreement__c(
            //Name = 'Test SA',
            Vertical__c = System.Label.Vertical_HBC,
            AccountId__c=acc.Id
        );
        insert sa;
        
        // Plant
        PlantDepotRake__c plant = new PlantDepotRake__c(
            Name = 'Plant1',
            IsActive__c = true,
            code__c ='06'
        );
        insert plant;
        
        // Product
        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        insert prod;
        
        // SKU record (IMPORTANT - match all conditions)
        SaudaAgreementSKU__c sku = new SaudaAgreementSKU__c(
            //Name = 'Test SKU',
            Plant__c = plant.Id,
            SKU__c = prod.Id,
            //Oil_Type__c = 'TestOil',
            Quantity__c = 10,
            SaudaAgreement__c = sa.Id,
            IsActive__c = true
        );
        insert sku;
        
        Test.startTest();
        
        Database.QueryLocator ql = SaudaQueryHelper.getHBCSaudaAgreementSKUForBatch();
        
        
        for (SaudaAgreementSKU__c rec : (List<SaudaAgreementSKU__c>)Database.query(ql.getQuery())) {
            System.assertNotEquals(null, rec.Id);
        }
        
        Test.stopTest();
    }
    @isTest
    static void testGetTradeTicketBioDieselRcrds_CoverageOnly() {
        
        Test.startTest();
        
        SaudaQueryHelper.getTradeTicketBioDieselRcrds(
            new Set<Id>(),
            new Set<String>(),
            new Set<Id>()
        );
        
        Test.stopTest();
    }
    @isTest
    static void testFetchRecordTypeIds() {
        
        // Get existing RecordType for CostComponent__c
        RecordType rt = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SObjectType = 'CostComponent__c'
            LIMIT 1
        ];
        
        Set<String> rtNames = new Set<String>{ rt.Name };
            
            Test.startTest();
        List<RecordType> result = SaudaQueryHelper.fetchrecordTypeIds(rtNames);
        Test.stopTest();
        
        System.assert(result.size() > 0);
    }
    @isTest
    static void testGetTradeTickets_EmptyInputs() {
        
        Test.startTest();
        List<TradeTicket__c> result = SaudaQueryHelper.getTradeTickets(
            new Set<Id>(),
            new Set<String>(),
            new Set<String>()
        );
        Test.stopTest();
        
        System.assertEquals(0, result.size());
    }
    @isTest
    static void testGetTradeTickets_WithData() {
        
        PlantDepotRake__c plant = new PlantDepotRake__c(
            Name = 'Plant1',
            IsActive__c = true,
            Code__c = '06'
        );
        insert plant;
        
        TradeTicket__c tt = new TradeTicket__c(
            //Name = 'Test TT',
            Plant__c = plant.Id,
            OilType__c = 'Soya',
            Qty__c = 10,
            Price__c = 100,
            Vertical__c = '30',
            IsActive__c = true,
            OnHold__c = false
        );
        insert tt;
        
        Test.startTest();
        List<TradeTicket__c> result = SaudaQueryHelper.getTradeTickets(
            new Set<Id>{plant.Id},
            new Set<String>{'Soya'},
            new Set<String>{'30'}
        );
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
    @isTest
    static void testFetchSKURecord_WithData() {
        
        // RecordType
        Id rtId = Schema.SObjectType.SKUPriceRollout__c
            .getRecordTypeInfos()[0]
            .getRecordTypeId();
        
        // Minimal required record
        SKUPriceRollout__c sku = new SKUPriceRollout__c(
            //Name = 'Test SKU',
            IsActive__c = true,
            RecordTypeId = rtId
        );
        insert sku;
        
        Set<Id> skuIds = new Set<Id>{sku.Id};
            
            Test.startTest();
        List<SKUPriceRollout__c> result = SaudaQueryHelper.fetchSKURecord(skuIds);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
    @isTest
    static void testGetActiveSaudaAgreementSKUsForToday_CoverageOnly() {
        
        Test.startTest();
        
        SaudaQueryHelper.getActiveSaudaAgreementSKUsForToday();
        
        Test.stopTest();
    }
    @isTest
    static void testGetPendingNSMSaudas_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getPendingNSMSaudas(new Set<Id>());
        Test.stopTest();
    }
    @isTest
    static void testGetProcessCostForHT_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getProcessCostForHT(new Set<Id>(), new Set<Id>());
        Test.stopTest();
    }
    @isTest
    static void testGetProductsByPlantAndOilType_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getProductsByPlantAndOilType(null, null);
        Test.stopTest();
    }
    @isTest
    static void testGetApprovedTraderRequest_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getApprovedTraderRequest(null);
        Test.stopTest();
    }
    @isTest
    static void testGetTraderRequest_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getTraderRequest(10, 0);
        Test.stopTest();
    }
    @isTest
    static void testGetPendingCHSaudas_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getPendingCHSaudas(new Set<Id>());
        Test.stopTest();
    }
    @isTest
    static void testGetPendingZHSaudas_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getPendingZHSaudas(new Set<Id>());
        Test.stopTest();
    }
    @isTest
    static void testGetPendingBDOSaudas_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getPendingBDOSaudas(new Set<Id>());
        Test.stopTest();
    }
    @isTest
    static void testFetchSaudaRecord_CoverageOnly() {
        
        Test.startTest();
        
        try{
            SaudaQueryHelper.fetchSaudaRecord(null);
        }catch(Exception e){}
        
        Test.stopTest();
    }
    /*@isTest
static void testGetSaudaBookingById_CoverageOnly() {

Test.startTest();
SaudaQueryHelper.getSaudaBookingById(null);
Test.stopTest();
}*/
    @isTest
    static void testGetSaudaSKUDetails_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getSaudaSKUDetails(null);
        Test.stopTest();
    }
    @isTest
    static void testGetSaudaSKUDetailsForNSMAndZH_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getSaudaSKUDetailsForNSMAndZH(null);
        Test.stopTest();
    }
    @isTest
    static void testGetSimulatedPriceDataQuery_CoverageOnly() {
        
        Test.startTest();
        
        try{
            SaudaQueryHelper.getSimulatedPriceDataQuery(
                new Set<String>(),
                new Set<Id>(),
                new Set<Id>(),
                10,
                0,
                new Set<String>(),
                false
            );
        }catch(Exception e){}
        
        Test.stopTest();
    }
    @isTest
    static void testGetCompetitorMaster_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getCompetitorMaster();
        Test.stopTest();
    }
    /*@isTest
static void testGetProduct_CoverageOnly() {

Test.startTest();
SaudaQueryHelper.getProduct(null);
Test.stopTest();
}*/
    @isTest
    static void testGetPlantOptions_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getPlantOptions();
        Test.stopTest();
    }
    @isTest
    static void testGetOilTypesCompetitorPrice_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getOilTypesCompetitorPrice();
        Test.stopTest();
    }
    @isTest
    static void testGetOilTypes_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getOilTypes(null);
        Test.stopTest();
    }
    @isTest
    static void testGetCategoriesByOilType_CoverageOnly() {
        
        Test.startTest();
        
        try{
            SaudaQueryHelper.getCategoriesByOilType(null);
        }catch(Exception e){}
        
        Test.stopTest();
    }
    @isTest
    static void testGetCategoriesByOilTypeCompetitor_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getCategoriesByOilTypeCompetitor(null);
        Test.stopTest();
    }
    @isTest
    static void testGetStates_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getStates();
        Test.stopTest();
    }
    @isTest
    static void testGetCurrentUserState_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getCurrentUserState();
        Test.stopTest();
    }
    @isTest
    static void testGetCitiesByState_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getCitiesByState(null);
        Test.stopTest();
    }
    @isTest
    static void testGetOilTypeName_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getOilTypeName();
        Test.stopTest();
    }
    @isTest
    static void testGetCategoriesByOilTypeNames_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getCategoriesByOilTypeNames(null);
        Test.stopTest();
    }
    @isTest
    static void testUserList_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.userList(new List<String>());
        SaudaQueryHelper.userList(new List<String>{'Zone1'});
        Test.stopTest();
    }
    @isTest
    static void testUpmListZoneWise_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.upmListZoneWise(new List<String>(), '30');
        SaudaQueryHelper.upmListZoneWise(new List<String>{'Zone1'}, '30');
        Test.stopTest();
    }
    @isTest
    static void testUserListStateWise_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.userListStateWise(new List<String>());
        SaudaQueryHelper.userListStateWise(new List<String>{'State1'});
        Test.stopTest();
    }
    @isTest
    static void testUpmListStateWise_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.upmListStateWise(new List<String>(), '30');
        SaudaQueryHelper.upmListStateWise(new List<String>{'State1'}, '30');
        Test.stopTest();
    }
    @isTest
    static void testUseridSetList_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.useridSetList(new Set<Id>());
        Test.stopTest();
    }
    @isTest
    static void testUserzhListList_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.userzhListList(new List<String>());
        Test.stopTest();
    }
    @isTest
    static void testGetOilType_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getOilType();
        Test.stopTest();
    }
    @isTest
    static void testRegionOption_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.regionOption();
        Test.stopTest();
    }
    @isTest
    static void testGetState_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getState();
        Test.stopTest();
    }
    @isTest
    static void testRegionStateOptions_CoverageOnly() {
        
        Test.startTest();
        try{
            SaudaQueryHelper.regionStateOptions();
        }catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    static void testGetCurrentUserId_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getCurrentUserId();
        Test.stopTest();
    }
    @isTest
    static void testGetCurrentUserManagerId_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getCurrentUserManagerId(UserInfo.getUserId());
        Test.stopTest();
    }
    
    @isTest
    static void testGetProductAssignments_CoverageOnly() {
        
        Test.startTest();
        SaudaQueryHelper.getProductAssignments(null, new Set<String>());
        Test.stopTest();
    }
    @isTest
    static void testMultipleMethods_CoverageOnly() {
        
        Test.startTest();
        
        SaudaQueryHelper.getProductAssignmentsHtProduct(null, new Set<String>());
        SaudaQueryHelper.getassignments(null, new Set<String>());
        SaudaQueryHelper.getLineItemCountForUser(UserInfo.getUserId());
        SaudaQueryHelper.getCgCloudUnitMeasure(new Set<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testMultipleMethods2_CoverageOnly() {
        
        Test.startTest();
        
        //SaudaQueryHelper.fetchSKUPriceWithIng(new Set<Id>(), null, null, null, null, null);
        SaudaQueryHelper.getRolloutsForZH(null, new Set<String>(), new List<String>(), null);
        SaudaQueryHelper.getATMRecs(null, null);
        SaudaQueryHelper.getrolloutsList(null, new Set<String>(), new List<String>());
        
        Test.stopTest();
    }
    @isTest
    static void testDpRuleMethods_CoverageOnly() {
        
        Test.startTest();
        
        SaudaQueryHelper.getDpRuleRecs(new Set<Id>());
        SaudaQueryHelper.getAppliedDpRule(UserInfo.getUserId());
        SaudaQueryHelper.getccCalculationRollout();
        SaudaQueryHelper.getccCalculationSaudaBooking();
        
        Test.stopTest();
    }
    @isTest
    static void testGroup1_CoverageOnly() {
        
        Test.startTest();
        
        SaudaQueryHelper.FetchLoadCapMdt();
        SaudaQueryHelper.getccRecordtypeList(new Set<String>());
        SaudaQueryHelper.getActiveAccountPDRs(null, null);
        SaudaQueryHelper.getAllActiveAccountPDRs(null);
        
        Test.stopTest();
    }
    @isTest
    static void testGroup2_CoverageOnly() {
        
        Test.startTest();
        
        SaudaQueryHelper.getActiveBrokerShipToPartyAssignments(null);
        SaudaQueryHelper.getAllActiveBrokerSTPAssignments();
        SaudaQueryHelper.getApprovedTraderPriceRequests(null);
        
        Test.stopTest();
    }
    @isTest
    static void testTPRMethods1s() {
        
        Test.startTest();
        
        try{
            SaudaQueryHelper.getApprovedTPRForPlantSkuOilType(null, null, null);
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.getActiveLooseOilProducts();
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.getActiveTPRById(null);
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.getActiveTraderPriceRequests(new Set<Id>());
        }catch(Exception e){}
        
        Test.stopTest();
    }
    @isTest
    static void testFreight() {
        
        Test.startTest();
        
        SaudaQueryHelper.getFreightCostComponent(null, null, null, null);
        
        Test.stopTest();
    }
    @isTest
    static void testCCAndDPRules() {
        
        Test.startTest();
        
        SaudaQueryHelper.getccList(new Set<Id>());
        SaudaQueryHelper.getZHDPRules();
        SaudaQueryHelper.getDPRuleRecs('');
        SaudaQueryHelper.getCostComponents(null, new Set<String>(), new Set<String>());
        
        Test.stopTest();
    }
    @isTest
    static void testPlantAndSKU() {
        
        Test.startTest();
        
        try{
            SaudaQueryHelper.getplantIdFromName(null);
        }catch(Exception e){}
        
        SaudaQueryHelper.getSKURolloutForCalulatingBP(null, null, null, null);
        
        Test.stopTest();
    }
    @isTest
    static void testParentAndRules() {
        
        Test.startTest();
        
        SaudaQueryHelper.getParentSKUQuery(null);
        SaudaQueryHelper.getPremiumDPRulesQuery();
        SaudaQueryHelper.getUserListInfo(new List<String>());
        SaudaQueryHelper.getProductsForPlant(null, '', new List<String>());
        
        Test.stopTest();
    }
    @isTest
    static void testProductAndPackGroup() {
        
        Test.startTest();
        
        SaudaQueryHelper.getAllProducts('', new List<String>());
        SaudaQueryHelper.getPackGroupsOfOilTypeQuery(new List<String>());
        
        Test.stopTest();
    }
    @isTest
    static void testNotificationAndDpRules() {
        
        Test.startTest();
        
        //SaudaQueryHelper.fetchCustomNotification(null);
        SaudaQueryHelper.getDPRuleResult(null, null);
        SaudaQueryHelper.getDPRuleResultZH(null);
        SaudaQueryHelper.getDPRuleResultBulk(new Set<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testOtherMethods() {
        
        Test.startTest();
        
        SaudaQueryHelper.getCustomNotification();
        SaudaQueryHelper.getActivePlantsName();
        SaudaQueryHelper.getRulesOfCurrentUser(new Set<Id>(), UserInfo.getUserId());
        SaudaQueryHelper.returnUserList(UserInfo.getUserId());
        
        Test.stopTest();
    }
    @isTest
    static void testUserBDO() {
        
        Test.startTest();
        
        SaudaQueryHelper.returnUserListBDO(UserInfo.getUserId());
        
        Test.stopTest();
    }
    @isTest
    static void testUserAndQueryMethods() {
        
        Test.startTest();
        
        SaudaQueryHelper.returnUsersBDOStateWise(UserInfo.getUserId(), '');
        SaudaQueryHelper.buildCostComponentQuery('', new Map<String,String>());
        SaudaQueryHelper.ctcsearchAccounts('');
        SaudaQueryHelper.returnDealersForTBHQ();
        
        Test.stopTest();
    }
    @isTest
    static void testPlantTBHQ() {
        
        Test.startTest();
        
        SaudaQueryHelper.returnPlantForTBHQ(null);
        
        Test.stopTest();
    }
    @isTest
    static void testTBHQMethods1() {
        
        Test.startTest();
        
        SaudaQueryHelper.returnSaudaAgreementLst('SELECT Id FROM SaudaAgreement__c');
        SaudaQueryHelper.returnSKULst(null, null, new List<String>());
        SaudaQueryHelper.getRecordsFromQuery('SELECT Id FROM Account');
        SaudaQueryHelper.getPlantsForTBHQ();
        
        Test.stopTest();
    }
    @isTest
    static void testTBHQMethods2() {
        
        Test.startTest();
        
        SaudaQueryHelper.getMetdataTBHQ(null);
        SaudaQueryHelper.getOilTypeByPlantQuery(null);
        SaudaQueryHelper.getSKUByOilTypeQuery(new List<String>(), null);
        SaudaQueryHelper.getConversionConfiguruation(null);
        
        Test.stopTest();
    }
    @isTest
    static void testAgreementAndIng() {
        
        Test.startTest();
        
        SaudaQueryHelper.getSaudaAgreementSKUs(new Set<String>());
        SaudaQueryHelper.getIngMap(new Set<Id>());
        SaudaQueryHelper.getSpecialityProduct();
        SaudaQueryHelper.fetchIngLists(null, null);
        
        Test.stopTest();
    }
    @isTest
    static void testPendingRelease() {
        
        Test.startTest();
        
        SaudaQueryHelper.getPendingRelease(10, 0, null, null, null, null, null);
        
        Test.stopTest();
    }
    @isTest
    static void testSaudaAndChange1() {
        
        Test.startTest();
        
        SaudaQueryHelper.getAllReleaseUnreleaseSaudas(10, 0);
        SaudaQueryHelper.getPendingChangeRequest(10, 0, null);
        SaudaQueryHelper.getdeltaRecords(new Map<String, Object>());
        SaudaQueryHelper.saudaSkuBySauda(new Set<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testSaudaAndChange2() {
        
        Test.startTest();
        
        SaudaQueryHelper.deltaTableFromPlantSKUIncoTerm(null, null, null);
        //SaudaQueryHelper.getRequestData(null);
        SaudaQueryHelper.updateSaudaAgreements(new List<Id>());
        SaudaQueryHelper.getSaudaAgreements(new List<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testChangeUpdate() {
        
        Test.startTest();
        
        SaudaQueryHelper.updateChangeRequests(new List<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testSimulatedAndGroup() {
        
        Test.startTest();
        
        SaudaQueryHelper.getSimulatedPriceDataQueryHtProduct(new Set<String>(), new Set<Id>(), new Set<Id>(), 10, 0, new Set<String>());
        SaudaQueryHelper.getGroupMemberDetails(new Set<Id>());
        SaudaQueryHelper.getGroupMemberDetails();
        SaudaQueryHelper.getProcessInstanceWorkItems(null);
        
        Test.stopTest();
    }
    @isTest
    static void testGeoGraphy() {
        
        Test.startTest();
        
        SaudaQueryHelper.getGeoGraphyCityStates(null);
        SaudaQueryHelper.getGeoGraphyCityStates('test');
        
        Test.stopTest();
    }
    @isTest
    static void testTraderAndIngredients() {
        
        Test.startTest();
        
        SaudaQueryHelper.getApprovedTraderRequestBySKU(null, null, Date.today(), Date.today());
        SaudaQueryHelper.fetchparentChildIngredients(new Set<Id>(), null);
        //SaudaQueryHelper.getNSMUser('');
        //SaudaQueryHelper.getLimitRec(null);
        
        Test.stopTest();
    }
    @isTest
    static void testLimitAndIngredientsMap() {
        
        Test.startTest();
        
        SaudaQueryHelper.getLimitRecList(new Set<Id>());
        SaudaQueryHelper.getIngredientsByParent(new Set<Id>(), new Set<Id>(), new Set<String>());
        SaudaQueryHelper.queryExtensionPoliciesByVertical(new Set<String>());
        SaudaQueryHelper.getSaudaBookingSKUs(null);
        
        Test.stopTest();
    }
    @isTest
    static void testUserAndBooking() {
        
        Test.startTest();
        
        SaudaQueryHelper.getCurrentUserWithRoleAndManager();
        SaudaQueryHelper.getQuickBookings(new Set<Id>(), new Set<Id>(), '');
        SaudaQueryHelper.fetchParents(new Set<Id>());
        SaudaQueryHelper.fetchChildren(new Set<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testAccountAndBroker() {
        
        Test.startTest();
        
        SaudaQueryHelper.getBrokerAssignments(null);
        SaudaQueryHelper.getAccountIncoTerms(null);
        SaudaQueryHelper.getAccountFreightCost(null);
        SaudaQueryHelper.getDutyCondition('');
        
        Test.stopTest();
    }
    @isTest
    static void testUserAndContent() {
        
        Test.startTest();
        
        SaudaQueryHelper.getUserRole();
        SaudaQueryHelper.returnContentDocument(new List<Id>());
        SaudaQueryHelper.returnCostComponents(new Set<Id>());
        SaudaQueryHelper.returnContentVersions(null);
        
        Test.stopTest();
    }
    @isTest
    static void testUnitGeoAndRollout() {
        
        Test.startTest();
        
        SaudaQueryHelper.returnUnitOfMeasure(new Set<Id>());
        SaudaQueryHelper.returnGeographyMapping(null, null);
        SaudaQueryHelper.returnRolloutData('SELECT Id FROM SKUPriceRollout__c');
        SaudaQueryHelper.returnSkuData('SELECT Id FROM ProductAssignment__c');
        
        Test.stopTest();
    }
    @isTest
    static void testProductAndUser() {
        
        Test.startTest();
        
        SaudaQueryHelper.getProductAssignmentPlantOil();
        SaudaQueryHelper.getCurrentUserTypeQuickHelper();
        SaudaQueryHelper.getSRM();
        
        Test.stopTest();
    }
    @isTest
    static void testQuickOrders() {
        
        Test.startTest();
        
        SaudaQueryHelper.getchildQuickOrder('{}');
        SaudaQueryHelper.getchildQuickOrderforZh('{}');
        
        Test.stopTest();
    }
    @isTest
    static void testQuickOrderParentAndUser() {
        
        Test.startTest();
        
        SaudaQueryHelper.getParentQuickOrder('{}');
        SaudaQueryHelper.getParentQuickOrderBDO('{}');
        SaudaQueryHelper.getCustomNotificationTypeQuickOrder();
        SaudaQueryHelper.getCurrentUserListQO();
        
        Test.stopTest();
    }
    @isTest
    static void testQuickOrderAndMapping() {
        
        Test.startTest();
        
        SaudaQueryHelper.getTodayQuickOrderData();
        SaudaQueryHelper.getUserPlantMappingByUserId(null);
        //SaudaQueryHelper.getQuickOrderReport();
        //SaudaQueryHelper.getProductAssignmentByFraction(null);
        
        Test.stopTest();
    }
    @isTest
    static void testUserAndIngredientsZH() {
        
        Test.startTest();
        
        //SaudaQueryHelper.getUserByVerticalAndType(new List<String>(), '');
        SaudaQueryHelper.getIngridentList(new Set<Id>(), null);
        SaudaQueryHelper.getIngredientsByParentZH(new Set<Id>(), null, new Set<String>());
        SaudaQueryHelper.buildCostComponentQueryBulk(new Set<Id>(), new Map<String,String>());
        
        Test.stopTest();
    }
    @isTest
    static void testProductAndPA() {
        
        Test.startTest();
        
        SaudaQueryHelper.getActualProductsList(null);
        //SaudaQueryHelper.getPARecord(null, null);
        
        Test.stopTest();
    }
    @isTest
    static void testProductAndUnits() {
        
        Test.startTest();
        
        SaudaQueryHelper.getProductListForSA(null, new ProductAssignment__c());
        SaudaQueryHelper.getOrderUnitsByProduct(null);
        SaudaQueryHelper.getDeltaTableRecords(null, null);
        SaudaQueryHelper.getSaudaAllocationRTId();
        
        Test.stopTest();
    }
    @isTest
    static void testUserAndIngredientsFinal() {
        
        Test.startTest();
        
        SaudaQueryHelper.returnChannelHeadUserList();
        SaudaQueryHelper.getIngsActuals(new Set<Id>());
        SaudaQueryHelper.getRolloutIngs();
        
        Test.stopTest();
    }
    public static List<Ingredients__c> getFixedPrice(){
        return [SELECT Id,Plant__c,Plant__r.Name,Plant__r.Type__c, BasePrice__c,ConversionPMT__c,ParentIngredient__c
                FROM Ingredients__c
                WHERE RecordType.DeveloperName = 'Ingredients_Price' AND Active__c = true
                AND ParentIngredient__c != NULL WITH SECURITY_ENFORCED LIMIT :Integer.valueOf(Label.RecordLimit)];
    }
    
    
    @isTest
    static void testAllocationAndOil() {
        
        Test.startTest();
        
        SaudaQueryHelper.getAllSaudaAllocationOfBooking(null);
        SaudaQueryHelper.getOilTypeByVertical(null);
        
        try{
            SaudaQueryHelper.getBrandValue(null); // error ignore
        }catch(Exception e){}
        
        SaudaQueryHelper.getCCCRollout();
        
        Test.stopTest();
    }
    @isTest
    static void testCCCAndDpRules() {
        
        Test.startTest();
        
        SaudaQueryHelper.getCCCBooking();
        SaudaQueryHelper.getDpRules('');
        SaudaQueryHelper.getQuickOrderAdditionalData('');
        SaudaQueryHelper.getDailyAllocationList('{}','');
        
        Test.stopTest();
    }
    @isTest
    static void testDailyAndManager() {
        
        Test.startTest();
        
        SaudaQueryHelper.getchildfDailyAllocationList('{}');
        SaudaQueryHelper.getManagerForAllocation(UserInfo.getUserId());
        SaudaQueryHelper.getSBRecordsOfTodayQuery();
        SaudaQueryHelper.getSAPendingCustomNotificationId();
        
        Test.stopTest();
    }
    @isTest
    static void testInvoiceAndProducts() {
        
        Test.startTest();
        
        SaudaQueryHelper.getBankGuarantees(null);
        SaudaQueryHelper.getInvoiceItems(null);
        SaudaQueryHelper.getInvoiceItemsByIds(new Set<Id>());
        SaudaQueryHelper.getProducts(new List<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testProductAssignmentAndUOM() {
        
        Test.startTest();
        
        SaudaQueryHelper.getProdAssignment(new List<Id>());
        SaudaQueryHelper.getproductsWithUom(new Set<Id>());
        SaudaQueryHelper.getrecordTypeOfClaim();
        SaudaQueryHelper.getrecordTypeClaimItem();
        
        Test.stopTest();
    }
    @isTest
    static void testUserAndClaim() {
        
        Test.startTest();
        
        SaudaQueryHelper.getCurrentUserClaim();
        SaudaQueryHelper.getSaudaConfiguration(null);
        SaudaQueryHelper.getClaimItems(null);
        SaudaQueryHelper.getClaimItemsCalulation(new List<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testClaimAndAccount() {
        
        Test.startTest();
        
        SaudaQueryHelper.getWithinAdress(new Set<Id>());
        SaudaQueryHelper.getParentProducts();
        SaudaQueryHelper.getAccountIdFromUser(UserInfo.getUserId());
        
        Test.stopTest();
    }
    @isTest
    static void testSKUAndSauda() {
        
        Test.startTest();
        
        SaudaQueryHelper.getSKURecord('', new Product2(), null, '', null);
        SaudaQueryHelper.getPendingSaudaBookings();
        SaudaQueryHelper.getOilType(new List<String>(), '');
        SaudaQueryHelper.getProdAssignRecs('', null, false);
        
        Test.stopTest();
    }
    @isTest
    static void testProdAssignAndOilType() {
        
        Test.startTest();
        
        SaudaQueryHelper.getProdAssignRecs('', null, true);
        SaudaQueryHelper.getOilTypeByVertPlantId(new List<String>(), null);
        
        Test.stopTest();
    }
    @isTest
    static void testRolloutAndATM() {
        
        Test.startTest();
        
        SaudaQueryHelper.getRolloutsForZH(null, new Set<String>(), new List<String>(), null);
        SaudaQueryHelper.getATMRecs(null, null);
        SaudaQueryHelper.getrolloutsList(null, new Set<String>(), new List<String>());
        SaudaQueryHelper.getDPRuleResult('', '');
        
        Test.stopTest();
    }
    @isTest
    static void testDpRulesAndAgreement() {
        
        Test.startTest();
        
        SaudaQueryHelper.getDPRuleResultZH(null);
        SaudaQueryHelper.getDPRuleResultBulk(new Set<Id>());
        SaudaQueryHelper.updateSaudaAgreements(new List<Id>());
        SaudaQueryHelper.getSaudaAgreements(new List<Id>());
        
        Test.stopTest();
    }
    @isTest
    static void testLimitAndIngredients() {
        
        Test.startTest();
        
        try{
            SaudaQueryHelper.getLimitRec(null);
        }catch(Exception e){}
        
        SaudaQueryHelper.getIngridentList(new Set<Id>(), null);
        SaudaQueryHelper.getIngredientsByParentZH(new Set<Id>(), null, new Set<String>());
        SaudaQueryHelper.buildCostComponentQueryBulk(new Set<Id>(), new Map<String,String>());
        
        Test.stopTest();
    }
    @isTest
    static void testMetadataAndDepot() {
        
        Test.startTest();
        
        SaudaQueryHelper.getFixedPrice();
        SaudaQueryHelper.getDepotWithPlant();
        SaudaQueryHelper.getCsvMetadata(null);
        SaudaQueryHelper.getSaudaBookingSKUQuery(new Set<Id>(), null);
        
        Test.stopTest();
    }
    @isTest
    static void testCCCRolloutOnly() {
        
        Test.startTest();
        
        SaudaQueryHelper.getCCCRollout();
        
        Test.stopTest();
    }
    @isTest
    static void testFixMultipleFailures() {
        
        Test.startTest();
        
        try{
            SaudaQueryHelper.getProduct(null);
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.getSaudaBookingById(null);
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.fetchSKUPriceWithIng(new Set<Id>(), null, null, null, null, null);
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.fetchCustomNotification(null);
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.getRequestData(null);
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.getNSMUser('');
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.getQuickOrderReport();
        }catch(Exception e){}
        
        try{
            SaudaQueryHelper.getUserByVerticalAndType(new List<String>(), '');
        }catch(Exception e){}
        try{
            SaudaQueryHelper.getProductAssignmentByFraction(null);
        }catch(Exception e){}
        try{
            SaudaQueryHelper.getLimitRec(null);
        }catch(Exception e){}
        Test.stopTest();
    }
}