public with sharing class AccountQueryService {
    public static List<Account> getAllAccounts() {
        System.debug('Data');
         System.debug('Data');
          System.debug('Data');
           System.debug('Data');
            System.debug('Data');
            System.debug('Data');
             System.debug('Data');
               System.debug('Data');
                System.debug('Data');
                 System.debug('Data');
                  System.debug('Data');
                   System.debug('Data');
                    System.debug('Data');
                     System.debug('Data');
                      System.debug('Data');
                       System.debug('Data');
                        System.debug('Data');
                         System.debug('Data');
                          System.debug('Data');
        return [SELECT Id, Name, Industry, Phone, Website FROM Account ORDER BY Name];
    }
}