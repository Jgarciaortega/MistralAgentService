/** 
 * @description       : Apex class to wrap credentials to send via http request
 * @author            : jgarciaortega
 * @group             : 
 * @last modified on  : 28/10/2024
 * @last modified by  : 28/10/2024
 * @Created on        : 25/10/2024
 * @related           : DummyProductsCallOuts
**/
public with sharing class CredentialsWrapper {

    public String username;
    public String password;
    public String accessToken;
    public String id;

    public CredentialsWrapper(String userN, String pass){
        this.username = userN;
        this.password = pass;
    }
}