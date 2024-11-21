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
    
    Llm::Ollama.new.chat(prompt, @question.question, @articles)
  end

end
