class Llm::Api
  def self.create
    if ENV["LLM"] == "ollama"
      @llm ||= Llm::Ollama.new
    else
      @llm ||= Llm::OpenAi.new
    end
  end
end
