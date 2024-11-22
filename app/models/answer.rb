require 'ruby/openai'

class Answer

  def initialize(question, articles)
    @question = question
    @articles = articles
  end

  def generate
    # Note: limiting the article text because of max context length of 4096 tokens (incl. the 400 from the response)
    article_context = @articles[0..2].map(&:text).join(' ')

    #Rails.logger.info "Article has #{@article.text.split.size} words, using 900."
    prompt =
    "You are an knowledge search assistant answering customer requests based on performing a
    semantic search over documentation and knowledge base articles.
    You will answer in a helpful and friendly manner.
    You will be provided information after the keyword [Articles] below.
    You will answer the customer's requests only based on information from this chat.
    All of your knowledge only comes from this chat message.
    If the customer's request is not answered below, you will respond with
    'I'm sorry Dave, I don't know.'
    [Articles]
    #{article_context}"

    Llm::Api.create.generate(prompt, @question.question, @articles)
  end

end
