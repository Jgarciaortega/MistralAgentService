public with sharing class MistralCallOuts {

    private static final String BASE_URL = 'https://api.mistral.ai/v1';
    private static final String AGENT_URL = '/agents/completions';
    private static final String FIRST_KEY = 'zkV6tIQfewhb9w8SerCMSZRbdmrRF6wQ';
    private static final String POST_METHOD = 'POST';
    private static final String GET_METHOD = 'GET';
    private static final String AGENT_ID = 'ag:2121a128:20241130:untitled-agent:54e0b65f';
    private static final Integer HTTP_CODE_OK = 200;
    private static final String[] HEADER_CONTENT_TYPE = new string[] {'Content-Type', 'application/json'};
    private static final String[] HEADER_ACCEPT = new string[] {'Accept', 'application/json'};
    private static final String[] HEADER_AUTH = new string[] {'Authorization', 'Bearer '};

 
    @AuraEnabled(Cacheable = false)
    public static void chatWithAgent(String inputText){

        MistralAgentWrapper agentWrapper = createAgentRequest();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
    
        req.setEndpoint(BASE_URL + AGENT_URL);
        req.setMethod(POST_METHOD);
        req.setHeader(HEADER_CONTENT_TYPE[0], HEADER_CONTENT_TYPE[1]);
        req.setHeader(HEADER_ACCEPT[0], HEADER_ACCEPT[1]);
        req.setHeader(HEADER_AUTH[0], HEADER_AUTH[1] + FIRST_KEY);
        req.setBody(JSON.serialize(agentWrapper));

        try{

            HttpResponse res = http.send(req); 

            if(res.getStatusCode() == HTTP_CODE_OK){
                MistralAgentResponseWrapper response = (MistralAgentResponseWrapper) JSON.deserialize(res.getBody(), MistralAgentResponseWrapper.class);
                System.debug('Response => ' + response.choices[0].message.content);
            }else{
                System.debug(LoggingLevel.ERROR, 'Status ERROR: ' + res.getStatusCode());
                System.debug(LoggingLevel.ERROR, res.getBodyDocument());
            }

        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'MistralCallOut.chatWithAgent error. Msg => ' + e.getMessage());
        }

    }

    private static MistralAgentWrapper createAgentRequest(){

        MistralAgentWrapper agentWrapper = new MistralAgentWrapper();
        agentWrapper.max_tokens = 1000;
        agentWrapper.stream = true;
        agentWrapper.stop = '20s';
        agentWrapper.random_seed = 0;
        agentWrapper.agent_id = AGENT_ID;
        agentWrapper.n = 1;
        agentWrapper.presence_penalty = 0;

        MistralAgentWrapper.cls_messages msg = new MistralAgentWrapper.cls_messages();
        msg.role = 'user';
        msg.content = 'Hi, What is your main job?';
        agentWrapper.messages.add(msg);

        MistralAgentWrapper.cls_tools tools = new MistralAgentWrapper.cls_tools();
        tools.type = 'function';
        MistralAgentWrapper.cls_function functions = new MistralAgentWrapper.cls_function();
        MistralAgentWrapper.cls_parameters parameters = new MistralAgentWrapper.cls_parameters();
        functions.name = 'string';
        functions.description = '';
        functions.parameters = parameters;
        tools.function = functions;

        agentWrapper.tools.add(tools);
        agentWrapper.frequency_penalty = 0;
        agentWrapper.random_seed = 0;
        agentWrapper.stream = false;
        agentWrapper.tool_choice = 'auto';
        
        MistralAgentWrapper.cls_response_format response_format = new MistralAgentWrapper.cls_response_format();
        response_format.type = 'text';
        agentWrapper.response_format = response_format;

        return agentWrapper;   
    }

}