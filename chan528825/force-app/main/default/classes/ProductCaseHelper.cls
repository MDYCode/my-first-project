public class ProductCaseHelper {

    // ၁။ Input Data ပုံစံကို သတ်မှတ်ခြင်း
    public class CaseRequest {
        @InvocableVariable(label='Product Name' required=true)
        public String productName;
        
        @InvocableVariable(label='Customer Email' required=true)
        public String customerEmail;
    }

    // ၂။ Output Data (အဖြေ) ပုံစံကို သတ်မှတ်ခြင်း
    public class CaseResult {
        @InvocableVariable(label='Created Case ID')
        public String caseId;
    }

    // ၃။ ပင်မ Logic (Flow ကနေ လှမ်းခေါ်မယ့်နေရာ)
    @InvocableMethod(label='Create Support Case' description='Product အလိုက် Case အသစ်ဖွင့်ပေးခြင်း')
    public static List<CaseResult> createCase(List<CaseRequest> requests) {
        List<CaseResult> results = new List<CaseResult>();

        for (CaseRequest req : requests) {
            CaseResult res = new CaseResult();
            
            // Case record အသစ်တစ်ခုကို Memory ထဲမှာ အရင်ဆောက်တယ်
            Case c = new Case();
            c.Subject = 'New Order Inquiry: ' + req.productName;
            c.Description = 'Customer reached out for ' + req.productName;
            c.Status = 'New';
            c.Origin = 'Web';
            c.SuppliedEmail = req.customerEmail;
            
            insert c; // Database ထဲ ထည့်လိုက်ပြီ

            res.caseId = c.Id; // ရလာတဲ့ ID ကို result ထဲ ထည့်တယ်
            results.add(res);
        }
        
        return results; // Flow ဆီကို အဖြေပြန်ပို့တယ်
    }
}