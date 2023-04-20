require 'ruby/openai'

class Answer

  def initialize(question, article)
    @question = question
    @article = article
  end

  def generate

    # Note: limiting the article text because of max context length of 4096 tokens (incl. the 400 from the response)
    article_context = @article.text.split[0..900].join(' ')

    # Note: adding a '?' after the input, so the 'completions' endpoint doesn't try to
    # complete the question.
     Rails.logger.info "Article has #{@article.text.split.size} words"
    prompt =
    "You are an AI assistant. You work for the SUSE Customer Center team at SUSE which is a open source operating system.
    You will be asked questions from a customer and will answer in a helpful and friendly manner.
    You will be provided information from SUSE under the [Article] section. The customer question
    will be provided under the [Question] section. You will answer the customers questions only based on information
    from the article.
    If the users question is not answered by the article you will respond with 'I'm sorry Dave, I don't know.'
    [Article]
    #{article_context}
    [Question]
    #{@question.question}?"
    
		openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    # rate limits: https://platform.openai.com/docs/guides/rate-limits/overview
    # playground: https://platform.openai.com/playground
    response = openai.completions(
      parameters: {
        model: "text-davinci-003", # davinci: 1 token per minute
        prompt: prompt,
        temperature: 0.2, # low temperature = very high probability response
        max_tokens: 300,
      }
    )
    unless response['choices']
      Rails.logger.error(response.inspect)
      raise Exception.new("Generating answer failed: " + response['error'].inspect)
    end
    response['choices'][0]['text'].lstrip.sub('Answer: ', '')
  end

end
