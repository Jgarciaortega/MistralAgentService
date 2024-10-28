@isTest
public with sharing class DummyProductsCallOutsTest {

    private static final Integer HTTP_CODE_OK = 200;
    private static final String USER = 'Test Name';
    private static final String USERNAME = 'Test Username';
  
    private class SingleRequestMock implements HttpCalloutMock {

        private String body;
        private Integer httpResponse;

        public SingleRequestMock(String body, Integer resp) {
            this.body = body;
            this.httpResponse = resp;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(this.body);
            res.setStatusCode(this.httpResponse);
            return res;
        }
    }

    @isTest
    private static void getSessionCredentialsTest(){
  
        String fakeResponse = '{"accessToken": "123", "id": "1"}';
        Integer httpResponse = HTTP_CODE_OK;
        DummyProductsCallOuts dpC;

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(fakeResponse, httpResponse));

        Test.startTest();
        dpC = new DummyProductsCallOuts(USER, USERNAME);
        dpC.getSessionCredentials();

        Test.stopTest();

        Assert.areEqual('123', dpC.sessionCredentials.accessToken, 'Access Token hasn´t be set correctly.');
        Assert.areEqual('1', dpC.sessionCredentials.id, 'User Id hasn´t be set correctly.');

    }
    

    @isTest
    private static void getOneProductTest(){

        String fakeResponse = '{"title": "iphone" , "description": "red iphone"}';
        Integer httpResponse = HTTP_CODE_OK;
        DummyProductsCallOuts dpC;
        CredentialsWrapper sessionCredentials = new CredentialsWrapper(USER, USERNAME);
        sessionCredentials.accessToken = '123456';

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(fakeResponse,httpResponse));

        Test.startTest();

        dpC = new DummyProductsCallOuts(USER, USERNAME);
        dpC.isCurrentUserAuthorized = true;
        dpC.sessionCredentials = sessionCredentials;
        dpC.getOneProducts();

        Test.stopTest();

        List<Product2> prodCheck = [SELECT Name, Description FROM Product2 WHERE Name = 'iphone' AND Description = 'fake'];
        Assert.areEqual(0, prodCheck.size(), 'This record shouldn´t be persisted in database');
        prodCheck = [SELECT Name, Description FROM Product2 WHERE Name = 'iphone' AND Description = 'red iphone'];
        Assert.areEqual(1, prodCheck.size(), 'This record should be persisted in database');
       
    }

    @isTest
    private static void getAllProductTest(){

        String fakeResponse = '{"products":[{"title": "iphone" , "description": "iphone 15"},' +
                              '{"title": "samsung" , "description": "samsung galaxy"}]}';
        Integer httpResponse = HTTP_CODE_OK;
        DummyProductsCallOuts dpC;
        CredentialsWrapper sessionCredentials = new CredentialsWrapper(USER, USERNAME);
        sessionCredentials.accessToken = '123456';

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(fakeResponse,httpResponse));

        Test.startTest();

        dpC = new DummyProductsCallOuts(USER, USERNAME);
        dpC.isCurrentUserAuthorized = true;
        dpC.sessionCredentials = sessionCredentials;
        dpC.getAllProducts();

        Test.stopTest();

        List<Product2> prodCheck = [SELECT Name, Description FROM Product2 WHERE (Name = 'iphone' AND Description = 'iphone 15') OR 
        (Name = 'samsung' AND Description = 'samsung galaxy')];
        Assert.areEqual(2, prodCheck.size(), 'This records should be persisted in database');
     
    }

    @isTest
    private static void getProductWithBadHttpResponseTest(){

        String fakeResponse = '';
        Integer httpResponse = HTTP_CODE_OK;
        CredentialsWrapper sessionCredentials = new CredentialsWrapper(USER, USERNAME);
        sessionCredentials.accessToken = '123456';
        DummyProductsCallOuts dpC;

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(fakeResponse,httpResponse));

        Test.startTest();

        dpC = new DummyProductsCallOuts(USER, USERNAME);
        dpC.sessionCredentials = sessionCredentials;
        dpC.getOneProducts();

        Test.stopTest();

        Assert.areEqual(false, dpC.isCurrentUserAuthorized, 'Authorization user should be not authorized');
       
    }

    @isTest
    private static void getProductWithNoUserVerifiedTest(){

        String fakeResponse = '{"id": "2"}';
        Integer httpResponse = HTTP_CODE_OK;
        CredentialsWrapper sessionCredentials = new CredentialsWrapper(USER, USERNAME);
        sessionCredentials.accessToken = '123456';
        sessionCredentials.id = '1';
        DummyProductsCallOuts dpC;

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(fakeResponse,httpResponse));

        Test.startTest();

        dpC = new DummyProductsCallOuts(USER, USERNAME);
        dpC.sessionCredentials = sessionCredentials;
        dpC.getOneProducts();

        Test.stopTest();

        Assert.areEqual(false, dpC.isCurrentUserAuthorized, 'Authorization user should be not authorized');
       
    }


    
    @isTest
    private static void checkDuplicatesProductsTest(){

        String fakeResponse = '{"products":[{"title": "iphone" , "description": "iphone 15"}, ' +
                              '{"title": "samsung" , "description": "samsung galaxy"}]}';
        Integer httpResponse = HTTP_CODE_OK;
        DummyProductsCallOuts dpC;
        CredentialsWrapper sessionCredentials = new CredentialsWrapper(USER, USERNAME);
        sessionCredentials.accessToken = '123456';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(fakeResponse,httpResponse));

        Product2 prod = new Product2 (Name = 'iphone', Description = 'iphone red color');
        insert prod;

        Test.startTest();

        dpC = new DummyProductsCallOuts(USER, USERNAME);
        dpC.sessionCredentials = sessionCredentials;
        dpC.isCurrentUserAuthorized = true;
        dpC.getAllProducts();

        Test.stopTest();

        List<Product2> prodCheck = [SELECT Name, Description FROM Product2 WHERE Name = 'iphone' AND Description = 'iphone 15'];
        Assert.areEqual(0, prodCheck.size(), 'This record shouldn´t be persisted in database');
    }

    @isTest
    private static void checkUserAuthTest(){

        String fakeResponse = '{"id": "1" , "username": "test"}';          
        Integer httpResponse = HTTP_CODE_OK;
        CredentialsWrapper sessionCredentials = new CredentialsWrapper(USER, USERNAME);
        sessionCredentials.accessToken = '123456';
        sessionCredentials.id = '1';
        DummyProductsCallOuts dpC;

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(fakeResponse,httpResponse));
        
        Test.startTest();
        dpC = new DummyProductsCallOuts(USER, USERNAME);
        dpC.sessionCredentials = sessionCredentials;
        dpC.getOneProducts();
        Test.stopTest();

        Assert.areEqual(true, dpC.isCurrentUserAuthorized, 'User should be authorized');

    }

}