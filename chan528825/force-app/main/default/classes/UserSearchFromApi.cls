public with sharing class UserSearchFromApi {

    public class FlowInput {
        @InvocableVariable(required=true)
        public String username;
    }
    public class FlowOutput {
        @InvocableVariable public Boolean found;
        @InvocableVariable public String name;
        @InvocableVariable public String email;
        @InvocableVariable public String company;
        @InvocableVariable public String rawJson;
    }

    @InvocableMethod(label='Search JSONPlaceholder User')
    public static List<FlowOutput> searchUser(List<FlowInput> inputs) {
        FlowOutput out = new FlowOutput();

        if (inputs == null || inputs.isEmpty() || String.isBlank(inputs[0].username)) {
            out.found = false;
            return new List<FlowOutput>{ out };
        }

        String endpoint = 'callout:JSONPlaceholder/users?username=' +
            EncodingUtil.urlEncode(inputs[0].username, 'UTF-8');

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(15000);

        try {
            HttpResponse res = h.send(req);
            out.rawJson = res.getBody();

            if (res.getStatusCode() != 200) {
                out.found = false;
                return new List<FlowOutput>{ out };
            }

            List<Object> listAny = (List<Object>) JSON.deserializeUntyped(res.getBody());
            if (listAny == null || listAny.isEmpty()) {
                out.found = false;
                return new List<FlowOutput>{ out };
            }

            Map<String, Object> user = (Map<String, Object>) listAny[0];
            out.found = true;
            out.name  = (String) user.get('name');
            out.email = (String) user.get('email');

            Map<String, Object> company = (Map<String, Object>) user.get('company');
            if (company != null) out.company = (String) company.get('name');

            return new List<FlowOutput>{ out };

        } catch (Exception e) {
            out.found = false;
            out.rawJson = 'Callout error: ' + e.getMessage();
            return new List<FlowOutput>{ out };
        }
    }
}

/*
 * 
 ****** Flow name =  Search JSONPlaceholder User

1. Create External Credential
External Credentials define the authentication method for a remote system.
Go to Setup → Search for Named Credentials.
Click External Credentials tab → New.
Fill in:
Label: JSONPlaceholder_External
Name: JSONPlaceholder_External
Authentication Protocol: No Authentication (because this API is public)
Save.
2. Create Named Credential
Named Credentials store the API endpoint URL and reference the External Credential.
Still in Named Credentials, click Named Credentials tab → New.
Fill in:
Label: JSONPlaceholder
Name: JSONPlaceholder
URL: https://jsonplaceholder.typicode.com
Enabled for Callouts: ✅
Under Authentication:
External Credential: Select JSONPlaceholder_External
Callout Options:
Check Generate Authorization Header (optional for public APIs; leave unchecked if not needed)
Save.
3. Add External Credential Principal
Principals define a user or system context that can use the External Credential.
Go to your External Credential (JSONPlaceholder_External).
Under Principals, click New.
Fill in:
Label: Public
Name: Public
Authentication Parameter: Leave blank (public API)
Save.
4. Create Permission Set for API Access
We need to give Salesforce users permission to use the External Credential.
Go to Setup → Permission Sets → New.
Fill in:
Label: EC JSONPlaceholder Access
API Name: auto-filled
Save.
5. Assign External Credential to Permission Set
Inside your new Permission Set, find External Credential Principal Access (search in the Permission Set menu).
Click Edit.
In Available External Credential Principals, select:
JSONPlaceholder_External - Public
Click Add → Save.
6. Assign Permission Set to User
Open your Permission Set → Click Manage Assignments.
Click Add Assignments.
Select your user → Assign.  */