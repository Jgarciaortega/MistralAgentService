public class MistralAgentResponseWrapper{
	public String id;	//f67b8e97095741f59546358435b6e707
	public Integer created;	//1733061244
	public String model;	//open-mistral-nemo
	public cls_choices[] choices;
	public cls_usage usage;
	public class cls_choices {
		public Integer index;	//0
		public cls_message message;
		public String finish_reason;	//stop
	}
	public class cls_message {
		public String role;	//assistant
		public String content;	//I'm here to assist you! I can answer questions, provide explanations, or just chat if you're up for it. How about you? What do you do?
		public cls_tool_calls tool_calls;
	}
	class cls_tool_calls {
	}
	class cls_usage {
		public Integer prompt_tokens;	//43
		public Integer total_tokens;	//77
		public Integer completion_tokens;	//34
	}

}