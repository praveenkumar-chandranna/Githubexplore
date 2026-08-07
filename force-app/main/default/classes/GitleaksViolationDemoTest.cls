/**
 * GitleaksViolationDemoTest.cls
 * ─────────────────────────────────────────────────────────────
 * PURPOSE : Test class for GitleaksViolationDemo.
 *           All PII data below should be SKIPPED by Gitleaks
 *           because this file matches the Test.cls allowlist.
 *
 * SHOULD BE SKIPPED (allowlisted via Test.cls path):
 *   indian-aadhaar             → 12-digit Aadhaar
 *   indian-pan                 → PAN card format
 *   indian-mobile-labeled      → mobile = +91...
 *   indian-mobile-bare         → bare 10-digit number
 *   email-hardcoded            → quoted email
 *   indian-passport            → passport number
 *   indian-bank-account        → account_no = ...
 *   indian-ifsc                → IFSC code
 *   indian-gst                 → GST number
 *   sf-org-id                  → hardcoded Salesforce record ID
 *   sf-hardcoded-record-id     → accountId = '001xx...'
 *   apex-soql-hardcoded-id     → WHERE Id = '001xx...'
 *   apex-hardcoded-credential  → password = 'test...'
 *   generic-password           → pwd = 'test...'
 * ─────────────────────────────────────────────────────────────
 */
@isTest
private class GitleaksViolationDemoTest {

    // ── Test Data Constants ───────────────────────────────────
    // All PII below should NOT be flagged by Gitleaks

    // indian-aadhaar → allowlisted
    static final String TEST_AADHAAR = '2345 6789 0123';

    // indian-pan → allowlisted
    static final String TEST_PAN = 'ABCPF1234D';

    // indian-mobile-labeled → allowlisted
    static final String TEST_MOBILE = '+91 9876543210';

    // indian-mobile-bare → allowlisted
    static final String TEST_CONTACT = '9876543210';

    // email-hardcoded → allowlisted
    static final String TEST_EMAIL = 'testuser@somecompany.in';

    // indian-passport → allowlisted
    static final String TEST_PASSPORT = 'A1234567';

    // indian-bank-account → allowlisted
    static final String TEST_ACCOUNT_NO = '123456789012';

    // indian-ifsc → allowlisted
    static final String TEST_IFSC = 'HDFC0001234';

    // indian-gst → allowlisted
    static final String TEST_GST = '27ABCPF1234D1Z5';

    // sf-hardcoded-record-id → allowlisted
    static final String TEST_ACCOUNT_ID = '001xx000003GYkFAAW';

    // apex-hardcoded-credential → allowlisted
    static final String TEST_PASSWORD = 'testPassword123';

    // generic-password → allowlisted
    static final String TEST_PWD = 'dummyPwd123';

    // ── Test Setup ────────────────────────────────────────────

    @TestSetup
    static void setup() {
        insert new List<Account>{
            new Account(
                Name  = 'Test Account PII',
                Phone = '+91 9876543210'
            ),
            new Account(
                Name  = 'Test Account 2',
                Phone = '9876543210'
            )
        };
    }

    // ── Test Methods ──────────────────────────────────────────

    @isTest
    static void testPIIDataNotFlaggedInTestClass() {
        // Verify test data constants are set correctly
        System.assertEquals('2345 6789 0123', TEST_AADHAAR, 'Aadhaar should match');
        System.assertEquals('ABCPF1234D', TEST_PAN, 'PAN should match');
        System.assertEquals('+91 9876543210', TEST_MOBILE, 'Mobile should match');
        System.assertEquals('9876543210', TEST_CONTACT, 'Contact should match');
        System.assertEquals('testuser@somecompany.in', TEST_EMAIL, 'Email should match');
        System.assertEquals('A1234567', TEST_PASSPORT, 'Passport should match');
        System.assertEquals('123456789012', TEST_ACCOUNT_NO, 'Bank account should match');
        System.assertEquals('HDFC0001234', TEST_IFSC, 'IFSC should match');
        System.assertEquals('27ABCPF1234D1Z5', TEST_GST, 'GST should match');
    }

    @isTest
    static void testHardcodedRecordId() {
        // sf-hardcoded-record-id → allowlisted in Test.cls
        String accountId = '001xx000003GYkFAAW';
        System.assertNotEquals(null, accountId, 'Account ID should not be null');
    }

    @isTest
    static void testHardcodedCredentials() {
        // apex-hardcoded-credential → allowlisted in Test.cls
        String password = 'testPassword123';
        String pwd = 'dummyPwd123';
        System.assertNotEquals(null, password, 'Password should not be null');
        System.assertNotEquals(null, pwd, 'Pwd should not be null');
    }

    @isTest
    static void testAccountsWithPhone() {
        List<Account> accounts = [SELECT Id, Name, Phone FROM Account];
        System.assertEquals(2, accounts.size(), 'Expected 2 accounts');
        System.assertEquals('+91 9876543210', accounts[0].Phone, 'Phone should match');
    }
}
