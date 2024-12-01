public with sharing class MistralAgentWrapper {

    public boolean stream;
    public Integer max_tokens;	//5000
	public String stop;	//string
	public Integer random_seed;	//0
	public List<cls_messages> messages;
	public cls_response_format response_format;
	public List<cls_tools> tools;
	public String tool_choice;	//auto
	public Integer presence_penalty;	//0
	public Integer frequency_penalty;	//0
	public Integer n;	//1
	public String agent_id;	//ag:2121a128:20241130:untitled-agent:54e0b65f

    public MistralAgentWrapper(){
        this.messages = new List<cls_messages>();
        this.tools = new List<cls_tools>();
    }

	public class cls_messages {
		public String role;	//user
		public String content;	//Hello, what´s your main job?
	}
	public class cls_response_format {
		public String type;	//text
	}
	public class cls_tools {
		public String type;	//function
		public cls_function function;
	}
	public class cls_function {
		public String name;	//string
		public String description;	//
		public cls_parameters parameters;
	}
	public class cls_parameters {
	}



}