require 'ruby/openai'
require 'cosine_similarity'

class Question

  attr_reader :question

  def initialize(question)
    @question = question
  end

  def embedding
    return @embedding if @embedding
    openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    response = openai.embeddings(
      parameters: {
        model: "text-embedding-ada-002",
        input: @question
      }
    )
    unless response['data']
      Rails.logger.error(response.inspect)
    end
    @embedding = response['data'][0]['embedding']
  end

  def related_articles
    results = []
    Article.vectorized.find_each do |article|
      similarity = cosine_similarity(embedding, article.embedding) * 100
      similarity -= 2 if article.file =~ /kb/
      similarity = similarity.round(2)
      results << {similarity: similarity, article_id: article.id}
    end
    results.sort_by{|r| r[:similarity]}.reverse[0..4]
  end


end
