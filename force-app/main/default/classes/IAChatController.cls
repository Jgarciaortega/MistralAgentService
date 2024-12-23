public with sharing class IAChatController {


    @AuraEnabled
    public static String handleInputText(String inputText) {
        return MistralCallOuts.chatWithAgent(inputText);
    }


}