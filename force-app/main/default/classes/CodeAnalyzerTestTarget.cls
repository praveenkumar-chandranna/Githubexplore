/**
 * CodeAnalyzerTestTarget
 * Purpose : Intentional PMD/ESLint violations to verify Salesforce Code Analyzer
 *           is correctly detecting issues in the PR Validation workflow.
 *
 * Expected violations:
 *   Sev1 - ApexCRUDViolation       : SOQL/DML without FLS/CRUD checks
 *   Sev1 - ApexSharingViolations   : class missing with sharing keyword
 *   Sev2 - AvoidHardcodingId       : hardcoded Salesforce record Id
 *   Sev2 - ApexSOQLInjection       : dynamic SOQL built from user input
 *   Sev3 - UnusedLocalVariable     : variable declared but never used
 *   Sev3 - EmptyCatchBlock         : catch block with no handling
 *   Sev3 - AvoidDebugStatements    : System.debug in production code
 *   Sev3 - NcssMethodCount         : method too long / high complexity
 */
public class CodeAnalyzerTestTarget {

    // ----------------------------------------------------------------
    // Sev1: ApexSharingViolations — class has no 'with sharing' keyword
    // ----------------------------------------------------------------

    // ----------------------------------------------------------------
    // Sev1: ApexCRUDViolation — SOQL without isAccessible() check
    // ----------------------------------------------------------------
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Phone FROM Account LIMIT 100];
    }

    // ----------------------------------------------------------------
    // Sev1: ApexCRUDViolation — DML without isCreateable() check
    // ----------------------------------------------------------------
    public static void insertContact(String lastName) {
        Contact c = new Contact(LastName = lastName);
        insert c;
    }

    // ----------------------------------------------------------------
    // Sev2: AvoidHardcodingId — hardcoded record Id
    // ----------------------------------------------------------------
    public static Account getHardcodedAccount() {
        Id hardcodedId = '0015g00000XyZAbAAN';
        return [SELECT Id, Name FROM Account WHERE Id = :hardcodedId LIMIT 1];
    }

    // ----------------------------------------------------------------
    // Sev2: ApexSOQLInjection — dynamic SOQL from unescaped user input
    // ----------------------------------------------------------------
    public static List<Account> searchAccounts(String userInput) {
        String query = 'SELECT Id, Name FROM Account WHERE Name LIKE \'%' + userInput + '%\'';
        return Database.query(query);
    }

    // ----------------------------------------------------------------
    // Sev3: UnusedLocalVariable — declared but never read
    // ----------------------------------------------------------------
    public static void unusedVariableExample() {
        Integer unusedCounter = 0;
        String result = 'done';
        System.debug(result);
    }

    // ----------------------------------------------------------------
    // Sev3: EmptyCatchBlock — swallowed exception
    // ----------------------------------------------------------------
    public static void emptyCatchExample() {
        try {
            Account a = [SELECT Id FROM Account LIMIT 1];
            delete a;
        } catch (Exception e) {
            // intentionally empty — PMD EmptyCatchBlock violation
        }
    }

    // ----------------------------------------------------------------
    // Sev3: AvoidDebugStatements — System.debug in production code
    // ----------------------------------------------------------------
    public static void debugExample(String value) {
        System.debug('Processing value: ' + value);
        System.debug(LoggingLevel.ERROR, 'Error level debug: ' + value);
    }

    // ----------------------------------------------------------------
    // Sev3: NcssMethodCount — overly long method with high complexity
    // ----------------------------------------------------------------
    public static String complexMethod(Integer input) {
        String result = '';
        if (input == 1) {
            result = 'one';
        } else if (input == 2) {
            result = 'two';
        } else if (input == 3) {
            result = 'three';
        } else if (input == 4) {
            result = 'four';
        } else if (input == 5) {
            result = 'five';
        } else if (input == 6) {
            result = 'six';
        } else if (input == 7) {
            result = 'seven';
        } else if (input == 8) {
            result = 'eight';
        } else if (input == 9) {
            result = 'nine';
        } else if (input == 10) {
            result = 'ten';
        } else if (input == 11) {
            result = 'eleven';
        } else if (input == 12) {
            result = 'twelve';
        } else {
            result = 'unknown';
        }
        System.debug(result);
        return result;
    }
}
