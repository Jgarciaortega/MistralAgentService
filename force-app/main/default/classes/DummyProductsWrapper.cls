/**
 * @description       : Apex class to wrap json response from api service (https://dummyjson.com)
 * @author            : jgarciaortega
 * @group             : 
 * @last modified on  : 28/10/2024
 * @last modified by  : 28/10/2024
 * @Created on        : 25/10/2024
 * @related           : DummyProductsCallOuts
**/

public with sharing class DummyProductsWrapper {

    public List<DummyProduct> products;

	public class DummyProduct {
		public String title;
		public String description;
	}
}