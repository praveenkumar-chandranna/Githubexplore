@istest
public with sharing class SearchControllerTest {
  
    @testSetup static void setup() {
        Product2 testExistingProduct = new Product2(ProductCode = '12345',name ='Name');
        insert testExistingProduct;
    }
    
    @isTest static void   TestBasicProductAddProperties() {
        Test.startTest();
        Product2 updatedProduct = [select id,ProductCode,name from Product2 where name ='Name'];
        SearchController.retriveProducts(updatedProduct.name);
        Test.stopTest();
    }
}