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
      results << {'similarity' => similarity, 'article_id' => article.id}
    end
    results.sort_by{|r| r[:similarity]}.reverse[0..4]
  end

  def related_articles2

    begin
      ActiveRecord::Base.connection.execute('select vss_version()')
    rescue ActiveRecord::StatementInvalid
      ActiveRecord::Base.connection.raw_connection.enable_load_extension(true)
      ActiveRecord::Base.connection.raw_connection.load_extension('./lib/vector0')
      ActiveRecord::Base.connection.raw_connection.load_extension('./lib/vss0')
      Rails.logger.info("Enabled sqlite vss extension " +
        ActiveRecord::Base.connection.execute('select vss_version()').to_s)
    end

#byebug
    ActiveRecord::Base.connection.execute("select rowid as article_id, distance from vss_articles where vss_search(embedding, '#{embedding}') limit 5")
  end


end
