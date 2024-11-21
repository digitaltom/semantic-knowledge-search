require 'ruby/openai'
require 'sqlite_vec'
require 'vec'

class Llm::OpenAi

  MODEL_EMBEDDINGS = "text-embedding-ada-002" # (Pricing: Ada $0.0004 / 1K tokens, https://openai.com/pricing)
  MODEL_CHAT = "gpt-4o-mini" # https://openai.com/pricing
  TOKEN = ENV['OPENAI_API_KEY']

  def initialize
    @client = OpenAI::Client.new(access_token: TOKEN)
  end

  def embeddings(text)
    response = @client.embeddings(
      parameters: {
        model: MODEL_EMBEDDINGS,
        input: text
      }
    )
    unless response['data']
      Rails.logger.error(response.inspect)
      raise Exception.new("Vectorizing failed")
    end

    # embedding size from openai is 1536
    response['data'][0]['embedding']
  end


  def chat(prompt, question, articles)
    # rate limits: https://platform.openai.com/docs/guides/rate-limits/overview
    # playground: https://platform.openai.com/playground

    response = Rails.cache.fetch("chat_#{question}/#{articles.map(&:id).join(',')}", expires_in: 48.hours) do
      @client.chat(
        parameters: {
          model: MODEL_CHAT,
          messages: [
            { role: 'system', content: prompt },
            { role: "user", content: question}],
          temperature: 0.2, # low temperature = very high probability response
          max_tokens: 300,
        }
      )
    end

    unless response['choices']
      Rails.logger.error(response.inspect)
      raise Exception.new("Generating answer failed: " + response['error'].inspect)
    end
    # strip punctuation from the beginning of the string if it was completed.
    response.dig("choices", 0, "message", "content").strip.sub(/^[ ?!\.]*/, '')
  end

end
