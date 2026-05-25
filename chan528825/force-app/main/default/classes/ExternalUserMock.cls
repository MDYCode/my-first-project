@isTest
global class ExternalUserMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String jsonResponse = '[{"name":"Leanne Graham","email":"rey.padberg@karina.biz","phone":"1-770-736-8031","username":"Bret"}]';
        
        res.setBody(jsonResponse);
        return res;
    }
}