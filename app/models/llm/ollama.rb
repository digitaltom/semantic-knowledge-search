require 'ruby/openai'
require 'sqlite_vec'
require 'vec'

class Llm::OpenAi

  MODEL_EMBEDDINGS = "llama3.1:8b"
  MODEL_CHAT = "llama3.1:8b"
  TOKEN = ENV['OLLAMA_API_KEY']

  def initialize

  end

  def embeddings(text)

  end


  def chat(prompt, question, articles)


end
