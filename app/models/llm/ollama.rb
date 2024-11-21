require 'ollama-ai'
require 'sqlite_vec'
require 'vec'

class Llm::Ollama
  MODEL_EMBEDDINGS = 'llama3.1:8b'
  MODEL_CHAT = 'llama3.1:8b'

  TOKEN = ENV['OLLAMA_API_KEY']
  API_ENDPOINT = ENV['OLLAMA_API_ENDPOINT']

  # Number of embeddings returned by the LLM API
  # Needs to be aligned with the embeddings column size
  MAX_EMBEDDINGS = 4096

  # https://github.com/gbaptista/ollama-ai
  def initialize
    @client = Ollama.new(
      credentials: {
        address: API_ENDPOINT,
        bearer_token: TOKEN
      },
      options: { server_sent_events: true }
    )
  end

  def embeddings(text)
    response = @client.embeddings(
      {
        model: MODEL_EMBEDDINGS,
        prompt: text,
        options: {}
      }
    )
    unless response[0]['embedding']
      Rails.logger.error(response.inspect)
      raise Exception.new("Vectorizing failed")
    end
    response[0]['embedding']
  end


  def chat(prompt, question, articles)
    response = Rails.cache.fetch("chat_#{question}/#{articles.map(&:id).join(',')}", expires_in: 48.hours) do
      result = @client.chat(
        {
          model: MODEL_CHAT,
          messages: [
            { role: "user", content: prompt },
            { role: "user", content: question}],
          stream: false
        }
      )
      unless result.first['message']
        Rails.logger.error(result.inspect)
        raise Exception.new("Generating answer failed")
      end
      result.first['message']['content']
    end
  end

  def inspect
    puts("Using Ollama LLM backend (API: #{API_ENDPOINT}, model: #{MODEL_CHAT})")
  end

end
