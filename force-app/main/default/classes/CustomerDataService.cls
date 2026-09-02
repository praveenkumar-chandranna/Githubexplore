public class CustomerDataService {

    // Hardcoded PII - Aadhaar, PAN, mobile, email
    private static final String AADHAAR_NUMBER = '1234-5678-9012';
    private static final String PAN_NUMBER = 'ABCDE1234F';
    private static final String MOBILE_NUMBER = '9876543210';
    private static final String EMAIL_ADDRESS = 'john.doe@example.com';

    // Hardcoded Salesforce secret / token
    private static final String SF_ACCESS_TOKEN = '00D5g000004xyzABC!ARoAQHelloWorldTokenHardcoded123456';
    private static final String AWS_SECRET_KEY = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY';

    public static void processCustomer() {
        String customerAadhaar = '9876-5432-1098';
        String customerPAN = 'ZYXWV9876K';
        String customerMobile = '+91-9123456789';
        String customerEmail = 'jane.smith@company.org';
        String passportNumber = 'A1234567';
        String bankAccount = '001234567890';

        System.debug('Processing customer: ' + customerEmail);
        System.debug('Aadhaar: ' + customerAadhaar);
        System.debug('PAN: ' + customerPAN);
    }

    public static Contact createContact() {
        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Doe';
        c.Email = 'john.doe@example.com';
        c.Phone = '9876543210';
        c.Description = 'Aadhaar: 2345-6789-0123, PAN: PQRST5678U';
        return c;
    }
}
