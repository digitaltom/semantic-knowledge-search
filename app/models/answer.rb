require 'ruby/openai'

class Answer

  MODEL = "gpt-4o-mini" # https://openai.com/pricing

  def initialize(question, articles)
    @question = question
    @articles = articles
  end

  def generate
    # Note: limiting the article text because of max context length of 4096 tokens (incl. the 400 from the response)
    article_context = @articles[0..2].map(&:text).join(' ')

    #Rails.logger.info "Article has #{@article.text.split.size} words, using 900."
    prompt =
    "You are an AI assistant answering customer requests based on performing a
    semantic search over documentation and knowledge base articles.
    You will answer in a helpful and friendly manner.
    You will be provided information under the [Articles] section.
    You will answer the customer's requests only based on information from the article.
    All of your knowledge only comes from the articles content.
    If the customer's request is not answered by the articles you will respond with
    'I'm sorry Dave, I don't know.'
    [Articles]
    #{article_context}"
    
		openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    # rate limits: https://platform.openai.com/docs/guides/rate-limits/overview
    # playground: https://platform.openai.com/playground

    response = Rails.cache.fetch("chat_#{@question.question}/#{@articles.map(&:id).join(',')}", expires_in: 48.hours) do
      openai.chat(
        parameters: {
          model: MODEL,
          messages: [
            { role: 'system', content: prompt },
            { role: "user", content: @question.question}],
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
