class Llm::Api
  def self.create
    @llm ||= api_class.new
  end

  def self.api_class
    if ENV["LLM"] == "ollama"
      Llm::Ollama
    else
      Llm::OpenAi
    end
  end
end
