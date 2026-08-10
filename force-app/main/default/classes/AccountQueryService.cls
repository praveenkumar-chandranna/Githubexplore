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
                          //code not completed stupid
        return [SELECT Id, Name, Industry, Phone, Website FROM Account ORDER BY Name];
    }
}