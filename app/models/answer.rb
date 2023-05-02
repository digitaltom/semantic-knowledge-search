require 'ruby/openai'

class Answer

  MODEL = "gpt-3.5-turbo" # https://openai.com/pricing

  def initialize(question, article)
    @question = question
    @article = article
  end

  def generate
    # Note: limiting the article text because of max context length of 4096 tokens (incl. the 400 from the response)
    article_context = @article.text.split[0..900].join(' ')

    Rails.logger.info "Article has #{@article.text.split.size} words, using 900."
    prompt =
    "You are an AI assistant answering customer requests based on performing a
    semantic search over SUSE documentation and knowledge base articles.
    You will answer in a helpful and friendly manner.
    You will be provided information from SUSE under the [Article] section.
    The customer request will be provided under the [Question] section.
    You will answer the customer's requests only based on information from the article.
    If the customer's request is not answered by the article you will respond with
    'I'm sorry Dave, I don't know.'
    [Article]
    #{article_context}"
    
		openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    # rate limits: https://platform.openai.com/docs/guides/rate-limits/overview
    # playground: https://platform.openai.com/playground

    response = Rails.cache.fetch("chat_#{@question.question}/#{@article.id}", expires_in: 48.hours) do
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
