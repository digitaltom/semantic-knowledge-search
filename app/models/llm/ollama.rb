require 'ollama-ai'
require 'sqlite_vec'
require 'vec'

class Llm::Ollama
  MODEL_EMBEDDINGS = 'llama3.1:8b'
  MODEL_CHAT = 'llama3.1:8b'
  TOKEN = ENV['OLLAMA_API_KEY']
  API_ENDPOINT = ENV['OLLAMA_API_ENDPOINT']

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

    # embedding size from ollama is 4096
    response[0]['embedding']
  end


  def chat(prompt, question, articles)
    response = Rails.cache.fetch("chat_#{question}/#{articles.map(&:id).join(',')}", expires_in: 48.hours) do
      result = @client.generate(
        {
          model: MODEL_CHAT,
          prompt: prompt,
          question: question,
          stream: false
        }
      )
    end

    response[0]['response'].strip.sub(/^[ ?!\.]*/, '')
  end
end
