/**
 * GitleaksViolationDemo.cls
 * ─────────────────────────────────────────────────────────────
 * PURPOSE : Demonstrates Gitleaks rule violations.
 *           This file should be flagged by the scanner.
 *
 * RULES TRIGGERED:
 *   sf-consumer-key            → hardcoded Salesforce consumer key
 *   sf-consumer-secret         → hardcoded consumer secret
 *   sf-access-token            → hardcoded access token
 *   sf-sfdx-auth-url           → SFDX auth URL with credentials
 *   sf-my-domain-hardcoded     → hardcoded My Domain URL
 *   sf-hardcoded-record-id     → hardcoded record ID in field assignment
 *   apex-debug-sensitive       → System.debug with password/token
 *   apex-hardcoded-credential  → password = 'hardcoded'
 *   apex-soql-hardcoded-id     → WHERE Id = '001xx...'
 *   named-credential-hardcoded → direct endpoint URL
 *   private-key-pem            → PEM private key block
 *   generic-password           → pwd = 'secret'
 *   generic-secret             → api_key = 'value'
 *   jwt-token                  → eyJ... JWT format
 *   aws-access-key-id          → AKIA... key
 *   aws-secret-access-key      → aws_secret_access_key
 *   indian-aadhaar             → 12-digit Aadhaar
 *   indian-pan                 → PAN card format
 *   indian-mobile-labeled      → mobile = +91...
 *   indian-mobile-bare         → bare 10-digit number
 *   email-hardcoded            → quoted email
 *   indian-passport            → passport number
 *   indian-bank-account        → account_no = ...
 *   indian-ifsc                → IFSC code
 *   indian-gst                 → GST number
 *   profanity-in-code          → offensive word
 * ─────────────────────────────────────────────────────────────
 */
public class GitleaksViolationDemo {

    // ── Salesforce Credentials ────────────────────────────────

    // sf-consumer-key
    String consumerKey = '3MVG9ZL0ppAP1UkjlhOGkFakeConsumerKeyValueForTestingPurposesOnly';

    // sf-consumer-secret
    String consumerSecret = 'ABCD1234EFGH5678IJKL';

    // sf-access-token
    String accessToken = 'access_token=00Dxx0000001gPLFakeAccessTokenValueForTestingPurposes';

    // sf-sfdx-auth-url
    String sfdxUrl = 'force://fakekey:fakesecret@lodha.my.salesforce.com';

    // sf-my-domain-hardcoded
    String instanceUrl = 'https://lodha-dev.my.salesforce.com';

    // ── Salesforce Record IDs ─────────────────────────────────

    // sf-hardcoded-record-id
    String accountId = '001xx000003GYkFAAW';

    // apex-soql-hardcoded-id
    public static Account getAccount() {
        return [SELECT Id, Name FROM Account WHERE Id = '001xx000003GYkFAAW' LIMIT 1];
    }

    // ── Apex Patterns ─────────────────────────────────────────

    // apex-debug-sensitive
    public static void logSensitive(String password) {
        System.debug('User password: ' + password);
        System.debug('token value: ' + password);
    }

    // apex-hardcoded-credential
    String password = 'Sup3rS3cr3tP@ss';

    // named-credential-hardcoded
    String endpoint = 'https://api.externalservice.com/v1/data';

    // ── Private Key ───────────────────────────────────────────

    // private-key-pem
    String privateKey = '-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAfakekey\n-----END RSA PRIVATE KEY-----';

    // ── Generic Secrets ───────────────────────────────────────

    // generic-password
    String pwd = 'MyH@rdcodedPwd';

    // generic-secret
    String api_key = 'sk-fakeapikey1234567890';

    // jwt-token
    String jwtToken = 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ0ZXN0QHRlc3QuY29tIn0.fakeSignatureValue123';

    // ── AWS ───────────────────────────────────────────────────

    // aws-access-key-id
    String awsKey = 'AKIAFAKEAWSACCESSKEY1';

    // aws-secret-access-key
    String aws_secret_access_key = 'FakeAWSSecretKey1234567890abcdefghijklmn';

    // ── Indian PII ────────────────────────────────────────────

    // indian-aadhaar
    String aadhaar = '2345 6789 0123';

    // indian-pan
    String pan = 'ABCPF1234D';

    // indian-mobile-labeled
    String mobile = '+91 9876543210';

    // indian-mobile-bare
    String contactNo = '9876543210';

    // email-hardcoded
    String email = 'john.doe@somecompany.in';

    // indian-passport
    String passport = 'A1234567';

    // indian-bank-account
    String account_no = '123456789012';

    // indian-ifsc
    String ifsc = 'HDFC0001234';

    // indian-gst
    String gst = '27ABCPF1234D1Z5';

    // ── Profanity ─────────────────────────────────────────────

    // profanity-in-code
    // TODO: fix this shit logic later
    public static void badlyNamedMethod() {
        Integer x = 1;
    }
}
