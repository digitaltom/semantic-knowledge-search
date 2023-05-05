require 'ruby/openai'
require 'cosine_similarity'
require 'vss0'

class Question

  attr_reader :question

  MODEL = "text-embedding-ada-002" # (Pricing: Ada $0.0004 / 1K tokens, https://openai.com/pricing)

  def initialize(question)
    @question = question
  end

  def embedding
    Rails.cache.fetch("question_embedding_#{question}", expires_in: 48.hours) do
      openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
      response = openai.embeddings(
        parameters: {
          model: MODEL,
          input: @question
        }
      )
      unless response['data']
        Rails.logger.error(response.inspect)
        raise Exception.new("Vectorizing question failed")
      end
      embedding = response['data'][0]['embedding']
      Rails.logger.info("Generated embedding for '#{@question}' (#{embedding.size} vectors)")
      embedding
    end
  end

  def related_articles(vss: true)
    if vss
      Rails.cache.fetch("articles_#{embedding}", expires_in: 48.hours) do
        ensure_vss0
        begin
          ActiveRecord::Base.connection.execute("select rowid as article_id, distance from vss_articles where vss_search(embedding, '#{embedding}') limit 5")
        rescue => e
          # vss raises on select on empty db
          []
        end
      end
    else
      results = []
      Article.vectorized.find_each do |article|
        similarity = cosine_similarity(embedding, article.embedding) * 100
        similarity -= 2 if article.file =~ /kb/
        similarity = similarity.round(2)
        results << {'similarity' => similarity, 'article_id' => article.id}
      end
      results.sort_by{|r| r['similarity']}.reverse[0..4]
    end
  end

end
