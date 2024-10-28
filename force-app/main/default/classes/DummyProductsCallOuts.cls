/**
 * @description       : Apex class to get products from API service (https://dummyjson.com)
 * @author            : jgarciaortega
 * @group             : 
 * @last modified on  : 28/10/2024
 * @last modified by  : 28/10/2024
 * @Created on        : 25/10/2024
 * @related           : DummyProductsWrapper , CredentialWrapper
**/

public with sharing class DummyProductsCallOuts {

    private static final String END_POINT_GET_ALL_PRODUCTS = 'https://dummyjson.com/products';
    private static final String END_POINT_GET_ONE_PRODUCT = 'https://dummyjson.com/products/1';
    private static final String END_POINT_GET_CURRENT_USER = 'https://dummyjson.com/auth/me';
    private static final String END_POINT_AUTH = 'https://dummyjson.com/auth/login'; 
    private static final String POST_METHOD = 'POST';
    private static final String GET_METHOD = 'GET';
    private static final String[] HEADER_CONTENT_TYPE = new string[] {'Content-Type', 'application/json'};
    private static final String[] HEADER_AUTH = new string[] {'Authorization', 'Bearer'};
    private static final Integer HTTP_CODE_OK = 200;

    public CredentialsWrapper loginCredentials;
    public CredentialsWrapper sessionCredentials;
    public Boolean isCurrentUserAuthorized;

    /**
	* @description Constructor DummyProductsCallOuts
	* @param name String  
	* @param username Case  
	**/
    public DummyProductsCallOuts(String name, String username){
       this.loginCredentials = new CredentialsWrapper(name, username); 
       this.isCurrentUserAuthorized = false;
    }
    
	/**
	* @description Method to get credentials from service and wrap it in a CredentialWrapper object
	* 
	**/
    @AuraEnabled(cacheable=true)
    public void getSessionCredentials(){

        HttpRequest req = new HttpRequest();
        Http http = new Http();
    
        req.setEndpoint(END_POINT_AUTH);
        req.setMethod(POST_METHOD);
        req.setHeader(HEADER_CONTENT_TYPE[0],HEADER_CONTENT_TYPE[1]);
        req.setBody(JSON.serialize(this.loginCredentials));

        try{

            HttpResponse res = http.send(req); 
            
            if(res.getStatusCode() == HTTP_CODE_OK){
                this.sessionCredentials = (CredentialsWrapper) JSON.deserialize(res.getBody(), CredentialsWrapper.class);
            }else{
                System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.getSessionCredentials no ok http response ');
            }
       
        }catch(CalloutException cE){
            System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.getSessionCredentials error. CallOut error Msg => ' + cE.getMessage());
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.getSessionCredentials error. Msg => ' + e.getMessage());
        }
    }

    /**
	* @description Method to get all products from api endpoint
	* 
	**/
    @AuraEnabled(cacheable=true)
    public void getAllProducts() {

        String body;
        DummyProductsWrapper prodWrapper;

        checkUserAuthorization();
        if(this.isCurrentUserAuthorized){

            body = doGetCallOut(END_POINT_GET_ALL_PRODUCTS, null);
            try{
                prodWrapper = (DummyProductsWrapper) JSON.deserialize(body,DummyProductsWrapper.class);
                if(prodWrapper != null && prodWrapper.products != null && prodWrapper.products.size() > 0){
                    insertProducts(prodWrapper.products);
                }
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.getAllProducts error. Msg => ' + e.getMessage());
            }     
        }
    }

    /**
	* @description Method to get one products from api endpoint
	* 
	**/
    @AuraEnabled(cacheable=true)
    public void getOneProducts() {

        String body;
        DummyProductsWrapper.DummyProduct dummyProduct;
        List <DummyProductsWrapper.DummyProduct> lProducts;

        checkUserAuthorization();
        if(this.isCurrentUserAuthorized){

            body = doGetCallOut(END_POINT_GET_ONE_PRODUCT, null);

            try{
                dummyProduct = (DummyProductsWrapper.DummyProduct) JSON.deserialize(body,DummyProductsWrapper.DummyProduct.class);
                if(dummyProduct != null && dummyProduct.title != null){
                    lProducts = new List<DummyProductsWrapper.DummyProduct>();
                    lProducts.add(dummyProduct);
                    insertProducts(lProducts);
                }         
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.getOneProducts error. Msg => ' + e.getMessage());
            }             
        }
    }

    /**
    * @description Method that check user authorization 
    * 
    **/
   private void checkUserAuthorization(){

        String[] headerCurrentUser;
        String body;
        CredentialsWrapper currentUserCredentials;
        this.isCurrentUserAuthorized = false;

        if(this.sessionCredentials != null && this.sessionCredentials.accessToken != null){
            
            headerCurrentUser = new string[] {HEADER_AUTH[0], HEADER_AUTH[1] + ' ' + this.sessionCredentials.accessToken};
            body = doGetCallOut(END_POINT_GET_CURRENT_USER, headerCurrentUser);
                    
            try{
                currentUserCredentials = (CredentialsWrapper) JSON.deserialize(body, CredentialsWrapper.class);
                if(currentUserCredentials != null && currentUserCredentials.id == this.sessionCredentials.id){
                    this.isCurrentUserAuthorized = true;
                }
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.checkUserAuthorization error.Msg => ' + e.getMessage());
            }

        }
   }

   /**
    * @description Generic method to do a get http request
    * @return body String with http response
    **/
    private String doGetCallOut(String endPoint, String[] header){

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String body;
        HTTPResponse res;

        req.setEndpoint(endPoint);
        req.setMethod(GET_METHOD);

        if(header != null && header.size() > 0){
            req.setHeader(header[0],header[1]);
        }

        try{
            res = http.send(req);
            body = res.getBody();
        }catch(CalloutException cE){
            System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.doGetCallOut. Callout error => ' + cE.getMessage());
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.doGetCallOut. Msg => ' + e.getMessage());
        }
        
        return body;

   }

    /**
    * @description Method to persist products in bbdd
    * @param lProducts List<DummyProductsWrapper.DummyProduct> 
    **/
   private void insertProducts(List<DummyProductsWrapper.DummyProduct> lProducts){

        List<Product2> productsToInsert = new List<Product2>();

        if(lProducts != null && lProducts.size() > 0) {
            productsToInsert = checkDuplicates(lProducts);   
        }

        try{
            Database.insert(productsToInsert, false, AccessLevel.USER_MODE);

        }catch(DmlException ex){
            System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.insertProducts. Error DML => ' + ex.getMessage());
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'DummyProductsCallOuts.insertProducts. Msg => ' + e.getMessage());
        }

    }
    
    /**
    * @description Method to avoid duplicates products insertions in bbdd (same title name in api)
    * @param lProducts List<DummyProductsWrapper.DummyProduct> 
    * @return List<Product2> without duplicates and ready to persist
    **/
    private static List<Product2> checkDuplicates (List<DummyProductsWrapper.DummyProduct> lProducts){

        Set<String> newTitles = new Set<String>();
        Map<String, Product2> titleProductMap = new Map<String, Product2>();
        List<Product2> productsDuplicated = new List <Product2>();

        for(DummyProductsWrapper.DummyProduct pW: lProducts){
            titleProductMap.put(pW.title, new Product2(Name = pW.title, Description= pW.description));
            newTitles.add(pw.title);
        }

        productsDuplicated = [SELECT Id, Name FROM Product2 WHERE Name In: newTitles WITH SYSTEM_MODE];

        if(productsDuplicated != null && productsDuplicated.size() > 0){
            for(Product2 p: productsDuplicated){
                titleProductMap.remove(p.Name);
            }
        }
        return titleProductMap.values();
    }
}